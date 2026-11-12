shader_type canvas_item;
render_mode blend_add, unshaded;

// Pure GPU light compositing. Geometry is created at runtime by Godot,
// not supplied by prepainted VFX texture sheets.
uniform float light_gain : hint_range(0.5, 2.0) = 1.12;

void fragment() {
    // Motion is owned by cue-timed GDScript geometry, not a sin() evaluated
    // for every pixel. This is cheaper and respects Combat Lab HOLD.
    vec4 source = COLOR;
    COLOR = vec4(min(source.rgb * light_gain, vec3(1.0)), source.a);
}
