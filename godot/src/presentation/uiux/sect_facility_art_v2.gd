extends Control
## TRI-02 verified Source A building art with honest study art as a missing-source fallback.
## Read-only presentation: never assigns a portrait, state value, identity or gameplay reward.

const SOURCE_A_GATE = preload("res://src/presentation/p3/sect_map25_source_art.gd")
const VIS07_APPROVED = preload("res://src/presentation/p3/tmb_approved_building_art_v4.gd")
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
    # R4 Owner-approved Hall art; only fall back to SHA-gated Source A when
    # the separately published RGBA PNG cannot be imported from this commit.
    if facility_kind == "hall":
        _art = VIS07_APPROVED.texture_for(&"main_hall")
        _owner_approved = _art != null
    var source_spec: Dictionary = SOURCE_A_BUILDINGS.get(facility_kind, {}) if _art == null else {}
    if not source_spec.is_empty():
        var gate = SOURCE_A_GATE.new()
        _art = gate.texture_for(str(source_spec["relative"]))
        _original_source = _art != null
        if _original_source:
            _source_model_id = str(source_spec["model"])
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
    tooltip_text = (
        "Source A · Model %s · SHA-256 đã kiểm chứng" % _source_model_id
        if _original_source
        else ("TMB VIS-07 R4 · Owner-approved original art" if _owner_approved else "Tranh minh họa V2 · không phải asset Source A")
    )
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    if _art == null or size.x < 2.0 or size.y < 2.0:
        return
    if _original_source or _owner_approved:
        # Full independently authored Hall silhouette is displayed without crop.
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
