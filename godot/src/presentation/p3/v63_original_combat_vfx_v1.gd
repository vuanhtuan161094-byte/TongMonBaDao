class_name V63OriginalCombatVfxV1
extends Control

const CUES := ["telegraph", "v63_skill_hit", "skill_cast", "skill_release", "v63_mobility", "v63_sword_guard_reflect", "v63_blade_swing_hit", "v63_blade_guard_reflect", "v63_spear_line_hit", "v63_spear_shield_absorbed", "v63_dual_blade_hit", "v63_dual_blade_hp_trade", "v63_boss_phase", "boss_counter_hit", "status_applied"]
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
    var newest_blade_swing_by_skill: Dictionary = {}
    var newest_spear_line_by_skill: Dictionary = {}
    var newest_dual_blade_hit_by_skill: Dictionary = {}
    var newest_dual_blade_trade_by_skill: Dictionary = {}
    for index in range(battle.events.size()):
        var event: Dictionary = battle.events[index]
        var sequence := int(event.get("sequence", index + 1))
        if sequence <= _event_cursor:
            continue
        _event_cursor = maxi(_event_cursor, sequence)
        var event_type := str(event.get("type", ""))
        var event_skill_id := str(event.get("skill_id", ""))
        if CUES.has(event_type):
            newest = event
        if event_type == "v63_blade_swing_hit":
            newest_blade_swing_by_skill[event_skill_id] = event
        if event_type == "v63_spear_line_hit":
            newest_spear_line_by_skill[event_skill_id] = event
        if event_type == "v63_dual_blade_hit":
            newest_dual_blade_hit_by_skill[event_skill_id] = event
        if event_type == "v63_dual_blade_hp_trade":
            newest_dual_blade_trade_by_skill[event_skill_id] = event
    if str(newest.get("type", "")) == "v63_skill_hit":
        var newest_skill_id := str(newest.get("skill_id", ""))
        if newest_blade_swing_by_skill.has(newest_skill_id):
            newest = newest_blade_swing_by_skill[newest_skill_id]
        elif newest_spear_line_by_skill.has(newest_skill_id):
            newest = newest_spear_line_by_skill[newest_skill_id]
        elif newest_dual_blade_trade_by_skill.has(newest_skill_id):
            newest = newest_dual_blade_trade_by_skill[newest_skill_id]
        elif newest_dual_blade_hit_by_skill.has(newest_skill_id):
            newest = newest_dual_blade_hit_by_skill[newest_skill_id]
    if not newest.is_empty():
        _cue_event = newest.duplicate(true)
        _cue_kind = str(newest.get("type", ""))
        _cue_skill_id = str(newest.get("skill_id", newest.get("skill", "")))
        _cue_animation_key = ""
        _cue_vfx_key = ""
        _cue_effect = ""
        if _cue_skill_id.begins_with("tmb.skill.sword.") or _cue_skill_id.begins_with("tmb.skill.blade.") or _cue_skill_id.begins_with("tmb.skill.spear.") or _cue_skill_id.begins_with("tmb.skill.dual_blade."):
            var definition := V63HumanSkillCombatSystem.skill_definition(_cue_skill_id)
            _cue_animation_key = str(definition.get("animation_key",""))
            _cue_vfx_key = str(definition.get("vfx_key",""))
            _cue_effect = str(newest.get("status",definition.get("effect","")))
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
    if _cue_skill_id.begins_with("tmb.skill.blade."):
        _draw_blade(center, age, alpha)
        return
    if _cue_skill_id.begins_with("tmb.skill.spear."):
        _draw_spear(center, age, alpha)
        return
    if _cue_skill_id.begins_with("tmb.skill.dual_blade."):
        _draw_dual_blade(center, age, alpha)
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

func _draw_blade(center: Vector2, age: float, alpha: float) -> void:
    var branch := _blade_branch(_cue_skill_id)
    var color := _cue_color(_cue_kind)
    var pulse := 7.0 + 25.0 * age
    var ultimate := _cue_vfx_key.contains("ultimate")
    color.a = alpha
    if branch == "cuong_dao":
        # Each arc corresponds to a combat-confirmed swing event; no visual-only hit is added.
        var hit_index := int(_cue_event.get("hit_index",1))
        var sweep := -2.9 if hit_index % 2 == 1 else -0.2
        var radius := (12.0 + pulse * 0.7) * (1.0 + float(hit_index - 1) * 0.08)
        draw_arc(center, radius, sweep, sweep + 1.85, 34, color, 3.4 if ultimate else 2.8, true)
        draw_line(center + Vector2(-pulse * 0.7, pulse * 0.45), center + Vector2(pulse * 0.7, -pulse * 0.45), Color(color.r,color.g,color.b,alpha * 0.65), 2.0, true)
        if _cue_kind == "v63_blade_swing_hit":
            draw_circle(center + Vector2(pulse * 0.55,-pulse * 0.2), 2.0, color)
    elif branch == "tram_phach_dao":
        var slant := -1.0 if int(_cue_event.get("sequence",0)) % 2 == 0 else 1.0
        draw_line(center + Vector2(-pulse * 0.28,-pulse * slant), center + Vector2(pulse * 0.28,pulse * slant), color, 2.2 if not ultimate else 3.2, true)
        if _cue_effect == "mark" or (_cue_kind == "status_applied" and str(_cue_event.get("status","")) == "mark"):
            var mark_center := center + Vector2(0.0,-pulse * 0.18)
            var diamond := PackedVector2Array([mark_center + Vector2(0,-5),mark_center + Vector2(4,0),mark_center + Vector2(0,5),mark_center + Vector2(-4,0)])
            draw_colored_polygon(diamond, Color(color.r,color.g,color.b,alpha * 0.75))
            draw_arc(center, 6.0 + age * 8.0, 0.0, TAU, 24, Color(color.r,color.g,color.b,alpha * 0.72), 1.5, true)
        else:
            draw_line(center + Vector2(-pulse * 0.6,0),center + Vector2(pulse * 0.6,0),Color(color.r,color.g,color.b,alpha * 0.45),1.0,true)
    elif branch == "tran_dao":
        var start_angle := -2.75
        var end_angle := -0.38
        if _cue_kind == "v63_blade_guard_reflect":
            start_angle = 0.38
            end_angle = 2.75
        var gate_scale := 1.2 if ultimate else 1.0
        var radius := (10.0 + pulse * 0.45) * gate_scale
        draw_arc(center,radius,start_angle,end_angle,40,color,3.2 if ultimate else 2.5,true)
        draw_arc(center,radius * 0.72,start_angle,end_angle,36,Color(color.r,color.g,color.b,alpha * 0.42),1.2,true)
        if _cue_kind == "v63_blade_guard_reflect":
            for spoke in range(3):
                var x := float(spoke - 1) * 7.0
                draw_line(center + Vector2(x,0),center + Vector2(x * 1.8,pulse * 0.75),color,1.8,true)
        elif _cue_effect == "guard" or (_cue_kind == "status_applied" and str(_cue_event.get("status","")) == "guard"):
            draw_arc(center,radius * 1.15,0.0,TAU,36,Color(color.r,color.g,color.b,alpha * 0.35),1.1,true)
    else:
        draw_line(center + Vector2(-pulse * 0.6,pulse * 0.25),center + Vector2(pulse * 0.6,-pulse * 0.25),color,2.4,true)
        draw_arc(center,5.0 + pulse * 0.28,0.0,TAU,24,color,1.5,true)

func _draw_spear(center: Vector2, age: float, alpha: float) -> void:

    var branch := _spear_branch(_cue_skill_id)
    var color := _cue_color(_cue_kind)
    var reach := 9.0 + 30.0 * age
    var width := 2.0 + (1.1 if _cue_vfx_key.contains("ultimate") else 0.0)
    color.a = alpha
    if branch == "pha_tran_thuong":
        # Narrow, straight thrust. A separate short parallel trace reads as a spear shaft.
        draw_line(center + Vector2(-reach, 0), center + Vector2(reach, 0), color, width, true)
        draw_line(center + Vector2(-reach * 0.38, -3.0), center + Vector2(reach * 0.45, -3.0), Color(color.r,color.g,color.b,alpha * 0.56), 1.1, true)
        draw_colored_polygon(PackedVector2Array([center+Vector2(reach,0),center+Vector2(reach-7,-4),center+Vector2(reach-7,4)]),color)
    elif branch == "long_thuong":
        # Curled vapor follows one real line hit; it never creates a summoned actor.
        var curl := PackedVector2Array()
        for i in range(17):
            var t := float(i) / 16.0
            curl.append(center + Vector2(-reach + 2.0 * reach * t, sin(t * TAU * 1.35 + age * 2.0) * (2.0 + 4.0 * age)))
        draw_polyline(curl,color,width,true)
        draw_line(center + Vector2(reach * 0.45,-5.0),center + Vector2(reach,0),Color(color.r,color.g,color.b,alpha * 0.72),1.4,true)
    elif branch == "ho_quan_thuong":
        var radius := 12.0 + reach * 0.45
        var shield_color := Color("89ddc8",alpha * (0.75 if _cue_kind == "v63_spear_shield_absorbed" else 0.58))
        draw_arc(center,radius,-2.45,-0.69,32,shield_color,width,true)
        draw_arc(center,radius * 0.78,-2.30,-0.84,28,Color("ead18b",alpha * 0.58),1.2,true)
        if _cue_kind == "v63_spear_shield_absorbed":
            for spoke in range(3):
                var x := float(spoke - 1) * 9.0
                draw_line(center+Vector2(x,-radius * 0.25),center+Vector2(x * 1.35,radius * 0.45),shield_color,1.7,true)
    else:
        draw_line(center + Vector2(-reach * 0.75, reach * 0.18), center + Vector2(reach * 0.75, -reach * 0.18), color, width, true)
    draw_arc(center,4.0 + 10.0 * age,0.0,TAU,24,Color(color.r,color.g,color.b,alpha * 0.46),1.1,true)

func _draw_dual_blade(center: Vector2, age: float, alpha: float) -> void:
    var branch := _dual_blade_branch(_cue_skill_id)
    var reach := 10.0 + 26.0 * age
    var width := 2.0 + (1.0 if _cue_vfx_key.contains("ultimate") else 0.0)
    if _cue_kind == "v63_dual_blade_hp_trade":
        var blood := Color("b52f46", alpha)
        draw_arc(center, reach * 0.62, -2.9, 0.45, 38, blood, width + 0.8, true)
        draw_arc(center, reach * 0.44, -2.55, 0.2, 32, Color("ead18b", alpha * 0.78), 1.4, true)
        draw_circle(center, 3.0 + age * 4.0, Color(blood.r, blood.g, blood.b, alpha * 0.48))
        return
    var color := _cue_color(_cue_kind)
    color.a = alpha
    if branch == "anh_nhan":
        # Two arcs follow the original actor; no illusion actor or extra hit.
        draw_arc(center + Vector2(-4.0, 1.5), reach * 0.8, -2.7, 0.5, 32, color, width, true)
        draw_arc(center + Vector2(4.0, -1.5), reach * 0.8, 0.4, 3.6, 32, Color("8cd6e0", alpha), width, true)
    elif branch == "lien_hoan":
        var index := int(_cue_event.get("hit_index", 1))
        var sign := -1.0 if index % 2 == 1 else 1.0
        var start := center + Vector2(-reach * 0.72, sign * reach * 0.34)
        var finish := center + Vector2(reach * 0.72, -sign * reach * 0.34)
        draw_line(start, finish, color, width, true)
        draw_line(start + Vector2(0.0, sign * 5.0), finish + Vector2(0.0, sign * 5.0), Color("e7d5a0", alpha * 0.62), 1.1, true)
    elif branch == "huyet_nguyet":
        draw_arc(center, reach * 0.68, -2.7, 0.52, 36, Color("c94857", alpha), width, true)
        draw_line(center + Vector2(-reach * 0.55, reach * 0.18), center + Vector2(reach * 0.48, -reach * 0.12), Color("f0c6a0", alpha * 0.78), 1.5, true)
    else:
        draw_line(center + Vector2(-reach * 0.7, reach * 0.26), center + Vector2(reach * 0.7, -reach * 0.26), color, width, true)
    draw_arc(center, 3.0 + age * 10.0, 0.0, TAU, 24, Color(color.r, color.g, color.b, alpha * 0.42), 1.1, true)

func _blade_branch(skill_id: String) -> String:
    for branch in ["cuong_dao","tram_phach_dao","tran_dao"]:
        if skill_id.contains("." + branch + "."):
            return branch
    return "common"

func _sword_branch(skill_id: String) -> String:
    for branch in ["ngu_kiem", "sat_kiem", "ho_kiem"]:
        if skill_id.contains("." + branch + "."):
            return branch
    return "common"

func _spear_branch(skill_id: String) -> String:
    for branch in ["pha_tran_thuong", "long_thuong", "ho_quan_thuong"]:
        if skill_id.contains("." + branch + "."):
            return branch
    return "common"

func _dual_blade_branch(skill_id: String) -> String:
    for branch in ["anh_nhan", "lien_hoan", "huyet_nguyet"]:
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
    if _cue_kind == "v63_blade_guard_reflect":
        return Color("efcf75")
    if _cue_kind == "v63_dual_blade_hp_trade" or _cue_skill_id.contains(".huyet_nguyet."):
        return Color("c94857")
    if _cue_skill_id.contains(".anh_nhan."):
        return Color("9fc9e7")
    if _cue_skill_id.contains(".lien_hoan."):
        return Color("e6d69e")
    if _cue_kind == "v63_spear_shield_absorbed" or _cue_skill_id.contains(".ho_quan_thuong."):
        return Color("8bd8c6")
    if _cue_skill_id.contains(".long_thuong."):
        return Color("77c8e2")
    if _cue_skill_id.contains(".pha_tran_thuong."):
        return Color("d5dbe3")
    if _cue_skill_id.contains(".cuong_dao."):
        return Color("bf6b48")
    if _cue_skill_id.contains(".tram_phach_dao."):
        return Color("e4e9ed")
    if _cue_skill_id.contains(".tran_dao."):
        return Color("d5b867")
    if _cue_skill_id.contains(".sat_kiem."):
        return Color("e9dfd0")
    if _cue_skill_id.contains(".ho_kiem."):
        return Color("8bd8c6")
    return Color("8be5cf")
