
// PDIP package generator
//
// Copyright (c) 2019 Korbinian Schreiber
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


// Generates the PDIP body, centered at [0, 0, 0]
module body(nr_legs=14, width=6.477, $fn=$fn){
    // Body dimensions
    height=3.3;
    standart_width=6.477;
    length=(3.0 + (nr_legs/2 - 1)*2.54);

    // The body has trapezoid contours
    trapezial = 0.15*standart_width/width;
    contour = [
        [-width/2, -length/2],
        [width/2, -length/2],
        [width/2, length/2],
        [-width/2, length/2]
    ];
    xscale = 1 - trapezial;
    yscale = 1 - width/length*trapezial;

    // The direction marker scales with the size (sort of)
    marker_diameter = (0.3*standart_width) + (0.1*(width - standart_width));

    difference() {
        union(){
            linear_extrude(height=height/2, scale=[xscale, yscale]){
                polygon(contour);
            };
            rotate([0, 180, 0]){
                linear_extrude(height=height/2, scale=[xscale, yscale]){
                    polygon(contour);
                };
            };
        };
        translate([0, length/2*(1 - 0.75*width/length*trapezial), height/2]){
            rotate([0, 0, 0]){
                cylinder(d=marker_diameter, h=0.25*height, $fn=$fn, center=true);
            }
        };
    }
}

// Generates a leg, such that the leg origin is at at [0, 0, 0]
module leg(phi = 84.93, , $fn=$fn){
    // Parameters for top part
    twidth = 1.397;
    theight = 2.158;
    height_ratio = 0.7;
    width_ratio = 0.5;

    // Parameters for bottom part
    bwidth = 0.457;
    bheight = 3.048;

    // Material thickness
    strength = 0.292;

    // Extension of the upper part of the leg after bending
    center_extension = 0.5;

    rotate([0, 0, 90]){
        translate([0, 0, -1.5*strength]){
            union(){
                // Upper part of the leg that extends to the center
                translate([0, center_extension/2, 1.5*strength]){
                    cube([twidth, center_extension, strength], center=true);
                };
                // Bent part of the leg
                rotate([0, -90, 180]){
                    rotate_extrude(angle=phi, $fn=$fn){
                        polygon(points=[
                            [strength, -twidth/2],
                            [2*strength, -twidth/2],
                            [2*strength, twidth/2],
                            [strength, twidth/2]
                        ]);
                    };
                }
                // Torch-shaped leg
                rotate([phi, 0, 0]){
                    translate([0, 0, strength]){
                        linear_extrude(height=strength){
                            polygon(points=[
                                [-twidth/2, 0],
                                [-twidth/2, -height_ratio*theight],
                                [-width_ratio*twidth/2, -theight],
                                [-bwidth/2, -theight],
                                [-bwidth/2, -theight-bheight],
                                [bwidth/2, -theight-bheight],
                                [bwidth/2, -theight],
                                [width_ratio*twidth/2, -theight],
                                [twidth/2, -height_ratio*theight],
                                [twidth/2, -theight],
                                [twidth/2, 0],
                            ]);
                        };
                    };
                };
            };
        };
    };
}

// Generates the whole chip, centered at [0, 0, 0]
module pdip_package(nr_legs=14, package_type=0, $fn=128){
    widths = [6.477, 6.477+2.45, 6.477+(3*2.45)];
    width = widths[package_type];
    union(){
        body(nr_legs=nr_legs, width=width, $fn=$fn);
        for (i=[0:nr_legs/2 - 1]) {
            translate([-width/2, (nr_legs/4 - 0.5)*2.54 - (2.54*i), 0]){
                rotate([0, 0, 180]){
                    leg();
                };
            };
        };
        for (i=[0:nr_legs/2 - 1]) {
            translate([width/2, (2.54*i) - (nr_legs/4 - 0.5)*2.54, 0]){
                rotate([0, 0, 0]){
                    leg($fn=$fn);
                };
            };
        };
    };
}

// Generate an example image
rotate([0, 0, $t*360]){
    rotate([0, 0, 0]) translate([0, 10*1.27, 0]) pdip_package(nr_legs=8, package_type=0);
    rotate([0, 0, 120]) translate([0, 17*1.27, 0]) pdip_package(nr_legs=22, package_type=1);
    rotate([0, 0, 240]) translate([0, 20*1.27, 0]) pdip_package(nr_legs=28, package_type=2);
}
