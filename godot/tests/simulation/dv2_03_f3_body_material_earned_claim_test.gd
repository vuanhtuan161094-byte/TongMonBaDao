extends SceneTree

# F3: real map battle -> verified win -> main warehouse earned A/B.
# F2 fixture item seeding is NOT used in this test.
func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, message: String) -> bool:
    if not ok:
        push_error("DV2-03F/F3: "+message)
        quit(1)
        return false
    return true

func _fighters(state: SimulationState) -> Array:
    var ids: Array = state.disciples.keys()
    ids.sort()
    var members: Array = []
    for raw_id in ids:
        var disciple: DiscipleState = state.disciples[raw_id]
        var actor := DiscipleCombatLoadoutV2.build(
            state,disciple,1,1,1,1,"frontline",
            Vector2(8.0+float(members.size())*0.3,9.0),"f3_real_party"
        )
        if bool(actor.get("ok",false)):
            members.append(actor)
        if members.size() >= 6:
            break
    return members

func _real_win_claim(state: SimulationState, members: Array, region: String,
        encounter_id: String, seed: int) -> Dictionary:
    var spawned := HuntingMapV2.spawn(region,1,encounter_id,seed)
    if not bool(spawned.get("ok",false)):
        return {"ok":false,"reason":"spawn_failure"}
    var battle := MapBattleV2.new(seed)
    if not bool(battle.setup(encounter_id,members,spawned["monsters"]).get("ok",false)):
        return {"ok":false,"reason":"battle_setup_failure"}
    var resources_before := state.sect.warehouse_resources.duplicate(true)
    var claim_early := HuntingMapV2.claim_reward(state,spawned,battle)
    if bool(claim_early.get("ok",false)) or state.sect.warehouse_resources != resources_before:
        return {"ok":false,"reason":"unfinished_battle_rewarded"}
    battle.run(600)
    if battle.outcome != "win":
        return {"ok":false,"reason":"real_battle_not_won","outcome":battle.outcome}
    var won := HuntingMapV2.claim_reward(state,spawned,battle)
    if not bool(won.get("ok",false)):
        return won
    var warehouse_after := state.sect.warehouse_resources.duplicate(true)
    var duplicate := HuntingMapV2.claim_reward(state,spawned,battle)
    if bool(duplicate.get("ok",false)) or warehouse_after != state.sect.warehouse_resources:
        return {"ok":false,"reason":"duplicate_won_claim_paid_twice"}
    return won

func _run() -> void:
    var state := P37Factory.create_state(370117)
    state.sect.disciple_v2_birth_enabled = true
    var warehouse := WarehouseSystem.new()
    var members := _fighters(state)
    if not _assert(members.size()==6 and
        HuntingMapV2.early_body_sources_ready(state,1) and
        HuntingMapV2.early_body_sources_ready(state,6) and
        not HuntingMapV2.early_body_sources_ready(state,7),
        "P3.7 six-member real map hunting or low-tier content not ready."):
        return

    if not _assert(int(HuntingMapV2.REGION_CONTENT["bach_thach_khe"]["resources"].get("tu_van_thao",0))==2 and
        int(HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]["resources"].get("thanh_linh_thao",0))==1 and
        HuntingMapV2.LINH_TUY_GUARANTEE_WINS==4,
        "Unexpected F3 pilot source configuration."):
        return

    var initial_herbs := warehouse.quantity(state,&"thanh_linh_thao")
    var initial_marrow := warehouse.quantity(state,&"linh_tuy")
    var awarded_guarantee := 0
    for index in range(4):
        var identity := "f3_earned_truc_%d" % index
        var before := state.sect.v2_body_material_progress.duplicate(true)
        var session := _real_win_claim(state,members,"thanh_truc_lam",identity,901+index)
        if not _assert(bool(session.get("ok",false)),
            "Authentic real Trúc claim #%d rejected: %s" % [index,str(session)]):
            return
        if index < 3 and not _assert(
            int(state.sect.v2_body_material_progress.get("linh_tuy_thanh_truc_wins",-1))==index+1,
            "Win-only counter did not advance exactly once."):
            return
        if index == 3:
            awarded_guarantee = int(session["items"].get("linh_tuy",0))
            if not _assert(awarded_guarantee>=1 and
                int(state.sect.v2_body_material_progress["linh_tuy_thanh_truc_wins"])==0,
                "Four actual won-claims did not guarantee Linh Tủy with reset."):
                return
        if not _assert(state.sect.v2_body_material_progress != before,
            "Genuine won-claim did not advance durable anti-stuck progress."):
            return
    if not _assert(warehouse.quantity(state,&"thanh_linh_thao")>=initial_herbs+4 and
        warehouse.quantity(state,&"linh_tuy")>=initial_marrow+1,
        "A main ingredient or guaranteed B auxiliary not earned in real warehouse."):
        return

    var b_claim := _real_win_claim(state,members,"bach_thach_khe","f3_earned_b",992)
    if not _assert(bool(b_claim.get("ok",false)) and
        int(b_claim["items"].get("tu_van_thao",0))>=2 and
        int(b_claim["items"].get("tinh_lang_bi",0))>=2 and
        warehouse.quantity(state,&"tu_van_thao")>=2,
        "B main Tu Van was not earned without Spirit Field Lv30."):
        return

    # Progress and won-claim ledger survive JSON and actual SaveService disk I/O.
    var svc := SaveService.new()
    var path := "user://dv2_03_f3_body_earned_claim_test.json"
    if not _assert(svc.save_to_path(state,path)==OK,
        "F3 save failed."):
        return
    var restored := svc.load_from_path(path)
    DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if not _assert(restored!=null and
        int(restored.sect.v2_body_material_progress.get("linh_tuy_thanh_truc_wins",-1))==0 and
        restored.sect.v2_pve_reward_claims.size()==5 and
        WarehouseSystem.new().quantity(restored,&"tu_van_thao")>=2 and
        WarehouseSystem.new().quantity(restored,&"linh_tuy")>=initial_marrow+1,
        "F3 won-claim progress/items/receipt lost after disk restart."):
        return

    # Money/EXP law intentionally unchanged by hunting material settlement.
    if not _assert(DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE==1500.0 and
        DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE==1000.0,
        "F3 changed canonical EXP sources."):
        return
    print("DV2-03F F3 REAL EARNED A/B HUNT + BOUNDED LINH TUY: PASS; "+
        "real_wins=5, guaranteed_linh_tuy>=1, tu_van>=2, duplicate=blocked")
    quit(0)
