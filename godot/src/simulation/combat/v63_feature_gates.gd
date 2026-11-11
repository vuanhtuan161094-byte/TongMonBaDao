class_name V63FeatureGates
extends RefCounted

# D1: every new-content feature is explicitly OFF; consumers require an explicit preview override.
const DEFAULT_FLAGS := {
    "content_registry": false,
    "skill_successors": false,
    "boss_encounters": false,
    "sect_codex": false,
    "technique_learning": false,
    "human_skill_combat": false,
    "divine_skill_combat": false,
    "poison_evolution_strict": false,
    "spiritual_root_v2": false,
    "sword_skill_combat": false,
    "blade_skill_combat": false,
    "spear_skill_combat": false,
    "dual_blade_skill_combat": false
}

static func is_enabled(flag_id: String, preview_overrides: Dictionary = {}) -> bool:
    if not DEFAULT_FLAGS.has(flag_id):
        return false
    return bool(preview_overrides.get(flag_id, DEFAULT_FLAGS[flag_id]))

# Explicit opt-in survives Save/Reload; no new gate is enabled for legacy saves.
# A single source of truth is shared by the UI and runtime/offline scheduler.
static func persisted_preview_overrides(state: SimulationState) -> Dictionary:
    if state == null or not state.sect.v63_archive_opt_in or not state.sect.v63_skill_combat_opt_in:
        return {}
    return {
        "sect_codex": true,
        "technique_learning": true,
        "human_skill_combat": true,
        "divine_skill_combat": true,
        "poison_evolution_strict": true,
        "skill_successors": true,
        "boss_encounters": true
    }

static func all_disabled() -> bool:
    for key in DEFAULT_FLAGS.keys():
        if bool(DEFAULT_FLAGS[key]):
            return false
    return true

