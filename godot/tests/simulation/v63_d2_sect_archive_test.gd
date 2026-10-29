extends SceneTree

const PREVIEW := {"sect_codex":true}

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("V63_D2_ARCHIVE_FAIL: "+detail)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _check(not V63FeatureGates.is_enabled("sect_codex"),"archive release gate must default OFF"): return
    var loaded := V63SectArchiveSystem.load_catalogue()
    if not _check(bool(loaded.get("ok",false)),"archive catalogue errors: "+str(loaded.get("errors",[]))): return
    var data: Dictionary = loaded.data
    if not _check(data.codices.size()==159 and int(data.archivable_count)==150,"archive must cover 105 Human codices plus 18 Immortal, 18 Divine and 18 rare lineage codices without selling innate slots"): return
    var immortal_codices: Array = data.codices.filter(func(row: Dictionary): return str(row.get("generation", "")) == "immortal" and bool(row.get("archivable", false)))
    if not _check(immortal_codices.size()==18,"archive must expose both manual-backed Immortal lineage paths for all nine branches"): return
    if not _check(data.drop_profiles.is_empty(),"unapproved live drop rates appeared in D2"): return
    var invalid: Dictionary = data.duplicate(true)
    invalid.enabled = true
    if not _check(not V63SectArchiveSystem.validate_catalogue(invalid).is_empty(),"release-enabled D2 catalog must fail closed"): return

    var state := SimulationState.new()
    state.sect.disciple_capacity = 128
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    for i in range(128):
        var disciple := DiscipleState.new()
        disciple.id = StringName("d2_disciple_%03d" % i)
        state.disciples[disciple.id] = disciple

    var chosen: Dictionary = {}
    for codex in data.codices:
        if bool(codex.get("archivable",false)):
            chosen = codex
            break
    if not _check(not chosen.is_empty(),"no archivable Human transmission"): return
    var codex_id := str(chosen.id)
    var manual_id := StringName(chosen.manual_item_id)
    var warehouse := WarehouseSystem.new()
    if not _check(warehouse.registry.has(manual_id),"codex manual missing from canonical ResourceRegistry"): return
    if not _check(warehouse.add(state,manual_id,1),"could not seed the first complete manual into the Sect Warehouse"): return
    var archived := V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW)
    if not _check(bool(archived.get("ok",false)) and bool(state.sect.v63_archived_codices.get(codex_id,false)),"first manual did not permanently archive the transmission"): return
    if not _check(warehouse.quantity(state,manual_id)==0,"the archived source copy remained duplicated in the Warehouse"): return
    if not _check(V63SectArchiveSystem.available_disciple_count(state,codex_id,PREVIEW)==128,"archived transmission was not available to 100+ disciples"): return
    for disciple_id in state.disciples.keys():
        if not _check(V63SectArchiveSystem.transmission_available_for_disciple(state,StringName(disciple_id),codex_id,PREVIEW),"archived transmission unavailable to "+str(disciple_id)): return
    var second_archive := V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW)
    if not _check(bool(second_archive.get("already_archived",false)) and warehouse.quantity(state,manual_id)==0,"repeat archival consumed or granted another source copy"): return

    if not _check(warehouse.add(state,manual_id,2),"could not seed duplicate books"): return
    var donated := V63SectArchiveSystem.donate_duplicate_manual(state,codex_id,"archive-research:1",PREVIEW)
    if not _check(bool(donated.get("ok",false)) and int(state.sect.v63_archive_research_progress[codex_id])==1,"duplicate book did not produce one research point"): return
    var donated_again := V63SectArchiveSystem.donate_duplicate_manual(state,codex_id,"archive-research:1",PREVIEW)
    if not _check(bool(donated_again.get("duplicate",false)) and warehouse.quantity(state,manual_id)==1 and int(state.sect.v63_archive_research_progress[codex_id])==1,"duplicate research request settled twice"): return

    var fragment_id := StringName(chosen.fragment_resource_id)
    var required := int(chosen.restore_fragments_candidate)
    if not _check(warehouse.add(state,fragment_id,required),"could not seed restoration fragments"): return
    if not _check(warehouse.set_rule(state,fragment_id,0,true),"could not lock restoration fragments for policy test"): return
    var locked_resources: Dictionary = state.sect.warehouse_resources.duplicate(true)
    var locked_restore := V63SectArchiveSystem.restore_manual_from_fragments(state,codex_id,"archive-restore:locked",PREVIEW)
    if not _check(not bool(locked_restore.get("ok",false)) and state.sect.warehouse_resources==locked_resources,"fragment restoration bypassed a Warehouse lock"): return
    if not _check(warehouse.set_rule(state,fragment_id,0,false),"could not unlock restoration fragments"): return
    var restored := V63SectArchiveSystem.restore_manual_from_fragments(state,codex_id,"archive-restore:1",PREVIEW)
    if not _check(bool(restored.get("ok",false)) and warehouse.quantity(state,manual_id)==2 and warehouse.quantity(state,fragment_id)==0,"fragment restoration did not atomically create exactly one book"): return
    var restored_again := V63SectArchiveSystem.restore_manual_from_fragments(state,codex_id,"archive-restore:1",PREVIEW)
    if not _check(bool(restored_again.get("duplicate",false)) and warehouse.quantity(state,manual_id)==2,"restoration retry duplicated a manual"): return

    var errors := V63SectArchiveSystem.validate_state(state)
    if not _check(errors.is_empty(),"archive invariant errors: "+str(errors)): return
    var encoded := state.to_dict()
    var restored_state := SimulationState.from_dict(encoded)
    if not _check(restored_state.sect.v63_archive_opt_in and restored_state.sect.v63_archived_codices==state.sect.v63_archived_codices,"Sect Archive ownership did not round-trip"): return
    if not _check(restored_state.sect.v63_archive_operation_receipts==state.sect.v63_archive_operation_receipts and restored_state.sect.v63_archive_research_progress==state.sect.v63_archive_research_progress,"archive research/operation receipts did not round-trip"): return
    if not _check(restored_state.sect.warehouse_resources==state.sect.warehouse_resources,"canonical warehouse inventory did not round-trip"): return

    var legacy_sect := SectState.new()
    var legacy_data := legacy_sect.to_dict()
    if not _check(not legacy_data.has("v63_archive_opt_in") and not SectState.from_dict(legacy_data).v63_archive_opt_in,"legacy save was not left dormant by additive defaults"): return
    var gate_off := SimulationState.new()
    gate_off.sect.v63_archive_opt_in = true
    if not _check(not V63SectArchiveSystem.is_enabled(gate_off),"state opt-in bypassed the OFF release gate"): return
    var warehouse_gate_off := SimulationState.new()
    warehouse_gate_off.sect.v63_archive_opt_in = true
    var rejected_warehouse := V63SectArchiveSystem.settle_codex_kill_drop_once(
        warehouse_gate_off,"d2-disabled-warehouse","d2-disabled-warehouse:kill:1","species",
        {str(fragment_id):1},PREVIEW)
    if not _check(not bool(rejected_warehouse.get("ok",false)) and warehouse_gate_off.sect.warehouse_resources.is_empty(),"archive wrote through the canonical Warehouse while P3.7 building authority was disabled"): return
    print("V63_D2_ARCHIVE_PASS: 159 codices, 150 book sources, 128 disciples, warehouse restoration/research receipts and save round-trip")
    quit(0)

