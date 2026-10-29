class_name V63FeatureGates
extends RefCounted

# D1: every new-content feature is explicitly OFF. No live consumer is wired.
const DEFAULT_FLAGS := {
    "content_registry": false,
    "skill_successors": false,
    "boss_encounters": false,
    "sect_codex": false
}

static func is_enabled(flag_id: String, preview_overrides: Dictionary = {}) -> bool:
    if not DEFAULT_FLAGS.has(flag_id):
        return false
    return bool(preview_overrides.get(flag_id, DEFAULT_FLAGS[flag_id]))

static func all_disabled() -> bool:
    for key in DEFAULT_FLAGS.keys():
        if bool(DEFAULT_FLAGS[key]):
            return false
    return true
