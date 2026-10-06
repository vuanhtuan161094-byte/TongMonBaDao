class_name WarehouseSystem
extends RefCounted

const MAX_SAFE_STACK := 9000000000000000

var registry := ResourceRegistry.new()

func initialize(state: SimulationState) -> void:
    if not state.p3_7_buildings_enabled:
        return
    ensure_migrated(state)

func ensure_migrated(state: SimulationState) -> void:
    if not state.p3_7_buildings_enabled or state.sect.p3_7_resources_enabled:
        return

    state.sect.p3_7_resources_enabled = true
    _import_legacy_bucket(state, state.sect.forge_materials)
    _import_legacy_bucket(state, state.sect.technique_materials)
    state.sect.forge_materials.clear()
    state.sect.technique_materials.clear()
    state.sect.warehouse_event_count += 1

func quantity(state: SimulationState, resource_id: StringName) -> int:
    if not state.sect.p3_7_resources_enabled:
        return 0
    return maxi(int(state.sect.warehouse_resources.get(str(resource_id), 0)), 0)

func rule(state: SimulationState, resource_id: StringName) -> Dictionary:
    var raw = state.sect.warehouse_rules.get(str(resource_id), {})
    if not (raw is Dictionary):
        return {"reserve_min": 0, "locked": false}
    return {
        "reserve_min": maxi(int(raw.get("reserve_min", 0)), 0),
        "locked": bool(raw.get("locked", false))
    }

func available_quantity(state: SimulationState, resource_id: StringName, ignore_rules: bool = false) -> int:
    var stored := quantity(state, resource_id)
    if ignore_rules:
        return stored
    var current_rule := rule(state, resource_id)
    if bool(current_rule.get("locked", false)):
        return 0
    return maxi(stored - int(current_rule.get("reserve_min", 0)), 0)

func set_rule(state: SimulationState, resource_id: StringName, reserve_min: int, locked: bool) -> bool:
    if not state.sect.p3_7_resources_enabled or not registry.has(resource_id):
        return false
    state.sect.warehouse_rules[str(resource_id)] = {
        "reserve_min": maxi(reserve_min, 0),
        "locked": locked
    }
    state.sect.warehouse_event_count += 1
    return true

func add(state: SimulationState, resource_id: StringName, amount: int) -> bool:
    if not state.sect.p3_7_resources_enabled or not registry.has(resource_id) or amount <= 0:
        return false
    var current := quantity(state, resource_id)
    if amount > MAX_SAFE_STACK - current:
        return false
    state.sect.warehouse_resources[str(resource_id)] = current + amount
    state.sect.warehouse_event_count += 1
    return true

func can_consume(state: SimulationState, resource_id: StringName, amount: int, ignore_rules: bool = false) -> bool:
    if not state.sect.p3_7_resources_enabled or not registry.has(resource_id) or amount < 0:
        return false
    if amount == 0:
        return true
    return available_quantity(state, resource_id, ignore_rules) >= amount

func consume(state: SimulationState, resource_id: StringName, amount: int, ignore_rules: bool = false) -> bool:
    if amount == 0:
        return can_consume(state, resource_id, amount, ignore_rules)
    if not can_consume(state, resource_id, amount, ignore_rules):
        return false
    var next := quantity(state, resource_id) - amount
    if next <= 0:
        state.sect.warehouse_resources.erase(str(resource_id))
    else:
        state.sect.warehouse_resources[str(resource_id)] = next
    state.sect.warehouse_event_count += 1
    return true

func total_pham_luc(state: SimulationState, resource_id: StringName) -> int:
    return quantity(state, resource_id) * registry.base_pham_luc(resource_id)

func validate_invariants(state: SimulationState) -> Array[String]:
    var errors := registry.validate_definitions()
    if not state.sect.p3_7_resources_enabled:
        if not state.sect.warehouse_resources.is_empty() or not state.sect.warehouse_rules.is_empty() or state.sect.warehouse_event_count != 0:
            errors.append("P3.7 warehouse data exists while resource authority is disabled.")
        return errors

    if not state.p3_7_buildings_enabled:
        errors.append("P3.7 resource authority requires P3.7 building authority.")

    if not state.sect.forge_materials.is_empty():
        errors.append("Legacy forge_materials must be empty when canonical P3.7 warehouse is enabled.")
    if not state.sect.technique_materials.is_empty():
        errors.append("Legacy technique_materials must be empty when canonical P3.7 warehouse is enabled.")
    if state.sect.warehouse_event_count < 0:
        errors.append("Warehouse event count is negative.")

    var ids: Array = state.sect.warehouse_resources.keys()
    ids.sort()
    for raw_id in ids:
        var resource_id := StringName(raw_id)
        if not registry.has(resource_id):
            errors.append("Warehouse contains unknown resource %s." % resource_id)
            continue
        var amount := int(state.sect.warehouse_resources[raw_id])
        if amount < 0 or amount > MAX_SAFE_STACK:
            errors.append("Warehouse resource %s has invalid quantity." % resource_id)

    var rule_ids: Array = state.sect.warehouse_rules.keys()
    rule_ids.sort()
    for raw_id in rule_ids:
        var resource_id := StringName(raw_id)
        if not registry.has(resource_id):
            errors.append("Warehouse rule references unknown resource %s." % resource_id)
            continue
        var current_rule = state.sect.warehouse_rules[raw_id]
        if not (current_rule is Dictionary):
            errors.append("Warehouse rule %s has invalid storage." % resource_id)
            continue
        if int(current_rule.get("reserve_min", 0)) < 0:
            errors.append("Warehouse rule %s has negative reserve." % resource_id)
    return errors

func _import_legacy_bucket(state: SimulationState, bucket: Dictionary) -> void:
    var ids: Array = bucket.keys()
    ids.sort()
    for raw_id in ids:
        var resource_id := StringName(raw_id)
        var amount := maxi(int(bucket[raw_id]), 0)
        if amount <= 0:
            continue
        if not registry.has(resource_id):
            push_error("WarehouseSystem: cannot migrate unknown legacy resource %s." % resource_id)
            continue
        var current := maxi(int(state.sect.warehouse_resources.get(str(resource_id), 0)), 0)
        state.sect.warehouse_resources[str(resource_id)] = current + amount
