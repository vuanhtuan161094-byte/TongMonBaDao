shader_type canvas_item;
render_mode unshaded, blend_add;

// Compatibility-safe soft feather across the width of a textured Line2D.
// This is a spatial Gaussian, not a stack of overlapping hard rectangles.
// UV.y is the cross-section (Line2D.texture_mode = STRETCH).
uniform float feather : hint_range(0.5, 20.0) = 7.0;

void fragment() {
    float transverse = abs(UV.y * 2.0 - 1.0);
    float falloff = exp(-feather * transverse * transverse);
    COLOR.a *= falloff;
}
