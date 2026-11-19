extends Node2D
# ISOLATED AS48 REAL-ASSET FRONT-ONLY BRIDGE PROOF.
# VFX shader is a LAB TECH CUE, NOT an Art-First G3 source or approved art.
# Events below are LAB_ONLY envelopes, NOT actual Combat V2 receipts.
const BASE := "res://labs/character_family/aschar_v9_batch1/"
const BRIDGE := preload("res://labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd")
const SWORD_SKILL := "tmb.skill.sword.ngu_kiem.active_01.human"
const ATLAS := BASE + "assets/atlases/AS48_attack_front_consistency_v2_atlas.png"
const WEAPON := BASE + "assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
const SOCKETS := BASE + "meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"
const BINDINGS := "res://labs/visual_bridge_v1/as48_sword_vfx_binding_lab.json"
const MONSTER := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const TECH_SHADER := "res://labs/combat_lab/combat_lab_v16_impact_glow.gdshader"
const FOOT := Vector2(200, 429)
const MAP_SCALE := 0.17
const POSE_FPS := 7.0
var _reader
var _sockets: Dictionary
var _bindings: Dictionary
var _character: Dictionary
var _cels: Array[AtlasTexture] = []
var _actor: Node2D
var _body: Sprite2D
var _sword: Sprite2D
var _monster: AnimatedSprite2D
var _raw_monster_atlases: Dictionary = {}
var _glow: ColorRect
var _flash: ColorRect
var _glow_mat: ShaderMaterial
var _flash_mat: ShaderMaterial
var _clock := 0.0
var _serial := 0
var _cast := false
var _hit := false
var _done := false
var _moving := true
var _good := false
var _review_paused := false
var _review_speed := 1.0
var _review_fx_visible := true
var _review_bright := false
var _review_zoomed := false
var _release_point := Vector2.ZERO
var _monster_home := Vector2(875, 573)

func _json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        push_error("AS48_SOURCE_MISSING " + path)
        return {}
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if raw is Dictionary:
        return raw
    push_error("AS48_INVALID_JSON " + path)
    return {}

# Existing AS48 candidate PNGs are not all registered as imported Texture2D
# by the outer Godot project. Decode original repository bytes directly, with
# no new PNG/asset export, crop, copy, or changes to owner/character sources.
func _raw_png_texture(path: String) -> Texture2D:
    # Read packaged raw source bytes (works in native filesystem AND Web .pck).
    # The CI Web preset includes explicit *.png without converting original art.
    var source := FileAccess.open(path, FileAccess.READ)
    if source == null:
        push_error("AS48_RAW_PNG_OPEN_FAIL " + path)
        return null
    var data := source.get_buffer(source.get_length())
    source.close()
    var source_image := Image.new()
    var status := source_image.load_png_from_buffer(data)
    if status != OK or source_image.is_empty():
        push_error("AS48_RAW_PNG_DECODE_FAIL " + path + " error=" + str(status))
        return null
    return ImageTexture.create_from_image(source_image)

func _raw_webp_texture(path: String) -> Texture2D:
    var source := FileAccess.open(path, FileAccess.READ)
    if source == null:
        push_error("VFX_REVIEW_RAW_MONSTER_ATLAS_MISSING " + path)
        return null
    var bytes := source.get_buffer(source.get_length())
    source.close()
    var image := Image.new()
    var status := image.load_webp_from_buffer(bytes)
    if status != OK or image.is_empty():
        push_error("VFX_REVIEW_RAW_MONSTER_ATLAS_DECODE_FAIL " + path + " " + str(status))
        return null
    return ImageTexture.create_from_image(image)

func _ready() -> void:
    _sockets = _json(SOCKETS)
    _bindings = _json(BINDINGS)
    if _sockets.is_empty() or _bindings.is_empty():
        return
    if str(_bindings.get("skill_id", "")) != SWORD_SKILL:
        push_error("AS48_WRONG_SKILL_BINDING")
        return
    var rows: Array = _sockets.get("body_frames", [])
    var family: Dictionary = _sockets.get("weapon_assets", {}).get("jian_silver_candidate", {})
    if rows.size() != 4 or family.is_empty():
        push_error("AS48_REAL_FRONT_FRAME_OR_SWORD_MISSING")
        return
    var tip: Array = family.get("asset_tip_px", [])
    var grip: Array = family.get("asset_grip_px", [])
    if tip.size() != 2 or grip.size() != 2:
        push_error("AS48_SOURCE_WEAPON_TIP_MISSING")
        return
    var d := (Vector2(float(tip[0]), float(tip[1])) - Vector2(float(grip[0]), float(grip[1]))) * float(family.get("asset_scale", 0.0))
    var anchors: Array = []
    for i in range(4):
        var row: Dictionary = rows[i]
        var hand_data: Dictionary = row.get("grip_sockets", {}).get("main_hand", {})
        var p: Array = hand_data.get("body_grip_px", [])
        if i != int(row.get("index", -1)) or p.size() != 2:
            push_error("AS48_GRIP_NOT_AUTHORED_%d" % i)
            return
        var hand := Vector2(float(p[0]), float(p[1]))
        var sword_tip := hand + d.rotated(deg_to_rad(float(hand_data.get("rotation_deg", 0.0))))
        anchors.append({"frame": i, "anchors": {
            "hand_r": [hand.x, hand.y], "weapon_grip": [hand.x, hand.y],
            "weapon_tip": [sword_tip.x, sword_tip.y]}})
    _character = {"schema": "tmb.character_anchors.v1", "source_kind": "CHARACTER_ONLY",
        "source_status": "CANDIDATE", "asset_id": "AS48_V9.3_Attack_Front",
        "canvas_px": [400, 440], "foot_px": [FOOT.x, FOOT.y],
        "clips": {"attack": {"front": anchors}}}
    # NO fabricated left/right/back clips. These remain unavailable in PR #72.
    var body_atlas := _raw_png_texture(ATLAS)
    var weapon_tex := _raw_png_texture(WEAPON)
    var monsters := load(MONSTER) as SpriteFrames
    var shader := load(TECH_SHADER) as Shader
    if body_atlas == null or weapon_tex == null or monsters == null or shader == null:
        push_error("AS48_REAL_ASSET_OR_TECH_CUE_NOT_LOADED")
        return
    if not monsters.has_animation(&"walk"):
        push_error("AS48_MONSTER_WALK_CLIP_MISSING")
        return
    for i in range(4):
        var cel := AtlasTexture.new()
        cel.atlas = body_atlas
        cel.region = Rect2(i * 400, 0, 400, 440)
        _cels.append(cel)
    _actor = Node2D.new()
    _actor.name = "ActualAS48"
    _actor.position = Vector2(342, 595)
    _actor.scale = Vector2.ONE * MAP_SCALE
    add_child(_actor)
    _sword = Sprite2D.new()
    _sword.name = "RealIndependentJian"
    _sword.texture = weapon_tex
    _sword.centered = false
    _sword.offset = -Vector2(float(grip[0]), float(grip[1]))
    _sword.z_index = 0
    _actor.add_child(_sword)
    _body = Sprite2D.new()
    _body.name = "RealAuthoredFourFrontCels"
    _body.centered = false
    _body.position = -FOOT
    _body.z_index = 1
    _actor.add_child(_body)
    _monster = AnimatedSprite2D.new()
    _monster.name = "ActualMovingMonster"
    _monster.sprite_frames = monsters
    _monster.offset = Vector2(0, -135)
    _monster.scale = Vector2.ONE * 0.43
    _monster.z_index = 4
    add_child(_monster)
    _monster.play(&"walk")
    # Use the original monster .webp source bytes for the Web canvas too.
    # Built by the Asset pipeline; never modified or replaced here.
    for idx in range(3):
        var path := "res://assets/actors/v5_sa_monster_1113031_1/atlas_%03d.webp" % idx
        var texture := _raw_webp_texture(path)
        if texture == null:
            push_error("VFX_REVIEW_MONSTER_SOURCE_REQUIRED")
            return
        _raw_monster_atlases[path] = texture
    # The review canvas draws original pixels explicitly after its background.
    # This avoids the blank actor+monster seen in the owner's web screenshot,
    # without using a surrogate character or duplicating any art file.
    _body.visible = false
    _sword.visible = false
    _monster.visible = false
    _glow_mat = ShaderMaterial.new()
    _glow_mat.shader = shader
    _flash_mat = ShaderMaterial.new()
    _flash_mat.shader = shader
    _glow = _light("SwordReleaseTechCue", Vector2(56, 56), _glow_mat)
    _flash = _light("MonsterMovingContactTechCue", Vector2(112, 112), _flash_mat)
    _reader = BRIDGE.new()
    _replay()
    _good = true
    print("BRIDGE_AS48_READY actor=AS48 true_pose_count=4 direction=FRONT_ONLY original_vfx=SOURCE_PENDING tech_cue_only=true")
    queue_redraw()

func _light(label: String, size_px: Vector2, material_fx: ShaderMaterial) -> ColorRect:
    var item := ColorRect.new()
    item.name = label
    item.size = size_px
    item.color = Color.WHITE
    item.material = material_fx
    item.mouse_filter = Control.MOUSE_FILTER_IGNORE
    item.z_index = 8
    add_child(item)
    item.visible = false
    return item

func _replay() -> void:
    _serial += 1
    _reader.begin_encounter("LAB_ONLY_AS48_%d" % _serial)
    _clock = 0.0
    _cast = false
    _hit = false
    _done = false
    _monster.position = _monster_home
    _glow.visible = false
    _flash.visible = false
    _pose(0)

func _pose(frame: int) -> void:
    _body.texture = _cels[frame]
    var record: Dictionary = _sockets["body_frames"][frame]["grip_sockets"]["main_hand"]
    var p: Array = record["body_grip_px"]
    _sword.position = Vector2(float(p[0]), float(p[1])) - FOOT
    _sword.rotation_degrees = float(record["rotation_deg"])
    _sword.scale = Vector2.ONE * 0.19

func _send(type_name: String, nonce: String, frame: int) -> bool:
    var event := {
        "type": type_name, "event_id": "LAB_ONLY_AS48_%d/%s" % [_serial, nonce],
        "encounter_id": "LAB_ONLY_AS48_%d" % _serial, "actor_id": "AS48",
        "target_id": "REAL_MONSTER_SPRITE", "skill_id": SWORD_SKILL}
    var route: Dictionary = _reader.route_authoritative_event(event, _bindings)
    if not bool(route.get("ok", false)):
        push_error("BRIDGE_AS48_EVENT_FAIL " + str(route.get("reason", "")))
        return false
    var emissions: Array = route["emissions"]
    if emissions.size() != 1:
        push_error("BRIDGE_AS48_EVENT_COUNT_FAIL")
        return false
    var one: Dictionary = emissions[0]
    var resolved: Dictionary = BRIDGE.resolve_frame_anchor(
        _character, "attack", "front", frame, str(one["caster_slot"]), _actor.global_transform)
    if not bool(resolved.get("ok", false)):
        push_error("BRIDGE_AS48_ANCHOR_MISSING " + str(resolved.get("reason", "")))
        return false
    if type_name == "skill_cast":
        _release_point = resolved["world_position"]
        print("BRIDGE_AS48_ANCHOR_CAST=PASS frame=%d source=REAL_AS48_V9.3" % frame)
    elif type_name == "hit":
        print("BRIDGE_AS48_ANCHOR_CONTACT=PASS target=ACTUAL_MOVING_MONSTER source=LAB_ONLY")
        var replay: Dictionary = _reader.route_authoritative_event(event, _bindings)
        if bool(replay.get("ok", true)) or str(replay.get("reason", "")) != "duplicate_event_id":
            push_error("BRIDGE_AS48_DEDUPE_FAIL")
            return false
        print("BRIDGE_AS48_DUPLICATE_DROPPED=PASS")
    return true

func _process(delta: float) -> void:
    if not _good or _review_paused:
        return
    _clock += minf(delta, 0.06) * _review_speed
    var frame := mini(3, int(_clock * POSE_FPS))
    _pose(frame)
    if _moving:
        _monster.position = _monster_home + Vector2(64.0 * sin(_clock * 1.27), 9.0 * sin(_clock * 1.62))
    if not _cast and _clock >= 2.0 / POSE_FPS:
        _cast = _send("skill_cast", "cast_1", 2)
    if not _hit and _clock >= 0.72:
        _hit = _send("hit", "hit_1", 3)
    _glow.visible = _review_fx_visible and _cast and _clock < 0.76
    if _glow.visible:
        var p: Dictionary = BRIDGE.resolve_frame_anchor(
            _character, "attack", "front", frame, "weapon_tip", _actor.global_transform)
        if bool(p.get("ok", false)):
            _release_point = p["world_position"]
        _glow.position = _release_point - _glow.size * 0.5
        _glow_mat.set_shader_parameter("event_age", clampf((_clock - 0.29) / 0.5, 0.0, 1.0))
        _glow_mat.set_shader_parameter("power", 0.48)
    _flash.visible = _review_fx_visible and _hit and _clock < 1.45
    if _flash.visible:
        # LAB estimated monster chest target from actual moving art, NOT canonical gameplay geometry.
        _flash.position = _monster.position + Vector2(0, -54) - _flash.size * 0.5
        _flash_mat.set_shader_parameter("event_age", clampf((_clock - 0.72) / 0.73, 0.0, 1.0))
        _flash_mat.set_shader_parameter("power", 0.74)
    if not _done and _clock >= 2.8:
        _done = true
        if _cast and _hit and (not _moving or _monster.position.distance_to(_monster_home) > 1.0):
            if _moving:
                print("BRIDGE_AS48_TARGET_MOVING=PASS")
            else:
                print("BRIDGE_AS48_TARGET_STATIONARY=PASS")
            print("BRIDGE_AS48_END=PASS front_only=true G3=SOURCE_PENDING native_movie_is_not_device_fps=true")
        else:
            push_error("BRIDGE_AS48_END=FAIL")
    queue_redraw()


# Browser/manual VFX review surface: no scene replication or gameplay writes.
func review_replay() -> void:
    if _good:
        _replay()

func review_set_paused(value: bool) -> void:
    _review_paused = value
    if _monster != null:
        _monster.speed_scale = 0.0 if value else _review_speed

func review_set_moving(value: bool) -> void:
    _moving = value

func review_set_fx(value: bool) -> void:
    _review_fx_visible = value
    if not value:
        _glow.visible = false
        _flash.visible = false

func review_set_bright(value: bool) -> void:
    _review_bright = value
    queue_redraw()

func review_set_map_zoom(value: bool) -> void:
    _review_zoomed = value
    if _actor != null:
        _actor.scale = Vector2.ONE * (MAP_SCALE * 2.0 if value else MAP_SCALE)

func review_set_speed(value: float) -> void:
    _review_speed = clampf(value, 0.25, 2.0)
    if _monster != null:
        _monster.speed_scale = 0.0 if _review_paused else _review_speed

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var key := event as InputEventKey
    if not key.pressed or key.echo or not _good:
        return
    if key.keycode == KEY_SPACE:
        _replay()
    elif key.keycode == KEY_M:
        _moving = not _moving

func _draw_original_actor_and_monster() -> void:
    if not _good or _body == null or _sword == null or _monster == null:
        return
    # Overlay order: physical jian BEHIND AS48 authored cel; VFX in z=8.
    var map_scale := _actor.scale.x
    draw_set_transform(_actor.position + _sword.position * map_scale,
        _sword.rotation, Vector2.ONE * map_scale * _sword.scale.x)
    draw_texture(_sword.texture, _sword.offset)
    draw_set_transform(_actor.position, 0.0, _actor.scale)
    var pose := mini(3, int(_clock * POSE_FPS))
    var cel: AtlasTexture = _cels[pose]
    draw_texture_rect_region(cel.atlas,
        Rect2(-FOOT, Vector2(400, 440)), cel.region)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

    # Same monster SpriteFrames frame/UVs, but decode the genuine original WebP
    # bytes from PCK explicitly (Web export may omit imported atlas textures).
    var frames: SpriteFrames = _monster.sprite_frames
    var count := frames.get_frame_count(&"walk")
    if count <= 0:
        return
    var fps := frames.get_animation_speed(&"walk")
    var index := int(floor(_clock * fps)) % count
    var tex: Texture2D = frames.get_frame_texture(&"walk", index)
    var atlas := tex as AtlasTexture
    if atlas == null:
        draw_set_transform(_monster.position, 0.0, _monster.scale)
        draw_texture(tex, -tex.get_size() * 0.5 + _monster.offset)
        draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
        return
    var original_atlas := atlas.atlas
    var raw_path := original_atlas.resource_path
    if _raw_monster_atlases.has(raw_path):
        original_atlas = _raw_monster_atlases[raw_path]
    var size := atlas.region.size
    draw_set_transform(_monster.position, 0.0, _monster.scale)
    draw_texture_rect_region(original_atlas,
        Rect2(-size * 0.5 + _monster.offset, size), atlas.region)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("d9e6ed") if _review_bright else Color("17212b"))
    draw_rect(Rect2(0, 420, 1280, 300), Color("b2baae") if _review_bright else Color("383e3c"))
    draw_rect(Rect2(0, 496, 1280, 6), Color("869b8d") if _review_bright else Color("59665b"))
    draw_line(Vector2(80, 604), Vector2(1200, 604), Color("737f75"), 1.0)
    _draw_original_actor_and_monster()
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(24, 42), "AS48 KIEM TU HUMAN - PHI KIEM TRUY ANH - VISUAL EVENT BRIDGE LAB",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("163247") if _review_bright else Color("e7f3fa"))
    draw_string(font, Vector2(24, 68), "FOUR REAL FRONT POSES + SEPARATE JIAN - MAP SIZE 1X - VFX TECH CUE ONLY",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("643d17") if _review_bright else Color("f4cf90"))
    draw_string(font, Vector2(24, 94), "SYNTHETIC LAB EVENTS - NO HP/STATUS - SPACE REPLAY - M MOVE",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("304d63") if _review_bright else Color("bed2e0"))
    draw_string(font, Vector2(24, 682), "G3 SOURCE PENDING - OTHER THREE DIRECTIONS PENDING - OWNER ART PENDING - PVE HOLD",
        HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("68472c") if _review_bright else Color("f0d7b9"))
