wall_height = 76;               // height of support post
post_2x_on_center = 102;       // horizontal distance from center to center of posts along 2X walls
corner_support_depth = 3.1;  // from top of roof support ledge to top of post

max_wall_width = 6.5;
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

module TopFrameQuarter(dstep)  {
    himw = inside_max_width / 2;
    frame_width = 7;
    frame_corner_offset = 3;
    c_wall_width = 2;
    
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
                   depth_quad (  
                            //[ rim_inner, rim_inner, d+qheight ],
                            //[ rim_inner, -rim_inner, d+qheight],
                            [ rim_inner, rim_inner,  d ],
                            [ rim_inner, rim_inner,  0 ],
                            [ rim_inner, -rim_inner,  0 ],
                            [ rim_inner, -rim_inner, d+qheight],
                                    [ -c_wall_width, 0, 0 ]
                                );            
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
                translate( [ -lower_max_width/2, -lower_max_width/2, -(wall_height-corner_support_depth)] )
                cube( [ lower_max_width, lower_max_width, wall_height-corner_support_depth  ] );
               translate( [ -post_2x_on_center/2, -post_2x_on_center/2, -corner_support_depth] )
                    cube( [ post_2x_on_center, post_2x_on_center, corner_support_depth  ] );
                }
}

module TopFrame()  {
    translate( [0,0,wall_height-corner_support_depth] )
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
    TopFrameQuarters();
} else {
     // for stl 
    rotate( [180,0,0] ) TopFrame() ;
}

