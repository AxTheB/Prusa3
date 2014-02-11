// PRUSA iteration3
// X ends
// GNU GPL v3
// Josef Průša <josefprusa@me.com>
// Václav 'ax' Hůla <axtheb@gmail.com>
// http://www.reprap.org/wiki/Prusa_Mendel
// http://github.com/prusajr/PrusaMendel

include <configuration.scad>
use <bushing.scad>
use <inc/bearing-guide.scad>
use <y-drivetrain.scad>

z_axis_bearing_height = (bushing_z[2] > 30 ? x_box_height : (2 * bushing_z[2] + 8));
bearing_height = max(z_axis_bearing_height, x_box_height);

module x_end_motor(){
    motor_arm_thickness = max(11, belt_width + 5);

    mirror([0, 1, 0]) {

        x_end_base(thru=false);

        translate([0, -25 - bushing_outer_radius(bushing_z) , 0]) difference(){
            union(){
                union() {
                    translate([0, 20, x_box_height / 2]) cube_fillet([motor_arm_thickness, 16, x_box_height], center = true, vertical=[0, 0, 3, 3], top=[0, 3, 6, 3], $fn=16);
                    //lower arm holding outer stepper screw
                    translate([0, -1, 0]) intersection(){
                        translate([0, 2, 4]) cube_fillet([motor_arm_thickness, 42, 28], center = true, vertical=[0, 0, 0, 0], top=[0, 3, 5, 3]);
                        translate([-motor_arm_thickness/2, 10, -17]) rotate([45, 0, 0]) cube_fillet([motor_arm_thickness, 60, 60], radius=2);
                        translate([0, 0, x_box_height / 2]) cube([motor_arm_thickness, 100, x_box_height], center=true);
                    }
                }
#translate([-(motor_arm_thickness + 2) / 2, 0, x_box_height / 2 -1]) rotate([90, 0, 0])  rotate([0, 90, 0]) nema17(places=[1, 0, 1, 1], h=motor_arm_thickness + 2);
            }

            // belt hole
            translate([0, 20, x_box_height / 2 -1]) cube_fillet([belt_width + 1, 36, 22], vertical=0, top=[0, 1, 0, 1], bottom=[0, 1, 0, 1], center = true, $fn=4);
            //motor mounting holes
            translate([-(motor_arm_thickness + 1) / 2, 0, x_box_height / 2 -1]) rotate([0, 0, 0])  rotate([0, 90, 0]) nema17(places=[1, 1, 0, 1], holes=true, h=motor_arm_thickness, shadow=motor_arm_thickness - 3, $fn=7);
        }
    }
}

module x_end_base(vfillet=[3, 3, 3, 3], thru=true, width=0, offset=0){
    // basic x_end shape, X axis rod in XY plane and bearing rod in YZ
    // by default outer end is flush with bearing guide, increasing len grows it inward

    //outer edge translates centered object of len length so it touches both sides of base box
    len = max(bushing_outer_radius(bushing_z) + z_pair_separation + 7 - offset, width); // 7 here is half the cube with M5 nut
    outer_edge = len / 2 - bushing_outer_radius(bushing_z) + offset;

    difference(){
        union(){
            translate([0, outer_edge, x_box_height / 2]) cube_fillet([x_box_width, len, x_box_height], center=true, vertical=vfillet, top=[5, 3, 5, 3]);

            translate([x_to_z_distance, 0, 0]) render(convexity = 5) linear(bushing_z, bearing_height);
            // Nut trap
            translate([x_box_width / 2 + 5, z_pair_separation, 5]) cube_fillet([18, 14, 10], center = true, vertical=[4, 0, 0, 4]);
        }
        // Z axis bushings/bearings
        translate([x_to_z_distance, 0, 0]) linear_negative(bushing_z, bearing_height);

        translate([0, 0, -1]) { // smooth rod has hole above, so we have to offset for that
            // belt hole
            translate([0, outer_edge, x_box_height / 2]) cube_fillet([idler_width + 2, len + 1, 27 + xy_delta], center = true, vertical=0, top=[0, 1, 0, 1], bottom=[0, 1, 0, 1], $fn=4);

            //smooth rods
            translate([0, outer_edge + (thru ? 0 : 3), x_box_height / 2]) {
                translate([0, 0, xaxis_rod_distance / 2]) rotate([-90, 0, 0]) cylinder_pushfit(r=bushing_xy[0] + 0.1, h=len + 0.1, center=true);
                translate([0, 0, -xaxis_rod_distance / 2]) rotate([-90, 0, 0]) cylinder_pushfit(r=bushing_carriage[0] + 0.1, h=len + 0.1, center=true);
            }
        }
        translate([x_box_width / 2 + 6, z_pair_separation, 0]){
                //rod
                translate([0, 0, -1]) cylinder(h=(4.1 / 2 + 5), r=3, $fn=32);
                //nut
                translate([0, 0, 9]) cylinder(r=4.6, h=14.1, center = true, $fn=6);
                %cylinder(h = x_box_height, r=2.5+0.2);

        }
    }
}

module x_end_idler(){
    hole_width = z_pair_separation - bushing_outer_radius(bushing_z) + 8;

    difference() {
        x_end_base(offset=-10);
        // idler hole
        translate([0, -bushing_outer_radius(bushing_z) - 4, x_box_height / 2 -1]) {
            rotate([0, 90, 0]) cylinder(r=m4_diameter / 2, h=x_box_width + 1, center=true, $fn=small_hole_segments);
            translate([x_box_width / 2 - 1, 0, 0]) rotate([0, 90, 0]) cylinder(r=m4_nut_diameter_horizontal / 2, h=3, $fn=6);

        }


        translate([0, bushing_outer_radius(bushing_z) + hole_width/2 - 3 , x_box_height / 2 -1]) cube_fillet([x_box_width + 1, hole_width, idler_height + 2 * layer_height], center=true, $fn=4);
    }
        //%translate([-14 - xy_delta / 2, -9, 30 - idler_height / 2]) x_tensioner();
}

module x_tensioner(len=68, idler_height=idler_height) {
    idlermount(len=len, rod=m4_diameter / 2 + 0.5, idler_height=idler_height, narrow_len=47, narrow_width=idler_width + 2 - single_wall_width);
}


translate([-40, 0, 0]) x_tensioner();
translate([0, -80, 0]) x_end_idler();
   x_end_motor();


if (idler_bearing[3] == 1) {  // bearing guides
    translate([-39,  -60 - idler_bearing[0] / 2, 0]) rotate([0, 0, 55]) {
        render() bearing_assy();
    }
}
