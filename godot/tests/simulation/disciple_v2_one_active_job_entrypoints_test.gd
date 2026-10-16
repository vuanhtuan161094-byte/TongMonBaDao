extends SceneTree

# Genuine V2 recruit + real timed production, Field and Alchemy entrypoint
# probes. NO second timer, fake production, free salaries or balance changes.
var buildings := BuildingSystem.new()
var workforce := WorkforceSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("DISCIPLE V2 ONE ACTIVE JOB FAIL: " + why)
        quit(1)
        return false
    return true

func _seed(index: int) -> Dictionary:
    var state := P37Factory.create_state(962200+index)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = state.disciples.size()+1
    state.sect.spirit_stones = 500
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,962300+index)
    if candidate == null:
        return {}
    state.recruitment_candidates[candidate.id] = candidate
    if not bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)):
        return {}
    var actor: DiscipleState = state.disciples[candidate.id]
    actor.current_action = &"EVALUATE"
    if not bool(EconomySystem.new().enable_v1(state).get("ok",false)):
        return {}
    return {"state":state,"actor":actor}

func _run() -> void:
    if not _mine_timer_guards():
        return
    if not _field_duty_guards():
        return
    if not _alchemy_timer_guards():
        return
    if not _direct_training_and_command_guards():
        return
    print("DISCIPLE V2 ONE ACTIVE JOB ALL ENTRYPOINT REGRESSION PASS")
    quit(0)

func _mine_timer_guards() -> bool:
    var fixture := _seed(1)
    if not _check(not fixture.is_empty(),"Mine V2 fixture missing"):
        return false
    var state: SimulationState = fixture["state"]
    var actor: DiscipleState = fixture["actor"]
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"primary Mine missing"):
        return false
    for founder_id in buildings.active_worker_ids(state,mine):
        if not _check(workforce.assign_group(state,founder_id,&""),
            "initial Mine worker cannot be released"):
            return false
    if not _check(bool(workforce.assign_mine_worker(state,actor.id,mine.id).get("ok",false)),
        "authentic V2 worker could not take Mine slot"):
        return false
    var started := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(started.get("ok",false)) and bool(started.get("started",false))
        and not buildings.active_resource_timer_for_worker(state,actor.id).is_empty(),
        "real Mine packet did not start"):
        return false
    var ore_before := warehouse.quantity(state,&"thanh_thiet")
    var sect_stones_before := state.sect.spirit_stones
    var personal_before := actor.spirit_stones
    var profession_xp_before := float(actor.profession_xp.get("mining",0.0))
    var saved_worksite := actor.worksite_building_id

    if not _check(not workforce.assign_worksite(state,actor.id,&"")
        and not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_FORGING).get("ok",false))
        and not bool(workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_WORK,"forging",40))
        and not bool(DiscipleTrainingActionV2.request_training(state,actor.id,"cultivation").get("ok",false))
        and not bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false))
        and actor.worksite_building_id == saved_worksite
        and not buildings.active_resource_timer_for_worker(state,actor.id).is_empty()
        and warehouse.quantity(state,&"thanh_thiet") == ore_before
        and state.sect.spirit_stones == sect_stones_before
        and actor.spirit_stones == personal_before
        and float(actor.profession_xp.get("mining",0.0)) == profession_xp_before,
        "Mine timer was stolen, leaked income/XP, or accepted concurrent entrypoint"):
        return false

    # Explicit HOLD is authorized timer cancellation: no unearned output,
    # no salary and no legacy carried-unit deletion.
    if not _check(workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_HOLD,"",40)
        and buildings.active_resource_timer_for_worker(state,actor.id).is_empty()
        and warehouse.quantity(state,&"thanh_thiet") == ore_before
        and state.sect.spirit_stones == sect_stones_before
        and actor.spirit_stones == personal_before
        and actor.work_cycle_state.is_empty(),
        "lawful cancellation created rewards or failed to retire timer"):
        return false
    if not _check(workforce.assign_group(state,actor.id,&"")
        and buildings.ensure_body_training_facility(state) != null
        and bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false))
        and actor.direct_command.is_empty()
        and actor.current_action == &"EVALUATE",
        "legal Body transfer retained a stale HOLD command/action"):
        return false
    if not _check(bool(DiscipleTrainingPolicyV2.set_policy(state,actor.id,
            DiscipleTrainingPolicyV2.POLICY_BODY).get("ok",false))
        and workforce.next_action(state,actor) == &"TRAIN_BODY",
        "Body reservation still routes to HOLD instead of training"):
        return false
    return true

func _field_duty_guards() -> bool:
    var fixture := _seed(2)
    if not _check(not fixture.is_empty(),"Field fixture missing"):
        return false
    var state: SimulationState = fixture["state"]
    var actor: DiscipleState = fixture["actor"]
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(field != null and workforce.assign_group(state,actor.id,&"herbalism_crew")
        and workforce.assign_worksite(state,actor.id,field.id),
        "real Field worker assignment failed"):
        return false
    var field_stones := state.sect.spirit_stones
    actor.current_action = &"CULTIVATE"
    if not _check(not bool(buildings.perform_spirit_field_step(state,actor,1.0).get("ok",false))
        and state.sect.spirit_stones == field_stones,
        "direct Field entry overlapped cultivation or charged Stone"):
        return false
    actor.current_action = &"EVALUATE"
    var first := buildings.perform_spirit_field_step(state,actor,1.0)
    if not _check(bool(first.get("ok",false))
        and buildings.disciple_has_active_spirit_plot(state,actor.id,field),
        "first genuine Field plot did not start"):
        return false
    var second := buildings.perform_spirit_field_step(state,actor,1.0)
    if not _check(bool(second.get("ok",false)),
        "second plot under SAME Field duty incorrectly blocked"):
        return false
    var plots := buildings.spirit_field_plots(state,field)
    var duty_ids: Dictionary = {}
    var active_count := 0
    for entry in plots:
        if str(entry.get("assigned_worker_id","")) == str(actor.id):
            active_count += 1
            duty_ids[str(entry.get("field_duty_id",""))] = true
    if not _check(active_count == 2 and duty_ids.size() == 1
        and not duty_ids.has("") and not workforce.assign_worksite(state,actor.id,&"")
        and not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_FORGING).get("ok",false))
        and not bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false)),
        "Field job became multiple occupations or allowed another profession"):
        return false
    return true

func _alchemy_timer_guards() -> bool:
    var fixture := _seed(3)
    if not _check(not fixture.is_empty(),"Alchemy fixture missing"):
        return false
    var state: SimulationState = fixture["state"]
    var actor: DiscipleState = fixture["actor"]
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(hall != null and workforce.assign_group(state,actor.id,&"alchemy_crew")
        and workforce.assign_worksite(state,actor.id,hall.id),
        "genuine Alchemy worker assignment failed"):
        return false
    var recipe := AlchemyRecipeRegistry.new()
    var input_id := &"thanh_linh_thao"
    var required := int(recipe.inputs(AlchemyRecipeRegistry.RECIPE_HOI_XUAN_DAN).get(str(input_id),0))
    var missing := maxi(0,required-warehouse.available_quantity(state,input_id))
    if missing > 0 and not _check(warehouse.add(state,input_id,missing),"Alchemy fixture inputs unavailable"):
        return false
    var herbs_initial := warehouse.quantity(state,input_id)
    actor.current_action = &"CULTIVATE"
    if not _check(not bool(buildings.perform_alchemy_step(state,actor,0,1.0,1.0).get("ok",false))
        and warehouse.quantity(state,input_id) == herbs_initial,
        "direct Alchemy entry consumed herbs during cultivation"):
        return false
    actor.current_action = &"EVALUATE"
    var started := buildings.perform_alchemy_step(state,actor,0,1.0,1.0)
    if not _check(bool(started.get("ok",false))
        and not buildings.active_alchemy_job_for_worker(state,actor.id).is_empty(),
        "committed Alchemy timer did not start"):
        return false
    var stones_before := state.sect.spirit_stones
    var herbs_before := warehouse.quantity(state,input_id)
    if not _check(not workforce.assign_worksite(state,actor.id,&"")
        and not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_FORGING).get("ok",false))
        and not bool(workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_CULTIVATE,"",40))
        and not bool(DiscipleTrainingActionV2.request_training(state,actor.id,"body").get("ok",false))
        and not bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false))
        and not bool(buildings.perform_alchemy_step(state,actor,0,1.0,1.0).get("ok",false))
        and state.sect.spirit_stones == stones_before
        and warehouse.quantity(state,input_id) == herbs_before
        and not buildings.active_alchemy_job_for_worker(state,actor.id).is_empty(),
        "Alchemy timer transfer/overlap leaked work, resources or payment"):
        return false
    return true

func _direct_training_and_command_guards() -> bool:
    var fixture := _seed(4)
    if not _check(not fixture.is_empty(),"direct-work fixture unavailable"):
        return false
    var state: SimulationState = fixture["state"]
    var actor: DiscipleState = fixture["actor"]
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    if not _check(mine != null,"direct-work Mine missing"):
        return false
    for occupant in buildings.active_worker_ids(state,mine):
        if not _check(workforce.assign_group(state,occupant,&""),"direct-work Mine not released"):
            return false
    if not _check(bool(workforce.assign_mine_worker(state,actor.id,mine.id).get("ok",false)),
        "direct-work miner not assigned"):
        return false
    var ore_before := warehouse.quantity(state,&"thanh_thiet")
    var xp_before := float(actor.profession_xp.get("mining",0.0))
    for action in [&"CULTIVATE",&"TRAIN_BODY",&"WORK_FORGING"]:
        actor.current_action = action
        if not _check(not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING).get("ok",false))
            and not bool(buildings.perform_mining_step(state,actor,1.0,1.0).get("ok",false))
            and buildings.active_resource_timer_for_worker(state,actor.id).is_empty()
            and warehouse.quantity(state,&"thanh_thiet") == ore_before
            and float(actor.profession_xp.get("mining",0.0)) == xp_before,
            "direct Mine API admitted conflicting active action "+str(action)):
            return false
    actor.current_action = &"EVALUATE"
    actor.direct_command = {
        "kind":str(WorkforceSystem.COMMAND_HOLD),"target":"",
        "issued_tick":state.tick,"expires_tick":state.tick+40
    }
    if not _check(not bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING).get("ok",false))
        and not bool(buildings.perform_mining_step(state,actor,1.0,1.0).get("ok",false)),
        "direct Mine bypassed an existing HOLD order"):
        return false
    if not _check(workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_WORK,"mining",40),
        "explicit replacement of HOLD by WORK failed"):
        return false
    var started := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(started.get("ok",false)) and bool(started.get("started",false))
        and not buildings.active_resource_timer_for_worker(state,actor.id).is_empty(),
        "valid matching WORK order failed to start Mine timer"):
        return false
    # Round-trip the canonical saved timer, including the one-active-job gate.
    var recovered := SimulationState.from_dict(state.to_dict())
    if not _check(recovered != null,"Mine timer save/load roundtrip failed"):
        return false
    var loaded_actor: DiscipleState = recovered.disciples[actor.id]
    var loaded_job := buildings.active_resource_timer_for_worker(recovered,actor.id)
    if not _check(not loaded_job.is_empty()
        and not bool(workforce.perform_work(recovered,loaded_actor,WorkforceSystem.PROF_FORGING).get("ok",false)),
        "save/load dropped the timer occupation guard"):
        return false
    var target_tick := int(loaded_job.get("finish_tick",0))
    if not _check(target_tick > recovered.tick,"saved timer has invalid finish tick"):
        return false
    # Disable fresh autonomous Mine work; this does not alter the saved job.
    loaded_actor.work_preferences["mining"] = 0
    var scheduled := SimulationScheduler.new(recovered)
    var receipt_before := recovered.sect.economy_a_receipts.size()
    scheduled.run_ticks(target_tick-recovered.tick)
    var after_quantity := warehouse.quantity(recovered,&"thanh_thiet")
    var receipt_after := recovered.sect.economy_a_receipts.size()
    if not _check(after_quantity > ore_before
        and buildings.active_resource_timer_for_worker(recovered,actor.id).is_empty()
        and receipt_after == receipt_before+1,
        "offline-equivalent job settlement missing or receipt not written once"):
        return false
    scheduled.run_ticks(2)
    return _check(warehouse.quantity(recovered,&"thanh_thiet") == after_quantity
        and recovered.sect.economy_a_receipts.size() == receipt_after,
        "settled timer replay minted extra ore or wage receipts")
