class_name PveR12BalanceV1
extends RefCounted

# Candidate combat economy, internal QA only. Never enables itself.
# A real HP=0 kill remains the ONLY reward authority (PvePerKillRewardV1).
# No second wallet, loot store, clock, save ledger, or map-clear bonus.
const POLICY_KEY := "pve_r12_reward_pilot"
const KILLS_PER_HOUR_REFERENCE := 12.0
const HP_LOSS_PER_KILL_REFERENCE := 18.0
const HEAL_SERVICE_HP_REFERENCE := 10.0
const PILLS_PER_HOUR_REFERENCE := 2.0
const SPECIES_WEIGHTS := {"truc_thu":0.20,"thanh_lang":0.60,"hac_lang":0.20}

# Cultivation at 2,000 XP/min; Body expedition reference 750 XP/min.
# PvE: 50% cultivate Tu Vi rate and 32% Body-expedition rate at 12 kills/h.
# Currency: 3-6.5x candidate production minute per authentic kill,
# BEFORE real healing/pills, death, travel, lost work hours and rare loot.
# This DOES NOT alter QA-locked SX-V55-R12 production payouts.
const RATES := {
    1:{
        "name":"Phàm Nhân","production_stones_per_minute":100,
        "tuvi_xp_per_kill":5000.0,"body_xp_per_kill":1200.0,
        "personal_hp_service_per_10":100,"pill_shadow_stones":300,
        "kill_stones":{"truc_thu":300,"thanh_lang":450,"hac_lang":650}
    },
    2:{
        "name":"Luyện Khí","production_stones_per_minute":200,
        "tuvi_xp_per_kill":6350.0,"body_xp_per_kill":1524.0,
        "personal_hp_service_per_10":200,"pill_shadow_stones":600,
        "kill_stones":{"truc_thu":480,"thanh_lang":720,"hac_lang":1040}
    }
}

static func reward_for_realm(realm: int, species_id: String) -> Dictionary:
    var row: Dictionary = RATES.get(realm,{})
    if row.is_empty() or not row["kill_stones"].has(species_id):
        return {}
    return {
        "cultivation":float(row["tuvi_xp_per_kill"]),
        "body":float(row["body_xp_per_kill"]),
        "stones":int(row["kill_stones"][species_id])
    }

static func gated_reward(state: SimulationState, disciple: DiscipleState,
        species_id: String) -> Dictionary:
    if state == null or disciple == null or not state.sect.economy_a_enabled \
            or not state.sect.p3_7_resources_enabled or not state.p3_7_buildings_enabled \
            or not bool(state.sect.economy_a_policy.get(POLICY_KEY,false)) \
            or not DiscipleRealmProgressV2.progression_ready(disciple):
        return {}
    var realm := int(disciple.v2_realm_progress.get("cultivation",{}).get("realm",0))
    return reward_for_realm(realm,species_id)

# Explicitly modeled ONE hunter-hour, not observed kills/h or live HP/pill use.
# Real cost is computed from actual receipts in a later live-agent gate.
static func one_hunter_hour(realm: int) -> Dictionary:
    var row: Dictionary = RATES.get(realm,{})
    if row.is_empty():
        return {}
    var average_stones := 0.0
    for species_id in SPECIES_WEIGHTS.keys():
        average_stones += float(row["kill_stones"][species_id])*float(SPECIES_WEIGHTS[species_id])
    var gross := average_stones*KILLS_PER_HOUR_REFERENCE
    var hp_cost := KILLS_PER_HOUR_REFERENCE*HP_LOSS_PER_KILL_REFERENCE \
        /HEAL_SERVICE_HP_REFERENCE*float(row["personal_hp_service_per_10"])
    var pill_cost := PILLS_PER_HOUR_REFERENCE*float(row["pill_shadow_stones"])
    var net := gross-hp_cost-pill_cost
    return {
        "realm":realm,"kills":KILLS_PER_HOUR_REFERENCE,
        "pve_gross_stones":gross,"healing_stones":hp_cost,
        "pill_opportunity_stones":pill_cost,"pve_net_before_injury_and_time":net,
        "production_gross_stones":60*int(row["production_stones_per_minute"]),
        "tuvi_xp":KILLS_PER_HOUR_REFERENCE*float(row["tuvi_xp_per_kill"]),
        "body_xp":KILLS_PER_HOUR_REFERENCE*float(row["body_xp_per_kill"]),
        "pve_money_to_production_ratio":net/(60.0*float(row["production_stones_per_minute"]))
    }

static func validate_candidate() -> Array[String]:
    var errors: Array[String] = []
    for realm in [1,2]:
        var row: Dictionary = RATES[realm]
        var hourly := one_hunter_hour(realm)
        if reward_for_realm(realm,"nham_giap_thu") != {} or \
                reward_for_realm(3,"truc_thu") != {}:
            errors.append("unknown_species_or_unsourced_realm_paid")
        if int(row["production_stones_per_minute"]) <= 0 or \
                int(row["personal_hp_service_per_10"]) <= 0:
            errors.append("nonpositive_cost_or_income")
        if float(hourly.get("pve_net_before_injury_and_time",-1.0)) <= 0.0 or \
                float(hourly.get("pve_money_to_production_ratio",1.0)) >= 0.15:
            errors.append("combat_dominates_production_or_cannot_cover_care")
        var realm_xp := DiscipleProgressionBalanceV2.realm_total_xp(realm)
        if float(row["tuvi_xp_per_kill"]) != float(realm_xp)*0.0005 or \
                float(row["body_xp_per_kill"]) != float(realm_xp)*0.00012:
            errors.append("xp_does_not_follow_canonical_realm_cost")
    return errors
