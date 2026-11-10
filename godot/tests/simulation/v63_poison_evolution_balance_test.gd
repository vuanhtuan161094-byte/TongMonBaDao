extends SceneTree

# PVB1 exact-source acceptance: catalogue, 35 families, 183 nodes,
# 6 rare passives, 7 Divine rules and deterministic PvE mechanic bounds.
var failures := 0
var checks := 0

func _init() -> void:
    call_deferred("_run")

func _ok(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error("PVB1_FAIL " + message)

func _approx(value: float, expected: float, message: String, tolerance: float = 0.00001) -> void:
    _ok(absf(value - expected) <= tolerance, message + " got=" + str(value) + " expected=" + str(expected))

func _run() -> void:
    _catalogue_contract()
    _pure_consume_contract()
    _heal_budget_contract()
    _divine_rules_contract()
    _spread_contract()
    _ok(V63FeatureGates.all_disabled(), "legacy release gate must remain OFF")
    print("PVB1_POISON_EVOLUTION_SUMMARY " + JSON.stringify({
        "skills":183,"families":35,"rare_passive":6,"proposal_effect_change_count":36,
        "godot_checks":checks,"failures":failures,
        "scope":"real catalogue/schema + bounded mechanics, not live 30-hunter PvE telemetry",
        "status":"PASS" if failures == 0 else "FAIL"
    }))
    quit(0 if failures == 0 else 1)

func _catalogue_contract() -> void:
    var reg := V63ContentRegistry.load_catalogue()
    _ok(bool(reg.get("ok", false)), "registry strict validator: " + str(reg.get("errors", [])))
    var sources := [
        V63HumanSkillCombatSystem.load_catalogue(),
        V63ImmortalSkillCombatSystem.load_catalogue(),
        V63DivineSkillCombatSystem.load_catalogue()
    ]
    var source_ids: Dictionary = {}
    var all_names: Dictionary = {}
    var family_ids: Dictionary = {}
    var parent_links: Dictionary = {}
    var total := 0
    var rare_passives := 0
    var human := 0
    var immortal := 0
    var divine := 0
    for catalog in sources:
        _ok(bool(catalog.get("ok", false)), "V63 catalogue strict validation " + str(catalog.get("errors", [])))
        var data: Dictionary = catalog.get("data", {})
        _ok(not bool(data.get("enabled", true)), "candidate release gate remains OFF")
        for item in data.get("skills", []):
            if str(item.get("school", "")) != "poison":
                continue
            total += 1
            var id := str(item.get("id", ""))
            _ok(not source_ids.has(id), "duplicate ID " + id)
            source_ids[id] = true
            _ok(not all_names.has(str(item.get("name", ""))), "duplicate name " + id)
            all_names[str(item.get("name", ""))] = true
            family_ids[str(item.get("family_id", ""))] = true
            parent_links[id] = str(item.get("parent_skill_id", ""))
            _ok(str(item.get("poison_evolution_balance_rev", "")) == "PVB1_CANDIDATE_20261110",
                "unmigrated source row " + id)
            _ok(float(item.get("damage_ratio", 0.0)) > 0.0 and float(item.get("cooldown", 0.0)) > 0.0,
                "invalid current V63 validator field " + id)
            _ok(int(item.get("target_limit", 0)) >= 1 and int(item.get("target_limit", 0)) <= 3,
                "invalid AoE target bound " + id)
            _ok(float(item.get("radius", 0.0)) <= 3.0, "invalid AoE radius " + id)
            if str(item.get("tier", "")) == "human":
                human += 1
            elif str(item.get("tier", "")) == "immortal":
                immortal += 1
            else:
                divine += 1
            if id.contains(".rare_passive."):
                rare_passives += 1
    _ok(total == 183 and human == 35 and immortal == 68 and divine == 80,
        "tier histogram " + str([total,human,immortal,divine]))
    _ok(family_ids.size() == 35, "family count " + str(family_ids.size()))
    _ok(rare_passives == 6, "rare passive count " + str(rare_passives))
    var tiendu: Dictionary = V63HumanSkillCombatSystem.skill_definition(
        "tmb.skill.poison.doc_cham.active_02.immortal.a")
    var parents: Dictionary = {}
    _ok(not V63PoisonEvolutionV1.predecessor_ready(tiendu, parents),
        "new Tiên skill must not ignore unlearned Nhân predecessor")
    parents[str(tiendu.get("parent_skill_id", ""))] = {"mastery_xp":1.0}
    _ok(V63PoisonEvolutionV1.predecessor_ready(tiendu, parents),
        "matching predecessor unlocks same-family study")
    for id in parent_links.keys():
        if not id.ends_with(".human") and not id.ends_with(".human.base"):
            var parent := str(parent_links[id])
            _ok(not parent.is_empty() and source_ids.has(parent),
                "missing parent in combat catalogues " + id + " parent=" + parent)
    var registry_nodes: Dictionary = {}
    for family in reg.get("data", {}).get("families", []):
        if str(family.get("school", "")) != "poison":
            continue
        for node in family.get("nodes", []):
            registry_nodes[str(node.get("id", ""))] = true
    _ok(registry_nodes.size() == 183, "registry nodes " + str(registry_nodes.size()))
    for id in source_ids.keys():
        _ok(registry_nodes.has(id), "registry missing " + id)
    print("PVB1_CATALOGUE_PASS " + JSON.stringify({"total":total,"human":human,
        "immortal":immortal,"divine":divine,"families":family_ids.size(),
        "rare_passives":rare_passives,"registry_nodes":registry_nodes.size()}))

func _poison(owner: String, now: float, remaining_ticks: int, ratio: float) -> Dictionary:
    return {"owner_id":owner,"ratio":ratio,"next_tick":now + 1.0,
        "expires_at":now + 1.0 + float(remaining_ticks)}

func _pure_consume_contract() -> void:
    var now := 10.0
    var stacks := [_poison("A",now,4,0.03),_poison("A",now,4,0.03),
        _poison("B",now,8,0.20)]
    _approx(V63PoisonEvolutionV1.consume_bonus_ratio(stacks,"A",now),0.256,
        "two 4-tick stacks of caster A: consumes only A")
    _approx(V63PoisonEvolutionV1.consume_bonus_ratio(stacks,"B",now),0.60,
        "one high damage caster B capped")
    _approx(V63PoisonEvolutionV1.consume_bonus_ratio(stacks,"C",now),0.0,
        "unowned stacks cannot be consumed")
    var contested := [_poison("A",now,4,0.03), _poison("A",now,4,0.03)]
    for i in range(28):
        contested.append(_poison("other_%d" % i,now,4,0.03))
    _approx(V63PoisonEvolutionV1.consume_bonus_ratio(contested,"A",now),
        0.2224, "30-stack diminishing factor 19.5/30 must apply to future DoT")
    var five: Array = []
    for _i in range(5):
        five.append(_poison("A",now,8,0.03))
    _approx(V63PoisonEvolutionV1.consume_bonus_ratio(five,"A",now),0.60,
        "five 8-tick stacks capped at 0.60")
    var target := {"status_effects":{"v63_poison":[
        {"owner_id":"A","applied_at":5.0,"expires_at":13.0},
        {"owner_id":"A","applied_at":6.0,"expires_at":12.0},
        {"owner_id":"B","applied_at":7.0,"expires_at":12.0}
    ]}}
    _ok(V63PoisonEvolutionV1.refresh_oldest_owned_poison(target,"A",8.0,10.0),
        "refresh oldest owned stack")
    var after: Array = target.status_effects.v63_poison
    _approx(float(after[0].expires_at),18.0,"oldest owner A refreshed")
    _approx(float(after[2].expires_at),12.0,"owner B unchanged by A refresh")
    _ok(after.size()==3,"refresh must not mint a stack")
    print("PVB1_CONSUME_PASS")

func _heal_budget_contract() -> void:
    var ally := {"id":"ally","side":"disciple","v63_combat_enabled":true,
        "hp":154.0,"max_hp":190.0}
    V63PoisonEvolutionV1.record_damage_taken(ally,36.0,10.0)
    _approx(V63PoisonEvolutionV1.heal_allowed(ally,80.0,11.0),12.6,
        "r1 recent 36HP damage: min 12% MaxHP,35% damage")
    _approx(V63PoisonEvolutionV1.heal_allowed(ally,80.0,12.0),0.0,
        "second heal cannot double-spend budget")
    # Cold Save/Load duplicates retained actor receipt data: no fresh budget.
    var clone: Dictionary = bytes_to_var(var_to_bytes(ally))
    _approx(V63PoisonEvolutionV1.heal_allowed(clone,80.0,12.0),0.0,
        "serialized budget cannot reset")
    V63PoisonEvolutionV1.record_damage_taken(ally,1000.0,13.0)
    _approx(V63PoisonEvolutionV1.heal_allowed(ally,80.0,14.0),10.2,
        "120HP MaxHP target cap less already granted 12.6 -> 10.2")
    _approx(V63PoisonEvolutionV1.heal_allowed(ally,80.0,615.0),0.0,
        "10m window must expire rather than mint free healing")
    _ok(not ally.has("injury_recover_at_tick"),"heal must not modify Injury")
    print("PVB1_HEAL_BUDGET_PASS")

func _divine_rules_contract() -> void:
    var branches := {
        "doc_cham/a":"owned_poison_maintain",
        "doc_cham/b":"owned_poison_consume",
        "co_doc/a":"single_spread_poison",
        "co_doc/b":"marked_target_punish",
        "duoc_doc/a":"cleanse_heal_fatal_save",
        "duoc_doc/b":"removed_debuff_counter"
    }
    for path in branches.keys():
        var pair := str(path).split("/")
        var actor := {"id":"A","v63_combat_branch_id":pair[0],
            "v63_combat_lineage":pair[1],"v63_combat_generation":"divine"}
        _ok(V63PoisonEvolutionV1.rule_for_actor(actor)==branches[path],
            "wrong Divine rule for "+str(path))
    var caster := {"id":"A","v63_combat_generation":"divine",
        "v63_combat_branch_id":"co_doc","v63_combat_lineage":"b"}
    var victim := {"v63_marks":{"A":{"owner_id":"A","until":10.0}}}
    _approx(V63PoisonEvolutionV1.try_mark_bonus(caster,victim,1.0),0.12,
        "first owned valid mark")
    _approx(V63PoisonEvolutionV1.try_mark_bonus(caster,victim,2.0),0.0,
        "mark 8-second cooldown")
    caster.v63_combat_branch_id="duoc_doc"
    _ok(not V63PoisonEvolutionV1.arm_cleanse_counter(caster,0,1.0),
        "empty cleanse must not arm counter")
    _ok(V63PoisonEvolutionV1.arm_cleanse_counter(caster,1,1.0),
        "real cleanse arms one counter")
    _approx(V63PoisonEvolutionV1.consume_cleanse_counter(caster,2.0),0.08,
        "first post-cleanse attack gets +0.08")
    _approx(V63PoisonEvolutionV1.consume_cleanse_counter(caster,3.0),0.0,
        "counter cannot proc twice")
    print("PVB1_DIVINE_RULES_PASS")

func _spread_contract() -> void:
    var actor := {"id":"A","side":"disciple","position":Vector2.ZERO,
        "hp":1000.0,"max_hp":1000.0,"stats":{"attack":100.0},
        "v63_combat_generation":"divine","v63_combat_branch_id":"co_doc",
        "v63_combat_lineage":"a","v63_passive_ids":[],"v63_innate_skill_id":""}
    var near := {"id":"near","side":"monster","position":Vector2(2.4,0.0),
        "hp":1000.0,"max_hp":1000.0,"status_effects":{}}
    var far := {"id":"far","side":"monster","position":Vector2(2.6,0.0),
        "hp":1000.0,"max_hp":1000.0,"status_effects":{}}
    var main := {"id":"main","side":"monster","position":Vector2.ZERO,
        "hp":1000.0,"max_hp":1000.0,"status_effects":{}}
    var battle := MapBattleV2.new(20261110)
    battle.encounter_id="poison_test"
    battle.actors={"A":actor,"main":main,"near":near,"far":far}
    var skill_id := "tmb.skill.poison.co_doc.active_02.divine.a"
    var ok := V63PoisonEvolutionV1.spread_one(battle,actor,main,skill_id,
        0.02,8.0,"wood")
    _ok(ok,"one valid spread to 2.4 cells")
    _ok(near.status_effects.get("v63_poison",[]).size()==1,
        "near acquired exactly 1 stack")
    _ok(far.status_effects.get("v63_poison",[]).is_empty(),
        "far at 2.6 cells cannot spread")
    _ok(not V63PoisonEvolutionV1.spread_one(battle,actor,main,skill_id,
        0.02,8.0,"wood"),"spread 6s ICD prevents immediate second copy")
    print("PVB1_SPREAD_PASS")
