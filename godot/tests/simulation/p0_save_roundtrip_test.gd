extends SceneTree

const SAVE_PATH := "user://tong_mon_p0_roundtrip.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P0Factory.create_state(24680)
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(1000)

    var before_money := state.total_money()
    var before_tick := state.tick
    var before_count := state.disciples.size()

    var service := SaveService.new()
    var error := service.save_to_path(state, SAVE_PATH)
    if error != OK:
        push_error("Save failed with error %d." % error)
        quit(1)
        return

    var loaded := service.load_from_path(SAVE_PATH)
    if loaded == null:
        push_error("Load returned null.")
        quit(1)
        return

    if loaded.tick != before_tick:
        push_error("Tick mismatch after save/load.")
        quit(1)
        return
    if loaded.disciples.size() != before_count:
        push_error("Disciple count mismatch after save/load.")
        quit(1)
        return
    if loaded.total_money() != before_money:
        push_error("Money mismatch after save/load.")
        quit(1)
        return

    var resumed := SimulationScheduler.new(loaded)
    resumed.run_ticks(2000)

    var errors := loaded.validate_invariants()
    if not errors.is_empty():
        push_error("Loaded simulation violated invariants: %s" % " | ".join(errors))
        quit(1)
        return

    print("P0 SAVE ROUNDTRIP TEST PASS")
    print("tick=", loaded.tick, " money=", loaded.total_money(), " disciples=", loaded.disciples.size())
    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    quit(0)
