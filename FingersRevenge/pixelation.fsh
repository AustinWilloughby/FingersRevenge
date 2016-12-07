

float time = u_time;
vec2 resolution = u_sprite_size;
vec2 mouse = vec2(.5,.5);


void main( void )
{
    gl_FragColor = vec4( 0.0, -mod( gl_FragCoord.y + time, cos( gl_FragCoord.x ) + 0.004 ), 0.0, 0.3 );
