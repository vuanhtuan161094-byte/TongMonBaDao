class_name V63BladeSkillCombatSystem
extends RefCounted

# S2 additive Dao candidate runtime. The canonical manual is missing, so learning
# remains blocked and the feature gate stays OFF in persisted game state.
const CATALOGUE_PATH := "res://data/combat/v63_blade_combat_catalog.json"
const EXPECTED_SKILLS := 183
const EXPECTED_BRANCHES := 3
const EXPECTED_FAMILIES := 35
const MAX_GUARD_REFLECT_RATIO := 0.30
const VALID_EFFECTS := ["damage","mark","guard","mobility","passive","innate"]
const VALID_SHAPES := ["single_target","circle","line"]
const VALID_PASSIVE_MODIFIERS := ["outgoing_factor","crit_bonus","cast_speed_factor","cooldown_recovery_factor","attack_speed_factor","guard_factor","absorbed_reflect_ratio"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path,FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["blade_catalogue_unavailable"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["blade_catalogue_not_object"],"data":{}}
    var data: Dictionary = parsed
    var errors := validate_catalogue(data)
    if errors.is_empty() and path == CATALOGUE_PATH:
        _catalogue_cache = data.duplicate(true)
        _skill_cache.clear()
        for row in data.get("skills",[]):
            _skill_cache[str(row.get("id",""))] = row.duplicate(true)
    return {"ok":errors.is_empty(),"errors":errors,"data":data}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 1 or bool(data.get("enabled",true)) or str(data.get("release_gate","")) != "OFF":
        errors.append("blade_catalogue_must_remain_disabled")
    if int(data.get("branch_count",0)) != EXPECTED_BRANCHES or int(data.get("skill_count",0)) != EXPECTED_SKILLS:
        errors.append("blade_catalogue_count_metadata_mismatch")
    var branches: Variant = data.get("branches",null)
    var skills: Variant = data.get("skills",null)
    if not (branches is Array) or not (skills is Array):
        errors.append("blade_catalogue_arrays_missing")
        return errors
    if branches.size() != EXPECTED_BRANCHES or skills.size() != EXPECTED_SKILLS:
        errors.append("blade_catalogue_count_mismatch")
    var branch_ids: Dictionary = {}
    for raw_branch in branches:
        if not (raw_branch is Dictionary):
            errors.append("blade_branch_not_object")
            continue
        var branch: Dictionary = raw_branch
        var branch_id := str(branch.get("id",""))
        if branch_id not in ["cuong_dao","tram_phach_dao","tran_dao"] or branch_ids.has(branch_id):
            errors.append("blade_branch_id_invalid:"+branch_id)
        if str(branch.get("school","")) != "blade" or str(branch.get("element","")) != "metal":
            errors.append("blade_branch_identity_invalid:"+branch_id)
        if str(branch.get("story_vi","")).strip_edges().is_empty() or str(branch.get("signature_ultimate","")).strip_edges().is_empty():
            errors.append("blade_branch_story_or_ultimate_missing:"+branch_id)
        var lineages: Dictionary = branch.get("lineages",{})
        if str(lineages.get("a","")).is_empty() or str(lineages.get("b","")).is_empty():
            errors.append("blade_lineage_missing:"+branch_id)
        branch_ids[branch_id] = true
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var skill_by_id: Dictionary = {}
    var family_counts: Dictionary = {}
    var tier_counts := {"human":0,"immortal":0,"divine":0}
    for raw_skill in skills:
        if not (raw_skill is Dictionary):
            errors.append("blade_skill_not_object")
            continue
        var skill: Dictionary = raw_skill
        var id := str(skill.get("id",""))
        var family := str(skill.get("family_id",""))
        var school := str(skill.get("school",""))
        var branch := str(skill.get("branch",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var slot := str(skill.get("slot",""))
        if not id.begins_with("tmb.skill.blade.") or ids.has(id):
            errors.append("blade_skill_id_invalid_or_duplicate:"+id)
        if str(skill.get("name","")).strip_edges().is_empty() or names.has(str(skill.get("name",""))):
            errors.append("blade_skill_name_missing_or_duplicate:"+id)
        if school != "blade" or str(skill.get("element","")) != "metal" or family.is_empty():
            errors.append("blade_skill_identity_invalid:"+id)
        if not VALID_EFFECTS.has(str(skill.get("effect",""))) or slot not in ["basic","mobility","active","ultimate","passive","innate"]:
            errors.append("blade_skill_effect_or_slot_invalid:"+id)
        if tier not in ["human","immortal","divine"]:
            errors.append("blade_skill_tier_invalid:"+id)
        for numeric_field in ["damage_ratio","power","duration","range","cast_time","cooldown","projectile_speed","radius"]:
            if not skill.has(numeric_field):
                errors.append("blade_skill_runtime_field_missing:"+id+":"+numeric_field)
                continue
            var number := float(skill.get(numeric_field,0.0))
            if is_nan(number) or is_inf(number) or number < 0.0:
                errors.append("blade_skill_runtime_number_invalid:"+id+":"+numeric_field)
        if not (skill.get("passive_modifiers",{}) is Dictionary):
            errors.append("blade_skill_passive_modifiers_invalid:"+id)
        for modifier in skill.get("passive_modifiers",{}).keys():
            if not VALID_PASSIVE_MODIFIERS.has(str(modifier)):
                errors.append("blade_modifier_not_consumed_by_runtime:"+id+":"+str(modifier))
        var effect := str(skill.get("effect",""))
        if effect == "damage" and float(skill.get("damage_ratio",0.0)) <= 0.0:
            errors.append("blade_damage_without_ratio:"+id)
        if effect == "mark" and (float(skill.get("damage_ratio",0.0)) <= 0.0 or float(skill.get("power",0.0)) < 1.0 or float(skill.get("power",0.0)) > 1.15 or float(skill.get("duration",0.0)) <= 0.0 or float(skill.get("duration",0.0)) > 12.0):
            errors.append("blade_mark_out_of_runtime_bounds:"+id)
        if effect == "guard" and (float(skill.get("power",0.0)) <= 0.0 or float(skill.get("power",0.0)) > 0.8 or float(skill.get("duration",0.0)) <= 0.0 or float(skill.get("duration",0.0)) > 12.0):
            errors.append("blade_guard_without_bounded_effect:"+id)
        if effect in ["passive","innate"] and skill.get("passive_modifiers",{}).is_empty():
            errors.append("blade_passive_without_runtime_modifier:"+id)
        if not VALID_SHAPES.has(str(skill.get("shape",""))):
            errors.append("blade_skill_shape_invalid:"+id)
        var hit_count := int(skill.get("hit_count",1))
        if hit_count < 1 or hit_count > 3:
            errors.append("blade_hit_count_out_of_bounds:"+id)
        if str(skill.get("guard_target_policy","")) not in ["self","weakest_ally"]:
            errors.append("blade_guard_target_policy_invalid:"+id)
        if not str(skill.get("source_codex_id","")).is_empty() or bool(skill.get("archivable",true)):
            errors.append("blade_skill_source_must_remain_pending:"+id)
        if str(skill.get("candidate_status","")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(skill.get("balance_status","")) != "candidate_needs_qa":
            errors.append("blade_skill_gate_status_invalid:"+id)
        if int(skill.get("target_limit",0)) < 1 or int(skill.get("target_limit",0)) > 3:
            errors.append("blade_skill_numeric_bounds_invalid:"+id)
        if not branch.is_empty() and (branch not in ["cuong_dao","tram_phach_dao","tran_dao"]):
            errors.append("blade_skill_branch_missing:"+id)
        ids[id] = true
        names[str(skill.get("name",""))] = true
        skill_by_id[id] = skill
        family_counts[family] = int(family_counts.get(family,0))+1
        tier_counts[tier] = int(tier_counts.get(tier,0))+1
    var tier_order := {"human":0,"immortal":1,"divine":2}
    for raw_skill in skills:
        var skill: Dictionary = raw_skill
        var id := str(skill.get("id",""))
        var parent_id := str(skill.get("parent_skill_id",""))
        var replaces_id := str(skill.get("replaces_skill_id",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var family := str(skill.get("family_id",""))
        var rarity := str(skill.get("rarity",""))
        if tier == "human":
            if not parent_id.is_empty():
                errors.append("blade_human_node_has_parent:"+id)
        elif parent_id.is_empty() or not skill_by_id.has(parent_id):
            errors.append("blade_successor_parent_missing:"+id)
        else:
            var parent: Dictionary = skill_by_id[parent_id]
            if str(parent.get("family_id","")) != family:
                errors.append("blade_successor_cross_family:"+id)
            var parent_tier := str(parent.get("generation",parent.get("tier","")))
            if int(tier_order.get(parent_tier,99)) >= int(tier_order.get(tier,99)) and rarity != "rare_divine":
                errors.append("blade_successor_tier_order_invalid:"+id)
        if rarity == "rare_divine":
            if replaces_id != parent_id or parent_id.is_empty():
                errors.append("blade_rare_replacement_must_replace_parent:"+id)
        elif not replaces_id.is_empty():
            errors.append("blade_nonrare_replacement_must_not_replace:"+id)
    if ids.size() != EXPECTED_SKILLS or names.size() != EXPECTED_SKILLS or family_counts.size() != EXPECTED_FAMILIES:
        errors.append("blade_catalogue_unique_identity_counts_invalid")
    if tier_counts != {"human":35,"immortal":68,"divine":80}:
        errors.append("blade_tier_distribution_invalid:"+str(tier_counts))
    for branch_id in ["cuong_dao","tram_phach_dao","tran_dao"]:
        var count := 0
        for skill in skills:
            if str(skill.get("branch","")) == branch_id:
                count += 1
        if count != 59:
            errors.append("blade_branch_node_count_invalid:"+branch_id)
    return errors

static func branch_definitions() -> Dictionary:
    var result: Dictionary = {}
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        return result
    for row in loaded.data.get("branches",[]):
        result[str(row.get("id",""))] = row.duplicate(true)
    return result

static func skill_definition(skill_id: String) -> Dictionary:
    if _skill_cache.is_empty():
        load_catalogue()
    return _skill_cache.get(skill_id,{}).duplicate(true)

static func is_blade_skill(skill_id: String) -> bool:
    return skill_id.begins_with("tmb.skill.blade.")

static func can_learn(definition: Dictionary) -> Dictionary:
    if definition.is_empty() or str(definition.get("school","")) != "blade":
        return {"ok":false,"reason":"unknown_blade_skill"}
    return {"ok":false,"reason":"skill_source_pending"}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
    if not bool(actor.get("v63_blade_combat_enabled",false)):
        return false
    var definition := skill_definition(skill_id)
    return not definition.is_empty() and is_blade_skill(skill_id) and VALID_EFFECTS.has(str(definition.get("effect","")))

static func guard_reflection_profile(actor: Dictionary, now: float) -> Dictionary:
    if not bool(actor.get("v63_blade_combat_enabled",false)):
        return {"ratio":0.0,"skill_id":""}
    if now >= maxf(float(actor.get("learned_guard_until",-1.0)),float(actor.get("guard_until",-1.0))):
        return {"ratio":0.0,"skill_id":""}
    var ids: Array = actor.get("v63_passive_ids",[]).duplicate()
    var innate := str(actor.get("v63_innate_skill_id",""))
    if not innate.is_empty():
        ids.append(innate)
    var best_ratio := 0.0
    var best_id := ""
    for raw_id in ids:
        var skill_id := str(raw_id)
        var skill := skill_definition(skill_id)
        if str(skill.get("school","")) != "blade" or str(skill.get("branch","")) != "tran_dao":
            continue
        var modifiers: Dictionary = skill.get("passive_modifiers",{})
        var ratio := clampf(float(modifiers.get("absorbed_reflect_ratio",0.0)),0.0,MAX_GUARD_REFLECT_RATIO)
        if ratio > best_ratio:
            best_ratio = ratio
            best_id = skill_id
    return {"ratio":best_ratio,"skill_id":best_id}

static func reflect_absorbed(battle: MapBattleV2, defender: Dictionary, attacker: Dictionary, absorbed_damage: float, damage_element: String = "") -> float:
    if battle == null or defender.is_empty() or attacker.is_empty() or float(defender.get("hp",0.0)) <= 0.0 or float(attacker.get("hp",0.0)) <= 0.0:
        return 0.0
    if str(defender.get("side","")) == str(attacker.get("side","")) or absorbed_damage <= 0.0:
        return 0.0
    var profile := guard_reflection_profile(defender,battle.now)
    var ratio := float(profile.get("ratio",0.0))
    if ratio <= 0.0:
        return 0.0
    var attack := maxf(1.0,float(defender.get("stats",{}).get("attack",0.0)))
    var actual := battle._deal_direct(defender,attacker,absorbed_damage*ratio/attack,
        "v63_blade_absorbed_reflect",false,"metal" if damage_element.is_empty() else damage_element,false,"")
    if actual <= 0.0:
        return 0.0
    battle._event("v63_blade_guard_reflect",{
        "caster":str(defender.get("id","")),"target":str(attacker.get("id","")),
        "absorbed_damage":absorbed_damage,"candidate_reflect_ratio":ratio,
        "damage":actual,"skill_id":str(profile.get("skill_id",""))
    })
    return actual

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    # Candidate effects route through Combat V2's single shared resolver.
    V63HumanSkillCombatSystem.release_cast_base(battle,cast,caster)
