extends SceneTree

# ECON-V2 CORE FOUNDATION — authored regression contract.
# Runtime status remains PENDING until executed with official Godot 4.7.2.
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var resources := ResourceRegistry.new()
var crops := SpiritCropRegistry.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("ECON-V2 CORE TEST FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _verify_30x10_realm_alignment():
        return
    if not _verify_one_operator_contract():
        return
    if not _verify_field_duty_internal_plots():
        return
    if not _verify_fractional_work_speed_is_preserved():
        return
    if not _verify_profession_cap():
        return
    print("ECON-V2 CORE FOUNDATION TEST PASS")
    quit(0)

func _verify_30x10_realm_alignment() -> bool:
    if not _check(DiscipleRealmProgressV2.MAX_REALM == 30 and DiscipleRealmProgressV2.MAX_FLOOR == 10,
        "canonical progression is not 30 realms x 10 floors"):
        return false
    if not _check(
        DiscipleRealmProgressV2.CULTIVATION_REALM_NAMES.size() == 30
        and DiscipleRealmProgressV2.BODY_REALM_NAMES.size() == 30,
        "canonical realm-name lists are incomplete"
    ):
        return false
    if not _check(resources.validate_definitions().is_empty(),
        "resource registry canonical-realm metadata is invalid"):
        return false
    if not _check(crops.validate_definitions().is_empty(),
        "crop registry canonical-realm metadata is invalid"):
        return false
    if not _check(resources.cultivation_realm_min(&"thanh_thiet") == 2
        and resources.cultivation_realm_name(&"thanh_thiet") == "Luyện Khí",
        "Thanh Thiết is not aligned to Tu Vi realm 2 / Luyện Khí"):
        return false
    if not _check(resources.cultivation_realm_min(&"huyen_thiet") == 3
        and resources.cultivation_realm_name(&"huyen_thiet") == "Trúc Cơ",
        "Huyền Thiết is not aligned to Tu Vi realm 3 / Trúc Cơ"):
        return false
    if not _check(resources.body_realm_min(&"huyet_linh_sam") == 7
        and resources.body_realm_name(&"huyet_linh_sam") == "Tôi Tạng",
        "Huyết Linh Sâm is not aligned to Luyện Thể realm 7"):
        return false
    if not _check(resources.body_realm_min(&"an_than_gioi") == 29
        and resources.body_realm_name(&"an_than_gioi") == "Hỗn Độn Thần Thể",
        "Ấn Thần Giới is not aligned to Luyện Thể gate realm 29"):
        return false
    return true

func _verify_one_operator_contract() -> bool:
    var state := P37Factory.create_state(920601)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine != null and forest != null and field != null,
        "fresh raw-resource buildings are missing"):
        return false
    for level in [1, 5, 10, 20, 50, 100]:
        mine.level = level
        forest.level = level
        field.level = level
        if not _check(buildings.worker_slots(mine) == 1,
            "Mine worker count scales above one"):
            return false
        if not _check(buildings.worker_slots(forest) == 1,
            "Linh Lâm worker count scales above one"):
            return false
        if not _check(buildings.worker_slots(field) == 1,
            "Linh Điền worker count scales above one"):
            return false
        if not _check(buildings.spirit_plot_slots(field) == 4,
            "Linh Điền plot count incorrectly scales with building level"):
            return false
    mine.level = 1
    forest.level = 1
    field.level = 1

    var free: Array[DiscipleState] = []
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"" and actor.worksite_building_id == &"" and actor.region_id == &"sect":
            free.append(actor)
    if not _check(free.size() >= 2, "need two free founders for Forest/Field assignment"):
        return false

    var forest_result := workforce.assign_linh_forest_worker(state, free[0].id, forest.id)
    var field_result := workforce.assign_spirit_field_worker(state, free[1].id, field.id)
    if not _check(bool(forest_result.get("ok",false)) and bool(field_result.get("ok",false)),
        "atomic Forest/Field assignment failed"):
        return false
    if not _check(buildings.assigned_worker_ids(state,forest) == [free[0].id]
        and buildings.assigned_worker_ids(state,field) == [free[1].id],
        "Forest/Field do not own exactly one independent operator"):
        return false
    return _check(buildings.validate_invariants(state).is_empty(),
        "one-operator state violates BuildingSystem invariants")

func _verify_field_duty_internal_plots() -> bool:
    var state := P37Factory.create_state(920602)
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    var worker: DiscipleState = null
    var ids: Array = state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var actor: DiscipleState = state.disciples[raw_id]
        if actor.work_group_id == &"" and actor.worksite_building_id == &"" and actor.region_id == &"sect":
            worker = actor
            break
    if not _check(worker != null, "no free worker for Linh Điền duty"):
        return false
    if not _check(bool(workforce.assign_spirit_field_worker(state,worker.id,field.id).get("ok",false)),
        "cannot assign one Linh Điền operator"):
        return false

    var result := buildings.perform_spirit_field_step(state,worker,1.0)
    if not _check(bool(result.get("ok",false)) and int(result.get("plots_started",0)) == 4,
        "one field duty did not start the four internal plot timers"):
        return false
    var plots := buildings.spirit_field_plots(state,field)
    if not _check(plots.size() == 4, "field duty changed the four-plot contract"):
        return false
    var wage_ids: Dictionary = {}
    for raw_plot in plots:
        if not (raw_plot is Dictionary):
            return _check(false,"field contains invalid plot state")
        if not _check(str(raw_plot.get("assigned_worker_id","")) == str(worker.id),
            "field plot is owned by another disciple"):
            return false
        var wage_id := str(raw_plot.get("economy_a_wage_job_id",""))
        if wage_id != "":
            wage_ids[wage_id] = true
    if not _check(wage_ids.size() <= 1,
        "four plots created multiple wage identities for one field duty"):
        return false
    return _check(buildings.disciple_has_active_spirit_plot(state,worker.id,field),
        "field duty does not reserve its sole operator")

func _verify_fractional_work_speed_is_preserved() -> bool:
    var first := buildings._timed_duration_plan(60.0,1.01,0)
    if not _check(int(first.get("duration_ticks",0)) == 60
        and int(first.get("completion_remainder_bp",0)) == 6000,
        "first +1% speed cycle did not retain overshoot"):
        return false
    var second := buildings._timed_duration_plan(
        60.0,1.01,int(first.get("completion_remainder_bp",0))
    )
    return _check(int(second.get("duration_ticks",0)) == 59,
        "saved work remainder did not convert +1% speed into long-run throughput")

func _verify_profession_cap() -> bool:
    var state := P37Factory.create_state(920603)
    var actor: DiscipleState = state.disciples[state.disciples.keys()[0]]
    actor.profession_xp["mining"] = WorkforceSystem.P3_7_XP_LEVEL_SCALE * 150.0 * 150.0
    return _check(
        workforce.profession_level_for_state(state,actor,WorkforceSystem.PROF_MINING) == 100,
        "Economy V2 profession level exceeds approved Lv100 cap"
    )
