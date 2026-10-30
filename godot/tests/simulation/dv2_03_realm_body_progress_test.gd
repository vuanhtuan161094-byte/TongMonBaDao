extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error(why)
        quit(1)
        return false
    return true

func _close(a: float,b: float) -> bool:
    return absf(a-b) <= 0.00001

func _costs(realm: int, amount: float = 1000.0) -> Dictionary:
    var table: Dictionary = {}
    for floor_index in range(1,11):
        table["%d:%d" % [realm,floor_index]] = amount
    return table

func _run() -> void:
    var state := P37Factory.create_state(515151)
    if not _check(not state.sect.disciple_v2_birth_enabled,
        "Legacy P3.7 fixture must not turn on V2 birth/progression by default."):
        return
    var original: DiscipleState = state.disciples[state.disciples.keys()[0]]
    if not _check(original.v2_realm_progress.is_empty() and
        not bool(DiscipleRealmProgressV2.initialize(original).get("ok",true)),
        "Legacy disciples must not silently obtain a 300-floor V2 profile."):
        return

    state.sect.disciple_v2_birth_enabled = true
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,205
    )
    if not _check(candidate != null and
        DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile),
        "A genuinely generated V2 candidate is needed for a valid realm owner."):
        return
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)),
        "Recruitment failed to preserve the V2 disciple identity."):
        return
    var disciple: DiscipleState = state.disciples[candidate.id]
    disciple.aptitude = 100.0
    disciple.constitution = 100.0
    disciple.potential = 100.0
    var recruited := DiscipleRealmProgressV2.current(disciple)
    if not _check(bool(recruited.get("ok",false)) and
        int(recruited["cultivation_global_floor"]) == 1 and
        int(recruited["body_global_floor"]) == 1 and
        _close(float(recruited["cultivation"]["xp"]),0.0) and
        _close(float(recruited["body"]["xp"]),0.0) and
        not bool(DiscipleRealmProgressV2.initialize(disciple).get("ok",true)),
        "V2 recruitment must start exactly once at Phàm Nhân 1 + Phàm Thân 1, 0 EXP."):
        return

    # Keep the arithmetic fixture explicitly at the canonical production start.
    disciple.v2_realm_progress["cultivation"] = {
        "realm":1,"floor":1,"xp":0.0,"gate_failures":0,"lifetime_failures":0,
        "auto_breakthrough":false,"breakthrough_history":[],"last_training_event_id":""
    }
    disciple.v2_realm_progress["body"] = {
        "realm":1,"floor":1,"xp":0.0,"gate_failures":0,"lifetime_failures":0,
        "auto_breakthrough":false,"breakthrough_history":[],"last_training_event_id":""
    }
    disciple.v2_realm_progress["last_training_tick"] = -1
    if not _check(bool(DiscipleRealmProgressV2.sync_live_hp(disciple).get("ok",false)),
        "Focused fixture could not establish canonical V2 live HP."):
        return
    disciple.hp = disciple.max_hp * 0.40
    var hp_ratio_before_growth := disciple.hp / disciple.max_hp
    var first := DiscipleRealmProgressV2.current(disciple)
    if not _check(bool(first.get("ok",false)) and
        int(first["cultivation_global_floor"]) == 1 and
        int(first["body_global_floor"]) == 1,
        "Focused arithmetic fixture could not normalize independent 1/300 tracks."):
        return
    var before_invalid := disciple.v2_realm_progress.duplicate(true)
    var no_table := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",200.0,"natural",{}
    )
    if not _check(not bool(no_table.get("ok",true)) and
        disciple.v2_realm_progress == before_invalid,
        "Unapproved XP costs must block progression without mutation."):
        return

    var natural := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",2000.0,"natural",_costs(1)
    )
    if not _check(bool(natural.get("ok",false)) and
        _close(float(natural["gained"]),2500.0) and
        int(natural["floor"]) == 3 and _close(float(natural["xp"]),500.0),
        "Natural Tu Vi must add 0.25% per Tu Chat point and auto-cross minor floors."):
        return
    if not _check(int(disciple.v2_realm_progress["body"]["floor"]) == 1,
        "Tu Vi EXP also raised Luyen The without a body training event."):
        return

    var body := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",1000.0,"natural",_costs(1)
    )
    if not _check(bool(body.get("ok",false)) and
        _close(float(body["gained"]),1200.0) and
        int(body["floor"]) == 2 and _close(float(body["xp"]),200.0),
        "Body EXP must add exactly 0.20% per Can Cot point."):
        return
    var fixed := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",300.0,"fixed",_costs(1)
    )
    if not _check(bool(fixed.get("ok",false)) and _close(float(fixed["gained"]),300.0),
        "Fixed body EXP must bypass natural attribute percentage bonuses."):
        return
    var stats := DiscipleRealmProgressV2.derive_stats(disciple)
    if not _check(bool(stats.get("ok",false)),
        "Both persistent realm/body tracks failed to feed CombatStatsV2."):
        return
    if not _check(_close(disciple.max_hp,float(stats["stats"]["max_hp"])) and
        _close(disciple.hp/disciple.max_hp,hp_ratio_before_growth),
        "Floor growth did not update live V2 Max HP while preserving current HP ratio."):
        return
    var compared := CombatStatsV2.derive(1,3,1,2,disciple.potential,[],disciple.foundation_model_version >= FoundationSystem.MODEL_D7)
    if not _check(_close(float(stats["stats"]["max_hp"]),float(compared["stats"]["max_hp"])) and
        _close(float(stats["stats"]["attack"]),float(compared["stats"]["attack"])) and
        _close(float(stats["stats"]["defense"]),float(compared["stats"]["defense"])),
        "Persistent Tu Vi/Body coordinates produced incorrect canonical combat stats."):
        return

    # Gate floor 10 is NOT an automatic promotion; all natural overflow stays
    # out of generic banked Tich Tu unless a separate Fate mechanic owns it.
    disciple.v2_realm_progress["cultivation"]["floor"] = 9
    disciple.v2_realm_progress["cultivation"]["xp"] = 900.0
    var gate_gain := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",4000.0,"fixed",_costs(1)
    )
    if not _check(bool(gate_gain.get("ok",false)) and
        int(gate_gain["realm"]) == 1 and int(gate_gain["floor"]) == 10 and
        _close(float(gate_gain["xp"]),1000.0) and
        float(gate_gain["unapplied_overflow"]) > 0.0,
        "Automatic minor floors must stop at the actual major gate."):
        return
    var old_stamina := disciple.stamina
    var old_hp := disciple.hp
    if not _check(not bool(DiscipleRealmProgressV2.attempt_cultivation_breakthrough(
        disciple,GameRng.new(91),_costs(1),0.5,false,"gate_unapproved"
    ).get("ok",true)), "Gate must reject unverified content/requirements."):
        return
    var rng := GameRng.new(917)
    var failed := DiscipleRealmProgressV2.attempt_cultivation_breakthrough(
        disciple,rng,_costs(1),0.0,true,"attempt_01"
    )
    if not _check(bool(failed.get("ok",false)) and not bool(failed["success"]) and
        _close(float(failed["xp"]),900.0) and
        int(failed["same_gate_failures"]) == 1 and
        int(failed["lifetime_failures"]) == 1,
        "Failed major breakthrough must lose 10% gate XP and persist both counters."):
        return
    if not _check(_close(disciple.stamina,old_stamina) and _close(disciple.hp,old_hp),
        "V2 failed breakthrough must not inherit legacy HP/stamina penalties."):
        return
    var not_full := DiscipleRealmProgressV2.attempt_cultivation_breakthrough(
        disciple,rng,_costs(1),1.0,true,"attempt_02"
    )
    if not _check(not bool(not_full.get("ok",true)),
        "After failure the disciple must re-cultivate lost gate EXP."):
        return
    var refill := DiscipleRealmProgressV2.grant_xp(
        disciple,"cultivation",100.0,"fixed",_costs(1)
    )
    if not _check(bool(refill.get("ok",false)) and bool(refill["at_major_gate"]),
        "Re-cultivation did not replenish the gate."):
        return
    var won := DiscipleRealmProgressV2.attempt_cultivation_breakthrough(
        disciple,rng,_costs(1),1.0,true,"attempt_02"
    )
    if not _check(bool(won.get("ok",false)) and bool(won["success"]) and
        _close(float(won["chance"]),1.0) and int(won["realm"]) == 2 and
        int(won["floor"]) == 1 and int(won["same_gate_failures"]) == 0 and
        int(won["lifetime_failures"]) == 1,
        "Successful breakthrough must advance only Tu Vi, reset pity, retain lifetime history."):
        return
    if not _check(int(disciple.v2_realm_progress["body"]["realm"]) == 1 and
        not bool(DiscipleRealmProgressV2.attempt_cultivation_breakthrough(
            disciple,rng,_costs(1),1.0,true,"attempt_02"
        ).get("ok",true)),
        "A Tu Vi breakthrough advanced Body or replayed the same gate."):
        return

    disciple.v2_realm_progress["body"]["floor"] = 10
    disciple.v2_realm_progress["body"]["xp"] = 1000.0
    if not _check(not bool(DiscipleRealmProgressV2.commit_authorized_body_gate(
        disciple,_costs(1),false,"body_gate_bad"
    ).get("ok",true)), "Luyen The gate bypassed authored prerequisite authorization."):
        return
    var body_pass := DiscipleRealmProgressV2.commit_authorized_body_gate(
        disciple,_costs(1),true,"body_gate_01"
    )
    if not _check(bool(body_pass.get("ok",false)) and
        int(disciple.v2_realm_progress["body"]["realm"]) == 2 and
        int(disciple.v2_realm_progress["cultivation"]["realm"]) == 2,
        "Authorized Body gate did not advance its OWN 30x10 track."):
        return

    DiscipleRealmProgressV2.set_auto_breakthrough(disciple,"cultivation",true)
    var saved: Dictionary = JSON.parse_string(JSON.stringify(disciple.to_dict()))
    var restored := DiscipleState.from_dict(saved)
    if restored.v2_realm_progress != disciple.v2_realm_progress:
        print("V2 PROFILE EXPECTED: ",var_to_str(disciple.v2_realm_progress))
        print("V2 PROFILE RESTORED: ",var_to_str(restored.v2_realm_progress))
    if not _check(restored.v2_realm_progress == disciple.v2_realm_progress and
        bool(restored.v2_realm_progress["cultivation"]["auto_breakthrough"]) and
        int(restored.v2_realm_progress["cultivation"]["lifetime_failures"]) == 1 and
        _close(restored.max_hp,disciple.max_hp) and
        _close(restored.hp/restored.max_hp,disciple.hp/disciple.max_hp),
        "Progress, gate history, or ratio-preserving live V2 HP failed save/load."):
        return

    # Ordinary natural EXP modifiers from real sources stack additively with
    # Tu Chat/Can Cot in their own channel. Disabled future effects are inert.
    var body_bonus: Array = [
        {"source_id":"approved_training","channel":"body_xp_gain",
            "mode":"percent_add","value":0.10,"enabled":true},
        {"source_id":"unimplemented_trait","channel":"body_xp_gain",
            "mode":"percent_add","value":0.50,"enabled":false}
    ]
    var added_body := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",100.0,"natural",_costs(2),body_bonus
    )
    if not _check(bool(added_body.get("ok",false)) and
        _close(float(added_body["gained"]),130.0) and
        _close(float(added_body["natural_factor"]),1.30),
        "Căn Cốt and enabled authored body EXP modifier must add, not multiply."):
        return
    var fixed_again := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",100.0,"fixed",_costs(2),body_bonus
    )
    if not _check(bool(fixed_again.get("ok",false)) and
        _close(float(fixed_again["gained"]),100.0),
        "Fixed EXP was illegally multiplied by innate/active natural modifiers."):
        return
    var before_bad_source := disciple.v2_realm_progress.duplicate(true)
    var invalid_bonus := DiscipleRealmProgressV2.grant_xp(
        disciple,"body",100.0,"natural",_costs(2),[
            {"source_id":"fake","channel":"body_xp_gain","mode":"percent_add",
                "value":0.2,"condition":"any_boss"}
        ]
    )
    if not _check(not bool(invalid_bonus.get("ok",true)) and
        disciple.v2_realm_progress == before_bad_source,
        "Unknown conditional XP source must be rejected atomically."):
        return

    var first_labels := DiscipleRealmProgressV2.realm_name("cultivation",1)
    if not _check(first_labels == "Phàm Nhân" and
        DiscipleRealmProgressV2.realm_name("cultivation",10) == "Đại Thừa" and
        DiscipleRealmProgressV2.realm_name("cultivation",30) == "Sáng Thế Chủ" and
        DiscipleRealmProgressV2.realm_name("body",1) == "Phàm Thân" and
        DiscipleRealmProgressV2.realm_name("body",10) == "Linh Thân" and
        DiscipleRealmProgressV2.realm_name("body",30) == "Sáng Thế Thần Thể" and
        DiscipleRealmProgressV2.realm_name("body",31).is_empty() and
        DiscipleRealmProgressV2.CULTIVATION_REALM_NAMES.size()==30 and
        DiscipleRealmProgressV2.BODY_REALM_NAMES.size()==30,
        "Tu Vi and Luyen The names are not from the exact locked 30-realm ladders."):
        return
    var current_labels := DiscipleRealmProgressV2.current(disciple)
    if not _check(current_labels["cultivation_name"] == "Luyện Khí" and
        current_labels["body_name"] == "Luyện Bì",
        "The disciple's visible realm names do not match current persisted levels."):
        return
    var end_curve := CombatStatsV2.derive(30,10,30,10,disciple.potential)
    if not _check(bool(end_curve.get("ok",false)) and
        DiscipleRealmProgressV2.global_floor(30,10) == 300 and
        DiscipleRealmProgressV2.global_floor(31,1) == 0,
        "Both realm tracks must obey the 30x10 ceiling."):
        return
    # The real map PvE adapter must trust persistent character progression,
    # never the caller's fabricated 30x10 realm numbers.
    var choice := HuntingMapV2.choose_level(state,"thanh_truc_lam",1)
    if not _check(bool(choice.get("ok",false)),
        "Could not enable a real V2-region proving encounter."):
        return
    var member := {
        "disciple_id":str(disciple.id),"party_id":"v2_party",
        "role":"frontline","position":Vector2(8.0,9.0)
    }
    var authentic := HuntingPveRunV2.new()
    var started := authentic.begin(state,"thanh_truc_lam",
        "v2_real_realm_match",91223,[member])
    if not _check(bool(started.get("ok",false)),
        "A genuine V2 disciple could not fight with OWN saved dual progress."):
        return
    var fighter: Dictionary = authentic.battle.actors[str(disciple.id)]
    var expected := DiscipleRealmProgressV2.derive_stats(disciple)
    if not _check(_close(float(fighter["stats"]["max_hp"]),
        float(expected["stats"]["max_hp"])) and
        _close(float(fighter["stats"]["attack"]),float(expected["stats"]["attack"])),
        "Group PvE did not consume stored Tu Vi/Body stat authority."):
        return
    var impostor := member.duplicate(true)
    impostor["realm"] = 30
    var forbidden := HuntingPveRunV2.new().begin(state,"thanh_truc_lam",
        "v2_spoofed_realm",111,[impostor])
    if not _check(not bool(forbidden.get("ok",true)),
        "A caller forged a high realm over persistent V2 character state."):
        return

    print("DV2-03 2×300 REAL TRACKS + XP SOURCES + BREAKTHROUGH GATES + SAVE: PASS")
    quit(0)
