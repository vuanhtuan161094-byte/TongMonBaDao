extends SceneTree

# CODE-CLEAN focused regression: the finite encounter reward path must never
# process continuous world kills, even if a malformed caller forges WIN.
# Synthetic invalid state is intentional: this is a fail-closed test, not loot.
var checks: int = 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    if not ok:
        push_error("CODE-CLEAN FINITE/WORLD ISOLATION FAILED: " + label)
        quit(1)
        return false
    checks += 1
    return true

func _run() -> void:
    var state := SimulationState.new()
    state.sect.p3_7_resources_enabled = true
    state.sect.v2_pve_enabled = true
    # The region key is intentionally enough for restore's provenance preflight;
    # this test must stop at the mode guard before materialization or mutation.
    state.regions[&"thanh_truc_lam"] = null

    var id := "b3:vs1:bach_thach_khe:123:40"
    var world := MapBattleV2.new(7)
    if not _check(bool(world.setup(id,[],[],true).get("ok",false)),
        "Could not create valid empty continuous world"): return
    var fake_spawn := {"ok":true,"encounter_id":id}
    var items_before := state.sect.warehouse_resources.duplicate(true)
    var claims_before := state.sect.v2_pve_reward_claims.duplicate(true)
    var result := HuntingMapV2.claim_reward(state,fake_spawn,world)
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Live world reached finite reward writer"): return

    # Simulate an untrusted caller fabricating a terminal victory on an actual
    # continuous battle. The mode guard must run before the victory branch.
    world.active = false
    world.outcome = "win"
    result = HuntingMapV2.claim_reward(state,fake_spawn,world)
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Forged WIN from continuous world reached finite payout"): return

    var finite_with_reserved_id := MapBattleV2.new(12)
    finite_with_reserved_id.encounter_id = id
    finite_with_reserved_id.active = false
    finite_with_reserved_id.outcome = "win"
    result = HuntingMapV2.claim_reward(state,fake_spawn,finite_with_reserved_id)
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Reserved B3 world ID accepted from finite-style caller"): return

    # Isolation is based on MODE, not only the current B3 prefix. Future
    # R11-world IDs must be protected as well.
    var future := MapBattleV2.new(19)
    if not _check(bool(future.setup("r11:world:trial",[],[],true).get("ok",false)),
        "Future world setup failed"): return
    result = HuntingMapV2.claim_reward(state,
        {"ok":true,"encounter_id":"r11:world:trial"},future)
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Non-B3 continuous world leaked to finite payout"): return

    # A v3 continuous battle snapshot may be fully valid in MapBattleSnapshotV2,
    # but it must be invalid as a *finite* HuntingPveRunV2 save.
    var snapshot := MapBattleSnapshotV2.save(future)
    if not _check(bool(snapshot.get("ok",false)), "Continuous snapshot failed"): return
    var injected := {
        "ok":true,"version":1,"region_id":"thanh_truc_lam",
        "difficulty":1,"encounter_id":future.encounter_id,
        "reward_seed":333,"battle":snapshot
    }
    result = HuntingPveRunV2.restore_state(state,injected)
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Continuous snapshot restored as finite encounter"): return

    var session := HuntingPveRunV2.new()
    session.owner_state = state
    session.region_id = "thanh_truc_lam"
    session.battle = future
    session.spawn_data = injected
    for action in [
        session.advance(false),session.finish(8),session.claim(),
        session.save_state(),session._persist_live_state()
    ]:
        if not _check(not bool(action.get("ok",true)) and
            str(action.get("reason","")) == "continuous_world_requires_per_kill_receipts",
            "Finite lifecycle accepted a continuous battle"): return

    future.active = false
    future.outcome = "win"
    result = session._settle_terminal()
    if not _check(not bool(result.get("ok",true)) and
        str(result.get("reason","")) == "continuous_world_requires_per_kill_receipts",
        "Continuous world settled a finite encounter terminal"): return

    if not _check(items_before == state.sect.warehouse_resources and
        claims_before == state.sect.v2_pve_reward_claims and
        state.sect.v2_pve_active_runs.is_empty() and
        state.sect.v2_pve_settlement_receipts.is_empty(),
        "Negative fixtures mutated Warehouse or encounter receipts"): return
    print("CODE-CLEAN FINITE/WORLD REWARD ISOLATION PASS (%d checks)" % checks)
    quit(0)
