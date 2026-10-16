class_name NeedsSystem
extends RefCounted

const PRIORITY_BALANCED := &"balanced"
const PRIORITY_MEDICINE := &"medicine"
const PRIORITY_SUPPLIES := &"supplies"
const VALID_PRIORITIES := [PRIORITY_BALANCED, PRIORITY_MEDICINE, PRIORITY_SUPPLIES]

const MEDICINE_CAP := 60
const SUPPLY_CAP := 90
const HEALING_PILL_ID := &"hoi_xuan_dan"
const HEALING_PILL_HP := 55.0
const LOGISTICS_INTERVAL := 30
const LODGING_EXPANSION_COST_PER_SLOT := 8
const SUPPLIED_TRAVEL_STAMINA_COST := 7.0
const UNSUPPLIED_TRAVEL_STAMINA_COST := 13.0
const MIN_REST_MULTIPLIER := 0.45
const V2_FOOD_RESOURCE_ID := &"linh_coc"
const V2_FOOD_INTERVAL := 30
const V2_FOOD_PER_DISCIPLE := 2

var bloodline_system := BloodlineSystem.new()
var physique_system := PhysiqueSystem.new()
var warehouse := WarehouseSystem.new()

func initialize(state: SimulationState, medicine: int = 18, supplies: int = 24, lodging: int = 6) -> void:
    state.sect.needs_enabled = true
    state.sect.medicine_stock = clampi(medicine, 0, MEDICINE_CAP)
    state.sect.supply_stock = clampi(supplies, 0, SUPPLY_CAP)
    state.sect.lodging_capacity = maxi(lodging, 1)
    if not VALID_PRIORITIES.has(state.sect.needs_priority):
        state.sect.needs_priority = PRIORITY_BALANCED

func set_priority(state: SimulationState, priority: StringName) -> bool:
    if not state.sect.needs_enabled or not VALID_PRIORITIES.has(priority):
        return false
    if state.sect.needs_priority == priority:
        return true
    state.sect.needs_priority = priority
    state.sect.needs_event_count += 1
    return true

func apply_action_modifiers(state: SimulationState, disciple: DiscipleState, scores: Dictionary) -> void:
    if not state.sect.needs_enabled:
        return

    if state.sect.supply_stock <= 0:
        scores["HUNT"] = float(scores.get("HUNT", 0.0)) - 28.0
    elif state.sect.supply_stock < maxi(3, state.disciples.size()):
        scores["HUNT"] = float(scores.get("HUNT", 0.0)) - 10.0

    if state.sect.medicine_stock <= 0 and disciple.hp < disciple.max_hp * 0.90:
        scores["HEAL"] = float(scores.get("HEAL", 0.0)) - 40.0
        scores["REST"] = float(scores.get("REST", 0.0)) + 12.0

func region_need_modifier(state: SimulationState, region: RegionState) -> float:
    if not state.sect.needs_enabled:
        return 0.0
    if state.sect.supply_stock <= 0:
        return -float(region.danger) * 30.0
    if state.sect.supply_stock < maxi(3, state.disciples.size()):
        return -float(region.danger) * 9.0
    return 0.0

func can_heal(state: SimulationState) -> bool:
    return not state.sect.needs_enabled or state.sect.medicine_stock > 0

func use_healing_pill(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.needs_enabled or not state.sect.p3_7_resources_enabled:
        return false
    if disciple == null or disciple.region_id != &"sect" or disciple.hp >= disciple.max_hp:
        return false
    if not warehouse.consume(state, HEALING_PILL_ID, 1):
        return false
    disciple.hp = minf(disciple.max_hp, disciple.hp + HEALING_PILL_HP)
    state.sect.needs_stats["healing_pills_used"] = int(state.sect.needs_stats.get("healing_pills_used", 0)) + 1
    state.sect.needs_event_count += 1
    return true

func heal_with_medicine(state: SimulationState, disciple: DiscipleState, economy: EconomySystem) -> bool:
    if not state.sect.needs_enabled:
        return economy.heal(state, disciple)
    if state.sect.medicine_stock <= 0:
        return false
    if not economy.heal(state, disciple):
        return false

    state.sect.medicine_stock -= 1
    state.sect.needs_stats["medicine_used"] = int(state.sect.needs_stats.get("medicine_used", 0)) + 1
    state.sect.needs_event_count += 1
    return true

func prepare_departure(state: SimulationState, disciple: DiscipleState) -> bool:
    if not state.sect.needs_enabled:
        disciple.metrics.erase("p1_6_departure_supplied")
        return true

    var supplied := state.sect.supply_stock > 0
    if supplied:
        state.sect.supply_stock -= 1
        state.sect.needs_stats["supplies_used"] = int(state.sect.needs_stats.get("supplies_used", 0)) + 1
        disciple.metrics["p1_6_departure_supplied"] = 1
        if state.sect.bloodlines_enabled:
            var extra_cost := bloodline_system.extra_departure_supply_cost(state, disciple)
            var extra_used := mini(extra_cost, state.sect.supply_stock)
            if extra_used > 0:
                state.sect.supply_stock -= extra_used
                state.sect.needs_stats["supplies_used"] = int(state.sect.needs_stats.get("supplies_used", 0)) + extra_used
                disciple.metrics["bloodline_extra_supplies"] = int(disciple.metrics.get("bloodline_extra_supplies", 0)) + extra_used
    else:
        disciple.metrics["p1_6_departure_supplied"] = 0
    state.sect.needs_event_count += 1
    return supplied

func consume_travel_stamina_cost(state: SimulationState, disciple: DiscipleState) -> float:
    if not state.sect.needs_enabled:
        return 8.0
    var supplied := int(disciple.metrics.get("p1_6_departure_supplied", 0)) == 1
    disciple.metrics.erase("p1_6_departure_supplied")
    return SUPPLIED_TRAVEL_STAMINA_COST if supplied else UNSUPPLIED_TRAVEL_STAMINA_COST

func rest_recovery_multiplier(state: SimulationState) -> float:
    if not state.sect.needs_enabled:
        return 1.0
    var population := maxi(state.disciples.size(), 1)
    var ratio := float(state.sect.lodging_capacity) / float(population)
    return clampf(ratio, MIN_REST_MULTIPLIER, 1.0)

func apply_rest(
    state: SimulationState, disciple: DiscipleState,
    recover_stamina: bool = true
) -> float:
    var lodging_multiplier := rest_recovery_multiplier(state)
    var multiplier := lodging_multiplier
    if state.sect.bloodlines_enabled:
        multiplier *= bloodline_system.rest_recovery_multiplier(state, disciple)
    if state.sect.physiques_enabled:
        multiplier *= physique_system.recovery_multiplier(state, disciple)
    # V2 expedition stamina is not an ordinary in-sect rest meter. Legacy
    # callers keep the historical behavior through the default true argument.
    if recover_stamina:
        disciple.stamina = minf(100.0, disciple.stamina + 48.0 * multiplier)
    disciple.hp = minf(disciple.max_hp, disciple.hp + 5.0 * multiplier)
    disciple.metrics["rests"] = int(disciple.metrics.get("rests", 0)) + 1
    if state.sect.needs_enabled and lodging_multiplier < 0.999999:
        state.sect.needs_stats["overcrowded_rests"] = int(state.sect.needs_stats.get("overcrowded_rests", 0)) + 1
        state.sect.needs_event_count += 1
    return multiplier

func process_logistics_tick(state: SimulationState) -> void:
    if not state.sect.needs_enabled or state.tick <= 0 or state.tick % LOGISTICS_INTERVAL != 0:
        return

    # Economy V2 minimum food sink. Two Linh Cốc units per disciple per 30
    # simulation minutes is intentionally simple and population-scaled. It
    # respects Warehouse reserve/lock rules and adds no starvation penalty in
    # this packet; shortage is audit data only.
    if state.sect.p3_7_resources_enabled and state.tick % V2_FOOD_INTERVAL == 0:
        var required_food := maxi(state.disciples.size(),0) * V2_FOOD_PER_DISCIPLE
        var available_food := warehouse.available_quantity(state,V2_FOOD_RESOURCE_ID)
        var consumed_food := mini(required_food,available_food)
        if consumed_food > 0:
            warehouse.consume(state,V2_FOOD_RESOURCE_ID,consumed_food)
        state.sect.needs_stats["v2_linh_coc_consumed"] = int(
            state.sect.needs_stats.get("v2_linh_coc_consumed",0)
        ) + consumed_food
        state.sect.needs_stats["v2_linh_coc_shortage"] = int(
            state.sect.needs_stats.get("v2_linh_coc_shortage",0)
        ) + maxi(required_food-consumed_food,0)
        if required_food > 0:
            state.sect.needs_event_count += 1

    # P1.6 legacy logistics production is keyed from the P1.5 combat/adventure
    # role. Use the semantic accessor instead of treating role storage as a
    # profession system; P2.7+ workforce logistics remains a separate concept.
    var organization := OrganizationSystem.new()
    var logistics_count := 0
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        if organization.combat_role_for_disciple(state, StringName(raw_id)) == OrganizationSystem.ROLE_LOGISTICS:
            logistics_count += 1
    if logistics_count <= 0:
        return

    var medicine_per_worker := 1
    var supplies_per_worker := 2
    match state.sect.needs_priority:
        PRIORITY_MEDICINE:
            medicine_per_worker = 3
            supplies_per_worker = 1
        PRIORITY_SUPPLIES:
            medicine_per_worker = 1
            supplies_per_worker = 4
        _:
            medicine_per_worker = 1
            supplies_per_worker = 2

    var old_medicine := state.sect.medicine_stock
    var old_supplies := state.sect.supply_stock
    state.sect.medicine_stock = mini(MEDICINE_CAP, old_medicine + medicine_per_worker * logistics_count)
    state.sect.supply_stock = mini(SUPPLY_CAP, old_supplies + supplies_per_worker * logistics_count)

    var medicine_gain := state.sect.medicine_stock - old_medicine
    var supplies_gain := state.sect.supply_stock - old_supplies
    state.sect.needs_stats["medicine_produced"] = int(state.sect.needs_stats.get("medicine_produced", 0)) + medicine_gain
    state.sect.needs_stats["supplies_produced"] = int(state.sect.needs_stats.get("supplies_produced", 0)) + supplies_gain
    if medicine_gain > 0 or supplies_gain > 0:
        state.sect.needs_event_count += 1

func expand_lodging(state: SimulationState, slots: int = 1) -> bool:
    if not state.sect.needs_enabled or slots <= 0:
        return false
    var cost := slots * LODGING_EXPANSION_COST_PER_SLOT
    if state.sect.supply_stock < cost:
        return false

    state.sect.supply_stock -= cost
    state.sect.needs_stats["supplies_used"] = int(state.sect.needs_stats.get("supplies_used", 0)) + cost
    state.sect.lodging_capacity += slots
    state.sect.needs_stats["lodging_expansions"] = int(state.sect.needs_stats.get("lodging_expansions", 0)) + slots
    state.sect.needs_event_count += 1
    return true

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if not state.sect.needs_enabled:
        return errors
    if state.sect.medicine_stock < 0 or state.sect.medicine_stock > MEDICINE_CAP:
        errors.append("Medicine stock is outside the configured bounds.")
    if state.sect.supply_stock < 0 or state.sect.supply_stock > SUPPLY_CAP:
        errors.append("Supply stock is outside the configured bounds.")
    if state.sect.lodging_capacity <= 0:
        errors.append("Lodging capacity must be positive.")
    if not VALID_PRIORITIES.has(state.sect.needs_priority):
        errors.append("Sect needs priority is invalid.")
    for value in state.sect.needs_stats.values():
        if int(value) < 0:
            errors.append("Sect needs statistics cannot be negative.")
            break
    return errors
