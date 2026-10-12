extends SceneTree

const PATH := "user://safe_01_save_recovery_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var saves := SaveService.new()
    var first := P0Factory.create_state(137)
    first.tick = 111
    if not _check(saves.save_to_path(first, PATH) == OK, "first save failed"):
        return
    var second := P0Factory.create_state(137)
    second.tick = 222
    if not _check(saves.save_to_path(second, PATH) == OK, "rotated save failed"):
        return
    var recovered := saves.load_from_path(PATH)
    if not _check(recovered != null and recovered.tick == 222, "new primary incorrect"):
        return
    var old_copy := saves.load_from_path(PATH + ".bak")
    if not _check(old_copy != null and old_copy.tick == 111, "backup not previous snapshot"):
        return

    # Simulate torn primary: restore the last complete committed snapshot.
    _write_bad(PATH)
    recovered = saves.load_from_path(PATH)
    if not _check(recovered != null and recovered.tick == 111, "corrupted primary not recovered"):
        return
    var third := P0Factory.create_state(137)
    third.tick = 333
    if not _check(saves.save_to_path(third, PATH) == OK, "could not heal corrupt primary"):
        return
    if not _check(saves.load_from_path(PATH).tick == 333 and
            saves.load_from_path(PATH + ".bak").tick == 111,
            "healing overwrote only good backup"):
        return

    # Crash after moving the old primary to backup, before installing staged data.
    _cleanup()
    if not _check(saves.save_to_path(first, PATH) == OK, "recreate save failed"):
        return
    var err := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(PATH),
        ProjectSettings.globalize_path(PATH + ".bak")
    )
    if not _check(err == OK, "simulate interrupt rename failed"):
        return
    _write_bad(PATH + ".tmp")
    recovered = saves.load_from_path(PATH)
    if not _check(recovered != null and recovered.tick == 111,
            "backup-only recovery failed"):
        return
    if not _check(saves.save_to_path(second, PATH) == OK and
            saves.load_from_path(PATH).tick == 222,
            "save after backup-only recovery failed"):
        return

    # A corrupted save with no backup is never silently overwritten.
    _cleanup()
    _write_bad(PATH)
    var original_text := FileAccess.get_file_as_string(PATH)
    if not _check(saves.load_from_path(PATH) == null and
            saves.save_to_path(first, PATH) != OK and
            FileAccess.get_file_as_string(PATH) == original_text,
            "corrupted sole copy was overwritten"):
        return

    _cleanup()
    print("SAFE-01 SAVE RECOVERY PASS")
    quit(0)

func _write_bad(path: String) -> void:
    var f := FileAccess.open(path, FileAccess.WRITE)
    f.store_string("{ truncated")
    f.close()

func _check(ok: bool, reason: String) -> bool:
    if ok:
        return true
    push_error("SAFE-01: " + reason)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for suffix in ["", ".bak", ".tmp"]:
        var path := PATH + suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
