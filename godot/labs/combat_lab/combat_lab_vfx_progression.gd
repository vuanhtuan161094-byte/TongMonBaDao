extends RefCounted

# VFX-08: read-only cosmetic progression over APPROVED V6.3 combat.
# Do not add extra hits/targets/damage/DoT/casts as mastery levels rise.
# There is currently NO projectile_count-by-level authority in the catalogue.
const MAX_DECORATIVE_STRANDS := 8

static func mastery_for(actor: Dictionary, skill_id: String) -> int:
    var linked: Variant = actor.get("linked_disciple", null)
    if not (linked is DiscipleState):
        return 1
    var learned: Dictionary = linked.v63_learned_skill_nodes
    if not learned.has(skill_id):
        return 1
    var record: Dictionary = learned.get(skill_id, {})
    return maxi(1, int(record.get("level", 1)))

static func profile_for(skill: Dictionary, level: int,
        stats: Dictionary, live_cues: int) -> Dictionary:
    var human := str(skill.get("generation", skill.get("tier", "human"))) == "human"
    var max_level := 12 if human else 3
    var verified_level := clampi(level, 1, max_level)
    var cast_haste := clampf(float(stats.get("cast_speed", 0.0)), -0.9, 2.0)
    var attack_haste := clampf(float(stats.get("attack_speed", 0.0)), -0.9, 2.0)
    var shape := str(skill.get("shape", "single_target"))
    # 5 -> 8 decorative strands across Human mastery I-XII for the FAN,
    # not extra projectiles. The authoritatively selected targets stay <=3.
    var fan_strands := 1
    if shape == "circle" and str(skill.get("slot", "")) in ["active", "ultimate"]:
        fan_strands = clampi(5 + floori(float(verified_level - 1) / 3.0),
            5, MAX_DECORATIVE_STRANDS)
    # Lower-cost VFX during 4v8/30-v-40 scenes; never fade hit/CC or the
    # truthful AoE ground perimeter. Only optional glints/motes are culled.
    var lod := 2 if live_cues < 14 else (1 if live_cues < 28 else 0)
    var visible_strands := fan_strands if lod > 0 else mini(fan_strands, 5)
    var visual_intensity := clampf(0.78 + 0.02 * float(verified_level - 1),
        0.75, 1.0)
    return {
        "mastery_level":verified_level,
        "cast_speed":cast_haste,
        "attack_speed":attack_haste,
        "decorative_strands":visible_strands,
        "lod":lod,
        "intensity":visual_intensity,
        "combat_projectiles":maxi(1, int(skill.get("projectile_count", 1))),
        "combat_target_limit":int(skill.get("target_limit", 1)),
        "combat_radius":float(skill.get("radius", 0.0))
    }

static func from_actor(actor: Dictionary, skill_id: String,
        definition: Dictionary, live_cues: int) -> Dictionary:
    if definition.is_empty():
        return {}
    var stats := V63HumanSkillCombatSystem.effective_attack_stats(
        actor, actor.get("stats", {}))
    return profile_for(definition, mastery_for(actor, skill_id), stats, live_cues)
