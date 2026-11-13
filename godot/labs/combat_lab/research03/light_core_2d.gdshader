shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX18 / LIGHTCORE2D — original mathematical light, no texture/sprite.
// A tapered hot-core sword-qi stroke lives entirely in UV space.
// Created for GL Compatibility. Uniforms owned by LAB events, not engine TIME.
uniform float energy : hint_range(0.0, 1.0) = 1.0;
uniform float phase : hint_range(0.0, 1.0) = 0.0;
uniform float seed : hint_range(0.0, 6.2832) = 0.0;
uniform float width_bias : hint_range(0.5, 1.5) = 1.0;
uniform vec4 sheath_tint : source_color = vec4(0.10, 0.57, 1.0, 1.0);
uniform vec4 edge_tint : source_color = vec4(0.28, 0.96, 1.0, 1.0);

void fragment() {
    vec2 p = UV;
    float x = p.x;
    // A sword-shaped LIGHT intensity field, NOT an opaque polygon.
    float span = smoothstep(0.025, 0.115, x) * (1.0 - smoothstep(0.890, 0.970, x));
    float taper_u = clamp((x - 0.030) / 0.930, 0.0, 1.0);
    float swell = pow(max(0.0, sin(3.14159265 * taper_u)), 0.83);
    float blade_width = (0.011 + 0.057 * swell) *
        (1.0 - 0.83 * smoothstep(0.66, 0.96, x)) * width_bias;
    float wag = 0.0065 * sin(11.2 * x - 5.8 * phase + seed) *
        (1.0 - smoothstep(0.56, 0.92, x));
    float axis = 0.5 + wag;
    float d = abs(p.y - axis);

    // Continuous Gaussian falloff keeps the corona soft at the edges.
    float atmosphere = exp(-pow(d / (blade_width * 3.1 + 0.013), 2.0)) * span;
    float sheath = exp(-pow(d / (blade_width * 1.25 + 0.004), 2.0)) * span;
    float hot = exp(-pow(d / (blade_width * 0.20 + 0.0044), 2.0)) * span;

    // A moving two-lane wake: translucent, behind the leading tip only.
    float wake_window = smoothstep(0.028, 0.105, x) *
        (1.0 - smoothstep(0.48, 0.74, x));
    float wake_depth = 1.0 - smoothstep(0.19, 0.75, x);
    float w1 = 0.5 + 0.060 * sin(8.7 * x + phase * 7.2 + seed);
    float w2 = 0.5 - 0.063 * sin(10.1 * x + phase * 5.4 + seed + 1.5);
    float ribbon1 = exp(-pow((p.y - w1) / 0.028, 2.0));
    float ribbon2 = exp(-pow((p.y - w2) / 0.018, 2.0));
    float wake = (ribbon1 * 0.26 + ribbon2 * 0.14) *
        wake_window * wake_depth;

    // Needle-tip is a small white concentration, not an opaque arrowhead.
    float point = exp(-pow((x - 0.897) / 0.030, 2.0) -
        pow((p.y - axis) / 0.031, 2.0));
    float front_sheen = 0.78 + 0.22 * sin(phase * 12.0 + seed);

    vec3 rgb = sheath_tint.rgb *
        (atmosphere * 0.62 + wake * 0.70) +
        edge_tint.rgb *
        (sheath * 0.77 + wake * 0.40) +
        vec3(0.98, 0.99, 1.0) *
        (hot * 1.17 + point * 1.38 * front_sheen);
    float a = atmosphere * 0.20 + sheath * 0.47 +
        hot * 0.81 + wake * 0.40 + point * 0.78;
    float vertical_safe = smoothstep(0.008, 0.070, p.y) *
        (1.0 - smoothstep(0.930, 0.994, p.y));
    COLOR = vec4(clamp(rgb, 0.0, 1.0),
        clamp(a * energy * vertical_safe, 0.0, 1.0));
}
