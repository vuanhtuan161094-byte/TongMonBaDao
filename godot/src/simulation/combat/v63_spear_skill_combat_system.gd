class_name V63SpearSkillCombatSystem
extends RefCounted

# S3 Thương candidate runtime. It shares Combat V2 cast, line-query and damage
# settlement. Authentic transmission and numerical approval remain pending.
const CATALOGUE_PATH := "res://data/combat/v63_spear_combat_catalog.json"
const EXPECTED_SKILLS := 183
const EXPECTED_BRANCHES := 3
const EXPECTED_FAMILIES := 35
const VALID_BRANCHES := ["pha_tran_thuong", "long_thuong", "ho_quan_thuong"]
const VALID_EFFECTS := ["damage", "guard", "mobility", "passive", "innate"]
const VALID_SHAPES := ["single_target", "line"]
const VALID_PASSIVE_MODIFIERS := ["outgoing_factor", "crit_bonus", "cast_speed_factor", "cooldown_recovery_factor", "attack_speed_factor", "guard_factor"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
	if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
		return {"ok":true,"errors":[],"data":_catalogue_cache.duplicate(true)}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok":false,"errors":["spear_catalogue_unavailable"],"data":{}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok":false,"errors":["spear_catalogue_not_object"],"data":{}}
	var data: Dictionary = parsed
	var errors := validate_catalogue(data)
	if errors.is_empty() and path == CATALOGUE_PATH:
		_catalogue_cache = data.duplicate(true)
		_skill_cache.clear()
		for row in data.get("skills", []):
			_skill_cache[str(row.get("id", ""))] = row.duplicate(true)
	return {"ok":errors.is_empty(),"errors":errors,"data":data}

static func validate_catalogue(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(data.get("schema_version", -1)) != 1 or bool(data.get("enabled", true)) or str(data.get("release_gate", "")) != "OFF":
		errors.append("spear_catalogue_must_remain_disabled")
	var branches: Variant = data.get("branches", null)
	var skills: Variant = data.get("skills", null)
	if not (branches is Array) or not (skills is Array):
		errors.append("spear_catalogue_arrays_missing")
		return errors
	if branches.size() != EXPECTED_BRANCHES or skills.size() != EXPECTED_SKILLS or int(data.get("skill_count", 0)) != EXPECTED_SKILLS:
		errors.append("spear_catalogue_counts_invalid")
	var branch_ids: Dictionary = {}
	for raw_branch in branches:
		if not (raw_branch is Dictionary):
			errors.append("spear_branch_not_object")
			continue
		var branch: Dictionary = raw_branch
		var branch_id := str(branch.get("id", ""))
		var lineages: Dictionary = branch.get("lineages", {})
		if branch_id not in VALID_BRANCHES or branch_ids.has(branch_id):
			errors.append("spear_branch_identity_invalid:" + branch_id)
		if str(branch.get("school", "")) != "spear" or str(branch.get("element", "")) != "metal":
			errors.append("spear_branch_school_or_element_invalid:" + branch_id)
		if str(branch.get("story_vi", "")).strip_edges().is_empty() or str(branch.get("signature_ultimate", "")).strip_edges().is_empty():
			errors.append("spear_branch_lore_missing:" + branch_id)
		if str(lineages.get("a", "")).is_empty() or str(lineages.get("b", "")).is_empty():
			errors.append("spear_lineage_missing:" + branch_id)
		branch_ids[branch_id] = true
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var tier_counts := {"human":0,"immortal":0,"divine":0}
	var branch_counts: Dictionary = {"pha_tran_thuong":0,"long_thuong":0,"ho_quan_thuong":0}
	var skill_by_id: Dictionary = {}
	for raw_skill in skills:
		if not (raw_skill is Dictionary):
			errors.append("spear_skill_not_object")
			continue
		var skill: Dictionary = raw_skill
		var id := str(skill.get("id", ""))
		var name := str(skill.get("name", ""))
		var school := str(skill.get("school", ""))
		var branch := str(skill.get("branch", ""))
		var tier := str(skill.get("generation", skill.get("tier", "")))
		var slot := str(skill.get("slot", ""))
		var effect := str(skill.get("effect", ""))
		var family := str(skill.get("family_id", ""))
		if not id.begins_with("tmb.skill.spear.") or ids.has(id):
			errors.append("spear_skill_id_invalid_or_duplicate:" + id)
		if name.strip_edges().is_empty() or names.has(name):
			errors.append("spear_skill_name_invalid_or_duplicate:" + id)
		if school != "spear" or str(skill.get("element", "")) != "metal" or family.is_empty():
			errors.append("spear_skill_identity_invalid:" + id)
		if not VALID_EFFECTS.has(effect) or slot not in ["basic", "mobility", "active", "ultimate", "passive", "innate"]:
			errors.append("spear_effect_or_slot_invalid:" + id)
		if tier not in ["human", "immortal", "divine"]:
			errors.append("spear_tier_invalid:" + id)
		for field in ["damage_ratio", "range", "cast_time", "cooldown", "power", "duration", "radius", "guard_capacity_ratio"]:
			var value := float(skill.get(field, -1.0))
			if not skill.has(field) or is_nan(value) or is_inf(value) or value < 0.0:
				errors.append("spear_numeric_field_invalid:" + id + ":" + field)
		if slot in ["basic", "mobility", "active", "ultimate"] and (float(skill.get("range", 0.0)) <= 0.0 or float(skill.get("cooldown", 0.0)) <= 0.0):
			errors.append("spear_range_or_cooldown_invalid:" + id)
		if effect == "damage" and float(skill.get("damage_ratio", 0.0)) <= 0.0:
			errors.append("spear_damage_without_ratio:" + id)
		if effect in ["passive", "innate"] and not (skill.get("passive_modifiers", {}) is Dictionary):
			errors.append("spear_passive_modifiers_invalid:" + id)
		for modifier in skill.get("passive_modifiers", {}).keys():
			if not VALID_PASSIVE_MODIFIERS.has(str(modifier)):
				errors.append("spear_modifier_not_consumed:" + id + ":" + str(modifier))
		if str(skill.get("shape", "")) not in VALID_SHAPES or int(skill.get("target_limit", 0)) < 1 or int(skill.get("target_limit", 0)) > 3:
			errors.append("spear_target_shape_invalid:" + id)
		if not str(skill.get("source_codex_id", "")).is_empty() or bool(skill.get("archivable", true)):
			errors.append("spear_source_must_remain_pending:" + id)
		if str(skill.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(skill.get("balance_status", "")) != "candidate_needs_qa":
			errors.append("spear_candidate_gate_status_invalid:" + id)
		if effect == "guard":
			if str(skill.get("guard_mode", "")) != "capacity_shield" or float(skill.get("guard_capacity_ratio", 0.0)) <= 0.0 or float(skill.get("guard_capacity_ratio", 0.0)) > 0.8 or float(skill.get("duration", 0.0)) > 12.0:
				errors.append("spear_shield_bounds_invalid:" + id)
			if str(skill.get("guard_target_policy", "")) not in ["self", "weakest_ally"]:
				errors.append("spear_guard_target_policy_invalid:" + id)
		if not branch.is_empty() and not branch_ids.has(branch):
			errors.append("spear_skill_branch_missing:" + id)
		ids[id] = true
		names[name] = true
		families[family] = true
		tier_counts[tier] = int(tier_counts.get(tier, 0)) + 1
		if branch_counts.has(branch):
			branch_counts[branch] = int(branch_counts[branch]) + 1
		skill_by_id[id] = skill
	if ids.size() != EXPECTED_SKILLS or families.size() != EXPECTED_FAMILIES:
		errors.append("spear_unique_id_family_count_invalid")
	if tier_counts != {"human":35,"immortal":68,"divine":80} or branch_counts != {"pha_tran_thuong":59,"long_thuong":59,"ho_quan_thuong":59}:
		errors.append("spear_node_distribution_invalid")
	var order := {"human":0,"immortal":1,"divine":2}
	for id in skill_by_id:
		var skill: Dictionary = skill_by_id[id]
		var tier := str(skill.get("generation", ""))
		var parent_id := str(skill.get("parent_skill_id", ""))
		var replacement := str(skill.get("replaces_skill_id", ""))
		var rarity := str(skill.get("rarity", ""))
		if tier == "human":
			if not parent_id.is_empty():
				errors.append("spear_human_parent_invalid:" + str(id))
		elif not skill_by_id.has(parent_id):
			errors.append("spear_successor_parent_missing:" + str(id))
		else:
			var parent: Dictionary = skill_by_id[parent_id]
			if str(parent.get("family_id", "")) != str(skill.get("family_id", "")):
				errors.append("spear_successor_cross_family:" + str(id))
			if rarity != "rare_divine" and int(order.get(str(parent.get("generation", "")), 99)) >= int(order.get(tier, 99)):
				errors.append("spear_successor_order_invalid:" + str(id))
		if rarity == "rare_divine":
			if parent_id.is_empty() or replacement != parent_id or not parent_id.contains(".divine."):
				errors.append("spear_rare_replacement_invalid:" + str(id))
		elif not replacement.is_empty():
			errors.append("spear_unexpected_replacement:" + str(id))
	return errors

static func branch_definitions() -> Dictionary:
	var result: Dictionary = {}
	var loaded := load_catalogue()
	if not bool(loaded.get("ok", false)):
		return result
	for row in loaded.data.get("branches", []):
		result[str(row.get("id", ""))] = row.duplicate(true)
	return result

static func skill_definition(skill_id: String) -> Dictionary:
	if _skill_cache.is_empty():
		load_catalogue()
	return _skill_cache.get(skill_id, {}).duplicate(true)

static func is_spear_skill(skill_id: String) -> bool:
	return skill_id.begins_with("tmb.skill.spear.")

static func can_learn(definition: Dictionary) -> Dictionary:
	if definition.is_empty() or str(definition.get("school", "")) != "spear":
		return {"ok":false,"reason":"unknown_spear_skill"}
	return {"ok":false,"reason":"skill_source_pending"}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
	if not bool(actor.get("v63_spear_combat_enabled", false)):
		return false
	var definition := skill_definition(skill_id)
	return not definition.is_empty() and is_spear_skill(skill_id) and VALID_EFFECTS.has(str(definition.get("effect", "")))

static func preferred_offensive_range(actor: Dictionary) -> float:
	var best := 0.0
	if not bool(actor.get("v63_spear_combat_enabled", false)):
		return best
	for raw_id in actor.get("v63_skill_loadout", []):
		var definition := skill_definition(str(raw_id))
		if str(definition.get("school", "")) == "spear" and str(definition.get("effect", "")) == "damage" and str(definition.get("shape", "")) == "line":
			best = maxf(best, float(definition.get("range", 0.0)))
	return best

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
	V63HumanSkillCombatSystem.release_cast_base(battle, cast, caster)
