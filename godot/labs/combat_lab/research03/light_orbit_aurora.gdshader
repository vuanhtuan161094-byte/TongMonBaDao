shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX18.2 R1 subtle, smooth orbital atmosphere.
// No polar-sector cutoff / hard polygon / opaque ring or copied texture.
uniform float phase : hint_range(0.0, 1.0) = 0.0;
uniform float energy : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 p = (UV - vec2(0.5)) * 2.0;
    vec2 elliptical = vec2(p.x * 0.99, p.y * 1.38);
    float r = length(elliptical);
    float angle = atan(elliptical.y, elliptical.x);
    float drift = 0.031 * sin(angle * 4.0 - phase * 5.8) +
        0.021 * sin(angle * 8.0 + phase * 6.8);
    float radius = 0.67 + drift;

    // Gaussian rim is smooth over BOTH radius and angle; no hard gating.
    float halo = exp(-pow((r - radius) / 0.185, 2.0));
    float breathing = clamp(
        0.58 + 0.22 * sin(angle * 3.0 + phase * 8.0)
        + 0.16 * sin(angle * 7.0 - phase * 9.3), 0.17, 0.96);
    float thin_wave = exp(-pow((r - radius - 0.11) / 0.08, 2.0));
    float wave_mix = 0.45 + 0.36 * sin(angle * 5.0 - phase * 8.9);
    float shallow_center = exp(-pow(r / 0.78, 2.0));
    float strength = energy * (
        halo * breathing * 0.128
        + thin_wave * wave_mix * 0.020
        + shallow_center * 0.011);
    float cyan = 0.46 + 0.24 * sin(angle * 4.0 + phase * 6.3);
    vec3 tint = mix(vec3(0.085, 0.25, 0.79),
        vec3(0.17, 0.68, 1.0), clamp(cyan, 0.0, 1.0));
    COLOR = vec4(tint, clamp(strength, 0.0, 0.17));
}
