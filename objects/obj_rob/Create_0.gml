
// --- ESTADO E POSIÇÃO INICIAL ---
x = 32;
y = 32;

enum ESTADO_ROBO {
    BUSCANDO,
    CONTORNANDO,
    RECUPERANDO, 
    PRESO,      
    ALCANCADO
}
estado = ESTADO_ROBO.BUSCANDO;

// --- TIMERS E CONTROLES DE RECUPERAÇÃO (NOVO) ---
stuck_timer = 0;
recovery_timer = 0;
recovery_turn_direction = 1; // 1 para direita, -1 para esquerda

// --- ATRIBUTOS DE MOVIMENTO (MODELO FÍSICO) ---
linear_velocity = 0;
angular_velocity = 0;

// Parâmetros do robô físico
ROBOT_RADIUS = 12;
WHEEL_BASE = 28; 
MAX_SPEED = 60;
MAX_TURN_RATE = pi;
MAX_LINEAR_ACCEL = 40;
MAX_ANGULAR_ACCEL = pi * 1.5;

// --- ATRIBUTOS DOS SENSORES ---
distancia_sensor = 80;
angulos_sensores = [0, -30, 30, -60, 60, -90, 90, -135, 135];
leituras_sensores = array_create(array_length(angulos_sensores));

// --- PARÂMETROS DO DWA ---
DWA_SIM_TIME = 0.8;
DWA_TIME_STEP = 0.1;
DWA_VELOCITY_SAMPLES = 6;
DWA_ROTATION_SAMPLES = 17;

// --- PARÂMETROS DOS CAMPOS POTENCIAIS (APF) ---
APF_ATTRACTIVE_GAIN = 0.015; 
APF_REPULSIVE_GAIN = 4000;
DWA_APF_HEADING_BIAS = 2.0;

// --- PARÂMETROS DE CONTORNO DE PAREDE ---
WALL_FOLLOW_DISTANCE = 32;
WALL_FOLLOW_GAIN = 0.1;

#region // --- Métodos de Navegação ---
sense_environment = function() {
    for (var i = 0; i < array_length(angulos_sensores); i++) {
        var _sensor_angle_deg = direction + angulos_sensores[i];
        var _hit_dist = distancia_sensor;
        var _step = 4;
        for (var d = 0; d < distancia_sensor; d += _step) {
            var _check_x = x + lengthdir_x(d, _sensor_angle_deg);
            var _check_y = y + lengthdir_y(d, _sensor_angle_deg);
            if (position_meeting(_check_x, _check_y, obj_obstaculo)) {
                _hit_dist = d;
                break;
            }
        }
        var _end_x = x + lengthdir_x(_hit_dist, _sensor_angle_deg);
        var _end_y = y + lengthdir_y(_hit_dist, _sensor_angle_deg);
        leituras_sensores[i] = [_hit_dist, _end_x, _end_y];
    }
}

dynamic_window_approach = function() {
    if (estado == ESTADO_ROBO.CONTORNANDO) {
        var _angle_to_goal = point_direction(x, y, obj_goal.x, obj_goal.y);
        var _angle_diff = abs(angle_difference(direction, _angle_to_goal));
        var _front_sensor_dist = leituras_sensores[0][0];
        if (_angle_diff < 45 && _front_sensor_dist >= distancia_sensor * 0.8) {
            estado = ESTADO_ROBO.BUSCANDO;
        }
    }
    var _dt_sec = delta_time / 1000000;
    var _v_min = max(0, linear_velocity - MAX_LINEAR_ACCEL * _dt_sec);
    var _v_max = min(MAX_SPEED, linear_velocity + MAX_LINEAR_ACCEL * _dt_sec);
    var _w_min = max(-MAX_TURN_RATE, angular_velocity - MAX_ANGULAR_ACCEL * _dt_sec);
    var _w_max = min(MAX_TURN_RATE, angular_velocity + MAX_ANGULAR_ACCEL * _dt_sec);
    var _v_step = (DWA_VELOCITY_SAMPLES > 1) ? (_v_max - _v_min) / (DWA_VELOCITY_SAMPLES - 1) : 0;
    var _w_step = (DWA_ROTATION_SAMPLES > 1) ? (_w_max - _w_min) / (DWA_ROTATION_SAMPLES - 1) : 0;
    var _best_score = -infinity;
    var _best_v = 0;
    var _best_w = 0;
    for (var v = _v_min; v <= _v_max; v += _v_step) {
        for (var w = _w_min; w <= _w_max; w += _w_step) {
            if (!is_trajectory_safe(v, w)) continue;
            var _total_score = 0;
            if (estado == ESTADO_ROBO.CONTORNANDO) {
                _total_score = calculate_wall_follow_score(v, w);
            } else {
                var _end_pos = simulate_trajectory_endpoint(v, w);
                var _potential_score = calculate_potential_at(_end_pos.x, _end_pos.y);
                var _heading_score = calculate_heading_score_for_apf(v, w);
                _total_score = -_potential_score + (_heading_score * DWA_APF_HEADING_BIAS);
            }
            if (_total_score > _best_score) {
                _best_score = _total_score;
                _best_v = v;
                _best_w = w;
            }
            if (_w_step == 0) break;
        }
        if (_v_step == 0) break;
    }
    if (_best_score == -infinity) {
        estado = ESTADO_ROBO.CONTORNANDO;
        var _closest_sensor_angle = 0;
        var _min_dist = distancia_sensor;
        for(var i = 0; i < array_length(leituras_sensores); i++) {
            if (leituras_sensores[i][0] < _min_dist) {
                _min_dist = leituras_sensores[i][0];
                _closest_sensor_angle = angulos_sensores[i];
            }
        }
        return { v: 0, w: -sign(_closest_sensor_angle) * MAX_TURN_RATE };
    }
    if (estado == ESTADO_ROBO.PRESO) estado = ESTADO_ROBO.BUSCANDO;
    return { v: _best_v, w: _best_w };
}

calculate_wall_follow_score = function(_v, _w) {
    var _left_sensor_dist = leituras_sensores[5][0]; 
    var _dist_error = abs(_left_sensor_dist - WALL_FOLLOW_DISTANCE);
    var _dist_score = 1 - (_dist_error / distancia_sensor);
    var _turn_score = 1 - (abs(_w) / MAX_TURN_RATE);
    var _velocity_score = _v / MAX_SPEED;
    return (1.5 * _dist_score) + (0.5 * _turn_score) + (1.0 * _velocity_score);
}

calculate_potential_at = function(_px, _py) {
    var _attractive_potential = 0;
    if (instance_exists(obj_goal)) {
        var _dist_to_goal = point_distance(_px, _py, obj_goal.x, obj_goal.y);
        _attractive_potential = 0.5 * APF_ATTRACTIVE_GAIN * power(_dist_to_goal, 2);
    }
    var _repulsive_potential = 0;
    for (var i = 0; i < array_length(leituras_sensores); i++) {
        var _dist_to_obs = leituras_sensores[i][0];
        if (_dist_to_obs < distancia_sensor) {
            _repulsive_potential += 0.5 * APF_REPULSIVE_GAIN * power((1 / max(1, _dist_to_obs)) - (1 / distancia_sensor), 2);
        }
    }
    return _attractive_potential + _repulsive_potential;
}

is_trajectory_safe = function(_v, _w) {
    var _sim_x = x;
    var _sim_y = y;
    var _sim_dir = direction;
    for (var t = 0; t < DWA_SIM_TIME; t += DWA_TIME_STEP) {
        _sim_x += _v * dcos(_sim_dir) * DWA_TIME_STEP;
        _sim_y -= _v * dsin(_sim_dir) * DWA_TIME_STEP;
        _sim_dir += radtodeg(_w) * DWA_TIME_STEP;
        for (var i = 0; i < array_length(leituras_sensores); i++) {
            var _dist_to_obs = leituras_sensores[i][0];
            if (_dist_to_obs < distancia_sensor) { 
                 var _obs_x = leituras_sensores[i][1];
                 var _obs_y = leituras_sensores[i][2];
                 if (point_distance(_sim_x, _sim_y, _obs_x, _obs_y) < ROBOT_RADIUS) {
                     return false;
                 }
            }
        }
    }
    return true;
}

simulate_trajectory_endpoint = function(_v, _w) {
    var _sim_x = x + _v * dcos(direction) * DWA_SIM_TIME;
    var _sim_y = y - _v * dsin(direction) * DWA_SIM_TIME;
    return { x: _sim_x, y: _sim_y };
}

calculate_heading_score_for_apf = function(_v, _w) {
    if (!instance_exists(obj_goal)) return 0;
    var _sim_dir = direction + radtodeg(_w) * DWA_TIME_STEP;
    var _target_angle = point_direction(x, y, obj_goal.x, obj_goal.y);
    var _angle_diff = abs(angle_difference(_sim_dir, _target_angle));
    return 1 - (_angle_diff / 180);
}

#endregion
