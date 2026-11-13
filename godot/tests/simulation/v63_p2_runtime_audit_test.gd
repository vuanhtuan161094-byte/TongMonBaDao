extends SceneTree

# Runtime probe for exact-equal P2 passive/innate pairs. Equality is evidence,
# not proof that sharing was intentional; owner design approval remains required.
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Blade = preload("res://src/simulation/combat/v63_blade_skill_combat_system.gd")
const Sword = preload("res://src/simulation/combat/v63_sword_skill_combat_system.gd")
const Divine = preload("res://src/simulation/combat/v63_divine_skill_combat_system.gd")
const Summon = preload("res://src/simulation/combat/v63_summon_skill_combat_system.gd")
const MapBattle = preload("res://src/simulation/combat/map_battle_v2.gd")

const COMPARISON_PATH := "../docs/qa/V63_DESIGN_AUDIT_20261113/LINEAGE_AB_COMPARISON.csv"
var _checks := 0
var _failures := 0
var _p2_rows := 0
var _equal_rows := 0
var _different_rows := 0
var _missing_rows := 0
var _different_ids: Array[String] = []

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_P2_RUNTIME_FAIL " + label)

func _run() -> void:
    var csv_path := ProjectSettings.globalize_path("res://") + COMPARISON_PATH
    var file := FileAccess.open(csv_path,FileAccess.READ)
    _expect(file != null,"P2 source comparison CSV is readable")
    if file == null:
        _finish()
        return
    var header: PackedStringArray = file.get_csv_line()
    var columns: Dictionary = {}
    for index in range(header.size()):
        columns[str(header[index])] = index
    for required in ["school","branch","tier","slot","id_a","id_b","exact","priority"]:
        _expect(columns.has(required),"P2 comparison CSV has column "+required)
    while not file.eof_reached():
        var row: PackedStringArray = file.get_csv_line()
        if row.is_empty() or row.size() < header.size() or row[int(columns.get("priority",-1))] != "P2":
            continue
        _p2_rows += 1
        var school := row[int(columns["school"])]
        var branch := row[int(columns["branch"])]
        var slot := row[int(columns["slot"])]
        var id_a := row[int(columns["id_a"])]
        var id_b := row[int(columns["id_b"])]
        _expect(row[int(columns["exact"])] == "YES","P2 row is in the exact-equal audit set: "+id_a)
        var skill_a := HSC.skill_definition(id_a)
        var skill_b := HSC.skill_definition(id_b)
        _expect(not skill_a.is_empty() and not skill_b.is_empty(),"runtime definitions load for pair "+id_a)
        if skill_a.is_empty() or skill_b.is_empty():
            _missing_rows += 1
            continue
        _expect(str(skill_a.get("school","")) == school and str(skill_b.get("school","")) == school,
            "runtime school identity matches source row: "+id_a)
        _expect(str(skill_a.get("branch","")) == branch and str(skill_b.get("branch","")) == branch,
            "runtime branch identity matches source row: "+id_a)
        var actor_a := _actor_for_pair(school,id_a,slot)
        var actor_b := _actor_for_pair(school,id_b,slot)
        var observed_a := _observe_runtime(actor_a,skill_a,id_a)
        var observed_b := _observe_runtime(actor_b,skill_b,id_b)
        if observed_a == observed_b:
            _equal_rows += 1
        else:
            _different_rows += 1
            _different_ids.append(id_a+" <> "+id_b)
    _expect(_p2_rows == 196,"all 196 P2 rows were exercised; got "+str(_p2_rows))
    _expect(_missing_rows == 0,"all P2 runtime definitions resolved; missing="+str(_missing_rows))
    _expect(_equal_rows+_different_rows+_missing_rows == _p2_rows,"each P2 row received a runtime classification")
    _finish()

func _actor_for_pair(school: String, skill_id: String, slot: String) -> Dictionary:
    var actor := {"id":"p2_runtime_probe","side":"disciple","v63_combat_enabled":true,
        "v63_sword_combat_enabled":true,"v63_blade_combat_enabled":true,"v63_spear_combat_enabled":true,
        "v63_dual_blade_combat_enabled":true,"v63_palm_combat_enabled":true,"v63_talisman_combat_enabled":true,
        "v63_curse_combat_enabled":true,"v63_formation_combat_enabled":true,"v63_summon_combat_enabled":true,
        "v63_passive_ids":[],"v63_innate_skill_id":"","v63_root_global_all_damage_bonus":0.0,
        "learned_guard_until":100.0,"guard_until":100.0,"v63_fatal_save_ready_at":-1.0,
        "max_hp":200.0,"hp":100.0,"v63_base_max_hp":200.0,"v63_combat_generation":"divine",
        "stats":{"attack":100.0,"crit_chance":0.2,"attack_speed":0.1,"cast_speed":0.05,
            "cooldown_recovery":0.1,"lifesteal":0.02,"damage_reduction":0.25}}
    if slot == "innate":
        actor["v63_innate_skill_id"] = skill_id
    else:
        actor["v63_passive_ids"] = [skill_id]
    actor["v63_combat_branch_id"] = str(HSC.skill_definition(skill_id).get("branch", ""))
    actor["v63_combat_lineage"] = str(HSC.skill_definition(skill_id).get("lineage", ""))
    actor["v63_summon_combat_enabled"] = school == "summon"
    actor["v63_talisman_combat_enabled"] = school == "talisman"
    actor["v63_curse_combat_enabled"] = school == "curse"
    actor["v63_formation_combat_enabled"] = school == "formation"
    return actor

func _observe_runtime(actor: Dictionary, skill: Dictionary, skill_id: String) -> Dictionary:
    var stats: Dictionary = actor.get("stats",{})
    var mods: Dictionary = HSC._root_scaled_passive_modifiers(actor,skill_id)
    var result := {
        "modifier_payload":mods,
        "effective_attack":HSC.effective_attack_stats(actor,stats),
        "effective_defense":HSC.effective_defense_stats(actor,stats),
        "effective_poison":HSC.effective_poison_factor(actor),
        "effective_heal":HSC.effective_heal_factor(actor),
        "blade_guard_reflection":Blade.guard_reflection_profile(actor,0.0).get("ratio",0.0),
        "sword_guard_reflection":Sword.guard_reflection_profile(actor,0.0).get("ratio",0.0),
        "fatal_save_charges":int(skill.get("passive_modifiers",{}).get("fatal_save_charges",0)),
        "summon_modifier_profile":{}}
    var passive_modifiers: Dictionary = skill.get("passive_modifiers",{})
    var summon_profile: Dictionary = {}
    for key in passive_modifiers.keys():
        summon_profile[str(key)] = Summon._owner_modifier(actor,str(key))
    result["summon_modifier_profile"] = summon_profile
    var battle := MapBattle.new(760901+skill_id.length())
    battle.now = 0.0
    var fatal_actor: Dictionary = actor.duplicate(true)
    var prevented := Divine.prevent_lethal(battle,fatal_actor)
    result["prevent_lethal"] = prevented
    result["fatal_save_ready_at"] = float(fatal_actor.get("v63_fatal_save_ready_at",-1.0))
    var defender: Dictionary = actor.duplicate(true)
    defender["id"] = "p2_defender"
    defender["side"] = "disciple"
    var attacker := _combat_actor("p2_attacker","monster")
    battle.actors[str(defender.id)] = defender
    battle.actors[str(attacker.id)] = attacker
    Divine.reflect_committed(battle,defender,attacker,10.0,"basic")
    result["reflection_attacker_hp"] = float(attacker.get("hp",0.0))
    return result

func _combat_actor(actor_id: String, side: String) -> Dictionary:
    return {"id":actor_id,"side":side,"hp":200.0,"max_hp":200.0,"stats":{"attack":100.0,
        "defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,
        "crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":{"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
            "lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0},
        "status_effects":{},"context_sources":[],"v63_combat_enabled":true,"v63_combat_clock":-1.0}

func _finish() -> void:
    if _failures > 0:
        print("V63_P2_RUNTIME_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures)+
            " rows="+str(_p2_rows)+" equal="+str(_equal_rows)+" existing_differences="+str(_different_rows)+
            " missing="+str(_missing_rows)+" different_ids="+JSON.stringify(_different_ids))
        quit(1)
        return
    print("V63_P2_RUNTIME_RESULT PASS checks="+str(_checks)+" rows="+str(_p2_rows)+
        " equal="+str(_equal_rows)+" existing_differences="+str(_different_rows)+
        " missing="+str(_missing_rows)+" design_intent=OWNER_APPROVAL_PENDING")
    quit(0)
