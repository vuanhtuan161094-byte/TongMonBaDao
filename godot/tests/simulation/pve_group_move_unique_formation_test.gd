extends SceneTree

# Verifies that low-level MapBattleV2 formation orders are deterministic,
# unique, walkable and atomic when all nearby offsets snap to one tile.
# Synthetic navigation fixture. Godot engine execution is REQUIRED for PASS.
const GRID := 12
const SHA := "0123456789abcdef0123456789abcdef01234567"
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool,why: String) -> bool:
    checks += 1
    if not ok:
        push_error("PVE FORMATION UNIQUE FAIL: "+why)
        quit(1)
        return false
    return true

func _navigation(crowded: bool) -> Dictionary:
    var blocked := PackedByteArray()
    blocked.resize(GRID * GRID)
    if crowded:
        blocked.fill(1)
        blocked[2*GRID+2] = 0
        blocked[6*GRID+6] = 0
    else:
        for cell in [
            Vector2i(7,6),Vector2i(6,7),Vector2i(5,6),
            Vector2i(6,5),Vector2i(7,7)
        ]:
            blocked[cell.y*GRID+cell.x] = 1
    return {
        "width":GRID,"height":GRID,"blocked":blocked,
        "source_blob_sha":SHA,"source_map":"synthetic_formation_qa"
    }

func _party(crowded: bool) -> Array:
    var party: Array = []
    for i in range(6):
        var at := Vector2(2.5,2.5) if crowded else Vector2(1.5+float(i%3),1.5+float(int(i/3)))
        party.append({
            "id":"formation_%02d" % i,"party_id":"party_0",
            "role":"frontline","position":at,"hp":100.0,
            "stats":{"max_hp":100.0,"attack":10.0},"move_speed":2.0
        })
    return party

func _setup(crowded: bool) -> MapBattleV2:
    var battle := MapBattleV2.new(20261027)
    var setup := battle.setup_open_world(
        "formation_unique_%s" % str(crowded),_party(crowded),[],{
            "bounds":Rect2(Vector2.ZERO,Vector2(GRID,GRID)),
            "navigation":_navigation(crowded),"auto_hunt":false
        })
    if not bool(setup.get("ok",false)):
        return null
    return battle

func _destinations(battle: MapBattleV2) -> Dictionary:
    var result: Dictionary = {}
    for id in battle.actors:
        var actor: Dictionary = battle.actors[id]
        if actor.get("move_order_active",false):
            result[str(id)] = actor.get("move_order_position")
    return result

func _all_unique(battle: MapBattleV2) -> bool:
    var seen := {}
    for point in _destinations(battle).values():
        if seen.has(point) or not battle.is_world_position_allowed(point):
            return false
        seen[point] = true
    return seen.size() == 6

func _run() -> void:
    var battle := _setup(false)
    if not _check(battle != null,"walkable 6-member battle setup failed"):
        return
    var ids: Array = battle.actors.keys()
    ids.sort()
    var chosen := battle.order_group_move(ids,Vector2(6.5,6.5))
    if not _check(bool(chosen.get("ok",false)) and _all_unique(battle),
        "blocked offsets still converge onto same destination"):
        return
    var planned := _destinations(battle)
    var repeat := battle.order_group_move(ids,Vector2(6.5,6.5))
    if not _check(bool(repeat.get("ok",false)) and _destinations(battle) == planned,
        "repeat command returned different reserved slots"):
        return
    var snapshot := MapBattleSnapshotV2.save(battle)
    if not _check(bool(snapshot.get("ok",false)),"active movement snapshot was not saved"):
        return
    var loaded := MapBattleSnapshotV2.load(snapshot)
    if not _check(bool(loaded.get("ok",false)),"active movement snapshot was rejected"):
        return
    var restored: MapBattleV2 = loaded["battle"]
    if not _check(_all_unique(restored) and _destinations(restored) == planned,
        "unique formation was not preserved by Save/Restore"):
        return
    # With only two traversable cells, reject the entire request before
    # updating a single actor or writing a partial authoritative event.
    var scarce := _setup(true)
    if not _check(scarce != null,"scarce-grid setup failed"):
        return
    var before_events := scarce.events.size()
    var refused := scarce.order_group_move(ids,Vector2(6.5,6.5))
    if not _check(not bool(refused.get("ok",true))
        and str(refused.get("reason","")) == "move_formation_has_insufficient_walkable_cells",
        "insufficient formation slots should fail closed"):
        return
    if not _check(_destinations(scarce).is_empty() and scarce.events.size() == before_events,
        "insufficient formation slots partially mutated actor orders/events"):
        return
    print("PVE FORMATION UNIQUE: PASS checks=%d slots=6 deterministic=true snapshot=true atomic_failure=true physical_mouse=NOT_TESTED" % checks)
    quit(0)
