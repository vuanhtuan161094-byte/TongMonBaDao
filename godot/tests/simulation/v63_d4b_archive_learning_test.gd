extends SceneTree

const PREVIEW := {"sect_codex":true,"human_skill_combat":true}

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D4B_ARCHIVE_EFFECTS_FAIL: "+message)
    quit(1)

func _check(ok: bool, message: String) -> bool:
    if not ok:
        _fail(message)
        return false
    return true

func _run() -> void:
    var loaded := V63HumanSkillCombatSystem.load_catalogue()
    if not _check(bool(loaded.get("ok",false)),"candidate Human catalog did not validate: "+str(loaded.get("errors",[]))):
        return
    var checked_manuals := 0
    for skill in loaded.data.skills:
        if bool(skill.get("archivable",false)):
            var codex: Dictionary = V63SectArchiveSystem.codex_definition(str(skill.source_codex_id))
            if not _check(not codex.is_empty() and str(codex.get("source_node_id","")) == str(skill.node_id),"Human skill manual/source-node mismatch: "+str(skill.id)):
                return
            checked_manuals += 1
    if not _check(checked_manuals == 96,"expected 96 archived Human family manuals"):
        return

    var branch_state := _new_state()
    var poison_disciple := DiscipleState.new({"id":"poison_owner","name":"Poison Owner"})
    branch_state.disciples[poison_disciple.id] = poison_disciple
    var poison_skill_id := "tmb.skill.poison.doc_cham.active_02.human"
    if not _archive_learn_equip(branch_state,poison_disciple,poison_skill_id):
        return
    var actors := _make_actors(5)
    var poison_party: Array = actors[0]
    poison_party[0]["id"] = str(poison_disciple.id)
    var attach := V63HumanSkillCombatSystem.attach_disciple_loadout(branch_state,poison_party[0],PREVIEW)
    if not _check(bool(attach.get("ok",false)),"poison skill actor did not attach"):
        return
    var battle := _start_battle(actors)
    var caster: Dictionary = battle.actors[str(poison_disciple.id)]
    var target: Dictionary = battle.actors["enemy_0"]
    var poison_skill := V63HumanSkillCombatSystem.skill_definition(poison_skill_id)
    for _i in range(8):
        V63HumanSkillCombatSystem.release_cast(battle,_cast(poison_skill,caster,target),caster)
    var stacks: Array = target.get("status_effects",{}).get("v63_poison",[])
    if not _check(stacks.size() == 5 and str(stacks[0].get("owner_id","")) == str(caster.id),"Human poison did not enforce five stacks per owner/target with attribution"):
        return
    var hp_before := float(target.hp)
    caster["hp"] = 0.0
    battle.now = 1.0
    V63HumanSkillCombatSystem.process_status_effects(battle)
    if not _check(absf(float(target.hp)-hp_before) < 0.001,"dead poison owner produced a free damage tick"):
        return

    if not _support_effects():
        return
    if not _mobility_and_passive():
        return
    if not _boss_poison_cap():
        return
    print("V63 D4-B ARCHIVE/EFFECTS PASS: 96 source codices; five owner stacks; dead-owner stop; guard/heal/cleanse/mark/AoE/mobility/passive and 30-stack boss cap")
    quit(0)

func _new_state() -> SimulationState:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 12
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    return state

func _archive_learn_equip(state: SimulationState, disciple: DiscipleState, skill_id: String) -> bool:
    var skill := V63HumanSkillCombatSystem.skill_definition(skill_id)
    var codex_id := str(skill.get("source_codex_id",""))
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    var manual_id := StringName(str(codex.get("manual_item_id","")))
    var warehouse := WarehouseSystem.new()
    if codex.is_empty() or not warehouse.registry.has(manual_id) or not warehouse.add(state,manual_id,1):
        _fail("authentic manual could not enter canonical Warehouse: "+codex_id)
        return false
    if not bool(V63SectArchiveSystem.archive_manual(state,codex_id,PREVIEW).get("ok",false)):
        _fail("archive rejected manual "+codex_id)
        return false
    if not bool(V63HumanSkillCombatSystem.learn_skill(state,disciple,skill_id,PREVIEW).get("ok",false)):
        _fail("manual-backed learning failed "+skill_id)
        return false
    if not bool(V63HumanSkillCombatSystem.equip_skill(state,disciple,skill_id,PREVIEW).get("ok",false)):
        _fail("learned skill did not equip "+skill_id)
        return false
    return true

func _make_actors(monster_count: int, with_ally: bool = false) -> Array:
    var core := CombatStatsV2.derive(1,1,1,1,0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 10000000.0
    stats["attack"] = 60.0
    stats["defense"] = 25.0
    var party: Array = []
    var actor_count := 2 if with_ally else 1
    for i in range(actor_count):
        var position := Vector2(10.0+float(i),10.0)
        party.append({"id":"ally_%d" % i,"party_id":"effect_test","role":"frontline","tier":"disciple",
            "race_id":"nhan_toc","position":position,"stats":stats.duplicate(true),"hp":5000000.0,"max_hp":10000000.0,
            "resistances":core.resistances.duplicate(true),"basic_range":5.5,"move_speed":2.0,
            "basic_ratio":0.1,"basic_interval":20.0,"skill_loadout":[],"skill_factors":{},
            "context_sources":[],"disciple":null})
    var monsters: Array = []
    for i in range(monster_count):
        var raw := MonsterCatalogueV2.create_actor("truc_thu",1,1,"effect_monster_%d" % i)
        raw["id"] = "enemy_%d" % i
        raw["position"] = Vector2(12.0+float(i%3),10.0+float(i/3))
        var monster_stats: Dictionary = raw.stats.duplicate(true)
        monster_stats["max_hp"] = 10000000.0
        raw["stats"] = monster_stats
        raw["hp"] = 10000000.0
        monsters.append(raw)
    return [party,monsters]

func _start_battle(actor_data: Array) -> MapBattleV2:
    var battle := MapBattleV2.new(92177)
    var started := battle.setup("d4b_effect_test",actor_data[0],actor_data[1])
    if not bool(started.get("ok",false)):
        _fail("could not create effect Combat V2 encounter: "+str(started))
    return battle if bool(started.get("ok",false)) else null

func _cast(skill: Dictionary, caster: Dictionary, target: Dictionary) -> Dictionary:
    var record := {"caster":str(caster.id),"target_id":str(target.id),"v63_skill_id":str(skill.id),"ready":1.0,
        "ratio":float(skill.damage_ratio),"element":str(skill.element),"effect":str(skill.effect),
        "shape":str(skill.shape),"power":float(skill.get("power",0.0)),"duration":float(skill.get("duration",0.0)),
        "poison_stacks":int(skill.get("poison_stacks",1)),"radius":float(skill.get("radius",0.0)),
        "maximum":int(skill.get("target_limit",1))}
    if bool(caster.get("v63_custom_boss_ai",false)):
        record["v63_boss_id"] = str(caster.get("v63_boss_id",""))
    if str(skill.get("shape","")) == "circle":
        record["center"] = target.get("position",Vector2.ZERO)
    return record

func _support_effects() -> bool:
    var setup := _make_actors(4,true)
    var battle := _start_battle(setup)
    var caster: Dictionary = battle.actors["ally_0"]
    var ally: Dictionary = battle.actors["ally_1"]
    var enemy: Dictionary = battle.actors["enemy_0"]
    var guard := V63HumanSkillCombatSystem.skill_definition("tmb.skill.fist.kim_cang.active_02.human")
    V63HumanSkillCombatSystem.release_cast(battle,_cast(guard,caster,caster),caster)
    if not _check(float(caster.get("learned_guard_until",-1.0)) > 0.0,"Kim Cang guard did not settle"):
        return false
    var healer := V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.duoc_doc.active_02.human")
    ally["hp"] = 1000.0
    V63HumanSkillCombatSystem.release_cast(battle,_cast(healer,caster,ally),caster)
    if not _check(float(ally.hp) > 1000.0,"Dược Độc heal did not restore an ally"):
        return false
    var poison_status := [{"owner_id":"other","source_skill_id":"test","attack_snapshot":caster.stats.duplicate(true),
        "ratio":0.06,"element":"nether","next_tick":50.0,"expires_at":100.0}]
    ally["status_effects"] = {"v63_poison":poison_status,"burn":{"until":100.0}}
    var cleanse := V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.duoc_doc.active_03.human")
    V63HumanSkillCombatSystem.release_cast(battle,_cast(cleanse,caster,ally),caster)
    if not _check(not ally.get("status_effects",{}).has("v63_poison") and not ally.get("status_effects",{}).has("burn"),"Dược Độc cleanse did not remove bounded debuffs"):
        return false
    var mark := V63HumanSkillCombatSystem.skill_definition("tmb.skill.fist.huyet_quyen.active_02.human")
    V63HumanSkillCombatSystem.release_cast(battle,_cast(mark,caster,enemy),caster)
    if not _check(V63HumanSkillCombatSystem.marked_damage_factor(caster,enemy,battle.now) > 1.0,"Huyết Quyền mark did not amplify its owner's follow-up"):
        return false
    var aoe := V63HumanSkillCombatSystem.skill_definition("tmb.skill.bow.thien_vu.active_03.human")
    var aoe_cast := _cast(aoe,caster,enemy)
    aoe_cast["shape"] = "circle"
    aoe_cast["center"] = enemy.position
    var before_events := battle.events.size()
    V63HumanSkillCombatSystem.release_cast(battle,aoe_cast,caster)
    var hits := 0
    for event in battle.events.slice(before_events):
        if str(event.get("type","")) == "v63_skill_hit" and str(event.get("skill_id","")) == str(aoe.id):
            hits += 1
    return _check(hits == 3,"bounded AoE did not stop at the three-target ceiling: %d" % hits)

func _mobility_and_passive() -> bool:
    var state := _new_state()
    var disciple := DiscipleState.new({"id":"mobility_owner"})
    state.disciples[disciple.id] = disciple
    var mobility_id := "tmb.skill.bow.mobility.human"
    if not _archive_learn_equip(state,disciple,mobility_id):
        return false
    var setup := _make_actors(1)
    var actor: Dictionary = setup[0][0]
    actor["id"] = str(disciple.id)
    actor["position"] = Vector2(10.0,10.0)
    actor["role"] = "ranged"
    actor["basic_range"] = 2.0
    var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,PREVIEW)
    if not _check(bool(attached.get("ok",false)),"mobility did not attach"):
        return false
    var original: Vector2 = actor.position
    var mobility_monster: Dictionary = setup[1][0]
    mobility_monster["position"] = Vector2(20.0,10.0)
    var battle := _start_battle([setup[0],[mobility_monster]])
    battle.step()
    battle.step()
    battle.step()
    var moved := (battle.actors[str(disciple.id)].position as Vector2).distance_to(original) > 0.1
    if not _check(moved,"bow mobility did not change the actual Combat V2 position"):
        return false
    var evaded := false
    for event in battle.events:
        if str(event.get("type","")) == "evade" and str(event.get("target","")) == str(disciple.id):
            evaded = true
    if not _check(evaded,"mobility evasion window did not block a real Combat V2 hit"):
        return false
    var passive_state := _new_state()
    var passive_disciple := DiscipleState.new({"id":"passive_owner"})
    passive_state.disciples[passive_disciple.id] = passive_disciple
    var passive_id := "tmb.skill.bow.liep_anh.passive_01.human"
    if not _archive_learn_equip(passive_state,passive_disciple,passive_id):
        return false
    var passive_actor: Dictionary = _make_actors(0)[0][0]
    passive_actor["id"] = str(passive_disciple.id)
    if not _check(bool(V63HumanSkillCombatSystem.attach_disciple_loadout(passive_state,passive_actor,PREVIEW).get("ok",false)),"passive did not attach"):
        return false
    var base_stats: Dictionary = passive_actor.stats.duplicate(true)
    var effective := V63HumanSkillCombatSystem.effective_attack_stats(passive_actor,base_stats)
    return _check(float(effective.attack) > float(base_stats.attack),"branch passive did not modify CombatStatsV2 attack input")

func _boss_poison_cap() -> bool:
    var spawned := HuntingMapV2.spawn("thanh_truc_lam",1,"d4b_poison_boss",93100)
    var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawned,"tmb.boss.bach_doc_chu_hau")
    if not bool(installed.get("ok",false)):
        return _check(false,"Bách Độc did not install for stack cap test")
    var boss: Dictionary = installed.boss_actor.duplicate(true)
    var setup := _make_actors(0)
    var party: Array = setup[0]
    party[0]["position"] = Vector2(20.0,8.0)
    boss["position"] = Vector2(21.0,8.0)
    var battle := MapBattleV2.new(93101)
    if not _check(bool(battle.setup("d4b_boss_poison_cap",party,[boss]).get("ok",false)),"could not build boss poison cap encounter"):
        return false
    var source: Dictionary = battle.actors[str(boss.id)]
    var target: Dictionary = battle.actors["ally_0"]
    var skill: Dictionary = V63HumanSkillCombatSystem.boss_skill_definitions(str(boss.v63_boss_id))["tmb.bossskill.bach_doc_chu_hau.active_01"]
    for _i in range(12):
        V63HumanSkillCombatSystem.release_cast(battle,_cast(skill,source,target),source)
    var stacks: Array = target.get("status_effects",{}).get("v63_poison",[])
    return _check(stacks.size() == 5 and str(stacks[0].get("owner_id","")) == str(source.id),"boss poison did not respect cap 5 per owner (target cap remains 30): "+str(stacks.size()))
