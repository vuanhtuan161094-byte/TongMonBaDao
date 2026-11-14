shader_type canvas_item;
render_mode unshaded;
uniform vec4 quality_color : source_color = vec4(0.85, 0.75, 0.56, 1.0);
uniform float divine = 0.0;
uniform float motion = 1.0;
void fragment() {
    vec2 p = UV;
    float d = min(min(p.x, 1.0 - p.x), min(p.y, 1.0 - p.y));
    float outer = 1.0 - smoothstep(0.004, 0.025, d);
    float fine = 1.0 - smoothstep(0.004, 0.011, d);
    float at = fract((p.x + p.y * 0.41) * 0.65 - TIME * motion * 0.075);
    float sweep = exp(-pow((at - 0.51) / 0.06, 2.0));
    float breathe = 0.86 + 0.14 * sin(TIME * motion * 0.65);
    vec3 celestial = mix(vec3(0.55, 0.90, 0.82), vec3(0.86, 0.71, 1.0), 0.5 + 0.5 * sin((p.x + p.y) * 5.0 - TIME * motion * 0.21));
    celestial = mix(celestial, vec3(1.0, 0.87, 0.61), 0.30);
    vec3 hue = mix(quality_color.rgb, celestial, divine * 0.74);
    float alpha = outer * (0.30 + fine * 0.40 + divine * sweep * 0.20) * breathe;
    // A 2 px rim, almost transparent elsewhere. Never overlay the portrait center.
    COLOR = vec4(hue + vec3(divine * sweep * 0.06), clamp(alpha, 0.0, 0.85));
}
