shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX18.2 original atmospheric underglow, mathematical light only.
// Faint irregular elliptical field with angular gaps and breathing phase.
// Does NOT signify a damage radius, hitbox or active status.
uniform float phase : hint_range(0.0, 1.0) = 0.0;
uniform float energy : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 p = (UV - vec2(0.5)) * 2.0;
    vec2 q = vec2(p.x * 0.99, p.y * 1.38);
    float r = length(q);
    float angle = atan(q.y, q.x);
    float flutter = 0.036 * sin(angle * 5.0 - 5.3 * phase) +
        0.026 * sin(angle * 9.0 + 7.1 * phase);
    float rho = 0.68 + flutter;
    float beam = exp(-pow((r - rho) / 0.13, 2.0));
    float texture = 0.39 + 0.36 * sin(angle * 6.0 + phase * 8.6) +
        0.19 * sin(angle * 11.0 - phase * 11.0);
    float gated = smoothstep(0.00, 0.26, texture);
    float inner = exp(-pow(r / 0.82, 2.0)) * 0.055;
    float curl = exp(-pow((r - rho - 0.16) / 0.11, 2.0)) *
        (0.40 + 0.60 * sin(angle * 4.0 + phase * 5.0) *
        sin(angle * 4.0 + phase * 5.0));
    float intensity = energy * (beam * gated * 0.30 +
        curl * gated * 0.068 + inner * 0.65);
    vec3 color = mix(vec3(0.07, 0.26, 0.94),
        vec3(0.16, 0.78, 1.0),
        clamp(0.47 + 0.3 * sin(angle * 6.0 + phase * 5.0),0.0,1.0));
    COLOR = vec4(color, clamp(intensity,0.0,0.28));
}
