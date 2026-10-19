extends SceneTree

# Run using Godot 4.7.2 in isolated TEMP clone, never with a live save.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("C4_JX_PILOT_FAIL: "+reason)
        quit(1)
    return ok

func _stats() -> Dictionary:
    return CombatStatsV2.derive(1,1,1,1,0.0)["stats"]

func _team() -> Array:
    var entries: Array = []
    var configs := [
        ["monk","frontline",["jx_shaolin_15"],0.50],
        ["sword","mage",["jx_wudang_159","jx_wudang_158"],1.00],
        ["poison","mage",["jx_wudu_63"],1.00],
        ["healer","healer",["jx_emei_93"],1.00]
    ]
    for i in range(configs.size()):
        var c: Array = configs[i]
        var row := {"id":c[0],"role":c[1],"party_id":"party_1",
            "stats":_stats().duplicate(true),
            "position":Vector2(8.0,7.0+float(i)*0.5),
            "hp":float(_stats()["max_hp"])*float(c[3]),
            "pilot_skill_loadout":c[2],"spiritual_root_values":{}}
        if i == 2:
            # Force application in a deterministic fixture, not gameplay balance.
            row["stats"]["effect_hit"] = 1.0
        entries.append(row)
    return entries

func _mobs() -> Array:
    var mob := MonsterCatalogueV2.create_actor("truc_thu",1,1,"jx_mob_1")
    mob["id"] = "jx_mob_1"
    mob["position"] = Vector2(11.0,8.0)
    var stats: Dictionary = _stats()
    stats["max_hp"] = 5000.0
    stats["attack"] = 2.0
    mob["stats"] = stats
    mob["hp"] = 5000.0
    mob["primary_element"] = "wood"
    return [mob]

func _start(seed_value: int) -> MapBattleV2:
    var battle := MapBattleV2.new(seed_value)
    var started := battle.setup("jx_pilot_focused",_team(),_mobs())
    if not bool(started.get("ok",false)):
        push_error("C4 pilot setup failed: "+str(started))
        return null
    return battle

func _run() -> void:
    if not _check(JxPilotSkillsV1.valid_loadout(["jx_wudu_63","jx_emei_93"]) and
        not JxPilotSkillsV1.valid_loadout(["jx_wudu_63","jx_wudu_63"]) and
        not JxPilotSkillsV1.valid_loadout(["nonexistent"]) and
        not JxPilotSkillsV1.valid_roots({"metal":0}),"skill or root admission guard"):
        return
    if not _check(is_equal_approx(JxPilotSkillsV1.elemental_matchup("metal","wood"),1.25) and
        is_equal_approx(JxPilotSkillsV1.elemental_matchup("wood","metal"),0.85) and
        is_equal_approx(JxPilotSkillsV1.elemental_matchup("earth","fire"),1.0) and
        is_equal_approx(JxPilotSkillsV1.matching_root_multiplier({"metal":100},"metal"),1.33),
        "five-element counter or perfect-root magnitude"):
        return
    # All five roots, no assumed school-only element and no fake main root.
    var perfect_roots := {"metal":100,"wood":100,"water":100,"fire":100,"earth":100}
    if not _check(is_equal_approx(
        JxPilotSkillsV1.matching_root_multiplier(perfect_roots,"fire"),1.60) and
        is_equal_approx(
        JxPilotSkillsV1.matching_root_multiplier({"metal":80,"wood":45,"water":70,"earth":60},"earth"),1.18),
        "five-root resonance or independent earth root"):
        return
    var counter_edges := {"metal":"wood","wood":"earth","earth":"water",
        "water":"fire","fire":"metal"}
    for key in counter_edges.keys():
        var victim_element := str(counter_edges[key])
        if not _check(is_equal_approx(JxPilotSkillsV1.elemental_matchup(str(key),victim_element),1.25) and
            is_equal_approx(JxPilotSkillsV1.elemental_matchup(victim_element,str(key)),0.85),
            "five-element matchup cycle at "+str(key)):
            return
    var real_monster := MonsterCatalogueV2.create_actor("truc_thu",1,1,"element_source")
    real_monster["id"] = "element_source"
    real_monster["position"] = Vector2(11.0,8.0)
    var source_battle := MapBattleV2.new(909)
    if not _check(bool(source_battle.setup("element_identity",_team(),[real_monster]).get("ok",false)) and
        str(source_battle.actors["element_source"].get("primary_element","")) == "wood",
        "MonsterCatalogue elemental source lost during battle setup"):
        return
    # A pilot kit and a learned P2 damage bar may not grant eight active slots.
    var mixed_team: Array = _team()
    mixed_team[1]["skill_loadout"] = ["ngu_kiem_thuat"]
    var mixed_battle := MapBattleV2.new(932)
    var mixed_result := mixed_battle.setup("mixed_active_bar",mixed_team,_mobs())
    if not _check(not bool(mixed_result.get("ok",false)) and
        str(mixed_result.get("reason","")) == "mixed_pilot_and_learned_active_slots",
        "mixed pilot/learned skill loadout bypasses four-active slot limit"):
        return
    # Projectile cast wind-up is distinct from travel. At t=0.75 the cast
    # has committed, its bolt remains in flight, and caster action is unlocked.
    var ranged_team: Array = [{"id":"ranged_fixture","party_id":"range_party",
        "role":"mage","position":Vector2(5.0,8.0),"stats":_stats(),
        "pilot_skill_loadout":["jx_wudang_158"]}]
    var flight_battle := MapBattleV2.new(19001)
    var ranged_mob: Dictionary = _mobs()[0]
    ranged_mob["position"] = Vector2(11.0,8.0)
    if not _check(bool(flight_battle.setup("flight_focused",ranged_team,[ranged_mob]).get("ok",false)),
        "ranged projectile fixture failed setup"):
        return
    flight_battle.step(false) # starts casting at t=0.25
    if not _check(flight_battle.pending_casts.size() == 1,
        "no queued cast during wind-up"):
        return
    var queued: Dictionary = flight_battle.pending_casts[0]
    var committed_at := float(queued.get("commit_at",-1.0))
    if not _check(is_equal_approx(committed_at,0.75) and
        is_equal_approx(float(queued["ready"]),1.50) and
        is_equal_approx(float(flight_battle.actors["ranged_fixture"]["pilot_ready"]["jx_wudang_158"]),5.75),
        "cast/flight separation or cooldown starting at wrong timestamp"):
        return
    flight_battle.step(false) # t=0.50, actor locked
    if not _check(flight_battle._actor_casting("ranged_fixture"),
        "caster unlocked BEFORE cast completion"):
        return
    flight_battle.step(false) # t=0.75, launched but missile still in flight
    if not _check(flight_battle.pending_casts.size() == 1 and
        not flight_battle._actor_casting("ranged_fixture") and
        bool(flight_battle.pending_casts[0].get("committed",false)),
        "caster still immobilized during launched projectile"):
        return
    var commit_count := 0
    for evt in flight_battle.events:
        if str(evt.get("type","")) == "pilot_commit":
            commit_count += 1
    if not _check(commit_count == 1,"cast committed more than once"):
        return
    var flight_save := MapBattleSnapshotV2.save(flight_battle)
    var flight_loaded := MapBattleSnapshotV2.load(JSON.parse_string(JSON.stringify(flight_save)))
    if not _check(bool(flight_loaded.get("ok",false)),
        "post-commit in-flight snapshot rejected"):
        return
    var restored_flight: MapBattleV2 = flight_loaded["battle"]
    if not _check(restored_flight.pending_casts == flight_battle.pending_casts and
        restored_flight.actors["ranged_fixture"]["pilot_ready"] ==
        flight_battle.actors["ranged_fixture"]["pilot_ready"],
        "in-flight snapshot lost commit state/cooldown"):
        return
    for _flight_step in range(7):
        flight_battle.step(false)
        restored_flight.step(true)
    if not _check(flight_battle.events == restored_flight.events and
        is_equal_approx(float(flight_battle.actors["jx_mob_1"]["hp"]),
            float(restored_flight.actors["jx_mob_1"]["hp"])),
        "post-flight impact mismatch after snapshot replay"):
        return
    var impacts := 0
    var commits := 0
    for evt in flight_battle.events:
        if str(evt.get("type","")) == "pilot_impact":
            impacts += 1
        if str(evt.get("type","")) == "pilot_commit":
            commits += 1
    if not _check(impacts == 1 and commits == 1,
        "duplicate projectile impact/commit packet"):
        return
    var initial := _start(4444)
    if not _check(initial != null,"fixture"):
        return
    for i in range(28):
        initial.step(false)
    var observed: Dictionary = {}
    var poison_hits := 0
    var heal_hits := 0
    for e in initial.events:
        if not _check(not (str(e.get("type","")) == "cast" and str(e.get("skill","")) == "area_burst"),
            "opt-in JX mage received an unlearned legacy role AoE"):
            return
        observed[str(e["type"])] = true
        if str(e["type"]) == "pilot_poison_tick":
            poison_hits += 1
        if str(e["type"]) == "pilot_hot_tick":
            heal_hits += 1
            if not _check(float(e.get("amount",-1.0)) >= 0.0,
                "negative or forged HoT amount"):
                return
    for name in ["pilot_cast","pilot_guard","pilot_party_defense","pilot_impact",
                 "pilot_hot_applied","pilot_hot_tick","pilot_poison_applied","pilot_poison_tick"]:
        if not _check(observed.has(name),"pilot event missing: "+name):
            return
    if not _check(poison_hits >= 1 and heal_hits >= 1,"no real status ticks"):
        return
    if not _check(float(initial.actors["monk"]["pilot_guard_until"]) > 0.0 and
        float(initial.actors["sword"]["pilot_def_until"]) > 0.0,
        "guard or party defense never committed"):
        return
    var a := _start(4444)
    var b := _start(4444)
    if not _check(a != null and b != null,"replay fixtures"):
        return
    for _i in range(9):
        a.step(false)
        b.step(true)
    if not _check(a.events == b.events,"viewed flag altered pilot combat"):
        return
    var save := MapBattleSnapshotV2.save(a)
    var loaded := MapBattleSnapshotV2.load(JSON.parse_string(JSON.stringify(save)))
    if not _check(bool(loaded.get("ok",false)),
        "mid-DoT/HoT/projectile snapshot invalid: "+str(loaded.get("reason",""))):
        return
    var resumed: MapBattleV2 = loaded["battle"]
    if not _check(a.pending_casts == resumed.pending_casts and
        a.actors["healer"]["pilot_ready"] == resumed.actors["healer"]["pilot_ready"],
        "snapshot lost pilot cooldown/casts"):
        return
    var end_a := a.run(400,false)
    var end_b := resumed.run(400,true)
    if not _check(end_a == end_b,
        "snapshot RNG/DoT/HoT/guard/proc/reward journal divergence"):
        return
    # Four independent poison casters must share ONE global target cap of three.
    var poison_team: Array = []
    for caster_index in range(4):
        var poison_stats: Dictionary = _stats()
        poison_stats["effect_hit"] = 1.0
        poison_team.append({"id":"p%d" % caster_index,"party_id":"poison_party",
            "role":"mage","stats":poison_stats,
            "position":Vector2(8.0,7.0+0.4*float(caster_index)),
            "pilot_skill_loadout":["jx_wudu_63"]})
    var cap_battle := MapBattleV2.new(5817)
    if not _check(bool(cap_battle.setup("poison_cap_probe",poison_team,_mobs()).get("ok",false)),
        "four-caster status setup"):
        return
    for caster_index in range(4):
        JxPilotRuntimeV1.release(cap_battle,cap_battle.actors["p%d" % caster_index],
            {"pilot_id":"jx_wudu_63","target_id":"jx_mob_1"},MapBattleV2.STEP_SECONDS)
    var poison_stacks := 0
    for fx in cap_battle.actors["jx_mob_1"]["pilot_effects"]:
        if str(fx.get("kind","")) == "poison":
            poison_stacks += 1
    if not _check(poison_stacks == 3,
        "four casters bypassed poison cap=3 across one target"):
        return
    # Fatal stacked Poison ticks must settle one and only one downed receipt.
    cap_battle.actors["jx_mob_1"]["hp"] = 1.0
    cap_battle.now = 1.0
    JxPilotRuntimeV1.tick(cap_battle)
    var lethal_receipts := 0
    for e in cap_battle.events:
        if str(e.get("type","")) == "downed" and str(e.get("actor_id","")) == "jx_mob_1":
            lethal_receipts += 1
    if not _check(lethal_receipts == 1,"stacked poison caused duplicate downed receipts"):
        return
    # A party aura may never leak into a second party even at the same position.
    var teams := _team()
    teams.append({"id":"guest","party_id":"party_2","role":"ranged",
        "position":Vector2(8.0,8.0),"stats":_stats()})
    var isolation := MapBattleV2.new(567)
    if not _check(bool(isolation.setup("party_isolation",teams,_mobs()).get("ok",false)),
        "party-isolation setup"):
        return
    for _t in range(4):
        isolation.step()
    if not _check(float(isolation.actors["guest"]["pilot_def_until"]) < 0.0 and
        float(isolation.actors["sword"]["pilot_def_until"]) > 0.0,
        "party defense buff leaked or failed to activate"):
        return
    # A second healer's HoT may not stack for free on the same target.
    var lifeline: Dictionary = resumed.actors["monk"]
    var effects: Array = lifeline.get("pilot_effects",[])
    var hot_count := 0
    for fx in effects:
        if str(fx.get("kind","")) == "hot":
            hot_count += 1
    if not _check(hot_count <= 1,"multiple same-family HoT stacks"):
        return
    # Focused six-person benchmark: observe, do not approve combat balance from 8 seeds.
    var wins := 0
    var total_time := 0.0
    var total_downed := 0
    for seed_index in range(8):
        var team := _team()
        for flex_index in range(2):
            team.append({"id":"flex_%d" % flex_index,"role":"ranged",
                "party_id":"party_1","stats":_stats(),
                "position":Vector2(7.0,8.0+float(flex_index)),
                "hp":float(_stats()["max_hp"])})
        var group: Array = []
        var regular := MonsterCatalogueV2.create_actor("truc_thu",1,1,"jx_bench_normal")
        regular["id"] = "jx_bench_normal"
        regular["position"] = Vector2(11.0,8.0)
        group.append(regular)
        for j in range(3):
            var species := "hac_lang_vuong" if j == 0 else "thanh_lang"
            var mob := MonsterCatalogueV2.create_actor(species,1,1,"benchmark_%d" % j)
            mob["id"] = "benchmark_%d" % j
            mob["position"] = Vector2(13.0+float(j),7.5)
            group.append(mob)
        var bench := MapBattleV2.new(70000+seed_index)
        if not _check(bool(bench.setup("jx_bench_%d" % seed_index,team,group).get("ok",false)),
            "six-person benchmark could not initialize"):
            return
        var result := bench.run(400,false)
        if not _check(str(result["outcome"]) in ["win","defeat","timeout_retreat"],
            "six-person benchmark had no terminal state"):
            return
        if str(result["outcome"]) == "win":
            wins += 1
        total_time += float(result["time"])
        total_downed += int(result["downed_disciples"])
    print("C4-JX-PILOT BENCHMARK (not balanced/approved): 6v4, 8 seeds; wins=",
        wins,"/8, mean_time=",total_time/8.0,"s, total_downed=",total_downed)
    print("C4-JX-PILOT focused status, source, skill, 5-elements, snapshot, replay: PASS")
    quit(0)
