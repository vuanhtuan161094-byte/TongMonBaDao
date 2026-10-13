extends SceneTree

# GP-02C1. Deterministic terminal fixtures below exercise transaction edges;
# the genuine PvE map encounter is exercised separately without synthetic loot.
const PATH := "user://gp_02c1_injury_settlement_test.json"
var workforce := WorkforceSystem.new()
var buildings := BuildingSystem.new()
var warehouse := WarehouseSystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, id: String, detail: String) -> bool:
    if not ok:
        push_error("GP-02C1 " + id + " FAILED: " + detail)
        _cleanup()
        quit(1)
        return false
    print("GP-02C1 " + id + " PASS")
    return true

func _cleanup() -> void:
    for path in [PATH, PATH + ".tmp", PATH + ".bak"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _seed(count: int = 3) -> Dictionary:
    var state := P37Factory.create_state(930211)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.spirit_stones = 400
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, state.disciples.size() + count)
    buildings.ensure_body_training_facility(state)
    for raw_id in state.disciples.keys():
        workforce.issue_command(state, StringName(raw_id), WorkforceSystem.COMMAND_HOLD, "", 10000)
    var actors: Array = []
    for i in range(count):
        var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
            state, DiscipleGeneratorV2.SOURCE_ORDINARY, 99441 + i
        )
        if candidate == null:
            return {}
        state.recruitment_candidates[candidate.id] = candidate
        if not bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)):
            return {}
        var disciple: DiscipleState = state.disciples[candidate.id]
        if not DiscipleRealmProgressV2.progression_ready(disciple):
            return {}
        disciple.current_action = &"EVALUATE"
        actors.append(disciple)
    return {"state":state,"actors":actors}

func _begin(fx: Dictionary, id: String, level: int = 1) -> HuntingPveRunV2:
    var state: SimulationState = fx["state"]
    if not bool(HuntingMapV2.choose_level(state,"thanh_truc_lam",level).get("ok",false)):
        return null
    var party: Array = []
    var i := 0
    for disciple in fx["actors"]:
        party.append({"disciple_id":str(disciple.id),"party_id":"gp02c1",
            "role":"healer" if i == 2 else "frontline",
            "position":Vector2(8.0+float(i)*0.35,8.0+float(i%2)*0.35)})
        i += 1
    var session := HuntingPveRunV2.new()
    return session if bool(session.begin(state,"thanh_truc_lam",id,7788,party).get("ok",false)) else null

# Explicitly controlled terminal battle actors are unit fixtures ONLY. They
# do not claim that a real battle produced a win or any earned reward.
func _fixture_terminal(session: HuntingPveRunV2, outcome: String, downed: Array) -> Dictionary:
    for raw_id in session.battle.actors.keys():
        var a: Dictionary = session.battle.actors[raw_id]
        if str(a["side"]) == "disciple":
            a["hp"] = 0.0 if downed.has(str(raw_id)) else float(a["max_hp"])*0.35
        elif outcome == "win":
            a["hp"] = 0.0
    session.battle.active = false
    session.battle.outcome = outcome
    return session.finish()

func _run() -> void:
    _cleanup()
    if not _terminal_contract(): return
    if not _receipt_replay_and_compatibility(): return
    if not _legacy_active_pve_save_migration(): return
    if not _legacy_terminal_and_fail_closed(): return
    if not _legacy_completed_win_claim(): return
    if not _timed_occupation_guards(): return
    if not _work_guard_and_recovery(): return
    if not _real_pve_and_claim(): return
    print("GP-02C1 T01-T23 FOCUSED TERMINAL/RECOVERY/COMPATIBILITY PASS")
    _cleanup()
    quit(0)

func _terminal_contract() -> bool:
    var fx := _seed(3)
    if not _check(not fx.is_empty(),"SETUP","real V2 recruits unavailable"): return false
    var state: SimulationState = fx["state"]
    var actors: Array = fx["actors"]
    var wounded: DiscipleState = actors[0]
    wounded.hp = wounded.max_hp*0.15
    if not _check(wounded.hp > 0.0 and wounded.injury_level == 0,"T01","low HP cannot imply Injury"): return false
    var s := _begin(fx,"gp2c-win-with-downed")
    if not _check(s != null,"BEGIN","real map session refused valid roster"): return false
    if not _check(wounded.active_pve_encounter_id == s.battle.encounter_id and s.battle.actors[str(wounded.id)].get("linked_disciple",null) == null,"HP_OWNER","live DiscipleState leaked into battle"): return false
    var second := HuntingPveRunV2.new()
    var conflict: Array = [{"disciple_id":str(wounded.id),"party_id":"x"}]
    var refused := second.begin(state,"thanh_truc_lam","gp2c-second-id",779,conflict)
    if not _check(not bool(refused.get("ok",false)) and not state.sect.v2_pve_active_runs.has("gp2c-second-id"),"T13","same disciple entered two encounters"): return false
    if not _check(not bool(s.claim().get("ok",false)) and state.sect.v2_pve_reward_claims.is_empty(),"T07","unsettled battle claimed reward"): return false
    var before := wounded.hp
    s.battle.actors[str(wounded.id)]["hp"] = 0.0
    if not _check(wounded.hp == before and wounded.injury_level == 0,"HP_ISOLATION","combat mutated persistent HP before settle"): return false
    var settled := _fixture_terminal(s,"win",[str(wounded.id)])
    var healthy: DiscipleState = actors[1]
    if not _check(bool(settled.get("ok",false)) and wounded.hp == 1.0 and wounded.injury_level == 1 and wounded.region_id == &"sect","T02","downed character missing HP=1 and Injury=1"): return false
    if not _check(healthy.injury_level == 0 and healthy.hp > 1.0 and state.sect.v2_pve_settlement_receipts.has(s.battle.encounter_id),"T03","win with downed participant injured non-downed actor"): return false
    var first_tick := wounded.injury_recover_at_tick
    var once := s.finish()
    if not _check(bool(once.get("ok",false)) and bool(once.get("already_settled",false)) and wounded.injury_recover_at_tick == first_tick,"T05","repeat finish changed injury timestamp"): return false
    if not _check(not bool(s.advance().get("ok",false)) and wounded.injury_recover_at_tick == first_tick,"T06","terminal advance replayed combat"): return false
    if not _check(wounded.active_pve_encounter_id.is_empty() and healthy.active_pve_encounter_id.is_empty(),"RELEASE","terminal failed to release actor reservations"): return false

    var other := _seed(1)
    if not _check(not other.is_empty(),"SETUP_RETREAT","missing retreat actor"): return false
    var retreat := _begin(other,"gp2c-retreat")
    if not _check(retreat != null,"RETREAT_BEGIN","could not launch retreat fixture"): return false
    var r := _fixture_terminal(retreat,"timeout_retreat",[])
    var r_actor: DiscipleState = other["actors"][0]
    if not _check(bool(r.get("ok",false)) and r_actor.injury_level == 0 and not (other["state"] as SimulationState).sect.v2_pve_active_runs.has(retreat.battle.encounter_id),"T04","clean retreat applied injury or kept run"): return false
    return true

func _receipt_replay_and_compatibility() -> bool:
    var fx := _seed(1)
    if not _check(not fx.is_empty(),"SAVE_SETUP","seed unavailable"): return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actors"][0]
    var session := _begin(fx,"gp2c-defeat")
    if not _check(session != null,"DEFEAT_BEGIN","real session unavailable"): return false
    var out := _fixture_terminal(session,"defeat",[str(actor.id)])
    if not _check(bool(out.get("ok",false)) and actor.injury_level == 1 and not state.sect.v2_pve_active_runs.has("gp2c-defeat"),"T09","defeat did not independently settle and clean"): return false
    if not _check(not bool(session.claim().get("ok",false)) and state.sect.v2_pve_reward_claims.is_empty(),"NO_LOOT","defeat could claim reward"): return false
    var saved := SaveService.new().save_to_path(state,PATH)
    if not _check(saved == OK,"SAVE","canonical SaveService failed"): return false
    var reload := SaveService.new().load_from_path(PATH)
    if not _check(reload != null and reload.sect.v2_pve_settlement_receipts.has("gp2c-defeat"),"RECEIPT_SAVE","terminal receipt missing after disk reload"): return false
    var restored: DiscipleState = reload.disciples[actor.id]
    if not _check(restored.injury_level == 1 and restored.injury_recover_at_tick == actor.injury_recover_at_tick and not HuntingPveRunV2.resume_active(reload,"gp2c-defeat").get("ok",false),"RECEIPT_LOAD","resumed already-settled defeat"): return false
    var recorded: Dictionary = state.sect.v2_pve_settlement_receipts["gp2c-defeat"].duplicate(true)
    state.sect.v2_pve_settlement_receipts["gp2c-defeat"] = {"outcome":"win","members":{}}
    var rejected := session.finish()
    if not _check(not bool(rejected.get("ok",false)) and actor.injury_level == 1,"T23","corrupt receipt permitted terminal replay"): return false
    state.sect.v2_pve_settlement_receipts["gp2c-defeat"] = recorded
    _cleanup()

    var old := _seed(1)
    if not _check(not old.is_empty(),"LEGACY_SETUP","seed unavailable"): return false
    var old_state: SimulationState = old["state"]
    var data: Dictionary = old_state.to_dict()
    for row in data["disciples"]:
        row.erase("injury_level")
        row.erase("injury_recover_at_tick")
        row.erase("active_pve_encounter_id")
    (data["sect"] as Dictionary).erase("v2_pve_settlement_receipts")
    var migrated := SimulationState.from_dict(data)
    var a: DiscipleState = migrated.disciples[(old["actors"][0] as DiscipleState).id]
    if not _check(a.injury_level == 0 and a.injury_recover_at_tick == 0 and a.active_pve_encounter_id.is_empty(),"T22","older save failed compatibility defaults"): return false
    return true


# T15: genuine paid Spirit Field and Alchemy jobs must remain untouched when
# the same worker attempts a conflicting V2 expedition.

# Genuine legacy V2 snapshot fixtures are saved WITHOUT the GP-02C1 field.
# SaveService then migrates the exact persisted bytes before offline catch-up.
func _legacy_active_pve_save_migration() -> bool:
    var fx := _seed(2)
    if not _check(not fx.is_empty(),"LEGACY_ACTIVE_SETUP","missing authentic V2 recruits"): return false
    var state: SimulationState = fx["state"]
    var s := _begin(fx,"gp2c-legacy-inflight")
    if not _check(s != null,"LEGACY_ACTIVE_BEGIN","cannot start genuine hunt"): return false
    var actors: Array = fx["actors"]
    for actor in actors:
        (actor as DiscipleState).active_pve_encounter_id = ""
    var hp_before := (actors[0] as DiscipleState).hp
    var old_tick := state.tick
    state.runtime_last_wall_unix = 1000000
    if not _check(SaveService.new().save_to_path(state,PATH) == OK,"LEGACY_ACTIVE_SAVE","legacy snapshot not accepted by canonical SaveService"): return false
    var loaded := SaveService.new().load_from_path(PATH)
    if not _check(loaded != null,"LEGACY_ACTIVE_LOAD","legacy save was not migrated"): return false
    for actor in actors:
        var current: DiscipleState = loaded.disciples[(actor as DiscipleState).id]
        if not _check(current.active_pve_encounter_id == "gp2c-legacy-inflight","LEGACY_ACTIVE_OWNER","missing restored reservation"): return false
    if not _check(not bool(workforce.issue_command(loaded,(actors[0] as DiscipleState).id,WorkforceSystem.COMMAND_HOLD,"",100)) and
        not bool(DiscipleTrainingActionV2.request_training(loaded,(actors[0] as DiscipleState).id,"body").get("ok",false)) and
        (loaded.disciples[(actors[0] as DiscipleState).id] as DiscipleState).hp == hp_before,"LEGACY_ACTIVE_GUARD","legacy active participant worked or changed HP"): return false
    var resumed := HuntingPveRunV2.resume_active(loaded,"gp2c-legacy-inflight")
    if not _check(bool(resumed.get("ok",false)),"LEGACY_ACTIVE_RESUME","cannot resume genuine combat snapshot"): return false
    var live: HuntingPveRunV2 = resumed["session"]
    if not _check(bool(live.finish().get("ok",false)) and loaded.sect.v2_pve_settlement_receipts.has("gp2c-legacy-inflight") and loaded.tick == old_tick,"LEGACY_ACTIVE_FINISH","cannot settle restored legacy battle"): return false
    _cleanup()
    return true

func _legacy_terminal_and_fail_closed() -> bool:
    var fx := _seed(1)
    if not _check(not fx.is_empty(),"LEGACY_TERM_SETUP","missing V2 disciple"): return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actors"][0]
    var s := _begin(fx,"gp2c-legacy-defeat")
    if not _check(s != null,"LEGACY_TERM_BEGIN","missing battle"): return false
    s.battle.actors[str(actor.id)]["hp"] = 0.0
    s.battle.active = false
    s.battle.outcome = "defeat"
    state.sect.v2_pve_active_runs["gp2c-legacy-defeat"] = s.save_state()
    actor.active_pve_encounter_id = ""
    state.runtime_last_wall_unix = 1500000
    if not _check(SaveService.new().save_to_path(state,PATH) == OK,"LEGACY_TERM_SAVE","cannot save pre-Injury terminal snapshot"): return false
    var loaded := SaveService.new().load_from_path(PATH)
    if not _check(loaded != null,"LEGACY_TERM_LOAD","terminal migration failed"): return false
    var injured: DiscipleState = loaded.disciples[actor.id]
    if not _check(injured.injury_level == 1 and injured.hp == 1.0 and injured.injury_recover_at_tick == loaded.tick + 120 and
        injured.active_pve_encounter_id.is_empty() and loaded.sect.v2_pve_settlement_receipts.has("gp2c-legacy-defeat") and
        not loaded.sect.v2_pve_active_runs.has("gp2c-legacy-defeat"),"LEGACY_TERM_SETTLE","legacy defeat incorrectly settled or retained run"): return false
    var owner := SimulationRuntimeOwnerV2.new()
    var caught := owner.load_from_path(PATH,1500000 + 119*60)
    if not _check(bool(caught.get("ok",false)) and (owner.state.disciples[actor.id] as DiscipleState).injury_level == 1,"LEGACY_TERM_119","legacy Injury healed before 120 ticks"): return false
    if not _check(bool(owner.update_to(1500000+120*60).get("ok",false)) and (owner.state.disciples[actor.id] as DiscipleState).injury_level == 0,"LEGACY_TERM_120","legacy Injury did not expire on exact tick"): return false
    _cleanup()

    var contested := _seed(1)
    if not _check(not contested.is_empty(),"LEGACY_CONFLICT_SETUP","missing V2 actor"): return false
    var badstate: SimulationState = contested["state"]
    var bad: DiscipleState = contested["actors"][0]
    var old := _begin(contested,"gp2c-legacy-contested")
    if not _check(old != null,"LEGACY_CONFLICT_BEGIN","missing active snapshot"): return false
    bad.active_pve_encounter_id = ""
    bad.work_cycle_state = {"profession":"mining","profession_id":"mining","phase":"haul_back","carried_units":3}
    var old_receipts := badstate.sect.v2_pve_settlement_receipts.size()
    var parsed := SimulationState.from_dict(badstate.to_dict())
    if not _check(parsed == null and badstate.sect.v2_pve_settlement_receipts.size() == old_receipts and bad.active_pve_encounter_id.is_empty(),"LEGACY_FAIL_CLOSED","conflicting old occupation created partial receipt/reservation"): return false
    return true


# Completed, unclaimed legacy win: authentic P3.7 party/battle and genuine
# earned map reward, not a simulated win reward fixture.
func _legacy_completed_win_claim() -> bool:
    var state := P37Factory.create_state(12311)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var party: Array = []
    for i in range(mini(6,ids.size())):
        party.append({"disciple_id":str(ids[i]),"party_id":"legacy_crew",
            "role":"healer" if i == 3 else ("mage" if i == 2 else "frontline"),
            "position":Vector2(8.0+float(i)*0.3,8.0+float(i%2)*0.45),
            "realm":2,"floor":1,"body_realm":2,"body_floor":1})
    if not _check(bool(HuntingMapV2.choose_level(state,"bach_thach_khe",1).get("ok",false)),"LEGACY_WIN_MAP","map selection unavailable"): return false
    var session := HuntingPveRunV2.new()
    if not _check(bool(session.begin(state,"bach_thach_khe","gp02c-legacy-unclaimed",12771,party).get("ok",false)),"LEGACY_WIN_BEGIN","unable to start authentic PvE party"): return false
    session.battle.run(400,false)
    if not _check(not session.battle.active and session.battle.outcome == "win","LEGACY_WIN_REAL","genuine map battle did not win"): return false
    state.sect.v2_pve_active_runs["gp02c-legacy-unclaimed"] = session.save_state()
    for member in party:
        (state.disciples[StringName(member["disciple_id"])] as DiscipleState).active_pve_encounter_id = ""
    if not _check(SaveService.new().save_to_path(state,PATH) == OK,"LEGACY_WIN_SAVE","old terminal winning battle save refused"): return false
    var loaded := SaveService.new().load_from_path(PATH)
    if not _check(loaded != null and loaded.sect.v2_pve_settlement_receipts.has("gp02c-legacy-unclaimed")
        and loaded.sect.v2_pve_active_runs.has("gp02c-legacy-unclaimed"),"LEGACY_WIN_RECEIPT","old terminal win lost claimable checkpoint"): return false
    var restored := HuntingPveRunV2.resume_active(loaded,"gp02c-legacy-unclaimed")
    if not _check(bool(restored.get("ok",false)),"LEGACY_WIN_RESUME","settled old win cannot resume for reward"): return false
    var claimant: HuntingPveRunV2 = restored["session"]
    if not _check(bool(claimant.claim().get("ok",false)) and
        not bool(claimant.claim().get("ok",false)) and
        loaded.sect.v2_pve_reward_claims.has("gp02c-legacy-unclaimed") and
        not loaded.sect.v2_pve_active_runs.has("gp02c-legacy-unclaimed"),"LEGACY_WIN_EXACTLY_ONCE","old win reward/cleanup was replayed"): return false
    _cleanup()
    return true

func _timed_occupation_guards() -> bool:
    var fx := _seed(1)
    if not _check(not fx.is_empty(),"T15_SETUP","cannot recruit V2 field worker"): return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actors"][0]
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if not _check(field != null and hall != null,"T15_BUILD","real timed buildings missing"): return false
    for worker_id in buildings.assigned_worker_ids(state,field):
        workforce.assign_group(state,worker_id,&"")
    for worker_id in buildings.assigned_worker_ids(state,hall):
        workforce.assign_group(state,worker_id,&"")
    if not _check(workforce.assign_group(state,actor.id,field.worker_group_id)
        and workforce.assign_worksite(state,actor.id,field.id)
        and workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_HOLD,"",10000),"T15_ASSIGN","cannot assign real plot worker"): return false
    var ready := false
    for i in range(5):
        var plot := workforce.perform_work(state,actor,WorkforceSystem.PROF_HERBALISM)
        if not _check(bool(plot.get("ok",false)) and buildings.disciple_has_active_spirit_plot(state,actor.id),"T15_PLANT","real paid plot unavailable"): return false
        var stones := state.sect.spirit_stones
        if not _check(_begin(fx,"gp2c-field-blocked-%d" % i) == null and state.sect.spirit_stones == stones
            and buildings.disciple_has_active_spirit_plot(state,actor.id),"T15","PvE interrupted paid Spirit Field"): return false
        var finish := -1
        for row in buildings.spirit_field_plots(state,field):
            if str(row.get("assigned_worker_id","")) == str(actor.id):
                finish = int(row.get("finish_tick",-1))
        if not _check(finish >= state.tick,"T15_TIMER","plot finish tick unavailable"): return false
        var sched := SimulationScheduler.new(state)
        while state.tick <= finish:
            sched.step()
        if warehouse.quantity(state,&"thanh_linh_thao") >= 3:
            ready = true
            break
    if not _check(ready,"T15_HERBS","real field did not grow paid Alchemy input"): return false
    if not _check(workforce.assign_group(state,actor.id,hall.worker_group_id)
        and workforce.assign_worksite(state,actor.id,hall.id),"T15_HALL","cannot assign the actual Alchemy worker"): return false
    var began := workforce.perform_work(state,actor,WorkforceSystem.PROF_ALCHEMY)
    if not _check(bool(began.get("ok",false)) and buildings.disciple_has_active_timed_recipe(state,actor.id),"T15_RECIPE","earned herbs did not start timed recipe"): return false
    var job := buildings.active_alchemy_job_for_worker(state,actor.id)
    var pills := warehouse.quantity(state,NeedsSystem.HEALING_PILL_ID)
    if not _check(_begin(fx,"gp2c-alchemy-blocked") == null
        and buildings.active_alchemy_job_for_worker(state,actor.id) == job
        and warehouse.quantity(state,NeedsSystem.HEALING_PILL_ID) == pills,"T15_ALCHEMY","PvE interfered with active Alchemy job"): return false
    return true

func _work_guard_and_recovery() -> bool:
    var fx := _seed(1)
    if not _check(not fx.is_empty(),"WORK_SETUP","V2 worker unavailable"): return false
    var state: SimulationState = fx["state"]
    var actor: DiscipleState = fx["actors"][0]
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    for id in buildings.assigned_worker_ids(state,mine):
        workforce.assign_group(state,id,&"")
    if not _check(workforce.assign_group(state,actor.id,mine.worker_group_id) and workforce.assign_worksite(state,actor.id,mine.id),"MINE_ASSIGN","could not reserve canonical Mine"): return false
    var working := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    if not _check(bool(working.get("ok",false)) and not actor.work_cycle_state.is_empty(),"WORK_START","real carry-cycle unavailable"): return false
    var blocked := _begin(fx,"gp2c-busy-mine")
    if not _check(blocked == null and not actor.work_cycle_state.is_empty(),"T14","PvE interrupted real Mine carry-cycle"): return false
    actor.work_cycle_state.clear() # Test isolation only: no output or XP granted.
    workforce.assign_group(state,actor.id,&"")
    actor.worksite_building_id = &""
    if not _check(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false)),"BODY_RESERVE","paid Body facility missing"): return false
    var body_blocked := _begin(fx,"gp2c-busy-body")
    if not _check(body_blocked == null and DiscipleBodyTrainingFacilityV2.has_reserved_slot(state,actor),"T16","PvE stole Body slot"): return false
    if not _check(bool(DiscipleBodyTrainingFacilityV2.release_slot(state,actor.id).get("ok",false)),"BODY_RELEASE","could not release occupied facility"): return false
    actor.current_action = &"EVALUATE"
    var s := _begin(fx,"gp2c-occupation")
    if not _check(s != null,"WORK_PVE_BEGIN","session unavailable after legal release"): return false
    var stock := state.sect.spirit_stones
    var xp := float(actor.v2_realm_progress["body"]["xp"])
    var refused_work := workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING)
    var refused_body := DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id)
    var refused_train := DiscipleTrainingActionV2.request_training(state,actor.id,"cultivation")
    var refused_command := workforce.issue_command(state,actor.id,WorkforceSystem.COMMAND_WORK,"mining",10)
    if not _check(not bool(refused_work.get("ok",false)) and not bool(refused_body.get("ok",false)) and not bool(refused_train.get("ok",false)) and not refused_command and stock == state.sect.spirit_stones and xp == float(actor.v2_realm_progress["body"]["xp"]),"T17","active PvE stole job/training resources"): return false
    var out := _fixture_terminal(s,"defeat",[str(actor.id)])
    if not _check(bool(out.get("ok",false)) and actor.injury_level == 1,"WORK_DEFEAT","injury missing"): return false
    actor.hp = actor.max_hp # Ordinary HP restored; Injury independently remains.
    if not _check(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(state,actor.id).get("ok",false)) and bool(DiscipleTrainingActionV2.request_training(state,actor.id,"body").get("ok",false)),"T18","Injury illegally blocked legitimate Body training"): return false
    DiscipleBodyTrainingFacilityV2.release_slot(state,actor.id)
    actor.current_action = &"EVALUATE"
    if not _check(workforce.assign_group(state,actor.id,mine.worker_group_id)
        and workforce.assign_worksite(state,actor.id,mine.id)
        and bool(workforce.perform_work(state,actor,WorkforceSystem.PROF_MINING).get("ok",false)),"T18_WORK","Injury forbade legitimate production shift"): return false
    actor.current_action = &"HOLD"
    state.sect.workforce_enabled = false
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(119)
    if not _check(actor.injury_level == 1 and actor.injury_recover_at_tick == 120,"T19","Injury healed before 120 ticks"): return false
    scheduler.step()
    if not _check(actor.injury_level == 0 and actor.injury_recover_at_tick == 0,"T20","Injury did not expire at exact tick"): return false

    var other := _seed(1)
    if not _check(not other.is_empty(),"OFFLINE_SETUP","seed unavailable"): return false
    var offline_state: SimulationState = other["state"]
    var offline_actor: DiscipleState = other["actors"][0]
    var os := _begin(other,"gp2c-offline")
    if not _check(os != null and bool(_fixture_terminal(os,"defeat",[str(offline_actor.id)]).get("ok",false)),"OFFLINE_DEFEAT","defeat setup failed"): return false
    offline_actor.current_action = &"HOLD"
    offline_state.sect.workforce_enabled = false
    var owner := SimulationRuntimeOwnerV2.new()
    if not _check(bool(owner.attach(offline_state,2000000).get("ok",false)) and bool(owner.save_to_path(PATH,2000000).get("ok",false)),"OFFLINE_SAVE","cannot write offline save"): return false
    var returned := SimulationRuntimeOwnerV2.new()
    var loaded := returned.load_from_path(PATH,2000000+120*60)
    if not _check(bool(loaded.get("ok",false)) and int(loaded.get("catch_up_steps",-1)) == 120 and (returned.state.disciples[offline_actor.id] as DiscipleState).injury_level == 0,"T21","offline 120 ticks disagree with online"): return false
    if not _check(bool(returned.save_to_path(PATH,2000000+120*60).get("ok",false)) and int(returned.update_to(2000000+120*60).get("steps_run",-1)) == 0,"OFFLINE_REPEAT","same-time reload replayed elapsed minutes"): return false
    _cleanup()
    return true

func _real_pve_and_claim() -> bool:
    # Genuine P3.7 team, actual monster spawn and deterministic MapBattleV2;
    # no fabricated victory, actor damage, item or EXP fixtures.
    var state := P37Factory.create_state(12311)
    var original_ids: Array = state.disciples.keys()
    original_ids.sort()
    var party: Array = []
    for i in range(mini(6,original_ids.size())):
        party.append({"disciple_id":str(original_ids[i]),"party_id":"real_crew",
            "role":"healer" if i == 3 else ("mage" if i == 2 else "frontline"),
            "position":Vector2(8.0+float(i)*0.3,8.0+float(i%2)*0.45),
            "realm":2,"floor":1,"body_realm":2,"body_floor":1})
    if not _check(bool(HuntingMapV2.choose_level(state,"bach_thach_khe",1).get("ok",false)),"REAL_MAP","real five-level selection failed"): return false
    var session := HuntingPveRunV2.new()
    if not _check(bool(session.begin(state,"bach_thach_khe","gp02c-real-win",12771,party).get("ok",false)),"REAL_BEGIN","real owned party rejected"): return false
    for i in range(5):
        if session.battle.active:
            session.advance()
    var copy := HuntingPveRunV2.resume_active(state,"gp02c-real-win")
    if not _check(bool(copy.get("ok",false)),"T12","mid-battle snapshot cannot resume"): return false
    var resumed: HuntingPveRunV2 = copy["session"]
    var actual := session.finish()
    var again := resumed.finish()
    if not _check(bool(actual.get("ok",false)) and bool(again.get("ok",false)) and actual["summary"] == again["summary"],"T12B","reloaded real encounter diverged: first_ok=%s, resumed_ok=%s, resumed_reason=%s, outcome_A=%s, outcome_B=%s, actions_A=%s, actions_B=%s, receipt=%s" % [str(actual.get("ok")),str(again.get("ok")),str(again.get("reason","")),str(actual.get("summary",{}).get("outcome","")),str(again.get("summary",{}).get("outcome","")),str(actual.get("summary",{}).get("actions",-1)),str(again.get("summary",{}).get("actions",-1)),str(state.sect.v2_pve_settlement_receipts.get("gp02c-real-win",{})).left(600)]): return false
    if not _check(str(actual["summary"]["outcome"]) == "win","REAL_WIN","expected source-proven fair baseline win"): return false
    var preclaim := state.sect.v2_pve_active_runs.has("gp02c-real-win") and state.sect.v2_pve_settlement_receipts.has("gp02c-real-win")
    if not _check(preclaim and SaveService.new().save_to_path(state,PATH) == OK,"T08","terminal winning claim was lost before save"): return false
    var reload := SaveService.new().load_from_path(PATH)
    if not _check(reload != null,"REAL_RELOAD","canonical disk save failed"): return false
    var restored := HuntingPveRunV2.resume_active(reload,"gp02c-real-win")
    if not _check(bool(restored.get("ok",false)),"WIN_RESUME","claimable completed win cannot resume"): return false
    var claiming: HuntingPveRunV2 = restored["session"]
    var before := warehouse.quantity(reload,&"thanh_thiet")
    var claimed := claiming.claim()
    if not _check(bool(claimed.get("ok",false)) and reload.sect.v2_pve_reward_claims.has("gp02c-real-win") and warehouse.quantity(reload,&"thanh_thiet") >= before,"T08B","real earned claim failed"): return false
    # A replay must share the SAME canonical loaded state. Two independently
    # forked save universes do not provide cross-device/server transactions.
    var replay := HuntingPveRunV2.restore_state(
        reload,state.sect.v2_pve_active_runs["gp02c-real-win"])
    var stale_claim_ok := false
    if bool(replay.get("ok",false)):
        var stale: HuntingPveRunV2 = replay["session"]
        stale_claim_ok = bool(stale.claim().get("ok",false))
    if not _check(not bool(claiming.claim().get("ok",false)) and not stale_claim_ok,"T10","duplicate claim succeeded within one canonical save"): return false
    if not _check(not reload.sect.v2_pve_active_runs.has("gp02c-real-win") and not bool(HuntingPveRunV2.resume_active(reload,"gp02c-real-win").get("ok",false)),"T11","claimed terminal reopened active state"): return false
    return true
