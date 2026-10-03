extends Control

const ZOOMS := [0.75, 1.0, 1.35]

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _build_title()
    var x_positions := [230.0, 560.0, 900.0]
    for index in range(ZOOMS.size()):
        _spawn_actor(Vector2(x_positions[index], 300.0), float(ZOOMS[index]))

func _build_title() -> void:
    var title := Label.new()
    title.text = "female_normal_v1 — Stage A down/front pivot-lock"
    title.position = Vector2(40.0, 26.0)
    title.size = Vector2(1200.0, 40.0)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 24)
    add_child(title)

func _spawn_actor(center: Vector2, zoom: float) -> void:
    var holder := Control.new()
    holder.position = center
    holder.size = Vector2(180.0, 230.0)
    holder.pivot_offset = holder.size * 0.5
    add_child(holder)

    var actor := ModularDiscipleActor.new()
    actor.position = Vector2(46.0, 40.0)
    actor.scale = Vector2.ONE * zoom
    holder.add_child(actor)
    var result := FemaleStageAAssetLoader.apply_down(actor)
    actor.set_status_text("zoom %.2f" % zoom)

    var info := Label.new()
    info.position = Vector2(0.0, 170.0)
    info.size = Vector2(180.0, 48.0)
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info.text = "%.2fx\n%s" % [zoom, "OK" if int(result.get("applied", 0)) == FemaleStageAAssetLoader.DOWN_COMPONENTS.size() else "MISSING"]
    holder.add_child(info)
