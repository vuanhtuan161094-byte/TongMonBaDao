extends Control
## PAF07 – Dưỡng Phù Quy Nguyên, passive-always-on cast-speed bonus candidate.
## Original key-pose talisman pearl sprite near palm, NO cast or target hit.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.passive_02.human"
const AI_PROFILE := "passive_always_on"
const EFFECT := "passive"
const ELEMENT := "wind"
const CAST_SPEED_FACTOR := .015
const CAST_TIME := 0.0
const COOLDOWN := 0.0
const DURATION := 0.0
const PROJECTILE_SPEED := 0.0
const NO_DAMAGE_OR_HIT := true
const FRAMES := 24
const COLS := 6
const CELL := 256
const LOOP := 2.4
const ACTOR_FEET := Vector2(632,565)
const PALM := Vector2(706,473)
const BACKDROP: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const PEARL: Texture2D = preload("res://labs/combat_lab/talisman17/assets/paf07_quy_nguyen_24.webp")

@export var passive_equipped := true
var elapsed := 0.0
var motes: CPUParticles2D
var star: Texture2D

static func frame_index(t:float)->int:
	return posmod(int(floor(maxf(t,0.0)/LOOP*FRAMES)),FRAMES)
static func frame_blend(t:float)->float:
	return fposmod(maxf(t,0.0)/LOOP*FRAMES,1.0)
static func tile(k:int)->Rect2:
	var q:int=posmod(k,FRAMES)
	return Rect2((q%COLS)*CELL,int(q/COLS)*CELL,CELL,CELL)
static func dummy_pos(t:float)->Vector2:
	return Vector2(950+22*sin(t*1.17),537+9*sin(t*1.89))

func _ready()->void:
	custom_minimum_size=Vector2(1280,720)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	var im:=Image.create(40,40,false,Image.FORMAT_RGBA8)
	for y in range(40):
		for x in range(40):
			var d:float=Vector2(x-19.5,y-19.5).length()/19.5
			im.set_pixel(x,y,Color(1,1,.86,exp(-10*d*d)*(1.0-smoothstep(.67,1.0,d))))
	star=ImageTexture.create_from_image(im)
	motes=CPUParticles2D.new()
	motes.amount=14
	motes.texture=star
	motes.position=PALM
	motes.lifetime=1.25
	motes.direction=Vector2(0,-1)
	motes.spread=24
	motes.gravity=Vector2.ZERO
	motes.initial_velocity_min=15
	motes.initial_velocity_max=41
	motes.scale_amount_min=.09
	motes.scale_amount_max=.21
	motes.color=Color(.98,.88,.57,.68)
	motes.emitting=passive_equipped
	add_child(motes)
	set_process(true)
	print("PAF07_R1_READY always_on=true original_rgba=true hand_nourishing_pearl=true no_cast_no_hit=true")

func set_passive_equipped(enabled:bool)->void:
	passive_equipped=enabled
	if motes!=null:motes.emitting=enabled
	queue_redraw()

func _process(delta:float)->void:
	elapsed+=maxf(delta,0.0)
	queue_redraw()

func _draw()->void:
	draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
	var p:Vector2=dummy_pos(elapsed)
	var count:int=maxi(1,MONSTER.get_frame_count("walk"))
	draw_texture_rect(MONSTER.get_frame_texture("walk",int(elapsed*11)%count),Rect2(p-Vector2(48,124),Vector2(96,124)),false)
	draw_texture_rect_region(ACTOR,Rect2(ACTOR_FEET-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88))
	if not passive_equipped:return
	var r:=Rect2(PALM-Vector2(75,75),Vector2(150,150))
	var k:int=frame_index(elapsed)
	var next:int=(k+1)%FRAMES
	var b:float=frame_blend(elapsed)
	draw_texture_rect_region(PEARL,r,tile(k),Color(1,1,1,.91*(1-b)))
	draw_texture_rect_region(PEARL,r,tile(next),Color(1,1,1,.91*b))
