class_name DiscipleBodyGateContentV2
extends RefCounted

# DV2-03F/F1: versioned, read-only 29-gate Body tempering CONTENT ONLY.
# Never grants loot, proves acquisition, spends warehouse items or advances Body.
# The F2 authoritative transaction and F3 real sources are NOT implemented here.
const VERSION := 1
const GATE_COUNT := 29
const CONTENT_AVAILABLE := false # F1 is metadata-only. NEVER a live gate switch.

const GROUP_ITEMS := {
    "A": ["thanh_linh_thao", "tinh_lang_bi"],
    "B": ["tu_van_thao", "linh_tuy"],
    "C": ["huyet_linh_sam", "huyet_thu_tinh_huyet"],
    "D": ["kim_cot_thao", "linh_thu_cot_ngoc"],
    "E": ["tien_tuy_lien", "tien_thu_chan_cot"],
    "F": ["bat_hoai_tuy_dich", "dai_la_kim_cot"],
    "G": ["than_mach_tinh", "than_thu_cot"],
    "H": ["hon_don_tuy_hoa", "bat_diet_than_cot"]
}
const GATE_SEALS := {10: "an_nhan_gioi", 20: "an_tien_gioi", 29: "an_than_gioi"}

# EXACT row order from section D of the reviewed F1 contract.
# Index 0 = source Body realm 1. Tu Vi is deliberately not a prerequisite.
# [group, main quantity, auxiliary quantity]
const ROWS := [
    ["A", 12, 4], ["A", 18, 5], ["A", 24, 6],
    ["B", 12, 1], ["B", 16, 2], ["B", 24, 3],
    ["C", 12, 3], ["C", 16, 4], ["C", 22, 6], ["C", 32, 8],
    ["D", 12, 3], ["D", 16, 4], ["D", 20, 5], ["D", 24, 6],
    ["E", 12, 3], ["E", 16, 4], ["E", 22, 6],
    ["F", 14, 4], ["F", 20, 6], ["F", 30, 9],
    ["G", 12, 3], ["G", 16, 4], ["G", 20, 5], ["G", 24, 6], ["G", 30, 8],
    ["H", 12, 3], ["H", 18, 5], ["H", 24, 7], ["H", 32, 10]
]

static func recipe(source_realm: int) -> Dictionary:
    if source_realm < 1 or source_realm > GATE_COUNT:
        return {}
    var row: Array = ROWS[source_realm - 1]
    var pair: Array = GROUP_ITEMS[str(row[0])]
    var seal_id := str(GATE_SEALS.get(source_realm, ""))
    # Every lookup returns a NEW value dictionary: no mutable shared recipe.
    return {
        "version": VERSION,
        "source_realm": source_realm,
        "target_realm": source_realm + 1,
        "group": str(row[0]),
        "main_id": str(pair[0]),
        "main_qty": int(row[1]),
        "aux_id": str(pair[1]),
        "aux_qty": int(row[2]),
        "seal_id": seal_id,
        "seal_qty": 1 if not seal_id.is_empty() else 0,
        "content_available": false,
        "reason": "content_unavailable"
    }

static func all_recipes() -> Array:
    var result: Array = []
    for source_realm in range(1, GATE_COUNT + 1):
        result.append(recipe(source_realm))
    return result

static func material_ids() -> Array:
    var result: Array = []
    for group_id in GROUP_ITEMS.keys():
        for item_id in GROUP_ITEMS[group_id]:
            if not result.has(str(item_id)):
                result.append(str(item_id))
    for seal_id in GATE_SEALS.values():
        if not result.has(str(seal_id)):
            result.append(str(seal_id))
    result.sort()
    return result

static func validate_manifest(raw: Variant) -> Dictionary:
    if not (raw is Array):
        return {"ok": false, "reason": "invalid_body_gate_manifest"}
    var data: Array = raw
    if data.size() != GATE_COUNT or ROWS.size() != GATE_COUNT:
        return {"ok": false, "reason": "invalid_body_gate_count"}
    var totals := {"main": 0, "aux": 0, "seals": 0}
    var seals_seen: Dictionary = {}
    for index in range(GATE_COUNT):
        var candidate = data[index]
        if not (candidate is Dictionary):
            return {"ok": false, "reason": "invalid_body_gate_row", "realm": index + 1}
        var expected := recipe(index + 1)
        # Compare all 11 required fields; reject unauthorized extra keys.
        if candidate.size() != expected.size():
            return {"ok": false, "reason": "invalid_body_gate_row_schema", "realm": index + 1}
        for field in expected.keys():
            if not candidate.has(field) or candidate[field] != expected[field]:
                return {"ok": false, "reason": "body_gate_row_changed", "realm": index + 1, "field": field}
            if field in ["version", "source_realm", "target_realm", "main_qty", "aux_qty", "seal_qty"] and not (candidate[field] is int):
                return {"ok": false, "reason": "invalid_body_gate_numeric_type", "realm": index + 1}
        totals["main"] += int(candidate["main_qty"])
        totals["aux"] += int(candidate["aux_qty"])
        totals["seals"] += int(candidate["seal_qty"])
        if int(candidate["seal_qty"]) > 0:
            var seal_id := str(candidate["seal_id"])
            if seals_seen.has(seal_id):
                return {"ok": false, "reason": "duplicate_body_gate_seal"}
            seals_seen[seal_id] = true
    if totals["main"] != 562 or totals["aux"] != 143 or totals["seals"] != 3 or seals_seen.size() != 3:
        return {"ok": false, "reason": "body_gate_manifest_totals_changed"}
    return {"ok": true, "version": VERSION, "gates": GATE_COUNT,
        "main": totals["main"], "aux": totals["aux"], "seals": totals["seals"]}

static func validate_registry() -> Dictionary:
    var registry := ResourceRegistry.new()
    if GROUP_ITEMS.size() != 8 or GATE_SEALS.size() != 3 or material_ids().size() != 19:
        return {"ok": false, "reason": "body_gate_resource_identity_count"}
    for item_id in material_ids():
        if not registry.has(StringName(item_id)):
            return {"ok": false, "reason": "unregistered_body_gate_resource", "item_id": item_id}
        var definition := registry.definition(StringName(item_id))
        if str(definition.get("family", "")).is_empty() or
            str(definition.get("realm_grade", "")).is_empty() or
            int(definition.get("realm_rank", -1)) < 0 or
            not (definition.get("tags", null) is Array) or
            not (definition.get("market_value", null) is int):
            return {"ok": false, "reason": "invalid_body_gate_resource_metadata", "item_id": item_id}
    for seal_id in GATE_SEALS.values():
        if not registry.has_tag(StringName(seal_id), &"body_gate_seal"):
            return {"ok": false, "reason": "untyped_body_gate_seal", "item_id": seal_id}
    return {"ok": true, "count": 19, "groups": 8, "seals": 3}

static func validate() -> Dictionary:
    var manifest := validate_manifest(all_recipes())
    if not bool(manifest.get("ok", false)):
        return manifest
    return validate_registry()
