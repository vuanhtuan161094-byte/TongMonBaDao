class_name V63DivineSkillCombatSystem
extends RefCounted

const CATALOGUE_PATH := "res://data/combat/v63_divine_combat_catalog.json"
const EFFECTS := ["damage", "poison", "guard", "heal", "cleanse", "mark", "consume_poison", "mobility", "passive", "innate"]
const SLOTS := ["basic", "active", "ultimate", "mobility", "passive", "innate"]
const MAX_SKILLS := 240
static var _catalogue_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_divine_combat_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["divine_combat_catalogue_not_object"],"data":{}}
    var errors := validate_catalogue(parsed)
    if errors.is_empty() and path == CATALOGUE_PATH:
        _catalogue_cache = parsed.duplicate(true)
    return {"ok":errors.is_empty(),"errors":errors,"data":parsed}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version", -1)) != 1 or bool(data.get("enabled", true)):
        errors.append("bad_divine_combat_schema_or_release_gate")
    if str(data.get("balance_status", "")) != "candidate":
        errors.append("divine_balance_must_remain_candidate")
    var branches = data.get("branches", null)
    var skills = data.get("skills", null)
    var bosses = data.get("bosses", null)
    if not (branches is Array) or not (skills is Array) or not (bosses is Array):
        errors.append("missing_divine_combat_arrays")
        return errors
    var branch_ids: Dictionary = {}
    for raw in branches:
        if not (raw is Dictionary):
            errors.append("divine_branch_not_object")
            continue
        var id := str(raw.get("id", ""))
        if not _valid_slug(id) or branch_ids.has(id):
            errors.append("bad_or_duplicate_divine_branch:" + id)
        branch_ids[id] = true
        if str(raw.get("school", "")) not in ["bow", "fist", "poison"] or not (raw.get("lineages", null) is Dictionary):
            errors.append("bad_divine_branch_identity:" + id)
        for path in ["a", "b"]:
            var lineage_skill := str(raw.get("divine_innate_node_ids", {}).get(path, ""))
            if lineage_skill.is_empty() or raw.get("divine_technique_ids", {}).get(path, []).size() != 3:
                errors.append("incomplete_divine_branch_path:" + id + ":" + path)
    if branch_ids.size() != 9:
        errors.append("divine_branch_coverage_not_nine")
    var skill_ids: Dictionary = {}
    var archivable_count := 0
    var innate_count := 0
    var shared_count := 0
    for raw in skills:
        if not (raw is Dictionary):
            errors.append("divine_skill_not_object")
            continue
        var id := str(raw.get("id", ""))
        var slot := str(raw.get("slot", ""))
        var effect := str(raw.get("effect", ""))
        var branch := str(raw.get("branch", ""))
        if not _valid_id(id) or skill_ids.has(id):
            errors.append("bad_or_duplicate_divine_skill:" + id)
        skill_ids[id] = true
        if str(raw.get("tier", "")) != "divine" or str(raw.get("generation", "")) != "divine" or slot not in SLOTS or not EFFECTS.has(effect):
            errors.append("unsupported_divine_skill:" + id)
        if not branch.is_empty() and not branch_ids.has(branch):
            errors.append("unknown_divine_skill_branch:" + id)
        if float(raw.get("damage_ratio", 0.0)) <= 0.0 or float(raw.get("range", 0.0)) <= 0.0 or float(raw.get("cooldown", 0.0)) <= 0.0 or float(raw.get("cast_time", -1.0)) < 0.0:
            errors.append("bad_divine_skill_action_values:" + id)
        if str(raw.get("element", "")) not in CombatStatsV2.ELEMENTS or str(raw.get("shape", "")) not in ["single_target", "circle", "line"]:
            errors.append("bad_divine_skill_geometry_or_element:" + id)
        if int(raw.get("target_limit", 0)) < 1 or int(raw.get("target_limit", 0)) > 3 or float(raw.get("radius", -1.0)) < 0.0:
            errors.append("bad_divine_skill_target_bounds:" + id)
        if slot == "innate":
            innate_count += 1
            if bool(raw.get("archivable", true)) or not (raw.get("passive_modifiers", null) is Dictionary):
                errors.append("divine_innate_must_be_derived:" + id)
        elif branch.is_empty() and slot in ["basic", "mobility"]:
            shared_count += 1
            if bool(raw.get("archivable", true)) or not str(raw.get("source_codex_id", "")).is_empty():
                errors.append("divine_shared_school_node_must_be_inherited:" + id)
        else:
            if not bool(raw.get("archivable", false)):
                errors.append("divine_action_must_link_to_lineage_manual:" + id)
            archivable_count += 1
            if not str(raw.get("source_codex_id", "")).begins_with("tmb.codex."):
                errors.append("divine_action_missing_manual_source:" + id)
            if slot in ["passive"] and not (raw.get("passive_modifiers", null) is Dictionary):
                errors.append("divine_passive_missing_modifiers:" + id)
    if skills.size() != MAX_SKILLS or archivable_count != 216 or innate_count != 18 or shared_count != 6:
        errors.append("divine_skill_coverage_mismatch")
    var boss_ids: Dictionary = {}
    for raw in bosses:
        if not (raw is Dictionary):
            errors.append("divine_boss_not_object")
            continue
        var id := str(raw.get("id", ""))
        if not _valid_id(id) or boss_ids.has(id) or str(raw.get("tier_band", "")) != "divine":
            errors.append("bad_or_duplicate_divine_boss:" + id)
        boss_ids[id] = true
        if not MonsterCatalogueV2.SPECIES.has(str(raw.get("origin_species_id", ""))):
            errors.append("divine_boss_missing_source_species:" + id)
        var thresholds = raw.get("phase_thresholds", [])
        if not (thresholds is Array) or thresholds.size() != 2 or float(thresholds[0]) >= 1.0 or float(thresholds[0]) <= float(thresholds[1]) or float(thresholds[1]) <= 0.0:
            errors.append("bad_divine_boss_stages:" + id)
        var observed: Array = []
        for action in raw.get("skills", []):
            if not (action is Dictionary):
                errors.append("divine_boss_action_not_object:" + id)
                continue
            var action_id := str(action.get("id", ""))
            if not action_id.begins_with("tmb.bossskill.") or observed.has(action_id) or not EFFECTS.has(str(action.get("effect", ""))):
                errors.append("bad_divine_boss_action:" + action_id)
            observed.append(action_id)
            if float(action.get("damage_ratio", 0.0)) <= 0.0 or float(action.get("range", 0.0)) <= 0.0 or float(action.get("cast_time", 0.0)) <= 0.0 or float(action.get("cooldown", 0.0)) <= 0.0:
                errors.append("bad_divine_boss_action_values:" + action_id)
            if str(action.get("counter_element", "")) not in CombatStatsV2.ELEMENTS or int(action.get("counter_hits", 0)) <= 0:
                errors.append("bad_divine_boss_counter:" + action_id)
        if observed.size() < 3 or raw.get("skill_ids", []) != observed:
            errors.append("divine_boss_action_index_mismatch:" + id)
    if bosses.size() != 3:
        errors.append("divine_boss_coverage_not_three")
    return errors

static func skill_definitions() -> Dictionary:
    var result: Dictionary = {}
    var loaded := load_catalogue()
    if bool(loaded.get("ok", false)):
        for row in loaded.data.skills:
            result[str(row.id)] = row.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    return skill_definitions().get(skill_id, {})

static func branch_definitions() -> Dictionary:
    var result: Dictionary = {}
    var loaded := load_catalogue()
    if bool(loaded.get("ok", false)):
        for row in loaded.data.branches:
            result[str(row.id)] = row.duplicate(true)
    return result

static func boss_definition(boss_id: String) -> Dictionary:
    var loaded := load_catalogue()
    if not bool(loaded.get("ok", false)):
        return {}
    for row in loaded.data.bosses:
        if str(row.id) == boss_id:
            return row.duplicate(true)
    return {}

static func boss_skill_definitions(boss_id: String) -> Dictionary:
    var result: Dictionary = {}
    for row in boss_definition(boss_id).get("skills", []):
        result[str(row.id)] = row.duplicate(true)
    return result

static func is_divine_skill(skill_id: String) -> bool:
    return not skill_definition(skill_id).is_empty()

static func is_divine_boss(boss_id: String) -> bool:
    return not boss_definition(boss_id).is_empty()

static func try_boss_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary) -> bool:
    if battle == null or actor.is_empty() or target.is_empty() or battle.now < float(actor.get("v63_boss_stagger_until", -1.0)):
        return false
    var boss_id := str(actor.get("v63_boss_id", ""))
    var boss := boss_definition(boss_id)
    if boss.is_empty():
        return false
    var ready: Dictionary = actor.get("v63_skill_ready", {})
    var phase := clampi(int(actor.get("v63_boss_phase", 1)), 1, 3)
    for raw_id in boss.get("skill_ids", []):
        var id := str(raw_id)
        var skill: Dictionary = boss_skill_definitions(boss_id).get(id, {})
        if skill.is_empty() or phase < int(skill.get("minimum_phase", 1)) or battle.now < float(ready.get(id, 0.0)):
            continue
        var cast_target: Dictionary = actor if str(skill.get("effect", "")) in ["guard", "heal", "cleanse"] else target
        if (actor["position"] as Vector2).distance_to(cast_target["position"]) > float(skill.range):
            continue
        var laws: Array = boss.get("laws", [])
        if not laws.is_empty():
            skill = skill.duplicate(true)
            var law_index := int(actor.get("v63_boss_law_index", 0)) % laws.size()
            skill["element"] = str(laws[law_index])
            actor["v63_boss_law_index"] = (law_index + 1) % laws.size()
            battle._event("boss_law_cycle", {"boss_id":boss_id,"law":str(skill.element),"law_index":law_index})
        var deadline := battle.now + maxf(MapBattleV2.STEP_SECONDS, float(skill.cast_time))
        var cast := _cast_record(actor, cast_target, id, skill, deadline, boss_id)
        if str(skill.shape) == "circle":
            cast["center"] = cast_target["position"]
        elif str(skill.shape) == "line":
            cast["line_origin"] = actor["position"]
            cast["line_direction"] = ((cast_target["position"] as Vector2) - (actor["position"] as Vector2)).normalized()
        actor["v63_pending_cast"] = cast
        ready[id] = battle.now + maxf(MapBattleV2.STEP_SECONDS, float(skill.cooldown))
        actor["v63_skill_ready"] = ready
        var counter := {"element":str(skill.get("counter_element", boss.get("counter_element", ""))),
            "until":battle.now + clampf(float(boss.get("counter_window", 1.5)), 0.5, 4.0),
            "hits_required":mini(8, maxi(1, int(skill.get("counter_hits", boss.get("break_gauge_required", 2))))),
            "hits":0,"skill_id":id}
        if bool(skill.get("interruptible", true)):
            actor["v63_boss_counter_window"] = counter
        else:
            actor.erase("v63_boss_counter_window")
        actor["v63_boss_break_gauge"] = 0
        actor["next_skill"] = battle.now + MapBattleV2.STEP_SECONDS
        battle._event("telegraph", {"caster":str(actor.id),"boss_id":boss_id,"skill":id,"skill_id":id,
            "center":cast_target["position"],"shape":str(skill.shape),"radius":float(skill.radius),"release_at":deadline,
            "phase":phase,"counter_element":str(counter.element),"counter_until":float(counter.until),"generation":"divine"})
        battle.actions += 1
        return true
    return false

static func observe_boss_damage(battle: MapBattleV2, boss_actor: Dictionary, hp_before: float,
        attacker: Dictionary, element: String, kind: String) -> void:
    if battle == null or not bool(boss_actor.get("v63_custom_boss_ai", false)):
        return
    var boss_id := str(boss_actor.get("v63_boss_id", ""))
    var boss := boss_definition(boss_id)
    var thresholds: Array = boss.get("phase_thresholds", [0.7, 0.35])
    var hp_ratio := float(boss_actor.hp) / maxf(1.0, float(boss_actor.get("max_hp", 1.0)))
    var phase := clampi(int(boss_actor.get("v63_boss_phase", 1)), 1, 3)
    while phase < 3 and hp_ratio <= float(thresholds[phase - 1]):
        phase += 1
        boss_actor["v63_boss_phase"] = phase
        battle._event("v63_boss_phase", {"boss_id":boss_id,"actor_id":str(boss_actor.id),"phase":phase,
            "threshold":float(thresholds[phase - 2]),"hp_before":hp_before,"hp_after":float(boss_actor.hp),
            "hp_ratio":hp_ratio,"generation":"divine"})
    if phase >= 2 and int(boss_actor.get("v63_summoned_phase", 1)) < phase:
        boss_actor["v63_summoned_phase"] = phase
        battle.add_v63_boss_summons(boss_actor, 2)
    if not is_divine_boss(boss_id) or kind not in ["basic", "v63_skill"] or str(attacker.get("side", "")) != "disciple":
        return
    var counter: Dictionary = boss_actor.get("v63_boss_counter_window", {})
    if counter.is_empty() or battle.now > float(counter.get("until", -1.0)) or element != str(counter.get("element", "")) or element.is_empty():
        return
    counter["hits"] = int(counter.get("hits", 0)) + 1
    boss_actor["v63_boss_break_gauge"] = int(counter.hits)
    boss_actor["v63_boss_counter_window"] = counter
    battle._event("boss_counter_hit", {"boss_id":boss_id,"attacker":str(attacker.get("id", "")),
        "element":element,"hits":int(counter.hits),"required":int(counter.hits_required),"skill_id":str(counter.skill_id)})
    if int(counter.hits) < int(counter.hits_required):
        return
    var pending: Dictionary = boss_actor.get("v63_pending_cast", {})
    if str(pending.get("v63_skill_id", "")) != str(counter.get("skill_id", "")):
        return
    boss_actor.erase("v63_pending_cast")
    boss_actor.erase("v63_boss_counter_window")
    boss_actor["v63_boss_stagger_until"] = battle.now + 1.35
    boss_actor["v63_boss_break_gauge"] = 0
    battle._event("boss_counter_break", {"boss_id":boss_id,"actor_id":str(boss_actor.id),
        "attacker":str(attacker.get("id", "")),"interrupted_skill":str(counter.skill_id),"stagger_until":float(boss_actor.v63_boss_stagger_until)})

static func apply_elemental_reaction(battle: MapBattleV2, attacker: Dictionary, target: Dictionary,
        skill_id: String, element: String) -> void:
    if battle == null or target.is_empty() or str(attacker.get("side", "")) != "disciple" or not is_divine_skill(skill_id):
        return
    var trace: Dictionary = target.get("v63_divine_element_trace", {})
    var previous := str(trace.get("element", ""))
    var previous_at := float(trace.get("at", -1.0))
    var owner_id := str(attacker.get("id", ""))
    var reaction_name := ""
    var ratio := 0.0
    if not previous.is_empty() and previous != element and battle.now - previous_at <= 2.5:
        var pair := [previous, element]
        pair.sort()
        var combo := "+".join(pair)
        match combo:
            "fire+water":
                reaction_name = "steam_burst"
                ratio = 0.24
            "lightning+water":
                reaction_name = "storm_arc"
                ratio = 0.28
            "fire+wood":
                reaction_name = "burning_growth"
                ratio = 0.22
            "nether+wood":
                reaction_name = "corrupted_root"
                ratio = 0.20
        if not reaction_name.is_empty():
            var ready: Dictionary = attacker.get("v63_reaction_ready", {})
            var key := str(target.get("id", ""))
            if battle.now >= float(ready.get(key, 0.0)):
                var damage := battle._deal_direct(attacker, target, ratio, "v63_reaction", false, element, false)
                ready[key] = battle.now + 0.8
                attacker["v63_reaction_ready"] = ready
                target.erase("v63_divine_element_trace")
                battle._event("elemental_reaction", {"caster":owner_id,"target":str(target.get("id", "")),
                    "name":reaction_name,"elements":pair,"damage":damage,"candidate":true})
                return
    target["v63_divine_element_trace"] = {"element":element,"owner_id":owner_id,"at":battle.now,"skill_id":skill_id}

static func _cast_record(caster: Dictionary, target: Dictionary, id: String, skill: Dictionary,
        deadline: float, boss_id: String) -> Dictionary:
    var root_factor := V63SpiritualRootEvaluator.attached_skill_effect_factor(caster, id)
    var effect := str(skill.get("effect", "damage"))
    var power := float(skill.get("power", 0.0))
    if effect in ["poison", "heal", "guard", "mark"]:
        power *= root_factor
    return {"caster":str(caster.id),"target_id":str(target.id),"v63_skill_id":id,"v63_boss_id":boss_id,
        "ready":deadline,"ratio":float(skill.damage_ratio)*root_factor,"element":str(skill.element),"effect":effect,
        "shape":str(skill.shape),"power":power,"duration":float(skill.get("duration", 0.0)),
        "poison_stacks":int(skill.get("poison_stacks", 0)),"radius":float(skill.get("radius", 0.0)),
        "maximum":mini(3, maxi(1, int(skill.get("target_limit", 1))))}

static func _valid_id(value: String) -> bool:
    return value.length() >= 12 and value.length() <= 128 and value.begins_with("tmb.")

static func _valid_slug(value: String) -> bool:
    if value.is_empty() or value.length() > 48:
        return false
    for character in value:
        if not ((character >= "a" and character <= "z") or (character >= "0" and character <= "9") or character == "_"):
            return false
    return true


static func attach_divine_state(actor: Dictionary, disciple: DiscipleState, lineage: String, stage: int) -> void:
    actor["v63_divine_stage"] = clampi(stage, 1, 3)
    actor["v63_combat_generation"] = "divine"
    if str(actor.get("v63_combat_branch_id", "")) != "huyet_quyen":
        return
    actor["v63_base_max_hp"] = float(actor.max_hp)
    actor["v63_blood_mode"] = "blood_life" if lineage == "b" else "blood_ma"
    if lineage == "b":
        return
    var covenant := false
    for skill_id in actor.get("v63_passive_ids", []):
        if not skill_definition(str(skill_id)).get("blood_covenant", {}).is_empty():
            covenant = true
    var base := float(actor.v63_base_max_hp)
    actor["v63_blood_mode"] = "blood_covenant" if covenant else "blood_ma"
    actor["v63_shield_received_factor"] = 0.6 if covenant else 1.0
    actor["max_hp"] = base * (0.55 if covenant else 0.65)
    actor["hp"] = minf(float(actor.hp), float(actor.max_hp))
    actor["stats"] = actor.stats.duplicate(true)
    actor.stats["max_hp"] = float(actor.max_hp)

static func healing_amount(caster: Dictionary, target: Dictionary, amount: float) -> float:
    var mode := str(target.get("v63_blood_mode", ""))
    if mode == "blood_covenant":
        return 0.0
    if mode == "blood_ma":
        if str(caster.id) == str(target.id) or float(target.hp) >= 0.35 * float(target.get("v63_base_max_hp", target.max_hp)):
            return 0.0
        return amount * 0.5
    return amount

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var skill_id := str(cast.get("v63_skill_id", ""))
    var definition := skill_definition(skill_id)
    var adjusted := cast.duplicate(true)
    if not definition.is_empty():
        var stage := clampi(int(caster.get("v63_divine_stage", 1)), 1, 3)
        adjusted["ratio"] = float(cast.ratio) * [1.0, 1.12, 1.24][stage - 1]
        if str(definition.get("branch", "")) == "huyet_quyen" and str(definition.get("lineage", "")) == "a":
            var before := float(caster.hp)
            var cost_fraction := 0.12 if str(definition.get("slot", "")) == "ultimate" else 0.10
            var cost := minf(maxf(0.0, before - 1.0), before * cost_fraction)
            caster["hp"] = before - cost
            battle._sync_linked_hp(caster)
            battle._event("blood_sacrifice", {"caster":str(caster.id),"skill_id":skill_id,"generation":"divine","lineage":"a","hp_before":before,"spent_hp":cost,"hp_after":float(caster.hp),"damage_packet":false})
            if str(definition.get("slot", "")) == "ultimate" and str(definition.get("lineage", "")) == "a":
                var missing := 1.0 - float(caster.hp) / maxf(1.0, float(caster.get("v63_base_max_hp", caster.max_hp)))
                adjusted["ratio"] = minf(82.32, 42.0 * (1.0 + 1.2 * minf(0.8, missing)))
    V63HumanSkillCombatSystem.release_cast_base(battle, adjusted, caster)
    if not definition.is_empty():
        battle._event("divine_action", {"caster":str(caster.id),"skill_id":skill_id,"rule":str(definition.get("divine_rule", "")),"stage":int(caster.get("v63_divine_stage", 1)),"ratio":float(adjusted.ratio)})


static func prevent_lethal(battle: MapBattleV2, target: Dictionary) -> bool:
    if battle.now < float(target.get("v63_fatal_save_ready_at", -1.0)):
        return false
    for id in target.get("v63_passive_ids", []):
        if int(skill_definition(str(id)).get("passive_modifiers", {}).get("fatal_save_charges", 0)) > 0:
            target["v63_fatal_save_ready_at"] = battle.now + 90.0
            battle._event("fatal_save", {"target":str(target.id),"skill_id":str(id),"family":"fatal_protection","ready_at":float(target.v63_fatal_save_ready_at)})
            return true
    return false

static func reflect_committed(battle: MapBattleV2, defender: Dictionary, attacker: Dictionary, damage: float, kind: String) -> void:
    if kind == "v63_reflection" or damage <= 0.0 or float(defender.hp) <= 0.0 or float(attacker.hp) <= 0.0:
        return
    var factor := 0.0
    for id in defender.get("v63_passive_ids", []):
        factor = maxf(factor, float(skill_definition(str(id)).get("passive_modifiers", {}).get("reflection_factor", 0.0)))
    if factor > 0.0:
        battle._deal_direct(defender, attacker, damage * minf(factor, 0.2) / maxf(1.0, float(defender.stats.attack)), "v63_reflection", false, "earth", false)
