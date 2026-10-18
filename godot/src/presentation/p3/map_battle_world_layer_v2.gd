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

func attach_session(session: MapBattleV2) -> void:
    battle = session
    displayed_at = 0.0
    queue_redraw()

func refresh_from_authority() -> void:
    if battle != null:
        displayed_at = battle.now
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
    var ids: Array = battle.actors.keys()
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
        draw_circle(at+Vector2(0.0,2.0),radius+2.0,BORDER)
        draw_circle(at,radius,fill)
        if tier == "boss" and alive:
            draw_arc(at,radius+3.0,0.0,TAU,24,Color(0.94,0.73,0.39,0.85),1.3)
        var health := clampf(float(actor["hp"])/maxf(1.0,float(actor["max_hp"])),0.0,1.0)
        var bar := Rect2(at+Vector2(-11.0,-radius-10.0),Vector2(22.0,3.5))
        draw_rect(bar,HP_BG)
        draw_rect(Rect2(bar.position,Vector2(bar.size.x*health,bar.size.y)),
            HP_GOOD if side == "disciple" else HP_ENEMY)
