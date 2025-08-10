$fn = 1200;
hole_dist = 56.85;
hole_size = 6;

eight_ball = [
    [0],
    [-1, 1],
    [-2, 0, 2],
    [-3, -1, 1, 3],
    [-4, -2, 0, 2, 4]
];

// Flip this between true/false for 9/10 ball compatability
nine_ten_ball_compatable=false;

rack_type = eight_ball;

// We need to iterate over the *indices* of the rack_type list
// to use them for the Y-coordinate calculation.
// The list comprehension `[0:len(rack_type)-1]` generates the numbers [0, 1, 2, 3, 4]
module make_holes() {
    for (row_num = [0:len(rack_type)-1]) {
        y_coord = calc_y_coord(row_num);
        row_data = rack_type[row_num];

        // The inner loop iterates over the elements of the row
        for (ball = row_data) {
            x_coord = calc_x_coord(ball);
            translate([x_coord, y_coord]) make_hole();
            echo (str(row_num, ":", ball, "   ", x_coord, "   ", y_coord));
        }
    }
}

function calc_x_coord(x_index) = (hole_dist / 2) * x_index;
function calc_y_coord(y_index) = -hole_dist * y_index * sin(60);

module make_hole() rotate([0, 0, 30]) circle(d = hole_size, $fn=3);

module make_shape() {
    factor = 0.8;
    template_width = hole_size + 10;
    last_row = len(rack_type)-1;
    len_last_row = len(rack_type[last_row]);
    // "a" refers to the top of the triangle
    // "b" refers to the bottom left
    // "c" refers to the bottom right
    ay = calc_y_coord(0);
    ax = calc_x_coord(rack_type[0][0]);
    by = calc_y_coord(last_row);
    bx = calc_x_coord(rack_type[last_row][0]);
    cy = calc_y_coord(last_row);
    cx = calc_x_coord(rack_type[last_row][len_last_row-1]);

    centroid_x = (ax + bx + cx) / 3;
    centroid_y = (ay + by + cy) / 3;

    shrunk_ax = centroid_x + factor * (ax - centroid_x);
    shrunk_ay = centroid_y + factor * (ay - centroid_y);
    shrunk_bx = centroid_x + factor * (bx - centroid_x);
    shrunk_by = centroid_y + factor * (by - centroid_y);
    shrunk_cx = centroid_x + factor * (cx - centroid_x);
    shrunk_cy = centroid_y + factor * (cy - centroid_y);

    difference(){
        color("red", 0.5)
        hull(){
            translate([ax, ay]) circle(d=template_width);
            translate([bx, by]) circle(d=template_width);
            translate([cx, cy]) circle(d=template_width);
        }

        color("green", 0.5)
        hull(){
            translate([shrunk_ax, shrunk_ay]) circle(d=template_width*factor);
            translate([shrunk_bx, shrunk_by]) circle(d=template_width*factor);
            translate([shrunk_cx, shrunk_cy]) circle(d=template_width*factor);
        }
    }

    if (nine_ten_ball_compatable == true){
        mid_left_x = calc_x_coord(-2);
        mid_right_x = calc_x_coord(2);
        mid_y = calc_y_coord(2);
        bottom_y = calc_y_coord(last_row);
        bottom_x = calc_x_coord(0);
        hull(){
            translate([bottom_x, bottom_y]) circle(d=template_width);
            translate([mid_left_x, mid_y]) circle(d=template_width);
        }
        hull(){
            translate([bottom_x, bottom_y]) circle(d=template_width);
            translate([mid_right_x, mid_y]) circle(d=template_width);
        }
        hull(){
            translate([mid_left_x, mid_y]) circle(d=template_width);
            translate([mid_right_x, mid_y]) circle(d=template_width);
        }
    }
}
difference(){
    make_shape();
    make_holes();
}