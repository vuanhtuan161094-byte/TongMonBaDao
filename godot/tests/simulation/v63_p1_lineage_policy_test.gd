extends SceneTree

# Exercises the owner-approved P1 policies through Combat V2's real cast path.
# Actor dictionaries below are deterministic simulation fixtures only; status
# and summon prerequisites use the existing Combat V2 helpers/factory.
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Summon = preload("res://src/simulation/combat/v63_summon_skill_combat_system.gd")

const CONTRACT_RELATIVE_PATH := "../docs/qa/V63_P1_LINEAGE_CONTRACT_20261113/LINEAGE_P1_BEHAVIOR_CONTRACTS.json"
var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_P1_LINEAGE_FAIL " + label)

func _run() -> void:
    var contract_path := ProjectSettings.globalize_path("res://")+CONTRACT_RELATIVE_PATH
    var file := FileAccess.open(contract_path,FileAccess.READ)
    _expect(file != null,"approved P1 contract is readable")
    if file == null:
        _finish()
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    _expect(parsed is Dictionary,"approved P1 contract parses as object")
    if not (parsed is Dictionary):
        _finish()
        return
    var contracts: Array = parsed.get("contracts",[])
    _expect(contracts.size() == 41,"contract contains exactly 41 approved A/B pairs")
    var seen_ids: Dictionary = {}
    var completed := 0
    for contract in contracts:
        if not (contract is Dictionary):
            _expect(false,"contract row is an object")
            continue
        var skill_a := HSC.skill_definition(str(contract.get("id_a","")))
        var skill_b := HSC.skill_definition(str(contract.get("id_b","")))
        var pair_label := str(contract.get("contract_id",""))
        _expect(not skill_a.is_empty() and not skill_b.is_empty(),pair_label+" runtime A/B definitions exist")
        if skill_a.is_empty() or skill_b.is_empty():
            continue
        _expect(str(skill_a.get("lineage","")) == "a" and str(skill_b.get("lineage","")) == "b",pair_label+" runtime lineage identity matches contract")
        seen_ids[str(skill_a.id)] = true
        seen_ids[str(skill_b.id)] = true
        if str(contract.get("school","")) == "summon":
            _exercise_summon_pair(contract,skill_a,skill_b,pair_label)
        else:
            var battle_a := _build_battle(skill_a,false)
            var actor_a: Dictionary = battle_a["caster"]
            var enemy_a: Dictionary = battle_a["enemy"]
            var cast_a := HSC.try_cast(battle_a["battle"],actor_a,enemy_a)
            var pending_a: Dictionary = actor_a.get("v63_pending_cast",{})
            _expect(cast_a and not pending_a.is_empty(),pair_label+" A is selected and enters Combat V2 cast")
            var battle_b := _build_battle(skill_b,false)
            var actor_b: Dictionary = battle_b["caster"]
            var enemy_b: Dictionary = battle_b["enemy"]
            var cast_b := HSC.try_cast(battle_b["battle"],actor_b,enemy_b)
            var pending_b: Dictionary = actor_b.get("v63_pending_cast",{})
            _expect(cast_b and not pending_b.is_empty(),pair_label+" B is selected and enters Combat V2 cast")
            if cast_a and cast_b:
                _expect(str(pending_a.get("target_id","")) != str(pending_b.get("target_id","")),pair_label+" A/B target choice differs on the approved deterministic state")
                _expect(str(pending_a.get("shape","")) == str(skill_a.get("shape","")) and str(pending_b.get("shape","")) == str(skill_b.get("shape","")),pair_label+" cast keeps canonical shape")
                _expect(int(pending_a.get("maximum",0)) == int(skill_a.get("target_limit",0)) and int(pending_b.get("maximum",0)) == int(skill_b.get("target_limit",0)),pair_label+" cast keeps canonical target limit")
                _release_and_check_trace(battle_a["battle"],actor_a,skill_a,pair_label+" A")
                _release_and_check_trace(battle_b["battle"],actor_b,skill_b,pair_label+" B")
            completed += 1
    _expect(seen_ids.size() == 82,"all 82 exact P1 skill IDs are exercised")
    _expect(completed == 35,"all non-summon P1 pairs completed their target-selection path")
    _finish()

func _exercise_summon_pair(contract: Dictionary, skill_a: Dictionary, skill_b: Dictionary, label: String) -> void:
    var no_summon_a := _build_battle(skill_a,false)
    var actor_a: Dictionary = no_summon_a["caster"]
    var cast_a := HSC.try_cast(no_summon_a["battle"],actor_a,no_summon_a["enemy"])
    var pending_a: Dictionary = actor_a.get("v63_pending_cast",{})
    _expect(cast_a and str(pending_a.get("target_id","")) == str(actor_a.get("id","")),label+" A guard casts on threatened owner without a summon")
    if cast_a:
        _release_and_check_trace(no_summon_a["battle"],actor_a,skill_a,label+" A")
    var no_summon_b := _build_battle(skill_b,false)
    var actor_b: Dictionary = no_summon_b["caster"]
    var cast_without_summon := HSC.try_cast(no_summon_b["battle"],actor_b,no_summon_b["enemy"])
    _expect(not cast_without_summon and actor_b.get("v63_pending_cast",{}).is_empty(),label+" B guard is withheld when its branch summon is absent")
    var with_summon_b := _build_battle(skill_b,true)
    var summoned_actor: Dictionary = with_summon_b["caster"]
    var cast_b := HSC.try_cast(with_summon_b["battle"],summoned_actor,with_summon_b["enemy"])
    var pending_b: Dictionary = summoned_actor.get("v63_pending_cast",{})
    _expect(cast_b and str(pending_b.get("target_id","")) == str(summoned_actor.get("id","")),label+" B guard casts on owner only after its owned summon is valid")
    if cast_b:
        _release_and_check_trace(with_summon_b["battle"],summoned_actor,skill_b,label+" B")

func _build_battle(skill: Dictionary, with_summon: bool) -> Dictionary:
    var battle := MapBattleV2.new(760301+str(skill.get("id","")).length())
    battle.active = true
    battle.outcome = "fighting"
    battle.encounter_id = "v63_p1_"+str(skill.get("id",""))
    var caster := _actor("p1_caster","disciple",Vector2.ZERO)
    caster["party_id"] = "p1_test_party"
    caster["stats"]["attack"] = 40.0
    caster["v63_combat_enabled"] = true
    caster["v63_palm_combat_enabled"] = true
    caster["v63_talisman_combat_enabled"] = true
    caster["v63_summon_combat_enabled"] = true
    caster["v63_skill_loadout"] = [str(skill.get("id",""))]
    battle.actors[str(caster.id)] = caster
    var branch := str(skill.get("branch",""))
    var effect := str(skill.get("effect",""))
    var fallback := _actor("p1_nearest_enemy","enemy",Vector2(1.5,0.0))
    var all_enemies: Array[Dictionary] = [fallback]
    if branch in ["hoi_phong_chuong","phong_an_phu"] and effect in ["heal","cleanse","guard"]:
        var low_ally := _actor("p1_low_ally","disciple",Vector2(1.0,0.0))
        var threat_ally := _actor("p1_threat_ally","disciple",Vector2(0.0,1.0))
        low_ally["party_id"] = caster.party_id
        threat_ally["party_id"] = caster.party_id
        low_ally["hp"] = 80.0
        threat_ally["hp"] = 160.0
        if effect == "cleanse":
            low_ally["status_effects"] = {"slow":{"until":100.0,"movement_factor":0.8},"weaken":{"until":100.0}}
            threat_ally["status_effects"] = {"burn":{"until":100.0}}
        battle.actors[str(low_ally.id)] = low_ally
        battle.actors[str(threat_ally.id)] = threat_ally
        fallback["position"] = Vector2(0.0,2.0)
    elif branch == "han_ngoc_chuong":
        var carry := _actor("p1_carry","disciple",Vector2(0.0,5.0))
        carry["party_id"] = caster.party_id
        carry["stats"]["attack"] = 120.0
        battle.actors[str(carry.id)] = carry
        var engagement := _actor("p1_engaged_enemy","enemy",Vector2(3.0,0.0))
        engagement["aggro_range"] = 4.5
        var carry_threat := _actor("p1_carry_threat","enemy",Vector2(0.0,4.0))
        all_enemies.append(engagement)
        all_enemies.append(carry_threat)
    elif branch == "loi_phu":
        var row_a := _actor("p1_line_a","enemy",Vector2(3.0,0.0))
        var row_b := _actor("p1_line_b","enemy",Vector2(5.0,0.0))
        var row_c := _actor("p1_line_c","enemy",Vector2(6.5,0.0))
        var marked := _actor("p1_owned_mark","enemy",Vector2(6.5,2.0))
        HSC._apply_mark(battle,caster,marked,"tmb.skill.talisman.loi_phu.active_03.human",1.0,30.0)
        all_enemies.append(row_a)
        all_enemies.append(row_b)
        all_enemies.append(row_c)
        all_enemies.append(marked)
    elif branch == "liet_duong_chuong" and str(skill.get("shape","")) == "circle":
        fallback["position"] = Vector2(1.5,0.0)
        var cluster_a := _actor("p1_cluster_a","enemy",Vector2(3.0,0.0))
        var cluster_b := _actor("p1_cluster_b","enemy",Vector2(3.5,0.1))
        var cluster_c := _actor("p1_cluster_c","enemy",Vector2(4.0,0.0))
        all_enemies.append(cluster_a)
        all_enemies.append(cluster_b)
        all_enemies.append(cluster_c)
    if branch in ["liet_duong_chuong","hoa_phu"]:
        var durable := _actor("p1_durable_enemy","enemy",Vector2(5.5,0.0))
        durable["hp"] = 500.0
        durable["max_hp"] = 500.0
        durable["tier"] = "elite"
        all_enemies.append(durable)
    if str(contract_school(skill)) == "summon":
        fallback["position"] = Vector2(3.0,0.0)
        fallback["v63_pending_cast"] = {"target_id":str(caster.get("id","")),"v63_skill_id":"test_existing_enemy_cast"}
    for enemy in all_enemies:
        enemy["hp"] = maxf(200.0,float(enemy.get("hp",0.0)))
        enemy["max_hp"] = maxf(200.0,float(enemy.get("max_hp",0.0)))
        battle.actors[str(enemy.get("id",""))] = enemy
    if with_summon:
        var factory_id := "tmb.skill.summon.%s.active_01.human" % branch
        var summon_skill := Summon.skill_definition(factory_id)
        if not summon_skill.is_empty():
            Summon.release_cast(battle,{"v63_skill_id":factory_id},caster)
            for candidate in battle.actors.values():
                if bool(candidate.get("is_v63_summon",false)) and str(candidate.get("summon_owner_id","")) == str(caster.id):
                    if branch == "linh_thu":
                        candidate["position"] = Vector2(2.5,0.0)
                    elif branch == "khoi_loi_ho_phap":
                        candidate["position"] = Vector2(1.5,0.0)
                    break
    return {"battle":battle,"caster":caster,"enemy":fallback}

func _release_and_check_trace(battle: MapBattleV2, actor: Dictionary, skill: Dictionary, label: String) -> void:
    var pending: Dictionary = actor.get("v63_pending_cast",{})
    var cast_id := str(pending.get("mastery_event_id",""))
    var cast_events := _events_for_cast(battle,cast_id)
    _expect(not cast_id.is_empty() and cast_events.size() == 1,label+" cast has unique Combat V2 identity")
    if not cast_events.is_empty():
        _expect(str(cast_events[0].get("event_id","")) == cast_id+"/skill_cast" and cast_events[0].has("caster_position_at_cast") and cast_events[0].has("target_position_at_cast"),label+" cast event is spatially identifiable for event consumers")
    battle.now = float(pending.get("ready",battle.now))
    battle._release_casts()
    var release_events: Array = []
    var hit_receipts: Array = []
    var all_ids: Dictionary = {}
    for event in battle.events:
        if str(event.get("cast_id","")) != cast_id:
            continue
        var event_id := str(event.get("event_id",""))
        _expect(not event_id.is_empty() and not all_ids.has(event_id),label+" each cast lifecycle receipt has a deduplicable event ID")
        all_ids[event_id] = true
        if str(event.get("type","")) == "skill_release":
            release_events.append(event)
        if str(event.get("type","")) in ["hit","v63_skill_hit","heal","cleanse","status_applied","v63_talisman_hit","v63_talisman_mark_applied"]:
            hit_receipts.append(event)
    _expect(release_events.size() == 1,label+" emits one authoritative release event")
    _expect(not hit_receipts.is_empty(),label+" reaches at least one authoritative hit/status/support receipt")
    for event in release_events:
        _expect(str(event.get("event_id","")) == cast_id+"/skill_release",label+" release event retains lifecycle identity")
        _expect(event.has("caster_position") and event.has("target_position") and event.has("shape"),label+" release event carries resolved geometry")
    for event in hit_receipts:
        var event_target_id := str(event.get("target",event.get("target_id","")))
        if not event_target_id.is_empty() and battle.actors.has(event_target_id):
            _expect(event.has("caster_position") and event.has("target_position"),label+" effect receipt carries actual actor positions")

func _events_for_cast(battle: MapBattleV2, cast_id: String) -> Array:
    var result: Array = []
    for event in battle.events:
        if str(event.get("cast_id","")) == cast_id and str(event.get("type","")) == "skill_cast":
            result.append(event)
    return result

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,"lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
    return {"id":actor_id,"side":side,"party_id":"","role":"melee","position":position,
        "hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
        "stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
            "crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,
        "v63_palm_combat_enabled":true,"v63_talisman_combat_enabled":true,"v63_summon_combat_enabled":true,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,
        "next_skill":0.0,"learned_guard_factor":1.0,"learned_guard_until":-1.0}

func contract_school(skill: Dictionary) -> String:
    return str(skill.get("school",""))

func _finish() -> void:
    if _failures > 0:
        print("V63_P1_LINEAGE_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
        quit(1)
        return
    print("V63_P1_LINEAGE_RESULT PASS checks="+str(_checks)+" pairs=41 skills=82 cast=CombatV2 gate=OFF")
    quit(0)
