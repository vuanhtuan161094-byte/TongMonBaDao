extends Control
## PAF05 R4 native hybrid wind: genuine evolving ribbons + 2D particles + shader.
## Render-only / no gameplay writes. Mark contact in this LAB is simulated.
const SKILL_ID := "tmb.skill.talisman.phong_an_phu.ultimate.human"
const CAP := 3
const RADIUS := 2.1
const CAST := 0.9
const COOLDOWN := 23.0
const STATUS := 7.0
const RECEIPT := 1.33
const LOOP := 9.30
const AREA := Vector2(814, 525)
const HAND := Vector2(392,423)
const BACK: Texture2D = preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTER: SpriteFrames = preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const FLOW: Shader = preload("res://labs/combat_lab/talisman15/r4/wind_flow.gdshader")
var clock: float = 0.0
var shader_mat: ShaderMaterial
var ambient: CPUParticles2D
var bursts: Array[CPUParticles2D] = []
var glow: Texture2D
static func target(k: int,t: float) -> Vector2:
	if k<0 or k>=CAP: return Vector2.INF
	return Vector2(705.0+113.0*k+26.0*sin(t*(1.13+.12*k)+.65*k),516.0+10.0*sin(t*1.6+k))
static func target_anchor(k: int,t: float) -> Vector2: return target(k,t)+Vector2(0,-86)
static func in_circle(k: int,t: float) -> bool:
	return k>=0 and k<CAP and target(k,t).distance_to(AREA)<=176.0
static func mark_alive(k: int,t: float) -> bool:
	return in_circle(k,t) and t>=RECEIPT and t<RECEIPT+STATUS
static func field_envelope(t: float) -> float:
	return smoothstep(.60,1.15,t)*(1.0-smoothstep(2.08,2.52,t))
static func charge_envelope(t: float) -> float:
	return smoothstep(.02,.22,t)*(1.0-smoothstep(.76,.98,t))
static func contact_envelope(t: float) -> float:
	return smoothstep(RECEIPT,1.45,t)*(1.0-smoothstep(1.64,1.92,t))
func _particle_texture() -> Texture2D:
	var img:=Image.create(64,64,false,Image.FORMAT_RGBA8)
	for y in range(64):
		for x in range(64):
			var d: float=Vector2(x-31.5,y-31.5).length()/31.5
			img.set_pixel(x,y,Color(1,1,.94,exp(-9.0*d*d)*(1.0-smoothstep(.72,1.0,d))))
	return ImageTexture.create_from_image(img)
func _emitter(n: int, life: float, speed: float, tint: Color) -> CPUParticles2D:
	var p:=CPUParticles2D.new()
	p.amount=n
	p.lifetime=life
	p.texture=glow
	p.color=tint
	p.direction=Vector2.RIGHT
	p.spread=180.0
	p.gravity=Vector2.ZERO
	p.initial_velocity_min=speed*.28
	p.initial_velocity_max=speed
	p.tangential_accel_min=38.0
	p.tangential_accel_max=85.0
	p.emitting=false
	return p
func _ready() -> void:
	custom_minimum_size=Vector2(1280,720)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	glow=_particle_texture()
	shader_mat=ShaderMaterial.new()
	shader_mat.shader=FLOW
	var field:=ColorRect.new()
	field.color=Color.WHITE
	field.position=AREA-Vector2(235,198)
	field.size=Vector2(470,320)
	field.mouse_filter=Control.MOUSE_FILTER_IGNORE
	field.material=shader_mat
	add_child(field)
	ambient=_emitter(78,.68,130.0,Color(.4,1,.85,.5))
	ambient.position=AREA+Vector2(0,-30)
	ambient.emission_shape=CPUParticles2D.EMISSION_SHAPE_SPHERE
	ambient.emission_sphere_radius=88
	add_child(ambient)
	for k in range(CAP):
		var p:=_emitter(14,.32,78.0,Color(1,1,.83,.82))
		p.one_shot=true
		p.explosiveness=.85
		add_child(p)
		bursts.append(p)
	set_process(true)
	print("VFX_PAF05_R4_READY true_runtime_particles=true shader_flow=true procedural_ribbons=true")
func _process(delta: float) -> void:
	var last: float=clock
	clock=fposmod(clock+maxf(delta,0.0),LOOP)
	shader_mat.set_shader_parameter("activity",field_envelope(clock))
	shader_mat.set_shader_parameter("clock",clock)
	ambient.emitting=clock>.7 and clock<2.1
	for k in range(CAP):
		var p: CPUParticles2D=bursts[k]
		p.position=target_anchor(k,clock)
		if last<RECEIPT and clock>=RECEIPT and in_circle(k,clock):
			p.restart()
			p.emitting=true
		if clock>1.65: p.emitting=false
	queue_redraw()
func _sweep(k: int,u: float,t: float,ext: float) -> Vector2:
	var a: float=k*TAU/4.0+t*.92+1.21*u-1.32
	var r: float=18.0+153.0*u*ext
	return AREA+Vector2(cos(a)*r,sin(a)*r*.47-38.0*(1.0-u))
func _ribbons(t: float) -> void:
	var f: float=field_envelope(t)
	if f<.006: return
	# Individual wind blades are GENERATED per time from their moving head/tail;
	# no picture is warped or enlarged to fake animation.
	for k in range(4):
		var curve: Array[Vector2]=[]
		for j in range(31): curve.append(_sweep(k,j/30.0,t,f))
		for layer in range(3):
			var wm: float=[1.65,1.0,.15][layer]
			var alpha: float=[.19,.45,.82][layer]*f
			var col: Color=[Color(.09,.92,.78,alpha),Color(.22,.97,.75,alpha),Color(.96,1,.89,alpha)][layer]
			# Draw one convex ribbon segment at a time. A single highly curved
			# polygon self-intersects and Godot triangulation correctly rejects it.
			for j in range(30):
				var u0: float=j/30.0
				var u1: float=(j+1)/30.0
				var dir: Vector2=(curve[j+1]-curve[j]).normalized()
				var norm: Vector2=Vector2(-dir.y,dir.x)
				var w0: float=(3.0+18.0*pow(sin(PI*u0),1.2))*(1.0-.54*u0)*wm
				var w1: float=(3.0+18.0*pow(sin(PI*u1),1.2))*(1.0-.54*u1)*wm
				var quad:=PackedVector2Array([
					curve[j]+norm*w0,
					curve[j+1]+norm*w1,
					curve[j+1]-norm*w1*.56,
					curve[j]-norm*w0*.56
				])
				draw_colored_polygon(quad,col)
		var u: float=fposmod((t-.6)+k*.26,1.0)
		var h: Vector2=_sweep(k,u,t,f)
		draw_line(h,_sweep(k,minf(1.0,u+.13),t,f),Color(.99,1,.86,.89*f),3,true)
		draw_texture_rect(glow,Rect2(h-Vector2(15,15),Vector2(30,30)),false,Color(.8,1,.8,.55*f))
func _draw() -> void:
	var t: float=clock
	draw_texture_rect(BACK,Rect2(0,0,1280,720),false)
	draw_texture_rect_region(ACTOR,Rect2(Vector2(315,554)-Vector2(72,163),Vector2(144,163)),Rect2(0,0,320,384),Color(.97,.94,.88))
	var c: float=charge_envelope(t)
	if c>.005:
		for k in range(3):
			var a: float=t*6.0+k*TAU/3.0
			var p: Vector2=HAND+Vector2(cos(a),sin(a))*(30-20*smoothstep(.10,.86,t))
			draw_line(p,p+(HAND-p).normalized()*22,Color(.24,1,.85,.64*c),4.5,true)
			draw_line(p,p+(HAND-p).normalized()*17,Color(1,1,.88,.92*c),1.5,true)
		draw_texture_rect(glow,Rect2(HAND-Vector2(30,30),Vector2(60,60)),false,Color(.7,1,.84,.5*c))
	var f: float=field_envelope(t)
	if f>.005:
		for j in range(8):
			var a: float=j*TAU/8.0
			var p0: Vector2=AREA+Vector2(162*cos(a),67*sin(a))
			var p1: Vector2=AREA+Vector2(162*cos(a+.39),67*sin(a+.39))
			draw_line(p0,p1,Color(1,.81,.43,.36*f),2.0,true)
	_ribbons(t)
	var count: int=maxi(1,MONSTER.get_frame_count("walk"))
	for k in range(CAP):
		var q: Vector2=target(k,t)
		var texture: Texture2D=MONSTER.get_frame_texture("walk",(int(t*12)+k*3)%count)
		draw_texture_rect(texture,Rect2(q-Vector2(48,124),Vector2(96,124)),false)
		var v: float=contact_envelope(t)
		if v>.005 and in_circle(k,t):
			var center: Vector2=target_anchor(k,t)
			for j in range(6):
				var a: float=j*TAU/6.0
				var d:=Vector2(cos(a),sin(a))
				draw_line(center+d*13,center+d*(30+12*(1-v)),Color(.34,1,.87,.65*v),3,true)
			draw_texture_rect(glow,Rect2(center-Vector2(28,28),Vector2(56,56)),false,Color(1,1,.84,.46*v))
		if mark_alive(k,t):
			var b: Vector2=q+Vector2(0,-149)
			var opacity: float=.78+.10*sin((t-RECEIPT)*2.5+k)
			draw_arc(b,16,0,TAU,24,Color(1,.83,.46,opacity),1.8,true)
			for j in range(3):
				var a: float=j*TAU/3.0+.3
				var tip:=b+Vector2(cos(a),sin(a))*10.0
				draw_line(tip,tip+Vector2(-sin(a),cos(a))*8.5,Color(.37,1,.85,opacity),2.7,true)
