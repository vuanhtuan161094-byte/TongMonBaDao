class_name VisualAssetRegistry
extends RefCounted

# FE-01A: read-only candidate lookup. P3_ASSET_REGISTRY.json is the approval authority.
const DEFAULT_MANIFEST_PATH := "res://data/presentation/source_a_candidate_manifest.json"

var _candidates: Dictionary = {}
var _destinations: Dictionary = {}
var _valid := false
var _errors: PackedStringArray = PackedStringArray()


static func load_default() -> VisualAssetRegistry:
    var file := FileAccess.open(DEFAULT_MANIFEST_PATH, FileAccess.READ)
    if file == null:
        var unavailable := VisualAssetRegistry.new()
        unavailable._errors.append("Missing candidate manifest")
        return unavailable
    var raw: Variant = JSON.parse_string(file.get_as_text())
    if not (raw is Dictionary):
        var invalid := VisualAssetRegistry.new()
        invalid._errors.append("Malformed JSON candidate manifest")
        return invalid
    return from_dictionary(raw)


static func from_dictionary(raw: Dictionary) -> VisualAssetRegistry:
    var result := VisualAssetRegistry.new()
    result._build(raw)
    return result


func _reject(why: String) -> void:
    _candidates.clear()
    _destinations.clear()
    _valid = false
    _errors.append(why)


func _build(raw: Dictionary) -> void:
    if int(raw.get("schema_version", -1)) != 1:
        _reject("Unsupported manifest schema")
        return
    if str(raw.get("authority_registry", "")) != "docs/P3_ASSET_REGISTRY.json":
        _reject("Candidate data must defer to canonical P3 registry")
        return
    if str(raw.get("binary_transport", "")) != "NOT_APPROVED" or str(raw.get("runtime_asset_import", "")) != "NONE":
        _reject("FE-01A cannot import binaries or enable transport")
        return
    if str(raw.get("release_policy", "")) != "INTERNAL_LAB_ONLY_UNTIL_RIGHTS_VERIFIED":
        _reject("Source A release rights have not been verified")
        return
    var items: Variant = raw.get("candidates", null)
    if not (items is Array) or (items as Array).size() != 13:
        _reject("Expected exactly 13 candidate entries")
        return
    var analog_count := 0
    for raw_item in items:
        if not (raw_item is Dictionary):
            _reject("Candidate entry is not a Dictionary")
            return
        var item: Dictionary = raw_item
        var id := str(item.get("candidate_id", ""))
        var dest := str(item.get("destination_id", ""))
        var evidence := str(item.get("evidence_status", ""))
        var deps: Variant = item.get("source_dependencies", null)
        if not id.begins_with("candidate.source_a.building.") or dest.is_empty():
            _reject("Invalid candidate identity")
            return
        if _candidates.has(id) or _destinations.has(dest):
            _reject("Duplicate candidate ID or destination")
            return
        if evidence != "VERIFIED" and evidence != "INFERRED_VISUAL_ANALOG":
            _reject("Invalid source-evidence classification")
            return
        if evidence == "INFERRED_VISUAL_ANALOG":
            analog_count += 1
        if str(item.get("visual_status", "")) != "CANDIDATE_NOT_APPROVED":
            _reject("An unapproved visual cannot be promoted by this manifest")
            return
        if bool(item.get("binary_imported", true)) or not str(item.get("runtime_resource_path", "")).is_empty():
            _reject("Binary import or runtime path is forbidden in FE-01A")
            return
        if str(item.get("release_rights", "")) != "UNVERIFIED":
            _reject("Unproven release rights must remain UNVERIFIED")
            return
        if int(item.get("source_model_id", -1)) < 1:
            _reject("Missing Source A model ID")
            return
        if not (deps is Array) or (deps as Array).size() < 3:
            _reject("Source dependencies are missing")
            return
        var widths: Variant = item.get("footprint", null)
        if not (widths is Array) or (widths as Array).size() != 2:
            _reject("Invalid presentation footprint metadata")
            return
        var door: Variant = item.get("doorway_offset", null)
        if not (door is Array) or (door as Array).size() != 2:
            _reject("Invalid doorway metadata")
            return
        var candidate := VisualAssetRecord.new(item)
        _candidates[id] = candidate
        _destinations[dest] = id
    if analog_count != 3:
        _reject("Exactly 3 visual analogs are expected")
        return
    _valid = true


func is_valid() -> bool:
    return _valid


func errors() -> PackedStringArray:
    return _errors.duplicate()


func candidate_count() -> int:
    return _candidates.size() if _valid else 0


func candidate(candidate_id: String) -> Dictionary:
    if not _valid or not _candidates.has(candidate_id):
        return {}
    var rec: VisualAssetRecord = _candidates[candidate_id]
    return rec.snapshot()


func for_destination(destination_id: String) -> Dictionary:
    if not _valid or not _destinations.has(destination_id):
        return {}
    return candidate(str(_destinations[destination_id]))


func candidates_for_source_model(source_model_id: int) -> Array[Dictionary]:
    var matches: Array[Dictionary] = []
    if not _valid:
        return matches
    var keys: Array = _candidates.keys()
    keys.sort()
    for key in keys:
        var rec: VisualAssetRecord = _candidates[key]
        if rec.source_model_id() == source_model_id:
            matches.append(rec.snapshot())
    return matches


func resolve_destination(destination_id: String) -> Dictionary:
    if not _valid:
        return {"status": "MANIFEST_INVALID", "resource_path": "", "fallback_asset_id": ""}
    var raw: Dictionary = for_destination(destination_id)
    if raw.is_empty():
        return {"status": "UNMAPPED", "resource_path": "", "fallback_asset_id": ""}
    # S3 fallback IDs express historical design identities, NOT readable textures.
    return {
        "status": "FALLBACK_ONLY",
        "candidate_id": str(raw["candidate_id"]),
        "destination_id": destination_id,
        "source_model_id": int(raw["source_model_id"]),
        "fallback_asset_id": str(raw.get("legacy_visual_asset_id", "")),
        "resource_path": "",
        "source_evidence_status": str(raw["evidence_status"])
    }
