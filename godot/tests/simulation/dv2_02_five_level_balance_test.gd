extends SceneTree

# Diagnostics only: numerical coefficients remain pilot. Never force a
# universal 100% win-rate expectation from a few seeded archetypes.
func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var state := P37Factory.create_state(602901)
    var ids: Array = state.disciples.keys()
    ids.sort()
    if ids.size() < 6:
        push_error("Need six ACTUAL P3.7 disciples for 5-tier group balance matrix.")
        quit(1)
        return
    var scenario_realm := [1,1,2]
    var scenario_people := [4,6,6]
    var overall: Dictionary = {}
    var regions: Array = HuntingMapV2.REGION_CONTENT.keys()
    regions.sort()
    for raw_region in regions:
        var region := str(raw_region)
        for level in range(1,6):
            var chosen := HuntingMapV2.choose_level(state,region,level)
            if not bool(chosen.get("ok",false)):
                push_error("Region-level choice refused in balance benchmark.")
                quit(1)
                return
            var won := [0,0,0]
            var downed := [0,0,0]
            var duration := [0.0,0.0,0.0]
            for configuration in range(3):
                for run_index in range(8):
                    var members: Array = []
                    for i in range(int(scenario_people[configuration])):
                        members.append({
                            "disciple_id":str(ids[i]),
                            "party_id":"balance_party",
                            "role":"healer" if i == 3 else (
                                "mage" if i == 2 else ("ranged" if i == 1 else "frontline")),
                            "position":Vector2(8.0+float(i%3)*0.7,8.0+float(i/3)*0.75),
                            "realm":int(scenario_realm[configuration]),"floor":1,
                            "body_realm":int(scenario_realm[configuration]),"body_floor":1
                        })
                    var run := HuntingPveRunV2.new()
                    var seed_value := 70011+run_index*149
                    var encounter_id := "%s_level%d_set%d_trial%d" % [
                        region,level,configuration,run_index
                    ]
                    var start := run.begin(state,region,encounter_id,seed_value,members)
                    if not bool(start.get("ok",false)):
                        push_error("One group balance session could not initialize.")
                        quit(1)
                        return
                    var ended := run.finish()
                    if not bool(ended.get("ok",false)):
                        push_error("One group balance session did not resolve.")
                        quit(1)
                        return
                    var result: Dictionary = ended["summary"]
                    if str(result["outcome"]) == "win":
                        won[configuration] += 1
                    downed[configuration] += int(result["downed_disciples"])
                    duration[configuration] += float(result["time"])
            var key := "%s_%d" % [region,level]
            overall[key] = won.duplicate()
            print("DV2E FIVE-TIER BALANCE ",key,
                " same_realm_4=",won[0],"/8",
                " same_realm_6=",won[1],"/8",
                " +1realm_6=",won[2],"/8",
                " avg_downed_6=",float(downed[1])/8.0,
                " avg_seconds_6=",duration[1]/8.0)
    # This is a sanity check, not a desired win-rate:
    # an easier version of the SAME map must not systematically become harder.
    for region in regions:
        var easy: Array = overall["%s_1" % str(region)]
        var hard: Array = overall["%s_5" % str(region)]
        if int(easy[1]) < int(hard[1]):
            push_error("Same team cleared this region's level 5 more often than level 1.")
            quit(1)
            return
    print("DV2-02E FIVE-TIER GROUP BALANCE MATRIX: PASS (PILOT REPORT, NOT FINAL BALANCE)")
    quit(0)
