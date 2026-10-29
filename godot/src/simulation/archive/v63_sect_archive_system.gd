class_name V63SectArchiveSystem
extends RefCounted

const CATALOGUE_PATH := "res://data/combat/v63_archive_catalog.json"
const SKILL_CATALOGUE_PATH := "res://data/combat/v63_content_registry.json"
const FRAGMENT_IDS := [
    "tmb.item.codex.fragment.human",
    "tmb.item.codex.fragment.immortal",
    "tmb.item.codex.fragment.divine",
    "tmb.item.codex.fragment.rare_divine"
]

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_archive_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["archive_catalogue_not_object"],"data":{}}
    var data: Dictionary = parsed
    var errors := validate_catalogue(data)
    return {"ok":errors.is_empty(),"errors":errors,"data":data}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 1 or bool(data.get("enabled",true)):
        errors.append("bad_archive_schema_or_release_gate")
    if typeof(data.get("codices",null)) != TYPE_ARRAY or typeof(data.get("warehouse_items",null)) != TYPE_ARRAY:
        errors.append("missing_archive_arrays")
        return errors
    var loaded_skills := V63ContentRegistry.load_catalogue(SKILL_CATALOGUE_PATH)
    if not bool(loaded_skills.get("ok",false)):
        errors.append("skill_catalogue_unavailable")
        return errors
    var skill_families: Dictionary = {}
    for family in loaded_skills.data.get("families",[]):
        skill_families[str(family.get("id",""))] = family
    var item_ids: Dictionary = {}
    var item_kinds: Dictionary = {}
    for item in data.warehouse_items:
        if not (item is Dictionary):
            errors.append("archive_item_not_object")
            continue
        var item_id := str(item.get("id",""))
        var kind := str(item.get("kind",""))
        if not _valid_id(item_id) or not item_id.begins_with("tmb.item.codex.") or item_ids.has(item_id):
            errors.append("bad_or_duplicate_archive_item:"+item_id)
        if not ["codex_manual","codex_fragment"].has(kind):
            errors.append("bad_archive_item_kind:"+item_id)
        if str(item.get("name","")).is_empty() or typeof(item.get("tags",null)) != TYPE_ARRAY:
            errors.append("bad_archive_item_definition:"+item_id)
        item_ids[item_id] = true
        item_kinds[item_id] = kind
    for fragment_id in FRAGMENT_IDS:
        if not item_ids.has(fragment_id) or str(item_kinds.get(fragment_id,"")) != "codex_fragment":
            errors.append("missing_archive_fragment_item:"+fragment_id)
    var codices: Array = data.codices
    if codices.size() != int(data.get("family_count",-1)) or codices.size() != 105:
        errors.append("wrong_archive_family_count")
    var codex_ids: Dictionary = {}
    var family_ids: Dictionary = {}
    var manual_ids: Dictionary = {}
    var archivable_count := 0
    for codex in codices:
        if not (codex is Dictionary):
            errors.append("codex_not_object")
            continue
        var codex_id := str(codex.get("id",""))
        var family_id := str(codex.get("family_id",""))
        var manual_id := str(codex.get("manual_item_id",""))
        if not _valid_id(codex_id) or not codex_id.begins_with("tmb.codex.") or codex_ids.has(codex_id):
            errors.append("bad_or_duplicate_codex_id:"+codex_id)
        if not skill_families.has(family_id) or family_ids.has(family_id):
            errors.append("bad_or_duplicate_source_family:"+family_id)
        else:
            var family: Dictionary = skill_families[family_id]
            var human_node := ""
            for node in family.get("nodes",[]):
                if str(node.get("tier","")) == "human":
                    human_node = str(node.get("id",""))
                    break
            var family_parts: PackedStringArray = family_id.split(".")
            var family_slot := str(family_parts[family_parts.size()-1]) if not family_parts.is_empty() else ""
            if str(codex.get("source_node_id","")) != human_node:
                errors.append("codex_source_not_human_root:"+codex_id)
            if str(codex.get("school","")) != str(family.get("school","")) or str(codex.get("slot","")) != family_slot:
                errors.append("codex_source_metadata_mismatch:"+codex_id)
        codex_ids[codex_id] = true
        family_ids[family_id] = true
        if bool(codex.get("archivable",false)):
            archivable_count += 1
            if not item_ids.has(manual_id) or str(item_kinds.get(manual_id,"")) != "codex_manual" or manual_ids.has(manual_id):
                errors.append("bad_or_duplicate_codex_manual:"+codex_id)
            if int(codex.get("restore_fragments_candidate",0)) <= 0 or str(codex.get("fragment_resource_id","")) not in FRAGMENT_IDS:
                errors.append("bad_restore_candidate:"+codex_id)
            manual_ids[manual_id] = true
        else:
            if not manual_id.is_empty() or int(codex.get("restore_fragments_candidate",-1)) != 0:
                errors.append("innate_codex_must_not_be_manual:"+codex_id)
    if archivable_count != int(data.get("archivable_count",-1)) or archivable_count != 96:
        errors.append("wrong_archivable_count")
    if item_ids.size() != manual_ids.size()+FRAGMENT_IDS.size():
        errors.append("orphan_or_duplicate_archive_item")
    if typeof(data.get("drop_profiles",null)) != TYPE_ARRAY or not data.drop_profiles.is_empty():
        errors.append("live_drop_profiles_not_authorized")
    return errors

static func resource_definitions() -> Dictionary:
    var loaded := load_catalogue()
    var result: Dictionary = {}
    if not bool(loaded.get("ok",false)):
        return result
    for item in loaded.data.get("warehouse_items",[]):
        var item_id := str(item.get("id",""))
        result[item_id] = {
            "name":str(item.get("name",item_id)),
            "family":"v63_codex_"+str(item.get("kind","")),
            "realm_grade":str(item.get("realm_grade","pham")),
            "realm_rank":maxi(int(item.get("realm_rank",0)),0),
            "market_value":0,
            "tags":item.get("tags",[]).duplicate(true)
        }
    return result

static func codices() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        return result
    for codex in loaded.data.get("codices",[]):
        result.append(codex.duplicate(true))
    return result

static func codex_definition(codex_id: String) -> Dictionary:
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        return {}
    for codex in loaded.data.get("codices",[]):
        if str(codex.get("id","")) == codex_id:
            return codex.duplicate(true)
    return {}

static func is_enabled(state: SimulationState, preview_overrides: Dictionary = {}) -> bool:
    return state != null and state.sect.v63_archive_opt_in and V63FeatureGates.is_enabled("sect_codex",preview_overrides)

static func transmission_available_for_disciple(state: SimulationState, disciple_id: StringName,
        codex_id: String, preview_overrides: Dictionary = {}) -> bool:
    if not is_enabled(state,preview_overrides) or not state.disciples.has(disciple_id):
        return false
    return bool(state.sect.v63_archived_codices.get(codex_id,false))

static func available_disciple_count(state: SimulationState, codex_id: String,
        preview_overrides: Dictionary = {}) -> int:
    if not is_enabled(state,preview_overrides) or not bool(state.sect.v63_archived_codices.get(codex_id,false)):
        return 0
    return state.disciples.size()

static func archive_manual(state: SimulationState, codex_id: String,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    var codex := codex_definition(codex_id)
    if codex.is_empty():
        return _failure("unknown_codex")
    if not bool(codex.get("archivable",false)):
        return _failure("codex_unlocked_by_branch_awakening")
    if bool(state.sect.v63_archived_codices.get(codex_id,false)):
        return {"ok":true,"reason":"already_archived","already_archived":true}
    var manual_id := StringName(codex.get("manual_item_id",""))
    var warehouse := WarehouseSystem.new()
    if not _canonical_warehouse_available(state) or warehouse.quantity(state,manual_id) <= 0:
        return _failure("complete_manual_missing_from_sect_warehouse")
    if not warehouse.consume(state,manual_id,1):
        return _failure("complete_manual_consume_failed")
    state.sect.v63_archived_codices[codex_id] = true
    state.sect.v63_archive_event_count += 1
    return {"ok":true,"reason":"transmission_archived","codex_id":codex_id,
        "available_to_disciples":state.disciples.size(),"remaining_manuals":warehouse.quantity(state,manual_id)}

static func donate_duplicate_manual(state: SimulationState, codex_id: String, request_id: String,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    var codex := codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable",false)):
        return _failure("unknown_or_unarchivable_codex")
    if not bool(state.sect.v63_archived_codices.get(codex_id,false)):
        return _failure("archive_first_complete_copy")
    var prior := _prior_operation(state,codex_id,request_id,"duplicate_research")
    if not prior.is_empty():
        return prior
    if not _valid_operation_id(request_id):
        return _failure("invalid_request_id")
    var warehouse := WarehouseSystem.new()
    var manual_id := StringName(codex.get("manual_item_id",""))
    if not _canonical_warehouse_available(state) or warehouse.quantity(state,manual_id) <= 0:
        return _failure("duplicate_manual_missing_from_sect_warehouse")
    if int(state.sect.v63_archive_research_progress.get(codex_id,0)) >= 2147483647:
        return _failure("research_counter_overflow")
    if not warehouse.consume(state,manual_id,1):
        return _failure("duplicate_manual_consume_failed")
    var progress := int(state.sect.v63_archive_research_progress.get(codex_id,0))+1
    state.sect.v63_archive_research_progress[codex_id] = progress
    state.sect.v63_archive_operation_index += 1
    var receipt := {"request_id":request_id,"operation":"duplicate_research","codex_id":codex_id,
        "research_points":1,"total_research":progress}
    state.sect.v63_archive_operation_receipts[request_id] = receipt
    state.sect.v63_archive_event_count += 1
    return {"ok":true,"reason":"duplicate_donated_to_research","receipt":receipt.duplicate(true)}

static func restore_manual_from_fragments(state: SimulationState, codex_id: String, request_id: String,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    var codex := codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable",false)):
        return _failure("unknown_or_unarchivable_codex")
    var prior := _prior_operation(state,codex_id,request_id,"fragment_restoration")
    if not prior.is_empty():
        return prior
    if not _valid_operation_id(request_id):
        return _failure("invalid_request_id")
    var fragment_id := StringName(codex.get("fragment_resource_id",""))
    var fragment_count := int(codex.get("restore_fragments_candidate",0))
    if fragment_count <= 0:
        return _failure("invalid_restore_candidate")
    if not _canonical_warehouse_available(state):
        return _failure("canonical_warehouse_disabled")
    var manual_id := StringName(codex.get("manual_item_id",""))
    var warehouse := WarehouseSystem.new()
    if warehouse.quantity(state,manual_id) >= warehouse.MAX_SAFE_STACK:
        return _failure("warehouse_overflow")
    var requirements := {str(fragment_id):fragment_count}
    if not warehouse.can_consume_requirements(state,requirements,true):
        return _failure("insufficient_codex_fragments")
    var old_resources: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var old_warehouse_events := state.sect.warehouse_event_count
    if not warehouse.consume_requirements(state,requirements,true) or not warehouse.add(state,manual_id,1):
        state.sect.warehouse_resources = old_resources
        state.sect.warehouse_event_count = old_warehouse_events
        return _failure("restoration_transaction_failed")
    state.sect.v63_archive_operation_index += 1
    var receipt := {"request_id":request_id,"operation":"fragment_restoration","codex_id":codex_id,
        "fragment_id":str(fragment_id),"fragments_consumed":fragment_count,"manual_item_id":str(manual_id)}
    state.sect.v63_archive_operation_receipts[request_id] = receipt
    state.sect.v63_archive_event_count += 1
    return {"ok":true,"reason":"manual_restored","receipt":receipt.duplicate(true),
        "manual_quantity":warehouse.quantity(state,manual_id)}

static func encounter_reward_items(state: SimulationState, spawn_data: Dictionary,
        preview_overrides: Dictionary = {}) -> Dictionary:
    return _validated_reward_items(state,spawn_data.get("v63_codex_rewards",{}),preview_overrides)

static func kill_reward_items(state: SimulationState, spawn_data: Dictionary, event: Dictionary,
        preview_overrides: Dictionary = {}) -> Dictionary:
    var raw_table = spawn_data.get("v63_codex_drop_table",{})
    if not (raw_table is Dictionary):
        return _failure("codex_drop_table_not_object")
    var species_id := str(event.get("species_id",""))
    var raw_items = raw_table.get(species_id,{})
    return _validated_reward_items(state,raw_items,preview_overrides)

static func settle_codex_kill_drop_once(state: SimulationState, encounter_id: String,
        kill_id: String, source_id: String, items: Dictionary,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if encounter_id.is_empty() or kill_id.is_empty() or source_id.is_empty():
        return _failure("invalid_kill_receipt_identity")
    if not kill_id.begins_with(encounter_id+":"):
        return _failure("kill_receipt_wrong_encounter")
    return _settle_resources_once(state,kill_id,encounter_id,source_id,items,"kill",preview_overrides)

static func record_victory_codex_receipt(state: SimulationState, encounter_id: String,
        items: Dictionary, preview_overrides: Dictionary = {}) -> Dictionary:
    if items.is_empty():
        return {"ok":true,"recorded":false}
    if encounter_id.is_empty():
        return _failure("invalid_encounter_receipt_identity")
    return _record_claim_receipt(state,encounter_id+":victory",encounter_id,"victory",items,preview_overrides)

static func _settle_resources_once(state: SimulationState, receipt_id: String,
        encounter_id: String, source_id: String, items: Dictionary, kind: String,
        preview_overrides: Dictionary) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    var normalized := _normalize_reward_items(state,items)
    if not bool(normalized.get("ok",false)):
        return normalized
    var values: Dictionary = normalized.get("items",{})
    var existing = state.sect.v63_codex_drop_receipts.get(receipt_id,null)
    if existing != null:
        if not (existing is Dictionary) or str(existing.get("encounter_id","")) != encounter_id or str(existing.get("source_id","")) != source_id or existing.get("items",{}) != values:
            return _failure("codex_receipt_id_collision")
        return {"ok":true,"reason":"already_settled","duplicate":true,"receipt":existing.duplicate(true)}
    if values.is_empty():
        return {"ok":true,"reason":"no_codex_reward","rewards_granted":false}
    var warehouse := WarehouseSystem.new()
    var old_resources: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var old_events := state.sect.warehouse_event_count
    if not _preflight_resources(state,values):
        return _failure("codex_reward_preflight_failed")
    for raw_id in values.keys():
        if not warehouse.add(state,StringName(raw_id),int(values[raw_id])):
            state.sect.warehouse_resources = old_resources
            state.sect.warehouse_event_count = old_events
            return _failure("codex_reward_commit_failed")
    var receipt := {"version":1,"kind":kind,"receipt_id":receipt_id,"encounter_id":encounter_id,
        "source_id":source_id,"items":values.duplicate(true)}
    state.sect.v63_codex_drop_receipts[receipt_id] = receipt
    state.sect.v63_archive_event_count += 1
    return {"ok":true,"reason":"codex_reward_settled","duplicate":false,"receipt":receipt.duplicate(true)}

static func _record_claim_receipt(state: SimulationState, receipt_id: String,
        encounter_id: String, source_id: String, items: Dictionary,
        preview_overrides: Dictionary) -> Dictionary:
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    if state.sect.v63_codex_drop_receipts.has(receipt_id):
        return _failure("codex_receipt_already_exists")
    var normalized := _normalize_reward_items(state,items)
    if not bool(normalized.get("ok",false)) or normalized.get("items",{}).is_empty():
        return normalized if not bool(normalized.get("ok",false)) else _failure("empty_codex_receipt")
    var receipt := {"version":1,"kind":"victory","receipt_id":receipt_id,
        "encounter_id":encounter_id,"source_id":source_id,"items":normalized.items.duplicate(true)}
    state.sect.v63_codex_drop_receipts[receipt_id] = receipt
    state.sect.v63_archive_event_count += 1
    return {"ok":true,"receipt":receipt.duplicate(true)}

static func _validated_reward_items(state: SimulationState, raw_items: Variant,
        preview_overrides: Dictionary) -> Dictionary:
    if not (raw_items is Dictionary):
        return _failure("codex_rewards_not_object")
    if raw_items.is_empty():
        return {"ok":true,"items":{}}
    if not is_enabled(state,preview_overrides):
        return _failure("sect_codex_disabled")
    return _normalize_reward_items(state,raw_items)

static func _normalize_reward_items(state: SimulationState, raw_items: Dictionary) -> Dictionary:
    if not _canonical_warehouse_available(state):
        return _failure("canonical_warehouse_disabled")
    var registry := ResourceRegistry.new()
    var normalized: Dictionary = {}
    var keys: Array = raw_items.keys()
    keys.sort()
    for raw_id in keys:
        var id := StringName(raw_id)
        var amount := int(raw_items[raw_id])
        if amount <= 0 or float(raw_items[raw_id]) != float(amount):
            return _failure("invalid_codex_reward_quantity")
        if not registry.has(id) or not registry.has_tag(id,&"v63_codex_reward"):
            return _failure("unregistered_codex_reward:"+str(id))
        normalized[str(id)] = amount
    return {"ok":true,"items":normalized}

static func _canonical_warehouse_available(state: SimulationState) -> bool:
    return state != null and state.p3_7_buildings_enabled and state.sect.p3_7_resources_enabled

static func _preflight_resources(state: SimulationState, items: Dictionary) -> bool:
    var warehouse := WarehouseSystem.new()
    for raw_id in items.keys():
        var id := StringName(raw_id)
        var amount := int(items[raw_id])
        if amount <= 0 or amount > warehouse.MAX_SAFE_STACK-warehouse.quantity(state,id):
            return false
    return true

static func _prior_operation(state: SimulationState, codex_id: String, request_id: String,
        operation: String) -> Dictionary:
    if not state.sect.v63_archive_operation_receipts.has(request_id):
        return {}
    var receipt = state.sect.v63_archive_operation_receipts[request_id]
    if not (receipt is Dictionary) or str(receipt.get("codex_id","")) != codex_id or str(receipt.get("operation","")) != operation:
        return _failure("request_id_collision")
    return {"ok":true,"reason":"already_committed","duplicate":true,"receipt":receipt.duplicate(true)}

static func validate_state(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if state == null:
        errors.append("V6.3 archive state is missing.")
        return errors
    var loaded := load_catalogue()
    if not bool(loaded.get("ok",false)):
        errors.append("V6.3 archive catalogue is invalid.")
        return errors
    var known_codices: Dictionary = {}
    for codex in loaded.data.codices:
        known_codices[str(codex.get("id",""))] = true
    for codex_id in state.sect.v63_archived_codices.keys():
        if not known_codices.has(str(codex_id)) or not bool(state.sect.v63_archived_codices[codex_id]):
            errors.append("Invalid archived codex %s." % str(codex_id))
    for codex_id in state.sect.v63_archive_research_progress.keys():
        if not known_codices.has(str(codex_id)) or int(state.sect.v63_archive_research_progress[codex_id]) < 0:
            errors.append("Invalid archive research progress %s." % str(codex_id))
    if state.sect.v63_archive_event_count < 0 or state.sect.v63_archive_operation_index < 0:
        errors.append("V6.3 archive event counter is negative.")
    for request_id in state.sect.v63_archive_operation_receipts.keys():
        var receipt = state.sect.v63_archive_operation_receipts[request_id]
        if not _valid_operation_id(str(request_id)) or not (receipt is Dictionary) or not known_codices.has(str(receipt.get("codex_id",""))):
            errors.append("Invalid archive operation receipt %s." % str(request_id))
    var registry := ResourceRegistry.new()
    for receipt_id in state.sect.v63_codex_drop_receipts.keys():
        var receipt = state.sect.v63_codex_drop_receipts[receipt_id]
        if str(receipt_id).is_empty() or not (receipt is Dictionary) or typeof(receipt.get("items",null)) != TYPE_DICTIONARY:
            errors.append("Invalid codex drop receipt %s." % str(receipt_id))
            continue
        for raw_id in receipt.items.keys():
            var item_id := StringName(raw_id)
            if not registry.has(item_id) or not registry.has_tag(item_id,&"v63_codex_reward") or int(receipt.items[raw_id]) <= 0:
                errors.append("Invalid codex reward in receipt %s." % str(receipt_id))
    return errors

static func _valid_operation_id(value: String) -> bool:
    if value.is_empty() or value.length() > 160:
        return false
    for ch in value:
        if not "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:._-".contains(ch):
            return false
    return true

static func _valid_id(value: String) -> bool:
    if not value.begins_with("tmb.") or value.ends_with(".") or value.find("..") >= 0:
        return false
    for ch in value:
        if not "abcdefghijklmnopqrstuvwxyz0123456789_.".contains(ch):
            return false
    return true

static func _failure(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}

