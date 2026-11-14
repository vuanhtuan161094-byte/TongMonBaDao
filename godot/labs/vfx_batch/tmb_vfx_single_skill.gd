extends Control
## EXACT-SKILL FULL-SIZE GODOT VFX BATCH STUDY — 201 draft cast families.
## This is a 1280x720 visual-only LAB. NOT a live Combat V2 presentation adapter.
## Authored sprite materials, NOT giant SVG icons or procedural neon bodies. NO rigs.
const BATCH = preload("res://labs/vfx_batch/tmb_vfx_batch_preview.gd")
const MANIFEST := "res://labs/vfx_batch/manifest.json"
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const CASTER := Vector2(290.0,547.0)
const TARGETS := [Vector2(866.0,535.0),Vector2(988.0,555.0),Vector2(743.0,550.0)]
const CAST_END := 0.61
const ARRIVE_AT := 1.74
const IMPACT_END := 2.58
const FADE_END := 3.52
const LOOP_SECONDS := 4.20
const DEFAULT_ID := "tmb.skill.poison.doc_cham.active_01.human"
var elapsed := 0.0
var paused := false
var skill_id := ""
var entry: Dictionary = {}
var _radial: Texture2D
var _error := ""
var _tex: Texture2D
var _tone := Color("9bea9f")

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < ARRIVE_AT: return "travel"
    if t < IMPACT_END: return "contact"
    if t < FADE_END: return "dissolve"
    return "idle"

static func travel_at(t: float) -> float:
    return smoothstep(CAST_END,ARRIVE_AT,t)

func _ready() -> void:
    custom_minimum_size = Vector2(1280,720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _radial_texture()
    skill_id = OS.get_environment("TMB_VFX_BATCH_SKILL_ID")
    if skill_id.is_empty(): skill_id = DEFAULT_ID
    _load_entry()
    set_process(true)
    queue_redraw()
    print("VFX_BATCH_SINGLE_READY id=",skill_id," family=",entry.get("id","")," error=",_error," gameplay=false")

func _load_entry() -> void:
    if not FileAccess.file_exists(MANIFEST):
        _error="MISSING SKILL MANIFEST"
        push_error(_error)
        return
    var doc: Variant=JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not doc is Dictionary:
        _error="INVALID MANIFEST"
        push_error(_error)
        return
    var family_id := ""
    for row in doc.get("skills",[]):
        if row is Array and row.size()>1 and str(row[0])==skill_id:
            family_id=str(row[1])
            break
    if family_id.is_empty():
        _error="UNKNOWN CANONICAL SKILL ID"
        push_error(_error+": "+skill_id)
        return
    for f in doc.get("masters",[]):
        if f is Dictionary and f.get("id")==family_id:
            entry=f
            break
    if entry.is_empty() or entry.get("kind")!="CAST_MASTER":
        _error="NO CAST VFX (EVENT-ONLY OR MISSING)"
        push_error(_error)
        return
    if entry.get("status")=="OWNER_APPROVED_LAB_LOCKED":
        _error="USE LOCKED OWNER-APPROVED SCENE: "+str(entry.get("scene",""))
        return
    _tone=BATCH.SCHOOL_COLORS.get(str(entry.get("school","")),Color("b1d1df"))
    var key:=BATCH.asset_key(entry)
    _tex=BATCH.TEX.get(key,BATCH.TEX["sword"])
    if _tex==null:
        _error="MISSING PAINTED MOTIF "+key
        push_error(_error)

func _radial_texture() -> Texture2D:
    var img:=Image.create(96,96,false,Image.FORMAT_RGBA8)
    for y in range(96):
        for x in range(96):
            var p:Vector2=(Vector2(float(x),float(y))-Vector2(47.5,47.5))/47.5
            var a:=exp(-5.6*p.length_squared())*(1.0-smoothstep(0.69,1.0,p.length()))
            img.set_pixel(x,y,Color(1,1,1,clampf(a,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _process(delta: float) -> void:
    if paused:return
    elapsed=fposmod(elapsed+maxf(0.0,delta),LOOP_SECONDS)
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo:return
    if event.keycode==KEY_SPACE:
        elapsed=0.0
    elif event.keycode==KEY_P:
        paused=not paused
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("101722"))
    draw_rect(Rect2(0,0,1280,85),Color("142530"))
    _text(Vector2(35,41),"TMB / VFX-BATCH 01 / EXACT-SKILL GODOT PREVIEW",27,Color("e9fff2"))
    if not _error.is_empty():
        _text(Vector2(55,364),_error,20,Color("f0bdad"))
        return
    _text(Vector2(36,70),str(entry.get("name","?"))+"   /   "+str(entry.get("school","")).to_upper()+"   /   "+str(entry.get("effect",""))+"   /   "+str(entry.get("shape","")),16,_tone)
    draw_rect(Rect2(0,86,1280,574),Color("121c28"))
    for line in range(11):
        var py:=245.0+float(line)*34.0
        draw_line(Vector2(44,py),Vector2(1245,py+12),Color("8ea5a0",0.065),1.0)
    for line in range(13):
        var px:=53.0+float(line)*96.0
        draw_line(Vector2(px,253),Vector2(px+113,647),Color("788e9a",0.058),1.0)
    for dot in range(66):
        var k:=float(dot)
        draw_circle(Vector2(69+fposmod(k*175.27,1110),257+fposmod(k*73.17,363)),1.0,Color("c4dbba",0.16))
    var t:=elapsed
    var is_circle:=str(entry.get("shape",""))=="circle"
    var kind:=BATCH.visual_kind(entry)
    var supporting:=kind=="support" or kind=="guard"
    var zone:=kind=="zone_visual_only"
    var ultimate:=str(entry.get("slot",""))=="ultimate"
    var seed:=int(entry.get("seed",0))
    var hand:=CASTER+Vector2(60,-111)
    var target:=TARGETS[0]+Vector2(0,-70)
    if kind=="guard":
        target=CASTER+Vector2(0,-85)
    if zone:
        target=TARGETS[0]+Vector2(0,-22)
    var q:=travel_at(t)
    var flying:=hand.lerp(target,q)+Vector2(0,-85.0*sin(PI*q))
    var charge:=smoothstep(0.05,0.43,t)*(1.0-smoothstep(CAST_END,0.88,t))
    if charge>0.007:
        _halo(hand,88.0,Color(_tone,charge*0.22))
        _halo(hand,25.0,Color("fff8da",charge*0.26))
        _paint(_tex,hand,0.16+0.054*charge,0.10*sin(t*5.0),Color(1,1,1,charge*0.65))
        for i in range(7):
            var a:=float(i)*2.399+t*2.4
            _halo(hand+Vector2(cos(a)*34.0,sin(a)*22.0),7.0,Color(_tone,charge*0.26))
    var alpha:=smoothstep(CAST_END,CAST_END+0.16,t)*(1.0-smoothstep(ARRIVE_AT-0.13,ARRIVE_AT+0.12,t))
    if alpha>0.006:
        var ang:float=-0.62 if str(entry.get("school")) in ["sword","blade","dual_blade","bow","spear","poison"] else 0.1*sin(t*3.0)
        var sz:=0.21+0.13*q
        if BATCH.asset_key(entry)=="cloud":sz*=1.30
        for i in range(4):
            var old:=t-0.062*float(i+1)
            if old>CAST_END and old<ARRIVE_AT and not supporting and not zone:
                var u:=travel_at(old)
                _paint(_tex,hand.lerp(target,u)+Vector2(0,-85.0*sin(PI*u)),sz*(0.68-float(i)*0.10),
                    ang,Color(_tone,alpha*(0.19-float(i)*0.029)))
        _halo(flying,96.0,Color(_tone,alpha*0.16))
        _paint(_tex,flying,sz*(1.15 if ultimate else 1.0),ang,Color(1,1,1,alpha*0.90))
    var impact:=smoothstep(ARRIVE_AT-0.04,ARRIVE_AT+0.17,t)*(1.0-smoothstep(2.58,FADE_END,t))
    if impact>0.004:
        var after:=clampf((t-ARRIVE_AT)/maxf(0.01,FADE_END-ARRIVE_AT),0,1)
        var size:= (0.78 if is_circle else 0.46)*(1.13 if ultimate else 1.0)
        if BATCH.asset_key(entry)=="cloud":size*=1.20
        if supporting:size=0.67*(1.08 if ultimate else 1.0)
        if zone:size=0.74
        var focal := target
        if not is_circle and not supporting and not zone:
            focal += Vector2(76,-15)
        _halo(focal,167.0 if is_circle else 121.0,Color(_tone,impact*0.25))
        _paint(_tex,focal,size*(0.96+0.05*sin(after*8.0+float(seed%5))),
            0.08*sin(after*6.0),Color(1,1,1,impact*0.82))
        # These are presentation-only light motes. They never imply damage/status receipts.
        for i in range(11 if ultimate else 7):
            var a:=float(i)*2.399+float(seed%13)*0.21
            var pos:=focal+Vector2(cos(a)*(34+117*after),sin(a)*(29+96*after)-25*after)
            _halo(pos,7.0,Color(_tone,impact*0.26))
    # Put target sprite over the painted zone / impact base to retain full actor readability.
    _halo(CASTER+Vector2(0,8),59.0,Color("081118",0.48))
    _actor(CASTER,0.48,Color.WHITE)
    _halo(TARGETS[0]+Vector2(0,8),59.0,Color("081118",0.45))
    _actor(TARGETS[0],0.45,Color("cbd6dc"))
    if is_circle:
        _actor(TARGETS[1],0.41,Color("c3bfd6",0.85))
        _actor(TARGETS[2],0.41,Color("bdd1c6",0.84))
    if impact>0.006:
        var p:=TARGETS[0]+Vector2(0,-74)
        if kind=="guard":p=CASTER+Vector2(0,-75)
        for i in range(8):
            var ang:=float(i)*2.399+t*0.3
            _halo(p+Vector2(cos(ang)*58.0,sin(ang)*47.0),7.0,Color(_tone,impact*0.34))
        if is_circle:
            _halo(TARGETS[1]+Vector2(0,-76),49.0,Color(_tone,impact*0.14))
            _halo(TARGETS[2]+Vector2(0,-76),49.0,Color(_tone,impact*0.14))
    _text(Vector2(39,684),skill_id+"  |  "+phase_at(t).to_upper()+"  |  ORIGINAL SPRITE LAB / NOT AUTHORIZED COMBAT",13,Color("b1bdb9"))
    _text(Vector2(1116,684),"%0.2fs" % t,14,Color("b3c2bd"))

func _actor(center: Vector2,scale: float,tint: Color) -> void:
    var top_left:=center-Vector2(160,351)*scale
    draw_texture_rect_region(ACTOR,Rect2(top_left,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _paint(tex: Texture2D,center: Vector2,scale: float,rot: float,tint: Color) -> void:
    draw_set_transform(center,rot,Vector2.ONE*scale)
    draw_texture_rect(tex,Rect2(-256,-256,512,512),false,tint)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _halo(center: Vector2,size: float,tint: Color) -> void:
    draw_texture_rect(_radial,Rect2(center-Vector2.ONE*size,Vector2.ONE*size*2.0),false,tint)

func _text(at: Vector2,s: String,size: int,color: Color) -> void:
    draw_string(ThemeDB.fallback_font,at,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
