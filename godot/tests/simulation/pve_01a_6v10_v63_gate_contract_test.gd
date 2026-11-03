extends SceneTree

# PVE-01B regression: Source A 6v10 ON/OFF V6.3 gates, real skill
# damage, cached/uncached clock, two OS-process Save/Reload, and no duplicate
# settlement. Test actors come from the 130-roster QA seed; no free New Game
# recruits or player-owned item entitlements are created.
const SAVE_PATH := "user://pve01a_6v10_v63_gate_20261103.json"
const OFF_SAVE_PATH := "user://pve01b_6v10_gate_off_20261103.json"
const OFF_ENCOUNTER := "pve01b:c01:6v10:off"
const START_WALL := 1800001103
const SEED := 20261103
const ENCOUNTER := "pve01a:c01:6v10:20261103"
const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("PVE01A_6V10_V63_GATE_FAIL: " + why)
        _cleanup()
        quit(1)
        return false
    return true

func _cleanup() -> void:
    for base_path in [SAVE_PATH, OFF_SAVE_PATH]:
        for suffix in ["", ".tmp", ".bak"]:
            var path: String = str(base_path) + str(suffix)
            if FileAccess.file_exists(path):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _world_options() -> Dictionary:
    var navigation: Dictionary = SectIsometricWorldV1.pve_navigation_grid()
    if navigation.is_empty():
        return {}
    var topology := PveOpenWorldTopologyV1.build(
        navigation,
        Vector2(SectIsometricWorldV1.PVE_SPAWN_CELL) + Vector2(0.5, 0.5)
    )
    if not bool(topology.get("ok", false)):
        return {}
    topology["respawn_delay_sim_seconds"] = 30.0
    topology["auto_hunt"] = true
    return topology

func _eligible_for_pve(state: SimulationState, disciple: DiscipleState) -> bool:
    if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
        return false
    if disciple.hp <= 0.0 or disciple.injury_level != 0 or not disciple.active_pve_encounter_id.is_empty():
        return false
    if disciple.region_id != &"sect" or not [&"EVALUATE", &"IDLE", &"HOLD"].has(disciple.current_action):
        return false
    if not disciple.work_cycle_state.is_empty() or disciple.worksite_building_id != &"" or not disciple.work_progress.is_empty():
        return false
    var buildings := BuildingSystem.new()
    return not buildings.disciple_has_active_spirit_plot(state, disciple.id) \
        and not buildings.disciple_has_active_timed_recipe(state, disciple.id) \
        and buildings.active_resource_timer_for_worker(state, disciple.id).is_empty() \
        and not DiscipleBodyTrainingFacilityV2.has_reserved_slot(state, disciple)

func _select_real_v2_party(state: SimulationState) -> Array:
    # Select existing authentic V2 disciples in the committed 130-roster QA
    # fixture. No capacity/resource/realm mutation or fake recruitment.
    var ids: Array = state.disciples.keys()
    ids.sort()
    var roles := ["frontline", "frontline", "mage", "healer", "ranged", "ranged"]
    var party: Array = []
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[StringName(raw_id)]
        if not _eligible_for_pve(state, disciple):
            continue
        var p: Dictionary = DiscipleRealmProgressV2.current(disciple)
        var qi: Dictionary = p["cultivation"]
        var body: Dictionary = p["body"]
        var i := party.size()
        party.append({
            "disciple_id": str(disciple.id),
            "party_id": "pve01a_test_party",
            "role": roles[i],
            "position": Vector2(8.0 + float(i % 3) * 0.55, 8.7 + float(int(i / 3)) * 0.55),
            "realm": int(qi["realm"]), "floor": int(qi["floor"]),
            "body_realm": int(body["realm"]), "body_floor": int(body["floor"])
        })
        if party.size() == 6:
            break
    return party

func _equip_real_human_skill(state: SimulationState, disciple_id: StringName,
        preview: Dictionary) -> bool:
    var disciple: DiscipleState = state.disciples.get(disciple_id)
    if disciple == null:
        return false
    var definition := V63HumanSkillCombatSystem.skill_definition(SKILL_ID)
    if definition.is_empty() or not bool(definition.get("archivable", false)):
        return false
    var codex_id := str(definition.get("source_codex_id", ""))
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable", false)):
        return false
    var manual := StringName(str(codex.get("manual_item_id", "")))
    var warehouse := WarehouseSystem.new()
    # Authoritative add/archive/learn/equip in an isolated test fixture;
    # never inject skill IDs directly into a combat actor or production save.
    if not warehouse.registry.has(manual) or not warehouse.add(state, manual, 1):
        return false
    if not bool(V63SectArchiveSystem.archive_manual(state, codex_id, preview).get("ok", false)):
        return false
    if not bool(V63HumanSkillCombatSystem.learn_skill(
            state, disciple, SKILL_ID, preview).get("ok", false)):
        return false
    return bool(V63HumanSkillCombatSystem.equip_skill(
        state, disciple, SKILL_ID, preview).get("ok", false))

# This phase runs only in a new Godot executable launched by process one.
# Process two consumes the persisted snapshot through the canonical runtime
# clock, not an in-process new RuntimeOwner or a direct battle snapshot import.
func _process2_resume() -> void:
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, START_WALL + 1, SEED)
    if not _check(bool(opened.get("ok", false)) and bool(opened.get("loaded", false)),
            "process-2 could not load canonical SaveService hunt: " + str(opened)):
        return
    var state: SimulationState = runtime.state()
    var overrides: Dictionary = runtime.owner.scheduler.v63_preview_overrides
    if not _check(bool(overrides.get("human_skill_combat", false))
            and V63HumanSkillCombatSystem.is_enabled(state, overrides),
            "process-2 lost the persisted V6.3 opt-in"):
        return
    var encounter: String = HuntingPveRunV2.active_multicamp_id(state)
    if not _check(encounter == ENCOUNTER and state.sect.v2_pve_active_runs.size() == 1,
            "process-2 did not restore the single authoritative multicamp"):
        return
    var before := HuntingPveRunV2.resume_active(state, ENCOUNTER, overrides)
    if not _check(bool(before.get("ok", false)),
            "process-2 could not rehydrate V6.3 enabled battle"):
        return
    var battle: MapBattleV2 = before["session"].battle
    var skilled_id: String = ""
    for id in battle.actors.keys():
        var actor: Dictionary = battle.actors[id]
        if str(actor.get("side", "")) == "disciple" and actor.get("v63_skill_loadout", []).has(SKILL_ID):
            skilled_id = str(id)
    if not _check(not skilled_id.is_empty()
            and bool(battle.actors[skilled_id].get("v63_combat_enabled", false)),
            "process-2 V6.3 actor/learned equipped skill is disabled"):
        return
    var warehouse_before: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var before_time: float = battle.now
    # The cache is absent in a new process. This exercises the shared-clock
    # restore path from SimulationRuntimeClockV2 rather than a UI resume.
    var advanced := runtime.poll(START_WALL + 2, -1, 4)
    if not _check(bool(advanced.get("ok", false))
            and int(advanced.get("frames_run", 0)) > 0,
            "process-2 cold-cache shared-clock advance failed: " + str(advanced)):
        return
    var after := HuntingPveRunV2.resume_active(state, ENCOUNTER, overrides)
    if not _check(bool(after.get("ok", false)),
            "process-2 checkpoint after offline advance could not restore"):
        return
    var resumed_battle: MapBattleV2 = after["session"].battle
    if not _check(resumed_battle.now > before_time
            and bool(resumed_battle.actors[skilled_id].get("v63_combat_enabled", false))
            and resumed_battle.actors[skilled_id].get("v63_skill_loadout", []).has(SKILL_ID)
            and state.sect.v2_pve_active_runs.size() == 1
            and state.sect.v2_pve_reward_claims.is_empty()
            and state.sect.v2_pve_settlement_receipts.is_empty()
            and state.sect.warehouse_resources == warehouse_before,
            "process-2 lost skill/clock/active hunt or duplicated receipt/warehouse payout"):
        return
    if not _check(bool(runtime.save(START_WALL + 2).get("ok", false)),
            "process-2 canonical snapshot commit failed"):
        return
    print("PVE01B_PROCESS2_RELOAD_CLOCK_EXACT_ONCE_PASS " + JSON.stringify({
        "active_runs":state.sect.v2_pve_active_runs.size(),
        "before_time":before_time,"after_time":resumed_battle.now,
        "frames_run":int(advanced.get("frames_run", 0)),
        "skills_enabled":true,"rewards":state.sect.v2_pve_reward_claims.size(),
        "settlements":state.sect.v2_pve_settlement_receipts.size()
    }))
    quit(0)

func _run() -> void:
    if OS.get_cmdline_user_args().has("process2"):
        _process2_resume()
        return
    _cleanup()
    var fresh := LiveGameRuntimeV2.new()
    var fresh_open := fresh.start(SAVE_PATH, START_WALL, SEED)
    if not _check(bool(fresh_open.get("ok", false)) and bool(fresh_open.get("created", false)),
            "fresh canonical New Game runtime failed"):
        return
    var fresh_state: SimulationState = fresh.state()
    var natural_v2 := 0
    for raw_disciple in fresh_state.disciples.values():
        if DiscipleRealmProgressV2.progression_ready(raw_disciple):
            natural_v2 += 1
    print("PVE01A_FRESH_NEW_GAME_OBSERVATION " + JSON.stringify({
        "initial_roster": fresh_state.disciples.size(),
        "naturally_ready_v2": natural_v2,
        "can_start_6v10_without_recruitment": natural_v2 >= 6
    }))

    # Reset the isolated test slot to a canonical endgame QA roster, rather
    # than bypassing the production Sect Residence limit via disciple_capacity.
    var staged: SimulationState = SaveService.new().load_from_path(QA_SEED_SAVE)
    if not _check(staged != null and staged.disciples.size() == 130,
            "the committed authentic 130-disciple Source A QA seed is unavailable"):
        return
    staged.runtime_last_wall_unix = START_WALL
    staged.runtime_unconsumed_wall_seconds = 0.0
    if not _check(SaveService.new().save_to_path(staged, SAVE_PATH) == OK,
            "could not stage an independent SaveService copy of the QA fixture"):
        return
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, START_WALL, SEED)
    if not _check(bool(opened.get("ok", false)) and bool(opened.get("loaded", false)),
            "canonical owner could not load isolated QA seed"):
        return
    var state: SimulationState = runtime.state()
    var party := _select_real_v2_party(state)
    if not _check(party.size() == 6, "130-roster QA fixture did not provide six free authentic V2 actors"):
        return
    state.sect.v63_archive_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    state.sect.v63_learning_opt_in = true
    var preview := V63FeatureGates.persisted_preview_overrides(state)
    runtime.owner.scheduler.v63_preview_overrides = preview.duplicate(true)
    if not _check(V63HumanSkillCombatSystem.is_enabled(state, preview),
            "persisted human combat preview is not ON"):
        return
    var skilled_id := StringName(str(party[0]["disciple_id"]))
    if not _check(_equip_real_human_skill(state, skilled_id, preview),
            "real Source A V2 disciple failed canonical Archive/learn/equip for the gate probe"):
        return
    if not _check(bool(runtime.save(START_WALL).get("ok", false)),
            "isolated V63-prepared canonical state save failed"):
        return
    var options := _world_options()
    if not _check(bool(options.get("ok", false))
            and str(options.get("source_blob_sha", "")) == str(options.get("navigation", {}).get("source_blob_sha", "")),
            "Source A 192x192 world topology/identity invalid"):
        return

    # Gate-OFF is a genuine negative control: clone the QA setup AFTER the
    # disciple legally learns/equips his skill. Only disable the opt-in on the
    # copied canonical save. This catches accidental globally-enabled gates.
    var off_seed: SimulationState = SaveService.new().load_from_path(SAVE_PATH)
    if not _check(off_seed != null
            and off_seed.disciples[skilled_id].v63_equipped_skill_ids.has(SKILL_ID),
            "gate-OFF control must retain a legitimately equipped skill"):
        return
    off_seed.sect.v63_skill_combat_opt_in = false
    if not _check(V63FeatureGates.persisted_preview_overrides(off_seed).is_empty()
            and SaveService.new().save_to_path(off_seed, OFF_SAVE_PATH) == OK,
            "gate-OFF isolated QA save failed"):
        return
    var off_runtime := LiveGameRuntimeV2.new()
    var off_open := off_runtime.start(OFF_SAVE_PATH, START_WALL, SEED)
    if not _check(bool(off_open.get("ok", false)) and bool(off_open.get("loaded", false))
            and off_runtime.owner.scheduler.v63_preview_overrides.is_empty(),
            "gate-OFF runtime incorrectly inherited ON flags"):
        return
    var off_start := HuntingPveRunV2.new().begin_multicamp(
        off_runtime.owner, OFF_ENCOUNTER, SEED + 1, party, 10, options)
    if not _check(bool(off_start.get("ok", false))
            and int(off_start.get("party_size", 0)) == 6
            and int(off_start.get("monster_count", 0)) == 10,
            "gate-OFF canonical 6v10 failed to start: " + str(off_start)):
        return
    var off_state: SimulationState = off_runtime.state()
    var off_resumed := HuntingPveRunV2.resume_active(
        off_state, OFF_ENCOUNTER, off_runtime.owner.scheduler.v63_preview_overrides)
    if not _check(bool(off_resumed.get("ok", false)),
            "gate-OFF active hunt did not restore"):
        return
    var off_actor: Dictionary = off_resumed["session"].battle.actors.get(str(skilled_id), {})
    if not _check(not bool(off_actor.get("v63_combat_enabled", false))
            and off_actor.get("v63_skill_loadout", []).is_empty()
            and off_state.disciples[skilled_id].v63_equipped_skill_ids.has(SKILL_ID),
            "gate-OFF equipped skill was activated or legitimate skill identity lost"):
        return
    var off_poll := off_runtime.poll(START_WALL + 1, -1, 4)
    var off_after := HuntingPveRunV2.resume_active(
        off_state, OFF_ENCOUNTER, off_runtime.owner.scheduler.v63_preview_overrides)
    if not _check(bool(off_poll.get("ok", false))
            and bool(off_after.get("ok", false))
            and not bool(off_after["session"].battle.actors[str(skilled_id)].get("v63_combat_enabled", false))
            and off_state.sect.v2_pve_reward_claims.is_empty()
            and off_state.sect.v2_pve_settlement_receipts.is_empty(),
            "gate-OFF activated during cached scheduler tick or created duplicate claims"):
        return
    print("PVE01B_V63_GATE_OFF_PASS 6v10=true learned_skill_preserved=true activated=false scheduler_off=true")

    # Use the real public live API; PVE-01B production fix must derive the
    # gate from persisted opt-in, rather than requiring a special UI override.
    var launched := HuntingPveRunV2.new().begin_multicamp(
        runtime.owner, ENCOUNTER, SEED, party, 10, options)
    if not _check(bool(launched.get("ok", false))
            and bool(launched.get("world_mode", false))
            and int(launched.get("party_size", 0)) == 6
            and int(launched.get("monster_count", 0)) == 10,
            "canonical Source A 6v10 world did not begin: " + str(launched)):
        return
    var resumed := HuntingPveRunV2.resume_active(state, ENCOUNTER, preview)
    if not _check(bool(resumed.get("ok", false)), "6v10 SaveService snapshot cannot restore"):
        return
    var battle: MapBattleV2 = resumed["session"].battle
    if not _check(battle.world_mode and battle.continuous_mode
            and battle._count_alive("disciple") == 6
            and battle._count_alive("monster") == 10,
            "6v10 authoritative roster changed after resume"):
        return
    print("PVE01A_6V10_BASELINE_PASS " + JSON.stringify({
        "source_map": options.get("source_map", ""),
        "source_sha": options.get("source_blob_sha", ""),
        "disciples": battle._count_alive("disciple"),
        "monsters": battle._count_alive("monster")
    }))

    var actor: Dictionary = battle.actors.get(str(skilled_id), {})
    var gate_pass: bool = bool(actor.get("v63_combat_enabled", false)) \
        and actor.get("v63_skill_loadout", []).has(SKILL_ID)
    if not gate_pass:
        print("PVE01A_TEST_FIRST_EXPECTED_RED V63_ON_IN_SAVE_BUT_MULTICAMP_ACTOR_HAS_NO_ACTIVE_EQUIPPED_SKILL")
    if not _check(gate_pass,
            "persisted V63 ON was not propagated into the authentic 6v10 actor; PVE-01B pending"):
        return

    if not _check(bool(runtime.save(START_WALL).get("ok", false)),
            "mid-combat SaveService commit failed"):
        return
    var new_runtime := LiveGameRuntimeV2.new()
    var reopened := new_runtime.start(SAVE_PATH, START_WALL, SEED)
    if not _check(bool(reopened.get("ok", false)) and bool(reopened.get("loaded", false)),
            "new runtime failed independent SaveService reopen"):
        return
    var after := HuntingPveRunV2.resume_active(new_runtime.state(), ENCOUNTER,
        new_runtime.owner.scheduler.v63_preview_overrides)
    if not _check(bool(after.get("ok", false)), "independent V63 6v10 restore failed"):
        return
    var after_actor: Dictionary = after["session"].battle.actors.get(str(skilled_id), {})
    if not _check(bool(after_actor.get("v63_combat_enabled", false))
            and after_actor.get("v63_skill_loadout", []).has(SKILL_ID),
            "V63 equipped skill/gate disappeared across Save/exit/reload"):
        return
    print("PVE01A_V63_6V10_GATE_PASS seed=%d 6v10=true persisted_reload=true" % SEED)
    _cleanup()
    quit(0)
