class_name GameRng
extends RefCounted

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(seed_value: int = 1337) -> void:
    _rng.seed = seed_value

func reseed(seed_value: int) -> void:
    _rng.seed = seed_value

func randf() -> float:
    return _rng.randf()

func randf_range(min_value: float, max_value: float) -> float:
    return _rng.randf_range(min_value, max_value)

func randi_range(min_value: int, max_value: int) -> int:
    return _rng.randi_range(min_value, max_value)

func chance(probability: float) -> bool:
    return _rng.randf() < clampf(probability, 0.0, 1.0)

func weighted_pick(weights: Dictionary) -> StringName:
    var keys: Array = weights.keys()
    keys.sort()

    var total := 0.0
    for key in keys:
        total += maxf(float(weights[key]), 0.0)
    if total <= 0.0:
        return StringName()

    var roll := _rng.randf_range(0.0, total)
    var cursor := 0.0
    for key in keys:
        cursor += maxf(float(weights[key]), 0.0)
        if roll <= cursor:
            return StringName(key)

    return StringName(keys.back())

func snapshot_seed_state() -> int:
    return _rng.state

func restore_seed_state(state_value: int) -> void:
    _rng.state = state_value
