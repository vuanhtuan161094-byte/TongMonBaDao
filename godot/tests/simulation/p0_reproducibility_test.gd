extends SceneTree

const SEED := 515151
const TICKS := 5000

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var first := _run_once()
    var second := _run_once()

    if first != second:
        push_error("Determinism gate failed: same seed produced different simulation snapshots.")
        quit(1)
        return

    print("P0 REPRODUCIBILITY TEST PASS")
    print("seed=", SEED, " ticks=", TICKS)
    quit(0)

func _run_once() -> Dictionary:
    var state := P0Factory.create_state(SEED)
    var scheduler := SimulationScheduler.new(state)
    scheduler.run_ticks(TICKS)
    return state.to_dict()
