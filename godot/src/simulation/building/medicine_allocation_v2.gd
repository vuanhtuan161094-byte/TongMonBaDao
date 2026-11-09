class_name MedicineAllocationV2
extends RefCounted

# Deterministic allocation of existing Warehouse stock. No item minting.
# Both Sect AI and B3 CARE call this owner; catalogue remains pure data.

# BAL-04A: the old Hoi Xuan Dan still heals exactly 55 HP and remains
# manually usable at any realm. Auto use is only worthwhile if the ACTUAL
# restore (also capped by missing HP) is at least 2% of maximum HP.
const MIN_LEGACY_AUTO_HEAL_RATIO := 0.02


static func legacy_heal_useful_for_auto(disciple: DiscipleState) -> bool:
    if disciple == null or not is_finite(disciple.max_hp) or not is_finite(disciple.hp) or disciple.max_hp <= 0.0:
        return false
    var effective_heal := minf(NeedsSystem.HEALING_PILL_HP,
        maxf(disciple.max_hp - disciple.hp, 0.0))
    return effective_heal > 0.0 and effective_heal / disciple.max_hp >= MIN_LEGACY_AUTO_HEAL_RATIO


# Choose from real Warehouse stock without bypassing locks/reserves.
# Prefer the strongest useful medicine, breaking equal-heal ties toward the
# less potent pill to avoid throwing away rarer high-grade medicine.
static func best_available(state: SimulationState, disciple: DiscipleState, family: String) -> StringName:
    if state == null or disciple == null or not [MedicineCatalogueV2.FAMILY_HEAL, MedicineCatalogueV2.FAMILY_TUVI].has(family):
        return &""
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return &""
    var row = disciple.v2_realm_progress.get("cultivation", {})
    if not (row is Dictionary):
        return &""
    var max_realm := clampi(int(row.get("realm", 1)), 1, MedicineCatalogueV2.MAX_REALM)
    var warehouse := WarehouseSystem.new()
    var best: StringName = &""
    var best_value := -1.0
    var best_power := 1.0e30
    var missing := maxf(disciple.max_hp - disciple.hp, 0.0)
    if family == MedicineCatalogueV2.FAMILY_HEAL and missing <= 0.0:
        return &""
    # B3.consume only accepts the CURRENT track realm for all graded
    # HEAL/TUVI pills. An older stronger pill cannot shadow a usable one.
    for realm in range(max_realm, max_realm + 1):
        for quality in range(1, MedicineCatalogueV2.MAX_QUALITY + 1):
            var id := MedicineCatalogueV2.item_id(family, realm, quality)
            if warehouse.available_quantity(state, id) <= 0:
                continue
            var power := float(MedicineCatalogueV2.definition(id).get("potency", 0))
            var useful := minf(power, missing) if family == MedicineCatalogueV2.FAMILY_HEAL else power
            if useful > best_value or (is_equal_approx(useful, best_value) and power < best_power):
                best = id
                best_value = useful
                best_power = power
    return best

