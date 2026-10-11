extends SceneTree

# DV2-03F/F0 ONLY: observable baseline from REAL existing V2 owners.
# Does not register resources, grant new rewards, change XP or enable Body gates.
# This test verifies a representative paid Body minute and a completed map loot
# claim, while recording unimplemented source coverage without faking it.
func _init() -> void:
    call_deferred("_run")


func _assert(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("DV2-03F F0: " + reason)
        quit(1)
        return false
    return true


func _near(a: float, b: float) -> bool:
    return absf(a - b) < 0.0001


func _run() -> void:
    var xp_sum: int = 0
    for realm_index in range(29):
        xp_sum += int(DiscipleProgressionBalanceV2.REALM_TOTAL_XP[realm_index])
    if not _assert(xp_sum == 37890400000 and
        DiscipleProgressionBalanceV2.REALM_TOTAL_XP.size() == 30 and
        _near(DiscipleProgressionBalanceV2.BASE_TUVI_PER_MINUTE, 1000.0) and
        _near(DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE, 250.0) and
        _near(DiscipleProgressionBalanceV2.BODY_EXPEDITION_REFERENCE_PER_MINUTE, 750.0) and
        _near(DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE, 1500.0),
        "Locked EXP table or reference rates changed during F0."):
        return

    # The expedition rate is a typed-source REFERENCE, not proof of an
    # automatically dispatched hunting/expedition Body EXP minute.
    var unsupported_expedition := {
        "source_id":"f0_unverified_expedition",
        "source_kind":DiscipleBodyXpSourceV2.SOURCE_EXPEDITION,
        "base_body_xp_per_minute":750.0,
        "floor_costs":DiscipleTrainingContentV2.canonical_rules()["body"]["floor_costs"]
    }
    if not _assert(not bool(DiscipleBodyXpSourceV2.validate_source(
        unsupported_expedition).get("ok",true)),
        "Body expedition reference was accepted without active expedition proof."):
        return

    # One real V2 disciple earns Body EXP only after an eligible PAID minute.
    var state := P37Factory.create_state(130072)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.v2_training_enabled = true
    state.sect.v2_training_rules = DiscipleTrainingContentV2.canonical_rules()
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    var facility := BuildingSystem.new().ensure_body_training_facility(state)
    if not _assert(facility != null and
        BuildingSystem.new().worker_slots(facility) == 2,
        "Paid training facility has no canonical two-slot owner."):
        return
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,701
    )
    state.recruitment_candidates[candidate.id] = candidate
    if not _assert(bool(RecruitmentSystem.new().accept_candidate(
        state,candidate.id).get("ok",false)),
        "Failed to recruit a genuine V2 disciple for paid Body audit."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    if not _assert(bool(DiscipleBodyTrainingFacilityV2.reserve_slot(
        state,disciple.id).get("ok",false)),
        "Real disciple could not reserve existing Rèn Thân slot."):
        return
    disciple.current_action = &"TRAIN_BODY"
    state.tick = 1
    var before_stones := state.sect.spirit_stones
    var before_body := float(disciple.v2_realm_progress["body"]["xp"])
    var paid := DiscipleBodyTrainingFacilityV2.commit_minute(state,disciple)
    var expected := DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE * (
        1.0 + 0.0020 * disciple.constitution
    )
    if not _assert(bool(paid.get("ok",false)) and
        _near(float(paid.get("gained",0.0)),expected) and
        _near(float(disciple.v2_realm_progress["body"]["xp"])-before_body,expected) and
        state.sect.spirit_stones == before_stones-1 and
        int(facility.production_state.get("spent_spirit_stones",-1)) == 1,
        "Actual paid Body minute did not match EXP and Sect-stone ledger."):
        return
    var duplicate_training := DiscipleBodyTrainingFacilityV2.commit_minute(state,disciple)
    if not _assert(not bool(duplicate_training.get("ok",true)) and
        state.sect.spirit_stones == before_stones-1,
        "Repeated training minute charged or granted twice."):
        return

    # The existing PvE content includes three low-tier regions, with no
    # real early B Tử Vân Thảo drop and no deterministic Linh Tủy guarantee.
    var registry := ResourceRegistry.new()
    var map_ids: Array = HuntingMapV2.REGION_CONTENT.keys()
    map_ids.sort()
    if not _assert(map_ids.size()==3 and
        registry.has(&"thanh_linh_thao") and registry.has(&"tinh_lang_bi") and
        registry.has(&"tu_van_thao") and registry.has(&"linh_tuy"),
        "Existing A/B resource registry or three-region baseline changed."):
        return
    var early_b_sources := 0
    for region_id in map_ids:
        var info: Dictionary = HuntingMapV2.REGION_CONTENT[region_id]
        if info["resources"].has("tu_van_thao") or str(info["rare"])=="tu_van_thao":
            early_b_sources += 1
        if not _assert(HuntingMapV2.valid_choice(str(region_id),1) and
            bool(HuntingMapV2.overview(str(region_id)).get("ok",false)),
            "Existing low-tier region failed content lookup."):
            return
    if not _assert(early_b_sources==0 and
        str(HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]["rare"])=="linh_tuy" and
        _near(float(HuntingMapV2.LEVELS[1]["rare"]),0.0),
        "Unexpected early B source or L1 rare-rate changed; update F0 audit before claiming coverage."):
        return

    # Legitimate real fight -> one earned warehouse settlement. Pure preview,
    # defeat protection, idempotent claim and Sect-stone ownership are audited.
    var legacy_ids: Array = state.disciples.keys()
    legacy_ids.sort()
    var legacy: DiscipleState = state.disciples[legacy_ids[0]]
    var plain := DiscipleCombatLoadoutV2.build(
        state,legacy,1,1,1,1,"frontline",Vector2(8.0,9.0),"f0_party"
    )
    if not _assert(bool(plain.get("ok",false)),
        "Could not construct an actual combat actor from a saved disciple."):
        return
    var spawn := HuntingMapV2.spawn("thanh_truc_lam",1,"f0_real_claim",901)
    var fighters: Array = []
    for i in range(6):
        var actor: Dictionary = plain.duplicate(true)
        actor["id"] = "f0_hunter_%d" % i
        actor["position"] = Vector2(8.0+float(i)*0.3,9.0)
        actor["party_id"] = "f0_party"
        fighters.append(actor)
    var battle := MapBattleV2.new(901)
    if not _assert(bool(spawn.get("ok",false)) and
        bool(battle.setup("f0_real_claim",fighters,spawn["monsters"]).get("ok",false)),
        "F0 real hunt could not start."):
        return
    var stones_before_claim := state.sect.spirit_stones
    var resources_before := state.sect.warehouse_resources.duplicate(true)
    var preview: Dictionary = HuntingMapV2.preview_reward(spawn)
    if not _assert(resources_before==state.sect.warehouse_resources and
        not bool(HuntingMapV2.claim_reward(state,spawn,battle).get("ok",true)),
        "Preview/unfinished fight produced unauthorized loot."):
        return
    battle.run(400)
    if not _assert(battle.outcome=="win",
        "Deterministic real F0 six-hunter battle did not win."):
        return
    var claim := HuntingMapV2.claim_reward(state,spawn,battle)
    if not _assert(bool(claim.get("ok",false)) and
        claim["items"]==preview and
        claim["items"].has("linh_moc") and
        state.sect.spirit_stones==stones_before_claim,
        "Victorious claim did not settle actual items, or minted undocumented Sect Stones."):
        return
    var warehouse := WarehouseSystem.new()
    for item_id in claim["items"].keys():
        if not _assert(registry.has(StringName(item_id)) and
            warehouse.quantity(state,StringName(item_id))>=int(claim["items"][item_id]),
            "An actual reward was unregistered or missed the canonical warehouse."):
            return
    var replay := HuntingMapV2.claim_reward(state,spawn,battle)
    var saved_sect := SectState.from_dict(
        JSON.parse_string(JSON.stringify(state.sect.to_dict()))
    )
    if not _assert(not bool(replay.get("ok",true)) and
        saved_sect.v2_pve_reward_claims.has("f0_real_claim") and
        saved_sect.spirit_stones == stones_before_claim,
        "Earned hunt was replayable or reward/stone record lost in save/load."):
        return

    print("DV2-03F F0 SOURCE BASELINE: ",JSON.stringify({
        "exp_realm_1_to_29":xp_sum,
        "body_reference_per_minute":{
            "production":DiscipleProgressionBalanceV2.BODY_PRODUCTION_REFERENCE_PER_MINUTE,
            "expedition_unverified":DiscipleProgressionBalanceV2.BODY_EXPEDITION_REFERENCE_PER_MINUTE,
            "paid_training":DiscipleProgressionBalanceV2.BODY_TRAINING_REFERENCE_PER_MINUTE
        },
        "paid_body_xp_gained":float(paid["gained"]),
        "paid_training_stones_spent":before_stones-state.sect.spirit_stones,
        "region_count":map_ids.size(),
        "early_tu_van_drop_source_count":early_b_sources,
        "real_claim_items":claim["items"],
        "hunt_sect_stones_earned":0,
        "missing_guaranteed_linh_tuy":true,
        "full_hunting_scheduler_verified":false
    }))
    print("DV2-03F F0 SOURCE BASELINE: PASS")
    quit(0)
