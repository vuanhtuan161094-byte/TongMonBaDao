extends SceneTree

# V6.5 preview flags are opt-in per canonical save, not globally enabled.
# The runtime must restore them before offline catch-up, without involving UI.
const SAVE_PATH := "user://v63_d8_preview_resume_gate_test.json"
const EXPECTED := [
    "sect_codex", "technique_learning", "human_skill_combat",
    "divine_skill_combat", "skill_successors", "boss_encounters"
]

func _init() -> void:
    call_deferred("_run")

func _check(value: bool, reason: String) -> bool:
    if value:
        return true
    push_error("V63 D8 PREVIEW RESUME FAIL: " + reason)
    _cleanup()
    quit(1)
    return false

func _cleanup() -> void:
    for suffix in ["", ".tmp", ".bak"]:
        var path: String = SAVE_PATH + suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check_enabled(overrides: Dictionary, context: String) -> bool:
    if not _check(overrides.size() == EXPECTED.size(), context + ": wrong gate count"):
        return false
    for flag in EXPECTED:
        if not _check(bool(overrides.get(flag, false)), context + ": missing " + flag):
            return false
    return true

func _run() -> void:
    _cleanup()
    if not _check(V63FeatureGates.all_disabled(),
            "default feature gates were enabled globally"):
        return

    var legacy := P37Factory.create_state(30102061)
    var legacy_owner := SimulationRuntimeOwnerV2.new()
    if not _check(bool(legacy_owner.attach(legacy, 1000).get("ok", false))
            and legacy_owner.scheduler.v63_preview_overrides.is_empty(),
            "legacy runtime unexpectedly opted into V6.5"):
        return
    legacy.sect.v63_archive_opt_in = true
    if not _check(V63FeatureGates.persisted_preview_overrides(legacy).is_empty(),
            "partial archive-only consent turned on combat"):
        return

    var state := P37Factory.create_state(30102062)
    state.sect.v63_archive_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    var owner := SimulationRuntimeOwnerV2.new()
    if not _check(bool(owner.attach(state, 1000).get("ok", false)),
            "runtime attach failed"):
        return
    if not _check_enabled(owner.scheduler.v63_preview_overrides, "attached owner"):
        return
    if not _check(owner.saves.save_to_path(state, SAVE_PATH) == OK,
            "isolated preview save failed"):
        return

    var restored_owner := SimulationRuntimeOwnerV2.new()
    var restored := restored_owner.load_from_path(SAVE_PATH, 1000)
    if not _check(bool(restored.get("ok", false)) and restored_owner.scheduler != null,
            "preview Save/Reload failed: " + str(restored)):
        return
    if not _check_enabled(restored_owner.scheduler.v63_preview_overrides, "restored owner"):
        return
    if not _check(V63HumanSkillCombatSystem.is_enabled(restored_owner.state,
            restored_owner.scheduler.v63_preview_overrides),
            "restored personal combat gate is unexpectedly OFF"):
        return
    if not _check(not V63HumanSkillCombatSystem.is_enabled(restored_owner.state, {}),
            "empty preview overrides must remain legacy gate-OFF"):
        return

    _cleanup()
    print("V63 D8 PREVIEW RESUME PASS: legacy_off=true persisted_owner_optin=true runtime_attach_reload=true")
    quit(0)
