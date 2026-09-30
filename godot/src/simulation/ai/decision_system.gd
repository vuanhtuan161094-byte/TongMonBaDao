class_name DecisionSystem
extends RefCounted

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
        if hp_ratio < 0.72 and disciple.wallet >= 12:
            chosen = &"HEAL"
            reason = "Injured and can afford sect healing."
        elif disciple.stamina < 42.0:
            chosen = &"REST"
            reason = "Stamina below rest threshold."
        elif inventory_count > 0:
            chosen = &"SELL"
            reason = "Returned with loot to liquidate."
        elif disciple.stamina < 78.0 and disciple.wallet >= 20 and buy_score >= 10.0:
            chosen = &"BUY"
            reason = "Behavior profile accepts buying recovery supplies."
        else:
            chosen = &"HUNT"

    var result := {
        "action": chosen,
        "scores": scores,
        "reason": reason
    }
    disciple.last_decision = result.duplicate(true)
    return result

func choose_region(state: SimulationState, disciple: DiscipleState) -> StringName:
    var best_id: StringName = &""
    var best_score := -1.0e30

    for region in state.regions.values():
        var danger_term := float(region.danger) * (110.0 * disciple.risk_bias - 70.0)
        var score := region.profit_modifier * 100.0 + danger_term
        if score > best_score:
            best_score = score
            best_id = region.id

    return best_id
