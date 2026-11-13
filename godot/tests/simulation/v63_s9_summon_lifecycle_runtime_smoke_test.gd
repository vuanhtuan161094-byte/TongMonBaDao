extends SceneTree

# Runtime-only S9 verification. Deliberately excludes viewport/VFX capture,
# which is exercised by v63_s9_summon_skill_test.gd and currently hangs headless.
const Summon = preload("res://src/simulation/combat/v63_summon_skill_combat_system.gd")
const Snapshot = preload("res://src/simulation/combat/map_battle_snapshot_v2.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const MapBattle = preload("res://src/simulation/combat/map_battle_v2.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    _run()

func _expect(valid: bool, label: String) -> void:
    _checks += 1
    if not valid:
        _failures += 1
        push_error("V63_S9_RUNTIME_FAIL "+label)

func _run() -> void:
    var loaded := Summon.load_catalogue()
    _expect(bool(loaded.get("ok",false)),"summon catalogue validates while feature gates remain OFF")
    _expect(Gates.all_disabled() and not Gates.is_enabled("summon_skill_combat"),"production V6.3/Summon gates remain OFF")
    for branch in ["kiem_linh","linh_thu","khoi_loi_ho_phap"]:
        _exercise_branch(branch)
    if _failures > 0:
        print("V63_S9_RUNTIME_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
        quit(1)
        return
    print("V63_S9_RUNTIME_RESULT PASS checks="+str(_checks)+" branches=3 cast=CombatV2 summon_actor=real auto_attack=CombatV2 snapshot=cold gate=OFF viewport_capture=PENDING")
    quit(0)

func _exercise_branch(branch: String) -> void:
    var skill_id := "tmb.skill.summon.%s.active_01.human" % branch
    var battle := MapBattle.new(91009+branch.length())
    battle.encounter_id = "s9_runtime_"+branch
    battle.active = true
    battle.outcome = "fighting"
    var owner := _actor("owner_"+branch,"disciple",Vector2(2,3))
    owner["v63_summon_combat_enabled"] = true # isolated candidate preview, not a production gate
    owner["v63_skill_loadout"] = [skill_id]
    battle.actors[str(owner.get("id",""))] = owner
    var enemy := _actor("enemy_"+branch,"monster",Vector2(5,3))
    enemy["hp"] = 10000.0
    enemy["max_hp"] = 10000.0
    enemy["stats"]["max_hp"] = 10000.0
    battle.actors[str(enemy.get("id",""))] = enemy
    _expect(not Summon.can_cast(_actor("default_gate_"+branch,"disciple",Vector2.ZERO),skill_id),
        branch+" cannot cast with the ordinary default-off actor")
    battle.step()
    var pending: Dictionary = owner.get("v63_pending_cast",{})
    _expect(not pending.is_empty(),branch+" starts from actual MapBattle AI")
    if pending.is_empty():
        return
    battle.now = float(pending.get("ready",battle.now))
    battle._release_casts()
    var summon: Dictionary = {}
    for actor in battle.actors.values():
        if bool(actor.get("is_v63_summon",false)) and str(actor.get("summon_owner_id","")) == str(owner.get("id","")):
            summon = actor
            break
    _expect(not summon.is_empty(),branch+" release creates one real bounded summon actor")
    if summon.is_empty():
        return
    _expect(float(summon.get("hp",0.0)) > 0.0 and float(summon.get("summon_expires_at",0.0)) > battle.now,
        branch+" summon has live HP and finite expiry")
    _expect(Summon._living_summons_for_owner(battle,str(owner.get("id",""))) == 1,
        branch+" per-owner live actor cap counts one summon")
    var save_result: Dictionary = Snapshot.save(battle)
    var load_result: Dictionary = Snapshot.load(save_result)
    _expect(bool(load_result.get("ok",false)),branch+" cold snapshot loads: "+str(load_result.get("reason","")))
    if bool(load_result.get("ok",false)):
        var restored: MapBattle = load_result.get("battle")
        var restored_count := 0
        for actor in restored.actors.values():
            if bool(actor.get("is_v63_summon",false)):
                restored_count += 1
                _expect(str(actor.get("summon_owner_id","")) == str(owner.get("id",""))
                    and is_equal_approx(float(actor.get("summon_expires_at",0.0)),float(summon.get("summon_expires_at",0.0))),
                    branch+" snapshot preserves owner and finite expiry")
        _expect(restored_count == 1,branch+" snapshot preserves exactly one summon")
    var hp_before := float(enemy.get("hp",0.0))
    for _tick in range(12):
        battle.step()
        if float(enemy.get("hp",0.0)) < hp_before:
            break
    _expect(float(enemy.get("hp",0.0)) < hp_before,branch+" autonomous summon routes an attack through Combat V2")
    var attack_found := false
    for event in battle.events:
        if str(event.get("type","")) == "v63_summon_attack" and str(event.get("owner_id","")) == str(owner.get("id","")) and str(event.get("skill_id","")) == skill_id:
            attack_found = true
    _expect(attack_found,branch+" emits an owner-attributed real summon attack receipt")

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
        "lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
    return {"id":actor_id,"side":side,"party_id":"s9_party_"+side,"role":"ranged","position":position,
        "hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
        "stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
            "crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,
        "v63_summon_combat_enabled":false,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_basic":0.0,"next_skill":0.0,"basic_ratio":1.0,"basic_interval":1.6,
        "guard_until":-1.0,"learned_guard_factor":1.0,"learned_guard_until":-1.0,"hunt_policy":"auto",
        "hunt_after_move":"auto","hunt_radius":8.0,"home_position":position,"move_order_position":position,
        "move_order_active":false,"race_id":"yeu_thu" if side == "monster" else ""}
