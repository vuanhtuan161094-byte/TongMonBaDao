extends SceneTree

# SOURCE-vs-RUNTIME gate, not a V5.5-D feature toggle. Reads the exact
# approved spreadsheet 30-realm rows, checks earned-source identities, then
# reports conservative current Economy-A throughput against design. It never
# grants Stone, resources, EXP, upgrade, tax income or opens r3+ content.
const REFERENCE_PATH := "res://data/economy/v55d_30_realm_reference.json"
const DESIGN_TAX_SCENARIO := {"field":40,"mine":70,"forest":30}
const WORKERS_PER_SITE := 2
const ACTIVE_MINUTES_PER_WORKER_PER_DAY := 360

var registry := ResourceRegistry.new()
var buildings := BuildingSystem.new()
var crop_registry := SpiritCropRegistry.new()
var economy := EconomySystem.new()

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("SX-V55-ECO SOURCE GATE FAIL: " + reason)
        quit(1)
        return false
    return true

func _run() -> void:
    var raw := FileAccess.get_file_as_string(REFERENCE_PATH)
    var data = JSON.parse_string(raw)
    if not _check(data is Dictionary,"V5.5-D source reference missing or invalid JSON"):
        return
    if not _check(str(data.get("status","")) == "APPROVED_DESIGN_ONLY_NOT_LIVE"
        and not bool(data.get("runtime_activation",true)),"design rates were promoted into live gameplay"):
        return
    var realms: Array = data.get("realms",[])
    if not _check(realms.size() == 30,"V5.5-D exact 30 realm rows missing"):
        return
    var targets: Array = data.get("owner_batch_targets",[])
    if not _check(targets.size() == 5,"approved five production targets missing"):
        return

    var state := P37Factory.create_state(5511026)
    if not _check(not state.sect.economy_a_enabled,"legacy P3.7 Economy-A opt-in mutated"):
        return
    if not _check(bool(economy.enable_v1(state).get("ok",false)),"canonical Warehouse cannot enable Economy-A"):
        return
    var base_wage := int(state.sect.economy_a_policy.get("wage_per_batch",-1))
    var base_minutes := int(state.sect.economy_a_policy.get("resource_duration_ticks",-1))
    if not _check(base_wage == 2 and base_minutes == 10,"provisional Economy-A baseline changed without a funded migration"):
        return
    var mine := buildings.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := buildings.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    var field := buildings.primary_building(state,BuildingSystem.TYPE_SPIRIT_FIELD)
    if not _check(mine != null and forest != null and field != null,"three real production authorities missing"):
        return
    if not _check(BuildingSystem.MINE_ORE_OPTIONS.has("thanh_thiet")
        and BuildingSystem.FOREST_MATERIAL_OPTIONS.has("linh_moc")
        and crop_registry.has(&"linh_coc") and crop_registry.has(&"thanh_linh_thao")
        and crop_registry.has(&"tu_van_thao"),"real level-gated sources missing"):
        return
    # Five original V5.5-D IDs are now real, source-routed Mine/Forest
    # outputs. Their V5.6 reference market values were NOT approved prices.
    # This guard prevents the 30-stage design table from becoming a free
    # economy faucet or falsely implying all 630 materials exist in runtime.
    var preserved_sources := [
        {"id":"ore_r01_c2","kind":"mines"},
        {"id":"ore_r02_c2","kind":"mines"},
        {"id":"forest_r01_wood2","kind":"forests"},
        {"id":"forest_r02_wood","kind":"forests"},
        {"id":"forest_r02_wood2","kind":"forests"}
    ]
    for entry in preserved_sources:
        var material_id := StringName(entry.get("id",""))
        if not _check(registry.has(material_id),"preserved material missing: "+str(material_id)):
            return
        var status := str(registry.definition(material_id).get("value_status",""))
        var routes := MedicineResourceSourceV1.routes_for_ingredient(material_id)
        var route_name := str(entry.get("kind",""))
        if not _check(status == "V56_G_PROPOSED_REFERENCE_NOT_TRADEABLE"
            and economy.market_sell_price(material_id) == 0
            and bool(routes.get("ok",false))
            and not Array(routes.get(route_name,[])).is_empty(),
            "unverified trading/source route: "+str(material_id)):
            return
    if not _check(not registry.has(&"ore_r03_c1")
        and not registry.has(&"forest_r03_wood")
        and not AlchemyRecipeRegistry.new().has(&"sx02_recipe_heal_r03"),
        "r3 content unlocked without a verified source + recipe packet"):
        return

    var printed_targets := 0
    for value in targets:
        if not _check(value is Dictionary,"invalid approved batch target"):
            return
        var target: Dictionary = value
        var id := StringName(target.get("resource_id",""))
        var kind := str(target.get("source",""))
        if not _check(registry.has(id),"unregistered source target " + str(id)):
            return
        var minutes := int(target.get("minutes",0))
        var expected := int(target.get("quantity",0))
        var units := 0
        var cycle := 0
        match kind:
            "MINE":
                if not _check(BuildingSystem.MINE_ORE_OPTIONS.has(str(id)),"mine target unavailable"):
                    return
                units = buildings.mine_ore_batch_units(mine,id)
                cycle = base_minutes
            "FOREST":
                if not _check(BuildingSystem.FOREST_MATERIAL_OPTIONS.has(str(id)),"forest target unavailable"):
                    return
                units = buildings.forest_material_batch_units(forest,id)
                cycle = base_minutes
            "FIELD":
                if not _check(crop_registry.has(id),"field target unavailable"):
                    return
                units = crop_registry.base_yield(id)
                cycle = crop_registry.base_cycle_ticks(id)
            _:
                _check(false,"invented producer " + kind)
                return
        if not _check(minutes > 0 and units > 0 and cycle > 0 and expected > 0,"invalid batch data"):
            return
        var baseline_units := int(floor(float(minutes)/float(cycle))) * units
        if not _check(expected > baseline_units,"owner plan/runtime comparison unexpectedly collapsed"):
            return
        print("SX_V55_TARGET_HOLD source=",kind," id=",str(id),
            " window_min=",minutes," design_units=",expected,
            " runtime_single_worker_unmodified_upper=",baseline_units)
        printed_targets += 1
    if not _check(printed_targets == 5,"incomplete 60/90/180 minute comparisons"):
        return

    # Strict ceiling only: assumes every sellable unit is highest-priced, in
    # Warehouse unreserved, and there is uninterrupted external NPC demand.
    # The real game does not guarantee any of those favorable conditions.
    var highest_price := 0
    for raw_id in EconomySystem.V2_MARKET_SELLABLE:
        var item_id := StringName(raw_id)
        if not _check(registry.has(item_id),"unregistered NPC sellable " + str(item_id)):
            return
        highest_price = maxi(highest_price,economy.market_sell_price(item_id))
    var small_quota := economy.effective_market_daily_units(state)
    if not _check(highest_price > 0 and small_quota > 0,"missing real NPC sale authority"):
        return
    # The code's real 30-person rule: baseline vs 8 units per disciple,
    # bounded by 4000. This is a ceiling, not a simulated 30-person roster.
    var quota_at_30 := maxi(small_quota,mini(4000,30*8))
    var small_stone_ceiling := small_quota*highest_price
    var roster_30_stone_ceiling := quota_at_30*highest_price
    var previous_rate := 0
    var held := 0
    for i in range(realms.size()):
        var row = realms[i]
        if not _check(row is Dictionary,"malformed realm row"):
            return
        var tier := int(row.get("realm",-1))
        var rate := int(row.get("lt2_per_minute",-1))
        var wage := int(row.get("w2_min_wage_per_job",-1))
        var field_level := int(row.get("field_level",-1))
        var profession_level := int(row.get("profession_level",-1))
        var hall_level := int(row.get("hall_level",-1))
        if not _check(tier == i+1 and rate > previous_rate
            and wage == 2*rate and field_level >= 1 and field_level <= 100
            and profession_level >= 0 and hall_level >= 1,
            "V5.5-D row corrupt at tier " + str(tier)):
            return
        previous_rate = rate
        # Source worksheet scenario: 2 disciples per facility, 360 active
        # minutes per person/day, 40/70/30% Field/Mine/Forest tax. Hypothetical
        # gross/tax only, WITHOUT seeds, upgrades, real worker attendance, tax
        # command, gathered resources or verified 30-tier source IDs.
        var gross_site := WORKERS_PER_SITE*ACTIVE_MINUTES_PER_WORKER_PER_DAY*rate
        var design_gross := gross_site*3
        var scenario_tax := int(gross_site * (
            int(DESIGN_TAX_SCENARIO.field) +
            int(DESIGN_TAX_SCENARIO.mine) +
            int(DESIGN_TAX_SCENARIO.forest)
        ) / 100.0)
        var min_six_wages := wage * 6
        var late_sources_available := tier <= 2
        if not late_sources_available:
            held += 1
        print("SX_V55_REALM_AUDIT realm=",tier," lt2_design_only=",rate,
            " w2_design_only=",wage," design_gross_6workers_360min=",design_gross,
            " scenario_T2_tax_not_runtime=",scenario_tax,
            " npc6_upper=",small_stone_ceiling,
            " npc30_upper=",roster_30_stone_ceiling,
            " six_min_wages=",min_six_wages,
            " stage_sources=",("EARLY_AUTHORED" if late_sources_available else "DESIGN_HOLD"))
    if not _check(held == 28 and realms[0]["lt2_per_minute"] == 1000
        and realms[9]["lt2_per_minute"] == 22000
        and realms[19]["lt2_per_minute"] == 444000
        and realms[29]["lt2_per_minute"] == 8921000,
        "tier progression/source HOLD invariant violated"):
        return
    # Never let a reference-only model mutate actual monetary/warehouse
    # authority. Creation/enable of Economy-A is existing behavior.
    if not _check(int(state.sect.economy_a_policy.get("wage_per_batch",0)) == base_wage
        and state.sect.economy_a_receipts.is_empty()
        and state.sect.economy_a_market_units_sold == 0
        and state.sect.economy_a_market_units_bought == 0,
        "audit changed live currency/receipt authority"):
        return
    if not _check(state.validate_invariants().is_empty(),"source model broke runtime invariants"):
        return
    print("SX-V55-ECO VERIFIED SOURCE 30CG, 5 TARGET HOLD, ACTUAL MARKET CEILINGS: PASS; LIVE LT2/W2/T2=DESIGN_HOLD")
    quit(0)
