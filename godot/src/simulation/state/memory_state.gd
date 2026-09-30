class_name MemoryState
extends RefCounted

var id: StringName
var owner_id: StringName
var event_id: StringName
var target_id: StringName = &""
var region_id: StringName = &""
var valence: float = 0.0
var importance: float = 50.0
var occurrences: int = 1
var created_tick: int = 0
var last_event_tick: int = 0
var player_linked: bool = false

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "memory"))
    owner_id = StringName(definition.get("owner_id", ""))
    event_id = StringName(definition.get("event_id", ""))
    target_id = StringName(definition.get("target_id", ""))
    region_id = StringName(definition.get("region_id", ""))
    valence = clampf(float(definition.get("valence", 0.0)), -1.0, 1.0)
    importance = clampf(float(definition.get("importance", 50.0)), 0.0, 100.0)
    occurrences = maxi(int(definition.get("occurrences", 1)), 1)
    created_tick = maxi(int(definition.get("created_tick", 0)), 0)
    last_event_tick = maxi(int(definition.get("last_event_tick", created_tick)), created_tick)
    player_linked = bool(definition.get("player_linked", false))

func effective_strength(current_tick: int) -> float:
    var age := maxi(current_tick - last_event_tick, 0)
    var age_factor := maxf(0.25, 1.0 / (1.0 + float(age) / 6000.0))
    var repetition_factor := 1.0 + minf(float(occurrences - 1) * 0.08, 0.40)
    return importance * age_factor * repetition_factor

func to_dict() -> Dictionary:
    return {
        "id": str(id),
        "owner_id": str(owner_id),
        "event_id": str(event_id),
        "target_id": str(target_id),
        "region_id": str(region_id),
        "valence": valence,
        "importance": importance,
        "occurrences": occurrences,
        "created_tick": created_tick,
        "last_event_tick": last_event_tick,
        "player_linked": player_linked
    }

static func from_dict(data: Dictionary) -> MemoryState:
    return MemoryState.new(data)
