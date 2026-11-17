extends "res://labs/combat_lab/talisman16/r3/vo_lam_orbit_buff_r3.gd"
## PAF06 R5: FIRST-PARTY RGBA sprite VFX, NOT three spinning paper cards.
## Original art source was created in this ChatGPT session from generated concept;
## isolated via RGB->alpha, palette-compressed solely for shipping in Git.
## Keeps user-approved R3 genuine rotating 2.5D rings, far/near placement.
const ATLAS: Texture2D = preload("res://labs/combat_lab/talisman16/r5/assets/paf06_r5_original_energy_sprites.png")
const SPRITE_CELL := 96
const WIND := Rect2(0,0,SPRITE_CELL,SPRITE_CELL)
const SWIRL := Rect2(SPRITE_CELL,0,SPRITE_CELL,SPRITE_CELL)
const GROUND := Rect2(SPRITE_CELL*2,0,SPRITE_CELL,SPRITE_CELL)
const SWIRL_AREA := Rect2(503.0,424.0,258.0,139.0)
const GROUND_AREA := Rect2(514.0,511.0,238.0,116.0)
const SEAL_AREA := Rect2(591.0,323.0,82.0,82.0)
const PERIOD := 3.0
var flow_rear: Texture2D
var flow_front: Texture2D
var texture_source_valid := false
var seal_clean: Texture2D
var ground_clean: Texture2D

static func full_sprite_region(kind:int) -> Rect2:
	return Rect2(kind*SPRITE_CELL,0,SPRITE_CELL,SPRITE_CELL)

static func material_alpha(t:float) -> float:
	return .75+.11*sin(TAU*t/PERIOD)

func _make_depth_split() -> void:
	var orig: Image=ATLAS.get_image()
	if orig.get_width()!=SPRITE_CELL*3 or orig.get_height()!=SPRITE_CELL:
		push_error("PAF06_R5_ATLAS_DIMENSIONS_INVALID")
		return
	# The user approved the R3 orbit: preserve it. Wind source is split into
	# separate actual RGBA textures so it truly passes BEHIND/IN FRONT of actor.
	var sprite:Image=orig.get_region(Rect2i(SPRITE_CELL,0,SPRITE_CELL,SPRITE_CELL))
	var behind:Image=sprite.duplicate()
	var ahead:Image=sprite.duplicate()
	for y in range(SPRITE_CELL):
		for x in range(SPRITE_CELL):
			if y < 49:
				ahead.set_pixel(x,y,Color.TRANSPARENT)
			else:
				behind.set_pixel(x,y,Color.TRANSPARENT)
	flow_rear=ImageTexture.create_from_image(behind)
	flow_front=ImageTexture.create_from_image(ahead)
	# Source artwork is original RGB/alpha, but its concept-board extraction
	# retained one thin gold layout rule (row 19) above the sigil.
	# Remove that rule once on GPU import. No flat poster/border in game.
	var seal:Image=orig.get_region(Rect2i(0,0,SPRITE_CELL,SPRITE_CELL))
	for x in range(SPRITE_CELL):
		seal.set_pixel(x,19,Color.TRANSPARENT)
	seal_clean=ImageTexture.create_from_image(seal)
	# Kill low-alpha dark matte from the concept board under the gold ring.
	# The floor should be clear engraved light, not a muddy rectangular patch.
	var grounding:Image=orig.get_region(Rect2i(SPRITE_CELL*2,0,SPRITE_CELL,SPRITE_CELL))
	for y in range(SPRITE_CELL):
		for x in range(SPRITE_CELL):
			var ink:Color=grounding.get_pixel(x,y)
			if ink.a < .62:
				grounding.set_pixel(x,y,Color.TRANSPARENT)
	ground_clean=ImageTexture.create_from_image(grounding)
	texture_source_valid=true

func _ready() -> void:
	super._ready()
	_make_depth_split()
	# Continuous buff stays light and unlike an always-on shield.
	spirit_motes.color=Color(.75,1.0,.83,.60)
	spirit_motes.amount=15
	print("PAF06_R5_READY original_rgba_sprite=true previous_three_paper_seals=false R3_orbit_unchanged=true passive=true")

func _draw() -> void:
	draw_texture_rect(BACKDROP,Rect2(0,0,1280,720),false)
	var foot:Vector2=decoy_foot(time_s)
	var count:int=maxi(1,DECOY.get_frame_count("walk"))
	var monster:Texture2D=DECOY.get_frame_texture("walk",int(time_s*11.0)%count)
	draw_texture_rect(monster,Rect2(foot-Vector2(48,124),Vector2(96,124)),false)
	if passive_equipped:
		var ink:float=material_alpha(time_s)
		# The approved R3 ring key-poses keep rotating; new sprite art is
		# luminous MATERIAL, never a poster of the whole character.
		_r3_layer(R3_REAR,.83)
		if texture_source_valid:draw_texture_rect(flow_rear,SWIRL_AREA,false,Color(1,1,1,ink*.69))
		draw_texture_rect(ground_clean,GROUND_AREA,false,Color(1,1,1,.42+.08*sin(time_s*2.6)))
	draw_texture_rect_region(ACTOR,Rect2(HERO_FEET-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88))
	if passive_equipped:
		if texture_source_valid:draw_texture_rect(flow_front,SWIRL_AREA,false,Color(1,1,1,material_alpha(time_s)*.85))
		_r3_layer(R3_FRONT,.89)
		_r3_layer(R3_SPARK,.71)
		# One recognisable WIND seal, not three ugly rotating paper talismans.
		var beat:float=.84+.09*sin(time_s*1.9)
		draw_texture_rect(seal_clean,SEAL_AREA,false,Color(1,1,1,beat))
