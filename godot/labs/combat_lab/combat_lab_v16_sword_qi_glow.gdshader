shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX16 LAB-ONLY: soft analytic sword-qi energy, no sword model or bitmap.
// Local x: rear stream [-110,-38], core [-42,52], luminous tip x=52.
// The quad center sits 52px BEHIND the gameplay-safe pre-contact tip.
// All time values come from the Python-independent Godot preview timeline.
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float phase : hint_range(0.0, 1.0) = 0.0;
uniform float size_factor : hint_range(0.1, 2.0) = 0.8;
uniform float seed = 0.0;

void fragment() {
    vec2 q = (UV - vec2(0.5)) * vec2(320.0, 160.0);
    vec2 p = q / clamp(size_factor, 0.23, 1.8);
    float x = p.x;
    float y = p.y;
    float u = clamp((x + 42.0) / 94.0, 0.0, 1.0);
    float body_window = smoothstep(-44.0, -26.0, x) *
                        (1.0 - smoothstep(43.0, 53.0, x));
    // Irregular light contour; no metallic faceting or sharp geometry edges.
    float bent_axis = sin(x * 0.042 - phase * 3.9 + seed) * 1.65 *
                      (1.0 - u * 0.66);
    float half_width = (1.2 + 7.0 * pow(max(0.0, sin(3.14159265 * u)), 0.85))
                       * (1.0 - 0.52 * u);
    float transverse = abs(y - bent_axis);
    float haze = exp(-pow(transverse / (half_width * 3.7 + 2.8), 2.0))
                 * body_window;
    float sheath = exp(-pow(transverse / (half_width * 1.32 + 0.9), 2.0))
                   * body_window;
    float spine = exp(-pow(transverse / max(0.60, half_width * 0.24), 2.0))
                  * body_window;
    float point = exp(-dot((p - vec2(49.0, 0.0)) / vec2(6.0, 4.2),
                           (p - vec2(49.0, 0.0)) / vec2(6.0, 4.2)));
    // Detached, dissolving wake, curved in local blade coordinates.
    float tail = smoothstep(-115.0, -78.0, x) *
                 (1.0 - smoothstep(-33.0, -12.0, x));
    float tail_s = clamp((-x - 12.0) / 103.0, 0.0, 1.0);
    float ribbon_a = 9.0 * sin(phase * 6.0 + tail_s * 3.0 + seed) * tail_s;
    float ribbon_b = -7.0 * sin(phase * 5.0 + tail_s * 4.8 + seed) * tail_s;
    float wake_a = exp(-pow((y - ribbon_a) / (3.2 + 7.0 * tail_s), 2.0));
    float wake_b = exp(-pow((y - ribbon_b) / (1.8 + 3.0 * tail_s), 2.0));
    float wake = (wake_a * 0.31 + wake_b * 0.25) * tail *
                 (1.0 - smoothstep(0.60, 0.96, phase));
    // Three low-cost, phase-linked glints instead of free-running particles.
    float sparks = 0.0;
    for (int i = 0; i < 3; i++) {
        float j = float(i);
        float sx = -78.0 + 17.0 * j + 19.0 * phase;
        float sy = (j - 1.0) * 10.0 + sin(phase * 7.0 + j + seed) * 6.0;
        vec2 delta = (p - vec2(sx, sy)) / vec2(2.6, 1.7);
        sparks += exp(-dot(delta, delta) * 1.8) * (1.0 - phase);
    }
    float transfer = smoothstep(0.72, 0.94, phase);
    float fade_at_contact = 1.0 - smoothstep(0.78, 1.0, phase);
    vec3 blue = vec3(0.20, 0.50, 1.00);
    vec3 cyan = vec3(0.20, 0.87, 1.00);
    vec3 white = vec3(0.90, 0.98, 1.00);
    vec3 rgb = blue * (haze * 0.18 + wake * 0.34) +
               cyan * (sheath * 0.34 + wake * 0.55 + sparks * 0.42) +
               white * (spine * 0.61 + point * (0.44 + transfer * 0.36));
    float energy = haze * 0.20 + sheath * 0.29 + spine * 0.55 +
                   point * 0.48 + wake * 0.45 + sparks * 0.36;
    float edge = smoothstep(0.01, 0.08, UV.x) *
                 (1.0 - smoothstep(0.93, 0.995, UV.x)) *
                 smoothstep(0.03, 0.13, UV.y) *
                 (1.0 - smoothstep(0.87, 0.98, UV.y));
    COLOR = vec4(rgb, clamp(energy * strength * fade_at_contact * edge,
                            0.0, 1.0));
}
