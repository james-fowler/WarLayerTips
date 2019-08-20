/*
 painting support clamp for WarLayer 4.0
*/
jaw_tooth_top = 25; // from bottom edge of part
jaw_tooth_bottom = 17; // from bottom edge of part
jaw2_tooth_bottom = 50; // from bottom edge of part
jaw_tooth_offset = 12;
jaw_rail_width = 4.2; // width of rail (top of "T") on wall edge
jaw_brace_width = 14;
jaw_slide_wall = 5;
jaw_slide_wall_slop = 0.1; 

wall_height = 77;
tslot_filler_top_width = 4.27;
tslot_filler_mid_width = 2.31;
tslot_filler_top_height = 1.5 ;
tslot_filler_height = 4;
tslot_filler_length = 25;

frame_gap = 20;
frame_rail_width = 15;
frame_rail_inner = 10;
frame_rail_height = 25;
frame_width = 7;

frame_jaw_stop_length = tslot_filler_height * 4;

frame_inner_length = 6 * 25.4; // six inch span

holes = 11;


frame_length = frame_inner_length  // widest wall section it can hold
                    + 2*(jaw_tooth_offset+jaw_brace_width) // additonal space for jaw
                    + 2*frame_jaw_stop_length 
                    ;

jaw_height = jaw_tooth_top - jaw_tooth_bottom;
jaw2_tooth_top = jaw2_tooth_bottom + jaw_height;

$fn = 49;


module half_jaw_frame_teeth() {
    teeth = 2;
    tooth_height  = (jaw_height / (teeth+0)) ;
    
    cr = tooth_height/3;
    ch = tooth_height * 1.5;
    brace_thickness = cr*2;
    tooth_angle = -35;
    //tooth_angle_shift = sqrt(2*cr*cr);
    tooth_angle_shift = cr*cos(tooth_angle)*2;
    
    //tribrace_corner = tooth_height * 1.2;
    tribrace_corner_x =   (ch-cr*2) * cos( tooth_angle );
    tribrace_corner_y =   (ch-cr*2) * sin( tooth_angle );
    union() {
        for( tooth = [1:teeth ] ) {
            z = (tooth - 0.5) * tooth_height;

            translate( [0,0,z] ) {
                translate( [ -cr*sin(tooth_angle), -jaw_rail_width, -brace_thickness/2 ] )
                    linear_extrude( height=brace_thickness ) 
                            polygon( [ 
                                        [ 0, 0 ], 
                                        [ -tribrace_corner_x, tribrace_corner_y ],
                                        [ tooth_height-tribrace_corner_x, tribrace_corner_y ], 
                                        [ ch, 0] 
                                    ] );

                translate( [tooth_angle_shift,0,0] ) 
                    rotate( [0,-90,tooth_angle] )
                        translate( [0,0,-cr] ) {
                            
                            cylinder( r=cr, h =ch );
                        }
                    }
        }
    }
}

anchor_z_height = jaw_brace_width;
module jaw_anchor(fix_teeth = false) {
    translate( [fix_teeth ? jaw_brace_width/4 : 0, jaw_slide_wall, -anchor_z_height/4 ] )
    {
        cube( [ jaw_brace_width*0.75, jaw_slide_wall, anchor_z_height/2] );
    }
    translate( [0, jaw_slide_wall*2, -jaw_brace_width/2 ] ) {
        cube( [ jaw_brace_width, jaw_slide_wall, anchor_z_height] );
    }
}

module half_jaw_frame_rail(fix_teeth = false) {
    union() {
        side_height = frame_gap + frame_rail_height + jaw_slide_wall + jaw_slide_wall_slop*2;

        // teeth
        if( fix_teeth ) {
            translate( [ jaw_brace_width + jaw_tooth_offset, jaw_rail_width/2, jaw_tooth_top ] ) 
                    rotate( [0,180,0] )
                        half_jaw_frame_teeth();
            translate( [ jaw_brace_width + jaw_tooth_offset, jaw_rail_width/2, jaw2_tooth_top] ) 
                    rotate( [0,180,0] )
                        half_jaw_frame_teeth();

        } else {
            translate( [ -jaw_tooth_offset, jaw_rail_width/2, jaw_tooth_bottom ] ) half_jaw_frame_teeth();
            translate( [ -jaw_tooth_offset, jaw_rail_width/2, jaw2_tooth_bottom ] ) half_jaw_frame_teeth();
        }
       
    
        cube( [ jaw_brace_width, frame_rail_width/2+jaw_slide_wall , jaw_slide_wall ] );
        
        // jaw slide outer side
        translate( [ 0, frame_rail_width/2+ jaw_slide_wall_slop , -side_height  ] ) cube( [ jaw_brace_width, jaw_slide_wall, side_height ] );

        // jaw slide inner side
        translate( [ 0, frame_rail_inner/2+ jaw_slide_wall_slop , -frame_gap  ] ) cube( [ jaw_brace_width, jaw_slide_wall, frame_gap ] );

        
        // jaw slide outer bottom
        translate( [ 0, frame_width/2+ jaw_slide_wall_slop , -side_height ] ) cube( [ jaw_brace_width, (frame_rail_width-frame_width)/2+jaw_slide_wall, jaw_slide_wall ] );

        // anchors
        translate( [ 0, frame_rail_width/2+ jaw_slide_wall_slop , -side_height *0.25 ] ) jaw_anchor(  fix_teeth=fix_teeth );
        translate( [ 0, frame_rail_width/2+ jaw_slide_wall_slop , -side_height *0.75 ] ) jaw_anchor(  fix_teeth=fix_teeth );
        translate( [ 0, jaw_rail_width/2-jaw_slide_wall, wall_height + anchor_z_height/2 ] ) jaw_anchor(  fix_teeth=fix_teeth );
        
        
    }
}


module jaw() {
    // triangle brace
    brace_height = wall_height + anchor_z_height ;
    translate( [ 0,  jaw_rail_width /2, 0 ] )
        rotate( [90, 0, 0] )
            linear_extrude( height =  jaw_rail_width  ) 
                polygon( [ 
                                    [0,0], 
                                    [0,brace_height],  
                                    [jaw_brace_width,brace_height],
                                    //[jaw_brace_width/4,brace_height],
                                    //[ jaw_brace_width, jaw2_tooth_top*0.75], 
                                    [ jaw_brace_width, 0] 
                            ] ) ;
    
    // jaws
    translate( [ -jaw_tooth_offset, - jaw_rail_width /2, jaw_tooth_bottom ] ) cube( [ jaw_tooth_offset*1.5, jaw_rail_width, jaw_height ] );
    translate( [ -jaw_tooth_offset, - jaw_rail_width /2, jaw2_tooth_bottom ] ) cube( [ jaw_tooth_offset*1.5, jaw_rail_width, jaw_height ] );

    translate( [ -jaw_tooth_offset, - jaw_rail_width /2, jaw2_tooth_bottom ] ) cube( [ jaw_tooth_offset*1.5, jaw_rail_width, jaw_height ] );
    
   if(1) half_jaw_frame_rail();
    
    if(1) translate( [jaw_brace_width,0,0] ) {
            rotate( [0,0,180] ) {
                half_jaw_frame_rail(fix_teeth=true);
            }
        }
}


module t_support(inner = true) {
    t_slop = inner ? -0.2 : 0.2;
    t_top_width = tslot_filler_top_width + t_slop;
    t_mid_width = tslot_filler_mid_width + t_slop;
    t_top_height = tslot_filler_top_height + t_slop / 2;
    t_height = tslot_filler_height;
    difference() {
        union() {
            translate( [0, -t_top_width/2, -frame_gap] ) 
                cube( [ t_top_height, t_top_width, frame_gap ] );

            translate( [0, -t_mid_width/2, -frame_gap] ) 
                cube( [ t_height, t_mid_width, frame_gap ] );
            translate( [-t_top_height, -t_mid_width/2, -frame_gap] ) 
                cube( [ t_top_height, t_mid_width, frame_gap/2 ] );

        }
        
        cube_size = t_top_width*1.5;
        translate( [0, -t_top_width/2, 0] ) 
            rotate( [0,45,0] )
                cube( [ cube_size, cube_size, cube_size ] );
        

    }
    
}

module frame_tslot_cutout() {
           translate( [ 0, -frame_rail_width/2,  0 ] ) {
                        rotate( [-90, 0, 180] )  t_support(inner=false);
                }
                translate( [ 0, frame_rail_width/2,  0 ] ) {
                       rotate( [90, 0, 180] )  t_support(inner=false);
                }
                
}
module frame() {
    hole_r = frame_rail_width/3;
    hole_interval =  frame_inner_length   / holes;
    hole_offset = (frame_length - frame_inner_length - hole_interval) / 2;
    difference() {
        union() {
            // main rail
            translate( [-frame_length, 0, -frame_gap-frame_rail_height ] ) {
                translate( [ 0, -frame_rail_width/2, 0 ] ) cube( [  frame_length,  frame_rail_width, frame_rail_height ] );
            }

            
            if(0) { // base-ish bit for handle to grab
                top_clamp_width = 35;
                lower_radius = 25;
                lower_width = 18;
                upper_radius = 32;
                upper_width = 22.8;
                
                translate( [-frame_length/2, 0, -frame_gap-frame_rail_height] ) {
                    cylinder( h=2, r1=lower_radius/2, r2 = lower_radius/2.25 );
                    translate( [-top_clamp_width/2,-lower_width/2, 0] )
                            cube( [ top_clamp_width, lower_width, 2 ] );
                    translate( [0,0,2] )  {
                        cylinder( h=2, r1=upper_radius/2, r2 = upper_radius/2.25 );
                        translate( [-top_clamp_width/2,-upper_width/2, 0] )
                                cube( [ top_clamp_width, upper_width, 2 ] );
                    }
                }
            }
            
            // wall bottom / post supports
            for( hole = [ 1 : holes ] ) {
                rotation =  ( hole == (holes+1) / 2 ) ? 
                                                90 // middle
                                    :  ( (hole < holes/2) ?
                                                 0 // left
                                            :
                                                180 // right
                
                            );
                translate( [ -hole_interval * hole - hole_offset, 0,  0 ] ) {
                    rotate( [0, 0, rotation] ) 
                        t_support();
                }
            }
            if(0) { // test for end stop holes
                translate( [ -frame_length+frame_jaw_stop_length,///2,
                        frame_jaw_stop_length*4,  -frame_gap-tslot_filler_length/2] ) {
                    rotate( [-180, 0, 0] ) 
                        //scale( [t_slot_negative_scale, t_slot_negative_scale, t_slot_negative_scale] )
                            t_support(inner=false);
                        }
            }
        }
        
        // holes 
        for( hole = [ 1 : holes ] ) {
            translate( [ -hole_interval * hole - hole_offset, 0,  0 ] ) {
                translate( [ 0, frame_rail_width,  -frame_gap-(frame_rail_height/2) ] ) {
                    rotate( [90,0,0] ) {
                        cylinder( r=hole_r, h=frame_rail_width*2 );
                    }
                }
            }
        }
       
        
        translate( [ 0, 0,  -frame_gap-tslot_filler_length/2] ) {
                 translate( [ -frame_length+frame_jaw_stop_length/2, 0, 0] ) 
                    frame_tslot_cutout();

                 translate( [ -frame_jaw_stop_length/2, 0, 0] ) 
                    rotate( [ 0, 180, 0 ] )
                    frame_tslot_cutout();
         
    
            }
        }
        
}

module frame_size_test() {
    frame_length = 25;
    hole_interval = 0;
    hole_offset = frame_length/2;
    holes = 1;
 difference() {
        union() {
            
            // main rail
            translate( [-frame_length, 0, -frame_gap-frame_rail_height ] ) {
                translate( [ 0, -frame_rail_width/2, 0 ] ) cube( [  frame_length,  frame_rail_width, frame_rail_height ] );
            }
       
            // wall bottom / post supports
            for( hole = [ 1 : 1] ) {
                rotation =  ( hole == (holes+1) / 2 ) ? 
                                                90 // middle
                                    :  ( (hole < holes/2) ?
                                                 0 // left
                                            :
                                                180 // right
                
                            );
                translate( [ -hole_interval * hole - hole_offset, 0,  0 ] ) {
                    rotate( [0, 0, rotation] ) 
                        t_support();
                }
            }
             }
        
             
        translate( [ -frame_length+frame_jaw_stop_length/2, 0,  -frame_gap-tslot_filler_length/2] ) {
                    rotate( [-180, 0, 180] )  t_support(inner=false);
            }
        translate( [ -frame_jaw_stop_length/2, 0,  -frame_gap-tslot_filler_length/2] ) {
                    rotate( [-180, 0, 0] )  t_support(inner=false);
            }

    }
        
}

frame_display_gap = 5;

if(0) {
} else if(0) {
    jaw();
    translate( [-frame_display_gap,0,0] ) frame();
    translate( [-frame_display_gap*2-frame_length,0,0] ) rotate( [0,0,180] ) jaw();
} else {
    rotate( [0,0,45] ) 
    {
        //rotate( [ 0, 90, 0] )  jaw();
        frame();
        //frame_size_test();
    }
}

//translate( [-frame_display_gap*2-frame_length,0,0] ) rotate( [0,0,180] ) jaw();