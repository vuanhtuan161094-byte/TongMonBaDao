extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _assert(ok: bool, msg: String) -> bool:
    if not ok:
        push_error(msg)
        quit(1)
        return false
    return true

func _near(a: float,b: float) -> bool:
    return absf(a-b) <= 0.0001

func _run() -> void:
    var registry := ResourceRegistry.new()
    for region in HuntingMapV2.REGION_CONTENT.keys():
        var menu := HuntingMapV2.overview(str(region))
        if not _assert(bool(menu.get("ok",false)) and menu["levels"].size() == 5,
            "Every map must have exactly five distinct difficulty choices."):
            return
        var last_hp_factor := -1.0
        var last_attack_factor := -1.0
        var last_expected_reward := -1
        for level in range(1,6):
            var spawned := HuntingMapV2.spawn(str(region),level,
                "%s-%d" % [str(region),level],991)
            if not _assert(bool(spawned.get("ok",false)),
                "A valid map difficulty failed to spawn."):
                return
            var monsters: Array = spawned["monsters"]
            if not _assert(monsters.size()==int(HuntingMapV2.LEVELS[level]["count"]),
                "Five-level map monster group has incorrect count."):
                return
            var first: Dictionary = monsters[0]
            # The randomly chosen first monster may be a RARE boss even on
            # Ngoại Vi, so compare *same-species* scaling, not slot-zero HP.
            var baseline: Dictionary = MonsterCatalogueV2.create_actor(
                str(first["species_id"]),
                int(HuntingMapV2.REGION_CONTENT[region]["realm"]),
                int(HuntingMapV2.REGION_CONTENT[region]["floor"]),"check_baseline"
            )
            var hp_factor := float(first["stats"]["max_hp"])/float(baseline["stats"]["max_hp"])
            var attack_factor := float(first["stats"]["attack"])/float(baseline["stats"]["attack"])
            if not _assert(_near(hp_factor,float(HuntingMapV2.LEVELS[level]["hp"])) and
                _near(attack_factor,float(HuntingMapV2.LEVELS[level]["attack"])),
                "Monster HP/Attack must use per-map tier scaling even for an outer-map boss."):
                return
            if not _assert(hp_factor > last_hp_factor and attack_factor > last_attack_factor,
                "Increasing difficulty must grow HP and Attack for the SAME species."):
                return
            last_hp_factor = hp_factor
            last_attack_factor = attack_factor
            var loot: Dictionary = HuntingMapV2.preview_reward(spawned)
            var regular_sum := 0
            for id in loot.keys():
                if not _assert(registry.has(StringName(id)),
                    "Map rewards included a fictitious resource ID."):
                    return
                if str(id) != str(HuntingMapV2.REGION_CONTENT[region]["rare"]):
                    regular_sum += int(loot[id])
            if not _assert(regular_sum > last_expected_reward,
                "Higher map difficulty did not produce more standard resource yield."):
                return
            last_expected_reward = regular_sum
            var elites := 0
            var bosses := 0
            for monster in monsters:
                if str(monster["tier"]) == "elite":
                    elites += 1
                elif str(monster["tier"]) == "boss":
                    bosses += 1
            var required_elites := int(HuntingMapV2.LEVELS[level]["min_elites"])
            # Boss takes the special tier slot on easy levels; it is an
            # optional *rare encounter*, not forbidden on levels 1–4.
            if not _assert(elites >= required_elites and
                elites <= required_elites+1 and bosses <= 1 and
                (bosses == 1 if level == 5 else true),
                "Monster Elite/Boss composition is inconsistent with this map level."):
                return
            if level <= 2 and bosses == 1 and not _assert(elites == 0,
                "A rare low-level Boss must replace the optional Elite to avoid a double spike."):
                return
    # Regression: EVERY map level may offer both Elite and Boss. Neither
    # rarity nor the normal-majority criterion is replaced with a guarantee
    # on Ngoại Vi. 1,300 deterministic seeds sample the real generator.
    for tier in range(1,5):
        var seen_elite := 0
        var seen_boss := 0
        var seen_normal_only := 0
        for index in range(1300):
            var spawn_case := HuntingMapV2.spawn(
                "thanh_truc_lam",tier,
                "tier_%d_seed_%d" % [tier,index],120001+index*37
            )
            if not _assert(bool(spawn_case.get("ok",false)),
                "A valid tier's rarity sample could not generate a group."):
                return
            var has_elite := false
            var has_boss := false
            for creature in spawn_case["monsters"]:
                if str(creature["tier"]) == "elite":
                    has_elite = true
                elif str(creature["tier"]) == "boss":
                    has_boss = true
            if has_elite:
                seen_elite += 1
            if has_boss:
                seen_boss += 1
            if not has_elite and not has_boss:
                seen_normal_only += 1
        if not _assert(seen_elite > 0 and seen_boss > 0 and seen_boss < 1300,
            "Every tier 1–4 must have a possible but non-guaranteed Boss and Elite."):
            return
        if tier <= 2 and not _assert(seen_normal_only > 900 and seen_elite < 400 and seen_boss < 150,
            "Outer zones should remain mostly safe, not always spawn boss/elite."):
            return
        print("DV2 ZONE RARITY level=",tier," encounters=1300 elite=",seen_elite,
            " boss=",seen_boss," no_special=",seen_normal_only)

    if not _assert(not bool(HuntingMapV2.spawn("thanh_truc_lam",6,"bad",1).get("ok",true)) and
        not bool(HuntingMapV2.spawn("thanh_truc_lam",0,"bad",1).get("ok",true)),
        "Invalid map difficulty accepted."):
        return
    var x := HuntingMapV2.spawn("thanh_truc_lam",3,"repeatable",666)
    var y := HuntingMapV2.spawn("thanh_truc_lam",3,"repeatable",666)
    if not _assert(x == y and HuntingMapV2.preview_reward(x)==HuntingMapV2.preview_reward(y),
        "Five-level spawn/reward is not deterministic for same seed."):
        return

    # P3.7 real baseline state, genuine P2 equipment and learned P2 skill.
    var state := P37Factory.create_state(12311)
    var ids: Array = state.disciples.keys()
    ids.sort()
    var disciple: DiscipleState = state.disciples[ids[0]]
    var plain := DiscipleCombatLoadoutV2.build(
        state,disciple,1,1,1,1,"frontline",Vector2(8.0,9.0),"squad_1"
    )
    if not _assert(bool(plain.get("ok",false)),"Plain disciple V2 build failed."):
        return
    state.sect.equipment_enabled = true
    state.sect.combat_skills_enabled = true
    disciple.learned_combat_skills["thanh_phong_tram"] = true
    var forged: Dictionary = {
        "id":"test_sword_01","recipe_id":"thanh_thiet_kiem",
        "slot":"weapon","location":"equipped","owner_id":str(disciple.id),
        "path":"sword","element":"metal",
        "stats":{"combat_power":999999.0,"basic_speed":0.18,
            "basic_ratio":0.20,"basic_range":0.10,"skill_effect":0.12}
    }
    disciple.equipped_items["weapon"] = "test_sword_01"
    state.sect.equipment_items["test_sword_01"] = forged
    var armor: Dictionary = {
        "id":"test_armor_01","recipe_id":"tinh_lang_giap",
        "slot":"armor","location":"equipped","owner_id":str(disciple.id),
        "path":"body","element":"earth",
        "stats":{"combat_power":999999.0,"defense_reduction":0.15}
    }
    disciple.equipped_items["armor"] = "test_armor_01"
    state.sect.equipment_items["test_armor_01"] = armor
    var equipped := DiscipleCombatLoadoutV2.build(
        state,disciple,1,1,1,1,"frontline",Vector2(8.0,9.0),"squad_1"
    )
    if not _assert(bool(equipped.get("ok",false)) and
        _near(float(equipped["stats"]["attack"]),float(plain["stats"]["attack"])),
        "Legacy item combat_power was incorrectly converted to V2 Attack."):
        return
    if not _assert(_near(float(equipped["stats"]["damage_reduction"]),0.15) and
        _near(float(equipped["stats"]["attack_speed"]),0.18) and
        float(equipped["basic_ratio"])>float(plain["basic_ratio"]) and
        float(equipped["basic_range"])>float(plain["basic_range"]),
        "Real equipped-item effects did not reach the correct V2 stat/action channels."):
        return
    if not _assert(equipped["skill_loadout"].has("thanh_phong_tram") and
        float(equipped["skill_factors"]["thanh_phong_tram"])>1.0,
        "Actually learned damage skill was not enabled with matching weapon effect."):
        return
    if not _assert(equipped["disciple"] == null,
        "Pilot V2 HP would corrupt persistent legacy Max HP if silently linked."):
        return

    # Skill MUST be an actual action with cast+cooldown, not a +Damage label.
    var teammate := DiscipleCombatLoadoutV2.build(
        state,disciple,1,1,1,1,"frontline",Vector2(8.6,9.1),"squad_1"
    )
    teammate["id"] = "teammate_02"
    teammate["skill_loadout"] = []
    var mobs: Array = HuntingMapV2.spawn("thanh_truc_lam",1,"pve_skill_action",441)["monsters"]
    var session := MapBattleV2.new(441)
    if not _assert(bool(session.setup("pve_skill_action",[equipped,teammate],mobs).get("ok",false)),
        "Loadout-injected real group PvE setup failed."):
        return
    session.run(400)
    var saw_cast := false
    var saw_hit := false
    var skill_cooldown_respected := true
    var last_cast := -100.0
    for e in session.events:
        if str(e["type"]) == "skill_cast" and str(e.get("skill_id","")) == "thanh_phong_tram":
            if float(e["time"])-last_cast < 2.79:
                skill_cooldown_respected = false
            last_cast = float(e["time"])
            saw_cast = true
        if str(e["type"]) == "skill_hit" and str(e.get("skill_id","")) == "thanh_phong_tram":
            saw_hit = true
    if not _assert(saw_cast and saw_hit and skill_cooldown_respected,
        "Learned V2 skill did not cast, hit and observe its authored cooldown."):
        return
    # Remove the equipped objects; existing item and skill identity must vanish.
    disciple.equipped_items.clear()
    disciple.learned_combat_skills.clear()
    var unequipped := DiscipleCombatLoadoutV2.build(
        state,disciple,1,1,1,1,"frontline",Vector2(8.0,9.0),"squad_1"
    )
    if not _assert(_near(float(unequipped["stats"]["damage_reduction"]),0.0) and
        _near(float(unequipped["stats"]["attack_speed"]),0.0) and
        unequipped["skill_loadout"].is_empty(),
        "Removing equipment/learned skills did not remove gameplay buffs."):
        return

    # Chosen region+level survives actual SectState save/load; rewards are
    # final only on win and cannot be claimed twice, even after JSON reload.
    if not _assert(bool(HuntingMapV2.choose_level(state,"thanh_truc_lam",2).get("ok",false)),
        "Region-specific difficulty selection failed."):
        return
    if not _assert(HuntingMapV2.selected_level(state,"thanh_truc_lam")==2 and
        HuntingMapV2.selected_level(state,"hac_phong_coc")==1,
        "Selecting one map difficulty incorrectly modified another map."):
        return
    # The actual reusable Node Control has five clickable levels; clicking
    # updates per-map persisted state, not a decorative screenshot.
    var scene := load("res://scenes/p3/hunting_level_selector_v2.tscn") as PackedScene
    if not _assert(scene != null,"Difficulty-selector scene is missing."):
        return
    var choice := scene.instantiate() as HuntingLevelSelectorV2
    get_root().add_child(choice)
    if not _assert(bool(choice.show_region(state,"thanh_truc_lam").get("ok",false)) and
        choice.buttons.size() == 5,"Map did not display five selectable levels."):
        return
    choice.buttons[4].pressed.emit()
    if not _assert(HuntingMapV2.selected_level(state,"thanh_truc_lam")==4 and
        HuntingMapV2.selected_level(state,"hac_phong_coc")==1,
        "Clicking fourth map-level button failed or overwrote other map."):
        return
    choice.queue_free()
    var saved := SectState.from_dict(JSON.parse_string(JSON.stringify(state.sect.to_dict())))
    if not _assert(saved.v2_pve_enabled and
        int(saved.v2_pve_selected_levels["thanh_truc_lam"]) == 4,
        "Chosen five-level region difficulty did not survive JSON save/load."):
        return
    var victory_spawn := HuntingMapV2.spawn("thanh_truc_lam",1,"real_reward_01",901)
    var finished := MapBattleV2.new(901)
    var fighters: Array = []
    for i in range(6):
        var actor := plain.duplicate(true)
        actor["id"] = "hunter_%d" % i
        actor["position"] = Vector2(8.0+float(i)*0.3,9.0)
        actor["party_id"] = "p1"
        fighters.append(actor)
    if not _assert(bool(finished.setup("real_reward_01",fighters,victory_spawn["monsters"]).get("ok",false)),
        "Reward encounter setup failed."):
        return
    finished.run(400)
    if not _assert(finished.outcome == "win",
        "A fair level-one six-hunter party did not finish victory in reward regression."):
        return
    var warehouse := WarehouseSystem.new()
    var claim := HuntingMapV2.claim_reward(state,victory_spawn,finished)
    if not _assert(bool(claim.get("ok",false)) and not claim["items"].is_empty(),
        "Legitimate cleared map did not deposit registered materials to warehouse."):
        return
    for item_id in claim["items"].keys():
        if not _assert(warehouse.quantity(state,StringName(item_id))>=int(claim["items"][item_id]),
            "Claimed resource failed to reach canonical P3.7 warehouse."):
            return
    var dupe := HuntingMapV2.claim_reward(state,victory_spawn,finished)
    if not _assert(not bool(dupe.get("ok",true)) and
        state.sect.v2_pve_reward_claims.has("real_reward_01"),
        "Repeat completion paid out twice."):
        return
    saved = SectState.from_dict(JSON.parse_string(JSON.stringify(state.sect.to_dict())))
    if not _assert(saved.v2_pve_reward_claims.has("real_reward_01"),
        "Exactly-once reward claim did not survive save/load."):
        return
    var lost := MapBattleV2.new(57)
    lost.setup("lost_encounter",fighters,victory_spawn["monsters"])
    lost.outcome = "defeat"
    lost.active = false
    if not _assert(not bool(HuntingMapV2.claim_reward(state,
        HuntingMapV2.spawn("thanh_truc_lam",1,"lost_encounter",902),lost).get("ok",true)),
        "Defeated party received map loot."):
        return
    # End-to-end V2 lifecycle: stored map selection -> actual owned disciples
    # with explicit V2 dual progress -> many-vs-many map battle -> warehouse.
    HuntingMapV2.choose_level(state,"bach_thach_khe",1)
    var participant_ids: Array = state.disciples.keys()
    participant_ids.sort()
    var team: Array = []
    for i in range(mini(6,participant_ids.size())):
        team.append({
            "disciple_id":str(participant_ids[i]),
            "party_id":"hunting_party_0",
            "role":"healer" if i == 3 else ("mage" if i == 2 else "frontline"),
            "position":Vector2(8.0+float(i)*0.3,8.0+float(i%2)*0.45),
            "realm":2,"floor":1,"body_realm":2,"body_floor":1
        })
    if not _assert(team.size() >= 3,"Not enough real P3.7 disciples to form group PvE test."):
        return
    var orchestrator := HuntingPveRunV2.new()
    var launch := orchestrator.begin(state,"bach_thach_khe","guided_group_hunt_01",12771,team)
    if not _assert(bool(launch.get("ok",false)) and
        int(launch["party_size"]) == team.size() and
        int(launch["level"]) == 1,
        "Selected map did not start a real group hunt with actual disciples."):
        return
    var spectator := orchestrator.snapshot()
    if not _assert(bool(spectator.get("ok",false)) and
        spectator["possible_rewards"] is Dictionary and
        int(spectator["summary"]["alive_monsters"]) >= 3,
        "Group PvE session failed to expose map state/reward preview."):
        return
    if not _assert(not bool(orchestrator.claim().get("ok",true)),
        "Session awarded actual warehouse resources before battle completion."):
        return
    var resolved := orchestrator.finish()
    if not _assert(bool(resolved.get("ok",false)) and
        str(resolved["summary"]["outcome"]) == "win",
        "Authentic V2 disciples could not finish chosen map hunt."):
        return
    var actual_claim := orchestrator.claim()
    if not _assert(bool(actual_claim.get("ok",false)) and
        state.sect.v2_pve_reward_claims.has("guided_group_hunt_01") and
        not bool(orchestrator.claim().get("ok",true)),
        "Full group hunting lifecycle failed to commit exactly one warehouse reward."):
        return
    var broken := HuntingPveRunV2.new()
    var no_progress: Array = team.duplicate(true)
    no_progress[0].erase("body_realm")
    if not _assert(not bool(broken.begin(state,"bach_thach_khe","invalid_track",123,no_progress).get("ok",true)),
        "Missing Luyện Thể progression was silently invented from legacy power."):
        return

    print("DV2-02E FIVE DIFFICULTIES + REAL GEAR/SKILLS + PERSISTENT REGISTERED REWARDS: PASS")
    quit(0)
