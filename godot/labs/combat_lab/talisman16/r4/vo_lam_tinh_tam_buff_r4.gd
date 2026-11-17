extends "res://labs/combat_lab/talisman16/r3/vo_lam_orbit_buff_r3.gd"
## PAF06 R4 semantic identity: three orbiting jade-gold talisman feathers
## and a hand-painted 6-petal quiet-heart lotus. All motion is view-only.
## Retains exact R3 ellipse orbits, light, actors, CPUParticles2D, gameplay.
const R4_POSES := 48
const R4_COLUMNS := 8
const ID_REAR: Texture2D = preload("res://labs/combat_lab/talisman16/r4/assets/paf06_r4_rear.webp")
const ID_FRONT: Texture2D = preload("res://labs/combat_lab/talisman16/r4/assets/paf06_r4_front.webp")
const ID_HEART: Texture2D = preload("res://labs/combat_lab/talisman16/r4/assets/paf06_r4_heart.webp")
const CORE_POS := Vector2(632.0,505.0)

static func canonical_motif() -> String:
	return "THREE_MOVING_JADE_GOLD_WIND_TALISMANS_PLUS_QUIET_HEART_LOTUS"

static func identity_frame(t: float) -> int:
	return posmod(int(floor(maxf(t,0.0)/R3_LOOP*float(R4_POSES))),R4_POSES)

static func identity_phase(t: float) -> float:
	return fposmod(maxf(t,0.0)/R3_LOOP*float(R4_POSES),1.0)

func _ready() -> void:
	super._ready()
	print("PAF06_R4_READY visual_semantic=TINH_GIOI_TINH_TAM original_art=true 3_orbiting_seals=true quiet_heart=true no_combat_write=true")

func _r4_layer(source: Texture2D,alpha: float) -> void:
	var i: int=identity_frame(time_s)
	var j: int=(i+1)%R4_POSES
	var blend: float=identity_phase(time_s)
	draw_texture_rect_region(source,R3_DEST,frame_region(i),Color(1.0,1.0,1.0,alpha*(1.0-blend)))
	draw_texture_rect_region(source,R3_DEST,frame_region(j),Color(1.0,1.0,1.0,alpha*blend))

func _draw() -> void:
	draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
	var pos: Vector2=decoy_foot(time_s)
	var walk_frames: int=maxi(1,DECOY.get_frame_count("walk"))
	var texture: Texture2D=DECOY.get_frame_texture("walk",int(time_s*11.0)%walk_frames)
	draw_texture_rect(texture,Rect2(pos-Vector2(48,124),Vector2(96,124)),false)
	if passive_equipped:
		_r3_layer(R3_REAR,.93)
		_r4_layer(ID_REAR,.93)
	draw_texture_rect_region(ACTOR,Rect2(HERO_FEET-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88))
	if passive_equipped:
		_r3_layer(R3_FRONT,.93)
		_r4_layer(ID_FRONT,.96)
		_r3_layer(R3_SPARK,.73)
		# Warm pearl sits over the center of the robe, not above the face.
		# Petals breathe slowly while wind calligraphy traverses the 2.5D orbit.
		_r4_layer(ID_HEART,.94)
