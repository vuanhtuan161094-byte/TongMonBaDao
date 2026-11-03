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
    if cli.size() >= 3 and str(cli[0]) == "reload":
        path = str(cli[1])
        _reload_child(str(cli[2]))
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
    var profile := DiscipleRealmProgressV2.current(disciple)
    var cult: Dictionary = profile["cultivation"]
    var body: Dictionary = profile["body"]
    var member := {
        "disciple_id":str(picked),"role":"frontline","party_id":"solo:"+str(picked),
        "position":options["party_spawn_points"][0],
        "realm":int(cult["realm"]),"floor":int(cult["floor"]),
        "body_realm":int(body["realm"]),"body_floor":int(body["floor"])
    }
    var session := HuntingPveRunV2.new()
    var opened := session.begin_multicamp(runtime.owner,
        "p0_natural_one_hunter",SEED,[member],10,options)
    if not _ok(bool(opened.get("ok",false))
            and int(opened.get("party_size",0)) == 1
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
        "--","reload",path,str(picked)
    ])
    var exit_code := OS.execute(OS.get_executable_path(),params,output,true)
    print("PVE_P0_NATURAL_PROCESS2_BEGIN")
    for item in output:
        print(str(item))
    print("PVE_P0_NATURAL_PROCESS2_END")
    if not _ok(exit_code == 0 and "".join(PackedStringArray(output)).contains(
            "PVE_P0_NATURAL_SAVE_RELOAD_PASS"),
            "second actual Godot process failed cold receipts/EXP reload, exit="+str(exit_code)):
        return
    _clean()
    print("PVE_P0_NATURAL_SOLO_PASS checks=%d" % checks)
    quit(0)

func _reload_child(disciple_id: String) -> void:
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
    var rewards: Dictionary = session.camp_population.get("p0_kill_rewards",{})
    if not _ok(rewards.size() == 10
            and int(session.camp_population.get("world_total_kills",0)) == 10
            and float(xp["cultivation"]["xp"]) > 0.0
            and float(xp["body"]["xp"]) > 0.0
            and session.battle._count_alive("disciple") == 1
            and session.battle._count_alive("monster") == 0
            and PveDistributedWorldV1.enabled(session.camp_population),
            "cold reload lost active solo hunt, XP or exactly ten receipts"):
        return
    print("PVE_P0_NATURAL_SAVE_RELOAD_PASS "+JSON.stringify({
        "kills":10,"reward_receipts":rewards.size(),
        "cultivation_xp":xp["cultivation"]["xp"],"body_xp":xp["body"]["xp"],
        "active_hunters":1,"live_monsters_waiting_respawn":0
    }))
    quit(0)
