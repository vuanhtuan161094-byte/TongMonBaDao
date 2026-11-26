extends RefCounted
## A3 candidate runtime, not G8 approval. No combat/Save authority.
const ROOT := "res://assets/p3/vfx/a3_sword_batch6/"
const PREVIEW_SETTING := "runtime/a3_sword_vfx_preview"
const BINDINGS := {
    "tmb.skill.sword.ngu_kiem.active_02.human":{"tag":"02","shape":"circle","limit":3},
    "tmb.skill.sword.ngu_kiem.active_03.human":{"tag":"03","shape":"line","limit":3},
    "tmb.skill.sword.ngu_kiem.active_04.human":{"tag":"04","shape":"single_target","limit":1},
    "tmb.skill.sword.ngu_kiem.ultimate.human":{"tag":"05","shape":"circle","limit":3},
    "tmb.skill.sword.sat_kiem.active_01.human":{"tag":"06","shape":"single_target","limit":1},
    "tmb.skill.sword.sat_kiem.active_02.human":{"tag":"07","shape":"line","limit":3},
    "tmb.skill.sword.sat_kiem.active_03.human":{"tag":"08","shape":"single_target","limit":1}
}
## Temporary same-family art reuse: exact real event IDs remain authoritative.
const COMPATIBLE_VARIANTS := {
    "tmb.skill.sword.ngu_kiem.active_02.immortal.a":"tmb.skill.sword.ngu_kiem.active_02.human",
    "tmb.skill.sword.ngu_kiem.active_02.immortal.b":"tmb.skill.sword.ngu_kiem.active_02.human",
    "tmb.skill.sword.ngu_kiem.active_02.divine.a":"tmb.skill.sword.ngu_kiem.active_02.human",
    "tmb.skill.sword.ngu_kiem.active_02.divine.b":"tmb.skill.sword.ngu_kiem.active_02.human",
    "tmb.skill.sword.ngu_kiem.active_03.immortal.a":"tmb.skill.sword.ngu_kiem.active_03.human",
    "tmb.skill.sword.ngu_kiem.active_03.immortal.b":"tmb.skill.sword.ngu_kiem.active_03.human",
    "tmb.skill.sword.ngu_kiem.active_03.divine.a":"tmb.skill.sword.ngu_kiem.active_03.human",
    "tmb.skill.sword.ngu_kiem.active_03.divine.b":"tmb.skill.sword.ngu_kiem.active_03.human",
    "tmb.skill.sword.ngu_kiem.active_04.immortal.a":"tmb.skill.sword.ngu_kiem.active_04.human",
    "tmb.skill.sword.ngu_kiem.active_04.immortal.b":"tmb.skill.sword.ngu_kiem.active_04.human",
    "tmb.skill.sword.ngu_kiem.active_04.divine.a":"tmb.skill.sword.ngu_kiem.active_04.human",
    "tmb.skill.sword.ngu_kiem.active_04.divine.b":"tmb.skill.sword.ngu_kiem.active_04.human",
    "tmb.skill.sword.ngu_kiem.ultimate.immortal.a":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.ngu_kiem.ultimate.immortal.b":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.ngu_kiem.ultimate.divine.a":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.ngu_kiem.ultimate.divine.b":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.ngu_kiem.ultimate.rare.a":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.ngu_kiem.ultimate.rare.b":"tmb.skill.sword.ngu_kiem.ultimate.human",
    "tmb.skill.sword.sat_kiem.active_01.immortal.a":"tmb.skill.sword.sat_kiem.active_01.human",
    "tmb.skill.sword.sat_kiem.active_01.immortal.b":"tmb.skill.sword.sat_kiem.active_01.human",
    "tmb.skill.sword.sat_kiem.active_01.divine.a":"tmb.skill.sword.sat_kiem.active_01.human",
    "tmb.skill.sword.sat_kiem.active_01.divine.b":"tmb.skill.sword.sat_kiem.active_01.human",
    "tmb.skill.sword.sat_kiem.active_02.immortal.a":"tmb.skill.sword.sat_kiem.active_02.human",
    "tmb.skill.sword.sat_kiem.active_02.immortal.b":"tmb.skill.sword.sat_kiem.active_02.human",
    "tmb.skill.sword.sat_kiem.active_02.divine.a":"tmb.skill.sword.sat_kiem.active_02.human",
    "tmb.skill.sword.sat_kiem.active_02.divine.b":"tmb.skill.sword.sat_kiem.active_02.human",
    "tmb.skill.sword.sat_kiem.active_03.immortal.a":"tmb.skill.sword.sat_kiem.active_03.human",
    "tmb.skill.sword.sat_kiem.active_03.immortal.b":"tmb.skill.sword.sat_kiem.active_03.human",
    "tmb.skill.sword.sat_kiem.active_03.divine.a":"tmb.skill.sword.sat_kiem.active_03.human",
    "tmb.skill.sword.sat_kiem.active_03.divine.b":"tmb.skill.sword.sat_kiem.active_03.human"
}

static func binding_for(skill_id: String) -> Dictionary:
    var master := str(COMPATIBLE_VARIANTS.get(skill_id,skill_id))
    return BINDINGS.get(master,{})

const PRESENTATION := {
    "02":{"extent":212.0,"arc":0.0,"rotate":false},
    "03":{"extent":190.0,"arc":-12.0,"rotate":true},
    "04":{"extent":184.0,"arc":-24.0,"rotate":true},
    "05":{"extent":218.0,"arc":0.0,"rotate":false},
    "06":{"extent":174.0,"arc":-5.0,"rotate":true},
    "07":{"extent":202.0,"arc":10.0,"rotate":true},
    "08":{"extent":192.0,"arc":-17.0,"rotate":true}
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
        if event_id.is_empty() or cast_id.is_empty() or binding_for(skill_id).is_empty():
            continue
        var binding: Dictionary = binding_for(skill_id)
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
            if not cue.has("first_contact"):
                cue["first_contact"] = _clock
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
                var fraction := clampf(elapsed/float(cue["windup"]),0.0,1.0)
                # Visual anticipation only: projectile-speed skills travel during the authoritative cast deadline.
                var tag := str(binding_for(str(cue["id"]))["tag"])
                if tag in ["02","03","04","05"] and fraction>=0.60:
                    var progress := (fraction-0.60)/0.40
                    result.append({"id":cue["id"],"phase":"release","caster":cue["caster"],"target":cue["target"],"frame":6+mini(10,int(progress*11.0)),"progress":progress})
                else:
                    result.append({"id":cue["id"],"phase":"charge","caster":cue["caster"],"target":cue["target"],"frame":mini(5,int(fraction/0.60*6.0))})
        elif Dictionary(cue["seen"]).is_empty():
            var flight := _clock-float(cue.get("release_clock",_clock))
            if flight < 0.32:
                result.append({"id":cue["id"],"phase":"release","caster":cue["caster"],"target":cue["target"],"frame":6+mini(10,int(flight/0.32*11.0)),"progress":clampf(flight/0.32,0.0,0.9)})
        elif str(binding_for(str(cue["id"]))["tag"]) == "04" and cue.has("first_contact"):
            var back := _clock-float(cue["first_contact"])-0.12
            if back >= 0.0 and back < 0.24:
                result.append({"id":cue["id"],"phase":"return","caster":cue["caster"],"target":cue["target"],"frame":16-mini(10,int(back/0.24*11.0)),"progress":clampf(back/0.24,0.0,1.0)})
    for hit in _hits:
        result.append({"id":hit["id"],"phase":"contact","caster":hit["caster"],"target":hit["target"],"at":hit["at"],"frame":17+mini(6,int((_clock-float(hit["started"]))*25.0))})
    return result

func texture_for(skill_id: String) -> Texture2D:
    var binding := binding_for(skill_id)
    if binding.is_empty():
        return null
    var tag := str(binding["tag"])
    if _textures.has(tag):
        return _textures[tag] as Texture2D
    var path := ROOT+("sword_02_r1e_12f.png" if tag=="02" else "sword_"+tag+"_24f.png")
    var texture := ResourceLoader.load(path,"Texture2D",ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
    var expected_size := Vector2(2048,1536) if tag=="02" else Vector2(2048,3072)
    if texture == null or texture.get_size() != expected_size:
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
        var at: Vector2 = projection.call(cue.get("at",positions.get(target,Vector2.ZERO)) if phase=="contact" else positions.get(target,Vector2.ZERO))
        at += Vector2(0,-42)*scale_amount
        var profile: Dictionary = PRESENTATION[str(binding_for(str(cue["id"]))["tag"])]
        var heading := 0.0
        if positions.has(caster):
            var from: Vector2 = projection.call(positions[caster])
            from += Vector2(0,-42)*scale_amount
            if phase != "contact":
                var destination := at
                if phase == "charge":
                    at = from
                else:
                    var progress := float(cue["progress"])
                    if phase == "return":
                        at = destination.lerp(from,progress)
                        heading = (from-destination).angle()
                    else:
                        at = from.lerp(destination,progress)
                        heading = (destination-from).angle()
                    at.y += float(profile["arc"])*sin(PI*progress)*scale_amount
        var tag := str(binding_for(str(cue["id"]))["tag"])
        var texture := texture_for(str(cue["id"]))
        var frame := int(cue["frame"])
        if tag=="04" and phase in ["release","return"]:
            frame=18
        if tag in ["04","06"] and phase=="contact":
            texture=texture_for("tmb.skill.sword.ngu_kiem.ultimate.human")
            frame=clampi(frame,17,21)
        if texture == null:
            continue
        # R1E uses the 12 exact owner-accepted source cels, not derived V2 art.
        # Keep the three gameplay-bound phases distinct at the original cadence.
        if tag == "02":
            if phase == "charge":
                frame = clampi(floori(float(frame) / 2.0), 0, 2)
            elif phase == "contact":
                frame = clampi(9 + floori(float(frame-17) / 2.0), 9, 11)
            else:
                frame = clampi(3 + floori(float(frame-6) / 2.0), 3, 8)
        var region := Rect2(Vector2(frame%4,floori(float(frame)/4.0))*512.0,Vector2(512,512))
        var extent := Vector2.ONE*float(profile["extent"])*scale_amount
        if phase == "charge":
            extent *= lerpf(0.58,0.88,float(frame)/5.0)
        elif phase == "contact":
            # Contact cels are attached to the actual authoritative hit target, not an averaged point.
            extent *= 0.78
        if not bool(profile["rotate"]):
            heading = 0.0
        canvas.draw_set_transform(at,heading)
        canvas.draw_texture_rect_region(texture,Rect2(-extent*0.5,extent),region,Color(1.08,1.08,1.08,1.0))
        canvas.draw_set_transform(Vector2.ZERO)
