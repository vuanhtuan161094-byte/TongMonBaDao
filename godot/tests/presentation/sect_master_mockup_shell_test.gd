extends SceneTree
# UI-MOCKUP-01: test the authentic 1280x720 playable Godot scene.
const SAVE_PATH := "user://sect_master_mockup_shell_isolated.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for suffix in ["",".tmp",".bak"]:
        if FileAccess.file_exists(SAVE_PATH+suffix):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH+suffix))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var packed := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed == null:
        _fail("main Godot game unavailable")
        return
    var scene := packed.instantiate() as Control
    root.add_child(scene)
    for _frame in range(8):
        await process_frame
    var state := scene.get("state") as SimulationState
    if state == null or not bool(scene.get("runtime_ready")):
        _fail("live simulation not ready")
        return
    var previous := state.to_dict().duplicate(true)
    var top := scene.get("resource_label") as Label
    if top == null:
        _fail("canonical top resources label missing")
        return
    var text_value := top.text
    if not text_value.contains("Tiền") or not text_value.contains("Linh thạch") \
            or not text_value.contains("Đệ tử"):
        _fail("top bar lacks currency/roster status")
        return
    for raw_name in ["Thiết","Đan","Tủy"]:
        if text_value.contains(raw_name):
            _fail("raw warehouse item leaked into global HUD: "+raw_name)
            return
    var inventory := str(scene.call("_warehouse_operation_text"))
    for item in ["NGUYÊN LIỆU","TRANG BỊ","TIỀN TỆ"]:
        if not inventory.contains(item):
            _fail("canonical warehouse inventory section missing: "+item)
            return
    var bottom := scene.find_child("PlayerBottomBar",true,false) as Panel
    if bottom == null:
        _fail("single bottom navigation missing")
        return
    var buttons: Array[Button] = []
    for child in bottom.get_children():
        if child is Button:
            buttons.append(child as Button)
    if buttons.size() != 5:
        _fail("expected exactly five existing game navigation actions")
        return
    for i in range(buttons.size()):
        if buttons[i].text != ["Tông Môn","Đệ Tử","Kho","Thế Giới","Săn Quái"][i]:
            _fail("bottom navigation lost its canonical action order")
            return
        var bounds := Rect2(buttons[i].position,buttons[i].size)
        if bounds.position.x < 0 or bounds.end.x > 1280 or bounds.end.y > 78:
            _fail("bottom navigation clipped the 1280px viewport")
            return
        if i > 0 and buttons[i-1].position.x+buttons[i-1].size.x >= buttons[i].position.x:
            _fail("bottom navigation collision")
            return
    var dock := scene.find_child("SectMasterOverviewDock",true,false) as Panel
    if dock == null or not dock.visible or dock.position.x < 990 or dock.position.x+dock.size.x > 1280:
        _fail("Sect Master contextual dock absent or clipped")
        return
    var action := dock.find_child("SectMasterManage",true,false) as Button
    if action == null:
        _fail("Sect Master dock lacks real management action")
        return
    action.pressed.emit()
    await process_frame
    var detail := scene.find_child("BuildingOperationPanel",true,false) as Control
    if detail == null or not detail.visible:
        _fail("dock management button did not open real Hall gameplay panel")
        return
    scene.call("_close_building_operation_panel",true)
    await process_frame
    if state.to_dict() != previous:
        _fail("read-only mockup shell changed canonical game state")
        return
    print("SECT MASTER MOCKUP SHELL PASS top/warehouse/nav/dock/real management/no mutation")
    quit(0)

func _fail(detail: String) -> void:
    push_error("SECT MASTER MOCKUP SHELL FAIL: "+detail)
    quit(1)
