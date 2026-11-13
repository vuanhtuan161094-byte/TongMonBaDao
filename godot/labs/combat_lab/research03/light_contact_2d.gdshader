shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX18.2 original light-only incisional impact. No bitmap or fake gameplay.
// One pre-authorized LAB contact at the projectile's actual pre-hit tip.
uniform float age : hint_range(0.0, 1.0) = 1.0;
uniform float power : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 p = (UV - vec2(0.5)) * 2.0;
    float t = clamp(age, 0.0, 1.0);
    // The cut travels rapidly along its own direction. It cannot turn
    // into an always-on glowing painted stripe or a solid explosion disk.
    float reach = mix(-0.78, 0.92, smoothstep(0.00, 0.22, t));
    float visible = smoothstep(-0.94, -0.77, p.x) *
        (1.0 - smoothstep(reach - 0.13, reach + 0.07, p.x));
    float bend = 0.06 * sin(p.x * 4.5 + 3.4 * t);
    float signed_cut = p.y + 0.51 * p.x - bend;
    float bright = exp(-pow(signed_cut / 0.017, 2.0)) * visible;
    float rim = exp(-pow(signed_cut / 0.044, 2.0)) * visible;
    float field = exp(-pow(signed_cut / 0.145, 2.0)) * visible;

    // A delayed, thinner counter-shear: art rhythm instead of a radial
    // ring or huge opaque slash-arc polygon.
    float delayed = smoothstep(0.17, 0.34, t) *
        (1.0 - smoothstep(0.57, 0.90, t));
    float counter_curve = p.y - (0.34 * p.x + 0.22
        + 0.075 * sin(p.x * 3.8 - t * 4.0));
    float counter_window = smoothstep(-0.54, -0.27, p.x) *
        (1.0 - smoothstep(0.44, 0.80, p.x));
    float echo = exp(-pow(counter_curve / 0.026, 2.0)) *
        counter_window * delayed;
    float echo_halo = exp(-pow(counter_curve / 0.103, 2.0)) *
        counter_window * delayed;

    // Small directed white nexus; this is a tip contact, not a bomb.
    float nexus = exp(-pow((p.x - 0.08) / 0.17, 2.0) -
        pow((p.y + 0.04) / 0.12, 2.0));
    float hot_decay = 1.0 - smoothstep(0.17, 0.88, t);
    float haze_decay = 1.0 - smoothstep(0.37, 0.97, t);
    float glint = exp(-pow((p.x + 0.2 - t * 0.25) / 0.22, 2.0) -
        pow((p.y - 0.28 + t * 0.3) / 0.09, 2.0));
    vec3 rgb = vec3(0.055, 0.31, 0.89) *
        (field * 0.48 * haze_decay + echo_halo * 0.20) +
        vec3(0.18, 0.75, 1.0) *
        (rim * 0.84 * haze_decay + echo_halo * 0.46 +
        glint * 0.18 * hot_decay) +
        vec3(0.94, 0.99, 1.0) *
        (bright * 1.28 * hot_decay + echo * 0.69 +
        nexus * 0.65 * hot_decay);
    float alpha = power * (
        field * 0.17 * haze_decay +
        rim * 0.50 * haze_decay +
        bright * 0.96 * hot_decay +
        echo * 0.63 + echo_halo * 0.18 +
        nexus * 0.61 * hot_decay);
    COLOR = vec4(clamp(rgb, 0.0, 1.0), clamp(alpha, 0.0, 1.0));
}
