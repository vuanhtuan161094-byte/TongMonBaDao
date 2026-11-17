extends "res://labs/combat_lab/talisman16/tinh_gioi_tinh_tam_r1.gd"
## PAF06 R3 – 2.5D glowing body-orbit buff in the spirit of classic Võ Lâm.
## ALL VFX pixels are newly authored in tools/vfx/paint_paf06_r3_orbit.py.
## Far-half behind ACTOR / near-half in front: physically reads around the body.
## Passive cosmetic only: no gameplay passive write, cast, target hit or shield.
const R3_POSES := 48
const R3_COLUMNS := 8
const R3_LOOP := 3.0
const R3_REAR: Texture2D = preload("res://labs/combat_lab/talisman16/r3/assets/paf06_r3_rear.webp")
const R3_FRONT: Texture2D = preload("res://labs/combat_lab/talisman16/r3/assets/paf06_r3_front.webp")
const R3_SPARK: Texture2D = preload("res://labs/combat_lab/talisman16/r3/assets/paf06_r3_spark.webp")
const R3_DEST := Rect2(Vector2(632.0-152.0,467.0-154.0),Vector2(304.0,304.0))

static func frame_at(t: float) -> int:
	return posmod(int(floor(maxf(t,0.0) / R3_LOOP * float(R3_POSES))),R3_POSES)

static func blend_at(t: float) -> float:
	return fposmod(maxf(t,0.0)/R3_LOOP*float(R3_POSES),1.0)

static func frame_region(i: int) -> Rect2:
	var k: int=posmod(i,R3_POSES)
	return Rect2((k%R3_COLUMNS)*CELL,int(k/R3_COLUMNS)*CELL,CELL,CELL)

static func depth_front(angle: float) -> bool:
	# Real ring projection far/near convention matches first-party alpha bake.
	return sin(angle)>=0.0

static func moving_caustic(t: float,ring_index: int) -> float:
	var signed_revolutions: float=[1.0,-2.0,1.0][ring_index]
	return fposmod(TAU*(t/R3_LOOP*signed_revolutions)+ring_index*.95,TAU)

func _ready() -> void:
	super._ready()
	# Existing quiet wind-motes stay independent; reduce clutter now the
	# rotational buff rings are the clear visual identity.
	spirit_motes.amount=12
	spirit_motes.color=Color(.90,1.0,.83,.66)
	spirit_motes.initial_velocity_min=8.0
	spirit_motes.initial_velocity_max=28.0
	print("PAF06_R3_READY original_glowing_orbit=true near_far_layers=true always_on=true no_combat_write=true")

func _r3_layer(tex: Texture2D,opacity: float) -> void:
	var k: int=frame_at(time_s)
	var f: float=blend_at(time_s)
	var j: int=(k+1)%R3_POSES
	# The source frames contain differently positioned white-hot caustic heads,
	# golden brush glints and their own 2.5D perspective depth split.
	# These are NOT a single static ring sprite rotated/UV-wobbled.
	draw_texture_rect_region(tex,R3_DEST,frame_region(k),Color(1,1,1,opacity*(1.0-f)))
	draw_texture_rect_region(tex,R3_DEST,frame_region(j),Color(1,1,1,opacity*f))

func _draw() -> void:
	draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
	var foot: Vector2=decoy_foot(time_s)
	var walk_count: int=maxi(1,DECOY.get_frame_count("walk"))
	var monster: Texture2D=DECOY.get_frame_texture("walk",int(time_s*11.0)%walk_count)
	draw_texture_rect(monster,Rect2(foot-Vector2(48,124),Vector2(96,124)),false)
	if passive_equipped:
		_r3_layer(R3_REAR,.92)
	draw_texture_rect_region(ACTOR,
		Rect2(HERO_FEET-Vector2(72,163),Vector2(144,163)),
		Rect2(0,0,320,384),Color(.97,.94,.88,1.0))
	if passive_equipped:
		_r3_layer(R3_FRONT,.95)
		_r3_layer(R3_SPARK,.77)
