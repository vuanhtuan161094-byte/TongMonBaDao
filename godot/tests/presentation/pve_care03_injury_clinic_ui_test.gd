extends SceneTree

# GUI-backed contract for one genuine V2 recruit in One Game 1280x720.
# The personal 2,000 LT is a TEST-ONLY wallet fixture (not a new faucet).
const PREFIX := "user://pve_care03_gui_"
var qa_path := ""
var ui: Control

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("PVE_CARE03_CLINIC_UI_FAIL "+why)
        _cleanup()
        quit(1)
        return false
    return true

func _cleanup() -> void:
    if ui != null:
        for name in ["runtime_poll_timer","autosave_timer"]:
            var clock := ui.get(name) as Timer
            if clock != null:
                clock.stop()
        ui.set("runtime_ready",false)
        ui.queue_free()
        ui = null
    if qa_path.begins_with(PREFIX):
        for suffix in ["",".tmp",".bak"]:
            var path: String = qa_path+str(suffix)
            if FileAccess.file_exists(path):
                DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _run() -> void:
    root.size = Vector2i(1280,720)
    qa_path = PREFIX+str(OS.get_process_id())+".json"
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",qa_path)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if not _check(packed != null,"canonical main scene missing"):
        return
    ui = packed.instantiate() as Control
    if not _check(ui != null,"live Control cannot instantiate"):
        return
    root.add_child(ui)
    await process_frame
    var state: SimulationState = ui.get("state")
    var runtime: LiveGameRuntimeV2 = ui.get("runtime_session")
    if not _check(bool(ui.get("runtime_ready")) and runtime != null and state != null
            and state.sect.economy_a_enabled,"canonical runtime/economy missing"):
        return
    for timer_name in ["runtime_poll_timer","autosave_timer"]:
        var timer := ui.get(timer_name) as Timer
        if timer != null:
            timer.stop()
    state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
    state.runtime_unconsumed_wall_seconds = 0.0
    var candidates: Array = state.recruitment_candidates.keys()
    candidates.sort()
    if not _check(not candidates.is_empty(),"no V2 candidate"):
        return
    var id := StringName(str(candidates[0]))
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,id).get("ok",false)),
            "legitimate V2 recruitment failed"):
        return
    var d: DiscipleState = state.disciples[id]
    if not _check(DiscipleRealmProgressV2.progression_ready(d),"recruit is not authentic V2"):
        return
    d.region_id = &"sect"
    d.current_action = &"HOLD"
    d.injury_level = 1
    d.injury_recover_at_tick = state.tick+120
    d.spirit_stones = 2000
    var hp_before := d.hp
    var sect_before := state.sect.spirit_stones
    ui.call("_open_disciple_deep_screen",id,"Tổng Quan")
    var root_popup := ui.get("popup_layer") as Control
    var clinic := root_popup.find_child("SectInjuryTreatmentAction",true,false) as Button if root_popup != null else null
    if not _check(clinic != null and not clinic.disabled
            and clinic.visible and clinic.text.contains("trọng thương"),
            "V2 Injury clinic button not visible and actionable"):
        return
    if not _check(clinic.tooltip_text.contains("1500") or clinic.tooltip_text.contains("1"),
            "clinic price and duration not visible"):
        return
    clinic.pressed.emit()
    await process_frame
    if not _check(d.injury_level == 1 and d.injury_recover_at_tick == state.tick+30
            and d.spirit_stones == 500
            and state.sect.spirit_stones == sect_before+1500
            and is_equal_approx(d.hp,hp_before),
            "UI did not debit exactly 1500LT and create 30-tick Injury treatment"):
        return
    var second := root_popup.find_child("SectInjuryTreatmentAction",true,false) as Button
    if not _check(second != null and second.disabled,
            "UI permitted duplicate paid clinic appointment"):
        return
    var cold := SaveService.new().load_from_path(qa_path)
    if not _check(cold != null and cold.disciples.has(id)
            and cold.disciples[id].injury_level == 1
            and cold.disciples[id].injury_recover_at_tick == state.tick+30
            and cold.disciples[id].spirit_stones == 500
            and is_equal_approx(cold.disciples[id].hp,hp_before),
            "player button did not durably save Injury timer/wallet/HP"):
        return
    print("PVE_CARE03_GUI_REAL_INJURY_CLINIC_1500LT_30TICKS_SAVE_PASS")
    _cleanup()
    quit(0)
