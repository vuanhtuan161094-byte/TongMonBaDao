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

# P1.1 personality + goal state. The three numeric biases remain the
# behavior vector; personality_id is the stable human-readable archetype.
var personality_id: StringName = &"balanced"
var active_goal: StringName = &"GROWTH"
var goal_changed_tick: int = 0

# P2.1 cultivation state. Defaults are deliberately inert for all P0-P1 factories.
var cultivation_stage_index: int = 0
var cultivation_progress: float = 0.0
var cultivation_combat_bonus: float = 0.0
var cultivation_hp_bonus: float = 0.0
var cultivation_directive: StringName = &"balanced"
var breakthrough_failures: int = 0
var next_breakthrough_tick: int = 0
var last_breakthrough_outcome: StringName = &""

# P2.2 stays empty until SpiritualRootSystem is enabled.
var spiritual_root_quality: StringName = &""

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
    "breakthrough_failures": 0
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
        "spiritual_root_quality": data.get("spiritual_root_quality", "")
    })
    disciple.max_hp = float(data.get("max_hp", 100.0))
    disciple.hp = float(data.get("hp", disciple.max_hp))
    disciple.stamina = float(data.get("stamina", 100.0))
    disciple.current_action = StringName(data.get("current_action", "EVALUATE"))
    disciple.region_id = StringName(data.get("region_id", "sect"))
    disciple.target_region_id = StringName(data.get("target_region_id", ""))
    disciple.inventory = _int_dictionary(data.get("inventory", {}))
    disciple.pending_loot = _int_dictionary(data.get("pending_loot", {}))
    disciple.last_decision = data.get("last_decision", {}).duplicate(true)
    if disciple.last_decision.has("action"):
        disciple.last_decision["action"] = str(disciple.last_decision["action"])

    var saved_metrics = data.get("metrics", {})
    if saved_metrics is Dictionary:
        for key in disciple.metrics.keys():
            disciple.metrics[key] = int(saved_metrics.get(key, disciple.metrics[key]))

    return disciple

static func _int_dictionary(value: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if not (value is Dictionary):
        return normalized

    var keys: Array = value.keys()
    keys.sort()
    for key in keys:
        normalized[str(key)] = int(value[key])
    return normalized
