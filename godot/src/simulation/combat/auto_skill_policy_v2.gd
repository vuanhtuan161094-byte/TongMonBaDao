class_name AutoSkillPolicyV2
extends RefCounted

const SCHEMA := "tmb_auto_skill_policy_v2"
const MAX_ACTIVE_SLOTS := 4
const VALID_TIERS := ["normal", "elite", "boss"]

static func default_policy(owned_skill_ids: Array) -> Dictionary:
	var rows: Array = []
	var unique: Dictionary = {}
	for raw_id in owned_skill_ids:
		var skill_id := str(raw_id)
		if unique.has(skill_id) or not has_v2_damage_consumer(skill_id):
			continue
		unique[skill_id] = true
		if rows.size() >= MAX_ACTIVE_SLOTS:
			break
		var definition: Dictionary = CombatSkillSystem.SKILLS[skill_id]
		rows.append({
			"canonical_skill_id": skill_id,
			"enabled": true,
			"priority": rows.size(),
			"conditions": {
				"actor_hp_at_or_below": 1.0,
				"target_hp_at_or_below": 1.0,
				"min_range": 0.0,
				"max_range": float(definition.get("range", 0.0)),
				"target_tiers": VALID_TIERS.duplicate(),
				"minimum_enemies_near_target": 1
			}
		})
	return {"schema": SCHEMA, "basic_fallback": true, "skills": rows}

static func normalize(policy_value: Variant, owned_skill_ids: Array) -> Dictionary:
	var owned: Dictionary = {}
	for raw_id in owned_skill_ids:
		var id := str(raw_id)
		if has_v2_damage_consumer(id):
			owned[id] = true
	if policy_value == null or (policy_value is Dictionary and (policy_value as Dictionary).is_empty()):
		var default_value := default_policy(owned_skill_ids)
		return {"ok": true, "policy": default_value,
			"equipped_skill_ids": enabled_skill_ids(default_value)}
	if not (policy_value is Dictionary):
		return {"ok": false, "reason": "auto_skill_policy_not_object"}
	var raw: Dictionary = policy_value
	if str(raw.get("schema", "")) != SCHEMA or not (raw.get("skills") is Array):
		return {"ok": false, "reason": "unsupported_auto_skill_policy"}
	if not (raw.get("basic_fallback", true) is bool):
		return {"ok": false, "reason": "invalid_basic_fallback"}
	var skills: Array = raw["skills"]
	if skills.size() > MAX_ACTIVE_SLOTS:
		return {"ok": false, "reason": "active_skill_slot_limit_exceeded"}
	var seen_ids: Dictionary = {}
	var seen_priorities: Dictionary = {}
	var normalized_rows: Array = []
	for entry in skills:
		if not (entry is Dictionary):
			return {"ok": false, "reason": "invalid_auto_skill_entry"}
		var row: Dictionary = entry
		var id := str(row.get("canonical_skill_id", ""))
		if not owned.has(id):
			return {"ok": false, "reason": "skill_not_learned_and_equipped:" + id}
		if seen_ids.has(id):
			return {"ok": false, "reason": "duplicate_auto_skill:" + id}
		var priority_value = row.get("priority", -1)
		if not _is_whole_number(priority_value) or int(roundf(float(priority_value))) < 0 or int(roundf(float(priority_value))) >= MAX_ACTIVE_SLOTS:
			return {"ok": false, "reason": "invalid_skill_priority:" + id}
		var priority := int(roundf(float(priority_value)))
		if seen_priorities.has(priority):
			return {"ok": false, "reason": "duplicate_skill_priority"}
		if not (row.get("enabled", true) is bool):
			return {"ok": false, "reason": "invalid_skill_enabled:" + id}
		var conditions_result := _normalize_conditions(row.get("conditions", {}), id)
		if not bool(conditions_result.get("ok", false)):
			return conditions_result
		seen_ids[id] = true
		seen_priorities[priority] = true
		normalized_rows.append({
			"canonical_skill_id": id,
			"enabled": bool(row.get("enabled", true)),
			"priority": priority,
			"conditions": conditions_result["conditions"]
		})
	normalized_rows.sort_custom(func(a, b):
		if int(a["priority"]) != int(b["priority"]):
			return int(a["priority"]) < int(b["priority"])
		return str(a["canonical_skill_id"]) < str(b["canonical_skill_id"])
	)
	var normalized := {
		"schema": SCHEMA,
		"basic_fallback": bool(raw.get("basic_fallback", true)),
		"skills": normalized_rows
	}
	return {"ok": true, "policy": normalized,
		"equipped_skill_ids": enabled_skill_ids(normalized)}

static func enabled_skill_ids(policy: Dictionary) -> Array:
	var result: Array = []
	for row_value in policy.get("skills", []):
		if not (row_value is Dictionary):
			continue
		var row: Dictionary = row_value
		if bool(row.get("enabled", false)):
			result.append(str(row.get("canonical_skill_id", "")))
	return result

static func ordered_enabled_skill_ids(actor: Dictionary) -> Array:
	var policy: Dictionary = actor.get("auto_skill_policy", {})
	var result: Array = []
	for row_value in policy.get("skills", []):
		if row_value is Dictionary and bool(row_value.get("enabled", false)):
			result.append(str(row_value.get("canonical_skill_id", "")))
	return result

static func eligible(battle: Variant, actor: Dictionary, target: Dictionary, skill_id: String) -> bool:
	if battle == null or not has_v2_damage_consumer(skill_id):
		return false
	var policy: Dictionary = actor.get("auto_skill_policy", {})
	var row: Dictionary = {}
	for row_value in policy.get("skills", []):
		if row_value is Dictionary and str(row_value.get("canonical_skill_id", "")) == skill_id:
			row = row_value
			break
	if row.is_empty() or not bool(row.get("enabled", false)):
		return false
	var ready: Dictionary = actor.get("skill_ready", {})
	if float(battle.now) + 0.000001 < float(ready.get(skill_id, 0.0)):
		return false
	var conditions: Dictionary = row.get("conditions", {})
	var actor_ratio := float(actor.get("hp", 0.0)) / maxf(1.0, float(actor.get("max_hp", 1.0)))
	var target_ratio := float(target.get("hp", 0.0)) / maxf(1.0, float(target.get("max_hp", 1.0)))
	if actor_ratio > float(conditions.get("actor_hp_at_or_below", 1.0)):
		return false
	if target_ratio > float(conditions.get("target_hp_at_or_below", 1.0)):
		return false
	var distance := (actor["position"] as Vector2).distance_to(target["position"])
	if distance + 0.000001 < float(conditions.get("min_range", 0.0)):
		return false
	if distance - 0.000001 > float(conditions.get("max_range", 0.0)):
		return false
	if str(target.get("tier", "normal")) not in conditions.get("target_tiers", []):
		return false
	var required_nearby := int(conditions.get("minimum_enemies_near_target", 1))
	if required_nearby > 1 and int(battle._enemies_near(target, 3.0)) < required_nearby:
		return false
	return true

static func has_v2_damage_consumer(skill_id: String) -> bool:
	var definition: Dictionary = CombatSkillSystem.SKILLS.get(skill_id, {})
	return not definition.is_empty() and str(definition.get("effect", "")) == "damage"

static func _normalize_conditions(value: Variant, skill_id: String) -> Dictionary:
	if not (value is Dictionary):
		return {"ok": false, "reason": "invalid_skill_conditions:" + skill_id}
	var raw: Dictionary = value
	for key in ["actor_hp_at_or_below", "target_hp_at_or_below", "min_range", "max_range"]:
		if not (raw.get(key, null) is int or raw.get(key, null) is float):
			return {"ok": false, "reason": "missing_numeric_condition:" + skill_id + ":" + key}
		var number := float(raw[key])
		if is_nan(number) or is_inf(number):
			return {"ok": false, "reason": "non_finite_skill_condition:" + skill_id + ":" + key}
	for key in ["actor_hp_at_or_below", "target_hp_at_or_below"]:
		var ratio := float(raw[key])
		if ratio < 0.0 or ratio > 1.0:
			return {"ok": false, "reason": "invalid_hp_threshold:" + skill_id + ":" + key}
	var definition: Dictionary = CombatSkillSystem.SKILLS[skill_id]
	var minimum := float(raw["min_range"])
	var maximum := float(raw["max_range"])
	if minimum < 0.0 or maximum < minimum or maximum > float(definition.get("range", 0.0)):
		return {"ok": false, "reason": "skill_range_exceeds_v2_definition:" + skill_id}
	if not (raw.get("target_tiers") is Array) or raw["target_tiers"].is_empty():
		return {"ok": false, "reason": "empty_target_tiers:" + skill_id}
	var tiers: Array = []
	for raw_tier in raw["target_tiers"]:
		var tier := str(raw_tier)
		if tier not in VALID_TIERS or tier in tiers:
			return {"ok": false, "reason": "invalid_target_tier:" + skill_id}
		tiers.append(tier)
	var nearby = raw.get("minimum_enemies_near_target", 1)
	if not _is_whole_number(nearby) or int(roundf(float(nearby))) < 1 or int(roundf(float(nearby))) > MapBattleV2.MAX_TARGETS_AOE:
		return {"ok": false, "reason": "invalid_nearby_target_condition:" + skill_id}
	var nearby_count := int(roundf(float(nearby)))
	return {"ok": true, "conditions": {
		"actor_hp_at_or_below": float(raw["actor_hp_at_or_below"]),
		"target_hp_at_or_below": float(raw["target_hp_at_or_below"]),
		"min_range": minimum,
		"max_range": maximum,
		"target_tiers": tiers,
		"minimum_enemies_near_target": nearby_count
	}}

static func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return not is_nan(float(value)) and not is_inf(float(value)) and is_equal_approx(float(value), roundf(float(value)))
	return false
