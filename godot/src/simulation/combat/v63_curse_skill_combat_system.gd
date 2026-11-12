class_name V63CurseSkillCombatSystem
extends RefCounted

# S7 Chú candidate adapter. Source and balance remain pending; the release
# gate stays OFF. Preview fixtures still pass through the shared Combat V2 core.
const CATALOGUE_PATH := "res://data/combat/v63_curse_combat_catalog.json"
const EXPECTED_SKILLS := 183
const EXPECTED_FAMILIES := 35
const BRANCH_IDS := ["tran_hon_chu", "phe_linh_chu", "ho_menh_chu"]
const VALID_EFFECTS := ["damage", "mark", "guard", "heal", "cleanse", "mobility", "passive", "innate", "slow"]
const VALID_MODIFIERS := ["outgoing_factor", "attack_speed_factor", "cast_speed_factor", "cooldown_recovery_factor", "heal_factor"]
static var _catalogue_cache: Dictionary = {}
static var _skill_cache: Dictionary = {}

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
	if path == CATALOGUE_PATH and not _catalogue_cache.is_empty():
		return {"ok":true, "errors":[], "data":_catalogue_cache.duplicate(true)}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok":false, "errors":["curse_catalogue_unavailable"], "data":{}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok":false, "errors":["curse_catalogue_not_object"], "data":{}}
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
		errors.append("curse_must_remain_disabled")
	if str(data.get("school", "")) != "curse" or str(data.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING":
		errors.append("curse_identity_or_candidate_state_invalid")
	if str(data.get("balance_status", "")) != "candidate_needs_qa" or not str(data.get("source_codex_id", "")).is_empty() or bool(data.get("archivable", true)):
		errors.append("curse_source_or_balance_must_remain_pending")
	var branches: Variant = data.get("branches", null)
	var skills: Variant = data.get("skills", null)
	if not (branches is Array) or not (skills is Array):
		errors.append("curse_arrays_missing")
		return errors
	if branches.size() != 3 or skills.size() != EXPECTED_SKILLS or int(data.get("skill_count", 0)) != EXPECTED_SKILLS:
		errors.append("curse_metadata_counts_invalid")
	var branch_set: Dictionary = {}
	for raw_branch in branches:
		if not (raw_branch is Dictionary):
			errors.append("curse_branch_not_object")
			continue
		var branch: Dictionary = raw_branch
		var branch_id := str(branch.get("id", ""))
		if branch_id not in BRANCH_IDS or branch_set.has(branch_id):
			errors.append("curse_branch_identity_invalid:" + branch_id)
		if str(branch.get("school", "")) != "curse" or str(branch.get("path_id", "")) != "tmb.path.curse." + branch_id:
			errors.append("curse_branch_authority_invalid:" + branch_id)
		if _word_count(str(branch.get("story_vi", ""))) < 60:
			errors.append("curse_branch_story_too_short:" + branch_id)
		var lineages: Dictionary = branch.get("lineages", {})
		var lineage_stories: Dictionary = branch.get("lineage_stories_vi", {})
		for lineage_id in ["a", "b"]:
			if str(lineages.get(lineage_id, "")).strip_edges().is_empty() or _word_count(str(lineage_stories.get(lineage_id, ""))) < 35:
				errors.append("curse_lineage_story_missing:" + branch_id + ":" + lineage_id)
		if str(branch.get("signature_ultimate", "")).strip_edges().is_empty():
			errors.append("curse_signature_ultimate_missing:" + branch_id)
		branch_set[branch_id] = true
	if branch_set.size() != 3 or _word_count(str(data.get("school_story_vi", ""))) < 120:
		errors.append("curse_school_lore_incomplete")
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var family_counts: Dictionary = {}
	var tier_counts := {"human":0, "immortal":0, "divine":0}
	var branch_counts := {"tran_hon_chu":0, "phe_linh_chu":0, "ho_menh_chu":0}
	var by_id: Dictionary = {}
	for raw_skill in skills:
		if not (raw_skill is Dictionary):
			errors.append("curse_skill_not_object")
			continue
		var skill: Dictionary = raw_skill
		var id := str(skill.get("id", ""))
		var family := str(skill.get("family_id", ""))
		var branch := str(skill.get("branch", ""))
		var tier := str(skill.get("generation", ""))
		var slot := str(skill.get("slot", ""))
		var family_slot := str(skill.get("family_slot", ""))
		var effect := str(skill.get("effect", ""))
		var name := str(skill.get("name", "")).strip_edges()
		if not id.begins_with("tmb.skill.curse.") or ids.has(id) or str(skill.get("node_id", "")) != id:
			errors.append("curse_skill_id_invalid_or_duplicate:" + id)
		if not name.is_empty() and names.has(name):
			errors.append("curse_skill_name_duplicate:" + id)
		if name.is_empty():
			errors.append("curse_skill_name_missing:" + id)
		if branch.is_empty():
			if slot not in ["basic", "mobility"] or family != "tmb.skill.curse." + family_slot:
				errors.append("curse_common_family_id_invalid:" + id)
		elif branch not in BRANCH_IDS or not id.contains("." + branch + ".") or not family.begins_with("tmb.skill.curse." + branch + "."):
			errors.append("curse_branch_id_or_family_mismatch:" + id)
		if str(skill.get("school", "")) != "curse" or not CombatStatsV2.ELEMENTS.has(str(skill.get("element", ""))):
			errors.append("curse_skill_school_or_element_invalid:" + id)
		if slot not in ["basic", "mobility", "active", "ultimate", "passive", "innate"] or not VALID_EFFECTS.has(effect):
			errors.append("curse_skill_slot_or_effect_invalid:" + id)
		if slot in ["passive", "innate"] and effect != slot:
			errors.append("curse_passive_slot_effect_mismatch:" + id + ":" + slot + ":" + effect)
		if tier not in ["human", "immortal", "divine"]:
			errors.append("curse_skill_tier_invalid:" + id)
		for field in ["damage_ratio", "range", "cast_time", "cooldown", "power", "duration", "radius", "target_limit", "slow_movement_factor", "boss_effect_strength_factor", "boss_duration_factor"]:
			var value := float(skill.get(field, -1.0))
			if not skill.has(field) or is_nan(value) or is_inf(value) or value < 0.0:
				errors.append("curse_numeric_field_invalid:" + id + ":" + field)
		if effect == "damage" and float(skill.get("damage_ratio", 0.0)) <= 0.0:
			errors.append("curse_damage_ratio_missing:" + id)
		if effect == "guard" and (str(skill.get("guard_mode", "")) != "mitigation" or float(skill.get("power", 0.0)) < 0.05 or float(skill.get("power", 0.0)) > 0.8 or float(skill.get("duration", 0.0)) <= 0.0):
			errors.append("curse_guard_mitigation_invalid:" + id)
		if effect in ["passive", "innate"]:
			var modifiers: Variant = skill.get("passive_modifiers", null)
			if not (modifiers is Dictionary) or modifiers.is_empty():
				errors.append("curse_passive_modifier_missing:" + id)
			else:
				for modifier in modifiers.keys():
					if not VALID_MODIFIERS.has(str(modifier)) or float(modifiers[modifier]) < 0.0 or float(modifiers[modifier]) > 0.05:
						errors.append("curse_passive_modifier_unconsumed_or_unbounded:" + id + ":" + str(modifier))
		if int(skill.get("target_limit", 0)) < 1 or int(skill.get("target_limit", 0)) > 3 or int(skill.get("hit_count", 0)) != 1:
			errors.append("curse_target_or_hit_cap_invalid:" + id)
		if str(skill.get("source_codex_id", "")).strip_edges() != "" or bool(skill.get("archivable", true)) or str(skill.get("candidate_status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or str(skill.get("balance_status", "")) != "candidate_needs_qa":
			errors.append("curse_skill_must_stay_gated:" + id)
		var parent_id := str(skill.get("parent_skill_id", ""))
		if tier == "human" and not parent_id.is_empty():
			errors.append("curse_human_parent_invalid:" + id)
		if tier != "human" and parent_id.is_empty():
			errors.append("curse_successor_parent_missing:" + id)
		ids[id] = true
		names[name] = true
		families[family] = true
		family_counts[family] = int(family_counts.get(family, 0)) + 1
		by_id[id] = skill
		tier_counts[tier] = int(tier_counts.get(tier, 0)) + 1
		if branch_counts.has(branch):
			branch_counts[branch] = int(branch_counts[branch]) + 1
	if ids.size() != EXPECTED_SKILLS or families.size() != EXPECTED_FAMILIES:
		errors.append("curse_unique_counts_invalid")
	if tier_counts != {"human":35, "immortal":68, "divine":80} or branch_counts != {"loi_phu":59, "hoa_phu":59, "phong_an_phu":59}:
		errors.append("curse_node_distribution_invalid:" + str(tier_counts) + ":" + str(branch_counts))
	for family_id in family_counts.keys():
		if int(family_counts[family_id]) not in [3, 5, 7]:
			errors.append("curse_family_graph_size_invalid:" + str(family_id))
	var tier_order := {"human":0, "immortal":1, "divine":2}
	for id in by_id.keys():
		var skill: Dictionary = by_id[id]
		var parent_id := str(skill.get("parent_skill_id", ""))
		var replaces_id := str(skill.get("replaces_skill_id", ""))
		var rare := str(skill.get("rarity", "")) == "rare_divine"
		if not parent_id.is_empty():
			if not by_id.has(parent_id):
				errors.append("curse_parent_not_found:" + str(id))
			else:
				var parent: Dictionary = by_id[parent_id]
				if str(parent.get("family_id", "")) != str(skill.get("family_id", "")) or int(tier_order.get(str(parent.get("generation", "")), 99)) > int(tier_order.get(str(skill.get("generation", "")), -1)):
					errors.append("curse_parent_graph_invalid:" + str(id))
		if rare and replaces_id != parent_id:
			errors.append("curse_rare_replacement_invalid:" + str(id))
		if not rare and not replaces_id.is_empty():
			errors.append("curse_unexpected_replacement:" + str(id))
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

static func is_curse_skill(skill_id: String) -> bool:
	return skill_id.begins_with("tmb.skill.curse.")

static func can_learn(definition: Dictionary) -> Dictionary:
	if definition.is_empty() or str(definition.get("school", "")) != "curse":
		return {"ok":false, "reason":"unknown_curse_skill"}
	return {"ok":false, "reason":"skill_source_pending"}

static func can_cast(actor: Dictionary, skill_id: String) -> bool:
	if not bool(actor.get("v63_curse_combat_enabled", false)):
		return false
	var definition := skill_definition(skill_id)
	return not definition.is_empty() and is_curse_skill(skill_id) and VALID_EFFECTS.has(str(definition.get("effect", ""))) and str(definition.get("slot", "")) in ["active", "ultimate", "mobility"]

static func preferred_offensive_range(actor: Dictionary) -> float:
	if not bool(actor.get("v63_curse_combat_enabled", false)):
		return 0.0
	var best := 0.0
	for raw_id in actor.get("v63_skill_loadout", []):
		var skill := skill_definition(str(raw_id))
		if str(skill.get("school", "")) == "curse" and str(skill.get("effect", "")) in ["damage", "mark", "slow"] and str(skill.get("slot", "")) in ["basic", "active", "ultimate"]:
			best = maxf(best, float(skill.get("range", 0.0)))
	return best

static func should_cast(battle: MapBattleV2, actor: Dictionary, target: Dictionary, definition: Dictionary) -> bool:
	if battle == null or target.is_empty():
		return false
	var effect := str(definition.get("effect", ""))
	var now := battle.now
	if effect == "mark":
		var owner_mark: Dictionary = target.get("v63_marks", {}).get(str(actor.get("id", "")), {})
		if str(owner_mark.get("skill_id", "")) == str(definition.get("id", "")) and now < float(owner_mark.get("until", -1.0)):
			return false
	elif effect == "slow":
		var active_slow: Dictionary = target.get("status_effects", {}).get("slow", {})
		if not active_slow.is_empty() and now < float(active_slow.get("until", -1.0)):
			var requested := clampf(float(definition.get("slow_movement_factor", 1.0)), 0.5, 1.0)
			var strength := 1.0 - requested
			if str(target.get("tier", "")) == "boss" or not str(target.get("v63_boss_id", "")).is_empty():
				strength *= clampf(float(definition.get("boss_effect_strength_factor", 0.35)), 0.0, 1.0)
			var wanted_factor := clampf(1.0 - strength, 0.5, 1.0)
			if float(active_slow.get("movement_factor", 1.0)) <= wanted_factor + 0.000001 and float(active_slow.get("until", 0.0)) - now > MapBattleV2.STEP_SECONDS * 2.0:
				return false
	elif effect == "guard":
		if float(target.get("learned_guard_until", -1.0)) > now and float(target.get("learned_guard_factor", 1.0)) <= 1.0 - clampf(float(definition.get("power", 0.0)), 0.05, 0.8) + 0.000001:
			return false
	return true

static func release_cast(battle: MapBattleV2, cast: Dictionary, caster: Dictionary) -> void:
	V63HumanSkillCombatSystem.release_cast_base(battle, cast, caster)


