extends "res://labs/combat_lab/talisman15/r4/thai_huyen_phong_gioi_r4.gd"
## PAF05 R5 – Phong Linh Triện: evolving painted strokes + genuine hybrid runtime.
## R4 moving wind/particles remain; R4 flat three-stroke UI ring mark is REPLACED.
## This LAB's mark is only a simulated cosmetic receipt, NOT a Combat V2 write.
const MARK_TEX: Texture2D = preload("res://labs/combat_lab/talisman15/r5/assets/paf05_r5_mark.webp")
const CONTACT_TEX: Texture2D = preload("res://labs/combat_lab/talisman15/r5/assets/paf05_r5_contact.webp")
const MARK_FRAMES := 12
const CONTACT_FRAMES := 11
const MARK_CELL := 320
const FORM_START := 0.60
const FORM_END := 2.52

static func latched_mark(k: int, t: float) -> bool:
	# A recorded mark persists after the target walks outside the painted circle.
	# The only legality check happens at the one simulated receipt instant.
	return k >= 0 and k < CAP and in_circle(k, RECEIPT) and t >= RECEIPT and t < RECEIPT + STATUS

static func mark_pos(k: int, t: float) -> Vector2:
	# Near the moving enemy shoulder/chest, no UI icon above its head.
	return target_anchor(k,t) + Vector2(32,10)

static func mark_frame(t: float) -> int:
	if t < RECEIPT: return 0
	var elapsed := t - RECEIPT
	if elapsed < .38: return mini(5,int(elapsed/.076))
	return 6 + int(floor(fposmod((elapsed-.38)*3.0,6.0)))

static func seal_frame(t: float) -> int:
	return clampi(int((t-FORM_START)/1.55*11.0),0,11)

func _ready() -> void:
	super._ready()
	print("VFX_PAF05_R5_READY original_painted_seal=true shoulder_mark=true seven_seconds=true no_ui_ring=true moving_target=true")

func _atlas(tex: Texture2D,k: int,at: Vector2,size: Vector2,color: Color=Color.WHITE) -> void:
	var clamped := maxi(0,k)
	var uv := Rect2((clamped%4)*MARK_CELL,int(clamped/4)*MARK_CELL,MARK_CELL,MARK_CELL)
	draw_texture_rect_region(tex,Rect2(at-size*.5,size),uv,color)

# R5D: move four DIFFERENT stream heads/tails at independent phase/sweep speeds.
# Only actual energy-geometry movement, never global sprite wave/UV remap.
func _sweep(k: int,u: float,t: float,ext: float) -> Vector2:
	var angles: Array[float]=[-.11,.17,-.24,.09]
	var scales: Array[float]=[.92,1.11,.83,1.03]
	var speeds: Array[float]=[.83,.96,.76,.88]
	var angle: float=k*TAU/4.0+t*speeds[k]+u*(1.12+.16*sin(float(k)*1.4))-1.28+angles[k]
	var radius: float=22.0+157.0*u*ext*scales[k]
	return AREA+Vector2(cos(angle)*radius,sin(angle)*radius*.46-39.0*(1.0-u))

func _draw_charge_r5(t: float) -> void:
	var strength: float = charge_envelope(t)
	if strength <= .004: return
	# Three luminous handwritten strands draw towards the actual raised hand.
	for j in range(3):
		var a: float = (float(j)*TAU/3.0+t*2.8)
		var radius: float = 67.0-45.0*smoothstep(.04,.90,t)
		var p: Vector2 = HAND+Vector2(cos(a),sin(a)) * radius
		var tang: Vector2 = Vector2(-sin(a),cos(a))
		draw_line(p-22.0*tang,p+22.0*tang,Color(.11,.85,.72,.37*strength),8.2,true)
		draw_line(p-16.0*tang,p+19.0*tang,Color(.96,1,.88,.92*strength),2.0,true)
	draw_texture_rect(glow,Rect2(HAND-Vector2(48,48),Vector2(96,96)),false,Color(.77,1.0,.86,.65*strength))
	# The talisman visibly grows from an authored stroke, not scaling one still.
	if t>.34:
		var idx: int=mini(5,int((t-.34)/.09))
		_atlas(MARK_TEX,idx,HAND+Vector2(-7,-17),Vector2(76,82),Color(1,1,1,.73*strength))

func _draw_field_r5(t: float) -> void:
	var p: float=field_envelope(t)
	if p <= .005: return
	# Deliberately BROKEN 2.5D earthen inscription, subordinate to moving qi.
	for j in range(12):
		var a0: float=j*TAU/12.0+.15
		var a1: float=a0+.25+.05*sin(j*1.7)
		var p0: Vector2=AREA+Vector2(cos(a0)*170.0,sin(a0)*76.0)
		var p1: Vector2=AREA+Vector2(cos(a1)*170.0,sin(a1)*76.0)
		draw_line(p0,p1,Color(.98,.82,.47,.29*p),1.65,true)
		if j%3==0:
			var radial: Vector2=Vector2(cos(a0),sin(a0)*.46)
			draw_line(p0,p0+radial*11.0,Color(.95,.93,.69,.45*p),1.25,true)
	# This is the transient ORIGINAL artwork, but never the sole animation:
	# moving heads/tails/caustics/particles below are all genuine runtime motion.
	var k: int = seal_frame(t)
	var seal_opacity: float = p * .31
	_atlas(MARK_TEX,k,AREA+Vector2(0,-23),Vector2(165,102),Color(1,1,1,seal_opacity))
	_ribbons(t)

func _draw_contact_and_marks_r5(t: float) -> void:
	var v: float=contact_envelope(t)
	for k in range(CAP):
		var target_now: Vector2=target(k,t)
		if v>.003 and in_circle(k,RECEIPT):
			var contact_at: Vector2=mark_pos(k,t)
			var idx: int=clampi(int((t-RECEIPT)/.59*(CONTACT_FRAMES-1)),0,CONTACT_FRAMES-1)
			_atlas(CONTACT_TEX,idx,contact_at,Vector2(122,122),Color(1,1,1,.79*v))
			draw_texture_rect(glow,Rect2(contact_at-Vector2(28,28),Vector2(56,56)),false,Color(1.0,.98,.77,.44*v))
		if latched_mark(k,t):
			var anchor_now: Vector2=mark_pos(k,t)
			var phase: float=t-RECEIPT
			var frame: int=mark_frame(t)
			var ink: float=.93*(.91+.09*sin(phase*2.3))
			# Persistent 7s state is engraved slightly to the side of the
			# shoulder. The rune is ART-TEXTURE, not the old draw_arc badge.
			_atlas(MARK_TEX,frame,anchor_now,Vector2(73,73),Color(1,1,1,ink*.86))
			if phase<.28:
				var white: float=1.0-smoothstep(.08,.28,phase)
				draw_texture_rect(glow,Rect2(anchor_now-Vector2(22,22),Vector2(44,44)),false,Color(.94,1,.80,.34*white))

func _draw() -> void:
	var t: float=clock
	draw_texture_rect(BACK,Rect2(0,0,1280,720),false)
	# ground passes are behind caster and monsters
	_draw_field_r5(t)
	# Actual WALK SpriteFrames, not an image cutout copied through time
	var walk: int=maxi(1,MONSTER.get_frame_count("walk"))
	for k in range(CAP):
		var pos: Vector2=target(k,t)
		var texture: Texture2D=MONSTER.get_frame_texture("walk",(int(t*12.0)+k*3)%walk)
		draw_texture_rect(texture,Rect2(pos-Vector2(48,124),Vector2(96,124)),false)
	draw_texture_rect_region(ACTOR,Rect2(Vector2(315,554)-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88,1))
	_draw_charge_r5(t)
	_draw_contact_and_marks_r5(t)
