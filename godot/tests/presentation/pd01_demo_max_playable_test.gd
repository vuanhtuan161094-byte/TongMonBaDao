extends SceneTree

# Focused M1 gate: canonical DEMO MAX -> isolated save -> real P3.2 scene ->
# real HuntingPveRunV2 -> verified source-backed JX cues -> reward lifecycle.
const TEST_SAVE := "user://demo_sandbox/pd01_focused_gate_v3.json"
const PROTECTED_DEFAULT_SAVE := "user://tong_mon_ba_dao_live_v2.json"
const SOURCE_A_FLOOR_SHA256 := "c157965bd15f2747a55b602d4320dc34ad70c9129f79cc17eb8b4b139897468a"
const JX_HASHES := {
    "361b4525.webp":"4052de409053ad3dc3562795c0f0d93e96029387169c7f42a4dca5d104352e13",
    "1fffed7e.webp":"a22e5b9148a7d36e73dfea69cba271472e8700150f235da32fd5d36e212a5d2c",
    "2f8c6d50.webp":"621d884fd24c9fffbde197b667f734c0b88094fae3f3afdc6d37586f3ee6ab67"
}

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, detail: String) -> bool:
    if condition:
        return true
    push_error("PD01 DEMO MAX: " + detail)
    quit(1)
    return false

func _run() -> void:
    var data_dir := OS.get_user_data_dir().replace("\\", "/")
    print("DEMO_OS_USER_DATA_DIR=" + data_dir)
    if not _check(data_dir.to_lower().ends_with("/tong mon ba dao demo v3"),
            "Godot user data path is not the dedicated DEMO V3 application directory"):
        return
    var protected_before := _sha256_or_absent(PROTECTED_DEFAULT_SAVE)
    var launcher_scene := load("res://scenes/demo/demo_launcher.tscn") as PackedScene
    if not _check(launcher_scene != null,"default launcher scene missing"):
        return
    var launcher := launcher_scene.instantiate()
    get_root().add_child(launcher)
    await process_frame
    if not _check(launcher.get("play_max_button") is Button and
            launcher.get("new_game_button") is Button and
            launcher.get("continue_button") is Button,
            "launcher does not expose DEMO MAX / new game / continue actions"):
        return
    launcher.queue_free()
    await process_frame

    var built := DemoSandboxFactoryV1.create_max_state(DemoSandboxFactoryV1.SEED)
    if not _check(bool(built.get("ok",false)),"canonical sandbox factory failed: "+str(built)):
        return

    var state: SimulationState = built["state"]
    var hunters: Array = built["hunter_ids"]
    var workers: Array = built["worker_ids"]
    var assigned_workers: Array = built["assigned_worker_ids"]
    if not _check(hunters.size() == 6 and workers.size() == 6 and assigned_workers.size() >= 3,
            "expected six real hunters, six separate workers, and at least three assigned jobs"):
        return
    for id in hunters:
        var disciple: DiscipleState = state.disciples[StringName(str(id))]
        var progress := DiscipleRealmProgressV2.current(disciple)
        if not _check(bool(progress.get("ok",false)),"hunter has no canonical V2 progression: "+str(id)):
            return
        for track_id in ["cultivation","body"]:
            var track: Dictionary = progress[track_id]
            if not _check(int(track["realm"]) == 30 and int(track["floor"]) == 10,
                    "%s is not 30.10 on %s" % [str(id),track_id]):
                return
        if not _check(disciple.equipped_items.size() == 3,
                "hunter does not own weapon/armor/talisman: "+str(id)):
            return
        for item_id in disciple.equipped_items.values():
            var item: Dictionary = state.sect.equipment_items.get(str(item_id),{})
            if not _check(not item.is_empty() and str(item.get("owner_id","")) == str(id)
                    and str(item.get("location","")) == "equipped",
                    "equipment ownership/location invalid for "+str(id)):
                return
        if not _check(CombatSkillSystem.new().usable_skills(state,disciple).size() >= 1,
                "hunter has no actually learned, stage-legal P2 skill: "+str(id)):
            return
    for id in hunters:
        if not _check(not workers.has(id),"hunter and worker rosters overlap"):
            return

    var effects := CombatV4EffectAtlas.new()
    for pair in [
        ["jx_wudang_158_impact","361b4525.webp"],
        ["jx_wudu_63_impact","1fffed7e.webp"],
        ["jx_emei_93_precast","2f8c6d50.webp"]
    ]:
        var cue: Dictionary = effects.effects.get(str(pair[0]),{})
        var expected_hash := str(JX_HASHES[str(pair[1])])
        var path := "res://assets/combat_v4/jx1_skill_fx/"+str(pair[1])
        var bytes := FileAccess.get_file_as_bytes(path)
        if not _check(not cue.is_empty() and not bytes.is_empty(),"verified JX1 FX cue missing: "+str(pair[0])):
            return
        if not _check(_sha256_bytes(bytes) == expected_hash,
                "JX1 FX SHA-256 mismatch: "+str(pair[1])):
            return
        if not _check(not effects.frame_region(str(pair[0]),0.0).is_empty(),
                "JX1 cue atlas frame failed to load: "+str(pair[0])):
            return

    var floor_bytes := FileAccess.get_file_as_bytes(
        "res://art/source_a_env02a/env01_assets/terrain/stone_courtyard.png"
    )
    if not _check(not floor_bytes.is_empty() and _sha256_bytes(floor_bytes) == SOURCE_A_FLOOR_SHA256,
            "temporary Source A fallback floor hash did not match the verified file"):
        return

    var directory_error := DirAccess.make_dir_recursive_absolute(
        ProjectSettings.globalize_path("user://demo_sandbox")
    )
    if not _check(directory_error == OK or directory_error == ERR_ALREADY_EXISTS,
            "could not create isolated DEMO save directory"):
        return
    if not _check(SaveService.new().save_to_path(state,TEST_SAVE) == OK,
            "canonical SaveService rejected the DEMO sandbox state"):
        return
    var loaded := SaveService.new().load_from_path(TEST_SAVE)
    if not _check(loaded != null and loaded.disciples.size() == state.disciples.size(),
            "DEMO sandbox save did not round-trip through production SaveService"):
        return

    ProjectSettings.set_setting("runtime/live_save_path",TEST_SAVE)
    ProjectSettings.set_setting("demo/quick_hunt",true)
    ProjectSettings.set_setting("demo/hunter_ids",hunters)
    ProjectSettings.set_setting("demo/jx_loadouts",{
        hunters[1]:["jx_wudang_158"],
        hunters[2]:["jx_wudu_63"],
        hunters[3]:["jx_emei_93"]
    })
    var sect_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(sect_scene != null,"G1/MAP25 P3.2 scene missing"):
        return
    var sect := sect_scene.instantiate()
    get_root().add_child(sect)
    for unused in range(5):
        await process_frame
    if not _check(bool(sect.get("runtime_ready")),"real P3.2 scene did not start canonical live runtime"):
        return
    var popup := sect.get("popup_layer") as Control
    var panel := popup.get_node_or_null("LiveHuntingPveV2") as HuntingPlayPanelV2
    if not _check(panel != null,"launcher route did not open the real HuntingPveRunV2 panel"):
        return
    for unused in range(3):
        await process_frame
    if not _check(panel.session != null and panel.session.battle != null,
            "one-click hunt did not create an actual Combat V2 encounter"):
        return
    panel.set_process(false)
    var encounter := panel.session
    if not _check(encounter.spawn_data.get("level",0) == 5 and encounter.spawn_data.get("monsters",[]).size() == 7,
            "DEMO hunt did not use authored Tuyệt Địa group size"):
        return
    var has_boss := false
    for actor in encounter.battle.actors.values():
        if str(actor.get("side","")) == "monster" and str(actor.get("tier","")) == "boss":
            has_boss = true
    if not _check(has_boss,"level 5 encounter did not contain the guaranteed boss"):
        return
    if not _check(panel.battle_layer.enable_source_vl_art and
            panel.battle_layer.draw_pilot_ground and
            MapBattleWorldLayerV2.SOURCE_A_FLOOR != null,
            "source-backed combat art or scenic bridge floor did not load"):
        return
    if FileAccess.file_exists(MapBattleWorldLayerV2.JX_PRIVATE_BACKDROP):
        print("JX1_MAP_ASSET=AVAILABLE")
    else:
        print("JX1_MAP_ASSET=PENDING path="+MapBattleWorldLayerV2.JX_PRIVATE_BACKDROP)
    var snapshot := MapBattleSnapshotV2.save(encounter.battle)
    var restored := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(restored.get("ok",false)),"real JX pilot loadout snapshot failed to restore"):
        return
    var restored_battle: MapBattleV2 = restored["battle"]
    for id in [hunters[1],hunters[2],hunters[3]]:
        if not _check(not (restored_battle.actors[str(id)]["pilot_loadout"] as Array).is_empty(),
                "JX skill loadout did not persist in the actual encounter snapshot: "+str(id)):
            return

    var finished := encounter.finish(400)
    if not _check(bool(finished.get("ok",false)) and encounter.battle.outcome == "win",
            "actual level 5 boss run did not finish successfully: "+str(finished)):
        return
    panel.battle_layer.call("_ingest_authority_events")
    var events: Array = encounter.battle.events
    var source_158 := false
    var source_63 := false
    var source_93 := false
    for event in events:
        var pilot_id := str(event.get("pilot_id",""))
        if str(event.get("type","")) == "pilot_impact" and pilot_id == "jx_wudang_158":
            source_158 = true
        if str(event.get("type","")) == "pilot_impact" and pilot_id == "jx_wudu_63":
            source_63 = true
        if str(event.get("type","")) == "pilot_cast" and pilot_id == "jx_emei_93":
            source_93 = true
    if not _check(source_158 and source_63 and source_93,
            "not all three verified JX cues were triggered by real combat events"):
        return
    # Short-lived FX may have expired by the end of a completed encounter.
    # Replay the authoritative event history through the same presentation
    # binding once, without advancing visual time, to verify all source stages.
    var cue_probe := MapBattleWorldLayerV2.new()
    cue_probe.enable_source_vl_art = true
    cue_probe.attach_session(encounter.battle)
    cue_probe.set("_event_cursor",0)
    cue_probe.call("_ingest_authority_events")
    var cue_kinds: Array[String] = []
    for cue in cue_probe.get("_effect_cues"):
        cue_kinds.append(str(cue.get("kind","")))
    if not _check(cue_kinds.has("jx_wudang_158_impact") and
            cue_kinds.has("jx_wudu_63_impact") and cue_kinds.has("jx_emei_93_precast"),
            "authoritative events were not bound to their three verified JX1 visual stages"):
        return
    var claimed := encounter.claim()
    if not _check(bool(claimed.get("ok",false)),"Combat V2 reward could not be claimed: "+str(claimed)):
        return

    var protected_after := _sha256_or_absent(PROTECTED_DEFAULT_SAVE)
    print("DEMO_DEFAULT_SAVE_SHA256_BEFORE="+protected_before)
    print("DEMO_DEFAULT_SAVE_SHA256_AFTER="+protected_after)
    if not _check(protected_before == protected_after,
            "the default save file checksum/existence changed during DEMO QA"):
        return
    print("DEMO_RESULT=PASS hunters=6 workers=6 assigned_workers=%d p2_damage_skills=%d boss=true jx_cues=3 reward=claimed" % [
        assigned_workers.size(),int(built.get("usable_p2_skills",0))
    ])
    var test_save_path := ProjectSettings.globalize_path(TEST_SAVE)
    for suffix in [".tmp", ".bak", ""]:
        if FileAccess.file_exists(test_save_path+suffix):
            DirAccess.remove_absolute(test_save_path+suffix)
    cue_probe.free()
    sect.queue_free()
    await process_frame
    quit(0)

func _sha256_or_absent(path: String) -> String:
    if not FileAccess.file_exists(path):
        return "ABSENT"
    return _sha256_bytes(FileAccess.get_file_as_bytes(path))

func _sha256_bytes(bytes: PackedByteArray) -> String:
    var context := HashingContext.new()
    if context.start(HashingContext.HASH_SHA256) != OK:
        return "HASH_ERROR"
    context.update(bytes)
    return context.finish().hex_encode()
