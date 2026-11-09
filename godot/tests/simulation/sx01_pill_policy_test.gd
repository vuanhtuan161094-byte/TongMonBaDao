extends SceneTree

# SX-01 focused contract: actual V2 recruitment, canonical Warehouse,
# unchanged B3 consumer and SX-01 policy. NOT an asset/GUI playtest.
const NOW := 1800000000
var count := 0
var failed := false

func _init() -> void:
    call_deferred("run")

func check(ok: bool, label: String) -> bool:
    count += 1
    if not ok:
        failed = true
        push_error("SX01 FAIL: " + label)
    return ok

func run() -> void:
    var path := "user://sx01_policy_test_%d.json" % Time.get_ticks_usec()
    var runtime := LiveGameRuntimeV2.new()
    var started := runtime.start(path, NOW, 930211)
    if not check(bool(started.get("ok", false)), "fresh V2 live game"):
        quit(1)
        return
    var state := runtime.state()
    var warehouse := WarehouseSystem.new()
    var buildings := BuildingSystem.new()
    var hall := buildings.primary_building(state, BuildingSystem.TYPE_ALCHEMY_HALL)
    check(SX01PillPolicy.active(state), "new V2 game installs SX-01 policy")
    check(hall != null, "existing alchemy hall")
    check(str(state.sect.sx01_pill_policy.get("recipe_mode", "")) == "fixed",
        "conservative fixed recipe default")
    check(not SX01PillPolicy.configure(state, "target_tu_khi_dan", -1)["ok"],
        "invalid negative policy refused")
    check(SX01PillPolicy.configure(state, "target_tu_khi_dan", 12)["ok"],
        "valid target accepted")

    var setup := B3DemoSetup.prepare(runtime)
    if not check(bool(setup.get("ok", false)), "genuinely recruited V2 disciple"):
        quit(1)
        return
    var disciple_id := StringName(setup["disciple_id"])
    var d: DiscipleState = state.disciples[disciple_id]
    check(DiscipleRealmProgressV2.progression_ready(d), "no forged V2 profile")
    check(not B3MedicalAutoplayV1.busy(state, d), "safe idle window")
    check(SX01PillPolicy.set_tuvi_priority(state, disciple_id, true)["ok"],
        "explicit Tu Vi priority")

    # Synthetic warehouse addition is used solely to test the consumer policy.
    # The existing O4/O8 tests cover real, paid planting and timed alchemy.
    check(warehouse.add(state, &"hoi_xuan_dan", 1), "fixture medicinal item")
    var hp_before := d.hp
    d.hp = maxf(1.0, d.max_hp - 80.0)
    var damaged := d.hp
    state.tick = 5
    SX01PillPolicy.review(state)
    check(is_equal_approx(d.hp, minf(d.max_hp, damaged + 55.0)),
        "automatic HXD delegates to B3 unchanged +55 HP")
    check(warehouse.quantity(state, &"hoi_xuan_dan") == 0,
        "one item consumed, no extra output")
    check(B3PillSatietyV1.spent_today(state, d) == 10,
        "shared B3 satiety +10")
    # BAL-04A isolated high-HP stage probe: the old +55HP potion is not
    # wasted by SX01, while the player's manual-use right is unchanged.
    var canonical_max_hp := d.max_hp
    d.max_hp = 5000.0
    d.hp = 500.0
    check(not MedicineAllocationV2.legacy_heal_useful_for_auto(d),
        "55HP / 5000HP is less than 2% and auto heal must skip")
    check(warehouse.add(state, &"hoi_xuan_dan", 1),
        "isolated high-realm auto-use probe holds one real item")
    var sequence_before := int(d.b3_pill_state.get("sequence", 0))
    state.tick = 10
    SX01PillPolicy.review(state)
    check(warehouse.quantity(state, &"hoi_xuan_dan") == 1
        and int(d.b3_pill_state.get("sequence", 0)) == sequence_before
        and B3PillSatietyV1.spent_today(state, d) == 10,
        "ineffective auto HXD leaves Warehouse, receipt and satiety unchanged")
    d.max_hp = 2750.0
    d.hp = 1000.0
    check(MedicineAllocationV2.legacy_heal_useful_for_auto(d),
        "55HP / 2750HP is exactly the permitted 2% boundary")
    d.max_hp = canonical_max_hp
    d.hp = d.max_hp
    check(not SX01PillPolicy.configure(state, "recipe_mode", "invalid")["ok"],
        "bad recipe mode rejected")

    # Return to full health: priority HOLD disciple may receive TQD,
    # while a busy/CULTIVATE actor is blocked by unchanged B3 busy law.
    d.hp = d.max_hp
    check(warehouse.add(state, &"tu_khi_dan", 4), "fixture four Tu Khi Dan")
    var before_xp := float(d.v2_realm_progress["cultivation"]["xp"])
    state.tick = 10
    SX01PillPolicy.review(state)
    state.tick = 15
    SX01PillPolicy.review(state)
    state.tick = 20
    SX01PillPolicy.review(state)
    check(warehouse.quantity(state, &"tu_khi_dan") == 2,
        "two/day policy cap, even after three reviews")
    check(float(d.v2_realm_progress["cultivation"]["xp"]) == before_xp + 20000.0,
        "two B3 fixed grants of 10000, without extra source")
    check(B3PillSatietyV1.spent_today(state, d) == 60,
        "combined shared HXD10 + TQD25x2")
    check(int(state.sect.sx01_pill_policy["auto_tu_khi_used"].get(str(disciple_id), 0)) == 2,
        "auto budget recorded once each")

    # When demand mode is enabled, the hall must plan real usable input.
    check(SX01PillPolicy.configure(state, "recipe_mode", "demand")["ok"], "demand enabled")
    check(SX01PillPolicy.planned_recipe(state, hall) == &"",
        "no phantom recipe while ingredients are absent")
    check(warehouse.add(state, &"thanh_linh_thao", 3),
        "fixture real resource ID herb")
    check(SX01PillPolicy.planned_recipe(state, hall) == &"hoi_xuan_dan",
        "medical reserve prioritized over Tu Khi")
    check(warehouse.set_rule(state, &"thanh_linh_thao", 3, false),
        "warehouse hard reserve")
    check(SX01PillPolicy.planned_recipe(state, hall) == &"",
        "hard reservation stops next job")

    # Fixture-only field selector probe. Restore all state before the
    # canonical SaveService regression: this test does not grow/free-mint
    # a single herb, heart, item, EXP point or actual level-up.
    var field := buildings.primary_building(state, BuildingSystem.TYPE_SPIRIT_FIELD)
    if check(field != null, "existing canonical Spirit Field for graded demand"):
        var original_hall_level := hall.level
        var original_field_level := field.level
        var original_hall_production := hall.production_state.duplicate(true)
        var original_field_production := field.production_state.duplicate(true)
        var original_stock := state.sect.warehouse_resources.duplicate(true)
        var original_stones := state.sect.spirit_stones
        var original_recipe_mode := str(state.sect.sx01_pill_policy["recipe_mode"])
        state.sect.sx01_pill_policy["recipe_mode"] = "fixed"
        hall.level = 10
        hall.production_state["recipe_id"] = str(MedicineCatalogueV2.recipe_id("heal", 2))
        field.level = 10
        field.production_state = {"policy_mode": str(BuildingSystem.FIELD_POLICY_AUTO_DEMAND), "plots": []}
        state.sect.spirit_stones = 100
        # Abundant Thanh Linh deliberately neutralizes its own demand even
        # with the earlier reserve; Tử Vân is missing in real Warehouse stock.
        state.sect.warehouse_resources = {"thanh_linh_thao": 100}
        check(buildings._select_crop(state, field, field.production_state) == &"tu_van_thao",
            "AUTO_DEMAND chooses missing real r2 herb for fixed r2 healing recipe")
        field.level = 9
        check(buildings._select_crop(state, field, field.production_state) != &"tu_van_thao",
            "AUTO_DEMAND cannot bypass Tử Vân Field Lv10 gate")
        field.level = 10
        field.production_state["policy_mode"] = str(BuildingSystem.FIELD_POLICY_FIXED)
        field.production_state["fixed_crop_id"] = "linh_coc"
        check(buildings._select_crop(state, field, field.production_state) == &"linh_coc",
            "player's fixed crop policy always outranks graded auto demand")
        hall.level = original_hall_level
        hall.production_state = original_hall_production
        field.level = original_field_level
        field.production_state = original_field_production
        state.sect.warehouse_resources = original_stock
        state.sect.spirit_stones = original_stones
        state.sect.sx01_pill_policy["recipe_mode"] = original_recipe_mode

    var saved := SaveService.new().save_to_path(state, path)
    check(saved == OK, "SaveService commit")
    var reloaded := SaveService.new().load_from_path(path)
    if check(reloaded != null, "reload canonical save"):
        check(reloaded.sect.sx01_pill_policy == state.sect.sx01_pill_policy,
            "policy and daily quota roundtrip")
        check(warehouse.quantity(reloaded, &"tu_khi_dan") == 2,
            "no replayed B3 debit after reload")
        check(reloaded.disciples[disciple_id].b3_pill_state["sequence"] == d.b3_pill_state["sequence"],
            "B3 idempotent sequence preserved")
    # Post-save, isolated in-memory probe. An older-rank Q4 medicine is
    # stronger than current-rank Q1 but must not shadow a B3-usable dose.
    if reloaded != null:
        var probe: DiscipleState = reloaded.disciples[disciple_id]
        probe.v2_realm_progress["cultivation"]["realm"] = 2
        probe.v2_realm_progress["cultivation"]["floor"] = 1
        probe.v2_realm_progress["cultivation"]["xp"] = 0.0
        var old_tuvi := MedicineCatalogueV2.item_id("tuvi", 1, 4)
        var current_tuvi := MedicineCatalogueV2.item_id("tuvi", 2, 1)
        check(warehouse.add(reloaded, old_tuvi, 1)
            and warehouse.add(reloaded, current_tuvi, 1),
            "fixture owns stronger old-rank and weaker eligible Tu Vi")
        check(MedicineAllocationV2.best_available(reloaded, probe,
            MedicineCatalogueV2.FAMILY_TUVI) == current_tuvi,
            "Tu Vi allocation only selects the B3-usable exact realm")
        var old_stock := warehouse.quantity(reloaded, old_tuvi)
        var refused := B3PillSatietyV1.consume(reloaded, probe, old_tuvi,
            B3PillSatietyV1.next_sequence(probe))
        check(not bool(refused.get("ok",false))
            and str(refused.get("reason","")) == "medicine_wrong_realm"
            and warehouse.quantity(reloaded,old_tuvi) == old_stock,
            "wrong-realm direct use refuses before stock debit")
        var old_heal := MedicineCatalogueV2.item_id("heal", 1, 4)
        var current_heal := MedicineCatalogueV2.item_id("heal", 2, 1)
        probe.hp = maxf(1.0,probe.max_hp-125.0)
        check(warehouse.add(reloaded,old_heal,1)
            and warehouse.add(reloaded,current_heal,1),
            "fixture owns stronger old-rank and eligible HEAL")
        check(MedicineAllocationV2.best_available(reloaded,probe,
            MedicineCatalogueV2.FAMILY_HEAL) == current_heal,
            "HEAL allocation also honors B3 exact-realm rule")
    var old := SectState.from_dict({})
    check(old != null and old.sx01_pill_policy.is_empty(),
        "old save stays opted out")

    if not failed:
        print("SX01 POLICY + TARGET + B3 CONSUMER + SAVE PASS (%d checks)" % count)
    quit(1 if failed else 0)
