shader_type canvas_item;
render_mode unshaded;
// Original original shader authored for TMB. A luminous ink treatment only.
void fragment() {
    vec4 glyph = COLOR;
    float x = FRAGCOORD.x * 0.009 - TIME * 0.065;
    float wave = 0.5 + 0.5 * sin(x * 6.283185);
    vec3 jade = vec3(0.66, 0.94, 0.86);
    vec3 violet = vec3(0.85, 0.76, 0.99);
    vec3 gold = vec3(1.0, 0.89, 0.66);
    vec3 icy = vec3(0.77, 0.92, 1.0);
    vec3 tint = mix(jade, violet, smoothstep(0.06, 0.49, wave));
    tint = mix(tint, gold, smoothstep(0.45, 0.90, wave));
    tint = mix(tint, icy, 0.18 + 0.12 * sin(x * 2.7));
    // Keep every glyph opaque and readable: no alpha pulse, no screen blur.
    COLOR = vec4(mix(glyph.rgb, tint, 0.82), glyph.a);
}
