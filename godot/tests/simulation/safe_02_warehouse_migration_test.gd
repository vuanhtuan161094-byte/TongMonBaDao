extends SceneTree

const SAVE_PATH := "user://safe_02_migration_invalid_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var warehouse := WarehouseSystem.new()
    var valid := _legacy_state()
    valid.sect.warehouse_resources = {"thanh_thiet":4}
    valid.sect.forge_materials = {"thanh_thiet":5, "linh_moc":7}
    valid.sect.technique_materials = {"thanh_thiet":3}
    var events := valid.sect.warehouse_event_count
    if not _check(warehouse.ensure_migrated(valid), "valid migration failed"):
        return
    if not _check(valid.sect.p3_7_resources_enabled and
            warehouse.quantity(valid, &"thanh_thiet") == 12 and
            warehouse.quantity(valid, &"linh_moc") == 7 and
            valid.sect.forge_materials.is_empty() and
            valid.sect.technique_materials.is_empty() and
            valid.sect.warehouse_event_count == events + 1,
            "valid migration lost materials or duplicated events"):
        return
    if not _check(warehouse.ensure_migrated(valid) and
            warehouse.quantity(valid, &"thanh_thiet") == 12 and
            valid.sect.warehouse_event_count == events + 1,
            "second migration duplicated resources"):
        return

    var unknown := _legacy_state()
    unknown.sect.forge_materials = {"unknown_legacy_safe02":3}
    unknown.sect.technique_materials = {"thanh_thiet":2}
    if not _check(_reject_without_mutation(warehouse, unknown),
            "unknown item was silently dropped"):
        return

    var overflow := _legacy_state()
    overflow.sect.warehouse_resources = {"thanh_thiet":WarehouseSystem.MAX_SAFE_STACK - 1}
    overflow.sect.forge_materials = {"thanh_thiet":2}
    if not _check(_reject_without_mutation(warehouse, overflow),
            "stack overflow was silently dropped"):
        return

    var negative := _legacy_state()
    negative.sect.forge_materials = {"linh_moc":-1}
    if not _check(_reject_without_mutation(warehouse, negative),
            "negative legacy stack was silently discarded"):
        return

    # Loading a malformed legacy save must not treat it as a fresh valid state.
    var bad := _legacy_state()
    bad.sect.forge_materials = {"unknown_legacy_safe02":9}
    var wire := bad.to_dict()
    wire["save_version"] = 1
    var text_data := JSON.stringify(wire)
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if not _check(f != null, "cannot create legacy fixture"):
        return
    f.store_string(text_data)
    f.close()
    var service := SaveService.new()
    if not _check(service.load_from_path(SAVE_PATH) == null and
            FileAccess.get_file_as_string(SAVE_PATH) == text_data,
            "invalid legacy disk save migrated or got overwritten"):
        return

    var boundary := _legacy_state()
    boundary.sect.warehouse_resources = {"thanh_thiet":WarehouseSystem.MAX_SAFE_STACK - 1}
    boundary.sect.forge_materials = {"thanh_thiet":1}
    if not _check(warehouse.ensure_migrated(boundary) and
            warehouse.quantity(boundary, &"thanh_thiet") == WarehouseSystem.MAX_SAFE_STACK,
            "exact capacity boundary failed"):
        return

    _cleanup()
    print("SAFE-02 WAREHOUSE MIGRATION PASS")
    quit(0)

func _legacy_state() -> SimulationState:
    var state := P37Factory.create_state(283)
    state.sect.p3_7_resources_enabled = false
    state.sect.forge_materials.clear()
    state.sect.technique_materials.clear()
    state.sect.warehouse_resources.clear()
    return state

func _reject_without_mutation(warehouse: WarehouseSystem, state: SimulationState) -> bool:
    var before := JSON.stringify(state.sect.to_dict())
    var event_count := state.sect.warehouse_event_count
    var ok := warehouse.ensure_migrated(state)
    return (
        not ok and not state.sect.p3_7_resources_enabled and
        state.sect.warehouse_event_count == event_count and
        JSON.stringify(state.sect.to_dict()) == before
    )

func _check(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("SAFE-02: " + reason)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for suffix in ["", ".bak", ".tmp"]:
        var path: String = SAVE_PATH + str(suffix)
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
