class_name CandidateState
extends RefCounted

var id: StringName
var display_name: String
var combat_power: float = 18.0
var risk_bias: float = 0.5
var spend_bias: float = 0.5
var survival_bias: float = 0.5
var personality_id: StringName = &"balanced"
var generated_index: int = 0

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "candidate"))
    display_name = str(definition.get("name", id))
    combat_power = float(definition.get("combat_power", combat_power))
    risk_bias = float(definition.get("risk_bias", risk_bias))
    spend_bias = float(definition.get("spend_bias", spend_bias))
    survival_bias = float(definition.get("survival_bias", survival_bias))
    personality_id = StringName(definition.get("personality_id", personality_id))
    generated_index = int(definition.get("generated_index", generated_index))

func to_dict() -> Dictionary:
    return {
        "id": str(id),
        "name": display_name,
        "combat_power": combat_power,
        "risk_bias": risk_bias,
        "spend_bias": spend_bias,
        "survival_bias": survival_bias,
        "personality_id": str(personality_id),
        "generated_index": generated_index
    }

func to_disciple() -> DiscipleState:
    return DiscipleState.new({
        "id": str(id),
        "name": display_name,
        "wallet": 0,
        "combat_power": combat_power,
        "risk_bias": risk_bias,
        "spend_bias": spend_bias,
        "survival_bias": survival_bias,
        "personality_id": str(personality_id)
    })

static func from_dict(data: Dictionary) -> CandidateState:
    return CandidateState.new(data)
