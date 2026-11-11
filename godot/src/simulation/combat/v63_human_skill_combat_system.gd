class_name V63HumanSkillCombatSystem
extends RefCounted

const CATALOGUE_PATH := "res://data/combat/v63_human_combat_catalog.json"
const MAX_SKILLS_PER_DISCIPLE := 12
const MAX_TARGETS := 3
const POISON_OWNER_CAP := 5
const POISON_BOSS_TARGET_CAP := 30
const POISON_TICK_INTERVAL_SECONDS := 1.0
const EFFECTS := ["damage","poison","guard","heal","cleanse","mark","consume_poison","mobility","passive","innate"]
const BOW_LINE_RANGE_SKILL_IDS := [
    "tmb.skill.bow.liep_anh.ultimate.divine.b",
    "tmb.skill.bow.liep_anh.ultimate.rare.b"
]
static var _catalogue_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path,FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_human_combat_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["human_combat_catalogue_not_object"],"data":{}}
    var errors := validate_catalogue(parsed)
    if errors.is_empty() and path == CATALOGUE_PATH:
        _catalogue_cache = parsed.duplicate(true)
    return {"ok":errors.is_empty(),"errors":errors,"data":parsed}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 2 or bool(data.get("enabled",true)):
        errors.append("bad_human_combat_schema_or_release_gate")
    var skills = data.get("skills",null)
    var bosses = data.get("bosses",null)
    var branches = data.get("branches",null)
    if not (skills is Array) or not (bosses is Array) or not (branches is Array):
        errors.append("missing_human_combat_arrays")
        return errors
    var branch_ids: Dictionary = {}
    for branch in branches:
        var branch_id := str(branch.get("id","")) if branch is Dictionary else ""
        if not _valid_slug(branch_id) or branch_ids.has(branch_id):
            errors.append("bad_or_duplicate_human_branch:"+branch_id)
        branch_ids[branch_id] = true
    if branch_ids.size() != 9:
        errors.append("human_branch_count_not_nine")
    var ids: Dictionary = {}
    for skill in skills:
        if not (skill is Dictionary):
            errors.append("human_skill_not_object")
            continue
        var id := str(skill.get("id",""))
        var slot := str(skill.get("slot",""))
        var effect := str(skill.get("effect",""))
        if not _valid_id(id) or ids.has(id):
            errors.append("bad_or_duplicate_human_skill:"+id)
        ids[id] = true
        if str(skill.get("tier","")) != "human" or not EFFECTS.has(effect):
            errors.append("unsupported_human_skill:"+id)
        if slot not in ["basic","active","ultimate","mobility","passive","innate"]:
            errors.append("bad_human_skill_slot:"+id)
        if not str(skill.get("branch","")).is_empty() and not branch_ids.has(str(skill.branch)):
            errors.append("unknown_human_skill_branch:"+id)
        if bool(skill.get("archivable",false)) != (slot != "innate") or (slot != "innate" and str(skill.get("source_codex_id","")).is_empty()):
            errors.append("human_skill_archive_mismatch:"+id)
        if float(skill.get("damage_ratio",0.0)) <= 0.0 or float(skill.get("range",0.0)) <= 0.0 or float(skill.get("cooldown",0.0)) <= 0.0 or float(skill.get("cast_time",-1.0)) < 0.0 or not CombatStatsV2.ELEMENTS.has(str(skill.get("element",""))):
            errors.append("human_skill_bad_action_values:"+id)
        if not ["single_target","circle","line"].has(str(skill.get("shape",""))) or float(skill.get("radius",0.0)) < 0.0 or int(skill.get("target_limit",0)) < 1 or int(skill.get("target_limit",0)) > MAX_TARGETS:
            errors.append("human_skill_bad_shape_or_bounds:"+id)
        if effect in ["passive","innate"] and not (skill.get("passive_modifiers",null) is Dictionary):
            errors.append("human_skill_missing_passive_data:"+id)
    if skills.size() != 105:
        errors.append("human_skill_coverage_not_105")
    var boss_ids: Dictionary = {}
    for boss in bosses:
        if not (boss is Dictionary):
            errors.append("human_boss_not_object")
            continue
        var boss_id := str(boss.get("id",""))
        if not _valid_id(boss_id) or boss_ids.has(boss_id) or str(boss.get("tier_band","")) != "human":
            errors.append("bad_or_duplicate_human_boss:"+boss_id)
        boss_ids[boss_id] = true
        if not MonsterCatalogueV2.SPECIES.has(str(boss.get("origin_species_id",""))):
            errors.append("human_boss_missing_source_species:"+boss_id)
        var thresholds = boss.get("phase_thresholds",[])
        if not (thresholds is Array) or thresholds.size() != 2 or float(thresholds[0]) >= 1.0 or float(thresholds[0]) <= float(thresholds[1]) or float(thresholds[1]) <= 0.0:
            errors.append("human_boss_bad_phases:"+boss_id)
        var observed: Array = []
        for action in boss.get("skills",[]):
            if not (action is Dictionary):
                errors.append("human_boss_action_not_object:"+boss_id)
                continue
            var action_id := str(action.get("id",""))
            if not action_id.begins_with("tmb.bossskill.") or observed.has(action_id) or not EFFECTS.has(str(action.get("effect",""))):
                errors.append("bad_human_boss_action:"+action_id)
            observed.append(action_id)
            if float(action.get("damage_ratio",0.0)) <= 0.0 or float(action.get("range",0.0)) <= 0.0 or float(action.get("cast_time",0.0)) <= 0.0 or float(action.get("cooldown",0.0)) <= 0.0:
                errors.append("bad_human_boss_action_values:"+action_id)
        if observed.size() < 3 or boss.get("skill_ids",[]) != observed:
            errors.append("human_boss_action_index_mismatch:"+boss_id)
    if bosses.size() != 3:
        errors.append("human_boss_coverage_not_three")
    return errors

static func is_enabled(state: SimulationState, preview_overrides: Dictionary = {}) -> bool:
    return state != null and state.sect.v63_skill_combat_opt_in and V63FeatureGates.is_enabled("human_skill_combat",preview_overrides)

static var _all_skill_definition_cache: Dictionary = {}

static func skill_definitions() -> Dictionary:
    if not _all_skill_definition_cache.is_empty():
        return _all_skill_definition_cache.duplicate(true)
    var result: Dictionary = {}
    var all_loaded := true
    var loaded := load_catalogue()
    if bool(loaded.get("ok",false)):
        for row in loaded.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    var immortal := V63ImmortalSkillCombatSystem.load_catalogue()
    if bool(immortal.get("ok",false)):
        for row in immortal.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    var divine := V63DivineSkillCombatSystem.load_catalogue()
    if bool(divine.get("ok", false)):
        for row in divine.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    var sword := V63SwordSkillCombatSystem.load_catalogue()
    if bool(sword.get("ok", false)):
        for row in sword.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    var blade := V63BladeSkillCombatSystem.load_catalogue()
    if bool(blade.get("ok", false)):
        for row in blade.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    var spear := V63SpearSkillCombatSystem.load_catalogue()
    if bool(spear.get("ok", false)):
        for row in spear.data.skills:
            result[str(row.id)] = row.duplicate(true)
    else:
        all_loaded = false
    if all_loaded:
        _all_skill_definition_cache = result.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    if _all_skill_definition_cache.is_empty():
        skill_definitions()
    var definition: Dictionary = _all_skill_definition_cache.get(skill_id,{})
    return definition.duplicate(true)

static func branch_definitions() -> Dictionary:
    var result: Dictionary = {}
    var loaded := load_catalogue()
    if bool(loaded.get("ok",false)):
        for row in loaded.data.branches:
            result[str(row.id)] = row.duplicate(true)
    var immortal := V63ImmortalSkillCombatSystem.branch_definitions()
    for branch_id in immortal.keys():
        var row: Dictionary = immortal[branch_id].duplicate(true)
        row["innate_node_id"] = str(result.get(branch_id, {}).get("innate_node_id", ""))
        result[str(branch_id)] = row
    var sword := V63SwordSkillCombatSystem.branch_definitions()
    for branch_id in sword.keys():
        result[str(branch_id)] = sword[branch_id].duplicate(true)
    var blade := V63BladeSkillCombatSystem.branch_definitions()
    for branch_id in blade.keys():
        result[str(branch_id)] = blade[branch_id].duplicate(true)
    var spear := V63SpearSkillCombatSystem.branch_definitions()
    for branch_id in spear.keys():
        result[str(branch_id)] = spear[branch_id].duplicate(true)
    return result

static func boss_definition(boss_id: String) -> Dictionary:
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        return {}
    for row in loaded.data.bosses:
        if str(row.id) == boss_id:
            return row.duplicate(true)
    var immortal := V63ImmortalSkillCombatSystem.boss_definition(boss_id)
    return immortal if not immortal.is_empty() else V63DivineSkillCombatSystem.boss_definition(boss_id)

static func boss_skill_definitions(boss_id: String) -> Dictionary:
    var result: Dictionary = {}
    for row in boss_definition(boss_id).get("skills",[]):
        result[str(row.id)] = row.duplicate(true)
    return result

static func learn_skill(state: SimulationState, disciple: DiscipleState, skill_id: String, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("human_skill_combat_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    var definition := skill_definition(skill_id)
    if str(definition.get("school", "")) == "sword":
        return V63SwordSkillCombatSystem.can_learn(definition)
    if str(definition.get("school", "")) == "blade":
        return V63BladeSkillCombatSystem.can_learn(definition)
    if str(definition.get("school", "")) == "spear":
        return V63SpearSkillCombatSystem.can_learn(definition)
    if definition.is_empty() or not bool(definition.get("archivable",false)):
        return _failure("unknown_or_derived_human_skill")
    var codex_id := str(definition.get("source_codex_id",""))
    if not V63SectArchiveSystem.transmission_available_for_disciple(state,disciple.id,codex_id,preview_overrides):
        return _failure("required_manual_not_archived")
    if str(definition.get("generation", "human")) == "immortal" \
        and not V63LearningSystem.lineage_study_complete(disciple, str(definition.get("branch", "")), str(definition.get("lineage", ""))):
        return _failure("immortal_lineage_study_incomplete")
    if str(definition.get("generation", "")) == "divine":
        if not V63FeatureGates.is_enabled("divine_skill_combat", preview_overrides):
            return _failure("divine_skill_combat_disabled")
        if V63LearningSystem.divine_lineage_stage(disciple, str(definition.branch), str(definition.lineage)) < int(definition.get("required_divine_stage", 1)):
            return _failure("divine_lineage_study_incomplete")
    # Existing saved high-tier skills are grandfathered by the duplicate path.
    # New study in opted-in V63 requires the exact predecessor of the family,
    # not an unrelated high-tier spell with a similar name.
    if disciple.v63_learned_skill_nodes.has(skill_id):
        return {"ok":true,"duplicate":true,"skill_id":skill_id}
    if V63FeatureGates.is_enabled("poison_evolution_strict", preview_overrides) \
            and not V63PoisonEvolutionV1.predecessor_ready(definition, disciple.v63_learned_skill_nodes):
        return _failure("poison_predecessor_not_learned")
    disciple.v63_learned_skill_nodes[skill_id] = {"source_codex_id":codex_id,"learned_tick":maxi(state.tick,0),"mastery_xp":0.0,"level":1,"branch_id":str(definition.get("branch",""))}
    return {"ok":true,"skill_id":skill_id,"codex_id":codex_id}

static func equip_skill(state: SimulationState, disciple: DiscipleState, skill_id: String, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("human_skill_combat_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    var definition := skill_definition(skill_id)
    if definition.is_empty() or not bool(definition.get("archivable",false)) or not disciple.v63_learned_skill_nodes.has(skill_id):
        return _failure("skill_not_personally_learned")
    if disciple.v63_equipped_skill_ids.has(skill_id):
        return {"ok":true,"duplicate":true,"skill_id":skill_id}
    var branch := str(definition.get("branch",""))
    var selected := str(disciple.v63_combat_branch_id)
    if not branch.is_empty() and not selected.is_empty() and branch != selected:
        return _failure("skill_belongs_to_other_branch")
    var slot := str(definition.get("slot",""))
    var limit := 4 if slot == "active" else (5 if slot == "passive" else 1)
    var replacement_ids: Array[String] = []
    var lineage := str(definition.get("lineage", "base"))
    for raw_old_id in disciple.v63_equipped_skill_ids:
        var old_id := str(raw_old_id)
        var old_definition := skill_definition(old_id)
        var same_family := str(old_definition.get("family_id", "")) == str(definition.get("family_id", ""))
        var switching_immortal_lineage := str(definition.get("generation", "")) in ["immortal", "divine"] \
            and str(old_definition.get("generation", "")) in ["immortal", "divine"] \
            and str(old_definition.get("branch", "")) == branch \
            and str(old_definition.get("lineage", "base")) != lineage
        if same_family or switching_immortal_lineage:
            replacement_ids.append(old_id)
    var count := 0
    for old_id in disciple.v63_equipped_skill_ids:
        if not replacement_ids.has(str(old_id)) and str(skill_definition(str(old_id)).get("slot","")) == slot:
            count += 1
    if count >= limit or disciple.v63_equipped_skill_ids.size() - replacement_ids.size() >= MAX_SKILLS_PER_DISCIPLE:
        return _failure("skill_slot_full")
    for old_id in replacement_ids:
        disciple.v63_equipped_skill_ids.erase(old_id)
    disciple.v63_equipped_skill_ids.append(skill_id)
    disciple.v63_equipped_skill_ids.sort()
    if not branch.is_empty() and selected.is_empty():
        disciple.v63_combat_branch_id = StringName(branch)
    return {"ok":true,"skill_id":skill_id,"slot":slot,"branch_id":str(disciple.v63_combat_branch_id),"replaced_skill_ids":replacement_ids}

static func attach_disciple_loadout(state: SimulationState, actor: Dictionary, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return {"ok":true,"attached":false}
    var id := StringName(str(actor.get("id","")))
    if not state.disciples.has(id):
        return _failure("unknown_disciple")
    var disciple: DiscipleState = state.disciples[id]
    actor["v63_sword_combat_enabled"] = V63FeatureGates.is_enabled("sword_skill_combat",preview_overrides)
    actor["v63_blade_combat_enabled"] = V63FeatureGates.is_enabled("blade_skill_combat",preview_overrides)
    actor["v63_spear_combat_enabled"] = V63FeatureGates.is_enabled("spear_skill_combat",preview_overrides)
    var definitions := skill_definitions()
    var skills: Array = []
    var passives: Array = []
    var immortal_lineage := ""
    var divine_lineage := ""
    for raw_id in disciple.v63_equipped_skill_ids:
        var skill_id := str(raw_id)
        if disciple.v63_learned_skill_nodes.has(skill_id) and definitions.has(skill_id):
            if str(definitions[skill_id].get("generation", "")) == "divine":
                if not V63FeatureGates.is_enabled("divine_skill_combat", preview_overrides):
                    continue
                divine_lineage = str(definitions[skill_id].get("lineage", ""))
            skills.append(skill_id)
            if str(definitions[skill_id].get("slot","")) == "passive":
                passives.append(skill_id)
            if str(definitions[skill_id].get("generation", "")) == "immortal":
                immortal_lineage = str(definitions[skill_id].get("lineage", ""))
    var branch: Dictionary = branch_definitions().get(str(disciple.v63_combat_branch_id),{})
    if not branch.is_empty() and immortal_lineage in ["a", "b"]:
        var school := str(branch.get("school", ""))
        for index in range(skills.size() - 1, -1, -1):
            var equipped: Dictionary = definitions.get(str(skills[index]), {})
            if str(equipped.get("slot", "")) in ["basic", "mobility"]:
                skills.remove_at(index)
        skills.append("tmb.skill.%s.basic.immortal.base" % school)
        skills.append("tmb.skill.%s.mobility.immortal.base" % school)
    if divine_lineage in ["a", "b"]:
        var divine_branch: Dictionary = V63DivineSkillCombatSystem.branch_definitions().get(str(disciple.v63_combat_branch_id), {})
        if divine_branch.is_empty():
            divine_branch = branch_definitions().get(str(disciple.v63_combat_branch_id), {})
        if divine_branch.is_empty():
            return _failure("divine_branch_definition_missing")
        for index in range(skills.size() - 1, -1, -1):
            if str(definitions[str(skills[index])].get("slot", "")) in ["basic", "mobility"]:
                skills.remove_at(index)
        skills.append("tmb.skill.%s.basic.divine.base" % str(divine_branch.school))
        skills.append("tmb.skill.%s.mobility.divine.base" % str(divine_branch.school))
        actor["v63_divine_innate_id"] = str(divine_branch.divine_innate_node_ids[divine_lineage])
    skills.sort()
    actor["v63_skill_loadout"] = skills
    actor["v63_passive_ids"] = passives
    actor["v63_combat_branch_id"] = str(disciple.v63_combat_branch_id)
    if not branch.is_empty():
        actor["v63_innate_skill_id"] = str(branch.get("innate_node_ids", {}).get(immortal_lineage, branch.get("innate_node_id", "")))
    if not divine_lineage.is_empty():
        actor["v63_innate_skill_id"] = str(actor.v63_divine_innate_id)
    actor["v63_combat_lineage"] = divine_lineage if not divine_lineage.is_empty() else immortal_lineage
    actor["v63_skill_ready"] = {}
    actor["v63_combat_enabled"] = true
    if V63FeatureGates.is_enabled("spiritual_root_v2", preview_overrides):
        if not bool(actor.get("v63_spiritual_root_enabled", false)):
            return _failure("spiritual_root_v2_not_applied_to_combat_loadout")
        var root_values: Dictionary = actor.get("v63_root_values", {}).duplicate(true)
        var root_factors: Dictionary = {}
        var root_mastery_factors: Dictionary = {}
        var factor_ids: Array = skills.duplicate()
        var innate_for_root := str(actor.get("v63_innate_skill_id", ""))
        if not innate_for_root.is_empty() and not factor_ids.has(innate_for_root):
            factor_ids.append(innate_for_root)
        for factor_id_value in factor_ids:
            var factor_id := str(factor_id_value)
            var definition: Dictionary = definitions.get(factor_id, {})
            if definition.is_empty():
                continue
            var root_factor := V63SpiritualRootEvaluator.skill_effect_factor(root_values, definition)
            if not bool(root_factor.get("ok", false)):
                return _failure("invalid_spiritual_root_skill_factor:" + factor_id)
            var factor := float(root_factor.get("factor", 1.0))
            if factor > 1.0:
                root_factors[factor_id] = factor
            var mastery_factor := V63SpiritualRootEvaluator.skill_mastery_factor(root_values, definition)
            if not bool(mastery_factor.get("ok", false)):
                return _failure("invalid_spiritual_root_mastery_factor:" + factor_id)
            var mastery_multiplier := float(mastery_factor.get("factor", 1.0))
            if mastery_multiplier > 1.0:
                root_mastery_factors[factor_id] = mastery_multiplier
        var skill_factor_map: Dictionary = actor.get("skill_factors", {}).duplicate(true)
        skill_factor_map["__v63_root_skill_effect_factors"] = root_factors
        skill_factor_map["__v63_root_skill_mastery_factors"] = root_mastery_factors
        actor["skill_factors"] = skill_factor_map
    for skill_id in skills:
        var skill: Dictionary = definitions[skill_id]
        if str(skill.get("slot","")) == "basic":
            actor["v63_basic_skill_id"] = skill_id
            actor["basic_ratio"] = float(skill.damage_ratio) * V63SpiritualRootEvaluator.attached_skill_effect_factor(actor, skill_id)
            actor["range"] = float(skill.range)
            actor["basic_range"] = float(skill.range)
            actor["basic_element"] = str(skill.element)
    if not divine_lineage.is_empty():
        V63DivineSkillCombatSystem.attach_divine_state(actor, disciple, divine_lineage, V63LearningSystem.divine_lineage_stage(disciple, str(disciple.v63_combat_branch_id), divine_lineage))
    elif not immortal_lineage.is_empty():
        V63ImmortalSkillCombatSystem.attach_immortal_state(actor, immortal_lineage)
    return {"ok":true,"attached":not skills.is_empty(),"skill_ids":skills}

static func _valid_id(value: String) -> bool:
    return value.length() >= 12 and value.length() <= 128 and value.begins_with("tmb.")

static func _valid_slug(value: String) -> bool:
    if value.is_empty() or value.length() > 48:
        return false
    for character in value:
        if not ((character >= "a" and character <= "z") or (character >= "0" and character <= "9") or character == "_"):
            return false
    return true

static func _failure(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}

static func basic_element(actor: Dictionary) -> String:
    return str(actor.get("basic_element",""))

static func handles_actor(actor: Dictionary) -> bool:
    return bool(actor.get("v63_custom_boss_ai",false)) or bool(actor.get("v63_combat_enabled",false)) or not actor.get("v63_skill_loadout",[]).is_empty()

static func effective_attack_stats(actor: Dictionary, input_stats: Dictionary) -> Dictionary:
    var stats := input_stats.duplicate(true)
    if not bool(actor.get("v63_combat_enabled",false)):
        return stats
    var factor := 1.0
    var crit := 0.0
    var attack_speed := 0.0
    var cast_speed := 0.0
    var cooldown_recovery := 0.0
    var lifesteal := 0.0
    for skill_id in _passive_ids(actor):
        var mods := _root_scaled_passive_modifiers(actor, str(skill_id))
        factor *= 1.0+clampf(float(mods.get("outgoing_factor",0.0)),-0.5,0.5)
        crit += clampf(float(mods.get("crit_bonus",0.0)),-0.25,0.25)
        attack_speed += clampf(float(mods.get("attack_speed_factor",0.0)),-0.5,0.5)
        cast_speed += clampf(float(mods.get("cast_speed_factor",0.0)),-0.5,0.5)
        cooldown_recovery += clampf(float(mods.get("cooldown_recovery_factor",0.0)),-0.5,0.5)
        lifesteal += clampf(float(mods.get("lifesteal",0.0)),0.0,0.1)
    var innate_id := str(actor.get("v63_innate_skill_id",""))
    if not innate_id.is_empty():
        var innate := _root_scaled_passive_modifiers(actor, innate_id)
        factor *= 1.0+clampf(float(innate.get("outgoing_factor",0.0)),-0.5,0.5)
        crit += clampf(float(innate.get("crit_bonus",0.0)),-0.25,0.25)
        attack_speed += clampf(float(innate.get("attack_speed_factor",0.0)),-0.5,0.5)
        cast_speed += clampf(float(innate.get("cast_speed_factor",0.0)),-0.5,0.5)
        cooldown_recovery += clampf(float(innate.get("cooldown_recovery_factor",0.0)),-0.5,0.5)
        lifesteal += clampf(float(innate.get("lifesteal",0.0)),0.0,0.1)
    if float(actor.get("v63_combat_clock", INF)) < float(actor.get("v63_blood_frenzy_until", -1.0)):
        factor *= 1.25
    if str(actor.get("v63_blood_mode", "")) == "blood_covenant":
        factor *= 1.2
    stats["attack"] = float(stats.get("attack",0.0))*factor
    stats["crit_chance"] = clampf(float(stats.get("crit_chance",0.0))+crit,0.0,0.95)
    stats["attack_speed"] = clampf(float(stats.get("attack_speed",0.0))+attack_speed,-0.9,2.0)
    stats["cast_speed"] = clampf(float(stats.get("cast_speed",0.0))+cast_speed,-0.9,2.0)
    stats["cooldown_recovery"] = clampf(float(stats.get("cooldown_recovery",0.0))+cooldown_recovery,-0.9,2.0)
    stats["lifesteal"] = 0.0 if str(actor.get("v63_blood_mode", "")) in ["blood_ma", "blood_covenant"] else clampf(float(stats.get("lifesteal",0.0))+lifesteal,0.0,0.5)
    return stats

static func effective_defense_stats(actor: Dictionary, input_stats: Dictionary) -> Dictionary:
    var stats := input_stats.duplicate(true)
    if not bool(actor.get("v63_combat_enabled",false)):
        return stats
    var factor := 1.0
    for skill_id in _passive_ids(actor):
        factor *= clampf(float(_root_scaled_passive_modifiers(actor, str(skill_id)).get("guard_factor",1.0)),0.5,1.0)
    var innate_id := str(actor.get("v63_innate_skill_id",""))
    if not innate_id.is_empty():
        factor *= clampf(float(_root_scaled_passive_modifiers(actor, innate_id).get("guard_factor",1.0)),0.5,1.0)
    var reduction := clampf(float(stats.get("damage_reduction",0.0)),0.0,0.95)
    stats["damage_reduction"] = 1.0-(1.0-reduction)*factor
    return stats

static func marked_damage_factor(attacker: Dictionary, target: Dictionary, now: float, source_skill_id: String = "") -> float:
    var marks: Dictionary = target.get("v63_marks",{})
    var mark: Dictionary = marks.get(str(attacker.get("id","")),{})
    if mark.is_empty() or now >= float(mark.get("until",-1.0)):
        return 1.0
    if str(mark.get("school","")) == "blade" and not source_skill_id.begins_with("tmb.skill.blade."):
        return 1.0
    var maximum_factor := 1.15 if str(mark.get("school","")) == "blade" else 1.5
    return clampf(float(mark.get("damage_factor",1.0)),1.0,maximum_factor)

static func effective_poison_factor(actor: Dictionary) -> float:
    var factor := 1.0
    for raw_id in _passive_ids(actor):
        factor *= 1.0 + clampf(float(_root_scaled_passive_modifiers(actor, str(raw_id)).get("poison_factor", 0.0)), 0.0, 0.5)
    var innate_id := str(actor.get("v63_innate_skill_id", ""))
    if not innate_id.is_empty():
        factor *= 1.0 + clampf(float(_root_scaled_passive_modifiers(actor, innate_id).get("poison_factor", 0.0)), 0.0, 0.5)
    return factor

static func effective_heal_factor(actor: Dictionary) -> float:
    var factor := 1.0
    for raw_id in _passive_ids(actor):
        factor *= 1.0 + clampf(float(_root_scaled_passive_modifiers(actor, str(raw_id)).get("heal_factor", 0.0)), 0.0, 0.25)
    var innate_id := str(actor.get("v63_innate_skill_id", ""))
    if not innate_id.is_empty():
        factor *= 1.0 + clampf(float(_root_scaled_passive_modifiers(actor, innate_id).get("heal_factor", 0.0)), 0.0, 0.25)
    return factor

static func _root_scaled_passive_modifiers(actor: Dictionary, skill_id: String) -> Dictionary:
    var modifiers: Dictionary = skill_definition(skill_id).get("passive_modifiers", {}).duplicate(true)
    var factor := V63SpiritualRootEvaluator.attached_skill_effect_factor(actor, skill_id)
    if factor <= 1.0:
        return modifiers
    # Only the authored numeric passive-effect magnitudes scale. Durations,
    # cooldowns, target counts and proc/receipt limits are never modified here.
    # Root affinity amplifies the magnitude of an authored skill effect,
    # not generic crit, attack/cast speed, cooldown recovery or lifesteal.
    # Those channels already have their own source-specific Root V2 passives.
    for field in ["outgoing_factor", "poison_factor", "heal_factor"]:
        if modifiers.has(field):
            modifiers[field] = float(modifiers[field]) * factor
    if modifiers.has("guard_factor"):
        var guard_factor := clampf(float(modifiers["guard_factor"]), 0.5, 1.0)
        modifiers["guard_factor"] = clampf(1.0 - (1.0 - guard_factor) * factor, 0.5, 1.0)
    return modifiers

static func _passive_ids(actor: Dictionary) -> Array:
    var value = actor.get("v63_passive_ids",[])
    return value if value is Array else []

# Positioning must follow an equipped offensive skill, never an invented
# radius. Ranged cultivators retain their maximum authored reach on cooldown;
# support/mobility skills cannot artificially extend attack distance.
static func preferred_offensive_range(actor: Dictionary) -> float:
    var basic := maxf(0.0, float(actor.get("range", 1.8)))
    basic = maxf(basic,V63SwordSkillCombatSystem.preferred_offensive_range(actor))
    basic = maxf(basic,V63SpearSkillCombatSystem.preferred_offensive_range(actor))
    if str(actor.get("side", "")) != "disciple" or str(actor.get("role", "")) not in ["mage", "ranged"]:
        return basic
    if not bool(actor.get("v63_combat_enabled", false)):
        return basic
    for raw_id in actor.get("v63_skill_loadout", []):
        var definition := skill_definition(str(raw_id))
        if str(definition.get("slot", "")) not in ["active", "ultimate"]:
            continue
        if str(definition.get("effect", "")) in ["heal", "cleanse", "guard", "mobility"]:
            continue
        basic = maxf(basic, float(definition.get("range", 0.0)))
    return basic

static func try_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary, guard_only: bool = false) -> bool:
    if battle == null or guard_only or target.is_empty():
        return false
    if bool(actor.get("v63_custom_boss_ai",false)) and str(actor.get("side","")) == "monster":
        return bool(actor.get("v63_combat_enabled",false)) and _try_boss_cast(battle,actor,target)
    return bool(actor.get("v63_combat_enabled",false)) and _try_human_cast(battle,actor,target)

static func _try_human_cast(battle: MapBattleV2, actor: Dictionary, enemy: Dictionary) -> bool:
    var ready: Dictionary = actor.get("v63_skill_ready",{})
    for raw_id in actor.get("v63_skill_loadout",[]):
        var id := str(raw_id)
        var skill := skill_definition(id)
        var slot := str(skill.get("slot",""))
        var effect := str(skill.get("effect",""))
        if str(skill.get("school","")) == "sword" and not V63SwordSkillCombatSystem.can_cast(actor,id):
            continue
        if str(skill.get("school","")) == "blade" and not V63BladeSkillCombatSystem.can_cast(actor,id):
            continue
        if str(skill.get("school","")) == "spear" and not V63SpearSkillCombatSystem.can_cast(actor,id):
            continue
        if skill.is_empty() or slot not in ["active","ultimate","mobility"] or battle.now < float(ready.get(id,0.0)):
            continue
        if effect == "mobility":
            if _try_mobility(battle,actor,enemy,id,skill,ready):
                return true
            continue
        var target := _support_target(battle,actor,skill) if effect in ["guard","heal","cleanse"] else enemy
        if target.is_empty() or (effect not in ["guard","heal","cleanse"] and str(target.side) == str(actor.side)):
            continue
        if (actor["position"] as Vector2).distance_to(target["position"]) > float(skill.range):
            continue
        _begin_cast(battle,actor,target,id,skill,ready)
        return true
    return false

static func _same_p0_support_party(caster: Dictionary, ally: Dictionary) -> bool:
    # NPC monster-side support keeps its legacy faction behavior.
    # Independent sect hunters are not automatically one 30-person party.
    # Solo actors may always heal/guard THEMSELVES.
    if str(caster.get("side","")) != "disciple":
        return true
    if str(caster.get("id","")) == str(ally.get("id","")):
        return true
    var group := str(caster.get("party_id",""))
    return not group.is_empty() and group == str(ally.get("party_id",""))

static func _support_target(battle: MapBattleV2, actor: Dictionary, skill: Dictionary) -> Dictionary:
    if str(skill.effect) == "guard":
        if str(skill.get("school","")) in ["blade", "spear"] and str(skill.get("guard_target_policy","self")) == "weakest_ally":
            var guard_candidates: Array = []
            for raw_id in battle.actors.keys():
                var guard_ally: Dictionary = battle.actors[raw_id]
                if str(guard_ally.get("side","")) != str(actor.get("side","")) or float(guard_ally.get("hp",0.0)) <= 0.0:
                    continue
                if not _same_p0_support_party(actor,guard_ally):
                    continue
                if (actor.get("position",Vector2.ZERO) as Vector2).distance_to(guard_ally.get("position",Vector2.ZERO)) > float(skill.get("range",0.0)):
                    continue
                guard_candidates.append(guard_ally)
            guard_candidates.sort_custom(func(a: Dictionary,b: Dictionary):
                var a_ratio := float(a.get("hp",0.0)) / maxf(1.0,float(a.get("max_hp",1.0)))
                var b_ratio := float(b.get("hp",0.0)) / maxf(1.0,float(b.get("max_hp",1.0)))
                return a_ratio < b_ratio if not is_equal_approx(a_ratio,b_ratio) else str(a.get("id","")) < str(b.get("id","")))
            return guard_candidates[0] if not guard_candidates.is_empty() else {}
        return actor
    var candidates: Array = []
    for raw_id in battle.actors.keys():
        var ally: Dictionary = battle.actors[raw_id]
        if str(ally.side) != str(actor.side) or float(ally.hp) <= 0.0 \
                or not _same_p0_support_party(actor,ally):
            continue
        if (actor["position"] as Vector2).distance_to(ally["position"]) <= float(skill.range):
            if str(skill.get("effect", "")) == "heal":
                var missing_hp := maxf(0.0, float(ally.get("max_hp", 0.0)) - float(ally.get("hp", 0.0)))
                if missing_hp <= 0.001:
                    continue
                var potential_heal := minf(float(ally.get("max_hp", 0.0)) * clampf(float(skill.get("power", 0.0)), 0.0, 0.5), missing_hp)
                var effective_heal := potential_heal
                if str(ally.get("v63_combat_generation", "")) == "immortal":
                    effective_heal = V63ImmortalSkillCombatSystem.healing_amount(actor, ally, potential_heal)
                else:
                    effective_heal = V63DivineSkillCombatSystem.healing_amount(actor, ally, potential_heal)
                if effective_heal <= 0.001:
                    continue
                if str(skill.get("school", "")) == "poison" and \
                        V63PoisonEvolutionV1.heal_capacity(ally, battle.now) <= 0.001:
                    continue
            candidates.append(ally)
    if str(skill.effect) == "cleanse":
        candidates.sort_custom(func(a: Dictionary,b: Dictionary):
            var a_count := _status_count(a)
            var b_count := _status_count(b)
            return a_count > b_count if a_count != b_count else str(a.id) < str(b.id))
        return candidates[0] if not candidates.is_empty() and _status_count(candidates[0]) > 0 else {}
    candidates.sort_custom(func(a: Dictionary,b: Dictionary):
        var a_ratio := float(a.hp) / maxf(1.0, float(a.max_hp))
        var b_ratio := float(b.hp) / maxf(1.0, float(b.max_hp))
        return a_ratio < b_ratio if not is_equal_approx(a_ratio, b_ratio) else str(a.id) < str(b.id))
    return candidates[0] if not candidates.is_empty() else {}

static func _status_count(actor: Dictionary) -> int:
    var statuses: Dictionary = actor.get("status_effects",{})
    return int(statuses.get("v63_poison",[]).size())+int(statuses.has("burn"))+int(statuses.has("weaken"))

static func _try_mobility(battle: MapBattleV2, actor: Dictionary, target: Dictionary, id: String, skill: Dictionary, ready: Dictionary) -> bool:
    if str(actor.get("side", "")) != "disciple":
        return false
    var attack_range := maxf(1.0, preferred_offensive_range(actor))
    if battle.world_mode:
        return _try_world_mobility(battle,actor,target,id,skill,ready,attack_range)
    var distance := (actor["position"] as Vector2).distance_to(target["position"])
    if distance <= attack_range+0.2 or distance > float(skill.range):
        return false
    var direction := ((target["position"] as Vector2)-(actor["position"] as Vector2)).normalized()
    var destination := battle._keep_inside((target["position"] as Vector2)-direction*(attack_range-0.15))
    if not battle._position_allowed(destination):
        return false
    actor["position"] = destination
    actor["v63_evasion_until"] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.get("duration",1.0)))
    ready[id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cooldown))
    actor["v63_skill_ready"] = ready
    actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
    battle._event("v63_mobility",{"actor_id":str(actor.id),"skill_id":id,"position":destination,"evasion_until":float(actor.v63_evasion_until)})
    battle.actions += 1
    return true

static func _try_world_mobility(battle: MapBattleV2, actor: Dictionary, target: Dictionary, id: String, skill: Dictionary, ready: Dictionary, attack_range: float) -> bool:
    if battle.world_navigation.is_empty():
        return false
    var origin: Vector2 = actor["position"]
    var path: Array[Vector2i] = battle._world_path(origin,target["position"])
    if path.size() < 2:
        return false
    var route_distance := battle._world_route_distance(origin,path)
    if route_distance <= attack_range+0.2 or route_distance > float(skill.get("range",0.0)):
        return false

    # World mobility follows the same blocked-cell route used by auto-hunt.
    # The move order advances through walkable cells over normal simulation steps.
    var desired_progress := maxf(0.0,route_distance-maxf(0.0,attack_range-0.15))
    var travelled := 0.0
    var previous := origin
    var destination := origin
    for path_index in range(1,path.size()):
        var waypoint := Vector2(path[path_index])+Vector2(0.5,0.5)
        travelled += previous.distance_to(waypoint)
        previous = waypoint
        destination = waypoint
        if travelled >= desired_progress:
            break
    if destination.distance_to(origin) < 0.1 or not battle._position_allowed(destination):
        return false
    actor["move_order_position"] = destination
    actor["move_order_active"] = true
    actor["v63_evasion_until"] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.get("duration",1.0)))
    ready[id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cooldown))
    actor["v63_skill_ready"] = ready
    actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
    battle._event("v63_mobility",{"actor_id":str(actor.id),"skill_id":id,"position":destination,
        "route_distance":route_distance,"world_path":true,"evasion_until":float(actor.v63_evasion_until)})
    battle.actions += 1
    return true

static func _begin_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary, id: String, skill: Dictionary, ready: Dictionary) -> void:
    var stats := effective_attack_stats(actor,actor.get("stats",{}))
    var cast_rate := maxf(0.1,1.0+float(stats.get("cast_speed",0.0)))
    var cooldown_rate := maxf(0.1,1.0+float(stats.get("cooldown_recovery",0.0)))
    var distance := (actor["position"] as Vector2).distance_to(target["position"])
    var speed := float(skill.get("projectile_speed",0.0))
    var deadline := battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cast_time)/cast_rate)+(distance/speed if speed > 0.0 else 0.0)
    actor["v63_cast_sequence"] = int(actor.get("v63_cast_sequence", 0)) + 1
    var cast := _cast_record(actor,target,id,skill,deadline)
    cast["mastery_event_id"] = "%s/%s/%d" % [battle.encounter_id,str(actor.id),int(actor.v63_cast_sequence)]
    if str(skill.get("shape","")) == "circle":
        cast["center"] = target["position"]
    elif str(skill.get("shape", "")) == "line":
        cast["line_origin"] = actor["position"]
        cast["line_direction"] = ((target["position"] as Vector2) - (actor["position"] as Vector2)).normalized()
    actor["v63_pending_cast"] = cast
    ready[id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cooldown)/cooldown_rate)
    actor["v63_skill_ready"] = ready
    actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
    battle._event("skill_cast",{"actor_id":str(actor.id),"target":str(target.id),"skill_id":id,"generation":str(skill.get("generation",skill.get("tier","human"))),"lineage":str(skill.get("lineage","")),"release_at":deadline,"cooldown_ready_at":float(ready[id]),"combat_family":"v63_human","effect":str(skill.effect)})
    battle.actions += 1

static func _try_boss_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary) -> bool:
    var boss_id := str(actor.get("v63_boss_id",""))
    var boss := boss_definition(boss_id)
    if str(boss.get("tier_band", "")) == "divine":
        return V63DivineSkillCombatSystem.try_boss_cast(battle, actor, target)
    if str(boss.get("tier_band", "")) == "immortal":
        return V63ImmortalSkillCombatSystem.try_boss_cast(battle, actor, target)
    var definitions := boss_skill_definitions(boss_id)
    var ready: Dictionary = actor.get("v63_skill_ready",{})
    var phase := clampi(int(actor.get("v63_boss_phase",1)),1,3)
    for raw_id in boss.get("skill_ids",[]):
        var id := str(raw_id)
        var skill: Dictionary = definitions.get(id,{})
        if skill.is_empty() or phase < int(skill.minimum_phase) or battle.now < float(ready.get(id,0.0)):
            continue
        var cast_target: Dictionary = actor if str(skill.effect) == "guard" else target
        if (actor["position"] as Vector2).distance_to(cast_target["position"]) > float(skill.range):
            continue
        var deadline := battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cast_time))
        var cast := _cast_record(actor,cast_target,id,skill,deadline,boss_id)
        if str(skill.shape) == "circle":
            cast["center"] = cast_target["position"]
        actor["v63_pending_cast"] = cast
        ready[id] = battle.now+maxf(MapBattleV2.STEP_SECONDS,float(skill.cooldown))
        actor["v63_skill_ready"] = ready
        actor["next_skill"] = battle.now+MapBattleV2.STEP_SECONDS
        battle._event("telegraph",{"caster":str(actor.id),"boss_id":boss_id,"skill":id,"skill_id":id,"center":cast_target["position"],"radius":float(skill.radius),"release_at":deadline,"phase":phase})
        battle.actions += 1
        return true
    return false

static func _cast_record(caster: Dictionary, target: Dictionary, id: String, skill: Dictionary, deadline: float, boss_id: String = "") -> Dictionary:
    var root_factor := V63SpiritualRootEvaluator.attached_skill_effect_factor(caster, id)
    var effect := str(skill.get("effect", "damage"))
    var ratio := float(skill.get("damage_ratio", 0.0)) * root_factor
    var power := float(skill.get("power", 0.0))
    if effect in ["poison", "heal", "guard", "mark"]:
        power *= root_factor
    var cast := {"caster":str(caster.id),"target_id":str(target.id),"v63_skill_id":id,"ready":deadline,
        "ratio":ratio,"element":str(skill.element),"effect":effect,"shape":str(skill.shape),
        "power":power,"duration":float(skill.get("duration",0.0)),
        "poison_stacks":int(skill.get("poison_stacks",1)),"radius":float(skill.get("radius",0.0)),
        "range":float(skill.get("range",0.0)),"maximum":mini(int(skill.get("target_limit",1)),MAX_TARGETS),
        "hit_count":clampi(int(skill.get("hit_count",1)),1,3),"guard_target_policy":str(skill.get("guard_target_policy","self")),
        "guard_mode":str(skill.get("guard_mode","mitigation")),"guard_capacity_ratio":clampf(float(skill.get("guard_capacity_ratio",0.0)),0.0,0.8)}
    if not boss_id.is_empty():
        cast["v63_boss_id"] = boss_id
    return cast

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var skill_id := str(cast.get("v63_skill_id", ""))
    if V63SwordSkillCombatSystem.is_sword_skill(skill_id):
        V63SwordSkillCombatSystem.release_cast(battle,cast,caster)
        return
    if V63BladeSkillCombatSystem.is_blade_skill(skill_id):
        V63BladeSkillCombatSystem.release_cast(battle,cast,caster)
        return
    if V63SpearSkillCombatSystem.is_spear_skill(skill_id):
        V63SpearSkillCombatSystem.release_cast(battle,cast,caster)
        return
    if V63DivineSkillCombatSystem.is_divine_skill(skill_id) or V63DivineSkillCombatSystem.is_divine_boss(str(cast.get("v63_boss_id", ""))):
        V63DivineSkillCombatSystem.release_cast(battle, cast, caster)
        return
    if V63ImmortalSkillCombatSystem.is_immortal_skill(skill_id):
        V63ImmortalSkillCombatSystem.release_cast(battle, cast, caster)
        return
    release_cast_base(battle, cast, caster)

static func release_cast_base(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    var id := str(cast.get("v63_skill_id",""))
    var boss_id := str(cast.get("v63_boss_id",""))
    var definition: Dictionary = boss_skill_definitions(boss_id).get(id,{}) if not boss_id.is_empty() else skill_definition(id)
    if definition.is_empty():
        return
    var effect := str(cast.get("effect",definition.get("effect","damage")))
    var generation := str(definition.get("generation",definition.get("tier","human")))
    var lineage := str(definition.get("lineage",""))
    var meaningful := false
    for target in _cast_targets(battle,caster,cast,effect):
        var caster_position: Vector2 = caster.get("position",Vector2.ZERO)
        var target_position: Vector2 = target.get("position",Vector2.ZERO)
        if not battle.is_world_position_allowed(caster_position) or not battle.is_world_position_allowed(target_position):
            battle._event("skill_miss",{"caster":str(caster.get("id","")),"target":str(target.get("id","")),"skill_id":id,"generation":generation,"lineage":lineage,"reason":"invalid_position"})
            continue
        if str(cast.get("shape",definition.get("shape",""))) == "single_target" and caster_position.distance_to(target_position) > float(definition.get("range",0.0)):
            battle._event("skill_miss",{"caster":str(caster.get("id","")),"target":str(target.get("id","")),"skill_id":id,"generation":generation,"lineage":lineage,"reason":"target_out_of_range_at_release"})
            continue
        var before := float(target.hp)
        var caster_before := float(caster.hp)
        var damage := 0.0
        if effect in ["damage","poison","mark","consume_poison"]:
            var ratio := float(cast.ratio)
            if effect == "consume_poison":
                var owned_stacks: Array = target.get("status_effects", {}).get("v63_poison", [])
                if str(definition.get("school", "")) == "poison":
                    ratio += V63PoisonEvolutionV1.consume_bonus_ratio(owned_stacks, str(caster.id), battle.now)
                else:
                    var owned := 0
                    for stack in owned_stacks:
                        if str(stack.get("owner_id", "")) == str(caster.id):
                            owned += 1
                    ratio += minf(0.75, float(owned) * 0.05)
            var mark_bonus := 0.0
            var counter_bonus := 0.0
            if str(definition.get("school", "")) == "poison":
                mark_bonus = V63PoisonEvolutionV1.peek_mark_bonus(caster, target, battle.now)
                counter_bonus = V63PoisonEvolutionV1.peek_cleanse_counter(caster, battle.now)
            var blade_hit_count := clampi(int(definition.get("hit_count",cast.get("hit_count",1))),1,3) if str(definition.get("school","")) == "blade" and effect == "damage" else 1
            for blade_hit_index in range(blade_hit_count):
                if float(target.get("hp",0.0)) <= 0.0:
                    break
                var strike_ratio := ratio / float(blade_hit_count)
                var strike_damage := battle._deal_direct(caster,target,strike_ratio,"v63_skill",true,str(cast.element),true,id)
                damage += strike_damage
                if str(definition.get("school","")) == "blade" and blade_hit_count > 1 and strike_damage > 0.0:
                    battle._event("v63_blade_swing_hit",{"caster":str(caster.id),"target":str(target.id),"skill_id":id,
                        "hit_index":blade_hit_index+1,"hit_count":blade_hit_count,"damage":strike_damage})
            if damage > 0.0 and float(target.get("hp", 0.0)) > 0.0 \
                    and str(definition.get("school", "")) == "poison":
                if mark_bonus > 0.0:
                    V63PoisonEvolutionV1.commit_mark_bonus(caster, battle.now)
                    _consume_mark(battle, caster, target, id)
                    # Separate proc: not crit-eligible, not lifesteal-eligible,
                    # and already consumed the mark to avoid double amplification.
                    var proc_mark := battle._deal_direct(caster,target,mark_bonus,
                        "v63_skill",false,str(cast.element),false)
                    battle._event("poison_mark_punish", {"caster":str(caster.id),"target":str(target.id),
                        "skill_id":id,"bonus_ratio":mark_bonus,"actual_damage":proc_mark,"icd":8.0})
                if counter_bonus > 0.0 and float(target.get("hp", 0.0)) > 0.0:
                    V63PoisonEvolutionV1.commit_cleanse_counter(caster, battle.now)
                    var proc_counter := battle._deal_direct(caster,target,counter_bonus,
                        "v63_skill",false,str(cast.element),false)
                    battle._event("poison_cleanse_counter", {"caster":str(caster.id),"target":str(target.id),
                        "skill_id":id,"bonus_ratio":counter_bonus,"actual_damage":proc_counter,"icd":12.0})
        if effect == "poison":
            if damage > 0.0 or str(definition.get("school", "")) != "poison":
                _apply_poison(battle,caster,target,id,float(cast.power),float(cast.duration),int(cast.poison_stacks),str(cast.element))
                if damage > 0.0 and str(definition.get("school", "")) == "poison":
                    V63PoisonEvolutionV1.spread_one(battle,caster,target,id,float(cast.power),
                        float(cast.duration),str(cast.element))
        elif effect == "guard":
            var guard_until := battle.now+clampf(float(cast.duration),0.5,12.0)
            if str(cast.get("guard_mode",definition.get("guard_mode","mitigation"))) == "capacity_shield":
                var capacity := maxf(0.0,float(target.get("max_hp",0.0))*clampf(float(cast.get("guard_capacity_ratio",definition.get("guard_capacity_ratio",0.0))),0.0,0.8))
                if capacity > 0.0:
                    target["v63_capacity_shield_remaining"] = maxf(float(target.get("v63_capacity_shield_remaining",0.0)),capacity)
                    target["v63_capacity_shield_until"] = maxf(float(target.get("v63_capacity_shield_until",-1.0)),guard_until)
                    target["v63_capacity_shield_skill_id"] = id
                    battle._event("status_applied",{"caster":str(caster.id),"target":str(target.id),"status":"capacity_shield","skill_id":id,"generation":generation,"lineage":lineage,"until":float(target.v63_capacity_shield_until),"capacity":float(target.v63_capacity_shield_remaining)})
            else:
                target["learned_guard_factor"] = minf(float(target.get("learned_guard_factor",1.0)),1.0-clampf(float(cast.power),0.05,0.8))
                target["learned_guard_until"] = maxf(float(target.get("learned_guard_until",-1.0)),guard_until)
                battle._event("status_applied",{"caster":str(caster.id),"target":str(target.id),"status":"guard","skill_id":id,"generation":generation,"lineage":lineage,"until":float(target.learned_guard_until)})
        elif effect == "heal":
            _heal_target(battle,caster,target,id,float(cast.power))
        elif effect == "cleanse":
            var cleared := _cleanse_target(battle,caster,target,id,int(round(float(cast.power))))
            if str(definition.get("school", "")) == "poison":
                V63PoisonEvolutionV1.arm_cleanse_counter(caster, cleared, battle.now)
                if cleared > 0 and V63PoisonEvolutionV1.rule_for_actor(caster) == "cleanse_heal_fatal_save":
                    _heal_target(battle,caster,target,id,0.03)
        elif effect == "mark":
            var mark_school := str(definition.get("school",""))
            if damage > 0.0 and mark_school in ["blade","poison"]:
                _apply_mark(battle,caster,target,id,float(cast.power),float(cast.duration))
            elif mark_school != "blade" and mark_school != "poison":
                _apply_mark(battle,caster,target,id,float(cast.power),float(cast.duration))
        elif effect == "consume_poison":
            if damage > 0.0 or str(definition.get("school", "")) != "poison":
                _consume_poison(battle,caster,target,id)
        if damage > 0.0 and effect in ["damage", "consume_poison"] and str(definition.get("combat_trait", "")) == "co_doc_b":
            _consume_mark(battle,caster,target,id)
        if damage > 0.0 and str(definition.get("school", "")) == "spear" and str(definition.get("shape", "")) == "line":
            battle._event("v63_spear_line_hit",{"caster":str(caster.id),"target":str(target.id),"skill_id":id,"damage":damage,"target_limit":int(definition.get("target_limit",1))})
        var poison_school := str(definition.get("school", "")) == "poison"
        meaningful = meaningful or damage > 0.0 or effect in ["guard", "cleanse"] \
            or (not poison_school and str(definition.get("school","")) != "blade" and effect in ["mark", "poison"]) or float(target.hp) > before
        battle._event("v63_skill_hit",{"caster":str(caster.id),"target":str(target.id),"skill_id":id,"generation":generation,"lineage":lineage,"effect":effect,"damage":damage,"caster_hp_before":caster_before,"caster_hp_after":float(caster.hp),"target_hp_before":before,"target_hp_after":float(target.hp)})
        if effect == "mark" and str(definition.get("branch", "")) == "huyet_quyen" and float(target.hp) > 0.0:
            record_blood_mark(battle, caster, target, id)
        if damage > 0.0:
            V63ImmortalSkillCombatSystem.apply_elemental_reaction(battle,caster,target,id,str(cast.get("element", "")))
            V63DivineSkillCombatSystem.apply_elemental_reaction(battle,caster,target,id,str(cast.get("element", "")))

    if meaningful:
        record_cast_mastery(caster, id, str(cast.get("mastery_event_id", "")))

static func record_cast_mastery(caster: Dictionary, skill_id: String, event_id: String) -> bool:
    var disciple = caster.get("linked_disciple", null)
    if event_id.is_empty() or event_id.length() > 512:
        return false
    # Real PvE deliberately detaches character pointers from combat actors.
    # Queue the authored cast receipt in the durable battle snapshot rather
    # than silently dropping mastery or mutating the character during combat.
    if not (disciple is DiscipleState):
        return V63PveMasteryReceipts.queue_cast(caster, skill_id, event_id)
    if not disciple.v63_learned_skill_nodes.has(skill_id):
        return false
    var record: Dictionary = disciple.v63_learned_skill_nodes[skill_id].duplicate(true)
    var receipts: Dictionary = record.get("mastery_cast_receipts", {})
    if receipts.has(event_id) or receipts.size() >= 4096:
        return false
    receipts[event_id] = true
    record["mastery_cast_receipts"] = receipts
    var mastery_multiplier := V63SpiritualRootEvaluator.attached_skill_mastery_factor(caster, skill_id)
    record["mastery_xp"] = minf(1000000.0,
        float(record.get("mastery_xp", 0.0)) + mastery_multiplier)
    var maximum := 12 if str(skill_definition(skill_id).get("generation", "human")) == "human" else 3
    record["level"] = mini(maximum, 1 + int(float(record.mastery_xp) / 100.0))
    disciple.v63_learned_skill_nodes[skill_id] = record
    return true

static func _cast_targets(battle: MapBattleV2, caster: Dictionary, cast: Dictionary, effect: String) -> Array:
    var result: Array = []
    var allies := effect in ["guard","heal","cleanse"]
    if str(cast.get("shape","")) == "circle":
        var center: Vector2 = cast.get("center",caster.get("position",Vector2.ZERO))
        var ids: Array = battle.actors.keys()
        ids.sort()
        for raw_id in ids:
            var target: Dictionary = battle.actors[raw_id]
            var same_side := str(target.get("side","")) == str(caster.get("side",""))
            if float(target.get("hp",0.0)) <= 0.0 or same_side != allies \
                    or (allies and not _same_p0_support_party(caster,target)):
                continue
            if (target.position as Vector2).distance_to(center) <= float(cast.get("radius",0.0)):
                result.append(target)
                if result.size() >= mini(int(cast.get("maximum",MAX_TARGETS)),MAX_TARGETS):
                    break
        return result
    if str(cast.get("shape", "")) == "line":
        var origin: Vector2 = cast.get("line_origin", caster.get("position", Vector2.ZERO))
        var direction: Vector2 = cast.get("line_direction", Vector2.ZERO).normalized()
        var length := maxf(0.0, float(cast.get("radius", 0.0)))
        if BOW_LINE_RANGE_SKILL_IDS.has(str(cast.get("v63_skill_id", ""))):
            length = maxf(length, float(cast.get("range", length)))
        var ids: Array = battle.actors.keys()
        ids.sort()
        for raw_id in ids:
            var candidate: Dictionary = battle.actors[raw_id]
            var same_side := str(candidate.get("side", "")) == str(caster.get("side", ""))
            if float(candidate.get("hp", 0.0)) <= 0.0 or same_side != allies \
                    or (allies and not _same_p0_support_party(caster,candidate)):
                continue
            var offset: Vector2 = candidate["position"] - origin
            var along := offset.dot(direction)
            var across := absf(offset.cross(direction))
            if along >= 0.0 and along <= length and across <= 0.85:
                result.append(candidate)
                if result.size() >= mini(int(cast.get("maximum", MAX_TARGETS)), MAX_TARGETS):
                    break
        return result
    var target: Dictionary = battle.actors.get(str(cast.get("target_id","")),{})
    if not target.is_empty() and float(target.get("hp",0.0)) > 0.0:
        var same_side := str(target.get("side","")) == str(caster.get("side",""))
        if same_side == allies and (not allies or _same_p0_support_party(caster,target)):
            result.append(target)
    return result

static func _heal_target(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String, power: float) -> void:
    var factor := effective_heal_factor(caster)
    var before := float(target.hp)
    var amount := minf(maxf(0.0,float(target.max_hp)*clampf(power,0.0,0.5)*factor),maxf(0.0,float(target.max_hp)-before))
    var adjusted_amount := amount
    if str(target.get("v63_combat_generation", "")) == "immortal":
        adjusted_amount = V63ImmortalSkillCombatSystem.healing_amount(caster, target, amount)
    else:
        adjusted_amount = V63DivineSkillCombatSystem.healing_amount(caster, target, amount)
    amount = minf(adjusted_amount, maxf(0.0, float(target.max_hp) - before))
    if str(skill_definition(skill_id).get("school", "")) == "poison":
        amount = V63PoisonEvolutionV1.heal_allowed(target, amount, battle.now)
    target["hp"] = before+amount
    battle._sync_linked_hp(target)
    battle._event("heal",{"caster":str(caster.id),"target":str(target.id),"skill_id":skill_id,"amount":amount,"hp_after":float(target.hp)})

static func _cleanse_target(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String, count: int) -> int:
    var statuses: Dictionary = target.get("status_effects",{})
    var poison: Array = statuses.get("v63_poison",[])
    var removed := mini(poison.size(),maxi(1,count))
    for _i in range(removed):
        poison.pop_front()
    if poison.is_empty():
        statuses.erase("v63_poison")
    else:
        statuses["v63_poison"] = poison
    var cleared: Array[String] = []
    # Strict global cleanse budget applies to Poison only; bow/fist keep their
    # existing contract until independently reviewed.
    var poison_school := str(skill_definition(skill_id).get("school", "")) == "poison"
    var remaining := maxi(0, maxi(1,count) - removed) if poison_school else maxi(1,count)
    for status_id in ["burn","weaken"]:
        if statuses.has(status_id) and cleared.size() < remaining:
            statuses.erase(status_id)
            cleared.append(status_id)
    target["status_effects"] = statuses
    var removed_debuff_count := removed + cleared.size()
    battle._event("cleanse",{"caster":str(caster.id),"target":str(target.id),"skill_id":skill_id,"poison_stacks":removed,"statuses":cleared,"removed_debuff_count":removed_debuff_count})
    return removed_debuff_count

static func _apply_mark(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String, power: float, duration: float) -> void:
    var marks: Dictionary = target.get("v63_marks",{})
    var definition := skill_definition(skill_id)
    var mark_school := str(definition.get("school",""))
    var maximum_factor := 1.15 if mark_school == "blade" else 1.5
    marks[str(caster.id)] = {"owner_id":str(caster.id),"skill_id":skill_id,"school":mark_school,
        "damage_factor":clampf(power,1.0,maximum_factor),"until":battle.now+clampf(duration,0.5,12.0)}
    target["v63_marks"] = marks
    battle._event("status_applied",{"caster":str(caster.id),"target":str(target.id),"status":"mark","skill_id":skill_id,"until":float(marks[str(caster.id)].until)})

static func record_blood_mark(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String) -> void:
    var definition := skill_definition(skill_id)
    if definition.is_empty() or str(definition.get("branch", "")) != "huyet_quyen" or str(definition.get("effect", "")) != "mark":
        return
    var generation := str(definition.get("generation", definition.get("tier", "human")))
    if generation in ["immortal", "divine"] and str(definition.get("lineage", "")) != "a":
        return
    var marks: Dictionary = target.get("v63_blood_marks", {})
    for key in marks.keys():
        if battle.now >= float(marks[key]):
            marks.erase(key)
    marks[str(caster.id) + "/" + skill_id] = battle.now + 10.0
    target["v63_blood_marks"] = marks
    if marks.size() >= 2 and battle.now >= float(caster.get("v63_blood_frenzy_ready", -1.0)):
        caster["v63_blood_frenzy_until"] = battle.now + 5.0
        caster["v63_blood_frenzy_ready"] = battle.now + 35.0
        battle._event("blood_frenzy", {"caster":str(caster.id),"skill_id":skill_id,"generation":generation,"lineage":str(definition.get("lineage", "")),"until":battle.now+5.0,"family_icd":35.0})

static func _consume_mark(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String) -> int:
    var marks: Dictionary = target.get("v63_marks", {})
    var owner_id := str(caster.id)
    var mark: Dictionary = marks.get(owner_id, {})
    if mark.is_empty() or battle.now >= float(mark.get("until", -1.0)):
        return 0
    marks.erase(owner_id)
    if marks.is_empty():
        target.erase("v63_marks")
    else:
        target["v63_marks"] = marks
    battle._event("mark_consumed",{"caster":owner_id,"target":str(target.id),"skill_id":skill_id,"source_skill_id":str(mark.get("skill_id", "")),"stacks":1})
    return 1

static func _apply_poison(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String, ratio: float, duration: float, requested: int, element: String) -> void:
    var statuses: Dictionary = target.get("status_effects",{})
    var stacks: Array = statuses.get("v63_poison",[])
    var owner := str(caster.id)
    var owner_count := 0
    for stack in stacks:
        if str(stack.get("owner_id","")) == owner:
            owner_count += 1
    var boss_source := bool(caster.get("v63_custom_boss_ai",false))
    var owner_cap := POISON_OWNER_CAP
    var add_count := mini(maxi(0,owner_cap-owner_count),maxi(0,POISON_BOSS_TARGET_CAP-stacks.size()))
    add_count = mini(add_count,maxi(1,requested))
    var snapshot := effective_attack_stats(caster,caster.get("stats",{}))
    var poison_factor := effective_poison_factor(caster)
    var ordinals: Dictionary = target.get("v63_poison_ordinals", {})
    var previous_ordinal := int(ordinals.get(owner, 0))
    ordinals[owner] = previous_ordinal + add_count
    target["v63_poison_ordinals"] = ordinals
    for _i in range(add_count):
        stacks.append({"owner_id":owner,"source_skill_id":skill_id,"source_skill_generation_id":skill_id,"stack_ordinal":previous_ordinal+_i+1,"attack_snapshot":snapshot.duplicate(true),
            "ratio":clampf(ratio*poison_factor,0.0,0.2),"element":element,"applied_at":battle.now,
            "next_tick":battle.now+POISON_TICK_INTERVAL_SECONDS,"expires_at":battle.now+clampf(duration,1.0,10.0)})
    statuses["v63_poison"] = stacks
    target["status_effects"] = statuses
    if add_count == 0 and owner_count >= owner_cap and \
            V63PoisonEvolutionV1.rule_for_actor(caster) == "owned_poison_maintain":
        if V63PoisonEvolutionV1.refresh_oldest_owned_poison(target, owner, duration, battle.now):
            battle._event("poison_owned_refresh", {"caster":owner,"target":str(target.id),
                "skill_id":skill_id,"stack_count":owner_count})
    battle._event("status_applied",{"caster":owner,"target":str(target.id),"status":"poison","skill_id":skill_id,
        "added":add_count,"owner_stack_count":owner_count+add_count,"target_stack_count":stacks.size(),
        "owner_cap":owner_cap,"target_cap":POISON_BOSS_TARGET_CAP})

static func _consume_poison(battle: MapBattleV2, caster: Dictionary, target: Dictionary, skill_id: String) -> void:
    var statuses: Dictionary = target.get("status_effects",{})
    var stacks: Array = statuses.get("v63_poison",[])
    var retained: Array = []
    var count := 0
    for stack in stacks:
        if str(stack.get("owner_id","")) == str(caster.id):
            count += 1
        else:
            retained.append(stack)
    if retained.is_empty():
        statuses.erase("v63_poison")
    else:
        statuses["v63_poison"] = retained
    target["status_effects"] = statuses
    battle._event("poison_consumed",{"caster":str(caster.id),"target":str(target.id),"skill_id":skill_id,"stacks":count})

static func process_status_effects(battle: MapBattleV2) -> void:
    if battle == null:
        return
    var ids: Array = battle.actors.keys()
    ids.sort()
    for raw_id in ids:
        var target: Dictionary = battle.actors[raw_id]
        if float(target.get("hp",0.0)) <= 0.0:
            continue
        var statuses: Dictionary = target.get("status_effects",{})
        var stacks: Array = statuses.get("v63_poison",[])
        if not stacks.is_empty():
            var kept: Array = []
            var valid_count := 0
            for candidate in stacks:
                var source: Dictionary = battle.actors.get(str(candidate.get("owner_id", "")), {})
                if not source.is_empty() and float(source.get("hp", 0.0)) > 0.0 and battle.now < float(candidate.get("expires_at", -1.0)):
                    valid_count += 1
            var effective_count := float(mini(valid_count, 12)) + float(clampi(valid_count - 12, 0, 12)) * 0.5 + float(maxi(0, valid_count - 24)) * 0.25
            var fair_factor := effective_count / maxf(1.0, float(valid_count))
            var ordinal := 0
            for value in stacks:
                if not (value is Dictionary):
                    continue
                var stack: Dictionary = value
                var owner: Dictionary = battle.actors.get(str(stack.get("owner_id","")),{})
                if owner.is_empty() or float(owner.get("hp",0.0)) <= 0.0 or str(owner.side) == str(target.side) or battle.now >= float(stack.get("expires_at",-1.0)):
                    continue
                kept.append(stack)
                if float(stack.get("next_tick",INF)) <= battle.now+0.000001:
                    var factor := fair_factor
                    var proxy: Dictionary = owner.duplicate(true)
                    proxy["stats"] = stack.get("attack_snapshot",{}).duplicate(true)
                    proxy["hp"] = 1.0
                    proxy["max_hp"] = 1.0
                    proxy["context_sources"] = []
                    proxy["v63_combat_enabled"] = false
                    var event_start := battle.events.size()
                    var kill_start := battle._pending_kill_events.size()
                    var hp_before := float(target.get("hp", 0.0))
                    var damage := battle._deal_direct(proxy,target,float(stack.get("ratio",0.0))*factor,"v63_poison",false,str(stack.get("element","nether")),false)
                    _attribute_poison_tick(battle,target,owner,stack,event_start,kill_start)
                    battle._event("status_tick",{"caster":str(owner.id),"target":str(target.id),"status":"poison","damage":damage,
                        "source_skill_id":str(stack.get("source_skill_id","")),"source_skill_generation_id":str(stack.get("source_skill_generation_id", "")),
                        "owner_id":str(owner.id),"stack_ordinal":int(stack.get("stack_ordinal", ordinal+1)),"diminishing_factor":factor,
                        "target_hp_before":hp_before,"target_hp_after":float(target.get("hp", 0.0))})
                    stack["next_tick"] = float(stack.get("next_tick",battle.now))+POISON_TICK_INTERVAL_SECONDS
                ordinal += 1
            if kept.is_empty():
                statuses.erase("v63_poison")
            else:
                statuses["v63_poison"] = kept
        target["status_effects"] = statuses
        var marks: Dictionary = target.get("v63_marks",{})
        for owner_id in marks.keys():
            if battle.now >= float(marks[owner_id].get("until",-1.0)):
                marks.erase(owner_id)
        target["v63_marks"] = marks

static func _attribute_poison_tick(battle: MapBattleV2, target: Dictionary, owner: Dictionary, stack: Dictionary, event_start: int, kill_start: int) -> void:
    var owner_id := str(owner.get("id", ""))
    var target_id := str(target.get("id", ""))
    var source_skill_id := str(stack.get("source_skill_id", ""))
    var source_generation_id := str(stack.get("source_skill_generation_id", ""))
    var stack_ordinal := int(stack.get("stack_ordinal", 0))
    var attribution := {"damage_source":"poison_dot","source_skill_id":source_skill_id,
        "source_skill_generation_id":source_generation_id,"poison_stack_ordinal":stack_ordinal}
    for event_index in range(event_start, battle.events.size()):
        var event: Dictionary = battle.events[event_index]
        var event_type := str(event.get("type", ""))
        if event_type == "hit" and str(event.get("attacker", "")) == owner_id and str(event.get("target", "")) == target_id and str(event.get("kind", "")) == "v63_poison":
            event.merge(attribution, true)
            battle.events[event_index] = event
        elif event_type == "downed" and str(event.get("actor_id", "")) == target_id:
            event.merge(attribution, true)
            event["killer_actor_id"] = owner_id
            battle.events[event_index] = event
    for kill_index in range(kill_start, battle._pending_kill_events.size()):
        var kill: Dictionary = battle._pending_kill_events[kill_index]
        if str(kill.get("monster_instance_id", "")) == target_id and str(kill.get("killer_actor_id", "")) == owner_id and str(kill.get("damage_kind", "")) == "v63_poison":
            kill.merge(attribution, true)
            battle._pending_kill_events[kill_index] = kill

static func observe_boss_damage(battle: MapBattleV2, actor: Dictionary, hp_before: float,
        attacker: Dictionary = {}, element: String = "", kind: String = "") -> void:
    if battle == null or not bool(actor.get("v63_custom_boss_ai",false)) or not bool(actor.get("v63_combat_enabled",false)):
        return
    if V63DivineSkillCombatSystem.is_divine_boss(str(actor.get("v63_boss_id", ""))):
        V63DivineSkillCombatSystem.observe_boss_damage(battle, actor, hp_before, attacker, element, kind)
        return
    if V63ImmortalSkillCombatSystem.is_immortal_boss(str(actor.get("v63_boss_id", ""))):
        V63ImmortalSkillCombatSystem.observe_boss_damage(battle, actor, hp_before, attacker, element, kind)
        return
    var boss := boss_definition(str(actor.get("v63_boss_id","")))
    var thresholds: Array = boss.get("phase_thresholds",[0.7,0.35])
    var hp_ratio := float(actor.hp)/maxf(1.0,float(actor.get("max_hp",1.0)))
    var phase := clampi(int(actor.get("v63_boss_phase",1)),1,3)
    while phase < 3 and hp_ratio <= float(thresholds[phase-1]):
        phase += 1
        actor["v63_boss_phase"] = phase
        battle._event("v63_boss_phase",{"boss_id":str(actor.v63_boss_id),"actor_id":str(actor.id),"phase":phase,
            "threshold":float(thresholds[phase-2]),"hp_before":hp_before,"hp_after":float(actor.hp),"hp_ratio":hp_ratio})

static func install_boss_spawn(spawn_data: Dictionary, boss_id: String) -> Dictionary:
    var boss := boss_definition(boss_id)
    var monsters = spawn_data.get("monsters",null)
    if boss.is_empty() or not bool(spawn_data.get("ok",false)) or not (monsters is Array) or monsters.is_empty():
        return _failure("unknown_boss_or_spawn")
    var region_id := str(spawn_data.get("region_id",""))
    var level := int(spawn_data.get("level",0))
    if not HuntingMapV2.valid_choice(region_id,level):
        return _failure("boss_spawn_map_identity_invalid")
    var region: Dictionary = HuntingMapV2.REGION_CONTENT[region_id]
    var row: Dictionary = monsters[0]
    var origin := MonsterCatalogueV2.create_actor(str(boss.origin_species_id),int(region.realm),int(region.floor),str(spawn_data.encounter_id)+"/v63_boss")
    if not bool(origin.get("ok",false)):
        return origin
    var spec: Dictionary = HuntingMapV2.LEVELS[level]
    var base: Dictionary = MonsterCatalogueV2.TIERS[str(origin.tier)]
    var boss_tier: Dictionary = MonsterCatalogueV2.TIERS["boss"]
    var stats: Dictionary = origin.stats.duplicate(true)
    for stat in ["max_hp","attack","defense"]:
        var key: String = "hp" if stat == "max_hp" else str(stat)
        stats[stat] = float(stats[stat])*float(spec[key])*float(boss_tier[stat])/maxf(0.001,float(base[stat]))*float(boss.get("boss_"+key+"_factor",1.0))
    origin["id"] = str(row.get("id",""))
    origin["encounter_id"] = str(spawn_data.encounter_id)+"/"+str(row.get("id",""))
    origin["position"] = row.get("position",Vector2(23,8))
    origin["region_id"] = region_id
    origin["difficulty_level"] = level
    origin["tier"] = "boss"
    origin["stats"] = stats
    origin["hp"] = float(stats.max_hp)
    origin["v63_boss_id"] = boss_id
    origin["v63_custom_boss_ai"] = true
    origin["v63_combat_enabled"] = true
    origin["v63_boss_phase"] = 1
    origin["v63_skill_ready"] = {}
    origin["v63_boss_counter_window"] = {}
    origin["v63_boss_break_gauge"] = 0
    origin["v63_boss_stagger_until"] = -1.0
    var result: Dictionary = spawn_data.duplicate(true)
    var updated: Array = monsters.duplicate(true)
    updated[0] = origin
    result["monsters"] = updated
    result["has_boss"] = true
    result["v63_boss_id"] = boss_id
    return {"ok":true,"spawn_data":result,"boss_actor":origin.duplicate(true)}

static func validate_battle(battle: MapBattleV2, expected_boss_id: String = "") -> Array[String]:
    var errors: Array[String] = []
    if battle == null:
        return ["missing_human_battle"]
    var observed_boss := ""
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        var loadout = actor.get("v63_skill_loadout",[])
        var ready = actor.get("v63_skill_ready",{})
        if not (loadout is Array) or not (ready is Dictionary):
            errors.append("invalid_v63_actor_action_state:"+str(raw_id))
            continue
        var boss_id := str(actor.get("v63_boss_id",""))
        var custom_boss := bool(actor.get("v63_custom_boss_ai",false))
        var valid_actions: Dictionary = {}
        if custom_boss:
            var boss := boss_definition(boss_id)
            if boss.is_empty() or not observed_boss.is_empty():
                errors.append("unknown_or_duplicate_v63_boss:"+boss_id)
            else:
                var species: Dictionary = MonsterCatalogueV2.SPECIES.get(str(boss.origin_species_id),{})
                if str(actor.get("race_id","")) != str(species.get("race_id","")) or str(actor.get("tier","")) != "boss":
                    errors.append("v63_boss_identity_mismatch:"+boss_id)
                for action_id in boss.skill_ids:
                    valid_actions[str(action_id)] = true
            observed_boss = boss_id
        elif not boss_id.is_empty():
            errors.append("v63_boss_marker_without_ai:"+str(raw_id))
        for raw_skill_id in loadout:
            var skill_id := str(raw_skill_id)
            if skill_definition(skill_id).is_empty() or valid_actions.has(skill_id):
                errors.append("unknown_or_duplicate_v63_actor_skill:"+skill_id)
            valid_actions[skill_id] = true
        var innate_id := str(actor.get("v63_innate_skill_id",""))
        if not innate_id.is_empty():
            var innate := skill_definition(innate_id)
            if innate.is_empty() or str(innate.slot) != "innate" or str(innate.branch) != str(actor.get("v63_combat_branch_id","")):
                errors.append("invalid_v63_derived_innate:"+innate_id)
        for ready_id in ready.keys():
            var value = ready[ready_id]
            if not valid_actions.has(str(ready_id)) or not (value is int or value is float) or is_nan(float(value)) or is_inf(float(value)) or float(value) < 0.0 or float(value) > battle.now+90.0:
                errors.append("invalid_v63_skill_cooldown:"+str(ready_id))
        var pending = actor.get("v63_pending_cast",{})
        if not (pending is Dictionary):
            errors.append("invalid_v63_pending_cast_record:"+str(raw_id))
        elif not pending.is_empty():
            var cast_id := str(pending.get("v63_skill_id",""))
            var cast_boss := str(pending.get("v63_boss_id",""))
            var definition: Dictionary = boss_skill_definitions(cast_boss).get(cast_id,{}) if not cast_boss.is_empty() else skill_definition(cast_id)
            var target: Dictionary = battle.actors.get(str(pending.get("target_id","")),{})
            var deadline = pending.get("ready",null)
            var effect := str(pending.get("effect",""))
            var same_side := str(target.get("side","")) == str(actor.get("side",""))
            var valid := not definition.is_empty() and valid_actions.has(cast_id)
            valid = valid and (cast_boss == boss_id if custom_boss else cast_boss.is_empty())
            if target.is_empty() or (same_side and effect not in ["guard","heal","cleanse"]) or not valid or not EFFECTS.has(effect):
                errors.append("invalid_v63_pending_cast:"+cast_id)
            if not (deadline is int or deadline is float) or is_nan(float(deadline)) or is_inf(float(deadline)) or float(deadline) < battle.now or float(deadline) > battle.now+90.0:
                errors.append("invalid_v63_pending_cast_deadline:"+cast_id)
            if float(pending.get("ratio",-1.0)) <= 0.0 or not CombatStatsV2.ELEMENTS.has(str(pending.get("element",""))):
                errors.append("invalid_v63_pending_cast_values:"+cast_id)
    if expected_boss_id.is_empty() and not observed_boss.is_empty():
        errors.append("unexpected_v63_boss")
    elif not expected_boss_id.is_empty() and observed_boss != expected_boss_id:
        errors.append("v63_boss_identity_mismatch")
    return errors

static func validate_state(state: SimulationState) -> Array[String]:
    if state == null:
        return ["missing_human_combat_state"]
    var errors: Array[String] = []
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        errors.append_array(loaded.get("errors",[]))
        return errors
    var definitions := skill_definitions()
    var branches := branch_definitions()
    for raw_disciple in state.disciples.values():
        var disciple: DiscipleState = raw_disciple
        var branch_id := str(disciple.v63_combat_branch_id)
        if not branch_id.is_empty() and not branches.has(branch_id):
            errors.append("%s has an unknown Human branch." % disciple.display_name)
        for raw_id in disciple.v63_learned_skill_nodes.keys():
            var id := str(raw_id)
            var record = disciple.v63_learned_skill_nodes[raw_id]
            var skill: Dictionary = definitions.get(id,{})
            if skill.is_empty() or not bool(skill.get("archivable",false)) or not (record is Dictionary) or str(record.get("source_codex_id","")) != str(skill.get("source_codex_id","")) or int(record.get("learned_tick",-1)) < 0 or float(record.get("mastery_xp",-1.0)) < 0.0:
                errors.append("%s has invalid Human skill knowledge %s." % [disciple.display_name,id])
        var seen: Dictionary = {}
        var seen_families: Dictionary = {}
        var equipped_immortal_lineages: Dictionary = {}
        var counts := {"basic":0,"active":0,"ultimate":0,"mobility":0,"passive":0}
        for raw_id in disciple.v63_equipped_skill_ids:
            var id := str(raw_id)
            var skill: Dictionary = definitions.get(id,{})
            var slot := str(skill.get("slot",""))
            var skill_branch := str(skill.get("branch",""))
            var family_id := str(skill.get("family_id", ""))
            if skill.is_empty() or not disciple.v63_learned_skill_nodes.has(id) or seen.has(id):
                errors.append("%s has an unlearned or duplicate Human skill." % disciple.display_name)
            elif not skill_branch.is_empty() and skill_branch != branch_id:
                errors.append("%s has a Human skill equipped from another branch." % disciple.display_name)
            else:
                seen[id] = true
                if not family_id.is_empty() and seen_families.has(family_id):
                    errors.append("%s has multiple active successors in skill family %s." % [disciple.display_name,family_id])
                elif not family_id.is_empty():
                    seen_families[family_id] = id
                if str(skill.get("generation", "")) in ["immortal", "divine"]:
                    var lineage := str(skill.get("lineage", ""))
                    if equipped_immortal_lineages.has(skill_branch) and str(equipped_immortal_lineages[skill_branch]) != lineage:
                        errors.append("%s has both A/B Immortal paths equipped in %s." % [disciple.display_name,skill_branch])
                    else:
                        equipped_immortal_lineages[skill_branch] = lineage
                if counts.has(slot):
                    counts[slot] += 1
        if disciple.v63_equipped_skill_ids.size() > MAX_SKILLS_PER_DISCIPLE or counts.active > 4 or counts.passive > 5 or counts.basic > 1 or counts.ultimate > 1 or counts.mobility > 1:
            errors.append("%s exceeds Human skill slot bounds." % disciple.display_name)
    return errors
