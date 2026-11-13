shader_type canvas_item;
render_mode blend_add, unshaded;

// Sprite-derived material, not geometric snake reconstruction.
// Motion is externally clocked by the standalone lab so pause is deterministic.
uniform float phase = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.84;

void fragment() {
    vec2 uv = UV;
    float envelope = smoothstep(0.025, 0.19, uv.x) *
                     (1.0 - smoothstep(0.86, 0.99, uv.x));
    vec2 swim = vec2(
        0.013 * sin(uv.y * 25.0 + phase * 6.5) * envelope,
        0.010 * sin(uv.x * 21.0 - phase * 5.1)
    );
    vec2 warped = clamp(uv + swim, vec2(0.001), vec2(0.999));
    vec4 painted = texture(TEXTURE, warped);
    COLOR = vec4(painted.rgb, painted.a * opacity);
}
