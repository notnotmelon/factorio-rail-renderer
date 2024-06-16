factorio_version = "1.1"; // 1.1 or 2.0

use <spline.scad>

// layer indexes
RED_WIRE = 0;
GREEN_WIRE = 1;
COPPER_WIRE = 2;
STONE_PATH = 3;
BACKPLATES = 4;
TIES = 5;
METALS = 6;
ITEM_ICON = 7;
WIRE_CLASPERS = 8;

function rotate90(point) = [-point[1], point[0], point[2]];
function rotate90arr(points) = [for (point = points) rotate90(point)];
function rotate360arr(points) = concat(points, rotate90arr(rotate90arr(rotate90arr(points))), rotate90arr(rotate90arr(points)), rotate90arr(points));

seven_and_a_bit = 7.51;

subdivisions = 5;
tie_subdivisions = 3;

function rotate90(point) = [-point[1], point[0], point[2]];
function rotate90arr(points) = [for (point = points) rotate90(point)];

fourth_control_points = factorio_version == "1.1" ? [[0, 11, 0], [7.5, 7.5, 0]] : [[0, 13, 0],[5,12, 0],[9,9, 0],[12,5, 0]];   // for factorio 1.0!

control_points = concat(fourth_control_points, rotate90arr(rotate90arr(rotate90arr(fourth_control_points))), rotate90arr(rotate90arr(fourth_control_points)), rotate90arr(fourth_control_points));
path = smooth(control_points, subdivisions, loop = true);

straight_control_points = [[0, 2*64/56, 0], [0, -2*64/56, 0]];
straight_path = straight_control_points;

item_icon_control_points = [[0, 64/56, 0], [0, -64/56, 0]];
item_icon_path = item_icon_control_points;

neck_inner_width = 0.5*1.2;
neck_outer_width = 1*1.2;
total_height = 0.3;
top_width = 1.5*1.2;
tie_radius = 0.1;
crosses_width = 0.1;

function top_point_inner(negate) = [negate*neck_inner_width/2, total_height, 0];
function top_point_outer(negate) = [negate*top_width/2, total_height, 0];
function neck_point_inner(negate) = [negate*neck_inner_width/2, 0, 0];
function neck_point_outer(negate) = [negate*neck_outer_width/2, 0, 0];

function full_rail_polygon(negate) = rotate90arr([
    neck_point_inner(negate),
    neck_point_outer(negate),
    top_point_outer(negate),
    top_point_inner(negate)
]);

function stone_path_polygon(negate) = rotate90arr([
    neck_point_inner(negate),
    neck_point_outer(negate),
    top_point_outer(negate),
    top_point_inner(negate)    
]);

function backplates_polygon(negate) = rotate90arr([
    neck_point_inner(negate),
    neck_point_outer(negate),
    [negate*neck_inner_width/2, 0.01, 0]
]);

function points_offset(points, offset) = [for (point = points) [point[0] + offset[0], point[1] + offset[1], point[2] + offset[2]]];
wire_distance = 0.022;
wire_offset = 0.8;
wire_height = -0.2;
wire_diameter = 0.015;
function red_wire_polygon(negate) = points_offset(circle_points(wire_diameter, 16), [wire_height - wire_distance, negate*(wire_offset + wire_distance), 0]);
function green_wire_polygon(negate) = points_offset(circle_points(wire_diameter, 16), [wire_height, negate*(wire_offset), 0]);
function copper_wire_polygon(negate) = points_offset(circle_points(wire_diameter, 16), [wire_height + wire_distance, negate*(wire_offset - wire_distance), 0]);

function pick_polygon(layers, negate) = 
    layers[BACKPLATES] && layers[STONE_PATH] ? full_rail_polygon(negate) :
    layers[BACKPLATES] ? backplates_polygon(negate) :
    layers[STONE_PATH] ? stone_path_polygon(negate) :
    undef;

module rail_half(path, polygon, straight) {
    if (polygon != undef)
        noodle(path, polygon, loop = !straight);
}

module crosses_helper(point1, point2, angle) {
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

    translate([0, 0, total_height - crosses_width/2]) {
        udon([start1, end1], width = crosses_width);
        udon([start2, end2], width = crosses_width);
    }
}

module crosses(tie_points, angle, straight) {
    for (i = [1 : len(tie_points)-1]) {
        point = tie_points[i];
        previous_point = tie_points[i-1];
        crosses_helper(point, previous_point, angle);
    }

    if (!straight) {
        crosses_helper(tie_points[len(tie_points)-1], tie_points[0], angle);
    }
}

module ties(tie_points, angle) {
    for (point = tie_points)
        translate(point) {
            // Calculate the rotation angle
            angle = angle == -1 ? atan2(point[0], point[1]) : angle;
            rotate([angle + 90, 90, 0]) {
                cylinder(h = 0.8, r = tie_radius, center = true);
            }
        }
}

module wire_claspers(negate, wire_points, angle, straight) {
    for (point = wire_points) {
        translate(point) {
            // Calculate the rotation angle
            angle = angle == -1 ? atan2(point[0], point[1]) : angle;
            rotate([angle + 90, 90, 0])
                translate([wire_height, 0, -negate*wire_offset])
                    rotate([0, negate*45, 0])
                        cylinder(h = 0.2, r = 0.02, center = true);
        }
    }
}

module rail(layers, path, control_points, angle, straight = true) {
    color([0.8, 0.9, 1]) {
        rail_half(path, pick_polygon(layers, 1), straight);
        rail_half(path, pick_polygon(layers, -1), straight);
    }

    tie_control_points = smooth(control_points, straight ? tie_subdivisions - 1 : tie_subdivisions, loop = !straight);
    // remove the first, last, and center points if straight==true
    tie_points = straight ? [for (i = [1 : len(tie_control_points)-2]) if (i != floor(len(tie_control_points)/2)) tie_control_points[i]] : tie_control_points;

    difference() {
        union() {
            if (layers[TIES]) color([0.5, 0.5, 0.5]) ties(tie_points, angle);
            if (layers[STONE_PATH]) color([0.8, 0.9, 1]) crosses(tie_control_points, angle, straight);
            if (layers[GREEN_WIRE]) color([0, 1, 0]) noodle(path, green_wire_polygon(1), loop = !straight);
            if (layers[RED_WIRE]) color([1, 0, 0]) noodle(path, red_wire_polygon(1), loop = !straight);
            if (layers[COPPER_WIRE]) color([1, 0.5, 0]) noodle(path, copper_wire_polygon(1), loop = !straight);
            if (layers[GREEN_WIRE]) color([0, 1, 0]) noodle(path, green_wire_polygon(-1), loop = !straight);
            if (layers[RED_WIRE]) color([1, 0, 0]) noodle(path, red_wire_polygon(-1), loop = !straight);
            if (layers[COPPER_WIRE]) color([1, 0.5, 0]) noodle(path, copper_wire_polygon(-1), loop = !straight);
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

    if (layers[WIRE_CLASPERS]) {
        wire_control_points = smooth(tie_control_points, 1, loop = !straight);
        wire_points = straight ? [for (i = [0 : len(wire_control_points)-1]) if (i % 2 == 0) wire_control_points[i]] : wire_control_points;
        color("black") wire_claspers(1, wire_points, angle, straight);
        color("black") wire_claspers(-1, wire_points, angle, straight);
    }
}

module draw_rail(red_wire = false, green_wire = false, copper_wire = false, stone_path = false, backplates = false, ties = false, metals = false, item_icon = false, wire_claspers = false) {
    $fa = 3;
    $fs = 0.01;
    $vpr = [45, 0, 90];
    $vpt = [5, 0, 5];

    layers = item_icon ? [
        true,
        true,
        true,
        true,
        true,
        false,
        true,
        true,
        true
    ] : [
        red_wire,
        green_wire,
        copper_wire,
        stone_path,
        backplates,
        ties,
        metals,
        item_icon,
        wire_claspers
    ];

    scale_factor = 0.325;
    scale([scale_factor, scale_factor, -0.2]) {
        foreshortening_factor = 1/sqrt(2);
        scale([1, foreshortening_factor, 1]) {
            if (layers[ITEM_ICON]) {
                rail(layers, item_icon_path, item_icon_control_points, 90, straight = true);
            } else {
                rail(layers, path, control_points, -1, straight = false);
                translate([-4, 0, 0])
                    rotate([0, 0, 180])
                        rail(layers, straight_path, straight_control_points, 90, straight = true);
                translate([4, 0, 0])
                    rotate([0, 0, 90])
                        rail(layers, straight_path, straight_control_points, 90, straight = true);
                translate([0, 4, 0])
                    rotate([0, 0, -45+180])
                        rail(layers, straight_path, straight_control_points, 90, straight = true);
                translate([0, -4, 0])
                    rotate([0, 0, 45])
                        rail(layers, straight_path, straight_control_points, 90, straight = true);
            }
        }
    }
}

$vpr = [45, 0, 90];
$vpt = [5, 0, 5];

draw_rail(
    red_wire = true,
    green_wire = true,
    copper_wire = true,
    stone_path = true,
    backplates = true,
    ties = false,
    metals = true,
    item_icon = false,
    wire_claspers = true
);