extends SceneTree

# ECON-V2 CAP PREVIEW. This test MUST NOT create or charge real construction.
var policy := ResourceBuildingExpansionPolicyV2.new()
var buildings := BuildingSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
    if not ok:
        push_error("ECON-V2 EXPANSION CAP FAIL: "+message)
        quit(1)
        return false
    return true

func _run() -> void:
    var state := P37Factory.create_state(161016)
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine != null and forest != null and field != null,
        "P37 state must own one initial Mine, Forest and Field"):
        return

    var tier_rows := [
        [1,1,1,1,1],
        [9,1,1,1,1],
        [10,2,2,3,5],
        [19,2,2,3,5],
        [20,5,5,7,10],
        [39,5,5,7,10],
        [40,10,10,14,20],
        [59,10,10,14,20],
        [60,18,18,24,35],
        [79,18,18,24,35],
        [80,30,30,40,50],
        [100,30,30,40,50]
    ]
    for row in tier_rows:
        var hall_level := int(row[0])
        var tier := policy.tier_for_level(hall_level)
        if not _check(
            policy.capacity_for(hall_level,BuildingSystem.TYPE_MINE) == int(row[1])
            and policy.capacity_for(hall_level,BuildingSystem.TYPE_LINH_FOREST) == int(row[2])
            and policy.capacity_for(hall_level,BuildingSystem.TYPE_SPIRIT_FIELD) == int(row[3])
            and int(tier.get("minimum_average",-1)) == int(row[4]),
            "cap/average thresholds mismatch for Hall Lv%d" % hall_level
        ):
            return

    if not _check(
        policy.capacity_for(0,BuildingSystem.TYPE_MINE) == 0
        and policy.capacity_for(101,BuildingSystem.TYPE_MINE) == 0
        and policy.capacity_for(80,BuildingSystem.TYPE_ALCHEMY_HALL) == 0,
        "invalid/unrelated Hall or type unexpectedly granted expansion"
    ):
        return

    var at_first := policy.preview(state,BuildingSystem.TYPE_MINE,1)
    var at_ten := policy.preview(state,BuildingSystem.TYPE_MINE,10)
    if not _check(
        not bool(at_first.get("ok",true))
        and bool(at_first.get("preview_only",false))
        and int(at_first.get("available_slots",-1)) == 0
        and not bool(at_ten.get("ok",true))
        and int(at_ten.get("available_slots",-1)) == 1
        and not bool(at_ten.get("progression_condition_met",true))
        and str(at_ten.get("reason","")) == "hall_land_and_construction_authority_pending",
        "preview incorrectly permits unsupported real construction"
    ):
        return

    # Test-only extra instance: verifies deterministic index, count, average
    # and CAP without representing a paid/placed real construction.
    mine.level = 10
    var secondary := buildings.create_building(BuildingSystem.TYPE_MINE,3)
    state.buildings[str(secondary.id)] = secondary
    var expanded := policy.preview(state,BuildingSystem.TYPE_MINE,20)
    if not _check(
        int(expanded.get("current_count",-1)) == 2
        and int(expanded.get("limit",-1)) == 5
        and int(expanded.get("next_instance_index",-1)) == 4
        and is_equal_approx(float(expanded.get("mean_existing_level",-1.0)),5.5)
        and not bool(expanded.get("progression_condition_met",true))
        and not bool(expanded.get("ok",true)),
        "multi-instance preview is not fail-closed/deterministic"
    ):
        return

    var ids_before: Array = state.buildings.keys()
    ids_before.sort()
    policy.preview(state,BuildingSystem.TYPE_MINE,100)
    var ids_after: Array = state.buildings.keys()
    ids_after.sort()
    if not _check(ids_before == ids_after,
        "pure preview mutated canonical buildings"):
        return

    print("ECON-V2 EXPANSION CAP PREVIEW TEST PASS (NOT CONSTRUCTION AUTHORITY)")
    quit(0)
