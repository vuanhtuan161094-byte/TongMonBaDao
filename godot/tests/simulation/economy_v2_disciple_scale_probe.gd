extends SceneTree

# Local Windows capacity probe. Reports real scheduler time; no arbitrary PASS threshold.
const COUNTS := [100, 500, 1000, 3000]

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    for count in COUNTS:
        var state := P37Factory.create_state(166000 + count)
        state.sect.disciple_capacity = count
        var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
            state, DiscipleGeneratorV2.SOURCE_ORDINARY, 90000 + count
        )
        if candidate == null:
            _fail("Could not create authentic V2 benchmark donor")
            return
        state.recruitment_candidates[candidate.id] = candidate
        var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
        if not bool(accepted.get("ok",false)):
            _fail("Could not recruit authentic V2 benchmark donor")
            return
        var donor: DiscipleState = state.disciples[candidate.id]
        if not DiscipleRealmProgressV2.owns_v2_progression(donor):
            _fail("Benchmark donor is not authentic V2")
            return
        donor.current_action = &"HOLD"
        var blueprint := donor.to_dict()
        var serial := 0
        while state.disciples.size() < count:
            serial += 1
            var row := blueprint.duplicate(true)
            row["id"] = "scale_%04d" % serial
            row["name"] = "Scale %04d" % serial
            var actor := DiscipleState.from_dict(row)
            state.disciples[actor.id] = actor
        var scheduler := SimulationScheduler.new(state)
        var start_usec := Time.get_ticks_usec()
        scheduler.step()
        var elapsed_usec := Time.get_ticks_usec() - start_usec
        print("DISCIPLE_SCALE count=%d tick_ms=%.3f actual=%d" % [
            count, float(elapsed_usec) / 1000.0, state.disciples.size()
        ])
        if state.tick != 1 or state.disciples.size() != count:
            _fail("Scheduler did not process requested actor count")
            return
    print("DISCIPLE SCALE PROBE COMPLETED")
    quit(0)

func _fail(message: String) -> void:
    push_error("DISCIPLE SCALE PROBE FAILED: " + message)
    quit(1)
