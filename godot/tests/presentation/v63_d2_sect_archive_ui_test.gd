extends SceneTree

const TEST_SEED := 1323232
const PREVIEW := {"sect_codex":true}

func _init() -> void:
    call_deferred("_run")

func _fail(detail: String) -> void:
    push_error("V63_D2_UI_FAIL: "+detail)
    quit(1)

func _run() -> void:
    var state := P23Factory.create_state(TEST_SEED)
    state.p3_7_buildings_enabled = true
    if not WarehouseSystem.new().initialize(state):
        _fail("could not initialize the existing Sect Warehouse fixture")
        return
    state.sect.v63_archive_opt_in = true
    var codices := V63SectArchiveSystem.codices()
    var chosen: Dictionary = {}
    for codex in codices:
        if bool(codex.get("archivable",false)):
            chosen = codex
            break
    if chosen.is_empty():
        _fail("no archive entry available")
        return
    var warehouse := WarehouseSystem.new()
    if not warehouse.add(state,StringName(chosen.manual_item_id),1):
        _fail("could not seed a real codex book into the canonical Warehouse")
        return

    var packed: PackedScene = load("res://scenes/p2/p2_3_techniques.tscn")
    if packed == null:
        _fail("could not load existing techniques screen")
        return
    var ui = packed.instantiate()
    ui.initial_state_override = state
    ui.archive_preview_overrides = PREVIEW
    root.add_child(ui)
    await process_frame
    if ui.archive_manual_button.disabled:
        _fail("archive action did not read the real Warehouse stock")
        return
    ui.archive_manual_button.pressed.emit()
    await process_frame
    var codex_id := str(chosen.id)
    if not bool(state.sect.v63_archived_codices.get(codex_id,false)):
        _fail("screen action did not archive the selected manual through simulation authority")
        return
    if warehouse.quantity(state,StringName(chosen.manual_item_id)) != 0:
        _fail("screen action left an extra manual copy in the Warehouse")
        return
    if not ui.archive_label.text.contains("%d đệ tử có truyền thụ" % state.disciples.size()):
        _fail("archive panel did not show the sect-wide transmission count")
        return
    ui.queue_free()
    await process_frame
    print("V63_D2_UI_PASS: existing techniques screen archives a real Warehouse manual and shows sect-wide transmission availability")
    quit(0)

