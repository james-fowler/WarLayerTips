use <common.scad>

// outer dimension of LED along strip
led_length = 4.91; 

// outer dimension of LED across strip
led_width = 4.91;

// distance from START of an led to START of next led (not the gap between)
led_spacing = 55 / 8;

led_overhang = 1;
shroud_height = 2;

// width of the inner circle
led_inner_width = 4.0;

// fiber_diameter
fiber_diameter = 1.75;
fiber_shoulder = 2.0;

test_holes = [
    [ fiber_diameter, fiber_shoulder, 0, 0, 0 ],
    [ 0.75, fiber_shoulder, 1.4, 0, 0 ],
    [ 0.75, fiber_shoulder, 0.3, 90, 15 ],
];

big_hole = [
    [ fiber_diameter, fiber_shoulder, 0, 0, 0 ],
];

big_holes = [
    [ fiber_diameter, fiber_shoulder, 0, 0, 30 ],
    [ fiber_diameter, fiber_shoulder, 0, 120, 30 ],
    [ fiber_diameter, fiber_shoulder, 0, 240, 30 ],
];

lh_offset = 0.214;
lh_angle = 12;
lh_shoulder = 1.4;
lh_diameter = 0.75;
little_holes = [
    [ lh_diameter, lh_shoulder, lh_offset, 0, lh_angle ],
    [ lh_diameter, lh_shoulder, lh_offset, 90, lh_angle ],
    [ lh_diameter, lh_shoulder, lh_offset, 180, lh_angle ],
    [ lh_diameter, lh_shoulder, lh_offset, 270, lh_angle ],
    
];

strip_holes = [
    test_holes,
    little_holes,
    little_holes,
    big_hole,
    big_holes,
    big_hole,
    little_holes,
    little_holes,
];

// *************************************************************
/* [Hidden] */

gap = led_spacing - led_length;

$fn = 64;

module make_hole(hole,div) {
        rotate( [0,hole[4],hole[3] ] ) {
            translate( [hole[2], 0, 0 ] ) {
                cylinder( r = hole[0]/div, h = shroud_height + hole[1] *div);
            }
        }
}

module cover(holes) {
    
    outer_width = led_width * 1.5;
    outer_length = led_length + gap;
    
    difference() {
        union() {
            translate( [ -outer_length/2, -outer_width/2, -led_overhang ] ) {
                cube( [ outer_length, outer_width, led_overhang  + shroud_height ] );
            }
            for( hole = holes ) {
                make_hole( hole, 1 );
            }
        }
        
        translate( [ -led_length/2, -led_width/2, -led_overhang ] ) {
            cube( [ led_length, led_width, led_overhang  ] );
        }
        sphere( r = led_inner_width/2 , center=true);
            for( hole = holes ) {
                make_hole( hole, 2 );
            }
    }
    
}

module strip() {
    union() {
        // echo( "strip count : ",  len(strip_holes) );
        for( i = [0:len(strip_holes)-1] ) {
            holes = strip_holes[i];
            translate( [i * led_spacing, 0, 0 ]) {
                cover(holes);   
            }
        }
    }
}

strip();
