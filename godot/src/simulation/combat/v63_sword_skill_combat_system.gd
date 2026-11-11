class_name V63SwordSkillCombatSystem
extends RefCounted

# S1 additive candidate system. Canonical learning sources are absent, and the
# dedicated opt-in is deliberately not included in persisted preview overrides.
const CATALOGUE_PATH := "res://data/combat/v63_sword_combat_catalog.json"
const EXPECTED_SKILLS := 183
const EXPECTED_BRANCHES := 3
const EXPECTED_FAMILIES := 35
const MAX_GUARD_REFLECT_RATIO := 0.30
const VALID_EFFECTS := ["damage","guard","mobility","passive","innate"]
const VALID_SHAPES := ["single_target","circle","line"]
const VALID_PASSIVE_MODIFIERS := ["outgoing_factor","crit_bonus","cast_speed_factor","cooldown_recovery_factor","attack_speed_factor","guard_factor","absorbed_reflect_ratio"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
        return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
    var file := FileAccess.open(path,FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["sword_catalogue_unavailable"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["sword_catalogue_not_object"],"data":{}}
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
        errors.append("sword_catalogue_must_remain_disabled")
    if int(data.get("branch_count",0)) != EXPECTED_BRANCHES or int(data.get("skill_count",0)) != EXPECTED_SKILLS:
        errors.append("sword_catalogue_count_metadata_mismatch")
    var branches: Variant = data.get("branches",null)
    var skills: Variant = data.get("skills",null)
    if not (branches is Array) or not (skills is Array):
        errors.append("sword_catalogue_arrays_missing")
        return errors
    if branches.size() != EXPECTED_BRANCHES or skills.size() != EXPECTED_SKILLS:
        errors.append("sword_catalogue_count_mismatch")
    var branch_ids: Dictionary = {}
    for raw_branch in branches:
        if not (raw_branch is Dictionary):
            errors.append("sword_branch_not_object")
            continue
        var branch: Dictionary = raw_branch
        var branch_id := str(branch.get("id",""))
        if branch_id not in ["ngu_kiem","sat_kiem","ho_kiem"] or branch_ids.has(branch_id):
            errors.append("sword_branch_id_invalid:"+branch_id)
        if str(branch.get("school","")) != "sword" or str(branch.get("element","")) != "metal":
            errors.append("sword_branch_identity_invalid:"+branch_id)
        if str(branch.get("story_vi","")).strip_edges().is_empty() or str(branch.get("signature_ultimate","")).strip_edges().is_empty():
            errors.append("sword_branch_story_or_ultimate_missing:"+branch_id)
        var lineages: Dictionary = branch.get("lineages",{})
        if str(lineages.get("a","")).is_empty() or str(lineages.get("b","")).is_empty():
            errors.append("sword_lineage_missing:"+branch_id)
        branch_ids[branch_id] = true
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var skill_by_id: Dictionary = {}
    var family_counts: Dictionary = {}
    var tier_counts := {"human":0,"immortal":0,"divine":0}
    var lineage_counts: Dictionary = {}
    for raw_skill in skills:
        if not (raw_skill is Dictionary):
            errors.append("sword_skill_not_object")
            continue
        var skill: Dictionary = raw_skill
        var id := str(skill.get("id",""))
        var family := str(skill.get("family_id",""))
        var school := str(skill.get("school",""))
        var branch := str(skill.get("branch",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var slot := str(skill.get("slot",""))
        if not id.begins_with("tmb.skill.sword.") or ids.has(id):
            errors.append("sword_skill_id_invalid_or_duplicate:"+id)
        if str(skill.get("name","")).strip_edges().is_empty() or names.has(str(skill.get("name",""))):
            errors.append("sword_skill_name_missing_or_duplicate:"+id)
        if school != "sword" or str(skill.get("element","")) != "metal" or family.is_empty():
            errors.append("sword_skill_identity_invalid:"+id)
        if not VALID_EFFECTS.has(str(skill.get("effect",""))) or slot not in ["basic","mobility","active","ultimate","passive","innate"]:
            errors.append("sword_skill_effect_or_slot_invalid:"+id)
        if tier not in ["human","immortal","divine"]:
            errors.append("sword_skill_tier_invalid:"+id)
        var numeric_fields := ["damage_ratio","power","duration","range","cast_time","cooldown","projectile_speed","radius"]
        for numeric_field in numeric_fields:
            if not skill.has(numeric_field):
                errors.append("sword_skill_runtime_field_missing:"+id+":"+numeric_field)
                continue
            var number := float(skill.get(numeric_field,0.0))
            if is_nan(number) or is_inf(number) or number < 0.0:
                errors.append("sword_skill_runtime_number_invalid:"+id+":"+numeric_field)
        if not (skill.get("passive_modifiers",{}) is Dictionary):
            errors.append("sword_skill_passive_modifiers_invalid:"+id)
        if not VALID_SHAPES.has(str(skill.get("shape",""))):
            errors.append("sword_skill_shape_invalid:"+id)
        var passive_modifiers: Dictionary=skill.get("passive_modifiers",{})
        for modifier in passive_modifiers.keys():
            if not VALID_PASSIVE_MODIFIERS.has(str(modifier)):
                errors.append("sword_skill_passive_modifier_not_consumed_by_runtime:"+id+":"+str(modifier))
        var effect := str(skill.get("effect",""))
        if effect=="damage" and float(skill.get("damage_ratio",0.0))<=0.0:
            errors.append("sword_damage_node_without_damage:"+id)
        if effect=="guard" and (float(skill.get("power",0.0))<=0.0 or float(skill.get("duration",0.0))<=0.0):
            errors.append("sword_guard_node_without_bounded_effect:"+id)
        if effect=="mobility" and (float(skill.get("range",0.0))<=0.0 or float(skill.get("duration",0.0))<=0.0):
            errors.append("sword_mobility_node_without_route_window:"+id)
        if effect in ["passive","innate"] and passive_modifiers.is_empty():
            errors.append("sword_passive_node_without_runtime_modifier:"+id)
        if not str(skill.get("source_codex_id","")).is_empty() or bool(skill.get("archivable",true)):
            errors.append("sword_skill_source_must_remain_pending:"+id)
        if str(skill.get("candidate_status","")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(skill.get("balance_status","")) != "candidate_needs_qa":
            errors.append("sword_skill_gate_status_invalid:"+id)
        if float(skill.get("range",0.0)) < 0.0 or float(skill.get("cooldown",0.0)) < 0.0 or int(skill.get("target_limit",0)) < 1 or int(skill.get("target_limit",0)) > 3:
            errors.append("sword_skill_numeric_bounds_invalid:"+id)
        if not branch.is_empty() and not branch_ids.has(branch):
            errors.append("sword_skill_branch_missing:"+id)
        ids[id] = true
        names[str(skill.get("name",""))] = true
        skill_by_id[id] = skill
        family_counts[family] = int(family_counts.get(family,0))+1
        tier_counts[tier] = int(tier_counts.get(tier,0))+1
        var lineage_key := branch+":"+str(skill.get("family_slot",""))+":"+tier+":"+str(skill.get("lineage",""))
        lineage_counts[lineage_key] = int(lineage_counts.get(lineage_key,0))+1
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
                errors.append("sword_human_node_has_parent:"+id)
        elif parent_id.is_empty() or not skill_by_id.has(parent_id):
            errors.append("sword_successor_parent_missing:"+id)
        else:
            var parent: Dictionary = skill_by_id[parent_id]
            if str(parent.get("family_id","")) != family:
                errors.append("sword_successor_cross_family:"+id)
            var parent_tier := str(parent.get("generation",parent.get("tier","")))
            if int(tier_order.get(parent_tier,99)) >= int(tier_order.get(tier,99)) and rarity != "rare_divine":
                errors.append("sword_successor_tier_order_invalid:"+id)
        if rarity == "rare_divine":
            if replaces_id != parent_id or parent_id.is_empty():
                errors.append("sword_rare_replacement_must_replace_its_parent:"+id)
        elif not replaces_id.is_empty():
            errors.append("sword_nonrare_replacement_must_not_replace:"+id)
    if ids.size() != EXPECTED_SKILLS or names.size() != EXPECTED_SKILLS or family_counts.size() != EXPECTED_FAMILIES:
        errors.append("sword_catalogue_unique_identity_counts_invalid")
    if tier_counts != {"human":35,"immortal":68,"divine":80}:
        errors.append("sword_tier_distribution_invalid:"+str(tier_counts))
    for branch_id in ["ngu_kiem","sat_kiem","ho_kiem"]:
        var branch_nodes := 0
        for raw_skill in skills:
            if str(raw_skill.get("branch","")) == branch_id:
                branch_nodes += 1
        if branch_nodes != 59:
            errors.append("sword_branch_node_count_invalid:"+branch_id)
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

static func is_sword_skill(skill_id: String) -> bool:
    return skill_id.begins_with("tmb.skill.sword.")

static func can_learn(definition: Dictionary) -> Dictionary:
    if definition.is_empty() or str(definition.get("school","")) != "sword":
        return {"ok":false,"reason":"unknown_sword_skill"}
    # No authenticated Sword manual/codex is present in canonical Warehouse.
    return {"ok":false,"reason":"skill_source_pending"}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
    if not bool(actor.get("v63_sword_combat_enabled",false)):
        return false
    var definition := skill_definition(skill_id)
    return not definition.is_empty() and is_sword_skill(skill_id) and str(definition.get("effect","")) in VALID_EFFECTS

static func preferred_offensive_range(actor: Dictionary) -> float:
    if str(actor.get("side","")) != "disciple" or not bool(actor.get("v63_sword_combat_enabled",false)):
        return 0.0
    if str(actor.get("v63_combat_branch_id","")) != "ngu_kiem":
        return 0.0
    var preferred := maxf(0.0,float(actor.get("range",0.0)))
    for raw_id in actor.get("v63_skill_loadout",[]):
        var skill := skill_definition(str(raw_id))
        if str(skill.get("branch","")) != "ngu_kiem" or str(skill.get("effect","")) in ["guard","mobility","passive","innate"]:
            continue
        if str(skill.get("slot","")) in ["active","ultimate"]:
            preferred = maxf(preferred,float(skill.get("range",0.0)))
    return preferred

static func guard_reflection_profile(actor: Dictionary, now: float) -> Dictionary:
    if not bool(actor.get("v63_sword_combat_enabled",false)):
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
        if str(skill.get("school","")) != "sword" or str(skill.get("branch","")) != "ho_kiem":
            continue
        var modifiers: Dictionary = skill.get("passive_modifiers",{})
        var ratio := clampf(float(modifiers.get("absorbed_reflect_ratio",0.0)),0.0,MAX_GUARD_REFLECT_RATIO)
        if ratio > best_ratio:
            best_ratio = ratio
            best_id = skill_id
    return {"ratio":best_ratio,"skill_id":best_id}

static func guard_reflection_ratio(actor: Dictionary, now: float) -> float:
    return float(guard_reflection_profile(actor,now).get("ratio",0.0))

static func reflect_absorbed(battle: MapBattleV2, defender: Dictionary, attacker: Dictionary, absorbed_damage: float, damage_element: String = "") -> float:
    if battle == null or defender.is_empty() or attacker.is_empty() or float(defender.get("hp",0.0)) <= 0.0 or float(attacker.get("hp",0.0)) <= 0.0:
        return 0.0
    if str(defender.get("side","")) == str(attacker.get("side","")) or absorbed_damage <= 0.0:
        return 0.0
    var profile := guard_reflection_profile(defender,battle.now)
    var ratio := float(profile.get("ratio",0.0))
    if ratio <= 0.0:
        return 0.0
    var stats: Dictionary = defender.get("stats",{})
    var attack := maxf(1.0,float(stats.get("attack",0.0)))
    var actual := battle._deal_direct(defender,attacker,absorbed_damage*ratio/attack,
        "v63_sword_absorbed_reflect",false,"metal" if damage_element.is_empty() else damage_element,false)
    battle._event("v63_sword_guard_reflect",{
        "caster":str(defender.get("id","")),"target":str(attacker.get("id","")),
        "absorbed_damage":absorbed_damage,"candidate_reflect_ratio":ratio,
        "damage":actual,"skill_id":str(profile.get("skill_id",""))
    })
    return actual

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
    # Sword uses the shared V63 effect resolver; the catalog cannot add a new
    # damage, status, target-cap, or reward authority.
    V63HumanSkillCombatSystem.release_cast_base(battle,cast,caster)
