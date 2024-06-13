use <spline.scad>
use <C:/Users/zacha/Documents/boltsos_0.4.1/BOLTS.scad>

function rotate90(point) = [-point[1], point[0], point[2]];
function rotate90arr(points) = [for (point = points) rotate90(point)];

subdivisions = 5;
//fourth_control_points = [[0, 13, 0],[5,12, 0],[9,9, 0],[12,5, 0]];  // for factorio 2.0!
fourth_control_points = [[0, 11, 0], [7.5, 7.5, 0]];   // for factorio 1.0!

control_points = concat(fourth_control_points, rotate90arr(rotate90arr(rotate90arr(fourth_control_points))), rotate90arr(rotate90arr(fourth_control_points)), rotate90arr(fourth_control_points));
path = smooth(control_points, subdivisions, loop = true);

straight_control_points = [[0, 2, 0], [0, -2, 0]];
straight_path = straight_control_points;

neck_inner_width = 0.5;
neck_outer_width = 1;
total_height = 0.5;
neck_height = 0.2;
base_width = 2;
top_width = 1.5;

function base_point_outer(negate) = [negate*base_width/2, 0, 0];
function base_point_inner(negate) = [negate*neck_inner_width/2, 0, 0];
function top_point_inner(negate) = [negate*neck_inner_width/2, total_height, 0];
function top_point_outer(negate) = [negate*top_width/2, total_height, 0];
function neck_point_inner(negate) = [negate*neck_inner_width/2, neck_height, 0];
function neck_point_outer(negate) = [negate*neck_outer_width/2, neck_height, 0];

function full_rail_polygon(negate) = rotate90arr([
    base_point_outer(negate),
    base_point_inner(negate),
    top_point_inner(negate),
    top_point_outer(negate),
    neck_point_outer(negate)
]);

function stone_path_polygon(negate) = rotate90arr([
    base_point_outer(negate),
    base_point_inner(negate),
    neck_point_inner(negate),
    neck_point_outer(negate)
]);

function backplates_polygon(negate) = rotate90arr([
    neck_point_inner(negate),
    neck_point_outer(negate),
    top_point_outer(negate),
    top_point_inner(negate)
]);

function pick_polygon(negate, metals, backplates, ties, stone_path) = 
    backplates && stone_path ? full_rail_polygon(negate) :
    backplates ? backplates_polygon(negate) :
    stone_path ? stone_path_polygon(negate) :
    undef;

module rail_half(path, polygon, straight) {
    if (polygon != undef)
        noodle(path, polygon, loop = !straight);
}

module backplates_connections_helper(point1, point2, angle) {
    // Calculate the rotation angle
    angle1 = angle == -1 ? atan2(point1[0], point1[1]) : angle;
    angle2 = angle == -1 ? atan2(point2[0], point2[1]) : angle;

    rotation_factor = 0.32;

    start1 = [
        point1[0] + sin(angle1) * rotation_factor,
        point1[1] + cos(angle1) * rotation_factor,
        0
    ];
    end1 = [
        point2[0] - sin(angle2) * rotation_factor,
        point2[1] - cos(angle2) * rotation_factor,
        0
    ];


    start2 = [
        point1[0] - sin(angle1) * rotation_factor,
        point1[1] - cos(angle1) * rotation_factor,
        0
    ];
    end2 = [
        point2[0] + sin(angle2) * rotation_factor,
        point2[1] + cos(angle2) * rotation_factor,
        0
    ];

    udon_width = 0.1;
    translate([0, 0, total_height - udon_width/2]) {
        udon([start1, end1], width = udon_width);
        udon([start2, end2], width = udon_width);
    }
}

module backplates_connections(tie_points, angle, straight) {
    for (i = [1 : len(tie_points)-1]) {
        point = tie_points[i];
        previous_point = tie_points[i-1];
        backplates_connections_helper(point, previous_point, angle);
    }

    if (!straight) {
        backplates_connections_helper(tie_points[len(tie_points)-1], tie_points[0], angle);
    }
}

module ties(tie_points, angle) {
    translate([0, 0, 0.25]) {
        for (point = tie_points)
            translate(point) {
                // Calculate the rotation angle
                angle = angle == -1 ? atan2(point[0], point[1]) : angle;
                rotate([angle + 90, 90, 0]) {
                    cylinder(h = 0.8, r = neck_height / 2, center = true);
                }
            }
    }
}

module wire_claspers(tie_points, angle) {
    for (point = tie_points)
        translate(point) {
            // Calculate the rotation angle
            angle = angle == -1 ? atan2(point[0], point[1]) : angle;
            rotate([angle + 90, 90, 0]) {
                translate([1, 0, 0])
                cylinder(h = 0.2, r = 0.05, center = true);
            }
        }
}

module rail(path, control_points, metals, backplates, ties, stone_path, angle, straight = true) {
    translate([0, 0, -total_height]) {
        color([0.8, 0.9, 1]) {
            rail_half(path, pick_polygon(1, metals, backplates, ties, stone_path), straight);
            rail_half(path, pick_polygon(-1, metals, backplates, ties, stone_path), straight);
        }

        tie_control_points = smooth(control_points, 3, loop = !straight);
        tie_points = straight ? [for (i = [1 : len(tie_control_points)-2]) tie_control_points[i]] : tie_control_points; // remove the first and last points

        difference() {
            union() {
                if (ties) color([0.5, 0.5, 0.5]) ties(tie_points, angle);
                if (backplates) color([0.8, 0.9, 1]) backplates_connections(tie_points, angle, straight);
                //if (stone_path) color([0.6, 0.2, 0.7]) wire_claspers(tie_points, angle);
            }
            color([0.5, 0.5, 0.5]) if (straight) {
                // remove anything beyond the limits of the first and last points in the path
                translate(path[0]) {
                    rotate([0, 0, angle])
                        translate([0.5/2, 0, 0])
                            cube([0.501, 1, 1], center = true);
                }
                translate(path[len(path)-1]) {
                    rotate([0, 0, angle])
                        translate([-0.5/2, 0, 0])
                            cube([0.501, 1, 1], center = true);
                }
            }
        }
    }
}

module draw_rail(metals, backplates, ties, stone_path) {
    scale_factor = 0.325;
    scale([scale_factor, scale_factor, 0.2]) {
        foreshortening_factor = 1/sqrt(2);
        scale([1, foreshortening_factor, 1]) {
            rail(path, control_points, metals, backplates, ties, stone_path, -1, straight = false);
            translate([-4, 0, 0])
                rotate([0, 0, 0])
                    rail(straight_path, straight_control_points, metals, backplates, ties, stone_path, 90, straight = true);
            translate([4, 0, 0])
                rotate([0, 0, 90])
                    rail(straight_path, straight_control_points, metals, backplates, ties, stone_path, 90, straight = true);
            translate([0, 4, 0])
                rotate([0, 0, -45])
                    rail(straight_path, straight_control_points, metals, backplates, ties, stone_path, 90, straight = true);
            translate([0, -4, 0])
                rotate([0, 0, 45])
                    rail(straight_path, straight_control_points, metals, backplates, ties, stone_path, 90, straight = true);
        }
    }
}

$fa = 3;
$fs = 0.01;
$vpr = [45, 0, 90];
$vpt = [5, 0, 5];

draw_rail(metals = true, backplates = true, ties = true, stone_path = true);