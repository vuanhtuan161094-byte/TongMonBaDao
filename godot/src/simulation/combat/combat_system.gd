class_name CombatSystem
extends RefCounted

const REALTIME_QUANTUM := 0.25
const MAX_REALTIME_SECONDS := 45.0
const MAX_TRACE_EVENTS := 96
const MONSTER_ATTACK_RANGE := 1.25
const MONSTER_MOVE_SPEED := 2.85
const MONSTER_ATTACK_INTERVAL := 1.65

var cultivation_system := CultivationSystem.new()
var technique_system := TechniqueSystem.new()
var cultivation_path_system := CultivationPathSystem.new()
var combat_skill_system := CombatSkillSystem.new()
var equipment_system := EquipmentSystem.new()
var bloodline_system := BloodlineSystem.new()
var physique_system := PhysiqueSystem.new()

func resolve_encounter(state: SimulationState, disciple: DiscipleState, rng: GameRng) -> Dictionary:
    if state.sect.combat_skills_enabled:
        return _resolve_realtime_encounter(state, disciple, rng)

    var region: RegionState = state.regions.get(disciple.region_id)
    if region == null:
        return {"outcome":"invalid", "loot":{}}

    var species_id := rng.weighted_pick(region.monster_weights)
    var definition: Dictionary = P0Content.MONSTERS.get(str(species_id), {})
    if definition.is_empty():
        return {"outcome":"invalid", "loot":{}}

    var monster_hp := float(definition.get("hp", 30.0))
    var monster_power := float(definition.get("power", 10.0))
    var effective_power := cultivation_system.effective_combat_power(state, disciple) if state.sect.cultivation_enabled else disciple.combat_power
    if state.sect.equipment_enabled:
        effective_power += equipment_system.combat_power_bonus(state, disciple)
    var damage_multiplier := technique_system.incoming_damage_multiplier(state, disciple) if state.sect.techniques_enabled else 1.0
    if state.sect.cultivation_paths_enabled:
        if state.sect.techniques_enabled:
            var active_path := cultivation_path_system.active_technique_path(disciple)
            var path_effect := cultivation_path_system.technique_effect_multiplier(state, disciple, active_path)
            damage_multiplier = clampf(1.0 - (1.0 - damage_multiplier) * path_effect, 0.45, 1.0)
        damage_multiplier *= cultivation_path_system.incoming_damage_multiplier(state, disciple)
    if state.sect.bloodlines_enabled:
        damage_multiplier *= bloodline_system.incoming_damage_multiplier(state, disciple)
    if state.sect.physiques_enabled:
        damage_multiplier *= physique_system.incoming_damage_multiplier(state, disciple)
    disciple.metrics["combats"] = int(disciple.metrics.get("combats", 0)) + 1

    for _round in range(20):
        if disciple.hp / maxf(disciple.max_hp, 1.0) <= disciple.retreat_hp_ratio():
            disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
            return {"outcome":"retreat", "loot":{}}

        var dealt := effective_power * rng.randf_range(0.72, 1.28)
        monster_hp -= dealt
        if monster_hp <= 0.0:
            disciple.metrics["wins"] = int(disciple.metrics.get("wins", 0)) + 1
            return {
                "outcome":"win",
                "species_id":str(species_id),
                "monster_name":str(definition.get("name", species_id)),
                "loot":definition.get("loot", {}).duplicate(true)
            }

        var taken := monster_power * rng.randf_range(0.65, 1.22) * damage_multiplier
        disciple.hp = maxf(0.0, disciple.hp - taken)

        if disciple.hp <= 0.0:
            disciple.hp = 1.0
            disciple.metrics["defeats"] = int(disciple.metrics.get("defeats", 0)) + 1
            return {"outcome":"defeat", "loot":{}}

    disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
    return {"outcome":"retreat", "loot":{}}

func _resolve_realtime_encounter(state: SimulationState, disciple: DiscipleState, rng: GameRng) -> Dictionary:
    var region: RegionState = state.regions.get(disciple.region_id)
    if region == null:
        return {"outcome":"invalid", "loot":{}, "trace":[]}

    var species_id := rng.weighted_pick(region.monster_weights)
    var definition: Dictionary = P0Content.MONSTERS.get(str(species_id), {})
    if definition.is_empty():
        return {"outcome":"invalid", "loot":{}, "trace":[]}

    var effective_power := cultivation_system.effective_combat_power(state, disciple) if state.sect.cultivation_enabled else disciple.combat_power
    if state.sect.equipment_enabled:
        effective_power += equipment_system.combat_power_bonus(state, disciple)
    var incoming_multiplier := _realtime_incoming_multiplier(state, disciple)
    var style: Dictionary = combat_skill_system.style_profile(state, disciple)
    if state.sect.equipment_enabled:
        incoming_multiplier *= equipment_system.incoming_damage_multiplier(state, disciple)
        style = equipment_system.apply_style_modifiers(state, disciple, style)
    var trace: Array = []
    var projectiles: Array = []
    var cooldowns: Dictionary = {}
    var casting: Dictionary = {}
    var context := {
        "time": 0.0,
        "distance": 6.0,
        "monster_hp": float(definition.get("hp", 30.0)),
        "monster_power": float(definition.get("power", 10.0)),
        "guard_until": -1.0,
        "guard_multiplier": 1.0,
        "burn_until": -1.0,
        "burn_next_tick": -1.0,
        "burn_damage": 0.0,
        "weaken_until": -1.0,
        "weaken_multiplier": 1.0,
        "disciple_basic_ready": 0.0,
        "monster_basic_ready": 0.0,
        "basic_attacks": 0,
        "skills_used": [],
        "last_move_mode": ""
    }
    disciple.metrics["combats"] = int(disciple.metrics.get("combats", 0)) + 1

    var max_steps := int(ceil(MAX_REALTIME_SECONDS / REALTIME_QUANTUM))
    for step in range(max_steps + 1):
        var now := float(step) * REALTIME_QUANTUM
        context["time"] = now

        _resolve_projectiles(state, disciple, rng, effective_power, context, projectiles, trace)
        _resolve_burn_tick(context, trace)
        if float(context["monster_hp"]) <= 0.0:
            return _realtime_victory(disciple, species_id, definition, context, trace, style)

        if not casting.is_empty() and now + 0.000001 >= float(casting.get("finish_at", 0.0)):
            _finish_cast(state, disciple, rng, effective_power, context, casting, projectiles, trace)
            casting.clear()
            if float(context["monster_hp"]) <= 0.0:
                return _realtime_victory(disciple, species_id, definition, context, trace, style)

        if disciple.hp / maxf(disciple.max_hp, 1.0) <= disciple.retreat_hp_ratio():
            disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
            _trace(trace, {"type":"retreat", "time":now, "distance":float(context["distance"])})
            return _realtime_result("retreat", disciple, context, trace, style)

        _move_combatants(style, casting, context, trace)

        if casting.is_empty():
            var chosen_skill := _select_skill(state, disciple, effective_power, context, cooldowns)
            if chosen_skill != &"":
                var skill_data := combat_skill_system.definition(chosen_skill)
                casting = {
                    "skill_id": str(chosen_skill),
                    "finish_at": now + maxf(float(skill_data.get("cast_time", 0.0)), REALTIME_QUANTUM)
                }
                cooldowns[str(chosen_skill)] = now + float(skill_data.get("cooldown", 0.0))
                context["skills_used"].append(str(chosen_skill))
                state.sect.combat_skill_event_count += 1
                _trace(trace, {
                    "type":"cast_start", "time":now, "skill_id":str(chosen_skill),
                    "distance":float(context["distance"]), "finish_at":float(casting["finish_at"])
                })
            elif now + 0.000001 >= float(context["disciple_basic_ready"]) and float(context["distance"]) <= float(style.get("basic_range", 1.75)):
                var dealt := effective_power * float(style.get("basic_ratio", 1.0)) * rng.randf_range(0.78, 1.22)
                context["monster_hp"] = float(context["monster_hp"]) - dealt
                context["disciple_basic_ready"] = now + float(style.get("basic_interval", 1.35))
                context["basic_attacks"] = int(context["basic_attacks"]) + 1
                _trace(trace, {"type":"basic_attack", "time":now, "damage":dealt, "distance":float(context["distance"])})
                if float(context["monster_hp"]) <= 0.0:
                    return _realtime_victory(disciple, species_id, definition, context, trace, style)

        if now + 0.000001 >= float(context["monster_basic_ready"]) and float(context["distance"]) <= MONSTER_ATTACK_RANGE:
            var weaken := float(context["weaken_multiplier"]) if now < float(context["weaken_until"]) else 1.0
            var guard := float(context["guard_multiplier"]) if now < float(context["guard_until"]) else 1.0
            var taken := float(context["monster_power"]) * rng.randf_range(0.65, 1.22) * incoming_multiplier * weaken * guard
            disciple.hp = maxf(0.0, disciple.hp - taken)
            context["monster_basic_ready"] = now + MONSTER_ATTACK_INTERVAL
            _trace(trace, {"type":"monster_attack", "time":now, "damage":taken, "distance":float(context["distance"])})
            if disciple.hp <= 0.0:
                disciple.hp = 1.0
                disciple.metrics["defeats"] = int(disciple.metrics.get("defeats", 0)) + 1
                _trace(trace, {"type":"defeat", "time":now})
                return _realtime_result("defeat", disciple, context, trace, style)

    disciple.metrics["retreats"] = int(disciple.metrics.get("retreats", 0)) + 1
    _trace(trace, {"type":"timeout_retreat", "time":MAX_REALTIME_SECONDS})
    return _realtime_result("retreat", disciple, context, trace, style)

func _move_combatants(style: Dictionary, casting: Dictionary, context: Dictionary, trace: Array) -> void:
    var distance := float(context["distance"])
    var preferred := float(style.get("preferred_distance", 1.6))
    var move_speed := float(style.get("move_speed", 2.7))
    var move_mode := "hold"

    if casting.is_empty():
        if distance > preferred + 0.30:
            distance = maxf(0.0, distance - move_speed * REALTIME_QUANTUM)
            move_mode = "approach"
        elif distance < preferred - 0.30 and str(style.get("id", "")) == "spell":
            distance = minf(8.0, distance + move_speed * REALTIME_QUANTUM)
            move_mode = "kite"

    if distance > MONSTER_ATTACK_RANGE:
        distance = maxf(0.0, distance - MONSTER_MOVE_SPEED * REALTIME_QUANTUM)

    context["distance"] = distance
    if move_mode != str(context.get("last_move_mode", "")):
        context["last_move_mode"] = move_mode
        _trace(trace, {"type":"move", "time":float(context["time"]), "mode":move_mode, "distance":distance})

func _select_skill(state: SimulationState, disciple: DiscipleState, effective_power: float, context: Dictionary, cooldowns: Dictionary) -> StringName:
    var now := float(context["time"])
    var distance := float(context["distance"])
    var best_id := &""
    var best_score := 35.0
    for skill_id in combat_skill_system.usable_skills(state, disciple):
        if now + 0.000001 < float(cooldowns.get(str(skill_id), 0.0)):
            continue
        var data := combat_skill_system.definition(skill_id)
        var self_target := bool(data.get("self_target", false))
        if not self_target and distance > float(data.get("range", 0.0)) + 0.000001:
            continue
        var score := _skill_utility(state, disciple, skill_id, effective_power, context)
        if score > best_score + 0.000001 or (absf(score - best_score) <= 0.000001 and (best_id == &"" or str(skill_id) < str(best_id))):
            best_id = skill_id
            best_score = score
    return best_id

func _skill_utility(state: SimulationState, disciple: DiscipleState, skill_id: StringName, effective_power: float, context: Dictionary) -> float:
    var data := combat_skill_system.definition(skill_id)
    var effect := StringName(data.get("effect", "damage"))
    var multiplier := combat_skill_system.effect_multiplier(state, disciple, skill_id)
    if state.sect.equipment_enabled:
        multiplier *= equipment_system.skill_effect_multiplier(
            state,
            disciple,
            StringName(data.get("path", "")),
            StringName(data.get("element", ""))
        )
    var damage_ratio := float(data.get("damage_ratio", 0.0))
    var score := damage_ratio * 48.0 * multiplier
    var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
    score += damage_ratio * clampf(disciple.risk_bias, 0.0, 1.0) * 10.0

    match effect:
        CombatSkillSystem.EFFECT_GUARD:
            score = 18.0 + (1.0 - hp_ratio) * 115.0 * (0.75 + clampf(disciple.survival_bias, 0.0, 1.0))
            if float(context["time"]) < float(context["guard_until"]):
                score -= 80.0
        CombatSkillSystem.EFFECT_DASH:
            score += maxf(float(context["distance"]) - 1.5, 0.0) * 8.0
            if float(context["distance"]) < 2.0:
                score -= 28.0
        CombatSkillSystem.EFFECT_BURN:
            score += 28.0 if float(context["time"]) >= float(context["burn_until"]) else -12.0
        CombatSkillSystem.EFFECT_WEAKEN:
            score += 24.0 if float(context["time"]) >= float(context["weaken_until"]) else -10.0
        CombatSkillSystem.EFFECT_FIRE_COMBO:
            score += 42.0 if float(context["time"]) < float(context["burn_until"]) else -20.0
        _:
            pass

    var estimated_damage := effective_power * damage_ratio * multiplier
    if effect == CombatSkillSystem.EFFECT_FIRE_COMBO and float(context["time"]) < float(context["burn_until"]):
        estimated_damage *= float(data.get("burning_bonus", 1.0))
    if estimated_damage + 0.000001 >= float(context["monster_hp"]):
        score += 35.0
    return score

func _finish_cast(state: SimulationState, disciple: DiscipleState, rng: GameRng, effective_power: float, context: Dictionary, casting: Dictionary, projectiles: Array, trace: Array) -> void:
    var skill_id := StringName(casting.get("skill_id", ""))
    var data := combat_skill_system.definition(skill_id)
    if data.is_empty():
        return
    if float(data.get("dash_to", 0.0)) > 0.0:
        context["distance"] = minf(float(context["distance"]), float(data.get("dash_to", 1.35)))
        _trace(trace, {"type":"dash", "time":float(context["time"]), "skill_id":str(skill_id), "distance":float(context["distance"])})

    var projectile_speed := float(data.get("projectile_speed", 0.0))
    if projectile_speed > 0.0:
        var travel_time := maxf(float(context["distance"]), 0.1) / projectile_speed
        projectiles.append({"skill_id":str(skill_id), "hit_at":float(context["time"]) + travel_time})
        _trace(trace, {
            "type":"projectile_launch", "time":float(context["time"]), "skill_id":str(skill_id),
            "hit_at":float(context["time"]) + travel_time, "distance":float(context["distance"])
        })
        return
    _apply_skill_effect(state, disciple, rng, effective_power, skill_id, context, trace)

func _resolve_projectiles(state: SimulationState, disciple: DiscipleState, rng: GameRng, effective_power: float, context: Dictionary, projectiles: Array, trace: Array) -> void:
    var index := projectiles.size() - 1
    while index >= 0:
        var projectile: Dictionary = projectiles[index]
        if float(context["time"]) + 0.000001 >= float(projectile.get("hit_at", 0.0)):
            var skill_id := StringName(projectile.get("skill_id", ""))
            _trace(trace, {"type":"projectile_hit", "time":float(context["time"]), "skill_id":str(skill_id), "distance":float(context["distance"])})
            _apply_skill_effect(state, disciple, rng, effective_power, skill_id, context, trace)
            projectiles.remove_at(index)
        index -= 1

func _apply_skill_effect(state: SimulationState, disciple: DiscipleState, rng: GameRng, effective_power: float, skill_id: StringName, context: Dictionary, trace: Array) -> void:
    var data := combat_skill_system.definition(skill_id)
    var effect := StringName(data.get("effect", "damage"))
    var effect_multiplier := combat_skill_system.effect_multiplier(state, disciple, skill_id)
    if state.sect.equipment_enabled:
        effect_multiplier *= equipment_system.skill_effect_multiplier(
            state,
            disciple,
            StringName(data.get("path", "")),
            StringName(data.get("element", ""))
        )
    var damage_ratio := float(data.get("damage_ratio", 0.0))
    if effect == CombatSkillSystem.EFFECT_FIRE_COMBO and float(context["time"]) < float(context["burn_until"]):
        damage_ratio *= float(data.get("burning_bonus", 1.0))

    var dealt := 0.0
    if damage_ratio > 0.0:
        dealt = effective_power * damage_ratio * effect_multiplier * rng.randf_range(0.82, 1.18)
        context["monster_hp"] = float(context["monster_hp"]) - dealt

    match effect:
        CombatSkillSystem.EFFECT_GUARD:
            context["guard_multiplier"] = float(data.get("guard_multiplier", 1.0))
            context["guard_until"] = float(context["time"]) + float(data.get("guard_duration", 0.0))
            _trace(trace, {"type":"buff", "time":float(context["time"]), "skill_id":str(skill_id), "buff":"guard", "until":float(context["guard_until"])})
        CombatSkillSystem.EFFECT_BURN:
            context["burn_damage"] = effective_power * float(data.get("burn_ratio", 0.0)) * effect_multiplier
            context["burn_until"] = float(context["time"]) + float(data.get("burn_duration", 0.0))
            context["burn_next_tick"] = float(context["time"]) + 1.0
            _trace(trace, {"type":"debuff", "time":float(context["time"]), "skill_id":str(skill_id), "debuff":"burn", "until":float(context["burn_until"])})
        CombatSkillSystem.EFFECT_WEAKEN:
            context["weaken_multiplier"] = float(data.get("weaken_multiplier", 1.0))
            context["weaken_until"] = float(context["time"]) + float(data.get("weaken_duration", 0.0))
            _trace(trace, {"type":"debuff", "time":float(context["time"]), "skill_id":str(skill_id), "debuff":"weaken", "until":float(context["weaken_until"])})
        _:
            pass

    _trace(trace, {"type":"skill_hit", "time":float(context["time"]), "skill_id":str(skill_id), "damage":dealt, "distance":float(context["distance"])})

func _resolve_burn_tick(context: Dictionary, trace: Array) -> void:
    var now := float(context["time"])
    if now + 0.000001 < float(context["burn_next_tick"]) or now >= float(context["burn_until"]):
        return
    var damage := float(context["burn_damage"])
    context["monster_hp"] = float(context["monster_hp"]) - damage
    context["burn_next_tick"] = float(context["burn_next_tick"]) + 1.0
    _trace(trace, {"type":"burn_tick", "time":now, "damage":damage})

func _realtime_incoming_multiplier(state: SimulationState, disciple: DiscipleState) -> float:
    var damage_multiplier := technique_system.incoming_damage_multiplier(state, disciple) if state.sect.techniques_enabled else 1.0
    if state.sect.cultivation_paths_enabled:
        if state.sect.techniques_enabled:
            var active_path := cultivation_path_system.active_technique_path(disciple)
            var path_effect := cultivation_path_system.technique_effect_multiplier(state, disciple, active_path)
            damage_multiplier = clampf(1.0 - (1.0 - damage_multiplier) * path_effect, 0.45, 1.0)
        damage_multiplier *= cultivation_path_system.incoming_damage_multiplier(state, disciple)
    if state.sect.bloodlines_enabled:
        damage_multiplier *= bloodline_system.incoming_damage_multiplier(state, disciple)
    if state.sect.physiques_enabled:
        damage_multiplier *= physique_system.incoming_damage_multiplier(state, disciple)
    return damage_multiplier

func _realtime_victory(disciple: DiscipleState, species_id: StringName, definition: Dictionary, context: Dictionary, trace: Array, style: Dictionary) -> Dictionary:
    disciple.metrics["wins"] = int(disciple.metrics.get("wins", 0)) + 1
    _trace(trace, {"type":"victory", "time":float(context["time"])})
    var result := _realtime_result("win", disciple, context, trace, style)
    result["species_id"] = str(species_id)
    result["monster_name"] = str(definition.get("name", species_id))
    result["loot"] = definition.get("loot", {}).duplicate(true)
    return result

func _realtime_result(outcome: String, disciple: DiscipleState, context: Dictionary, trace: Array, style: Dictionary) -> Dictionary:
    return {
        "outcome": outcome,
        "loot": {},
        "elapsed": float(context["time"]),
        "final_distance": float(context["distance"]),
        "combat_style": str(style.get("id", "balanced")),
        "basic_attacks": int(context["basic_attacks"]),
        "skills_used": context["skills_used"].duplicate(),
        "trace": trace.duplicate(true),
        "disciple_hp": disciple.hp,
        "monster_hp": maxf(float(context["monster_hp"]), 0.0)
    }

func _trace(trace: Array, event: Dictionary) -> void:
    if trace.size() < MAX_TRACE_EVENTS:
        trace.append(event)


# DV2-02 staged integration. A caller that ALREADY resolved a legal V2 skill
# may commit its actual hit to two real DiscipleState HP meters. Default P0–P3.7
# encounters remain untouched until canonical monster/skill V2 adapters exist.
# One hit_id per encounter is committed at most once in this encounter context.
func commit_v2_direct_hit(
    attacker: DiscipleState, defender: DiscipleState,
    attacker_stats: Dictionary, defender_stats: Dictionary,
    defender_resistances: Dictionary, encounter_context: Dictionary,
    hit_id: String, skill_ratio: float = 1.0,
    was_crit: bool = false, element: String = "",
    elemental_matchup_factor: float = 1.0, can_crit: bool = true,
    lifesteal_eligible: bool = true
) -> Dictionary:
    if attacker == null or defender == null or attacker == defender or hit_id.is_empty():
        return {"ok":false,"reason":"invalid_v2_hit_actor"}
    var seen = encounter_context.get("v2_hit_ids", {})
    if not (seen is Dictionary) or seen.has(hit_id):
        return {"ok":false,"reason":"duplicate_or_invalid_v2_hit_id"}
    var hit := CombatStatsV2.resolve_direct_hit(
        attacker_stats,defender_stats,defender_resistances,skill_ratio,
        was_crit,element,elemental_matchup_factor,can_crit
    )
    if not bool(hit.get("ok",false)):
        return hit
    var settled := CombatStatsV2.settle_damage_and_lifesteal(
        hit,attacker_stats,defender_stats,
        attacker.hp,attacker.max_hp,defender.hp,lifesteal_eligible
    )
    if not bool(settled.get("ok",false)):
        return settled
    # HP mutation happens only after successful validation. All other
    # economy/XP/reward/quest effects remain owned by their action systems.
    attacker.hp = float(settled["attacker_hp_after"])
    defender.hp = float(settled["target_hp_after"])
    seen[hit_id] = true
    encounter_context["v2_hit_ids"] = seen
    var result: Dictionary = hit.duplicate(true)
    result.merge(settled,true)
    result["hit_id"] = hit_id
    return result
