extends SceneTree

# Real landscape Hall command and read-only UI. Only the simulation owns cash.
const SAVE_PATH := "user://qa_eco01_origin_vein_hall_ui.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("missing canonical OneGame scene")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state == null or not state.sect.economy_a_enabled:
        _fail("real NewGame Economy-A not enabled")
        return
    _stop_timers(ui)
    state.sect.spirit_stones = 0
    ui.call("_open_building",SectMapPresentation.DEST_MAIN_HALL)
    await process_frame
    var button := ui.find_child("ECO01OriginVeinStart",true,false) as Button
    var pick := ui.find_child("ECO01OriginVeinWorker",true,false) as OptionButton
    var status := ui.find_child("ECO01OriginVeinStatus",true,false) as Label
    if button == null or button.disabled or pick == null or pick.disabled \
            or pick.item_count < 1 or status == null \
            or not status.text.contains("Miễn phí") or not status.text.contains("1.000"):
        _fail("Hall cannot show real free starter job from 0 LT")
        return
    var worker := StringName(str(pick.get_item_metadata(pick.selected)))
    button.emit_signal("pressed")
    await process_frame
    var live := Eco01OriginVein.new().snapshot(state)
    if not bool(live.get("busy",false)) or StringName(str(live.get("worker_id",""))) != worker \
            or state.sect.spirit_stones != 0:
        _fail("Hall Start did not launch canonical unpaid 60-minute job")
        return
    var begin_again := ui.find_child("ECO01OriginVeinStart",true,false)
    var cancel := ui.find_child("ECO01OriginVeinCancel",true,false) as Button
    if begin_again != null or cancel == null or cancel.disabled:
        _fail("Hall did not block a duplicate running job or expose cancel")
        return
    cancel.emit_signal("pressed")
    await process_frame
    if bool(Eco01OriginVein.new().snapshot(state).get("busy",false)) \
            or state.sect.spirit_stones != 0:
        _fail("Hall cancellation minted cash or left an active worker")
        return
    button = ui.find_child("ECO01OriginVeinStart",true,false) as Button
    if button == null or button.disabled:
        _fail("cancelled job did not recover free entry")
        return
    button.emit_signal("pressed")
    await process_frame
    if not bool(Eco01OriginVein.new().snapshot(state).get("busy",false)):
        _fail("Hall did not restart real worker after cancellation")
        return
    var runtime := ui.get("runtime_session") as LiveGameRuntimeV2
    if runtime == null or runtime.scheduler() == null:
        _fail("Hall job has no canonical simulation scheduler")
        return
    runtime.scheduler().run_ticks(60)
    ui.call("_refresh_building_operation_content")
    await process_frame
    status = ui.find_child("ECO01OriginVeinStatus",true,false) as Label
    if status == null or not status.text.contains("Đã nhận") \
            or state.sect.spirit_stones != 998 \
            or ui.find_child("ECO01OriginVeinStart",true,false) != null:
        _fail("Hall still claims free payout after earned daily settlement")
        return
    print("ECO01 HALL 1280X720 REAL START/CANCEL/ETA/RECEIPT UI: PASS")
    _cleanup()
    quit(0)

func _stop_timers(n: Node) -> void:
    if n is Timer:
        (n as Timer).stop()
    for child in n.get_children():
        _stop_timers(child)

func _cleanup() -> void:
    if ui != null and is_instance_valid(ui):
        root.remove_child(ui)
        ui.queue_free()
    ui = null
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    for suffix in ["",".bak",".tmp"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))

func _fail(why: String) -> void:
    push_error("ECO01 HALL UI FAIL: "+why)
    _cleanup()
    quit(1)
