class_name CombatContextEffectsV2
extends RefCounted

# DV2-02 contextual combat modifiers: never stored as core ATK or as birth stats.
# Only genuine tagged targets can consume these sources.
const TIERS := ["normal","elite","boss"]
const RACES := ["yeu_thu","linh_thu","yeu_thuc","quy_toc","ma_toc","nhan_toc"]
const BASE_FOLLOWUP_RATIO := 0.60 # PILOT, not an approved permanent balance constant

static func valid_source(source: Dictionary) -> bool:
    if str(source.get("source_id","")).is_empty() or not source.has("value"):
        return false
    var value := float(source.get("value",0.0))
    if is_nan(value) or is_inf(value):
        return false
    # Precondition logic that has no real owner must not be silently ignored.
    if source.has("scope") or source.has("condition") or source.has("filter"):
        return false
    var channel := str(source.get("channel",""))
    var mode := str(source.get("mode",""))
    if channel == "damage_vs_boss" or channel == "damage_vs_elite":
        return mode == "percent_add"
    if channel.begins_with("damage_vs_race/"):
        return mode == "percent_add" and channel.split("/").size() == 2 and RACES.has(channel.get_slice("/",1))
    if channel == "basic_followup_chance":
        return mode == "percentage_points"
    if channel == "basic_followup_damage":
        return mode == "percent_add"
    return false

static func resolve_context(sources: Array, target: Dictionary, attack_kind: String) -> Dictionary:
    var tier := str(target.get("tier",""))
    var race := str(target.get("race_id",""))
    if not TIERS.has(tier) or not RACES.has(race):
        return {"ok":false,"reason":"unknown_monster_tier_or_race"}
    if not ["basic","skill","dot","reflect","proc","summon"].has(attack_kind):
        return {"ok":false,"reason":"invalid_attack_kind"}
    var ordered := sources.duplicate(true)
    ordered.sort_custom(func(a,b): return (str(a.get("source_id",""))+":"+str(a.get("channel",""))) < (str(b.get("source_id",""))+":"+str(b.get("channel",""))))
    var seen: Dictionary = {}
    var applicable: Array = []
    var bonus := 0.0
    var followup_chance := 0.0
    var followup_damage_bonus := 0.0
    for entry in ordered:
        if not (entry is Dictionary) or not valid_source(entry):
            return {"ok":false,"reason":"invalid_context_source"}
        var source: Dictionary = entry
        var channel := str(source["channel"])
        var key := str(source["source_id"])+":"+channel
        if seen.has(key):
            return {"ok":false,"reason":"duplicate_context_source"}
        seen[key] = true
        if not bool(source.get("enabled",true)):
            continue
        var value := float(source["value"])
        if channel == "damage_vs_boss" and tier == "boss":
            bonus += value
            applicable.append(source.duplicate(true))
        elif channel == "damage_vs_elite" and tier == "elite":
            bonus += value
            applicable.append(source.duplicate(true))
        elif channel == "damage_vs_race/"+race:
            bonus += value
            applicable.append(source.duplicate(true))
        elif channel == "basic_followup_chance" and attack_kind == "basic":
            followup_chance += value
            applicable.append(source.duplicate(true))
        elif channel == "basic_followup_damage" and attack_kind == "basic":
            followup_damage_bonus += value
            applicable.append(source.duplicate(true))
    return {
        "ok":true,
        "outgoing_damage_factor":maxf(0.0,1.0+bonus),
        "basic_followup_chance":clampf(followup_chance,0.0,1.0) if attack_kind == "basic" else 0.0,
        "basic_followup_ratio":BASE_FOLLOWUP_RATIO*maxf(0.0,1.0+followup_damage_bonus) if attack_kind == "basic" else 0.0,
        "applicable_sources":applicable
    }

static func roll_basic_followup(
    rng: GameRng, context: Dictionary, attack_kind: String,
    target_hp_after_primary: float
) -> bool:
    if attack_kind != "basic" or target_hp_after_primary <= 0.0:
        return false
    if not bool(context.get("ok",false)):
        return false
    var chance := clampf(float(context.get("basic_followup_chance",0.0)),0.0,1.0)
    return chance > 0.0 and rng.chance(chance)
