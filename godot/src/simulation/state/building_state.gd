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
        "metrics": metrics.duplicate(true)
    }

static func from_dict(data: Dictionary):
    return BuildingState.new(data)

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
