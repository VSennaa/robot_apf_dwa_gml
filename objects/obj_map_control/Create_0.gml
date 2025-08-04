
// Garante que o objeto de controle não seja destruído ao mudar de sala
persistent = true;

// --- CONTADORES GLOBAIS ---
global.success_count = 0;
global.failure_count = 0;

// --- MÉTODO PARA REINICIAR A SIMULAÇÃO ---
// Este método encapsula a sua lógica original de criação de cenário
reset_simulation = function() {
    // Destrói o robô e os obstáculos existentes para um novo começo
    instance_destroy(obj_rob);
    instance_destroy(obj_obstaculo);
    
    // --- CRIA OS OBSTÁCULOS ---
    var _grid_width = room_width div 32;
    var _grid_height = room_height div 32;
    randomize();
    var _count = 0;
    while (_count < 50) {
        var _x_cell = irandom(_grid_width - 1);
        var _y_cell = irandom(_grid_height - 1);
        var _px = _x_cell * 32;
        var _py = _y_cell * 32;

        // Garante que não crie obstáculo no ponto de partida do robô
        if (_x_cell <= 2 && _y_cell <= 2) continue;

        if (!position_meeting(_px, _py, obj_obstaculo)) {
            instance_create_layer(_px, _py, "Instances", obj_obstaculo);
            _count++;
        }
    }

    // --- CRIA O OBJETIVO ---
    var _goal_x = 768;
    var _goal_py;
    var _is_goal_pos_free = false;
    while (!_is_goal_pos_free) {
        var _goal_y_cell = irandom(_grid_height - 1);
        _goal_py = _goal_y_cell * 32;
        if (!position_meeting(_goal_x, _goal_py, obj_obstaculo)) {
            // Garante que o obj_goal exista antes de tentar acessá-lo
            if (instance_exists(obj_goal)) {
                obj_goal.x = _goal_x;
                obj_goal.y = _goal_py;
            }
            _is_goal_pos_free = true;
        }
    }
    
    // --- CRIA UMA NOVA INSTÂNCIA DO ROBÔ ---
    instance_create_layer(32, 32, "Instances", obj_rob);
}

// Inicia a primeira simulação
reset_simulation();
