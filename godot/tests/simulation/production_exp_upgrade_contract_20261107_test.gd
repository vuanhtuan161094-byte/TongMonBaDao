extends SceneTree

# Real P3.7 backend contracts: paid Forest upgrades; selected Mine ore; exact
# profession EXP per completed work cycle; cold-save survival. QA state only.
const SAVE_PATH := "user://production_exp_upgrade_contract_20261107.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(73119)
    var buildings := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    var warehouse := WarehouseSystem.new()
    var forest := buildings.primary_building(state, BuildingSystem.TYPE_LINH_FOREST)
    var mine := buildings.primary_building(state, BuildingSystem.TYPE_MINE)
    if forest == null or mine == null:
        _fail("missing real Mine/Forest buildings")
        return

    # Forest upgrade must have actual materials, payment and a real duration.
    var cost := buildings.upgrade_cost(forest)
    var wood_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD))
    var ore_before := warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE))
    var stones_before := state.sect.spirit_stones
    var old_duration := buildings.resource_job_work_duration(forest)
    if not bool(buildings.can_start_upgrade(state, forest.id).get("ok", false)):
        _fail("Lv1 Linh Lam must expose a payable upgrade with starter stock")
        return
    var started := buildings.start_upgrade(state, forest.id)
    if not bool(started.get("ok", false)) or forest.level != 1 or not forest.is_upgrading():
        _fail("Linh Lam upgrade did not enter real timed state")
        return
    if warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_WOOD)) != wood_before - int(cost.get(BuildingSystem.MATERIAL_WOOD,0)) or warehouse.quantity(state, StringName(BuildingSystem.MATERIAL_ORE)) != ore_before - int(cost.get(BuildingSystem.MATERIAL_ORE,0)) or state.sect.spirit_stones != stones_before - int(cost.get("spirit_stones",0)):
        _fail("Linh Lam did not debit the exact canonical upgrade price once")
        return
    var upgrade_ticks := ceili(forest.upgrade_required_work)
    for index in range(upgrade_ticks):
        state.tick += 1
        buildings.process_tick(state)
    if forest.level != 2 or forest.is_upgrading() or int(forest.metrics.get("upgrade_completions",0)) != 1 or buildings.resource_job_work_duration(forest) >= old_duration:
        _fail("Linh Lam upgrade did not apply exactly one real level/speed change")
        return

    # Mine resource identity is durable and must pass invariants while in haul.
    mine.level = 10
    if not bool(buildings.select_mine_ore(state, mine.id, &"huyen_thiet").get("ok",false)):
        _fail("Lv10 Mine cannot select registered Huyen Thiet")
        return
    var active := buildings.active_worker_ids(state, mine)
    if active.is_empty() or not state.disciples.has(active[0]):
        _fail("no existing real Mine worker")
        return
    var worker: DiscipleState = state.disciples[active[0]]
    var xp_before := workforce.profession_xp(worker, WorkforceSystem.PROF_MINING)
    var expected_xp := workforce.expected_profession_xp_gain(state, worker, WorkforceSystem.PROF_MINING)
    var huyen_before := warehouse.quantity(state, &"huyen_thiet")
    var completed := false
    for cycle_step in range(64):
        var result := workforce.perform_work(state, worker, WorkforceSystem.PROF_MINING)
        if not bool(result.get("ok",false)):
            _fail("canonical Mine cycle rejected "+str(result))
            return
        if not worker.work_cycle_state.is_empty():
            if StringName(worker.work_cycle_state.get("resource_id","")) != &"huyen_thiet":
                _fail("committed Mine cycle lost its selected ore")
                return
            for error in buildings.validate_invariants(state):
                if str(error).contains("invalid resource-job output identity"):
                    _fail("invariant wrongly rejected legitimate Huyen Thiet carry")
                    return
        if bool(result.get("completed",false)):
            completed = true
            break
    if not completed:
        _fail("Mine cycle never settled")
        return
    var yielded := buildings.mine_ore_batch_units(mine, &"huyen_thiet")
    if warehouse.quantity(state,&"huyen_thiet") != huyen_before + yielded:
        _fail("completed Mine cycle did not deposit selected ore exactly once")
        return
    if not is_equal_approx(workforce.profession_xp(worker,WorkforceSystem.PROF_MINING)-xp_before, expected_xp):
        _fail("Mine credited a different amount of profession XP from the read-only preview")
        return
    var progress := workforce.profession_xp_progress(state,worker,WorkforceSystem.PROF_MINING)
    if int(progress.get("level",-1)) != workforce.profession_level_for_state(state,worker,WorkforceSystem.PROF_MINING) or float(progress.get("next_threshold",-1.0)) <= float(progress.get("xp",0.0)):
        _fail("profession XP level/threshold preview is inconsistent")
        return

    var saver := SaveService.new()
    if saver.save_to_path(state,SAVE_PATH) != OK:
        _fail("save of upgraded forest/selected ore/EXP failed")
        return
    var reloaded := saver.load_from_path(SAVE_PATH)
    if reloaded == null:
        _fail("cold reload failed")
        return
    var reloaded_forest := buildings.primary_building(reloaded,BuildingSystem.TYPE_LINH_FOREST)
    var reloaded_mine := buildings.primary_building(reloaded,BuildingSystem.TYPE_MINE)
    if reloaded_forest == null or reloaded_forest.level != 2 or reloaded_mine == null or buildings.mine_selected_ore(reloaded_mine) != &"huyen_thiet":
        _fail("cold reload changed Forest upgrade or Mine ore selection")
        return
    if not is_equal_approx(workforce.profession_xp(reloaded.disciples[worker.id],WorkforceSystem.PROF_MINING),workforce.profession_xp(worker,WorkforceSystem.PROF_MINING)):
        _fail("cold reload changed earned Mine profession EXP")
        return
    _cleanup()
    print("PRODUCTION EXP + FOREST PAID UPGRADE + SELECTED ORE + SAVE: PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error("PRODUCTION EXP/UPGRADE CONTRACT FAIL: "+message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for extension in ["",".tmp",".bak"]:
        var location: String = SAVE_PATH + str(extension)
        if FileAccess.file_exists(location):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(location))
