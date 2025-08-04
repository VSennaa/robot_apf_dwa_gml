// Se a instância do robô não existir, não desenha nada
if (!instance_exists(obj_rob)) {
    exit;
}

// --- Configurações de Desenho ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// --- Lógica de Posicionamento Dinâmico da GUI ---
var _gui_w = display_get_gui_width();
var _panel_width = 260; // Largura do painel ajustada
var _panel_height = 130; // Altura ajustada para a nova informação

// Posição padrão da GUI (canto superior esquerdo)
var _gui_x = 10;
var _gui_y = 10;

// Verifica se o robô está no quadrante superior esquerdo da sala
if (obj_rob.x < room_width / 2 && obj_rob.y < room_height / 2) {
    // Se estiver, move a GUI para o canto superior direito da tela
    _gui_x = _gui_w - _panel_width - 10;
}


// --- Desenha um fundo semi-transparente para legibilidade ---
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(_gui_x - 5, _gui_y - 5, _gui_x + _panel_width, _gui_y + _panel_height, false);
draw_set_alpha(1.0);
draw_set_color(c_white);


// --- Título ---
var _line_height = 20; // Espaçamento entre as linhas
var _start_x = _gui_x;
var _start_y = _gui_y + 10;

draw_text(_start_x, _start_y, "Status do Robô");
_start_y += _line_height * 1.5; // Espaço extra após o título

// --- Informações do Robô ---

// 1. Estado Atual
var _estado_str = "Desconhecido";
switch (obj_rob.estado) {
    case ESTADO_ROBO.BUSCANDO:    _estado_str = "Buscando"; break;
    case ESTADO_ROBO.CONTORNANDO: _estado_str = "Contornando"; break;
    case ESTADO_ROBO.RECUPERANDO: _estado_str = "Recuperando"; break;
    case ESTADO_ROBO.PRESO:       _estado_str = "Preso"; break;
    case ESTADO_ROBO.ALCANCADO:   _estado_str = "Alcançado!"; break;
}
draw_text(_start_x, _start_y, "Estado: " + _estado_str);
_start_y += _line_height;

// 2. Posição Atual (NOVO)
var _pos_x_str = string_format(obj_rob.x, 0, 0);
var _pos_y_str = string_format(obj_rob.y, 0, 0);
draw_text(_start_x, _start_y, "Posição (X, Y): (" + _pos_x_str + ", " + _pos_y_str + ")");
_start_y += _line_height;

// 3. Velocidade Linear
var _vel_linear_str = string_format(obj_rob.linear_velocity, 1, 2);
draw_text(_start_x, _start_y, "Velocidade Linear: " + _vel_linear_str);
_start_y += _line_height;

// 4. Velocidade Angular
var _vel_angular_str = string_format(radtodeg(obj_rob.angular_velocity), 1, 2);
draw_text(_start_x, _start_y, "Velocidade Angular: " + _vel_angular_str + "°/s");
_start_y += _line_height;

// 5. Stuck Timer
var _stuck_timer_str = string_format(obj_rob.stuck_timer, 1, 1);
draw_text(_start_x, _start_y, "Timer Preso: " + _stuck_timer_str + "s");
_start_y += _line_height;
