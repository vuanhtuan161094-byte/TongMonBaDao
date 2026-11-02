extends Control
## TRI-01 visual V2. Read-only art renderer: Source A verified hall first,
## new original SVG study illustrations second, prior native vector fallback last.
## Never assigns a portrait, state value, asset identity or gameplay reward.

const SOURCE_A_GATE = preload("res://src/presentation/p3/sect_map25_source_art.gd")
const LEGACY_ART = preload("res://src/presentation/uiux/sect_facility_illustration_v1.gd")
# Literal preloads guarantee inclusion in Android/export resource packs.
const HALL_STUDY = preload("res://art/uiux/hall_paint_v2.svg")
const RESIDENCE_STUDY = preload("res://art/uiux/residence_paint_v2.svg")
const GUIDANCE_STUDY = preload("res://art/uiux/guidance_paint_v2.svg")
const CANDIDATE_STUDY = preload("res://art/uiux/candidate_neutral_v2.svg")
const SOURCE_HALL_ID := "pv01_assets/main_hall/510052.png"

var facility_kind := "hall"
var _art: Texture2D
var _original_source := false

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = true
    if custom_minimum_size == Vector2.ZERO:
        custom_minimum_size = Vector2(300, 155)
    if facility_kind == "hall":
        var gate = SOURCE_A_GATE.new()
        _art = gate.texture_for(SOURCE_HALL_ID)
        _original_source = _art != null
    if _art == null:
        match facility_kind:
            "residence":
                _art = RESIDENCE_STUDY
            "guidance":
                _art = GUIDANCE_STUDY
            "candidate":
                _art = CANDIDATE_STUDY
            _:
                _art = HALL_STUDY
    if _art == null:
        var legacy: Control = LEGACY_ART.new()
        legacy.name = "LegacyArtFallback"
        legacy.set("facility_kind", facility_kind)
        legacy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        add_child(legacy)
    tooltip_text = "Source A · SHA256 đã kiểm chứng" if _original_source else "Tranh minh họa V2 · không phải asset Source A"
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    if _art == null or size.x < 2.0 or size.y < 2.0:
        return
    if _original_source:
        # Real Source A building PNG is isolated on a shaded canvas. No stretching.
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.115, 0.205, 0.205, 1.0))
        var source_size := Vector2(_art.get_width(), _art.get_height())
        var scale_value: float = minf(size.x * 0.92 / source_size.x, size.y * 0.92 / source_size.y)
        var fitted_size: Vector2 = source_size * scale_value
        draw_texture_rect(_art, Rect2((size - fitted_size) * 0.5, fitted_size), false)
    else:
        # Illustration study is cropped, never distorted; the central subject
        # remains large enough in the narrow Dẫn Tiên candidate portrait slot.
        var source_size := Vector2(_art.get_width(), _art.get_height())
        var cover: float = maxf(size.x / source_size.x, size.y / source_size.y)
        var visible_size: Vector2 = size / cover
        var source_region := Rect2((source_size - visible_size) * 0.5, visible_size)
        draw_texture_rect_region(_art, Rect2(Vector2.ZERO, size), source_region)
