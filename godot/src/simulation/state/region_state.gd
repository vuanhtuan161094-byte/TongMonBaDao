class_name RegionState
extends RefCounted

var id: StringName
var display_name: String
var danger: int
var profit_modifier: float
var monster_weights: Dictionary

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "region"))
    display_name = str(definition.get("name", id))
    danger = int(definition.get("danger", 1))
    profit_modifier = float(definition.get("profit_modifier", 1.0))
    monster_weights = definition.get("monster_weights", {}).duplicate(true)

func to_dict() -> Dictionary:
    return {
        "id": str(id),
        "name": display_name,
        "danger": danger,
        "profit_modifier": profit_modifier,
        "monster_weights": monster_weights.duplicate(true)
    }

static func from_dict(data: Dictionary) -> RegionState:
    return RegionState.new(data)
