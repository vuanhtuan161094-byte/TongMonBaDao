extends SceneTree

const DEFAULT_SOURCE_ROOT := "E:/codex/work/jxqy2_slice/source"

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, reason: String) -> bool:
    if condition:
        return true
    push_error("PVE JX OPEN WORLD TOPOLOGY FAIL: "+reason)
    quit(1)
    return false

func _run() -> void:
    var root_path := OS.get_environment("TMB_JXQY2_ASSET_ROOT")
    if root_path.is_empty():
        root_path = DEFAULT_SOURCE_ROOT
    var source := Jxqy2SourceSliceV1.new()
    var loaded := source.load_sources(root_path)
    if not _check(bool(loaded.get("ok",false)),"pinned JX source load/hash validation failed: "+str(loaded.get("reason",""))):
        return
    if not _check(source.verified_files == 44 and source.map_data.get("width",0) == 50 and source.map_data.get("height",0) == 100,
        "the reviewed 50x100 JX map and 44-file manifest were not used"):
        return
    var navigation := source.navigation_grid()
    var topology := PveOpenWorldTopologyV1.build(navigation)
    if not _check(bool(topology.get("ok",false)),"could not build walkable zone topology: "+str(topology.get("reason",""))):
        return
    if not _check(topology["camp_positions"].size() == 20 and topology["slot_positions"].size() == 200
        and topology["party_spawn_points"].size() == 6 and str(topology["source_blob_sha"]) == str(source.map_data["source_blob_sha"]),
        "one world did not expose 20 internal zones, 200 natural spawn slots, and a real 6-person start"):
        return
    var unique_positions: Dictionary = {}
    var party_anchor: Vector2 = topology["camp_positions"][0]
    var party_cell := Vector2i(floori(party_anchor.x),floori(party_anchor.y))
    for point in topology["party_spawn_points"]:
        var cell := Vector2i(floori(point.x),floori(point.y))
        var key := "%.3f:%.3f" % [point.x,point.y]
        if not _check(PveOpenWorldTopologyV1._walkable(navigation,cell)
            and cell == party_cell and point.distance_to(party_anchor) <= 0.55
            and not unique_positions.has(key),
            "six disciples are not tightly grouped on the walkable C01 tile"):
            return
        unique_positions[key] = true
    var nearest_c01_spawn := INF
    for ordinal in range(PveOpenWorldTopologyV1.SLOTS_PER_CAMP):
        var monster_position: Vector2 = topology["slot_positions"][PveMultiCampPopulationV1.slot_id(0,ordinal)]
        nearest_c01_spawn = minf(nearest_c01_spawn,party_anchor.distance_to(monster_position))
    if not _check(nearest_c01_spawn <= 0.71,
        "C01 monsters are not close enough for the grouped team to engage naturally"):
        return
    for camp_index in range(20):
        var center: Vector2 = topology["camp_positions"][camp_index]
        var key := Vector2i(floori(center.x),floori(center.y))
        if not _check(PveOpenWorldTopologyV1._walkable(navigation,key),
            "a continuous spawn region was placed inside blocked source terrain"):
            return
    var data := JSON.stringify(topology, "", false, true)
    if not _check(not data.is_empty() and JSON.parse_string(data) is Dictionary,
        "the saved topology fields are not serializable for the canonical state envelope"):
        return
    print("PVE JX OPEN WORLD TOPOLOGY PASS map=50x100 source_hashes=%d connected_cells=%d zones=20 spawn_slots=200 party_spawn=6 grouped_near_c01=true" % [
        source.verified_files,topology["navigation"]["blocked"].size()])
    quit(0)
