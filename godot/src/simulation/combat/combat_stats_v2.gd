class_name CombatStatsV2
extends RefCounted

# DV2-02 focused derived-stat authority, not a second gameplay encounter engine.
# Source values: fractions (0.10 means +10%; 0.05 pp means +5 percentage points).
# All active global sources must have an actual registered channel and mode.
const ELEMENTS := ["metal","wood","water","fire","earth","lightning","wind","ice","yang","nether"]
const CORE_CHANNELS := ["max_hp","attack","defense"]
const RATE_CHANNELS := ["move_speed","attack_speed","cast_speed","cooldown_recovery"]
const PP_CHANNELS := ["crit_chance","crit_resistance","defense_penetration","effect_hit","effect_resistance"]
const PRIMARY_CHANNELS := [
    "max_hp","attack","defense","move_speed","attack_speed","cast_speed",
    "cooldown_recovery","crit_chance","crit_damage","crit_resistance",
    "defense_penetration","effect_hit","effect_resistance","damage_reduction"
]
const REALM_BASE := {"max_hp":100.0,"attack":20.0,"defense":12.0}
const BODY_BASE := {"max_hp":90.0,"attack":3.0,"defense":7.0}

static func valid_source(source: Dictionary) -> bool:
    var source_id := str(source.get("source_id", ""))
    var channel := str(source.get("channel", ""))
    var mode := str(source.get("mode", ""))
    if source_id.is_empty() or not source.has("value"):
        return false
    var value := float(source.get("value", 0.0))
    if is_nan(value) or is_inf(value):
        return false
    if CORE_CHANNELS.has(channel):
        return ["flat","percent_add"].has(mode)
    if RATE_CHANNELS.has(channel):
        return mode == "percent_add"
    if PP_CHANNELS.has(channel):
        return mode == "percentage_points"
    if channel == "crit_damage":
        # +50% Crit Damage is +0.50 to its 1.50x multiplier, NOT ×1.50.
        return mode == "multiplier_add"
    if channel == "damage_reduction" or channel.begins_with("elemental_resistance/"):
        if channel.begins_with("elemental_resistance/") and not ELEMENTS.has(channel.get_slice("/", 1)):
            return false
        # Ordinary independent sources cannot silently confer true immunity.
        return mode == "remaining_reduction" and value >= 0.0 and value < 1.0
    return false

static func derive(
    cultivation_realm: int, cultivation_floor: int,
    body_realm: int, body_floor: int, current_potential: float,
    sources: Array = []
) -> Dictionary:
    if cultivation_realm < 1 or cultivation_realm > 30 or body_realm < 1 or body_realm > 30:
        return {"ok":false,"reason":"invalid_realm"}
    if cultivation_floor < 1 or cultivation_floor > 10 or body_floor < 1 or body_floor > 10:
        return {"ok":false,"reason":"invalid_floor"}
    if is_nan(current_potential) or is_inf(current_potential) or current_potential < 0.0:
        return {"ok":false,"reason":"invalid_potential"}

    var ordered: Array = sources.duplicate(true)
    ordered.sort_custom(func(a, b): return str(a.get("source_id", "")) < str(b.get("source_id", "")))
    var seen: Dictionary = {}
    var flat: Dictionary = {}
    var pct: Dictionary = {}
    var pp: Dictionary = {}
    var remaining: Dictionary = {}
    var contributions: Array = []
    for entry in ordered:
        if not (entry is Dictionary) or not valid_source(entry):
            return {"ok":false,"reason":"unregistered_or_invalid_source"}
        var src: Dictionary = entry
        var channel := str(src["channel"])
        var source_id := str(src["source_id"])
        var key := source_id + ":" + channel
        if seen.has(key):
            return {"ok":false,"reason":"duplicate_source_channel"}
        seen[key] = true
        # A source may be recorded yet inactive; it must NEVER give a modifier.
        if not bool(src.get("enabled", true)):
            continue
        var value := float(src["value"])
        var mode := str(src["mode"])
        contributions.append(src.duplicate(true))
        if mode == "flat":
            flat[channel] = float(flat.get(channel,0.0)) + value
        elif mode == "percent_add":
            pct[channel] = float(pct.get(channel,0.0)) + value
        elif mode == "percentage_points" or mode == "multiplier_add":
            pp[channel] = float(pp.get(channel,0.0)) + value
        elif mode == "remaining_reduction":
            remaining[channel] = float(remaining.get(channel,1.0)) * (1.0-value)

    var realm_growth := pow(1.65, cultivation_realm-1) * pow(1.03, cultivation_floor-1)
    var body_growth := pow(1.65, body_realm-1) * pow(1.03, body_floor-1)
    var potential_factor := 1.0 + 0.0005*current_potential
    var stats: Dictionary = {}
    var core_breakdown: Dictionary = {}
    for channel in CORE_CHANNELS:
        var realm_piece := float(REALM_BASE[channel]) * realm_growth
        var body_piece := float(BODY_BASE[channel]) * body_growth
        var core := (realm_piece + body_piece) * potential_factor
        var before_percent := core + float(flat.get(channel,0.0))
        var final_stat := before_percent * (1.0 + float(pct.get(channel,0.0)))
        stats[channel] = maxf(1.0, final_stat) if channel == "max_hp" else maxf(0.0, final_stat)
        core_breakdown[channel] = {
            "realm":realm_piece,"body":body_piece,"potential_factor":potential_factor,
            "core_after_potential":core,"unrelated_flat":float(flat.get(channel,0.0)),
            "same_channel_percent":float(pct.get(channel,0.0))
        }
    stats["move_speed"] = maxf(0.0, 1.0 + float(pct.get("move_speed",0.0)))
    stats["attack_speed"] = float(pct.get("attack_speed",0.0))
    stats["cast_speed"] = float(pct.get("cast_speed",0.0))
    stats["cooldown_recovery"] = float(pct.get("cooldown_recovery",0.0))
    stats["crit_chance"] = clampf(0.05 + float(pp.get("crit_chance",0.0)),0.0,1.0)
    stats["crit_damage"] = maxf(1.0, 1.50 + float(pp.get("crit_damage",0.0)))
    stats["crit_resistance"] = clampf(float(pp.get("crit_resistance",0.0)),0.0,1.0)
    stats["defense_penetration"] = clampf(float(pp.get("defense_penetration",0.0)),0.0,1.0)
    stats["effect_hit"] = float(pp.get("effect_hit",0.0))
    stats["effect_resistance"] = float(pp.get("effect_resistance",0.0))
    stats["damage_reduction"] = 1.0 - float(remaining.get("damage_reduction",1.0))

    var resistances: Dictionary = {}
    for element in ELEMENTS:
        resistances[element] = 1.0 - float(remaining.get("elemental_resistance/"+element,1.0))

    for channel in PRIMARY_CHANNELS:
        if is_nan(float(stats[channel])) or is_inf(float(stats[channel])):
            return {"ok":false,"reason":"nonfinite_derived_stat"}
    return {
        "ok":true,"stats":stats,"resistances":resistances,
        "core_breakdown":core_breakdown,"applied_sources":contributions
    }

static func rescale_current_hp(old_hp: float, old_max_hp: float, new_max_hp: float) -> float:
    if old_max_hp <= 0.0 or new_max_hp <= 0.0:
        return 0.0
    return clampf(old_hp/old_max_hp,0.0,1.0) * new_max_hp

static func effective_interval(base_interval: float, rate_bonus: float) -> float:
    # A -100% or worse rate cannot be used to create negative/zero intervals.
    if base_interval <= 0.0 or rate_bonus <= -1.0:
        return -1.0
    return base_interval / (1.0 + rate_bonus)

static func effective_crit_chance(attacker: Dictionary, target: Dictionary) -> float:
    return clampf(
        float(attacker.get("crit_chance",0.05)) -
        float(target.get("crit_resistance",0.0)),0.0,1.0
    )

static func ordinary_status_chance(
    base_chance: float, attacker: Dictionary, target: Dictionary,
    guaranteed: bool = false, immune: bool = false
) -> float:
    if immune:
        return 0.0
    if guaranteed:
        return 1.0
    return clampf(
        base_chance + float(attacker.get("effect_hit",0.0)) -
        float(target.get("effect_resistance",0.0)),0.0,1.0
    )

static func resolve_direct_hit(
    attacker_stats: Dictionary, target_stats: Dictionary,
    target_resistances: Dictionary, skill_ratio: float = 1.0,
    was_crit: bool = false, element: String = "",
    elemental_matchup_factor: float = 1.0, can_crit: bool = true
) -> Dictionary:
    # This computes a single authorized packet; RNG/skill legality belongs
    # to CombatSystem. It does not consume legacy combat_power.
    if skill_ratio < 0.0 or elemental_matchup_factor < 0.0:
        return {"ok":false,"reason":"invalid_damage_packet"}
    if not element.is_empty() and not ELEMENTS.has(element):
        return {"ok":false,"reason":"unknown_element"}
    var attack := maxf(float(attacker_stats.get("attack",0.0)),0.0)
    var defense := maxf(float(target_stats.get("defense",0.0)),0.0)
    var penetration := clampf(float(attacker_stats.get("defense_penetration",0.0)),0.0,1.0)
    var effective_defense := defense * (1.0-penetration)
    var before_defense := attack*skill_ratio
    var critical := was_crit and can_crit
    if critical:
        before_defense *= maxf(float(attacker_stats.get("crit_damage",1.50)),1.0)
    var defense_factor := 0.0
    if attack > 0.0:
        var k := 2.0*attack
        defense_factor = k/(k+effective_defense)
    var damage := before_defense * defense_factor * elemental_matchup_factor
    if not element.is_empty():
        damage *= 1.0-clampf(float(target_resistances.get(element,0.0)),0.0,1.0)
    damage *= 1.0-clampf(float(target_stats.get("damage_reduction",0.0)),0.0,1.0)
    return {
        "ok":true,"damage":maxf(0.0,damage),"critical":critical,
        "effective_defense":effective_defense,
        "defense_factor":defense_factor,"predefense_damage":before_defense
    }
