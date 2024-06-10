use <spline.scad>
use <C:/Users/zacha/Documents/boltsos_0.4.1/BOLTS.scad>
use <C:/Users/zacha/Documents/closepoints/closepoints.scad>

$fa = 3;
$fs = 0.05;
$vpr = [45, 0, 90];
$vpt = [5, 0, 5];

function rotate90(point) = [-point[1], point[0], point[2]];
function rotate90arr(points) = [for (point = points) rotate90(point)];

subdivisions = 5;
//fourth_control_points = [[0, 13, 0],[5,12, 0],[9,9, 0],[12,5, 0]];  // for factorio 2.0!
fourth_control_points = [[0, 11, 0], [7.5, 7.5, 0]];   // for factorio 1.0!

control_points = concat(fourth_control_points, rotate90arr(rotate90arr(rotate90arr(fourth_control_points))), rotate90arr(rotate90arr(fourth_control_points)), rotate90arr(fourth_control_points));
path = smooth(control_points, subdivisions, loop = true);

straight_control_points = [[0, 2, 0], [0, 1, 0], [0, -1, 0], [0, -2, 0]];
straight_path = straight_control_points;

diagonal_control_points = [[0, 2, 0], [0, -2, 0]];
diagonal_path = diagonal_control_points;

neck_width = 0.5;
total_height = 0.75;
base_width = 2;
top_width = 1.5;
necktie_width = 1;
neck_height = 0.5;
circle_radius = 10;

module rail_half(path, negate, straight) {
    noodle(path, rotate90arr([
        [negate*base_width/2, 0, 0],
        [negate*neck_width/2, 0, 0],
        [negate*neck_width/2, neck_height, 0],
        [negate*top_width/2, total_height, 0],
        [negate*necktie_width/2, 0.3, 0],
    ]), loop = !straight);
}

module rail(path, control_points, angle = -1, straight) {
    color([1, 0, 0]) {
        spline_wall(path, width=0.1, height=0.01, subdivisions=0, loop=!straight);
    }

    translate([0, 0, -total_height]) {

    color([0.8, 0.9, 1]) {
        rail_half(path, 1, straight);
        rail_half(path, -1, straight);
    }

    color([0.2, 0.2, 0.2]) {
        translate([0, 0, 0.25]) {
            for (point = control_points) {
                translate(point) {
                    // Calculate the rotation angle
                    angle = angle == -1 ? atan2(point[0], point[1]) : angle;
                    rotate([angle + 90, 90, 0]) {
                        cylinder(h = 0.8, r = neck_height / 2, center = true);
                    }
                }
            }
        }
    }

    }
}

scale_factor = 0.325;
scale([scale_factor, scale_factor, 0.15]) {
    foreshortening_factor = 1/sqrt(2);
    scale([1, foreshortening_factor, 1]) {
        rail(path, control_points, straight = false);
        translate([-4, 0, 0])
            rotate([0, 0, 0])
                rail(straight_path, straight_control_points, 90, straight = true);
        translate([4, 0, 0])
            rotate([0, 0, 90])
                rail(straight_path, straight_control_points, 90, straight = true);
        translate([0, 4, 0])
            rotate([0, 0, -45])
                rail(diagonal_path, diagonal_control_points, 90, straight = true);
        translate([0, -4, 0])
            rotate([0, 0, 45])
                rail(diagonal_path, diagonal_control_points, 90, straight = true);
    }
}