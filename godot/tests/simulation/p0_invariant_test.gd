extends SceneTree

const TICKS := 20000

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P0Factory.create_state(1337)
    var scheduler := SimulationScheduler.new(state)

    for i in range(TICKS):
        scheduler.step()
        var errors := state.validate_invariants()
        if not errors.is_empty():
            push_error("P0 invariant failure at tick %d: %s" % [i + 1, " | ".join(errors)])
            quit(1)
            return

    var aggressive: DiscipleState = state.disciples.get(&"co_truong_phong")
    var cautious: DiscipleState = state.disciples.get(&"tran_mac")

    if aggressive == null or cautious == null:
        push_error("P0 behavior profiles missing.")
        quit(1)
        return

    if int(aggressive.metrics.get("danger_visits", 0)) <= int(cautious.metrics.get("danger_visits", 0)):
        push_error("Behavior diversity gate failed: aggressive profile did not visit danger region more often.")
        quit(1)
        return

    var total_combats := 0
    var total_sales := 0
    var total_recovery := 0
    for disciple in state.disciples.values():
        total_combats += int(disciple.metrics.get("combats", 0))
        total_sales += int(disciple.metrics.get("sales", 0))
        total_recovery += int(disciple.metrics.get("heals", 0)) + int(disciple.metrics.get("rests", 0))

    if total_combats <= 0:
        push_error("Autonomous combat loop never executed.")
        quit(1)
        return
    if total_sales <= 0:
        push_error("Economy sell loop never executed.")
        quit(1)
        return
    if total_recovery <= 0:
        push_error("Recovery loop never executed.")
        quit(1)
        return

    if state.sect.treasury < EconomySystem.MIN_TREASURY_RESERVE:
        push_error("Economy survival gate failed: sect treasury dropped below operating reserve.")
        quit(1)
        return

    for disciple in state.disciples.values():
        if int(disciple.metrics.get("combats", 0)) <= 0:
            push_error("Agent activity gate failed: %s never entered combat." % disciple.display_name)
            quit(1)
            return

    print("P0 INVARIANT TEST PASS")
    print("ticks=", state.tick, " money=", state.total_money(), " treasury=", state.sect.treasury)
    print("combats=", total_combats, " sales=", total_sales, " recovery=", total_recovery)
    print("danger aggressive=", aggressive.metrics.get("danger_visits", 0), " cautious=", cautious.metrics.get("danger_visits", 0))
    quit(0)
