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


// 2. Desenhar o robô (o sprite principal)
draw_self();

// 3. Desenhar o estado atual do robô
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(x, y - sprite_height / 2 - 4, string(estado));
