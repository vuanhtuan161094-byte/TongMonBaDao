shader_type canvas_item;
render_mode unshaded;
// VIS-02 original dual-lip jade-crystal rim: translucent center preserves source art.
uniform vec4 quality_color : source_color = vec4(0.85, 0.75, 0.56, 1.0);
uniform float divine = 0.0;
uniform float motion = 1.0;
void fragment() {
    vec2 p = UV;
    float edge = min(min(p.x, 1.0 - p.x), min(p.y, 1.0 - p.y));
    float lip = 1.0 - smoothstep(0.002, 0.009, edge);
    float halo = 1.0 - smoothstep(0.005, 0.032, edge);
    float near = edge;
    float progress = 0.0;
    // Clockwise perimeter traversal, not a diagonal streak.
    if (near == p.y) {
        progress = p.x * 0.25;
    } else if (near == 1.0 - p.x) {
        progress = 0.25 + p.y * 0.25;
    } else if (near == 1.0 - p.y) {
        progress = 0.5 + (1.0 - p.x) * 0.25;
    } else {
        progress = 0.75 + (1.0 - p.y) * 0.25;
    }
    float lap = fract(progress - TIME * motion * 0.045);
    float distance = min(abs(lap - 0.27), 1.0 - abs(lap - 0.27));
    float sweep = exp(-pow(distance / 0.038, 2.0));
    float breathe = 0.92 + 0.08 * sin(TIME * motion * 0.48);
    float wave = 0.5 + 0.5 * sin(progress * 25.13 - TIME * motion * 0.28);
    vec3 jade = vec3(0.52,0.92,0.84);
    vec3 violet = vec3(0.82,0.69,0.99);
    vec3 pearl = vec3(0.78,0.92,1.0);
    vec3 amber = vec3(1.0,0.86,0.65);
    vec3 iridescent = mix(jade,violet,smoothstep(0.12,0.88,wave));
    iridescent = mix(iridescent,pearl,0.26);
    iridescent = mix(iridescent,amber,0.24 * (0.5+0.5*sin(progress*13.0+1.3)));
    vec3 pigment = mix(quality_color.rgb,iridescent,divine*0.93);
    float opacity = (lip * (0.28 + divine*0.40) + halo * (0.09 + divine * (0.26 + sweep*0.25)))*breathe;
    COLOR = vec4(pigment + vec3(divine*sweep*0.05),clamp(opacity,0.0,0.86));
}
