//http://glslsandbox.com/e#36196.0

float time = u_time;
vec2 resolution = u_sprite_size;

void main( void )
{
    float t = time;
    float x = gl_FragCoord.x / resolution.x;
    float y = gl_FragCoord.y / resolution.y * 3.3;
    float px = x * 10.0;
    float py = y * 5.0;
    
    float v1 = smoothstep(0.45, 0.5, fract(px));
    float v2 = 1.0 - smoothstep(0.5, 0.55, fract(px));
    float vx = (v1 + v2) - 1.0;
    
    v1 = smoothstep(0.45, 0.5, fract(py));
    v2 = 1.0 - smoothstep(0.5, 0.55, fract(py));
    float vy = (v1 + v2) - 1.0;
    
    v1 = smoothstep(0.0, 0.2, fract( t - ( x / -0.3 ) - ( y / -0.3 ) ));
    v2 = 1.0 - smoothstep(0.0, 0.9, fract( t - ( x / -0.3 ) - ( y / -0.3 ) ));
    float gleam = ( v1 + v2 ) - 1.0;
    
    vec4 color = mix(vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 0.25, 0.0, 1.0), vx + vy);
    vec4 color2 = mix(vec4(0.0, 0.0, 0.0, 1.0), color, gleam );
    
    float l = step(mod(t, 2.1), 1220.6);
    gl_FragColor = color + color2 * l;
}
