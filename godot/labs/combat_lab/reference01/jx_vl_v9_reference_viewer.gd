extends Control
## VFX-REF-01 | visual-only original JX1, Source VL, TMB V9 preview.
## Event-free, no damage/target/status/SaveService, no rigging.
const JX_ROOT := "res://assets/combat_v4/jx1_skill_fx/"
const VL_ROOT := "res://assets/combat_v4/source_vl/"
const V9 = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const LOOP := 5.60
const TRACKS := [
    {"label":"JX1 / NGU DOC #63","caption":"13 frames / 56 ms | impact ONLY","codes":["jx_wudu_63_impact"],"type":"jx"},
    {"label":"JX1 / VO DANG #158","caption":"10 precast + 17 cast + 8 impact | lab sequencing only","codes":["jx_wudang_158_precast","jx_wudang_158_cast","jx_wudang_158_impact"],"type":"jx"},
    {"label":"SOURCE VL / SWORD 150","caption":"36 cast + 21 hit | lab sequencing only","codes":["sword_cast","sword_hit"],"type":"vl"},
    {"label":"TMB V9 / ENERGY SERPENT","caption":"Original energy reference | not commercial JX footage","codes":[],"type":"v9"}
]
var clock := 0.0
var paused := false
var focused := -1
var _source: Dictionary = {}
var _issues: Array[String] = []

static func frame_index(age: float, frame_ms: float, total: int) -> int:
    if age < 0.0 or frame_ms <= 0.0 or total <= 0: return -1
    var index := int(floor(age * 1000.0 / frame_ms))
    return index if index < total else -1

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _load_manifest(JX_ROOT, "jx")
    _load_manifest(VL_ROOT, "vl")
    for track in TRACKS:
        for code in track["codes"]:
            if not _source.has(str(code)):
                _issues.append("MISSING VFX SOURCE: " + str(code))
    print("VFX_REF01_READY count=", _source.size(), " issues=", _issues.size())
    for issue in _issues: push_error(issue)
    set_process(true)
    queue_redraw()

func _load_manifest(root: String, collection: String) -> void:
    var path := root + "fx_manifest.json" if collection == "jx" else root + "vfx_manifest.json"
    if not FileAccess.file_exists(path):
        _issues.append("MISSING MANIFEST: " + path)
        return
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if not parsed is Dictionary:
        _issues.append("INVALID MANIFEST: " + path)
        return
    var entries: Dictionary = parsed.get("effects", {})
    for key in entries.keys():
        var row: Dictionary = entries[key]
        var asset_path := root + str(row.get("image", ""))
        var atlas := load(asset_path) as Texture2D
        if atlas == null:
            _issues.append("MISSING IMAGE: " + asset_path)
            continue
        var rects: Array = row.get("rects", [])
        var count := int(row.get("frames", 0))
        if rects.size() < count * 6:
            _issues.append("INCOMPLETE RECTS: " + str(key))
            continue
        _source[str(key)] = {"atlas": atlas, "rects": rects, "frames": count,
            "ms": float(row.get("frame_ms", 0)), "origin":collection}

func metadata(key: String) -> Dictionary:
    return _source.get(key, {})

func issues() -> Array[String]:
    return _issues.duplicate()

func _process(delta: float) -> void:
    if paused: return
    clock = fposmod(clock + maxf(0.0, delta), LOOP)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    match event.keycode:
        KEY_SPACE: clock = 0.0
        KEY_P: paused = not paused
        KEY_0, KEY_ESCAPE: focused = -1
        KEY_1: focused = 0
        KEY_2: focused = 1
        KEY_3: focused = 2
        KEY_4: focused = 3
    queue_redraw()

func _label(pos: Vector2, text_value: String, font_size: int, tint: Color) -> void:
    draw_string(ThemeDB.fallback_font, pos, text_value,
        HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, tint)

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("0b1119"))
    draw_rect(Rect2(0, 0, 1280, 78), Color("14212a"))
    _label(Vector2(24, 35), "JX1 / SOURCE VL / V9  |  AUTHENTIC SPRITE SOURCE COMPARISON", 23, Color("e3f2e8"))
    _label(Vector2(24, 61), "REAL FRAME RECTANGLES / NATIVE FRAME TIMINGS  |  REFERENCE LAB ONLY", 14, Color("91b3b2"))
    if focused == -1:
        _panel(0, Rect2(20, 92, 610, 258), false)
        _panel(1, Rect2(650, 92, 610, 258), false)
        _panel(2, Rect2(20, 369, 610, 269), false)
        _panel(3, Rect2(650, 369, 610, 269), false)
    else:
        _panel(focused, Rect2(24, 93, 1232, 545), true)
    if not _issues.is_empty():
        _label(Vector2(24, 663), "MISSING SOURCE FILES: " + str(_issues.size()), 15, Color("ff9999"))
    _label(Vector2(24, 690), "1-4: FOCUS  |  0: FOUR SOURCES  |  P: PAUSE  |  SPACE: REPLAY", 15, Color("b9cbd0"))
    _label(Vector2(1084, 690), "PVE OFF / LAB", 13, Color("a4cdb4"))

func _panel(which: int, box: Rect2, big: bool) -> void:
    var track: Dictionary = TRACKS[which]
    draw_rect(box, Color("1a2830"))
    draw_rect(box, Color("426166"), false, 1.3)
    _label(box.position + Vector2(17, 30), str(track["label"]), 19, Color("dcf5e4"))
    _label(box.position + Vector2(17, 54), str(track["caption"]), 13, Color("aec5c4"))
    var region := Rect2(box.position + Vector2(15, 69), box.size - Vector2(30, 84))
    draw_rect(region, Color("0e171e"))
    for i in range(3):
        var py := region.position.y + region.size.y * (0.32 + float(i) * 0.24)
        draw_line(Vector2(region.position.x, py), Vector2(region.end.x, py), Color("4d705e", 0.10), 1.0)
    if str(track["type"]) == "v9":
        _v9(region, big)
    else:
        _source_frames(track, region, big)
    _label(region.position + Vector2(10, region.size.y - 6), "CLOCK %0.2fs" % clock, 12, Color("80a8ab"))

func _source_frames(track: Dictionary, area: Rect2, big: bool) -> void:
    # Each authored clip runs in manifest time and is chained only in THIS lab;
    # the original JX game event sequence is not inferred.
    var age := fposmod(clock - 0.30 + LOOP, LOOP)
    var chosen := ""
    var within := 0.0
    for code in track["codes"]:
        var data: Dictionary = metadata(str(code))
        if data.is_empty(): continue
        var duration := float(data["frames"]) * float(data["ms"]) / 1000.0
        if age < duration:
            chosen = str(code)
            within = age
            break
        age -= duration
    if chosen.is_empty(): return
    var data: Dictionary = metadata(chosen)
    var frame := frame_index(within, float(data["ms"]), int(data["frames"]))
    if frame < 0: return
    var coords: Array = data["rects"]
    var off := frame * 6
    var rect := Rect2(float(coords[off]), float(coords[off+1]), float(coords[off+2]), float(coords[off+3]))
    if rect.size.x <= 2.0 or rect.size.y <= 2.0: return
    var pivot := Vector2(float(coords[off+4]), float(coords[off+5]))
    var zoom := 1.0
    match chosen:
        "jx_wudu_63_impact": zoom = 3.0 if big else 2.1
        "jx_wudang_158_precast": zoom = 1.25 if big else 0.84
        "jx_wudang_158_cast": zoom = 1.0 if big else 0.44
        "jx_wudang_158_impact": zoom = 1.6 if big else 1.2
        "sword_cast": zoom = 1.15 if big else 0.77
        "sword_hit": zoom = 1.55 if big else 1.15
    zoom = minf(zoom, minf((area.size.x - 38.0)/rect.size.x, (area.size.y - 46.0)/rect.size.y))
    var at := area.position + Vector2(area.size.x * 0.52, area.size.y * 0.66)
    draw_texture_rect_region(data["atlas"], Rect2(at - pivot * zoom, rect.size * zoom), rect, Color.WHITE)
    _label(area.position + Vector2(14, 20), "%s  |  %02d/%02d   %.0fms" % [
        chosen, frame + 1, int(data["frames"]), float(data["ms"])], 13, Color("b8f7d6"))

func _v9(area: Rect2, big: bool) -> void:
    var start := area.position + Vector2(area.size.x * 0.22, area.size.y * 0.60)
    var dest := area.position + Vector2(area.size.x * 0.80, area.size.y * 0.60)
    var phase := fposmod(clock, 2.50)
    var progress := clampf((phase - 0.43) / 1.48, 0.0, 1.0)
    if progress > 0.0 and progress < 1.0:
        V9.serpent_light(self, start, dest, progress, 1.1 if not big else 1.6, 1)
    elif phase >= 1.91 and phase < 2.41:
        V9.serpent_impact(self, dest, (phase - 1.91) / 0.50, 1.1 if not big else 1.6, 1)
    _label(area.position + Vector2(14, 21), "V9 original 2.50s timeline  |  not source JX", 13, Color("b8f7d6"))
