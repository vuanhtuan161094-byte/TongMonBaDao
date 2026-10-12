extends "res://scripts/env01_environment.gd"
## ENV-02A presentation-only view. Inherits ENV-01 textures and road/selection
## conventions; uses the same TransferMapModel for all authoritative geometry.
const WORLD_GRID := Vector2i(192, 192)
var initial_area := Rect2i(72, 72, 48, 48)
var district_spawn := Vector2i(82, 84)
var chunk_cells := 16
var visible_chunks: Array[Vector2i] = []
var decor_sprites: Array[Sprite2D] = []

func configure_district(p_area: Rect2i, p_spawn: Vector2i, p_chunk_size: int) -> void:
    initial_area = p_area
    district_spawn = p_spawn
    chunk_cells = p_chunk_size

func set_visible_chunks(chunks: Array[Vector2i]) -> void:
    visible_chunks = chunks.duplicate()
    queue_redraw()
    for sprite in decor_sprites:
        var chunk: Vector2i = Vector2i(floori(float(sprite.get_meta("tile_x")) / chunk_cells), floori(float(sprite.get_meta("tile_y")) / chunk_cells))
        sprite.visible = chunk in visible_chunks

func _draw() -> void:
    if model == null:
        return
    # Opaque backdrop; no per-cell nodes are created and off-screen chunks are
    # NOT painted. The 36,864 logical cells never become 36,864 Sprite2D nodes.
    draw_rect(Rect2(-8000, -2000, 16000, 10500), Color("152a25"))
    for chunk in visible_chunks:
        var start := chunk * chunk_cells
        var end := Vector2i(mini(start.x + chunk_cells, model.grid_size.x), mini(start.y + chunk_cells, model.grid_size.y))
        for x in range(start.x, end.x):
            for y in range(start.y, end.y):
                var cell := Vector2i(x, y)
                var rng := posmod(x * 17 + y * 31 + x * y * 7, 19)
                var color := Color("3a5749") if rng < 7 else Color("3d5c4d")
                if rng > 14:
                    color = Color("405e4e")
                # Outside starter area is only darker PREVIEW terrain, not a
                # simulated locked-land state or construction entitlement.
                if not initial_area.has_point(cell):
                    color = color.darkened(0.18)
                _diamond(world_for(Vector2(cell)), color)
                if posmod(x * 11 + y * 23, 13) == 0:
                    _draw_source_surface(cell, "base", 0.11)
        # A small curated number of Source A pavement patches. These are visual
        # only; footprint and path pass through the same MapModel.
        for x in range(start.x, end.x):
            for y in range(start.y, end.y):
                if initial_area.has_point(Vector2i(x, y)) and posmod(x * 9 + y * 7, 71) == 0:
                    _draw_courtyard(Vector2i(x, y))
    _draw_visible_roads()
    _draw_selection_overlay()
    _draw_initial_boundary()

func _draw_visible_roads() -> void:
    for cell in model.roads:
        var key := Vector2i(floori(float(cell.x) / chunk_cells), floori(float(cell.y) / chunk_cells))
        if key not in visible_chunks or model.occupied(cell):
            continue
        var center := world_for(Vector2(cell))
        _diamond(center, Color(0.55, 0.53, 0.40, 0.68))
        var art_key: String = _road_texture_key(cell)
        if art.has(art_key):
            var size := Vector2(half_w * 2.20, half_h * 2.30)
            draw_texture_rect(art[art_key], Rect2(center - size * 0.5, size), false, Color(0.91, 0.89, 0.78, 0.93))

func _draw_selection_overlay() -> void:
    if selected_id == "" or model.get_building(selected_id).is_empty():
        return
    var b: Dictionary = model.get_building(selected_id)
    for cell in model.cells_for(b["kind"], b["origin"], b["orientation"]):
        _diamond(world_for(Vector2(cell)), Color(0.94, 0.72, 0.34, 0.16))
    var door: Vector2i = model.doorway(b["kind"], b["origin"], b["orientation"])
    draw_circle(world_for(Vector2(door)), 4.5, Color(1.0, 0.86, 0.44))
    draw_circle(world_for(Vector2(district_spawn)), 4.5, Color(0.72, 0.94, 0.89))

func _draw_initial_boundary() -> void:
    var x0: float = float(initial_area.position.x) - 0.5
    var y0: float = float(initial_area.position.y) - 0.5
    var x1: float = float(initial_area.end.x) - 0.5
    var y1: float = float(initial_area.end.y) - 0.5
    var p := [world_for(Vector2(x0, y0)), world_for(Vector2(x1, y0)), world_for(Vector2(x1, y1)), world_for(Vector2(x0, y1))]
    for i in range(4):
        draw_line(p[i], p[(i + 1) % 4], Color(0.8, 0.85, 0.61, 0.48), 2)

func _install_decorations() -> void:
    # Reuse original Source A DECOR_LAYOUT, offset into the initial district;
    # original images and hashes remain unchanged.
    var base_offset := district_spawn - Vector2i.ZERO
    for item in DECOR_LAYOUT:
        var cell: Vector2i = Vector2i(item["cell"]) + base_offset
        if model.inside(cell) and (model.occupied(cell) or cell in model.roads):
            continue
        var texture: Texture2D = load(ART_DIR + "vegetation/" + str(item["id"]) + ".png")
        expected_count += 1
        if texture == null or texture.get_width() == 0:
            decor_layout_ok = false
            push_error("ENV02A_DECOR_MISSING " + str(item["id"]))
            continue
        loaded_count += 1
        var sprite := Sprite2D.new()
        sprite.name = "SourceA_" + str(item["id"]) + "_" + str(decoration_count)
        sprite.texture = texture
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        var scale_value: float = float(item["scale"])
        sprite.scale = Vector2.ONE * scale_value
        var foot := world_for(Vector2(cell))
        sprite.position = foot - Vector2(0, texture.get_height() * scale_value * 0.5 - 4)
        sprite.z_index = roundi(foot.y)
        sprite.set_meta("tile_x", cell.x)
        sprite.set_meta("tile_y", cell.y)
        sprite.visible = false
        add_child(sprite)
        decor_sprites.append(sprite)
        decoration_anchors.append(cell)
        decoration_count += 1

func validate_existing_routes() -> bool:
    for id in ["main_hall", "warehouse", "forge"]:
        var route: Array[Vector2i] = model.path_to(id, district_spawn)
        if route.is_empty():
            return false
        for cell in route:
            if cell in decoration_anchors:
                return false
    return true