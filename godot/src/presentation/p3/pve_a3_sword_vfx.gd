extends RefCounted
## A3 candidate runtime, not G8 approval. No combat/Save authority.
const ROOT := "res://assets/p3/vfx/a3_sword_batch6/"
const PREVIEW_SETTING := "runtime/a3_sword_vfx_preview"
const BINDINGS := {
    "tmb.skill.sword.ngu_kiem.active_03.human":{"tag":"03","shape":"line","limit":3},
    "tmb.skill.sword.ngu_kiem.active_04.human":{"tag":"04","shape":"single_target","limit":1},
    "tmb.skill.sword.ngu_kiem.ultimate.human":{"tag":"05","shape":"circle","limit":3},
    "tmb.skill.sword.sat_kiem.active_01.human":{"tag":"06","shape":"single_target","limit":1},
    "tmb.skill.sword.sat_kiem.active_02.human":{"tag":"07","shape":"line","limit":3},
    "tmb.skill.sword.sat_kiem.active_03.human":{"tag":"08","shape":"single_target","limit":1}
}
const MAX_CASTS := 12
const MAX_HITS := 36
var _encounter := ""
var _tail := ""
var _clock := 0.0
var _casts: Dictionary = {}
var _hits: Array[Dictionary] = []
var _textures: Dictionary = {}
var _texture_order: Array[String] = []

func reset() -> void:
    _encounter = ""
    _tail = ""
    _clock = 0.0
    _casts.clear()
    _hits.clear()

func observe(events: Array[Dictionary], battle: MapBattleV2, enabled: bool) -> void:
    if battle == null or not enabled:
        reset()
        return
    var tail := str(battle.events.back().get("event_id","")) if not battle.events.is_empty() else ""
    if _encounter != battle.encounter_id or (events.is_empty() and tail != _tail):
        reset()
        _encounter = battle.encounter_id
        _tail = tail
        return
    _tail = tail
    for event in events:
        if str(event.get("encounter_id","")) != _encounter:
            continue
        var event_id := str(event.get("event_id",""))
        var cast_id := str(event.get("cast_id",""))
        var skill_id := str(event.get("skill_id",""))
        if event_id.is_empty() or cast_id.is_empty() or not BINDINGS.has(skill_id):
            continue
        var binding: Dictionary = BINDINGS[skill_id]
        var caster := str(event.get("caster",event.get("actor_id","")))
        var target := str(event.get("target",event.get("target_id","")))
        if not battle.actors.has(caster) or not battle.actors.has(target):
            continue
        var source: Dictionary = battle.actors[caster]
        var victim: Dictionary = battle.actors[target]
        if str(source.get("side","")) != "disciple" or str(victim.get("side","")) != "monster" or caster == target:
            continue
        if not bool(source.get("v63_sword_combat_enabled",false)) or not bool(source.get("v63_combat_enabled",false)):
            continue
        var kind := str(event.get("type",""))
        if kind == "skill_cast":
            if _casts.has(cast_id) or _casts.size() >= MAX_CASTS:
                continue
            if str(event.get("shape","")) != str(binding["shape"]) or int(event.get("target_limit",0)) != int(binding["limit"]):
                continue
            if str(event.get("effect","")) != "damage":
                continue
            var windup := clampf(float(event.get("release_at",battle.now))-float(event.get("time",battle.now)),0.05,2.0)
            _casts[cast_id] = {"id":skill_id,"caster":caster,"target":target,"started":_clock,"windup":windup,"released":false,"seen":{}}
            continue
        if not _casts.has(cast_id):
            continue
        var cue: Dictionary = _casts[cast_id]
        if cue["id"] != skill_id or cue["caster"] != caster:
            continue
        if kind == "skill_release" and cue["target"] == target and not bool(cue["released"]):
            cue["released"] = true
            cue["release_clock"] = _clock
        elif kind == "v63_skill_hit" and bool(cue["released"]) and float(event.get("damage",0.0)) > 0.0:
            var seen: Dictionary = cue["seen"]
            if seen.has(target) or seen.size() >= int(binding["limit"]) or _hits.size() >= MAX_HITS:
                continue
            if str(binding["shape"]) == "single_target" and target != cue["target"]:
                continue
            seen[target] = true
            _hits.append({"id":skill_id,"caster":caster,"target":target,"at":victim.get("position",Vector2.ZERO),"started":_clock})
        _casts[cast_id] = cue

func advance(delta: float) -> void:
    _clock += maxf(delta,0.0)
    for key in _casts.keys():
        var cue: Dictionary = _casts[key]
        if _clock-float(cue["started"]) > float(cue["windup"])+1.0:
            _casts.erase(key)
    for index in range(_hits.size()-1,-1,-1):
        if _clock-float(_hits[index]["started"]) >= 0.28:
            _hits.remove_at(index)

func cues() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for raw in _casts.values():
        var cue: Dictionary = raw
        var elapsed := _clock-float(cue["started"])
        if not bool(cue["released"]):
            if elapsed <= float(cue["windup"]):
                result.append({"id":cue["id"],"phase":"charge","caster":cue["caster"],"target":cue["target"],"frame":mini(5,int(elapsed/float(cue["windup"])*6.0))})
        elif Dictionary(cue["seen"]).is_empty():
            var flight := _clock-float(cue.get("release_clock",_clock))
            if flight < 0.32:
                result.append({"id":cue["id"],"phase":"release","caster":cue["caster"],"target":cue["target"],"frame":6+mini(10,int(flight/0.32*11.0)),"progress":clampf(flight/0.32,0.0,0.9)})
    for hit in _hits:
        result.append({"id":hit["id"],"phase":"contact","caster":hit["caster"],"target":hit["target"],"at":hit["at"],"frame":17+mini(6,int((_clock-float(hit["started"]))*25.0))})
    return result

func texture_for(skill_id: String) -> Texture2D:
    if not BINDINGS.has(skill_id):
        return null
    var tag := str(BINDINGS[skill_id]["tag"])
    if _textures.has(tag):
        return _textures[tag] as Texture2D
    var path := ROOT+"sword_"+tag+"_24f.png"
    var texture := ResourceLoader.load(path,"Texture2D",ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
    if texture == null or texture.get_size() != Vector2(2048,3072):
        return null
    _textures[tag] = texture
    _texture_order.append(tag)
    if _texture_order.size() > 3:
        _textures.erase(_texture_order.pop_front())
    return texture

func draw_on(canvas: CanvasItem, positions: Dictionary, projection: Callable, scale_amount: float) -> void:
    for cue in cues():
        var phase := str(cue["phase"])
        var caster := str(cue["caster"])
        var target := str(cue["target"])
        if phase != "contact" and (not positions.has(caster) or not positions.has(target)):
            continue
        if phase == "contact" and not positions.has(target) and not cue.has("at"):
            continue
        var at: Vector2 = projection.call(positions.get(target,cue.get("at",Vector2.ZERO)))
        at += Vector2(0,-42)*scale_amount
        if phase != "contact":
            var from: Vector2 = projection.call(positions[caster])
            from += Vector2(0,-42)*scale_amount
            at = from if phase == "charge" else from.lerp(at,float(cue["progress"]))
        var texture := texture_for(str(cue["id"]))
        if texture == null:
            continue
        var frame := int(cue["frame"])
        var region := Rect2(Vector2(frame%4,floori(float(frame)/4.0))*512.0,Vector2(512,512))
        var extent := Vector2.ONE*176.0*scale_amount
        canvas.draw_texture_rect_region(texture,Rect2(at-extent*0.5,extent),region)
