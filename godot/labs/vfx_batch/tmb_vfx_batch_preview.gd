extends Control
## VFX Batch Stage 1: 2196 mapped skill IDs, 204 cast family PREVIEWS, 216 event-only gates.
## Original 12 school-specific sprite motifs and 2 poison-branch motifs. Art NOT mass-approved.
## OWNER_APPROVED_LAB_LOCKED source scenes are NEVER overwritten by generic preview.
## LAB ONLY. No Combat V2, HP, targeting, save, economy, status application, or rigging.
const MANIFEST_PATH := "res://labs/vfx_batch/manifest.json"
const ACTOR: Texture2D = preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const TEX := {
    "poison": preload("res://labs/vfx_batch/assets/needle.svg"),
    "talisman": preload("res://labs/vfx_batch/assets/talisman.svg"),
    "sword": preload("res://labs/vfx_batch/assets/sword.svg"),
    "bow": preload("res://labs/vfx_batch/assets/bow.svg"),
    "fist": preload("res://labs/vfx_batch/assets/fist.svg"),
    "blade": preload("res://labs/vfx_batch/assets/blade.svg"),
    "dual_blade": preload("res://labs/vfx_batch/assets/dual_blade.svg"),
    "spear": preload("res://labs/vfx_batch/assets/spear.svg"),
    "palm": preload("res://labs/vfx_batch/assets/palm.svg"),
    "curse": preload("res://labs/vfx_batch/assets/curse.svg"),
    "formation": preload("res://labs/vfx_batch/assets/formation.svg"),
    "summon": preload("res://labs/vfx_batch/assets/summon.svg"),
    "lotus": preload("res://labs/vfx_batch/assets/lotus.svg"),
    "vial": preload("res://labs/vfx_batch/assets/vial.svg"),
    "gu": preload("res://labs/combat_lab/poison03/assets/fu_cot_gu_master.svg"),
    "cloud": preload("res://labs/combat_lab/poison04/assets/co_vu_painted_cloud.svg"),
    "moth": preload("res://labs/combat_lab/poison04/assets/co_vu_gu_moth.svg"),
}
const PAGE_SECONDS := 3.60
const PREVIEW_RELEASE := 0.53
const PREVIEW_CONTACT := 1.71
const PREVIEW_FADE := 3.24
const CARD_WIDTH := 604.0
const CARD_HEIGHT := 270.0
const SCHOOL_COLORS := {
    "poison": Color("9bea9f"),
    "talisman": Color("edc483"),
    "sword": Color("bceeff"),
    "bow": Color("ddceaa"),
    "fist": Color("e5b4a3"),
    "blade": Color("ffacaa"),
    "dual_blade": Color("d1afff"),
    "spear": Color("9fe3e4"),
    "palm": Color("b0dff8"),
    "curse": Color("c2a1ef"),
    "formation": Color("bdf4b9"),
    "summon": Color("c7d7ef"),
}
var manifest: Dictionary = {}
var family_by_id: Dictionary = {}
var skill_by_id: Dictionary = {}
var playlist: Array[Dictionary] = []
var mode := "poison"
var elapsed := 0.0
var paused := false
var _radial: Texture2D
var _error := ""

static func phase_at(t: float) -> String:
    if t < PREVIEW_RELEASE: return "charge"
    if t < PREVIEW_CONTACT: return "flight"
    if t < PREVIEW_FADE: return "contact"
    return "fade"

static func travel_at(t: float) -> float:
    return smoothstep(PREVIEW_RELEASE, PREVIEW_CONTACT, t)

static func visual_kind(f: Dictionary) -> String:
    var effect := str(f.get("effect",""))
    var slot := str(f.get("slot",""))
    if effect == "heal" or effect == "cleanse": return "support"
    if effect == "guard": return "guard"
    if effect == "summon": return "summon_visual_only"
    if effect == "mobility" or slot == "mobility": return "mobility_visual_only"
    if effect == "formation_zone": return "zone_visual_only"
    if effect == "mark" or effect == "slow": return "mark_visual_only"
    if effect == "poison": return "poison_visual_only"
    return "attack_visual_only"

static func asset_key(f: Dictionary) -> String:
    var school := str(f.get("school",""))
    var branch := str(f.get("branch",""))
    var effect := str(f.get("effect",""))
    var slot := str(f.get("slot",""))
    if school == "poison":
        if effect == "heal" or effect == "cleanse": return "lotus"
        if branch == "duoc_doc": return "vial"
        if branch == "co_doc":
            if str(f.get("shape","")) == "circle": return "cloud"
            return "gu"
        if slot == "mobility": return "moth"
        return "poison"
    return school

func _ready() -> void:
    custom_minimum_size = Vector2(1280, 720)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _radial = _create_radial()
    _load_manifest()
    mode = OS.get_environment("TMB_VFX_BATCH_MODE")
    if mode.is_empty(): mode = "poison"
    _build_playlist()
    set_process(true)
    queue_redraw()
    print("VFX_BATCH_READY mode=",mode," samples=",playlist.size(),
        " skills=",skill_by_id.size()," families=",family_by_id.size()," error=",_error)

func _load_manifest() -> void:
    if not FileAccess.file_exists(MANIFEST_PATH):
        _error = "MISSING MANIFEST"
        push_error("VFX_BATCH_MISSING_MANIFEST")
        return
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
    if not parsed is Dictionary:
        _error = "INVALID MANIFEST"
        push_error("VFX_BATCH_INVALID_MANIFEST")
        return
    manifest = parsed
    for f in manifest.get("masters", []):
        if f is Dictionary:
            family_by_id[str(f.get("id",""))] = f
    for entry in manifest.get("skills", []):
        if entry is Array and entry.size() >= 9:
            skill_by_id[str(entry[0])] = entry

func _build_playlist() -> void:
    playlist.clear()
    var families: Array = manifest.get("masters", [])
    if mode == "poison":
        for f in families:
            if f is Dictionary and f.get("school") == "poison" and f.get("status") == "BATCH_PREVIEW_UNREVIEWED" and f.get("kind") == "CAST_MASTER":
                playlist.append(f)
    elif mode == "schools":
        for school in manifest.get("school_order", []):
            var choices: Array[Dictionary] = []
            for f in families:
                if f is Dictionary and f.get("school") == school and f.get("status") == "BATCH_PREVIEW_UNREVIEWED" and f.get("kind") == "CAST_MASTER" and f.get("branch") != "shared":
                    choices.append(f)
            if choices.size() > 0:
                playlist.append(choices[0])
                var first_effect := str(choices[0].get("effect", ""))
                var second: Dictionary = choices[choices.size() - 1]
                for c in choices:
                    if str(c.get("effect", "")) != first_effect and c.get("branch") != choices[0].get("branch"):
                        second = c
                        break
                playlist.append(second)
    elif mode == "all":
        for f in families:
            if f is Dictionary and f.get("kind") == "CAST_MASTER" and f.get("status") == "BATCH_PREVIEW_UNREVIEWED":
                playlist.append(f)
    else:
        var requested := OS.get_environment("TMB_VFX_BATCH_SKILL_ID")
        if skill_by_id.has(requested):
            var row: Array = skill_by_id[requested]
            var f: Dictionary = family_by_id.get(str(row[1]), {})
            if not f.is_empty() and f.get("kind") == "CAST_MASTER":
                playlist.append(f)
        elif family_by_id.has(requested):
            var f: Dictionary = family_by_id[requested]
            if f.get("kind") == "CAST_MASTER":
                playlist.append(f)
        if playlist.is_empty():
            _error = "EXACT SKILL NOT FOUND"
            push_error("VFX_BATCH_INVALID_SKILL_SELECTION")
    if playlist.is_empty() and _error.is_empty():
        _error = "EMPTY CAST PLAYLIST"
        push_error("VFX_BATCH_NO_PLAYLIST")

func get_family(id: String) -> Dictionary:
    return family_by_id.get(id, {})

func get_skill(id: String) -> Array:
    return skill_by_id.get(id, [])

func _create_radial() -> Texture2D:
    var im := Image.create(80,80,false,Image.FORMAT_RGBA8)
    for y in range(80):
        for x in range(80):
            var d := (Vector2(float(x),float(y)) - Vector2(39.5,39.5))/39.5
            var alpha := exp(-5.5*d.length_squared())*(1.0-smoothstep(0.68,1.0,d.length()))
            im.set_pixel(x,y,Color(1,1,1,clampf(alpha,0.0,1.0)))
    return ImageTexture.create_from_image(im)

func _process(delta: float) -> void:
    if paused: return
    elapsed += maxf(0.0,delta)
    if playlist.size() > 0:
        elapsed = fposmod(elapsed, PAGE_SECONDS*float(ceili(float(playlist.size())/4.0)))
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey or not event.pressed or event.echo: return
    if event.keycode == KEY_SPACE:
        elapsed = 0.0
    elif event.keycode == KEY_P:
        paused = not paused
    elif event.keycode == KEY_LEFT:
        elapsed = maxf(0.0,elapsed-PAGE_SECONDS)
    elif event.keycode == KEY_RIGHT:
        elapsed += PAGE_SECONDS
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("0e1420"))
    draw_rect(Rect2(0,0,1280,79),Color("14232a"))
    _text(Vector2(25,32),"TMB / VFX FAMILY BATCH 01 / ORIGINAL SPRITE LIBRARY",23,Color("e8f4ed"))
    _text(Vector2(25,58),"204 CAST FAMILY PREVIEW SYSTEM  |  216 EVENT-ONLY GATES  |  V63 OFF / LAB ONLY",13,Color("a0b9c1"))
    if not _error.is_empty():
        _text(Vector2(50,380),_error,25,Color("ffbbbb"))
        return
    if playlist.is_empty(): return
    var page := int(floor(elapsed/PAGE_SECONDS))
    var t := fposmod(elapsed,PAGE_SECONDS)
    var total_pages := ceili(float(playlist.size())/4.0)
    for i in range(4):
        var n := page*4+i
        var box := Rect2(Vector2(22.0+float(i%2)*630.0,91.0+float(i/2)*283.0),Vector2(CARD_WIDTH,CARD_HEIGHT))
        if n < playlist.size():
            _card(playlist[n],box,t,n)
        else:
            draw_rect(box,Color("182832"))
            draw_rect(box,Color("334b51"),false,1.0)
    _text(Vector2(23,686),"MODE: "+mode.to_upper()+"  |  PAGE %d/%d  |  SPACE REPLAY / P PAUSE / ARROWS STEP" % [page+1,total_pages],14,Color("aec4c8"))
    _text(Vector2(1065,686),"DRAFT / NO PVE",14,Color("d6b89c"))

func _card(f: Dictionary, box: Rect2, t: float, n: int) -> void:
    var school := str(f.get("school","poison"))
    var school_color: Color = SCHOOL_COLORS.get(school,Color("a4b4d2"))
    var key := asset_key(f)
    var tex: Texture2D = TEX.get(key, TEX["poison"])
    var seed := int(f.get("seed",1))
    var u := travel_at(t)
    var is_circle := str(f.get("shape","")) == "circle"
    var kind := visual_kind(f)
    var support := kind == "support" or kind == "guard"
    var zone := kind == "zone_visual_only"
    var ult := str(f.get("slot","")) == "ultimate"
    draw_rect(box,Color("18232d"))
    draw_rect(box,school_color.darkened(0.58),false,1.25)
    draw_rect(Rect2(box.position,Vector2(box.size.x,4.0)),school_color*Color(1,1,1,0.78))
    _text(box.position+Vector2(15,27),str(f.get("name","?")),18,Color("e4eced"))
    _text(box.position+Vector2(16,49),school.to_upper()+"  /  "+str(f.get("branch","")).to_upper()+"  /  "+str(f.get("slot","")).to_upper(),12,school_color)
    _text(box.position+Vector2(365,49),str(f.get("effect",""))+"  /  "+str(f.get("shape","")),12,Color("9db6bc"))
    var field := Rect2(box.position+Vector2(11,58),Vector2(box.size.x-22.0,192.0))
    draw_rect(field,Color("0d1722"))
    for line in range(5):
        var y := field.position.y+27.0+float(line)*36.0
        draw_line(Vector2(field.position.x,y),Vector2(field.end.x,y+8.0),Color("647f8c",0.11),1.0)
    var base := field.position
    var caster := base+Vector2(106,166)
    var enemy := base+Vector2(442,163)
    var enemy2 := enemy+Vector2(71,-4)
    var enemy3 := enemy+Vector2(-69,11)
    _halo(caster+Vector2(0,6),44.0,Color("0b131d",0.65))
    _halo(enemy+Vector2(0,6),42.0,Color("0b131d",0.65))
    _actor(caster,0.34,Color.WHITE)
    _actor(enemy,0.28,Color("bac8cf"))
    if is_circle:
        _actor(enemy2,0.24,Color("a9a6bf",0.83))
        _actor(enemy3,0.24,Color("a6c0a7",0.86))
    var from := caster+Vector2(27,-48)
    var dest := enemy+Vector2(-1,-36)
    if support:
        dest = caster+Vector2(1,-42) if kind=="guard" else enemy+Vector2(0,-37)
    if zone:
        dest = enemy+Vector2(-5,-2)
    var path := from.lerp(dest,u)+Vector2(0,-24.0*sin(PI*u))
    var early := smoothstep(0.0,0.30,t)*(1.0-smoothstep(PREVIEW_CONTACT-0.16,PREVIEW_CONTACT+0.12,t))
    var impact := smoothstep(PREVIEW_CONTACT-0.12,PREVIEW_CONTACT+0.19,t)*(1.0-smoothstep(2.52,PREVIEW_FADE,t))
    var is_blade := school == "sword" or school == "blade" or school == "dual_blade"
    var is_arrow := school == "bow" or school == "spear" or key == "poison"
    var is_seal := school == "talisman" or school == "curse" or school == "formation"
    if t < PREVIEW_CONTACT+0.12 and early>0.003:
        var pos := path if t>=PREVIEW_RELEASE else from
        var scale := (0.083 if t < PREVIEW_RELEASE else 0.112+0.045*u)*(1.13 if ult else 1.0)
        if key == "cloud": scale*=1.42
        var angle := -0.18+0.10*sin(t*7.5+float(seed%7))
        if is_blade: angle = -0.66+0.15*sin(t*3.0)
        if is_arrow: angle = -0.76+0.05*sin(t*6.0)
        if is_seal: angle = 0.08*sin(t*4.0)
        if support: angle = 0.04*sin(t*3.0)
        for j in range(3):
            var lag := float(j+1)*0.074
            if t>PREVIEW_RELEASE+lag and t<PREVIEW_CONTACT and not support and not zone:
                var pu := travel_at(t-lag)
                var at := from.lerp(dest,pu)+Vector2(0,-24.0*sin(PI*pu))
                _paint(tex,at,scale*(0.77-float(j)*0.12),angle,Color(school_color,early*(0.16-float(j)*0.04)))
        _halo(pos,34.0+17.0*u,Color(school_color,early*0.19))
        _paint(tex,pos,scale,angle,Color(1,1,1,early*0.91))
    if impact>0.002:
        var v := clampf((t-PREVIEW_CONTACT)/maxf(0.01,PREVIEW_FADE-PREVIEW_CONTACT),0.0,1.0)
        var peak := smoothstep(0.0,0.18,v)
        var corona := (0.85+0.08*sin(v*13.0))*(1.0-smoothstep(0.68,1.0,v))
        var fx_pos := dest
        var sz := (0.145+0.018*float(seed%4))*(1.13 if ult else 1.0)*peak
        if is_circle:
            fx_pos = enemy+Vector2(0,-31)
            sz = (0.33 if key=="cloud" else 0.23)*(1.14 if ult else 1.0)*peak
        if zone:
            fx_pos = enemy+Vector2(0,5)
            sz = 0.25*(1.12 if ult else 1.0)*peak
        if support:
            sz = 0.20*(1.12 if ult else 1.0)*peak
        _halo(fx_pos,49.0+19.0*v,Color(school_color,impact*0.16))
        var angle2 := 0.025*sin(v*7.0+float(seed%5))
        if is_blade: angle2 = -0.44+0.21*v
        if is_arrow: angle2 = -0.67
        if is_seal: angle2 = 0.11*sin(v*4.0)
        _paint(tex,fx_pos,sz,angle2,Color(1,1,1,impact*(0.53+0.19*corona)))
        # Repaint dummies over the low-lying area layer. No VFX is allowed to erase the target.
        if is_circle or support or zone:
            if kind=="guard":
                _actor(caster,0.34,Color.WHITE)
            else:
                _actor(enemy,0.28,Color("bac8cf"))
                if is_circle:
                    _actor(enemy2,0.24,Color("a9a6bf",0.83))
                    _actor(enemy3,0.24,Color("a6c0a7",0.86))
        for j in range(7 if ult else 4):
            var k := float(j)
            var phi := k*2.399+float(seed%11)*0.22
            var p := fx_pos+Vector2(cos(phi)*(17.0+46.0*v),sin(phi)*(13.0+35.0*v))
            _halo(p,4.5+2.0*(1.0-v),Color(school_color,impact*0.28))
    _text(box.position+Vector2(17,263),str(n+1).pad_zeros(3)+"  |  "+phase_at(t).to_upper()+"  |  "+str(f.get("status","BATCH_PREVIEW")).replace("BATCH_PREVIEW_UNREVIEWED","ART PENDING"),11,Color("a7bdb9"))

func _actor(at: Vector2, scale: float, tint: Color) -> void:
    var origin := at-Vector2(160,351)*scale
    draw_texture_rect_region(ACTOR,Rect2(origin,Vector2(320,384)*scale),Rect2(0,0,320,384),tint)

func _paint(tex: Texture2D,center: Vector2,amount: float,rot: float,tint: Color) -> void:
    draw_set_transform(center,rot,Vector2.ONE*amount)
    draw_texture_rect(tex,Rect2(-256,-256,512,512),false,tint)
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _halo(center: Vector2,r: float,tint: Color) -> void:
    draw_texture_rect(_radial,Rect2(center-Vector2.ONE*r,Vector2.ONE*r*2.0),false,tint)

func _text(at: Vector2,s: String,size: int,tint: Color) -> void:
    draw_string(ThemeDB.fallback_font,at,s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,tint)
