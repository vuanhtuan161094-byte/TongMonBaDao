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
    var initial := _start(4444)
    if not _check(initial != null,"fixture"):
        return
    for i in range(28):
        initial.step(false)
    var observed: Dictionary = {}
    var poison_hits := 0
    var heal_hits := 0
    for e in initial.events:
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
