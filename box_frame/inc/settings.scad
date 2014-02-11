// Moved from config.scad
//calculated from settings
single_wall_width = width_over_thickness * layer_height;
//deltas are used to enlarge parts for bigger bearings, depends on outer bushing radius
//7.7 here is outer radius of lm8uu
xy_delta = max(0, bushing_xy[1] - 7.7, bushing_carriage[1] - 7.7);
z_delta = max(0, bushing_z[1] - 7.7);
x_to_z_distance = max(bushing_xy[0],bushing_carriage[0]) + bushing_z[1] + 3;
//distance of X axis rods, center to center
xaxis_rod_distance = 45 + xy_delta * 2;

// height and width of the x blocks depend on x smooth rod radius
x_box_height = xaxis_rod_distance + 8 + 2 * bushing_xy[0];
// Pretend the smooth rods are at least 8mm diameter
x_box_width = max(8, bushing_xy[0] * 2, bushing_carriage[0] * 2) + 10;

// distance between centers of z threaded and smooth rod, in X direction
z_pair_separation = max(bushing_outer_radius(bushing_z) + 8, 18);

idler_width = max(belt_width, idler_bearing[1], 7) + 2.5 * idler_bearing[3];

//move the XZ plane further away from board for bigger bearings
board_to_x_distance = x_box_width / 2 + 2;

m3_nut_diameter_bigger = ((m3_nut_diameter / 2) / cos (180 / 6)) * 2;
idler_height=max(idler_bearing[0], 16);
