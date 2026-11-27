extends RefCounted
## Source-backed, receipt-driven PvE candidate atlas player. No authority over
## combat, learning, status duration, targeting or saves. Never emits receipts.
const INDEX := "res://data/presentation/pve_factory_r2.json"
const EXTERNAL_INDEX := "res://data/presentation/pve_external_auxiliary_v1.json"
const EXTERNAL_PREVIEW_SETTING := "runtime/external_auxiliary_vfx_preview"
const MAX_CUES := 80
const MAX_TEXTURES := 36
var _entries: Dictionary = {}
var _resolved: Dictionary = {}
var _textures: Dictionary = {}
var _texture_order: Array[String] = []
var _cues: Dictionary = {}
var _clock := 0.0
var _encounter := ""

func reset() -> void:
    _cues.clear()
    _clock = 0.0
    _encounter = ""

func _ensure_index() -> void:
    if not _entries.is_empty():
        return
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(INDEX))
    if raw is Dictionary:
        _entries = raw.get("bindings",{}).duplicate(true)
    # Separate preview gate; never replace the existing 58 source bindings.
    if bool(ProjectSettings.get_setting(EXTERNAL_PREVIEW_SETTING,false)):
        var external: Variant = JSON.parse_string(FileAccess.get_file_as_string(EXTERNAL_INDEX))
        if external is Dictionary:
            for id in external.get("bindings",{}):
                if not _entries.has(id):
                    _entries[id] = external["bindings"][id]

func _binding(id: String) -> Dictionary:
    if _entries.has(id):
        return _entries[id]
    if _resolved.has(id):
        return _resolved[id]
    # Reuse only same-family art whose authoritative effect/shape/target
    # contract is identical. A changed effect or shape requires its own art.
    var parts := id.split(".")
    var master := ""
    for i in range(parts.size()):
        if parts[i] in ["immortal","divine","rare"]:
            master = ".".join(parts.slice(0,i))+".human"
            break
    var source: Dictionary = _entries.get(master,{})
    if not source.is_empty() and not bool(source.get("external_auxiliary",false)):
        var definition := V63HumanSkillCombatSystem.skill_definition(id)
        if str(definition.get("effect","")) == str(source.get("effect","")) and str(definition.get("shape","")) == str(source.get("shape","")) and int(definition.get("target_limit",0)) == int(source.get("limit",-1)):
            _resolved[id] = source
            return source
    _resolved[id] = {}
    return {}

static func resolve_receipt_phase(phases: Dictionary, requested: String) -> String:
    if phases.has(requested):
        return requested
    if requested == "release" and phases.has("flight"):
        return "flight"
    return ""

static func external_receipt_allowed(entry: Dictionary,event: Dictionary) -> bool:
    var effect := str(entry.get("effect",""))
    var kind := str(event.get("type",""))
    if effect == "heal":
        return kind == "heal" and float(event.get("amount",0.0)) > 0.0
    if effect == "guard":
        return kind == "status_applied" and str(event.get("status","")) in ["guard","capacity_shield"]
    if effect == "cleanse":
        return kind == "cleanse" and int(event.get("removed_debuff_count",0)) > 0
    return false

func observe(events: Array[Dictionary],battle: MapBattleV2) -> void:
    if battle == null:
        reset()
        return
    if _encounter != battle.encounter_id:
        reset()
        _encounter = battle.encounter_id
    _ensure_index()
    for event in events:
        if str(event.get("encounter_id","")) != _encounter:
            continue
        var owner := str(event.get("caster",event.get("attacker",event.get("actor_id",event.get("owner_id","")))))
        var actor: Dictionary = battle.actors.get(owner,{})
        if str(actor.get("side","")) != "disciple" or not bool(actor.get("v63_combat_enabled",false)):
            continue
        var kind := str(event.get("type",""))
        var id := str(event.get("skill_id",""))
        if kind == "hit" and id.is_empty() and str(event.get("kind","")) == "basic":
            id = str(actor.get("v63_basic_skill_id",""))
        if id.is_empty():
            continue
        var entry := _binding(id)
        if entry.is_empty():
            continue
        var receipt := str(event.get("event_id",""))
        var allowed: Dictionary = entry.get("receipts",{})
        if receipt.is_empty() or not allowed.has(kind):
            continue
        if bool(entry.get("external_auxiliary",false)) and not external_receipt_allowed(entry,event):
            continue
        var cast_id := str(event.get("cast_id",""))
        var cast_key := "cast|"+owner+"|"+id+"|"+cast_id
        var phase := str(allowed[kind])
        var target := str(event.get("target",event.get("target_id","")))
        if kind == "v63_mobility":
            target = owner
        var target_actor: Dictionary = battle.actors.get(target,{})
        var at: Vector2 = event.get("target_position",target_actor.get("position",actor.get("position",Vector2.ZERO)))
        var origin: Vector2 = event.get("source_position",actor.get("position",Vector2.ZERO))
        var phases: Dictionary = entry.get("phases",{})
        if kind == "skill_cast":
            if str(event.get("effect","")) != str(entry["effect"]) or str(event.get("shape","")) != str(entry["shape"]) or int(event.get("target_limit",0)) != int(entry["limit"]):
                continue
            if not phases.has("charge"):
                continue
            var windup := clampf(float(event.get("release_at",battle.now))-battle.now,0.06,6.0)
            # The combat deadline already includes projectile travel. Display
            # a flight before that deadline, not after damage has landed.
            var definition := V63HumanSkillCombatSystem.skill_definition(id)
            var speed := float(definition.get("projectile_speed",0.0))
            var travel := minf(windup*0.85,origin.distance_to(at)/speed) if speed > 0.0 and phases.has("flight") else 0.0
            _add(cast_key,{"skill":id,"phase":"charge","owner":owner,"target":target,"origin":origin,"at":at,"begin":_clock,"end":_clock+windup,"travel":travel,"kind":kind,"persistent":false})
            continue
        if kind == "skill_release":
            var prior: Dictionary = _cues.get(cast_key,{})
            _cues.erase(cast_key)
            if float(prior.get("travel",0.0)) > 0.0 and not phases.has("release"):
                continue
        elif kind == "hit" or kind.ends_with("_hit"):
            if float(event.get("damage",0.0)) <= 0.0:
                continue
        phase = resolve_receipt_phase(phases,phase)
        if phase.is_empty():
            continue
        var ids: Array = []
        if not target.is_empty():
            ids.append(target)
        elif event.get("target_ids",[]) is Array:
            ids = event.get("target_ids",[]).duplicate()
        if ids.is_empty() and kind in ["skill_release","v63_mobility"] and phase != "flight":
            ids = [owner]
        for raw_target in ids:
            var tid := str(raw_target)
            var victim: Dictionary = battle.actors.get(tid,{})
            if victim.is_empty():
                continue
            var where: Vector2 = event.get("target_position",victim.get("position",at)) if tid == target else victim.get("position",at)
            var source: Dictionary = phases[phase]
            var frames: Array = source.get("frames",[])
            var max_duration := 1.2 if bool(entry.get("external_auxiliary",false)) else 0.85
            var duration := clampf(float(frames.size())/maxf(1.0,float(source.get("fps",12))),0.14,max_duration)
            var expiry := float(event.get("until",event.get("expires_at",event.get("evasion_until",0.0))))
            if str(event.get("status","")) == "poison":
                var stacks: Array = victim.get("status_effects",{}).get("v63_poison",[])
                for stack in stacks:
                    if str(stack.get("owner_id","")) == owner and str(stack.get("source_skill_id","")) == id:
                        expiry = maxf(expiry,float(stack.get("expires_at",0.0)))
            var persistent := phase == "start" and phases.has("sustain") and expiry > battle.now
            if persistent:
                duration = clampf(expiry-battle.now,0.10,30.0)
            var key := "receipt|"+receipt+"|"+tid
            if persistent:
                key = "status|"+owner+"|"+id+"|"+tid
            _add(key,{"skill":id,"phase":phase,"owner":owner,"target":tid,"origin":origin,"at":where,"begin":_clock,"end":_clock+duration,"kind":kind,"persistent":persistent,"status":str(event.get("status",""))})
    # Poison sustain cannot remain after an authoritative cleanse/consumption.
    for key in _cues.keys():
        var cue: Dictionary = _cues[key]
        if not bool(cue.get("persistent",false)) or str(cue.get("status","")) != "poison":
            continue
        var victim: Dictionary = battle.actors.get(str(cue["target"]),{})
        var owned := false
        for stack in victim.get("status_effects",{}).get("v63_poison",[]):
            if str(stack.get("owner_id","")) == str(cue["owner"]) and str(stack.get("source_skill_id","")) == str(cue["skill"]) and float(stack.get("expires_at",0.0)) > battle.now:
                owned = true
                break
        if not owned:
            _cues.erase(key)

func _add(key: String,cue: Dictionary) -> void:
    if _cues.size() >= MAX_CUES and not _cues.has(key):
        _cues.erase(_cues.keys()[0])
    _cues[key] = cue

func advance(delta: float) -> void:
    _clock += maxf(delta,0.0)
    for key in _cues.keys():
        if _clock > float(_cues[key]["end"])+0.20:
            _cues.erase(key)

func _texture(path: String) -> Texture2D:
    if _textures.has(path):
        return _textures[path] as Texture2D
    if not ResourceLoader.exists(path,"Texture2D"):
        return null
    var texture := ResourceLoader.load(path,"Texture2D") as Texture2D
    if texture != null:
        if _texture_order.size() >= MAX_TEXTURES:
            _textures.erase(_texture_order.pop_front())
        _textures[path] = texture
        _texture_order.append(path)
    return texture

func draw_on(canvas: CanvasItem,positions: Dictionary,projection: Callable) -> void:
    for raw in _cues.values():
        var cue: Dictionary = raw
        var entry := _binding(str(cue["skill"]))
        var phases: Dictionary = entry.get("phases",{})
        var phase := str(cue["phase"])
        var age := maxf(0.0,_clock-float(cue["begin"]))
        var duration := maxf(0.05,float(cue["end"])-float(cue["begin"]))
        var progress := clampf(age/duration,0.0,1.0)
        var opacity := 0.93
        if _clock > float(cue["end"]):
            var tail := "end" if bool(cue.get("persistent",false)) else "fade"
            if not phases.has(tail):
                continue
            phase = tail
            age = _clock-float(cue["end"])
            opacity *= clampf(1.0-age/0.20,0.0,1.0)
        elif bool(cue.get("persistent",false)) and age > 0.20:
            phase = "sustain"
            age -= 0.20
        elif phase == "charge" and float(cue.get("travel",0.0)) > 0.0:
            var travel := float(cue["travel"])
            if age >= duration-travel:
                phase = "flight"
                age = maxf(0.0,age-(duration-travel))
                progress = clampf(age/travel,0.0,1.0)
        var source: Dictionary = phases.get(phase,{})
        var frames: Array = source.get("frames",[])
        if frames.is_empty():
            continue
        var frame_index := int(age*float(source.get("fps",12)))
        frame_index = posmod(frame_index,frames.size()) if bool(source.get("loop",false)) else mini(frame_index,frames.size()-1)
        var frame: Dictionary = frames[frame_index]
        var texture := _texture(str(frame["path"]))
        if texture == null:
            continue
        var region := Rect2(Vector2.ZERO,texture.get_size())
        var rect_data: Array = frame.get("region",[])
        if rect_data.size() == 4:
            region = Rect2(float(rect_data[0]),float(rect_data[1]),float(rect_data[2]),float(rect_data[3]))
        if region.size.x <= 0.0 or region.size.y <= 0.0 or not Rect2(Vector2.ZERO,texture.get_size()).encloses(region):
            continue
        var origin: Vector2 = projection.call(positions.get(str(cue["owner"]),cue["origin"]))
        var target: Vector2 = projection.call(positions.get(str(cue["target"]),cue["at"]))
        var at := target
        var angle := 0.0
        if phase == "charge":
            at = origin
        elif phase == "flight":
            at = origin.lerp(target,progress)
            angle = (target-origin).angle()
        elif str(entry.get("shape","")) == "line" and phase == "release":
            at = origin.lerp(target,0.5)
            angle = (target-origin).angle()
        elif phase == "contact":
            # Keep the impact where the authoritative hit landed; moving
            # victims must not drag the flash around after contact.
            at = projection.call(cue["at"])
            if str(entry.get("mechanic","")) in ["projectile","melee","line"]:
                var from: Vector2 = projection.call(cue["origin"])
                angle = (at-from).angle()
        if bool(entry.get("external_auxiliary",false)):
            # FLARE atlas offsets share an explicit foot pivot; preserve native pose proportions.
            var offset: Array = frame.get("source_offset",[])
            if offset.size() == 2:
                var scale_factor := float(source.get("source_pixel_scale",0.5))
                var pivot := Vector2(float(offset[0]),float(offset[1]))*scale_factor
                canvas.draw_texture_rect_region(texture,Rect2(at-pivot,region.size*scale_factor),region,Color(1,1,1,opacity))
                continue
        if str(entry.get("mechanic","")) not in ["circle_aoe","formation"]:
            at += Vector2(0,-30)
        var width := float(source.get("width",110))
        # Enhance only source-backed contact cels. Keep original projectile,
        # AoE footprint, and persistent status scale intact.
        var accent_contact := phase == "contact" and str(entry.get("mechanic","")) in ["projectile","melee","line"]
        if accent_contact:
            width *= 1.12
        var dims := Vector2(width,width*region.size.y/region.size.x)
        canvas.draw_set_transform(at,angle)
        if accent_contact:
            var halo_dims := dims*1.18
            canvas.draw_texture_rect_region(texture,Rect2(-halo_dims*0.5,halo_dims),region,Color(1,1,1,opacity*0.22))
        canvas.draw_texture_rect_region(texture,Rect2(-dims*0.5,dims),region,Color(1,1,1,opacity))
        canvas.draw_set_transform(Vector2.ZERO)
