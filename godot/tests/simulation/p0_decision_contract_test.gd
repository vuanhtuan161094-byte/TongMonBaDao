extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P0Factory.create_state(1337)
    var decisions := DecisionSystem.new()

    var expected_regions := {
        &"lam_thanh_vu": &"hac_phong_coc",
        &"tran_mac": &"thanh_truc_lam",
        &"bach_nguyet": &"bach_thach_khe",
        &"lam_an": &"thanh_truc_lam",
        &"co_truong_phong": &"hac_phong_coc",
        &"trieu_linh_nhi": &"bach_thach_khe"
    }

    for disciple_id in expected_regions.keys():
        var disciple: DiscipleState = state.disciples.get(disciple_id)
        if disciple == null:
            _fail("Missing disciple profile: %s" % disciple_id)
            return

        var chosen := decisions.choose_region(state, disciple)
        var expected: StringName = expected_regions[disciple_id]
        if chosen != expected:
            _fail("Region contract failed for %s: expected %s, got %s" % [disciple.display_name, expected, chosen])
            return

    var cautious: DiscipleState = state.disciples.get(&"tran_mac")
    var aggressive: DiscipleState = state.disciples.get(&"co_truong_phong")
    if cautious == null or aggressive == null:
        _fail("Retreat-threshold profiles missing.")
        return

    if aggressive.retreat_hp_ratio() >= cautious.retreat_hp_ratio():
        _fail("Risk contract failed: aggressive disciple must retreat at a lower HP ratio than cautious disciple.")
        return

    var broke_injured := DiscipleState.new({
        "id": "broke_injured",
        "name": "Broke Injured",
        "wallet": 0,
        "combat_power": 18.0,
        "risk_bias": 0.5,
        "spend_bias": 0.5,
        "survival_bias": 0.7
    })
    broke_injured.hp = 50.0
    broke_injured.region_id = &"sect"
    var broke_decision := decisions.evaluate(state, broke_injured)
    if StringName(broke_decision.get("action", "")) != &"REST":
        _fail("Recovery safety-floor contract failed: broke injured disciple must choose REST.")
        return

    var funded_injured := DiscipleState.new({
        "id": "funded_injured",
        "name": "Funded Injured",
        "wallet": EconomySystem.HEAL_FEE,
        "combat_power": 18.0,
        "risk_bias": 0.5,
        "spend_bias": 0.5,
        "survival_bias": 0.7
    })
    funded_injured.hp = 50.0
    funded_injured.region_id = &"sect"
    var funded_decision := decisions.evaluate(state, funded_injured)
    if StringName(funded_decision.get("action", "")) != &"HEAL":
        _fail("Paid-heal contract failed: injured disciple with enough money must choose HEAL.")
        return

    print("P0 DECISION CONTRACT TEST PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error(message)
    quit(1)
