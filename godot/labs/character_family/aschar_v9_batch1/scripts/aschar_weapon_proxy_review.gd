extends Node2D

const SOCKETS_PATH := "res://meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"
const PIPELINE_PATH := "res://meta/ASCHAR_WEAPON_PROXY_GRIP_PIPELINE_V9_3.json"
const BODY_CELL := Vector2(400.0, 440.0)
const BODY_SCALE := 0.72
const CENTER := Vector2(385.0, 393.0)
const PHASE_FRAMES := 60
const TOTAL_FRAMES := 120
const SocketMath = preload("res://scripts/aschar_weapon_socket_v1.gd")

var sockets: Dictionary = {}
var pipeline: Dictionary = {}
var body_textures: Array[Texture2D] = []
var frame_sockets: Array[Dictionary] = []
var weapon_items: Array[Dictionary] = []
var weapon_textures: Array[Texture2D] = []
var output_dir := "user://aschar_v9_3_review"
var frame_tick := 0
var current_frame := -1
var current_weapon := -1
var proxy_enabled := true
var captured: Dictionary = {}
var visited := [{}, {}]
var last_seen_frame := [-1, -1]
var failure_code := 0
var failure_message := ""
var _finish_printed := false

func _ready() -> void:
	get_window().size = Vector2i(1280, 720)
	_parse_user_args()
	if not _load_and_validate():
		push_error("ASCHAR_V9_3_LOAD_FAIL=" + failure_message)
		get_tree().quit(failure_code if failure_code != 0 else 2)
		return
	print("ASCHAR_V9_3_REVIEW_START identity=AS48 clip=Attack_Front authored_fps=7 capture_fps=60 resolution=1280x720 debug_proxy=on")
	print("ASCHAR_V9_3_BODY_HASHES=" + ",".join(sockets["body_frames"].map(func(f): return str(f["sha256"]))))
	set_process(true)
	queue_redraw()

func _parse_user_args() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		if args[i] == "--qa-output":
			output_dir = args[i + 1]
	if output_dir.begins_with("user://"):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	else:
		DirAccess.make_dir_recursive_absolute(output_dir)

func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func _load_and_validate() -> bool:
	sockets = _load_json(SOCKETS_PATH)
	pipeline = _load_json(PIPELINE_PATH)
	if sockets.get("schema") != "tmb.aschar.frame_weapon_sockets.v9_3":
		return _fail(10, "socket_schema")
	if pipeline.get("schema") != "tmb.aschar.weapon_proxy_grip_pipeline.v9_3":
		return _fail(11, "pipeline_schema")
	if bool(sockets.get("proxy_visible_in_production", true)):
		return _fail(12, "proxy_must_be_lab_only")
	if bool(pipeline.get("body_contract", {}).get("rigging", true)):
		return _fail(13, "rigging_forbidden")
	if bool(pipeline.get("body_contract", {}).get("body_source_mutation_on_weapon_swap", true)):
		return _fail(14, "body_mutation_forbidden")
	var families: Dictionary = pipeline.get("family_conventions", {})
	var family_motion_keys := {}
	for family_name in families:
		var family_contract: Dictionary = families[family_name]
		if not SocketMath.is_valid_family_contract(family_contract):
			return _fail(15, "invalid_family:" + str(family_name))
		var motion_key := str(family_contract["proxy_shape"]) + "|" + str(family_contract["motion_profile"])
		if family_motion_keys.has(motion_key):
			return _fail(15, "family_motion_contract_duplicated:" + str(family_name))
		family_motion_keys[motion_key] = true
		var fixture_sockets := {}
		var fixture_asset_sockets := {}
		for role_value in family_contract["grip_roles"]:
			var role := str(role_value)
			fixture_sockets[role] = {"body_grip_px": [200, 200], "rotation_deg": 0.0, "scale_multiplier": 1.0, "draw_order": "WEAPON_BEHIND_BODY", "hand_mask_rect_px": []}
			fixture_asset_sockets[role] = [100, 100]
		if not SocketMath.frame_sockets_match_family(fixture_sockets, family_contract):
			return _fail(15, "role_socket_fixture_invalid:" + str(family_name))
		for role_value in family_contract["grip_roles"]:
			if not SocketMath.asset_grip_point({"socket_points_px": fixture_asset_sockets}, str(role_value)) is Vector2:
				return _fail(15, "asset_role_fixture_invalid:" + str(family_name))
	var spear_fixture_sockets := {
		"front_hand": {"body_grip_px": [300, 240], "rotation_deg": 0.0, "scale_multiplier": 1.0, "draw_order": "WEAPON_BEHIND_BODY", "hand_mask_rect_px": []},
		"rear_hand": {"body_grip_px": [100, 240], "rotation_deg": 0.0, "scale_multiplier": 1.0, "draw_order": "WEAPON_BEHIND_BODY", "hand_mask_rect_px": []}
	}
	var spear_fixture_part := {"socket_role": "front_hand", "secondary_socket_role": "rear_hand", "asset_grip_px": [0, 0], "asset_secondary_grip_px": [200, 0], "asset_tip_px": [240, 0], "asset_scale": 1.0}
	var spear_transform := SocketMath.resolve_weapon_part_transform(spear_fixture_part, spear_fixture_sockets, Vector2.ZERO, 1.0)
	if spear_transform.is_empty():
		return _fail(15, "two_hand_socket_transform_fixture_failed")
	var mapped_rear := SocketMath.asset_point_world(spear_transform["grip_world"], Vector2(200, 0), Vector2.ZERO, spear_transform["rotation_deg"], spear_transform["world_scale"])
	if not spear_transform["secondary_grip_world"] is Vector2 or mapped_rear.distance_to(spear_transform["secondary_grip_world"]) > 0.01:
		return _fail(15, "two_hand_socket_alignment_fixture_failed")
	var dual_fixture_parts := SocketMath.resolve_weapon_parts({"parts": [spear_fixture_part, {"socket_role": "rear_hand", "path": "res://fixture_offhand.png"}]})
	if dual_fixture_parts.size() != 2:
		return _fail(15, "multi_part_weapon_fixture_failed")
	if not families.has("jian") or families.size() < 10:
		return _fail(16, "family_conventions_incomplete")
	print("ASCHAR_V9_3_ROLE_SOCKET_CONTRACT=PASS family_contracts=%d two_hand_alignment_fixture=PASS multi_part_fixture=PASS runtime_weapon_family=jian_only" % families.size())
	var frame_data: Array = sockets.get("body_frames", [])
	var family_contract: Dictionary = families.get("jian", {})
	if frame_data.size() != 4:
		return _fail(17, "expected_four_attack_frames")
	var frame_hashes := {}
	for item in frame_data:
		var path := str(item.get("path", ""))
		if item.get("index", -1) != frame_hashes.size():
			return _fail(18, "frame_index_not_contiguous")
		var resolved := SocketMath.resolve_frame_grip_sockets(item, family_contract)
		if not SocketMath.frame_sockets_match_family(resolved, family_contract):
			return _fail(19, "frame_sockets_do_not_match_family")
		var main_socket: Dictionary = resolved["main_hand"]
		var rect_data: Array = main_socket.get("hand_mask_rect_px", [])
		if not rect_data.is_empty() and (rect_data[0] < 0 or rect_data[1] < 0 or rect_data[0] + rect_data[2] > 400 or rect_data[1] + rect_data[3] > 440):
			return _fail(20, "hand_mask_outside_body")
		if main_socket["draw_order"] == "WEAPON_FRONT_WITH_HAND_MASK" and rect_data.is_empty():
			return _fail(20, "front_weapon_requires_hand_mask")
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != BODY_CELL:
			return _fail(21, "body_texture_missing_or_wrong_size:" + path)
		var body_sha := FileAccess.get_sha256(path).to_lower()
		if body_sha != str(item.get("sha256", "")).to_lower():
			return _fail(22, "body_hash_mismatch:" + path)
		if frame_hashes.has(body_sha):
			return _fail(23, "duplicate_body_pose")
		frame_hashes[body_sha] = true
		body_textures.append(texture)
		frame_sockets.append(resolved)
	var assets: Dictionary = sockets.get("weapon_assets", {})
	if assets.size() != 2:
		return _fail(24, "expected_two_candidate_swords")
	for item_id in ["jian_silver_candidate", "jian_phoenix_wing_candidate"]:
		if not assets.has(item_id):
			return _fail(25, "missing_weapon:" + item_id)
		var asset: Dictionary = assets[item_id]
		if asset.get("family") != "jian":
			return _fail(26, "incompatible_weapon_family:" + item_id)
		var texture := load(str(asset.get("path", ""))) as Texture2D
		if texture == null:
			return _fail(27, "weapon_texture_missing:" + item_id)
		if texture.get_size() != Vector2(asset["canvas_px"][0], asset["canvas_px"][1]):
			return _fail(28, "weapon_canvas_mismatch:" + item_id)
		if FileAccess.get_sha256(str(asset["path"])).to_lower() != str(asset["sha256"]).to_lower():
			return _fail(29, "weapon_hash_mismatch:" + item_id)
		var grip_value: Variant = SocketMath.asset_grip_point(asset, "main_hand")
		if not grip_value is Vector2:
			return _fail(29, "weapon_missing_main_hand_socket:" + item_id)
		var grip: Vector2 = grip_value
		var tip := Vector2(asset["asset_tip_px"][0], asset["asset_tip_px"][1])
		if grip.distance_to(tip) < 100.0:
			return _fail(30, "weapon_axis_too_short:" + item_id)
		weapon_items.append(asset)
		weapon_textures.append(texture)
	if assets["jian_silver_candidate"]["sha256"] == assets["jian_phoenix_wing_candidate"]["sha256"]:
		return _fail(31, "weapon_variants_not_distinct")
	for index in range(frame_data.size()):
		var sockets_by_role: Dictionary = frame_sockets[index]
		var socket: Dictionary = sockets_by_role["main_hand"]
		var body_grip := Vector2(socket["body_grip_px"][0], socket["body_grip_px"][1])
		var mask_values: Array = socket.get("hand_mask_rect_px", [])
		var mask_rect := Rect2(mask_values[0], mask_values[1], mask_values[2], mask_values[3]) if mask_values.size() == 4 else Rect2()
		if socket["draw_order"] == "WEAPON_FRONT_WITH_HAND_MASK" and not mask_rect.has_point(body_grip):
			return _fail(33, "front_weapon_mask_does_not_cover_grip")
		for asset in weapon_items:
			for part in SocketMath.resolve_weapon_parts(asset):
				var role := str(part.get("socket_role", "main_hand"))
				if not sockets_by_role.has(role):
					return _fail(34, "weapon_part_role_missing:" + role)
				var transform := SocketMath.resolve_weapon_part_transform(part, sockets_by_role, Vector2.ZERO, 1.0)
				if transform.is_empty():
					return _fail(34, "weapon_part_transform_invalid:" + role)
				var expected_grip := Vector2(sockets_by_role[role]["body_grip_px"][0], sockets_by_role[role]["body_grip_px"][1])
				if transform["grip_world"].distance_to(expected_grip) > 0.01:
					return _fail(34, "weapon_grip_does_not_match_role:" + role)
				if transform["tip_world"] is Vector2 and transform["tip_world"].distance_to(transform["grip_world"]) < 100.0:
					return _fail(34, "grip_tip_transform_invalid:" + role)
	if sockets.get("fps", 0.0) <= 0.0 or sockets.get("loop", true):
		return _fail(32, "attack_must_be_non_looping_authored_clip")
	return true

func _fail(code: int, message: String) -> bool:
	failure_code = code
	failure_message = message
	return false

func _process(_delta: float) -> void:
	frame_tick += 1
	var weapon_index := 0 if frame_tick <= PHASE_FRAMES else 1
	var local_tick := frame_tick if weapon_index == 0 else frame_tick - PHASE_FRAMES
	var next_frame := mini(int(floor(float(local_tick) * float(sockets["fps"]) / 60.0)), body_textures.size() - 1)
	if next_frame < last_seen_frame[weapon_index]:
		push_error("ASCHAR_V9_3_NON_LOOP_REGRESSION=FAIL weapon=%d previous=%d current=%d" % [weapon_index, last_seen_frame[weapon_index], next_frame])
		get_tree().quit(41)
		return
	last_seen_frame[weapon_index] = next_frame
	if weapon_index != current_weapon or next_frame != current_frame:
		current_weapon = weapon_index
		current_frame = next_frame
		visited[weapon_index][next_frame] = true
		queue_redraw()
		print("ASCHAR_V9_3_FRAME weapon=%s index=%d pose=%s grip=%s angle=%s order=%s" % [
			"silver" if weapon_index == 0 else "phoenix_wing",
			next_frame,
			str(sockets["body_frames"][next_frame]["pose"]),
			str(frame_sockets[next_frame]["main_hand"]["body_grip_px"]),
			str(frame_sockets[next_frame]["main_hand"]["rotation_deg"]),
			str(frame_sockets[next_frame]["main_hand"]["draw_order"])
		])
		var capture_key := "%d_%d" % [weapon_index, next_frame]
		if not captured.has(capture_key):
			captured[capture_key] = true
			var capture_name := "AS48_ATTACK_FRONT_SOCKET_%s_FRAME%02d_1280x720.png" % ["SILVER" if weapon_index == 0 else "PHOENIX_WING", next_frame]
			call_deferred("_capture_after_render", capture_name)
	if frame_tick >= TOTAL_FRAMES and not _finish_printed:
		_finish_printed = true
		if visited[0].size() != 4 or visited[1].size() != 4 or captured.size() != 8:
			push_error("ASCHAR_V9_3_COVERAGE_FAIL frames=%s captures=%s" % [str(visited), str(captured)])
			get_tree().quit(40)
		else:
			print("ASCHAR_V9_3_NON_LOOP=PASS authored_order=0,1,2,3 hold_last_pose=true")
			print("ASCHAR_V9_3_WEAPON_SWAP=PASS same_body_frames=4 weapon_variants=2 family=jian proxy=debug_scene_only captures=8 physical_mouse=not_claimed")
			print("ASCHAR_V9_3_RENDER_COMPLETE=PASS native_viewport=1280x720 capture_fps=60 authored_attack_fps=7")
			get_tree().quit(0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_D:
		proxy_enabled = not proxy_enabled
		queue_redraw()
		print("ASCHAR_WEAPON_PROXY_TOGGLE=" + ("ON" if proxy_enabled else "OFF"))

func _capture_after_render(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("ASCHAR_V9_3_CAPTURE_EMPTY=" + file_name)
		return
	var path := output_dir.path_join(file_name)
	var error := image.save_png(path)
	print("ASCHAR_V9_3_CAPTURE=%s size=%dx%d error=%d" % [path, image.get_width(), image.get_height(), error])

func _draw_body(frame_index: int, body_origin: Vector2) -> void:
	draw_set_transform(body_origin, 0.0, Vector2(BODY_SCALE, BODY_SCALE))
	draw_texture(body_textures[frame_index], Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_weapon_parts(
		frame_sockets_by_role: Dictionary,
		asset: Dictionary,
		primary_texture: Texture2D,
		body_origin: Vector2,
		draw_order: String
) -> Array[Dictionary]:
	var drawn_parts: Array[Dictionary] = []
	var parts := SocketMath.resolve_weapon_parts(asset)
	for part in parts:
		var role := str(part.get("socket_role", "main_hand"))
		if not frame_sockets_by_role.has(role):
			continue
		var socket: Dictionary = frame_sockets_by_role[role]
		if str(socket.get("draw_order", "")) != draw_order:
			continue
		var texture: Texture2D = primary_texture if str(part.get("path", "")) == str(asset.get("path", "")) else load(str(part.get("path", ""))) as Texture2D
		if texture == null:
			continue
		var transform := SocketMath.resolve_weapon_part_transform(part, frame_sockets_by_role, body_origin, BODY_SCALE)
		if transform.is_empty():
			continue
		draw_set_transform(transform["grip_world"], deg_to_rad(transform["rotation_deg"]), Vector2(transform["world_scale"], transform["world_scale"]))
		draw_texture(texture, -transform["asset_grip_px"])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		transform["texture"] = texture
		drawn_parts.append(transform)
	return drawn_parts

func _draw_hand_mask(socket: Dictionary, body_texture: Texture2D, body_origin: Vector2) -> void:
	var values: Array = socket["hand_mask_rect_px"]
	var source_rect := Rect2(values[0], values[1], values[2], values[3])
	var destination := Rect2(
		body_origin + source_rect.position * BODY_SCALE,
		source_rect.size * BODY_SCALE
	)
	draw_texture_rect_region(body_texture, destination, source_rect, Color.WHITE, false)

func _socket_world(sockets_by_role: Dictionary, body_origin: Vector2, role: String) -> Variant:
	if not sockets_by_role.has(role):
		return null
	var grip: Array = sockets_by_role[role].get("body_grip_px", [])
	if grip.size() != 2:
		return null
	return SocketMath.body_grip_world(body_origin, BODY_SCALE, Vector2(float(grip[0]), float(grip[1])))

func _draw_proxy_anchor(point: Vector2, label: String, color: Color) -> void:
	draw_circle(point, 5.0, color)
	draw_arc(point, 10.0, 0.0, TAU, 24, color, 1.4)
	draw_string(ThemeDB.fallback_font, point + Vector2(9, -8), label.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)

func _draw_proxy_axis(weapon_draw: Dictionary, color: Color, width: float = 2.0) -> void:
	var tip: Variant = weapon_draw.get("tip_world")
	if tip is Vector2:
		draw_line(weapon_draw["grip_world"], tip, color, width, true)
		_draw_proxy_anchor(tip, "tip", color)
	_draw_proxy_anchor(weapon_draw["grip_world"], str(weapon_draw.get("socket_role", "grip")), Color(1.0, 0.82, 0.18, 0.98))

func _draw_proxy_alpha_bounds(weapon_draw: Dictionary, color: Color) -> void:
	var part: Dictionary = weapon_draw["part"]
	var alpha_values: Array = part.get("alpha_bounds_gt128_px", [])
	if alpha_values.size() != 4:
		return
	var alpha_bounds := Rect2(alpha_values[0], alpha_values[1], alpha_values[2], alpha_values[3])
	var corners := SocketMath.proxy_corners_world(
		weapon_draw["grip_world"],
		alpha_bounds,
		weapon_draw["asset_grip_px"],
		weapon_draw["rotation_deg"],
		weapon_draw["world_scale"]
	)
	for i in range(corners.size()):
		draw_line(corners[i], corners[(i + 1) % corners.size()], color, 1.6, true)

func _draw_family_proxy(weapon_draws: Array[Dictionary], sockets_by_role: Dictionary, body_origin: Vector2) -> void:
	var family_name := str(sockets.get("weapon_family", ""))
	var family_contract: Dictionary = pipeline.get("family_conventions", {}).get(family_name, {})
	var shape := str(family_contract.get("proxy_shape", ""))
	var role_names: Array = family_contract.get("grip_roles", [])
	var role_points := {}
	for role_value in role_names:
		var role := str(role_value)
		var point: Variant = _socket_world(sockets_by_role, body_origin, role)
		if point is Vector2:
			role_points[role] = point
	for weapon_draw in weapon_draws:
		_draw_proxy_alpha_bounds(weapon_draw, Color(0.20, 0.91, 1.0, 0.88))
	match shape:
		"single_grip_blade_axis_bounds":
			for weapon_draw in weapon_draws:
				_draw_proxy_axis(weapon_draw, Color(1.0, 0.27, 0.30, 0.95))
		"single_grip_asymmetric_blade_axis_bounds":
			for weapon_draw in weapon_draws:
				_draw_proxy_axis(weapon_draw, Color(1.0, 0.43, 0.24, 0.95))
				if weapon_draw.get("tip_world") is Vector2:
					var axis: Vector2 = weapon_draw["tip_world"] - weapon_draw["grip_world"]
					var side := axis.normalized().orthogonal() * 7.0
					draw_line(weapon_draw["grip_world"] + side, weapon_draw["tip_world"] + side * 0.25, Color(1.0, 0.72, 0.22, 0.85), 1.2, true)
		"two_independent_hand_axes", "two_grips_long_axis_tip":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(0.68, 0.92, 1.0, 0.95))
			if role_points.size() >= 2:
				var role_keys: Array = role_points.keys()
				draw_line(role_points[role_keys[0]], role_points[role_keys[1]], Color(0.85, 0.67, 1.0, 0.9), 2.0, true)
			for weapon_draw in weapon_draws:
				_draw_proxy_axis(weapon_draw, Color(1.0, 0.36, 0.34, 0.95))
		"bow_grip_string_nock":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(0.72, 1.0, 0.74, 0.95))
			if role_points.has("bow_hand") and role_points.has("draw_hand"):
				draw_line(role_points["bow_hand"], role_points["draw_hand"], Color(0.55, 0.94, 1.0, 0.95), 2.0, true)
			if role_points.has("draw_hand") and role_points.has("nock"):
				draw_line(role_points["draw_hand"], role_points["nock"], Color(1.0, 0.72, 0.28, 0.95), 2.0, true)
			for weapon_draw in weapon_draws:
				_draw_proxy_axis(weapon_draw, Color(0.96, 0.42, 0.72, 0.9), 1.5)
		"hinge_and_fan_edge":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(1.0, 0.82, 0.36, 0.98))
			if role_points.has("main_hand") and role_points.has("hinge"):
				var hinge: Vector2 = role_points["hinge"]
				var radius: float = maxf(8.0, hinge.distance_to(role_points["main_hand"]))
				draw_line(hinge, role_points["main_hand"], Color(1.0, 0.58, 0.23, 0.95), 2.0, true)
				draw_arc(hinge, radius, -1.8, 1.4, 32, Color(0.95, 0.72, 1.0, 0.95), 2.0, true)
		"palm_plane_and_tip":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(1.0, 0.78, 0.50, 0.98))
			if role_points.has("palm_hold") and role_points.has("paper_tip"):
				draw_line(role_points["palm_hold"], role_points["paper_tip"], Color(1.0, 0.46, 0.26, 0.95), 2.0, true)
				draw_circle(role_points["paper_tip"], 3.5, Color(1.0, 0.93, 0.52, 1.0))
		"focus_center_and_support_axis":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(0.58, 0.93, 1.0, 0.98))
			if role_points.has("focus_center") and role_points.has("support_hand"):
				draw_line(role_points["focus_center"], role_points["support_hand"], Color(0.65, 0.84, 1.0, 0.95), 2.0, true)
		"two_fist_contact_boxes":
			for role in role_points:
				var point: Vector2 = role_points[role]
				_draw_proxy_anchor(point, str(role), Color(1.0, 0.54, 0.36, 0.98))
				draw_rect(Rect2(point - Vector2(12, 9), Vector2(24, 18)), Color(1.0, 0.45, 0.31, 0.88), false, 1.6)
			if role_points.has("main_hand") and role_points.has("off_hand"):
				draw_line(role_points["main_hand"], role_points["off_hand"], Color(1.0, 0.75, 0.34, 0.75), 1.2, true)
		"focus_ray_and_free_weapon_axis":
			for role in role_points:
				_draw_proxy_anchor(role_points[role], str(role), Color(0.68, 0.89, 1.0, 0.98))
			if role_points.has("focus_hand") and role_points.has("floating_origin"):
				draw_line(role_points["focus_hand"], role_points["floating_origin"], Color(0.42, 0.91, 1.0, 0.95), 2.0, true)
			for weapon_draw in weapon_draws:
				_draw_proxy_axis(weapon_draw, Color(1.0, 0.36, 0.38, 0.95))
		_:
			push_error("ASCHAR_V9_3_UNSUPPORTED_PROXY_SHAPE=" + shape)

func _draw_proxy(weapon_draws: Array[Dictionary], sockets_by_role: Dictionary, body_origin: Vector2) -> void:
	if proxy_enabled:
		_draw_family_proxy(weapon_draws, sockets_by_role, body_origin)

func _draw() -> void:
	if body_textures.is_empty() or weapon_items.is_empty() or frame_sockets.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#141d29"), true)
	draw_rect(Rect2(26, 18, 1228, 72), Color("#233344"), true)
	draw_string(ThemeDB.fallback_font, Vector2(48, 51), "AS-CHAR-48 · KIẾM TU · ATTACK_FRONT · V9.3 SOCKET LAB", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f6e8cb"))
	draw_string(ThemeDB.fallback_font, Vector2(48, 76), "Godot 4.7.2 · body cel nguyên khối · D bật/tắt proxy debug · art CANDIDATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#c4d1dc"))
	draw_rect(Rect2(38, 111, 694, 566), Color("#1d2b39"), true)
	draw_rect(Rect2(758, 111, 484, 566), Color("#1d2b39"), true)
	var body_origin := CENTER - BODY_CELL * BODY_SCALE * 0.5
	var safe_frame: int = clampi(current_frame, 0, body_textures.size() - 1)
	var frame: Dictionary = sockets["body_frames"][safe_frame]
	var sockets_by_role: Dictionary = frame_sockets[safe_frame]
	var socket: Dictionary = sockets_by_role["main_hand"]
	var item_index: int = clampi(current_weapon, 0, weapon_items.size() - 1)
	var asset: Dictionary = weapon_items[item_index]
	var texture: Texture2D = weapon_textures[item_index]
	var order := str(socket["draw_order"])
	var behind_draws := _draw_weapon_parts(sockets_by_role, asset, texture, body_origin, "WEAPON_BEHIND_BODY")
	_draw_body(safe_frame, body_origin)
	var front_draws := _draw_weapon_parts(sockets_by_role, asset, texture, body_origin, "WEAPON_FRONT_WITH_HAND_MASK")
	for draw_data in front_draws:
		_draw_hand_mask(draw_data["frame_socket"], body_textures[safe_frame], body_origin)
	_draw_proxy(behind_draws + front_draws, sockets_by_role, body_origin)
	draw_line(Vector2(70, 615), Vector2(700, 615), Color("#917b56"), 1.0)
	var active_name := "KIẾM NGÂN LAM · JIAN CANDIDATE" if item_index == 0 else "PHƯỢNG DỰC · JIAN CANDIDATE"
	draw_string(ThemeDB.fallback_font, Vector2(72, 151), "VŨ KHÍ ĐANG GẮN", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#d9c49b"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 179), active_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#ffffff"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 207), "Pha %d/2 · Pose %d/4 · %s" % [item_index + 1, safe_frame + 1, str(frame["pose"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#c8d7e4"))
	draw_string(ThemeDB.fallback_font, Vector2(72, 647), "Proxy chỉ có trong scene review; đường đỏ là grip → tip, khung xanh là alpha bounds.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#b9cad7"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 158), "SOCKET THEO FRAME", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f1dbb8"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 196), "Hand grip: %s px" % str(socket["body_grip_px"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#e7edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 224), "Góc: %.1f°   Scale: %.3f" % [float(socket["rotation_deg"]), float(asset["asset_scale"]) * float(socket["scale_multiplier"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#e7edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 252), "Layer: " + order, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e7edf2"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 280), "Body SHA giữ nguyên khi đổi kiếm.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#a9d8bc"))
	draw_line(Vector2(786, 304), Vector2(1214, 304), Color("#53697b"), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(786, 341), "DẢI QUỸ ĐẠO SOCKET", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#f1dbb8"))
	var trajectory := PackedVector2Array()
	for socket_frame in frame_sockets:
		var socket_px := Vector2(socket_frame["main_hand"]["body_grip_px"][0], socket_frame["main_hand"]["body_grip_px"][1])
		trajectory.append(SocketMath.body_grip_world(body_origin, BODY_SCALE, socket_px))
	draw_polyline(trajectory, Color("#4daabe"), 2.0, true)
	for i in range(trajectory.size()):
		draw_circle(trajectory[i], 3.0, Color("#79d2df"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 397), "4 pose Attack_Front · authored 7 FPS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d5e0e7"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 425), "Swap chỉ thay sprite và asset metadata.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d5e0e7"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 453), "Attack chạy một lần rồi giữ pose cuối.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d5e0e7"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 481), "Không sinh frame nội suy.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d5e0e7"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 549), "Dùng proxy để soi góc, tầm với,", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#c5d6e3"))
	draw_string(ThemeDB.fallback_font, Vector2(786, 576), "chuôi và hướng lưỡi theo từng cel.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#c5d6e3"))
