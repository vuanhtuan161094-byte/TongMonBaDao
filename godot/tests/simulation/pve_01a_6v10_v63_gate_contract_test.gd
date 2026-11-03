extends SceneTree

# PVE-01A TEST-FIRST. This is a genuine Source A 6v10 V2 run, with a
# deliberately RED V6.3 integration assertion until PVE-01B is authorized.
# The six new V2 recruits and one archived manual exist ONLY in this isolated
# QA save. Never claim they are free resources for a normal New Game.
const SAVE_PATH := "user://pve01a_6v10_v63_gate_20261103.json"
const START_WALL := 1800001103
const SEED := 20261103
const ENCOUNTER := "pve01a:c01:6v10:20261103"
const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"

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
    for suffix in ["", ".tmp", ".bak"]:
        var path := SAVE_PATH + suffix
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

func _recruit_isolated_v2_party(state: SimulationState) -> Array:
    # The live New Game founders are legacy. This enlarged-capacity fixture
    # must never be confused with natural New Game PvE availability.
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity, state.disciples.size() + 6)
    var roles := ["frontline", "ranged", "mage", "healer", "frontline", "ranged"]
    var party: Array = []
    for index in range(6):
        var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
            state, DiscipleGeneratorV2.SOURCE_ORDINARY, SEED + index + 101)
        if candidate == null or not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            return []
        state.recruitment_candidates[candidate.id] = candidate
        var admitted := RecruitmentSystem.new().accept_candidate(state, candidate.id)
        if not bool(admitted.get("ok", false)):
            return []
        var disciple: DiscipleState = state.disciples.get(candidate.id)
        if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
            return []
        disciple.current_action = &"HOLD"
        party.append({
            "disciple_id": str(disciple.id),
            "party_id": "pve01a_test_party",
            "role": roles[index],
            "position": Vector2(8.0 + float(index % 3) * 2.0, 8.0 + float(int(index / 3)) * 2.0)
        })
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

func _run() -> void:
    _cleanup()
    var runtime := LiveGameRuntimeV2.new()
    var opened := runtime.start(SAVE_PATH, START_WALL, SEED)
    if not _check(bool(opened.get("ok", false)) and bool(opened.get("created", false)),
            "fresh canonical New Game runtime failed"):
        return
    var state: SimulationState = runtime.state()
    var natural_v2 := 0
    for raw_disciple in state.disciples.values():
        if DiscipleRealmProgressV2.progression_ready(raw_disciple):
            natural_v2 += 1
    print("PVE01A_FRESH_NEW_GAME_OBSERVATION " + JSON.stringify({
        "initial_roster": state.disciples.size(),
        "naturally_ready_v2": natural_v2,
        "can_start_6v10_without_recruitment": natural_v2 >= 6
    }))

    var party := _recruit_isolated_v2_party(state)
    if not _check(party.size() == 6, "canonical QA recruitment could not create six authentic V2 actors"):
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

    # Deliberately use the CURRENT game API without an imaginary new argument.
    # PVE-01B should fix the authority's persisted-flag propagation, not this test.
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
    var gate_pass := bool(actor.get("v63_combat_enabled", false)) \
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
