extends SceneTree

const SAVE_PATH := "user://dv2_03_f4_body_gate_player_command_test.json"
var ui: Control
var state: SimulationState

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("DV2-03F/F4: "+message)
    if ui != null:
        ui.queue_free()
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    quit(1)

func _run() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",SAVE_PATH)
    var scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if scene == null:
        _fail("No P3.2 scene.")
        return
    ui = scene.instantiate() as Control
    root.add_child(ui)
    await process_frame
    state = ui.get("state") as SimulationState
    if state==null or not bool(ui.get("runtime_ready")):
        _fail("Cannot use actual live scene.")
        return
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,409
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)):
        _fail("Genuine disciple recruitment failed.")
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    ui.set("selected_id",disciple.id)
    ui.call("_open_disciple_deep_screen",disciple.id,"Thuộc tính")
    await process_frame
    var popup: Control = ui.get("popup_layer") as Control
    var deep := popup.get_node_or_null("DiscipleDeepScreen") as Panel
    if deep == null:
        _fail("Real profile could not open.")
        return
    var button: Button = deep.find_child("BodyGateRealCommit",true,false) as Button
    if button==null or not button.disabled:
        _fail("Ungained-EXP Body gate should render visible but disabled.")
        return
    var preview := str(ui.call("_disciple_tab_text","Thuộc tính",disciple))
    if (
        not preview.contains("ĐỘT PHÁ LUYỆN THỂ 1 → 2") or
        not preview.contains("Thanh Linh Thảo") or
        not preview.contains("Tinh Lang Bì") or
        not preview.contains("EXP")
    ):
        _fail("Body gate preview failed to show actual named materials and EXP.")
        return
    # Isolated UI fixture can stock registered items; F3 separately proves
    # those same items are EARNED via actual confirmed PvE victories.
    var cost := DiscipleBodyGateContentV2.recipe(1)
    var warehouse := WarehouseSystem.new()
    var herb_id := StringName(cost["main_id"])
    var pelt_id := StringName(cost["aux_id"])
    if (
        not warehouse.add(state,herb_id,int(cost["main_qty"])) or
        not warehouse.add(state,pelt_id,int(cost["aux_qty"]))
    ):
        _fail("Cannot fund test-only preview fixture.")
        return
    disciple.v2_realm_progress["body"]["floor"]=10
    disciple.v2_realm_progress["body"]["xp"]=float(
        DiscipleProgressionBalanceV2.floor_cost(1,10)
    )
    disciple.current_action=&"EVALUATE"
    disciple.region_id=&"sect"
    var pure := DiscipleBodyGateTransactionV2.new().preview_gate(state,disciple.id)
    if not bool(pure.get("can_commit",false)):
        _fail("Real production A/B source did not unlock eligible gate: "+str(pure))
        return
    ui.call("_open_disciple_deep_screen",disciple.id,"Thuộc tính")
    await process_frame
    deep = popup.get_node_or_null("DiscipleDeepScreen") as Panel
    button = deep.find_child("BodyGateRealCommit",true,false) as Button
    if button==null or button.disabled:
        _fail("Eligible Body gate button did not become clickable.")
        return

    var old_tuvi: Dictionary = disciple.v2_realm_progress["cultivation"].duplicate(true)
    ui.call("_disciple_tab_action","v2_body_gate")
    await process_frame
    if (
        int(disciple.v2_realm_progress["body"]["realm"])!=2 or
        int(disciple.v2_realm_progress["body"]["floor"])!=1 or
        warehouse.quantity(state,herb_id)!=0 or
        warehouse.quantity(state,pelt_id)!=0 or
        disciple.v2_realm_progress["cultivation"]!=old_tuvi
    ):
        _fail("Actual UI command failed real transaction or changed Tu Vi.")
        return
    if not FileAccess.file_exists(SAVE_PATH):
        _fail("Successful UI gate did not save via live runtime.")
        return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if (
        loaded==null or not loaded.disciples.has(disciple.id) or
        int(loaded.disciples[disciple.id].v2_realm_progress["body"]["realm"])!=2 or
        loaded.sect.v2_body_gate_receipts.size()!=1
    ):
        _fail("UI gate success did not persist progression and receipt.")
        return
    var resources_before := state.sect.warehouse_resources.duplicate(true)
    ui.call("_disciple_tab_action","v2_body_gate")
    await process_frame
    if (
        resources_before!=state.sect.warehouse_resources or
        int(disciple.v2_realm_progress["body"]["realm"])!=2
    ):
        _fail("UI double click illegally spent materials again.")
        return

    ui.queue_free()
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    ProjectSettings.set_setting("runtime/live_save_path",LiveGameRuntimeV2.DEFAULT_SAVE_PATH)
    print("DV2-03F F4 REAL DISCIPLE BODY GATE UI: PASS; ",
        "read_only_preview=yes,button=real,save_receipt=yes,replay=blocked")
    quit(0)
