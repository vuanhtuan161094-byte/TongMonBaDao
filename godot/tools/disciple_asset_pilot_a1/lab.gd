extends Node2D

const VIEW_SIZE := Vector2(1280.0, 720.0)
const COURTYARD: Texture2D = preload("res://assets/background/stone_courtyard.png")
const FLOOR_TILE: Texture2D = preload("res://assets/background/stone_variant.png")
const ZOOM_STEPS := [0.75, 1.0]
const ACTORS := [
	{
		"tag": "A",
		"id": "1113028_1",
		"scene": "res://assets/actors/1113028_1/actor.tscn",
		"label": "Female disciple pool (PR #26; unmerged)",
		"base_scale": 0.34,
		"qa": "Staged-pack runtime proof pending"
	},
	{
		"tag": "B",
		"id": "body_1110201",
		"scene": "res://assets/actors/body_1110201/actor.tscn",
		"label": "Male disciple pool (PR #26; unmerged)",
		"base_scale": 0.34,
		"qa": "Historic Godot import/playback + RGBA sample pass"
	},
	{
		"tag": "C",
		"id": "body_1120402",
		"scene": "res://assets/actors/body_1120402/actor.tscn",
		"label": "PR #26 says male; source path says body_female",
		"base_scale": 0.34,
		"qa": "Historic QA pass; gender evidence conflict"
	},
	{
		"tag": "D",
		"id": "113104_5",
		"scene": "res://assets/actors/113104_5/actor.tscn",
		"label": "Source A candidate; role/gender unverified",
		"base_scale": 0.34,
		"qa": "Historic pass; current converter blocked by active Godot"
	}
]

var _sprites: Array[AnimatedSprite2D] = []
var _selected := 0
var _animation: StringName = &"stand"
var _zoom_index := 1
var _ui_layer: CanvasLayer

func _ready() -> void:
	_build_actor_row()
	_build_ui()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("d7dfda"), true)
	var tile_size := Vector2(256.0, 128.0)
	var y := 0.0
	while y < VIEW_SIZE.y:
		var x := 0.0
		while x < VIEW_SIZE.x:
			draw_texture_rect(COURTYARD, Rect2(Vector2(x, y), tile_size), false, Color(1.0, 1.0, 1.0, 0.28))
			x += tile_size.x
		y += tile_size.y
	for index in range(ACTORS.size()):
		var center_x := 160.0 + float(index) * 320.0
		draw_rect(Rect2(center_x - 148.0, 118.0, 296.0, 490.0), Color(0.93, 0.95, 0.91, 0.72), true)
		draw_rect(Rect2(center_x - 148.0, 118.0, 296.0, 490.0), Color(0.27, 0.38, 0.34, 0.75), false, 1.0)
		draw_texture_rect(FLOOR_TILE, Rect2(center_x - 124.0, 420.0, 248.0, 124.0), false, Color(1.0, 1.0, 1.0, 0.82))
	if _selected >= 0 and _selected < ACTORS.size():
		var selected_x := 160.0 + float(_selected) * 320.0
		draw_rect(Rect2(selected_x - 148.0, 118.0, 296.0, 490.0), Color("d6ad58"), false, 3.0)

func _build_actor_row() -> void:
	for index in range(ACTORS.size()):
		var spec: Dictionary = ACTORS[index]
		var packed := load(str(spec["scene"])) as PackedScene
		if packed == null:
			push_error("Missing actor scene: " + str(spec["scene"]))
			continue
		var actor := packed.instantiate() as AnimatedSprite2D
		if actor == null or actor.sprite_frames == null:
			push_error("Actor scene is not an AnimatedSprite2D with SpriteFrames: " + str(spec["id"]))
			continue
		actor.position = Vector2(160.0 + float(index) * 320.0, 458.0)
		actor.scale = Vector2.ONE * float(spec["base_scale"]) * float(ZOOM_STEPS[_zoom_index])
		actor.z_index = 2
		add_child(actor)
		_sprites.append(actor)
		if actor.sprite_frames.has_animation(_animation):
			actor.play(_animation)
		else:
			push_error("Missing stand clip for " + str(spec["id"]))

func _build_ui() -> void:
	_ui_layer = CanvasLayer.new()
	add_child(_ui_layer)
	_add_label("DISCIPLE ASSET LAB A1", Vector2(28.0, 16.0), 24, Color("273531"), 400.0, 34.0)
	_add_label("Source A baked profiles • map-style scale • 1280 × 720", Vector2(30.0, 50.0), 14, Color("3f514b"), 500.0, 24.0)
	for index in range(ACTORS.size()):
		var spec: Dictionary = ACTORS[index]
		var x := 26.0 + float(index) * 320.0
		_add_label(str(spec["tag"]) + "  •  " + str(spec["id"]), Vector2(x, 132.0), 17, Color("26352f"), 280.0, 28.0)
		_add_label(str(spec["label"]), Vector2(x, 162.0), 12, Color("42524d"), 276.0, 42.0)
		_add_label(str(spec["qa"]), Vector2(x, 566.0), 11, Color("42524d"), 276.0, 34.0)
	_refresh_footer()

func _add_label(value: String, at: Vector2, size: int, color: Color, width: float, height: float) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.size = Vector2(width, height)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	_ui_layer.add_child(label)
	return label

func _refresh_footer() -> void:
	var footer := _ui_layer.get_node_or_null("Footer") as Label
	if footer == null:
		footer = _add_label("", Vector2(30.0, 640.0), 13, Color("25342e"), 1200.0, 64.0)
		footer.name = "Footer"
	var zoom_value := float(ZOOM_STEPS[_zoom_index])
	footer.text = "State: %s  |  Zoom: %.2f  |  Facing: native source view only; no mirror  |  1–4 select • ←/→ select • Space stand/walk • Z zoom 0.75/1.0" % [String(_animation), zoom_value]

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: _select(0)
		KEY_2: _select(1)
		KEY_3: _select(2)
		KEY_4: _select(3)
		KEY_LEFT: _select((_selected + ACTORS.size() - 1) % ACTORS.size())
		KEY_RIGHT: _select((_selected + 1) % ACTORS.size())
		KEY_SPACE: _toggle_animation()
		KEY_Z: _toggle_zoom()
		KEY_ESCAPE: get_tree().quit()

func _select(index: int) -> void:
	_selected = clampi(index, 0, ACTORS.size() - 1)
	queue_redraw()

func _toggle_animation() -> void:
	_animation = &"walk" if _animation == &"stand" else &"stand"
	for actor in _sprites:
		if actor.sprite_frames.has_animation(_animation):
			actor.play(_animation)
	_refresh_footer()

func _toggle_zoom() -> void:
	_zoom_index = 0 if _zoom_index == 1 else 1
	for index in range(_sprites.size()):
		var actor := _sprites[index]
		var spec: Dictionary = ACTORS[index]
		actor.scale = Vector2.ONE * float(spec["base_scale"]) * float(ZOOM_STEPS[_zoom_index])
	_refresh_footer()

