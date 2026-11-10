extends SceneTree

# Structural map/performance contract. This does NOT assert real FPS gain.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    if not PveClusterLayoutV1.source_gates_valid():
        push_error("PVE_MAP02_FAIL illegal camp grouping or unsourced next world")
        quit(1)
        return
    var registry := PveMultiCampPopulationV1.new_registry(10)
    if not bool(registry.get("ok",false)) or (registry.get("slots",{}) as Dictionary).size() != 200:
        push_error("PVE_MAP02_FAIL 200 real slots not preserved")
        quit(1)
        return
    var seen: Dictionary = {}
    for cluster in PveClusterLayoutV1.LIVE_CLUSTERS:
        var camps := PveClusterLayoutV1.camps_for_cluster(str(cluster["id"]))
        if camps.size() != 10:
            push_error("PVE_MAP02_FAIL invalid ten-camp segment")
            quit(1)
            return
        for index in camps:
            var row := PveClusterLayoutV1.for_camp(index)
            if str(row.get("cluster_id","")) != str(cluster["id"]) \
                    or seen.has(index) or bool(row.get("physical_map_changed",true)):
                push_error("PVE_MAP02_FAIL duplicate/imaginary physical map")
                quit(1)
                return
            seen[index] = true
    if seen.size() != 20 or not PveClusterLayoutV1.for_camp(-1).is_empty() \
            or not PveClusterLayoutV1.for_camp(20).is_empty() \
            or PveClusterLayoutV1.camps_for_cluster("fabricated").size() != 0:
        push_error("PVE_MAP02_FAIL new camp or lost existing camp")
        quit(1)
        return
    if PveDistributedWorldV1.MAX_ACTIVE_MONSTERS != 40:
        push_error("PVE_MAP02_FAIL active actor cap was silently rewritten")
        quit(1)
        return
    print("PVE_MAP02_20_CAMPS_2X10_GROUPS_200_SLOTS_40_ACTIVE_CAP_PASS"
        +" playable_new_maps=0 real_fps_qa=PENDING")
    quit(0)
