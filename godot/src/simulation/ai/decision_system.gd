class_name DecisionSystem
extends RefCounted

const REGION_RISK_WEIGHT := 35.0
const UNDERPOWER_PENALTY := 12.0

var relationship_system := RelationshipSystem.new()
var memory_system := MemorySystem.new()

func evaluate(state: SimulationState, disciple: DiscipleState) -> Dictionary:
	var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
	var stamina_ratio := disciple.stamina / 100.0
	var inventory_count := disciple.inventory_count()

	var heal_score := (1.0 - hp_ratio) * (0.55 + disciple.survival_bias) * 100.0
	var rest_score := (1.0 - stamina_ratio) * 100.0
	var sell_score := minf(float(inventory_count) * 22.0, 100.0)
	var buy_score := disciple.spend_bias * (1.0 - stamina_ratio) * 80.0 if disciple.region_id == &"sect" else 0.0
	var hunt_score := (0.35 + stamina_ratio) * (0.55 + disciple.risk_bias * 0.35) * 72.0

	var scores := {
		"HUNT": hunt_score,
		"HEAL": heal_score,
		"REST": rest_score,
		"SELL": sell_score,
		"BUY": buy_score
	}

	if state.p1_goal_personality_enabled:
		_apply_goal_modifiers(scores, disciple.active_goal)

	var chosen: StringName = &"HUNT"
	var reason := "Healthy enough to continue autonomous hunting."

	if disciple.region_id != &"sect":
		if hp_ratio <= disciple.retreat_hp_ratio():
			chosen = &"RETURN_SECT"
			reason = "HP crossed personal retreat threshold."
		elif disciple.stamina <= 22.0:
			chosen = &"RETURN_SECT"
			reason = "Stamina too low to safely continue."
		elif inventory_count >= 4:
			chosen = &"RETURN_SECT"
			reason = "Inventory reached sell threshold."
		else:
			chosen = &"HUNT"
	else:
		if hp_ratio < 0.72:
			if disciple.wallet >= EconomySystem.HEAL_FEE:
				chosen = &"HEAL"
				reason = "Injured and can afford sect healing."
			else:
				chosen = &"REST"
				reason = "Injured but cannot afford paid healing; use free basic recovery."
		elif disciple.stamina < 42.0:
			chosen = &"REST"
			reason = "Stamina below rest threshold."
		elif inventory_count > 0:
			chosen = &"SELL"
			reason = "Returned with loot to liquidate."
		elif state.p1_goal_personality_enabled:
			chosen = _choose_p1_sect_action(scores, disciple)
			reason = "P1.1 utility choice shaped by personality goal %s." % str(disciple.active_goal)
		elif disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE and buy_score >= 10.0:
			chosen = &"BUY"
			reason = "Behavior profile accepts buying recovery supplies."
		else:
			chosen = &"HUNT"

	var result := {
		"action": str(chosen),
		"scores": scores,
		"reason": reason,
		"personality_id": str(disciple.personality_id),
		"active_goal": str(disciple.active_goal)
	}
	disciple.last_decision = result.duplicate(true)
	return result

func choose_region(state: SimulationState, disciple: DiscipleState) -> StringName:
	var best_id: StringName = &""
	var best_score: float = -1.0e30
	var region_scores: Dictionary = {}
	var social_scores: Dictionary = {}
	var memory_scores: Dictionary = {}

	for region_value in state.regions.values():
		var region: RegionState = region_value
		var risk_adjustment: float = (disciple.risk_bias * 2.0 - 1.0) * float(region.danger) * REGION_RISK_WEIGHT
		var power_gap: float = maxf(0.0, region.recommended_power - disciple.combat_power)
		var underpower_penalty: float = power_gap * UNDERPOWER_PENALTY
		var score: float = region.profit_modifier * 100.0 + risk_adjustment - underpower_penalty

		if state.p1_goal_personality_enabled:
			score += _goal_region_modifier(disciple.active_goal, region)

		var social_modifier := 0.0
		if state.p1_relationships_enabled:
			social_modifier = relationship_system.region_social_modifier(state, disciple, region.id)
			score += social_modifier

		var memory_modifier := 0.0
		if state.p1_memory_enabled:
			memory_modifier = memory_system.region_memory_modifier(state, disciple, region.id)
			score += memory_modifier

		region_scores[str(region.id)] = score
		social_scores[str(region.id)] = social_modifier
		memory_scores[str(region.id)] = memory_modifier

		if score > best_score:
			best_score = score
			best_id = region.id

	disciple.last_decision["region_scores"] = region_scores
	disciple.last_decision["social_region_scores"] = social_scores
	if state.p1_memory_enabled:
		disciple.last_decision["memory_region_scores"] = memory_scores
	disciple.last_decision["chosen_region"] = str(best_id)
	if state.p1_memory_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, relationships, and consequential memory."
	elif state.p1_relationships_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, and sparse relationship influence."
	elif state.p1_goal_personality_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk tolerance, power gap, and active goal modifier."
	else:
		disciple.last_decision["region_reason"] = "Profit adjusted by risk tolerance and combat-power gap."
	return best_id

func _choose_p1_sect_action(scores: Dictionary, disciple: DiscipleState) -> StringName:
	var chosen: StringName = &"HUNT"
	var best_score := float(scores.get("HUNT", 0.0))

	if disciple.stamina < 88.0:
		var rest_score := float(scores.get("REST", 0.0))
		if rest_score > best_score:
			chosen = &"REST"
			best_score = rest_score

	if disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE:
		var buy_score := float(scores.get("BUY", 0.0))
		if buy_score > best_score:
			chosen = &"BUY"

	return chosen

func _apply_goal_modifiers(scores: Dictionary, goal: StringName) -> void:
	match goal:
		GoalSystem.GOAL_RECOVER:
			scores["HEAL"] = float(scores["HEAL"]) + 30.0
			scores["REST"] = float(scores["REST"]) + 40.0
			scores["BUY"] = float(scores["BUY"]) + 10.0
			scores["HUNT"] = float(scores["HUNT"]) - 35.0
		GoalSystem.GOAL_WEALTH:
			scores["SELL"] = float(scores["SELL"]) + 35.0
			scores["HUNT"] = float(scores["HUNT"]) + 15.0
			scores["BUY"] = float(scores["BUY"]) - 15.0
		GoalSystem.GOAL_GLORY:
			scores["HUNT"] = float(scores["HUNT"]) + 30.0
			scores["REST"] = float(scores["REST"]) - 10.0
		GoalSystem.GOAL_SECURITY:
			scores["HEAL"] = float(scores["HEAL"]) + 15.0
			scores["REST"] = float(scores["REST"]) + 20.0
			scores["HUNT"] = float(scores["HUNT"]) - 15.0
		GoalSystem.GOAL_PREPARE:
			scores["BUY"] = float(scores["BUY"]) + 30.0
			scores["REST"] = float(scores["REST"]) + 10.0
		GoalSystem.GOAL_GROWTH:
			scores["HUNT"] = float(scores["HUNT"]) + 10.0

func _goal_region_modifier(goal: StringName, region: RegionState) -> float:
	match goal:
		GoalSystem.GOAL_GLORY:
			return float(region.danger) * 18.0
		GoalSystem.GOAL_SECURITY, GoalSystem.GOAL_RECOVER:
			return -float(region.danger) * 22.0
		GoalSystem.GOAL_WEALTH:
			return region.profit_modifier * 15.0
		GoalSystem.GOAL_GROWTH:
			return float(region.danger) * 6.0
		_:
			return 0.0
