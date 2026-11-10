extends SceneTree

# VFX-08 presentation-only contracts: no HP, cooldown, Save or gameplay data
# written. The real battle fixture and source skill definitions are loaded.
const LabScene = preload("res://labs/combat_lab/combat_lab.tscn")
const Progress = preload("res://labs/combat_lab/combat_lab_vfx_progression.gd")
const Atlas = preload("res://labs/combat_lab/combat_lab_poison_atlas_v1.gd")
const Spark = preload("res://labs/combat_lab/combat_lab_v4_spell_spark.gd")
const ID := "tmb.skill.poison.doc_cham.active_03.human"
var total := 0
var failures := 0

func _check(condition: bool, message: String) -> void:
    total += 1
    if not condition:
        failures += 1
        push_error("POISON_V4_GROWTH_REACT_FAIL: " + message)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(ID)
    _check(not definition.is_empty(), "canonical Bách Độc Tán Châm exists")
    var stats := {"cast_speed":0.0,"attack_speed":0.0}
    var novice: Dictionary = Progress.profile_for(definition, 1, stats, 0)
    var middle: Dictionary = Progress.profile_for(definition, 6, stats, 0)
    var expert: Dictionary = Progress.profile_for(definition, 12, stats, 0)
    var raid: Dictionary = Progress.profile_for(definition, 12, stats, 36)
    _check(int(novice.decorative_strands) == 5 and
        int(middle.decorative_strands) == 6 and
        int(expert.decorative_strands) == 8,
        "mastery levels 1/6/12 scale only 5/6/8 decorative needles")
    _check(int(raid.decorative_strands) <= 5 and int(raid.lod) == 0,
        "36 simultaneous cues reduce GPU/sparkle work without dropping damage")
    for profile in [novice, middle, expert, raid]:
        _check(int(profile.combat_projectiles) == 1 and
            int(profile.combat_target_limit) == int(definition.target_limit) and
            is_equal_approx(float(profile.combat_radius), float(definition.radius)),
            "mastery decoration NEVER invents gameplay projectiles, hit cap or AoE")
    var haste: Dictionary = Progress.profile_for(definition, 8,
        {"cast_speed":1.4,"attack_speed":1.0}, 4)
    _check(is_equal_approx(float(haste.cast_speed), 1.4) and
        is_equal_approx(float(haste.attack_speed), 1.0),
        "read-only visual profile follows verified effective haste")
    _check(Atlas.clip_duration_ms("hit") > 1500 and
        Atlas.clip_duration_ms("attack") > 1500,
        "original long source animation objectively explains hurt spam")

    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", "doc_cham")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "1")
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "single")
    OS.set_environment("TMB_POISON_V4_PREVIEW", "1")
    OS.set_environment("TMB_POISON_V4_CINEMATIC", "0")
    var lab: Control = LabScene.instantiate()
    root.add_child(lab)
    await process_frame
    lab.call("_set_auto", false)
    var arena: Control = lab.get("arena")
    var battle: MapBattleV2 = lab.get("battle")
    _check(battle != null and battle.active, "real Lab battle setup")
    if battle == null or not battle.active:
        quit(1)
        return
    var monster_id := ""
    for raw_id in battle.actors.keys():
        if str(battle.actors[raw_id].get("side", "")) == "monster":
            monster_id = str(raw_id)
            break
    _check(not monster_id.is_empty(), "real canonical monster")
    var current := float(battle.now)
    arena.set_visual_time(current)
    arena._set_pose("lab_disciple_01", "walk", 500, current)
    var walk_before := str(arena.pose_for_actor("lab_disciple_01"))
    arena.consume_events([{
        "type":"hit", "attacker":monster_id, "target":"lab_disciple_01",
        "kind":"basic", "damage":31.0, "time":current
    }])
    _check(walk_before == "walk" and
        str(arena.pose_for_actor("lab_disciple_01")) == "walk",
        "normal positive hit does not interrupt a moving recipient")
    arena.consume_events([{
        "type":"status_tick", "caster":monster_id, "target":"lab_disciple_01",
        "status":"poison", "damage":5.0, "time":current
    }])
    _check(str(arena.pose_for_actor("lab_disciple_01")) == "walk",
        "DoT must not trigger a full-body hurt clip")
    arena.consume_events([{
        "type":"status_applied", "caster":monster_id, "target":"lab_disciple_01",
        "status":"stun", "time":current
    }])
    _check(str(arena.pose_for_actor("lab_disciple_01")) == "hit",
        "authoritative crowd-control event may animate a brief hurt")
    arena.set_visual_time(current + 0.35)
    _check(str(arena.pose_for_actor("lab_disciple_01")) != "hit",
        "CC visual response is never a multi-second animation lock")
    arena.consume_events([{
        "type":"skill_cast", "actor_id":"lab_disciple_01",
        "target":monster_id, "skill_id":ID, "time":current + 0.35,
        "release_at":current + 2.25
    }])
    var state: Dictionary = arena.actor_states.get("lab_disciple_01", {})
    var windup := float(state.get("until", 0.0)) - float(state.get("started", 0.0))
    _check(windup < 0.8 and windup > 0.20,
        "cast wind-up excludes projectile flight to avoid frozen caster")
    var realtime_attack := int(arena.call("_combat_pose_ms", "lab_disciple_01", true))
    _check(realtime_attack < Atlas.clip_duration_ms("attack") and realtime_attack <= 540,
        "attack clip remaps to actual attack cadence, not 2.6s source")
    _check(Spark.active_count(arena) == 0,
        "additive GPU spark does not spawn in ordinary Lab or synthetic DoT")
    lab.queue_free()
    print("POISON_V4_GROWTH_REACTION_RESULT=" +
        ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(total) + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
