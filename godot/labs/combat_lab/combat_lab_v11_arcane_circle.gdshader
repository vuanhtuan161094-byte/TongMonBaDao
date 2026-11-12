shader_type canvas_item;
render_mode blend_add, unshaded;

// V11.2 original Godot visual shader: bounded 360x360 ColorRect.
// This is NOT a texture, animation sheet, target marker authority or hit.
// No TIME dependency; Combat Lab HOLD freezes the entire ritual.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform int ritual_mode = 0; // 0: caster charge, 1: distant ground AOE

void fragment() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 p = UV * 2.0 - 1.0;
    // Isometric-looking ground circle with an atmospheric vertical haze.
    vec2 ground = vec2(p.x, p.y * 1.38);
    float r = length(ground);
    float a = atan(ground.y, ground.x);
    float halo = 0.0;
    float arc = 0.0;
    float glints = 0.0;
    float gold = 0.0;
    if (ritual_mode == 0) {
        float charge = smoothstep(0.01, 0.23, t) *
            (1.0 - smoothstep(0.36, 0.50, t));
        float rim = exp(-pow((r - 0.55) * 14.0, 2.0));
        float inner = exp(-r * r * 8.0);
        float sigils = pow(max(0.0, cos(a * 8.0 + t * 3.0)), 12.0);
        halo = charge * (rim * 0.27 + inner * 0.075);
        arc = charge * rim * 0.20;
        gold = charge * rim * sigils * 0.25;
        glints = charge * (1.0 - smoothstep(0.0, 0.05,
            abs(p.x))) * exp(-abs(p.y) * 6.0) * 0.06;
    } else {
        // Strong AOE telegraph, then outward shock front and dissipating
        // dust-like mist. These are shader-only presentation features.
        float tele = smoothstep(0.22, 0.45, t) *
            (1.0 - smoothstep(0.83, 0.98, t));
        float hit = smoothstep(0.72, 0.78, t) *
            (1.0 - smoothstep(0.87, 0.98, t));
        float rim = exp(-pow((r - 0.69) * 17.0, 2.0));
        float inner_rim = exp(-pow((r - 0.49) * 20.0, 2.0));
        float sigils = pow(max(0.0, cos(a * 12.0 - t * 2.4)), 18.0);
        float wave_r = 0.18 + 0.76 * clamp((t - 0.74) / 0.22, 0.0, 1.0);
        float shock = exp(-pow((r - wave_r) * 10.0, 2.0));
        float mist = exp(-r * r * 3.1) *
            (0.5 + 0.5 * sin(a * 5.0 + r * 13.0 - t * 18.0));
        halo = tele * (rim * 0.18 + inner_rim * 0.08) +
            hit * (shock * 0.30 + mist * 0.08);
        arc = tele * rim * 0.22 + hit * shock * 0.25;
        gold = tele * (rim * sigils * 0.34 + inner_rim * 0.05);
        glints = hit * exp(-r * r * 5.0) * 0.075;
    }
    vec3 cyan = vec3(0.22, 0.68, 0.98);
    vec3 pale = vec3(0.80, 0.94, 1.00);
    vec3 amber = vec3(1.00, 0.63, 0.26);
    vec3 rgb = cyan * halo + pale * (arc + glints) + amber * gold;
    float alpha = clamp(halo + arc + glints + gold, 0.0, 0.65);
    COLOR = vec4(rgb, alpha);
}
