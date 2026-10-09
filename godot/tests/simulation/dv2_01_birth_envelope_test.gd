extends SceneTree

const TEST_SEED := 26091009
const SAVE_PATH := "user://dv2_01_birth_envelope_test.json"

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var original_state := P37Factory.create_state(TEST_SEED)
    if original_state.sect.disciple_v2_birth_enabled:
        _fail("DV2-01 incorrectly enabled V2 birth for the P3.7 locked baseline.")
        return

    var source := DiscipleGeneratorV2.SOURCE_ORDINARY
    var generator := DiscipleGeneratorOpenPoints.new()
    var old_candidate := generator.generate_candidate(original_state, source, 205)
    if old_candidate == null or not old_candidate.v2_birth_profile.is_empty():
        _fail("Default-off V2 birth modified the old candidate generation.")
        return

    var state := P37Factory.create_state(TEST_SEED)
    state.sect.disciple_v2_birth_enabled = true
    var first := generator.generate_candidate(state, source, 205)
    var again := generator.generate_candidate(state, source, 205)
    if first == null or again == null:
        _fail("V2 envelope candidate generation returned null.")
        return
    if not DiscipleBirthProfileV2.valid_envelope(first.v2_birth_profile):
        _fail("V2 birth envelope is missing version/seed/layer initialization metadata.")
        return
    if first.to_dict() != again.to_dict():
        _fail("Same world seed/source/generation index did not reproduce the same person.")
        return

    var baseline_fields := first.to_dict()
    baseline_fields.erase("v2_birth_profile")
    if baseline_fields != old_candidate.to_dict():
        _fail("V2 envelope changed P3.7C1 quality, lục duy, root, name, or existing birth RNG.")
        return

    var profile := first.v2_birth_profile
    for layer in DiscipleBirthProfileV2.UNINITIALIZED_LAYERS:
        var row: Dictionary = profile["layers"][layer]
        if bool(row.get("initialized", true)) or row.has("value"):
            _fail("Unapproved birth layer '" + layer + "' is falsely initialized or selected.")
            return

    var seeds: Dictionary = profile["domain_seeds"]
    var known: Dictionary = {}
    for domain in DiscipleBirthProfileV2.DOMAINS:
        var seed_value := int(seeds[domain])
        if known.has(str(seed_value)):
            _fail("Two named birth domains got the same seed.")
            return
        known[str(seed_value)] = true

    # Verify the REAL RecruitmentSystem accept path, not only CandidateState.to_disciple().
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity, state.disciples.size() + 1)
    state.recruitment_candidates[first.id] = first
    var accepted: Dictionary = RecruitmentSystem.new().accept_candidate(state, first.id)
    if not bool(accepted.get("ok", false)):
        _fail("Real candidate acceptance failed: " + str(accepted.get("reason", "unknown")))
        return
    var disciple: DiscipleState = state.disciples.get(first.id)
    if disciple == null or disciple.v2_birth_profile != profile:
        _fail("Real recruitment discarded/changed the V2 birth envelope.")
        return
    # Explicit initialized+none is different from uninitialized.
    # Mutation of the recruited disciple must not mutate the original candidate.
    disciple.v2_birth_profile["layers"]["bloodline"] = {"initialized": true, "value": "none"}
    if bool(first.v2_birth_profile["layers"]["bloodline"]["initialized"]):
        _fail("Recruitment copied the birth profile by reference rather than by value.")
        return
    if first.v2_birth_profile["layers"]["traits"].has("value"):
        _fail("Trait identity leaked from an uninitialized pool.")
        return

    state.disciples[disciple.id] = disciple
    var save_error := SaveService.new().save_to_path(state, SAVE_PATH)
    if save_error != OK:
        _fail("V2 birth envelope could not be serialized.")
        return
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if loaded == null:
        _fail("V2 birth envelope save could not be loaded.")
        return
    if not loaded.sect.disciple_v2_birth_enabled:
        _fail("V2 birth opt-in flag was not persisted.")
        return
    var restored: DiscipleState = loaded.disciples.get(disciple.id)
    if restored == null or restored.v2_birth_profile != disciple.v2_birth_profile:
        print("DV2-01 EXPECTED: ", var_to_str(disciple.v2_birth_profile))
        print("DV2-01 ACTUAL: ", var_to_str(restored.v2_birth_profile) if restored != null else "missing disciple")
        _fail("The same visible/hidden V2 birth metadata was not preserved on load.")
        return
    if not DiscipleBirthProfileV2.valid_envelope(restored.v2_birth_profile):
        _fail("Loaded V2 birth envelope is invalid.")
        return

    var legacy := P37Factory.create_state(TEST_SEED)
    var legacy_path := "user://dv2_01_baseline_roundtrip.json"
    if SaveService.new().save_to_path(legacy, legacy_path) != OK:
        _fail("Legacy baseline save failed.")
        return
    var loaded_legacy := SaveService.new().load_from_path(legacy_path)
    if loaded_legacy == null or loaded_legacy.sect.disciple_v2_birth_enabled:
        _fail("Legacy baseline gained an unauthorized V2 birth flag on load.")
        return

    _cleanup()
    if FileAccess.file_exists(legacy_path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(legacy_path))
    print("DV2-01A OPT-IN BIRTH ENVELOPE TEST PASS")
    quit(0)

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> void:
    _cleanup()
    push_error(message)
    quit(1)
