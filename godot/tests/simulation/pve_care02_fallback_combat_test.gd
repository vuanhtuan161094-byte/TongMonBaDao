extends SceneTree

# Covers the V2 scheduler fallback after a legacy CombatSystem defeat.
# One real state + recruit, canonical scheduler minutes and Injury return.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P37Factory.create_state(915731)
    var ids: Array = state.recruitment_candidates.keys()
    ids.sort()
    if ids.is_empty():
        push_error("PVE_CARE02_FALLBACK_FAIL no V2 candidates")
        quit(1)
        return
    var id := StringName(str(ids[0]))
    if not bool(RecruitmentSystem.new().accept_candidate(state,id).get("ok",false)):
        push_error("PVE_CARE02_FALLBACK_FAIL recruit refused")
        quit(1)
        return
    var d: DiscipleState = state.disciples[id]
    if not DiscipleRealmProgressV2.owns_v2_progression(d):
        push_error("PVE_CARE02_FALLBACK_FAIL recruit not V2")
        quit(1)
        return
    var regions: Array = state.regions.keys()
    regions.sort()
    if regions.is_empty():
        push_error("PVE_CARE02_FALLBACK_FAIL no legacy region")
        quit(1)
        return
    d.region_id = StringName(str(regions[0]))
    d.current_action = &"RETURN_SECT"
    d.hp = d.max_hp
    # This persisted marker is created by the two real defeat branches in
    # CombatSystem. Here we target the separate scheduler return contract.
    d.last_decision["v2_legacy_defeat_injury_pending"] = true
    var before_hp := d.hp
    var scheduler := SimulationScheduler.new(state)
    scheduler.step()
    if d.region_id != &"sect" or d.injury_level != 1 \
            or d.injury_recover_at_tick != state.tick+120 \
            or not is_equal_approx(d.hp,before_hp) \
            or d.last_decision.has("v2_legacy_defeat_injury_pending"):
        push_error("PVE_CARE02_FALLBACK_FAIL scheduler did not attach one Injury after full HP revive")
        quit(1)
        return
    var due := d.injury_recover_at_tick
    scheduler.run_ticks(119)
    if d.injury_level != 1 or not is_equal_approx(d.hp,before_hp):
        push_error("PVE_CARE02_FALLBACK_FAIL Injury healed early or changed HP")
        quit(1)
        return
    scheduler.step()
    if d.injury_level != 0 or d.injury_recover_at_tick != 0 \
            or state.tick != due or not is_equal_approx(d.hp,before_hp):
        push_error("PVE_CARE02_FALLBACK_FAIL Injury did not expire on canonical tick")
        quit(1)
        return
    print("PVE_CARE02_V2_LEGACY_COMBAT_RETURN_INJURY120_FULLHP_PASS")
    quit(0)
