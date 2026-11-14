extends Control
## TRI-02 verified Source A building art with honest study art as a missing-source fallback.
## Read-only presentation: never assigns a portrait, state value, identity or gameplay reward.

const VIS08_ORIGINAL_BUILDINGS = preload("res://src/presentation/p3/tmb_original_building_art_v5.gd")
const VIS09_HANDPAINT = preload("res://src/presentation/p3/tmb_handpaint_building_art_v6.gd")
const LEGACY_ART = preload("res://src/presentation/uiux/sect_facility_illustration_v1.gd")
# Literal preloads guarantee fallback inclusion in Android/export resource packs.
const HALL_STUDY = preload("res://art/uiux/hall_paint_v2.svg")
const RESIDENCE_STUDY = preload("res://art/uiux/residence_paint_v2.svg")
const GUIDANCE_STUDY = preload("res://art/uiux/guidance_paint_v2.svg")
const CANDIDATE_STUDY = preload("res://art/uiux/candidate_neutral_v2.svg")
const SOURCE_A_BUILDINGS := {
    "hall": {"relative": "pv01_assets/main_hall/510052.png", "model": "510052"},
    "residence": {"relative": "pv01_assets/residence/510076.png", "model": "510076"},
    "guidance": {"relative": "pv01_assets/guidance/510111.png", "model": "510111"}
}

var facility_kind := "hall"
var _art: Texture2D
var _original_source := false
var _owner_approved := false
var _source_model_id := ""

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = true
    if custom_minimum_size == Vector2.ZERO:
        custom_minimum_size = Vector2(300, 155)
    # VIS-08 presents only independently authored art for the three real
    # TRI facility views; no fallback to historical Source A sprite bytes.
    _art = VIS08_ORIGINAL_BUILDINGS.texture_for(StringName(facility_kind))
    if facility_kind == "hall":
        var handpaint_hall := VIS09_HANDPAINT.texture_for(&"main_hall")
        if handpaint_hall != null:
            _art = handpaint_hall
    _owner_approved = false
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
    tooltip_text = "TMB VIS-09 · 2D handpainted · chưa nghiệm thu mỹ thuật Android" if facility_kind == "hall" else "TMB VIS-08 · artwork độc lập · chờ duyệt mỹ thuật trên bản đồ"
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    if _art == null or size.x < 2.0 or size.y < 2.0:
        return
    if _art != null and VIS08_ORIGINAL_BUILDINGS.texture_for(StringName(facility_kind)) != null:
        # Native PNGs keep full alpha and aspect; no cropped architecture.
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.115, 0.205, 0.205, 1.0))
        var source_size := Vector2(_art.get_width(), _art.get_height())
        var scale_value: float = minf(size.x * 0.92 / source_size.x, size.y * 0.92 / source_size.y)
        var fitted_size: Vector2 = source_size * scale_value
        draw_texture_rect(_art, Rect2((size - fitted_size) * 0.5, fitted_size), false)
    else:
        # Original vector study fallback is cropped, never distorted.
        var source_size := Vector2(_art.get_width(), _art.get_height())
        var scale_value: float = maxf(size.x / source_size.x, size.y / source_size.y)
        var fitted_size: Vector2 = source_size * scale_value
        draw_texture_rect(_art, Rect2((size - fitted_size) * 0.5, fitted_size), false)
        draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.035, 0.04, 0.22), true)
