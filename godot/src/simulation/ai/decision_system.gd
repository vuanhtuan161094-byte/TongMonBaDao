class_name DecisionSystem
extends RefCounted

const REGION_RISK_WEIGHT := 35.0
const UNDERPOWER_PENALTY := 12.0

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
        elif disciple.stamina < 78.0 and disciple.wallet >= EconomySystem.SUPPLY_FEE and buy_score >= 10.0:
            chosen = &"BUY"
            reason = "Behavior profile accepts buying recovery supplies."
        else:
            chosen = &"HUNT"

    var result := {
        "action": str(chosen),
        "scores": scores,
        "reason": reason
    }
    disciple.last_decision = result.duplicate(true)
    return result

func choose_region(state: SimulationState, disciple: DiscipleState) -> StringName:
    var best_id: StringName = &""
    var best_score: float = -1.0e30
    var region_scores: Dictionary = {}

    for region_value in state.regions.values():
        var region: RegionState = region_value
        var risk_adjustment: float = (disciple.risk_bias * 2.0 - 1.0) * float(region.danger) * REGION_RISK_WEIGHT
        var power_gap: float = maxf(0.0, region.recommended_power - disciple.combat_power)
        var underpower_penalty: float = power_gap * UNDERPOWER_PENALTY
        var score: float = region.profit_modifier * 100.0 + risk_adjustment - underpower_penalty
        region_scores[str(region.id)] = score

        if score > best_score:
            best_score = score
            best_id = region.id

    disciple.last_decision["region_scores"] = region_scores
    disciple.last_decision["chosen_region"] = str(best_id)
    disciple.last_decision["region_reason"] = "Profit adjusted by risk tolerance and combat-power gap."
    return best_id
