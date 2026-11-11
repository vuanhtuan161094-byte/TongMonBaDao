class_name V63SpiritualRootEvaluator
extends RefCounted

# Pure V2 calculation primitive. It is intentionally not connected to a live actor,
# CombatStatsV2, recruitment, or persistence until the later G1 integration gate.
# Values below come from the locked Root V2 design as starting candidates; V63
# remains disabled, and these derived values are not gameplay acceptance.

const BASE_ELEMENTS := ["metal", "wood", "water", "fire", "earth"]
const NEUTRAL_ELEMENTS := ["", "neutral", "none"]
const RESONANCE_BY_PERFECTED_ROOTS := [1.0, 1.10, 1.25, 1.45, 1.70, 2.0]
const BEATS := {
	"metal": "wood",
	"wood": "earth",
	"earth": "water",
	"water": "fire",
	"fire": "metal"
}
const MATCHING_SKILL_EFFECT_PER_PURITY := 0.003
const MULTI_ELEMENT_WEAK_ROOT_WEIGHT := 0.60
const MULTI_ELEMENT_MEAN_WEIGHT := 0.40

static func evaluate_base_roots(root_values: Dictionary) -> Dictionary:
	var normalized: Dictionary = {}
	for raw_key in root_values.keys():
		var element := str(raw_key).to_lower()
		if not BASE_ELEMENTS.has(element):
			return {"ok": false, "reason": "unsupported_base_root:" + element}
		if normalized.has(element):
			return {"ok": false, "reason": "duplicate_normalized_root:" + element}
		var raw_purity: Variant = root_values[raw_key]
		if not (raw_purity is int):
			return {"ok": false, "reason": "root_purity_must_be_integer:" + element}
		var purity := int(raw_purity)
		if purity < 1 or purity > 100:
			return {"ok": false, "reason": "root_purity_out_of_range:" + element}
		normalized[element] = purity

	if normalized.size() > BASE_ELEMENTS.size():
		return {"ok": false, "reason": "too_many_base_roots"}

	var perfected_count := 0
	for element in BASE_ELEMENTS:
		if int(normalized.get(element, 0)) == 100:
			perfected_count += 1
	var resonance := float(RESONANCE_BY_PERFECTED_ROOTS[perfected_count])
	var roots: Dictionary = {}
	var total: Dictionary = {
		"matching_cultivation": 0.0,
		"matching_mastery": 0.0,
		"matching_skill_effect": 0.0,
		"matching_element_resistance": 0.0,
		"defense_penetration": 0.0,
		"max_hp": 0.0,
		"attack_speed": 0.0,
		"cast_speed": 0.0,
		"all_damage": 0.0,
		"defense": 0.0
	}
	for element in BASE_ELEMENTS:
		if not normalized.has(element):
			continue
		var purity := int(normalized[element])
		var matching := {
			"cultivation": purity * 0.0030 * resonance,
			"mastery": purity * 0.0015 * resonance,
			"skill_effect": purity * 0.0030 * resonance,
			"element_resistance": purity * 0.0015 * resonance
		}
		var permanent := {}
		match element:
			"metal":
				permanent["defense_penetration"] = purity * 0.0010 * resonance
			"wood":
				permanent["max_hp"] = purity * 0.0012 * resonance
			"water":
				permanent["attack_speed"] = purity * 0.0008 * resonance
				permanent["cast_speed"] = purity * 0.0008 * resonance
			"fire":
				permanent["all_damage"] = purity * 0.0010 * resonance
			"earth":
				permanent["defense"] = purity * 0.0012 * resonance
		roots[element] = {
			"purity": purity,
			"perfected": purity == 100,
			"matching": matching,
			"permanent": permanent
		}
		for key in matching.keys():
			total["matching_" + str(key)] = float(total.get("matching_" + str(key), 0.0)) + float(matching[key])
		for key in permanent.keys():
			total[str(key)] = float(total.get(str(key), 0.0)) + float(permanent[key])

	return {
		"ok": true,
		"status": "DERIVED_CANDIDATE_NOT_APPLIED",
		"legacy_unmigrated": normalized.is_empty(),
		"root_values": normalized,
		"root_count": normalized.size(),
		"perfected_root_count": perfected_count,
		"resonance_multiplier": resonance,
		"roots": roots,
		"total_contributions": total
	}

static func current_values_from_birth_profile(profile_value: Variant) -> Dictionary:
	if not (profile_value is Dictionary) or not DiscipleBirthProfileV2.valid_complete_birth(profile_value):
		return {"ok": false, "reason": "missing_or_invalid_v2_birth_profile", "status": "LEGACY_NEUTRAL_NO_WRITE"}
	var layers: Dictionary = profile_value.get("layers", {})
	var root_layer: Dictionary = layers.get("spiritual_root", {})
	var raw_values: Variant = root_layer.get("current_values", {})
	if not (raw_values is Dictionary):
		return {"ok": false, "reason": "invalid_current_root_values", "status": "V2_PROFILE_REJECTED"}
	var evaluated := evaluate_base_roots(raw_values)
	if bool(evaluated.get("ok", false)):
		evaluated["source"] = "v2_birth_profile.current_values"
	return evaluated

static func current_values_for_disciple(disciple: DiscipleState) -> Dictionary:
	if disciple == null:
		return {"ok": false, "reason": "disciple_missing", "status": "LEGACY_NEUTRAL_NO_WRITE"}
	if not disciple.v2_birth_profile.is_empty():
		# A malformed/newer profile must fail closed. Never silently fall back to
		# legacy scalar data when a V2 envelope exists but cannot be validated.
		return current_values_from_birth_profile(disciple.v2_birth_profile)
	# Compatibility bridge for pre-V2 saves: reuse the saved root list and scalar
	# purity without writing or rerolling. No roots or invalid legacy purity stays neutral.
	var purity_fraction := float(disciple.spiritual_root_purity)
	if disciple.spiritual_root_elements.is_empty() or purity_fraction <= 0.0 or is_nan(purity_fraction) or is_inf(purity_fraction):
		return {"ok": true, "status": "LEGACY_NEUTRAL_NO_WRITE", "source": "legacy_empty_root_profile",
			"legacy_unmigrated": true, "root_values": {}, "root_count": 0,
			"perfected_root_count": 0, "resonance_multiplier": 1.0, "roots": {}, "total_contributions": {}}
	var legacy_values: Dictionary = {}
	var purity := clampi(int(round(purity_fraction * 100.0)), 1, 100)
	for raw_element in disciple.spiritual_root_elements:
		var element := str(raw_element).to_lower()
		if BASE_ELEMENTS.has(element):
			legacy_values[element] = purity
	var legacy_result := evaluate_base_roots(legacy_values)
	if bool(legacy_result.get("ok", false)):
		legacy_result["source"] = "legacy_global_purity_preview_only"
		legacy_result["legacy_unmigrated"] = true
	return legacy_result

static func combat_stat_sources(root_values: Dictionary, owner_id: String) -> Dictionary:
	if owner_id.is_empty():
		return {"ok": false, "reason": "root_source_owner_missing", "sources": []}
	var evaluated := evaluate_base_roots(root_values)
	if not bool(evaluated.get("ok", false)):
		return {"ok": false, "reason": str(evaluated.get("reason", "invalid_roots")), "sources": []}
	var sources: Array[Dictionary] = []
	var roots: Dictionary = evaluated.get("roots", {})
	var resonance := float(evaluated.get("resonance_multiplier", 1.0))
	for element in BASE_ELEMENTS:
		if not roots.has(element):
			continue
		var purity := float(roots[element].get("purity", 0))
		var prefix := "v63_root/%s/%s" % [owner_id, element]
		var permanent: Dictionary = roots[element].get("permanent", {})
		for channel in permanent.keys():
			# Global outgoing damage is consumed by MapBattle's existing packet
			# boundary, not by CombatStatsV2's registered stat-source channels.
			if str(channel) == "all_damage":
				continue
			var mode := "percentage_points" if str(channel) == "defense_penetration" else "percent_add"
			sources.append({"source_id": prefix + "/" + str(channel), "channel": str(channel),
				"mode": mode, "value": float(permanent[channel])})
		sources.append({"source_id": prefix + "/elemental_resistance", "channel": "elemental_resistance/" + element,
			"mode": "remaining_reduction", "value": purity * 0.0015 * resonance})
	return {"ok": true, "status": "DERIVED_CANDIDATE_NOT_APPLIED", "sources": sources,
		"resonance_multiplier": resonance, "root_count": roots.size(),
		"global_all_damage_bonus": float(evaluated.get("total_contributions", {}).get("all_damage", 0.0))}

static func attached_skill_effect_factor(actor: Dictionary, skill_id: String) -> float:
	var factors: Dictionary = actor.get("skill_factors", {}).get("__v63_root_skill_effect_factors", {})
	var factor := float(factors.get(skill_id, 1.0))
	if is_nan(factor) or is_inf(factor) or factor < 1.0 or factor > 1.6:
		return 1.0
	return factor

static func attached_skill_mastery_factor(actor: Dictionary, skill_id: String) -> float:
	var factors: Dictionary = actor.get("skill_factors", {}).get("__v63_root_skill_mastery_factors", {})
	var factor := float(factors.get(skill_id, 1.0))
	if is_nan(factor) or is_inf(factor) or factor < 1.0 or factor > 1.3:
		return 1.0
	return factor

static func skill_effect_factor(root_values: Dictionary, skill: Dictionary) -> Dictionary:
	var elements: Array = []
	var raw_required: Variant = skill.get("base_elements", [])
	if raw_required is Array and not raw_required.is_empty():
		elements = raw_required.duplicate()
	else:
		var base_element := str(skill.get("base_element", "")).to_lower()
		if base_element.is_empty():
			var element_tag := str(skill.get("element", "")).to_lower()
			if BASE_ELEMENTS.has(element_tag):
				base_element = element_tag
		if not base_element.is_empty():
			elements = [base_element]
	if elements.is_empty():
		return {"ok": true, "factor": 1.0, "bonus": 0.0, "matched": false,
			"status": "ADVANCED_ELEMENT_REQUIRES_EXPLICIT_BASE_TAG"}
	var bonus_result := required_multi_element_skill_effect_bonus(root_values, elements)
	if not bool(bonus_result.get("ok", false)):
		return bonus_result
	if not bool(bonus_result.get("compatible", bonus_result.get("matched", false))):
		return {"ok": true, "factor": 1.0, "bonus": 0.0, "matched": false,
			"status": "REQUIRED_ROOT_MISSING", "reason": str(bonus_result.get("reason", ""))}
	var bonus := float(bonus_result.get("bonus", 0.0))
	return {"ok": true, "factor": 1.0 + bonus, "bonus": bonus,
		"matched": bonus > 0.0, "status": str(bonus_result.get("status", "ROOT_MATCHED"))}

static func skill_mastery_factor(root_values: Dictionary, skill: Dictionary) -> Dictionary:
	var skill_result := skill_effect_factor(root_values, skill)
	if not bool(skill_result.get("ok", false)):
		return skill_result
	# V2 mastery is half the matching skill-effect coefficient, not a second
	# damage bonus. No scaling of study duration or resource cost occurs here.
	var mastery_bonus := (float(skill_result.get("factor", 1.0)) - 1.0) * 0.5
	return {"ok": true, "factor": 1.0 + mastery_bonus, "bonus": mastery_bonus,
		"matched": mastery_bonus > 0.0, "status": str(skill_result.get("status", "ROOT_MATCHED"))}

static func matching_skill_effect_bonus(root_values: Dictionary, skill_element: String) -> Dictionary:
	var evaluated := evaluate_base_roots(root_values)
	if not bool(evaluated.get("ok", false)):
		return evaluated
	var element := skill_element.to_lower()
	if not BASE_ELEMENTS.has(element):
		return {"ok": false, "reason": "skill_element_not_base_root:" + element}
	if not evaluated.roots.has(element):
		return {
			"ok": true,
			"matched": false,
			"bonus": 0.0,
			"status": "NO_MATCHING_BASE_ROOT"
		}
	var root: Dictionary = evaluated.roots[element]
	return {
		"ok": true,
		"matched": true,
		"bonus": float(root.matching.skill_effect),
		"effective_purity": int(root.purity),
		"resonance_multiplier": float(evaluated.resonance_multiplier),
		"status": "DERIVED_CANDIDATE_NOT_APPLIED"
	}

static func required_multi_element_skill_effect_bonus(root_values: Dictionary, required_elements: Array) -> Dictionary:
	var evaluated := evaluate_base_roots(root_values)
	if not bool(evaluated.get("ok", false)):
		return evaluated
	if required_elements.is_empty():
		return {"ok": true, "compatible": true, "bonus": 0.0, "status": "NO_ROOT_REQUIREMENT"}
	var required: Array[String] = []
	var seen: Dictionary = {}
	for raw_element in required_elements:
		var element := str(raw_element).to_lower()
		if not BASE_ELEMENTS.has(element):
			return {"ok": false, "reason": "unsupported_required_root:" + element}
		if seen.has(element):
			return {"ok": false, "reason": "duplicate_required_root:" + element}
		seen[element] = true
		required.append(element)
	if required.size() == 1:
		return matching_skill_effect_bonus(root_values, required[0])
	var purity_values: Array[int] = []
	for element in required:
		if not evaluated.roots.has(element):
			return {
				"ok": true,
				"compatible": false,
				"bonus": 0.0,
				"reason": "missing_required_base_root:" + element
			}
		purity_values.append(int(evaluated.roots[element].purity))
	purity_values.sort()
	var weakest := float(purity_values[0])
	var sum := 0.0
	for purity in purity_values:
		sum += float(purity)
	var average := sum / float(purity_values.size())
	var effective_purity := weakest * MULTI_ELEMENT_WEAK_ROOT_WEIGHT + average * MULTI_ELEMENT_MEAN_WEIGHT
	var bonus := effective_purity * MATCHING_SKILL_EFFECT_PER_PURITY * float(evaluated.resonance_multiplier)
	return {
		"ok": true,
		"compatible": true,
		"bonus": bonus,
		"effective_purity": effective_purity,
		"resonance_multiplier": float(evaluated.resonance_multiplier),
		"status": "DERIVED_CANDIDATE_NOT_APPLIED"
	}

static func elemental_matchup_factor(attacker_element: String, defender_element: String) -> float:
	var attacker := attacker_element.to_lower()
	var defender := defender_element.to_lower()
	if NEUTRAL_ELEMENTS.has(attacker) or NEUTRAL_ELEMENTS.has(defender):
		return 1.0
	if not BASE_ELEMENTS.has(attacker) or not BASE_ELEMENTS.has(defender):
		return 1.0
	if str(BEATS.get(attacker, "")) == defender:
		return 1.25
	if str(BEATS.get(defender, "")) == attacker:
		return 0.85
	return 1.0

