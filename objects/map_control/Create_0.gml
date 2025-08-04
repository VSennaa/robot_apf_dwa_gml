var grid_width = room_width div 32;
var grid_height = room_height div 32;
randomize();

// --- CRIA OS OBSTÁCULOS ---
var count = 0;
while (count < 50) {
    var x_cell = irandom(grid_width - 1);
    var y_cell = irandom(grid_height - 1);

    var px = x_cell * 32;
    var py = y_cell * 32;

    if (!position_meeting(px, py, obj_obstaculo) && !position_meeting(px + 128, py +128, obj_rob)) {
        instance_create_layer(px, py, "Instances", obj_obstaculo);
        count++;
    }
}

// --- CRIA O OBJETIVO ---
var goal_x = 768;
var goal_py;
var is_goal_pos_free = false;

while (!is_goal_pos_free) {
    var goal_y_cell = irandom(grid_height - 1);
    goal_py = goal_y_cell * 32;
    
    if (!position_meeting(goal_x, goal_py, obj_obstaculo)) {
        obj_goal.x = goal_x;
        obj_goal.y = goal_py;
        is_goal_pos_free = true;
    }
}