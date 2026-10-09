class_name DiscipleProgressionBalanceV2
extends RefCounted

# DV2-03 authoritative progression balance table.
#
# The 30 realm totals preserve the approved ~1.27 progression shape but use
# cultivation-scale numbers: realm 1 starts at 10,000,000 EXP. Values are frozen
# as explicit integers so gameplay does not depend on floating-point pow()/round()
# differences at runtime.
#
# Both Tu Vi and Luyện Thể consume the SAME 300-floor XP requirement curve.
# Their actual real-time pace differs because their source rates/mechanics differ.

const VERSION := 1
const FLOORS_PER_REALM := 10
const REALM_COUNT := 30

const BASE_TUVI_PER_MINUTE := 1000.0
const CULTIVATE_MULTIPLIER := 2.0

# Reference Body rates are balance anchors only. Real consumers still have to
# prove an eligible source context through DiscipleBodyXpSourceV2.
const BODY_PRODUCTION_REFERENCE_PER_MINUTE := 250.0
const BODY_EXPEDITION_REFERENCE_PER_MINUTE := 750.0
const BODY_TRAINING_REFERENCE_PER_MINUTE := 1500.0

# Realm totals, r1..r30.
const REALM_TOTAL_XP := [
    10000000, 12700000, 16200000, 20500000, 26000000, 33000000, 42000000, 53300000, 67700000, 86000000,
    109200000, 138700000, 176000000, 223700000, 284000000, 360700000, 458000000, 581700000, 738700000, 938200000,
    1191500000, 1513200000, 1921700000, 2440500000, 3099500000, 3936300000, 4999200000, 6349000000, 8063200000, 10240200000
]

# Sum = 10.0. Within each realm, later floors are deliberately heavier.
const FLOOR_WEIGHT_PER_MILLE := [700,750,800,850,900,1000,1100,1200,1300,1400]

static func validate() -> Dictionary:
    if REALM_TOTAL_XP.size() != REALM_COUNT:
        return {"ok":false,"reason":"invalid_realm_total_count"}
    if FLOOR_WEIGHT_PER_MILLE.size() != FLOORS_PER_REALM:
        return {"ok":false,"reason":"invalid_floor_weight_count"}
    var weight_sum := 0
    for weight in FLOOR_WEIGHT_PER_MILLE:
        if int(weight) <= 0:
            return {"ok":false,"reason":"invalid_floor_weight"}
        weight_sum += int(weight)
    if weight_sum != 10000:
        return {"ok":false,"reason":"floor_weights_do_not_sum_to_realm"}
    var previous := 0
    for total in REALM_TOTAL_XP:
        if int(total) <= 0 or int(total) <= previous:
            return {"ok":false,"reason":"invalid_realm_total_curve"}
        previous = int(total)
    if BASE_TUVI_PER_MINUTE <= 0.0 or CULTIVATE_MULTIPLIER < 1.0:
        return {"ok":false,"reason":"invalid_tuvi_rate"}
    if not (
        BODY_PRODUCTION_REFERENCE_PER_MINUTE > 0.0
        and BODY_PRODUCTION_REFERENCE_PER_MINUTE < BODY_EXPEDITION_REFERENCE_PER_MINUTE
        and BODY_EXPEDITION_REFERENCE_PER_MINUTE < BODY_TRAINING_REFERENCE_PER_MINUTE
    ):
        return {"ok":false,"reason":"invalid_body_reference_order"}
    return {"ok":true}

static func realm_total_xp(realm: int) -> int:
    if realm < 1 or realm > REALM_COUNT:
        return 0
    return int(REALM_TOTAL_XP[realm-1])

static func floor_cost(realm: int, floor_index: int) -> int:
    if realm < 1 or realm > REALM_COUNT or floor_index < 1 or floor_index > FLOORS_PER_REALM:
        return 0
    var total := realm_total_xp(realm)
    var allocated := 0
    # Floors 1..9 round to the nearest 10 EXP. Floor 10 receives the exact
    # residual so every realm sums precisely to its authored total.
    for f in range(1,FLOORS_PER_REALM):
        var weighted := float(total) * float(FLOOR_WEIGHT_PER_MILLE[f-1]) / 10000.0
        var value := int(round(weighted/10.0))*10
        if f == floor_index:
            return value
        allocated += value
    if floor_index == FLOORS_PER_REALM:
        return total-allocated
    return 0

static func floor_costs() -> Dictionary:
    var result: Dictionary = {}
    for realm in range(1,REALM_COUNT+1):
        for floor_index in range(1,FLOORS_PER_REALM+1):
            result["%d:%d" % [realm,floor_index]] = floor_cost(realm,floor_index)
    return result

static func cultivation_rule() -> Dictionary:
    return {
        "authority_id":"dv2-progression-balance-v1",
        "action":"CULTIVATE",
        "base_tuvi_per_minute":BASE_TUVI_PER_MINUTE,
        "cultivate_multiplier":CULTIVATE_MULTIPLIER,
        "floor_costs":floor_costs(),
        "sources":[]
    }

static func body_progression_rule() -> Dictionary:
    return {
        "authority_id":"dv2-progression-balance-v1",
        "training_mechanic":"typed_source_contract",
        "floor_costs":floor_costs(),
        "sources":[]
    }

static func canonical_training_rules() -> Dictionary:
    return {
        "cultivation":cultivation_rule(),
        "body":body_progression_rule()
    }

static func benchmark_minutes_for_realm(realm: int, rate_per_minute: float) -> float:
    if rate_per_minute <= 0.0:
        return INF
    return float(realm_total_xp(realm))/rate_per_minute

static func cumulative_xp_through_realm(realm: int) -> int:
    if realm < 1:
        return 0
    var capped := mini(realm,REALM_COUNT)
    var total := 0
    for index in range(capped):
        total += int(REALM_TOTAL_XP[index])
    return total

static func benchmark_days_through_realm(realm: int, rate_per_minute: float) -> float:
    if rate_per_minute <= 0.0:
        return INF
    return float(cumulative_xp_through_realm(realm))/rate_per_minute/60.0/24.0
