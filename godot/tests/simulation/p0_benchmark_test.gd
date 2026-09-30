extends SceneTree

const SEEDS := [1337, 24680, 90210, 314159, 271828, 424242, 777777, 888888]
const TICKS_PER_SEED := 12000
const REPORT_PATH := "res://reports/p0_benchmark.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var aggregate := {
        "runs": 0,
        "ticks": 0,
        "money_min": 1 << 30,
        "money_max": 0,
        "treasury_min": 1 << 30,
        "treasury_max": 0,
        "combats": 0,
        "wins": 0,
        "retreats": 0,
        "defeats": 0,
        "sales": 0,
        "heals": 0,
        "rests": 0,
        "buys": 0,
        "disciples": {}
    }

    for seed_value in SEEDS:
        var state := P0Factory.create_state(seed_value)
        var scheduler := SimulationScheduler.new(state)
        scheduler.run_ticks(TICKS_PER_SEED)

        var errors := state.validate_invariants()
        if not errors.is_empty():
            push_error("Benchmark seed %d violated invariants: %s" % [seed_value, " | ".join(errors)])
            quit(1)
            return

        aggregate["runs"] += 1
        aggregate["ticks"] += state.tick
        aggregate["money_min"] = mini(int(aggregate["money_min"]), state.total_money())
        aggregate["money_max"] = maxi(int(aggregate["money_max"]), state.total_money())
        aggregate["treasury_min"] = mini(int(aggregate["treasury_min"]), state.sect.treasury)
        aggregate["treasury_max"] = maxi(int(aggregate["treasury_max"]), state.sect.treasury)

        for disciple in state.disciples.values():
            _accumulate_disciple(aggregate, disciple)

    if not _assert_aggregate(aggregate):
        quit(1)
        return

    _write_report(aggregate)
    _print_report(aggregate)
    quit(0)

func _accumulate_disciple(aggregate: Dictionary, disciple: DiscipleState) -> void:
    var metrics: Dictionary = disciple.metrics
    for key in ["combats", "wins", "retreats", "defeats", "sales", "heals", "rests", "buys"]:
        aggregate[key] = int(aggregate.get(key, 0)) + int(metrics.get(key, 0))

    var id := str(disciple.id)
    if not aggregate["disciples"].has(id):
        aggregate["disciples"][id] = {
            "name": disciple.display_name,
            "danger_visits": 0,
            "safe_visits": 0,
            "combats": 0,
            "wins": 0,
            "retreats": 0,
            "sales": 0,
            "ending_wallet": 0,
            "ending_hp": 0.0,
            "ending_stamina": 0.0
        }

    var row: Dictionary = aggregate["disciples"][id]
    row["danger_visits"] += int(metrics.get("danger_visits", 0))
    row["safe_visits"] += int(metrics.get("safe_visits", 0))
    row["combats"] += int(metrics.get("combats", 0))
    row["wins"] += int(metrics.get("wins", 0))
    row["retreats"] += int(metrics.get("retreats", 0))
    row["sales"] += int(metrics.get("sales", 0))
    row["ending_wallet"] += disciple.wallet
    row["ending_hp"] += disciple.hp
    row["ending_stamina"] += disciple.stamina

func _assert_aggregate(aggregate: Dictionary) -> bool:
    if int(aggregate["runs"]) != SEEDS.size():
        push_error("Benchmark did not complete all seeds.")
        return false

    if int(aggregate["money_min"]) != int(aggregate["money_max"]):
        push_error("Money conservation drifted between runs.")
        return false

    if int(aggregate["treasury_min"]) < EconomySystem.MIN_TREASURY_RESERVE:
        push_error("Sect treasury dropped below operating reserve in benchmark.")
        return false

    if int(aggregate["combats"]) <= 0 or int(aggregate["sales"]) <= 0:
        push_error("Core loop activity missing in benchmark.")
        return false

    var aggressive: Dictionary = aggregate["disciples"].get("co_truong_phong", {})
    var cautious: Dictionary = aggregate["disciples"].get("tran_mac", {})
    if aggressive.is_empty() or cautious.is_empty():
        push_error("Behavior benchmark rows missing.")
        return false

    if int(aggressive.get("danger_visits", 0)) <= int(cautious.get("danger_visits", 0)):
        push_error("Behavior benchmark failed: aggressive profile is not taking more danger exposure.")
        return false

    return true

func _write_report(aggregate: Dictionary) -> void:
    var absolute_dir := ProjectSettings.globalize_path("res://reports")
    DirAccess.make_dir_recursive_absolute(absolute_dir)
    var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
    if file == null:
        push_warning("Benchmark passed but report could not be written: %s" % REPORT_PATH)
        return
    file.store_string(JSON.stringify(aggregate, "  "))
    file.close()
    print("benchmark_report=", REPORT_PATH)

func _print_report(aggregate: Dictionary) -> void:
    print("P0 BENCHMARK PASS")
    print("runs=", aggregate["runs"], " ticks=", aggregate["ticks"])
    print("money=", aggregate["money_min"], " treasury_range=", aggregate["treasury_min"], "..", aggregate["treasury_max"])
    print("combats=", aggregate["combats"], " wins=", aggregate["wins"], " retreats=", aggregate["retreats"], " defeats=", aggregate["defeats"])
    print("sales=", aggregate["sales"], " heals=", aggregate["heals"], " rests=", aggregate["rests"], " buys=", aggregate["buys"])

    for id in aggregate["disciples"].keys():
        var row: Dictionary = aggregate["disciples"][id]
        var runs := float(aggregate["runs"])
        print(
            row["name"],
            " | danger=", row["danger_visits"],
            " safe=", row["safe_visits"],
            " combats=", row["combats"],
            " wins=", row["wins"],
            " retreats=", row["retreats"],
            " sales=", row["sales"],
            " avg_wallet=", snappedf(float(row["ending_wallet"]) / runs, 0.1),
            " avg_hp=", snappedf(float(row["ending_hp"]) / runs, 0.1),
            " avg_stamina=", snappedf(float(row["ending_stamina"]) / runs, 0.1)
        )
