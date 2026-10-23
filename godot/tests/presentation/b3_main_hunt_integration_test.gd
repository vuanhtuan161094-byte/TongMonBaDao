extends SceneTree

const TEST_SAVE_PATH := "user://b3_main_hunt_integration_test.json"
const TEST_SAVE_PATH_ENV := "TMB_B3_MAIN_HUNT_TEST_SAVE_PATH"
const LEGACY_POISON := 7654321.0
const V2_TUVI_FIXTURE := 2468.0

var test_save_path := TEST_SAVE_PATH
var ui: Control
var state: SimulationState
var disciple: DiscipleState

func _init() -> void:
    call_deferred("_run")

func _check(valid: bool, reason: String) -> bool:
    if valid:
        return true
    push_error(reason)
    _cleanup_ui()
    _cleanup()
    quit(1)
    return false

func _cleanup_ui() -> void:
    if ui == null:
        return
    var poll := ui.get("runtime_poll_timer") as Timer
    var autosave := ui.get("autosave_timer") as Timer
    if poll != null:
        poll.stop()
    if autosave != null:
        autosave.stop()
    ui.set("runtime_ready",false)
    ui.queue_free()
    ui = null

func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _cleanup() -> void:
    _remove(test_save_path)
    _remove(test_save_path+".bak")
    ProjectSettings.set_setting("runtime/live_save_path",null)

func _recruit_real_v2() -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,73021
    )
    if candidate == null or candidate.v2_birth_profile.is_empty():
        return null
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    return state.disciples.get(candidate.id) if accepted.get("ok",false) else null

func _open_main() -> bool:
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(packed != null,"Could not load the actual P3.2 main scene."):
        return false
    ui = packed.instantiate() as Control
    if not _check(ui != null,"Could not instantiate the actual P3.2 main scene."):
        return false
    root.add_child(ui)
    await process_frame
    if not _check(bool(ui.get("runtime_ready")),"P3.2 main scene did not start its live runtime."):
        return false
    var poll := ui.get("runtime_poll_timer") as Timer
    var autosave := ui.get("autosave_timer") as Timer
    if poll != null:
        poll.stop()
    if autosave != null:
        autosave.stop()
    state = ui.get("state") as SimulationState
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    return _check(state != null and runtime != null and runtime.owner.state == state,
        "Main screen state is not the state owned by its existing LiveGameRuntimeV2.")

func _drain_main_runtime(runtime: LiveGameRuntimeV2, now: int) -> bool:
    for _iteration in range(2000):
        var result := runtime.poll(now,10)
        if not result.get("ok",false):
            return _check(false,"Main runtime clock failed during the integrated hunt: %s" % str(result))
        if runtime.state().runtime_unconsumed_wall_seconds < 0.25:
            return true
    return _check(false,"Main runtime did not drain the bounded hunt-time batch.")

func _run() -> void:
    var isolated_path := OS.get_environment(TEST_SAVE_PATH_ENV).strip_edges()
    if not isolated_path.is_empty():
        test_save_path = isolated_path
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",test_save_path)
    if not await _open_main():
        return

    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    disciple = _recruit_real_v2()
    if not _check(disciple != null and DiscipleRealmProgressV2.progression_ready(disciple),
        "Could not recruit a real V2 disciple in the main runtime."):
        return
    if not _check(WorkforceSystem.new().issue_command(state,disciple.id,WorkforceSystem.COMMAND_HOLD,"",1000000),
        "Could not place the real V2 disciple into an idle, non-working state."):
        return
    var equipment := EquipmentSystem.new()
    var weapon := equipment.craft(state,&"thanh_thiet_kiem",false)
    if not _check(not weapon.is_empty()
        and equipment.manual_equip(state,disciple.id,StringName(weapon.get("id","")))
        and not equipment.equipped_item(state,disciple,EquipmentSystem.SLOT_WEAPON).is_empty(),
        "Could not equip the real V2 disciple through canonical crafting/equipment APIs."):
        return
    if not _check(CombatSkillSystem.new().learn_skill(state,disciple,&"thanh_phong_tram"),
        "Could not teach the real V2 disciple its Combat V2 pilot skill."):
        return

    # Use unmistakable values to prove that the hunt panel reads V2 authority,
    # not P2 compatibility fields or a multiplied/formatted display value.
    disciple.v2_realm_progress["cultivation"]["xp"] = V2_TUVI_FIXTURE
    disciple.cultivation_progress = LEGACY_POISON
    disciple.cultivation_stage_index = 8
    disciple.combat_power = LEGACY_POISON

    ui.call("_open_disciple",disciple.id)
    var summary_button := ui.get_node("DiscipleSummaryPanel/SummaryB3Hunt") as Button
    if not _check(summary_button != null and summary_button.visible and not summary_button.disabled,
        "A selected authentic V2 disciple has no usable Đi săn command."):
        return
    summary_button.emit_signal("pressed")
    await process_frame

    if not _check(ui.get("runtime_session") == runtime and runtime.owner.state == state,
        "Opening the hunt replaced or forked the main runtime owner."):
        return
    var world: Dictionary = state.sect.b3_hunt
    if not _check(not world.is_empty() and str(world.get("member","")) == str(disciple.id),
        "The main Đi săn command did not deploy the selected real V2 disciple into B3HuntWorld."):
        return
    if not _check(bool(ui.get_node("B3MainHuntShade").visible)
        and bool(ui.get_node("B3MainHuntShade/B3MainHuntPanel").visible),
        "The integrated hunt card did not become visible over the main screen."):
        return

    var battle_result := B3HuntWorld.restore(state)
    if not _check(battle_result.get("ok",false),"The integrated hunt has no restorable Combat V2 battle snapshot."):
        return
    var battle: MapBattleV2 = battle_result["battle"]
    if not _check(battle.actors.has(str(disciple.id)),"Combat V2 snapshot does not contain the selected disciple."):
        return
    var has_monster := false
    for actor_value in battle.actors.values():
        var actor: Dictionary = actor_value
        if str(actor.get("side","")) == "monster":
            has_monster = true
            break
    if not _check(has_monster,"Combat V2 snapshot does not contain the real pilot monster."):
        return

    ui.call("_refresh_b3_hunt_panel")
    var facts := str(ui.get("b3_hunt_facts").text)
    var progression := DiscipleRealmProgressV2.current(disciple)
    var tuvi: Dictionary = progression["cultivation"]
    var required := DiscipleProgressionBalanceV2.floor_cost(int(tuvi["realm"]),int(tuvi["floor"]))
    var expected_tuvi := "%s tầng %d · %.0f / %.0f Tu Vi" % [
        DiscipleRealmProgressV2.realm_name("cultivation",int(tuvi["realm"])),
        int(tuvi["floor"]),V2_TUVI_FIXTURE,float(required)
    ]
    if not _check(facts.contains(expected_tuvi) and not facts.contains(str(LEGACY_POISON)),
        "Hunt UI Tu Vi is not the real V2 number or leaked legacy progress."):
        return
    if not _check(facts.contains("HP: %.0f / %.0f" % [disciple.hp,disciple.max_hp]) and facts.contains("Injury: Khỏe mạnh"),
        "Hunt UI HP or Injury does not reflect the selected simulation disciple."):
        return

    var auto_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntAuto") as Button
    auto_button.emit_signal("pressed")
    if not _check(bool(state.sect.b3_hunt.get("care",{}).get("auto_hunt",false)),
        "AUTO button did not save the B3MedicalAutoplayV1 policy on the main owner."):
        return
    var auto_world_id := str(state.sect.b3_hunt["world_id"])
    var stock_before := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    print("B3 MAIN BASELINE: paid=",world["slot"]["paid_generation"]," pilot_stock=",stock_before)
    var save_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntSave") as Button
    save_button.emit_signal("pressed")
    if not _check(FileAccess.file_exists(test_save_path),"Main hunt Save button did not write the canonical save file."):
        return
    var saved := SaveService.new().load_from_path(test_save_path)
    if not _check(saved != null and str(saved.sect.b3_hunt.get("world_id","")) == auto_world_id
        and str(saved.sect.b3_hunt.get("member","")) == str(disciple.id)
        and bool(saved.sect.b3_hunt.get("care",{}).get("auto_hunt",false)),
        "SaveService did not persist the in-progress world/member/AUTO state."):
        return

    _cleanup_ui()
    await process_frame
    if not await _open_main():
        return
    runtime = ui.get("runtime_session") as LiveGameRuntimeV2
    state = runtime.state()
    if not _check(bool(ui.get_node("B3MainHuntShade").visible)
        and bool(ui.get_node("B3MainHuntShade/B3MainHuntPanel").visible),
        "Reloading the main scene did not resume the saved hunt interface."):
        return
    world = state.sect.b3_hunt
    if not _check(str(world.get("world_id","")) == auto_world_id
        and str(world.get("member","")) == str(disciple.id)
        and bool(world.get("care",{}).get("auto_hunt",false)),
        "Main-screen Save/Load changed the active world, disciple or AUTO policy."):
        return
    var loaded_battle := B3HuntWorld.restore(state)
    if not _check(loaded_battle.get("ok",false) and loaded_battle["battle"].actors.has(str(disciple.id)),
        "Save/Load lost the actual Combat V2 battle actor."):
        return
    if not _check(WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE) == stock_before
        and int(world.get("slot",{}).get("paid_generation",0)) == 0,
        "Reload duplicated loot or changed canonical Warehouse stock before a paid kill."):
        return

    disciple = state.disciples[disciple.id]
    var sim_now := int(state.runtime_last_wall_unix)
    var paid_before := int(world["slot"]["paid_generation"])
    for _second in range(1,601):
        sim_now += 1
        if not _drain_main_runtime(runtime,sim_now):
            return
        if int(state.sect.b3_hunt["slot"]["paid_generation"]) > paid_before:
            break
    var first_kills := int(state.sect.b3_hunt["slot"]["paid_generation"])
    var first_stock := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    print("B3 MAIN FIRST LOOT: paid=",first_kills," pilot_stock=",first_stock," receipt=",state.sect.b3_hunt["receipt"]["state"])
    if not _check(first_kills > paid_before
        and first_stock-stock_before == (first_kills-paid_before)*B3PilotContent.QUANTITY,
        "Combat V2 did not settle real hunt loot into the main runtime's canonical Warehouse."):
        return
    ui.call("_refresh_b3_hunt_panel")
    var loot_facts := str(ui.get("b3_hunt_facts").text)
    if not _check(loot_facts.contains("Hạ gục đã trả thưởng: %d" % first_kills)
        and loot_facts.contains("Tổng: %d" % first_stock),
        "Main hunt UI did not refresh real kill and canonical Warehouse counts."):
        return
    var loot_save := SaveService.new().load_from_path(test_save_path)
    if not _check(loot_save != null
        and int(loot_save.sect.b3_hunt["slot"]["paid_generation"]) == first_kills
        and WarehouseSystem.new().quantity(loot_save,B3PilotContent.RESOURCE) == first_stock,
        "B3 exactly-once kill receipt and Warehouse result were not persisted by the main SaveService."):
        return

    # No Hồi Xuân Đan exists in this clean main save. AUTO must use canonical
    # REST, retain the locked Injury120, then re-enter the same world at tick 120.
    if not _check(WarehouseSystem.new().quantity(state,&"hoi_xuan_dan") == 0,
        "Clean integration fixture unexpectedly contains a healing pill."):
        return
    var downed := false
    for _second in range(1,601):
        sim_now += 1
        if not _drain_main_runtime(runtime,sim_now):
            return
        if disciple.injury_level == 1:
            downed = true
            break
    var down_tick := state.tick
    var recover_tick := disciple.injury_recover_at_tick
    var kills_at_down := int(state.sect.b3_hunt["slot"]["paid_generation"])
    print("B3 MAIN DOWN: tick=",down_tick," recover_tick=",recover_tick," paid=",kills_at_down," injury=",disciple.injury_level," hp=",disciple.hp," returned_to_sect=",disciple.region_id == &"sect")
    if not _check(downed and recover_tick == down_tick+120 and disciple.hp == 1.0
        and disciple.region_id == &"sect" and str(state.sect.b3_hunt["member"]) == "",
        "Real Combat V2 defeat did not return the selected disciple with Injury exactly 120 ticks."):
        return
    ui.call("_refresh_b3_hunt_panel")
    if not _check(str(ui.get("b3_hunt_facts").text).contains("Injury: Injury 1 · còn 120 tick"),
        "Main hunt panel did not display the real Injury countdown after defeat."):
        return
    while state.tick < recover_tick-1:
        sim_now += 60
        if not _drain_main_runtime(runtime,sim_now):
            return
    if not _check(disciple.injury_level == 1 and disciple.hp >= disciple.max_hp*0.75
        and int(state.sect.b3_hunt["care"]["rest_requests"]) > 0
        and int(state.sect.b3_hunt["care"]["auto_deploys"]) == 0,
        "AUTO did not recover through canonical REST while preserving Injury through tick 119."):
        return
    var deploys_before_recovery := int(state.sect.b3_hunt["care"]["auto_deploys"])
    for _second in range(1,601):
        sim_now += 1
        if not _drain_main_runtime(runtime,sim_now):
            return
        if int(state.sect.b3_hunt["care"]["auto_deploys"]) > deploys_before_recovery:
            break
    print("B3 MAIN INJURY120: tick=",state.tick," injury=",disciple.injury_level," hp=",disciple.hp," same_world_member=",state.sect.b3_hunt["member"]," rest_requests=",state.sect.b3_hunt["care"]["rest_requests"])
    if not _check(disciple.injury_level == 0 and str(state.sect.b3_hunt["member"]) == str(disciple.id)
        and str(state.sect.b3_hunt["world_id"]) == auto_world_id
        and int(state.sect.b3_hunt["care"]["auto_deploys"]) == 1,
        "AUTO did not redeploy the recovered disciple into the same world at Injury tick 120."):
        return
    var paid_at_redeploy := int(state.sect.b3_hunt["slot"]["paid_generation"])
    var stock_at_redeploy := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    print("B3 MAIN REDEPLOY: paid=",paid_at_redeploy," pilot_stock=",stock_at_redeploy," member=",state.sect.b3_hunt["member"]," injury=",disciple.injury_level)
    for _second in range(1,601):
        sim_now += 1
        if not _drain_main_runtime(runtime,sim_now):
            return
        if int(state.sect.b3_hunt["slot"]["paid_generation"]) > kills_at_down:
            break
    var final_kills := int(state.sect.b3_hunt["slot"]["paid_generation"])
    var final_stock := WarehouseSystem.new().quantity(state,B3PilotContent.RESOURCE)
    print("B3 MAIN REHUNT LOOT: paid=",final_kills," pilot_stock=",final_stock," delta_since_deploy=",final_stock-stock_at_redeploy," receipt=",state.sect.b3_hunt["receipt"]["state"])
    if not _check(final_kills > kills_at_down and final_kills > paid_at_redeploy
        and final_stock-stock_at_redeploy == (final_kills-paid_at_redeploy)*B3PilotContent.QUANTITY,
        "Recovered disciple did not resume hunting and credit the next real kill exactly once."):
        return
    var final_saved := SaveService.new().load_from_path(test_save_path)
    if not _check(final_saved != null
        and int(final_saved.sect.b3_hunt["slot"]["paid_generation"]) == final_kills
        and str(final_saved.sect.b3_hunt["receipt"].get("kill_id","")) == B3PilotContent.kill_id(auto_world_id,final_kills)
        and WarehouseSystem.new().quantity(final_saved,B3PilotContent.RESOURCE) == final_stock,
        "Post-recovery loot did not persist as one matching kill receipt and canonical Warehouse stock."):
        return
    ui.call("_refresh_b3_hunt_panel")
    var final_facts := str(ui.get("b3_hunt_facts").text)
    if not _check(final_facts.contains("Injury: Khỏe mạnh")
        and final_facts.contains("Hạ gục đã trả thưởng: %d" % final_kills)
        and final_facts.contains("Tổng: %d" % final_stock),
        "Main hunt panel did not show post-recovery combat and Warehouse values."):
        return

    var return_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntReturn") as Button
    return_button.emit_signal("pressed")
    if not _check(str(state.sect.b3_hunt.get("member","")) == ""
        and str(state.disciples[disciple.id].region_id) == "sect"
        and str(state.sect.b3_hunt["world_id"]) == auto_world_id,
        "Về tông môn did not return the selected disciple through B3HuntWorld."):
        return

    # Existing B3 admission rejects any worker; the integrated command must
    # keep the same fail-closed One Active Job rule.
    disciple = state.disciples[disciple.id]
    disciple.current_action = &"WORK_MINING"
    if not _check(not B3HuntWorld.admission(state,disciple.id).get("ok",false),
        "The real B3 admission accepted a disciple with an active work action."):
        return
    ui.call("_open_disciple",disciple.id)
    ui.call("_refresh_disciple_summary_content")
    summary_button = ui.get_node("DiscipleSummaryPanel/SummaryB3Hunt") as Button
    if not _check(not summary_button.disabled and summary_button.text == "Mở vòng săn",
        "Main screen did not distinguish reopening the existing world from deploying a working disciple."):
        return
    summary_button.emit_signal("pressed")
    await process_frame
    var deploy_button := ui.get_node("B3MainHuntShade/B3MainHuntPanel/B3MainHuntDeploy") as Button
    if not _check(deploy_button.disabled and str(state.sect.b3_hunt.get("member","")) == ""
        and disciple.current_action == &"WORK_MINING",
        "Integrated hunt panel deployed a disciple who already has production work."):
        return

    _cleanup_ui()
    await process_frame
    _cleanup()
    print("B3 MAIN SCREEN COMPLETE HUNT/CARE/LOOT/SAVE/RETURN INTEGRATION: PASS")
    quit(0)

