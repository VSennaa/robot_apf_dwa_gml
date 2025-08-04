// In the Step event of the object
x = clamp(x, 0, room_width - sprite_width); // Adjust for sprite size
y = clamp(y, 0, room_height - sprite_height); // Adjust for sprite size

// --- Lógica de Estado e Movimento ---

// Sai se o jogo acabou
if (!instance_exists(obj_goal) or estado == ESTADO_ROBO.ALCANCADO) {
    linear_velocity = 0;
    angular_velocity = 0;
	game_restart();
    exit;
}

// Verifica se chegou ao objetivo
if (point_distance(x, y, obj_goal.x, obj_goal.y) < 24) {
    estado = ESTADO_ROBO.ALCANCADO;
    linear_velocity = 0;
    angular_velocity = 0;
	room_restart()
    exit;
}

// --- RECUPERAÇÃO ---
if (abs(linear_velocity) < 5 && estado != ESTADO_ROBO.ALCANCADO && estado != ESTADO_ROBO.RECUPERANDO) {
    stuck_timer += delta_time / 1000000; 
} else {
    stuck_timer = 0;
}

if (stuck_timer > 2) {
    stuck_timer = 0;
    estado = ESTADO_ROBO.RECUPERANDO;
    recovery_timer = 1.0; 
    recovery_turn_direction = choose(1, -1);
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


// --- APLICAÇÃO DO MOVIMENTO E COLISÃO FÍSICA (SEMPRE EXECUTA) ---
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