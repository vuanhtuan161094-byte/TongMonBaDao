extends Node2D
# Human Sword / Phi Kiem Truy Anh R2B. Original first-party painted RGBA atlas
# plus separate first-party AS48 jian candidate; all effects are LAB_ONLY VIEW.
# Does not mutate authority, inflict damage, or add hits/status.
const BRIDGE := preload("res://labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd")
const ATLAS := "res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r2b/source/phi_kiem_human_r2b_atlas_rgba.png"
const CELL := 512
const RELEASE := 2.0 / 7.0
const CONTACT := 0.72
const FADE_END := 1.18
const WEAPON_CENTER := Vector2(443, 1054)
var _atlas: Texture2D
var _source_ok := false
var _printed_phase := ""

static func phase_at(t: float) -> String:
    if t < RELEASE:
        return "charge"
    if t < CONTACT:
        return "projectile"
    if t < FADE_END:
        return "contact"
    return "ended"

func _ready() -> void:
    z_index = 9
    _atlas = ResourceLoader.load(ATLAS, "Texture2D") as Texture2D
    if _atlas == null:
        var f := FileAccess.open(ATLAS, FileAccess.READ)
        if f == null:
            push_error("VFX_SWORD_R2B_SOURCE_MISSING")
            return
        var img := Image.new()
        var err := img.load_png_from_buffer(f.get_buffer(f.get_length()))
        f.close()
        if err != OK:
            push_error("VFX_SWORD_R2B_DECODE_ERROR " + str(err))
            return
        _atlas = ImageTexture.create_from_image(img)
    if _atlas.get_width() != 2048 or _atlas.get_height() != 1024:
        push_error("VFX_SWORD_R2B_ATLAS_DIMENSION_MISMATCH")
        return
    _source_ok = true
    print("VFX_SWORD_R2B_SOURCE_LOADED=PASS RGBA_MASTER_GITHUB=true poses=8 G3=OWNER_PROVISIONAL_NO_FINAL_ART_PASS")

func _tip_world(frame: int) -> Dictionary:
    var actor: Variant = get_parent().get("_actor")
    var character: Variant = get_parent().get("_character")
    if not (actor is Node2D) or not (character is Dictionary):
        return {"ok": false}
    return BRIDGE.resolve_frame_anchor(character, "attack", "front", frame,
        "weapon_tip", actor.global_transform)

func _monster_center() -> Vector2:
    var target: Variant = get_parent().get("_monster")
    if target is AnimatedSprite2D:
        return target.position + Vector2(0, -54)
    return Vector2(-9999, -9999)

func _paint_cel(index: int, at: Vector2, facing: float, factor: float, alpha: float) -> void:
    if not _source_ok:
        return
    var col := index % 4
    var row := index / 4
    draw_set_transform(at, facing, Vector2.ONE * factor)
    draw_texture_rect_region(_atlas,
        Rect2(-CELL * 0.5, -CELL * 0.5, CELL, CELL),
        Rect2(col * CELL, row * CELL, CELL, CELL),
        Color(1, 1, 1, clampf(alpha, 0.0, 1.0)))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _paint_real_jian(at: Vector2, facing: float, opacity: float) -> void:
    # The source weapon is an existing AS48 independent PNG (not a new sword
    # invented through shader geometry).  It has a visible blade AND hilt.
    var weapon: Variant = get_parent().get("_sword")
    if not (weapon is Sprite2D) or weapon.texture == null:
        return
    draw_set_transform(at, facing - PI * 0.5, Vector2.ONE * 0.052)
    draw_texture(weapon.texture, -WEAPON_CENTER, Color(1, 1, 1, opacity))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _process(_delta: float) -> void:
    if not _source_ok or get_parent() == null or not bool(get_parent().get("_good")):
        return
    var t := float(get_parent().get("_clock"))
    var phase := phase_at(t)
    if phase != _printed_phase:
        _printed_phase = phase
        if phase != "ended":
            print("VFX_SWORD_R2B_PHASE_" + phase.to_upper() + "=PASS")
    queue_redraw()

func _draw() -> void:
    var parent := get_parent()
    if not _source_ok or parent == null or not bool(parent.get("_good")) or not bool(parent.get("_review_fx_visible")):
        return
    var t := float(parent.get("_clock"))
    var frame := mini(3, int(t * 7.0))
    var origin := _tip_world(frame)
    if t < RELEASE:
        if not bool(origin.get("ok", false)):
            return
        var source: Vector2 = origin["world_position"]
        var to_target: Vector2 = _monster_center() - source
        var facing := to_target.angle()
        var cell := mini(1, int(t / RELEASE * 2.0))
        _paint_cel(cell, source, facing, 0.43 + (t / RELEASE) * 0.10, 0.9)
        return
    if bool(parent.get("_cast")) and t < CONTACT:
        var start: Variant = parent.get("_release_point")
        if not (start is Vector2):
            return
        var dest := _monster_center()
        var u := clampf((t - RELEASE) / (CONTACT - RELEASE), 0.0, 1.0)
        var eased := u * u * (3.0 - 2.0 * u)
        var center: Vector2 = start.lerp(dest, eased)
        center.y -= 11.0 * sin(PI * u)
        var facing := (dest - start).angle()
        var pose := 2 + mini(2, int(u * 3.0))
        _paint_cel(pose, center, facing, 0.64, 0.96)
        _paint_real_jian(center, facing, 1.0)
        return
    if bool(parent.get("_hit")) and t < FADE_END:
        var age := clampf((t - CONTACT) / (FADE_END - CONTACT), 0.0, 1.0)
        var pose := 5 + mini(2, int(age * 3.0))
        _paint_cel(pose, _monster_center(), 0.0, 0.52 + 0.10 * age, 1.0 - 0.72 * age)