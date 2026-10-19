extends SceneTree

# MAX LAB is an isolated seeded fixture, not a cheat in any player save.
# Always exercise the full allowed 30 disciples, 40 monsters, realm 30 floor 10,
# five 6-member parties, maximum legal 4 equipped pilot skills per disciple.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("C4 BE01 MAX LAB FAIL: "+why)
        quit(1)
        return ok
    return ok

func _run() -> void:
    var party: Array = []
    var roster := JxPilotSkillsV1.SKILLS.keys()
    roster.sort()
    if not _check(roster.size() == 5,"expected real five pilot source skills"):
        return
    for i in range(MapBattleV2.MAX_DISCIPLES):
        var stats_result: Dictionary = CombatStatsV2.derive(30,10,30,10,100.0)
        if not _check(bool(stats_result.get("ok",false)),
            "max canonical Tu Vi/Body stats invalid"):
            return
        var role: String = str(["frontline","ranged","mage","healer"][i%4])
        var equipped: Array = []
        for k in range(4):
            equipped.append(str(roster[(i+k)%roster.size()]))
        party.append({
            "id":"max_disc_%02d" % i,"party_id":"max_party_%02d" % int(i/6),
            "role":role,
            "position":Vector2(4.0+float(i%6)*0.9,4.0+float(i/6)*1.3),
            "stats":stats_result["stats"],"resistances":stats_result["resistances"],
            "pilot_skill_loadout":equipped,
            "spiritual_root_values":{"metal":100,"wood":100,"water":100,
                "fire":100,"earth":100},
            "move_speed":float(stats_result["stats"]["move_speed"])*2.35,
            "hp":float(stats_result["stats"]["max_hp"])*(
                0.65 if i%7 == 0 else 1.0)
        })
    var monsters: Array = []
    var species: Array = MonsterCatalogueV2.SPECIES.keys()
    species.sort()
    for i in range(MapBattleV2.MAX_MONSTERS):
        var mob: Dictionary = MonsterCatalogueV2.create_actor(
            str(species[i%species.size()]),30,10,"max_mob_%02d" % i)
        if not _check(bool(mob.get("ok",false)),
            "monster at max 30x10 failed"):
            return
        mob["id"] = "max_mob_%02d" % i
        mob["position"] = Vector2(20.0+float(i%8)*1.0,3.0+float(i/8)*2.0)
        monsters.append(mob)
    var battle := MapBattleV2.new(309999)
    var mirror := MapBattleV2.new(309999)
    if not _check(bool(battle.setup("c4_max_30v40",party,monsters).get("ok",false)) and
            bool(mirror.setup("c4_max_30v40",party.duplicate(true),monsters.duplicate(true)).get("ok",false)),
            "cannot initialize full 30v40 realm30 floor10"):
        return
    if not _check(battle.actors.size()==70,"actor cap not 70"):
        return
    for i in range(8):
        battle.step(false)
        mirror.step(true)
    if not _check(battle.events == mirror.events and
            battle.summary() == mirror.summary(),
            "max encounter changed with viewed/offscreen flag"):
        return
    var saved := MapBattleSnapshotV2.save(battle)
    var loaded := MapBattleSnapshotV2.load(saved)
    if not _check(bool(loaded.get("ok",false)),
            "max 70-actor snapshot restore fails"):
        return
    var restored: MapBattleV2 = loaded["battle"]
    if not _check(restored.actors.size()==70 and
            restored.pending_casts == battle.pending_casts and
            restored.events == battle.events,
            "max snapshot lost casts/event/actors"):
        return
    var final_a := battle.run(400,false)
    var final_b := restored.run(400,true)
    if not _check(final_a == final_b,
            "max 30x40 seeded snapshot replay not identical"):
        return
    var aoe_max := 0
    var typed_skills: Dictionary = {}
    for ev in battle.events:
        if str(ev.get("type","")) == "area_release":
            aoe_max = maxi(aoe_max,int(ev.get("target_count",0)))
        if str(ev.get("type","")) == "pilot_cast":
            typed_skills[str(ev.get("pilot_id",""))] = true
    if not _check(aoe_max <= MapBattleV2.MAX_TARGETS_AOE,
            "full-roster AoE exceeded legitimate max-3 cap"):
        return
    if not _check(battle.events.size() <= MapBattleV2.MAX_EVENTS,
            "event journal exceeded cap"):
        return
    print("C4 BE01 MAX LAB PASS 30v40 realm30/floor10 body30/floor10 4 equipped skills/fighter; seen=",typed_skills.keys()," events=",battle.events.size()," outcome=",final_a.get("outcome","unknown"))
    quit(0)
