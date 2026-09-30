class_name DiscipleState
extends RefCounted

var id: StringName
var display_name: String
var max_hp: float = 100.0
var hp: float = 100.0
var stamina: float = 100.0
var wallet: int = 100
var combat_power: float = 18.0
var risk_bias: float = 0.5
var spend_bias: float = 0.5
var survival_bias: float = 0.5

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
    "actions": 0
}

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "disciple"))
    display_name = str(definition.get("name", id))
    wallet = int(definition.get("wallet", wallet))
    combat_power = float(definition.get("combat_power", combat_power))
    risk_bias = float(definition.get("risk_bias", risk_bias))
    spend_bias = float(definition.get("spend_bias", spend_bias))
    survival_bias = float(definition.get("survival_bias", survival_bias))

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
    return {
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
        "current_action": str(current_action),
        "region_id": str(region_id),
        "target_region_id": str(target_region_id),
        "inventory": inventory.duplicate(true),
        "pending_loot": pending_loot.duplicate(true),
        "last_decision": last_decision.duplicate(true),
        "metrics": metrics.duplicate(true)
    }

static func from_dict(data: Dictionary) -> DiscipleState:
    var disciple := DiscipleState.new({
        "id": data.get("id", "disciple"),
        "name": data.get("name", "Disciple"),
        "wallet": data.get("wallet", 0),
        "combat_power": data.get("combat_power", 18.0),
        "risk_bias": data.get("risk_bias", 0.5),
        "spend_bias": data.get("spend_bias", 0.5),
        "survival_bias": data.get("survival_bias", 0.5)
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
