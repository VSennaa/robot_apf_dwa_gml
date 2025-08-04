
// --- Configurações de Desenho ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// --- Lógica de Posicionamento Dinâmico da GUI ---
var _gui_w = display_get_gui_width();
var _panel_width = 260;
var _panel_height = 150; // Altura ajustada para os novos contadores

var _gui_x = 10;
var _gui_y = 10;

// Verifica se o robô existe e se está no quadrante superior esquerdo
if (instance_exists(obj_rob) && obj_rob.x < room_width / 2 && obj_rob.y < room_height / 2) {
    // Se estiver, move a GUI para o canto superior direito da tela
    _gui_x = _gui_w - _panel_width - 10;
}

// --- Desenha o fundo ---
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(_gui_x - 5, _gui_y - 5, _gui_x + _panel_width, _gui_y + _panel_height, false);
draw_set_alpha(1.0);
draw_set_color(c_white);

// --- Informações ---
var _line_height = 20;
var _start_x = _gui_x;
var _start_y = _gui_y + 10;

draw_text(_start_x, _start_y, "Status do Robô");
_start_y += _line_height * 1.5;

// Contadores
draw_text(_start_x, _start_y, "Sucessos: " + string(global.success_count));
_start_y += _line_height;
draw_text(_start_x, _start_y, "Falhas: " + string(global.failure_count));
_start_y += _line_height;

// Se a instância do robô não existir, não desenha o resto
if (!instance_exists(obj_rob)) {
    exit;
}

// Estado
var _estado_str = "Desconhecido";
switch (obj_rob.estado) {
    case ESTADO_ROBO.BUSCANDO:    _estado_str = "Buscando"; break;
    case ESTADO_ROBO.CONTORNANDO: _estado_str = "Contornando"; break;
    case ESTADO_ROBO.RECUPERANDO: _estado_str = "Recuperando"; break;
    case ESTADO_ROBO.PRESO:       _estado_str = "Preso"; break;
    case ESTADO_ROBO.ALCANCADO:   _estado_str = "Alcancado"; break;
}
draw_text(_start_x, _start_y, "Estado: " + _estado_str);
_start_y += _line_height;

// Posição
var _pos_x_str = string_format(obj_rob.x, 0, 0);
var _pos_y_str = string_format(obj_rob.y, 0, 0);
draw_text(_start_x, _start_y, "Pos (X, Y): (" + _pos_x_str + ", " + _pos_y_str + ")");
_start_y += _line_height;

// Velocidade Linear
var _vel_linear_str = string_format(obj_rob.linear_velocity, 1, 2);
draw_text(_start_x, _start_y, "Velocidade Linear: " + _vel_linear_str);
_start_y += _line_height;

// Velocidade Angular
var _vel_angular_str = string_format(radtodeg(obj_rob.angular_velocity), 1, 2);
draw_text(_start_x, _start_y, "Velocidade Angular: " + _vel_angular_str + "°/s");
_start_y += _line_height;

// Stuck Timer
var _stuck_timer_str = string_format(obj_rob.stuck_timer, 1, 1);
draw_text(_start_x, _start_y, "Timer Preso: " + _stuck_timer_str + "s");
_start_y += _line_height;
