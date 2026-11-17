extends Control
## PAF08 R1: Lưu Văn Liễm Tức, subdued flowing wind calligraphy.
## Distinct from PAF06 rotating buff and PAF07 palm pearl.
## Cosmetic passive-always-on LAB: NO cast, no hit receipt, no stat writes.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.passive_03.human"
const EFFECT := "passive"
const ELEMENT := "wind"
const AI_PROFILE := "passive_always_on"
const OUTGOING_FACTOR := 0.015
const CAST_TIME := 0.0
const COOLDOWN := 0.0
const DURATION := 0.0
const DAMAGE_RATIO := 0.0
const PROJECTILE_SPEED := 0.0
const NO_HIT_OR_CAST := true
const FRAMES := 36
const COLS := 9
const CELL := 320
const LOOP := 3.0
const ACTOR_FEET := Vector2(632,565)
const AURA_DEST := Rect2(504,337,256,256)
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const INK_REAR: Texture2D = preload("res://labs/combat_lab/talisman18/assets/paf08_rear.webp")
const INK_FRONT: Texture2D = preload("res://labs/combat_lab/talisman18/assets/paf08_front.webp")
const INK_SCRIPT: Texture2D = preload("res://labs/combat_lab/talisman18/assets/paf08_script.webp")

@export var passive_equipped: bool = true
var elapsed: float = 0.0
var motes: CPUParticles2D
var light_texture: Texture2D

static func frame_index(t:float)->int:
	return posmod(int(floor(maxf(t,0.0)/LOOP*FRAMES)),FRAMES)
static func frame_blend(t:float)->float:
	return fposmod(maxf(t,0.0)/LOOP*FRAMES,1.0)
static func atlas_cell(idx:int)->Rect2:
	var k:int=posmod(idx,FRAMES)
	return Rect2((k%COLS)*CELL,int(k/COLS)*CELL,CELL,CELL)
static func monster_foot(t:float)->Vector2:
	return Vector2(956+27*sin(t*1.12),535+12*sin(t*1.79))

func _make_particle_core()->Texture2D:
	var im:=Image.create(44,44,false,Image.FORMAT_RGBA8)
	for y in range(44):
		for x in range(44):
			var v:float=Vector2(x-21.5,y-21.5).length()/21.5
			im.set_pixel(x,y,Color(1.0,1.0,.86,exp(-11.0*v*v)*(1.0-smoothstep(.7,1.0,v))))
	return ImageTexture.create_from_image(im)

func _ready()->void:
	custom_minimum_size=Vector2(1280,720)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	light_texture=_make_particle_core()
	motes=CPUParticles2D.new()
	motes.texture=light_texture
	motes.amount=11
	motes.position=Vector2(629,478)
	motes.lifetime=1.5
	motes.gravity=Vector2.ZERO
	motes.direction=Vector2(.16,-1)
	motes.spread=27
	motes.initial_velocity_min=11.0
	motes.initial_velocity_max=33.0
	motes.damping_min=5.0
	motes.damping_max=15.0
	motes.scale_amount_min=.10
	motes.scale_amount_max=.28
	motes.color=Color(.9,1.0,.82,.66)
	motes.emitting=passive_equipped
	add_child(motes)
	set_process(true)
	print("PAF08_R1_READY genuine_rgba_source=true passive=true flowing_ink=true no_fake_hit_or_cast=true")

func set_passive_equipped(value:bool)->void:
	passive_equipped=value
	if motes!=null:
		motes.emitting=value
	queue_redraw()

func _process(delta:float)->void:
	elapsed+=maxf(0.0,delta)
	queue_redraw()

func _draw_keypose(tex:Texture2D,opacity:float)->void:
	var i:int=frame_index(elapsed)
	var blend:float=frame_blend(elapsed)
	var next:int=(i+1)%FRAMES
	draw_texture_rect_region(tex,AURA_DEST,atlas_cell(i),Color(1,1,1,opacity*(1.0-blend)))
	draw_texture_rect_region(tex,AURA_DEST,atlas_cell(next),Color(1,1,1,opacity*blend))

func _draw()->void:
	draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
	var foot:Vector2=monster_foot(elapsed)
	var total:int=maxi(1,MONSTER.get_frame_count("walk"))
	draw_texture_rect(MONSTER.get_frame_texture("walk",int(elapsed*11)%total),Rect2(foot-Vector2(48,124),Vector2(96,124)),false)
	if passive_equipped:
		_draw_keypose(INK_REAR,.85)
	draw_texture_rect_region(ACTOR,Rect2(ACTOR_FEET-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88))
	if passive_equipped:
		_draw_keypose(INK_FRONT,.93)
		_draw_keypose(INK_SCRIPT,.82)
