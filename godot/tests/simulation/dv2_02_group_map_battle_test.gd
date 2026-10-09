extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _party(count: int, with_healer: bool = true, realm: int = 1) -> Array:
    var units: Array = []
    for i in range(count):
        var id := "disciple_%02d" % i
        var stats: Dictionary = CombatStatsV2.derive(realm,1,realm,1,0.0)["stats"]
        var role := "frontline"
        if i % 4 == 1:
            role = "ranged"
        elif i % 4 == 2:
            role = "mage"
        elif i % 4 == 3 and with_healer:
            role = "healer"
        var pos := Vector2(8.0+float(i%3)*0.8,8.0+float(i/3)*0.9)
        var hp := float(stats["max_hp"])
        if i == 0 and with_healer and count >= 4:
            hp *= 0.45
        units.append({"id":id,"party_id":"party_%02d" % int(i/6),"stats":stats,"role":role,"position":pos,"hp":hp})
    return units

func _monsters(ids: Array, realm: int = 1) -> Array:
    var units: Array = []
    for i in range(ids.size()):
        var creature := MonsterCatalogueV2.create_actor(str(ids[i]),realm,1,"mob_%02d" % i)
        creature["id"] = "mob_%02d" % i
        creature["position"] = Vector2(23.0+float(i%3)*0.8,8.0+float(i/3)*0.9)
        units.append(creature)
    return units

func _assert(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        quit(1)
        return false
    return true

func _run() -> void:
    # 4v5: AoE and support are REAL multi-target events on the map.
    var monsters := _monsters(["truc_thu","thanh_lang","hac_lang","truc_thu","thanh_lang"])
    var players := _party(4,true)
    var battle := MapBattleV2.new(14726)
    if not _assert(bool(battle.setup("sect_group_4v5",players,monsters).get("ok",false)),
        "4v5 map group failed to initialize."):
        return
    var result := battle.run(400,false)
    if not _assert(result["outcome"] in ["win","defeat","timeout_retreat"],
        "Group encounter never reached a valid outcome."):
        return
    var have_move := false
    var have_combat := false
    var have_heal := false
    var have_aoe := false
    var units_targeted: Dictionary = {}
    for event in result["events"]:
        var typ := str(event["type"])
        if typ == "move":
            have_move = true
        if typ == "hit":
            have_combat = true
            if str(event.get("kind","")) == "area_burst":
                have_aoe = true
            units_targeted[str(event.get("target",""))] = true
            if str(event.get("attacker","")) == str(event.get("target","")):
                if not _assert(false,"An actor attacked itself."):
                    return
        if typ == "heal":
            have_heal = true
        if typ == "area_release" and int(event.get("target_count",0)) > 3:
            if not _assert(false,"AoE exceeded the 3-target content cap."):
                return
    if not _assert(have_move and have_combat and have_heal and have_aoe,
        "Group map is missing live movement, multi-actor damage, healer support or mage AoE."):
        return
    if not _assert(units_targeted.size() >= 2,
        "Group combat only targeted one opponent as a fake repeated 1v1."):
        return

    # Deterministic outcome independent of order of input and viewed/offscreen state.
    var reordered_party := _party(4,true)
    reordered_party.reverse()
    var reordered_monsters := _monsters(["truc_thu","thanh_lang","hac_lang","truc_thu","thanh_lang"])
    reordered_monsters.reverse()
    var replay := MapBattleV2.new(14726)
    var visible := MapBattleV2.new(14726)
    if not _assert(bool(replay.setup("sect_group_4v5",reordered_party,reordered_monsters).get("ok",false)) and
       bool(visible.setup("sect_group_4v5",_party(4,true),_monsters(["truc_thu","thanh_lang","hac_lang","truc_thu","thanh_lang"])).get("ok",false)),
       "Map replay construction was invalid."):
        return
    var repeat_result := replay.run(400,false)
    var viewed_result := visible.run(400,true)
    if not _assert(result == repeat_result and result == viewed_result,
        "Order or rendered camera/view state changed the actual fight."):
        return

    # Fight a boss plus escorts as ONE encounter (not a 1v1 boss duel).
    var boss_party := _party(6,true)
    var boss_monsters := _monsters(["hac_lang_vuong","thanh_lang","hac_lang","truc_thu","thanh_lang"])
    var boss_battle := MapBattleV2.new(23425)
    if not _assert(bool(boss_battle.setup("boss_party_6v5",boss_party,boss_monsters).get("ok",false)),
       "Party vs boss+escorts setup failed."):
        return
    var boss_result := boss_battle.run(400)
    var have_telegraph := false
    var have_release := false
    for e in boss_result["events"]:
        if str(e["type"]) == "telegraph":
            have_telegraph = true
        if str(e["type"]) == "area_release":
            have_release = true
            if not _assert(int(e["target_count"]) <= 3,
                "Boss AoE exceeded cap."):
                return
    if not _assert(have_telegraph and have_release,
       "Boss fought the group without a warning and delayed AoE release."):
        return

    # Visible outside-region map reads SAME combat actor world positions.
    # Rendering must not consume RNG or advance battle time.
    var map_scene := load("res://scenes/p3/map_battle_world_layer_v2.tscn") as PackedScene
    if not _assert(map_scene != null,"Group map overlay scene is missing."):
        return
    var map_view := map_scene.instantiate() as MapBattleWorldLayerV2
    if not _assert(map_view != null,"Group map overlay script did not load."):
        return
    get_root().add_child(map_view)
    var prior_time := boss_battle.now
    var prior_rng := boss_battle.rng.snapshot_seed_state()
    map_view.attach_session(boss_battle)
    map_view.refresh_from_authority()
    var current: Dictionary = boss_battle.actors["disciple_00"]
    var point := map_view.point_on_map(current["position"])
    if not _assert(map_view.actor_at_map_point(point) == "disciple_00",
        "Map world actor selection missed authoritative disciple location."):
        return
    if not _assert(map_view.logical_from_map(point).distance_to(current["position"]) < 0.001,
        "Node2D visual map transform did not round-trip battle coordinates."):
        return
    if not _assert(_close(prior_time,boss_battle.now) and prior_rng == boss_battle.rng.snapshot_seed_state(),
        "Viewing map moved combat time or consumed battle RNG."):
        return
    map_view.queue_free()

    # Geometric counterplay: a monster's announced center can be avoided
    # by moving away during its cast; a target outside radius gets no damage.
    var dodge_test := MapBattleV2.new(9813)
    if not _assert(bool(dodge_test.setup("aoe_dodge",_party(4,false),
       _monsters(["hac_lang_vuong","truc_thu"])).get("ok",false)), "Dodge setup failed."):
        return
    var demon: Dictionary = dodge_test.actors["mob_00"]
    var focus: Dictionary = dodge_test.actors["disciple_00"]
    dodge_test.now = 3.0
    dodge_test._begin_telegraphed_aoe(demon,focus)
    var before := float(focus["hp"])
    focus["position"] = Vector2(0.0,0.0)
    dodge_test.now = 4.0
    dodge_test._release_casts()
    if not _assert(absf(float(focus["hp"])-before) < 0.00001,
        "Escaping outside boss red-circle area did not prevent damage."):
        return

    # Do not let the common Heal skill resurrect the downed state.
    var down_test := MapBattleV2.new(123)
    if not _assert(bool(down_test.setup("down_test",_party(4,true),
       _monsters(["truc_thu","truc_thu"])).get("ok",false)), "Down test failed."):
        return
    var fallen: Dictionary = down_test.actors["disciple_00"]
    fallen["hp"] = 0.0
    var healer: Dictionary = down_test.actors["disciple_03"]
    healer["next_skill"] = 0.0
    down_test.now = 1.0
    down_test._heal_ally(healer)
    if not _assert(float(fallen["hp"]) == 0.0, "Normal heal revived a downed actor."):
        return

    # 30 disciples can share one hunting encounter, not 30 synthetic duels.
    var cluster := MapBattleV2.new(62)
    var thirty: Array = []
    for i in range(30):
        thirty.append("truc_thu")
    if not _assert(bool(cluster.setup("thirty_disciples",_party(30,true),
       _monsters(thirty)).get("ok",false)), "30-participant cluster gate failed."):
        return
    for i in range(15):
        cluster.step()
    if not _assert(cluster.actors.size()==60,
        "One battle lost group actors rather than tracking all participants."):
        return

    # A 30-member cluster comprises multiple real parties (six each), not
    # one illegal 30-member party. Seven in ONE party must be rejected.
    var illegal_group := _party(7,false)
    for row in illegal_group:
        row["party_id"] = "same_party"
    var invalid_party_battle := MapBattleV2.new(100)
    if not _assert(not bool(invalid_party_battle.setup("party_7_illegal",illegal_group,
       _monsters(["truc_thu"])).get("ok",true)), "Illegal seven-member party was admitted."):
        return

    # Ordinary healer cannot heal a member in another party without an
    # explicitly authored encounter-wide support skill.
    var party_heal_test := MapBattleV2.new(442)
    if not _assert(bool(party_heal_test.setup("party_heal_boundary",_party(12,true),
       _monsters(["truc_thu","truc_thu"])).get("ok",false)), "Party healing test setup failed."):
        return
    var donor: Dictionary = party_heal_test.actors["disciple_03"]
    var other_party: Dictionary = party_heal_test.actors["disciple_06"]
    other_party["position"] = donor["position"]
    other_party["hp"] = 1.0
    for i in range(6):
        if i != 3:
            var same: Dictionary = party_heal_test.actors["disciple_%02d" % i]
            same["hp"] = float(same["max_hp"])
    party_heal_test.now = 1.0
    party_heal_test._heal_ally(donor)
    if not _assert(float(other_party["hp"]) == 1.0,
       "Healer healed another party through an unapproved cross-party rule."):
        return

    # Benchmark several seeded matchups. Report actual outcomes, no fake PASS
    # thresholds until gameplay balancing decisions are reviewed by user.
    var scenarios := {
        "3v3_normal":{"p":3,"m":["truc_thu","thanh_lang","hac_lang"]},
        "4v5_normal":{"p":4,"m":["truc_thu","truc_thu","thanh_lang","hac_lang","thanh_lang"]},
        "6v6_elite":{"p":6,"m":["nham_giap_thu","truc_thu","thanh_lang","hac_lang","truc_thu","thanh_lang"]},
        "6v5_boss":{"p":6,"m":["hac_lang_vuong","truc_thu","thanh_lang","hac_lang","truc_thu"]}
    }
    for label in scenarios.keys():
        var setup_info: Dictionary = scenarios[label]
        var victories := 0
        var total_downed := 0
        var total_time := 0.0
        for seed in range(16):
            var simulation := MapBattleV2.new(10000+seed*11)
            if not _assert(bool(simulation.setup(str(label)+"_"+str(seed),
               _party(int(setup_info["p"]),true),_monsters(setup_info["m"])).get("ok",false)),
               "Benchmark group scenario failed to instantiate."):
                return
            var snapshot := simulation.run(400)
            if str(snapshot["outcome"]) == "win":
                victories += 1
            total_downed += int(snapshot["downed_disciples"])
            total_time += float(snapshot["time"])
        print("DV2 GROUP BALANCE ",label,
              " sample=16 win=",victories,
              " downed_avg=",float(total_downed)/16.0,
              " time_avg=",total_time/16.0)

    # Contrast: understrength and unbalanced parties should NOT receive
    # invisible handicap buffs to force a victory against the boss.
    var weak_victories := 0
    var strong_victories := 0
    var no_healer_victories := 0
    for seed in range(16):
        var weak := MapBattleV2.new(22220+seed*13)
        weak.setup("weak_"+str(seed),_party(3,false),
            _monsters(["hac_lang_vuong","truc_thu","thanh_lang","hac_lang","truc_thu"]))
        if weak.run()["outcome"] == "win":
            weak_victories += 1
        var overleveled := MapBattleV2.new(22220+seed*13)
        overleveled.setup("strong_"+str(seed),_party(6,true,2),
            _monsters(["hac_lang_vuong","truc_thu","thanh_lang","hac_lang","truc_thu"]))
        if overleveled.run()["outcome"] == "win":
            strong_victories += 1
        var without_heal := MapBattleV2.new(22220+seed*13)
        without_heal.setup("no_healer_"+str(seed),_party(6,false),
            _monsters(["hac_lang_vuong","truc_thu","thanh_lang","hac_lang","truc_thu"]))
        if without_heal.run()["outcome"] == "win":
            no_healer_victories += 1
    print("DV2 GROUP DIFFICULTY weak_3v5_boss=",weak_victories,
        "/16 high_realm_6v5_boss=",strong_victories,
        "/16 no_healer_6v5_boss=",no_healer_victories,"/16")
    if not _assert(weak_victories < strong_victories,
        "Monster balancing has hidden player scaling or weak teams outperform stronger groups."):
        return

    print("DV2-02D GROUP MAP COMBAT: MOVEMENT/HEAL/AOE/BOSS/30-ACTOR/REPLAY TEST PASS")
    quit(0)
