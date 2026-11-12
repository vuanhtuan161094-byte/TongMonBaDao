class_name MapBattleWorldLayerV2
extends Node2D

# DV2-02D view adapter. This layer renders battle state only; it never advances combat.
# Summon silhouettes and short cues are procedural Godot drawing, driven by real V63 events.
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
const SUMMON_CUE_TYPES := ["v63_summon_created","v63_summon_attack","v63_summon_expired"]
const MAX_SUMMON_CUES := 12
const SUMMON_CUE_SECONDS := 0.9

var battle: MapBattleV2
var stage_rect := Rect2(Vector2(90.0,50.0),Vector2(1100.0,600.0))
var displayed_at: float = 0.0
var _event_cursor: int = 0
var _last_event_token := ""
var _summon_cues: Array[Dictionary] = []
var _presentation_time := 0.0
var _poll_accumulator := 0.0

func _ready() -> void:
    set_process(false)

func attach_session(session: MapBattleV2) -> void:
    battle = session
    displayed_at = battle.now if battle != null else 0.0
    _event_cursor = battle.events.size() if battle != null else 0
    _last_event_token = _last_token()
    _summon_cues.clear()
    _poll_accumulator = 0.0
    set_process(battle != null)
    queue_redraw()

func refresh_from_authority() -> void:
    if battle == null:
        return
    displayed_at = battle.now
    _consume_summon_events()
    set_process(true)
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
        if float(actor.get("hp",0.0)) <= 0.0 or bool(actor.get("is_v63_summon",false)):
            continue
        var at := point_on_map(actor["position"])
        var dist := at.distance_squared_to(map_position)
        if dist < nearest:
            nearest = dist
            best = str(id)
    return best

func _process(delta: float) -> void:
    if battle == null:
        set_process(false)
        return
    _presentation_time += delta
    _poll_accumulator += delta
    if _poll_accumulator >= 0.10:
        _poll_accumulator = 0.0
        var count := battle.events.size()
        var newest_token := _last_token()
        if battle.now != displayed_at or count != _event_cursor or (count >= MapBattleV2.MAX_EVENTS and newest_token != _last_event_token):
            displayed_at = battle.now
            _consume_summon_events()
    for cue in _summon_cues:
        cue["age"] = float(cue.get("age",0.0))+delta
    var alive_cues: Array[Dictionary] = []
    for cue in _summon_cues:
        if float(cue.get("age",0.0)) < SUMMON_CUE_SECONDS:
            alive_cues.append(cue)
    _summon_cues = alive_cues
    if not _summon_cues.is_empty() or _has_living_summons():
        queue_redraw()
    elif _poll_accumulator == 0.0:
        set_process(false)

func _consume_summon_events() -> void:
    if battle == null:
        return
    var count := battle.events.size()
    if count < _event_cursor:
        _event_cursor = maxi(0,count-16)
    var start := _event_cursor
    var newest_token := _last_token()
    if count == _event_cursor and count >= MapBattleV2.MAX_EVENTS and newest_token != _last_event_token:
        start = maxi(0,count-1)
    for index in range(start,count):
        var raw: Variant = battle.events[index]
        if not (raw is Dictionary):
            continue
        var event: Dictionary = raw
        var kind := str(event.get("type",""))
        if not SUMMON_CUE_TYPES.has(kind):
            continue
        var summon_id := str(event.get("summon_id",""))
        var summon: Dictionary = battle.actors.get(summon_id,{})
        var owner: Dictionary = battle.actors.get(str(event.get("owner_id","")),{})
        var origin: Vector2 = summon.get("position",owner.get("position",Vector2.ZERO))
        var target: Dictionary = battle.actors.get(str(event.get("target_id","")),{})
        var target_position: Vector2 = target.get("position",origin)
        var form := str(event.get("form",summon.get("summon_form","")))
        if form.is_empty():
            var skill_id := str(event.get("skill_id",""))
            if skill_id.contains(".kiem_linh."):
                form = "blade_spirit"
            elif skill_id.contains(".linh_thu."):
                form = "covenant_beast"
            elif skill_id.contains(".khoi_loi_ho_phap."):
                form = "guardian_construct"
        _summon_cues.append({
            "kind":kind,"skill_id":str(event.get("skill_id","")),"summon_id":summon_id,
            "form":form,"origin":origin,"target":target_position,"age":0.0
        })
        while _summon_cues.size() > MAX_SUMMON_CUES:
            _summon_cues.pop_front()
    _event_cursor = count
    _last_event_token = newest_token
    if not _summon_cues.is_empty() or _has_living_summons():
        set_process(true)

func _last_token() -> String:
    if battle == null or battle.events.is_empty():
        return ""
    var event: Dictionary = battle.events.back()
    return "|".join([str(event.get("type","")),str(event.get("time","")),str(event.get("summon_id","")),
        str(event.get("target_id","")),str(event.get("skill_id",""))])

func _has_living_summons() -> bool:
    if battle == null:
        return false
    for actor in battle.actors.values():
        if bool(actor.get("is_v63_summon",false)) and float(actor.get("hp",0.0)) > 0.0:
            return true
    return false

func summon_visual_family(form: String) -> String:
    if form == "blade_spirit":
        return "kiem_linh"
    if form == "covenant_beast":
        return "linh_thu"
    if form == "guardian_construct":
        return "khoi_loi_ho_phap"
    return "unknown"

func _draw() -> void:
    if battle == null:
        return
    var scale_x := stage_rect.size.x/GRID_SIZE.x
    var scale_y := stage_rect.size.y/GRID_SIZE.y
    for cast_value in battle.pending_casts:
        var cast: Dictionary = cast_value
        var center := point_on_map(cast["center"])
        var radius := Vector2(float(cast["radius"])*scale_x,float(cast["radius"])*scale_y)
        draw_set_transform(center,0.0,radius)
        draw_circle(Vector2.ZERO,1.0,WARNING)
        draw_arc(Vector2.ZERO,1.0,0.0,TAU,40,Color(0.94,0.36,0.26,0.74),0.08)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
    var ids: Array = battle.actors.keys()
    ids.sort()
    for id in ids:
        var actor: Dictionary = battle.actors[id]
        var at := point_on_map(actor["position"])
        var side := str(actor.get("side",""))
        var alive := float(actor["hp"]) > 0.0
        var tier := str(actor.get("tier","normal"))
        var is_summon := bool(actor.get("is_v63_summon",false))
        var fill := DISCIPLE_FILL if side == "disciple" else (
            BOSS_FILL if tier == "boss" else (ELITE_FILL if tier == "elite" else ENEMY_FILL)
        )
        if is_summon:
            fill = _summon_color(str(actor.get("summon_form","")))
        if not alive:
            fill = Color(0.42,0.42,0.41,0.36)
        var radius := 10.0 if tier == "boss" else (7.5 if tier == "elite" else (8.0 if is_summon else 6.0))
        draw_circle(at+Vector2(0.0,2.0),radius+2.0,BORDER)
        if is_summon and alive:
            _draw_summon_actor(actor,at,radius)
        else:
            draw_circle(at,radius,fill)
        if tier == "boss" and alive:
            draw_arc(at,radius+3.0,0.0,TAU,24,Color(0.94,0.73,0.39,0.85),1.3)
        var health := clampf(float(actor["hp"])/maxf(1.0,float(actor["max_hp"])),0.0,1.0)
        var bar := Rect2(at+Vector2(-11.0,-radius-10.0),Vector2(22.0,3.5))
        draw_rect(bar,HP_BG)
        draw_rect(Rect2(bar.position,Vector2(bar.size.x*health,bar.size.y)),
            HP_GOOD if side == "disciple" else HP_ENEMY)
    for cue in _summon_cues:
        _draw_summon_cue(cue)

func _summon_color(form: String) -> Color:
    if form == "blade_spirit":
        return Color("d9e5f0")
    if form == "covenant_beast":
        return Color("8fc89c")
    if form == "guardian_construct":
        return Color("dfc477")
    return DISCIPLE_FILL

func _draw_summon_actor(actor: Dictionary, center: Vector2, radius: float) -> void:
    var form := str(actor.get("summon_form",""))
    var color := _summon_color(form)
    var pulse := sin(_presentation_time*4.0)*0.14+0.86
    color.a = pulse
    var glow_color := Color(color.r,color.g,color.b,0.22+pulse*0.18)
    draw_arc(center,radius*1.25,0.0,TAU,28,glow_color,1.2,true)
    if form == "blade_spirit":
        draw_colored_polygon(PackedVector2Array([
            center+Vector2(0,-radius),center+Vector2(radius*0.26,0),
            center+Vector2(0,radius),center+Vector2(-radius*0.26,0)
        ]),color)
        draw_line(center+Vector2(0,-radius*1.2),center+Vector2(0,radius*1.2),Color("f4f7fa",pulse),1.2,true)
        draw_line(center+Vector2(-radius*0.5,radius*0.18),center+Vector2(radius*0.5,radius*0.18),Color("c7a95f",pulse),1.0,true)
        for side in [-1.0,1.0]:
            draw_line(center+Vector2(side*radius*0.34,-radius*0.22),center+Vector2(side*radius*0.9,-radius*0.48),glow_color,1.0,true)
    elif form == "covenant_beast":
        draw_set_transform(center,0.0,Vector2(1.0,0.72))
        draw_circle(Vector2(-radius*0.12,radius*0.13),radius*0.66,color)
        draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
        draw_circle(center+Vector2(radius*0.38,-radius*0.24),radius*0.36,Color("b8e1ae",pulse))
        draw_colored_polygon(PackedVector2Array([
            center+Vector2(radius*0.16,-radius*0.38),center+Vector2(radius*0.08,-radius*0.92),
            center+Vector2(radius*0.48,-radius*0.45)
        ]),color)
        draw_colored_polygon(PackedVector2Array([
            center+Vector2(radius*0.54,-radius*0.36),center+Vector2(radius*0.82,-radius*0.72),
            center+Vector2(radius*0.76,-radius*0.20)
        ]),color)
        var tail := PackedVector2Array([center+Vector2(-radius*0.46,radius*0.12),
            center+Vector2(-radius*0.94,radius*0.32),center+Vector2(-radius*1.08,radius*0.05)])
        draw_polyline(tail,glow_color,1.2,true)
    else:
        var shell := PackedVector2Array()
        for vertex in range(6):
            shell.append(center+Vector2.from_angle(TAU*float(vertex)/6.0-PI/2.0)*radius*0.9)
        draw_colored_polygon(shell,Color("7f6a3c",pulse))
        draw_polyline(shell,Color("f0d98f",pulse),1.4,true)
        draw_rect(Rect2(center-Vector2(radius*0.34,radius*0.42),Vector2(radius*0.68,radius*0.84)),Color("e4d09a",pulse))
        draw_line(center+Vector2(0,-radius*0.58),center+Vector2(0,radius*0.58),Color("9b7e49",pulse),1.0,true)

func _draw_summon_cue(cue: Dictionary) -> void:
    var age := clampf(float(cue.get("age",0.0))/SUMMON_CUE_SECONDS,0.0,1.0)
    var alpha := (1.0-age)*0.82
    if alpha <= 0.0:
        return
    var kind := str(cue.get("kind",""))
    var form := str(cue.get("form",""))
    var origin := point_on_map(cue.get("origin",Vector2.ZERO))
    var target := point_on_map(cue.get("target",Vector2.ZERO))
    var color := _summon_color(form)
    color.a = alpha
    if kind == "v63_summon_created":
        var radius := 7.0+age*34.0
        draw_arc(origin,radius,0.0,TAU,36,color,2.0,true)
        draw_arc(origin,radius*0.62,0.0,TAU,28,Color(color.r,color.g,color.b,alpha*0.6),1.0,true)
        for spoke in range(3):
            var angle := TAU*float(spoke)/3.0+age*0.5
            draw_line(origin+Vector2.from_angle(angle)*radius*0.45,origin+Vector2.from_angle(angle)*radius*0.88,color,1.1,true)
    elif kind == "v63_summon_attack":
        var thickness := maxf(0.8,2.8*(1.0-age))
        if form == "blade_spirit":
            draw_line(origin,target,color,thickness,true)
        elif form == "covenant_beast":
            var midpoint := origin.lerp(target,0.5)+Vector2(0.0,-7.0*(1.0-age))
            draw_polyline(PackedVector2Array([origin,midpoint,target]),color,thickness,true)
        elif form == "guardian_construct":
            draw_line(origin,target,Color(color.r,color.g,color.b,alpha*0.72),thickness*1.4,true)
            draw_line(origin+Vector2(-2.0,0.0),target+Vector2(-2.0,0.0),Color("fff0c3",alpha*0.62),1.0,true)
        draw_arc(target,3.0+age*12.0,0.0,TAU,24,color,thickness,true)
    else:
        var radius := 14.0*(1.0-age)
        draw_arc(origin,radius,0.0,TAU,28,color,1.2,true)

