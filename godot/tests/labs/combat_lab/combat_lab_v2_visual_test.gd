extends SceneTree

const ArenaScript = preload("res://labs/combat_lab/combat_lab_arena.gd")
const RigScript = preload("res://labs/combat_lab/combat_lab_actor_rig_v2.gd")
const VfxScript = preload("res://labs/combat_lab/combat_lab_vfx_v2.gd")

var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, description: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("COMBAT_LAB_V2_VISUAL_FAIL: " + description)

func _disciple(actor_id: String) -> Dictionary:
    var core: Dictionary = CombatStatsV2.derive(11, 1, 10, 1, 0.0)
    var stats: Dictionary = core.get("stats", {}).duplicate(true)
    stats["max_hp"] = 20000.0
    stats["attack"] = 200.0
    return {
        "id":actor_id, "party_id":"lab_v2_test", "role":"frontline",
        "position":Vector2(10.0, 10.0), "stats":stats,
        "hp":20000.0, "max_hp":20000.0,
        "resistances":core.get("resistances", {}),
        "basic_ratio":0.1, "basic_interval":90.0
    }

func _monster() -> Dictionary:
    var row: Dictionary = MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "lab_v2_dummy")
    row["position"] = Vector2(12.0, 10.0)
    return row

func _run() -> void:
    for pose in ["idle", "walk", "attack", "cast", "hit", "death"]:
        _check(RigScript.valid_pose(pose), "pose must be supported: " + pose)
    _check(not RigScript.valid_pose("teleport"), "unimplemented pose must be rejected")
    _check(VfxScript.school_color("bow") != VfxScript.school_color("fist"), "Cung and Quyền signatures differ")
    _check(VfxScript.school_color("fist") != VfxScript.school_color("poison"), "Quyền and Độc signatures differ")
    _check(VfxScript.MAX_PARTICLES_PER_CUE <= 12, "bounded VFX budget")
    _check(is_equal_approx(VfxScript.projectile_progress(0.0), 0.0)
        and is_equal_approx(VfxScript.projectile_progress(0.5), 0.5)
        and is_equal_approx(VfxScript.projectile_progress(1.0), 1.0),
        "projectile reaches its target exactly at the authoritative impact time")
    var battle := MapBattleV2.new(1720702)
    var ready := battle.setup("lab_v2_visual", [_disciple("test_archer")], [_monster()], false)
    if not bool(ready.get("ok", false)):
        _check(false, "canonical battle fixture setup: " + str(ready))
        quit(1)
        return
    var arena := ArenaScript.new()
    get_root().add_child(arena)
    arena.set_battle(battle, "bow")
    var initial_hp := float(battle.actors.lab_v2_dummy.hp)
    var initial_count := battle.events.size()
    var cast_rows: Array[Dictionary] = [
        {"type":"skill_cast", "caster":"test_archer", "target":"lab_v2_dummy",
            "skill_id":"tmb.skill.bow.liep_anh.active_01.human", "time":0.0, "release_at":0.8},
    ]
    arena.consume_events(cast_rows)
    _check(arena.pose_for_actor("test_archer") == "cast", "authored skill cast cues the animated cast pose")
    var scheduled_projectiles := 0
    var launch_at := -1.0
    var impact_at := -1.0
    var cast_origin_ok := false
    var projectile_endpoint_ok := false
    for cue in arena.cues:
        if str(cue.get("kind", "")) == "cast":
            cast_origin_ok = cast_origin_ok or cue.get("position", Vector2.ZERO) == battle.actors["test_archer"].position
        if str(cue.get("kind", "")) == "projectile":
            projectile_endpoint_ok = projectile_endpoint_ok or cue.get("position", Vector2.ZERO) == battle.actors["lab_v2_dummy"].position
            scheduled_projectiles += 1
            launch_at = float(cue.get("launch_at", -1.0))
            impact_at = float(cue.get("impact_at", -1.0))
    _check(cast_origin_ok and projectile_endpoint_ok,
        "cast aura anchors to caster; projectile endpoint anchors to target")
    _check(scheduled_projectiles == 1 and launch_at > 0.0 and impact_at > launch_at,
        "skill_cast schedules one real projectile AFTER wind-up and BEFORE impact")
    _check(is_equal_approx(impact_at, 0.8), "projectile timing ends at canonical cast deadline")
    var release_rows: Array[Dictionary] = [
        {"type":"skill_release", "caster":"test_archer", "target":"lab_v2_dummy",
            "skill_id":"tmb.skill.bow.liep_anh.active_01.human", "time":0.8},
    ]
    arena.consume_events(release_rows)
    _check(arena.pose_for_actor("test_archer") == "attack", "committed skill release cues attack")
    var release_projectiles := 0
    for cue in arena.cues:
        if str(cue.get("kind", "")) == "projectile":
            release_projectiles += 1
    _check(release_projectiles == 1, "skill_release does not spawn a second post-damage projectile")
    var hit_rows: Array[Dictionary] = [
        {"type":"hit", "attacker":"test_archer", "target":"lab_v2_dummy",
            "kind":"v63_skill", "damage":50.0, "critical":true, "lifesteal":5.0},
        {"type":"v63_skill_hit", "caster":"test_archer", "target":"lab_v2_dummy",
            "skill_id":"tmb.skill.bow.liep_anh.active_01.human", "damage":50.0}
    ]
    arena.consume_events(hit_rows)
    _check(arena.pose_for_actor("lab_v2_dummy") != "hit",
        "ordinary damage must show committed impact without interrupting locomotion")
    var impacts := 0
    var heals := 0
    for cue in arena.cues:
        if str(cue.get("kind", "")) == "impact": impacts += 1
        elif str(cue.get("kind", "")) == "heal": heals += 1
    _check(impacts == 1 and heals == 1, "one committed hit renders once despite semantic echo")
    _check(float(battle.actors.lab_v2_dummy.hp) == initial_hp, "VFX and rig do not alter monster HP")
    _check(battle.events.size() == initial_count, "presentation does not emit authoritative events")
    var warn_rows: Array[Dictionary] = [{"type":"telegraph", "caster":"lab_v2_dummy", "center":Vector2(11,10),
        "radius":3.0, "time":1.0}]
    arena.consume_events(warn_rows)
    var has_warning := false
    for cue in arena.cues:
        if str(cue.get("kind", "")) == "telegraph" and is_equal_approx(float(cue.get("radius", -1.0)), 3.0):
            has_warning = true
    _check(has_warning, "boss telegraph keeps actual canonical area radius")
    var poison_rows: Array[Dictionary] = [
        {"type":"hit", "attacker":"test_archer", "target":"lab_v2_dummy", "kind":"v63_poison", "damage":9.0},
        {"type":"status_tick", "caster":"test_archer", "target":"lab_v2_dummy", "status":"poison", "damage":9.0},
    ]
    var cues_before := arena.cues.size()
    arena.consume_events(poison_rows)
    _check(arena.cues.size() == cues_before + 1, "DoT hit/status tick does not create double VFX")
    # Canonical downed events carry actor_id (not target). Anchor both the
    # death pose and committed death cue to that same actor.
    var downed_rows: Array[Dictionary] = [{"type":"downed", "actor_id":"lab_v2_dummy", "side":"monster"}]
    arena.consume_events(downed_rows)
    var death_cue: Dictionary = arena.cues.back()
    _check(str(death_cue.get("kind", "")) == "death" and
        death_cue.get("position", Vector2.ZERO) == battle.actors["lab_v2_dummy"].position,
        "downed visual cue follows canonical actor_id, not the world center")
    _check(arena.pose_for_actor("lab_v2_dummy") == "death",
        "downed actor_id changes the same actor's presentation pose")
    var many: Array[Dictionary] = []
    for index in range(100):
        many.append({"type":"hit", "attacker":"test_archer", "target":"lab_v2_dummy",
            "kind":"basic", "damage":1.0, "lab_source_index":index})
    arena.consume_events(many)
    _check(arena.cues.size() <= 64, "VFX cue pool remains bounded under 100 hits")
    _check(float(battle.actors.lab_v2_dummy.hp) == initial_hp,
        "100 display-only hits never settle damage in MapBattleV2")
    arena.set_battle(battle, "poison")
    _check(arena.cues.is_empty() and arena.actor_states.is_empty(),
        "reset clears visual state and old VFX")
    # Geometry oracle: zoom must keep the arena's world center fixed and
    # enlarge distances monotonically without changing combat world positions.
    arena.size = Vector2(680.0, 440.0)
    var center_world := Vector2(18.0, 10.0)
    var center_expected := arena.size * 0.5
    var right_world := Vector2(20.0, 10.0)
    var prior_distance := 0.0
    var original_world_pos: Vector2 = battle.actors["test_archer"].position
    for scale_factor in [1.0, 2.0, 4.0, 6.0]:
        arena.set_zoom(scale_factor)
        var projected_center: Vector2 = arena._world_to_local(center_world)
        var projected_right: Vector2 = arena._world_to_local(right_world)
        var projected_distance := projected_center.distance_to(projected_right)
        _check(projected_center.distance_to(center_expected) < 0.01,
            "zoom %.0fx keeps the world-center foot anchor fixed" % scale_factor)
        _check(projected_distance > prior_distance,
            "zoom %.0fx scales actor separation monotonically" % scale_factor)
        prior_distance = projected_distance
    _check(battle.actors["test_archer"].position == original_world_pos,
        "1-6x visual zoom never moves the canonical actor")
    _check(V63FeatureGates.all_disabled(), "preview rendering does not enable production skill gates")
    arena.queue_free()
    print("COMBAT_LAB_V2_VISUAL_%s: %d checks, %d failures; PENDING Godot visual/physical mouse acceptance" %
        ["PASS" if failures == 0 else "FAIL", checks, failures])
    quit(0 if failures == 0 else 1)
