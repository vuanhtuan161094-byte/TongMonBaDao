extends SceneTree

# V5.7 P0: headless correctness test of large-roster worksite indexing.
# Uses test-only BuildingStates, never grants items, wages or production rewards.
const SAVE_PATH := "user://v57_worksite_scale_480.json"
const TARGET_ROSTER := 480
const TYPES := [
    BuildingSystem.TYPE_MINE, BuildingSystem.TYPE_LINH_FOREST,
    BuildingSystem.TYPE_SPIRIT_FIELD, BuildingSystem.TYPE_ALCHEMY_HALL
]
const GROUPS := [
    &"mining_crew", &"forestry_crew",
    &"herbalism_crew", &"alchemy_crew"
]

func _init() -> void:
    call_deferred("_run")

func _reference(state: SimulationState, system: BuildingSystem, site: BuildingState) -> Array[StringName]:
    var result: Array[StringName] = []
    var primary := system.primary_building(state, site.building_type)
    var ids := state.disciples.keys()
    ids.sort()
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        if disciple.work_group_id != site.worker_group_id:
            continue
        if disciple.worksite_building_id == site.id or (
            disciple.worksite_building_id == &"" and primary != null and primary.id == site.id
        ):
            result.append(disciple.id)
    return result

func _check_all(state: SimulationState, system: BuildingSystem) -> bool:
    for site in state.buildings.values():
        if not (site is BuildingState) or site.worker_group_id == &"":
            continue
        var actual := system.assigned_worker_ids(state, site)
        var expected := _reference(state, system, site)
        if actual != expected:
            _fail("assigned list drift at "+str(site.id))
            return false
        var active := system.active_worker_ids(state, site)
        var slots := system.worker_slots(site)
        var expected_active: Array[StringName] = []
        for i in range(mini(expected.size(), slots)):
            expected_active.append(expected[i])
        if active != expected_active:
            _fail("active slot selection drift at "+str(site.id))
            return false
    return true

func _run() -> void:
    _cleanup()
    var state := P37Factory.create_state(570480)
    var system := BuildingSystem.new()
    var workforce := WorkforceSystem.new()
    state.sect.workforce_enabled = true
    # QA-only additional producer identities; this test does not pretend the
    # production-annex construction economy or map UI is implemented.
    for kind in TYPES:
        for ordinal in range(2, 10):
            var site := system.create_building(kind, ordinal)
            if site == null:
                _fail("cannot instantiate test production site")
                return
            state.buildings[str(site.id)] = site
    state.building_event_count += 1
    var sequence := 0
    while state.disciples.size() < TARGET_ROSTER:
        var key := StringName("v57_scale_%04d" % sequence)
        var disciple := DiscipleState.new({"id":str(key), "name":str(key)})
        var group_index := sequence % TYPES.size()
        disciple.work_group_id = GROUPS[group_index]
        if sequence % 7 != 0:
            disciple.worksite_building_id = StringName("%s_%03d" % [str(TYPES[group_index]), 2 + sequence % 8])
        state.disciples[key] = disciple
        sequence += 1
    state.sect.disciple_capacity = TARGET_ROSTER
    if state.disciples.size() != TARGET_ROSTER or not _check_all(state, system):
        _fail("initial 480-actor index mismatch")
        return

    # Official assignment mutation must invalidate the per-minute index.
    var moved := false
    for raw_id in state.disciples.keys():
        var candidate: DiscipleState = state.disciples[raw_id]
        if candidate.work_group_id == &"alchemy_crew" and str(candidate.id).begins_with("v57_scale"):
            moved = workforce.assign_worksite(state, candidate.id, &"alchemy_hall_009")
            break
    if not moved or not _check_all(state, system):
        _fail("same-minute reassignment was stale")
        return

    # Creation of a new worksite and a new minute must both rebuild safely.
    var new_site := system.create_building(BuildingSystem.TYPE_MINE, 10)
    state.buildings[str(new_site.id)] = new_site
    state.building_event_count += 1
    if not _check_all(state, system):
        return
    state.tick += 1
    if not _check_all(state, system):
        return

    # Reload must use new object state identity and preserve all assignments.
    var saver := SaveService.new()
    if saver.save_to_path(state, SAVE_PATH) != OK:
        _fail("480-disciple cold save failed")
        return
    var loaded := saver.load_from_path(SAVE_PATH)
    if loaded == null or loaded.disciples.size() != TARGET_ROSTER:
        _fail("480-disciple cold reload failed")
        return
    if not _check_all(loaded, system):
        return
    _cleanup()
    print("V57 WORKSITE INDEX 480 + REASSIGN + MULTI-SITE + SAVE/LOAD PASS")
    quit(0)

func _fail(message: String) -> void:
    push_error("V57 WORKSITE 480 FAIL: "+message)
    _cleanup()
    quit(1)

func _cleanup() -> void:
    for suffix in ["",".tmp",".bak"]:
        var file := SAVE_PATH+suffix
        if FileAccess.file_exists(file):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
