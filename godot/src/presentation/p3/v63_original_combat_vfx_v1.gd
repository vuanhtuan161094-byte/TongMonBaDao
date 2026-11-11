class_name V63OriginalCombatVfxV1
extends Control

const CUES := ["telegraph", "v63_skill_hit", "skill_cast", "skill_release", "v63_mobility", "v63_sword_guard_reflect", "v63_boss_phase", "boss_counter_hit", "status_applied"]
var _cue_kind := ""
var _cue_started := 0.0
var _event_cursor := 0
var _cue_skill_id := ""
var _cue_animation_key := ""
var _cue_vfx_key := ""
var _cue_effect := ""
var _cue_event: Dictionary = {}

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
        _cue_event = newest.duplicate(true)
        _cue_kind = str(newest.get("type", ""))
        _cue_skill_id = str(newest.get("skill_id", newest.get("skill", "")))
        _cue_animation_key = ""
        _cue_vfx_key = ""
        _cue_effect = ""
        if _cue_skill_id.begins_with("tmb.skill.sword."):
            var definition := V63HumanSkillCombatSystem.skill_definition(_cue_skill_id)
            _cue_animation_key = str(definition.get("animation_key",""))
            _cue_vfx_key = str(definition.get("vfx_key",""))
            _cue_effect = str(definition.get("effect",""))
        _cue_started = Time.get_ticks_msec() / 1000.0
        queue_redraw()

func _process(_delta: float) -> void:
    if _cue_kind.is_empty():
        return
    if Time.get_ticks_msec() / 1000.0 - _cue_started > 1.25:
        _cue_kind = ""
        _cue_skill_id = ""
        _cue_animation_key = ""
        _cue_vfx_key = ""
        _cue_effect = ""
        _cue_event.clear()
    queue_redraw()

func _draw() -> void:
    if _cue_kind.is_empty():
        return
    var age := clampf((Time.get_ticks_msec() / 1000.0 - _cue_started) / 1.25, 0.0, 1.0)
    var center := size * 0.5
    var alpha := (1.0 - age) * 0.92
    if _cue_skill_id.begins_with("tmb.skill.sword."):
        _draw_sword(center, age, alpha)
        return
    var color := _cue_color(_cue_kind)
    color.a = alpha
    var radius := 6.0 + age * 22.0
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

func _draw_sword(center: Vector2, age: float, alpha: float) -> void:
    var branch := _sword_branch(_cue_skill_id)
    var color := _cue_color(_cue_kind)
    var tier_scale := 1.0
    if _cue_animation_key.contains("immortal"):
        tier_scale = 1.08
    elif _cue_animation_key.contains("divine"):
        tier_scale = 1.16
    var pulse := (5.0 + 23.0 * age) * tier_scale
    var is_ultimate := _cue_vfx_key.contains("ultimate")
    color.a = alpha
    if branch == "ngu_kiem":
        var converge := 0.25 + age * 0.75
        var blade_count := 5 if is_ultimate else 3
        for i in range(blade_count):
            var offset := float(i - (blade_count / 2))
            var start := center + Vector2(-pulse * (1.0 + absf(offset) * 0.25), offset * 13.0)
            var finish := center + Vector2(pulse * converge, offset * (10.0 - 6.0 * age))
            draw_line(start, finish, color, 2.4 - age * 0.8, true)
            draw_line(start + Vector2(0, -2.0), finish + Vector2(0, -2.0), Color(color.r, color.g, color.b, alpha * 0.32), 1.0, true)
        draw_arc(center, 4.0 + pulse * 0.45, -0.75, 0.75, 28, color, 1.6, true)
    elif branch == "sat_kiem":
        var direction := -1.0 if int(_cue_event.get("sequence", 0)) % 2 == 0 else 1.0
        draw_line(center + Vector2(-pulse, pulse * direction), center + Vector2(pulse, -pulse * direction), color, 3.2 - age * 1.0, true)
        if _cue_kind == "v63_skill_hit":
            draw_line(center + Vector2(-pulse * 0.45, 0), center + Vector2(pulse * 0.45, 0), Color(color.r, color.g, color.b, alpha * 0.72), 1.5, true)
    elif branch == "ho_kiem":
        var start_angle := -2.55
        var end_angle := -0.59
        if _cue_kind == "v63_sword_guard_reflect":
            start_angle = 0.59
            end_angle = 2.55
        var guard_scale := 1.18 if is_ultimate else 1.0
        draw_arc(center, (9.0 + pulse * 0.45) * guard_scale, start_angle, end_angle, 36, color, 3.0 - age * 0.7, true)
        draw_arc(center, (5.0 + pulse * 0.28) * guard_scale, start_angle, end_angle, 32, Color(color.r, color.g, color.b, alpha * 0.45), 1.3, true)
        if _cue_kind == "v63_sword_guard_reflect":
            for spoke in range(3):
                var x := float(spoke - 1) * 8.0
                draw_line(center + Vector2(x, -4.0), center + Vector2(x * 1.7, -pulse), color, 1.8, true)
    else:
        draw_line(center + Vector2(-pulse, pulse * 0.45), center + Vector2(pulse, -pulse * 0.45), color, 2.6, true)
        draw_arc(center, 4.0 + pulse * 0.3, 0.0, TAU, 24, color, 1.5, true)

func _sword_branch(skill_id: String) -> String:
    for branch in ["ngu_kiem", "sat_kiem", "ho_kiem"]:
        if skill_id.contains("." + branch + "."):
            return branch
    return "common"

func _cue_color(kind: String) -> Color:
    if kind == "telegraph":
        return Color("ef5748")
    if kind == "boss_counter_hit":
        return Color("f0bd53")
    if kind == "status_applied":
        return Color("65c8a3")
    if kind == "v63_boss_phase":
        return Color("bb8cef")
    if kind == "v63_sword_guard_reflect":
        return Color("f4d57a")
    if kind == "v63_mobility":
        return Color("9be8ee")
    if _cue_skill_id.contains(".sat_kiem."):
        return Color("e9dfd0")
    if _cue_skill_id.contains(".ho_kiem."):
        return Color("8bd8c6")
    return Color("8be5cf")
