extends Control
## View-only 3D preview for an owner-provided GLB/GLTF/FBX. No gameplay state.
const AUDIT := preload("res://src/presentation/labs/shadow_glb_asset_audit.gd")
const REQUIRED_CLIPS := ["stand", "walk", "attack1", "hit", "dead"]
const AZIMUTHS := [0, 45, 90, 135, 180, 225, 270, 315]

var _path_edit: LineEdit
var _status: Label
var _details: Label
var _playback_label: Label
var _clip_select: OptionButton
var _direction_select: OptionButton
var _play_button: Button
var _speed: HSlider
var _zoom: HSlider
var _shadow_toggle: CheckButton
var _viewport: SubViewport
var _camera: Camera3D
var _model_root: Node3D
var _animation_player: AnimationPlayer
var _meshes: Array[MeshInstance3D] = []
var _original_overrides: Dictionary = {}
var _shadow_material: ShaderMaterial
var _source_clip_names: Array[String] = []
var _playing := true
var _model_loaded := false
var _reference_height := 2.0

func _ready() -> void:
	_build_ui()
	_build_preview_world()
	_show_missing_model()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#100f19")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var title := _label("SHADOW KIẾM TU · 3D ANIMATION LAB", Vector2(22, 14), 24, Color("#eddbff"))
	var subtitle := _label("GLB/FBX thật · camera azimuth · preview 1280×720 · VIEW ONLY", Vector2(24, 50), 14, Color("#bba9d0"))
	var left := ColorRect.new()
	left.color = Color("#191724")
	left.position = Vector2(12, 92)
	left.size = Vector2(276, 610)
	add_child(left)
	var right := ColorRect.new()
	right.color = Color("#191724")
	right.position = Vector2(1006, 92)
	right.size = Vector2(262, 610)
	add_child(right)
	var top_rule := ColorRect.new()
	top_rule.color = Color("#795aa0")
	top_rule.position = Vector2(288, 92)
	top_rule.size = Vector2(718, 2)
	add_child(top_rule)
	var bottom_rule := ColorRect.new()
	bottom_rule.color = Color("#543d70")
	bottom_rule.position = Vector2(288, 667)
	bottom_rule.size = Vector2(718, 2)
	add_child(bottom_rule)
	_label("MODEL NGUỒN", Vector2(24, 108), 15, Color("#eadbff"))
	_path_edit = LineEdit.new()
	_path_edit.position = Vector2(22, 137)
	_path_edit.size = Vector2(254, 40)
	_path_edit.text = "res://assets/user_imports/shadow_kultai.glb"
	_path_edit.placeholder_text = "res://... .glb / .gltf / .fbx"
	add_child(_path_edit)
	var load_button := Button.new()
	load_button.text = "Tải rig"
	load_button.position = Vector2(22, 185)
	load_button.size = Vector2(254, 38)
	load_button.pressed.connect(_load_model)
	add_child(load_button)
	_label("CLIP GỐC", Vector2(24, 240), 15, Color("#eadbff"))
	_clip_select = OptionButton.new()
	_clip_select.position = Vector2(22, 269)
	_clip_select.size = Vector2(254, 38)
	_clip_select.item_selected.connect(_select_clip)
	add_child(_clip_select)
	_play_button = Button.new()
	_play_button.text = "Tạm dừng"
	_play_button.position = Vector2(22, 315)
	_play_button.size = Vector2(121, 38)
	_play_button.pressed.connect(_toggle_play)
	add_child(_play_button)
	var restart := Button.new()
	restart.text = "Phát lại"
	restart.position = Vector2(155, 315)
	restart.size = Vector2(121, 38)
	restart.pressed.connect(_restart)
	add_child(restart)
	_label("HƯỚNG CAMERA THẬT", Vector2(24, 370), 15, Color("#eadbff"))
	_direction_select = OptionButton.new()
	_direction_select.position = Vector2(22, 399)
	_direction_select.size = Vector2(254, 38)
	for azimuth in AZIMUTHS:
		_direction_select.add_item("Azimuth %03d°" % azimuth)
	_direction_select.item_selected.connect(_select_direction)
	add_child(_direction_select)
	_label("Tốc độ", Vector2(24, 454), 13, Color("#d6cce4"))
	_speed = _slider(Vector2(22, 476), 0.1, 2.0, 1.0, 0.05, Callable(self, "_set_speed"))
	_label("Zoom", Vector2(24, 512), 13, Color("#d6cce4"))
	_zoom = _slider(Vector2(22, 534), 0.6, 2.0, 1.0, 0.05, Callable(self, "_set_zoom"))
	_shadow_toggle = CheckButton.new()
	_shadow_toggle.text = "Shader bóng + viền tím"
	_shadow_toggle.position = Vector2(18, 578)
	_shadow_toggle.size = Vector2(258, 32)
	_shadow_toggle.toggled.connect(_set_shadow_style)
	add_child(_shadow_toggle)
	_label("Shader chỉ là presentation; không thay model/mesh.", Vector2(22, 618), 11, Color("#a99bb7"))
	_status = _label("", Vector2(1022, 112), 16, Color("#ffcf76"))
	_status.size = Vector2(226, 88)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var details_scroll := ScrollContainer.new()
	details_scroll.position = Vector2(1019, 207)
	details_scroll.size = Vector2(244, 426)
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(details_scroll)
	_details = Label.new()
	_details.add_theme_font_size_override("font_size", 13)
	_details.add_theme_color_override("font_color", Color("#d4cde0"))
	_details.custom_minimum_size = Vector2(226, 426)
	_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_scroll.add_child(_details)
	_playback_label = _label("Chưa tải rig", Vector2(1022, 641), 12, Color("#c6a9df"))
	_playback_label.size = Vector2(226, 45)
	var foot_note := _label("Camera azimuth 0° = mặt trước theo trục -Z của model. Đường chân là mặt sàn tham chiếu; cần duyệt chân từng clip bằng mắt.", Vector2(300, 674), 12, Color("#d1bedf"))
	foot_note.size = Vector2(690, 36)
	foot_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _build_preview_world() -> void:
	var container := SubViewportContainer.new()
	container.position = Vector2(294, 100)
	container.size = Vector2(706, 550)
	container.stretch = true
	add_child(container)
	_viewport = SubViewport.new()
	_viewport.name = "ImportedModelViewport"
	_viewport.size = Vector2i(1280, 960)
	_viewport.transparent_bg = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(_viewport)
	var world := Node3D.new()
	world.name = "PreviewWorld"
	_viewport.add_child(world)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#100f19")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b6a9c9")
	env.ambient_light_energy = 0.8
	environment.environment = env
	world.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-28, -32, 0)
	light.light_energy = 1.3
	world.add_child(light)
	var floor := MeshInstance3D.new()
	floor.name = "PreviewOnlyFloorGuide"
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(8, 8)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.14, 0.13, 0.18, 0.55)
	floor_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	floor_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	floor.material_override = floor_material
	floor.position.y = 0.005
	world.add_child(floor)
	_camera = Camera3D.new()
	_camera.name = "PreviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.current = true
	_camera.position = Vector3(0, 1.0, 4.5)
	world.add_child(_camera)
	_camera.look_at(Vector3(0, 1.0, 0))
	var shader := load("res://src/presentation/labs/shadow_preview_3d.gdshader") as Shader
	if shader != null:
		_shadow_material = ShaderMaterial.new()
		_shadow_material.shader = shader

func _process(_delta: float) -> void:
	if not _model_loaded:
		return
	if _animation_player == null or _animation_player.current_animation.is_empty():
		_playback_label.text = "Mesh đã tải; rig chưa có clip phát được."
		return
	_playback_label.text = "%s\n%.2f / %.2f giây" % [
		_animation_player.current_animation,
		_animation_player.current_animation_position,
		_animation_player.current_animation_length
	]

func _load_model() -> void:
	_clear_model()
	var path := _path_edit.text.strip_edges()
	var report: Dictionary = AUDIT.inspect_model_path(path)
	if not report.has("model_path"):
		_show_report(report)
		return
	var packed := ResourceLoader.load(path) as PackedScene
	if packed == null:
		_show_report({"status": "INVALID_IMPORTED_SCENE", "detail": "Godot could not load the imported PackedScene."})
		return
	var scene_root := packed.instantiate()
	var world := _viewport.get_child(0)
	_model_root = Node3D.new()
	_model_root.name = "OwnerProvidedImportedModel"
	world.add_child(_model_root)
	if scene_root is Node3D:
		_model_root.add_child(scene_root)
	else:
		var wrapper := Node3D.new()
		_model_root.add_child(wrapper)
		wrapper.add_child(scene_root)
	_find_preview_nodes(_model_root)
	await get_tree().process_frame
	var bounds := _model_bounds(_meshes)
	if not bool(bounds.get("valid", false)):
		_clear_model()
		_show_report({"status": "INVALID_MODEL_NO_MESH", "detail": "Could not compute imported mesh bounds."})
		return
	var min_corner: Vector3 = bounds["min"]
	var max_corner: Vector3 = bounds["max"]
	_reference_height = maxf(0.1, max_corner.y - min_corner.y)
	_model_root.global_position -= Vector3((min_corner.x + max_corner.x) * 0.5, min_corner.y, (min_corner.z + max_corner.z) * 0.5)
	_camera.size = _reference_height * 1.35
	_update_camera()
	_clip_select.clear()
	if _animation_player != null:
		for clip_name in _animation_player.get_animation_list():
			var animation := _animation_player.get_animation(clip_name)
			if animation != null and animation.length > 0.0:
				_source_clip_names.append(str(clip_name))
				_clip_select.add_item(str(clip_name))
	_model_loaded = true
	if _animation_player != null and not _source_clip_names.is_empty():
		_animation_player.play(_source_clip_names[0])
	_show_report(report)
	_set_shadow_style(_shadow_toggle.button_pressed)

func _clear_model() -> void:
	_model_loaded = false
	_animation_player = null
	_meshes.clear()
	_original_overrides.clear()
	_source_clip_names.clear()
	if is_instance_valid(_model_root):
		_model_root.queue_free()
	_model_root = null
	if is_instance_valid(_clip_select):
		_clip_select.clear()

func _find_preview_nodes(node: Node) -> void:
	if node is AnimationPlayer:
		_animation_player = node
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		_meshes.append(mesh_node)
		_original_overrides[mesh_node.get_instance_id()] = mesh_node.material_override
	for child in node.get_children():
		_find_preview_nodes(child)

func _model_bounds(mesh_nodes: Array[MeshInstance3D]) -> Dictionary:
	if mesh_nodes.is_empty():
		return {"valid": false}
	var low := Vector3(1.0e20, 1.0e20, 1.0e20)
	var high := Vector3(-1.0e20, -1.0e20, -1.0e20)
	for mesh_node in mesh_nodes:
		if mesh_node.mesh == null:
			continue
		var box := mesh_node.get_aabb()
		for ix in range(2):
			for iy in range(2):
				for iz in range(2):
					var local_point := box.position + Vector3(box.size.x * ix, box.size.y * iy, box.size.z * iz)
					var point := mesh_node.to_global(local_point)
					low = low.min(point)
					high = high.max(point)
	return {"valid": high.x > -1.0e19, "min": low, "max": high}

func _select_clip(index: int) -> void:
	if not _model_loaded or _animation_player == null or index < 0 or index >= _source_clip_names.size():
		return
	_animation_player.play(_source_clip_names[index])
	_animation_player.seek(0.0, true)
	_playing = true

func _select_direction(index: int) -> void:
	_update_camera()

func _update_camera() -> void:
	if _camera == null:
		return
	var selected := clampi(_direction_select.selected if _direction_select != null else 0, 0, AZIMUTHS.size() - 1)
	var degrees: int = AZIMUTHS[selected]
	var azimuth := deg_to_rad(float(degrees))
	var distance := maxf(3.5, _reference_height * 3.0)
	var target := Vector3(0, _reference_height * 0.53, 0)
	_camera.position = target + Vector3(sin(azimuth) * distance, 0, cos(azimuth) * distance)
	_camera.look_at(target, Vector3.UP)
	_camera.size = _reference_height * 1.35 / maxf(0.6, _zoom.value if _zoom != null else 1.0)

func _toggle_play() -> void:
	if not _model_loaded or _animation_player == null:
		return
	_playing = not _playing
	if _playing:
		_animation_player.play()
	else:
		_animation_player.pause()
	_play_button.text = "Tạm dừng" if _playing else "Tiếp tục"

func _restart() -> void:
	if _model_loaded and _animation_player != null and _clip_select.selected >= 0:
		_animation_player.play(_source_clip_names[_clip_select.selected])
		_animation_player.seek(0.0, true)
		_playing = true
		_play_button.text = "Tạm dừng"

func _set_speed(value: float) -> void:
	if _model_loaded and _animation_player != null:
		_animation_player.speed_scale = value

func _set_zoom(value: float) -> void:
	_update_camera()

func _set_shadow_style(enabled: bool) -> void:
	for mesh_node in _meshes:
		if not is_instance_valid(mesh_node):
			continue
		if enabled and _shadow_material != null:
			mesh_node.material_override = _shadow_material
		else:
			mesh_node.material_override = _original_overrides.get(mesh_node.get_instance_id())

func _show_missing_model() -> void:
	_show_report({
		"status": "BLOCKED_BY_TRIPO_ASSET",
		"detail": "Không tìm thấy GLB/FBX thật. Import model vào user_imports rồi tải rig; không dùng model/clip giả."
	})

func _show_report(report: Dictionary) -> void:
	_status.text = str(report.get("status", "UNKNOWN"))
	var lines: Array[String] = []
	lines.append(str(report.get("detail", "")))
	if report.has("model_path"):
		lines.append("\nNguồn: " + str(report["model_path"]))
		lines.append("SHA-256: " + str(report.get("source_sha256", "")))
	if report.has("bone_count"):
		lines.append("\nSkeleton: %d bone(s)" % int(report["bone_count"]))
		lines.append("Nhóm xương thiếu: " + (", ".join(report.get("missing_bone_groups", [])) if not report.get("missing_bone_groups", []).is_empty() else "không"))
		lines.append("\nTRẠNG THÁI CLIP")
		var states: Dictionary = report.get("clip_states", {})
		for clip_name in REQUIRED_CLIPS + ["run"]:
			var row: Dictionary = states.get(clip_name, {"state": "UNVERIFIED"})
			lines.append("%s: %s" % [clip_name, row.get("state", "UNVERIFIED")])
		lines.append("\nClip trong rig: " + ", ".join(report.get("actual_clips", [])))
		lines.append("\nFoot bones: " + str(report.get("foot_bone_indices", [])))
		var bone_names: Array = report.get("bone_names", [])
		lines.append("\nTên xương (%d):" % bone_names.size())
		for bone_name in bone_names:
			lines.append(str(bone_name))
	lines.append("\nTám hướng: camera azimuth thật; không phải animation 8 hướng được tác giả tạo.")
	_details.text = "\n".join(lines)
	_details.custom_minimum_size = Vector2(226, maxf(426.0, float(lines.size()) * 18.0))

func qa_snapshot() -> Dictionary:
	return {
		"status": _status.text if _status != null else "UI_NOT_READY",
		"model_loaded": _model_loaded,
		"source_path": _path_edit.text if _path_edit != null else "",
		"animation_player": is_instance_valid(_animation_player),
		"clip_names": _source_clip_names.duplicate(),
		"camera_azimuth_degrees": AZIMUTHS[_direction_select.selected] if _direction_select != null and _direction_select.selected >= 0 else 0,
		"presentation_only": true
	}

func _label(text_value: String, position_value: Vector2, font_size: int, tint: Color) -> Label:
	var item := Label.new()
	item.text = text_value
	item.position = position_value
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", tint)
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(item)
	return item

func _slider(position_value: Vector2, minimum: float, maximum: float, initial: float, step_value: float, callback: Callable) -> HSlider:
	var item := HSlider.new()
	item.position = position_value
	item.size = Vector2(254, 28)
	item.min_value = minimum
	item.max_value = maximum
	item.step = step_value
	item.value = initial
	item.value_changed.connect(callback)
	add_child(item)
	return item

