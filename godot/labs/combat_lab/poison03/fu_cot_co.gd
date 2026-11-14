extends Control
## VFX-POI-03: Phụ Cốt Cổ; new painted vector-textured beetle + bone seal.
## Exact skill: mark, single_target, target_limit=1, no actual damage/mark writes.
## Preview script only. Real PvE Combat V2 event integration is still HOLD.
## All art layers are Sprite2D or texture-based; NO rigging.
const SKILL_ID := "tmb.skill.poison.co_doc.active_01.human"
const CASTER := Vector2(324.0, 506.0)
const VICTIM := Vector2(893.0, 506.0)
const CAST_END := 0.45
const LAUNCH_AT := 0.60
const CONTACT_AT := 1.55
const MARK_HOLD_END := 2.60
const FADE_END := 3.12
const LOOP_SECONDS := 3.60
const GU_TEXTURE: Texture2D = preload("res://labs/combat_lab/poison03/assets/fu_cot_gu_master.svg")
const MARK_TEXTURE: Texture2D = preload("res://labs/combat_lab/poison03/assets/fu_cot_bone_seal.svg")
const JX_IMPACT: Texture2D = preload("res://assets/combat_v4/jx1_skill_fx/1fffed7e.webp")
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const IMPACT_FRAMES := 13
const IMPACT_FRAME_MS := 56
const TRAIL_COUNT := 5
var elapsed := 0.0
var paused := false
var _radial: Texture2D
var _gu: Sprite2D
var _gu_gloss: Sprite2D
var _trails: Array[Sprite2D] = []
var _seal: Sprite2D
var _seal_highlight: Sprite2D
var _target_actor: Sprite2D
var _impact_rects: Array = []

static func phase_at(t: float) -> String:
    if t < CAST_END: return "charge"
    if t < LAUNCH_AT: return "release"
    if t < CONTACT_AT: return "flight"
    if t < MARK_HOLD_END: return "contact"
    if t < FADE_END: return "dissolve"
    return "idle"

static func travel_at(t: float) -> float:
    if t <= LAUNCH_AT: return 0.0
    var q := clampf((t - LAUNCH_AT) / (CONTACT_AT - LAUNCH_AT), 0.0, 1.0)
    return q * q * (3.0 - 2.0 * q)

static func gu_gain(t: float) -> float:
    if t < 0.16 or t >= CONTACT_AT + 0.08: return 0.0
    return smoothstep(0.16, 0.37, t) * (1.0 - smoothstep(CONTACT_AT - 0.11, CONTACT_AT + 0.08, t))

static func mark_gain(t: float) -> float:
    if t < CONTACT_AT or t >= FADE_END: return 0.0
    return smoothstep(CONTACT_AT, CONTACT_AT + 0.20, t) * (1.0 - smoothstep(MARK_HOLD_END, FADE_END, t))

static func jx_frame(t: float) -> int:
    if t < CONTACT_AT: return -1
    var frame := int(floor((t - CONTACT_AT) * 1000.0 / float(IMPACT_FRAME_MS)))
    return frame if frame >= 0 and frame < IMPACT_FRAMES else -1

static func gu_position(t: float) -> Vector2:
    var start := CASTER + Vector2(69.0, -91.0)
    var finish := VICTIM + Vector2(-9.0, -61.0)
    var q := travel_at(t)
    var arch := -88.0 * sin(PI * q)
    var flutter := 10.0 * sin(q * PI * 5.0) * sin(q * PI)
    return start.lerp(finish, q) + Vector2(0.0, arch + flutter)

func _ready() -> void:
    custom_minimum_size = Vector2(1280.0, 720.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _make_radial()
    _read_jx_impact()
    for i in range(TRAIL_COUNT):
        var ghost := _sprite(GU_TEXTURE, 2, true)
        _trails.append(ghost)
    _gu = _sprite(GU_TEXTURE, 3, false)
    _gu_gloss = _sprite(GU_TEXTURE, 4, true)
    _seal = _sprite(MARK_TEXTURE, 5, false)
    _seal_highlight = _sprite(MARK_TEXTURE, 6, true)
    _target_actor = _make_target_actor()
    _update_sprites()
    set_process(true)
    queue_redraw()
    print("VFX_POI03_READY | ", SKILL_ID, " | mark=single_target | visual_only=true")

func _sprite(tex: Texture2D, z: int, additive: bool) -> Sprite2D:
    var item := Sprite2D.new()
    item.texture = tex
    item.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    item.z_index = z
    item.centered = true
    var material := CanvasItemMaterial.new()
    material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD if additive else CanvasItemMaterial.BLEND_MODE_MIX
    item.material = material
    add_child(item)
    item.visible = false
    return item

func _make_target_actor() -> Sprite2D:
    var spr := Sprite2D.new()
    var cut := AtlasTexture.new()
    cut.atlas = ACTOR
    cut.region = Rect2(0.0, 0.0, 320.0, 384.0)
    spr.texture = cut
    spr.centered = false
    spr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    spr.position = VICTIM - Vector2(160.0, 351.0) * 0.44
    spr.scale = Vector2.ONE * 0.44
    spr.modulate = Color("b0baca")
    spr.z_index = 3
    add_child(spr)
    return spr

func _make_radial() -> Texture2D:
    var img := Image.create(80, 80, false, Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var p := (Vector2(float(x), float(y)) - Vector2(39.5,39.5)) / 39.5
            var d := p.length()
            var alpha := exp(-6.4 * p.length_squared()) * (1.0 - smoothstep(0.68, 1.0, d))
            img.set_pixel(x,y,Color(1.0,1.0,1.0,clampf(alpha,0.0,1.0)))
    return ImageTexture.create_from_image(img)

func _read_jx_impact() -> void:
    var path := "res://assets/combat_v4/jx1_skill_fx/fx_manifest.json"
    if not FileAccess.file_exists(path):
        push_error("VFX_POI03_NO_JX_MANIFEST")
        return
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if raw is Dictionary:
        var effects: Dictionary = raw.get("effects", {})
        var effect: Dictionary = effects.get("jx_wudu_63_impact", {})
        _impact_rects = effect.get("rects",[])
    if _impact_rects.size() < 78: push_error("VFX_POI03_JX_RECTS_INVALID")

func _update_sprites() -> void:
    var t := elapsed
    var gain := gu_gain(t)
    var flight := t >= LAUNCH_AT and t < CONTACT_AT
    _gu.visible = gain > 0.005
    _gu_gloss.visible = _gu.visible
    if _gu.visible:
        var q := travel_at(t)
        var pos := gu_position(t)
        var wobble := 0.06 * sin(t * 18.5)
        var z := (0.19 + 0.15 * smoothstep(0.0,1.0,q)) if flight else (0.15 + 0.05 * smoothstep(0.16,0.50,t))
        _gu.position = pos
        _gu.rotation = PI * 0.5 + wobble
        _gu.scale = Vector2(z * (1.0 + 0.05 * sin(t * 23.0)), z)
        _gu.modulate = Color(1,1,1,gain * 0.98)
        _gu_gloss.position = pos
        _gu_gloss.rotation = _gu.rotation
        _gu_gloss.scale = _gu.scale * 1.02
        _gu_gloss.modulate = Color("a5ffbf", gain * 0.10)
        # A few real texture echoes, not stacked neon lines.
        for i in range(TRAIL_COUNT):
            var ghost := _trails[i]
            var age := (float(i)+1.0) * 0.055
            ghost.visible = flight and t - age >= LAUNCH_AT
            if ghost.visible:
                ghost.position = gu_position(t - age)
                ghost.rotation = PI * 0.5 + 0.06 * sin((t-age) * 18.5)
                ghost.scale = Vector2.ONE * (z * (0.92 - float(i)*0.055))
                ghost.modulate = Color("82c69f", gain * (0.14 - float(i) * 0.019))
    else:
        for ghost in _trails: ghost.visible = false
    var seal_strength := mark_gain(t)
    _seal.visible = seal_strength > 0.009
    _seal_highlight.visible = _seal.visible
    if _seal.visible:
        var q := clampf((t - CONTACT_AT) / maxf(0.01, MARK_HOLD_END - CONTACT_AT),0.0,1.0)
        var anchor := VICTIM + Vector2(1.0, -58.0) + Vector2(0.0, -8.0 * (1.0 - smoothstep(0.0,0.22,q)))
        _seal.position = anchor
        _seal.rotation = (-0.39 + 0.39 * smoothstep(0.0,0.38,q)) + 0.010 * sin(t * 5.0)
        _seal.scale = Vector2.ONE * (0.226 + 0.090 * exp(-8.0 * q) + 0.004 * sin(t*7.0))
        _seal.modulate = Color(1.0,1.0,1.0,seal_strength * 0.90)
        _seal_highlight.position = anchor
        _seal_highlight.rotation = _seal.rotation
        _seal_highlight.scale = _seal.scale * 1.09
        _seal_highlight.modulate = Color("a7ffc8", seal_strength * 0.18)

func _process(delta: float) -> void:
    if paused: return
    elapsed = fposmod(elapsed + maxf(0.0,delta), LOOP_SECONDS)
    _update_sprites()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
        _update_sprites()
    elif event.keycode == KEY_P:
        paused = not paused

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("101521"))
    draw_texture_rect(_radial,Rect2(96,126,1090,520),false,Color("365c4d",0.17))
    for i in range(10):
        var y := 279.0 + float(i)*39.0
        draw_line(Vector2(85,y),Vector2(1196,y+12),Color("67817b",0.09),1.0)
    for i in range(12):
        var x := 109.0+float(i)*99.0
        draw_line(Vector2(x,239),Vector2(x+92,651),Color("62737b",0.085),1.0)
    for i in range(58):
        var v := float(i)
        draw_circle(Vector2(96.0+fposmod(v*149.71,1080.0),287.0+fposmod(v*65.3,336.0)),0.75,Color("8fa49a",0.18))
    _halo(CASTER+Vector2(4.0,8.0),52.0,Color("0b111b",0.60))
    _halo(VICTIM+Vector2(2.0,7.0),52.0,Color("0b111b",0.60))
    var actor_cut := Rect2(0,0,320,384)
    var position := CASTER-Vector2(160,351)*0.44
    draw_texture_rect_region(ACTOR,Rect2(position,Vector2(320,384)*0.44),actor_cut,Color.WHITE)
    var charge := smoothstep(0.05,0.31,elapsed) * (1.0-smoothstep(CAST_END,0.73,elapsed))
    if charge > 0.009:
        var hand := CASTER+Vector2(69,-91)
        _halo(hand,58.0,Color("70f6a8",charge*0.39))
        _halo(hand,18.0,Color("f4ffd1",charge*0.70))
        for i in range(9):
            var v := float(i)
            var angle := v*2.399 +elapsed*2.2
            var offset := Vector2(cos(angle)*35.0,sin(angle)*28.0)
            _halo(hand+offset,6.0,Color("c5d8ff" if i%3==0 else "b9ffbe",charge*0.32))
    var t := elapsed
    if t >= LAUNCH_AT and t < CONTACT_AT:
        var p := gu_position(t)
        _halo(p,78.0,Color("91ffc1",gu_gain(t)*0.13))
        for i in range(7):
            var phi := float(i)*2.399+t*9.2
            var r := 25.0+11.0*sin(t*17.0+float(i))
            _halo(p+Vector2(cos(phi)*r,sin(phi)*r*0.62),7.0,
                Color("d6ffbf" if i%2==0 else "9b85ff",gu_gain(t)*0.30))
    if t >= CONTACT_AT and t < CONTACT_AT + 0.18:
        var hit := (t-CONTACT_AT)/0.18
        _halo(VICTIM+Vector2(1.0,-62.0),61.0+31.0*hit,
            Color("f6ffe0",(1.0-hit)*0.56))
    if t >= CONTACT_AT and t < CONTACT_AT+0.72 and _impact_rects.size()>=78:
        var idx := jx_frame(t)
        if idx >= 0:
            var offset := idx*6
            var region := Rect2(float(_impact_rects[offset]),float(_impact_rects[offset+1]),
                float(_impact_rects[offset+2]),float(_impact_rects[offset+3]))
            if region.size.x > 1.0 and region.size.y > 1.0:
                var pivot := Vector2(float(_impact_rects[offset+4]),float(_impact_rects[offset+5]))
                var sc := 1.83
                draw_texture_rect_region(JX_IMPACT, Rect2(VICTIM+Vector2(0,-63)-pivot*sc,region.size*sc),
                    region,Color(1,1,1,0.59))
    var mark := mark_gain(t)
    if mark > 0.008:
        for i in range(12):
            var phi := float(i)*2.399 + t*0.61
            var u := float(i)/11.0
            var r := 40.0+20.0*u
            var p := VICTIM+Vector2(cos(phi)*r, -60.0+sin(phi)*r*0.72)
            _halo(p,8.0,Color("d1ffc7" if i%2==0 else "b5a0ff",mark*0.22))
        _halo(VICTIM+Vector2(0,-58),63.0,Color("83f1bb",mark*0.16))
    if t >= MARK_HOLD_END and t < FADE_END:
        var fade := clampf((t-MARK_HOLD_END)/(FADE_END-MARK_HOLD_END),0,1)
        for i in range(13):
            var phi := float(i)*2.399
            var p := VICTIM+Vector2(cos(phi)*(26.0+88.0*fade),-59.0+sin(phi)*(19.0+56.0*fade)-40.0*fade)
            _halo(p,6.0+4.0*(1-fade),Color("cdffb3",(1.0-fade)*0.25))
    draw_string(ThemeDB.fallback_font,Vector2(38,46),
        "PHU COT CO / CO DOC",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e4ffe8"))
    draw_string(ThemeDB.fallback_font,Vector2(38,69),
        "ORIGINAL SPIRIT GU SPRITE  /  SINGLE TARGET MARK  /  SOURCE VL QUALITY STUDY",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("96b8b5"))
    draw_string(ThemeDB.fallback_font,Vector2(38,683),
        "VFX-POI-03 | GODOT 4.7.2 COMPATIBILITY | LAB ONLY | MARK IS VISUAL PREVIEW",
        HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("aac9c2"))

func _halo(center: Vector2, radius: float, tint: Color) -> void:
    draw_texture_rect(_radial,Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2.0),false,tint)
