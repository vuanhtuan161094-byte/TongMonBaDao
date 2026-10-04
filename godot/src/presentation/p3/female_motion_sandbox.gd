extends Control

const DIRECTIONS: Array[StringName] = [&"down", &"right", &"up", &"left"]
const DISPLAY_SCALE := 1.35

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_header()
    var library := FemaleNormalV1MotionLibrary.build()
    var x_positions := [120.0, 400.0, 680.0, 960.0]

    for index in range(DIRECTIONS.size()):
        _spawn_actor(Vector2(x_positions[index], 145.0), DIRECTIONS[index], &"idle", library)
        _spawn_actor(Vector2(x_positions[index], 395.0), DIRECTIONS[index], &"walk", library)

func _build_header() -> void:
    var title := Label.new()
    title.text = "female_normal_v1 — shared idle + walk motion proof"
    title.position = Vector2(40.0, 20.0)
    title.size = Vector2(1200.0, 38.0)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    add_child(title)

    var subtitle := Label.new()
    subtitle.text = "DOWN / RIGHT / UP authored art   •   LEFT mirrors RIGHT   •   one shared AnimationLibrary"
    subtitle.position = Vector2(40.0, 62.0)
    subtitle.size = Vector2(1200.0, 28.0)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 14)
    add_child(subtitle)

func _spawn_actor(origin: Vector2, direction: StringName, clip: StringName, library: AnimationLibrary) -> void:
    var holder := Control.new()
    holder.position = origin
    holder.size = Vector2(200.0, 210.0)
    add_child(holder)

    var actor := ModularDiscipleActor.new()
    actor.position = Vector2(55.0, 20.0)
    actor.scale = Vector2.ONE * DISPLAY_SCALE
    holder.add_child(actor)
    actor.set_animation_library(library)

    var result := FemaleStageAAssetLoader.apply_public_direction(actor, direction)
    if clip == &"walk":
        actor.play_walk_for_delta(_delta_for_direction(direction))
    else:
        actor.current_clip = &"idle"
        actor.set_facing_from_delta(_delta_for_direction(direction))
    actor.set_status_text("%s %s" % [str(clip), str(direction)])

    var label := Label.new()
    label.position = Vector2(0.0, 150.0)
    label.size = Vector2(200.0, 52.0)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.text = "%s %s\n%s" % [
        str(clip).to_upper(),
        str(direction).to_upper(),
        "OK" if int(result.get("applied", 0)) == 14 else "MISSING"
    ]
    label.add_theme_font_size_override("font_size", 15)
    holder.add_child(label)

func _delta_for_direction(direction: StringName) -> Vector2:
    match direction:
        &"down":
            return Vector2(0.0, 1.0)
        &"right":
            return Vector2(1.0, 0.0)
        &"up":
            return Vector2(0.0, -1.0)
        &"left":
            return Vector2(-1.0, 0.0)
        _:
            return Vector2(0.0, 1.0)
