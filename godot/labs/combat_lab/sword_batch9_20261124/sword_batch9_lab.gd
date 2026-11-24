extends Node2D
## Candidate review scenes: same AS48 painted sprites, independent grip, real monsters.
## No gameplay events or damage authority. Guards anchor to disciples, movement moves the actor.
@export_range(0,8,1) var slot: int = 0
const ROOT := "res://labs/combat_lab/sword_batch9_20261124/"
const AS48 := "res://labs/character_family/aschar_v9_batch1/"
const FOOT := Vector2(200,429)
const HOME := Vector2(350,540)
const TARGET := Vector2(770,540)
const MOB_POS := [Vector2(770,540),Vector2(865,562),Vector2(960,584)]
var spec: Dictionary
var actor: Node2D
var body: Sprite2D
var weapon: Sprite2D
var body_tex: Texture2D
var sheet: Texture2D
var rows: Array
var grip: Vector2
var fx: Array[Sprite2D] = []
var allies: Array[Node2D] = []
var mobs: Array[AnimatedSprite2D] = []
var clock := 0.0
var last_frame := -1
var ready_ok := false
var phase_logged := false

func _png(path: String) -> Texture2D:
    if ResourceLoader.exists(path):
        return load(path) as Texture2D
    var image := Image.new()
    if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))!=OK:
        return null
    return ImageTexture.create_from_image(image)

func _ready() -> void:
    var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOT+"manifest.json"))
    if not doc is Dictionary:
        push_error("BATCH9_BAD_MANIFEST")
        return
    spec=doc["skills"][slot]
    sheet=_png(ROOT+"generated/sword_"+str(spec["tag"])+"_24f.png")
    body_tex=_png(AS48+"assets/atlases/AS48_attack_front_consistency_v2_atlas.png")
    var sword_tex:=_png(AS48+"assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png")
    var sockets: Variant=JSON.parse_string(FileAccess.get_file_as_string(AS48+"meta/AS48_ATTACK_FRONT_SOCKET_V9_3.json"))
    if sheet==null or body_tex==null or sword_tex==null or not sockets is Dictionary:
        push_error("BATCH9_MISSING_SOURCE")
        return
    rows=sockets["body_frames"]
    var g: Array=sockets["weapon_assets"]["jian_silver_candidate"]["asset_grip_px"]
    grip=Vector2(float(g[0]),float(g[1]))
    actor=Node2D.new()
    actor.position=HOME
    actor.scale=Vector2.ONE*.23
    actor.z_index=5
    add_child(actor)
    weapon=Sprite2D.new()
    weapon.texture=sword_tex
    weapon.centered=false
    weapon.offset=-grip
    actor.add_child(weapon)
    body=Sprite2D.new()
    body.centered=false
    body.position=-FOOT
    body.z_index=1
    actor.add_child(body)
    _pose(0)
    if str(spec["effect"])=="guard" and int(spec["target_limit"])>1:
        for i in range(2):
            var ally := actor.duplicate() as Node2D
            ally.position=HOME+Vector2(110.0+float(i)*80.0,30.0-float(i)*55.0)
            add_child(ally)
            allies.append(ally)
    var monster_frames:=load("res://assets/actors/v5_sa_monster_1113031_1/animations.tres") as SpriteFrames
    if monster_frames==null:
        push_error("BATCH9_MONSTERS_MISSING")
        return
    for i in range(3):
        var mob:=AnimatedSprite2D.new()
        mob.sprite_frames=monster_frames
        mob.offset=Vector2(0,-135)
        mob.position=MOB_POS[i]
        mob.scale=Vector2.ONE*.41
        mob.z_index=4
        add_child(mob)
        mob.play(&"walk")
        mobs.append(mob)
    for i in range(int(spec["target_limit"])):
        var sprite:=Sprite2D.new()
        var atlas:=AtlasTexture.new()
        atlas.atlas=sheet
        atlas.region=Rect2(0,0,512,512)
        sprite.texture=atlas
        sprite.scale=Vector2.ONE*.67
        sprite.z_index=10
        add_child(sprite)
        fx.append(sprite)
    ready_ok=true
    print("BATCH9_LAB_READY tag=",spec["tag"]," effect=",spec["effect"]," source=DERIVED_CANDIDATE PvE=HOLD")

func _pose(index: int) -> void:
    var a:=AtlasTexture.new()
    a.atlas=body_tex
    a.region=Rect2(float(index)*400.0,0,400,440)
    body.texture=a
    var s: Dictionary=rows[index]["grip_sockets"]["main_hand"]
    var g: Array=s["body_grip_px"]
    weapon.position=Vector2(float(g[0]),float(g[1]))-FOOT
    weapon.rotation_degrees=float(s.get("rotation_deg",0.0))
    weapon.scale=Vector2.ONE*.19

func _process(delta: float) -> void:
    if not ready_ok:
        return
    clock=fmod(clock+minf(delta,.06),1.44)
    var f:=clampi(int(clock*25.0),0,23)
    var progress:=clampf((clock-.24)/.44,0.0,1.0)
    var kind:=str(spec["effect"])
    var style:=str(spec["style"])
    var active:=clock<.96
    if clock<.05:
        phase_logged=false
    if f!=last_frame:
        _pose(mini(3,floori(float(f)/6.0)))
        last_frame=f
    for i in range(mobs.size()):
        var home: Vector2=MOB_POS[i]
        mobs[i].position=home+Vector2(16*sin(clock*2.0+float(i)),5*sin(clock*2.0))
        mobs[i].modulate=Color.WHITE
    actor.position=HOME
    if kind=="mobility":
        actor.position=HOME.lerp(TARGET-Vector2(100,0),progress)
    elif style in ["heavy","counter","basic","line_guard"]:
        actor.position=HOME.lerp(TARGET-Vector2(100,0),clampf(clock/.24,0.0,1.0))
    for i in range(fx.size()):
        var s:=fx[i]
        var a:=s.texture as AtlasTexture
        a.region=Rect2(float(f%4)*512.0,float(floori(float(f)/4.0))*512.0,512,512)
        s.visible=active
        s.rotation=0.0
        s.modulate=Color.WHITE
        if kind=="guard":
            var foot: Vector2=actor.position if i==0 else allies[i-1].position
            s.position=foot+Vector2(0,-48)
            s.scale=Vector2.ONE*(.52 if style!="realm" else .75)
        elif kind=="mobility":
            s.position=actor.position+Vector2(-50,-45)
            s.scale=Vector2.ONE*.62
        else:
            var to: Vector2=mobs[i].position+Vector2(0,-68)
            s.position=(actor.position+Vector2(0,-45)).lerp(to,progress)
            s.scale=Vector2.ONE*(.85 if style=="heavy" else .57)
            if clock>=.68 and clock<.86:
                mobs[i].modulate=Color(1.15,1.12,1.06,1.0)
    if clock>=.68 and not phase_logged:
        phase_logged=true
        print("BATCH9_LAB_PHASE tag=",spec["tag"]," kind=",kind," target_limit=",spec["target_limit"]," visual_only=true")
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("16242c"))
    draw_rect(Rect2(12,220,1256,460),Color("293b3d"))
    if not ready_ok:
        return
    for mob in mobs:
        draw_set_transform(mob.position,0.0,Vector2(1.0,.32))
        draw_circle(Vector2.ZERO,25.0,Color(0,0,0,.25))
    for unit in [actor]+allies:
        draw_set_transform(unit.position,0.0,Vector2(1.0,.32))
        draw_circle(Vector2.ZERO,24.0,Color(0,0,0,.25))
    draw_set_transform(Vector2.ZERO)
    draw_string(ThemeDB.fallback_font,Vector2(26,38),str(spec["tag"])+"  "+str(spec["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color.WHITE)
    draw_string(ThemeDB.fallback_font,Vector2(26,68),"DERIVED SOURCE CANDIDATE  |  "+str(spec["effect"])+"  |  PVE HOLD",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("b5d0e7"))
