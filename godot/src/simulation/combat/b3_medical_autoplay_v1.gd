class_name B3MedicalAutoplayV1
extends RefCounted

const VERSION := 1
const MIN_HP_RATIO := 0.75

static func busy(state: SimulationState, d: DiscipleState) -> bool:
    if d.region_id != &"sect" or not d.active_pve_encounter_id.is_empty(): return true
    if WorkforceSystem.new().command_kind(d) not in [&"",WorkforceSystem.COMMAND_HOLD,WorkforceSystem.COMMAND_REST]: return true
    if not [&"EVALUATE",&"IDLE",&"HOLD",&"REST",&"HEAL"].has(d.current_action): return true
    var b := BuildingSystem.new()
    return not d.work_cycle_state.is_empty() or not d.work_progress.is_empty() or d.worksite_building_id != &"" or b.disciple_has_active_spirit_plot(state,d.id) or b.disciple_has_active_timed_recipe(state,d.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,d)

static func commit_owner(owner: SimulationRuntimeOwnerV2) -> Dictionary:
    if owner.state == null or owner.durable_path.is_empty(): return {"ok":false,"reason":"care_requires_durable_owner"}
    if not owner.state.sect.b3_hunt.is_empty(): return B3HuntWorld.commit(owner)
    var error := owner.saves.save_to_path(owner.state,owner.durable_path)
    owner.b3_write_blocked = error != OK
    return {"ok":error == OK,"reason":"care_save_barrier_failed" if error != OK else "","error":error}

static func command_ready(owner: SimulationRuntimeOwnerV2) -> bool:
    return owner != null and owner.state != null and not owner.durable_path.is_empty() and not owner.b3_write_blocked and (owner.state.runtime_unconsumed_wall_seconds < 0.25 if not owner.state.sect.b3_hunt.is_empty() else SimulationRuntimeClockV2.pending_minutes(owner.state) == 0)

static func configure(owner: SimulationRuntimeOwnerV2, id: StringName, enabled: bool) -> Dictionary:
    if not command_ready(owner) or owner.state.sect.b3_hunt.is_empty(): return {"ok":false,"reason":"care_clock_or_world_not_ready"}
    var state := owner.state
    if not state.disciples.has(id): return {"ok":false,"reason":"care_unknown_disciple"}
    var d: DiscipleState = state.disciples[id]
    var ready := B3PillSatietyV1.enable(state,d)
    if not ready["ok"]: return ready
    var world := state.sect.b3_hunt
    if not str(world["member"]).is_empty() and str(world["member"]) != str(id): return {"ok":false,"reason":"care_other_member_deployed"}
    if not world.has("care"):
        world["care"] = {"version":VERSION,"disciple_id":str(id),"auto_hunt":false,"auto_heal":false,
            "min_hp_ratio":MIN_HP_RATIO,"next_review_tick":state.tick,"last_review_tick":-1,
            "owns_rest":false,"paused_manual":false,"status":"OFF","auto_deploys":0,"heals":0,"rest_requests":0}
    var p: Dictionary = world["care"]
    if str(p["disciple_id"]) != str(id): return {"ok":false,"reason":"care_policy_owner_conflict"}
    p["auto_hunt"] = enabled
    p["auto_heal"] = enabled
    p["paused_manual"] = false
    p["next_review_tick"] = state.tick
    p["status"] = "READY" if enabled else "OFF"
    if not enabled and bool(p["owns_rest"]) and d.active_pve_encounter_id.is_empty():
        WorkforceSystem.new().issue_command(state,d.id,WorkforceSystem.COMMAND_HOLD,"",1000000)
        d.current_action = &"HOLD"
        p["owns_rest"] = false
    return commit_owner(owner)

static func pause_manual(state: SimulationState) -> void:
    if not state.sect.b3_hunt.has("care"): return
    var p: Dictionary = state.sect.b3_hunt["care"]
    p["auto_hunt"] = false
    p["paused_manual"] = true
    p["status"] = "MANUAL_PAUSE"

static func review(state: SimulationState, battle: MapBattleV2) -> void:
    var world := state.sect.b3_hunt
    if not world.has("care") or not battle.pending_kill_events().is_empty(): return
    var p: Dictionary = world["care"]
    if state.tick < int(p["next_review_tick"]) or (not p["auto_hunt"] and not p["auto_heal"]): return
    p["last_review_tick"] = state.tick
    p["next_review_tick"] = state.tick+1
    var d: DiscipleState = state.disciples[StringName(p["disciple_id"])]
    if not d.active_pve_encounter_id.is_empty():
        p["status"] = "HUNTING" if B3HuntWorld.owns_reservation(state,d) else "BUSY"
        return
    if busy(state,d):
        p["status"] = "BUSY"
        return
    var workforce := WorkforceSystem.new()
    if d.hp/d.max_hp < MIN_HP_RATIO and p["auto_heal"]:
        var pill_id := MedicineAllocationV2.best_available(state, d, MedicineCatalogueV2.FAMILY_HEAL)
        # CARE and SX01 share the same no-waste rule. If no meaningful
        # legacy recovery is possible, fall back to the existing REST path
        # without touching Warehouse, B3 satiety, or receipt sequence.
        if pill_id == &"" and MedicineAllocationV2.legacy_heal_useful_for_auto(d):
            pill_id = &"hoi_xuan_dan"
        var used := {"ok":false}
        if pill_id != &"":
            used = B3PillSatietyV1.consume(state,d,pill_id,B3PillSatietyV1.next_sequence(d))
        if used["ok"]:
            p["heals"] = int(p["heals"])+1
            p["status"] = "PILL_RECOVERY"
        else:
            # One review per simulation minute; canonical REST is the effect.
            if workforce.command_kind(d) not in [&"",WorkforceSystem.COMMAND_HOLD,WorkforceSystem.COMMAND_REST]:
                p["status"] = "BUSY"
                return
            if workforce.issue_command(state,d.id,WorkforceSystem.COMMAND_REST,"",3):
                if d.current_action not in [&"EVALUATE",&"REST"]: d.current_action = &"EVALUATE"
                p["owns_rest"] = true
                p["rest_requests"] = int(p["rest_requests"])+1
            p["status"] = "REST_RECOVERY"
    # After REST has restored enough HP, keep this policy's idle reservation
    # throughout Injury. A short REST command must not expire into autonomous
    # cultivation on the same scheduler tick that clears Injury.
    if d.hp/d.max_hp >= MIN_HP_RATIO and p["owns_rest"]:
        workforce.issue_command(state,d.id,WorkforceSystem.COMMAND_HOLD,"",1000000)
        d.current_action = &"HOLD"
    if d.injury_level != 0:
        if d.hp/d.max_hp >= MIN_HP_RATIO: p["status"] = "INJURY_WAIT"
        return
    if not p["auto_hunt"]:
        p["status"] = "MANUAL_PAUSE" if p["paused_manual"] else "OFF"
        return
    if d.hp/d.max_hp < MIN_HP_RATIO: return
    if p["owns_rest"]:
        workforce.clear_command(state,d)
        d.current_action = &"HOLD"
        p["owns_rest"] = false
    if EquipmentSystem.new().equipped_item(state,d,EquipmentSystem.SLOT_WEAPON).is_empty():
        p["status"] = "MISSING_LOADOUT"
        return
    var admitted := B3HuntWorld.admission(state,d.id)
    if not admitted["ok"]:
        p["status"] = str(admitted["reason"])
        return
    var deployed := B3HuntWorld.deploy(state,battle,d.id)
    if deployed["ok"]:
        p["auto_deploys"] = int(p["auto_deploys"])+1
        p["status"] = "HUNTING"

static func use_pill(owner: SimulationRuntimeOwnerV2, id: StringName, pill: StringName, sequence: int) -> Dictionary:
    if not command_ready(owner) or not owner.state.disciples.has(id): return {"ok":false,"reason":"pill_clock_or_actor_not_ready"}
    var d: DiscipleState = owner.state.disciples[id]
    var enabled := B3PillSatietyV1.enable(owner.state,d)
    if not enabled["ok"]: return enabled
    var result := B3PillSatietyV1.consume(owner.state,d,pill,sequence)
    if not result["ok"]: return result
    var saved := commit_owner(owner)
    return result if saved["ok"] else saved

static func craft(owner: SimulationRuntimeOwnerV2, recipe: StringName, sequence: int, protected_id: StringName = &"") -> Dictionary:
    if not command_ready(owner): return {"ok":false,"reason":"craft_clock_not_ready"}
    var state := owner.state
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null or not AlchemyRecipeRegistry.new().has(recipe): return {"ok":false,"reason":"craft_hall_or_recipe_missing"}
    var previous: Dictionary = hall.production_state.get("b3_command",{})
    var last := int(previous.get("sequence",0))
    if sequence <= last:
        return {"ok":sequence == last and str(previous.get("recipe","")) == str(recipe),"replay":true,"reason":"duplicate_craft_request"}
    if sequence != last+1: return {"ok":false,"reason":"invalid_craft_sequence"}
    if not WarehouseSystem.new().can_consume_requirements(state,AlchemyRecipeRegistry.new().inputs(recipe)):
        return {"ok":false,"reason":"insufficient_or_reserved_inputs"}
    var chosen: DiscipleState
    var ids: Array = state.disciples.keys()
    ids.sort()
    var reserved := str(state.sect.b3_hunt.get("care",{}).get("disciple_id",state.sect.b3_hunt.get("member","")))
    for id in ids:
        var d: DiscipleState = state.disciples[id]
        if d.id == protected_id or str(d.id) == reserved or d.region_id != &"sect" or not d.active_pve_encounter_id.is_empty() or d.current_action not in [&"EVALUATE",&"IDLE",&"HOLD"]: continue
        if WorkforceSystem.new().command_kind(d) not in [&"",WorkforceSystem.COMMAND_HOLD]: continue
        if not d.work_cycle_state.is_empty() or buildings.disciple_has_active_timed_recipe(state,d.id) or buildings.disciple_has_active_spirit_plot(state,d.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,d): continue
        if d.worksite_building_id != &"" and d.worksite_building_id != hall.id: continue
        if buildings.active_worker_ids(state,hall).has(d.id) or buildings.active_worker_ids(state,hall).size() < buildings.worker_slots(hall):
            chosen = d
            break
    if chosen == null: return {"ok":false,"reason":"craft_no_idle_alchemy_worker"}
    var workforce := WorkforceSystem.new()
    if not workforce.assign_group(state,chosen.id,hall.worker_group_id) or not workforce.assign_worksite(state,chosen.id,hall.id): return {"ok":false,"reason":"craft_assignment_failed"}
    if not buildings.set_alchemy_recipe(state,hall.id,recipe): return {"ok":false,"reason":"craft_recipe_rejected"}
    var result := workforce.perform_work(state,chosen,WorkforceSystem.PROF_ALCHEMY)
    if not result.get("ok",false): return result
    var job: Dictionary = result["job"]
    hall.production_state["b3_command"] = {"sequence":sequence,"recipe":str(recipe),"job_id":job["job_id"],"worker_id":str(chosen.id),"state":"COMMITTED"}
    var saved := commit_owner(owner)
    return result if saved["ok"] else saved

static func buy_demo_inputs(owner: SimulationRuntimeOwnerV2) -> Dictionary:
    if not command_ready(owner): return {"ok":false,"reason":"market_clock_not_ready"}
    var state := owner.state
    var economy := EconomySystem.new()
    economy.enable_v1(state)
    var results: Array = [economy.sell_to_npc_v1(state,&"thanh_thiet",5,"b3-care-starter-sell-a"),
        economy.sell_to_npc_v1(state,&"thanh_thiet",5,"b3-care-starter-sell-b"),
        economy.buy_from_npc_v1(state,&"thanh_linh_thao",5,"b3-care-starter-herbs"),
        economy.buy_from_npc_v1(state,&"linh_coc",1,"b3-care-starter-grain")]
    var saved := commit_owner(owner)
    if not saved["ok"]: return saved
    for result in results:
        if not result["ok"]: return result
    return {"ok":true,"starter_trade":true}

static func validate(state: SimulationState) -> String:
    for d in state.disciples.values():
        var error := B3PillSatietyV1.validate(state,d)
        if not error.is_empty(): return error
    var w := state.sect.b3_hunt
    if w.has("care"):
        if not (w["care"] is Dictionary): return "invalid_care_policy_shape"
        var p: Dictionary = w["care"]
        if not B3PillSatietyV1.whole(p.get("version")) or not (p.get("min_hp_ratio") is int or p.get("min_hp_ratio") is float): return "invalid_care_version_or_ratio_shape"
        if int(p["version"]) != VERSION or float(p["min_hp_ratio"]) != MIN_HP_RATIO: return "unsupported_care_policy"
        for key in ["auto_hunt","auto_heal","owns_rest","paused_manual"]:
            if not (p.get(key) is bool): return "invalid_care_flag_"+key
        for key in ["next_review_tick","last_review_tick","auto_deploys","heals","rest_requests"]:
            if not B3PillSatietyV1.whole(p.get(key)): return "invalid_care_counter_"+key
        if int(p["next_review_tick"]) < 0 or int(p["last_review_tick"]) < -1 or int(p["last_review_tick"]) > state.tick or int(p["auto_deploys"]) < 0 or int(p["heals"]) < 0 or int(p["rest_requests"]) < 0: return "invalid_care_counter_range"
        var id := StringName(p.get("disciple_id",""))
        if not state.disciples.has(id) or state.disciples[id].b3_pill_state.is_empty(): return "care_satiety_owner_missing"
        if not str(w.get("member","")).is_empty() and str(w["member"]) != str(id): return "care_world_owner_conflict"
    for building in state.buildings.values():
        if building.building_type != BuildingSystem.TYPE_ALCHEMY_HALL: continue
        var command = building.production_state.get("b3_command",{})
        if not (command is Dictionary): return "invalid_craft_receipt_shape"
        if not command.is_empty():
            if not B3PillSatietyV1.whole(command.get("sequence")) or int(command["sequence"]) < 1 or str(command.get("state","")) != "COMMITTED" or not AlchemyRecipeRegistry.new().has(StringName(command.get("recipe",""))) or not state.disciples.has(StringName(command.get("worker_id",""))) or str(command.get("job_id","")).is_empty(): return "invalid_craft_receipt"
        if not (building.production_state.get("jobs",[]) is Array): return "invalid_alchemy_jobs_shape"
        for job in building.production_state.get("jobs",[]):
            if job is Dictionary and str(job.get("recipe_id","")) == "tu_khi_dan":
                if str(job.get("output_resource_id","")) != "tu_khi_dan" or int(job.get("output_quantity",0)) != 1 or not (job.get("inputs") is Dictionary) or job["inputs"].size() != 2 or float(job["inputs"].get("thanh_linh_thao",0)) != 2.0 or float(job["inputs"].get("linh_coc",0)) != 1.0: return "invalid_tu_khi_recipe_snapshot"
    return ""
