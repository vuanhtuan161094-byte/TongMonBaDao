shader_type canvas_item;
render_mode blend_add, unshaded;

// One small, sharp contact bloom. Never a whole-screen or monster-wide disk.
// Only the explicitly approved mock victim may receive this in a LAB demo.
uniform float age : hint_range(0.0, 1.0) = 1.0;
uniform float power : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 p = (UV - vec2(0.5)) * 2.0;
    float t = clamp(age, 0.0, 1.0);
    float a = power * (1.0 - smoothstep(0.06, 0.93, t));
    // Directional diagonal cut: thin white incision with tapered ends.
    float skew = p.y - (-0.47 * p.x + 0.09 * sin(p.x * 4.3 + t));
    float segment = smoothstep(-0.91, -0.65, p.x) *
        (1.0 - smoothstep(0.63, 0.94, p.x));
    float blade = exp(-pow(skew / 0.027, 2.0)) * segment;
    float glow = exp(-pow(skew / 0.155, 2.0)) * segment;
    float hotspot = exp(-pow(p.x / 0.16, 2.0) -
        pow((p.y - 0.02) / 0.18, 2.0));
    float spark1 = exp(-pow((p.y + 1.8 * p.x) / 0.045, 2.0)) *
        exp(-pow((p.x + 0.14 + t * 0.10) / 0.42, 2.0));
    float spark2 = exp(-pow((p.y - 1.5 * p.x) / 0.051, 2.0)) *
        exp(-pow((p.x - 0.11 - t * 0.08) / 0.30, 2.0));
    float spark = (spark1 + spark2) * 0.24 * (1.0 - t);
    vec3 c = vec3(0.12, 0.39, 0.95) * (glow * 0.42) +
        vec3(0.22, 0.87, 1.0) * (glow * 0.52 + spark) +
        vec3(0.97, 0.99, 1.0) * (blade * 1.24 + hotspot * 0.84);
    COLOR = vec4(clamp(c, 0.0, 1.0),
        clamp((blade * 0.86 + glow * 0.45 + hotspot * 0.77 + spark * 0.56)
            * a, 0.0, 1.0));
}
