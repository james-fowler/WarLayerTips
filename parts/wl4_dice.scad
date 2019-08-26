wall_height = 77;               // height of support post
post_2x_on_center = 102;       // horizontal distance from center to center of posts along 2X walls
corner_support_depth = 3.1;  // from top of roof support ledge to top of post

max_wall_width = 7.5;
inside_max_width = post_2x_on_center - max_wall_width;

function dt_t1( i, j ) = [ i, j, i+3];
function dt_t2( i, j ) = [  i+3, j, j+3 ];

module depth_tri( a, b, c, delta ) {
    //echo( "beveled_cube ", b1, b2, t1, t2 );
    points = [
                  [ a.x, a.y,  a.z ],  //0
                  [ b.x, b.y,  b.z ],  //1
                  [ c.x,  c.y,  c.z ],  //2
                  [ a.x + delta.x, a.y+ delta.y,  a.z + delta.z],  //3
                  [ b.x+ delta.x, b.y+ delta.y,  b.z + delta.z],  //4
                  [ c.x+ delta.x, c.y+ delta.y,  c.z + delta.z],  //5
            ];
     polyhedron(  points = points,
             faces = [
                  [0,1,2],  // top
                /*
                     dt_t1(0,1), dt_t2(0,1),
                     dt_t1(1,2), dt_t2(1,2),
                     dt_t1(2,0), dt_t2(2,0),
    */
                  [2,1,4,5],  // side BC
                  [2,5,3,0],  // side CA
                  [3,5,4],  // bottom
                  [0,3,4,1],  // side AB
    
                   //[0,1,4,], [ 4,3,1 ],  // side AB

                  // [5, 4, 3],  // bottom
              
                  
            ] , convexity = 3 );
}

function distance(a, b) = sqrt( (a[0] - b[0])*(a[0] - b[0]) +
                                (a[1] - b[1])*(a[1] - b[1]) +
                                (a[2] - b[2])*(a[2] - b[2]) );


function rf( a,b,v,d,d2 ) = (v[d2] == 0) ? 0 : atan((v[d]/v[d2]));

module bar( a, b, size ) {
    ///vector = [ a.x-b.x, a.y - b.y, a.z - b.z ] ;
    vector = [ b.x-a.x, b.y - a.y, b.z - a.z ] ;
    length = norm(vector);
    cube_bounds =  [size,size, length ] ;
    
    ang_b = acos(vector.z/length); // inclination angle
    ang_c = atan2(vector.y,vector.x);     // azimuthal angle

        //rotate([0, b, c]) 
    
    rv = [
                    0, // rf( a,b,vector,1,0 ) ,
                    ang_b, //rf( a,b,vector,2 ,0) ,
                    ang_c, // brf( a,b,vector,0 ,1) , 
        ] ;
    //echo( "bar( ", a, b, size , " ) v= ", vector, ", cb=", cube_bounds, ", rv=", rv ) ;

   
    translate( a ) {
        //sphere( r=size );
        rotate( rv )
            translate( [-size/2, -size/2, 0] )
                cube( cube_bounds );
    }
}
function vec_double( a, b ) = [
                        a.x + 2* (b.x-a.x),
                        a.y + 2* (b.y-a.y),
                        a.z + 2* (b.z-a.z) ];

module depth_tri_inner( a, b, c, size , splits, frame = true ) {
    if( frame ) {
        bar(a,b,size);
        bar(b,c,size);
        bar(c,a,size);
    }
        
    vector = [ b.x-a.x, b.y - a.y, b.z - a.z ] ;
    if( splits> 0 ) {
        center = [ 
                                        (a.x+b.x+c.x)/3,
                                        (a.y+b.y+c.y)/3,
                                        (a.z+b.z+c.z)/3,
                ];
        sm1 = splits-1;
        s2 = size * 0.85;
        if( 0/*splits %2 == 1 */) {
            depth_tri_inner( a, b,  vec_double(b,center), s2, sm1 );
            depth_tri_inner( b,  c, vec_double(b,center), s2, sm1 );
        } 
        else {
            bar( a, center, s2 );
            bar( b, center, s2 );
            bar( c, center, s2 );
            depth_tri_inner( a, b, center, s2, sm1, frame = false );
            depth_tri_inner(  b, c,  center, s2, sm1, frame = false );
            depth_tri_inner(   c, a,   center, s2, sm1, frame = false );
        }
    }     
}

module depth_tri_grid( a, b, c,  delta ) {
    size = max( [for( i = [0:3] ) abs(delta[i])] );
       
    echo( "depth_tri( ", a, b, c, delta, " ) size= ", size ) ;
    
    depth_tri_inner( a, b, c, size, 4 );
}

module depth_quad( a, b, c, d, delta ) {
    center = [
                    (a.x+b.x+c.x+d.x) / 4,
                    (a.y+b.y+c.y+d.y) / 4,
                    (a.z+b.z+c.z+d.z) / 4,
            ];
    
    union() {
        for ( edge = [
                        [a, b ],
                        [b,c],
                        [c,d],
                        [d,a],
                    ] ) 
        {
             e1 = edge[0];
            e2 = edge[1];
            depth_tri( e1, e2, center, delta );
        }
    }
}


module depth_rect( a, b, delta ) {
    depth_tri( 
                        [ a.x, a.y. a.z ],
                        [ b.x, a.y. a.z ],
                        [ b.x, b.y. b.z ],
                        delta 
                );
}

module  mesh_wall( rim_inner,  d, qheight, c_wall_width )  {
    z_start = 0 ;
    // z_end = d+qheight-c_wall_width ; // just enough for each level - but allows dice to fly out windows
    z_end = wall_height;
    z_span = z_start - z_end ;
    z_interval = 12.3;
    z_steps = floor( abs(z_span / z_interval)+1);
    mw_width = c_wall_width * 1.4;
    
    //echo( "mesh_wall : ", rim_inner,  d, qheight, " cww:", c_wall_width , z_start, z_end,  z_span, z_steps );
    for( z_step = [ 0 : z_steps+1 ]  ) {
              current_z = z_step * -z_interval;  
            
            //echo( "  step:", z_step, " ,  current_z:", current_z );
            depth_quad (  
                [ rim_inner, rim_inner,  current_z+mw_width ],
                [ rim_inner, rim_inner,  current_z ],

                [  rim_inner, -rim_inner,  current_z ],
                [ rim_inner, -rim_inner, current_z+mw_width],
                    [- c_wall_width, 0, 0]
                );      
    }      

    // h_steps = floor( abs((rim_inner*2) / h_interval)+1);
    h_steps = 12;
    h_interval = (rim_inner*2) / h_steps ;
    
    h_z = -z_interval * (z_steps+1);
    for( h_step = [ -1 : h_steps+1 ]  ) {
              current_h = -rim_inner 
                                            +c_wall_width 
                                            + h_step * h_interval;  
            
            //echo( "  step:", z_step, " ,  current_z:", current_z );
            depth_quad (  
                [ rim_inner, current_h,  h_z ],
                [ rim_inner, current_h,  0],

                [  rim_inner, current_h-mw_width,  0],
                [ rim_inner, current_h-mw_width, h_z],
                    [- c_wall_width, 0, 0]
                );      
    }      

/*
       depth_quad (  
            [ rim_inner, rim_inner,  d-c_wall_width ],
            [ rim_inner, rim_inner,  0 ],
            [ rim_inner, -rim_inner,  0 ],
            [ rim_inner, -rim_inner, d+qheight-c_wall_width ],
                    [ -c_wall_width, 0, 0 ]
                );            
*/
}

module TopFrameQuarter(dstep)  {
    himw = inside_max_width / 2;
    frame_width = 7;
    frame_corner_offset = 3;
    c_wall_width = 1.5;
    
    qheight = (wall_height - corner_support_depth) / 4 ;
    rim_outer = himw;
    rim_outer_corner = post_2x_on_center /2 - 7;
    rim_inner = himw - frame_width;
    rim_inner_corner = himw - (frame_width+frame_corner_offset); 

// difference() 
    { union() {
        if(1) { // top bevel
            tb_outer_edge = rim_outer;
            tb_inner_edge = rim_inner;
            if(0) depth_quad( 
                        [0,tb_outer_edge, 0],
                        [tb_outer_edge,tb_outer_edge, 0],
                        [tb_inner_edge , tb_inner_edge, -corner_support_depth ],
                        [tb_inner_edge,0 , -corner_support_depth],
                        [0, 0, corner_support_depth *10] );
            
                cube_side = sqrt( corner_support_depth*corner_support_depth*2 );
               translate( [tb_inner_edge-corner_support_depth, tb_outer_edge , -corner_support_depth ] ) {
                   rotate( [90,45,0] )
                   cube( [ cube_side,cube_side, tb_outer_edge*2 ] );
               }
        }
        translate( [0, 0,-corner_support_depth] ) {
            linear_extrude( height = corner_support_depth ) {
                
                polygon( [
                            [rim_outer, rim_outer_corner ],
                            [rim_outer, 0],
                            [rim_inner, 0],
                            [rim_inner, rim_inner_corner],
                            [rim_inner_corner, rim_inner],
                            [0,rim_inner],
                            [0,rim_outer],
                            [rim_outer_corner,rim_outer ],
                    ] );
            }
            
            
            d = -qheight * dstep;

            c_wall_offset = [0,0,-c_wall_width];
            cww2 = c_wall_width/2;
            if( dstep == -1 ) {
                if(0) depth_tri( 
                        [ rim_inner, rim_inner, d ],
                                    [ 0, rim_inner, d],
                                    [ 0, 0, d-qheight],
                                    c_wall_offset
                            );
                depth_tri( 
                                    [ rim_inner, rim_inner, d ],
                                    [ rim_inner, 0, d],
                                    [ 0, 0, d-qheight],
                                    c_wall_offset
                            );                
        //} else if(1) {
        }else if(0) { // complex
            
                   depth_tri( 
                        [ rim_inner, rim_inner, d ],
                                    [ 0, rim_inner, d],
                                    [ 0, 0, d-qheight],
                                    c_wall_offset
                            );
                    depth_tri( 
                                    [ rim_inner, rim_inner, d ],
                                    [ rim_inner, 0, d],
                                    [ 0, 0, d-qheight],
                                    c_wall_offset
                            );   
                    depth_quad ( 
                                [  rim_inner, rim_inner, d ],
                                [  rim_inner, 0, d+qheight ],
                                 [  0, 0,  d],
                                 [  0, 0,  d-qheight ],
                                [ -c_wall_width, -c_wall_width, -c_wall_width ]
                            );
                depth_quad ( 
                                [  rim_inner, rim_inner_corner, 0 ],
                                [  rim_inner, 0, 0 ],
                                [  rim_inner, 0,  d +qheight -c_wall_width],
                                [  rim_inner, rim_inner_corner, d -c_wall_width],
                                [ -c_wall_width, 0, 0 ]
                            );                
                depth_quad ( 
                                [  rim_inner_corner, rim_inner, 0 ],
                                [  0, rim_inner, 0 ],
                                [  0, rim_inner, d ],
                                [  rim_inner_corner, rim_inner, d ],
                                [ 0, -c_wall_width, 0 ]
                            );
            } else {
                if(1) { // slope
                    depth_tri( 
                            [ rim_inner, rim_inner, d ],
                                        [ rim_inner, -rim_inner, d+qheight],
                                        [ 0, 0, d-qheight],
                                        c_wall_offset
                                );                
                }
                if(1) { // inner / vertical center join
                    
                    depth_quad( 
                            [ rim_inner+cww2, -rim_inner, d+qheight],
                            [ rim_inner+cww2, -rim_inner, d+qheight-c_wall_width],
                            [ 0, 0, d-qheight-c_wall_width],
                            [ 0,0, d],
                                        [ -c_wall_width, -c_wall_width, 0]
                                );        
                }
               if(1) { // outer side wall
                   if(1) {
                       mesh_wall( rim_inner,  d, qheight, c_wall_width );
                   } else {
                       depth_quad (  
                            //[ rim_inner, rim_inner, d+qheight ],
                            //[ rim_inner, -rim_inner, d+qheight],
                            [ rim_inner, rim_inner,  d-c_wall_width ],
                            [ rim_inner, rim_inner,  0 ],
                            [ rim_inner, -rim_inner,  0 ],
                            [ rim_inner, -rim_inner, d+qheight-c_wall_width ],
                                    [ -c_wall_width, 0, 0 ]
                                );            
                   }
               }           

            }
        }
    }
    

    }
}

module post_tongue_cuts() {
    {    
            for( angle = [ 0, 90, 180, 270 ] ) {
                rotate( [0,0,angle] )
                translate( [post_2x_on_center/2, post_2x_on_center/2,-wall_height-corner_support_depth ] ) {
                    ledge_cutout_width = 4;
                    ledge_cutout_length = 15;
                        rotate( [0,0,135] )
                            translate( [-ledge_cutout_width/2,0,0] )
                            cube( [ledge_cutout_width, ledge_cutout_length, wall_height ] );
                    }
            }
        }
}

module TopFrameQuarters()   {
    union() {
        for( quarter_specs = [ 
                        [0, 0],
                        [90, 1],
                        [180, 2],
                        [270, 3],
                        [0, 4],
                    ] ) {
            angle = quarter_specs[0];
            dstep = quarter_specs[1];
            rotate( [0,0,angle] ) TopFrameQuarter(dstep);
        }
    }
}

module max_box() {
                lower_max_width =  inside_max_width -14;
            union() {
                translate( [ -lower_max_width/2, -lower_max_width/2, -(wall_height)] )
                cube( [ lower_max_width, lower_max_width, wall_height] );
               translate( [ -post_2x_on_center/2, -post_2x_on_center/2, -corner_support_depth] )
                    cube( [ post_2x_on_center, post_2x_on_center, corner_support_depth  ] );
                }
}

module TopFrame()  {
    translate( [0,0,wall_height
                        //-corner_support_depth
    ] )
    difference() 
    {
        intersection()
        {
            TopFrameQuarters();
            max_box();
        }
        post_tongue_cuts();               
    }
}

module TopFrameBorder()   {
    translate( [0,0,wall_height] )  difference() {
        cube( [ post_2x_on_center, post_2x_on_center, 2], center = true );
        cube( [ inside_max_width, inside_max_width, 3], center = true );
    }
}

if( 0 ) {
    //a = [1,1,0];
    //b = [12,20,24];
    //c =  [77,24,14];
    a = [13,1,1];
    b = [1,44,31];
    c =  [44,7,1];
    
   depth =  [0,0,-5] ;
    depth_tri_poly(  a, b, c, depth );
    translate( [0, 60, 0 ] )
        depth_tri( a, b, c, depth  );
    //TopFrameQuarters();
} else {
     // for stl 
    rotate( [180,0,0] )
    TopFrame() ;
   // TopFrameBorder()  ;
}

