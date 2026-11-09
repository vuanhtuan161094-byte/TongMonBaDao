extends SceneTree

# SX-07B real job settlement contract. Test-only paid budget and a direct
# elevation to Lv10 for source-gate probing: NOT a free player upgrade.
# No fake harvest, no dropped loot, no duplicate Warehouse or second clock.
const SAVE_PATH := "user://sx07b_preserved_materials_save.json"
const CASES := [
    {"kind":"mine","resource":"ore_r01_c2","level":1},
    {"kind":"linh_forest","resource":"forest_r01_wood2","level":1},
    {"kind":"mine","resource":"ore_r02_c2","level":10},
    {"kind":"linh_forest","resource":"forest_r02_wood","level":10},
    {"kind":"linh_forest","resource":"forest_r02_wood2","level":10}
]
var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("SX07B JOB FAIL: "+message)

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(710072)
    var bs := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    var warehouse := WarehouseSystem.new()
    var economy := EconomySystem.new()
    _check(bool(economy.enable_v1(state).get("ok",false)),"activate canonical Economy-A")
    # This is a QA budget only; runtime never grants LT for extra output IDs.
    state.sect.spirit_stones = 1000
    var mine := bs.primary_building(state,BuildingSystem.TYPE_MINE)
    var forest := bs.primary_building(state,BuildingSystem.TYPE_LINH_FOREST)
    _check(mine != null and forest != null,"canonical Mine and Forest")
    if mine == null or forest == null:
        _finish()
        return
    _check(not bool(bs.select_mine_ore(state,mine.id,&"ore_r02_c2").get("ok",false)),
        "realm 2 ore blocked before paid Mine Lv10")
    _check(not bool(bs.select_forest_material(state,forest.id,&"forest_r02_wood").get("ok",false)),
        "realm 2 wood blocked before paid Forest Lv10")

    var ids := state.disciples.keys()
    ids.sort()
    var workers: Dictionary = {}
    for kind in ["mine","linh_forest"]:
        var chosen: StringName = &""
        var group := &"mining_crew" if kind == "mine" else &"forestry_crew"
        var site: BuildingState = mine if kind == "mine" else forest
        for raw_id in ids:
            var actor: DiscipleState = state.disciples[raw_id]
            if workers.values().has(str(actor.id)) or actor.region_id != &"sect" \
                    or not actor.active_pve_encounter_id.is_empty():
                continue
            if not workforce.assign_group(state,actor.id,group):
                continue
            if not workforce.assign_worksite(state,actor.id,site.id):
                continue
            if not bs.can_disciple_work(state,site,actor):
                continue
            chosen = actor.id
            break
        _check(chosen != &"","real workforce slot for "+kind)
        if chosen == &"":
            _finish()
            return
        workers[kind] = str(chosen)

    var save := SaveService.new()
    for row in CASES:
        var kind := str(row["kind"])
        var id := StringName(row["resource"])
        var level := int(row["level"])
        var site_type := BuildingSystem.TYPE_MINE if kind == "mine" else BuildingSystem.TYPE_LINH_FOREST
        var site := bs.primary_building(state,site_type)
        # The existing paid upgrade system is independently tested. Source
        # selection and payout require this level; there is no QA code in game.
        site.level = maxi(site.level,level)
        state.building_event_count += 1
        var selected := bs.select_mine_ore(state,site.id,id) if kind == "mine" \
            else bs.select_forest_material(state,site.id,id)
        _check(bool(selected.get("ok",false)),"unlock and choose "+str(id))
        if not bool(selected.get("ok",false)):
            break
        var actor_id := StringName(workers[kind])
        var actor: DiscipleState = state.disciples[actor_id]
        var profession := BuildingSystem.PROF_MINING if kind == "mine" else BuildingSystem.PROF_FORESTRY
        var old_qty := warehouse.quantity(state,id)
        var old_xp := workforce.profession_xp(actor,profession)
        var old_stones := state.sect.spirit_stones
        var old_worker_stones := actor.spirit_stones
        var gain := workforce.expected_profession_xp_gain(state,actor,profession)
        var started := bs._start_resource_timer(state,site,actor,1.0,profession,gain)
        _check(bool(started.get("ok",false)) and bool(started.get("started",false)),
            "actual canonical timed job started: "+str(id))
        if not bool(started.get("ok",false)):
            break
        var frozen := bs.active_resource_timer_for_worker(state,actor_id)
        var job_id := str(frozen.get("job_id",""))
        var frozen_qty := int(frozen.get("output_quantity",0))
        _check(str(frozen.get("resource_id","")) == str(id) and frozen_qty > 0,
            "frozen output identity/quantity "+str(id))
        _check(warehouse.quantity(state,id) == old_qty,"no grant before delivery")
        var base := &"thanh_thiet" if kind == "mine" else &"linh_moc"
        var switched := bs.select_mine_ore(state,site.id,base) if kind == "mine" \
            else bs.select_forest_material(state,site.id,base)
        _check(bool(switched.get("ok",false)),
            "new selection must not cancel in-flight work")
        _check(str(bs.active_resource_timer_for_worker(state,actor_id).get("resource_id","")) == str(id),
            "selection change preserves previous job")
        _check(save.save_to_path(state,SAVE_PATH) == OK,
            "cold save during in-flight "+str(id))
        var loaded := save.load_from_path(SAVE_PATH)
        if loaded == null:
            _check(false,"cold reload failed for "+str(id))
            break
        state = loaded
        var pending := bs.active_resource_timer_for_worker(state,actor_id)
        _check(str(pending.get("resource_id","")) == str(id) \
                and int(pending.get("output_quantity",0)) == frozen_qty,
            "Save/Load retains pinned output and qty")
        _check(warehouse.quantity(state,id) == old_qty,"cold load cannot advance payout")
        var finish := int(pending.get("finish_tick",state.tick))
        while state.tick <= finish:
            state.tick += 1
            bs.process_tick(state)
        var done: DiscipleState = state.disciples[actor_id]
        _check(warehouse.quantity(state,id) == old_qty+frozen_qty,
            "exact once delivery into canonical Warehouse "+str(id))
        _check(is_equal_approx(workforce.profession_xp(done,profession),old_xp+gain),
            "one paid profession EXP award "+str(id))
        _check(bs.active_resource_timer_for_worker(state,actor_id).is_empty(),
            "job removed after delivery")
        var receipt_id := "wage:"+job_id
        var wage: Dictionary = state.sect.economy_a_receipts.get(receipt_id,{})
        _check(str(wage.get("worker_id","")) == str(actor_id),
            "durable exact-once wage receipt exists")
        _check(state.sect.spirit_stones == old_stones-int(wage.get("paid",0)) \
                and done.spirit_stones == old_worker_stones+int(wage.get("paid",0)),
            "wage is Sect-to-person transfer, never minted")
        bs.process_tick(state)
        _check(warehouse.quantity(state,id) == old_qty+frozen_qty \
                and is_equal_approx(workforce.profession_xp(done,profession),old_xp+gain),
            "same-tick replay cannot duplicate units or XP")
        _check(state.sect.economy_a_receipts.has(receipt_id) \
                and state.sect.economy_a_receipts[receipt_id] == wage,
            "wage receipt unchanged after redundant tick")
        _check(bs.validate_invariants(state).is_empty(),
            "building invariants accept earned selected resource")
        _check(warehouse.validate_invariants(state).is_empty(),
            "canonical Warehouse invariant accepts preserved material")
    _finish()

func _finish() -> void:
    print("SX07B PRESERVED SOURCE JOB/SAVE %d checks, %d failures" % [checks,failures])
    _cleanup()
    quit(1 if failures > 0 else 0)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var location := SAVE_PATH+suffix
        if FileAccess.file_exists(location):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(location))
