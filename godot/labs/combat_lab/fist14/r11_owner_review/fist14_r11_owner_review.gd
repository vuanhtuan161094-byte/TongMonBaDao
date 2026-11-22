extends Node2D
## Isolated Art-First LAB for the exact owner-approved FIST14 R11 animated GIF.
## Technical review only. No Combat V2/SaveService/PvE or real mark receipts.
## The existing real Godot character below is a SCALE STAND-IN (NU DOC TU),
## NOT the final Quyen Tu character. Do not use as official character artwork.

const SKILL_ID := "tmb.skill.fist.huyet_quyen.active_04.human"
const EFFECT := "mark"
const ELEMENT := "nether"
const TARGET_LIMIT := 1
const CAST_DURATION := 0.45
const MARK_DURATION := 6.0
const PROJECTILE_SPEED := 0.0
const CONTACT := 0.94  # LAB ONLY, not authoritative Combat V2 receipt
const MARK_END := CONTACT + MARK_DURATION
const FADE_END := MARK_END + 0.28
const LOOP_END := FADE_END + 0.36
const SIZE := 309.0
const SHAPE := "single_target"
const COOLDOWN := 8.0
const DECLARED_RANGE := 2.8
const DECLARED_RADIUS := 0.0
const FRAME_COUNT := 16
const ATLAS_PATH := "res://labs/combat_lab/fist14/r11_owner_review/assets/fist14_r11_rgba_atlas_4x4.png"
const TEMP_ACTOR_PATH := "res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png"
const REAL_MONSTER_PATH := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"

var _atlas: Texture2D
var _actor: Texture2D
var _monster: SpriteFrames
var _clock := 0.0
var _review_paused := false
var _moving := true
var _fx_visible := true
var _bright := false
var _zoom2x := false
var _speed := 1.0
var _ready_to_draw := false

func _ready() -> void:
    # References are deliberately read-only. Avoid changing any canonical assets.
    _atlas = load(ATLAS_PATH) as Texture2D
    _actor = load(TEMP_ACTOR_PATH) as Texture2D
    _monster = load(REAL_MONSTER_PATH) as SpriteFrames
    if _atlas == null or _actor == null or _monster == null:
        push_error("FIST14_R11_SOURCE_OR_EXISTING_ACTOR_MISSING")
        return
    if _atlas.get_width() != 4 * int(SIZE) or _atlas.get_height() != 4 * int(SIZE):
        push_error("FIST14_R11_RGBA_ATLAS_INVALID")
        return
    if not _monster.has_animation(&"walk") or _monster.get_frame_count(&"walk") <= 0:
        push_error("FIST14_R11_REAL_MONSTER_WALK_MISSING")
        return
    _ready_to_draw = true
    set_process(true)
    print("FIST14_R11_GODOT_LAB_READY skill=", SKILL_ID,
        " owner=GIF_ONLY actor=EXISTING_TEMP_STANDIN monster=REAL_WALK",
        " projectile_speed=0 target_limit=1 native_approval=PENDING PvE=HOLD")
    queue_redraw()

func _process(delta: float) -> void:
    if not _ready_to_draw or _review_paused:
        return
    _clock += minf(delta, 0.07) * _speed
    if _clock > LOOP_END:
        _clock = 0.0
    queue_redraw()

func _caster_at(t: float) -> Vector2:
    # DEMONSTRATION position; not Combat V2 character movement authority.
    return Vector2(545.0 + 8.0 * sin(t * 1.3), 572.0)

func _target_at(t: float) -> Vector2:
    if not _moving:
        return Vector2(758.0, 572.0)
    return Vector2(758.0 + 32.0 * sin(t * 1.45), 572.0 + 4.0 * sin(t * 2.1))

func _chest_at(t: float) -> Vector2:
    return _target_at(t) + Vector2(-13.0, -75.0)

func _phase_progress(t: float) -> float:
    # 16 DISTINCT illustrated poses, no frame interpolation by drawing new art.
    # Two neighboring original RGBA poses are only alpha-crossfaded for timing.
    if t < CAST_DURATION:
        return clampf(t / CAST_DURATION, 0.0, 1.0) * 3.0
    if t < CONTACT:
        return 4.0 + clampf((t - CAST_DURATION) / (CONTACT - CAST_DURATION), 0.0, 1.0) * 6.0
    if t < 1.30:
        return 10.0 + clampf((t - CONTACT) / 0.36, 0.0, 1.0) * 4.0
    return 14.0 + clampf((t - 1.30) / 0.23, 0.0, 1.0)

func _draw_pose(index: int, center: Vector2, diameter: float, alpha: float) -> void:
    if alpha <= 0.002 or _atlas == null:
        return
    var cell := clampi(index, 0, FRAME_COUNT - 1)
    var rect := Rect2(Vector2(float(cell % 4) * SIZE, float(int(cell / 4)) * SIZE), Vector2(SIZE, SIZE))
    # Deliberately small relative to real 1x actor/monster; not a full-screen spell.
    draw_texture_rect_region(_atlas,
        Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter),
        rect, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))

func _draw_owner_vfx(t: float) -> void:
    if not _fx_visible or t >= 1.55:
        return
    var progress := clampf(_phase_progress(t), 0.0, 15.0)
    var lo := clampi(int(floor(progress)), 0, 15)
    var hi := mini(lo + 1, 15)
    var blend := smoothstep(0.0, 1.0, progress - float(lo))
    var caster := _caster_at(t)
    var target := _chest_at(t)
    var center := (caster + Vector2(47.0, -95.0)).lerp(
        target + Vector2(-92.0, -4.0), smoothstep(0.30, 0.90, t))
    # No independent projectile entity, homing VFX, or fake multiple hits.
    var opacity := smoothstep(0.0, 0.11, t) * (1.0 - smoothstep(1.30, 1.53, t))
    var diameter := 210.0 if not _zoom2x else 280.0
    _draw_pose(lo, center, diameter, opacity * (1.0 - blend))
    if hi != lo:
        _draw_pose(hi, center, diameter, opacity * blend)

func _draw_mark(t: float) -> void:
    # THREE meridian streaks = exactly ONE cosmetic mark (6 sec).
    # This supplementary LAB cue is NOT part of the GIF's approved art and
    # does NOT apply damage/DoT/stun, and has no real Combat receipt.
    if not _fx_visible or t < CONTACT or t > FADE_END:
        return
    var opacity := (smoothstep(CONTACT, CONTACT + 0.08, t) *
        (1.0 - smoothstep(MARK_END, FADE_END, t)))
    var center := _chest_at(t) + Vector2(10, 10)
    for i in range(3):
        var shift := Vector2((float(i) - 1.0) * 12.0, 0)
        var begin := center + shift + Vector2(-7.0, -15.0)
        var ending := center + shift + Vector2(7.0, 13.0)
        draw_line(begin, ending, Color(0.58, 0.02, 0.12, 0.74 * opacity), 6.0)
        draw_line(begin, ending, Color(1.0, 0.59, 0.40, 0.94 * opacity), 2.0)

func _draw_existing_actor(t: float) -> void:
    var foot := _caster_at(t)
    draw_texture_rect_region(_actor,
        Rect2(foot - Vector2(69.0, 155.0), Vector2(138.0, 169.0)),
        Rect2(0, 0, 320, 384))

func _draw_real_walk_monster(t: float) -> void:
    var count := _monster.get_frame_count(&"walk")
    var idx := int(floor(t * 12.0)) % count
    var texture := _monster.get_frame_texture(&"walk", idx)
    if texture != null:
        var foot := _target_at(t)
        draw_texture_rect(texture,
            Rect2(foot - Vector2(69.0, 136.0), Vector2(138.0, 135.0)), false)

func _draw() -> void:
    var dark_bg := Color("17222c")
    var light_bg := Color("d8e6eb")
    draw_rect(Rect2(0, 0, 1280, 720), light_bg if _bright else dark_bg)
    draw_rect(Rect2(0, 405, 1280, 315), Color("bcc6b4") if _bright else Color("353e3a"))
    draw_line(Vector2(0, 573), Vector2(1280, 573),
        Color("879b8d") if _bright else Color("54655e"), 2.0)
    if not _ready_to_draw:
        return
    _draw_existing_actor(_clock)
    _draw_real_walk_monster(_clock)
    _draw_owner_vfx(_clock)
    _draw_mark(_clock)
    var font := ThemeDB.fallback_font
    var ink := Color("173040") if _bright else Color("edf5f9")
    var note := Color("674622") if _bright else Color("f9d09b")
    draw_string(font, Vector2(28, 40), "FIST14 R11 — OWNER-APPROVED GIF / ISOLATED GODOT LAB",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 18, ink)
    draw_string(font, Vector2(28, 69), "ONE TARGET • 0.45s CAST • ONE 6s MARK • NO PROJECTILE",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, note)
    draw_string(font, Vector2(28, 97), "TEMP CHARACTER = EXISTING NU DOC TU / ACTUAL MONSTER WALK",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 14, note)
    draw_string(font, Vector2(28, 684), "LAB SYNTHETIC TIMING • G3 APPROVED GIF • NATIVE/PvE NOT APPROVED",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 14, note)

# Canonical /vfx/ review contract (when staged and native QA is complete).
func review_replay() -> void:
    _clock = 0.0
    _review_paused = false
    queue_redraw()

func review_seek_phase(phase: String) -> void:
    match phase:
        "charge": _clock = 0.21
        "projectile", "release": _clock = 0.63  # UI alias; no actual projectile
        "contact": _clock = 0.97
        "mark": _clock = 2.50
        "fade": _clock = 7.08
        _: return
    _review_paused = true
    queue_redraw()

func review_set_paused(value: bool) -> void:
    _review_paused = value

func review_set_moving(value: bool) -> void:
    _moving = value
    queue_redraw()

func review_set_fx(value: bool) -> void:
    _fx_visible = value
    queue_redraw()

func review_set_bright(value: bool) -> void:
    _bright = value
    queue_redraw()

func review_set_map_zoom(value: bool) -> void:
    _zoom2x = value
    queue_redraw()

func review_set_speed(value: float) -> void:
    _speed = clampf(value, 0.25, 2.0)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_SPACE:
            review_replay()
        elif event.keycode == KEY_P:
            review_set_paused(not _review_paused)
        elif event.keycode == KEY_B:
            review_set_bright(not _bright)
