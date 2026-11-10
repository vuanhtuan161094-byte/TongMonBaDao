class_name PveClusterLayoutV1
extends RefCounted

# PVE-MAP02: PRESENTATION PLANNING only. Exactly one physical Source-A
# Thanh Truc Lam topology remains; no new terrain, save migration or rewards.
# Two discoverable groups of 10 logical camps preserve all 20 camp/200 slots.
const CAMPS_PER_CLUSTER := 10
const LIVE_MAP_ID := "thanh_truc_lam"
const LIVE_CLUSTERS := [
    {"id":"thanh_truc_lam_bac","name":"Thanh Trúc Lâm · Bắc","first":0,"count":10},
    {"id":"thanh_truc_lam_nam","name":"Thanh Trúc Lâm · Nam","first":10,"count":10}
]
# Other authored instanced-map IDs are NOT claims of playable open-world maps.
const NEXT_MAP_GATES := {
    "bach_thach_khe":{"region_authored":true,"open_world":false,
        "reason":"needs_real_topology_scene_and_save_identity"},
    "hac_phong_coc":{"region_authored":true,"open_world":false,
        "reason":"needs_real_topology_scene_and_save_identity"}
}

static func for_camp(index: int) -> Dictionary:
    if index < 0 or index >= PveMultiCampPopulationV1.CAMP_COUNT:
        return {}
    var cluster: Dictionary = LIVE_CLUSTERS[int(index/CAMPS_PER_CLUSTER)]
    return {"map_id":LIVE_MAP_ID,"cluster_id":cluster["id"],
        "cluster_name":cluster["name"],"camp_id":PveMultiCampPopulationV1.camp_id(index),
        "camp_index":index,"physical_map_changed":false}

static func camps_for_cluster(cluster_id: String) -> Array[int]:
    var camps: Array[int] = []
    for raw in LIVE_CLUSTERS:
        var group: Dictionary = raw
        if str(group["id"]) == cluster_id:
            for index in range(int(group["first"]),int(group["first"])+int(group["count"])):
                camps.append(index)
            return camps
    return camps

static func source_gates_valid() -> bool:
    if PveMultiCampPopulationV1.CAMP_COUNT != 20 \
            or PveMultiCampPopulationV1.MIN_SLOTS_PER_CAMP != 10 \
            or MapBattleV2.MAX_MONSTERS != 40:
        return false
    var seen: Dictionary = {}
    for group in LIVE_CLUSTERS:
        for index in camps_for_cluster(str(group["id"])):
            if seen.has(index) or index < 0 or index >= PveMultiCampPopulationV1.CAMP_COUNT:
                return false
            seen[index] = true
    if seen.size() != 20:
        return false
    for map_id in NEXT_MAP_GATES:
        if bool(NEXT_MAP_GATES[map_id]["open_world"]):
            return false
        if not HuntingMapV2.REGION_CONTENT.has(map_id):
            return false
    return true
