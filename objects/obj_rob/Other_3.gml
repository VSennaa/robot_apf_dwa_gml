var file = file_text_open_write("performance_log.csv");
file_text_write_string(file, "time,pos_x,pos_y,vel_lin,vel_ang,distance\n");

for (var i = 0; i < ds_list_size(log_data); i++) {
    var e = log_data[| i];
    file_text_write_string(file, string(e.time) + "," +
                                   string(e.pos_x) + "," +
                                   string(e.pos_y) + "," +
                                   string(e.linear_velocity) + "," +
                                   string(e.angular_velocity) + "," +
                                   string(e.distance) + "\n");
}
file_text_close(file);


