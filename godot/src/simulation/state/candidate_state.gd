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
var spiritual_root_quality: StringName = &""
var spiritual_root_elements: Array = []

# P2.7 non-combat value. Empty/zero until workforce is enabled.
var comprehension: float = 0.0
var profession_traits: Array = []

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "candidate"))
    display_name = str(definition.get("name", id))
    combat_power = float(definition.get("combat_power", combat_power))
    risk_bias = float(definition.get("risk_bias", risk_bias))
    spend_bias = float(definition.get("spend_bias", spend_bias))
    survival_bias = float(definition.get("survival_bias", survival_bias))
    personality_id = StringName(definition.get("personality_id", personality_id))
    generated_index = int(definition.get("generated_index", generated_index))
    spiritual_root_quality = StringName(definition.get("spiritual_root_quality", spiritual_root_quality))
    var raw_elements = definition.get("spiritual_root_elements", [])
    if raw_elements is Array:
        for item in raw_elements:
            spiritual_root_elements.append(str(item))
    comprehension = maxf(float(definition.get("comprehension", comprehension)), 0.0)
    var raw_traits = definition.get("profession_traits", [])
    if raw_traits is Array:
        for item in raw_traits:
            profession_traits.append(str(item))
    profession_traits.sort()

func to_dict() -> Dictionary:
    var data := {
        "id": str(id),
        "name": display_name,
        "combat_power": combat_power,
        "risk_bias": risk_bias,
        "spend_bias": spend_bias,
        "survival_bias": survival_bias,
        "personality_id": str(personality_id),
        "generated_index": generated_index
    }
    if spiritual_root_quality != &"":
        data["spiritual_root_quality"] = str(spiritual_root_quality)
    if not spiritual_root_elements.is_empty():
        data["spiritual_root_elements"] = spiritual_root_elements.duplicate()
    if comprehension > 0.0 or not profession_traits.is_empty():
        data["comprehension"] = comprehension
        data["profession_traits"] = profession_traits.duplicate()
    return data

func to_disciple() -> DiscipleState:
    var definition := {
        "id": str(id),
        "name": display_name,
        "wallet": 0,
        "combat_power": combat_power,
        "risk_bias": risk_bias,
        "spend_bias": spend_bias,
        "survival_bias": survival_bias,
        "personality_id": str(personality_id)
    }
    if spiritual_root_quality != &"":
        definition["spiritual_root_quality"] = str(spiritual_root_quality)
    if not spiritual_root_elements.is_empty():
        definition["spiritual_root_elements"] = spiritual_root_elements.duplicate()
    if comprehension > 0.0 or not profession_traits.is_empty():
        definition["comprehension"] = comprehension
        definition["profession_traits"] = profession_traits.duplicate()
        definition["sect_rank"] = "outer"
    return DiscipleState.new(definition)

static func from_dict(data: Dictionary) -> CandidateState:
    return CandidateState.new(data)
