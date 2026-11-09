extends SceneTree

# SX03: historical 2-million B3 meter remains loadable, but NEW spending
# obeys the current owner-locked 1-million/day limit. This isolated fixture
# never grants a player item or changes the global SaveService schema.
const START := 1800000000
var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _expect(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("SX03 SATIETY MIGRATION FAIL: " + label)

func _run() -> void:
    var path := "user://sx03_satiety_migration_%d.json" % Time.get_ticks_usec()
    var live := LiveGameRuntimeV2.new()
    if not bool(live.start(path,START,930211).get("ok",false)):
        _expect(false,"isolated runtime starts")
        quit(1)
        return
    var prep := B3DemoSetup.prepare(live)
    if not bool(prep.get("ok",false)):
        _expect(false,"real V2 disciple recruited for old-save fixture")
        quit(1)
        return
    var state := live.state()
    var id := StringName(prep["disciple_id"])
    var d: DiscipleState = state.disciples[id]
    var warehouse := WarehouseSystem.new()
    _expect(B3PillSatietyV1.CAPACITY == 1000000 and B3PillSatietyV1.VERSION == 3,
        "current cap exactly 1 million and new embedded meter version 3")
    var old_day := int(state.tick/B3PillSatietyV1.DAY_TICKS)
    var historical := {"sequence":60000,"pill":"tu_khi_dan","state":"COMMITTED",
        "day":old_day,"tick":state.tick,"cost":25,"spent_after":1500000,
        "hp_delta":0.0,"tuvi":10000.0,"injury":0,"recover_tick":0}
    d.b3_pill_state = {"version":2,"capacity":2000000,"day":old_day,
        "spent":1500000,"sequence":60000,"receipt":historical.duplicate(true)}
    _expect(B3PillSatietyV1.validate(state,d).is_empty(),
        "existing V2 two-million receipt remains valid, not reset")
    _expect(warehouse.add(state,&"tu_khi_dan",1),
        "test-only registered pill in isolated Warehouse")
    var qty := warehouse.quantity(state,&"tu_khi_dan")
    var refused := B3PillSatietyV1.consume(state,d,&"tu_khi_dan",60001)
    _expect(not bool(refused.get("ok",false))
        and str(refused.get("reason","")) == "daily_pill_satiety_full",
        "old over-cap state denies new spending before any debit")
    _expect(warehouse.quantity(state,&"tu_khi_dan") == qty
        and int(d.b3_pill_state["sequence"]) == 60000
        and int(d.b3_pill_state["spent"]) == 1500000,
        "rejected spend preserves inventory, sequence and old spent count")
    var save := SaveService.new()
    _expect(save.save_to_path(state,path) == OK,
        "unchanged SaveService serializes old V2 meter")
    var reloaded := save.load_from_path(path)
    _expect(reloaded != null,"old V2 meter cold-loads")
    if reloaded != null:
        var restored: DiscipleState = reloaded.disciples[id]
        _expect(B3PillSatietyV1.validate(reloaded,restored).is_empty()
            and int(restored.b3_pill_state["spent"]) == 1500000
            and int(restored.b3_pill_state["capacity"]) == 2000000,
            "historical cap and last receipt survive cold Save/Load")
        reloaded.tick += B3PillSatietyV1.DAY_TICKS
        _expect(B3PillSatietyV1.spent_today(reloaded,restored) == 0,
            "new canonical day resets only effective spent counter")
        restored.current_action = &"EVALUATE"
        var used := B3PillSatietyV1.consume(reloaded,restored,&"tu_khi_dan",60001)
        _expect(bool(used.get("ok",false)), "new day consumes real pill once")
        _expect(int(restored.b3_pill_state["version"]) == 3
            and int(restored.b3_pill_state["capacity"]) == 1000000
            and int(restored.b3_pill_state["spent"]) == 25
            and warehouse.quantity(reloaded,&"tu_khi_dan") == qty-1,
            "new receipt migrates to one-million cap without duplicate debit")
        _expect(B3PillSatietyV1.validate(reloaded,restored).is_empty(),
            "migrated meter validates under unchanged SaveService schema")
    for suffix in ["",".tmp",".bak"]:
        var candidate := path + suffix
        if FileAccess.file_exists(candidate):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
    print("SX03 SATIETY 2M HISTORICAL -> 1M CURRENT MIGRATION %d checks, %d failures"
        % [checks,failures])
    quit(1 if failures > 0 else 0)
