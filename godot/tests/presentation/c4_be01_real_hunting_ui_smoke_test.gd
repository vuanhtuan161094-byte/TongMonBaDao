extends SceneTree

# BE01 UI smoke: opens ACTUAL P3.2 live scene in runner-isolated user://,
# then enters Thế Giới. No fake V2 recruits, resources, combat or rewards.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("C4-BE01 UI SMOKE: "+detail)
        quit(1)
    return ok

func _run() -> void:
    var fresh_path := "user://c4_be01_scene_smoke_%d.json" % Time.get_ticks_usec()
    ProjectSettings.set_setting("runtime/live_save_path",fresh_path)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(packed != null,"sect scene not found"):
        return
    var sect := packed.instantiate()
    get_root().add_child(sect)
    if not _check(bool(sect.get("runtime_ready")) and
            sect.get("runtime_session") is LiveGameRuntimeV2,
            "P3.2 live scene failed to load canonical simulation state"):
        return
    var state: SimulationState = sect.get("state")
    var original_claims := state.sect.v2_pve_reward_claims.duplicate(true)
    var original_runs := state.sect.v2_pve_active_runs.duplicate(true)
    sect.call("_bottom_action","world")
    var holder := sect.get("popup_layer") as Control
    var panel: HuntingPlayPanelV2 = null
    if holder != null:
        panel = holder.get_node_or_null("LiveHuntingPveV2") as HuntingPlayPanelV2
    if not _check(panel != null,"Thế Giới button did not open canonical PvE panel"):
        return
    var regions: OptionButton = panel.region_choice
    var levels: OptionButton = panel.level_choice
    if not _check(regions != null and regions.item_count == 3 and
            levels != null and levels.item_count == 5,
            "region/level selector not built for 3 authored maps / 5 real tiers"):
        return
    if not _check(panel.battle_layer != null and panel.session == null and
            panel.launch_button != null and panel.launch_button.disabled,
            "empty new game incorrectly starts a fake hunt without V2 recruits"):
        return
    if not _check(state.sect.v2_pve_reward_claims == original_claims and
            state.sect.v2_pve_active_runs == original_runs,
            "opening Thế Giới mutated canon combat/save/rewards"):
        return
    # Founders inherited from the legacy P2 save must explain their real
    # admission state instead of showing an undifferentiated locked checkbox.
    var founders: Array = state.disciples.keys()
    founders.sort()
    if not founders.is_empty():
        var old: DiscipleState = state.disciples[founders[0]]
        if not DiscipleRealmProgressV2.progression_ready(old):
            if not _check(panel._eligibility_reason(old) == "Chưa có hồ sơ Tu Vi + Luyện Thể V2",
                    "founder displayed a generic busy/injured message instead of missing realm source"):
                return

    # Create ONE authentic V2 recruit only in this isolated memory/file.
    # It does not appear on the player's saved sect and is not a fake 30x10.
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,20261019)
    if not _check(candidate != null and not candidate.v2_birth_profile.is_empty(),
            "authentic V2 birth fixture unavailable"):
        return
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not _check(bool(accepted.get("ok",false)),"actual V2 recruit rejected"):
        return
    var new_disciple: DiscipleState = state.disciples[candidate.id]
    if not _check(DiscipleRealmProgressV2.progression_ready(new_disciple),
            "real V2 recruit lacks canonical Tu Vi + Luyện Thể profile"):
        return
    panel._rebuild_roster()
    if not _check(panel._eligibility_reason(new_disciple).is_empty(),
            "new uninjured V2 recruit still cannot be selected: " +
            panel._eligibility_reason(new_disciple)):
        return
    panel._select_disciple(true,str(new_disciple.id))
    if not _check(panel.chosen.has(str(new_disciple.id)) and
            not panel.launch_button.disabled,
            "real V2 disciple cannot be selected for hunting"):
        return

    # The live canonical PvE begin path must register an actual saved
    # encounter, NOT merely enable a button in a synthetic interface.
    panel._launch()
    if not _check(panel.session != null and
            panel.session.battle != null and
            state.sect.v2_pve_active_runs.has(panel.session.battle.encounter_id),
            "real V2 hunter was selected but canonical encounter failed to begin: " +
            panel.status.text):
        return
    if not _check(state.sect.v2_pve_reward_claims == original_claims and
            panel.session.battle.active and
            state.disciples[candidate.id].active_pve_encounter_id == panel.session.battle.encounter_id,
            "live UI start awarded phantom resources or failed to reserve real disciple"):
        return

    # Close checkpoints while still fighting; never generates a win/loot.
    panel.call("_close")
    sect.queue_free()
    print("C4-BE01 LIVE WORLD HUNT UI / REAL STATE / NO SYNTHETIC ENCOUNTER: PASS")
    quit(0)
