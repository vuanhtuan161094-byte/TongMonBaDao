extends RefCounted
## Read-only candidate art from the existing 17-master formation factory.
## 16 usable source bindings; one art-rework row is deliberately excluded.
## Combat stays OFF by default. Only actual enabled actor receipts are consumed.
const INDEX := "res://data/presentation/pve_formation_r2.json"
var _bindings: Dictionary = {}
var _textures: Dictionary = {}
var _cues: Dictionary = {}
var _encounter := ""
var _clock := 0.0

func reset() -> void:
    _cues.clear()
    _encounter = ""
    _clock = 0.0

func _load_bindings() -> void:
    if not _bindings.is_empty():
        return
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(INDEX))
    if raw is Dictionary:
        _bindings = raw.get("bindings",{})

func observe(events: Array[Dictionary],battle: MapBattleV2) -> void:
    if battle == null:
        reset()
        return
    if _encounter != battle.encounter_id:
        reset()
        _encounter = battle.encounter_id
    _load_bindings()
    for event in events:
        if str(event.get("encounter_id","")) != _encounter:
            continue
        var id := str(event.get("skill_id",""))
        var owner := str(event.get("caster",event.get("attacker",event.get("actor_id",""))))
        if not battle.actors.has(owner):
            continue
        var actor: Dictionary = battle.actors[owner]
        if str(actor.get("side","")) != "disciple" or not bool(actor.get("v63_combat_enabled",false)) or not bool(actor.get("v63_formation_combat_enabled",false)):
            continue
        var kind := str(event.get("type",""))
        if kind == "hit" and id.is_empty() and str(event.get("kind","")) == "basic":
            id = str(actor.get("v63_basic_skill_id",""))
        if not _bindings.has(id):
            continue
        var binding: Dictionary = _bindings[id]
        var receipt := str(event.get("event_id",""))
        if receipt.is_empty():
            continue
        var target := str(event.get("target",event.get("target_id","")))
        var target_actor: Dictionary = battle.actors.get(target,{})
        var effect := str(binding["effect"])
        var cast_id := str(event.get("cast_id",""))
        var key := owner+"|"+id+"|"+cast_id
        if kind == "skill_cast":
            if str(event.get("effect","")) != effect or str(event.get("shape","")) != str(binding["shape"]) or int(event.get("target_limit",0)) != int(binding["limit"]):
                continue
            _put(key,{"skill":id,"phase":0,"actor":owner,"at":actor.get("position",Vector2.ZERO),"start":_clock,"end":_clock+maxf(0.08,float(event.get("release_at",battle.now))-battle.now)})
        elif kind == "skill_release" and _cues.has(key):
            _put(key,{"skill":id,"phase":1,"actor":"","at":target_actor.get("position",actor.get("position",Vector2.ZERO)),"start":_clock,"end":_clock+0.20})
        elif kind == "v63_formation_zone_created" and effect == "formation_zone":
            var zone := str(event.get("zone_id",""))
            if not zone.is_empty():
                _put("zone|"+owner+"|"+zone,{"skill":id,"phase":2,"actor":"","at":event.get("center",actor.get("position",Vector2.ZERO)),"start":_clock,"end":_clock+maxf(0.10,float(event.get("expires_at",battle.now))-battle.now)})
        elif kind == "v63_formation_zone_expired":
            _cues.erase("zone|"+owner+"|"+str(event.get("zone_id","")))
        elif effect == "mobility" and kind == "v63_mobility":
            _put("receipt|"+receipt,{"skill":id,"phase":2,"actor":owner,"at":actor.get("position",Vector2.ZERO),"start":_clock,"end":_clock+0.28})
        elif not target_actor.is_empty():
            var valid_contact := (effect == "damage" and kind in ["v63_skill_hit","hit"] and float(event.get("damage",0.0)) > 0.0)
            valid_contact = valid_contact or (effect == "slow" and kind == "v63_formation_slow_applied")
            valid_contact = valid_contact or (effect == "guard" and kind == "status_applied" and str(event.get("status","")) == "guard")
            if valid_contact:
                var duration := 0.32
                if effect == "guard" or effect == "slow":
                    duration = clampf(float(event.get("until",battle.now+0.32))-battle.now,0.32,8.0)
                _put("receipt|"+receipt,{"skill":id,"phase":2,"actor":target,"at":target_actor.get("position",Vector2.ZERO),"start":_clock,"end":_clock+duration})

func _put(key: String,cue: Dictionary) -> void:
    if _cues.size() >= 64 and not _cues.has(key):
        _cues.erase(_cues.keys()[0])
    _cues[key] = cue

func advance(delta: float) -> void:
    _clock += maxf(0.0,delta)
    for key in _cues.keys():
        var cue: Dictionary = _cues[key]
        if _clock > float(cue["end"])+0.18:
            _cues.erase(key)

func draw_on(canvas: CanvasItem,positions: Dictionary,projection: Callable) -> void:
    for raw in _cues.values():
        var cue: Dictionary = raw
        var binding: Dictionary = _bindings.get(str(cue["skill"]),{})
        if binding.is_empty():
            continue
        var atlas_index := int(binding["atlas"])
        if not _textures.has(atlas_index):
            var path := "res://assets/p3/vfx/formation_r2/formation_%d.png" % (atlas_index+1)
            if ResourceLoader.exists(path,"Texture2D"):
                _textures[atlas_index] = ResourceLoader.load(path,"Texture2D")
        var atlas := _textures.get(atlas_index) as Texture2D
        if atlas == null:
            continue
        var phase := int(cue["phase"])
        var opacity := 0.92
        if _clock > float(cue["end"]):
            phase = 3
            opacity *= clampf(1.0-(_clock-float(cue["end"]))/0.18,0.0,1.0)
        var frame: Array = binding["frames"][phase]
        var region := Rect2(float(frame[0]),float(frame[1]),float(frame[2]),float(frame[3]))
        var at: Vector2 = projection.call(positions.get(str(cue["actor"]),cue["at"]))
        var extent := 174.0 if str(binding["shape"]) == "circle" else 112.0
        if phase == 0:
            extent *= 0.70
        if str(binding["effect"]) != "formation_zone":
            at += Vector2(0,-28)
        var dims := Vector2.ONE*extent
        canvas.draw_texture_rect_region(atlas,Rect2(at-dims*0.5,dims),region,Color(1,1,1,opacity))
