extends SceneTree

# F5 reproducible low-tier PILOT demand worksheet, not 1k/3k live load proof.
# Numbers are derived from actual F1 recipe and F3 authored reward configs.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("DV2-03F/F5: "+reason)
        quit(1)
        return false
    return true

func _ceil_div(num: int, denominator: int) -> int:
    return (num + denominator - 1) / denominator

func _run() -> void:
    var sums := {"A_main":0,"A_aux":0,"B_main":0,"B_aux":0}
    for realm in range(1,7):
        var row := DiscipleBodyGateContentV2.recipe(realm)
        var group := str(row["group"])
        sums[group+"_main"] += int(row["main_qty"])
        sums[group+"_aux"] += int(row["aux_qty"])
    var truc: Dictionary = HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]["resources"]
    var bach: Dictionary = HuntingMapV2.REGION_CONTENT["bach_thach_khe"]["resources"]
    var herb_per_truc := int(truc.get("thanh_linh_thao",0))
    var marrow_every := HuntingMapV2.LINH_TUY_GUARANTEE_WINS
    var pelt_per_bach := int(bach.get("tinh_lang_bi",0))
    var tuvan_per_bach := int(bach.get("tu_van_thao",0))
    if not _check(sums=={"A_main":54,"A_aux":15,"B_main":52,"B_aux":6} and
        herb_per_truc==1 and marrow_every==4 and
        pelt_per_bach==2 and tuvan_per_bach==2,
        "Actual A/B recipes or earned-source pilot changed unexpectedly."):
        return
    # This is strictly source throughput *after victorious claims*, not
    # required combat time, not map auto-dispatch/EXP and not stone revenue.
    var truc_wins := _ceil_div(int(sums["A_main"]),herb_per_truc)
    var bach_wins := _ceil_div(int(sums["B_main"]),tuvan_per_bach)
    var lower_count := truc_wins+bach_wins
    var guaranteed_marrow := truc_wins/marrow_every
    var pelt_from_bach := bach_wins*pelt_per_bach
    if not _check(truc_wins==54 and bach_wins==26 and lower_count==80 and
        guaranteed_marrow>=int(sums["B_aux"]) and
        pelt_from_bach>=int(sums["A_aux"]),
        "Earned guaranteed low-tier routes are internally contradictory."):
        return
    var proj1000 := lower_count*1000
    var proj3000 := lower_count*3000
    if not _check(proj1000==80000 and proj3000==240000 and
        DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE==1000.0 and
        DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE==1500.0,
        "F5 arithmetic or locked EXP source changed."):
        return
    print("DV2-03F F5 PILOT ECONOMY: ",JSON.stringify({
        "A_main":sums["A_main"],"A_aux":sums["A_aux"],
        "B_main":sums["B_main"],"B_aux":sums["B_aux"],
        "truc_victories_min":truc_wins,"bach_victories_min":bach_wins,
        "hunt_only_theoretical_victories_per_disciple":lower_count,
        "projected_victories_1000_disciple":proj1000,
        "projected_victories_3000_disciple":proj3000,
        "actual_elapsed_time_verified":false,
        "full_autonomous_hunting_dispatch_verified":false,
        "earned_recurring_spirit_stone_income_verified":false,
        "high_tier_economy_verified":false
    }))
    print("DV2-03F F5 LOW-TIER PILOT AUDIT: PASS (arithmetic only; economy NOT certified)")
    quit(0)
