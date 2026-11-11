extends SceneTree

# Focused D1 test. Invoke with Godot 4.7.2:
# godot --headless --path godot --script res://tests/simulation/v63_d1_content_registry_test.gd

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, detail: String) -> bool:
    if not ok:
        push_error("V63_D1_FAIL: "+detail)
        quit(1)
        return false
    return true

func _run() -> void:
    if not _check(V63FeatureGates.all_disabled(), "all feature flags MUST default OFF"): return
    for key in V63FeatureGates.DEFAULT_FLAGS.keys():
        if not _check(not V63FeatureGates.is_enabled(str(key)), "enabled unexpectedly: "+str(key)): return
    if not _check(not V63FeatureGates.is_enabled("unknown"), "unknown feature enabled"): return
    var loaded: Dictionary = V63ContentRegistry.load_catalogue()
    if not _check(bool(loaded.get("ok",false)), "registry errors: "+str(loaded.get("errors",[]))): return
    var data: Dictionary = loaded["data"]
    if not _check(data["families"].size()==140 and data["paths"].size()==12 and data["bosses"].size()==9,"bad registry counts"): return
    var nodes := 0
    var rare_ultimate := 0
    var rare_passive := 0
    var poison_rare_passive := 0
    var sword_rare_passive := 0
    for family in data["families"]:
        nodes += family["nodes"].size()
        var slot := str(family.get("slot",""))
        var school := str(family.get("school",""))
        for node in family["nodes"]:
            var node_id := str(node.get("id",""))
            var tier := str(node.get("tier",""))
            if slot == "ultimate" and tier == "rare_divine":
                rare_ultimate += 1
            elif slot == "passive" and str(family.get("id","")).ends_with("passive_05") and node_id.contains(".rare_passive."):
                rare_passive += 1
                if school == "poison" and tier == "rare_divine":
                    poison_rare_passive += 1
                elif school == "sword" and tier == "divine":
                    sword_rare_passive += 1
    if not _check(nodes==732 and rare_ultimate==24 and rare_passive==12 and poison_rare_passive==6 and sword_rare_passive==6,"wrong successor distribution: 732 total, 24 rare ultimates, 6 poison + 6 sword rare-passive descendants"): return
    if not _check(int(data.get("skills_s1_candidate_count",0)) == 183 and str(data.get("skills_s1_candidate_source_status","")).contains("SOURCE_PENDING"), "Sword candidate registry must remain source pending"): return
    if not _check(not bool(data.get("enabled",true)), "Sword registry remains inactive"): return
    var poison: Dictionary = V63ContentRegistry.lookup_family(data,"tmb.skill.poison.doc_cham.ultimate")
    if not _check(not poison.is_empty(),"missing poison ultimate"): return
    var human: String = poison["nodes"][0]["id"]
    var children: Array[String] = V63SuccessorGraph.children_of(poison,human)
    if not _check(children.size()==2,"Human must branch into Immortal A/B"): return
    if not _check(V63SuccessorGraph.can_advance(poison,human,children[0],[human]),"known predecessor cannot advance"): return
    if not _check(not V63SuccessorGraph.can_advance(poison,human,children[0],[]),"missing personal knowledge granted successor"): return
    if not _check(not V63SuccessorGraph.valid_active_selection(data,[children[0],children[1]]),"both A/B descendants equipped"): return
    if not _check(V63SuccessorGraph.valid_active_selection(data,[children[0]]),"single descendant rejected"): return
    if not _check(not V63SuccessorGraph.valid_active_selection(data,["tmb.skill.fake"]), "unknown equipped ID accepted"): return
    for boss in data["bosses"]:
        if not _check(not V63BossReadModel.can_spawn(str(boss["id"])) and not V63BossReadModel.can_award_loot(str(boss["id"])), "boss must not be live in D1"): return
        if not _check(V63BossReadModel.get_boss(data,str(boss["id"]))["abilities"].size()==4, "boss read model incomplete"): return
    var duplicate: Dictionary = data.duplicate(true)
    duplicate["families"][1]["id"] = duplicate["families"][0]["id"]
    if not _check(not V63ContentRegistry.validate_catalogue(duplicate).is_empty(),"duplicate ID not rejected"): return
    var cycle: Dictionary = data.duplicate(true)
    cycle["families"][0]["nodes"][1]["parent"] = cycle["families"][0]["nodes"][2]["id"]
    if not _check(not V63ContentRegistry.validate_catalogue(cycle).is_empty(),"successor cycle not rejected"): return
    var unsafe_boss: Dictionary = data.duplicate(true)
    unsafe_boss["bosses"][0]["spawn_ready"] = true
    if not _check(not V63ContentRegistry.validate_catalogue(unsafe_boss).is_empty(),"Boss accidentally spawnable"): return
    print("V63_D1_PASS: 140 families, 732 registry nodes, 24 rare-tier ultimates (24 ultimates), 6 poison + 6 sword rare-passive successors, 9 bosses, gates OFF and negative cases")
    quit(0)
