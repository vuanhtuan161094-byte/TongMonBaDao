class_name RelationshipState
extends RefCounted

const NEUTRAL := 50.0

var source_id: StringName
var target_id: StringName
var affinity: float = NEUTRAL
var trust: float = NEUTRAL
var respect: float = NEUTRAL
var interactions: int = 0
var last_event_tick: int = 0
var last_event: StringName = &""

func _init(definition: Dictionary = {}) -> void:
    source_id = StringName(definition.get("source_id", ""))
    target_id = StringName(definition.get("target_id", ""))
    affinity = clampf(float(definition.get("affinity", NEUTRAL)), 0.0, 100.0)
    trust = clampf(float(definition.get("trust", NEUTRAL)), 0.0, 100.0)
    respect = clampf(float(definition.get("respect", NEUTRAL)), 0.0, 100.0)
    interactions = maxi(int(definition.get("interactions", 0)), 0)
    last_event_tick = maxi(int(definition.get("last_event_tick", 0)), 0)
    last_event = StringName(definition.get("last_event", ""))

func composite_deviation() -> float:
    return (
        (affinity - NEUTRAL) * 0.30
        + (trust - NEUTRAL) * 0.45
        + (respect - NEUTRAL) * 0.25
    )

func to_dict() -> Dictionary:
    return {
        "source_id": str(source_id),
        "target_id": str(target_id),
        "affinity": affinity,
        "trust": trust,
        "respect": respect,
        "interactions": interactions,
        "last_event_tick": last_event_tick,
        "last_event": str(last_event)
    }

static func from_dict(data: Dictionary) -> RelationshipState:
    return RelationshipState.new(data)
