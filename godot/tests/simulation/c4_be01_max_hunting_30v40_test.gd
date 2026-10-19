extends SceneTree

# MAX AUTHORIZED TEST PROFILE, NEVER A PLAYER SAVE OR AN ACTUAL SPAWN RATE.
# Godot 4.7.2 official required for execution. All mutations below belong
# exclusively to temporary fixture objects created inside this test.
const BOSS_SEED := 881931
const MAX_PARTY := 30
const MAX_MOBS := 40
const MAX_REALM := 30
const MAX_FLOOR := 10
const MAX_SKILLS := 4

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("C4_BE01_MAX_FAIL: "+why)
        quit(1)
    return ok

func _four_skills(index: int) -> Array:
    var keys := ["jx_shaolin_15","jx_wudang_158","jx_wudang_159",
        "jx_wudu_63","jx_emei_93"]
    var chosen: Array = []
    for j in range(MAX_SKILLS):
        chosen.append(keys[(index+j)%keys.size()])
    return chosen

func _maximum_team() -> Array:
    var team: Array = []
    var stats_result := CombatStatsV2.derive(MAX_REALM,MAX_FLOOR,
        MAX_REALM,MAX_FLOOR,100.0)
    var statistics: Dictionary = stats_result["stats"]
    for i in range(MAX_PARTY):
        var skills := _four_skills(i)
        team.append({
            "id":"c4_max_disciple_%02d" % i,
            "party_id":"team_%d" % int(i/6),
            "role":["frontline","ranged","mage","healer","frontline","mage"][i%6],
            "position":Vector2(5.8+float(i%6)*0.65,4.3+float(int(i/6))*2.55),
            "stats":statistics.duplicate(true),
            "hp":float(statistics["max_hp"]),
            "pilot_skill_loadout":skills,
            "spiritual_root_values":{"metal":100,"wood":100,"earth":100,
                "water":100,"fire":100},
            "move_speed":3.0
        })
    return team

func _maximum_monsters() -> Array:
    var units: Array = []
    for i in range(MAX_MOBS):
        var species := "hac_lang_vuong" if i%10 == 0 else (
            "nham_giap_thu" if i%5 == 0 else "thanh_lang")
        var row := MonsterCatalogueV2.create_actor(
            species,MAX_REALM,MAX_FLOOR,"max_mob_%02d" % i)
        if not bool(row.get("ok",false)):
            return []
        row["id"] = "max_mob_%02d" % i
        row["position"] = Vector2(20.0+float(i%8)*0.72,
            4.2+float(int(i/8))*2.40)
        units.append(row)
    return units

func _max_battle(seed: int) -> MapBattleV2:
    var battle := MapBattleV2.new(seed)
    if not bool(battle.setup("max_30v40",_maximum_team(),
            _maximum_monsters()).get("ok",false)):
        return null
    return battle

func _run() -> void:
    var started_at := Time.get_ticks_usec()
    var troops := _maximum_team()
    var enemies := _maximum_monsters()
    if not _check(troops.size()==MAX_PARTY and enemies.size()==MAX_MOBS,
            "fixture not populated 30v40"):
        return
    var teams: Dictionary = {}
    var all_skills: Dictionary = {}
    for unit in troops:
        var group := str(unit["party_id"])
        teams[group] = int(teams.get(group,0))+1
        if not _check((unit["pilot_skill_loadout"] as Array).size()==MAX_SKILLS and
                JxPilotSkillsV1.valid_loadout(unit["pilot_skill_loadout"]) and
                JxPilotSkillsV1.valid_roots(unit["spiritual_root_values"]),
                "full four-skill loadout or max root purity invalid"):
            return
        for skill in unit["pilot_skill_loadout"]:
            all_skills[str(skill)] = true
    if not _check(teams.size() == 5 and all_skills.size() == 5,
            "five real parties and all five authorized pilot skills missing"):
        return
    for group in teams:
        if not _check(int(teams[group])==6,"illegal party >6"): return
    for enemy in enemies:
        if not _check(int(enemy["realm_index"])==MAX_REALM and
                int(enemy["floor_index"])==MAX_FLOOR,
                "monster not max realm/floor"):
            return
    # Boundary rejects must exercise COUNT caps, not merely duplicate IDs.
    var thirty_one: Dictionary = troops[0].duplicate(true)
    thirty_one["id"] = "overflow_member_31"
    thirty_one["party_id"] = "sixth_team"
    var forty_one: Dictionary = enemies[0].duplicate(true)
    forty_one["id"] = "overflow_monster_41"
    if not _check(not bool(MapBattleV2.new(3).setup("illegal_31",
            troops+[thirty_one],enemies).get("ok",true)),
            "31 unique disciples illegally admitted"):
        return
    if not _check(not bool(MapBattleV2.new(3).setup("illegal_41",
            troops,enemies+[forty_one]).get("ok",true)),
            "41 unique monsters illegally admitted"):
        return
    var main := _max_battle(BOSS_SEED)
    if not _check(main != null and main.actors.size()==70,
            "maximum live V2 arena failed to admit 70 entities"):
        return
    for _i in range(4):
        if main.active:
            main.step(false)
    var checkpoint := MapBattleSnapshotV2.save(main)
    var restored := MapBattleSnapshotV2.load(checkpoint)
    if not _check(bool(checkpoint.get("ok",false)) and
            bool(restored.get("ok",false)),
            "70-unit snapshot failed"):
        return
    var other: MapBattleV2 = restored["battle"]
    if not _check(other.actors.size()==70 and other.events==main.events and
            other.rng.snapshot_seed_state()==main.rng.snapshot_seed_state(),
            "70-unit checkpoint corrupted actors/events/seed"):
        return
    var out_a := main.run(400,false)
    var out_b := other.run(400,true)
    if not _check(out_a == out_b and
            out_a["outcome"] in ["win","defeat","timeout_retreat"],
            "30v40 MAX 30/10 four-skill replay diverged offscreen/viewed"):
        return
    if not _check(main.events.size()<=MapBattleV2.MAX_EVENTS and
            main.now <= MapBattleV2.MAX_SECONDS+0.00001,
            "event or tick budget exceeded"):
        return
    for event in main.events:
        if str(event["type"]) == "area_release" and
                not _check(int(event.get("target_count",0)) <= 3,
                    "MAX boss AoE exceeded 3-target cap"):
            return
    print("C4_BE01_MAX_30V40: result=",str(out_a["outcome"]),
        " steps=",int(main.now/MapBattleV2.STEP_SECONDS),
        " events=",main.events.size(),
        " setup_run_ms=",float(Time.get_ticks_usec()-started_at)/1000.0)

    # Production authority E2E on a genuine generated V2 recruit, not a
    # fabricated 30/10 realm on an old founder. Advancement to the ceiling
    # below is isolated test preparation; no player progresses instantly.
    var state := P37Factory.create_state(1913)
    state.sect.disciple_v2_birth_enabled = true
    var generated := DiscipleGeneratorOpenPoints.new().generate_candidate(
        state,DiscipleGeneratorV2.SOURCE_ORDINARY,191305)
    if not _check(generated != null and
            DiscipleBirthProfileV2.valid_complete_birth(generated.v2_birth_profile),
            "genuine V2 generated recruit unavailable"):
        return
    state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
    state.recruitment_candidates[generated.id] = generated
    if not _check(bool(RecruitmentSystem.new().accept_candidate(
            state,generated.id).get("ok",false)),
            "genuine V2 recruitment failed"):
        return
    var recruit: DiscipleState = state.disciples[generated.id]
    for track in ["cultivation","body"]:
        recruit.v2_realm_progress[track]["realm"] = MAX_REALM
        recruit.v2_realm_progress[track]["floor"] = MAX_FLOOR
        recruit.v2_realm_progress[track]["xp"] = 0.0
    if not _check(bool(DiscipleRealmProgressV2.sync_live_hp(recruit).get("ok",false)),
            "MAX V2 recruit HP sync failed"):
        return
    recruit.hp = recruit.max_hp
    recruit.region_id = &"sect"
    recruit.current_action = &"IDLE"
    # Actual three canonical P2 equipment slots, all nine learned P2 skill
    # definitions in a test-only maximal inventory. Runtime only equips
    # damage consumers, not deferred dash/DoT/guard mechanics.
    state.sect.equipment_enabled = true
    state.sect.combat_skills_enabled = true
    recruit.cultivation_stage_index = 9
    for skill in CombatSkillSystem.SKILLS.keys():
        recruit.learned_combat_skills[str(skill)] = true
    var slots := [
        {"slot":"weapon","recipe_id":"thanh_thiet_kiem",
            "stats":{"combat_power":6.0,"basic_speed":0.12,"move_speed":0.08,
                "basic_ratio":0.10,"skill_effect":0.16}},
        {"slot":"armor","recipe_id":"tinh_lang_giap",
            "stats":{"combat_power":2.0,"defense_reduction":0.16}},
        {"slot":"talisman","recipe_id":"hoa_van_ngoc",
            "stats":{"combat_power":3.0,"skill_effect":0.20}}
    ]
    for gear in slots:
        var item_id := "qa_max_"+str(gear["slot"])
        state.sect.equipment_items[item_id] = {
            "id":item_id,"recipe_id":gear["recipe_id"],"slot":gear["slot"],
            "location":"equipped","owner_id":str(recruit.id),
            "path":"sword","element":"metal","quality_id":"thuong",
            "stats":gear["stats"]
        }
        recruit.equipped_items[str(gear["slot"])] = item_id
    var outfit := DiscipleCombatLoadoutV2.build(
        state,recruit,30,10,30,10,"frontline",Vector2(7.0,8.0),"owned_party"
    )
    if not _check(bool(outfit.get("ok",false)) and
            (outfit["equipped_item_ids"] as Array).size()==EquipmentSystem.VALID_SLOTS.size() and
            (outfit["skill_loadout"] as Array).has("thanh_phong_tram") and
            (outfit["deferred_skill_ids"] as Array).has("truy_phong_bo") and
            float(outfit["move_speed"]) > 2.7,
            "owned three-slot gear or nine learned skills not routed correctly"):
        return
    var zone := HuntingMapV2.choose_level(state,"thanh_truc_lam",5)
    if not _check(bool(zone.get("ok",false)) and
            HuntingMapV2.selected_level(state,"thanh_truc_lam")==5,
            "difficulty 5 not persisted for real hunting"):
        return
    var command := {"disciple_id":str(recruit.id),"role":"frontline",
        "party_id":"owned_party","position":Vector2(7.0,8.0)}
    var hunt := HuntingPveRunV2.new()
    var launch := hunt.begin(state,"thanh_truc_lam","max_real_hunt_01",
        2019,[command])
    if not _check(bool(launch.get("ok",false)) and
            state.sect.v2_pve_active_runs.has("max_real_hunt_01") and
            recruit.active_pve_encounter_id=="max_real_hunt_01",
            "authentic 30/10 V2 recruit could not begin reserved hunt"):
        return
    if not _check(not bool(hunt.claim().get("ok",true)),
            "reward paid before combat ended"):
        return
    for _i in range(4):
        if hunt.battle.active:
            var step_result := hunt.advance(false)
            if not _check(bool(step_result.get("ok",false)),"running hunt tick failed"):
                return
    var mid := HuntingPveRunV2.resume_active(state,"max_real_hunt_01")
    if not _check(bool(mid.get("ok",false)),"mid-hunt cannot resume"):
        return
    var resumed: HuntingPveRunV2 = mid["session"]
    var finish := hunt.finish()
    var repeat := resumed.finish()
    if not _check(bool(finish.get("ok",false)) and
            bool(repeat.get("ok",false)) and
            finish["summary"] == repeat["summary"],
            "real V2 hunt replay/resume inconsistent"):
        return
    if not _check(recruit.active_pve_encounter_id.is_empty() and
            state.sect.v2_pve_settlement_receipts.has("max_real_hunt_01"),
            "terminal recovery/reservation receipt absent"):
        return
    var amount_before := WarehouseSystem.new().quantity(state,&"linh_moc")
    var claim := hunt.claim()
    if not _check(bool(claim.get("ok",false)) and
            state.sect.v2_pve_reward_claims.has("max_real_hunt_01") and
            WarehouseSystem.new().quantity(state,&"linh_moc") > amount_before and
            not bool(resumed.claim().get("ok",true)) and
            not bool(hunt.claim().get("ok",true)),
            "warehouse reward not settled exactly once"):
        return
    var sect_reloaded := SectState.from_dict(
        JSON.parse_string(JSON.stringify(state.sect.to_dict())))
    if not _check(sect_reloaded.v2_pve_reward_claims.has("max_real_hunt_01") and
            sect_reloaded.v2_pve_settlement_receipts.has("max_real_hunt_01"),
            "max hunt claim/reservation lost after SectState serialization"):
        return

    # UI component smoke: it must instantiate without awarding resources;
    # a null runtime leaves the action buttons fail-closed.
    var panel := HuntingExpeditionPanelV2.new()
    get_root().add_child(panel)
    panel.bind_runtime(null)
    if not _check(panel.session == null and panel.start_button.disabled,
            "real hunt modal invented an encounter without runtime state"):
        return
    panel.queue_free()
    print("C4_BE01_REAL_HUNT_MAX_REALM_SAVE_CLAIM: PASS")
    quit(0)
