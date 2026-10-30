extends SceneTree

const BOSS_ID := "tmb.boss.thiet_giap_son_vien"
const PREVIEW := {"sect_codex":true,"human_skill_combat":true,"boss_encounters":true}

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D7_RUNTIME_BOSS_FAIL: " + message)
    quit(1)

func _run() -> void:
    var state := SimulationState.new()
    state.sect.v2_pve_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_skill_combat_opt_in = true
    state.sect.disciple_capacity = 6
    state.sect.v2_pve_selected_levels["thanh_truc_lam"] = 1
    state.regions[&"thanh_truc_lam"] = RegionState.new({"id":"thanh_truc_lam","name":"Thanh Trúc Lâm","danger":1})
    var party: Array = []
    for index in range(6):
        var id := "d7_boss_%02d" % index
        state.disciples[StringName(id)] = DiscipleState.new({"id":id,"name":"D7 Boss %d" % index})
        party.append({"disciple_id":id,"party_id":"d7_boss_fixture","role":"ranged" if index > 1 else "frontline",
            "position":Vector2(8.0+float(index%3)*2.0,8.0+float(int(index/3))*2.0),
            "realm":1,"floor":1,"body_realm":1,"body_floor":1})
    var run := HuntingPveRunV2.new()
    var begun := run.begin(state,"thanh_truc_lam","d7_boss_clock",887766,party,BOSS_ID,PREVIEW)
    if not bool(begun.get("ok",false)):
        _fail("existing HuntingPveRunV2 Boss begin failed: " + str(begun))
        return
    var seeded := run._persist_live_state()
    if not bool(seeded.get("ok",false)):
        _fail("Could not persist the Boss fixture before clock advance: " + str(seeded))
        return
    var scheduler := SimulationScheduler.new(state)
    scheduler.v63_preview_overrides = PREVIEW.duplicate(true)
    var initialized := SimulationRuntimeClockV2.advance_to(state,scheduler,100)
    if not bool(initialized.get("ok",false)):
        _fail("shared runtime clock did not initialize: " + str(initialized))
        return
    var advanced := SimulationRuntimeClockV2.advance_to(state,scheduler,140)
    if not bool(advanced.get("ok",false)) or int(advanced.get("frames_run",0)) < 20:
        _fail("shared clock did not tick the single Boss run: " + str(advanced))
        return
    var encounter := HuntingPveRunV2.active_single_encounter_id(state)
    var active_snapshot_has_boss := false
    var settled_boss_time := -1.0
    var settled_boss_actions := -1
    if encounter == "d7_boss_clock":
        var saved_run: Dictionary = state.sect.v2_pve_active_runs[encounter]
        var decoded_battle := MapBattleSnapshotV2.load(saved_run.get("battle",{}))
        if not bool(decoded_battle.get("ok",false)):
            _fail("shared-clock Boss snapshot could not decode: " + str(decoded_battle))
            return
        var saved_battle: MapBattleV2 = decoded_battle["battle"]
        settled_boss_time = saved_battle.now
        settled_boss_actions = saved_battle.actions
        for actor_value in saved_battle.actors.values():
            var actor: Dictionary = actor_value
            if str(actor.get("v63_boss_id","")) == BOSS_ID and bool(actor.get("v63_combat_enabled",false)):
                active_snapshot_has_boss = true
        if not active_snapshot_has_boss:
            _fail("shared-clock checkpoint lost its enabled Boss actor")
            return
    elif not state.sect.v2_pve_settlement_receipts.has("d7_boss_clock"):
        _fail("clock removed the Boss without a terminal settlement receipt")
        return
    if state.tick != 0 or not is_equal_approx(state.runtime_unconsumed_wall_seconds,40.0):
        _fail("terminal Boss time was not carried exactly into the shared clock remainder: tick=" + str(state.tick) + " remainder=" + str(state.runtime_unconsumed_wall_seconds))
        return
    if not state.sect.v2_pve_settlement_receipts.has("d7_boss_clock"):
        _fail("terminal Boss clock path did not keep its exactly-once settlement receipt")
        return
    var terminal_receipt: Dictionary = state.sect.v2_pve_settlement_receipts["d7_boss_clock"].duplicate(true)
    var continued := SimulationRuntimeClockV2.advance_to(state,scheduler,160)
    if not bool(continued.get("ok",false)) or state.tick != 1 or not is_equal_approx(state.runtime_unconsumed_wall_seconds,0.0):
        _fail("receipt-held Boss encounter did not return elapsed remainder to the shared scheduler: " + str(continued))
        return
    if state.sect.v2_pve_settlement_receipts["d7_boss_clock"] != terminal_receipt:
        _fail("completed Boss encounter changed or duplicated its terminal receipt")
        return
    if encounter == "d7_boss_clock":
        var after_run: Dictionary = state.sect.v2_pve_active_runs[encounter]
        var after_decoded := MapBattleSnapshotV2.load(after_run.get("battle",{}))
        if not bool(after_decoded.get("ok",false)) or not is_equal_approx(after_decoded["battle"].now,settled_boss_time) or after_decoded["battle"].actions != settled_boss_actions:
            _fail("settled Boss snapshot advanced after its receipt was written")
            return
    if SimulationRuntimeClockV2.pending_minutes(state) < 0:
        _fail("pending-minute phase became invalid for the single Boss run")
        return
    print("V63 D7 RUNTIME BOSS PASS: shared-clock ticks, preview forwarding, persisted Boss snapshot or terminal receipt")
    quit(0)
