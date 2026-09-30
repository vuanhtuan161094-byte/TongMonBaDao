class_name SaveService
extends RefCounted

const CURRENT_VERSION := 1

func save_to_path(state: SimulationState, path: String) -> Error:
    var payload := state.to_dict()
    payload["save_version"] = CURRENT_VERSION

    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()

    file.store_string(JSON.stringify(payload))
    file.close()
    return OK

func load_from_path(path: String) -> SimulationState:
    if not FileAccess.file_exists(path):
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null

    var raw := file.get_as_text()
    file.close()

    var parsed = JSON.parse_string(raw)
    if not (parsed is Dictionary):
        return null

    var data: Dictionary = parsed
    var version := int(data.get("save_version", 0))
    if version > CURRENT_VERSION:
        push_error("SaveService: save version %d is newer than supported %d." % [version, CURRENT_VERSION])
        return null

    data = _migrate(data, version)
    return SimulationState.from_dict(data)

func _migrate(data: Dictionary, version: int) -> Dictionary:
    var current := version
    var migrated := data.duplicate(true)

    while current < CURRENT_VERSION:
        match current:
            0:
                migrated["save_version"] = 1
                current = 1
            _:
                push_error("SaveService: unknown migration path from version %d." % current)
                return {}

    return migrated
