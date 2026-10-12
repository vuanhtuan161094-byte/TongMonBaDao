class_name VisualAssetRecord
extends RefCounted

# FE-01A: presentation candidate only. This is never an asset approval or gameplay state.
# The backing Dictionary is private. Callers receive deep-copy snapshots.
var _fields: Dictionary = {}


func _init(raw: Dictionary = {}) -> void:
    _fields = raw.duplicate(true)


func snapshot() -> Dictionary:
    return _fields.duplicate(true)


func value(key: String, fallback: Variant = null) -> Variant:
    var found: Variant = _fields.get(key, fallback)
    if found is Dictionary:
        return (found as Dictionary).duplicate(true)
    if found is Array:
        return (found as Array).duplicate(true)
    return found


func candidate_id() -> String:
    return str(_fields.get("candidate_id", ""))


func destination_id() -> String:
    return str(_fields.get("destination_id", ""))


func source_model_id() -> int:
    return int(_fields.get("source_model_id", -1))


func legacy_visual_asset_id() -> String:
    return str(_fields.get("legacy_visual_asset_id", ""))


func is_visual_analog() -> bool:
    return str(_fields.get("evidence_status", "")) == "INFERRED_VISUAL_ANALOG"


func is_renderable() -> bool:
    # FE-01A has no approved binary import. Never attempt ResourceLoader here.
    return false
