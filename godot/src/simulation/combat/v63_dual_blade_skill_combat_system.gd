class_name V63DualBladeSkillCombatSystem
extends RefCounted

# S4 Song Đao candidate adapter. The catalog remains source-pending and the
# production release gate is OFF; preview fixtures still use Combat V2.
const CATALOGUE_PATH := "res://data/combat/v63_dual_blade_combat_catalog.json"
const EXPECTED_SKILLS := 183
const EXPECTED_FAMILIES := 35
const BRANCH_IDS := ["anh_nhan", "lien_hoan", "huyet_nguyet"]
const VALID_EFFECTS := ["damage", "mobility", "passive", "innate"]
const VALID_MODIFIERS := ["outgoing_factor", "crit_bonus", "cast_speed_factor", "cooldown_recovery_factor", "attack_speed_factor", "guard_factor"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
	if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
		return {"ok":true, "errors":[], "data":_catalogue_cache.duplicate(true)}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok":false, "errors":["dual_blade_catalogue_unavailable"], "data":{}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok":false, "errors":["dual_blade_catalogue_not_object"], "data":{}}
	var data: Dictionary = parsed
	var errors := validate_catalogue(data)
	if errors.is_empty() and path == CATALOGUE_PATH:
		_catalogue_cache = data.duplicate(true)
		_skill_cache.clear()
		for row in data.get("skills", []):
			_skill_cache[str(row.get("id", ""))] = row.duplicate(true)
	return {"ok":errors.is_empty(), "errors":errors, "data":data}

static func validate_catalogue(data: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(data.get("schema_version", -1)) != 1 or bool(data.get("enabled", true)) or str(data.get("release_gate", "")) != "OFF":
		errors.append("dual_blade_must_remain_disabled")
	if str(data.get("school", "")) != "dual_blade" or str(data.get("element", "")) != "metal":
		errors.append("dual_blade_school_or_element_invalid")
	if str(data.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(data.get("balance_status", "")) != "candidate_needs_qa":
		errors.append("dual_blade_candidate_state_invalid")
	if not str(data.get("source_codex_id", "")).is_empty() or bool(data.get("archivable", true)):
		errors.append("dual_blade_source_must_remain_pending")
	var branches: Variant = data.get("branches", null)
	var skills: Variant = data.get("skills", null)
	if not (branches is Array) or not (skills is Array):
		errors.append("dual_blade_arrays_missing")
		return errors
	if branches.size() != 3 or skills.size() != EXPECTED_SKILLS or int(data.get("skill_count", 0)) != EXPECTED_SKILLS or int(data.get("human_skill_count", 0)) != 35 or int(data.get("immortal_skill_count", 0)) != 68 or int(data.get("divine_skill_count", 0)) != 80:
		errors.append("dual_blade_metadata_counts_invalid")
	var branch_ids: Dictionary = {}
	for raw_branch in branches:
		if not (raw_branch is Dictionary):
			errors.append("dual_blade_branch_not_object")
			continue
		var branch: Dictionary = raw_branch
		var id := str(branch.get("id", ""))
		var lineages: Dictionary = branch.get("lineages", {})
		if id not in BRANCH_IDS or branch_ids.has(id):
			errors.append("dual_blade_branch_identity_invalid:" + id)
		if str(branch.get("school", "")) != "dual_blade" or str(branch.get("element", "")) != "metal":
			errors.append("dual_blade_branch_authority_invalid:" + id)
		if str(lineages.get("a", "")).strip_edges().is_empty() or str(lineages.get("b", "")).strip_edges().is_empty():
			errors.append("dual_blade_branch_lineage_missing:" + id)
		if _word_count(str(branch.get("story_vi", ""))) < 60:
			errors.append("dual_blade_branch_story_too_short:" + id)
		if str(branch.get("signature_ultimate", "")).strip_edges().is_empty():
			errors.append("dual_blade_signature_missing:" + id)
		branch_ids[id] = true
	if _word_count(str(data.get("school_story_vi", ""))) < 120:
		errors.append("dual_blade_school_story_too_short")
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var family_nodes: Dictionary = {}
	var tier_counts := {"human":0, "immortal":0, "divine":0}
	var branch_counts := {"anh_nhan":0, "lien_hoan":0, "huyet_nguyet":0}
	var by_id: Dictionary = {}
	for raw_skill in skills:
		if not (raw_skill is Dictionary):
			errors.append("dual_blade_skill_not_object")
			continue
		var skill: Dictionary = raw_skill
		var id := str(skill.get("id", ""))
		var family := str(skill.get("family_id", ""))
		var name := str(skill.get("name", ""))
		var branch := str(skill.get("branch", ""))
		var slot := str(skill.get("slot", ""))
		var tier := str(skill.get("generation", ""))
		var effect := str(skill.get("effect", ""))
		if not id.begins_with("tmb.skill.dual_blade.") or ids.has(id):
			errors.append("dual_blade_skill_id_invalid_or_duplicate:" + id)
		if name.strip_edges().is_empty() or names.has(name):
			errors.append("dual_blade_skill_name_invalid_or_duplicate:" + id)
		if family.is_empty() or not family.begins_with("tmb.skill.dual_blade.") or str(skill.get("school", "")) != "dual_blade" or str(skill.get("element", "")) != "metal":
			errors.append("dual_blade_skill_identity_invalid:" + id)
		if slot not in ["basic", "mobility", "active", "ultimate", "passive", "innate"] or not VALID_EFFECTS.has(effect):
			errors.append("dual_blade_slot_or_effect_invalid:" + id)
		if tier not in ["human", "immortal", "divine"]:
			errors.append("dual_blade_tier_invalid:" + id)
		if branch.is_empty():
			if slot not in ["basic", "mobility"]:
				errors.append("dual_blade_invalid_common_family:" + id)
		elif not BRANCH_IDS.has(branch):
			errors.append("dual_blade_unknown_branch:" + id)
		for field in ["damage_ratio", "range", "cast_time", "cooldown", "power", "duration", "radius", "hit_count", "target_limit", "health_cost_ratio", "health_trade_bonus_ratio"]:
			var value := float(skill.get(field, -1.0))
			if not skill.has(field) or is_nan(value) or is_inf(value) or value < 0.0:
				errors.append("dual_blade_numeric_field_invalid:" + id + ":" + field)
		if effect == "damage" and float(skill.get("damage_ratio", 0.0)) <= 0.0:
			errors.append("dual_blade_damage_without_ratio:" + id)
		if effect in ["passive", "innate"]:
			var modifiers: Variant = skill.get("passive_modifiers", null)
			if not (modifiers is Dictionary) or modifiers.is_empty():
				errors.append("dual_blade_modifier_missing:" + id)
			else:
				for modifier in modifiers.keys():
					if not VALID_MODIFIERS.has(str(modifier)) or float(modifiers[modifier]) < 0.0 or float(modifiers[modifier]) > 0.05:
						errors.append("dual_blade_modifier_unconsumed_or_unbounded:" + id + ":" + str(modifier))
		if int(skill.get("hit_count", 0)) < 1 or int(skill.get("hit_count", 0)) > 3 or int(skill.get("target_limit", 0)) != 1:
			errors.append("dual_blade_hit_or_target_cap_invalid:" + id)
		if str(skill.get("shape", "")) != "single_target":
			errors.append("dual_blade_shape_not_supported:" + id)
		if float(skill.get("health_cost_ratio", 0.0)) > 0.08 or float(skill.get("health_trade_bonus_ratio", 0.0)) > 1.2:
			errors.append("dual_blade_health_trade_unbounded:" + id)
		if float(skill.get("health_cost_ratio", 0.0)) > 0.0 and (branch != "huyet_nguyet" or effect != "damage"):
			errors.append("dual_blade_health_trade_outside_huyet_nguyet:" + id)
		if str(skill.get("source_codex_id", "")).strip_edges() != "" or bool(skill.get("archivable", true)) or str(skill.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(skill.get("balance_status", "")) != "candidate_needs_qa":
			errors.append("dual_blade_skill_must_stay_gated:" + id)
		if int(skill.get("target_limit", 0)) < 1 or int(skill.get("target_limit", 0)) > 1:
			errors.append("dual_blade_target_limit_invalid:" + id)
		ids[id] = true
		names[name] = true
		by_id[id] = skill
		families[family] = true
		if not family_nodes.has(family):
			family_nodes[family] = []
		family_nodes[family].append(skill)
		tier_counts[tier] = int(tier_counts.get(tier, 0)) + 1
		if branch_counts.has(branch):
			branch_counts[branch] = int(branch_counts[branch]) + 1
	if ids.size() != EXPECTED_SKILLS or families.size() != EXPECTED_FAMILIES:
		errors.append("dual_blade_unique_counts_invalid")
	if tier_counts != {"human":35, "immortal":68, "divine":80} or branch_counts != {"anh_nhan":59, "lien_hoan":59, "huyet_nguyet":59}:
		errors.append("dual_blade_node_distribution_invalid:" + str(tier_counts) + ":" + str(branch_counts))
	var tier_order := {"human":0, "immortal":1, "divine":2}
	for id in by_id.keys():
		var skill: Dictionary = by_id[id]
		var tier := str(skill.get("generation", ""))
		var parent_id := str(skill.get("parent_skill_id", ""))
		var rarity := str(skill.get("rarity", ""))
		var replaces := str(skill.get("replaces_skill_id", ""))
		if tier == "human":
			if not parent_id.is_empty():
				errors.append("dual_blade_human_parent_invalid:" + str(id))
		elif not by_id.has(parent_id):
			errors.append("dual_blade_successor_parent_missing:" + str(id))
		else:
			var parent: Dictionary = by_id[parent_id]
			if str(parent.get("family_id", "")) != str(skill.get("family_id", "")):
				errors.append("dual_blade_cross_family_parent:" + str(id))
			if rarity != "rare_divine" and int(tier_order.get(str(parent.get("generation", "")), 99)) >= int(tier_order.get(tier, 99)):
				errors.append("dual_blade_successor_order_invalid:" + str(id))
		if rarity == "rare_divine":
			if replaces != parent_id or not parent_id.contains(".divine."):
				errors.append("dual_blade_rare_replacement_invalid:" + str(id))
		elif not replaces.is_empty():
			errors.append("dual_blade_nonrare_replacement_invalid:" + str(id))
	for family in family_nodes.keys():
		var rows: Array = family_nodes[family]
		if rows.size() not in [3, 5, 7]:
			errors.append("dual_blade_family_node_count_invalid:" + str(family))
	return errors

static func _word_count(value: String) -> int:
	return value.strip_edges().split(" ", false).size()

static func branch_definitions() -> Dictionary:
	var result: Dictionary = {}
	var loaded := load_catalogue()
	if not bool(loaded.get("ok", false)):
		return result
	for branch in loaded.data.get("branches", []):
		result[str(branch.get("id", ""))] = branch.duplicate(true)
	return result

static func skill_definition(skill_id: String) -> Dictionary:
	if _skill_cache.is_empty():
		load_catalogue()
	return _skill_cache.get(skill_id, {}).duplicate(true)

static func is_dual_blade_skill(skill_id: String) -> bool:
	return skill_id.begins_with("tmb.skill.dual_blade.")

static func can_learn(definition: Dictionary) -> Dictionary:
	if definition.is_empty() or str(definition.get("school", "")) != "dual_blade":
		return {"ok":false, "reason":"unknown_dual_blade_skill"}
	return {"ok":false, "reason":"skill_source_pending"}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
	if not bool(actor.get("v63_dual_blade_combat_enabled", false)):
		return false
	var definition := skill_definition(skill_id)
	if definition.is_empty() or not is_dual_blade_skill(skill_id) or not VALID_EFFECTS.has(str(definition.get("effect", ""))):
		return false
	var cost_ratio := clampf(float(definition.get("health_cost_ratio", 0.0)), 0.0, 0.08)
	if cost_ratio <= 0.0:
		return true
	var hp := float(actor.get("hp", 0.0))
	var cost := float(actor.get("max_hp", 0.0)) * cost_ratio
	return hp - cost >= 1.0

static func preferred_offensive_range(actor: Dictionary) -> float:
	if not bool(actor.get("v63_dual_blade_combat_enabled", false)):
		return 0.0
	var best := 0.0
	for raw_id in actor.get("v63_skill_loadout", []):
		var skill := skill_definition(str(raw_id))
		if str(skill.get("school", "")) == "dual_blade" and str(skill.get("effect", "")) == "damage" and str(skill.get("slot", "")) in ["basic", "active", "ultimate"]:
			best = maxf(best, float(skill.get("range", 0.0)))
	return best

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
	V63HumanSkillCombatSystem.release_cast_base(battle, cast, caster)
