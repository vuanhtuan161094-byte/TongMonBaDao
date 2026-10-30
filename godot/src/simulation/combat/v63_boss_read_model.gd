class_name V63BossReadModel
extends RefCounted

# D1: preview-only definitions. Does not spawn an actor or create combat events.
static func get_boss(data: Dictionary, boss_id: String) -> Dictionary:
    return V63ContentRegistry.lookup_boss(data, boss_id)

static func can_spawn(_boss_id: String) -> bool:
    return false

static func can_award_loot(_boss_id: String) -> bool:
    return false
