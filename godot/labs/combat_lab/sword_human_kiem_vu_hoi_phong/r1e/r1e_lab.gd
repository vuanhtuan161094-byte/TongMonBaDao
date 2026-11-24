extends Node2D
## Kiếm Vũ Hồi Phong / Nhân R1E — isolated AS48 + moving real monsters.
## VFX-only approved source; NO combat receipts, SaveService, HP or PvE.
## Original AS48 Front attack cels and socket metadata; no puppet or rig.
const ROOT := "res://labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/source/"
const VFX := ROOT + "KVHP_R1E_VFX_only_atlas_4x3_RGBA.png"
const V2_VFX := "res://labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/v2_source/R1E_V2_24_atlas_4x6_RGBA.png"
const V2_MANIFEST := "res://labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/v2_source/R1E_V2_SOURCE_MANIFEST.json"
const V2_FPS := 25.0
const V2_COUNT := 24
const V2_DURATION := 0.96
const V2_RELEASE := 0.24
const V2_CONTACT := 0.72
const AS48 := "res://labs/character_family/aschar_v9_batch1/"
const ACTOR_SHEET := AS48 + "assets/atlases/AS48_attack_front_consistency_v2_atlas.png"
const JIAN := AS48 + "assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
const SOCKETS := AS48 + "meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"
const MOB := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const SKILL_ID := "tmb.skill.sword.ngu_kiem.active_02.human"
const FOOT := Vector2(200, 429)
const FRAME_STARTS := [0.00, 0.12, 0.24, 0.36, 0.45, 0.54, 0.63, 0.72, 0.82, 0.96, 1.12, 1.30]
const REVIEW_DURATION := 1.54
const RELEASE_START := 0.36
const CONTACT_START := 0.96
const FX_1X := 174.0 / 512.0
const MOB_HOMES := [Vector2(766, 563), Vector2(873, 552), Vector2(970, 580)]

var _actor: Node2D
var _body: Sprite2D
var _sword: Sprite2D
var _fx: Sprite2D
var _fx_glow: Sprite2D
var _fx_cell: AtlasTexture
var _legacy_vfx_texture: Texture2D
var _v2_vfx_texture: Texture2D
var _version_v2 := true
var _as48_texture: Texture2D
var _weapon_texture: Texture2D
var _socket_rows: Array = []
var _weapon_grip := Vector2.ZERO
var _weapon_tip_px := Vector2.ZERO
var _monsters: Array[AnimatedSprite2D] = []
var _time := 0.0
var _frame := -1
var _ready_ok := false
var _paused := false
var _moving := true
var _fx_enabled := true
var _bright := false
var _zoom := false
var _speed := 1.0
var _visual_contacts := 0
var _contact_shown := false

func _raw_png_texture(location: String) -> Texture2D:
    if ResourceLoader.exists(location):
        var res := ResourceLoader.load(location) as Texture2D
        if res != null:
            return res
    var bytes := FileAccess.get_file_as_bytes(location)
    if bytes.is_empty():
        push_error("R1E_MISSING_PNG " + location)
        return null
    var im := Image.new()
    if im.load_png_from_buffer(bytes) != OK:
        push_error("R1E_PNG_DECODE_FAIL " + location)
        return null
    return ImageTexture.create_from_image(im)

func _ready() -> void:
    _as48_texture = _raw_png_texture(ACTOR_SHEET)
    _weapon_texture = _raw_png_texture(JIAN)
    _legacy_vfx_texture = _raw_png_texture(VFX)
    _v2_vfx_texture = _raw_png_texture(V2_VFX)
    if _as48_texture == null or _weapon_texture == null or _legacy_vfx_texture == null or _v2_vfx_texture == null:
        return
    if _legacy_vfx_texture.get_size() != Vector2(2048,1536):
        push_error("R1E_ATLAS_INVALID_SIZE")
        return
    if _v2_vfx_texture.get_size() != Vector2(2048,3072):
        push_error("R1E_V2_ATLAS_INVALID_SIZE")
        return
    if not FileAccess.file_exists(V2_MANIFEST):
        push_error("R1E_V2_MANIFEST_MISSING")
        return
    var v2_meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(V2_MANIFEST))
    if not (v2_meta is Dictionary) or int(v2_meta.get("total_preview_samples",0)) != V2_COUNT:
        push_error("R1E_V2_MANIFEST_INVALID")
        return
    if not FileAccess.file_exists(SOCKETS):
        push_error("R1E_SOCKETS_MISSING")
        return
    var metadata: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOCKETS))
    if not (metadata is Dictionary):
        push_error("R1E_SOCKETS_INVALID_JSON")
        return
    _socket_rows = metadata.get("body_frames", [])
    var jian: Dictionary = metadata.get("weapon_assets", {}).get("jian_silver_candidate", {})
    var grip: Array = jian.get("asset_grip_px", [])
    var tip: Array = jian.get("asset_tip_px", [])
    if _socket_rows.size() != 4 or grip.size() != 2 or tip.size() != 2:
        push_error("R1E_FRONT_SOCKETS_MISSING")
        return
    _weapon_grip = Vector2(float(grip[0]), float(grip[1]))
    _weapon_tip_px = Vector2(float(tip[0]),float(tip[1]))
    var monster_frames := load(MOB) as SpriteFrames
    if monster_frames == null or not monster_frames.has_animation(&"walk"):
        push_error("R1E_REAL_MONSTER_MISSING")
        return
    _actor = Node2D.new()
    _actor.name = "OriginalAS48FrontAttackNoRig"
    _actor.position = Vector2(332, 582)
    _actor.scale = Vector2.ONE * 0.17
    _actor.z_index = 6
    add_child(_actor)
    _sword = Sprite2D.new()
    _sword.name = "OriginalAS48IndependentSword"
    _sword.texture = _weapon_texture
    _sword.centered = false
    _sword.offset = -_weapon_grip
    _sword.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _actor.add_child(_sword)
    _body = Sprite2D.new()
    _body.name = "OriginalAS48FrontFourCels"
    _body.centered = false
    _body.position = -FOOT
    _body.z_index = 1
    _body.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _actor.add_child(_body)
    for k in range(3):
        var mob := AnimatedSprite2D.new()
        mob.name = "RealMovingMonster%d" % (k+1)
        mob.sprite_frames = monster_frames
        mob.offset = Vector2(0,-135)
        mob.position = MOB_HOMES[k]
        mob.scale = Vector2.ONE * 0.38
        mob.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
        mob.z_index = 4
        mob.play(&"walk")
        add_child(mob)
        _monsters.append(mob)
    _fx_cell = AtlasTexture.new()
    _fx_cell.atlas = _v2_vfx_texture
    _fx = Sprite2D.new()
    _fx.name = "R1E_ApprovedVFXOnly_OneCircularAOE"
    _fx.texture = _fx_cell
    _fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _fx.scale = Vector2.ONE * FX_1X
    _fx.z_index = 16
    add_child(_fx)
    # Sprite-first accent: a restrained additive pass from the EXACT SAME R1E atlas.
    # No drawn geometry, procedural particles, or new weapon/actor graphics.
    _fx_glow = Sprite2D.new()
    _fx_glow.name = "R1E_Atlas_Additive_Glow_Only"
    _fx_glow.texture = _fx_cell
    _fx_glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    var glow_material := CanvasItemMaterial.new()
    glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
    _fx_glow.material = glow_material
    _fx_glow.modulate = Color(0.55,0.86,1.0,0.28)
    _fx_glow.z_index = 15
    add_child(_fx_glow)
    _ready_ok = true
    _set_frame(0)
    _update_positions()
    print("R1E_COMBAT_LAB_READY=PASS source=R1E_RGBA actor=ORIGINAL_AS48_FRONT moving_monsters=3 no_rig=true no_gameplay=true PvE=HOLD")
    print("R1E_V2_SELECTED=PASS frames=24 fps=25 runtime_lab_only=true old_version_available=true")
    set_process(true)
    queue_redraw()

func _set_frame(idx: int) -> void:
    idx = clampi(idx,0,(V2_COUNT-1 if _version_v2 else 11))
    _frame = idx
    _fx_cell.region = Rect2(float(idx%4)*512.0, float(int(idx/4))*512.0,512.0,512.0)
    var original_index := int(idx/2.0) if _version_v2 else idx
    var pose := mini(3, int(float(original_index)/3.0))
    var art := AtlasTexture.new()
    art.atlas = _as48_texture
    art.region = Rect2(float(pose)*400.0,0,400,440)
    _body.texture = art
    var socket: Dictionary = _socket_rows[pose].get("grip_sockets",{}).get("main_hand",{})
    var grip: Array = socket.get("body_grip_px",[])
    if grip.size()==2:
        _sword.position = Vector2(float(grip[0]),float(grip[1])) - FOOT
        _sword.rotation_degrees = float(socket.get("rotation_deg",0.0))
        _sword.scale = Vector2.ONE * 0.19
    if idx in [0,3,9]:
        print("R1E_PHASE_FRAME=%d visual_only=true no_hp=true" % idx)

func _weapon_tip_world() -> Vector2:
    # Read true AS48 independent weapon tip (grip/rotation/scale), NEVER a rig.
    # Sprite2D.offset displaces pixel coordinates before node transforms.
    return _sword.to_global(_weapon_tip_px + _sword.offset)

func _impact_origin() -> Vector2:
    # Visual AoE center follows the three actual moving monsters.
    var sum_pos := Vector2.ZERO
    for mob in _monsters:
        sum_pos += mob.position
    return sum_pos / float(maxi(1,_monsters.size())) + Vector2(8,-86)

func _update_hit_tint() -> void:
    # Freeze/seek must show the hit reaction as well as regular playback.
    var hit := (_frame >= 18 and _frame <= 21) if _version_v2 else (_frame >= 9 and _frame <= 10)
    for mob in _monsters:
        mob.modulate = Color("b9ebff") if hit else Color.WHITE

func _update_positions() -> void:
    if _fx == null:
        return
    _fx.visible = _fx_enabled
    var factor := 2.0 if _zoom else 1.0
    _fx.scale = Vector2.ONE * FX_1X * factor
    # The 2x preview must magnify the actor and monsters, not just the VFX.
    _actor.scale = Vector2.ONE * 0.17 * factor
    for mob in _monsters:
        mob.scale = Vector2.ONE * 0.38 * factor
    var charge_end := 6 if _version_v2 else 3
    var contact_frame := 18 if _version_v2 else 9
    var release_time := V2_RELEASE if _version_v2 else RELEASE_START
    var contact_time := V2_CONTACT if _version_v2 else CONTACT_START
    if _frame < charge_end:
        # Keep the source charging ring close to the actor's feet.
        # Interpolate towards the actual blade tip as the attack prepares.
        var q := clampf(_time / release_time,0.0,1.0)
        var foot_ring := _actor.position + Vector2(28,-35)
        _fx.position = foot_ring.lerp(_weapon_tip_world(),q*0.70)
    elif _frame < contact_frame:
        # The source R1E gyre is carried continuously FROM the blade tip TO
        # the moving enemy centroid, instead of teleporting to (585,474).
        var p := clampf((_time-release_time)/(contact_time-release_time),0.0,1.0)
        var smooth := p*p*(3.0-2.0*p)
        var from_tip := _weapon_tip_world()
        var target := _impact_origin()
        _fx.position = from_tip.lerp(target,smooth) + Vector2(0,-24*sin(PI*smooth))
    else:
        # End exactly on the enemy group, without frame-9 location jump.
        _fx.position = _impact_origin()
    # Glow follows the source sprite 1:1 and must NEVER become a separate effect.
    _fx_glow.visible = _fx_enabled
    _fx_glow.position = _fx.position
    _fx_glow.scale = _fx.scale * 1.06
    var hit := (_frame >= 18 and _frame <= 21) if _version_v2 else (_frame >= 9 and _frame <= 10)
    _fx_glow.modulate = Color(0.55,0.86,1.0, (0.30 if hit else 0.18) if _bright else (0.48 if hit else 0.28))
    _update_hit_tint()

func _process(delta: float) -> void:
    if not _ready_ok or _paused:
        return
    _time += minf(delta,0.06)*_speed
    var duration := V2_DURATION if _version_v2 else REVIEW_DURATION
    if _time >= duration:
        review_replay()
    var index := 0
    if _version_v2:
        index = clampi(int(floor(_time*V2_FPS)),0,V2_COUNT-1)
    else:
        for i in range(12):
            if _time >= float(FRAME_STARTS[i]):
                index = i
    if index != _frame:
        _set_frame(index)
    if _moving:
        for i in range(_monsters.size()):
            var p: Vector2 = MOB_HOMES[i]
            _monsters[i].position = p + Vector2(38*sin(_time*(1.3+float(i)*0.22)+float(i)), 13*sin(_time*(1.1+float(i)*0.14)+float(i)))
    if not _contact_shown and index >= (18 if _version_v2 else 9):
        _contact_shown = true
        _visual_contacts += 1
        for mob in _monsters:
            mob.modulate = Color("b8efff")
        print("R1E_LAB_VISUAL_AOE_PULSE=1 max_targets=3 ONLY_VISUAL no_combat_receipts=true")
    # Tint is now derived from the current phase in _update_positions(),
    # including during paused screenshot reviews.
    _update_positions()
    queue_redraw()

func _draw() -> void:
    var bg := Color("d4dfd6") if _bright else Color("101c2a")
    draw_rect(Rect2(0,0,1280,720),bg)
    draw_rect(Rect2(48,260,1174,385),Color("849d90") if _bright else Color("2b383b"))
    for k in range(9):
        var yy := 280.0+float(k)*40.0
        draw_line(Vector2(58,yy),Vector2(1210,yy+9),Color(0.05,0.19,0.26,0.15) if _bright else Color(0.8,0.9,1.0,0.055),1.0)
    draw_rect(Rect2(0,0,1280,108),Color("182538") if _bright else Color("0e1827"))
    draw_string(ThemeDB.fallback_font,Vector2(30,35),"KIEM VU HOI PHONG · R1E SOURCE APPROVED / RUNTIME ART UNDER REVIEW",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("eaf6ff"))
    draw_string(ThemeDB.fallback_font,Vector2(30,65),"AS48 FRONT ORIGINAL | 3 MOVING REAL MONSTERS | LAB ONLY | NO PVE / NO HP",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a9d0e7"))
    draw_rect(Rect2(0,660,1280,60),Color("101828"))
    var source_note := "R1E V2: 24 FRAME @25 FPS | SOURCE G3 APPROVED | FRONT ONLY | PVE HOLD" if _version_v2 else "R1E LEGACY: 12 FRAME | REFERENCE ONLY | FRONT ONLY | PVE HOLD"
    draw_string(ThemeDB.fallback_font,Vector2(27,696),source_note,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("d6e2f6"))

func review_replay() -> void:
    _time=0.0
    _frame=-1
    _contact_shown=false
    for mob in _monsters:
        mob.modulate=Color.WHITE
    _set_frame(0)
    _update_positions()
    print("R1E_REPLAY=PASS")

func review_set_version(version: String) -> void:
    var is_v2 := version.to_lower()=="v2"
    if _version_v2 == is_v2:
        return
    _version_v2 = is_v2
    _fx_cell.atlas = _v2_vfx_texture if _version_v2 else _legacy_vfx_texture
    review_replay()
    queue_redraw()
    print("R1E_REVIEW_VERSION="+("V2_24_FRAMES" if _version_v2 else "R1E_12_FRAMES"))

func review_set_paused(value: bool) -> void:
    _paused=value
func review_set_moving(value: bool) -> void:
    _moving=value
func review_set_fx(value: bool) -> void:
    _fx_enabled=value
    if _fx!=null: _fx.visible=value
    if _fx_glow!=null: _fx_glow.visible=value
func review_set_bright(value: bool) -> void:
    _bright=value
    queue_redraw()
func review_set_map_zoom(value: bool) -> void:
    _zoom=value
    _update_positions()
func review_set_speed(value: float) -> void:
    _speed=clampf(value,0.25,2.0)
func review_seek_phase(phase: String) -> void:
    match phase:
        "charge": _time=0.16 if _version_v2 else 0.24
        "projectile": _time=0.48 if _version_v2 else 0.68
        "contact": _time=0.76 if _version_v2 else 1.02
        _: return
    _paused=true
    var index := 0
    if _version_v2:
        index = clampi(int(floor(_time*V2_FPS)),0,V2_COUNT-1)
    else:
        for i in range(12):
            if _time >= float(FRAME_STARTS[i]): index=i
    _set_frame(index)
    _update_positions()
    print("R1E_SWORD02_PHASE_HELD="+phase+" frame="+str(index))