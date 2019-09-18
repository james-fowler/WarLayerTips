

function mm2inches(mm) = mm/25.4;
function inches2mm(inches) = inches*25.4;

function circle_midpoint_by_three_points(A, B, C) =
let (
  yD_b = C.y - B.y,  xD_b = C.x - B.x,  yD_a = B.y - A.y,
  xD_a = B.x - A.x,  aS = yD_a / xD_a,  bS = yD_b / xD_b,
  cex = (aS * bS * (A.y - C.y) + 
  bS * (A.x + B.x) -    aS * (B.x + C.x)) / (2 * (bS - aS)),
  cey = -1 * (cex - (A.x + B.x) / 2) / aS + (A.y + B.y) / 2
)
[cex, cey];

function distance(a, b) = sqrt( (a[0] - b[0])*(a[0] - b[0]) +
                                (a[1] - b[1])*(a[1] - b[1]) +
                                (a[2] - b[2])*(a[2] - b[2]) );

function distance2d(a, b) = sqrt( (a[0] - b[0])*(a[0] - b[0]) +
                                (a[1] - b[1])*(a[1] - b[1])  );
                                
function radius_by_three_points(A, B, C) =
    let (
        center = circle_midpoint_by_three_points( A, B, C ),
        radius = distance2d( A, center )
    ) radius;


function tval( tag, data ) = data[ search([tag],data,num_returns_per_match=1)[0]][1];
function tcontains( tag, data ) =  len( search([tag],data,num_returns_per_match=0) [0] );

function tmerge( la, lb ) = concat( [ for( v = la ) if( ! tcontains( v[0], lb ) ) v ],  lb );
    
function tadd( settings, tag, val ) = tmerge( settings, [ [tag,val] ]  );        

function tdval( tag,  default_val, data ) = ( tval(tag,data)  == undef ) ? default_val : tval(tag,data) ;


function  default_settings( lb ) = tmerge( [
        
        ["led_length", 4.91 ],          // outer dimension of LED along strip

        ["led_width",  4.91 ],          // outer dimension of LED across strip


        ["led_spacing",  49.5 / 7  ],  // 55 / 8; // distance from START of an led to START of next led (not the gap between)

        ["led_overhang",  1 ],
        ["shroud_height",   2 ],

        ["led_inner_width",  4.0 ], // width of the inner circle
        
    ], lb );