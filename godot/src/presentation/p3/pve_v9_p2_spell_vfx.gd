extends RefCounted
const ATLASES := {
    "hoa_cau":preload("res://art/pve_v9/hoa_cau_12cel.svg"),
    "han_suong_an":preload("res://art/pve_v9/han_suong_an_12cel.svg")
}
const LIMIT := 32
var _encounter := ""
var _clock := 0.0
var _cues: Dictionary = {}

func reset() -> void:
    _encounter = ""
    _clock = 0.0
    _cues.clear()

func observe(events: Array[Dictionary],battle: MapBattleV2) -> void:
    if battle == null:
        reset()
        return
    if _encounter != battle.encounter_id:
        reset()
        _encounter = battle.encounter_id
    for event in events:
        var id := str(event.get("skill_id",""))
        var cast_id := str(event.get("cast_id",""))
        var caster := str(event.get("caster",""))
        var target := str(event.get("target",""))
        var kind := str(event.get("type",""))
        if not ATLASES.has(id) or cast_id.is_empty() or str(event.get("event_id","")).is_empty() or str(event.get("encounter_id","")) != _encounter:
            continue
        if not battle.actors.has(caster) or not battle.actors.has(target):
            continue
        var actor: Dictionary = battle.actors[caster]
        var victim: Dictionary = battle.actors[target]
        if str(actor.get("side","")) != "disciple" or str(victim.get("side","")) != "monster" or not actor.get("skill_loadout",[]).has(id):
            continue
        if kind == "skill_cast":
            if _cues.has(cast_id) or _cues.size() >= LIMIT:
                continue
            var deadline := maxf(0.05,float(event.get("release_at",battle.now))-float(event.get("time",battle.now)))
            _cues[cast_id] = {"skill":id,"caster":caster,"target":target,"from":event.get("caster_position",actor.get("position",Vector2.ZERO)),"to":event.get("target_position",victim.get("position",Vector2.ZERO)),"started":_clock,"duration":deadline,"released":false,"hit":false,"contact_at":-1.0}
        elif _cues.has(cast_id):
            var cue: Dictionary = _cues[cast_id]
            if cue["skill"] != id or cue["caster"] != caster or cue["target"] != target:
                continue
            if kind == "skill_release":
                cue["released"] = true
            elif kind == "skill_hit" and bool(cue["released"]) and not bool(cue["hit"]) and float(event.get("damage",0.0)) > 0.0:
                cue["hit"] = true
                cue["contact_at"] = _clock
                cue["to"] = event.get("target_position",victim.get("position",Vector2.ZERO))
            _cues[cast_id] = cue

func advance(delta: float) -> void:
    _clock += maxf(delta,0.0)
    for key in _cues.keys():
        var cue: Dictionary = _cues[key]
        if (bool(cue["hit"]) and _clock-float(cue["contact_at"]) > 0.42) or _clock-float(cue["started"]) > float(cue["duration"])+1.0:
            _cues.erase(key)

func draw_on(canvas: CanvasItem,positions: Dictionary,projection: Callable) -> void:
    for value in _cues.values():
        var cue: Dictionary = value
        var origin: Vector2 = projection.call(positions.get(cue["caster"],cue["from"]))
        var destination: Vector2 = projection.call(cue["to"])
        origin += Vector2(0,-42)
        destination += Vector2(0,-42)
        var at := origin
        var angle := (destination-origin).angle()
        var phase := 0
        var q := 0.0
        var extent := 90.0
        if bool(cue["hit"]):
            var age := _clock-float(cue["contact_at"])
            phase = 2 if age < 0.21 else 3
            q = age/0.21 if phase == 2 else (age-0.21)/0.21
            at = destination
            angle = 0.0
            extent = 134.0
        elif bool(cue["released"]):
            continue
        else:
            var progress := clampf((_clock-float(cue["started"]))/float(cue["duration"]),0.0,1.0)
            if progress >= 0.55:
                phase = 1
                q = (progress-0.55)/0.45
                at = origin.lerp(destination,q)
                extent = 100.0
            else:
                q = progress/0.55
                angle = 0.0
        var col := clampi(int(q*3.0),0,2)
        var atlas: Texture2D = ATLASES[cue["skill"]]
        var size := Vector2.ONE*extent
        canvas.draw_set_transform(at,angle)
        canvas.draw_texture_rect_region(atlas,Rect2(-size*0.5,size),Rect2(Vector2(col,phase)*128.0,Vector2(128,128)))
        canvas.draw_set_transform(Vector2.ZERO)
