shader_type canvas_item;
render_mode blend_add, unshaded;

// Pure GPU light compositing. Geometry is created at runtime by Godot,
// not supplied by prepainted VFX texture sheets.
uniform float light_gain : hint_range(0.5, 2.0) = 1.12;

void fragment() {
    vec4 source = COLOR;
    float shimmer = 0.94 + 0.06 * sin(TIME * 20.0 + UV.x * 19.0 + UV.y * 13.0);
    COLOR = vec4(min(source.rgb * light_gain * shimmer, vec3(1.0)), source.a);
}
