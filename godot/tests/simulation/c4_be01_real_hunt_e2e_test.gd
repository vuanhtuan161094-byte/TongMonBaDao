extends SceneTree

# Real P37 state → authentic V2 recruit → optional owned skills →
# selected map → begin → checkpoint → deterministic resume → settle → claim.
# All maxed stats/skills here are in disposable test state only.
func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("C4 BE01 E2E FAIL: "+detail)
        quit(1)
        return false
    return true

func _run() -> void:
    var state := P37Factory.create_state(40401)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.combat_skills_enabled = true
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+6)
    var picked: Array = []
    for i in range(6):
        var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
            state,DiscipleGeneratorV2.SOURCE_ORDINARY,950+i)
        if not _assert(candidate != null,
                "authentic candidate could not be generated"):
            return
        state.recruitment_candidates[candidate.id] = candidate
        var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
        if not _assert(bool(accepted.get("ok",false)),
                "authentic V2 recruit failed"):
            return
        var person: DiscipleState = state.disciples[candidate.id]
        if not _assert(DiscipleRealmProgressV2.progression_ready(person),
                "recruit lacked canonical V2 progression"):
            return
        # Stress level and full learned skill ownership are temporary QA
        # fixtures. These assignments NEVER touch player saves or main.
        person.v2_realm_progress["cultivation"]["realm"] = 30
        person.v2_realm_progress["cultivation"]["floor"] = 10
        person.v2_realm_progress["body"]["realm"] = 30
        person.v2_realm_progress["body"]["floor"] = 10
        person.cultivation_stage_index = 9
        person.current_action = &"IDLE"
        person.region_id = &"sect"
        for skill in CombatSkillSystem.SKILLS.keys():
            person.learned_combat_skills[str(skill)] = true
        if not _assert(bool(DiscipleRealmProgressV2.sync_live_hp(person).get("ok",false)),
                "max canonical HP sync failed"):
            return
        person.hp = person.max_hp
        picked.append(str(person.id))
    var roster := HuntingExpeditionEntryV2.eligible_roster(state)
    if not _assert(roster.size() >= 6,"roster omitted real maxed V2 recruits"):
        return
    var built := HuntingExpeditionEntryV2.build_party(state,picked)
    if not _assert(bool(built.get("ok",false)) and built["party"].size()==6,
            "world-gate party composition invalid"):
        return
    var party: Array = built["party"]
    if not _assert(party[0]["party_id"] == party[5]["party_id"] and
            int(party[0]["realm"]) == 30 and int(party[5]["body_floor"]) == 10,
            "max ranks/party IDs not preserved"):
        return
    if not _assert(not bool(HuntingExpeditionEntryV2.build_party(
            state,[picked[0],picked[0]]).get("ok",true)),
            "duplicate member admitted"):
        return
    if not _assert(bool(HuntingMapV2.choose_level(
            state,"thanh_truc_lam",5).get("ok",false)),
            "tier-five region selection failed"):
        return
    var encounter := HuntingExpeditionEntryV2.next_encounter_id(state)
    var run := HuntingPveRunV2.new()
    var started := run.begin(state,"thanh_truc_lam",encounter,16101,party)
    if not _assert(bool(started.get("ok",false)),
            "real 6-person hunt did not begin: "+str(started.get("reason","unknown"))):
        return
    var origin := HuntingExpeditionEntryV2.display_metadata(state,run)
    if not _assert(origin.size() == run.battle.actors.size() and
            str(origin[picked[0]]["display_name"]) ==
                str(state.disciples[StringName(picked[0])].display_name) and
            int(origin["mob_00"]["realm_index"]) == 1,
            "real actor/source monster identity bridge missing"):
        return
    if not _assert(not bool(run.claim().get("ok",true)),
            "active battle yielded early rewards"):
        return
    var no_second := HuntingPveRunV2.new()
    if not _assert(not bool(no_second.begin(state,"thanh_truc_lam",
            "not_while_reserved",16102,party).get("ok",true)),
            "reserved disciple admitted into two hunts"):
        return
    for k in range(4):
        if run.battle.active:
            var next := run.advance(false)
            if not _assert(bool(next.get("ok",false)),
                    "advance failed"):
                return
    var restored := HuntingPveRunV2.resume_active(state,encounter)
    if not _assert(bool(restored.get("ok",false)),
            "persisted encounter could not resume"):
        return
    var duplicate: HuntingPveRunV2 = restored["session"]
    var done := run.finish()
    var repeated := duplicate.finish()
    if not _assert(bool(done.get("ok",false)) and
            bool(repeated.get("ok",false)) and
            done["summary"] == repeated["summary"] and
            run.battle.outcome == "win",
            "replay diverged or max-cohort victory failed"):
        return
    if not _assert(state.sect.v2_pve_settlement_receipts.has(encounter),
            "injury/HP settlement receipt missing"):
        return
    var first_claim := run.claim()
    if not _assert(bool(first_claim.get("ok",false)) and
            state.sect.v2_pve_reward_claims.has(encounter) and
            not bool(run.claim().get("ok",true)) and
            not bool(duplicate.claim().get("ok",true)),
            "warehouse reward paid more than once"):
        return
    for raw in picked:
        var person: DiscipleState = state.disciples[StringName(str(raw))]
        if not _assert(person.active_pve_encounter_id.is_empty() and
                person.region_id == &"sect",
                "participant left reserved/outside after terminal settlement"):
            return
    var saved := SectState.from_dict(JSON.parse_string(JSON.stringify(state.sect.to_dict())))
    if not _assert(saved.v2_pve_reward_claims.has(encounter) and
            saved.v2_pve_settlement_receipts.has(encounter),
            "claim/settlement receipt not persistent"):
        return
    print("C4 BE01 REAL E2E PASS: six V2 max-rank recruits all learned P2 skill IDs, five-tier map, resume, terminal, once-only warehouse receipt")
    quit(0)
