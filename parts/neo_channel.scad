use <common.scad>;

$fn=77;

strip_settings = default_settings( [
        // [ "tag", val ],                      //  measured GW part  / measured printed
        

        ["led_spacing",  49.5 / 7  ],  // 55 / 8; // distance from START of an led to START of next led (not the gap between)

        ["led_overhang",  1 ],
        ["shroud_height",   2 ],

        ["led_inner_width",  4.0 ], // width of the inner circle
        
        ] ) ;


cs1 = default_settings( [
        // [ "tag", val ],                      //  measured GW part  / measured printed
        
        ["led_length", 5.0 ],          // outer dimension of LED along strip
        ["led_width",  5.0 ],          // outer dimension of LED across strip
        
        ["led_spacing",  49.5 / 7  ],  // 55 / 8; // distance from START of an led to START of next led (not the gap between)

        ["led_overhang",  1 ],
        ["shroud_height",   2 ],

        ["led_inner_width",  4.0 ], // width of the inner circle
        
        ["strip_width",   12.1 ],  // outer width of strip
        ["sw_instep",   -1 ],  // 
        ["sw_outstep",   0.8 ],  // outer width of inserts
        ["channel_width",   16 ],  // outer width of channel
        ["channel_depth",   5 ],  
        ["channel_d_bottom",   1 ],           // height of channel bottom
        ["channel_d_strip",   2 ],           // height of channel strip ledge 
        ["channel_d_insert",   3 ],           // height of channel insert ledge
        ] ) ;
        
        
function tadd( settings, tag, val ) = tmerge( settings, [ [tag,val] ]  );        

function cs_fill( settings ) = 
    let(  gap = tval( "led_spacing", settings ) - tval( "led_length", settings )  )
        tmerge( settings, [
                        [ "outer_width", tval( "led_width", settings ) * 1.5 ],
                        [ "gap", gap ],
                        ["outer_length",  tval( "led_length", settings )+ gap  ],
                ]  );        
        
channel_settings = cs_fill(   cs1 );
            
  echo( "channel_settings : ", channel_settings );
    
// fiber_diameter
fiber_diameter = 2.0;
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


bh2_offset = fiber_diameter *0.58;
big_holes2 = [
    [ fiber_diameter*0.9, fiber_shoulder, 0, 0, 0 ],
    [ fiber_diameter, fiber_shoulder, bh2_offset, 0, 0 ],
    [ fiber_diameter, fiber_shoulder, bh2_offset, 120,  0 ],
    [ fiber_diameter, fiber_shoulder, bh2_offset, 240,  0 ],
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



$fn = 64;

module make_hole(settings,hole,div) {
        rotate( [0,hole[4],hole[3] ] ) {
            translate( [hole[2], 0, 0 ] ) {
                cylinder( r = hole[0]/div, h = tval("shroud_height", settings) + hole[1] *div);
            }
        }
}

module cover(settings, holes) {
    led_length = tval("led_length",settings);
    led_spacing = tval("led_spacing",settings);
    led_overhang = tval("led_overhang",settings);
    led_width = tval("led_width",settings);
    led_inner_width = tval("led_inner_width",settings);
    shroud_height  = tval("shroud_height",settings);
    
    outer_width = tval("outer_width",settings); // led_width * 1.5;
    gap = tval("gap",settings); // led_spacing - led_length;
    outer_length = tval("outer_length",settings); // led_length+ gap;
    echo(  "outer_width ,gap,outer_length = ", outer_width ,gap,outer_length  );
    
    difference() {
        union() {
            translate( [ -outer_length/2, -outer_width/2, -led_overhang ] ) {
                cube( [ outer_length, outer_width, led_overhang  + shroud_height ] );
            }
            for( hole = holes ) {
                make_hole( settings, hole, 1 );
            }
        }
        
        translate( [ -led_length/2, -led_width/2, -led_overhang ] ) {
            cube( [ led_length, led_width, led_overhang  ] );
        }
        sphere( r = led_inner_width/2 , center=true);
            for( hole = holes ) {
                make_hole( settings, hole, 2 );
            }
    }
    
}

module strip(settings,  strip_holes) {
    led_spacing = tval( "led_spacing", settings );
    led_length = tval("led_length",settings);
    union() {
        echo( "strip count : ",  len(strip_holes), "  led_spacing:", led_spacing , "  led_length:", led_length  );
        for( i = [0:len(strip_holes)-1] ) {
            holes = strip_holes[i];
            translate( [i * led_spacing, 0, 0 ]) {
                cover(settings,holes);   
            }
        }
    }
}

module channel_cover( settings, hole ) {
    channel_width = tval( "channel_width", settings );
    channel_depth = tval( "channel_depth", settings );
    led_spacing = tval( "led_spacing", settings );
    led_overhang = tval("led_overhang", settings);
    width_along_channel = led_spacing  * 0.9;
    led_width = tval("led_width",settings);
    offset = tval("sw_outstep",settings);
    width = tval("strip_width",settings) + offset * 2;
    height = channel_depth - tval( "channel_d_insert", settings );
     difference() 
    {
        union() {
            cover(settings,hole);   
            translate( [ 0,  -led_spacing/2,  -led_overhang ]  )
                difference() {
                    translate( [ -width/2,  0,  0 ]  )
                        cube( [  width, led_spacing,  height ] );
                    translate( [ -led_width /2,  0,  0 ]  )
                        cube( [  led_width , led_spacing,  height ] );
                }
        }
        translate( [ -channel_width/2, -width_along_channel*1.5, -led_overhang ] )                cube( [channel_width,width_along_channel,channel_depth*3] );
        translate( [ -channel_width/2, width_along_channel*0.5, -led_overhang ] )                cube( [channel_width,width_along_channel,channel_depth*3] );
    }
}


module strip_cut(  tag, btag, channel_length, settings ) {
    channel_width = tval( "channel_width", settings );
    channel_depth = tval( "channel_depth", settings );
    offset = tag == 0 ? 0 : tval(tag,settings);
    width = tval("strip_width",settings) + offset * 2;
     translate( [ -width/2,  0,  tval(btag,settings)]  )
                cube( [  width, channel_length,  channel_depth ] );
}
    
module channel( settings, length ) {
    led_spacing = tval( "led_spacing", settings );
    channel_width = tval( "channel_width", settings );
    channel_depth = tval( "channel_depth", settings );

    channel_length = led_spacing * length;
    difference() {
        translate( [ -channel_width/2,0,0 ]  )
                cube( [ channel_width , channel_length,  channel_depth ] );
        strip_cut( "sw_instep",  "channel_d_bottom", channel_length, settings);
        strip_cut( 0,  "channel_d_strip",channel_length, settings);
        strip_cut( "sw_outstep",  "channel_d_insert",channel_length, settings);
    }
    
    lip_r =   (channel_width -  tval( "strip_width",settings)  - tval( "sw_outstep",settings) *2 )  / 4;
    lip_x_offset = lip_r /7;
    lip_z_sa = (lip_r-lip_x_offset )/ lip_r ;
    lip_z_a = asin(lip_z_sa);
    lip_z_offset = cos(lip_z_a) * lip_r;
    //echo( "lip_r = ", lip_r, "  lip_x_offset=", lip_x_offset,"  lip_z_a=", lip_z_a, "   lip_z_sa=", lip_z_sa, "    lip_z_offset=", lip_z_offset );
    //echo( "sin= ", sin( lip_z_a), "cos= ", cos( lip_z_a), "tan= ", tan( lip_z_a));
    //lip = sqrt( lip_r * lip_r * 2 );

    translate(  [ -channel_width/2+ lip_r,0,channel_depth  ]  ) {

        translate(  [ -lip_r,0,-lip_z_offset]  ) cube( [ lip_r, channel_length, lip_r*2] );

        translate(  [ lip_x_offset,0,lip_z_offset  ]  ) {
            rotate( [ -90, 0, 0 ] ) 
                cylinder( r=lip_r, h=channel_length );
        };
    }

    translate(  [  channel_width/2 - lip_r,0,channel_depth  ]  ) {

        translate(  [ 0,0,-lip_z_offset]  ) cube( [ lip_r, channel_length, lip_r*2] );

        translate(  [- lip_x_offset,0,lip_z_offset  ]  ) {
            rotate( [ -90, 0, 0 ] ) 
                cylinder( r=lip_r, h=channel_length );
        };
    }

    // cover(settings,hole);   
}

//strip( strip_settings, strip_holes );
// channel_cover( channel_settings, big_holes2 );

// translate( [(12.1+1.6)/2,-5,0] )  rotate( [-90,0,0] )
channel( channel_settings, 7 );