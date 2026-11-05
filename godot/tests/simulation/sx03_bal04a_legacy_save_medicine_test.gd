extends SceneTree

# BAL-04A compatibility acceptance contract, isolated QA user:// save.
# Old last-receipt potency was 10000 * 1.65^(realm-1) * quality.
# Modern potency is 0.1% of the canonical realm XP total * quality.
# Neither path may duplicate reward, alter historical receipts, or mint items.
const START := 1800000000
var checks := 0
var failed := false


func _init() -> void:
    call_deferred("_run")


func _check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failed = true
        push_error("BAL04A SAVE FAIL: " + label)


func _run() -> void:
    var path := "user://bal04a_legacy_receipt_%d.json" % Time.get_ticks_usec()
    var live := LiveGameRuntimeV2.new()
    if not bool(live.start(path, START, 930211).get("ok", false)):
        _check(false, "open isolated current V2 runtime")
        quit(1)
        return
    var setup := B3DemoSetup.prepare(live)
    if not bool(setup.get("ok", false)):
        _check(false, "authentic recruit exists")
        quit(1)
        return

    var state := live.state()
    var id := StringName(setup["disciple_id"])
    var d: DiscipleState = state.disciples[id]
    var warehouse := WarehouseSystem.new()
    _check(DiscipleRealmProgressV2.progression_ready(d),
        "real V2 disciple has canonical cultivation progress")
    _check(bool(B3PillSatietyV1.enable(state, d).get("ok", false)),
        "original B3 saturation authority enabled")
    var old_item := MedicineCatalogueV2.item_id("tuvi", 2, 1)
    var current_item := MedicineCatalogueV2.item_id("tuvi", 1, 1)
    _check(MedicineCatalogueV2.VERSION == 2
        and MedicineCatalogueV2.potency_for_version(old_item, 1) == 16500
        and MedicineCatalogueV2.potency_for_version(old_item, 2) == 12700,
        "old and new realm-2 potencies are separate versions")
    var old_realm := int(d.v2_realm_progress["cultivation"]["realm"])
    _check(old_realm == 1, "new real recruit starts at cultivation realm 1")

    # Reconstruct a VALID HISTORICAL LAST RECEIPT ONLY as an acceptance
    # fixture; this is not a live player grant or an alternative reward path.
    var day := int(state.tick / B3PillSatietyV1.DAY_TICKS)
    var historical := {
        "sequence": 1, "pill": str(old_item), "state": "COMMITTED",
        "day": day, "tick": state.tick, "cost": 25, "spent_after": 25,
        "hp_delta": 0.0, "tuvi": 16500.0, "injury": 0, "recover_tick": 0,
        "medicine_version": 1, "medicine_potency": 16500
    }
    d.b3_pill_state = {
        "version": B3PillSatietyV1.VERSION,
        "capacity": B3PillSatietyV1.CAPACITY,
        "day": day, "spent": 25, "sequence": 1,
        "receipt": historical.duplicate(true)
    }
    _check(B3PillSatietyV1.validate(state, d).is_empty(),
        "historical v1 graded Tu Vi last receipt remains valid after version 2")
    var xp_before := float(d.v2_realm_progress["cultivation"]["xp"])
    var stock_before := warehouse.quantity(state, old_item)
    _check(warehouse.add(state, old_item, 1),
        "QA inventory contains exactly one registered high-rank SKU")
    var qty_before := warehouse.quantity(state, old_item)
    var replay := B3PillSatietyV1.consume(state, d, old_item, 1)
    _check(bool(replay.get("ok", false)) and bool(replay.get("replay", false)),
        "replayed receipt is acknowledged without any fresh effect")
    _check(warehouse.quantity(state, old_item) == qty_before
        and float(d.v2_realm_progress["cultivation"]["xp"]) == xp_before,
        "replay cannot mint EXP or debit Warehouse")

    var blocked := B3PillSatietyV1.consume(state, d, old_item, 2)
    _check(not bool(blocked.get("ok", false))
        and str(blocked.get("reason", "")) == "medicine_realm_not_reached",
        "rank-2 pill cannot be consumed early through direct B3 interface")
    _check(warehouse.quantity(state, old_item) == qty_before
        and int(d.b3_pill_state.get("sequence", 0)) == 1
        and float(d.v2_realm_progress["cultivation"]["xp"]) == xp_before,
        "early-tier rejection preserves stock, EXP, receipt and sequence")

    var current_pill := MedicineCatalogueV2.definition(current_item)
    _check(int(current_pill["potency"]) == 10000
        and MedicineCatalogueV2.potency_for_version(current_item, 1) == 10000,
        "rank-1 core 10k Tu Vi effect preserved across both versions")
    _check(SaveService.new().save_to_path(state, path) == OK,
        "historical receipt and unchanged save schema are durable")
    var reloaded := SaveService.new().load_from_path(path)
    if reloaded == null:
        _check(false, "historical receipt can be loaded by current SaveService")
    else:
        var restored: DiscipleState = reloaded.disciples[id]
        _check(B3PillSatietyV1.validate(reloaded, restored).is_empty(),
            "loaded v1 receipt validates at new code HEAD")
        _check(int(restored.b3_pill_state["receipt"]["medicine_version"]) == 1
            and int(restored.b3_pill_state["receipt"]["medicine_potency"]) == 16500,
            "no migration rewrites committed historical potency/sequence")
        _check(warehouse.quantity(reloaded, old_item) == stock_before + 1,
            "save/reload never duplicates or loses staged warehouse stock")
        var good_receipt: Dictionary = restored.b3_pill_state["receipt"].duplicate(true)
        restored.b3_pill_state["receipt"]["medicine_potency"] = 16501
        _check(not B3PillSatietyV1.validate(reloaded, restored).is_empty(),
            "forged historical receipt potency fails closed")
        restored.b3_pill_state["receipt"] = good_receipt
        _check(B3PillSatietyV1.validate(reloaded, restored).is_empty(),
            "restore of correct original receipt returns to valid state")

    if not failed:
        print("BAL04A V1 RECEIPT -> V2 POTENCY / SAVE / EXACTLY-ONCE PASS (%d checks)" % checks)
    quit(1 if failed else 0)
