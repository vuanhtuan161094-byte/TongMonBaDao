extends RefCounted
## Receipt-driven, read-only renderer for the six existing Blade candidates.
## Explicit preview only, independent of combat authority and learning gates.
const PREVIEW_SETTING := "runtime/v8_blade_vfx_preview"
const ROOT := "res://assets/p3/vfx/blade_v8/"
const BINDINGS := {
    "tmb.skill.blade.cuong_dao.active_01.human":{"prefix":"pha_vay_khai_son_","shape":"single_target","limit":1,"count":1,"extent":180.0},
    "tmb.skill.blade.cuong_dao.active_02.human":{"atlas":"lien_son_tram_12cel.svg","shape":"circle","limit":3,"count":3,"extent":190.0},
    "tmb.skill.blade.cuong_dao.active_03.human":{"atlas":"cuu_trung_hoi_dao_12cel.svg","shape":"line","limit":3,"count":3,"extent":182.0},
    "tmb.skill.blade.cuong_dao.active_04.human":{"atlas":"cuong_dao_pha_vay_16cel.svg","shape":"single_target","limit":1,"count":4,"extent":182.0},
    "tmb.skill.blade.cuong_dao.ultimate.human":{"atlas":"cuu_trung_cuong_dao_12cel.svg","shape":"circle","limit":3,"count":3,"extent":210.0},
    "tmb.skill.blade.tram_phach_dao.active_01.human":{"atlas":"tram_phach_nhat_tuyen_12cel.svg","shape":"single_target","limit":1,"count":3,"extent":166.0}
}
const MAX_CASTS := 18
const MAX_CONTACTS := 48
const CONTACT_SECONDS := 0.18
const FADE_SECONDS := 0.18
var _encounter := ""
var _clock := 0.0
var _casts: Dictionary = {}
var _contacts: Array[Dictionary] = []
var _textures: Dictionary = {}

func reset() -> void:
    _encounter = ""
    _clock = 0.0
    _casts.clear()
    _contacts.clear()

func observe(events: Array[Dictionary],battle: MapBattleV2,enabled: bool) -> void:
    if battle == null or not enabled:
        reset()
        return
    if _encounter != battle.encounter_id:
        reset()
        _encounter = battle.encounter_id
    for event in events:
        if str(event.get("encounter_id","")) != _encounter:
            continue
        var id := str(event.get("skill_id",""))
        if not BINDINGS.has(id):
            continue
        var receipt := str(event.get("event_id",""))
        var cast_id := str(event.get("cast_id",""))
        var caster := str(event.get("caster",event.get("actor_id","")))
        var target := str(event.get("target",event.get("target_id","")))
        if receipt.is_empty() or cast_id.is_empty() or not battle.actors.has(caster) or not battle.actors.has(target):
            continue
        var actor: Dictionary = battle.actors[caster]
        var victim: Dictionary = battle.actors[target]
        if str(actor.get("side","")) != "disciple" or str(victim.get("side","")) != "monster":
            continue
        if not bool(actor.get("v63_combat_enabled",false)) or not bool(actor.get("v63_blade_combat_enabled",false)):
            continue
        var binding: Dictionary = BINDINGS[id]
        var kind := str(event.get("type",""))
        if kind == "skill_cast":
            if _casts.has(cast_id) or _casts.size() >= MAX_CASTS:
                continue
            if str(event.get("effect","")) != "damage" or str(event.get("shape","")) != binding["shape"] or int(event.get("target_limit",0)) != int(binding["limit"]):
                continue
            var duration := clampf(float(event.get("release_at",battle.now))-float(event.get("time",battle.now)),0.05,5.0)
            _casts[cast_id] = {"skill":id,"caster":caster,"target":target,"from":actor.get("position",Vector2.ZERO),"to":victim.get("position",Vector2.ZERO),"started":_clock,"duration":duration,"released":false,"released_at":0.0,"targets":{},"receipts":{}}
            continue
        if not _casts.has(cast_id):
            continue
        var cue: Dictionary = _casts[cast_id]
        if cue["skill"] != id or cue["caster"] != caster:
            continue
        if kind == "skill_release" and target == cue["target"] and not bool(cue["released"]):
            cue["released"] = true
            cue["released_at"] = _clock
        elif kind == "v63_skill_hit" and bool(cue["released"]) and float(event.get("damage",0.0)) > 0.0:
            var receipts: Dictionary = cue["receipts"]
            var targets: Dictionary = cue["targets"]
            if receipts.has(receipt) or (not targets.has(target) and targets.size() >= int(binding["limit"])):
                continue
            if binding["shape"] == "single_target" and target != cue["target"]:
                continue
            receipts[receipt] = true
            targets[target] = true
            if _contacts.size() >= MAX_CONTACTS:
                _contacts.pop_front()
            _contacts.append({"skill":id,"caster":caster,"target":target,"from":actor.get("position",Vector2.ZERO),"at":victim.get("position",Vector2.ZERO),"started":_clock})
        _casts[cast_id] = cue

func advance(delta: float) -> void:
    _clock += maxf(0.0,delta)
    for cast_id in _casts.keys():
        var cue: Dictionary = _casts[cast_id]
        if _clock-float(cue["started"]) > float(cue["duration"])+3.0:
            _casts.erase(cast_id)
    for i in range(_contacts.size()-1,-1,-1):
        if _clock-float(_contacts[i]["started"]) >= CONTACT_SECONDS+FADE_SECONDS:
            _contacts.remove_at(i)

func contact_count() -> int:
    return _contacts.size()

func cast_count() -> int:
    return _casts.size()

func _texture(path: String) -> Texture2D:
    if _textures.has(path):
        return _textures[path] as Texture2D
    if not ResourceLoader.exists(ROOT+path,"Texture2D"):
        return null
    var texture := ResourceLoader.load(ROOT+path,"Texture2D") as Texture2D
    if texture != null:
        _textures[path] = texture
    return texture

func source_ready(skill_id: String) -> bool:
    if not BINDINGS.has(skill_id):
        return false
    var binding: Dictionary = BINDINGS[skill_id]
    if binding.has("atlas"):
        var atlas := _texture(str(binding["atlas"]))
        return atlas != null and atlas.get_size() == Vector2(int(binding["count"])*256,1024)
    for phase in ["charge","flight","contact","fade"]:
        if _texture(str(binding["prefix"])+phase+"_r1.png") == null:
            return false
    return true

func _draw_phase(canvas: CanvasItem,id: String,phase: int,progress: float,at: Vector2,angle: float,scale_amount: float) -> void:
    var binding: Dictionary = BINDINGS[id]
    var count := int(binding["count"])
    var extent := Vector2.ONE*float(binding["extent"])*scale_amount
    if phase == 0:
        extent *= 0.6
    elif phase >= 2:
        extent *= 0.84
    var texture: Texture2D
    var region := Rect2()
    if binding.has("atlas"):
        texture = _texture(str(binding["atlas"]))
        var frame := mini(count-1,int(clampf(progress,0.0,1.0)*float(count)))
        region = Rect2(Vector2(frame,phase)*256.0,Vector2(256,256))
    else:
        var phase_name := str(["charge","flight","contact","fade"][phase])
        texture = _texture(str(binding["prefix"])+phase_name+"_r1.png")
        if texture != null:
            region = Rect2(Vector2.ZERO,texture.get_size())
            extent.y = extent.x*region.size.y/maxf(1.0,region.size.x)
    if texture == null:
        return
    canvas.draw_set_transform(at,0.0 if binding["shape"] == "circle" and phase >= 2 else angle)
    canvas.draw_texture_rect_region(texture,Rect2(-extent*0.5,extent),region)
    canvas.draw_set_transform(Vector2.ZERO)

func draw_on(canvas: CanvasItem,positions: Dictionary,projection: Callable,scale_amount: float = 1.0) -> void:
    for raw in _casts.values():
        var cue: Dictionary = raw
        var from: Vector2 = projection.call(positions.get(str(cue["caster"]),cue["from"]))
        var to: Vector2 = projection.call(cue["to"])
        from += Vector2(0,-40)*scale_amount
        to += Vector2(0,-40)*scale_amount
        var angle := (to-from).angle()
        if not bool(cue["released"]):
            var p := clampf((_clock-float(cue["started"]))/float(cue["duration"]),0.0,1.0)
            if p < 0.55:
                _draw_phase(canvas,str(cue["skill"]),0,p/0.55,from,angle,scale_amount)
            elif p < 1.0:
                var q := (p-0.55)/0.45
                _draw_phase(canvas,str(cue["skill"]),1,q,from.lerp(to,q),angle,scale_amount)
        elif (cue["targets"] as Dictionary).is_empty():
            var q := (_clock-float(cue["released_at"]))/0.18
            if q < 1.0:
                _draw_phase(canvas,str(cue["skill"]),1,q,to,angle,scale_amount)
    for hit in _contacts:
        var from: Vector2 = projection.call(hit["from"])
        var to: Vector2 = projection.call(hit["at"])
        var angle := (to-from).angle()
        var elapsed := _clock-float(hit["started"])
        var phase := 2 if elapsed < CONTACT_SECONDS else 3
        var q := elapsed/CONTACT_SECONDS if phase == 2 else (elapsed-CONTACT_SECONDS)/FADE_SECONDS
        _draw_phase(canvas,str(hit["skill"]),phase,q,to+Vector2(0,-40)*scale_amount,angle,scale_amount)
