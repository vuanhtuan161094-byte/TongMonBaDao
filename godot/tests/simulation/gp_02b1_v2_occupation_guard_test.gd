extends SceneTree

# GP-02B1: backend-only occupation gates, real authenticated V2 recruits,
# Mine/Forest carry cycles, paid Spirit Field + timed Alchemy jobs, Body slot
# transfers and canonical save/offline continuation. No new gameplay state.
const SAVE_PATH := "user://gp_02b1_v2_occupation_guard_test.json"
var workforce := WorkforceSystem.new()
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    if not _test_body_switch_and_p2():
        return
    if not _test_carry(WorkforceSystem.PROF_MINING):
        return
    if not _test_carry(WorkforceSystem.PROF_FORESTRY):
        return
    if not _test_spirit_plot_and_alchemy():
        return
    print("GP-02B1 V2 BACKEND OCCUPATION + OFFLINE + LEGACY ISOLATION: PASS")
    _cleanup()
    quit(0)

func _seed() -> Dictionary:
    var state := P37Factory.create_state(820231)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 500
    var hall := buildings.ensure_body_training_facility(state)
    if hall == null:
        return {}
    var actor := _recruit(state, 8801)
    if actor == null:
        return {}
    var founders: Array = state.disciples.keys()
    founders.sort()
    for raw_id in founders:
        if StringName(raw_id) == actor.id:
            continue
        if not workforce.issue_command(state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 1000):
            return {}
    return {"state":state,"actor":actor}

func _recruit(state: SimulationState, index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    if candidate == null or candidate.v2_birth_profile.is_empty():
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    var actor: DiscipleState = state.disciples[candidate.id]
    actor.current_action = &"EVALUATE"
    return actor

func _test_body_switch_and_p2() -> bool:
    var fx := _seed()
    if not _check(not fx.is_empty(), "Cannot seed real V2 Body facility."):
        return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actor"]
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_BODY_TRAINING)
    var stones := state.sect.spirit_stones
    var body_xp := float(actor.v2_realm_progress["body"]["xp"])
    if not _check(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false))
        and bool(DiscipleTrainingActionV2.request_training(state,actor.id,"body").get("ok",false))
        and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor)
        and state.sect.spirit_stones == stones
        and float(actor.v2_realm_progress["body"]["xp"]) == body_xp,
        "Real Body reservation mutated unpaid training XP/cost."):
        return false
    if not _check(bool(DiscipleTrainingActionV2.request_training(state,actor.id,"cultivation").get("ok",false))
        and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor)
        and actor.work_group_id == &""
        and actor.worksite_building_id == &""
        and buildings.active_worker_ids(state,hall).is_empty(),
        "Valid Body -> Cultivation transfer failed to free real slot."):
        return false
    if not _check(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false))
        and bool(DiscipleTrainingActionV2.request_training(state,actor.id,"body").get("ok",false)),
        "Valid Cultivation -> Body transfer was blocked."):
        return false
    var scheduler := SimulationScheduler.new(state)
    scheduler.step()
    scheduler.step()
    if not _check(state.sect.spirit_stones == stones-1
        and float(actor.v2_realm_progress["body"]["xp"]) > body_xp,
        "Canonical scheduled Body minute was not charged/granted once."):
        return false
    var legacy_id := &""
    for raw_id in state.disciples.keys():
        var d: DiscipleState = state.disciples[raw_id]
        if not DiscipleRealmProgressV2.owns_v2_progression(d):
            legacy_id = d.id
            break
    if not _check(legacy_id != &"" and workforce.issue_command(
        state,legacy_id,WorkforceSystem.COMMAND_CULTIVATE,"",40
    ),"GP-02B1 changed the P2 legacy command branch."):
        return false
    return true

func _test_carry(profession: StringName) -> bool:
    var fx := _seed()
    if not _check(not fx.is_empty(),"Cannot seed V2 carry-cycle test."):
        return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actor"]
    var producer := buildings.primary_building(
        state,buildings.building_type_for_profession(profession)
    )
    if not _check(producer != null,"Missing producer for "+str(profession)):
        return false
    for raw_id in state.disciples.keys():
        var d: DiscipleState = state.disciples[raw_id]
        if d.id != actor.id and d.work_group_id == producer.worker_group_id:
            if not _check(workforce.assign_group(state,d.id,&""),"Cannot release occupied producer slot."):
                return false
    if not _check(workforce.assign_group(state,actor.id,producer.worker_group_id)
        and workforce.assign_worksite(state,actor.id,producer.id)
        and buildings.active_worker_ids(state,producer).has(actor.id)
        and workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_WORK,str(profession),200),
        "V2 cannot start a genuine production shift for "+str(profession)):
        return false
    var resource_id := &"thanh_thiet" if profession == WorkforceSystem.PROF_MINING else &"linh_moc"
    var old_stock := warehouse.quantity(state,resource_id)
    var old_xp := float(actor.profession_xp.get(str(profession),0.0))
    var phases: Array[String] = ["travel_out","mining" if profession == WorkforceSystem.PROF_MINING else "harvesting","haul_back"]
    var scheduler := SimulationScheduler.new(state)
    for phase in phases:
        var found := false
        for unused in range(80):
            scheduler.step()
            if str(actor.work_cycle_state.get("phase","")) == phase and actor.current_action == &"EVALUATE":
                found = true
                break
        if not _check(found,"Never reached "+phase+" in real "+str(profession)+" cycle."):
            return false
        if not _assert_training_denied(state,actor,phase):
            return false
        if not _check(warehouse.quantity(state,resource_id) == old_stock,
            "Rejected order caused early production output."):
            return false
    var carried := int(actor.work_cycle_state.get("carried_units",0))
    if not _check(carried > 0,"Real haul-back has no carried resources."):
        return false
    # Canonical runtime save/offline from real mid-haul stage.
    var start_wall := 1710000000
    var owner := SimulationRuntimeOwnerV2.new()
    if not _check(bool(owner.attach(state,start_wall).get("ok",false))
        and bool(owner.save_to_path(SAVE_PATH,start_wall).get("ok",false)),
        "Cannot commit canonical mid-haul save."):
        return false
    var restored := SimulationRuntimeOwnerV2.new()
    var loaded := restored.load_from_path(SAVE_PATH,start_wall+120*60)
    if not _check(bool(loaded.get("ok",false)),
        "Cannot reload and catch up genuine producer offline."):
        return false
    var after: SimulationState = restored.state
    var updated: DiscipleState = after.disciples[actor.id]
    var stock_after := warehouse.quantity(after,resource_id)
    if not _check(stock_after >= old_stock+carried
        and float(updated.profession_xp.get(str(profession),0.0)) > old_xp
        and int(updated.v2_realm_progress.get("last_passive_tuvi_tick",-1)) == after.tick,
        "Offline V2 cycle did not deliver work and natural Tu Vi."):
        return false
    if not _check(bool(restored.save_to_path(SAVE_PATH,start_wall+120*60).get("ok",false)),
        "Cannot save offline result before replay check."):
        return false
    var second := SimulationRuntimeOwnerV2.new()
    var repeat := second.load_from_path(SAVE_PATH,start_wall+120*60)
    if not _check(bool(repeat.get("ok",false))
        and int(repeat.get("catch_up_steps",-1)) == 0
        and warehouse.quantity(second.state,resource_id) == stock_after
        and float((second.state.disciples[actor.id] as DiscipleState).profession_xp.get(str(profession),0.0))
           == float(updated.profession_xp.get(str(profession),0.0)),
        "Repeated offline load minted another work payout."):
        return false
    _cleanup()
    return true

func _test_spirit_plot_and_alchemy() -> bool:
    var fx := _seed()
    if not _check(not fx.is_empty(),"Cannot seed field and Alchemy V2 workers."):
        return false
    var state: SimulationState = fx["state"]
    var field_worker: DiscipleState = fx["actor"]
    var alchemist := _recruit(state,8802)
    if not _check(alchemist != null,"Cannot recruit V2 Alchemist."):
        return false
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(field != null and hall != null,"Missing actual timed buildings."):
        return false
    if not _check(workforce.assign_group(state,field_worker.id,field.worker_group_id)
        and workforce.assign_worksite(state,field_worker.id,field.id)
        and workforce.issue_command(state,field_worker.id,WorkforceSystem.COMMAND_HOLD,"",1000)
        and workforce.assign_group(state,alchemist.id,hall.worker_group_id)
        and workforce.assign_worksite(state,alchemist.id,hall.id)
        and workforce.issue_command(state,alchemist.id,WorkforceSystem.COMMAND_HOLD,"",1000),
        "Cannot bind real Field/Alchemy occupations."):
        return false
    var crops := SpiritCropRegistry.new()
    var scheduler := SimulationScheduler.new(state)
    var herb_before := warehouse.quantity(state,&"thanh_linh_thao")
    var found_herbs := false
    for attempt in range(4):
        var start := workforce.perform_work(state,field_worker,WorkforceSystem.PROF_HERBALISM)
        if not _check(bool(start.get("ok",false)) and
            buildings.disciple_has_active_spirit_plot(state,field_worker.id),
            "Real Spirit Field did not start a paid growing plot."):
            return false
        if not _assert_training_denied(state,field_worker,"spirit_plot"):
            return false
        var plots := buildings.spirit_field_plots(state,field)
        if not _check(plots.size() > 0,"No actual Spirit Field production state."):
            return false
        var finish := -1
        for raw_plot in plots:
            if raw_plot is Dictionary and str(raw_plot.get("assigned_worker_id","")) == str(field_worker.id):
                finish = int(raw_plot.get("finish_tick",-1))
                break
        if not _check(finish > state.tick,"Paid plot has no valid finish tick."):
            return false
        while state.tick <= finish:
            scheduler.step()
        if not _check(not buildings.disciple_has_active_spirit_plot(state,field_worker.id),
            "Canonical field timer failed to release worker."):
            return false
        if warehouse.quantity(state,&"thanh_linh_thao") >= herb_before+3:
            found_herbs = true
            break
    if not _check(found_herbs and warehouse.quantity(state,&"thanh_linh_thao") >= 3,
        "Actual field failed to produce the recipe's paid herbs."):
        return false
    var started := workforce.perform_work(state,alchemist,WorkforceSystem.PROF_ALCHEMY)
    if not _check(bool(started.get("ok",false)) and
        buildings.disciple_has_active_timed_recipe(state,alchemist.id),
        "Real timed Alchemy recipe did not start on earned herbs."):
        return false
    if not _assert_training_denied(state,alchemist,"alchemy_job"):
        return false
    var before_pills := warehouse.quantity(state,NeedsSystem.HEALING_PILL_ID)
    var alchemy_job := buildings.active_alchemy_job_for_worker(state,alchemist.id)
    var finish_tick := int(alchemy_job.get("finish_tick",-1))
    if not _check(finish_tick > state.tick,"Timed Alchemy missing finish tick."):
        return false
    var saved_job := alchemy_job.duplicate(true)
    var persisted := SimulationState.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
    if not _check(buildings.active_alchemy_job_for_worker(persisted,alchemist.id) == saved_job,
        "Persisted V2 alchemy worker lost active recipe."):
        return false
    var loaded_scheduler := SimulationScheduler.new(persisted)
    while persisted.tick < finish_tick:
        loaded_scheduler.step()
    if not _check(not buildings.disciple_has_active_timed_recipe(persisted,alchemist.id)
        and warehouse.quantity(persisted,NeedsSystem.HEALING_PILL_ID) == before_pills+1,
        "Rejected Body/Chuyên Tu corrupted Alchemy receipt after reload."):
        return false
    return true

func _assert_training_denied(state: SimulationState, actor: DiscipleState, label: String) -> bool:
    var before_actor := actor.to_dict()
    var stones := state.sect.spirit_stones
    var event_count := state.sect.workforce_event_count
    var cultivation_xp := float(actor.v2_realm_progress["cultivation"]["xp"])
    var body_xp := float(actor.v2_realm_progress["body"]["xp"])
    var cult := DiscipleTrainingActionV2.request_training(state,actor.id,"cultivation")
    var body := DiscipleTrainingActionV2.request_training(state,actor.id,"body")
    var reserve := DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id)
    var compat := workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_CULTIVATE,"",40)
    return _check(not bool(cult.get("ok",true))
        and not bool(body.get("ok",true))
        and not bool(reserve.get("ok",true))
        and not compat
        and actor.to_dict() == before_actor
        and state.sect.spirit_stones == stones
        and state.sect.workforce_event_count == event_count
        and float(actor.v2_realm_progress["cultivation"]["xp"]) == cultivation_xp
        and float(actor.v2_realm_progress["body"]["xp"]) == body_xp,
        "Backend training stole a "+label+" worker, resources, or training state.")

func _check(ok: bool, message: String) -> bool:
    if ok:
        return true
    push_error("GP-02B1: "+message)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for path in [SAVE_PATH,SAVE_PATH+".bak",SAVE_PATH+".tmp"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
