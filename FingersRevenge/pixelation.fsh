

float time = u_time;
vec2 resolution = u_sprite_size;

void main( void )
{
    gl_FragColor = vec4( 0.0, -mod( gl_FragCoord.y + time, cos( gl_FragCoord.x ) + 0.001 ) - .4, 0.0, 1.0 );
}
