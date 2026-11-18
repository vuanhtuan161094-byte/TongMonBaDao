extends "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r2/phu_cot_co_tien_a.gd"
## POI18 Hybrid R3.2: sprite = Jade Gu BODY, Godot only supplements
## transparent trail/particles/soft core light, target-bound wrap; LAB only.
## R2C gather, burst and mark assets unchanged. No combat/status writes.
const R32_ATLAS := "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r32/assets/poi18_gu_16.png"
const R32_HEAD_LOCAL := Vector2(80.0,-8.0)
const R32_ENTRY_SECONDS := 0.16
static func head_offset(dim: Vector2) -> Vector2:
    return Vector2(R32_HEAD_LOCAL.x*dim.x/320.0,R32_HEAD_LOCAL.y*dim.y/256.0)
func _ready() -> void:
    super._ready()
    if not ResourceLoader.exists(R32_ATLAS):
        push_error("POI18_HYBRID_R32_MISSING_ATLAS")
        set_process(false)
        return
    var tex:=load(R32_ATLAS) as Texture2D
    if tex==null or tex.get_size()!=Vector2(1280,1024):
        push_error("POI18_HYBRID_R32_BAD_ATLAS")
        set_process(false)
        return
    gu_frames.clear()
    for i in range(16):
        gu_frames.append(_atlas(tex,i,Vector2(320,256)))
    print("POI18_HYBRID_R32_READY frames=16 r2_frozen=true moving_WALK_target=true receipt=false owner_pending=true")
    queue_redraw()
func _gu(pos: Vector2, dim: Vector2, frame: float, gain: float) -> void:
    _pose(gu_frames,pos-head_offset(dim),dim,frame,gain)
func _glow(pos: Vector2,gain: float) -> void:
    draw_circle(pos,21.,Color(.07,.65,.44,.055*gain))
    draw_circle(pos,12.,Color(.16,.91,.66,.12*gain))
    draw_circle(pos,5.,Color(.93,1.,.82,.18*gain))
func _soft_trail(t: float) -> void:
    var start:=maxf(RELEASE_AT,t-.20)
    var stop:=minf(t,CONTACT_AT)
    if stop<=start:return
    var path:=PackedVector2Array()
    for i in range(13):
        path.append(projectile_pos(lerpf(start,stop,float(i)/12.)))
    draw_polyline(path,Color(.08,.71,.52,.10),10.,true)
    draw_polyline(path,Color(.21,.92,.67,.13),5.,true)
    draw_polyline(path,Color(.86,1.,.84,.20),1.4,true)
    for i in range(7):
        var dt:=minf(stop,start+float(i)*.027)
        var p:=projectile_pos(dt)
        var off:=Vector2(0,9*sin(14.*dt+float(i)))
        draw_circle(p+off,1.15+float(i%3)*.2,Color(.98,.81,.49,.12+.03*float(i%3)))
func _back_wrap(p: Vector2,gain: float) -> void:
    draw_arc(p+Vector2(0,-4),45.,.11*PI,.90*PI,24,Color(.11,.76,.53,.13*gain),1.9,true)
    draw_arc(p+Vector2(0,1),37.,.13*PI,.81*PI,20,Color(.91,.76,.37,.10*gain),1.3,true)
func _front_wrap(p: Vector2,t: float,gain: float) -> void:
    var u:=t-CONTACT_AT
    draw_arc(p+Vector2(0,-3),40.+3.*sin(u*3.),PI*.95,PI*1.96,29,Color(.25,.95,.71,.35*gain),2.,true)
    draw_arc(p,33.+4.*cos(u*2.),PI*.10,PI*.84,21,Color(.92,.79,.41,.29*gain),1.5,true)
    for i in range(4):
        var a:=u*2.1+float(i)*TAU/4.
        draw_circle(p+Vector2(cos(a)*38.,sin(a)*26.),1.4,Color(.93,1.,.76,.26*gain))
func _draw() -> void:
    var t:=clock
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    var contact:=target_foot(t)+Vector2(0,-82)
    if t>=CONTACT_AT and t<MARK_FADE_END:
        _back_wrap(contact,mark_gain(t))
    _draw_monster(target_foot(t),t)
    _draw_monster(decoy_foot(t),t+.22)
    if gather_frames.size()!=8 or gu_frames.size()!=16 or burst_frames.size()!=12 or seal_frames.size()!=12:return
    _draw_disciple()
    if t<RELEASE_AT:
        var q:=smoothstep(0.0,.12,t)*(1.0-smoothstep(CAST_END,RELEASE_AT,t))
        _pose(gather_frames,CASTER_FOOT+Vector2(49,-89),Vector2(184,178),clampf(t/CAST_END*7,0,7),q*.94)
    if t>=CAST_END and t<CONTACT_AT:
        var gain:=smoothstep(CAST_END,RELEASE_AT+.05,t)
        _soft_trail(t)
        var p:=projectile_pos(t)
        _glow(p,gain)
        _gu(p,Vector2(262,205),flight_fraction(t)*15.,.96*gain)
    if t>=CONTACT_AT and t<CONTACT_AT+R32_ENTRY_SECONDS:
        var q:=smoothstep(CONTACT_AT,CONTACT_AT+R32_ENTRY_SECONDS,t)
        var dim:=Vector2(262,205)*(1.-.76*q)
        _gu(target_foot(t)+Vector2(-13,-70),dim,15.,.78*(1.-q))
    if t>=CONTACT_AT and t<IMPACT_FADE_AT:
        var u:=clampf((t-CONTACT_AT)/(IMPACT_FADE_AT-CONTACT_AT),0,1)
        _pose(burst_frames,target_foot(t)+Vector2(0,-81),Vector2(226,215),u*11.,.96*(1.-smoothstep(.78,1.,u)))
    if t>=CONTACT_AT and t<MARK_FADE_END:
        var m:=mark_gain(t)
        _front_wrap(contact,t,m*.68)
        _pose(seal_frames,target_foot(t)+Vector2(0,-89),Vector2(126,126),fposmod((t-CONTACT_AT)*6.,12.),.92*m)
