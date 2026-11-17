shader_type canvas_item;
render_mode blend_mix;

// A moving 2D refraction field ON TOP OF per-frame authored energy currents.
// Not physical 3D ray tracing; alpha remains sparse, no opaque glass icon.
uniform sampler2D back_buffer : hint_screen_texture, filter_linear;
uniform float flow_time = 0.0;
uniform float refraction_amount : hint_range(0.0, 0.006) = 0.0021;
uniform float brightness : hint_range(0.5, 2.0) = 1.34;

void fragment() {
    vec4 ink = texture(TEXTURE, UV);
    float a = clamp(ink.a * 1.2, 0.0, 0.89);
    float n1 = sin(UV.y * 23.0 + flow_time * 15.0 + 2.4 * sin(UV.x * 14.0 - flow_time * 7.1));
    float n2 = cos(UV.x * 32.0 - flow_time * 12.0 + 1.8 * sin(UV.y * 12.0 + flow_time * 8.0));
    vec2 normal = vec2(n1, n2);
    vec3 shifted = texture(back_buffer, SCREEN_UV + normal * refraction_amount * ink.a).rgb;
    float caustic = pow(max(0.0, sin(UV.y * 41.0 - flow_time * 24.0 + sin(UV.x * 31.0 + flow_time * 11.0))), 10.0);
    vec3 jade = ink.rgb * vec3(0.91, 1.18, 1.11);
    vec3 highlight = vec3(0.66, 1.0, 0.85) * caustic * 0.33;
    vec3 transmitted = mix(shifted, jade, 0.68);
    COLOR = vec4(clamp(transmitted * brightness + highlight, 0.0, 1.0), a);
}
