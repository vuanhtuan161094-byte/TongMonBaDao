extends Node2D
# Human Sword / Phi Kiem Truy Anh — FIRST-PARTY 12-cel RGBA R1 candidate.
# Source disclosure: code-painted raster, G3 owner ART_PENDING (not hand-illustrated).
# LAB_ONLY: NEVER creates a hit, status, damage, target or PvE event.
const BRIDGE := preload("res://labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd")
const SOURCE := "res://labs/combat_lab/sword_human_phi_kiem_truy_anh/r1/source/phi_kiem_human_r1_candidate_atlas.png"
const WIDTH := 160
const HEIGHT := 160
const RELEASE := 2.0 / 7.0
const CONTACT := 0.72
const CONTACT_END := 1.18
var _source_texture: Texture2D
var _source_ok := false
var _printed_phase := ""

func _ready() -> void:
    z_index = 9
    # Explicitly decode RGBA bytes so the same source works in Godot native
    # and the no-threads Web export PCK. No generated shaders as core source.
    var file := FileAccess.open(SOURCE, FileAccess.READ)
    if file == null:
        push_error("VFX_SWORD_R1_SOURCE_PNG_MISSING")
        return
    var data := file.get_buffer(file.get_length())
    file.close()
    var image := Image.new()
    var status := image.load_png_from_buffer(data)
    if status != OK or image.get_size() != Vector2i(640, 480):
        push_error("VFX_SWORD_R1_SOURCE_INVALID_RGBA_ATLAS")
        return
    if image.get_format() != Image.FORMAT_RGBA8:
        image.convert(Image.FORMAT_RGBA8)
    # Validate original atlas actually contains painted alpha in each row.
    var row_alpha_counts: Array[int] = []
    for row in range(3):
        var count := 0
        for y in range(row * HEIGHT, (row + 1) * HEIGHT, 2):
            for x in range(0, 640, 2):
                if image.get_pixel(x, y).a > 0.02:
                    count += 1
        row_alpha_counts.append(count)
    print("VFX_SWORD_R1_ALPHA_PIXELS_CHARGE=", row_alpha_counts[0],
        " FLIGHT=", row_alpha_counts[1],
        " CONTACT=", row_alpha_counts[2])
    if row_alpha_counts[0] < 10 or row_alpha_counts[1] < 10 or row_alpha_counts[2] < 10:
        push_error("VFX_SWORD_R1_EMPTY_SOURCE_ROW")
        return
    _source_texture = ImageTexture.create_from_image(image)
    _source_ok = _source_texture != null
    if _source_ok:
        print("VFX_SWORD_R1_SOURCE_LOADED=PASS 640x480 cels=12 alpha=RGBA source=CODE_PAINTED_CANDIDATE G3=ART_PENDING")

func _frame(phase: int, index: int, pos: Vector2, scale_factor: float, angle: float, opacity: float) -> void:
    if not _source_ok:
        return
    draw_set_transform(pos, angle, Vector2.ONE * scale_factor)
    var from := Rect2(float(index * WIDTH), float(phase * HEIGHT), float(WIDTH), float(HEIGHT))
    draw_texture_rect_region(_source_texture,
        Rect2(Vector2(-WIDTH * 0.5, -HEIGHT * 0.5), Vector2(WIDTH, HEIGHT)),
        from, Color(1.0, 1.0, 1.0, clampf(opacity, 0.0, 1.0)))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _tip_world(clip_index: int) -> Dictionary:
    var p := get_parent()
    if p == null:
        return {"ok": false}
    var actor: Variant = p.get("_actor")
    var manifest: Variant = p.get("_character")
    if not (actor is Node2D) or not (manifest is Dictionary):
        return {"ok": false}
    return BRIDGE.resolve_frame_anchor(manifest, "attack", "front", clip_index,
        "weapon_tip", actor.global_transform)

func _monster_center() -> Vector2:
    var target: Variant = get_parent().get("_monster")
    if target is AnimatedSprite2D:
        # Target uses the actual moving sprite location, not a stationary mock.
        return target.position + Vector2(0, -54)
    return Vector2(-1000, -1000)

func _process(_delta: float) -> void:
    if not _source_ok:
        return
    var parent := get_parent()
    if parent == null or not bool(parent.get("_good")):
        return
    if bool(parent.get("_review_paused")):
        return
    var clock := float(parent.get("_clock"))
    var phase := ""
    if clock < RELEASE:
        phase = "charge"
    elif bool(parent.get("_cast")) and clock < CONTACT:
        phase = "projectile"
    elif bool(parent.get("_hit")) and clock < CONTACT_END:
        phase = "contact"
    else:
        phase = "ended"
    if _printed_phase != phase:
        _printed_phase = phase
        if phase != "ended":
            print("VFX_SWORD_R1_PHASE_" + phase.to_upper() + "=PASS")
    queue_redraw()

func _draw() -> void:
    if not _source_ok:
        return
    var parent := get_parent()
    if parent == null or not bool(parent.get("_good")) or not bool(parent.get("_review_fx_visible")):
        return
    var t := float(parent.get("_clock"))
    var frame := mini(3, maxi(0, int(t * 7.0)))
    var origin := _tip_world(frame)
    if t < RELEASE:
        if not bool(origin.get("ok", false)):
            return
        var p: Vector2 = origin["world_position"]
        var cell := mini(3, int(t / RELEASE * 4.0))
        _frame(0, cell, p, .84 + .19 * (t / RELEASE), -0.24, 0.94)
        return
    if bool(parent.get("_cast")) and t < CONTACT:
        var source: Variant = parent.get("_release_point")
        if not (source is Vector2):
            return
        var start: Vector2 = source
        var end := _monster_center()
        var u := clampf((t - RELEASE) / (CONTACT - RELEASE), 0.0, 1.0)
        # An easing curve makes ONE identifiable sword blade, not 3 gameplay hits.
        var a := u * u * (3.0 - 2.0 * u)
        var point := start.lerp(end, a)
        point.y -= 15.0 * sin(PI * u)
        var rot := (end - start).angle()
        var cel := mini(3, int(u * 4.0))
        # R1 blade source is thin; overlap genuine authored RGBA poses for
        # legibility in a 1280x720 Web canvas. No generated vector substitute.
        # Slight subpixel offsets give a white-hot core + blue translucent halo.
        for pass_index in range(4):
            var offset := Vector2(0.0, (float(pass_index) - 1.5) * 0.75)
            _frame(1, cel, point + offset, 1.80 + .26 * sin(PI * u), rot, 1.0)
        return
    if bool(parent.get("_hit")) and t < CONTACT_END:
        var contact := _monster_center()
        var age := clampf((t - CONTACT) / (CONTACT_END - CONTACT), 0.0, 1.0)
        var cel := mini(3, int(age * 4.0))
        _frame(2, cel, contact, 1.12 + .38 * age, 0.0, 1.0 - .70 * age)
