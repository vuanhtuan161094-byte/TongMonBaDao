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

# P2.7 non-combat value. P2.8 adopts comprehension as canonical Thông Tuệ.
var comprehension: float = 0.0
var profession_traits: Array = []

# P2.8 procedural identity. Empty/zero for legacy candidates.
var profile_seed: int = 0
var recruitment_source: StringName = &""
var race_id: StringName = &""
var sex_id: StringName = &""
var origin_id: StringName = &""
var aptitude: float = 0.0
var constitution: float = 0.0
var fortune: float = 0.0
var charisma: float = 0.0
var potential: float = 0.0
var disciple_quality: StringName = &""
var spiritual_root_purity: float = 0.0
var age: int = 0
var base_lifespan: int = 0
var max_lifespan: int = 0
var latent_identity_seed: int = 0
var cultivation_stage_index: int = 0
var cultivation_progress: float = 0.0
var cultivation_combat_bonus: float = 0.0
var cultivation_hp_bonus: float = 0.0

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
    spiritual_root_elements = _string_array(definition.get("spiritual_root_elements", []))
    comprehension = maxf(float(definition.get("comprehension", comprehension)), 0.0)
    profession_traits = _string_array(definition.get("profession_traits", []))

    profile_seed = int(definition.get("profile_seed", 0))
    recruitment_source = StringName(definition.get("recruitment_source", ""))
    race_id = StringName(definition.get("race_id", ""))
    sex_id = StringName(definition.get("sex_id", ""))
    origin_id = StringName(definition.get("origin_id", ""))
    aptitude = maxf(float(definition.get("aptitude", 0.0)), 0.0)
    constitution = maxf(float(definition.get("constitution", 0.0)), 0.0)
    fortune = maxf(float(definition.get("fortune", 0.0)), 0.0)
    charisma = maxf(float(definition.get("charisma", 0.0)), 0.0)
    potential = maxf(float(definition.get("potential", 0.0)), 0.0)
    disciple_quality = StringName(definition.get("disciple_quality", ""))
    spiritual_root_purity = maxf(float(definition.get("spiritual_root_purity", 0.0)), 0.0)
    age = maxi(int(definition.get("age", 0)), 0)
    base_lifespan = maxi(int(definition.get("base_lifespan", 0)), 0)
    max_lifespan = maxi(int(definition.get("max_lifespan", 0)), 0)
    latent_identity_seed = int(definition.get("latent_identity_seed", 0))
    cultivation_stage_index = maxi(int(definition.get("cultivation_stage_index", 0)), 0)
    cultivation_progress = maxf(float(definition.get("cultivation_progress", 0.0)), 0.0)
    cultivation_combat_bonus = maxf(float(definition.get("cultivation_combat_bonus", 0.0)), 0.0)
    cultivation_hp_bonus = maxf(float(definition.get("cultivation_hp_bonus", 0.0)), 0.0)

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
    if profile_seed > 0 or recruitment_source != &"":
        data["profile_seed"] = profile_seed
        data["recruitment_source"] = str(recruitment_source)
        data["race_id"] = str(race_id)
        data["sex_id"] = str(sex_id)
        data["origin_id"] = str(origin_id)
        data["aptitude"] = aptitude
        data["constitution"] = constitution
        data["fortune"] = fortune
        data["charisma"] = charisma
        data["potential"] = potential
        data["disciple_quality"] = str(disciple_quality)
        data["spiritual_root_purity"] = spiritual_root_purity
        data["age"] = age
        data["base_lifespan"] = base_lifespan
        data["max_lifespan"] = max_lifespan
        data["latent_identity_seed"] = latent_identity_seed
        data["cultivation_stage_index"] = cultivation_stage_index
        data["cultivation_progress"] = cultivation_progress
        data["cultivation_combat_bonus"] = cultivation_combat_bonus
        data["cultivation_hp_bonus"] = cultivation_hp_bonus
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

    if profile_seed > 0 or recruitment_source != &"":
        definition["profile_seed"] = profile_seed
        definition["recruitment_source"] = str(recruitment_source)
        definition["race_id"] = str(race_id)
        definition["sex_id"] = str(sex_id)
        definition["origin_id"] = str(origin_id)
        definition["aptitude"] = aptitude
        definition["constitution"] = constitution
        definition["fortune"] = fortune
        definition["comprehension"] = comprehension
        definition["charisma"] = charisma
        definition["potential"] = potential
        definition["disciple_quality"] = str(disciple_quality)
        definition["spiritual_root_purity"] = spiritual_root_purity
        definition["age"] = age
        definition["base_lifespan"] = base_lifespan
        definition["max_lifespan"] = max_lifespan
        definition["latent_identity_seed"] = latent_identity_seed
        definition["cultivation_stage_index"] = cultivation_stage_index
        definition["cultivation_progress"] = cultivation_progress
        definition["cultivation_combat_bonus"] = cultivation_combat_bonus
        definition["cultivation_hp_bonus"] = cultivation_hp_bonus
        definition["sect_rank"] = "outer"

    var disciple := DiscipleState.new(definition)
    if profile_seed > 0 or recruitment_source != &"":
        disciple.max_hp = 100.0 + cultivation_hp_bonus
        disciple.hp = disciple.max_hp
    return disciple

static func from_dict(data: Dictionary) -> CandidateState:
    return CandidateState.new(data)

static func _string_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for item in value:
        result.append(str(item))
    result.sort()
    return result
