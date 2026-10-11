extends SceneTree

# F2-only QA fixture: override the *internal* content readiness in this test.
# Real production DiscipleBodyGateTransactionV2 remains fail-closed until F3.
class SourceFixture:
    extends DiscipleBodyGateTransactionV2
    func _content_ready(_state: SimulationState, _recipe: Dictionary) -> bool:
        return true

class FailedCommitFixture:
    extends SourceFixture
    func _after_debit(_state: SimulationState, _disciple: DiscipleState) -> bool:
        return false

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("DV2-03F/F2: "+reason)
        quit(1)
        return false
    return true

func _recruit(state: SimulationState, index: int) -> DiscipleState:
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,index
    )
    state.recruitment_candidates[candidate.id] = candidate
    var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
    if not bool(accepted.get("ok",false)):
        return null
    return state.disciples[candidate.id]

func _ready(disciple: DiscipleState, realm: int) -> void:
    var body: Dictionary = disciple.v2_realm_progress["body"]
    body["realm"] = realm
    body["floor"] = 10
    body["xp"] = float(DiscipleProgressionBalanceV2.floor_cost(realm,10))
    disciple.current_action = &"EVALUATE"
    disciple.region_id = &"sect"

func _fund(state: SimulationState, realm: int) -> bool:
    var recipe := DiscipleBodyGateContentV2.recipe(realm)
    var store := WarehouseSystem.new()
    if not store.add(state,StringName(recipe["main_id"]),int(recipe["main_qty"])):
        return false
    if not store.add(state,StringName(recipe["aux_id"]),int(recipe["aux_qty"])):
        return false
    if int(recipe["seal_qty"]) > 0:
        if not store.add(state,StringName(recipe["seal_id"]),1):
            return false
    return true

func _same_state(state: SimulationState, disciple: DiscipleState,
        materials: Dictionary, events: int, progress: Dictionary,
        old_hp: float, old_max_hp: float) -> bool:
    return (state.sect.warehouse_resources == materials and
        state.sect.warehouse_event_count == events and
        disciple.v2_realm_progress == progress and
        absf(disciple.hp-old_hp) < 0.001 and
        absf(disciple.max_hp-old_max_hp) < 0.001)

func _run() -> void:
    var state := P37Factory.create_state(120044)
    state.sect.disciple_v2_birth_enabled = true
    var first := _recruit(state,510)
    var second := _recruit(state,511)
    if not _check(first!=null and second!=null and
        DiscipleRealmProgressV2.progression_ready(first),
        "Genuine V2 disciples could not be recruited."):
        return

    var locked := DiscipleBodyGateTransactionV2.new()
    var fixture := SourceFixture.new()
    var store := WarehouseSystem.new()
    # Old save defaults: no retroactive gate receipt, no free material.
    var old_save := SimulationState.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
    if not _check(old_save != null and old_save.sect.v2_body_gate_receipts.is_empty() and
        old_save.sect.v2_body_gate_request_index.is_empty() and
        not state.sect.to_dict().has("v2_body_gate_receipts"),
        "Legacy F1 save was not migrated to empty F2 receipt state."):
        return

    # Normal production can preview actual requirements but never act on
    # F1-only metadata, even after QA grants enough stock and XP.
    _ready(first,1)
    if not _check(_fund(state,1),"Could not seed isolated F2 warehouse fixture."):
        return
    var sealed := locked.preview_gate(state,first.id)
    var before_locked := JSON.stringify(state.to_dict())
    var denied := locked.commit_gate(state,first.id,"qa-prod-must-deny")
    if not _check(bool(sealed.get("ok",false)) and
        not bool(sealed.get("can_commit",true)) and
        str(sealed.get("reason",""))=="content_unavailable" and
        str(denied.get("reason",""))=="content_unavailable" and
        JSON.stringify(state.to_dict())==before_locked,
        "F2 production accidentally unlocked a Body gate or mutated preview state."):
        return

    # Real floor-10/EXP authority (no Tu Vi equality) and named requirements.
    first.v2_realm_progress["body"]["floor"] = 9
    var not_ten := fixture.preview_gate(state,first.id)
    if not _check(str(not_ten.get("reason",""))=="body_major_gate_not_ready",
        "Body gate opened before floor 10."):
        return
    _ready(first,1)
    first.v2_realm_progress["body"]["xp"] -= 1.0
    var low_xp := fixture.preview_gate(state,first.id)
    if not _check(str(low_xp.get("reason",""))=="body_gate_xp_incomplete",
        "Body major gate ignored locked EXP."):
        return
    _ready(first,1)
    # Require reserve_min, then locked=true, before any debit.
    if not _check(store.set_rule(state,&"thanh_linh_thao",1,false),
        "Could not protect warehouse reserve."):
        return
    var reserved := fixture.preview_gate(state,first.id)
    if not _check(str(reserved.get("reason",""))=="body_gate_material_locked_or_reserved" and
        not bool(fixture.commit_gate(state,first.id,"qa-reserve").get("ok",true)),
        "Body consumer spent a reserved material."):
        return
    if not _check(store.set_rule(state,&"thanh_linh_thao",0,true),
        "Could not lock Body material."):
        return
    if not _check(str(fixture.preview_gate(state,first.id).get("reason",""))==
        "body_gate_material_locked_or_reserved" and
        not bool(fixture.commit_gate(state,first.id,"qa-locked").get("ok",true)),
        "Body consumer bypassed locked material."):
        return
    if not _check(store.set_rule(state,&"thanh_linh_thao",0,false),
        "Failed to release QA reservation."):
        return
    var true_preview := fixture.preview_gate(state,first.id)
    var count_rows: Array = true_preview.get("requirements",[])
    if not _check(bool(true_preview.get("can_commit",false)) and
        count_rows.size()==2 and
        int(true_preview["source_realm"])==1 and
        int(true_preview["target_realm"])==2,
        "Full material package did not produce a read-only ready preview."):
        return

    var before_tuvi: Dictionary = first.v2_realm_progress["cultivation"].duplicate(true)
    var ratio := first.hp / first.max_hp
    var first_tx := fixture.commit_gate(state,first.id,"qa-f2-one")
    if not _check(bool(first_tx.get("ok",false)) and
        int(first_tx.get("realm",0))==2 and
        int(first.v2_realm_progress["body"]["floor"])==1 and
        float(first.v2_realm_progress["body"]["xp"])==0.0 and
        store.quantity(state,&"thanh_linh_thao")==0 and
        store.quantity(state,&"tinh_lang_bi")==0 and
        absf(first.hp/first.max_hp-ratio)<0.0001 and
        first.v2_realm_progress["cultivation"]==before_tuvi and
        state.sect.v2_body_gate_receipts.size()==1,
        "A committed Body gate failed atomic debit/progression/HP/independent Tu Vi."):
        return

    var duplicate_before := JSON.stringify(state.to_dict())
    var replay := fixture.commit_gate(state,first.id,"qa-f2-one")
    var replay_another := fixture.commit_gate(state,first.id,"qa-f2-new-id")
    if not _check(str(replay.get("reason",""))=="body_gate_already_committed" and
        not bool(replay_another.get("ok",true)) and
        JSON.stringify(state.to_dict())==duplicate_before,
        "Second-click mutated warehouse or actor / replay was paid twice."):
        return
    var stolen_id := fixture.commit_gate(state,second.id,"qa-f2-one")
    if not _check(str(stolen_id.get("reason",""))=="body_gate_request_id_conflict",
        "Another actor reused an existing request ID."):
        return

    # Persist the single compact receipt + rebuild in-memory O(1) request index.
    var saved := SimulationState.from_dict(JSON.parse_string(JSON.stringify(state.to_dict())))
    if not _check(saved!=null and saved.sect.v2_body_gate_receipts.size()==1 and
        saved.sect.v2_body_gate_request_index.size()==1 and
        str(fixture.commit_gate(saved,first.id,"qa-f2-one").get("reason",""))==
        "body_gate_already_committed",
        "Same gate could be repaid after actual JSON reload."):
        return
    var svc := SaveService.new()
    var save_path := "user://dv2_03_f2_transaction_test.json"
    var save_error := svc.save_to_path(saved,save_path)
    var disk := svc.load_from_path(save_path) if save_error==OK else null
    if not _check(save_error==OK and disk!=null and
        disk.sect.v2_body_gate_request_index.size()==1 and
        str(fixture.commit_gate(disk,first.id,"qa-f2-one").get("reason",""))==
        "body_gate_already_committed",
        "SaveService disk round-trip lost transaction idempotence."):
        return
    DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

    # A different realm with same request_id is rejected.
    var disk_first: DiscipleState = disk.disciples[first.id]
    _ready(disk_first,2)
    if not _check(str(fixture.commit_gate(disk,first.id,"qa-f2-one").get("reason",""))==
        "body_gate_request_id_conflict",
        "The old request ID was reused for the next realm."):
        return

    # Force post-debit failure to verify full rollback (including audit counts).
    if not _check(_fund(state,2),"Could not fund rollback fixture."):
        return
    _ready(first,2)
    var before_materials := state.sect.warehouse_resources.duplicate(true)
    var before_events := state.sect.warehouse_event_count
    var before_progress := first.v2_realm_progress.duplicate(true)
    var before_hp := first.hp
    var before_max_hp := first.max_hp
    var before_receipts := state.sect.v2_body_gate_receipts.duplicate(true)
    var failed := FailedCommitFixture.new().commit_gate(state,first.id,"qa-failed-after-debit")
    if not _check(not bool(failed.get("ok",true)) and
        _same_state(state,first,before_materials,before_events,before_progress,before_hp,before_max_hp) and
        state.sect.v2_body_gate_receipts==before_receipts,
        "A failed post-debit Body gate left a partial spend/HP/state/receipt."):
        return

    # A real duel for the final material bundle: first consumes, second rejects.
    _ready(second,2)
    var second_gate := fixture.preview_gate(state,second.id)
    if not _check(bool(second_gate.get("can_commit",false)),
        "Second QA disciple could not compete for the same rare materials."):
        return
    var first_win := fixture.commit_gate(state,first.id,"qa-f2-realm-two")
    var second_loss := fixture.commit_gate(state,second.id,"qa-f2-realm-two-other")
    if not _check(bool(first_win.get("ok",false)) and
        not bool(second_loss.get("ok",true)) and
        str(second_loss.get("reason",""))=="body_gate_material_missing" and
        state.sect.v2_body_gate_receipts.size()==2,
        "Racing disciples consumed the same final materials or both advanced."):
        return

    # Cross-band Seal transaction: no one-time account flag / no free Seal.
    _ready(second,10)
    var recipe10 := DiscipleBodyGateContentV2.recipe(10)
    if not _check(store.add(state,StringName(recipe10["main_id"]),int(recipe10["main_qty"])) and
        store.add(state,StringName(recipe10["aux_id"]),int(recipe10["aux_qty"])),
        "Cannot set up realm-10 package."):
        return
    var without_seal := fixture.preview_gate(state,second.id)
    if not _check(str(without_seal.get("reason",""))=="body_gate_material_missing",
        "Realm 10 was allowed without its required Nhân Seal."):
        return
    if not _check(store.add(state,&"an_nhan_gioi",1),
        "Could not seed a one-time QA Seal."):
        return
    var with_seal := fixture.commit_gate(state,second.id,"qa-f2-seal-ten")
    if not _check(bool(with_seal.get("ok",false)) and
        int(with_seal.get("realm",0))==11 and
        store.quantity(state,&"an_nhan_gioi")==0 and
        state.sect.v2_body_gate_receipts.size()==3,
        "Realm 10->11 did not consume exactly one registered Nhân Seal."):
        return

    # Abort invalid actor ID, no expiry or synthetic endgame reward.
    if not _check(not bool(fixture.commit_gate(state,&"missing_actor","no_actor").get("ok",true)) and
        not bool(fixture.commit_gate(state,second.id,"").get("ok",true)) and
        state.validate_invariants().is_empty(),
        "Invalid transactions changed simulation or broke invariants."):
        return
    print("DV2-03F F2 ATOMIC BODY GATE TRANSACTION: PASS; ",
        "warehouse=single,requests=dedup,saves=json+disk,rollback=yes,seals=exact")
    quit(0)
