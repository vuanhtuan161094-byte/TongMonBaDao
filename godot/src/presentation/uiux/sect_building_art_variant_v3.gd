extends RefCounted
## AS-BUILD-V3. Visual-only replacement for three previously unverified worksite
## placeholders. Source A's five SHA-pinned original houses remain untouched.
## Each PNG is a separately authored view/state; never flip_h as a fake view.
const ROOT := "res://art/reimagined_source_a_v3/"
const ART_NAMES := {
    "linh_forest":"linh_lam",
    "spirit_field":"linh_dien",
    "alchemy_hall":"luyen_dan"
}
const TARGET_SIZE := {
    "linh_forest":Vector2(166,136),
    "spirit_field":Vector2(166,136),
    "alchemy_hall":Vector2(182,147)
}
static func supported(building_type: StringName) -> bool:
    return ART_NAMES.has(str(building_type))
static func sprite_path(building_type: StringName, direction: StringName, working: bool) -> String:
    var kind: String = str(building_type)
    if not ART_NAMES.has(kind):
        return ""
    var side: String = str(direction).to_upper()
    if side != "A" and side != "B":
        return ""
    return ROOT + str(ART_NAMES[kind]) + "_" + side + ("_active.png" if working else "_idle.png")
static func all_paths() -> Array[String]:
    var result: Array[String] = []
    for type_key in ART_NAMES:
        for side in ["A","B"]:
            for working in [false,true]:
                result.append(sprite_path(StringName(type_key),StringName(side),working))
    result.sort()
    return result
static func display_size(building_type: StringName) -> Vector2:
    return TARGET_SIZE.get(str(building_type),Vector2(166,136))
static func is_canonical_working(building: BuildingState,tick: int) -> bool:
    if building == null or not supported(building.building_type):
        return false
    var data: Dictionary = building.production_state
    var kind: String = str(building.building_type)
    var jobs = data.get("economy_a_jobs",[]) if kind == "linh_forest" else data.get("jobs",[])
    if kind == "spirit_field":
        for plot in data.get("plots",[]):
            if plot is Dictionary and str(plot.get("status","")) == "growing" \
                    and int(plot.get("started_tick",tick)) <= tick \
                    and tick < int(plot.get("finish_tick",tick)):
                return true
    elif jobs is Array:
        for job in jobs:
            if job is Dictionary and int(job.get("started_tick",tick)) <= tick \
                    and tick < int(job.get("finish_tick",tick)):
                return true
    return false
