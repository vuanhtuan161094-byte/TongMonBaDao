extends SceneTree

# Deterministic, no-gameplay-mutation balance guard.
# Does not claim natural PvE FPS, damage, healing purchases or 30-day played QA.
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
            "candidate profile violates canonical realm XP/ROI/receipt assumptions"):
        return
    if not _check(PveR12BalanceV1.POLICY_KEY == "pve_r12_reward_pilot"
            and PvePerKillRewardV1.TU_VI_XP_PER_NORMAL_KILL == 75.0
            and PvePerKillRewardV1.BODY_XP_PER_NORMAL_KILL == 25.0,
            "P0 legacy base was silently repriced"):
        return
    var r1 := PveR12BalanceV1.one_hunter_hour(1)
    var r2 := PveR12BalanceV1.one_hunter_hour(2)
    if not _check(is_equal_approx(float(r1["pve_gross_stones"]),5520.0)
            and is_equal_approx(float(r1["healing_stones"]),2160.0)
            and is_equal_approx(float(r1["pill_opportunity_stones"]),600.0)
            and is_equal_approx(float(r1["pve_net_before_injury_and_time"]),2760.0)
            and is_equal_approx(float(r1["tuvi_xp"]),60000.0)
            and is_equal_approx(float(r1["body_xp"]),14400.0)
            and int(r1["production_gross_stones"]) == 6000,
            "r1/hour full HP+pill+work opportunity oracle changed"):
        return
    if not _check(is_equal_approx(float(r2["pve_gross_stones"]),8832.0)
            and is_equal_approx(float(r2["healing_stones"]),4320.0)
            and is_equal_approx(float(r2["pill_opportunity_stones"]),1200.0)
            and is_equal_approx(float(r2["pve_net_before_injury_and_time"]),3312.0)
            and is_equal_approx(float(r2["tuvi_xp"]),76200.0)
            and is_equal_approx(float(r2["body_xp"]),18288.0)
            and int(r2["production_gross_stones"]) == 12000,
            "r2/hour full HP+pill+work opportunity oracle changed"):
        return
    if not _check(PveR12BalanceV1.reward_for_realm(3,"truc_thu").is_empty()
            and PveR12BalanceV1.reward_for_realm(2,"hac_lang_vuong").is_empty(),
            "no real R3/elite/Boss table must imply no paid reward"):
        return
    var old_production := EconomySystem.SX_V55_R12_RATES
    if not _check(int(old_production[1]["gross_per_minute"]) == 1000
            and int(old_production[2]["gross_per_minute"]) == 2000,
            "candidate must not rewrite already frozen live pilot receipts"):
        return
    print("PVE_R12_BAL01_PURE_FINANCE_CONTRACT_PASS R1="+JSON.stringify(r1)
        +" R2="+JSON.stringify(r2)+" R3_PLUS_HOLD=true")
    quit(0)
