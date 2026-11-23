extends Node2D
## Kiếm Vũ Hồi Phong / Nhân R1E — isolated AS48 + moving real monsters.
## VFX-only approved source; NO combat receipts, SaveService, HP or PvE.
## Original AS48 Front attack cels and socket metadata; no puppet or rig.
const ROOT := "res://labs/combat_lab/sword_human_kiem_vu_hoi_phong/r1e/source/"
const VFX := ROOT + "KVHP_R1E_VFX_only_atlas_4x3_RGBA.png"
const AS48 := "res://labs/character_family/aschar_v9_batch1/"
const ACTOR_SHEET := AS48 + "assets/atlases/AS48_attack_front_consistency_v2_atlas.png"
const JIAN := AS48 + "assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
const SOCKETS := AS48 + "meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"
const MOB := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const SKILL_ID := "tmb.skill.sword.ngu_kiem.active_02.human"
const FOOT := Vector2(200, 429)
const FRAME_STARTS := [0.00, 0.12, 0.24, 0.36, 0.45, 0.54, 0.63, 0.72, 0.82, 0.96, 1.12, 1.30]
const REVIEW_DURATION := 1.54
const MOB_HOMES := [Vector2(766, 563), Vector2(873, 552), Vector2(970, 580)]

var _actor: Node2D
var _body: Sprite2D
var _sword: Sprite2D
var _fx: Sprite2D
var _fx_cell: AtlasTexture
var _as48_texture: Texture2D
var _weapon_texture: Texture2D
var _socket_rows: Array = []
var _weapon_grip := Vector2.ZERO
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
    var vfx_texture := _raw_png_texture(VFX)
    if _as48_texture == null or _weapon_texture == null or vfx_texture == null:
        return
    if vfx_texture.get_width() != 2048 or vfx_texture.get_height() != 1536:
        push_error("R1E_ATLAS_INVALID_SIZE")
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
    if _socket_rows.size() != 4 or grip.size() != 2:
        push_error("R1E_FRONT_SOCKETS_MISSING")
        return
    _weapon_grip = Vector2(float(grip[0]), float(grip[1]))
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
    _fx_cell.atlas = vfx_texture
    _fx = Sprite2D.new()
    _fx.name = "R1E_ApprovedVFXOnly_OneCircularAOE"
    _fx.texture = _fx_cell
    _fx.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _fx.scale = Vector2.ONE * (174.0/512.0)
    _fx.z_index = 16
    add_child(_fx)
    _ready_ok = true
    _set_frame(0)
    _update_positions()
    print("R1E_COMBAT_LAB_READY=PASS source=R1E_RGBA actor=ORIGINAL_AS48_FRONT moving_monsters=3 no_rig=true no_gameplay=true PvE=HOLD")
    set_process(true)
    queue_redraw()

func _set_frame(idx: int) -> void:
    idx = clampi(idx,0,11)
    _frame = idx
    _fx_cell.region = Rect2(float(idx%4)*512.0, float(int(idx/4))*512.0,512.0,512.0)
    var pose := mini(3, int(float(idx)/3.0))
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

func _update_positions() -> void:
    if _fx == null:
        return
    _fx.visible = _fx_enabled
    _fx.scale = Vector2.ONE * (174.0/512.0) * (2.0 if _zoom else 1.0)
    if _frame < 3:
        _fx.position = _actor.position + Vector2(40,-74)
    elif _frame < 9:
        _fx.position = Vector2(585,474)
    else:
        _fx.position = _monsters[1].position + Vector2(0,-75)

func _process(delta: float) -> void:
    if not _ready_ok or _paused:
        return
    _time += minf(delta,0.06)*_speed
    if _time >= REVIEW_DURATION:
        review_replay()
    var index := 0
    for i in range(12):
        if _time >= float(FRAME_STARTS[i]):
            index = i
    if index != _frame:
        _set_frame(index)
    if _moving:
        for i in range(_monsters.size()):
            var p := MOB_HOMES[i]
            _monsters[i].position = p + Vector2(38*sin(_time*(1.3+float(i)*0.22)+float(i)), 13*sin(_time*(1.1+float(i)*0.14)+float(i)))
    if not _contact_shown and index>=9:
        _contact_shown = true
        _visual_contacts += 1
        for mob in _monsters:
            mob.modulate = Color("b8efff")
        print("R1E_LAB_VISUAL_AOE_PULSE=1 max_targets=3 ONLY_VISUAL no_combat_receipts=true")
    if index>=11:
        for mob in _monsters:
            mob.modulate = Color.WHITE
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
    draw_string(ThemeDB.fallback_font,Vector2(30,35),"KIEM VU HOI PHONG · HUMAN · R1E / G3 OWNER ACCEPTED",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("eaf6ff"))
    draw_string(ThemeDB.fallback_font,Vector2(30,65),"AS48 FRONT ORIGINAL | 3 MOVING REAL MONSTERS | LAB ONLY | NO PVE / NO HP",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a9d0e7"))
    draw_rect(Rect2(0,660,1280,60),Color("101828"))
    draw_string(ThemeDB.fallback_font,Vector2(27,696),"SOURCE FRAMES 12 RGBA | TIMING REVIEW ONLY | FRONT DIRECTION VERIFIED",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("d6e2f6"))

func review_replay() -> void:
    _time=0.0
    _frame=-1
    _contact_shown=false
    for mob in _monsters:
        mob.modulate=Color.WHITE
    _set_frame(0)
    _update_positions()
    print("R1E_REPLAY=PASS")

func review_set_paused(value: bool) -> void:
    _paused=value
func review_set_moving(value: bool) -> void:
    _moving=value
func review_set_fx(value: bool) -> void:
    _fx_enabled=value
    if _fx!=null: _fx.visible=value
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
        "charge": _time=0.24
        "projectile": _time=0.68
        "contact": _time=1.02
        _: return
    _paused=true
    var index := 0
    for i in range(12):
        if _time >= float(FRAME_STARTS[i]): index=i
    _set_frame(index)
    _update_positions()
    print("R1E_SWORD02_PHASE_HELD="+phase+" frame="+str(index))