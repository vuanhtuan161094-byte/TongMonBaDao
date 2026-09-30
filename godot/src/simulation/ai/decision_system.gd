class_name DecisionSystem
extends RefCounted

const REGION_RISK_WEIGHT := 35.0
const UNDERPOWER_PENALTY := 12.0

var relationship_system := RelationshipSystem.new()
var memory_system := MemorySystem.new()
var organization_system := OrganizationSystem.new()
var needs_system := NeedsSystem.new()
var cultivation_system := CultivationSystem.new()

func evaluate(state: SimulationState, disciple: DiscipleState) -> Dictionary:
	var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
	var stamina_ratio := disciple.stamina / 100.0
	var inventory_count := disciple.inventory_count()

	var heal_score := (1.0 - hp_ratio) * (0.55 + disciple.survival_bias) * 100.0
	var rest_score := (1.0 - stamina_ratio) * 100.0
	var sell_score := minf(float(inventory_count) * 22.0, 100.0)
	var buy_score := disciple.spend_bias * (1.0 - stamina_ratio) * 80.0 if disciple.region_id == &"sect" else 0.0
	var hunt_score := (0.35 + stamina_ratio) * (0.55 + disciple.risk_bias * 0.35) * 72.0

	var scores := {"HUNT": hunt_score, "HEAL": heal_score, "REST": rest_score, "SELL": sell_score, "BUY": buy_score}
	if state.p1_goal_personality_enabled:
		_apply_goal_modifiers(scores, disciple.active_goal)
	if state.p1_organization_enabled:
		organization_system.apply_action_role_modifiers(state, disciple, scores)
	if state.sect.needs_enabled:
		needs_system.apply_action_modifiers(state, disciple, scores)
	if state.sect.cultivation_enabled:
		cultivation_system.apply_action_modifiers(state, disciple, scores)

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
			if state.sect.needs_enabled and not needs_system.can_heal(state):
				chosen = &"REST"
				reason = "Sect medicine stock is empty; paid healing is unavailable."
			elif disciple.wallet >= EconomySystem.HEAL_FEE:
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
		elif state.sect.cultivation_enabled:
			chosen = _choose_p2_sect_action(scores, disciple)
			reason = "Utility choice shaped by goal, personality, organization, resources, and cultivation priority."
		elif state.p1_goal_personality_enabled:
			chosen = _choose_p1_sect_action(scores, disciple)
			if state.sect.needs_enabled:
				reason = "Utility choice shaped by goal, organization, and sect resource pressure."
			elif state.p1_organization_enabled:
				reason = "Utility choice shaped by goal plus assigned organizational role."
			else:
				reason = "P1.1 utility choice shaped by personality goal %s." % str(disciple.active_goal)
		elif disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE and buy_score >= 10.0:
			chosen = &"BUY"
			reason = "Behavior profile accepts buying recovery supplies."
		else:
			chosen = &"HUNT"

	var result := {"action": str(chosen), "scores": scores, "reason": reason, "personality_id": str(disciple.personality_id), "active_goal": str(disciple.active_goal)}
	if state.p1_organization_enabled:
		result["organization_role"] = str(organization_system.role_for_disciple(state, disciple.id))
		var team := organization_system.team_for_disciple(state, disciple.id)
		result["team_id"] = str(team.id) if team != null else ""
	if state.sect.needs_enabled:
		result["medicine_stock"] = state.sect.medicine_stock
		result["supply_stock"] = state.sect.supply_stock
		result["lodging_capacity"] = state.sect.lodging_capacity
	if state.sect.cultivation_enabled:
		result["cultivation_stage"] = cultivation_system.stage_name(disciple)
		result["cultivation_progress"] = disciple.cultivation_progress
		result["cultivation_required"] = cultivation_system.required_progress(disciple)
		result["cultivation_directive"] = str(disciple.cultivation_directive)
		result["effective_combat_power"] = cultivation_system.effective_combat_power(state, disciple)
	disciple.last_decision = result.duplicate(true)
	return result

func choose_region(state: SimulationState, disciple: DiscipleState) -> StringName:
	var best_id: StringName = &""
	var best_score: float = -1.0e30
	var region_scores: Dictionary = {}
	var social_scores: Dictionary = {}
	var memory_scores: Dictionary = {}
	var organization_scores: Dictionary = {}
	var needs_scores: Dictionary = {}
	var effective_power := cultivation_system.effective_combat_power(state, disciple) if state.sect.cultivation_enabled else disciple.combat_power

	for region_value in state.regions.values():
		var region: RegionState = region_value
		var risk_adjustment: float = (disciple.risk_bias * 2.0 - 1.0) * float(region.danger) * REGION_RISK_WEIGHT
		var power_gap: float = maxf(0.0, region.recommended_power - effective_power)
		var underpower_penalty: float = power_gap * UNDERPOWER_PENALTY
		var score: float = region.profit_modifier * 100.0 + risk_adjustment - underpower_penalty
		if state.p1_goal_personality_enabled:
			score += _goal_region_modifier(disciple.active_goal, region)
		var social_modifier := relationship_system.region_social_modifier(state, disciple, region.id) if state.p1_relationships_enabled else 0.0
		score += social_modifier
		var memory_modifier := memory_system.region_memory_modifier(state, disciple, region.id) if state.p1_memory_enabled else 0.0
		score += memory_modifier
		var organization_modifier := organization_system.region_organization_modifier(state, disciple, region) if state.p1_organization_enabled else 0.0
		score += organization_modifier
		var needs_modifier := needs_system.region_need_modifier(state, region) if state.sect.needs_enabled else 0.0
		score += needs_modifier
		region_scores[str(region.id)] = score
		social_scores[str(region.id)] = social_modifier
		memory_scores[str(region.id)] = memory_modifier
		organization_scores[str(region.id)] = organization_modifier
		needs_scores[str(region.id)] = needs_modifier
		if score > best_score:
			best_score = score
			best_id = region.id

	disciple.last_decision["region_scores"] = region_scores
	disciple.last_decision["social_region_scores"] = social_scores
	if state.p1_memory_enabled:
		disciple.last_decision["memory_region_scores"] = memory_scores
	if state.p1_organization_enabled:
		disciple.last_decision["organization_region_scores"] = organization_scores
	if state.sect.needs_enabled:
		disciple.last_decision["needs_region_scores"] = needs_scores
	if state.sect.cultivation_enabled:
		disciple.last_decision["effective_combat_power"] = effective_power
	disciple.last_decision["chosen_region"] = str(best_id)
	if state.sect.cultivation_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, effective realm power, goal, relationships, memory, organization, and sect resources."
	elif state.sect.needs_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, relationships, memory, organization, and sect resource pressure."
	elif state.p1_organization_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, relationships, memory, role, and team leadership."
	elif state.p1_memory_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, relationships, and consequential memory."
	elif state.p1_relationships_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk, power, goal, and sparse relationship influence."
	elif state.p1_goal_personality_enabled:
		disciple.last_decision["region_reason"] = "Profit, risk tolerance, power gap, and active goal modifier."
	else:
		disciple.last_decision["region_reason"] = "Profit adjusted by risk tolerance and combat-power gap."
	return best_id

func _choose_p2_sect_action(scores: Dictionary, disciple: DiscipleState) -> StringName:
	var candidates := [&"HUNT", &"CULTIVATE", &"BREAKTHROUGH"]
	if disciple.stamina < 88.0:
		candidates.append(&"REST")
	if disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE:
		candidates.append(&"BUY")
	var chosen := StringName(candidates[0])
	var best_score := float(scores.get(str(chosen), -1.0e30))
	for candidate in candidates:
		var score := float(scores.get(str(candidate), -1.0e30))
		if score > best_score:
			best_score = score
			chosen = candidate
	return chosen

func _choose_p1_sect_action(scores: Dictionary, disciple: DiscipleState) -> StringName:
	var chosen: StringName = &"HUNT"
	var best_score := float(scores.get("HUNT", 0.0))
	if disciple.stamina < 88.0 and float(scores.get("REST", 0.0)) > best_score:
		chosen = &"REST"
		best_score = float(scores.get("REST", 0.0))
	if disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE and float(scores.get("BUY", 0.0)) > best_score:
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
