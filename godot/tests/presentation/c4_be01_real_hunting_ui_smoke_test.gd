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
    # Closing saves only the isolated scene's empty, unspent game state.
    panel.call("_close")
    sect.queue_free()
    print("C4-BE01 LIVE WORLD HUNT UI / REAL STATE / NO SYNTHETIC ENCOUNTER: PASS")
    quit(0)
