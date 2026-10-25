extends SceneTree

# This is a World Population contract, NOT live 300-monster combat QA.
# No loot or new XP/warehouse economics are represented or paid in this test.
func _init() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("PVE MULTI CAMP POPULATION FAIL: "+reason)
    quit(1)

func _run() -> void:
    if PveMultiCampPopulationV1.road_edges().size() != 30 or not PveMultiCampPopulationV1.graph_connected():
        _fail("20 camp road topology not connected")
        return
    for count in [10,15,20]:
        var registry := PveMultiCampPopulationV1.new_registry(count)
        if not bool(registry.get("ok",false)):
            _fail("failed to create real deterministic slot registry")
            return
        if registry["slots"].size() != count*20 or not PveMultiCampPopulationV1.verify_structure(registry).is_empty():
            _fail("spawn slot geometry or density inconsistent")
            return
        var stable := JSON.stringify(registry)
        if stable != JSON.stringify(PveMultiCampPopulationV1.new_registry(count)):
            _fail("spawn slot registry not deterministic")
            return
        var loaded: Dictionary = JSON.parse_string(stable)
        if not PveMultiCampPopulationV1.verify_structure(loaded).is_empty():
            _fail("spawn slot state not JSON Save-compatible")
            return
    if bool(PveMultiCampPopulationV1.new_registry(21).get("ok",false)):
        _fail("unbounded camp population bypassed 20 cap")
        return

    var world := PveMultiCampPopulationV1.new_registry(15)
    var slot_id := PveMultiCampPopulationV1.slot_id(7,3)
    var old := JSON.stringify(world)
    var denied := PveMultiCampPopulationV1.record_hp0(world,slot_id,1,"kill_001",false,10.0,8.0)
    if bool(denied.get("ok",false)) or JSON.stringify(world) != old:
        _fail("unverified death mutated persistent spawn state")
        return
    var first := PveMultiCampPopulationV1.record_hp0(world,slot_id,1,"kill_001",true,10.0,8.0)
    if not bool(first.get("ok",false)) or bool(first.get("rewards_granted",true)):
        _fail("trusted HP0 was rejected or generated unauthorized payout")
        return
    if bool(PveMultiCampPopulationV1.record_hp0(world,slot_id,1,"kill_001",true,10.0,8.0).get("ok",false)):
        _fail("the same generation was paid twice")
        return
    if int(PveMultiCampPopulationV1.advance_respawns(world,99.0).get("respawned",-1)) != 0:
        _fail("unpaid HP0 respawned ahead of canonical receipt barrier")
        return
    var ack := PveMultiCampPopulationV1.acknowledge_paid_receipt(world,slot_id,"kill_001")
    if not bool(ack.get("ok",false)) or bool(ack.get("rewards_granted",true)):
        _fail("receipt acknowledgement did not preserve no-payout contract")
        return
    if bool(PveMultiCampPopulationV1.acknowledge_paid_receipt(world,slot_id,"kill_001").get("ok",false)):
        _fail("receipt acknowledged twice")
        return
    if int(PveMultiCampPopulationV1.advance_respawns(world,99.0).get("respawned",-1)) != 1:
        _fail("acknowledged cooldown failed to respawn at clock time")
        return
    var slot: Dictionary = world["slots"][slot_id]
    if int(slot["generation"]) != 2 or str(slot["phase"]) != "READY":
        _fail("next life is not unique or READY")
        return
    if bool(PveMultiCampPopulationV1.record_hp0(world,slot_id,1,"kill_001",true,99.0,8.0).get("ok",false)):
        _fail("stale generation replay accepted after respawn")
        return
    if not PveMultiCampPopulationV1.verify_structure(world).is_empty():
        _fail("post-respawn saved registry failed validation")
        return
    print("PVE MULTI CAMP POPULATION CONTRACT PASS 20_camps=true slots=200/300/400 life_idempotency=true receipt_barrier=true no_loot=true")
    quit(0)
