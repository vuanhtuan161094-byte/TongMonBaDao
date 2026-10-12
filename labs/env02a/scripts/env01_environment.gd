extends Node2D
## ENV-01 visual-only renderer. Ground / stone roads are drawn with original
## Source A tile sprites; scenery uses original single-region PNG textures.
## Canonical gameplay, map occupancy, collision and AStar remain in MapModel.

const MapModel = preload("res://scripts/map_model.gd")
const ART_DIR := "res://env01_assets/"
const TERRAIN_ART := {
    "base": "terrain/stone_courtyard.png",
    "runes": "terrain/stone_runes.png",
    "border": "terrain/stone_border.png",
    "alternate": "terrain/stone_variant.png"
}
const ROAD_ART := {
    "cross": "roads/stone_cross.png",
    "axis_a": "roads/stone_axis_a.png",
    "axis_b": "roads/stone_axis_b.png",
    "junction": "roads/stone_junction.png",
    "scatter": "roads/stone_scatter.png",
    "branch": "roads/stone_branch.png"
}

## Scene dressing only. Anchors outside the grid cannot obstruct AStar.
## Interior anchors are rejected when occupied or paved. Prop graphics may
## overhang their cells: gameplay movement must remain governed by MapModel.
const DECOR_LAYOUT := [
    {"id": "570036", "cell": Vector2i(-1, 7), "scale": 0.42},
    {"id": "570037", "cell": Vector2i(4, 13), "scale": 0.44},
    {"id": "570038", "cell": Vector2i(19, 9), "scale": 0.40},
    {"id": "570171", "cell": Vector2i(8, 14), "scale": 0.40},
    {"id": "570172", "cell": Vector2i(21, 4), "scale": 0.40},
    {"id": "570173", "cell": Vector2i(15, 13), "scale": 0.39},
    {"id": "570181", "cell": Vector2i(-2, 10), "scale": 0.47},
    {"id": "570182", "cell": Vector2i(20, 10), "scale": 0.46},
    {"id": "570041", "cell": Vector2i(2, 12), "scale": 0.50},
    {"id": "570042", "cell": Vector2i(18, -1), "scale": 0.43},
    {"id": "570043", "cell": Vector2i(13, 13), "scale": 0.47},
    {"id": "570073", "cell": Vector2i(0, 12), "scale": 0.32},
    {"id": "570073", "cell": Vector2i(21, 11), "scale": 0.27},
    {"id": "570144", "cell": Vector2i(9, 6), "scale": 0.38},
    {"id": "570144", "cell": Vector2i(17, 2), "scale": 0.33},
    {"id": "570399", "cell": Vector2i(16, 8), "scale": 0.43},
    {"id": "570185", "cell": Vector2i(-1, 8), "scale": 0.39},
    {"id": "570186", "cell": Vector2i(11, 13), "scale": 0.34},
    {"id": "570187", "cell": Vector2i(21, 6), "scale": 0.38},
    {"id": "570397", "cell": Vector2i(18, 7), "scale": 0.30}
]

var model
var map_origin := Vector2.ZERO
var half_w := 25.0
var half_h := 13.0
var art: Dictionary = {}
var loaded_count := 0
var expected_count := 0
var art_load_ok := false
var decoration_anchors: Array[Vector2i] = []
var decoration_count := 0
var decor_layout_ok := true
var selected_id := "main_hall"

func configure(p_model, p_origin: Vector2, p_half_w: float, p_half_h: float) -> void:
    model = p_model
    map_origin = p_origin
    half_w = p_half_w
    half_h = p_half_h

func _ready() -> void:
    if model == null:
        push_error("ENV01_MODEL_MISSING")
        return
    for key in TERRAIN_ART:
        _load_named_texture(str(key), str(TERRAIN_ART[key]))
    for key in ROAD_ART:
        _load_named_texture(str(key), str(ROAD_ART[key]))
    _install_decorations()
    art_load_ok = loaded_count == expected_count
    print("ENV01_ASSETS loaded=", loaded_count, " expected=", expected_count, " all_loaded=", art_load_ok, " props=", decoration_count)
    queue_redraw()

func _load_named_texture(key: String, relative_path: String) -> void:
    expected_count += 1
    var t: Texture2D = load(ART_DIR + relative_path)
    if t == null or t.get_width() <= 0 or t.get_height() <= 0:
        push_error("ENV01_TEXTURE_MISSING " + relative_path)
        return
    art[key] = t
    loaded_count += 1

func world_for(cell: Vector2) -> Vector2:
    return map_origin + Vector2((cell.x - cell.y) * half_w, (cell.x + cell.y) * half_h)

func _diamond(center: Vector2, color: Color) -> void:
    draw_colored_polygon(PackedVector2Array([
        center + Vector2(0.0, -half_h),
        center + Vector2(half_w, 0.0),
        center + Vector2(0.0, half_h),
        center + Vector2(-half_w, 0.0)
    ]), color)

func _draw() -> void:
    if model == null:
        return
    draw_rect(Rect2(-1400, -1300, 4200, 3100), Color("152a25"))
    # An edge halo makes the playable island legible against the backdrop.
    for x in range(MapModel.WIDTH):
        for y in range(MapModel.HEIGHT):
            var c := Vector2i(x, y)
            var rng := posmod(x * 17 + y * 31 + x * y * 7, 19)
            var shade := Color("3a5749") if rng < 7 else Color("3d5c4d")
            if rng > 14:
                shade = Color("405e4e")
            if x == 0 or y == 0 or x == MapModel.WIDTH - 1 or y == MapModel.HEIGHT - 1:
                shade = shade.darkened(0.07)
            _diamond(world_for(Vector2(c)), shade)
            # Original Source A stone surface, used selectively as an accent.
            # Low opacity keeps the garden natural rather than snow white.
            if posmod(x * 11 + y * 23, 13) == 0:
                _draw_source_surface(c, "base", 0.11)

    # Courtyard surface patches: Source A 256x130 tiles scaled to two
    # PV-01 cells along each grid axis (100x52 projected pixels).
    for p in [
        Vector2i(2, 0), Vector2i(4, 0), Vector2i(6, 0),
        Vector2i(8, 5), Vector2i(10, 5), Vector2i(12, 5),
        Vector2i(13, 1), Vector2i(15, 1),
        Vector2i(8, 10), Vector2i(10, 11)
    ]:
        _draw_courtyard(p)

    _draw_roads()
    _draw_selection_overlay()
    _draw_perimeter()

func _draw_source_surface(cell: Vector2i, key: String, alpha: float) -> void:
    if not art.has(key):
        return
    var center := world_for(Vector2(cell))
    var size := Vector2(half_w * 2.0, half_h * 2.0)
    draw_texture_rect(art[key], Rect2(center - size * 0.5, size), false, Color(0.77, 0.93, 0.76, alpha))

func _draw_courtyard(start: Vector2i) -> void:
    if not art.has("base"):
        return
    var center := world_for(Vector2(start) + Vector2(0.5, 0.5))
    var size := Vector2(half_w * 4.0, half_h * 4.0)
    draw_texture_rect(art["base"], Rect2(center - size * 0.5, size), false, Color(0.66, 0.81, 0.70, 0.42))

func _road_neighbors(c: Vector2i) -> int:
    var count := 0
    for delta in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
        if c + delta in model.roads:
            count += 1
    return count

func _road_texture_key(c: Vector2i) -> String:
    var n := _road_neighbors(c)
    if n >= 3:
        return "junction" if n == 3 else "cross"
    if n <= 1:
        return "scatter" if posmod(c.x + c.y, 3) == 0 else "branch"
    var along_x: bool = (c + Vector2i(1, 0) in model.roads) and (c + Vector2i(-1, 0) in model.roads)
    var along_y: bool = (c + Vector2i(0, 1) in model.roads) and (c + Vector2i(0, -1) in model.roads)
    if along_x:
        return "axis_a"
    if along_y:
        return "axis_b"
    return "cross"

func _draw_roads() -> void:
    for c in model.roads:
        if model.occupied(c):
            continue
        var center := world_for(Vector2(c))
        _diamond(center, Color(0.55, 0.53, 0.40, 0.68))
        var key := _road_texture_key(c)
        if not art.has(key):
            continue
        var size := Vector2(half_w * 2.20, half_h * 2.30)
        draw_texture_rect(art[key], Rect2(center - size * 0.5, size), false, Color(0.91, 0.89, 0.78, 0.93))

func set_selection(id: String) -> void:
    selected_id = id
    queue_redraw()

func _draw_selection_overlay() -> void:
    if selected_id == "":
        return
    var b: Dictionary = model.get_building(selected_id)
    if b.is_empty():
        return
    for c in model.cells_for(b["kind"], b["origin"], b["orientation"]):
        var center := world_for(Vector2(c))
        _diamond(center, Color(0.94, 0.72, 0.34, 0.16))
    var door: Vector2i = model.doorway(b["kind"], b["origin"], b["orientation"])
    draw_circle(world_for(Vector2(door)), 4.5, Color(1.0, 0.86, 0.44, 0.95))
    draw_arc(world_for(Vector2(door)), 8.0, 0.0, TAU, 24, Color(1.0, 0.86, 0.44, 0.7), 1.3)
    draw_circle(world_for(Vector2(MapModel.SPAWN)), 4.5, Color(0.72, 0.94, 0.89))

func _draw_perimeter() -> void:
    var a := world_for(Vector2(-0.5, -0.5))
    var b := world_for(Vector2(MapModel.WIDTH - 0.5, -0.5))
    var c := world_for(Vector2(MapModel.WIDTH - 0.5, MapModel.HEIGHT - 0.5))
    var d := world_for(Vector2(-0.5, MapModel.HEIGHT - 0.5))
    for line in [[a, b], [b, c], [c, d], [d, a]]:
        draw_line(line[0], line[1], Color(0.57, 0.68, 0.49, 0.35), 2.0)

func _install_decorations() -> void:
    for item in DECOR_LAYOUT:
        var cell: Vector2i = item["cell"]
        if model.inside(cell) and (model.occupied(cell) or cell in model.roads):
            # No new occupancy authority: do not spawn on model-owned cells.
            continue
        var model_id: String = item["id"]
        var t: Texture2D = load(ART_DIR + "vegetation/" + model_id + ".png")
        expected_count += 1
        if t == null or t.get_width() <= 0 or t.get_height() <= 0:
            push_error("ENV01_DECOR_MISSING " + model_id)
            decor_layout_ok = false
            continue
        loaded_count += 1
        var sprite := Sprite2D.new()
        sprite.name = "SourceA_" + model_id + "_" + str(decoration_count)
        sprite.texture = t
        sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        sprite.centered = true
        var scale_factor: float = float(item["scale"])
        sprite.scale = Vector2(scale_factor, scale_factor)
        var foot := world_for(Vector2(cell))
        sprite.position = foot - Vector2(0.0, t.get_height() * scale_factor * 0.5 - 4.0)
        sprite.z_index = clampi(roundi(foot.y), -3000, 3000)
        add_child(sprite)
        decoration_anchors.append(cell)
        decoration_count += 1

func validate_existing_routes() -> bool:
    if model == null:
        return false
    for kind in ["main_hall", "warehouse", "forge"]:
        var route: Array[Vector2i] = model.path_to(kind, MapModel.SPAWN)
        if route.is_empty():
            return false
        for cell in route:
            if cell in decoration_anchors:
                return false
    return true