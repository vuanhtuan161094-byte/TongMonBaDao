extends Control
## Candidate-only visual playback over the real P3.2 production map.
## The default project save is isolated by the launcher's --user-data-dir.

const GAME_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const AS48_SCENE := "res://assets/p3/baked_candidates/aschar48/AS48_BakedVisual4DirCandidate.tscn"
const AS49_SCENE := "res://assets/p3/baked_candidates/aschar49/AS49_BakedVisual4DirCandidate.tscn"
const DIRECTIONS: Array[StringName] = [&"front", &"right", &"back", &"left"]
const ACTIONS: Array[StringName] = [&"idle", &"walk", &"attack", &"cast", &"hit", &"downed"]
const STEP_SECONDS := 0.95

var actors: Array[BakedDiscipleAnimationAdapter] = []
var name_labels: Array[Label] = []
var status_label: Label
var sequence_index := 0
var step_elapsed := 0.0
var base_positions: Array[Vector2] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var game := load(GAME_SCENE) as PackedScene
	if game == null:
		push_error("ASCHAR_SHOWCASE_GAME_SCENE_MISSING")
		return
	var world := game.instantiate() as Control
	if world == null:
		push_error("ASCHAR_SHOWCASE_GAME_SCENE_INVALID")
		return
	world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(world)
	move_child(world, 0)

	var stage := CanvasLayer.new()
	stage.name = "CharacterPreviewLayer"
	stage.layer = 20
	add_child(stage)
	var shade := ColorRect.new()
	shade.name = "StageTint"
	shade.color = Color(0.025, 0.045, 0.07, 0.22)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(shade)

	var screen := get_viewport_rect().size
	var title := Label.new()
	title.text = "KIẾM TU — BỐN HƯỚNG · SÁU ĐỘNG TÁC"
	title.position = Vector2(28, 86)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color(0.96, 0.87, 0.64))
	title.add_theme_color_override("font_outline_color", Color(0.035, 0.055, 0.075))
	title.add_theme_constant_override("outline_size", 4)
	stage.add_child(title)

	status_label = Label.new()
	status_label.position = Vector2(28, 122)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
	status_label.add_theme_color_override("font_outline_color", Color(0.035, 0.055, 0.075))
	status_label.add_theme_constant_override("outline_size", 3)
	stage.add_child(status_label)

	var packed_paths := [AS48_SCENE, AS49_SCENE]
	var names := ["AS-CHAR-48 · NAM KIẾM TU", "AS-CHAR-49 · NỮ KIẾM TU"]
	var x_positions := [screen.x * 0.32, screen.x * 0.70]
	for i in range(packed_paths.size()):
		var packed := load(packed_paths[i]) as PackedScene
		if packed == null:
			push_error("ASCHAR_SHOWCASE_CANDIDATE_SCENE_MISSING %s" % packed_paths[i])
			return
		var actor := packed.instantiate() as BakedDiscipleAnimationAdapter
		if actor == null:
			push_error("ASCHAR_SHOWCASE_CANDIDATE_SCENE_INVALID %s" % packed_paths[i])
			return
		actor.position = Vector2(x_positions[i], screen.y * 0.80)
		stage.add_child(actor)
		actors.append(actor)
		base_positions.append(actor.position)
		var name_label := Label.new()
		name_label.text = names[i]
		name_label.position = Vector2(x_positions[i] - 190, screen.y * 0.245)
		name_label.size = Vector2(380, 28)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 17)
		name_label.add_theme_color_override("font_color", Color(0.98, 0.90, 0.72))
		name_label.add_theme_color_override("font_outline_color", Color(0.035, 0.055, 0.075))
		name_label.add_theme_constant_override("outline_size", 4)
		stage.add_child(name_label)
		name_labels.append(name_label)
	_begin_step()
	print("ASCHAR_48_49_4DIRECTION_SHOWCASE_READY scene=P3.2 window=%s" % str(screen))

func _process(delta: float) -> void:
	if actors.size() != 2:
		return
	step_elapsed += delta
	_apply_walk_motion(clampf(step_elapsed / STEP_SECONDS, 0.0, 1.0))
	if step_elapsed >= STEP_SECONDS:
		sequence_index = (sequence_index + 1) % (DIRECTIONS.size() * ACTIONS.size())
		step_elapsed = 0.0
		_begin_step()

func _begin_step() -> void:
	var direction_index := int(sequence_index / ACTIONS.size())
	var action_index := sequence_index % ACTIONS.size()
	var direction := DIRECTIONS[direction_index]
	var action := ACTIONS[action_index]
	for i in range(actors.size()):
		actors[i].position = base_positions[i]
		actors[i].play_game_action(action, direction)
	if status_label != null:
		status_label.text = "%s  /  %s" % [_direction_label(direction), _action_label(action)]
	print("ASCHAR_SHOWCASE_STEP direction=%s action=%s" % [str(direction), str(action)])

func _apply_walk_motion(progress: float) -> void:
	var direction_index := int(sequence_index / ACTIONS.size())
	var action := ACTIONS[sequence_index % ACTIONS.size()]
	if action != &"walk":
		return
	var direction := DIRECTIONS[direction_index]
	var delta := Vector2.ZERO
	match direction:
		&"front": delta = Vector2(0, 36)
		&"right": delta = Vector2(54, 0)
		&"back": delta = Vector2(0, -36)
		&"left": delta = Vector2(-54, 0)
	var eased := progress * progress * (3.0 - 2.0 * progress)
	for i in range(actors.size()):
		actors[i].position = base_positions[i] + delta * eased

func _direction_label(direction: StringName) -> String:
	match direction:
		&"front": return "CHÍNH DIỆN"
		&"right": return "NHÌN PHẢI"
		&"back": return "QUAY LƯNG"
		&"left": return "NHÌN TRÁI"
	return str(direction).to_upper()

func _action_label(action: StringName) -> String:
	match action:
		&"idle": return "TĨNH TỨC"
		&"walk": return "BỘ HÀNH"
		&"attack": return "XUẤT KIẾM"
		&"cast": return "NGỰ KIẾM"
		&"hit": return "TRÚNG ĐÒN"
		&"downed": return "GỤC NGÃ"
	return str(action).to_upper()
