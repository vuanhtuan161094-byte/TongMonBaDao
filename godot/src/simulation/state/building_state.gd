class_name BuildingState
extends RefCounted

var id: StringName
var building_type: StringName
var display_name: String
var instance_index: int = 1
var level: int = 1
var max_level: int = 100
var status: StringName = &"active"
var worker_group_id: StringName = &""
var specialization: StringName = &""

var upgrade_target_level: int = 0
var upgrade_started_tick: int = -1
var upgrade_required_work: float = 0.0
var upgrade_progress: float = 0.0
var unlocked_milestones: Array[int] = []

# Generic building-owned production lifecycle state.
# Empty means no active production process.
var production_state: Dictionary = {}

var metrics: Dictionary = {
    "upgrade_completions": 0,
    "production_batches": 0,
    "units_produced": 0
}

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "building"))
    building_type = StringName(definition.get("building_type", ""))
    display_name = str(definition.get("name", id))
    instance_index = maxi(int(definition.get("instance_index", 1)), 1)
    level = maxi(int(definition.get("level", 1)), 1)
    max_level = maxi(int(definition.get("max_level", 100)), 1)
    status = StringName(definition.get("status", "active"))
    worker_group_id = StringName(definition.get("worker_group_id", ""))
    specialization = StringName(definition.get("specialization", ""))
    upgrade_target_level = maxi(int(definition.get("upgrade_target_level", 0)), 0)
    upgrade_started_tick = int(definition.get("upgrade_started_tick", -1))
    upgrade_required_work = maxf(float(definition.get("upgrade_required_work", 0.0)), 0.0)
    upgrade_progress = maxf(float(definition.get("upgrade_progress", 0.0)), 0.0)
    unlocked_milestones = _int_array(definition.get("unlocked_milestones", []))
    production_state = _production_dictionary(definition.get("production_state", {}))

    var saved_metrics = definition.get("metrics", {})
    if saved_metrics is Dictionary:
        for key in metrics.keys():
            metrics[key] = maxi(int(saved_metrics.get(key, 0)), 0)

func is_upgrading() -> bool:
    return status == &"upgrading"

func to_dict() -> Dictionary:
    return {
        "id": str(id),
        "building_type": str(building_type),
        "name": display_name,
        "instance_index": instance_index,
        "level": level,
        "max_level": max_level,
        "status": str(status),
        "worker_group_id": str(worker_group_id),
        "specialization": str(specialization),
        "upgrade_target_level": upgrade_target_level,
        "upgrade_started_tick": upgrade_started_tick,
        "upgrade_required_work": upgrade_required_work,
        "upgrade_progress": upgrade_progress,
        "unlocked_milestones": unlocked_milestones.duplicate(),
        "production_state": production_state.duplicate(true),
        "metrics": metrics.duplicate(true)
    }

static func from_dict(data: Dictionary):
    return BuildingState.new(data)

static func _production_dictionary(value: Variant) -> Dictionary:
    if not (value is Dictionary) or value.is_empty():
        return {}
    var result: Dictionary = {}
    var keys: Array = value.keys()
    keys.sort()
    for raw_key in keys:
        var key := str(raw_key)
        var raw = value[raw_key]
        if key in ["phase", "resource_id", "planted_by", "policy_mode", "fixed_crop_id", "main_guide_id"]:
            result[key] = str(raw)
        elif key in ["growth_progress", "growth_required"]:
            result[key] = maxf(float(raw), 0.0)
        elif key == "snapshot_main_charisma":
            result[key] = maxf(float(raw), 0.0)
        elif key in ["plant_sequence", "enhanced_heaven_count", "daily_arrival_target", "daily_arrivals_generated", "job_sequence"]:
            result[key] = maxi(int(raw), 0)
        elif key == "recipe_enabled":
            result[key] = bool(raw)
        elif key == "recipe_id":
            result[key] = str(raw)
        elif key == "jobs":
            result[key] = _timed_job_array(raw)
        elif key == "snapshot_day_index":
            result[key] = int(raw)
        elif key == "priority_weights":
            result[key] = _int_dictionary(raw)
        elif key == "assistant_guide_ids":
            result[key] = _string_array(raw)
        elif key == "plots":
            result[key] = _plot_array(raw)
        else:
            result[key] = raw
    return result

static func _timed_job_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for raw_job in value:
        if not (raw_job is Dictionary):
            continue
        var job: Dictionary = {}
        var keys: Array = raw_job.keys()
        keys.sort()
        for raw_key in keys:
            var key := str(raw_key)
            var raw = raw_job[raw_key]
            if key in ["job_id", "recipe_id", "worker_id", "output_resource_id"]:
                job[key] = str(raw)
            elif key in ["started_tick", "finish_tick", "output_quantity"]:
                job[key] = int(raw)
            elif key == "profession_xp_gain":
                job[key] = maxf(float(raw), 0.0)
            elif key == "inputs":
                job[key] = _int_dictionary(raw)
            else:
                job[key] = raw
        result.append(job)
    return result

static func _plot_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for raw_plot in value:
        if raw_plot is Dictionary:
            result.append(_plot_dictionary(raw_plot))
    return result

static func _plot_dictionary(value: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    var keys: Array = value.keys()
    keys.sort()
    for raw_key in keys:
        var key := str(raw_key)
        var raw = value[raw_key]
        if key in ["plot_id", "crop_id", "status", "assigned_worker_id"]:
            result[key] = str(raw)
        elif key in ["started_tick", "finish_tick", "paid_spirit_stones", "routine_yield"]:
            result[key] = int(raw)
        elif key == "rare_factor":
            result[key] = float(raw)
        elif key == "profession_xp_gain":
            # Present only on new harvest-authoritative plots. Old in-flight
            # saves have no key: XP was already awarded at sowing.
            result[key] = maxf(float(raw),0.0)
        else:
            result[key] = raw
    return result

static func _int_dictionary(value: Variant) -> Dictionary:
    var result: Dictionary = {}
    if not (value is Dictionary):
        return result
    var keys: Array = value.keys()
    keys.sort()
    for raw_key in keys:
        result[str(raw_key)] = int(value[raw_key])
    return result

static func _string_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for raw in value:
        var text := str(raw)
        if text != "" and not result.has(text):
            result.append(text)
    result.sort()
    return result

static func _int_array(value: Variant) -> Array[int]:
    var result: Array[int] = []
    if not (value is Array):
        return result
    for raw in value:
        var number := int(raw)
        if number > 0 and not result.has(number):
            result.append(number)
    result.sort()
    return result
