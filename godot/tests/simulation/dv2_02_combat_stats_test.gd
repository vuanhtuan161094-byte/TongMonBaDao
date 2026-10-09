extends SceneTree

func _init() -> void:
    call_deferred("_run")

func _close(value: float, target: float, tolerance: float = 0.00001) -> bool:
    return absf(value-target) <= tolerance

func _source(name: String, channel: String, mode: String, value: float) -> Dictionary:
    return {"source_id":name,"channel":channel,"mode":mode,"value":value}

func _run() -> void:
    var base := CombatStatsV2.derive(1,1,1,1,0.0)
    if not bool(base.get("ok",false)):
        _fail("1.1 base stat derivation failed.")
        return
    var stats: Dictionary = base["stats"]
    if stats.size() != 16:
        _fail("Combat V2 registry must contain exactly sixteen headline stats.")
        return
    if not _close(float(stats["max_hp"]),190.0) or not _close(float(stats["attack"]),23.0) or not _close(float(stats["defense"]),19.0):
        _fail("Locked base MaxHP/Attack/Defense differs from 190/23/19.")
        return
    if not _close(float(stats["crit_chance"]),0.05) or not _close(float(stats["crit_damage"]),1.50):
        _fail("Default crit chance or 1.50x multiplier failed.")
        return
    if not _close(float(stats["move_speed"]),1.0) or not _close(float(stats["attack_speed"]),0.0):
        _fail("Realtime speed baseline is inconsistent.")
        return
    if base["resistances"].size() != 10:
        _fail("Element resistance map lacks ten registered keys.")
        return
    if not _close(float(stats["lifesteal"]),0.0) or not _close(float(stats["lifesteal_reduction"]),0.0):
        _fail("New Lifesteal and Anti-Lifesteal base rates must both be zero.")
        return

    var inputs: Array = [
        _source("potential_test_weapon","attack","flat",100.0),
        _source("attack_percent","attack","percent_add",0.10),
        _source("temporary_crit","crit_chance","percentage_points",0.15),
        _source("lightning_crit","crit_damage","multiplier_add",0.50),
        _source("enemy_crit_guard","crit_resistance","percentage_points",0.10),
        _source("penetrating_strike","defense_penetration","percentage_points",0.20),
        _source("status_accuracy","effect_hit","percentage_points",0.25),
        _source("status_defense","effect_resistance","percentage_points",0.15),
        _source("boots","move_speed","percent_add",0.08),
        _source("blade_speed","attack_speed","percent_add",1.0),
        _source("spell_tempo","cast_speed","percent_add",0.50),
        _source("cooldown_recovery","cooldown_recovery","percent_add",1.0),
        _source("guard_a","damage_reduction","remaining_reduction",0.20),
        _source("guard_b","damage_reduction","remaining_reduction",0.10),
        _source("fire_root","elemental_resistance/fire","remaining_reduction",0.30),
        _source("fire_gear","elemental_resistance/fire","remaining_reduction",0.20),
        _source("bloodthirst","lifesteal","percentage_points",0.20),
        _source("anti_bloodthirst","lifesteal_reduction","percentage_points",0.05),
        _source("forbidden_dormant_trait","attack","percent_add",0.80)
    ]
    inputs[inputs.size()-1]["enabled"] = false
    var character := CombatStatsV2.derive(1,1,1,1,1000.0,inputs)
    if not bool(character.get("ok",false)):
        _fail("Typed multi-source derivation failed.")
        return
    var st: Dictionary = character["stats"]
    if not _close(float(st["attack"]),147.95):
        _fail("Potential incorrectly multiplied unrelated flat equipment, or dormant Trait applied.")
        return
    if not _close(float(st["max_hp"]),285.0) or not _close(float(st["defense"]),28.50):
        _fail("Tiềm Lực +0.05%/point not retroactively applied to RealmBody core.")
        return
    if not _close(float(st["crit_chance"]),0.20) or not _close(float(st["crit_damage"]),2.0):
        _fail("Crit percentage-points/multiplier composition failed.")
        return
    if not _close(float(st["crit_resistance"]),0.10) or not _close(float(st["defense_penetration"]),0.20):
        _fail("Resistance or penetration was not stored as percentage points.")
        return
    if not _close(float(st["damage_reduction"]),0.28):
        _fail("Independent Damage Reduction sources incorrectly stacked additively.")
        return
    if not _close(float(st["lifesteal"]),0.20) or not _close(float(st["lifesteal_reduction"]),0.05):
        _fail("Life steal/Anti-Lifesteal are percentage-point sources, not damage multipliers.")
        return
    if not _close(float(character["resistances"]["fire"]),0.44):
        _fail("Fire elemental resistance sources incorrectly stacked additively.")
        return
    if not _close(float(st["move_speed"]),1.08):
        _fail("Move speed was silently treated as attack speed.")
        return
    if not _close(CombatStatsV2.effective_interval(10.0,float(st["cooldown_recovery"])),5.0):
        _fail("+100% cooldown recovery did not halve ordinary cooldown.")
        return
    if not _close(CombatStatsV2.effective_interval(1.5,float(st["cast_speed"])),1.0):
        _fail("Cast Speed 50% did not convert 1.5 seconds to 1.0 seconds.")
        return
    if not _close(CombatStatsV2.effective_interval(1.0,float(st["attack_speed"])),0.5):
        _fail("Attack Speed +100% did not double the basic frequency.")
        return
    if not _close(CombatStatsV2.effective_crit_chance(st,{"crit_resistance":0.1}),0.10):
        _fail("Crit Resistance must subtract points, not multiply damage.")
        return
    if not _close(CombatStatsV2.ordinary_status_chance(0.60,st,{"effect_resistance":0.15}),0.70):
        _fail("Base status chance + effect hit - effect resistance is incorrect.")
        return
    if not _close(CombatStatsV2.ordinary_status_chance(0.60,st,{},true),1.0):
        _fail("Guaranteed status should not roll the ordinary accuracy check.")
        return
    if not _close(CombatStatsV2.ordinary_status_chance(0.60,st,{},true,true),0.0):
        _fail("Explicit immunity must override guaranteed status.")
        return
    if not _close(CombatStatsV2.rescale_current_hp(25.0,100.0,200.0),50.0):
        _fail("Max HP changes did not preserve current HP ratio.")
        return
    if CombatStatsV2.effective_interval(2.0,-1.0) >= 0.0:
        _fail("-100% invalid rate silently became a zero/negative effective interval.")
        return

    var hit := CombatStatsV2.resolve_direct_hit(stats,{"defense":19.0,"damage_reduction":0.0},{},1.0,false)
    if not bool(hit.get("ok",false)) or not _close(float(hit["damage"]),23.0*46.0/65.0):
        _fail("Locked Defense formula K=2*ATK was not used.")
        return
    var penetrating_hit := CombatStatsV2.resolve_direct_hit(
        {"attack":23.0,"defense_penetration":0.20}, {"defense":19.0}, {}, 1.0, false
    )
    if float(penetrating_hit.get("damage",0.0)) <= float(hit["damage"]):
        _fail("20% penetration did not reduce the remaining Defense.")
        return
    var crit_hit := CombatStatsV2.resolve_direct_hit(
        {"attack":23.0,"crit_damage":2.0}, {"defense":19.0}, {}, 1.0, true
    )
    if not _close(float(crit_hit["damage"]),float(hit["damage"])*2.0):
        _fail("Critical direct hit did not apply the +100% multiplier.")
        return
    var no_crit := CombatStatsV2.resolve_direct_hit(
        {"attack":23.0,"crit_damage":2.0}, {"defense":19.0}, {}, 1.0, true, "", 1.0, false
    )
    if not _close(float(no_crit["damage"]),float(hit["damage"])):
        _fail("A non-crit eligible packet was incorrectly critically amplified.")
        return
    var element_hit := CombatStatsV2.resolve_direct_hit(
        st,{"defense":0.0,"damage_reduction":0.28},{"fire":0.44},
        1.0,false,"fire"
    )
    if not _close(float(element_hit["damage"]),float(st["attack"])*0.56*0.72):
        _fail("Element resistance and DR should reduce remaining damage independently.")
        return

    var reverse: Array = inputs.duplicate(true)
    reverse.reverse()
    if CombatStatsV2.derive(1,1,1,1,1000.0,reverse) != character:
        _fail("Stat outcome or source breakdown depends on input source order.")
        return
    if bool(CombatStatsV2.derive(1,1,1,1,0.0,[_source("bad","magic_attack","flat",10)]).get("ok",true)):
        _fail("Unknown Combat Stats V2 channel was silently accepted.")
        return
    if bool(CombatStatsV2.derive(1,1,1,1,0.0,[_source("a","attack","flat",10),_source("a","attack","flat",10)]).get("ok",true)):
        _fail("Duplicate source/channel could be counted twice.")
        return
    if bool(CombatStatsV2.derive(1,1,1,1,0.0,[_source("a","elemental_resistance/fire","remaining_reduction",1.0)]).get("ok",true)):
        _fail("Ordinary 100% resistance silently granted full immunity.")
        return

    # New user requirement: 20% Lifesteal minus 5 percentage-point counter
    # = 15% of ACTUAL HP damage after mitigation and overkill accounting.
    var lifesteal_attacker: Dictionary = {"attack":100.0,"lifesteal":0.20}
    var lifesteal_target: Dictionary = {"defense":0.0,"lifesteal_reduction":0.05}
    var source_hit := CombatStatsV2.resolve_direct_hit(
        lifesteal_attacker,lifesteal_target,{},1.0,false
    )
    var lifesteal := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,lifesteal_target,60.0,120.0,200.0
    )
    if not bool(lifesteal.get("ok",false)) or not _close(float(lifesteal["actual_damage"]),100.0):
        _fail("Eligible direct damage was not committed against current target HP.")
        return
    if not _close(float(lifesteal["effective_lifesteal"]),0.15) or not _close(float(lifesteal["lifesteal_heal"]),15.0):
        _fail("20% lifesteal minus 5pp anti-lifesteal on 100 damage must heal 15.")
        return
    if not _close(float(lifesteal["attacker_hp_after"]),75.0) or not _close(float(lifesteal["target_hp_after"]),100.0):
        _fail("Lifesteal did not update HP results exactly once.")
        return

    var overkill := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,lifesteal_target,60.0,120.0,20.0
    )
    if not _close(float(overkill["actual_damage"]),20.0) or not _close(float(overkill["lifesteal_heal"]),3.0):
        _fail("Lifesteal was calculated from overkill instead of actual lost target HP.")
        return
    var at_max_hp := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,lifesteal_target,120.0,120.0,200.0
    )
    if not _close(float(at_max_hp["lifesteal_heal"]),0.0):
        _fail("Lifesteal healed the attacker above Max HP.")
        return
    var limited_heal := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,lifesteal_target,118.0,120.0,200.0
    )
    if not _close(float(limited_heal["lifesteal_heal"]),2.0):
        _fail("Lifesteal failed to cap healing by missing HP.")
        return
    var fully_countered := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,{"lifesteal_reduction":0.30},60.0,120.0,200.0
    )
    if not _close(float(fully_countered["effective_lifesteal"]),0.0) or not _close(float(fully_countered["lifesteal_heal"]),0.0):
        _fail("Anti-Lifesteal greater than Lifesteal must reduce net healing to zero.")
        return
    if not _close(CombatStatsV2.effective_lifesteal_rate(
        {"lifesteal":1.5},{"lifesteal_reduction":1.2}),0.30):
        _fail("Lifesteal/Anti-Lifesteal should not have an invented 100% growth cap.")
        return
    var ineligible_hit := CombatStatsV2.settle_damage_and_lifesteal(
        source_hit,lifesteal_attacker,lifesteal_target,60.0,120.0,200.0,false
    )
    if not _close(float(ineligible_hit["actual_damage"]),100.0) or not _close(float(ineligible_hit["lifesteal_heal"]),0.0):
        _fail("Ineligible reflection/DoT/proc packet must not heal via lifesteal.")
        return
    var dodged_hp := CombatStatsV2.settle_damage_and_lifesteal(
        {"ok":true,"damage":0.0},lifesteal_attacker,lifesteal_target,60.0,120.0,200.0
    )
    if not _close(float(dodged_hp["lifesteal_heal"]),0.0):
        _fail("Zero damage generated lifesteal healing.")
        return
    if bool(CombatStatsV2.settle_damage_and_lifesteal(
        {"ok":false},lifesteal_attacker,lifesteal_target,60.0,120.0,200.0
    ).get("ok",true)):
        _fail("Rejected damage packet was nevertheless allowed to heal.")
        return
    if bool(CombatStatsV2.derive(1,1,1,1,0.0,[
        _source("wrong_lifesteal_mode","lifesteal","percent_add",0.2)
    ]).get("ok",true)):
        _fail("Lifesteal requires a percentage-points source.")
        return

    # Exercise actual DiscipleState HP mutation through CombatSystem without
    # touching legacy PvE routing. The same hit may not heal/pay twice.
    var live_attacker := DiscipleState.new({"id":"v2_attacker"})
    var live_target := DiscipleState.new({"id":"v2_target"})
    live_attacker.max_hp = 100.0
    live_attacker.hp = 50.0
    live_target.max_hp = 100.0
    live_target.hp = 75.0
    var encounter: Dictionary = {}
    var commit := CombatSystem.new().commit_v2_direct_hit(
        live_attacker,live_target,{"attack":100.0,"lifesteal":0.20},
        {"defense":0.0,"lifesteal_reduction":0.05}, {},
        encounter,"v2_live_hit_1"
    )
    if not bool(commit.get("ok",false)):
        _fail("CombatSystem failed to commit actual V2 HP damage and lifesteal.")
        return
    if not _close(float(commit["actual_damage"]),75.0) or not _close(float(commit["lifesteal_heal"]),11.25):
        _fail("V2 live combat must siphon 15% of the defender's actual 75 HP loss.")
        return
    if not _close(live_attacker.hp,61.25) or not _close(live_target.hp,0.0):
        _fail("CombatSystem did not apply V2 hit to real DiscipleState HP correctly.")
        return
    var duplicate := CombatSystem.new().commit_v2_direct_hit(
        live_attacker,live_target,{"attack":100.0,"lifesteal":0.20},
        {"defense":0.0,"lifesteal_reduction":0.05}, {},
        encounter,"v2_live_hit_1"
    )
    if bool(duplicate.get("ok",true)) or not _close(live_attacker.hp,61.25):
        _fail("Repeated V2 hit_id was permitted to heal or damage twice.")
        return
    var invalid_hit := CombatSystem.new().commit_v2_direct_hit(
        live_attacker,live_attacker,{"attack":100.0,"lifesteal":0.20},
        {"defense":0.0}, {},encounter,"self_hit"
    )
    if bool(invalid_hit.get("ok",true)) or not _close(live_attacker.hp,61.25):
        _fail("Self-directed V2 hit corrupted actual HP.")
        return

    var previous := 0.0
    for realm in range(1,31):
        for floor_index in range(1,11):
            var derived := CombatStatsV2.derive(realm,floor_index,realm,floor_index,0.0)
            if not bool(derived.get("ok",false)) or float(derived["stats"]["attack"]) <= previous:
                _fail("300-floor locked Combat Core has a gap/nonfinite/descending Attack.")
                return
            previous = float(derived["stats"]["attack"])
    print("DV2-02 SIXTEEN STAT CORE + LIFESTEAL + 10 ELEMENTS: PASS")
    quit(0)

func _fail(msg: String) -> void:
    push_error(msg)
    quit(1)
