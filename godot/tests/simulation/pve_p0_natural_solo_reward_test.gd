extends SceneTree

# PVE-P0: genuine fresh LiveGameRuntime/P37Factory, one authentic B1 V2
# recruit, actual Source A solo PvE actor, canonical HP0 domain kill events,
# per-kill warehouse/XP receipts, unattended clock and cold Save/Reload.
# Combat kills are triggered by the engine's test damage API; this is NOT
# proof that a natural solo hunter survives ten monsters organically.

const SAVE_PREFIX := "user://qa_pve_p0_natural_solo_"
const NOW := 1801000000
const SEED := 31012026
var checks := 0
var path := ""

func _init() -> void:
    call_deferred("_run")

func _ok(condition: bool,detail: String) -> bool:
    checks += 1
    if condition:
        return true
    push_error("PVE_P0_NATURAL_SOLO_RED "+detail)
    quit(1)
    return false

func _clean() -> void:
    if not path.begins_with(SAVE_PREFIX):
        return
    for suffix in ["",".tmp",".bak"]:
        var absolute := ProjectSettings.globalize_path(path+suffix)
        if FileAccess.file_exists(path+suffix):
            DirAccess.remove_absolute(absolute)

func _world() -> Dictionary:
    var nav := SectIsometricWorldV1.pve_navigation_grid()
    if nav.is_empty():
        return {}
    var options := PveOpenWorldTopologyV1.build(
        nav,Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL)+Vector2(0.5,0.5))
    if bool(options.get("ok",false)):
        options["p0_distributed_world"] = true
        options["respawn_delay_sim_seconds"] = 30.0
    return options

func _run() -> void:
    var cli := OS.get_cmdline_user_args()
    if cli.size() >= 4 and str(cli[0]) == "reload":
        path = str(cli[1])
        _reload_child(str(cli[2]),str(cli[3]))
        return
    path = SAVE_PREFIX+str(OS.get_process_id())+".json"
    _clean()
    var runtime := LiveGameRuntimeV2.new()
    var begun := runtime.start(path,NOW,SEED)
    if not _ok(bool(begun.get("ok",false)) and bool(begun.get("created",false)),
            "fresh New Game did not initialize canonical SaveService"):
        return
    var state: SimulationState = runtime.state()
    if not _ok(state.disciples.size() == 6 and state.sect.disciple_v2_birth_enabled,
            "New Game must begin with 6 legacy founders, V2 births enabled"):
        return
    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    var picked := StringName(str(candidates[0])) if not candidates.is_empty() else &""
    if not _ok(picked != &"" and
            DiscipleBirthProfileV2.valid_complete_birth(
                state.recruitment_candidates[picked].v2_birth_profile),
            "no authentic P37Factory V2 candidate"):
        return
    var accepted := RecruitmentSystem.new().accept_candidate(state,picked)
    if not _ok(bool(accepted.get("ok",false)) and state.disciples.size() == 7,
            "real V2 recruit at starter house capacity was blocked: "+str(accepted)):
        return
    var disciple: DiscipleState = state.disciples[picked]
    if not _ok(DiscipleRealmProgressV2.progression_ready(disciple),
            "accepted candidate missing genuine cultivation and body profiles"):
        return
    var options := _world()
    if not _ok(bool(options.get("ok",false)) and options.get("camp_positions",[]).size() == 20,
            "actual Source A world with 20 zones missing"):
        return
    var solo_formed := PveP0CommandsV1.build_members(state,[str(picked)])
    var duplicate_refused := PveP0CommandsV1.build_members(
        state,[str(picked),str(picked)])
    if not _ok(bool(solo_formed.get("ok",false))
            and (solo_formed.get("members",[]) as Array).size() == 1
            and str(solo_formed["members"][0]["party_id"]) == "solo:"+str(picked)
            and not bool(duplicate_refused.get("ok",true)),
            "canonical solo entry rejected or allowed duplicate disciples"):
        return
    var opened := PveP0CommandsV1.deploy(runtime.owner,
        "p0_natural_one_hunter",SEED,[str(picked)],options)
    var session := runtime.owner.get_active_multicamp_session()
    if not _ok(bool(opened.get("ok",false))
            and int(opened.get("party_size",0)) == 1
            and session != null
            and session.battle._count_alive("monster") == 10
            and PveDistributedWorldV1.enabled(session.camp_population),
            "one authentic V2 hunter cannot enter real distributed Source A world: "+str(opened)):
        return
    var before_xp: Dictionary = DiscipleRealmProgressV2.current(disciple)
    var before_warehouse: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var monster_ids: Array[String] = []
    for raw_id in session.battle.actors.keys():
        if str(session.battle.actors[raw_id].get("side","")) == "monster":
            monster_ids.append(str(raw_id))
    monster_ids.sort()
    var first_receipt: Dictionary = {}
    var first_event: Dictionary = {}
    for index in range(monster_ids.size()):
        var target := monster_ids[index]
        var damage := session.battle.apply_continuous_damage_tick(
            str(picked),target,"p0_real_hp0_%02d" % index,2000.0)
        if not _ok(bool(damage.get("ok",false))
                and float(session.battle.actors[target].get("hp",1.0)) == 0.0,
                "canonical combat damage did not kill genuine catalogue monster "+target):
            return
        var pending := session.battle.pending_kill_events()
        if not _ok(pending.size() == 1,
                "combat kernel emitted zero or duplicate real domain kill event"):
            return
        if index == 0:
            first_event = pending[0].duplicate(true)
        var settlement := session._record_open_world_kills()
        if not _ok(bool(settlement.get("ok",false)) and int(settlement.get("recorded",0)) == 1
                and session.battle.pending_kill_events().is_empty(),
                "per-kill reward / XP settlement failed: "+str(settlement)):
            return
        if index == 0:
            first_receipt = (session.camp_population["p0_kill_rewards"] as Dictionary).get(
                str(first_event["spawn_slot_id"]),{}).duplicate(true)
    var after_xp := DiscipleRealmProgressV2.current(disciple)
    var initial_cult := float(before_xp["cultivation"]["xp"])
    var initial_body := float(before_xp["body"]["xp"])
    if not _ok(session.camp_population["p0_kill_rewards"].size() == 10
            and int(session.camp_population.get("world_total_kills",0)) == 10
            and float(after_xp["cultivation"]["xp"]) > initial_cult
            and float(after_xp["body"]["xp"]) > initial_body,
            "ten unique real HP0 kills must produce exactly ten receipts and canonical XP"):
        return
    var after_warehouse: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var replay := PvePerKillRewardV1.commit(state,session.battle,
        session.camp_population,first_event,SEED)
    var replay_xp := DiscipleRealmProgressV2.current(disciple)
    if not _ok(bool(replay.get("ok",false)) and bool(replay.get("duplicate",false))
            and state.sect.warehouse_resources == after_warehouse
            and replay_xp["cultivation"] == after_xp["cultivation"]
            and replay_xp["body"] == after_xp["body"]
            and first_receipt == session.camp_population["p0_kill_rewards"][str(first_event["spawn_slot_id"])],
            "same kill_id replay granted resources or XP twice"):
        return
    var any_drop := after_warehouse != before_warehouse
    print("PVE_P0_REAL_KILLS_XP_PASS "+JSON.stringify({
        "kills":10,"receipts":10,"cultivation_xp":after_xp["cultivation"]["xp"],
        "body_xp":after_xp["body"]["xp"],"materials_dropped":any_drop,
        "distinct_life_replays_do_not_duplicate":true
    }))
    # Real command facade, not a renderer-side actor mutation: movement
    # and HOLD update the canonical cached battle and durable envelope.
    var move_cmd := PveP0CommandsV1.move(
        runtime.owner,[str(picked)],options["camp_positions"][19])
    if not _ok(bool(move_cmd.get("ok",false))
            and bool(move_cmd.get("save_required",false))
            and bool(session.battle.actors[str(picked)].get("move_order_active",false)),
            "canonical P0 command could not order solo to far Source A zone: "+str(move_cmd)):
        return
    var hold_cmd := PveP0CommandsV1.hunt_policy(
        runtime.owner,[str(picked)],"hold")
    if not _ok(bool(hold_cmd.get("ok",false))
            and bool(hold_cmd.get("save_required",false))
            and not bool(session.battle.actors[str(picked)].get("move_order_active",false))
            and str(session.battle.actors[str(picked)].get("hunt_policy","")) == "hold",
            "canonical solo HOLD did not cancel pursuit/previous move safely"):
        return
    var invalid_command := PveP0CommandsV1.move(
        runtime.owner,[str(picked),"unknown_hunter"],options["camp_positions"][19])
    if not _ok(not bool(invalid_command.get("ok",true))
            and str(session.battle.actors[str(picked)].get("hunt_policy","")) == "hold",
            "mixed valid/invalid command partially changed the real solo hunter"):
        return
    # A SECOND real candidate (not an invented test actor) joins and
    # returns while the first hunter's world, loot journal and HP persist.
    # The starter Residence has precisely eight beds: founder6 + V2x2.
    var candidates_after: Array = state.recruitment_candidates.keys()
    candidates_after.sort()
    if not _ok(not candidates_after.is_empty(),
            "New Game must retain another genuine recruitable V2 candidate"):
        return
    var second_id := StringName(str(candidates_after[0]))
    var second_accept := RecruitmentSystem.new().accept_candidate(state,second_id)
    if not _ok(bool(second_accept.get("ok",false))
            and state.disciples.size() == 8
            and DiscipleRealmProgressV2.progression_ready(state.disciples[second_id]),
            "second real V2 admission blocked within eight legitimate beds"):
        return
    var join := PveP0CommandsV1.join_one(
        runtime.owner,str(second_id))
    if not _ok(bool(join.get("ok",false))
            and bool(join.get("save_required",false))
            and str(join.get("party_id","")) == "solo:"+str(second_id)
            and session.battle._count_alive("disciple") == 2
            and session.battle.actors.has(str(second_id))
            and state.disciples[second_id].active_pve_encounter_id == "p0_natural_one_hunter",
            "real second V2 cannot join ongoing solo Source A hunt: "+str(join)):
        return
    var twice := PveP0CommandsV1.join_one(
        runtime.owner,str(second_id))
    if not _ok(not bool(twice.get("ok",true))
            and session.battle._count_alive("disciple") == 2,
            "same person joined twice and bypassed actor cap"):
        return
    var returned := PveP0CommandsV1.return_one(
        runtime.owner,str(second_id))
    if not _ok(bool(returned.get("ok",false))
            and bool(returned.get("save_required",false))
            and session.battle._count_alive("disciple") == 1
            and session.battle.active
            and session.battle.actors.has(str(picked))
            and not session.battle.actors.has(str(second_id))
            and state.disciples[second_id].active_pve_encounter_id.is_empty()
            and state.disciples[second_id].region_id == &"sect"
            and state.disciples[second_id].injury_level == 0
            and session.camp_population["p0_kill_rewards"].size() == 10
            and state.sect.warehouse_resources == after_warehouse,
            "returning one hunter ended the whole world or duplicated reward: "+str(returned)):
        return
    var redundant_return := PveP0CommandsV1.return_one(
        runtime.owner,str(second_id))
    var last_refused := PveP0CommandsV1.return_one(
        runtime.owner,str(picked))
    if not _ok(not bool(redundant_return.get("ok",true))
            and not bool(last_refused.get("ok",true))
            and str(last_refused.get("reason","")) == "p0_last_hunter_use_return_to_sect"
            and session.battle._count_alive("disciple") == 1,
            "last-hunter return or duplicate return bypassed terminal retreat"):
        return
    print("PVE_P0_NATURAL_JOIN_RETURN_PASS "+JSON.stringify({
        "genuine_recruits":2,"world_still_active":true,
        "remaining_hunters":1,"receipts_unchanged":10,
        "no_duplicate_join_or_return":true,"last_hunter_retreat_required":true
    }))
    var stored := session._persist_live_state()
    if not _ok(bool(stored.get("ok",false)),"active full world checkpoint failed"):
        return
    # No PvE map/view node is created: true offscreen runtime clock budget,
    # with 10 corpses waiting on their 30-sec per-slot respawn timers.
    var advanced := runtime.poll(NOW+1)
    if not _ok(bool(advanced.get("ok",false))
            and int(advanced.get("frames_run",0)) > 0,
            "world simulation stopped without a viewed map: "+str(advanced)):
        return
    var saved := runtime.save(NOW+1)
    if not _ok(bool(saved.get("ok",false)) and FileAccess.file_exists(path),
            "canonical SaveService could not persist offscreen kill receipts"):
        return
    var output: Array = []
    var params := PackedStringArray([
        "--headless","--path",ProjectSettings.globalize_path("res://"),
        "-s","res://tests/simulation/pve_p0_natural_solo_reward_test.gd",
        "--","reload",path,str(picked),str(second_id)
    ])
    var exit_code := OS.execute(OS.get_executable_path(),params,output,true)
    print("PVE_P0_NATURAL_PROCESS2_BEGIN")
    for item in output:
        print(str(item))
    print("PVE_P0_NATURAL_PROCESS2_END")
    if not _ok(exit_code == 0 and "".join(PackedStringArray(output)).contains(
            "PVE_P0_NATURAL_SAVE_RELOAD_PASS")
            and "".join(PackedStringArray(output)).contains("PVE_P0_RESPAWN_GEN2_PASS"),
            "second Godot process failed first cold reload or generation-2 kill, exit="+str(exit_code)):
        return
    # The child wrote the generation-2 receipt to the same QA-only path.
    # Read it in a separate LiveGameRuntime, not the parent's cached owner.
    var fresh_runtime := LiveGameRuntimeV2.new()
    var fresh_open := fresh_runtime.start(path,NOW+1)
    if not _ok(bool(fresh_open.get("ok",false)) and bool(fresh_open.get("loaded",false)),
            "generation-2 cold SaveService replay rejected: "+str(fresh_open)):
        return
    var reloaded := HuntingPveRunV2.resume_active(
        fresh_runtime.state(),"p0_natural_one_hunter")
    if not _ok(bool(reloaded.get("ok",false)),
            "generation-2 cold battle restore rejected: "+str(reloaded)):
        return
    var second_world: HuntingPveRunV2 = reloaded["session"]
    var first_slot := str(first_event["spawn_slot_id"])
    var second_receipt: Dictionary = second_world.camp_population["p0_kill_rewards"].get(
        first_slot,{})
    if not _ok(int(second_receipt.get("generation",0)) == 2
            and str(second_receipt.get("kill_id","")) == "p0_natural_one_hunter:slot:"+first_slot+":g2"
            and int(second_world.camp_population.get("world_total_kills",0)) == 11
            and second_world.camp_population["p0_kill_rewards"].size() == 10
            and second_world.battle.pending_kill_events().is_empty()
            and second_world.battle.active,
            "cold reload lost second-generation exactly-once receipt or running world"):
        return
    print("PVE_P0_RESPAWN_COLD_RELOAD_PASS "+JSON.stringify({
        "generation":2,"total_paid_kills":11,"bounded_receipts":10,
        "pending_journal":0,"world_active":true
    }))
    _clean()
    print("PVE_P0_NATURAL_SOLO_PASS checks=%d" % checks)
    quit(0)

func _reload_child(disciple_id: String, returned_id: String) -> void:
    if not _ok(path.begins_with(SAVE_PREFIX) and FileAccess.file_exists(path),
            "unsafe or missing QA-only save path"):
        return
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(path,NOW+1)
    if not _ok(bool(opened.get("ok",false)) and bool(opened.get("loaded",false)),
            "second process cannot open genuine SaveService state: "+str(opened)):
        return
    var state: SimulationState = runtime.state()
    var member: DiscipleState = state.disciples.get(StringName(disciple_id),null)
    var saved_run := HuntingPveRunV2.resume_active(state,"p0_natural_one_hunter")
    if not _ok(member != null and DiscipleRealmProgressV2.progression_ready(member)
            and bool(saved_run.get("ok",false)),
            "second process lost original solo V2 disciple or source world"):
        return
    var session: HuntingPveRunV2 = saved_run["session"]
    var xp := DiscipleRealmProgressV2.current(member)
    var returned: DiscipleState = state.disciples.get(StringName(returned_id),null)
    var rewards: Dictionary = session.camp_population.get("p0_kill_rewards",{})
    if not _ok(returned != null
            and returned.active_pve_encounter_id.is_empty()
            and returned.region_id == &"sect"
            and DiscipleRealmProgressV2.progression_ready(returned)
            and not session.battle.actors.has(returned_id)
            and rewards.size() == 10
            and int(session.camp_population.get("world_total_kills",0)) == 10
            and float(xp["cultivation"]["xp"]) > 0.0
            and float(xp["body"]["xp"]) > 0.0
            and session.battle._count_alive("disciple") == 1
            and session.battle._count_alive("monster") == 0
            and str(session.battle.actors[disciple_id].get("hunt_policy","")) == "hold"
            and not bool(session.battle.actors[disciple_id].get("move_order_active",false))
            and PveDistributedWorldV1.enabled(session.camp_population),
            "cold reload lost active solo hunt, XP or exactly ten receipts"):
        return
    print("PVE_P0_NATURAL_SAVE_RELOAD_PASS "+JSON.stringify({
        "kills":10,"reward_receipts":rewards.size(),
        "cultivation_xp":xp["cultivation"]["xp"],"body_xp":xp["body"]["xp"],
        "active_hunters":1,"returned_recruit_at_sect":true,
        "live_monsters_waiting_respawn":0
    }))
    if not _test_second_generation(runtime,session,member,disciple_id):
        return
    quit(0)

func _test_second_generation(runtime: LiveGameRuntimeV2,
        session: HuntingPveRunV2,member: DiscipleState,
        disciple_id: String) -> bool:
    # Run the real world clock frames without creating a P3 map view.
    # All ten original monster slots were paid once and are cooling down.
    if not _ok(runtime.owner.cache_active_multicamp_session(session),
            "second-process world session was not cached on runtime owner"):
        return false
    var receipts: Dictionary = session.camp_population["p0_kill_rewards"]
    var slot_ids: Array = receipts.keys()
    slot_ids.sort()
    var slot_id := str(slot_ids[0])
    var old_receipt: Dictionary = receipts[slot_id].duplicate(true)
    var before_progress := DiscipleRealmProgressV2.current(member)
    var old_stock := runtime.state().sect.warehouse_resources.duplicate(true)
    var frames := 0
    while frames < 150:
        var step := session.advance(false)
        if not _ok(bool(step.get("ok",false)),
                "offscreen cooldown simulation stopped at frame %d: %s" % [frames,str(step)]):
            return false
        frames += 1
        if int(session.camp_population["slots"][slot_id]["generation"]) >= 2:
            break
    var slot: Dictionary = session.camp_population["slots"][slot_id]
    var new_actor_id := "p0_natural_one_hunter/"+slot_id+"/g2"
    if not _ok(int(slot.get("generation",0)) == 2
            and str(slot.get("phase","")) == "READY"
            and not slot.has("reward_receipt_id")
            and not slot.has("reward_disposition")
            and session.battle.actors.has(new_actor_id)
            and float(session.battle.actors[new_actor_id].get("hp",0.0)) > 0.0
            and str(old_receipt.get("kill_id","")) != "p0_natural_one_hunter:slot:"+slot_id+":g2",
            "same registered monster slot did not respawn as distinct generation 2"):
        return false
    # Cold-load ledger corruption must fail closed, not silently award again.
    var corrupted := session.save_state()
    var bad_registry: Dictionary = corrupted["camp_population"]
    var bad_receipt: Dictionary = bad_registry["p0_kill_rewards"][slot_id]
    bad_receipt["generation"] = 999
    var rejected := HuntingPveRunV2.restore_state(runtime.state(),corrupted)
    if not _ok(not bool(rejected.get("ok",true))
            and str(rejected.get("reason","")) == "p0_reward_receipt_identity_invalid",
            "tampered paid-life generation survived world restoration"):
        return false
    var damage := session.battle.apply_continuous_damage_tick(
        disciple_id,new_actor_id,"p0_second_life_real_hp0",2000.0)
    var pending := session.battle.pending_kill_events()
    if not _ok(bool(damage.get("ok",false)) and pending.size() == 1
            and str(pending[0].get("spawn_slot_id","")) == slot_id
            and int(pending[0].get("slot_generation",0)) == 2,
            "second-generation combat did not produce genuine HP0 journal"):
        return false
    var recorded := PveMultiCampPopulationV1.record_authoritative_battle_kill(
        session.camp_population,session.battle,pending[0],
        session.world_respawn_delay,true)
    if not _ok(bool(recorded.get("ok",false)),
            "second-generation canonical population kill was rejected"):
        return false
    var forgery: Dictionary = pending[0].duplicate(true)
    forgery["damage_kind"] = "tampered"
    var refused := PvePerKillRewardV1.commit(
        runtime.state(),session.battle,session.camp_population,forgery,
        int(session.spawn_data.get("reward_seed",0)))
    if not _ok(not bool(refused.get("ok",true))
            and str(refused.get("reason","")) == "p0_kill_not_in_authoritative_journal"
            and runtime.state().sect.warehouse_resources == old_stock
            and DiscipleRealmProgressV2.current(member) == before_progress,
            "modified HP0 event minted items or cultivation/body progress"):
        return false
    var settled := session._record_open_world_kills()
    var new_receipt: Dictionary = session.camp_population["p0_kill_rewards"].get(slot_id,{})
    var after_progress := DiscipleRealmProgressV2.current(member)
    var after_stock := runtime.state().sect.warehouse_resources.duplicate(true)
    if not _ok(bool(settled.get("ok",false))
            and int(settled.get("recorded",0)) == 1
            and int(session.camp_population.get("world_total_kills",0)) == 11
            and session.camp_population["p0_kill_rewards"].size() == 10
            and int(new_receipt.get("generation",0)) == 2
            and str(new_receipt.get("kill_id","")) != str(old_receipt.get("kill_id",""))
            and after_progress != before_progress
            and session.battle.pending_kill_events().is_empty(),
            "second real HP0 failed exact-once Tu Vi/Body or bounded reward ledger"):
        return false
    var old_fake := {
        "spawn_slot_id":slot_id,"kill_id":str(old_receipt["kill_id"]),
        "slot_generation":1
    }
    var stale := PvePerKillRewardV1.commit(
        runtime.state(),session.battle,session.camp_population,old_fake,
        int(session.spawn_data.get("reward_seed",0)))
    var current_repeat := pending[0].duplicate(true)
    var duplicate := PvePerKillRewardV1.commit(
        runtime.state(),session.battle,session.camp_population,current_repeat,
        int(session.spawn_data.get("reward_seed",0)))
    if not _ok(not bool(stale.get("ok",true))
            and bool(duplicate.get("ok",false))
            and bool(duplicate.get("duplicate",false))
            and runtime.state().sect.warehouse_resources == after_stock
            and DiscipleRealmProgressV2.current(member) == after_progress,
            "stale or replayed monster life duplicated Tu Vi, body or materials"):
        return false
    var checkpoint := session._persist_live_state()
    var saved := runtime.save(NOW+1)
    if not _ok(bool(checkpoint.get("ok",false))
            and bool(saved.get("ok",false)),
            "SaveService could not persist second-generation receipt"):
        return false
    print("PVE_P0_RESPAWN_GEN2_PASS "+JSON.stringify({
        "simulated_frames":frames,"generation":2,
        "total_paid_kills":11,"bounded_receipts":10,
        "replay_no_extra_awards":true,"cold_reload_next":true
    }))
    return true
