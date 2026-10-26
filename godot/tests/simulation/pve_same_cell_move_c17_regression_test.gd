extends SceneTree

# Focused regression for AUX-02 C17: both positions floor to the same Source A
# cell, but the final gap exceeded MapBattleV2's 0.45 move-order threshold.
# This test uses a synthetic all-walkable grid (not real Source A art).
const SOURCE_SHA := "0123456789abcdef0123456789abcdef01234567"
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool,message: String) -> bool:
    checks += 1
    if not condition:
        push_error("PVE SAME-CELL MOVE FAIL: "+message)
        quit(1)
        return false
    return true

func _run() -> void:
    var navigation: Dictionary = {
        "width":192,"height":192,
        "blocked":PackedByteArray(),
        "source_blob_sha":SOURCE_SHA,
        "source_map":"synthetic_same_cell_c17_qa"
    }
    navigation["blocked"].resize(192*192)
    # Exact position/target from AUX-02 Windows regression evidence.
    var initial := Vector2(96.35806,168.0268)
    var target := Vector2(96.5,168.5)
    var party := [{
        "id":"same_cell_traveler","party_id":"six_slot_party",
        "role":"frontline","position":initial,
        "hp":100.0,"stats":{"max_hp":100.0,"attack":10.0},
        "move_speed":2.0
    }]
    var battle := MapBattleV2.new(20261027)
    var options := {
        "bounds":Rect2(Vector2.ZERO,Vector2(192,192)),
        "navigation":navigation,
        "auto_hunt":false
    }
    var setup := battle.setup_open_world("aux02_c17_subcell_regression",party,[],options)
    if not _check(bool(setup.get("ok",false)),"world setup failed: "+str(setup)):
        return
    if not _check(battle._world_path(initial,target).is_empty()
        and initial.distance_to(target) > 0.45,
        "fixture no longer reproduces same-cell empty-path stall"):
        return
    var sent := battle.order_group_move(["same_cell_traveler"],target)
    if not _check(bool(sent.get("ok",false)),"movement command rejected"):
        return
    for i in range(4):
        var stepped := battle.step()
        if not _check(bool(stepped.get("ok",false)),"world tick %d failed" % i):
            return
    var traveler: Dictionary = battle.actors["same_cell_traveler"]
    if not _check(not bool(traveler.get("move_order_active",true)),
        "move order remains active in destination cell"):
        return
    if not _check(Vector2(traveler["position"]).distance_to(target) <= 0.45,
        "actor remains too far from target: "+str(traveler["position"])):
        return
    if not _check(battle.is_world_position_allowed(traveler["position"]),
        "sub-cell move entered blocked/out-of-world tile"):
        return
    # A pending order must also complete after an active Save/Restore.
    var next := MapBattleV2.new(20261028)
    var next_setup := next.setup_open_world("aux02_c17_resume_regression",party,[],options)
    if not _check(bool(next_setup.get("ok",false)),"second world setup failed"):
        return
    next.order_group_move(["same_cell_traveler"],target)
    var snapshot := MapBattleSnapshotV2.save(next)
    if not _check(bool(snapshot.get("ok",false)),"could not create save snapshot"):
        return
    var restored := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(restored.get("ok",false)),"could not restore save snapshot"):
        return
    var replay: MapBattleV2 = restored["battle"]
    for _n in range(4):
        replay.step()
    var resumed: Dictionary = replay.actors["same_cell_traveler"]
    if not _check(not bool(resumed.get("move_order_active",true))
        and Vector2(resumed["position"]).distance_to(target) <= 0.45,
        "restored pending order never finished"):
        return
    print("PVE SAME-CELL MOVE C17: PASS checks=%d no_stall=true save_restore=true physical_mouse=NOT_TESTED" % checks)
    quit(0)
