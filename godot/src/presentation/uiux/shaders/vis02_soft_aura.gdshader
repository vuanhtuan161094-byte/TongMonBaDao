shader_type canvas_item;
render_mode unshaded;
uniform float motion = 1.0;
// Layer is BEHIND original Source A portrait, not applied to its pixels.
void fragment() {
    vec2 p = (UV - vec2(0.50, 0.48)) * vec2(1.08, 0.94);
    float r = length(p);
    float shell = smoothstep(0.02,0.26,r) * (1.0 - smoothstep(0.36,0.58,r));
    float sweep = 0.5 + 0.5 * sin((UV.x-UV.y)*4.5 - TIME*motion*0.26);
    vec3 jade = vec3(0.32,0.80,0.72);
    vec3 amethyst = vec3(0.71,0.47,0.93);
    vec3 hue = mix(jade,amethyst,sweep);
    float breathe = 0.88 + 0.12 * sin(TIME*motion*0.53);
    COLOR = vec4(hue, shell * breathe * 0.13);
}
