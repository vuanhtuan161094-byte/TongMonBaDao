class_name GoalSystem
extends RefCounted

const GOAL_RECOVER := &"RECOVER"
const GOAL_WEALTH := &"WEALTH"
const GOAL_GLORY := &"GLORY"
const GOAL_SECURITY := &"SECURITY"
const GOAL_PREPARE := &"PREPARE"
const GOAL_GROWTH := &"GROWTH"

func update_goal(state: SimulationState, disciple: DiscipleState) -> StringName:
    var next_goal := choose_goal(disciple)
    if next_goal != disciple.active_goal:
        disciple.active_goal = next_goal
        disciple.goal_changed_tick = state.tick
    return disciple.active_goal

func choose_goal(disciple: DiscipleState) -> StringName:
    var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)

    # Immediate survival needs always override longer-horizon personality goals.
    if hp_ratio < 0.72 or disciple.stamina < 42.0:
        return GOAL_RECOVER

    # Carrying a meaningful haul creates a short-term wealth/liquidation goal.
    if disciple.inventory_count() >= 3:
        return GOAL_WEALTH

    # Personality drives the default long-horizon goal without introducing
    # a second AI authority. Existing biases remain the behavior vector.
    if disciple.risk_bias >= 0.75 and disciple.stamina >= 70.0:
        return GOAL_GLORY
    if disciple.survival_bias >= 0.75:
        return GOAL_SECURITY
    if disciple.spend_bias >= 0.58 and disciple.stamina < 88.0:
        return GOAL_PREPARE
    if disciple.wallet < EconomySystem.HEAL_FEE * 2:
        return GOAL_WEALTH

    return GOAL_GROWTH
