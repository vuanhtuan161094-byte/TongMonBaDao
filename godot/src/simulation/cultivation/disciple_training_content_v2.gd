class_name DiscipleTrainingContentV2
extends RefCounted

# DV2-03C/V2.1: STRICT CONTENT FORMAT, not a production EXP balance table.
# Tu Vi rate is normalized per simulation minute. Luyện Thể now has a typed
# source contract in DiscipleBodyXpSourceV2, but this catalogue deliberately
# carries only Body floor costs until real production/training/expedition
# consumers author their own per-minute source rates and verified context.
const VERSION := 3
const FLOORS_PER_TRACK := 300
const RATE_UNIT := "per_simulation_minute"

static func validate_catalogue(raw: Variant) -> Dictionary:
    if not (raw is Dictionary):
        return {"ok":false,"reason":"invalid_training_catalogue"}
    var catalogue: Dictionary = raw
    # JSON.parse_string may restore a nominal integer version as a float.
    var raw_version = catalogue.get("version",null)
    if not (raw_version is int or raw_version is float):
        return {"ok":false,"reason":"invalid_training_catalogue_version"}
    var version := float(raw_version)
    if is_nan(version) or is_inf(version) or version != float(VERSION):
        return {"ok":false,"reason":"invalid_training_catalogue_version"}
    if str(catalogue.get("catalogue_id","")).is_empty():
        return {"ok":false,"reason":"missing_training_catalogue_id"}
    var raw_tracks = catalogue.get("tracks",null)
    if not (raw_tracks is Dictionary):
        return {"ok":false,"reason":"missing_training_catalogue_tracks"}
    var tracks: Dictionary = raw_tracks
    if tracks.size() != DiscipleRealmProgressV2.TRACKS.size():
        return {"ok":false,"reason":"invalid_training_catalogue_tracks"}
    for track in DiscipleRealmProgressV2.TRACKS:
        if not tracks.has(track) or not (tracks[track] is Dictionary):
            return {"ok":false,"reason":"missing_training_track","track":track}
        var rule: Dictionary = tracks[track]
        if str(rule.get("authority_id","")).is_empty():
            return {"ok":false,"reason":"missing_training_authority","track":track}
        if track == "cultivation":
            var raw_rate = rule.get("base_tuvi_per_minute",null)
            if not (raw_rate is int or raw_rate is float):
                return {"ok":false,"reason":"missing_training_base_rate","track":track}
            var rate := float(raw_rate)
            if is_nan(rate) or is_inf(rate) or rate <= 0.0:
                return {"ok":false,"reason":"invalid_training_base_rate","track":track}
            var raw_multiplier = rule.get("cultivate_multiplier",null)
            if not (raw_multiplier is int or raw_multiplier is float):
                return {"ok":false,"reason":"missing_cultivate_multiplier","track":track}
            var cultivate_multiplier := float(raw_multiplier)
            if is_nan(cultivate_multiplier) or is_inf(cultivate_multiplier) or cultivate_multiplier < 1.0:
                return {"ok":false,"reason":"invalid_cultivate_multiplier","track":track}
        var raw_costs = rule.get("floor_costs",null)
        if not (raw_costs is Dictionary):
            return {"ok":false,"reason":"missing_authored_floor_costs","track":track}
        var costs: Dictionary = raw_costs
        if costs.size() != FLOORS_PER_TRACK:
            return {"ok":false,"reason":"incomplete_training_floor_costs","track":track}
        for realm in range(1,DiscipleRealmProgressV2.MAX_REALM+1):
            for floor_index in range(1,DiscipleRealmProgressV2.MAX_FLOOR+1):
                var key := "%d:%d" % [realm,floor_index]
                if not costs.has(key):
                    return {"ok":false,"reason":"missing_training_floor","track":track,"floor":key}
                var raw_cost = costs[key]
                if not (raw_cost is int or raw_cost is float):
                    return {"ok":false,"reason":"invalid_training_floor_cost","track":track,"floor":key}
                var amount := float(raw_cost)
                if is_nan(amount) or is_inf(amount) or amount <= 0.0:
                    return {"ok":false,"reason":"invalid_training_floor_cost","track":track,"floor":key}
    return {"ok":true,"version":VERSION,"floors":2*FLOORS_PER_TRACK,
        "catalogue_id":str(catalogue["catalogue_id"])}

# Build but DO NOT enable. SectState.v2_training_enabled stays false by
# default, and the caller must have explicit approval for numeric content.
static func build_rules(raw: Variant) -> Dictionary:
    var validated := validate_catalogue(raw)
    if not bool(validated.get("ok",false)):
        return validated
    var tracks: Dictionary = raw["tracks"]
    var rules: Dictionary = {}
    for track in DiscipleRealmProgressV2.TRACKS:
        var item: Dictionary = tracks[track]
        var rule := {
            "authority_id":str(item["authority_id"]),
            "floor_costs":item["floor_costs"].duplicate(true),
            "sources":[]
        }
        if track == "cultivation":
            rule["action"] = "CULTIVATE"
            rule["base_tuvi_per_minute"] = float(item["base_tuvi_per_minute"])
            rule["cultivate_multiplier"] = float(item["cultivate_multiplier"])
        else:
            rule["training_mechanic"] = "unresolved"
        rules[track] = rule
    return {"ok":true,"rules":rules,"catalogue_id":validated["catalogue_id"]}
