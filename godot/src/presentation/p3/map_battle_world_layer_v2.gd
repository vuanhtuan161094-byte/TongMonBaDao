class_name MapBattleWorldLayerV2
extends Node2D

# DV2-02D region-map VIEW ADAPTER. NEVER advances battle simulation.
# Draws actor coordinates/HP/boss warning zones from MapBattleV2 snapshot.
# Minimal visual fallback only; production sprites/art and map tiles are later assets.
const DISCIPLE_FILL := Color(0.24,0.62,0.47,1.0)
const ENEMY_FILL := Color(0.68,0.28,0.23,1.0)
const ELITE_FILL := Color(0.75,0.45,0.16,1.0)
const BOSS_FILL := Color(0.58,0.23,0.46,1.0)
const BORDER := Color(0.13,0.15,0.12,0.88)
const HP_BG := Color(0.16,0.20,0.18,0.86)
const HP_GOOD := Color(0.36,0.83,0.45,1.0)
const HP_ENEMY := Color(0.91,0.39,0.35,1.0)
const WARNING := Color(0.92,0.28,0.20,0.32)
const GRID_SIZE := Vector2(36.0,20.0)

var battle: MapBattleV2
var stage_rect := Rect2(Vector2(90.0,50.0),Vector2(1100.0,600.0))
var displayed_at: float = 0.0

# Opt-in source-backed V4 view for isolated pilot; normal map retains original circles.
var enable_source_vl_art: bool = false
var draw_pilot_ground: bool = false
var _source_atlas := CombatV4SpriteAtlas.new()
var _frame_clock: float = 0.0
var _event_cursor: int = 0
var _facing: Dictionary = {}
var _positions: Dictionary = {}
var _last_move: Dictionary = {}
var _action_cues: Dictionary = {}
var _impact_cues: Dictionary = {}
var _effect_atlas := CombatV4EffectAtlas.new()
var _effect_cues: Array[Dictionary] = []

func _process(delta: float) -> void:
    if enable_source_vl_art and battle != null and is_visible_in_tree():
        # Visual time follows elapsed frame time; never slow down VFX on sub-20-FPS devices.
        _frame_clock += maxf(0.0, delta)
        for i in range(_effect_cues.size()-1,-1,-1):
            var cue: Dictionary = _effect_cues[i]
            if _frame_clock-float(cue["started"]) > _effect_atlas.duration(str(cue["kind"])):
                _effect_cues.remove_at(i)
        queue_redraw()

func _ingest_authority_events() -> void:
    if battle == null or not enable_source_vl_art:
        return
    for index in range(_event_cursor, battle.events.size()):
        var event: Dictionary = battle.events[index]
        var kind := str(event.get("type", ""))
        var actor_id := str(event.get("actor_id", ""))
        if kind == "move" and battle.actors.has(actor_id):
            var current: Vector2 = event.get("position", Vector2.ZERO)
            var previous: Vector2 = _positions.get(actor_id, current)
            var direction := current - previous
            if direction.length_squared() > 0.0001:
                _facing[actor_id] = direction.normalized()
            _positions[actor_id] = current
            _last_move[actor_id] = _frame_clock
        elif kind in ["hit", "skill_hit"]:
            if kind == "skill_hit" and str(event.get("skill_id","")) == "ngu_kiem_thuat":
                var impacted_id := str(event.get("target",""))
                if battle.actors.has(impacted_id):
                    _effect_cues.append({"kind":"sword_hit",
                        "at":point_on_map(battle.actors[impacted_id]["position"]),
                        "started":_frame_clock})
            var source := str(event.get("attacker", event.get("caster", "")))
            var target := str(event.get("target", ""))
            if battle.actors.has(source):
                _action_cues[source] = {"action":"attack", "started":_frame_clock, "until":_frame_clock+0.45}
                if battle.actors.has(target):
                    var direction := (battle.actors[target]["position"] as Vector2) - (battle.actors[source]["position"] as Vector2)
                    if direction.length_squared() > 0.001:
                        _facing[source] = direction.normalized()
            if kind == "hit" and battle.actors.has(target):
                _impact_cues[target] = _frame_clock
                if float(battle.actors[target].get("hp",0.0)) > 0.0:
                    _action_cues[target] = {"action":"hit","started":_frame_clock,"until":_frame_clock+0.24}
        elif kind == "skill_cast":
            var caster_id := str(event.get("actor_id", ""))
            if battle.actors.has(caster_id):
                if str(event.get("skill_id","")) == "ngu_kiem_thuat":
                    _effect_cues.append({"kind":"sword_cast",
                        "at":point_on_map(battle.actors[caster_id]["position"]),
                        "started":_frame_clock})
                _action_cues[caster_id] = {"action":"attack","started":_frame_clock,
                    "until":_frame_clock+clampf(float(event.get("release_at",battle.now+0.45))-battle.now,0.15,1.0)}
        elif kind in ["heal","guard","cast"]:
            var caster_id := str(event.get("caster",event.get("actor_id","")))
            if battle.actors.has(caster_id):
                _action_cues[caster_id] = {"action":"attack","started":_frame_clock,"until":_frame_clock+0.35}
        elif kind == "downed" and battle.actors.has(actor_id):
            _action_cues[actor_id] = {"action":"die","started":_frame_clock,"until":INF}
    _event_cursor = battle.events.size()

func _actor_clip(actor_id: String, alive: bool) -> Dictionary:
    var cue: Dictionary = _action_cues.get(actor_id,{})
    if not alive:
        return {"name":"die","age":maxf(0.0,_frame_clock-float(cue.get("started",_frame_clock)))}
    if not cue.is_empty() and _frame_clock <= float(cue.get("until",-1.0)):
        return {"name":str(cue["action"]),"age":maxf(0.0,_frame_clock-float(cue.get("started",_frame_clock)))}
    if _frame_clock-float(_last_move.get(actor_id,-99.0)) <= MapBattleV2.STEP_SECONDS+0.001:
        return {"name":"run","age":_frame_clock}
    return {"name":"idle","age":_frame_clock}


func attach_session(session: MapBattleV2) -> void:
    battle = session
    displayed_at = 0.0
    _frame_clock = 0.0
    _event_cursor = session.events.size() if session != null else 0
    _positions.clear()
    _facing.clear()
    _last_move.clear()
    _action_cues.clear()
    _impact_cues.clear()
    _effect_cues.clear()
    if session != null:
        for id in session.actors:
            _positions[str(id)] = session.actors[id]["position"]
            _facing[str(id)] = Vector2.RIGHT if str(session.actors[id].get("side","")) == "disciple" else Vector2.LEFT
    queue_redraw()

func refresh_from_authority() -> void:
    if battle != null:
        displayed_at = battle.now
        _ingest_authority_events()
    queue_redraw()

func point_on_map(logical_position: Vector2) -> Vector2:
    return stage_rect.position + Vector2(
        clampf(logical_position.x/GRID_SIZE.x,0.0,1.0)*stage_rect.size.x,
        clampf(logical_position.y/GRID_SIZE.y,0.0,1.0)*stage_rect.size.y
    )

func logical_from_map(map_position: Vector2) -> Vector2:
    if stage_rect.size.x <= 0.0 or stage_rect.size.y <= 0.0:
        return Vector2.ZERO
    var relative := (map_position-stage_rect.position)/stage_rect.size
    return Vector2(
        clampf(relative.x*GRID_SIZE.x,0.0,GRID_SIZE.x),
        clampf(relative.y*GRID_SIZE.y,0.0,GRID_SIZE.y)
    )

func actor_at_map_point(map_position: Vector2, max_distance: float = 17.0) -> String:
    if battle == null:
        return ""
    var best := ""
    var nearest := max_distance*max_distance
    var ids: Array = battle.actors.keys()
    ids.sort()
    for id in ids:
        var actor: Dictionary = battle.actors[id]
        if float(actor.get("hp",0.0)) <= 0.0:
            continue
        var at := point_on_map(actor["position"])
        var dist := at.distance_squared_to(map_position)
        if dist < nearest:
            nearest = dist
            best = str(id)
    return best

# Only cast packets with the actual delayed AoE geometry produce red zones.
# Learned single-target casts contain target_id/skill_id but NO center/radius.
# Kept pure so the focused test checks the SAME data consumed by _draw().
func aoe_warning_geometry() -> Array[Dictionary]:
    var zones: Array[Dictionary] = []
    if battle == null:
        return zones
    for cast_value in battle.pending_casts:
        if not (cast_value is Dictionary):
            continue
        var cast: Dictionary = cast_value
        if cast.has("skill_id") or cast.has("target_id"):
            continue
        if not (cast.has("center") and cast.has("radius") and cast.has("caster") and
                cast.has("ready") and cast.has("maximum")):
            continue
        if not (cast["center"] is Vector2) or not (cast["radius"] is float or cast["radius"] is int):
            continue
        if not (cast["ready"] is float or cast["ready"] is int) or not (cast["maximum"] is int):
            continue
        var center: Vector2 = cast["center"]
        var radius := float(cast["radius"])
        var ready_at := float(cast["ready"])
        if is_nan(center.x) or is_inf(center.x) or is_nan(center.y) or is_inf(center.y):
            continue
        if center.x < 0.0 or center.x > GRID_SIZE.x or center.y < 0.0 or center.y > GRID_SIZE.y:
            continue
        if is_nan(radius) or is_inf(radius) or radius <= 0.0:
            continue
        if is_nan(ready_at) or is_inf(ready_at) or ready_at < battle.now:
            continue
        if int(cast["maximum"]) < 1 or int(cast["maximum"]) > MapBattleV2.MAX_TARGETS_AOE:
            continue
        var caster_id := str(cast["caster"])
        var caster: Dictionary = battle.actors.get(caster_id,{})
        if caster_id.is_empty() or caster.is_empty() or float(caster.get("hp",0.0)) <= 0.0:
            continue
        zones.append({"center":center,"radius":radius})
    return zones

func _draw() -> void:
    if battle == null:
        return
    if draw_pilot_ground:
        draw_rect(stage_rect,Color(0.09,0.15,0.13,1.0))
        for grid_x in range(0,37,2):
            var x := stage_rect.position.x+float(grid_x)*stage_rect.size.x/GRID_SIZE.x
            draw_line(Vector2(x,stage_rect.position.y),Vector2(x,stage_rect.end.y),Color(0.16,0.25,0.18,0.18),1.0)
        for grid_y in range(0,21,2):
            var y := stage_rect.position.y+float(grid_y)*stage_rect.size.y/GRID_SIZE.y
            draw_line(Vector2(stage_rect.position.x,y),Vector2(stage_rect.end.x,y),Color(0.16,0.25,0.18,0.18),1.0)
    # Telegraphs are projected onto the SAME world-space positions as actors.
    # Drawing them never changes target hit checks performed in MapBattleV2.
    var scale_x := stage_rect.size.x/GRID_SIZE.x
    var scale_y := stage_rect.size.y/GRID_SIZE.y
    for zone in aoe_warning_geometry():
        var center := point_on_map(zone["center"])
        var radius := Vector2(float(zone["radius"])*scale_x,float(zone["radius"])*scale_y)
        # Slight top-down perspective: warning ellipse is a gameplay cue only.
        draw_set_transform(center,0.0,radius)
        draw_circle(Vector2.ZERO,1.0,WARNING)
        draw_arc(Vector2.ZERO,1.0,0.0,TAU,40,Color(0.94,0.36,0.26,0.74),0.08)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    # Art cues are observations of real V2 casts/hits; draw BELOW actor silhouettes and HP.
    if enable_source_vl_art:
        for cue in _effect_cues:
            var ratio := 0.42 if str(cue["kind"]) == "sword_cast" else 0.66
            _effect_atlas.draw_effect(self,str(cue["kind"]),cue["at"],
                _frame_clock-float(cue["started"]),ratio)
    var ids: Array = battle.actors.keys()
    # Isometric depth: far-away feet draw first; stable ID tie prevents flicker.
    # Presentation sort only, NEVER affects MapBattleV2 action/target order.
    if enable_source_vl_art:
        ids.sort_custom(func(a,b):
            var at_a: Vector2 = battle.actors[a]["position"]
            var at_b: Vector2 = battle.actors[b]["position"]
            if absf(at_a.y - at_b.y) > 0.00001:
                return at_a.y < at_b.y
            if absf(at_a.x - at_b.x) > 0.00001:
                return at_a.x < at_b.x
            return str(a) < str(b)
        )
    else:
        ids.sort()
    for id in ids:
        var actor: Dictionary = battle.actors[id]
        var at := point_on_map(actor["position"])
        var side := str(actor.get("side",""))
        var alive := float(actor["hp"]) > 0.0
        var tier := str(actor.get("tier","normal"))
        var fill := DISCIPLE_FILL if side == "disciple" else (
            BOSS_FILL if tier == "boss" else (ELITE_FILL if tier == "elite" else ENEMY_FILL)
        )
        if not alive:
            fill = Color(0.42,0.42,0.41,0.36)
        var radius := 10.0 if tier == "boss" else (7.5 if tier == "elite" else 6.0)
        var art_key := ""
        if side == "disciple":
            art_key = "hero"
        elif str(actor.get("species_id","")) in ["thanh_lang","hac_lang","hac_lang_vuong"]:
            art_key = "wolf"
        var art_used := false
        if enable_source_vl_art and not art_key.is_empty():
            var clip := _actor_clip(str(id),alive)
            var art_scale := 2.30 if tier == "boss" else (1.18 if art_key == "wolf" else 0.92)
            draw_circle(at+Vector2(0.0,3.0),maxf(8.0,radius*1.25),Color(0.02,0.05,0.04,0.43))
            art_used = _source_atlas.draw_actor(self,art_key,str(clip["name"]),at,
                _facing.get(str(id),Vector2.RIGHT),float(clip["age"]),art_scale)
        if not art_used:
            draw_circle(at+Vector2(0.0,2.0),radius+2.0,BORDER)
            draw_circle(at,radius,fill)
        if tier == "boss" and alive:
            draw_arc(at,maxf(15.0,radius+3.0),0.0,TAU,24,Color(0.94,0.73,0.39,0.85),1.5)
        var health := clampf(float(actor["hp"])/maxf(1.0,float(actor["max_hp"])),0.0,1.0)
        var bar_width := 53.0 if tier == "boss" else (42.0 if art_used else 22.0)
        var bar_height := 5.5 if tier == "boss" else 4.0
        var bar_y := -110.0 if art_used and tier == "boss" else (-78.0 if art_used else -radius-10.0)
        var bar := Rect2(at+Vector2(-bar_width*0.5,bar_y),Vector2(bar_width,bar_height))
        draw_rect(bar,HP_BG)
        draw_rect(Rect2(bar.position,Vector2(bar.size.x*health,bar.size.y)),
            HP_GOOD if side == "disciple" else HP_ENEMY)
        if enable_source_vl_art and _impact_cues.has(str(id)):
            var passed := _frame_clock-float(_impact_cues[str(id)])
            if passed >= 0.0 and passed < 0.30:
                draw_arc(at,13.0+passed*35.0,0.0,TAU,24,
                    Color(1.0,0.80,0.40,0.88*(1.0-passed/0.30)),2.0)
