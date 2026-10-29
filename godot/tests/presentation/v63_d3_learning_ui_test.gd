extends SceneTree

const TEST_SEED := 1323232
const PREVIEW := {"sect_codex":true,"technique_learning":true}

func _init() -> void:
    call_deferred("_run")

func _fail(detail: String) -> void:
    push_error("V63_D3_UI_FAIL: " + detail)
    quit(1)

func _run() -> void:
    var state := P23Factory.create_state(TEST_SEED)
    state.p3_7_buildings_enabled = true
    if not WarehouseSystem.new().initialize(state):
        _fail("could not initialize the canonical Sect Warehouse")
        return
    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    var disciple_ids: Array = state.disciples.keys()
    disciple_ids.sort()
    if disciple_ids.is_empty():
        _fail("P2.3 test fixture has no disciples")
        return
    for raw_id in disciple_ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        disciple.contribution_points = 500
        disciple.spirit_stones = 500
        disciple.current_action = &"HOLD"

    var techniques := V63LearningSystem.techniques()
    if techniques.size() != 12:
        _fail("D3 catalogue was unavailable to the existing techniques screen")
        return
    var first: Dictionary = techniques[0]
    var codex := V63SectArchiveSystem.codex_definition(str(first.get("source_codex_id", "")))
    if codex.is_empty() or not WarehouseSystem.new().add(state, StringName(codex.manual_item_id), 1):
        _fail("could not seed the real source manual in the canonical Warehouse")
        return

    var packed: PackedScene = load("res://scenes/p2/p2_3_techniques.tscn")
    if packed == null:
        _fail("could not load existing P2.3 techniques screen")
        return
    var ui = packed.instantiate()
    ui.initial_state_override = state
    ui.archive_preview_overrides = PREVIEW
    ui.learning_preview_overrides = PREVIEW
    root.add_child(ui)
    await process_frame
    if ui.archive_manual_button.disabled:
        _fail("D2 archive controls did not use the real Warehouse manual")
        return
    ui.archive_manual_button.pressed.emit()
    await process_frame
    var disciple: DiscipleState = state.disciples[disciple_ids[0]]
    if not bool(state.sect.v63_archived_codices.get(str(first.source_codex_id), false)):
        _fail("screen did not archive the selected source manual through D2 authority")
        return
    if ui.learning_start_button.disabled:
        _fail("D3 study button did not become available after manual transmission was archived")
        return
    ui.learning_start_button.pressed.emit()
    await process_frame
    if disciple.v63_study_job.is_empty() or ui.learning_cancel_button.disabled or not ui.learning_label.text.contains("Đang nghiên tu"):
        _fail("screen did not start and display the real timed study job")
        return
    ui.scheduler.run_ticks(5)
    ui._refresh_ui()
    if not ui.learning_label.text.contains("% | còn ") or not ui.learning_label.text.contains("tick | mã"):
        _fail("study progress and ETA were not visible in the existing techniques screen: " + ui.learning_label.text)
        return
    ui.learning_cancel_button.pressed.emit()
    await process_frame
    if not disciple.v63_study_job.is_empty() or disciple.known_techniques.has(str(first.id)):
        _fail("screen cancellation did not release unfinished study without granting knowledge")
        return
    ui.learning_start_button.pressed.emit()
    await process_frame
    ui.scheduler.run_ticks(int(first.study_ticks))
    ui._refresh_ui()
    if not disciple.known_techniques.has(str(first.id)) or ui.learning_main_button.disabled:
        _fail("screen did not surface completed personal knowledge for loadout selection")
        return
    ui.learning_main_button.pressed.emit()
    await process_frame
    if str(disciple.active_technique_main) != str(first.id):
        _fail("screen loadout action did not update the normalized main technique slot")
        return
    if not ui.learning_label.text.contains("Nguồn Bí Kíp") or not ui.learning_label.text.contains("Phụ Tu"):
        _fail("screen omitted source transmission or the 1+2 technique slots")
        return
    ui.queue_free()
    await process_frame
    print("V63_D3_UI_PASS: existing techniques screen archives a real book, starts/cancels/completes study, displays ETA and equips the main slot")
    quit(0)

