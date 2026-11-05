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
    var old := SectState.from_dict({})
    check(old != null and old.sx01_pill_policy.is_empty(),
        "old save stays opted out")

    if not failed:
        print("SX01 POLICY + TARGET + B3 CONSUMER + SAVE PASS (%d checks)" % count)
    quit(1 if failed else 0)
