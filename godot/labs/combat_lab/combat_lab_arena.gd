extends Control

const WORLD := Rect2(Vector2.ZERO, Vector2(36.0, 20.0))
const MAX_CUES := 64
var battle: MapBattleV2
var school := "bow"
var cues: Array[Dictionary] = []
var status_line := "Chưa bắt đầu · LAB_ONLY"
var zoom := 1.0

func _ready() -> void:
    custom_minimum_size = Vector2(620, 390)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = true

func set_battle(value: MapBattleV2, weapon_school: String) -> void:
    battle = value
    school = weapon_school
    cues.clear()
    queue_redraw()

func set_status(value: String) -> void:
    status_line = value
    queue_redraw()

func consume_events(rows: Array[Dictionary]) -> void:
    if battle == null:
        return
    var now_ms := Time.get_ticks_msec()
    for event in rows:
        var kind := str(event.get("type", ""))
        if kind == "hit":
            var hit_kind := str(event.get("kind", ""))
            if hit_kind == "v63_poison" or (hit_kind == "dot" and _has_damage_tick_record(event, rows)):
                continue
        var actor_id := str(event.get("target", event.get("actor_id", event.get("caster", event.get("attacker", "")))))
        var pos := _actor_position(actor_id)
        var cue_kind := ""
        var label := ""
        var color := Color("f2d9a0")
        var radius := 0.0
        var source_actor_id := str(event.get("caster", event.get("attacker", event.get("actor_id", ""))))
        match kind:
            "skill_cast", "cast":
                cue_kind = "cast"; color = Color("b890ff"); label = "THI PHÁP"
            "skill_release":
                var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(str(event.get("skill_id", "")), {})
                if float(definition.get("projectile_speed", 0.0)) > 0.0:
                    cue_kind = "projectile"; color = Color("d5bdff")
                elif str(definition.get("shape", "")) == "circle":
                    cue_kind = "aoe"; color = Color("e3a0ff"); radius = float(definition.get("radius", 0.0))
            "hit":
                cue_kind = "impact"; color = Color("ffb278")
                label = str(roundi(float(event.get("damage", 0.0))))
                if bool(event.get("critical", false)):
                    label = "BẠO KÍCH " + label; color = Color("fff09a")
            "v63_skill_hit", "skill_hit":
                # These semantic events follow the committed `hit`; render the
                # committed packet exactly once, plus independent status/heal events.
                continue
            "skill_miss":
                cue_kind = "miss"; color = Color("c1b6cf"); label = "TRƯỢT"
            "evade":
                cue_kind = "miss"; color = Color("a8e3ee"); label = "NÉ"
            "heal":
                cue_kind = "heal"; color = Color("82f0a1"); label = "+" + str(roundi(float(event.get("amount", 0.0))))
            "status_applied":
                cue_kind = "status"; color = Color("8fe878") if str(event.get("status", "")) == "poison" else Color("afa0ff")
                label = "ĐỘC" if str(event.get("status", "")) == "poison" else str(event.get("status", "")).to_upper()
            "status_tick":
                cue_kind = "poison" if str(event.get("status", "")) == "poison" else "impact"
                color = Color("91ec71") if cue_kind == "poison" else Color("ffad77")
                var tick_damage := float(event.get("damage", 0.0))
                label = ("ĐỘC " if cue_kind == "poison" else "DOT ") + str(roundi(tick_damage)) if tick_damage > 0.0 else str(event.get("status", "DOT")).to_upper()
            "damage_tick":
                cue_kind = "impact"; color = Color("91ec71"); label = "DOT " + str(roundi(float(event.get("damage", 0.0))))
            "telegraph":
                cue_kind = "telegraph"; color = Color("ff5368"); label = "NGUY HIỂM"
                var center: Variant = event.get("center", pos)
                if center is Vector2: pos = center
                radius = maxf(0.0, float(event.get("radius", 0.0)))
            "area_release":
                cue_kind = "area_burst"; color = Color("ff6671")
                var area_center: Variant = event.get("center", pos)
                if area_center is Vector2: pos = area_center
                label = "AOE · " + str(int(event.get("target_count", 0)))
            "downed":
                cue_kind = "death"; color = Color("8b8299"); label = "GỤC"
            "v63_boss_phase":
                cue_kind = "boss_phase"; color = Color("ff6c54"); label = "BOSS · PHA " + str(event.get("phase", ""))
        if cue_kind.is_empty():
            continue
        var cue_life := 220.0 if cue_kind == "projectile" else 1100.0
        var cue_from := _actor_position(source_actor_id)
        cues.append({"kind": cue_kind, "position": pos, "from_position": cue_from, "text": label, "color": color,
            "radius": radius, "source_actor_id": source_actor_id,
            "created": now_ms - (160 if cue_kind == "projectile" else 0), "life": cue_life,
            "source_index": int(event.get("lab_source_index", -1)), "time": float(event.get("time", 0.0))})
        if cues.size() > MAX_CUES: cues.pop_front()
        if kind == "hit" and float(event.get("lifesteal", 0.0)) > 0.0:
            var life_heal := roundi(float(event.get("lifesteal", 0.0)))
            cues.append({"kind": "heal", "position": cue_from, "from_position": cue_from, "text": "+" + str(life_heal),
                "color": Color("82f0a1"), "radius": 0.0, "source_actor_id": source_actor_id,
                "created": now_ms, "life": 1100.0, "source_index": int(event.get("lab_source_index", -1)),
                "time": float(event.get("time", 0.0))})
            if cues.size() > MAX_CUES: cues.pop_front()
    queue_redraw()

func _has_damage_tick_record(hit_event: Dictionary, rows: Array[Dictionary]) -> bool:
    for candidate in rows:
        if str(candidate.get("type", "")) != "damage_tick":
            continue
        if str(candidate.get("attacker", "")) != str(hit_event.get("attacker", "")):
            continue
        if str(candidate.get("target", "")) != str(hit_event.get("target", "")):
            continue
        if is_equal_approx(float(candidate.get("damage", -1.0)), float(hit_event.get("damage", -2.0))):
            return true
    return false
func _actor_position(actor_id: String) -> Vector2:
    if battle != null and battle.actors.has(actor_id):
        return battle.actors[actor_id].get("position", Vector2(18, 10))
    return Vector2(18, 10)

func _world_to_local(point: Vector2) -> Vector2:
    var margin := Vector2(30, 28)
    var span := size - margin * 2.0
    var centered := Vector2((point.x / WORLD.size.x - 0.5) * span.x, (point.y / WORLD.size.y - 0.5) * span.y)
    return margin + span * 0.5 + centered * zoom

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color("10101a"), true)
    draw_rect(Rect2(Vector2.ZERO, size), Color("403653"), false, 1.0)
    var margin := Vector2(30, 28)
    var span := size - margin * 2.0
    draw_rect(Rect2(margin, span), Color("171725"), true)
    for i in range(19):
        var x := margin.x + float(i) * span.x / 18.0
        draw_line(Vector2(x, margin.y), Vector2(x, margin.y + span.y), Color(0.65, 0.55, 0.8, 0.065), 1.0)
    for i in range(11):
        var y := margin.y + float(i) * span.y / 10.0
        draw_line(Vector2(margin.x, y), Vector2(margin.x + span.x, y), Color(0.65, 0.55, 0.8, 0.065), 1.0)
    draw_circle(Vector2(size.x * 0.5, size.y * 0.52), minf(size.x, size.y) * 0.30, Color(0.42, 0.24, 0.64, 0.055))
    draw_string(ThemeDB.fallback_font, Vector2(14, 20), status_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("cfc1e1"))
    if battle != null:
        var ids: Array = battle.actors.keys()
        ids.sort_custom(func(a: Variant, b: Variant) -> bool: return float(battle.actors[a].position.y) < float(battle.actors[b].position.y))
        for id in ids: _draw_actor(battle.actors[id])
    _draw_cues()

func _draw_actor(actor: Dictionary) -> void:
    var actor_id := str(actor.get("id", ""))
    var center := _world_to_local(actor.get("position", Vector2.ZERO))
    var monster := str(actor.get("side", "")) == "monster"
    var boss := str(actor.get("tier", "")) == "boss"
    var down := float(actor.get("hp", 0.0)) <= 0.0
    var scale := 1.45 if boss else 1.0
    var robe := Color("674791") if not monster else (Color("842b43") if boss else Color("536c4e"))
    var trim := Color("e8ca7b") if not monster else (Color("ff8071") if boss else Color("b8c98a"))
    if down: robe = robe.darkened(0.62)
    draw_circle(center + Vector2(0, 14 * scale), 15 * scale, Color(0, 0, 0, 0.45))
    # Temporary static Lab fixture. Combat movement and VFX come from real battle events.
    draw_rect(Rect2(center + Vector2(-8 * scale, -5 * scale), Vector2(16 * scale, 19 * scale)), robe, true)
    draw_colored_polygon(PackedVector2Array([center + Vector2(-10 * scale, 0), center + Vector2(0, 9 * scale), center + Vector2(10 * scale, 0), center + Vector2(14 * scale, 16 * scale), center + Vector2(-14 * scale, 16 * scale)]), trim.darkened(0.25))
    draw_circle(center + Vector2(0, -15 * scale), 8.0 * scale, Color("15121d"))
    draw_circle(center + Vector2(-2.7 * scale, -15 * scale), 1.25 * scale, Color("dfb4ff"))
    draw_circle(center + Vector2(2.7 * scale, -15 * scale), 1.25 * scale, Color("dfb4ff"))
    draw_line(center + Vector2(-5 * scale, 14 * scale), center + Vector2(-7 * scale, 22 * scale), trim, 2.5 * scale)
    draw_line(center + Vector2(5 * scale, 14 * scale), center + Vector2(7 * scale, 22 * scale), trim, 2.5 * scale)
    if not monster: _draw_weapon(center, school, scale, trim)
    var hp_ratio := clampf(float(actor.get("hp", 0)) / maxf(1.0, float(actor.get("max_hp", 1))), 0.0, 1.0)
    var bar := Rect2(center + Vector2(-16 * scale, -29 * scale), Vector2(32 * scale, 4 * scale))
    draw_rect(bar, Color("292531"), true)
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * hp_ratio, bar.size.y)), Color("81d99a") if not monster else Color("e56d74"), true)
    var name := actor_id.replace("lab_disciple_", "ĐT ")
    draw_string(ThemeDB.fallback_font, center + Vector2(-25 * scale, 38 * scale), name, HORIZONTAL_ALIGNMENT_CENTER, 50 * scale, 10, Color("e6dfef"))
func _draw_weapon(center: Vector2, weapon_school: String, scale: float, trim: Color) -> void:
    # Separate Lab-only weapon drawing path; body and weapon use no imported C2 art.
    match weapon_school:
        "bow":
            draw_arc(center + Vector2(14 * scale, -1), 9 * scale, -1.2, 1.2, 12, Color("d6c5f6"), 2 * scale)
            draw_line(center + Vector2(14 * scale, -10 * scale), center + Vector2(14 * scale, 8 * scale), trim, 1.2 * scale)
        "poison":
            draw_line(center + Vector2(13 * scale, 1), center + Vector2(24 * scale, -10 * scale), Color("a9ec82"), 3 * scale)
        _:
            draw_line(center + Vector2(12 * scale, 3), center + Vector2(23 * scale, -8 * scale), trim, 4 * scale)

func _draw_cues() -> void:
    var time := Time.get_ticks_msec()
    var live: Array[Dictionary] = []
    for cue in cues:
        var age := float(time - int(cue.created))
        if age >= float(cue.life): continue
        live.append(cue)
        var t := age / maxf(1.0, float(cue.life))
        var p := _world_to_local(cue.position)
        var color: Color = cue.color
        color.a *= 1.0 - t
        var lift := t * 28.0
        match str(cue.kind):
            "telegraph", "aoe":
                var r := float(cue.radius) * size.x / WORLD.size.x * (0.86 + t * 0.14)
                draw_arc(p, r, 0, TAU, 40, color, 3 if cue.kind == "telegraph" else 2)
                if cue.kind == "telegraph": draw_circle(p, r, Color(color.r, color.g, color.b, 0.09 * (1.0 - t)))
            "projectile":
                var projectile_start := _world_to_local(cue.get("from_position", cue.position))
                var projectile_point := projectile_start.lerp(p, t)
                draw_circle(projectile_point, 3.5, color)
                draw_line(projectile_start, projectile_point, color, 2)
            "area_burst": draw_arc(p, 12 + t * 18, 0, TAU, 28, color, 2)
            "death": draw_arc(p, 12 + t * 18, 0, TAU, 24, color, 2)
            "cast": draw_arc(p, 9 + t * 15, 0, TAU, 24, color, 2)
            "heal", "poison":
                for i in range(3):
                    var x := p.x + sin(t * TAU + float(i) * 2.1) * 8
                    draw_circle(Vector2(x, p.y - float(i) * 6 - lift * 0.4), 2.2, color)
            _:
                for i in range(5):
                    var angle := float(i) * TAU / 5.0 + t * 8
                    draw_circle(p + Vector2(cos(angle), sin(angle)) * (4 + t * 12), maxf(1.0, 2.8 * (1.0 - t)), color)
        if not str(cue.text).is_empty():
            draw_string(ThemeDB.fallback_font, p + Vector2(8, -12 - lift), str(cue.text), HORIZONTAL_ALIGNMENT_LEFT, 170, 12, color)
    cues = live
func set_zoom(value: float) -> void:
    zoom = clampf(value, 1.0, 6.0)
    queue_redraw()
