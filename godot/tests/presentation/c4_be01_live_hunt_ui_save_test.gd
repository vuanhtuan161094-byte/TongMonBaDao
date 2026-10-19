extends SceneTree

# End-to-end UI + LiveGameRuntimeV2 in its own uniquely named user:// file.
# No main game save is read, mutated or replaced.
func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, why: String) -> bool:
    if not condition:
        push_error("C4_BE01_UI_FAIL: "+why)
        quit(1)
    return condition

func _run() -> void:
    var save_path := "user://c4_be01_ui_qa_%d.json" % Time.get_ticks_usec()
    var live := LiveGameRuntimeV2.new()
    var boot := live.start(save_path,int(Time.get_unix_time_from_system()),81277)
    if not _check(bool(boot.get("ok",false)),"isolated live game boot: "+str(boot)):
        return
    var state: SimulationState = live.state()
    var recruit_candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,45077)
    if not _check(recruit_candidate != null and
            DiscipleBirthProfileV2.valid_complete_birth(recruit_candidate.v2_birth_profile),
            "new authentic V2 recruit unavailable"):
        return
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,
        state.disciples.size()+1)
    state.recruitment_candidates[recruit_candidate.id] = recruit_candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(
            state,recruit_candidate.id).get("ok",false)),
            "failed to recruit an owned V2 entity"):
        return
    var member: DiscipleState = state.disciples[recruit_candidate.id]
    # MAX Realm fixture only, not live game progression or a cheat toggle.
    for track in ["cultivation","body"]:
        member.v2_realm_progress[track]["realm"] = 30
        member.v2_realm_progress[track]["floor"] = 10
        member.v2_realm_progress[track]["xp"] = 0.0
    if not _check(bool(DiscipleRealmProgressV2.sync_live_hp(member).get("ok",false)),
            "MAX realm HP preparation"):
        return
    member.hp = member.max_hp
    member.current_action = &"IDLE"
    member.region_id = &"sect"

    var panel := HuntingExpeditionPanelV2.new()
    get_root().add_child(panel)
    panel.bind_runtime(live)
    if not _check(panel.session == null and
            panel.candidates.has(str(member.id)) and
            panel.start_button.disabled and
            panel.difficulty.buttons.size()==5,
            "five-level modal or authentic roster did not open"):
        return
    # All UI testing is performed at the highest REAL map difficulty.
    var zone := str(panel.zone_choice.get_item_metadata(panel.zone_choice.selected))
    var chosen := panel.difficulty.select_level(5)
    if not _check(bool(chosen.get("ok",false)) and
            HuntingMapV2.selected_level(state,zone)==5,
            "max fifth region difficulty was not actually selected"):
        return
    panel._toggle_member(true,str(member.id))
    if not _check(panel.selected_ids.size()==1 and
            not panel.start_button.disabled,
            "clicking eligible roster did not enable real launch"):
        return
    panel._begin_hunt()
    if not _check(panel.session != null and
            panel.session.battle.active and
            panel.game_state.sect.v2_pve_active_runs.has(
                panel.session.battle.encounter_id) and
            member.active_pve_encounter_id==panel.session.battle.encounter_id,
            "UI failed to start a reserved, saved encounter"):
        return
    var encounter := panel.session.battle.encounter_id
    if not _check(panel._source_view_metadata().has(str(member.id)) and
            panel._source_view_metadata().has("mob_00"),
            "real source ranks/name missing from live hunting view"):
        return
    var snapshot: Dictionary = panel.session.save_state()
    if not _check(bool(snapshot.get("ok",false)) and
            not bool(panel.session.claim().get("ok",true)),
            "active encounter cannot be checkpointed or pays early"):
        return
    var first_save := live.save()
    if not _check(bool(first_save.get("ok",false)),"saved active encounter"):
        return
    panel._finish_hunt()
    if not _check(not panel.session.battle.active and
            state.sect.v2_pve_settlement_receipts.has(encounter) and
            member.active_pve_encounter_id.is_empty(),
            "UI end battle failed to settle terminal injury or reservation"):
        return
    if not _check(panel.session.battle.outcome=="win",
            "MAX real recruit did not defeat baseline 5-tier map fixture"):
        return
    var old_amount := WarehouseSystem.new().quantity(state,&"linh_moc")
    panel._claim_reward()
    if not _check(panel.session==null and
            state.sect.v2_pve_reward_claims.has(encounter) and
            WarehouseSystem.new().quantity(state,&"linh_moc")>old_amount and
            not state.sect.v2_pve_active_runs.has(encounter),
            "UI did not atomically pay unique real warehouse reward"):
        return
    var paid := WarehouseSystem.new().quantity(state,&"linh_moc")
    var stale := HuntingPveRunV2.restore_state(state,snapshot)
    # A snapshot from a claimed encounter must not permit a second payout.
    if bool(stale.get("ok",false)):
        var old_run: HuntingPveRunV2 = stale["session"]
        old_run.finish()
        old_run.claim()
    if not _check(WarehouseSystem.new().quantity(state,&"linh_moc")==paid,
            "replaying an already-paid hunt duplicated warehouse resources"):
        return
    if not _check(bool(live.save().get("ok",false)),
            "UI terminal claim failed to persist through actual SaveService"):
        return
    panel.queue_free()
    DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path+".bak"))
    print("C4_BE01_LIVE_HUNT_UI_SAVE_EXACTLY_ONCE: PASS")
    quit(0)
