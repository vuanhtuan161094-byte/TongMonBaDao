extends SceneTree

var ui: Control
var state: SimulationState
var resolver := LivingCueResolver.new()
var tracker := LivingCueTracker.new()
var cultivation := CultivationSystem.new()
var equipment := EquipmentSystem.new()

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var packed_scene := load("res://scenes/p3/p3_2_landscape_sect.tscn") as PackedScene
    if packed_scene == null:
        _fail("P3.5 core could not load live map scene.")
        return

    ui = packed_scene.instantiate() as Control
    root.add_child(ui)
    await process_frame

    state = ui.get("state") as SimulationState
    if state == null or state.disciples.is_empty():
        _fail("P3.5 core requires live SimulationState with disciples.")
        return

    var ids: Array = state.disciples.keys()
    ids.sort()
    var target: DiscipleState = state.disciples[StringName(ids[0])]

    var readonly_ok := _verify_resolver_read_only()
    if not readonly_ok:
        return
    var health_ok := _verify_health_and_fatigue(target)
    if not health_ok:
        return
    var breakthrough_ok := _verify_breakthrough_ready(target)
    if not breakthrough_ok:
        return
    var danger_ok := _verify_outside_danger(target)
    if not danger_ok:
        return
    var building_ok := _verify_building_conditions(target)
    if not building_ok:
        return
    var selection_ok := _verify_selection_is_bounded_and_deterministic()
    if not selection_ok:
        return
    var identity_ok := _verify_hidden_identity_does_not_change_cues(target)
    if not identity_ok:
        return
    var tracker_ok := _verify_transient_tracker(target)
    if not tracker_ok:
        return

    print("P3.5 LIVING CUE CORE TEST PASS")
    ui.queue_free()
    await process_frame
    quit(0)

func _verify_resolver_read_only() -> bool:
    var before := state.to_dict().duplicate(true)
    resolver.resolve_state_cues(state, cultivation, equipment)
    var after := state.to_dict().duplicate(true)
    if before != after:
        return _fail("LivingCueResolver mutated SimulationState.")
    return true

func _verify_health_and_fatigue(disciple: DiscipleState) -> bool:
    _normalize_disciple_for_state_test(disciple)
    disciple.hp = disciple.max_hp * 0.50
    disciple.stamina = 20.0
    var cues := resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "disciple_injured", disciple.id):
        return _fail("HP < 72% did not produce Bị thương.")
    if _has_cue(cues, "disciple_tired", disciple.id):
        return _fail("Mệt was not suppressed by Bị thương on the same disciple.")

    disciple.hp = disciple.max_hp
    disciple.stamina = 20.0
    cues = resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "disciple_tired", disciple.id):
        return _fail("Stamina < 42 did not produce Mệt.")
    return true

func _verify_breakthrough_ready(disciple: DiscipleState) -> bool:
    _normalize_disciple_for_state_test(disciple)
    disciple.cultivation_stage_index = 0
    disciple.cultivation_progress = cultivation.required_progress(disciple)
    disciple.next_breakthrough_tick = state.tick
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    if not cultivation.can_breakthrough(state, disciple):
        return _fail("Test setup could not make disciple breakthrough-ready.")
    var cues := resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "disciple_breakthrough_ready", disciple.id):
        return _fail("can_breakthrough() did not produce actionable cue.")
    return true

func _verify_outside_danger(disciple: DiscipleState) -> bool:
    _normalize_disciple_for_state_test(disciple)
    disciple.region_id = &"p3_5_test_region"
    disciple.hp = disciple.max_hp
    disciple.stamina = 22.0
    var cues := resolver.resolve_state_cues(state, cultivation, equipment)
    var cue := _find_cue(cues, "disciple_danger", disciple.id)
    if cue.is_empty():
        return _fail("Outside stamina <= 22 did not produce Nguy hiểm.")
    if int(cue.get("severity", -1)) != LivingCueResolver.SEVERITY_CRITICAL:
        return _fail("Outside danger cue is not S0 critical.")

    disciple.stamina = 100.0
    disciple.hp = disciple.max_hp * disciple.retreat_hp_ratio()
    cues = resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "disciple_danger", disciple.id):
        return _fail("Personal retreat HP threshold did not produce Nguy hiểm.")
    return true

func _verify_building_conditions(target: DiscipleState) -> bool:
    for disciple_value in state.disciples.values():
        var disciple: DiscipleState = disciple_value
        _normalize_disciple_for_state_test(disciple)
        disciple.work_group_id = &""

    state.sect.medicine_stock = 0
    var cues := resolver.resolve_state_cues(state, cultivation, equipment)
    if _has_cue(cues, "medicine_empty"):
        return _fail("Medicine stock 0 alerted even though nobody needed healing.")

    target.hp = target.max_hp * 0.50
    cues = resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "medicine_empty"):
        return _fail("Medicine stock 0 + injured disciple did not alert Medicine Hall.")

    if state.disciples.size() > 1:
        state.sect.lodging_capacity = state.disciples.size() - 1
        cues = resolver.resolve_state_cues(state, cultivation, equipment)
        if not _has_cue(cues, "lodging_overloaded"):
            return _fail("Overcapacity did not alert Residence.")

    cues = resolver.resolve_state_cues(state, cultivation, equipment)
    if not _has_cue(cues, "mine_missing_people"):
        return _fail("Empty mining_crew did not produce Thiếu người.")
    if not _has_cue(cues, "forge_missing_people"):
        return _fail("Empty forge_hall did not produce Thiếu người.")

    target.work_group_id = &"forge_hall"
    for material_id in EquipmentSystem.MATERIAL_NAMES.keys():
        state.sect.forge_materials[str(material_id)] = 0
    cues = resolver.resolve_state_cues(state, cultivation, equipment)
    if _has_cue(cues, "forge_missing_people"):
        return _fail("Forge still reported missing people after real group assignment.")
    if not _has_cue(cues, "forge_missing_materials"):
        return _fail("Staffed Forge with no craftable recipe did not report missing materials.")
    return true

func _verify_selection_is_bounded_and_deterministic() -> bool:
    var candidates := resolver.resolve_state_cues(state, cultivation, equipment)
    var first := resolver.select_visible(candidates, 3)
    var second := resolver.select_visible(candidates, 3)
    if first.size() > 3:
        return _fail("Visible cue selection exceeded max 3.")
    if _keys(first) != _keys(second):
        return _fail("Cue ordering is not deterministic.")

    var targets: Dictionary = {}
    for cue in first:
        var target_key := "%s:%s" % [str(cue.get("target_kind", "")), str(cue.get("target_id", ""))]
        if targets.has(target_key):
            return _fail("More than one primary cue was selected for the same target.")
        targets[target_key] = true
    return true

func _verify_hidden_identity_does_not_change_cues(disciple: DiscipleState) -> bool:
    _normalize_disciple_for_state_test(disciple)
    disciple.stamina = 20.0
    var before := _keys(resolver.resolve_state_cues(state, cultivation, equipment))

    disciple.latent_identity_seed += 99991
    disciple.profile_seed += 77
    disciple.sex_id = &"p3_5_hidden_test"
    disciple.profession_traits = ["forge_talent", "miner_instinct", "diligent"]
    var after := _keys(resolver.resolve_state_cues(state, cultivation, equipment))

    if before != after:
        return _fail("Hidden identity/trait fields changed living-cue output.")
    return true

func _verify_transient_tracker(disciple: DiscipleState) -> bool:
    _normalize_disciple_for_state_test(disciple)
    disciple.metrics["mining_completions"] = 0
    disciple.metrics["forging_completions"] = 0
    disciple.metrics["breakthrough_successes"] = 0
    disciple.metrics["breakthrough_failures"] = 0
    disciple.metrics["heals"] = 0
    tracker.seed_from_state(state)

    disciple.metrics["mining_completions"] = 1
    var events := tracker.observe(state, 1000)
    if not _has_cue(events, "mining_complete", disciple.id):
        return _fail("Mining completion delta did not create transient cue.")
    var first_count := _count_cue(events, "mining_complete", disciple.id)
    events = tracker.observe(state, 1100)
    if _count_cue(events, "mining_complete", disciple.id) != first_count:
        return _fail("Unchanged mining metric re-triggered duplicate cue.")

    disciple.metrics["breakthrough_failures"] = 1
    disciple.last_breakthrough_outcome = &"failure"
    events = tracker.observe(state, 1200)
    var failure := _find_cue(events, "breakthrough_failure", disciple.id)
    if failure.is_empty() or int(failure.get("severity", -1)) != LivingCueResolver.SEVERITY_CRITICAL:
        return _fail("Breakthrough failure delta did not create S0 transient cue.")

    disciple.metrics["breakthrough_successes"] = 1
    disciple.last_breakthrough_outcome = &"success"
    events = tracker.observe(state, 1300)
    if not _has_cue(events, "breakthrough_success", disciple.id):
        return _fail("Breakthrough success delta did not create info cue.")

    disciple.metrics["heals"] = 1
    events = tracker.observe(state, 1400)
    if not _has_cue(events, "heal_complete", disciple.id):
        return _fail("Heal metric delta did not create Đã trị thương cue.")
    return true

func _normalize_disciple_for_state_test(disciple: DiscipleState) -> void:
    disciple.region_id = &"sect"
    disciple.target_region_id = &""
    disciple.hp = disciple.max_hp
    disciple.stamina = 100.0
    disciple.next_breakthrough_tick = maxi(disciple.next_breakthrough_tick, state.tick + 1000)
    disciple.cultivation_progress = 0.0

func _has_cue(cues: Array[Dictionary], cue_id: String, target_id: StringName = &"") -> bool:
    return not _find_cue(cues, cue_id, target_id).is_empty()

func _find_cue(cues: Array[Dictionary], cue_id: String, target_id: StringName = &"") -> Dictionary:
    for cue in cues:
        if str(cue.get("cue_id", "")) != cue_id:
            continue
        if target_id != &"" and StringName(cue.get("target_id", "")) != target_id:
            continue
        return cue
    return {}

func _count_cue(cues: Array[Dictionary], cue_id: String, target_id: StringName) -> int:
    var count := 0
    for cue in cues:
        if str(cue.get("cue_id", "")) == cue_id and StringName(cue.get("target_id", "")) == target_id:
            count += 1
    return count

func _keys(cues: Array[Dictionary]) -> Array[String]:
    var result: Array[String] = []
    for cue in cues:
        result.append(str(cue.get("stable_key", "")))
    return result

func _fail(message: String) -> bool:
    push_error(message)
    if ui != null:
        ui.queue_free()
    quit(1)
    return false
