class_name PveR12BalanceV1
extends RefCounted

# PVE-BAL01 pilot ONLY. Receipts use existing PvePerKillRewardV1 HP0 kill
# and existing DiscipleState personal Spirit Stone wallet. No extra currency.
# Public/legacy defaults remain OFF, including all upper-realm rewards.
const POLICY_KEY := "pve_r12_reward_pilot"
# Natural Tu Vi applies ONCE per sim minute in SimulationScheduler even in PvE.
# The kill award is ADDITIONAL, never a replacement for natural Tu Vi.
const PASSIVE_TUVI_PER_MINUTE := 1000.0
const SPECIALIZED_MULTIPLIER := 2.0

# Assumptions for feasibility (NOT actual measured combat).
const KILLS_PER_HOUR_REFERENCE := 12.0
const HEAL_SERVICE_HP_REFERENCE := 10.0
const PILLS_PER_HOUR_REFERENCE := 2
# Actual authored normal-monster weights for Thanh Truc Lam, not invented mix.
const SPECIES_WEIGHTS := {"truc_thu":0.65,"thanh_lang":0.30,"hac_lang":0.05}

# Values are PROPOSED CANDIDATES, not measured market prices.
# Existing SX-V55-R12 work pays 1000/2000 Stone/min, before T2.
# HP service is a personal-to-Sect Stone transfer, not global money sink.
# Pill opportunity cost is a shadow valuation of real consumed medicine;
# it must NOT be debited again in the combat reward.
const RATES := {
    1:{
        "name":"Phàm Nhân","production_stones_per_minute":1000,
        "hp_loss_per_kill_reference":18.0,
        "tuvi_xp_per_kill":5000.0,"body_xp_per_kill":1200.0,
        "personal_hp_service_per_10":300,"pill_shadow_stones":1500,
        "kill_stones":{"truc_thu":2100,"thanh_lang":3000,"hac_lang":4200}
    },
    2:{
        "name":"Luyện Khí","production_stones_per_minute":2000,
        "hp_loss_per_kill_reference":24.0,
        "tuvi_xp_per_kill":6350.0,"body_xp_per_kill":1524.0,
        "personal_hp_service_per_10":600,"pill_shadow_stones":3000,
        "kill_stones":{"truc_thu":4200,"thanh_lang":6000,"hac_lang":8400}
    }
}

# Proposed only: full NPC BUY price = base × existing market_buy_markup (default 2).
# Existing NPC purchase price remains unchanged while internal pilot is OFF.
# No new item, shop stock, seller route or currency is created here.
const NPC_PURCHASE_BASE_PRICE := {
    "linh_moc":50, "thanh_thiet":80, "linh_coc":40,
    "thanh_linh_thao":80, "tu_van_thao":200, "huyen_thiet":550,
    "tinh_lang_bi":375, "linh_tuy":1250,
    "tam_mach_ban":20000, "linh_tuyen_chi_tam_manh":600
}

static func npc_purchase_base_price(state: SimulationState, resource_id: StringName) -> int:
    if not active(state):
        return 0
    return int(NPC_PURCHASE_BASE_PRICE.get(str(resource_id),0))

static func reward_for_realm(realm: int, species_id: String) -> Dictionary:
    var row: Dictionary = RATES.get(realm,{})
    if row.is_empty() or not row["kill_stones"].has(species_id):
        return {}
    return {
        "cultivation":float(row["tuvi_xp_per_kill"]),
        "body":float(row["body_xp_per_kill"]),
        "stones":int(row["kill_stones"][species_id])
    }

static func active(state: SimulationState) -> bool:
    return state != null and state.sect.economy_a_enabled \
        and state.sect.p3_7_resources_enabled and state.p3_7_buildings_enabled \
        and bool(state.sect.economy_a_policy.get(POLICY_KEY,false))

static func gated_reward(state: SimulationState, disciple: DiscipleState,
        species_id: String) -> Dictionary:
    if not active(state) or disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        return {}
    var realm := int(disciple.v2_realm_progress.get("cultivation",{}).get("realm",0))
    return reward_for_realm(realm,species_id)

static func personal_hp_service_price(state: SimulationState, disciple: DiscipleState) -> int:
    if not active(state) or disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        return maxi(int(state.sect.economy_a_policy.get("personal_heal_cost",3)),1)
    var realm := int(disciple.v2_realm_progress.get("cultivation",{}).get("realm",0))
    var row: Dictionary = RATES.get(realm,{})
    if row.is_empty():
        return maxi(int(state.sect.economy_a_policy.get("personal_heal_cost",3)),1)
    return int(row["personal_hp_service_per_10"])

# A pure reference calculation; this is not live gameplay, 30-day simulation,
# nor a claim that real PvE kills/HP losses equal these assumptions.
static func one_hunter_hour(realm: int) -> Dictionary:
    var row: Dictionary = RATES.get(realm,{})
    if row.is_empty():
        return {}
    var average_stones := 0.0
    for species_id in SPECIES_WEIGHTS.keys():
        average_stones += float(row["kill_stones"][species_id])*float(SPECIES_WEIGHTS[species_id])
    var gross := average_stones*KILLS_PER_HOUR_REFERENCE
    # A consumed healing pill replaces HP services; never charge for both
    # therapies over the SAME HP. All quantities are modeled, not debited.
    var total_hp_lost := KILLS_PER_HOUR_REFERENCE*float(row["hp_loss_per_kill_reference"])
    var real_heal_pill := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_HEAL,realm,1)
    var pill_hp_each := float(MedicineCatalogueV2.definition(real_heal_pill).get("potency",0))
    var restored_by_pills := minf(total_hp_lost,pill_hp_each*float(PILLS_PER_HOUR_REFERENCE))
    var hp_to_service := maxf(0.0,total_hp_lost-restored_by_pills)
    var service_uses := ceili(hp_to_service/HEAL_SERVICE_HP_REFERENCE)
    var hp_cost := float(service_uses)*float(row["personal_hp_service_per_10"])
    var pill_cost := float(PILLS_PER_HOUR_REFERENCE)*float(row["pill_shadow_stones"])
    var net := gross-hp_cost-pill_cost
    var pve_xp := KILLS_PER_HOUR_REFERENCE*float(row["tuvi_xp_per_kill"])
    var passive_xp := PASSIVE_TUVI_PER_MINUTE*60.0
    var production_gross := 60.0*float(row["production_stones_per_minute"])
    return {
        "realm":realm,"kills":KILLS_PER_HOUR_REFERENCE,
        "pve_gross_stones":gross,"healing_stones":hp_cost,
        "hp_lost":total_hp_lost,"hp_restored_by_pills":restored_by_pills,
        "hp_service_purchases":service_uses,
        "pill_opportunity_stones":pill_cost,"pve_net_before_injury_and_time":net,
        "production_gross_stones":production_gross,
        "production_mine_personal":production_gross*0.30,
        "production_forest_personal":production_gross*0.70,
        "production_field_personal":production_gross*0.60,
        "passive_tuvi_xp":passive_xp,
        "pve_extra_tuvi_xp":pve_xp,
        "pve_total_tuvi_xp":passive_xp+pve_xp,
        "specialized_tuvi_xp":passive_xp*SPECIALIZED_MULTIPLIER,
        "body_xp":KILLS_PER_HOUR_REFERENCE*float(row["body_xp_per_kill"]),
        "pve_money_to_production_ratio":net/production_gross
    }

static func validate_candidate() -> Array[String]:
    var errors: Array[String] = []
    var world: Dictionary = HuntingMapV2.REGION_CONTENT.get(PveMultiCampPopulationV1.ZONE,{})
    if world.get("normal",{}) != SPECIES_WEIGHTS:
        errors.append("reference_species_weights_no_longer_match_p0_world")
    if PASSIVE_TUVI_PER_MINUTE != DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE:
        errors.append("incorrect_passive_tuvi_authority")
    for realm in [1,2]:
        var row: Dictionary = RATES[realm]
        var hourly := one_hunter_hour(realm)
        if reward_for_realm(realm,"nham_giap_thu") != {} or reward_for_realm(3,"truc_thu") != {}:
            errors.append("unknown_species_or_unsourced_realm_paid")
        if int(row["production_stones_per_minute"]) != int(EconomySystem.SX_V55_R12_RATES[realm]["gross_per_minute"]):
            errors.append("reference_work_income_mismatch")
        if int(row["personal_hp_service_per_10"]) <= 3:
            errors.append("hp_service_legacy_price_not_rebalanced")
        if int(hourly["hp_service_purchases"]) != 11:
            errors.append("hp_services_incorrectly_double_count_pill_healing")
        var ratio := float(hourly["pve_money_to_production_ratio"])
        if ratio < 0.25 or ratio > 0.50:
            errors.append("pve_net_outside_risk_adjusted_production_band")
        var realm_xp := DiscipleProgressionBalanceV2.realm_total_xp(realm)
        if float(row["tuvi_xp_per_kill"]) != float(realm_xp)*0.0005 or \
                float(row["body_xp_per_kill"]) != float(realm_xp)*0.00012:
            errors.append("xp_does_not_follow_canonical_realm_cost")
    return errors
