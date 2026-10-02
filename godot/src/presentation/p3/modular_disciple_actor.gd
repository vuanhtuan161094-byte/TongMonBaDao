class_name ModularDiscipleActor
extends Control

signal actor_pressed(disciple_id: StringName)

const ACTOR_SIZE := Vector2(86.0, 82.0)
const VISUAL_ORIGIN := Vector2(43.0, 55.0)
const SOURCE_FRAME_SIZE := Vector2(128.0, 128.0)
const SOURCE_FOOT_POINT := Vector2(64.0, 104.0)
const VISUAL_SCALE := 0.58

const PLACEHOLDER_FILL := Color(0.28, 0.48, 0.37, 1.0)
const PLACEHOLDER_BORDER := Color(0.12, 0.11, 0.09, 1.0)
const PLACEHOLDER_HOVER := Color(0.38, 0.58, 0.47, 1.0)
const PLACEHOLDER_GOLD := Color(0.78, 0.61, 0.25, 1.0)
const PLACEHOLDER_TEXT := Color(0.97, 0.94, 0.84, 1.0)
const STATUS_TEXT := Color(0.12, 0.11, 0.09, 1.0)

var disciple_id: StringName = &""
var display_name := ""
var archetype_id: StringName = &"male_sword"
var current_clip: StringName = DiscipleActorVisualCatalog.CLIP_IDLE
var facing: StringName = DiscipleActorVisualCatalog.DIR_DOWN

var visual_root: Node2D
var layers: Dictionary = {}
var click_button: Button
var status_label: Label
var _built := false

func _init() -> void:
    custom_minimum_size = ACTOR_SIZE
    size = ACTOR_SIZE
    mouse_filter = Control.MOUSE_FILTER_PASS

func _ready() -> void:
    _ensure_built()

func configure(disciple: DiscipleState) -> void:
    _ensure_built()
    if disciple == null:
        return
    disciple_id = disciple.id
    display_name = disciple.display_name
    archetype_id = DiscipleActorVisualCatalog.archetype_for_disciple(disciple)
    click_button.tooltip_text = display_name
    click_button.text = display_name.substr(0, 1)
    sync_action(disciple.current_action)
    _refresh_placeholder_mode()

func sync_action(action: StringName) -> void:
    _ensure_built()
    current_clip = DiscipleActorVisualCatalog.action_clip(action)
    status_label.text = SectMapPresentation.action_label(action)
    _play_all_layers()

func play_walk_for_delta(delta: Vector2) -> void:
    _ensure_built()
    facing = DiscipleActorVisualCatalog.direction_for_delta(delta, facing)
    current_clip = DiscipleActorVisualCatalog.CLIP_WALK
    _play_all_layers()

func set_facing_from_delta(delta: Vector2) -> void:
    _ensure_built()
    facing = DiscipleActorVisualCatalog.direction_for_delta(delta, facing)
    _play_all_layers()

func set_status_text(text: String) -> void:
    _ensure_built()
    status_label.text = text

func set_layer_frames(layer_name: StringName, sprite_frames: SpriteFrames) -> bool:
    _ensure_built()
    if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
        return false
    var sprite: AnimatedSprite2D = layers[str(layer_name)] as AnimatedSprite2D
    sprite.sprite_frames = sprite_frames
    _play_layer(sprite)
    _refresh_placeholder_mode()
    return true

func clear_layer_frames(layer_name: StringName) -> bool:
    _ensure_built()
    if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
        return false
    var sprite: AnimatedSprite2D = layers[str(layer_name)] as AnimatedSprite2D
    sprite.stop()
    sprite.sprite_frames = null
    sprite.visible = false
    _refresh_placeholder_mode()
    return true

func set_visual_bundle(layer_frames: Dictionary) -> void:
    _ensure_built()
    for raw_layer in layer_frames.keys():
        var layer_name := StringName(raw_layer)
        if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
            continue
        var frames = layer_frames[raw_layer]
        if frames == null or frames is SpriteFrames:
            set_layer_frames(layer_name, frames as SpriteFrames)

func layer_names() -> Array[StringName]:
    return DiscipleActorVisualCatalog.layer_order()

func production_body_active() -> bool:
    _ensure_built()
    var body: AnimatedSprite2D = layers["body"] as AnimatedSprite2D
    if body.sprite_frames == null:
        return false
    return _best_animation(body.sprite_frames) != &""

func current_animation_name() -> StringName:
    return DiscipleActorVisualCatalog.animation_name(current_clip, facing)

func _ensure_built() -> void:
    if _built:
        return
    _built = true

    visual_root = Node2D.new()
    visual_root.name = "VisualRoot"
    visual_root.position = VISUAL_ORIGIN
    visual_root.scale = Vector2.ONE * VISUAL_SCALE
    add_child(visual_root)

    for layer_name in DiscipleActorVisualCatalog.layer_order():
        var sprite := AnimatedSprite2D.new()
        sprite.name = _pascal_case(str(layer_name))
        sprite.centered = true
        sprite.offset = Vector2(0.0, -(SOURCE_FOOT_POINT.y - SOURCE_FRAME_SIZE.y * 0.5))
        sprite.z_index = DiscipleActorVisualCatalog.z_index_for_layer(layer_name)
        sprite.visible = false
        visual_root.add_child(sprite)
        layers[str(layer_name)] = sprite

    click_button = Button.new()
    click_button.name = "ActorButton"
    click_button.position = Vector2(17.0, 0.0)
    click_button.size = Vector2(52.0, 52.0)
    click_button.add_theme_font_size_override("font_size", 20)
    click_button.add_theme_color_override("font_color", PLACEHOLDER_TEXT)
    click_button.add_theme_stylebox_override("normal", _style(PLACEHOLDER_FILL, PLACEHOLDER_BORDER, 2, 26))
    click_button.add_theme_stylebox_override("hover", _style(PLACEHOLDER_HOVER, PLACEHOLDER_GOLD, 3, 26))
    click_button.add_theme_stylebox_override("pressed", _style(PLACEHOLDER_FILL.darkened(0.10), PLACEHOLDER_GOLD, 3, 26))
    click_button.pressed.connect(_emit_actor_pressed)
    add_child(click_button)

    status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.position = Vector2(0.0, 56.0)
    status_label.size = Vector2(86.0, 20.0)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 10)
    status_label.add_theme_color_override("font_color", STATUS_TEXT)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(status_label)

func _emit_actor_pressed() -> void:
    actor_pressed.emit(disciple_id)

func _play_all_layers() -> void:
    for layer_name in DiscipleActorVisualCatalog.layer_order():
        var sprite: AnimatedSprite2D = layers[str(layer_name)] as AnimatedSprite2D
        _play_layer(sprite)
    _refresh_placeholder_mode()

func _play_layer(sprite: AnimatedSprite2D) -> void:
    if sprite == null or sprite.sprite_frames == null:
        if sprite != null:
            sprite.visible = false
        return
    var animation := _best_animation(sprite.sprite_frames)
    if animation == &"":
        sprite.stop()
        sprite.visible = false
        return
    sprite.visible = true
    if sprite.animation != animation or not sprite.is_playing():
        sprite.play(animation)

func _best_animation(frames: SpriteFrames) -> StringName:
    if frames == null:
        return &""
    var candidates: Array[StringName] = [
        DiscipleActorVisualCatalog.animation_name(current_clip, facing),
        DiscipleActorVisualCatalog.animation_name(current_clip, DiscipleActorVisualCatalog.DIR_DOWN),
        DiscipleActorVisualCatalog.animation_name(DiscipleActorVisualCatalog.CLIP_IDLE, facing),
        DiscipleActorVisualCatalog.animation_name(DiscipleActorVisualCatalog.CLIP_IDLE, DiscipleActorVisualCatalog.DIR_DOWN)
    ]
    for animation in candidates:
        if frames.has_animation(animation):
            return animation
    return &""

func _refresh_placeholder_mode() -> void:
    if click_button == null:
        return
    if production_body_active():
        click_button.text = ""
        click_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
        click_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
        click_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
        return
    click_button.text = display_name.substr(0, 1) if display_name != "" else "?"
    click_button.add_theme_stylebox_override("normal", _style(PLACEHOLDER_FILL, PLACEHOLDER_BORDER, 2, 26))
    click_button.add_theme_stylebox_override("hover", _style(PLACEHOLDER_HOVER, PLACEHOLDER_GOLD, 3, 26))
    click_button.add_theme_stylebox_override("pressed", _style(PLACEHOLDER_FILL.darkened(0.10), PLACEHOLDER_GOLD, 3, 26))

func _style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(corner_radius)
    return style

func _pascal_case(value: String) -> String:
    var parts := value.split("_", false)
    var result := ""
    for part in parts:
        if part.is_empty():
            continue
        result += part.substr(0, 1).to_upper() + part.substr(1)
    return result
