use <common.scad>;

$fn=77;

/* [Hidden] */

$fn =88;


function d_settings( filament_size, settings ) = 
    let(  cylinder_top_r = filament_size * 3  )
        tmerge(  [
                        [ "cylinder_height", 5 ],
                        [ "filament_size", filament_size ],
                        ["cylinder_top_r",  cylinder_top_r ],
                ] , settings );        
        

module bulb_socket( settings ) {
    filament_size = tval( "filament_size", settings );
    
    h =  tdval( "socket_h", tval("cylinder_height", settings ) -  filament_size, settings );
    union() {
        cylinder( r=filament_size/2, h=h);
        translate( [0,0,h] )
                sphere( r = filament_size );
    }
  }
  
  
  module side_socket_bulb( settings , side_height , sbmult ) {
    filament_size = tval( "filament_size", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
      bulb_side = filament_size * sbmult;
     union() {
            translate( [-cylinder_top_r,0, side_height ] )
                rotate( [0,90,0] )
                    cylinder( r=filament_size/2, h=cylinder_top_r );

            translate( [0,0, side_height - (filament_size / 2 ) + bulb_side] )
                    sphere( r = bulb_side );
        }
  }
  
  module side_socket( settings, mirror = false, sbmult = 1 ) {
    filament_size = tval( "filament_size", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
      
      side_height = filament_size *1.5;
      
      if( mirror ) {
           difference()    {
            side_socket_bulb( settings , side_height, sbmult = sbmult    ) ;
            cube_side = cylinder_top_r;
            translate( [filament_size , -cube_side/2, side_height +filament_size /2] )
                rotate( [ 0, 135,  0 ] )
                    cube( [ cube_side, cube_side, cube_side] );
        }
    } else {
          side_socket_bulb( settings , side_height, sbmult = sbmult   ) ;
    }
}


module simple_socket( settings ) {
    filament_size = tval( "filament_size", settings );
    
    h =  tdval( "socket_h", tval("cylinder_height", settings ) -  filament_size / 2, settings );
    union() {
        cylinder( r=filament_size/2, h=h);
        translate( [0,0,h] )
                sphere( r = filament_size/2 );
    }
    
}

module cylinder_bottom(settings) {
    filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
    r1 = tdval( "cylinder_bottom_r", filament_size  *2, settings );

        cylinder ( h=cylinder_height , r1=r1,  r2=cylinder_top_r ) ;
}

module round_bottom(settings) {
    
        filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );

      //  cylinder ( h=cylinder_height , r1=filament_size  *2,  r2=cylinder_top_r ) ;

    lens_height = cylinder_height ;
    
    lens_angle = atan( lens_height / cylinder_top_r );
    lens_diameter =  ((( tan(90-lens_angle)) * cylinder_top_r) + lens_height) ;
    lens_r = lens_diameter  / 2;
    lens_r_offset = lens_r  - lens_height;
    
    echo( "lens_height, cylinder_top_r , lens_angle, lens_diameter , lens_r_offset, lens_r = ", lens_height, cylinder_top_r , lens_angle, lens_diameter , lens_r_offset, lens_r );
    echo( "cos, sin, tan = ", cos(lens_angle),   sin(lens_angle),  tan(lens_angle));
    echo( "cos, sin, tan = ", cos(90-lens_angle),   sin(90-lens_angle),  tan(90-lens_angle));
    
    translate( [0,0,cylinder_height  ]  ) {
        difference() {
            translate( [0,0, lens_r_offset ] ) sphere( r=lens_r , $fn=tdval( "top_fn", 17, settings )  );
            translate( [-lens_r, -lens_r,  0] )  {
                cube( [ lens_r*2, lens_r*2, lens_r*2] );
            }
            //translate( [0,0, lens_height] )  rotate( [180,0,0] ) cylinder( r1 = filament_size*2, r2=0, h=filament_size );
        }
    }
}

module sphere_top(settings) {
    filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
    lens_height = cylinder_height ;
    
    lens_angle = atan( lens_height / cylinder_top_r );
    lens_diameter =  ((( tan(90-lens_angle)) * cylinder_top_r) + lens_height) ;
    lens_r = lens_diameter  / 2;
    lens_r_offset = lens_r  - lens_height;
    
    echo( "lens_height, cylinder_top_r , lens_angle, lens_diameter , lens_r_offset, lens_r = ", lens_height, cylinder_top_r , lens_angle, lens_diameter , lens_r_offset, lens_r );
    echo( "cos, sin, tan = ", cos(lens_angle),   sin(lens_angle),  tan(lens_angle));
    echo( "cos, sin, tan = ", cos(90-lens_angle),   sin(90-lens_angle),  tan(90-lens_angle));
    
    translate( [0,0,cylinder_height  ]  ) {
        difference() {
            translate( [0,0,- lens_r_offset ] ) sphere( r=lens_r , $fn=tdval( "top_fn", 17, settings )  );
            translate( [-lens_r, -lens_r, -lens_r *2] )  {
                cube( [ lens_r*2, lens_r*2, lens_r*2] );
            }
            translate( [0,0, lens_height] )  rotate( [180,0,0] ) cylinder( r1 = filament_size*2, r2=0, h=filament_size );
        }
    }
}


module lens_top(settings, double=false) {
    filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
    lemult = tdval( "lemult", 0.5, settings );
    lens_curve_height = filament_size *  lemult ;

    lens_height = lens_curve_height * ( double ?  3 : 2 );
    lens_angle = atan( lens_curve_height / (cylinder_top_r *0.8) );
    lens_diameter =  ((( tan(90-lens_angle)) * cylinder_top_r) + lens_curve_height) ;
    lens_r = lens_diameter  / 2;
    lens_r_offset = lens_r  - lens_curve_height;
    
    lens_fn = 128 / lemult ;
    translate( [0,0,cylinder_height  ]  ) {
        difference() {
            cylinder( r= cylinder_top_r, h = lens_height );
            translate( [0,0,- lens_r_offset ] ) rotate( [90,90,90] ) sphere( r=lens_r , $fn=lens_fn  );
            if( double ) {
                translate( [0,0, lens_height + lens_r_offset ] )  rotate( [90,90,90] )  sphere( r=lens_r , $fn=lens_fn  );
            }
        }
    }
}

module flat_top(settings) {
    filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
    lens_height = cylinder_height ;
    
    translate( [0,0,cylinder_height  ]  ) {
        cylinder( r= cylinder_top_r, h = cylinder_height/2 );
            
    }
}
module torus_top(settings) {
    filament_size = tval( "filament_size", settings );
    cylinder_height = tval( "cylinder_height", settings );
    cylinder_top_r = tval( "cylinder_top_r", settings );
    
    lens_height = cylinder_top_r/2;
    
    lens_r = lens_height;
    echo("TORUS_TOP ", cylinder_height, lens_r ); 
    translate( [0,0,cylinder_height  ]  ) {
        difference() {
                rotate_extrude(convexity = 10)
                    translate([lens_r+0.001, 0, 0])  // extra +0.0001 workaround for OpenSCAD bug
                            circle(r = lens_r, $fn = 36);
            
        cube_half = lens_r*2.1;
            translate( [-cube_half, -cube_half, -cube_half *2] )  {
                cube( [ cube_half*2, cube_half*2, cube_half*2] );
            }
        }
    }
}

module diffusor( settings, top, bottom = "cylinder", socket  = "simple" ) {
    difference() {
        union() {
            if( bottom == "cylinder" ) {
                cylinder_bottom( settings );
             } else if( bottom == "round" ) {
                round_bottom( settings );
             } else if( bottom == "none" ) {
            } else {
                 echo( concat( "WARNING : bad bottom [" ,  bottom , "] " ) );
                cylinder_bottom( settings );
            }
            
             if( top == "torus" ) {
                    torus_top( settings );
             } else if( top == "sphere" ) {
                sphere_top( settings );
             } else if( top == "flat" ) {
                flat_top( settings );
             } else if( top == "lens" ) {
                lens_top( settings );
             } else if( top == "lens2" ) {
                lens_top( settings, double=true );
             } else if( top == "none" ) {
             } else  {
                 echo( concat( "WARNING : bad top [" ,  top , "] " ) );
                sphere_top( settings );
             }
        }
        
        if( socket   == "simple" ) {
            simple_socket( settings  );
        } else if( socket   == "bulb" ) {
            bulb_socket( settings  );
          } else if( socket   == "side" ) {
                side_socket( settings  );
          } else if( socket   == "srnd" ) {
                side_socket( settings , sbmult=0.5 );
          } else if( socket   == "smir" ) {
                side_socket( settings, mirror=true  );
          } else if( socket   == "none" ) {
        } else {
            echo( concat( "WARNING : bad socket [" ,  socket , "] " ) );
            simple_socket( settings  );
        }
    }
}


/*
diffusors = [
    [settings, "torus", "", "" ],
    [settings, "sphere", "", "" ],
    [settings, "sphere", "", "bulb" ],
];
*/

module diffusors_round( diffusor_list ) {
    d_count = len(diffusor_list);
    
    top_crs  = [ for( d = diffusor_list ) tval( "cylinder_top_r", d[0]  )  ] ;
    max_cr = max( top_crs  );
    max_filament = max(  [ for( d = diffusor_list ) tval( "filament_size", d[0]  )  ] );
    d_min_spacing = max_cr*2;
    d_one_angle = 360 / (d_count+1);
    r_extra = d_count > 4 ? 0 : max_cr / 2 * (1 / (d_count-1) );
    r_offset = d_min_spacing  / tan(d_one_angle/2)  /2  +   r_extra;
    echo( "max_cr, d_min_spacing, d_one_angle, r_offset, d_count, top_crs  = ", max_cr, d_min_spacing, d_one_angle, r_offset , d_count, top_crs  );
    for( i = [ 0 : d_count  -1]  ) {
        ds = diffusor_list[i];
        dangle = i * (360 / d_count);
        dsettings = ds[0];
        top_style = ds[1];
        bottom_style = ds[2];
        socket_style = ds[3];
        
        echo( i, top_style, bottom_style, socket_style , " at ", dangle, " degrees"  );
        
        translate( [sin(dangle)* r_offset ,cos(dangle)*r_offset,0] ) 
                    diffusor( dsettings, top_style, bottom_style, socket_style );
    }
    base_height = 1;
    difference() {
        cylinder( r = r_offset + max_cr, h = base_height );
        for( i = [ 0 : d_count  ]  ) {
            dangle = i * (360 / d_count);
            translate( [sin(dangle)* r_offset ,cos(dangle)*r_offset,0] ) 
                        cylinder( r=max_filament, h=base_height);
            }
    }
}


module diffusors( diffusor_list ) {
    d_count = len(diffusor_list);
    
    top_crs  = [ for( d = diffusor_list ) tval( "cylinder_top_r", d[0]  )  ] ;
    max_cr = max( top_crs  );
    max_filament = max(  [ for( d = diffusor_list ) tval( "filament_size", d[0]  )  ] );
    gap = max_cr / 5;
    center_separation =  max_cr *2 + gap;
    build_plate_width = 65;
    
    // per_row = floor( min( build_plate_width  / center_separation , d_count / 4 ));
    per_row = floor( build_plate_width  / center_separation );
    
    for( i = [ 0 : d_count  -1]  ) {
        ds = diffusor_list[i];
        row = floor( i / per_row );
        col = i - (row * per_row );
        dsettings = ds[0];
        top_style = ds[1];
        bottom_style = ds[2];
        socket_style = ds[3];
        
        rotation = ( socket_style == "smir" || socket_style == "side"  || socket_style == "srnd" ) ? 90 : 180;
        xshift = (rotation==90)?center_separation/4:0;
        echo("placing ", i , " at ", row, col );
        translate( [row * center_separation -xshift, col * center_separation,0] ) 
            rotate( [ 0, rotation, 0 ] )
                    diffusor( dsettings, top_style, bottom_style, socket_style );
    }
    
    if(0) {
        base_height = 1;
        rows = floor( (d_count-1) / per_row ) + 1;
        cols = (rows == 1 ) ? d_count : per_row;
        difference() {
            translate( [ -center_separation/2, -center_separation/2, 0 ] )
                cube( [center_separation * rows, center_separation * cols, base_height ] );
            for( i = [ 0 : d_count  ]  ) {
                row = floor( i / per_row );
                col = i - (row * per_row );
                translate( [row * center_separation, col * center_separation,0] ) 
                            cylinder( r=max_filament, h=base_height);
                }
        }
    }
}

// ********************
   
settings = d_settings( 2 );
s2 = d_settings( 1.8,  [
                    [ "top_fn", 77 ] 
        ] );

if( 0 )
        diffusors( [
            [settings, "torus", "", "side" ],
            [settings, "sphere", "", "side" ],
            [settings, "sphere", "", "smir" ],
        [settings, "sphere", "", "bulb" ],
    [settings, "sphere", "", "bulb" ],
[settings, "sphere", "", "bulb" ],
] );

 function add_shapes( settings, shapes = ["torus","sphere","flat"],  bottoms=["cylinder"], sockets=["side","smir","","bulb"]
           ) =
            [ for( shape =  shapes ) for( bottom = bottoms )  for( socket = sockets ) [settings, shape,  bottom, socket] ]    ;
                
if( 1 )  {
        // ds_list =      concat( add_shapes( settings ),  add_shapes( s2, shapes=["torus","sphere"]) );


  ds_list =       concat( 
                                add_shapes( s2, ["flat"],    ["cylinder","round"], sockets=["side","smir", "srnd" ]  ),
                                 add_shapes( tmerge(s2, [ [ "cylinder_bottom_r", 0.5]]),  ["flat"],   ["cylinder"], sockets=["side","smir", "srnd" ]  )
    
                                // add_shapes( s2,  ["lens", "lens2"],    ["none"], sockets=["side"]   ),
                                // add_shapes( tmerge(s2, [["lemult", 0.3]]),  ["lens", "lens2"],   ["none"], sockets=["side"]  )

                                //, add_shapes( settings, ["flat"],   [""], sockets=["side","smir" ] ) 
                       )
            ;
    echo( ds_list );
    diffusors( ds_list );
                            }
