extends Control

const ActorRigV2 = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const PoisonAtlasV1 = preload("res://labs/combat_lab/combat_lab_poison_atlas_v1.gd")
const VfxV2 = preload("res://labs/combat_lab/combat_lab_vfx_v2.gd")
const VFXProgression = preload("res://labs/combat_lab/combat_lab_vfx_progression.gd")
const V4SpellSpark = preload("res://labs/combat_lab/combat_lab_v4_spell_spark.gd")

var actor_states: Dictionary = {}
var last_skill_by_actor: Dictionary = {}
# Presentation-only cast snapshots: match V6.3 circle targeting's locked center.
var locked_aoe_center_by_caster: Dictionary = {}

const WORLD := Rect2(Vector2.ZERO, Vector2(36.0, 20.0))
const MAX_CUES := 64
var battle: MapBattleV2
var school := "bow"
var cues: Array[Dictionary] = []
var status_line := "Chưa bắt đầu · LAB_ONLY"
var zoom := 1.0
var visual_time := 0.0
var poison_atlas_warning_emitted := false
var v4_preview_enabled := OS.get_environment("TMB_POISON_V4_PREVIEW") == "1"
var v8_preview_enabled := OS.get_environment("TMB_POISON_V8_PREVIEW") == "1"

# Opt-in V4 Movie Maker focus; default Combat Lab/production camera is unchanged.
var v4_shot_source_id := ""
var v4_shot_target_id := ""
var v4_shot_camera_center := WORLD.size * 0.5
var v4_shot_reached_target := false
# LAB-only 4v8 cinema: an honest framing magnification, not a change to
# actor positions or canonical world-space ranges. Ordinary Lab remains 1:1.
var v4_swarm_cinematic := false

func set_v4_swarm_cinematic(value: bool) -> void:
    v4_swarm_cinematic = value
    queue_redraw()

func v4_effective_render_zoom() -> float:
    # Only cinematic 1x group footage needs a larger stage. 2x/4x/6x
    # retain their requested camera zoom and original actor dimensions.
    return 1.65 if v4_swarm_cinematic and zoom <= 1.01 else zoom

func _ready() -> void:
    custom_minimum_size = Vector2(620, 390)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    clip_contents = true

func set_battle(value: MapBattleV2, weapon_school: String) -> void:
    battle = value
    school = weapon_school
    cues.clear()
    actor_states.clear()
    last_skill_by_actor.clear()
    locked_aoe_center_by_caster.clear()
    visual_time = battle.now if battle != null else 0.0
    v4_shot_source_id = ""
    v4_shot_target_id = ""
    v4_shot_camera_center = WORLD.size * 0.5
    v4_shot_reached_target = false
    queue_redraw()

func set_status(value: String) -> void:
    status_line = value
    queue_redraw()

func set_v4_preview_enabled(value: bool) -> void:
    # Combat Lab only. Production/V3 renderer remains the default elsewhere.
    v4_preview_enabled = value
    queue_redraw()

func set_v8_preview_enabled(value: bool) -> void:
    # This is a render-only Lab switch. Turn on the V4 carrier, never
    # change V6.3 event semantics, actor statistics, cooldown or Save.
    v8_preview_enabled = value
    if value:
        v4_preview_enabled = true
    queue_redraw()

func set_visual_time(value: float) -> void:
    # Presentation clock follows battle time; HOLD freezes projectile motion.
    visual_time = maxf(0.0, value)

func _set_pose(actor_id: String, pose: String, lifetime_ms: int, event_time: float = -1.0) -> void:
    if battle == null or not battle.actors.has(actor_id):
        return
    var state: Dictionary = actor_states.get(actor_id, {})
    if state.is_empty():
        state = {"pose":"idle", "until":0.0, "started":visual_time,
            "last_position":battle.actors[actor_id].get("position", Vector2.ZERO)}
    if str(state.get("pose", "")) == "death":
        return
    var is_poison_disciple := school == "poison" and str(battle.actors[actor_id].get("side", "")) != "monster"
    var pose_start := visual_time
    if is_poison_disciple and event_time >= 0.0:
        pose_start = event_time
    # A canonical skill_release already starts the complete Attack clip. A
    # later hit event for that same swing must not restart it mid-frame.
    if is_poison_disciple and pose == "attack" and str(state.get("pose", "")) == "attack" \
            and pose_start < float(state.get("until", 0.0)):
        return
    # Poison atlas timing follows the event's battle timestamp; the other
    # Combat Lab rigs keep their existing presentation clock. HOLD freezes it.
    state["pose"] = pose
    state["started"] = pose_start
    state["until"] = pose_start + float(lifetime_ms) / 1000.0
    actor_states[actor_id] = state

func pose_for_actor(actor_id: String) -> String:
    # Public read-only visual probe. No simulation writes.
    if battle == null or not battle.actors.has(actor_id):
        return "idle"
    if float(battle.actors[actor_id].get("hp", 0.0)) <= 0.0:
        return "death"
    var state: Dictionary = actor_states.get(actor_id, {})
    if visual_time < float(state.get("until", 0.0)):
        return str(state.get("pose", "idle"))
    return "idle"

func _track_movement(actor: Dictionary) -> void:
    var id := str(actor.get("id", ""))
    var pos: Vector2 = actor.get("position", Vector2.ZERO)
    var state: Dictionary = actor_states.get(id, {})
    if state.is_empty():
        actor_states[id] = {"pose":"idle", "until":0.0, "started":visual_time,
            "last_position":pos}
        return
    var old_pos: Vector2 = state.get("last_position", pos)
    state["last_position"] = pos
    if pos.distance_to(old_pos) > 0.015 and visual_time >= float(state.get("until", 0.0)):
        state["pose"] = "walk"
        state["started"] = visual_time
        state["until"] = visual_time + 0.20
    actor_states[id] = state

func _pose_lifetime_ms(actor_id: String, pose: String, fallback_ms: int) -> int:
    if school != "poison" or battle == null or not battle.actors.has(actor_id):
        return fallback_ms
    var actor: Dictionary = battle.actors[actor_id]
    if str(actor.get("side", "")) == "monster":
        return fallback_ms
    var atlas_duration := PoisonAtlasV1.clip_duration_ms(pose)
    return atlas_duration if atlas_duration > 0 else fallback_ms

# Runtime pose cadence follows the CURRENT authoritative attack/cast speed,
# never the original 2.4s atlas movie clip duration. Long clips are time-
# remapped by PoisonAtlasV1.frame_index() to fit these windows.
func _combat_pose_ms(actor_id: String, skill_release: bool) -> int:
    if battle == null or not battle.actors.has(actor_id):
        return 320
    var owner: Dictionary = battle.actors[actor_id]
    var stats: Dictionary = V63HumanSkillCombatSystem.effective_attack_stats(owner, owner.get("stats", {}))
    var haste := float(stats.get("cast_speed", 0.0)) if skill_release else float(stats.get("attack_speed", 0.0))
    var divisor := maxf(0.45, 1.0 + haste)
    var baseline := 475.0 if skill_release else 290.0
    return clampi(roundi(baseline / divisor), 105, 540)

func consume_events(rows: Array[Dictionary]) -> void:
    if battle == null:
        return
    var now_ms := roundi(visual_time * 1000.0)
    for event in rows:
        var kind := str(event.get("type", ""))
        var source_actor_id := str(event.get("caster", event.get("attacker", event.get("actor_id", ""))))
        var target_id := str(event.get("target", event.get("target_id", event.get("actor_id", ""))))
        var source_skill := str(event.get("skill_id", event.get("source_skill_id", "")))
        var event_time := float(event.get("time", visual_time))
        if not source_skill.is_empty() and kind in ["skill_cast", "skill_release"]:
            last_skill_by_actor[source_actor_id] = source_skill
        if kind == "skill_cast" and battle.actors.has(source_actor_id):
            var owner: Dictionary = battle.actors[source_actor_id]
            var pending: Dictionary = owner.get("v63_pending_cast", {})
            if str(pending.get("shape", "")) == "circle" and pending.get("center", null) is Vector2:
                locked_aoe_center_by_caster[source_actor_id] = {
                    "center": pending["center"], "skill_id": source_skill}
        if kind == "skill_cast":
            if school == "poison" and battle.actors.has(source_actor_id) \
                    and str(battle.actors[source_actor_id].get("side", "")) != "monster":
                # The release deadline includes projectile flight. A caster
                # must animate only its actual wind-up, never stand casting
                # while the needle is already flying toward moving enemies.
                var skill: Dictionary = CombatLabRosterAdapter.skill_definitions().get(source_skill, {})
                var casting_actor: Dictionary = battle.actors[source_actor_id]
                var effective := V63HumanSkillCombatSystem.effective_attack_stats(casting_actor, casting_actor.get("stats", {}))
                var cast_rate := maxf(0.1, 1.0 + float(effective.get("cast_speed", 0.0)))
                var windup := maxf(MapBattleV2.STEP_SECONDS, float(skill.get("cast_time", 0.0)) / cast_rate)
                _set_pose(source_actor_id, "cast", roundi(windup * 1000.0), event_time)
            else:
                var duration := clampi(roundi((float(event.get("release_at", 0.0)) - event_time) * 1000.0), 300, 1200)
                _set_pose(source_actor_id, "cast", duration)
        elif kind == "skill_release":
            _set_pose(source_actor_id, "attack", _combat_pose_ms(source_actor_id, true), event_time)
        elif kind == "hit" and float(event.get("damage", 0.0)) > 0.0:
            # DoT/reflect are autonomous settlements: never replay a weapon swing
            # for the original caster when poison, burn or reflection ticks.
            var hit_kind := str(event.get("kind", ""))
            if hit_kind not in ["v63_poison", "dot", "burn", "reflect", "reflection"]:
                _set_pose(source_actor_id, "attack", _combat_pose_ms(source_actor_id, false), event_time)
            # HP reduction alone NEVER interrupts idle/walk/cast/attack.
            # One-shot spark + committed damage label are rendered below.
            # Continuous 1s poison ticks must not retrigger a 2.4s hit clip.
        elif kind == "status_applied" and str(event.get("status", "")) in [
                "stun", "freeze", "knockback", "knock_up", "stagger"]:
            # Only actual authoritative control statuses warrant a full-body
            # hurt response. This never writes CC or holds simulation actor.
            _set_pose(target_id, "hit", 300, event_time)
        elif kind in ["downed", "death"]:
            _set_pose(target_id, "death", _pose_lifetime_ms(target_id, "death", 2400), event_time)
        elif kind == "v63_mobility":
            _set_pose(str(event.get("actor_id", "")), "walk", 280, event_time)
        elif kind == "telegraph":
            _set_pose(source_actor_id, "cast", 700, event_time)
        if kind == "hit":
            var hit_kind := str(event.get("kind", ""))
            if hit_kind == "v63_poison" or (hit_kind == "dot" and _has_damage_tick_record(event, rows)):
                # status_tick/damage_tick is the singular presentation authority for DoT.
                continue
        var actor_id := str(event.get("target", event.get("actor_id", event.get("caster", event.get("attacker", "")))))
        var pos := _actor_position(actor_id)
        var cast_target_pos := pos
        var cue_kind := ""
        var label := ""
        var school_kind := school
        if battle.actors.has(source_actor_id):
            var actor: Dictionary = battle.actors[source_actor_id]
            if str(actor.get("side", "")) == "monster":
                school_kind = "boss" if str(actor.get("tier", "")) == "boss" else "monster"
        var color: Color = VfxV2.school_color(school_kind)
        var radius := 0.0
        match kind:
            "skill_cast", "cast":
                cue_kind = "cast"
                # Wind-up aura originates at the caster, not the target.
                pos = _actor_position(source_actor_id)
            "skill_release":
                var real_skill_id := str(event.get("skill_id", last_skill_by_actor.get(source_actor_id, "")))
                var definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(real_skill_id, {})
                var effect := str(definition.get("effect", ""))
                if school_kind == "poison" and effect in ["heal", "cleanse"]:
                    # Dược Độc renders only its canonical heal/cleanse result;
                    # an authored radius must not turn medicinal magic into a
                    # venom cloud.
                    cue_kind = ""
                elif school_kind == "poison" and str(definition.get("shape", "")) == "circle" \
                        and float(definition.get("radius", 0.0)) > 0.0:
                    # This is a post-release visual indicator for an authored
                    # circle skill (including consume/mark variants), NOT a
                    # new area/status or damage authority.
                    cue_kind = "venom_cloud"
                    radius = maxf(0.0, float(definition.get("radius", 0.0)))
                    var snapshot: Dictionary = locked_aoe_center_by_caster.get(source_actor_id, {})
                    if str(snapshot.get("skill_id", "")) == real_skill_id \
                            and snapshot.get("center", null) is Vector2:
                        pos = snapshot["center"]
                    else:
                        # A missing source snapshot is not proof of an AoE
                        # origin. Never invent a hit marker at a moved actor.
                        cue_kind = ""
                elif float(definition.get("projectile_speed", 0.0)) > 0.0:
                    # Projectile was scheduled from the real skill_cast event.
                    # Release is the authoritative impact deadline, not launch.
                    cue_kind = ""
                elif effect == "guard":
                    cue_kind = "guard"
                elif effect in ["heal", "cleanse"]:
                    if school_kind == "poison":
                        # The canonical heal/cleanse event below is the visible
                        # result; avoid an extra generic release aura.
                        cue_kind = ""
                    else:
                        cue_kind = "cast"
                elif str(definition.get("shape", "")) == "circle":
                    cue_kind = "aoe"
                    radius = float(definition.get("radius", 0.0))
            "hit":
                cue_kind = "impact"
                label = str(roundi(float(event.get("damage", 0.0))))
                if bool(event.get("critical", false)):
                    label = "BẠO KÍCH " + label
                    color = Color("fff09a")
            "v63_skill_hit", "skill_hit":
                # Numeric settlement has already been rendered from canonical hit.
                continue
            "skill_miss":
                cue_kind = "miss"; label = "TRƯỢT"
            "evade":
                cue_kind = "miss"; label = "NÉ"
            "heal":
                cue_kind = "heal"
                color = Color("79edba")
                label = "+" + str(roundi(float(event.get("amount", 0.0))))
            "cleanse":
                cue_kind = "cleanse"; color = Color("b9faff"); label = "GIẢI"
            "poison_consumed":
                var taken := int(event.get("stacks", 0))
                if taken > 0:
                    cue_kind = "venom_burst"
                    color = Color("b8eb83")
                    label = "PHỆ ĐỘC ×" + str(taken)
            "blood_frenzy":
                cue_kind = "blood_frenzy"; color = Color("e44b70"); label = "HUYẾT CUỒNG"
            "status_applied":
                var status := str(event.get("status", ""))
                if status == "poison":
                    var added := int(event.get("added", 0))
                    if added > 0:
                        cue_kind = "poison_apply"
                        color = Color("a5f28e")
                        label = "ĐỘC +" + str(added)
                elif status == "guard":
                    cue_kind = "guard"; color = Color("b0dafa"); label = "HỘ THỂ"
                elif status == "mark":
                    cue_kind = "mark"; color = Color("ae9bff"); label = "ẤN"
            "status_tick":
                var tick_damage := float(event.get("damage", 0.0))
                if str(event.get("status", "")) == "poison":
                    if tick_damage > 0.0:
                        cue_kind = "poison_tick"
                        color = Color("a5f28e")
                        label = "ĐỘC " + str(roundi(tick_damage))
                elif tick_damage > 0.0:
                    cue_kind = "impact"
                    color = Color("ffad77")
                    label = "DOT " + str(roundi(tick_damage))
            "damage_tick":
                cue_kind = "impact"; color = Color("91ec71")
                label = "DOT " + str(roundi(float(event.get("damage", 0.0))))
            "telegraph":
                cue_kind = "telegraph"; color = Color("ff5368"); label = "BOSS"
                var center: Variant = event.get("center", pos)
                if center is Vector2: pos = center
                radius = maxf(0.0, float(event.get("radius", 0.0)))
            "area_release":
                cue_kind = "area_burst"; color = Color("ff6671")
                var area_center: Variant = event.get("center", pos)
                if area_center is Vector2: pos = area_center
                label = "AOE"
            "downed":
                cue_kind = "death"; color = Color("8b8299")
            "v63_boss_phase":
                cue_kind = "boss_phase"; color = Color("ff6c54")
                label = "BOSS · PHA " + str(event.get("phase", ""))
            "v63_mobility":
                cue_kind = "mobility"
                var mobility_pos: Variant = event.get("position", pos)
                if mobility_pos is Vector2: pos = mobility_pos
        if cue_kind.is_empty() and kind != "skill_cast":
            continue
        # One-shot GPU glints only on REAL committed positive hit/heal.
        # No spark for pending casts, misses, telegraphs or DoT receipts.
        # Particle count is bounded independently from the authoritative
        # damage events, so 30-person raids cannot allocate endlessly.
        if v4_preview_enabled and school_kind == "poison" and (
                cue_kind == "heal" or (cue_kind == "impact" and
                    kind == "hit" and float(event.get("damage", 0.0)) > 0.0)):
            var spark_tint := Color("c0ffe7") if cue_kind == "heal" else Color("c8a0ff")
            var spark_skill := source_skill if not source_skill.is_empty() else str(last_skill_by_actor.get(source_actor_id, ""))
            if ".co_doc." in spark_skill: spark_tint = Color("dbff8c")
            var spark_screen := _world_to_local(pos) + Vector2(0.0,
                _actor_body_offset_px(target_id))
            V4SpellSpark.spawn(self, spark_screen, spark_tint,
                bool(event.get("critical", false)))
        if cue_kind == "poison_tick":
            # Multiple committed owned stacks can tick in one 0.25s engine step.
            # Aggregate *actual* numeric damage per target/owner/skill/time
            # to avoid 30 overlapping floating numbers (no invented damage).
            var actual_tick := float(event.get("damage", 0.0))
            var tick_at := float(event.get("time", battle.now))
            var grouped := false
            for index in range(cues.size() - 1, -1, -1):
                var prior_tick: Dictionary = cues[index]
                if str(prior_tick.get("kind", "")) != "poison_tick":
                    continue
                if str(prior_tick.get("target_actor_id", "")) != target_id:
                    continue
                if str(prior_tick.get("source_actor_id", "")) != source_actor_id:
                    continue
                if str(prior_tick.get("skill_id", "")) != source_skill:
                    continue
                if absf(float(prior_tick.get("time", -1.0)) - tick_at) > 0.00001:
                    continue
                var merged_count := int(prior_tick.get("stack_count", 1)) + 1
                var merged_damage := float(prior_tick.get("damage_total", 0.0)) + actual_tick
                prior_tick["stack_count"] = merged_count
                prior_tick["damage_total"] = merged_damage
                prior_tick["text"] = "ĐỘC " + str(roundi(merged_damage)) + " ×" + str(merged_count)
                cues[index] = prior_tick
                grouped = true
                break
            if grouped:
                continue
        var cue_life := 370.0 if cue_kind == "projectile" else (900.0 if cue_kind == "telegraph" else 790.0)
        var display_skill_id := source_skill
        if display_skill_id.is_empty():
            display_skill_id = str(last_skill_by_actor.get(source_actor_id, ""))
        var display_definition: Dictionary = CombatLabRosterAdapter.skill_definitions().get(display_skill_id, {})
        var display_generation := str(display_definition.get("generation", display_definition.get("tier", "human")))
        # Snapshot cosmetic visual level and authoritative haste at event time.
        # A maxed skill is brighter and has denser decorative trails, while
        # actor damage and the number of actually hit targets are unchanged.
        var growth := {}
        if school_kind == "poison" and battle.actors.has(source_actor_id):
            growth = VFXProgression.from_actor(battle.actors[source_actor_id],
                display_skill_id, display_definition, cues.size())
        var cue_from := _actor_position(source_actor_id)
        if kind == "v63_mobility" and actor_states.has(source_actor_id):
            var prior: Dictionary = actor_states[source_actor_id]
            cue_from = prior.get("last_position", cue_from)
        if not cue_kind.is_empty():
            cues.append({
                "kind":cue_kind, "position":pos, "from_position":cue_from,
                "text":label, "color":color, "radius":radius, "school":school_kind,
                "skill_id":display_skill_id, "generation":display_generation, "source_actor_id":source_actor_id,
                "target_actor_id":target_id, "stack_count":1, "damage_total":float(event.get("damage", 0.0)),
                "effect":str(display_definition.get("effect", event.get("effect", ""))),
                "shape":str(display_definition.get("shape", event.get("shape", ""))),
                "target_limit":int(display_definition.get("target_limit", event.get("target_limit", 0))),
                "v4_growth":growth, "event_type":kind, "committed_time":float(event.get("time", battle.now)),
                "committed_stacks":int(event.get("stacks", event.get("added", 0))),
                "created":now_ms, "life":cue_life,
                "source_index":int(event.get("lab_source_index", -1)),
                "time":float(event.get("time", 0.0))
            })
            if cues.size() > MAX_CUES: cues.pop_front()
        if kind == "skill_cast" and not source_skill.is_empty():
            # V6.3 _begin_cast explicitly schedules release after wind-up plus
            # projectile travel. Draw the projectile BEFORE settlement; do not
            # spawn a fake second arrow from skill_release (which commits HP).
            var authored: Dictionary = CombatLabRosterAdapter.skill_definitions().get(source_skill, {})
            var speed := float(authored.get("projectile_speed", 0.0))
            var caster: Dictionary = battle.actors.get(source_actor_id, {})
            if speed > 0.0 and not caster.is_empty():
                var effective: Dictionary = V63HumanSkillCombatSystem.effective_attack_stats(caster, caster.get("stats", {}))
                var cast_rate := maxf(0.1, 1.0 + float(effective.get("cast_speed", 0.0)))
                var start_time := float(event.get("time", battle.now))
                var launch_at := start_time + maxf(MapBattleV2.STEP_SECONDS, float(authored.get("cast_time", 0.0)) / cast_rate)
                var impact_at := float(event.get("release_at", launch_at))
                if impact_at > launch_at + 0.001:
                    cues.append({
                        "kind":"projectile", "position":cast_target_pos, "from_position":cue_from,
                        "text":"", "color":color, "radius":0.0, "school":school_kind,
                        "skill_id":source_skill, "generation":display_generation,
                        "effect":str(authored.get("effect", "")), "shape":str(authored.get("shape", "")),
                        "target_limit":int(authored.get("target_limit", 0)), "v4_growth":growth,
                        "event_type":"skill_cast",
                        "committed_time":start_time,
                        "source_actor_id":source_actor_id, "target_actor_id":target_id, "launch_at":launch_at, "impact_at":impact_at,
                        "created":now_ms, "life":0.0, "source_index":int(event.get("lab_source_index", -1)),
                        "time":start_time
                    })
                    if cues.size() > MAX_CUES: cues.pop_front()
        if kind == "hit" and float(event.get("lifesteal", 0.0)) > 0.0:
            var life_heal := roundi(float(event.get("lifesteal", 0.0)))
            cues.append({
                "kind":"heal", "position":cue_from, "from_position":cue_from,
                "text":"+" + str(life_heal), "color":Color("82f0a1"),
                "radius":0.0, "school":school_kind, "source_actor_id":source_actor_id,
                "created":now_ms, "life":900.0,
                "source_index":int(event.get("lab_source_index", -1)),
                "time":float(event.get("time", 0.0))
            })
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

# The V4 camera exists only for explicitly requested one-skill recordings.
# It tracks the real caster/target; it never moves actors or changes range.
func set_v4_showcase_focus(source_id: String, target_id: String) -> void:
    if battle == null or not battle.actors.has(source_id) or not battle.actors.has(target_id):
        return
    v4_shot_source_id = source_id
    v4_shot_target_id = target_id
    v4_shot_reached_target = false
    _update_v4_shot_camera()
    queue_redraw()

func _update_v4_shot_camera() -> void:
    v4_shot_camera_center = WORLD.size * 0.5
    if battle == null or v4_shot_source_id.is_empty() or v4_shot_target_id.is_empty():
        return
    if not battle.actors.has(v4_shot_source_id) or not battle.actors.has(v4_shot_target_id):
        return
    var source: Vector2 = battle.actors[v4_shot_source_id].get("position", WORLD.size * 0.5)
    var target: Vector2 = battle.actors[v4_shot_target_id].get("position", WORLD.size * 0.5)
    var midpoint := source.lerp(target, 0.5)
    # Keep both combatants in view ONLY if they fit the actual viewport
    # after margins/zoom. Full-screen 1280x720 at 2x may NOT fit actors
    # 20 world cells apart; old zoom<=2 shortcut clipped caster and target.
    # Otherwise show the true caster first, follow a committed projectile,
    # then hold the actual impact actor (no movement of simulation actors).
    var screen_span := size - Vector2(60.0, 56.0)
    var available := Vector2(
        WORLD.size.x * maxf(1.0, screen_span.x - 48.0) / maxf(1.0, screen_span.x) / zoom,
        WORLD.size.y * maxf(1.0, screen_span.y - 48.0) / maxf(1.0, screen_span.y) / zoom)
    if absf(source.x - target.x) <= available.x \
            and absf(source.y - target.y) <= available.y:
        v4_shot_camera_center = midpoint
        return
    if v4_shot_reached_target:
        v4_shot_camera_center = target
        return
    v4_shot_camera_center = source
    for cue in cues:
        if str(cue.get("kind", "")) != "projectile":
            continue
        if str(cue.get("source_actor_id", "")) != v4_shot_source_id or str(cue.get("target_actor_id", "")) != v4_shot_target_id:
            continue
        var launch_at := float(cue.get("launch_at", visual_time))
        var impact_at := float(cue.get("impact_at", launch_at))
        if visual_time >= impact_at:
            v4_shot_reached_target = true
            v4_shot_camera_center = target
        elif visual_time > launch_at:
            var progress := clampf((visual_time - launch_at) / maxf(0.001, impact_at - launch_at), 0.0, 1.0)
            v4_shot_camera_center = source.lerp(target, progress)
        break

func _world_to_local(point: Vector2) -> Vector2:
    var margin := Vector2(30, 28)
    var span := size - margin * 2.0
    var center := v4_shot_camera_center if not v4_shot_source_id.is_empty() else WORLD.size * 0.5
    var centered := Vector2((point.x - center.x) / WORLD.size.x * span.x, (point.y - center.y) / WORLD.size.y * span.y)
    return margin + span * 0.5 + centered * v4_effective_render_zoom()

func _draw() -> void:
    if not v4_shot_source_id.is_empty():
        _update_v4_shot_camera()
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
    # Cinematic overlay has a real skill-title label. The normal Lab
    # status string must not collide with it in the first 20 screen pixels.
    if OS.get_environment("TMB_POISON_V4_CINEMATIC") != "1":
        draw_string(ThemeDB.fallback_font, Vector2(14, 20), status_line,
            HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("cfc1e1"))
    # Authoritative AoE/telegraph footprints belong on the floor BEHIND
    # sprites, not in front of faces/health bars. This is purely draw order.
    _draw_ground_cues()
    if battle != null:
        var ids: Array = battle.actors.keys()
        ids.sort_custom(func(a: Variant, b: Variant) -> bool: return float(battle.actors[a].position.y) < float(battle.actors[b].position.y))
        for id in ids: _draw_actor(battle.actors[id])
    _draw_cues()

# Two verified horizontal atlas views (right + mirrored left), selected by
# nearest live monster. This is NOT a claim of four true direction sprites.
func _v4_actor_facing(actor: Dictionary) -> float:
    var ordinary := -1.0 if str(actor.get("side", "")) == "monster" else 1.0
    if school != "poison" or str(actor.get("side", "")) != "disciple" or battle == null:
        return ordinary
    var here: Vector2 = actor.get("position", Vector2.ZERO)
    var nearest_distance := INF
    var facing := ordinary
    for other_value in battle.actors.values():
        var other: Dictionary = other_value
        if str(other.get("side", "")) != "monster" or float(other.get("hp", 0.0)) <= 0.0:
            continue
        var there: Vector2 = other.get("position", Vector2.ZERO)
        var distance := here.distance_squared_to(there)
        if distance < nearest_distance and absf(there.x - here.x) > 0.3:
            nearest_distance = distance
            facing = -1.0 if there.x < here.x else 1.0
    return facing

func _draw_actor(actor: Dictionary) -> void:
    var actor_id := str(actor.get("id", ""))
    var foot := _world_to_local(actor.get("position", Vector2.ZERO))
    var boss := str(actor.get("tier", "")) == "boss"
    var monster := str(actor.get("side", "")) == "monster"
    _track_movement(actor)
    var pose := pose_for_actor(actor_id)
    # Other Combat Lab schools retain their existing authored launch pose.
    # Poison stays in Cast until its authoritative skill_release event.
    if school != "poison" and pose == "cast":
        for cue in cues:
            if str(cue.get("kind", "")) == "projectile" and str(cue.get("source_actor_id", "")) == actor_id \
                    and visual_time >= float(cue.get("launch_at", INF)):
                pose = "attack"
                break
    var actor_scale := (1.50 if boss else 1.0) * (0.55 + 0.29 * v4_effective_render_zoom())
    var facing := _v4_actor_facing(actor)
    var seconds := visual_time
    var state: Dictionary = actor_states.get(actor_id, {})
    var pose_elapsed := maxf(0.0, visual_time - float(state.get("started", visual_time)))
    if school == "poison" and not monster:
        var cast_window := maxf(0.0, float(state.get("until", 0.0)) - float(state.get("started", visual_time))) if pose == "cast" else -1.0
        if not PoisonAtlasV1.draw(self, foot, pose, seconds, pose_elapsed, actor_scale, facing, cast_window) and not poison_atlas_warning_emitted:
            push_warning("Combat Lab: Nữ Độc Tu atlas is unavailable; no substitute character is rendered.")
            poison_atlas_warning_emitted = true
    else:
        ActorRigV2.render(self, actor, foot, school, pose, seconds, actor_scale, facing, pose_elapsed)

    # Place health bars ABOVE the tallest character, not under feet.
    var hp_ratio := clampf(float(actor.get("hp", 0.0)) /
        maxf(1.0, float(actor.get("max_hp", 1.0))), 0.0, 1.0)
    var width := 37.0 * actor_scale
    var bar := Rect2(foot + Vector2(-width * 0.5, -79.0 * actor_scale),
        Vector2(width, 4.0 * actor_scale))
    draw_rect(bar, Color("201c2c"), true)
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * hp_ratio, bar.size.y)),
        Color("89e0aa") if not monster else Color("ec7884"), true)
    if boss:
        draw_rect(bar.grow(2.0), Color("dfb66a"), false, 1.0)
    # Persistent poisoned-state badge comes directly from live, owned V6.3
    # status stacks. No simulated stack count or extra on-hit particles.
    if float(actor.get("hp", 0.0)) > 0.0:
        var live_statuses: Dictionary = actor.get("status_effects", {})
        var real_poison_stacks: Array = live_statuses.get("v63_poison", [])
        if not real_poison_stacks.is_empty():
            var stack_count := real_poison_stacks.size()
            var badge_scale := clampf(actor_scale, 0.75, 1.5)
            var badge_center := bar.position + Vector2(bar.size.x + 11.0 * badge_scale,
                2.0 * badge_scale)
            draw_circle(badge_center, 7.5 * badge_scale, Color(0.125, 0.173, 0.169, 0.92))
            draw_circle(badge_center, 5.8 * badge_scale, Color("88df9f"))
            draw_circle(badge_center + Vector2(0.0, -2.0 * badge_scale),
                2.0 * badge_scale, Color("d6ffbb"))
            draw_string(ThemeDB.fallback_font,
                badge_center + Vector2(8.0 * badge_scale, 4.0 * badge_scale),
                str(stack_count), HORIZONTAL_ALIGNMENT_LEFT, 26.0 * badge_scale,
                clampi(roundi(9.0 * badge_scale), 9, 14), Color("cdf7d4"))
    var name := actor_id.replace("lab_disciple_", "ĐT ")
    var label_pos := foot + Vector2(-15.0 * actor_scale, 14.0 * actor_scale)
    draw_string(ThemeDB.fallback_font, label_pos, name,
        HORIZONTAL_ALIGNMENT_CENTER, 36.0 * actor_scale,
        clampi(roundi(10.0 * actor_scale), 9, 17), Color("e6dfef"))

# Presentation-only aim oracle: grounded in canonical actor IDs and positions.
# The event/simulation remains the sole authority for which actor is hit.
func _cue_target_world_position(cue: Dictionary) -> Vector2:
    var original: Vector2 = cue.get("position", Vector2.ZERO)
    var kind := str(cue.get("kind", ""))
    if kind in ["cast", "aoe", "area_burst", "venom_cloud", "telegraph", "mobility"]:
        return original
    var target_id := str(cue.get("target_actor_id", ""))
    if battle == null or target_id.is_empty() or not battle.actors.has(target_id):
        return original
    return battle.actors[target_id].get("position", original)

# Body center is measured from the actor's FEET, not multiplied directly by
# camera zoom. Boss and normal monster rigs have different rendered heights.
func _actor_body_offset_px(actor_id: String) -> float:
    if battle == null or actor_id.is_empty() or not battle.actors.has(actor_id):
        return -18.0 * (0.55 + 0.29 * zoom)
    var actor: Dictionary = battle.actors[actor_id]
    var monster := str(actor.get("side", "")) == "monster"
    var boss := str(actor.get("tier", "")) == "boss"
    var actor_scale := (1.5 if boss else 1.0) * (0.55 + 0.29 * v4_effective_render_zoom())
    # ActorRigV2 head/torso around -20..-40 at scale; PoisonAtlasV1
    # character has a taller 245px source frame scaled by 0.32.
    return (-26.0 if monster else -37.0) * actor_scale

static func _is_ground_cue(cue: Dictionary) -> bool:
    return str(cue.get("kind", "")) in ["venom_cloud", "aoe", "area_burst", "telegraph"]

# Project the *canonical world-space radius* through exactly the same
# world-to-screen transform as actor feet. The 30/28 margins and non-square
# Lab viewport make the ground boundary elliptical, never a fake larger AoE.
func _aoe_radii_px(world_radius: float) -> Vector2:
    var span := size - Vector2(60.0, 56.0)
    var render_zoom := v4_effective_render_zoom()
    return Vector2(maxf(0.0, world_radius) * maxf(1.0, span.x) / WORLD.size.x * render_zoom,
        maxf(0.0, world_radius) * maxf(1.0, span.y) / WORLD.size.y * render_zoom)

func _draw_ground_cues() -> void:
    var current_time := roundi(visual_time * 1000.0)
    for cue in cues:
        # Committed V6.3 ally-heal gets one additional under-foot lotus,
        # while the actual HP text/medicine ribbon still renders on top.
        var heal_floor := v4_preview_enabled and str(cue.get("kind", "")) == "heal" \
            and str(cue.get("school", "")) == "poison" \
            and str(cue.get("effect", "")) == "heal"
        if not _is_ground_cue(cue) and not heal_floor:
            continue
        var duration := maxf(1.0, float(cue.get("life", 1.0)))
        var age := float(current_time - int(cue.get("created", current_time)))
        if age < 0.0 or age >= duration:
            continue
        var t := clampf(age / duration, 0.0, 1.0)
        var p := _world_to_local(_cue_target_world_position(cue))
        var bounds := _aoe_radii_px(float(cue.get("radius", 0.0)))
        var presentation := cue.duplicate()
        presentation["v4_preview"] = v4_preview_enabled
        presentation["v4_radius_y"] = bounds.y
        presentation["v4_heal_ground"] = heal_floor
        VfxV2.render(self, presentation, p, p, t, bounds.x, v4_effective_render_zoom())

func _draw_cues() -> void:
    # HOLD freezes all existing spell/impact effects, not only projectiles.
    var current_time := roundi(visual_time * 1000.0)
    var live: Array[Dictionary] = []
    for cue in cues:
        var t := 0.0
        if str(cue.get("kind", "")) == "projectile" and cue.has("impact_at"):
            var launch_at := float(cue.get("launch_at", 0.0))
            var impact_at := float(cue.get("impact_at", launch_at))
            if visual_time > impact_at + MapBattleV2.STEP_SECONDS:
                continue
            live.append(cue)
            if visual_time < launch_at:
                continue
            t = clampf((visual_time - launch_at) / maxf(0.001, impact_at - launch_at), 0.0, 1.0)
        else:
            var age := float(current_time - int(cue.get("created", current_time)))
            var duration := maxf(1.0, float(cue.get("life", 1.0)))
            if age >= duration:
                continue
            live.append(cue)
            t = clampf(age / duration, 0.0, 1.0)
        # The canonical event identifies WHO was hit, not a fixed screen pixel.
        # A projectile may travel while the target moves; use its live foot
        # position for the visual endpoint. AoE/telegraphs stay at their event
        # center, never chase one of the targets.
        var p := _world_to_local(_cue_target_world_position(cue))
        var start := _world_to_local(cue.get("from_position", cue.get("position", Vector2.ZERO)))
        var projected_radii := _aoe_radii_px(float(cue.get("radius", 0.0)))
        var radius_px := projected_radii.x
        var visual_cue := cue
        if str(cue.get("school", "")) == "poison":
            visual_cue = cue.duplicate()
            visual_cue["v4_preview"] = v4_preview_enabled
            visual_cue["v8_preview"] = v8_preview_enabled
            if v4_preview_enabled:
                visual_cue["v4_radius_y"] = projected_radii.y
                visual_cue["v4_crowd"] = cues.size()
                visual_cue["v4_target_body_offset"] = _actor_body_offset_px(str(cue.get("target_actor_id", "")))
                visual_cue["v4_source_body_offset"] = _actor_body_offset_px(str(cue.get("source_actor_id", "")))
        if not _is_ground_cue(cue):
            VfxV2.render(self, visual_cue, p, start, t, radius_px, v4_effective_render_zoom())
        var label := str(cue.get("text", ""))
        if label.is_empty():
            continue
        var c: Color = cue.get("color", Color.WHITE)
        c.a *= 1.0 - t
        # Only committed damage/heal/status values enter floating text.
        var label_pos := p + Vector2(8.0 * zoom, -18.0 * zoom - 24.0 * zoom * t)
        draw_string(ThemeDB.fallback_font, label_pos, label,
            HORIZONTAL_ALIGNMENT_LEFT, 190.0,
            clampi(roundi(12.0 + zoom * 0.75), 12, 17), c)
    cues = live

func set_zoom(value: float) -> void:
    zoom = clampf(value, 1.0, 6.0)
    queue_redraw()
