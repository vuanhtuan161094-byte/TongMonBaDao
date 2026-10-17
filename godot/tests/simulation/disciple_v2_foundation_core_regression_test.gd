extends SceneTree

# Typed six-foundation effects and retroactive Tiềm Lực on the REAL V2
# Realm/Body core. Test grants are synthetic fixtures, NOT gameplay faucets.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("DISCIPLE V2 FOUNDATION CORE FAIL: " + why)
        quit(1)
        return false
    return true

func _close(a: float, b: float) -> bool:
    return absf(a-b) <= maxf(0.00001,maxf(absf(a),absf(b))*0.000001)

func _run() -> void:
    var state := P37Factory.create_state(962101)
    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = state.disciples.size()+1
    var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,962102)
    if not _check(candidate != null,"authentic V2 generation failed"):
        return
    state.recruitment_candidates[candidate.id] = candidate
    if not _check(bool(RecruitmentSystem.new().accept_candidate(state,candidate.id).get("ok",false)),
        "authentic V2 recruitment failed"):
        return
    var actor: DiscipleState = state.disciples[candidate.id]
    var foundation := FoundationSystem.new()
    var original_birth := actor.foundation_birth_values.duplicate(true)
    var original_potential := actor.potential
    var original_quality := actor.disciple_quality
    var before := DiscipleRealmProgressV2.derive_stats(actor)
    if not _check(bool(before.get("ok",false)),"canonical Realm/Body core missing"):
        return
    var before_progress := actor.v2_realm_progress.duplicate(true)
    actor.hp = actor.max_hp*0.40
    var original_hp_ratio := actor.hp/actor.max_hp

    for amount in [NAN,INF,-1.0,0.0]:
        if not _check(not foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,amount)
            and actor.potential == original_potential
            and actor.foundation_birth_values == original_birth
            and actor.v2_realm_progress == before_progress,
            "invalid/nonfinite permanent points mutated character"):
            return

    # A malformed current HP pair may not commit a permanent Potential gain.
    var valid_hp := actor.hp
    actor.hp = NAN
    var corrupted_gain := foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,10.0)
    actor.hp = valid_hp
    if not _check(not corrupted_gain and actor.potential == original_potential
        and actor.foundation_birth_values == original_birth,
        "corrupt HP accepted a non-atomic Potential mutation"):
        return

    if not _check(foundation.add_permanent_points(actor,FoundationSystem.DIM_POTENTIAL,1250.0),
        "valid permanent Tiềm Lực was refused"):
        return
    var after := DiscipleRealmProgressV2.derive_stats(actor)
    if not _check(bool(after.get("ok",false)),"post-growth core invalid"):
        return
    var expected_factor := (1.0+0.0005*actor.potential)/(1.0+0.0005*original_potential)
    for channel in CombatStatsV2.CORE_CHANNELS:
        var old_core := float(before["core_breakdown"][channel]["core_after_potential"])
        var new_core := float(after["core_breakdown"][channel]["core_after_potential"])
        if not _check(_close(new_core,old_core*expected_factor),
            "Tiềm Lực did not retroactively scale Realm+Body "+str(channel)):
            return
    if not _check(_close(actor.max_hp,float(after["stats"]["max_hp"]))
        and _close(actor.hp/actor.max_hp,original_hp_ratio)
        and actor.foundation_birth_values == original_birth
        and actor.v2_realm_progress == before_progress
        and actor.disciple_quality == foundation.quality_for_total(foundation.total_disciple(actor)),
        "HP ratio, immutable birth, independent realm/body or derived quality changed"):
        return

    # Unrelated fixed equipment-style flat ATK is NOT multiplied by potential.
    var flat_source := [{"source_id":"regression/flat_equipment","channel":"attack",
        "mode":"flat","value":100.0}]
    var pre_flat := CombatStatsV2.derive(4,5,3,2,original_potential,flat_source)
    var post_flat := CombatStatsV2.derive(4,5,3,2,actor.potential,flat_source)
    if not _check(bool(pre_flat.get("ok",false)) and bool(post_flat.get("ok",false))
        and _close(float(post_flat["core_breakdown"]["attack"]["unrelated_flat"]),100.0)
        and _close(float(post_flat["stats"]["attack"])-float(pre_flat["stats"]["attack"]),
            float(post_flat["core_breakdown"]["attack"]["core_after_potential"])
            -float(pre_flat["core_breakdown"]["attack"]["core_after_potential"])),
        "Tiềm Lực incorrectly amplified unrelated flat equipment"):
        return

    # All other five dimensions retain the C1 channel law, not generic yield.
    for dim in [FoundationSystem.DIM_APTITUDE,FoundationSystem.DIM_CONSTITUTION,
        FoundationSystem.DIM_COMPREHENSION,FoundationSystem.DIM_FORTUNE,FoundationSystem.DIM_CHARISMA]:
        if not _check(foundation.add_permanent_points(actor,dim,75.0),
            "valid foundation increase rejected for "+str(dim)):
            return
    var costs := DiscipleProgressionBalanceV2.floor_costs()
    var natural := DiscipleRealmProgressV2.grant_xp(actor,"cultivation",100.0,"natural",costs,[],true)
    var fixed := DiscipleRealmProgressV2.grant_xp(actor,"cultivation",100.0,"fixed",costs,[],true)
    var body := DiscipleRealmProgressV2.grant_xp(actor,"body",100.0,"natural",costs,[],true)
    if not _check(bool(natural.get("ok",false)) and bool(fixed.get("ok",false))
        and bool(body.get("ok",false))
        and _close(float(natural["gained"]),100.0*(1.0+0.0025*actor.aptitude))
        and _close(float(fixed["gained"]),100.0)
        and _close(float(body["gained"]),100.0*(1.0+0.0020*actor.constitution))
        and _close(foundation.learning_gain_factor(actor.comprehension),1.0+0.0015*actor.comprehension)
        and _close(foundation.luck_score(actor.fortune,100.0,7000),7000.0+actor.fortune-100.0)
        and _close(foundation.social_score(actor.charisma,100.0,7000),7000.0+actor.charisma-100.0)
        and actor.foundation_birth_values == original_birth
        and actor.disciple_quality == foundation.quality_for_total(foundation.total_disciple(actor))
        and original_quality != &"",
        "typed lục duy, fixed XP or unchanged birth snapshot diverged"):
        return

    # Persist the exact six-dimensional growth + live HP ratio through the
    # canonical state serializer, not just the immediate in-memory actor.
    var recovered := SimulationState.from_dict(state.to_dict())
    if not _check(recovered != null,"V2 foundation save/load roundtrip failed"):
        return
    var restored: DiscipleState = recovered.disciples[actor.id]
    if not _check(restored.foundation_birth_values == original_birth
        and restored.v2_realm_progress == before_progress
        and _close(restored.potential,actor.potential)
        and _close(restored.hp/restored.max_hp,actor.hp/actor.max_hp)
        and restored.disciple_quality == actor.disciple_quality,
        "V2 foundation lost canonical values or HP ratio on save/load"):
        return

    # No new foundation mutation may be inferred from dry-run XP checks.
    if not _check(actor.v2_realm_progress == before_progress
        and actor.potential == original_potential+1250.0,
        "preview granted progression or modified potential twice"):
        return
    print("DISCIPLE V2 FOUNDATION REALM/BODY CORE REGRESSION PASS")
    quit(0)
