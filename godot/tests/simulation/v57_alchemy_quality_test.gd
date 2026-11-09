extends SceneTree

# V5.7 Q1-Q4 craft mode; live stock only, frozen in-flight output per job.
const SAVE_PATH := "user://v57_alchemy_quality_save.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(570012)
    var buildings := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    var warehouse := WarehouseSystem.new()
    var hall := buildings.primary_building(state,BuildingSystem.TYPE_ALCHEMY_HALL)
    if hall == null:
        _fail("alchemy hall missing")
        return
    var recipe := MedicineCatalogueV2.recipe_id(MedicineCatalogueV2.FAMILY_TUVI,1)
    if not buildings.set_alchemy_recipe(state,hall.id,recipe):
        _fail("cannot select authored graded recipe")
        return
    var actor: DiscipleState = null
    for raw in state.disciples.values():
        actor = raw
        break
    if actor == null or not workforce.assign_group(state,actor.id,&"alchemy_crew")             or not workforce.assign_worksite(state,actor.id,hall.id):
        _fail("cannot assign real alchemist")
        return
    hall.level = 20
    state.building_event_count += 1
    actor.profession_xp["alchemy"] = 2400.0
    if workforce.profession_level_for_state(state,actor,WorkforceSystem.PROF_ALCHEMY) < 10:
        _fail("profession level fixture invalid")
        return
    for key in ["thanh_linh_thao","linh_coc","huyen_thiet","linh_tuy","tu_van_thao","tinh_lang_bi","linh_moc","thanh_thiet"]:
        if not warehouse.add(state,StringName(key),10):
            _fail("QA ingredient provisioning failed: "+key)
            return
    var quality := buildings.set_alchemy_quality(state,hall.id,4)
    if not bool(quality.get("ok",false)):
        _fail("Q4 selection failed")
        return
    var ready := buildings.alchemy_can_start(state,actor)
    if not bool(ready.get("ok",false)) or int(ready["plan"].get("output_quantity",0)) != 39:
        _fail("Q4 readiness or profession batch bonus incorrect")
        return
    var q4 := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_TUVI,1,4)
    var before := warehouse.quantity(state,q4)
    var launched := buildings.perform_alchemy_step(state,actor,10,1.0,10.0)
    if not bool(launched.get("ok",false)) or str(launched["job"]["output_resource_id"]) != str(q4):
        _fail("Q4 job failed or wrong product identity")
        return
    if not buildings.set_alchemy_quality(state,hall.id,1).get("ok",false):
        _fail("future-job quality selection failed")
        return
    for i in range(4):
        state.tick += 1
        buildings.process_tick(state)
    if warehouse.quantity(state,q4) != before+39:
        _fail("in-flight Q4 job was altered by selecting Q1")
        return
    var q1 := MedicineCatalogueV2.item_id(MedicineCatalogueV2.FAMILY_TUVI,1,1)
    var q1_before := warehouse.quantity(state,q1)
    var second := buildings.perform_alchemy_step(state,actor,10,1.0,10.0)
    if not bool(second.get("ok",false)):
        _fail("Q1 job rejected")
        return
    for i in range(4):
        state.tick += 1
        buildings.process_tick(state)
    if warehouse.quantity(state,q1) != q1_before+39:
        _fail("Q1 output not delivered")
        return
    var save := SaveService.new()
    if save.save_to_path(state,SAVE_PATH) != OK:
        _fail("save failed")
        return
    var loaded := save.load_from_path(SAVE_PATH)
    if loaded == null or warehouse.quantity(loaded,q1) != warehouse.quantity(state,q1)             or warehouse.quantity(loaded,q4) != warehouse.quantity(state,q4):
        _fail("cold reload lost graded output")
        return
    var loaded_hall := buildings.primary_building(loaded,BuildingSystem.TYPE_ALCHEMY_HALL)
    if loaded_hall == null or int(loaded_hall.production_state.get("v57_selected_quality",-1)) != 1:
        _fail("quality choice lost on cold reload")
        return
    _cleanup()
    print("V57 ALCHEMY Q1/Q4 36+PROF BONUS + SAVE PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error("V57 QUALITY FAIL: "+message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var path := SAVE_PATH+suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
