extends SceneTree

# F6 legitimate won-hunt warehouse materials + production Body gate + SaveService.
# Floor10 XP is a QA fixture after one REAL paid training minute; this test
# DOES NOT claim natural accumulation of 10,000,000 realm-1 XP is fast/verified.
func _init() -> void:
    call_deferred("_run")

func _ensure(ok: bool, label: String) -> bool:
    if not ok:
        push_error("DV2-03F/F6: "+label)
        quit(1)
        return false
    return true

func _build_party(state: SimulationState) -> Array:
    var ids: Array = state.disciples.keys()
    ids.sort()
    var party: Array = []
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var actor := DiscipleCombatLoadoutV2.build(state,disciple,1,1,1,1,
            "frontline",Vector2(8.0+float(party.size())*0.3,9.0),"f6_party")
        if bool(actor.get("ok",false)):
            party.append(actor)
        if party.size()>=6:
            break
    return party

func _victory(state: SimulationState, party: Array, region: String,
        encounter_id: String, seed: int) -> bool:
    var spawned := HuntingMapV2.spawn(region,1,encounter_id,seed)
    if not bool(spawned.get("ok",false)):
        return false
    var battle := MapBattleV2.new(seed)
    if not bool(battle.setup(encounter_id,party,spawned["monsters"]).get("ok",false)):
        return false
    battle.run(500,false)
    if battle.outcome!="win":
        return false
    var receipt := HuntingMapV2.claim_reward(state,spawned,battle)
    return bool(receipt.get("ok",false))

func _run() -> void:
    var state := P37Factory.create_state(370117)
    var party := _build_party(state)
    if not _ensure(party.size()==6 and HuntingMapV2.early_body_sources_ready(state,1),
        "No genuine already-registered hunt team or region."):
        return
    var original_herbs := WarehouseSystem.new().quantity(state,&"thanh_linh_thao")
    var original_pelts := WarehouseSystem.new().quantity(state,&"tinh_lang_bi")
    # Genuine monster wins and claim receipts, not seeded warehouse items.
    for i in range(12):
        if not _ensure(_victory(state,party,"thanh_truc_lam",
            "f6_real_truc_%02d" % i,901),
            "Genuine win #%d did not settle the A herb." % i):
            return
    for j in range(2):
        if not _ensure(_victory(state,party,"bach_thach_khe",
            "f6_real_bach_%02d" % j,992),
            "Genuine win #%d did not settle the A pelt." % j):
            return
    var warehouse := WarehouseSystem.new()
    if not _ensure(
        warehouse.quantity(state,&"thanh_linh_thao")>=original_herbs+12 and
        warehouse.quantity(state,&"tinh_lang_bi")>=original_pelts+4 and
        state.sect.v2_pve_reward_claims.size()==14,
        "14 actual victorious claims did not fund gate1 in canonical warehouse."):
        return
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,800
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _ensure(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),
        "Cannot recruit real V2 disciple after hunting."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    BuildingSystem.new().ensure_body_training_facility(state)
    if not _ensure(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(
        state,disciple.id).get("ok",false)),
        "Cannot reserve real first Rèn Thân slot."):
        return
    disciple.current_action=&"TRAIN_BODY"
    state.tick=1
    var real_paid := DiscipleBodyTrainingFacilityV2.commit_minute(state,disciple)
    if not _ensure(bool(real_paid.get("ok",false)) and
        float(real_paid.get("gained",0.0))>0.0,
        "Genuine paid training minute did not grant locked Body EXP."):
        return
    # Simulation integration targets the transaction, not the entire
    # intentionally long realm XP pacing (10m at realm1).
    disciple.current_action=&"EVALUATE"
    disciple.region_id=&"sect"
    disciple.v2_realm_progress["body"]["floor"]=10
    disciple.v2_realm_progress["body"]["xp"]=float(DiscipleProgressionBalanceV2.floor_cost(1,10))
    var gate := DiscipleBodyGateTransactionV2.new()
    var preview := gate.preview_gate(state,disciple.id)
    if not _ensure(bool(preview.get("can_commit",false)),
        "Funded real source gate is not eligible: "+str(preview)):
        return
    var before_tuvi: Dictionary = disciple.v2_realm_progress["cultivation"].duplicate(true)
    var result := gate.commit_gate(state,disciple.id,"f6-real-source-gate1")
    if not _ensure(bool(result.get("ok",false)) and
        int(disciple.v2_realm_progress["body"]["realm"])==2 and
        disciple.v2_realm_progress["cultivation"]==before_tuvi and
        warehouse.quantity(state,&"thanh_linh_thao")==original_herbs and
        warehouse.quantity(state,&"tinh_lang_bi")==original_pelts and
        state.sect.v2_body_gate_receipts.size()==1,
        "Real earned A materials did not settle to exactly one Body gate."):
        return
    # Continue authentic wins to cover ALL SIX currently playable A/B gates.
    # Cumulative pilot-only minimum = 54 Trúc wins + 26 Bạch wins.
    for i in range(12,54):
        if not _ensure(_victory(state,party,"thanh_truc_lam",
            "f6_real_truc_%02d" % i,901),
            "Missing actual claimed Trúc victory #%d." % i):
            return
    for j in range(2,26):
        if not _ensure(_victory(state,party,"bach_thach_khe",
            "f6_real_bach_%02d" % j,992),
            "Missing actual claimed Bạch victory #%d." % j):
            return
    if not _ensure(state.sect.v2_pve_reward_claims.size()==80 and
        warehouse.quantity(state,&"tu_van_thao")>=52 and
        warehouse.quantity(state,&"linh_tuy")>=6,
        "Won-claim source did not accumulate enough genuine B resources."):
        return
    for realm in range(2,7):
        disciple.v2_realm_progress["body"]["floor"]=10
        disciple.v2_realm_progress["body"]["xp"]=float(
            DiscipleProgressionBalanceV2.floor_cost(realm,10)
        )
        var next_preview := gate.preview_gate(state,disciple.id)
        if not _ensure(bool(next_preview.get("can_commit",false)),
            "Gate %d->%d not funded by 80 real wins: %s" % [
                realm,realm+1,str(next_preview)]):
            return
        var next_result := gate.commit_gate(state,disciple.id,
            "f6-real-source-gate%d" % realm)
        if not _ensure(bool(next_result.get("ok",false)) and
            int(disciple.v2_realm_progress["body"]["realm"])==realm+1 and
            disciple.v2_realm_progress["cultivation"]==before_tuvi,
            "Fully earned B gate failed at realm %d." % realm):
            return
    if not _ensure(state.sect.v2_body_gate_receipts.size()==6,
        "Real A/B six-gate chain receipts were incomplete."):
        return
    var saver := SaveService.new()
    var path := "user://dv2_03_f6_real_earned_gate_test.json"
    if not _ensure(saver.save_to_path(state,path)==OK,"SaveService save failed."):
        return
    var restored := saver.load_from_path(path)
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if not _ensure(restored!=null and
        restored.sect.v2_pve_reward_claims.size()==80 and
        restored.sect.v2_body_gate_receipts.size()==6 and
        int(restored.disciples[disciple.id].v2_realm_progress["body"]["realm"])==7 and
        str(gate.commit_gate(restored,disciple.id,"f6-real-source-gate6").get("reason",""))==
            "body_gate_already_committed",
        "Saved hunt rewards or Body payment replay after restart."):
        return
    # High tier C-H and Seals still fail closed, even with all typed IDs in registry.
    var restored_disciple: DiscipleState = restored.disciples[disciple.id]
    restored_disciple.v2_realm_progress["body"]["realm"]=7
    restored_disciple.v2_realm_progress["body"]["floor"]=10
    restored_disciple.v2_realm_progress["body"]["xp"]=float(DiscipleProgressionBalanceV2.floor_cost(7,10))
    if not _ensure(str(gate.preview_gate(restored,disciple.id).get("reason",""))==
        "content_unavailable" and
        restored.validate_invariants().is_empty(),
        "High-tier content was fabricated or saved state invalid."):
        return
    print("DV2-03F F6 REAL EARNED HUNT -> PRODUCTION BODY GATE -> SAVE: PASS; ",
        "wins=80,body_gates_A_B=6,paid_body_minute=real,gate_xp_at_10=qa_fixture,high_tier=blocked")
    quit(0)
