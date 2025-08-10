function my_draw_arrow(x1, y1, x2, y2) {
    draw_line(x1, y1, x2, y2);
    var dir = point_direction(x1, y1, x2, y2);
    var head_len = 4;
    draw_line(x2, y2, x2 - lengthdir_x(head_len, dir - 150), y2 - lengthdir_y(head_len, dir - 150));
    draw_line(x2, y2, x2 - lengthdir_x(head_len, dir + 150), y2 - lengthdir_y(head_len, dir + 150));
}