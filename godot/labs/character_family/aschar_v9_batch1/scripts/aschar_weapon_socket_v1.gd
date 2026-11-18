extends RefCounted
class_name ASCharWeaponSocketV1

static func body_grip_world(body_origin: Vector2, body_scale: float, body_grip_px: Vector2) -> Vector2:
	return body_origin + body_grip_px * body_scale

static func asset_point_world(
		grip_world: Vector2,
		asset_point_px: Vector2,
		asset_grip_px: Vector2,
		rotation_deg: float,
		world_scale: float
) -> Vector2:
	return grip_world + (asset_point_px - asset_grip_px).rotated(deg_to_rad(rotation_deg)) * world_scale

static func proxy_corners_world(
		grip_world: Vector2,
		alpha_bounds_px: Rect2,
		asset_grip_px: Vector2,
		rotation_deg: float,
		world_scale: float
) -> PackedVector2Array:
	var corners := PackedVector2Array()
	var points := [
		alpha_bounds_px.position,
		Vector2(alpha_bounds_px.end.x, alpha_bounds_px.position.y),
		alpha_bounds_px.end,
		Vector2(alpha_bounds_px.position.x, alpha_bounds_px.end.y),
	]
	for point in points:
		corners.append(asset_point_world(grip_world, point, asset_grip_px, rotation_deg, world_scale))
	return corners

static func resolve_frame_grip_sockets(frame: Dictionary, family: Dictionary) -> Dictionary:
	var authored: Variant = frame.get("grip_sockets", {})
	if authored is Dictionary and not authored.is_empty():
		return authored.duplicate(true)
	# Read old single-grip V9 metadata while all new metadata moves to role maps.
	if frame.has("body_grip_px"):
		var roles: Array = family.get("grip_roles", ["main_hand"])
		var role := str(roles[0]) if not roles.is_empty() else "main_hand"
		return {
			role: {
				"body_grip_px": frame.get("body_grip_px", []),
				"rotation_deg": frame.get("rotation_deg", 0.0),
				"scale_multiplier": frame.get("scale_multiplier", 1.0),
				"draw_order": frame.get("draw_order", "WEAPON_BEHIND_BODY"),
				"hand_mask_rect_px": frame.get("hand_mask_rect_px", [])
			}
		}
	return {}

static func asset_grip_point(asset: Dictionary, role: String) -> Variant:
	var authored: Variant = asset.get("socket_points_px", {})
	if authored is Dictionary and authored.has(role):
		var point: Variant = authored[role]
		if point is Array and point.size() == 2:
			return Vector2(float(point[0]), float(point[1]))
	if role == str(asset.get("socket_role", "main_hand")) and asset.has("asset_grip_px"):
		var legacy: Array = asset["asset_grip_px"]
		if legacy.size() == 2:
			return Vector2(float(legacy[0]), float(legacy[1]))
	return null

static func resolve_weapon_parts(asset: Dictionary) -> Array[Dictionary]:
	var authored: Variant = asset.get("parts", [])
	var parts: Array[Dictionary] = []
	if authored is Array and not authored.is_empty():
		for part_value in authored:
			if part_value is Dictionary:
				parts.append(part_value.duplicate(true))
		return parts
	# Legacy single-sprite weapons become a one-part assembly for the shared renderer.
	parts.append({
		"socket_role": str(asset.get("socket_role", "main_hand")),
		"path": str(asset.get("path", "")),
		"family": str(asset.get("family", "")),
		"socket_points_px": asset.get("socket_points_px", {}),
		"asset_grip_px": asset.get("asset_grip_px", []),
		"asset_tip_px": asset.get("asset_tip_px", []),
		"asset_scale": float(asset.get("asset_scale", 1.0)),
		"alpha_bounds_gt128_px": asset.get("alpha_bounds_gt128_px", []),
		"canvas_px": asset.get("canvas_px", []),
		"sha256": str(asset.get("sha256", ""))
	})
	return parts

static func resolve_weapon_part_transform(
		part: Dictionary,
		frame_sockets: Dictionary,
		body_origin: Vector2,
		body_scale: float
) -> Dictionary:
	var role := str(part.get("socket_role", "main_hand"))
	if not frame_sockets.has(role):
		return {}
	var frame_socket: Dictionary = frame_sockets[role]
	var body_grip: Array = frame_socket.get("body_grip_px", [])
	if body_grip.size() != 2:
		return {}
	var asset_grip_value: Variant = asset_grip_point(part, role)
	if not asset_grip_value is Vector2:
		return {}
	var asset_grip: Vector2 = asset_grip_value
	var rotation_deg := float(frame_socket.get("rotation_deg", 0.0))
	var world_scale := body_scale * float(part.get("asset_scale", 1.0)) * float(frame_socket.get("scale_multiplier", 1.0))
	var grip_world := body_grip_world(body_origin, body_scale, Vector2(float(body_grip[0]), float(body_grip[1])))
	var secondary_world: Variant = null
	var secondary_role := str(part.get("secondary_socket_role", ""))
	var secondary_asset: Variant = part.get("asset_secondary_grip_px", [])
	if not secondary_role.is_empty() and secondary_asset is Array and secondary_asset.size() == 2 and frame_sockets.has(secondary_role):
		var secondary_socket: Dictionary = frame_sockets[secondary_role]
		var secondary_body: Array = secondary_socket.get("body_grip_px", [])
		if secondary_body.size() != 2:
			return {}
		var target_vector := (Vector2(float(secondary_body[0]), float(secondary_body[1])) - Vector2(float(body_grip[0]), float(body_grip[1]))) * body_scale
		var asset_secondary := Vector2(float(secondary_asset[0]), float(secondary_asset[1]))
		var asset_vector := asset_secondary - asset_grip
		if target_vector.length() < 1.0 or asset_vector.length() < 1.0:
			return {}
		rotation_deg = rad_to_deg(target_vector.angle() - asset_vector.angle()) + float(part.get("rotation_offset_deg", 0.0))
		world_scale = target_vector.length() / asset_vector.length() * float(frame_socket.get("scale_multiplier", 1.0))
		secondary_world = body_grip_world(body_origin, body_scale, Vector2(float(secondary_body[0]), float(secondary_body[1])))
	var tip: Array = part.get("asset_tip_px", [])
	var tip_world: Variant = null
	if tip.size() == 2:
		tip_world = asset_point_world(grip_world, Vector2(float(tip[0]), float(tip[1])), asset_grip, rotation_deg, world_scale)
	return {
		"socket_role": role,
		"frame_socket": frame_socket,
		"grip_world": grip_world,
		"asset_grip_px": asset_grip,
		"rotation_deg": rotation_deg,
		"world_scale": world_scale,
		"secondary_grip_world": secondary_world,
		"tip_world": tip_world,
		"part": part
	}

static func frame_sockets_match_family(sockets: Dictionary, family: Dictionary) -> bool:
	var roles: Variant = family.get("grip_roles", [])
	if not roles is Array or roles.is_empty():
		return false
	for role_value in roles:
		var role := str(role_value)
		if not sockets.has(role):
			return false
		var socket: Variant = sockets[role]
		if not socket is Dictionary:
			return false
		var grip: Variant = socket.get("body_grip_px", [])
		if not grip is Array or grip.size() != 2:
			return false
		if not socket.has("rotation_deg") or not socket.has("scale_multiplier"):
			return false
		if socket.get("draw_order", "") not in ["WEAPON_BEHIND_BODY", "WEAPON_FRONT_WITH_HAND_MASK"]:
			return false
		if socket.get("draw_order") == "WEAPON_FRONT_WITH_HAND_MASK":
			var mask: Variant = socket.get("hand_mask_rect_px", [])
			if not mask is Array or mask.size() != 4:
				return false
	return true

static func is_valid_family_contract(family: Dictionary) -> bool:
	var roles: Variant = family.get("grip_roles", [])
	if not roles is Array or roles.is_empty():
		return false
	var unique_roles := {}
	for role_value in roles:
		var role := str(role_value)
		if role.is_empty() or unique_roles.has(role):
			return false
		unique_roles[role] = true
	return (
		is_supported_proxy_shape(str(family.get("proxy_shape", "")))
		and family.get("proxy_landmarks", []) is Array
		and not family.get("proxy_landmarks", []).is_empty()
		and not str(family.get("motion_profile", "")).is_empty()
		and bool(family.get("separate_motion_contract", false))
	)

static func is_supported_proxy_shape(shape: String) -> bool:
	return shape in [
		"single_grip_blade_axis_bounds",
		"single_grip_asymmetric_blade_axis_bounds",
		"two_independent_hand_axes",
		"two_grips_long_axis_tip",
		"bow_grip_string_nock",
		"hinge_and_fan_edge",
		"palm_plane_and_tip",
		"focus_center_and_support_axis",
		"two_fist_contact_boxes",
		"focus_ray_and_free_weapon_axis"
	]
