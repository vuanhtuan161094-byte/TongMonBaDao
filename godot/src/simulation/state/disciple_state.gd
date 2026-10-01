class_name DiscipleState
extends RefCounted

var id: StringName
var display_name: String
var max_hp: float = 100.0
var hp: float = 100.0
var stamina: float = 100.0
var wallet: int = 100
# Base/intrinsic combat power. P2.1 realm power is stored separately so older paths remain stable.
var combat_power: float = 18.0
var risk_bias: float = 0.5
var spend_bias: float = 0.5
var survival_bias: float = 0.5

# P1.1 personality + goal state.
var personality_id: StringName = &"balanced"
var active_goal: StringName = &"GROWTH"
var goal_changed_tick: int = 0

# P2.1 cultivation state.
var cultivation_stage_index: int = 0
var cultivation_progress: float = 0.0
var cultivation_combat_bonus: float = 0.0
var cultivation_hp_bonus: float = 0.0
var cultivation_directive: StringName = &"balanced"
var breakthrough_failures: int = 0
var next_breakthrough_tick: int = 0
var last_breakthrough_outcome: StringName = &""

# P2.2 quality stays empty until SpiritualRootSystem is enabled.
var spiritual_root_quality: StringName = &""
# P2.3 adds elemental affinity only when the technique system is enabled.
var spiritual_root_elements: Array = []

# P2.3 personal technique economy/progression.
var contribution_points: int = 0
var spirit_stones: int = 0
var learned_techniques: Dictionary = {}
var active_technique_id: StringName = &""

# P2.4 accumulated path history. No fixed class is stored; identity is derived from this history.
var cultivation_path_xp: Dictionary = {}

# P2.5 combat skills are independent from cultivation techniques.
var learned_combat_skills: Dictionary = {}

# P2.6 equipment is slot-based but classless. A locked slot is player-controlled;
# unlocked slots remain available to autonomous equipment purchasing/upgrading.
var equipped_items: Dictionary = {}
var locked_equipment_slots: Dictionary = {}

# P2.7 disciple life/workforce. P2.8 adopts comprehension as canonical Thông Tuệ.
var comprehension: float = 0.0
var sect_rank: StringName = &""
var profession_xp: Dictionary = {}
var profession_traits: Array = []
var work_preferences: Dictionary = {}
var work_group_id: StringName = &""
var direct_command: Dictionary = {}
var work_progress: Dictionary = {}

# P2.8 procedural identity. Empty/zero for all legacy disciples.
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

var current_action: StringName = &"EVALUATE"
var region_id: StringName = &"sect"
var target_region_id: StringName = &""
var inventory: Dictionary = {}
var pending_loot: Dictionary = {}
var last_decision: Dictionary = {}
var metrics: Dictionary = {
    "combats": 0,
    "wins": 0,
    "retreats": 0,
    "defeats": 0,
    "sales": 0,
    "heals": 0,
    "rests": 0,
    "buys": 0,
    "danger_visits": 0,
    "medium_visits": 0,
    "safe_visits": 0,
    "actions": 0,
    "cultivation_sessions": 0,
    "cultivation_gained": 0,
    "breakthrough_successes": 0,
    "breakthrough_failures": 0,
    "techniques_learned": 0,
    "technique_training_sessions": 0,
    "technique_upgrades": 0,
    "special_deposits": 0,
    "path_cultivation_events": 0,
    "path_combat_events": 0
}

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "disciple"))
    display_name = str(definition.get("name", id))
    wallet = int(definition.get("wallet", wallet))
    combat_power = float(definition.get("combat_power", combat_power))
    risk_bias = float(definition.get("risk_bias", risk_bias))
    spend_bias = float(definition.get("spend_bias", spend_bias))
    survival_bias = float(definition.get("survival_bias", survival_bias))
    personality_id = StringName(definition.get("personality_id", personality_id))
    active_goal = StringName(definition.get("active_goal", active_goal))
    goal_changed_tick = int(definition.get("goal_changed_tick", goal_changed_tick))
    cultivation_stage_index = int(definition.get("cultivation_stage_index", cultivation_stage_index))
    cultivation_progress = float(definition.get("cultivation_progress", cultivation_progress))
    cultivation_combat_bonus = float(definition.get("cultivation_combat_bonus", cultivation_combat_bonus))
    cultivation_hp_bonus = float(definition.get("cultivation_hp_bonus", cultivation_hp_bonus))
    cultivation_directive = StringName(definition.get("cultivation_directive", cultivation_directive))
    breakthrough_failures = int(definition.get("breakthrough_failures", breakthrough_failures))
    next_breakthrough_tick = int(definition.get("next_breakthrough_tick", next_breakthrough_tick))
    last_breakthrough_outcome = StringName(definition.get("last_breakthrough_outcome", last_breakthrough_outcome))
    spiritual_root_quality = StringName(definition.get("spiritual_root_quality", spiritual_root_quality))
    spiritual_root_elements = _string_array(definition.get("spiritual_root_elements", []))
    contribution_points = int(definition.get("contribution_points", contribution_points))
    spirit_stones = int(definition.get("spirit_stones", spirit_stones))
    learned_techniques = _technique_dictionary(definition.get("learned_techniques", {}))
    active_technique_id = StringName(definition.get("active_technique_id", active_technique_id))
    cultivation_path_xp = _float_dictionary(definition.get("cultivation_path_xp", {}))
    learned_combat_skills = _bool_dictionary(definition.get("learned_combat_skills", {}))
    equipped_items = _string_dictionary(definition.get("equipped_items", {}))
    locked_equipment_slots = _bool_dictionary(definition.get("locked_equipment_slots", {}))
    comprehension = maxf(float(definition.get("comprehension", comprehension)), 0.0)
    sect_rank = StringName(definition.get("sect_rank", sect_rank))
    profession_xp = _float_dictionary(definition.get("profession_xp", {}))
    profession_traits = _string_array(definition.get("profession_traits", []))
    work_preferences = _int_dictionary(definition.get("work_preferences", {}))
    work_group_id = StringName(definition.get("work_group_id", work_group_id))
    direct_command = _command_dictionary(definition.get("direct_command", {}))
    work_progress = _float_dictionary(definition.get("work_progress", {}))

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

func retreat_hp_ratio() -> float:
    return lerpf(0.48, 0.14, clampf(risk_bias, 0.0, 1.0))

func inventory_count() -> int:
    var total := 0
    for quantity in inventory.values():
        total += int(quantity)
    return total

func add_item(item_id: String, quantity: int) -> void:
    if quantity <= 0:
        return
    inventory[item_id] = int(inventory.get(item_id, 0)) + quantity

func clear_inventory() -> void:
    inventory.clear()

func to_dict() -> Dictionary:
    var data := {
        "id": str(id),
        "name": display_name,
        "max_hp": max_hp,
        "hp": hp,
        "stamina": stamina,
        "wallet": wallet,
        "combat_power": combat_power,
        "risk_bias": risk_bias,
        "spend_bias": spend_bias,
        "survival_bias": survival_bias,
        "personality_id": str(personality_id),
        "active_goal": str(active_goal),
        "goal_changed_tick": goal_changed_tick,
        "cultivation_stage_index": cultivation_stage_index,
        "cultivation_progress": cultivation_progress,
        "cultivation_combat_bonus": cultivation_combat_bonus,
        "cultivation_hp_bonus": cultivation_hp_bonus,
        "cultivation_directive": str(cultivation_directive),
        "breakthrough_failures": breakthrough_failures,
        "next_breakthrough_tick": next_breakthrough_tick,
        "last_breakthrough_outcome": str(last_breakthrough_outcome),
        "current_action": str(current_action),
        "region_id": str(region_id),
        "target_region_id": str(target_region_id),
        "inventory": inventory.duplicate(true),
        "pending_loot": pending_loot.duplicate(true),
        "last_decision": last_decision.duplicate(true),
        "metrics": metrics.duplicate(true)
    }
    if spiritual_root_quality != &"":
        data["spiritual_root_quality"] = str(spiritual_root_quality)
    if not spiritual_root_elements.is_empty():
        data["spiritual_root_elements"] = spiritual_root_elements.duplicate()
    if contribution_points > 0 or spirit_stones > 0 or not learned_techniques.is_empty() or active_technique_id != &"":
        data["contribution_points"] = contribution_points
        data["spirit_stones"] = spirit_stones
        data["learned_techniques"] = learned_techniques.duplicate(true)
        data["active_technique_id"] = str(active_technique_id)
    if not cultivation_path_xp.is_empty():
        data["cultivation_path_xp"] = cultivation_path_xp.duplicate(true)
    if not learned_combat_skills.is_empty():
        data["learned_combat_skills"] = learned_combat_skills.duplicate(true)
    if not equipped_items.is_empty():
        data["equipped_items"] = equipped_items.duplicate(true)
    if not locked_equipment_slots.is_empty():
        data["locked_equipment_slots"] = locked_equipment_slots.duplicate(true)
    if comprehension > 0.0 or sect_rank != &"" or not profession_xp.is_empty() or not profession_traits.is_empty() or not work_preferences.is_empty() or work_group_id != &"" or not direct_command.is_empty() or not work_progress.is_empty():
        data["comprehension"] = comprehension
        data["sect_rank"] = str(sect_rank)
        data["profession_xp"] = profession_xp.duplicate(true)
        data["profession_traits"] = profession_traits.duplicate()
        data["work_preferences"] = work_preferences.duplicate(true)
        data["work_group_id"] = str(work_group_id)
        data["direct_command"] = direct_command.duplicate(true)
        data["work_progress"] = work_progress.duplicate(true)
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
    return data

static func from_dict(data: Dictionary) -> DiscipleState:
    var disciple := DiscipleState.new({
        "id": data.get("id", "disciple"),
        "name": data.get("name", "Disciple"),
        "wallet": data.get("wallet", 0),
        "combat_power": data.get("combat_power", 18.0),
        "risk_bias": data.get("risk_bias", 0.5),
        "spend_bias": data.get("spend_bias", 0.5),
        "survival_bias": data.get("survival_bias", 0.5),
        "personality_id": data.get("personality_id", "balanced"),
        "active_goal": data.get("active_goal", "GROWTH"),
        "goal_changed_tick": data.get("goal_changed_tick", 0),
        "cultivation_stage_index": data.get("cultivation_stage_index", 0),
        "cultivation_progress": data.get("cultivation_progress", 0.0),
        "cultivation_combat_bonus": data.get("cultivation_combat_bonus", 0.0),
        "cultivation_hp_bonus": data.get("cultivation_hp_bonus", 0.0),
        "cultivation_directive": data.get("cultivation_directive", "balanced"),
        "breakthrough_failures": data.get("breakthrough_failures", 0),
        "next_breakthrough_tick": data.get("next_breakthrough_tick", 0),
        "last_breakthrough_outcome": data.get("last_breakthrough_outcome", ""),
        "spiritual_root_quality": data.get("spiritual_root_quality", ""),
        "spiritual_root_elements": data.get("spiritual_root_elements", []),
        "contribution_points": data.get("contribution_points", 0),
        "spirit_stones": data.get("spirit_stones", 0),
        "learned_techniques": data.get("learned_techniques", {}),
        "active_technique_id": data.get("active_technique_id", ""),
        "cultivation_path_xp": data.get("cultivation_path_xp", {}),
        "learned_combat_skills": data.get("learned_combat_skills", {}),
        "equipped_items": data.get("equipped_items", {}),
        "locked_equipment_slots": data.get("locked_equipment_slots", {}),
        "comprehension": data.get("comprehension", 0.0),
        "sect_rank": data.get("sect_rank", ""),
        "profession_xp": data.get("profession_xp", {}),
        "profession_traits": data.get("profession_traits", []),
        "work_preferences": data.get("work_preferences", {}),
        "work_group_id": data.get("work_group_id", ""),
        "direct_command": data.get("direct_command", {}),
        "work_progress": data.get("work_progress", {}),
        "profile_seed": data.get("profile_seed", 0),
        "recruitment_source": data.get("recruitment_source", ""),
        "race_id": data.get("race_id", ""),
        "sex_id": data.get("sex_id", ""),
        "origin_id": data.get("origin_id", ""),
        "aptitude": data.get("aptitude", 0.0),
        "constitution": data.get("constitution", 0.0),
        "fortune": data.get("fortune", 0.0),
        "charisma": data.get("charisma", 0.0),
        "potential": data.get("potential", 0.0),
        "disciple_quality": data.get("disciple_quality", ""),
        "spiritual_root_purity": data.get("spiritual_root_purity", 0.0),
        "age": data.get("age", 0),
        "base_lifespan": data.get("base_lifespan", 0),
        "max_lifespan": data.get("max_lifespan", 0),
        "latent_identity_seed": data.get("latent_identity_seed", 0)
    })
    disciple.max_hp = float(data.get("max_hp", 100.0))
    disciple.hp = float(data.get("hp", disciple.max_hp))
    disciple.stamina = float(data.get("stamina", 100.0))
    disciple.current_action = StringName(data.get("current_action", "EVALUATE"))
    disciple.region_id = StringName(data.get("region_id", "sect"))
    disciple.target_region_id = StringName(data.get("target_region_id", ""))
    disciple.inventory = _int_dictionary(data.get("inventory", {}))
    disciple.pending_loot = _int_dictionary(data.get("pending_loot", {}))
    disciple.last_decision = _decision_dictionary(data.get("last_decision", {}))

    var saved_metrics = data.get("metrics", {})
    if saved_metrics is Dictionary:
        var metric_keys: Array = saved_metrics.keys()
        metric_keys.sort()
        for key in metric_keys:
            disciple.metrics[str(key)] = int(saved_metrics[key])
    return disciple

static func _decision_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    normalized = value.duplicate(true)
    if normalized.has("action"):
        normalized["action"] = str(normalized["action"])
    for key in ["medicine_stock", "supply_stock", "lodging_capacity"]:
        if normalized.has(key):
            normalized[key] = int(normalized[key])
    return normalized

static func _command_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    if value.is_empty():
        return normalized
    normalized["kind"] = str(value.get("kind", ""))
    normalized["target"] = str(value.get("target", ""))
    normalized["issued_tick"] = int(value.get("issued_tick", 0))
    normalized["expires_tick"] = int(value.get("expires_tick", 0))
    return normalized

static func _int_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        normalized[str(key)] = int(value[key])
    return normalized

static func _float_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        normalized[str(key)] = maxf(float(value[key]), 0.0)
    return normalized

static func _bool_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        if bool(value[key]):
            normalized[str(key)] = true
    return normalized

static func _string_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        var text := str(value[key])
        if text != "":
            normalized[str(key)] = text
    return normalized

static func _string_array(value: Variant) -> Array:
    var result: Array = []
    if not (value is Array):
        return result
    for item in value:
        result.append(str(item))
    return result

static func _technique_dictionary(value: Variant) -> Dictionary:
    var result: Dictionary = {}
    if not (value is Dictionary):
        return result
    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        var row = value[key]
        if row is Dictionary:
            result[str(key)] = {
                "level": maxi(int(row.get("level", 1)), 1),
                "xp": maxf(float(row.get("xp", 0.0)), 0.0)
            }
    return result
