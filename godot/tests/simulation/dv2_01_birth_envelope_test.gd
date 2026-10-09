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
    if not DiscipleBirthCatalogueV2.valid_catalogue():
        _fail("The approved V2 birth catalogue has invalid IDs or conflict pairs.")
        return
    for layer in DiscipleBirthProfileV2.UNINITIALIZED_LAYERS:
        var row: Dictionary = profile["layers"][layer]
        if not bool(row.get("initialized", false)):
            _fail("Approved V2 birth layer '" + layer + "' was not generated.")
            return
    var birth_roots: Dictionary = profile["layers"]["spiritual_root"]["birth_values"]
    if birth_roots.size() < 1 or birth_roots.size() > 5:
        _fail("V2 root count is out of the 1..5 range.")
        return
    for purity in birth_roots.values():
        if int(purity) < 1 or int(purity) > 100:
            _fail("V2 root purity left the valid 1..100 range.")
            return
    var born_traits: Dictionary = profile["layers"]["traits"]
    if born_traits["visible"].size() < 1 or born_traits["visible"].size() > 3:
        _fail("V2 must generate 1..3 visible Traits.")
        return
    var all_trait_ids: Array = []
    for row in born_traits["visible"] + born_traits["latent"]:
        if row.has("grade") or row.has("level") or bool(row.get("active", true)):
            _fail("Ungraded V2 Traits may not activate without real consumers.")
            return
        var trait_id := str(row["id"])
        if all_trait_ids.has(trait_id) or DiscipleBirthCatalogueV2.conflicts_with(trait_id, all_trait_ids):
            _fail("Duplicate or incompatible V2 Traits were born together.")
            return
        all_trait_ids.append(trait_id)
    if born_traits["latent"].size() > 1:
        _fail("Ordinary V2 birth can have at most one latent Trait.")
        return
    if str(profile["layers"]["physique"].get("physique_id", "")) == "kiem_cot":
        _fail("Kiếm Cốt must not be eligible for birth yet.")
        return
    if str(profile["layers"]["destiny"].get("destiny_id", "")) == "kiem_tien_chuyen_the":
        _fail("Destiny birth override was not specified; identity may not be born.")
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
    var original_bloodline: Dictionary = first.v2_birth_profile["layers"]["bloodline"].duplicate(true)
    disciple.v2_birth_profile["layers"]["bloodline"] = {"initialized":true,"bloodline_id":"none"}
    if first.v2_birth_profile["layers"]["bloodline"] != original_bloodline:
        _fail("Recruitment copied V2 identity by reference.")
        return
    if disciple.v2_birth_profile["layers"]["bloodline"] == original_bloodline and str(original_bloodline.get("bloodline_id", "")) != "none":
        _fail("Test failed to mutate the disciple layer.")
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

    # REAL normal recruitment entry point: opt-in candidate must keep the V2 birth
    # profile while the old P2 per-sect identity maps must not gain another roll.
    var generated := RecruitmentSystem.new().generate_candidate(state, source)
    if generated == null or generated.v2_birth_profile.is_empty():
        _fail("Real V2 RecruitmentSystem generation omitted congenital identity.")
        return
    if not DiscipleBirthProfileV2.valid_envelope(generated.v2_birth_profile):
        _fail("Normal recruitment did not produce a valid V2 birth profile.")
        return
    if state.sect.disciple_trait_profiles.has(str(generated.id)):
        _fail("Normal V2 birth triggered the duplicate P2 Trait roll.")
        return
    if state.sect.bloodline_profiles.has(str(generated.id)):
        _fail("Normal V2 birth triggered the duplicate P2 Bloodline roll.")
        return
    if state.sect.physique_profiles.has(str(generated.id)):
        _fail("Normal V2 birth triggered the duplicate P2 Physique roll.")
        return
    var talent_row: Dictionary = generated.v2_birth_profile["layers"]["profession_talent"]["talents"]
    for talent_id in talent_row.keys():
        if not WorkforceSystem.PROFESSION_TRAITS.has(str(talent_id)):
            _fail("Invalid duplicated profession talent in new V2 profile.")
            return
        if int(talent_row[talent_id]) != int(generated.profession_trait_grades.get(str(talent_id),1)):
            _fail("V2 profession talent grade diverged after legacy P3.7 integration.")
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
    print("DV2-01B OPT-IN FULL INNATE BIRTH TEST PASS")
    quit(0)

func _cleanup() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _fail(message: String) -> void:
    _cleanup()
    push_error(message)
    quit(1)
