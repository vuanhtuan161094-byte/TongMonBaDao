class_name DiscipleBreakthroughBalanceV2
extends RefCounted

# DV2-03 canonical major-gate balance.
#
# Cultivation: 29 authored base chances for realm r -> r+1. Same-gate pity is
# owned by DiscipleRealmProgressV2 (+5 percentage points per prior failure).
# No generic Tư Chất/Căn Cốt/Linh Căn/HP/Stamina modifier is hidden here.
#
# Body: all 29 major gates are deterministic once floor-10 EXP and the external
# authored tempering requirements have both been verified. No RNG, pity or
# generic failure penalty belongs to Body gates.

const VERSION := 1
const GATE_COUNT := 29

# Source realms 1..29.
const CULTIVATION_BASE_CHANCE_PERCENT := [
    # Nhân 1->10 and crossing 10->11
    100,95,90,85,80,75,70,65,60,50,
    # Tiên 11->20 and crossing 20->21
    90,85,80,75,70,65,60,55,50,35,
    # Thần 21->30
    80,75,70,65,60,55,50,45,35
]

const BODY_GATE_MODE := "deterministic_requirements"

static func validate() -> Dictionary:
    if CULTIVATION_BASE_CHANCE_PERCENT.size() != GATE_COUNT:
        return {"ok":false,"reason":"invalid_cultivation_gate_count"}
    for index in range(GATE_COUNT):
        var chance := int(CULTIVATION_BASE_CHANCE_PERCENT[index])
        if chance < 0 or chance > 100:
            return {"ok":false,"reason":"invalid_cultivation_gate_chance","realm":index+1}
    if BODY_GATE_MODE != "deterministic_requirements":
        return {"ok":false,"reason":"invalid_body_gate_mode"}
    return {"ok":true}

static func cultivation_base_chance(source_realm: int) -> float:
    if source_realm < 1 or source_realm > GATE_COUNT:
        return -1.0
    return float(CULTIVATION_BASE_CHANCE_PERCENT[source_realm-1])/100.0

static func cultivation_base_chance_percent(source_realm: int) -> int:
    if source_realm < 1 or source_realm > GATE_COUNT:
        return -1
    return int(CULTIVATION_BASE_CHANCE_PERCENT[source_realm-1])

static func body_gate_is_deterministic(source_realm: int) -> bool:
    return source_realm >= 1 and source_realm <= GATE_COUNT

static func macro_band(source_realm: int) -> String:
    if source_realm < 1 or source_realm > GATE_COUNT:
        return ""
    if source_realm <= 10:
        return "nhan"
    if source_realm <= 20:
        return "tien"
    return "than"
