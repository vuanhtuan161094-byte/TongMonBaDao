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
var fallback_visual: Control
var baked_sprite: AnimatedSprite2D
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
    _apply_fallback_palette()
    click_button.tooltip_text = display_name
    sync_action(disciple.current_action)
    _refresh_placeholder_mode()

func reset_for_reuse() -> void:
    _ensure_built()
    clear_baked_visual()
    for key in visual_components.keys().duplicate():
        var component := visual_components[key] as Sprite2D
        if component != null and is_instance_valid(component):
            if component.get_parent() != null:
                component.get_parent().remove_child(component)
            component.free()
    visual_components.clear()
    disciple_id = &""
    display_name = ""
    facing = DiscipleActorVisualCatalog.DIR_DOWN
    mirror_left = true
    current_clip = DiscipleActorVisualCatalog.CLIP_IDLE
    if animation_player != null:
        animation_player.stop()
    if status_label != null:
        status_label.visible = false
        status_label.text = ""
    if click_button != null:
        click_button.tooltip_text = ""
    _refresh_placeholder_mode()

func apply_appearance_profile(raw_profile: Variant, disciple: DiscipleState = null) -> void:
    _ensure_built()
    appearance_profile = DiscipleActorVisualCatalog.normalize_appearance_profile(raw_profile, disciple)
    rig_id = StringName(appearance_profile.get("rig_id", DiscipleActorVisualCatalog.RIG_FEMALE_NORMAL_V1))
    _apply_fallback_palette()

func sync_action(action: StringName) -> void:
    _ensure_built()
    current_clip = DiscipleActorVisualCatalog.action_clip(action)
    status_label.text = SectMapPresentation.action_label(action)
    # Crowded map labels obscure real actors; tooltip preserves action state.
    # This is presentation-only and does not alter activity or job authority.
    status_label.visible = false
    if click_button != null:
        click_button.tooltip_text = "%s · %s" % [display_name, status_label.text] if display_name != "" else status_label.text
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

# A verified baked pilot can supply map pixels while this actor keeps the
# existing public direction, hit area, identity and action APIs. The modular
# appearance remains the authority whenever a real production body exists.
func set_baked_visual(packed: PackedScene) -> bool:
    _ensure_built()
    if packed == null or production_body_active():
        return false
    var candidate := packed.instantiate() as AnimatedSprite2D
    if candidate == null:
        return false
    if candidate.sprite_frames == null or not candidate.sprite_frames.has_animation(&"stand") or not candidate.sprite_frames.has_animation(&"walk"):
        candidate.free()
        return false
    if baked_sprite != null:
        baked_sprite.queue_free()
    baked_sprite = candidate
    baked_sprite.name = "VerifiedBakedVisual"
    baked_sprite.position = DiscipleActorVisualCatalog.ACTOR_FOOT_POINT
    # The baked scene offset encodes the manifest's foot anchor. Scale by
    # its real cropped frame height so differently sized rigs share a map
    # height near 67 px at zoom 1 without moving the ground contact.
    var stand_frame := baked_sprite.sprite_frames.get_frame_texture(&"stand",0)
    var frame_height := float(stand_frame.get_height()) if stand_frame != null else 192.0
    # A high-resolution atlas can have transparent margins. Read a PILOT-ONLY
    # visual-height metadata value when supplied, without altering older Source A.
    var native_height := frame_height
    var screen_height := 67.0
    if baked_sprite.has_meta("visible_height_px") and baked_sprite.has_meta("pilot_only"):
        native_height = maxf(1.0, float(baked_sprite.get_meta("visible_height_px")))
        screen_height = 75.0
    baked_sprite.scale = Vector2.ONE * (screen_height / maxf(native_height, 1.0))
    baked_sprite.z_index = 1
    # Keep the interactive area over the body, not the surrounding building.
    click_button.position = Vector2(20.0,5.0)
    click_button.size = Vector2(48.0,67.0)
    add_child(baked_sprite)
    _refresh_placeholder_mode()
    _play_shared_animation()
    return true

func baked_visual_active() -> bool:
    return baked_sprite != null and is_instance_valid(baked_sprite)

func clear_baked_visual() -> void:
    if baked_sprite != null and is_instance_valid(baked_sprite):
        if baked_sprite.get_parent() != null:
            baked_sprite.get_parent().remove_child(baked_sprite)
        baked_sprite.free()
    baked_sprite = null
    if click_button != null:
        click_button.position = Vector2(12.0,0.0)
        click_button.size = Vector2(64.0,74.0)

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

    _build_fallback_visual()

    click_button = Button.new()
    click_button.name = "ActorButton"
    click_button.position = Vector2(12.0, 0.0)
    click_button.size = Vector2(64.0, 74.0)
    click_button.add_theme_font_size_override("font_size", 20)
    click_button.add_theme_color_override("font_color", PLACEHOLDER_TEXT)
    click_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    click_button.add_theme_stylebox_override("hover", _outline_style(PLACEHOLDER_GOLD, 2, 18))
    click_button.add_theme_stylebox_override("pressed", _outline_style(PLACEHOLDER_GOLD, 3, 18))
    click_button.pressed.connect(_emit_actor_pressed)
    add_child(click_button)

    status_label = Label.new()
    status_label.name = "StatusLabel"
    # A narrow but opaque tag avoids invisible dark-on-terrain letters;
    # work actions are text-only until real authored Source A clips exist.
    status_label.position = Vector2(-32.0, -30.0)
    status_label.size = Vector2(152.0, 26.0)
    status_label.z_index = 8
    status_label.clip_text = true
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    status_label.add_theme_font_size_override("font_size", 11)
    status_label.add_theme_color_override("font_color", STATUS_TEXT)
    var tag_background := StyleBoxFlat.new()
    tag_background.bg_color = Color(0.96,0.92,0.80,0.97)
    tag_background.border_color = Color(0.25,0.23,0.18,1.0)
    tag_background.set_border_width_all(1)
    tag_background.set_corner_radius_all(5)
    status_label.add_theme_stylebox_override("normal", tag_background)
    status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    status_label.visible = false
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
    if baked_visual_active():
        # The new authored sprite can provide stand_front/right/back/left and
        # Walk-right. Never mirror an independently authored left-side static
        # view or pretend other directions have a moving clip.
        var art_dir := str(facing)
        if art_dir == "down":
            art_dir = "front"
        elif art_dir == "up":
            art_dir = "back"
        var has_independent_left := baked_sprite.sprite_frames.has_animation(&"stand_left")
        baked_sprite.flip_h = facing == DiscipleActorVisualCatalog.DIR_LEFT and mirror_left and not has_independent_left
        var requested_direction := StringName("%s_%s" % [str(current_clip), art_dir])
        var standing_direction := StringName("stand_%s" % art_dir)
        var baked_clip: StringName = current_clip if baked_sprite.sprite_frames.has_animation(current_clip) else (
            &"walk" if current_clip == DiscipleActorVisualCatalog.CLIP_WALK else &"stand"
        )
        if baked_sprite.sprite_frames.has_animation(requested_direction):
            baked_clip = requested_direction
        elif baked_sprite.sprite_frames.has_animation(standing_direction):
            baked_clip = standing_direction
        if baked_sprite.animation != baked_clip or not baked_sprite.is_playing():
            baked_sprite.play(baked_clip)
        return
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

func _build_fallback_visual() -> void:
    fallback_visual = Control.new()
    fallback_visual.name = "FallbackVisual"
    fallback_visual.position = Vector2(20.0, 3.0)
    fallback_visual.size = Vector2(48.0, 68.0)
    fallback_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(fallback_visual)

    var shadow := Panel.new()
    shadow.position = Vector2(6.0, 60.0)
    shadow.size = Vector2(36.0, 8.0)
    shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    shadow.add_theme_stylebox_override("panel", _style(Color(0.08, 0.10, 0.08, 0.28), Color.TRANSPARENT, 0, 8))
    fallback_visual.add_child(shadow)

    var leg_l := Panel.new()
    leg_l.name = "LegLeft"
    leg_l.position = Vector2(12.0, 43.0)
    leg_l.size = Vector2(10.0, 20.0)
    leg_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    leg_l.add_theme_stylebox_override("panel", _style(PLACEHOLDER_FILL.darkened(0.12), PLACEHOLDER_BORDER, 1, 5))
    fallback_visual.add_child(leg_l)

    var leg_r := Panel.new()
    leg_r.name = "LegRight"
    leg_r.position = Vector2(26.0, 43.0)
    leg_r.size = Vector2(10.0, 20.0)
    leg_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
    leg_r.add_theme_stylebox_override("panel", _style(PLACEHOLDER_FILL.darkened(0.12), PLACEHOLDER_BORDER, 1, 5))
    fallback_visual.add_child(leg_r)

    var torso := Panel.new()
    torso.name = "Torso"
    torso.position = Vector2(9.0, 20.0)
    torso.size = Vector2(30.0, 30.0)
    torso.mouse_filter = Control.MOUSE_FILTER_IGNORE
    torso.add_theme_stylebox_override("panel", _style(PLACEHOLDER_FILL, PLACEHOLDER_BORDER, 1, 10))
    fallback_visual.add_child(torso)

    for x in [2.0, 38.0]:
        var arm := Panel.new()
        arm.name = "LeftArm" if x < 10.0 else "RightArm"
        arm.position = Vector2(x, 23.0)
        arm.size = Vector2(8.0, 25.0)
        arm.mouse_filter = Control.MOUSE_FILTER_IGNORE
        arm.add_theme_stylebox_override("panel", _style(PLACEHOLDER_FILL.darkened(0.05), PLACEHOLDER_BORDER, 1, 5))
        fallback_visual.add_child(arm)

    var head := Panel.new()
    head.name = "Head"
    head.position = Vector2(14.0, 1.0)
    head.size = Vector2(20.0, 20.0)
    head.mouse_filter = Control.MOUSE_FILTER_IGNORE
    head.add_theme_stylebox_override("panel", _style(PLACEHOLDER_FILL.lightened(0.08), PLACEHOLDER_BORDER, 1, 10))
    fallback_visual.add_child(head)

    # Lightweight 2D chibi silhouette for unconverted Source A rigs.
    # Deliberately cosmetic, with visible skin/hair/robe rather than a
    # uniform green placeholder. Source A replaces this automatically.
    var hair := Panel.new()
    hair.name = "Hair"
    hair.position = Vector2(12.0, 0.0)
    hair.size = Vector2(24.0, 9.0)
    hair.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fallback_visual.add_child(hair)

    var sash := Panel.new()
    sash.name = "Sash"
    sash.position = Vector2(12.0, 40.0)
    sash.size = Vector2(24.0, 4.0)
    sash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    fallback_visual.add_child(sash)
    _apply_fallback_palette()

func _apply_fallback_palette() -> void:
    if fallback_visual == null or appearance_profile.is_empty():
        return
    # Already persisted profile_seed determines these display-only tint IDs.
    # This does not change the disciple, combat, work, or sprite source.
    var robe := Color.from_string(str(appearance_profile.get("outfit_tint","455472")), Color(0.27,0.33,0.45))
    var hair_tint := Color.from_string(str(appearance_profile.get("hair_tint","2b2624")), Color(0.17,0.15,0.14))
    var ink := Color(0.16,0.14,0.14,1.0)
    var skin := Color(0.94,0.79,0.65,1.0)
    for part_name in ["Torso","LeftArm","RightArm","LegLeft","LegRight"]:
        var part := fallback_visual.get_node_or_null(part_name) as Panel
        if part != null:
            var fill := robe.darkened(0.17) if part_name.begins_with("Leg") else robe
            part.add_theme_stylebox_override("panel",_style(fill,ink,1,5))
    var head := fallback_visual.get_node_or_null("Head") as Panel
    if head != null:
        head.add_theme_stylebox_override("panel",_style(skin,ink,1,10))
    var hair := fallback_visual.get_node_or_null("Hair") as Panel
    if hair != null:
        hair.add_theme_stylebox_override("panel",_style(hair_tint,ink,1,7))
    var sash := fallback_visual.get_node_or_null("Sash") as Panel
    if sash != null:
        sash.add_theme_stylebox_override("panel",_style(Color(0.73,0.56,0.30,1.0),Color.TRANSPARENT,0,2))

func _refresh_placeholder_mode() -> void:
    if click_button == null:
        return
    var has_production_body := production_body_active() or baked_visual_active()
    if fallback_visual != null:
        fallback_visual.visible = not has_production_body
    click_button.text = ""
    click_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
    click_button.add_theme_stylebox_override("hover", _outline_style(PLACEHOLDER_GOLD, 2, 18))
    click_button.add_theme_stylebox_override("pressed", _outline_style(PLACEHOLDER_GOLD, 3, 18))

func _outline_style(border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color.TRANSPARENT
    style.border_color = border
    style.set_border_width_all(border_width)
    style.set_corner_radius_all(corner_radius)
    return style

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
