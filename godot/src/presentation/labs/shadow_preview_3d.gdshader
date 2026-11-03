shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Preview-only treatment. It does not add geometry, hair, armor, or animation.
void fragment() {
	vec3 view_normal = normalize(NORMAL);
	float rim = pow(1.0 - max(dot(view_normal, VIEW), 0.0), 2.2);
	ALBEDO = vec3(0.012, 0.009, 0.025);
	METALLIC = 0.28;
	ROUGHNESS = 0.62;
	EMISSION = vec3(0.34, 0.06, 0.78) * rim * 1.8;
}

