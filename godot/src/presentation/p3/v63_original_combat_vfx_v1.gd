class_name V63OriginalCombatVfxV1
extends Control

const CUES := ["telegraph", "v63_skill_hit", "skill_cast", "v63_boss_phase", "boss_counter_hit", "status_applied"]
var _cue_kind := ""
var _cue_started := 0.0
var _event_cursor := 0

func _ready() -> void:
    set_process(true)
    queue_redraw()

func consume_battle_events(battle: MapBattleV2) -> void:
    if battle == null:
        return
    var newest: Dictionary = {}
    for index in range(battle.events.size()):
        var event: Dictionary = battle.events[index]
        var sequence := int(event.get("sequence", index + 1))
        if sequence <= _event_cursor:
            continue
        _event_cursor = maxi(_event_cursor, sequence)
        if CUES.has(str(event.get("type", ""))):
            newest = event
    if not newest.is_empty():
        _cue_kind = str(newest.get("type", ""))
        _cue_started = Time.get_ticks_msec() / 1000.0
        queue_redraw()

func _process(_delta: float) -> void:
    if _cue_kind.is_empty():
        return
    if Time.get_ticks_msec() / 1000.0 - _cue_started > 1.25:
        _cue_kind = ""
    queue_redraw()

func _draw() -> void:
    if _cue_kind.is_empty():
        return
    var age := clampf((Time.get_ticks_msec() / 1000.0 - _cue_started) / 1.25, 0.0, 1.0)
    var center := size * 0.5
    var color := _cue_color(_cue_kind)
    var radius := 6.0 + age * 22.0
    var alpha := (1.0 - age) * 0.92
    color.a = alpha
    draw_arc(center, radius, 0.0, TAU, 36, color, 3.0, true)
    if _cue_kind == "telegraph":
        draw_colored_polygon(PackedVector2Array([center + Vector2(0,-24), center + Vector2(-19,14), center + Vector2(19,14)]), Color(color.r, color.g, color.b, alpha * 0.30))
        draw_arc(center, 11.0 + age * 11.0, 0.0, TAU, 24, color, 2.0, true)
    elif _cue_kind == "v63_boss_phase":
        for spoke in range(4):
            var angle := float(spoke) * TAU / 4.0 + age * 0.5
            draw_line(center + Vector2.from_angle(angle) * 6.0, center + Vector2.from_angle(angle) * radius, color, 2.0, true)
    else:
        draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), color, 2.0, true)
        draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), color, 2.0, true)

func _cue_color(kind: String) -> Color:
    if kind == "telegraph":
        return Color("ef5748")
    if kind == "boss_counter_hit":
        return Color("f0bd53")
    if kind == "status_applied":
        return Color("65c8a3")
    if kind == "v63_boss_phase":
        return Color("bb8cef")
    return Color("8be5cf")
