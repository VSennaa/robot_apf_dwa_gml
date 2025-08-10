// --- DESENHAR INFORMAÇÕES DE DEBUG ---
// 1. Desenhar as linhas dos sensores
draw_set_alpha(0.5);
for (var i = 0; i < array_length(leituras_sensores); i++) {
    if (leituras_sensores[i] != undefined) {
        var _reading = leituras_sensores[i];
        var _dist = _reading[0];
        
        // Muda a cor do sensor se ele detectou um obstáculo
        if (_dist < distancia_sensor) {
            draw_set_color(c_red);
        } else {
            draw_set_color(c_yellow);
        }
        
        draw_line(x, y, _reading[1], _reading[2]);
    }
}
draw_set_alpha(1.0);

if (show_vector_field) {
    var spacing = 40; // distância entre amostras
    draw_set_alpha(0.4);
    draw_set_color(c_aqua);

    for (var gx = spacing/2; gx < room_width; gx += spacing) {
        for (var gy = spacing/2; gy < room_height; gy += spacing) {
            
            // Força estimada = gradiente do potencial
            var p_here  = calculate_potential_at(gx, gy);
            var p_right = calculate_potential_at(gx + 5, gy);
            var p_up    = calculate_potential_at(gx, gy + 5);
            
            var fx_total = p_here - p_right;
            var fy_total = p_here - p_up;

            var mag_total = point_distance(0, 0, fx_total, fy_total);
            if (mag_total > 0) {
                var nx = fx_total / mag_total;
                var ny = fy_total / mag_total;

                my_draw_arrow(gx, gy, gx + nx * 15, gy + ny * 15);
            }
        }
    }

    draw_set_alpha(1);
}


// 2. Desenhar o robô (o sprite principal)
draw_self();

// 3. Desenhar o estado atual do robô
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, y - sprite_height / 2 - 4, string(estado));
