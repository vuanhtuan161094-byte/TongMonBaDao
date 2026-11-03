shader_type canvas_item;
render_mode unshaded;

uniform vec4 ink_color : source_color = vec4(0.018, 0.013, 0.045, 1.0);
uniform vec4 edge_color : source_color = vec4(0.66, 0.24, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.95;
uniform float pulse : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    vec4 src = texture(TEXTURE, UV);
    vec2 d = TEXTURE_PIXEL_SIZE * 1.4;
    float nearby = min(min(texture(TEXTURE, UV + vec2(d.x, 0.0)).a,
                           texture(TEXTURE, UV - vec2(d.x, 0.0)).a),
                       min(texture(TEXTURE, UV + vec2(0.0, d.y)).a,
                           texture(TEXTURE, UV - vec2(0.0, d.y)).a));
    float rim = clamp(src.a - nearby, 0.0, 1.0);
    float glow = (0.66 + pulse * 0.34) * rim * rim_strength;
    vec3 rgb = mix(ink_color.rgb, edge_color.rgb, glow);
    COLOR = vec4(rgb, src.a * ink_color.a);
}
