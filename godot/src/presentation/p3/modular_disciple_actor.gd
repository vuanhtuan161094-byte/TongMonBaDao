class_name ModularDiscipleActor
extends Control

signal actor_pressed(disciple_id: StringName)

const ACTOR_SIZE := DiscipleActorVisualCatalog.ACTOR_BOX_SIZE
const VISUAL_SCALE := DiscipleActorVisualCatalog.MAP_DISPLAY_SCALE

const PLACEHOLDER_FILL := Color(0.28, 0.48, 0.37, 1.0)
const PLACEHOLDER_BORDER := Color(0.12, 0.11, 0.09, 1.0)
const PLACEHOLDER_HOVER := Color(0.38, 0.58, 0.47, 1.0)
const PLACEHOLDER_GOLD := Color(0.78, 0.61, 0.25, 1.0)
const PLACEHOLDER_TEXT := Color(0.97, 0.94, 0.84, 1.0)
const STATUS_TEXT := Color(0.12, 0.11, 0.09, 1.0)

var disciple_id: StringName = &""
var display_name := ""
var rig_id: StringName = DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1
var appearance_profile: Dictionary = {}
var current_clip: StringName = DiscipleActorVisualCatalog.CLIP_IDLE
var facing: StringName = DiscipleActorVisualCatalog.DIR_DOWN
var mirror_left := true

var visual_root: Node2D
var rig_root: Node2D
var skeleton: Skeleton2D
var animation_player: AnimationPlayer
var bones: Dictionary = {}
var visual_components: Dictionary = {}
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
    rig_id = DiscipleActorVisualCatalog.rig_for_disciple(disciple)
    appearance_profile = DiscipleActorVisualCatalog.default_appearance_for_disciple(disciple)
    click_button.tooltip_text = display_name
    sync_action(disciple.current_action)
    _refresh_placeholder_mode()

func apply_appearance_profile(raw_profile: Variant, disciple: DiscipleState = null) -> void:
    _ensure_built()
    appearance_profile = DiscipleActorVisualCatalog.normalize_appearance_profile(raw_profile, disciple)
    rig_id = StringName(appearance_profile.get("rig_id", DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1))

func sync_action(action: StringName) -> void:
    _ensure_built()
    current_clip = DiscipleActorVisualCatalog.action_clip(action)
    status_label.text = SectMapPresentation.action_label(action)
    _play_shared_animation()

func play_walk_for_delta(delta: Vector2) -> void:
    _ensure_built()
    facing = DiscipleActorVisualCatalog.direction_for_delta(delta, facing)
    current_clip = DiscipleActorVisualCatalog.CLIP_WALK
    _play_shared_animation()

func set_facing_from_delta(delta: Vector2) -> void:
    _ensure_built()
    facing = DiscipleActorVisualCatalog.direction_for_delta(delta, facing)
    _play_shared_animation()

func set_status_text(text: String) -> void:
    _ensure_built()
    status_label.text = text

func set_left_mirror_enabled(enabled: bool) -> void:
    mirror_left = enabled
    _play_shared_animation()

func set_animation_library(library: AnimationLibrary) -> void:
    _ensure_built()
    if animation_player.has_animation_library(&""):
        animation_player.remove_animation_library(&"")
    if library != null:
        animation_player.add_animation_library(&"", library)
    _play_shared_animation()

# Convenience for a full-canvas single-piece layer. Production body/outfit should
# normally use set_component_texture() for the coarse head/torso/arms/legs bundle.
func set_layer_texture(layer_name: StringName, texture: Texture2D) -> bool:
    if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
        return false
    clear_layer_components(layer_name)
    if texture == null:
        _refresh_placeholder_mode()
        return true
    return set_component_texture(
        layer_name,
        &"main",
        DiscipleActorVisualCatalog.default_bone_for_layer(layer_name),
        texture
    )

func set_component_texture(layer_name: StringName, component_name: StringName, bone_id: StringName, texture: Texture2D) -> bool:
    _ensure_built()
    if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
        return false
    if not DiscipleActorVisualCatalog.BONE_IDS.has(bone_id):
        return false

    var key := _component_key(layer_name, component_name)
    if visual_components.has(key):
        var existing: Sprite2D = visual_components[key] as Sprite2D
        if is_instance_valid(existing):
            existing.queue_free()
        visual_components.erase(key)

    if texture == null:
        _refresh_placeholder_mode()
        return true

    var bone: Bone2D = bones[str(bone_id)] as Bone2D
    var sprite := Sprite2D.new()
    sprite.name = "%s_%s" % [_pascal_case(str(layer_name)), _pascal_case(str(component_name))]
    sprite.texture = texture
    sprite.centered = true
    sprite.position = _registered_sprite_offset(bone_id)
    sprite.z_index = DiscipleActorVisualCatalog.z_index_for_layer(layer_name)
    bone.add_child(sprite)
    visual_components[key] = sprite
    _refresh_placeholder_mode()
    return true

func clear_layer_components(layer_name: StringName) -> bool:
    _ensure_built()
    if not DiscipleActorVisualCatalog.is_valid_layer(layer_name):
        return false
    var prefix := "%s:" % str(layer_name)
    var keys: Array = visual_components.keys()
    for key in keys:
        if not str(key).begins_with(prefix):
            continue
        var sprite: Sprite2D = visual_components[key] as Sprite2D
        if is_instance_valid(sprite):
            sprite.queue_free()
        visual_components.erase(key)
    _refresh_placeholder_mode()
    return true

func layer_names() -> Array[StringName]:
    return DiscipleActorVisualCatalog.layer_order()

func bone_names() -> Array[StringName]:
    return DiscipleActorVisualCatalog.BONE_IDS.duplicate()

func production_body_active() -> bool:
    for key in visual_components.keys():
        if str(key).begins_with("body:"):
            return true
    return false

func current_animation_name() -> StringName:
    return DiscipleActorVisualCatalog.animation_name(current_clip, facing)

func current_playback_animation_name() -> StringName:
    var playback_direction := DiscipleActorVisualCatalog.playback_direction(facing, mirror_left)
    return DiscipleActorVisualCatalog.animation_name(current_clip, playback_direction)

func uses_mirrored_left() -> bool:
    return DiscipleActorVisualCatalog.should_mirror(facing, mirror_left)

func _ensure_built() -> void:
    if _built:
        return
    _built = true

    visual_root = Node2D.new()
    visual_root.name = "VisualRoot"
    visual_root.position = DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    visual_root.scale = Vector2.ONE * VISUAL_SCALE
    add_child(visual_root)

    rig_root = Node2D.new()
    rig_root.name = "RigRoot"
    visual_root.add_child(rig_root)

    skeleton = Skeleton2D.new()
    skeleton.name = "Skeleton2D"
    rig_root.add_child(skeleton)
    _build_bone_hierarchy()

    animation_player = AnimationPlayer.new()
    animation_player.name = "AnimationPlayer"
    visual_root.add_child(animation_player)

    click_button = Button.new()
    click_button.name = "ActorButton"
    click_button.position = Vector2(15.0, 2.0)
    click_button.size = Vector2(58.0, 70.0)
    click_button.add_theme_font_size_override("font_size", 20)
    click_button.add_theme_color_override("font_color", PLACEHOLDER_TEXT)
    click_button.add_theme_stylebox_override("normal", _style(PLACEHOLDER_FILL, PLACEHOLDER_BORDER, 2, 28))
    click_button.add_theme_stylebox_override("hover", _style(PLACEHOLDER_HOVER, PLACEHOLDER_GOLD, 3, 28))
    click_button.add_theme_stylebox_override("pressed", _style(PLACEHOLDER_FILL.darkened(0.10), PLACEHOLDER_GOLD, 3, 28))
    click_button.pressed.connect(_emit_actor_pressed)
    add_child(click_button)

    status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.position = Vector2(0.0, 73.0)
    status_label.size = Vector2(ACTOR_SIZE.x, 18.0)
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 10)
    status_label.add_theme_color_override("font_color", STATUS_TEXT)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(status_label)

    _apply_mirror()
    _refresh_placeholder_mode()

func _build_bone_hierarchy() -> void:
    for bone_id in DiscipleActorVisualCatalog.BONE_IDS:
        var parent_id := DiscipleActorVisualCatalog.bone_parent(bone_id)
        var parent_node: Node = skeleton
        if parent_id != &"" and bones.has(str(parent_id)):
            parent_node = bones[str(parent_id)] as Bone2D
        var bone := Bone2D.new()
        bone.name = _pascal_case(str(bone_id))
        bone.set_autocalculate_length_and_angle(false)
        bone.position = DiscipleActorVisualCatalog.bone_rest_position(bone_id)
        parent_node.add_child(bone)
        bone.rest = bone.transform
        bones[str(bone_id)] = bone

func _emit_actor_pressed() -> void:
    actor_pressed.emit(disciple_id)

func _play_shared_animation() -> void:
    if not _built:
        return
    _apply_mirror()
    if animation_player == null:
        return
    var animation := _best_available_animation()
    if animation == &"":
        return
    if animation_player.current_animation != animation or not animation_player.is_playing():
        animation_player.play(animation)

func _best_available_animation() -> StringName:
    var playback_direction := DiscipleActorVisualCatalog.playback_direction(facing, mirror_left)
    var candidates: Array[StringName] = [
        DiscipleActorVisualCatalog.animation_name(current_clip, playback_direction),
        DiscipleActorVisualCatalog.animation_name(current_clip, DiscipleActorVisualCatalog.DIR_DOWN),
        DiscipleActorVisualCatalog.animation_name(DiscipleActorVisualCatalog.CLIP_IDLE, playback_direction),
        DiscipleActorVisualCatalog.animation_name(DiscipleActorVisualCatalog.CLIP_IDLE, DiscipleActorVisualCatalog.DIR_DOWN)
    ]
    for animation in candidates:
        if animation_player.has_animation(animation):
            return animation
    return &""

func _apply_mirror() -> void:
    if rig_root == null:
        return
    rig_root.scale = Vector2(-1.0, 1.0) if uses_mirrored_left() else Vector2.ONE

func _registered_sprite_offset(bone_id: StringName) -> Vector2:
    var source_center_relative_to_foot := DiscipleActorVisualCatalog.SOURCE_FRAME_SIZE * 0.5 - DiscipleActorVisualCatalog.SOURCE_FOOT_POINT
    return source_center_relative_to_foot - _bone_global_rest_position(bone_id)

func _bone_global_rest_position(bone_id: StringName) -> Vector2:
    var result := Vector2.ZERO
    var current := bone_id
    var guard := 0
    while current != &"" and guard < DiscipleActorVisualCatalog.BONE_IDS.size() + 1:
        result += DiscipleActorVisualCatalog.bone_rest_position(current)
        current = DiscipleActorVisualCatalog.bone_parent(current)
        guard += 1
    return result

func _component_key(layer_name: StringName, component_name: StringName) -> String:
    return "%s:%s" % [str(layer_name), str(component_name)]

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
    click_button.add_theme_stylebox_override("normal", _style(PLACEHOLDER_FILL, PLACEHOLDER_BORDER, 2, 28))
    click_button.add_theme_stylebox_override("hover", _style(PLACEHOLDER_HOVER, PLACEHOLDER_GOLD, 3, 28))
    click_button.add_theme_stylebox_override("pressed", _style(PLACEHOLDER_FILL.darkened(0.10), PLACEHOLDER_GOLD, 3, 28))

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
