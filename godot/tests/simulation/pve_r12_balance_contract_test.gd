extends SceneTree

# PVE-BAL01 read-only and candidate-only deterministic contract.
# This tests financial assumptions, not natural combat performance.
func _init() -> void:
    call_deferred("_run")

func _check(valid: bool, detail: String) -> bool:
    if not valid:
        push_error("PVE_R12_BAL01_FAIL: "+detail)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _check(PveR12BalanceV1.validate_candidate().is_empty(),
            "reference source, income or HP budget changed: "+str(PveR12BalanceV1.validate_candidate())):
        return
    if not _check(PveR12BalanceV1.POLICY_KEY == "pve_r12_reward_pilot"
            and PvePerKillRewardV1.TU_VI_XP_PER_NORMAL_KILL == 75.0
            and PvePerKillRewardV1.BODY_XP_PER_NORMAL_KILL == 25.0,
            "P0 legacy rewards silently repriced"):
        return
    var r1 := PveR12BalanceV1.one_hunter_hour(1)
    var r2 := PveR12BalanceV1.one_hunter_hour(2)
    if not _check(is_equal_approx(float(r1["pve_gross_stones"]),29700.0)
            and is_equal_approx(float(r1["injury_treatment_stones"]),225.0)
            and is_equal_approx(float(r1["injury_downtime_minutes"]),4.5)
            and is_equal_approx(float(r1["hp_healed_by_pills_reference"]),110.0)
            and is_equal_approx(float(r1["pill_opportunity_stones"]),3000.0)
            and is_equal_approx(float(r1["pve_net_before_injury_downtime"]),26475.0)
            and is_equal_approx(float(r1["passive_tuvi_xp"]),60000.0)
            and is_equal_approx(float(r1["pve_extra_tuvi_xp"]),60000.0)
            and is_equal_approx(float(r1["pve_total_tuvi_xp"]),120000.0)
            and is_equal_approx(float(r1["specialized_tuvi_xp"]),120000.0)
            and is_equal_approx(float(r1["body_xp"]),14400.0)
            and is_equal_approx(float(r1["production_gross_stones"]),60000.0),
            "R1 passive+combat EXP, pill-only HP and Injury-only budget changed"):
        return
    if not _check(is_equal_approx(float(r2["pve_gross_stones"]),59400.0)
            and is_equal_approx(float(r2["injury_treatment_stones"]),450.0)
            and is_equal_approx(float(r2["injury_downtime_minutes"]),4.5)
            and is_equal_approx(float(r2["hp_healed_by_pills_reference"]),182.0)
            and is_equal_approx(float(r2["pill_opportunity_stones"]),6000.0)
            and is_equal_approx(float(r2["pve_net_before_injury_downtime"]),52950.0)
            and is_equal_approx(float(r2["passive_tuvi_xp"]),60000.0)
            and is_equal_approx(float(r2["pve_extra_tuvi_xp"]),76200.0)
            and is_equal_approx(float(r2["pve_total_tuvi_xp"]),136200.0)
            and is_equal_approx(float(r2["body_xp"]),18288.0)
            and is_equal_approx(float(r2["production_gross_stones"]),120000.0),
            "R2 passive+combat EXP, pill-only HP and Injury-only budget changed"):
        return
    if not _check(PveR12BalanceV1.reward_for_realm(3,"truc_thu").is_empty()
            and PveR12BalanceV1.reward_for_realm(2,"hac_lang_vuong").is_empty(),
            "unsourced realms/elite/boss must not create money"):
        return
    var state := P37Factory.create_state(550321)
    var old_default := int(state.sect.economy_a_policy.get("personal_heal_cost",-1))
    var old_pilot := bool(state.sect.economy_a_policy.get(PveR12BalanceV1.POLICY_KEY,true))
    if not _check(old_default == 3 and not old_pilot
            and not bool(EconomySystem.new().configure_v1(state,PveR12BalanceV1.POLICY_KEY,true).get("ok",false)),
            "legacy heal price and restricted pilot gate must stay untouched"):
        return
    print("PVE_R12_BAL01_PURE_FINANCE_CONTRACT_PASS R1="+JSON.stringify(r1)
        +" R2="+JSON.stringify(r2)+" TUVI_PASSIVE_ALWAYS=true PLAYER_PILOT_OFF=true R3_PLUS_HOLD=true")
    quit(0)
