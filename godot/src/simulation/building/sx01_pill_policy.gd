class_name SX01PillPolicy
extends RefCounted

# SX-01 is a policy over the EXISTING Warehouse, Alchemy and B3 consumers.
# It never grants items, HP or Tu Vi; legacy saves without this policy stay off.
const VERSION := 1
const HXD := &"hoi_xuan_dan"
const TQD := &"tu_khi_dan"
const DEFAULTS := {
    "version": VERSION,
    "enabled": true,
    "auto_production": true,
    # Conservative default keeps previous O8/legacy recipe behavior until
    # Tông Chủ explicitly selects demand mode in the Alchemy UI.
    "recipe_mode": "fixed",
    "target_hoi_xuan_dan": 6,
    "target_tu_khi_dan": 12,
    "auto_use_hoi_xuan_dan": true,
    "auto_use_tu_khi_dan": true,
    "heal_hp_percent": 60,
    "auto_tu_khi_per_day": 2,
    "medical_soft_reserve": 2,
    "auto_day": -1,
    "auto_tu_khi_used": {},
    "priority_tuvi_ids": {}
}

static func install_new_game(state: SimulationState) -> void:
    if state == null or not state.sect.p3_7_resources_enabled or not state.sect.v2_training_enabled:
        return
    if state.sect.sx01_pill_policy.is_empty():
        state.sect.sx01_pill_policy = DEFAULTS.duplicate(true)

static func active(state: SimulationState) -> bool:
    return state != null and state.sect != null and state.sect.p3_7_resources_enabled \
        and int(state.sect.sx01_pill_policy.get("version", 0)) == VERSION \
        and bool(state.sect.sx01_pill_policy.get("enabled", false))

static func configure(state: SimulationState, key: String, value: Variant) -> Dictionary:
    if not active(state):
        return {"ok": false, "reason": "sx01_not_enabled"}
    var config := state.sect.sx01_pill_policy
    if not DEFAULTS.has(key) or key in ["version", "auto_day", "auto_tu_khi_used"]:
        return {"ok": false, "reason": "sx01_invalid_key"}
    var old = DEFAULTS[key]
    if old is bool:
        if not (value is bool):
            return {"ok": false, "reason": "sx01_wrong_type"}
    elif old is int:
        if not (value is int):
            return {"ok": false, "reason": "sx01_wrong_type"}
        var maximum := 1000 if key.begins_with("target_") else 100
        if key == "auto_tu_khi_per_day":
            maximum = 20
        if key == "medical_soft_reserve":
            maximum = 100
        if int(value) < 0 or int(value) > maximum or (key == "heal_hp_percent" and (int(value) < 40 or int(value) > 80)):
            return {"ok": false, "reason": "sx01_out_of_range"}
    elif key == "recipe_mode":
        if not (value is String) or not ["demand", "fixed"].has(value):
            return {"ok": false, "reason": "sx01_invalid_mode"}
    else:
        return {"ok": false, "reason": "sx01_wrong_type"}
    config[key] = value
    return {"ok": true, "key": key, "value": value}

# Tu Vi priority may be granted to a resting / HOLD disciple; cultivation
# actively running stays blocked by the original B3 busy gate.
static func set_tuvi_priority(state: SimulationState, disciple_id: StringName, enabled: bool) -> Dictionary:
    if not active(state) or not state.disciples.has(disciple_id):
        return {"ok": false, "reason": "sx01_invalid_priority_target"}
    var flags: Dictionary = state.sect.sx01_pill_policy.get("priority_tuvi_ids", {})
    if enabled:
        flags[str(disciple_id)] = true
    else:
        flags.erase(str(disciple_id))
    state.sect.sx01_pill_policy["priority_tuvi_ids"] = flags
    return {"ok": true, "disciple_id": str(disciple_id), "enabled": enabled}

static func stock_plan(state: SimulationState, hall: BuildingState) -> Dictionary:
    var warehouse := WarehouseSystem.new()
    var held_hxd := warehouse.quantity(state, HXD)
    var held_tqd := warehouse.quantity(state, TQD)
    var pending_hxd := 0
    var pending_tqd := 0
    if hall != null:
        for raw_job in BuildingSystem.new().alchemy_jobs(state, hall):
            if not (raw_job is Dictionary):
                continue
            var resource_id := str(raw_job.get("output_resource_id", ""))
            if resource_id == str(HXD):
                pending_hxd += maxi(int(raw_job.get("output_quantity", 0)), 0)
            elif resource_id == str(TQD):
                pending_tqd += maxi(int(raw_job.get("output_quantity", 0)), 0)
    var policy := state.sect.sx01_pill_policy
    var deficit_hxd := maxi(0, int(policy.get("target_hoi_xuan_dan", 0)) - held_hxd - pending_hxd)
    var deficit_tqd := maxi(0, int(policy.get("target_tu_khi_dan", 0)) - held_tqd - pending_tqd)
    return {
        "held_hxd": held_hxd, "held_tqd": held_tqd,
        "pending_hxd": pending_hxd, "pending_tqd": pending_tqd,
        "deficit_hxd": deficit_hxd, "deficit_tqd": deficit_tqd
    }

# Pure read-only planner. This is called in work_available too, where no
# recipe selection or other persistent state may be mutated.
static func planned_recipe(state: SimulationState, hall: BuildingState) -> StringName:
    if not active(state) or not bool(state.sect.sx01_pill_policy.get("auto_production", false)) \
        or str(state.sect.sx01_pill_policy.get("recipe_mode", "fixed")) != "demand":
        return StringName(hall.production_state.get("recipe_id", "hoi_xuan_dan"))
    var plan := stock_plan(state, hall)
    var warehouse := WarehouseSystem.new()
    var registry := AlchemyRecipeRegistry.new()
    var reserve := maxi(int(state.sect.sx01_pill_policy.get("medical_soft_reserve", 0)), 0)
    var priorities: Array[StringName] = []
    if int(plan["deficit_hxd"]) > 0 and int(plan["held_hxd"]) < reserve:
        priorities.append(HXD)
    if int(plan["deficit_tqd"]) > 0:
        priorities.append(TQD)
    if int(plan["deficit_hxd"]) > 0 and not priorities.has(HXD):
        priorities.append(HXD)
    for recipe_id in priorities:
        if warehouse.can_consume_requirements(state, registry.inputs(recipe_id)):
            return recipe_id
    return &""

static func _care_owns(state: SimulationState, disciple_id: StringName) -> bool:
    var care = state.sect.b3_hunt.get("care", {})
    return care is Dictionary and str(care.get("disciple_id", "")) == str(disciple_id) \
        and (bool(care.get("auto_heal", false)) or bool(care.get("auto_hunt", false)))

static func review(state: SimulationState) -> void:
    if not active(state) or state.tick <= 0 or state.tick % 5 != 0:
        return
    var policy := state.sect.sx01_pill_policy
    if not bool(policy.get("auto_use_hoi_xuan_dan", false)) and not bool(policy.get("auto_use_tu_khi_dan", false)):
        return
    var day := int(state.tick / B3PillSatietyV1.DAY_TICKS)
    if int(policy.get("auto_day", -1)) != day:
        policy["auto_day"] = day
        policy["auto_tu_khi_used"] = {}
    var used_today: Dictionary = policy.get("auto_tu_khi_used", {})
    var warehouse := WarehouseSystem.new()
    var ids: Array = state.disciples.keys()
    # Stable ordering across Save/Reload; prioritize the most injured first.
    ids.sort_custom(func(a, b):
        var da: DiscipleState = state.disciples[a]
        var db: DiscipleState = state.disciples[b]
        var ra := da.hp / maxf(da.max_hp, 1.0)
        var rb := db.hp / maxf(db.max_hp, 1.0)
        return str(a) < str(b) if is_equal_approx(ra, rb) else ra < rb
    )
    for id in ids:
        var disciple: DiscipleState = state.disciples[id]
        if not DiscipleRealmProgressV2.progression_ready(disciple) or _care_owns(state, disciple.id) \
            or B3MedicalAutoplayV1.busy(state, disciple):
            continue
        var hp_ratio := disciple.hp / maxf(disciple.max_hp, 1.0)
        if bool(policy.get("auto_use_hoi_xuan_dan", false)) and state.sect.needs_enabled \
            and hp_ratio <= float(policy.get("heal_hp_percent", 60)) / 100.0 \
            and disciple.hp < disciple.max_hp:
            if bool(B3PillSatietyV1.enable(state, disciple).get("ok", false)):
                var medicine_id := MedicineCatalogueV2.best_available(state, disciple, MedicineCatalogueV2.FAMILY_HEAL)
                if medicine_id == &"" and warehouse.available_quantity(state, HXD) > 0:
                    medicine_id = HXD
                if medicine_id != &"":
                    var healed := B3PillSatietyV1.consume(state, disciple, medicine_id, B3PillSatietyV1.next_sequence(disciple))
                    if bool(healed.get("ok", false)) and not bool(healed.get("replay", false)):
                        continue
        # Only explicitly Chuyên Tu disciples auto-consume Tụ Khí Đan;
        # everyone else still earns passive Tu Vi and can receive manual pills.
        var selected: Dictionary = policy.get("priority_tuvi_ids", {})
        if not bool(policy.get("auto_use_tu_khi_dan", false)) \
            or (disciple.current_action != &"CULTIVATE" and not bool(selected.get(str(disciple.id), false))) \
            :
            continue
        var count := int(used_today.get(str(disciple.id), 0))
        if count >= int(policy.get("auto_tu_khi_per_day", 2)):
            continue
        if not bool(B3PillSatietyV1.enable(state, disciple).get("ok", false)):
            continue
        var tuvi_pill := MedicineCatalogueV2.best_available(state, disciple, MedicineCatalogueV2.FAMILY_TUVI)
        if tuvi_pill == &"" and warehouse.available_quantity(state, TQD) > 0:
            tuvi_pill = TQD
        if tuvi_pill == &"":
            continue
        var consumed := B3PillSatietyV1.consume(state, disciple, tuvi_pill, B3PillSatietyV1.next_sequence(disciple))
        if bool(consumed.get("ok", false)) and not bool(consumed.get("replay", false)):
            used_today[str(disciple.id)] = count + 1
    policy["auto_tu_khi_used"] = used_today
