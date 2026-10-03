extends Control

const DIRECTIONS := [&"down", &"right", &"up"]
const ZOOMS := [0.75, 1.35]

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_header()

    var x_positions := [250.0, 550.0, 850.0]
    var y_positions := [155.0, 390.0]
    for row in range(ZOOMS.size()):
        for column in range(DIRECTIONS.size()):
            _spawn_actor(
                Vector2(x_positions[column], y_positions[row]),
                StringName(DIRECTIONS[column]),
                float(ZOOMS[row])
            )

func _build_header() -> void:
    var title := Label.new()
    title.text = "female_normal_v1 — Stage A authored direction review"
    title.position = Vector2(40.0, 24.0)
    title.size = Vector2(1200.0, 38.0)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    add_child(title)

    var subtitle := Label.new()
    subtitle.text = "DOWN = front   •   RIGHT = authored side   •   UP = back   •   LEFT mirrors RIGHT later"
    subtitle.position = Vector2(40.0, 65.0)
    subtitle.size = Vector2(1200.0, 28.0)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 14)
    add_child(subtitle)

func _spawn_actor(origin: Vector2, direction: StringName, zoom: float) -> void:
    var holder := Control.new()
    holder.position = origin
    holder.size = Vector2(190.0, 205.0)
    add_child(holder)

    var actor := ModularDiscipleActor.new()
    actor.position = Vector2(50.0, 18.0)
    actor.scale = Vector2.ONE * zoom
    holder.add_child(actor)

    var result := FemaleStageAAssetLoader.apply_direction(actor, direction)
    actor.set_status_text("%s %.2f" % [str(direction), zoom])

    var expected := FemaleStageAAssetLoader.components_for_direction(direction).size()
    var info := Label.new()
    info.position = Vector2(0.0, 135.0)
    info.size = Vector2(190.0, 55.0)
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.text = "%s / %.2fx\n%s" % [
        _direction_label(direction),
        zoom,
        "OK" if int(result.get("applied", 0)) == expected else "MISSING"
    ]
    info.add_theme_font_size_override("font_size", 15)
    holder.add_child(info)

func _direction_label(direction: StringName) -> String:
    match direction:
        &"down":
            return "DOWN (front)"
        &"right":
            return "RIGHT (side)"
        &"up":
            return "UP (back)"
        _:
            return str(direction).to_upper()
