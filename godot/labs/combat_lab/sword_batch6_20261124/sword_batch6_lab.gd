extends Node2D
## SWORD03-08 / Human isolated Godot runtime - ONE GAME, review-only scene.
## Original AS48 frame-by-frame, independent Jian sword; actual 3 monster SpriteFrames.
## No rig, no procedural sword painting, no combat damage, no PvE, no SaveService.
@export_range(0,5,1) var skill_slot: int = 0

const ROOT := "res://labs/combat_lab/sword_batch6_20261124/"
const AS48 := "res://labs/character_family/aschar_v9_batch1/"
const ACTOR_SHEET := AS48 + "assets/atlases/AS48_attack_front_consistency_v2_atlas.png"
const WEAPON := AS48 + "assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
const SOCKETS := AS48 + "meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"
const MONSTER := "res://assets/actors/v5_sa_monster_1113031_1/animations.tres"
const ATLAS_WIDTH := 2048
const ATLAS_HEIGHT := 3072
const CEL := 512
const COUNT := 24
const FPS := 25.0
const CYCLE := 0.96
const RELEASE := 0.24
const CONTACT := 0.68
const FOOT := Vector2(200,429)
const MONSTER_HOME := [Vector2(762,550),Vector2(866,550),Vector2(966,564)]
const SKILLS := [
    {"tag":"03","name":"Tu Phuong Phi Nhan","targets":3,"id":"tmb.skill.sword.ngu_kiem.active_03.human","shape":"line"},
    {"tag":"04","name":"Kiem Quang Hoi Chu","targets":1,"id":"tmb.skill.sword.ngu_kiem.active_04.human","shape":"single_target"},
    {"tag":"05","name":"Van Kiem Quy Tong","targets":3,"id":"tmb.skill.sword.ngu_kiem.ultimate.human","shape":"circle"},
    {"tag":"06","name":"Tram Anh Nhat Tuyen","targets":1,"id":"tmb.skill.sword.sat_kiem.active_01.human","shape":"single_target"},
    {"tag":"07","name":"Pha Van Truc Tram","targets":3,"id":"tmb.skill.sword.sat_kiem.active_02.human","shape":"line"},
    {"tag":"08","name":"Doan Thuy Kiem Mang","targets":1,"id":"tmb.skill.sword.sat_kiem.active_03.human","shape":"single_target"}
]
var _actor: Node2D
var _body: Sprite2D
var _sword: Sprite2D
var _fx: Sprite2D
var _glow: Sprite2D
var _atlas: AtlasTexture
var _body_sheet: Texture2D
var _sword_sheet: Texture2D
var _rows: Array
var _grip := Vector2.ZERO
var _tip := Vector2.ZERO
var _mobs: Array[AnimatedSprite2D] = []
var _clock := 0.0
var _frame := -1
var _ready_ok := false
var _paused := false
var _moving := true
var _fx_enabled := true
var _bright := false
var _zoom := false
var _speed := 1.0
var _visual_hits := 0
var _registered_hit := false

func _raw_png(p: String) -> Texture2D:
    if ResourceLoader.exists(p):
        var source := ResourceLoader.load(p) as Texture2D
        if source != null:
            return source
    var bytes := FileAccess.get_file_as_bytes(p)
    if bytes.is_empty():
        push_error("BATCH6_MISSING_PNG "+p)
        return null
    var img := Image.new()
    if img.load_png_from_buffer(bytes) != OK:
        push_error("BATCH6_INVALID_PNG "+p)
        return null
    return ImageTexture.create_from_image(img)

func _ready() -> void:
    if skill_slot < 0 or skill_slot >= SKILLS.size():
        push_error("BATCH6_INVALID_SKILL_SLOT")
        return
    var info: Dictionary = SKILLS[skill_slot]
    var atlas_path := ROOT+"source/sword_"+str(info["tag"])+"_24f.png"
    _body_sheet = _raw_png(ACTOR_SHEET)
    _sword_sheet = _raw_png(WEAPON)
    var texture := _raw_png(atlas_path)
    if _body_sheet == null or _sword_sheet == null or texture == null:
        return
    if texture.get_size() != Vector2(ATLAS_WIDTH,ATLAS_HEIGHT):
        push_error("BATCH6_ATLAS_SIZE_FAILED "+atlas_path)
        return
    if not FileAccess.file_exists(SOCKETS):
        push_error("BATCH6_AS48_SOCKET_MISSING")
        return
    var m: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOCKETS))
    if not (m is Dictionary):
        push_error("BATCH6_SOCKET_JSON_INVALID")
        return
    _rows = m.get("body_frames",[])
    var j: Dictionary = m.get("weapon_assets",{}).get("jian_silver_candidate",{})
    var grip: Array = j.get("asset_grip_px",[])
    var tip: Array = j.get("asset_tip_px",[])
    if _rows.size() != 4 or grip.size()!=2 or tip.size()!=2:
        push_error("BATCH6_SOCKET_METADATA_INVALID")
        return
    _grip = Vector2(float(grip[0]),float(grip[1]))
    _tip = Vector2(float(tip[0]),float(tip[1]))
    var monster_frames := load(MONSTER) as SpriteFrames
    if monster_frames == null or not monster_frames.has_animation(&"walk"):
        push_error("BATCH6_MONSTER_SOURCE_MISSING")
        return
    _actor = Node2D.new()
    _actor.name = "OriginalAS48_NoRig"
    _actor.position = Vector2(322,557)
    _actor.scale = Vector2.ONE * 0.20
    _actor.z_index=6
    add_child(_actor)
    _sword=Sprite2D.new()
    _sword.name="OriginalIndependentSwordSocket"
    _sword.texture=_sword_sheet
    _sword.centered=false
    _sword.offset=-_grip
    _sword.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _actor.add_child(_sword)
    _body=Sprite2D.new()
    _body.name="OriginalAS48Front4AttackCels"
    _body.centered=false
    _body.position=-FOOT
    _body.z_index=1
    _body.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    _actor.add_child(_body)
    for i in range(3):
        var mob := AnimatedSprite2D.new()
        mob.name="RealMonster%02d" % (i+1)
        mob.sprite_frames=monster_frames
        mob.offset=Vector2(0,-135)
        mob.position=MONSTER_HOME[i]
        mob.scale=Vector2.ONE * 0.38
        mob.z_index=4
        mob.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
        mob.play(&"walk")
        add_child(mob)
        _mobs.append(mob)
    _atlas=AtlasTexture.new()
    _atlas.atlas=texture
    _fx=Sprite2D.new()
    _fx.name="OwnerApprovedVFXAtlas24f"
    _fx.texture=_atlas
    _fx.z_index=16
    _fx.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    add_child(_fx)
    _glow=Sprite2D.new()
    _glow.name="SourceAtlasAdditiveAccent"
    _glow.texture=_atlas
    _glow.z_index=15
    _glow.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
    var mat := CanvasItemMaterial.new()
    mat.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD
    _glow.material=mat
    add_child(_glow)
    _ready_ok=true
    _set_frame(0)
    _move_effect()
    set_process(true)
    queue_redraw()
    print("BATCH6_REAL_GODOT_LAB_READY skill=",str(info["id"])," atlas=",str(info["tag"])," actor=AS48_FRONT monsters=3 source=OWNER_APPROVED no_rig=true PvE=HOLD")

func _set_frame(index: int) -> void:
    _frame=clampi(index,0,COUNT-1)
    _atlas.region=Rect2(float(_frame%4)*CEL,float(int(float(_frame)/4.0))*CEL,CEL,CEL)
    var pose := 0
    if _frame >= 18:
        pose=3
    elif _frame >= 11:
        pose=2
    elif _frame >= 6:
        pose=1
    var body_region := AtlasTexture.new()
    body_region.atlas=_body_sheet
    body_region.region=Rect2(float(pose)*400.0,0,400,440)
    _body.texture=body_region
    var s: Dictionary = _rows[pose].get("grip_sockets",{}).get("main_hand",{})
    var g: Array = s.get("body_grip_px",[])
    if g.size()==2:
        _sword.position=Vector2(float(g[0]),float(g[1]))-FOOT
        _sword.rotation_degrees=float(s.get("rotation_deg",0.0))
        _sword.scale=Vector2.ONE*0.19

func _sword_tip_world() -> Vector2:
    return _sword.to_global(_tip+_sword.offset)

func _impact_origin() -> Vector2:
    if skill_slot == 1 or skill_slot == 3 or skill_slot == 5:
        return _mobs[0].position+Vector2(0,-84)
    return (_mobs[0].position+_mobs[1].position+_mobs[2].position)/3.0+Vector2(0,-88)

func _move_effect() -> void:
    if not _ready_ok:
        return
    var zoom_factor := 1.35 if _zoom else 1.0
    _actor.scale=Vector2.ONE*0.20*zoom_factor
    for mob in _mobs:
        mob.scale=Vector2.ONE*0.38*zoom_factor
    var scale_amount := (0.67 if skill_slot != 2 else 0.79)*zoom_factor
    _fx.scale=Vector2.ONE*scale_amount
    _fx.visible=_fx_enabled
    var from_tip:=_sword_tip_world()
    var target:=_impact_origin()
    var position := from_tip
    if _clock < RELEASE:
        var charge:=clampf(_clock/RELEASE,0.0,1.0)
        position=_actor.position.lerp(from_tip,0.35+0.60*charge)+Vector2(10,-35)
    elif _clock < CONTACT:
        var t:=clampf((_clock-RELEASE)/(CONTACT-RELEASE),0.0,1.0)
        var smooth:=t*t*(3.0-2.0*t)
        position=from_tip.lerp(target,smooth)
        match skill_slot:
            0: position+=Vector2(0,-18*sin(PI*t))
            1: position+=Vector2(0,-35*sin(PI*t))
            2: position+=Vector2(30*cos(2*PI*t),20*sin(2*PI*t))
            3: position+=Vector2(0,-8*sin(PI*t))
            4: position+=Vector2(0,20*sin(2*PI*t))
            5: position+=Vector2(0,-24*sin(PI*t))
    else:
        position=target
        if skill_slot==1 and _clock>0.76:
            var back:=clampf((_clock-0.76)/(CYCLE-0.76),0.0,1.0)
            position=target.lerp(from_tip,back*back*(3.0-2.0*back))
    _fx.position=position
    _glow.position=_fx.position
    _glow.scale=_fx.scale*1.04
    _glow.visible=_fx_enabled
    var hit:=_frame>=17 and _frame<=20
    _glow.modulate=Color(0.55,0.84,1.0,(0.28 if hit else 0.17) if not _bright else (0.18 if hit else 0.10))
    for i in range(_mobs.size()):
        var active:= i<int(SKILLS[skill_slot]["targets"])
        _mobs[i].modulate=Color("b9efff") if hit and active else Color.WHITE

func _process(delta: float) -> void:
    if not _ready_ok or _paused:
        return
    _clock+=minf(delta,0.06)*_speed
    if _clock>=CYCLE:
        review_replay()
    var idx:=clampi(int(floor(_clock*FPS)),0,COUNT-1)
    if idx!=_frame:
        _set_frame(idx)
    for i in range(_mobs.size()):
        if _moving:
            var base: Vector2=MONSTER_HOME[i]
            _mobs[i].position=base+Vector2(26*sin(_clock*(1.8+float(i)*0.2)+float(i)),10*sin(_clock*(1.4+float(i)*0.2)))
    if not _registered_hit and idx>=17:
        _registered_hit=true
        _visual_hits+=1
        print("BATCH6_VISUAL_CONTACT skill=",str(SKILLS[skill_slot]["id"])," max_targets=",str(SKILLS[skill_slot]["targets"])," visual_only=true no_damage=true")
    _move_effect()
    queue_redraw()

func _draw() -> void:
    var bg:=Color("d3ded6") if _bright else Color("14222c")
    draw_rect(Rect2(0,0,1280,720),bg)
    draw_rect(Rect2(12,248,1256,412),Color("889e95") if _bright else Color("27363c"))
    for i in range(9):
        var y:=270.0+float(i)*42.0
        draw_line(Vector2(20,y),Vector2(1260,y+7),Color(0.05,0.2,0.2,0.10) if _bright else Color(0.8,0.9,1,0.04),1)
    draw_rect(Rect2(0,0,1280,86),Color("192d38") if _bright else Color("0e1821"))
    draw_string(ThemeDB.fallback_font,Vector2(24,34),str(SKILLS[skill_slot]["name"])+"  |  24F 25FPS  |  REAL AS48 + 3 MOB",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e4f4ff"))
    draw_string(ThemeDB.fallback_font,Vector2(24,62),"SWORD03-08 OWNER SOURCE | FRONT VIEW | LAB ONLY | PVE HOLD",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("b5d0e7"))

func review_replay() -> void:
    _clock=0.0
    _frame=-1
    _registered_hit=false
    _actor.position=Vector2(322,557)
    _set_frame(0)
    _move_effect()
func review_set_paused(value: bool) -> void:
    _paused=value
func review_set_moving(value: bool) -> void:
    _moving=value
func review_set_fx(value: bool) -> void:
    _fx_enabled=value
    if _fx!=null:
        _fx.visible=value
    if _glow!=null:
        _glow.visible=value
func review_set_bright(value: bool) -> void:
    _bright=value
    queue_redraw()
    _move_effect()
func review_set_map_zoom(value: bool) -> void:
    _zoom=value
    _move_effect()
func review_set_speed(value: float) -> void:
    _speed=clampf(value,0.25,2.0)
func review_seek_phase(phase: String) -> void:
    match phase:
        "charge": _clock=0.16
        "projectile": _clock=0.44
        "contact": _clock=0.76
        _: return
    _paused=true
    _set_frame(clampi(int(floor(_clock*FPS)),0,COUNT-1))
    _move_effect()
    print("BATCH6_PHASE_HELD skill=",str(SKILLS[skill_slot]["id"])," phase=",phase," frame=",str(_frame))
