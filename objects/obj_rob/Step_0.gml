
// --- Lógica de Estado e Movimento ---

// Sai se o jogo acabou
if (!instance_exists(obj_goal) or estado == ESTADO_ROBO.ALCANCADO) {
    linear_velocity = 0;
    angular_velocity = 0;
    exit;
}

// Verifica se chegou ao objetivo
if (point_distance(x, y, obj_goal.x, obj_goal.y) < 24) {
    estado = ESTADO_ROBO.ALCANCADO;
    linear_velocity = 0;
    angular_velocity = 0;
	global.success_count ++
	game_restart();
    exit;
}

// RECUPERAÇÃO ---
if (abs(linear_velocity) < 5 && estado != ESTADO_ROBO.ALCANCADO && estado != ESTADO_ROBO.RECUPERANDO) {
    stuck_timer += delta_time / 1000000; // Adiciona segundos
} else {
    stuck_timer = 0;
}
if (stuck_timer > 2) {
    stuck_timer = 0;
    estado = ESTADO_ROBO.RECUPERANDO;
    recovery_timer = 1.0; // Duração da manobra de recuperação
    recovery_turn_direction = choose(1, -1); // Escolhe uma direção de giro aleatória
}


// --- MÁQUINA DE ESTADOS PRINCIPAL ---
sense_environment(); // Sensores são lidos em todos os estados

switch (estado) {
    case ESTADO_ROBO.BUSCANDO:
    case ESTADO_ROBO.CONTORNANDO:
        // Nos modos normais, usa o DWA para planejar
        var _velocities = dynamic_window_approach();
        linear_velocity = _velocities.v;
        angular_velocity = _velocities.w;
        break;
    
    case ESTADO_ROBO.RECUPERANDO:
        // No modo de recuperação, executa uma manobra pré-definida
        linear_velocity = -MAX_SPEED * 0.75; // Dá ré
        angular_velocity = recovery_turn_direction * MAX_TURN_RATE * 0.5; // Vira
        
        recovery_timer -= delta_time / 1000000;
        if (recovery_timer <= 0) {
            estado = ESTADO_ROBO.BUSCANDO; // Volta a buscar após a manobra
        }
        break;
}


// --- APLICAÇÃO DO MOVIMENTO E COLISÃO FÍSICA ---
// (A lógica de colisão física com place_meeting continua importante como última camada de segurança)
var _dt_sec = delta_time / 1000000;
var _move_x = linear_velocity * dcos(direction) * _dt_sec;
var _move_y = -linear_velocity * dsin(direction) * _dt_sec;

// Colisão Horizontal
if (place_meeting(x + _move_x, y, obj_obstaculo)) {
    while (!place_meeting(x + sign(_move_x), y, obj_obstaculo)) { x += sign(_move_x); }
    linear_velocity = 0;
    _move_x = 0; 
}

// Colisão Vertical
if (place_meeting(x, y + _move_y, obj_obstaculo)) {
    while (!place_meeting(x, y + sign(_move_y), obj_obstaculo)) { y += sign(_move_y); }
    linear_velocity = 0;
    _move_y = 0;
}

x += _move_x;
y += _move_y;

direction += radtodeg(angular_velocity) * _dt_sec;

if obj_rob.x > room_width or obj_rob.x < 0{
	game_restart();
}
if obj_rob.y > room_height or obj_rob.y < 0{
	game_restart();
}

if (keyboard_check_pressed(ord("F"))) {
    show_vector_field = !show_vector_field; // alterna
}

// Distância acumulada
distance_traveled += point_distance(last_x, last_y, x, y);
last_x = x;
last_y = y;

// Log por frame
var entry = {
    time: current_time,
    pos_x: x,
    pos_y: y,
    linear_velocity: linear_velocity,
    angular_velocity: angular_velocity,
    distance: distance_traveled
};
ds_list_add(log_data, entry);

