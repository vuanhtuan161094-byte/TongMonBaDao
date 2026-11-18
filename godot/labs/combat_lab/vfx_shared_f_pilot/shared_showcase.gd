extends Node2D
## F pilot 1280x720 TRUE Godot composite: existing POI02/POI15/PAF06 first-party
## atlas pixels used read-only for showing the shared layer API. This is NOT
## re-approval of those skill animations or a PvE receipt integration.
const LAYER = preload("res://labs/combat_lab/vfx_shared_f_pilot/vfx_sprite_layer.gd")
const POI02_FLIGHT: Texture2D = preload("res://labs/combat_lab/poison02/assets/serpent-flight-atlas.webp")
const POI15_FIELD: Texture2D = preload("res://labs/combat_lab/poison15_hoa_doc_tan/r1/assets/poi15_field_12.png")
const PAF06_PASSIVE: Texture2D = preload("res://labs/combat_lab/talisman16/r5/assets/paf06_r5_original_energy_sprites.png")
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
var time_s := 0.0
var moving_targets: Array = []
var serpent = null
var poison = null
var passive = null

func _make_actor(feet: Vector2, enemy: bool) -> Sprite2D:
    var art := Sprite2D.new()
    if enemy:
        art.texture = MONSTER.get_frame_texture("walk",0)
        art.scale = Vector2(0.95,0.95)
        art.position = feet-Vector2(0,47)
        moving_targets.append({"node":art,"base":feet})
    else:
        art.texture = DISCIPLE
        art.region_enabled = true
        art.region_rect = Rect2(0,0,320,384)
        art.scale = Vector2(0.32,0.32)
        art.position = feet-Vector2(0,65)
    add_child(art)
    return art

func _ready() -> void:
    var six_serpent: Array = []
    for i in range(6):
        six_serpent.append(Rect2(float(i%3)*512.0,float(floori(float(i)/3.0))*179.0,512,179))
    serpent = LAYER.new()
    add_child(serpent)
    assert(serpent.configure(POI02_FLIGHT,six_serpent,"projectile",1.65,0.37,0.96,"back"))
    var twelve_field: Array = []
    for i in range(12):
        twelve_field.append(Rect2(float(i%4)*320.0,float(floori(float(i)/4.0))*320.0,320,320))
    poison = LAYER.new()
    add_child(poison)
    assert(poison.configure(POI15_FIELD,twelve_field,"impact",1.55,0.60,0.89,"back"))
    passive = LAYER.new()
    add_child(passive)
    ## Passive aura: one original RGBA motif. No fake cast or hit is created.
    assert(passive.configure(PAF06_PASSIVE,[Rect2(96,0,96,96)],"mark",8.0,1.28,0.90,"back"))
    _make_actor(Vector2(108,558),false)
    _make_actor(Vector2(298,558),true)
    _make_actor(Vector2(526,558),false)
    _make_actor(Vector2(762,558),true)
    _make_actor(Vector2(1043,558),false)
    _make_actor(Vector2(1180,558),true)
    set_process(true)
    print("VFX_F_SHARED_SHOWCASE_READY original_atlases=POI02_POI15_PAF06 lab_only=true fake_combat=false art_owner=PENDING")
    queue_redraw()

func _process(delta: float) -> void:
    time_s = fposmod(time_s+maxf(0.0,delta),4.0)
    var n := maxi(1,MONSTER.get_frame_count("walk"))
    for i in range(moving_targets.size()):
        var row: Dictionary = moving_targets[i]
        var node: Sprite2D = row["node"]
        var base: Vector2 = row["base"]
        node.position = base + Vector2(14.0*sin(time_s*2.0+float(i)), -47.0+5.0*cos(time_s*1.7+float(i)))
        node.texture = MONSTER.get_frame_texture("walk",(int(time_s*12.0)+i*3)%n)
    var target0: Sprite2D = moving_targets[0]["node"]
    var target1: Sprite2D = moving_targets[1]["node"]
    serpent.set_anchors(Vector2(151,472),target0.position+Vector2(0,-4))
    serpent.visible = time_s>=0.3 and time_s<1.95
    serpent.seek(clampf(time_s-0.3,0.0,1.65))
    poison.set_anchors(Vector2(585,463),target1.position+Vector2(0,15))
    poison.visible = time_s>=0.8 and time_s<2.35
    poison.seek(clampf(time_s-0.8,0.0,1.55))
    passive.set_anchors(Vector2(1042,477),Vector2(1042+6.0*sin(time_s*2.0),477))
    passive.visible = true
    passive.seek(time_s)
    queue_redraw()

func _draw() -> void:
    draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false,Color(0.68,0.71,0.84))
    draw_rect(Rect2(0,0,1280,100),Color(0.035,0.05,0.085,0.88))
    draw_rect(Rect2(0,630,1280,90),Color(0.035,0.05,0.085,0.83))
    for x in [420.0,840.0]:
        draw_line(Vector2(x,100),Vector2(x,630),Color(0.88,0.86,0.99,0.28),1.0)
    var font := ThemeDB.fallback_font
    draw_string(font,Vector2(30,41),"TMB VFX — SHARED RENDERER PILOT / GENUINE GODOT",HORIZONTAL_ALIGNMENT_LEFT,1200,24,Color(0.98,0.96,0.92))
    draw_string(font,Vector2(36,83),"POI02 — XÀ ẢNH / FLIGHT",HORIZONTAL_ALIGNMENT_LEFT,350,18,Color(0.74,1.0,0.88))
    draw_string(font,Vector2(453,83),"POI15 — HÓA ĐỘC / AoE",HORIZONTAL_ALIGNMENT_LEFT,350,18,Color(0.78,1.0,0.77))
    draw_string(font,Vector2(875,83),"PAF06 — TĨNH TÂM / PASSIVE",HORIZONTAL_ALIGNMENT_LEFT,350,18,Color(0.92,0.91,0.62))
    draw_string(font,Vector2(35,672),"Read-only source RGBA | moving targets | no rig | no fake Combat V2 status | not owner art approval",HORIZONTAL_ALIGNMENT_LEFT,1210,17,Color(0.95,0.95,0.96))
    draw_string(font,Vector2(36,704),"F PILOT V1 · 1280 × 720 · DOC/ART/PvE HOLD",HORIZONTAL_ALIGNMENT_LEFT,1100,13,Color(0.8,0.82,0.9))
