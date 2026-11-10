extends SceneTree

# Presentation-only finite regression for BOTH production PvE viewers.
# Synthetic visual-event envelope, genuine canonical skill/stat authority;
# no gameplay HP change, Save, movement order, cast or damage injection.
const Iso := preload("res://src/presentation/p3/sect_isometric_world_v1.gd")
const Jx := preload("res://src/presentation/p3/pve_jx_continuous_world_view_v1.gd")
var checks := 0
var failures := 0

func _check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("PVE_VFX08_REACTION_FAIL " + label)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var battle := MapBattleV2.new(8220)
    battle.now = 2.0
    battle.actors = {
        "real_disciple":{"id":"real_disciple","side":"disciple","role":"mage",
            "hp":1000.0,"position":Vector2(4.0,3.0),
            "stats":{"attack_speed":1.0,"cast_speed":1.0}},
        "real_monster":{"id":"real_monster","side":"monster","role":"frontline",
            "hp":1000.0,"position":Vector2(6.0,3.0),
            "stats":{"attack_speed":0.0,"cast_speed":0.0}}
    }
    var iso := Iso.new()
    iso.pve_clock = 2.0
    var basic: Array[Dictionary] = [{
        "type":"hit", "attacker":"real_disciple", "target":"real_monster",
        "kind":"basic", "damage":42.0, "time":2.0}]
    var dot: Array[Dictionary] = [{
        "type":"status_tick", "caster":"real_disciple", "target":"real_monster",
        "status":"poison", "damage":4.0, "time":2.1}]
    iso._apply_pve_actor_events(basic,battle)
    _check(not iso.pve_actor_actions.has("real_monster"),
        "isometric PvE does not issue hurt on normal damage")
    _check(str(iso.pve_actor_actions.get("real_disciple",{}).get("action","")) == "attack",
        "real attacker retains speed-correct attack response")
    var action_window := float(iso.pve_actor_actions["real_disciple"]["until"]) - 2.0
    _check(action_window < 0.3,
        "attack-speed stat produces short motion instead of 850ms lock")
    iso._apply_pve_actor_events(dot,battle)
    _check(not iso.pve_actor_actions.has("real_monster"),
        "isometric PvE ignores poison DoT for full-body hurt")
    var stun: Array[Dictionary] = [{
        "type":"status_applied", "caster":"real_disciple", "target":"real_monster",
        "status":"stun", "time":2.2}]
    iso._apply_pve_actor_events(stun,battle)
    _check(str(iso.pve_actor_actions["real_monster"].get("action","")) == "hit" and
        float(iso.pve_actor_actions["real_monster"]["until"]) <= 2.31,
        "real CC alone may trigger bounded short hurt")
    var cast: Array[Dictionary] = [{
        "type":"skill_cast", "actor_id":"real_disciple",
        "skill_id":"tmb.skill.poison.doc_cham.active_03.human",
        "time":2.0, "release_at":3.7}]
    iso._apply_pve_actor_events(cast,battle)
    var cast_window := float(iso.pve_actor_actions["real_disciple"]["until"]) - 2.0
    _check(cast_window < 0.4 and cast_window > 0.1,
        "production cast pose uses real wind-up/haste, not projectile flight")
    var jx := Jx.new()
    jx.battle = battle
    jx._clock = 2.0
    jx._render_positions["real_monster"] = Vector2(6.0,3.0)
    battle.events = basic.duplicate(true)
    jx._update_actor_visual("real_monster", battle.actors["real_monster"])
    _check(str(jx._actor_visuals.get("real_monster",{}).get("action","")) != "hit",
        "continuous world damage cannot trigger hurt")
    battle.events.append(dot[0])
    jx._update_actor_visual("real_monster", battle.actors["real_monster"])
    _check(str(jx._actor_visuals.get("real_monster",{}).get("action","")) != "hit",
        "continuous world poison ticks cannot trigger hurt")
    battle.events.append(stun[0])
    battle.now = 2.2
    jx._update_actor_visual("real_monster", battle.actors["real_monster"])
    _check(str(jx._actor_visuals.get("real_monster",{}).get("action","")) == "hit",
        "continuous world accepts real CC reaction")
    battle.now = 2.6
    jx._clock = 2.6
    jx._render_positions["real_monster"] = Vector2(5.4,3.0)
    jx._update_actor_visual("real_monster", battle.actors["real_monster"])
    _check(str(jx._actor_visuals.get("real_monster",{}).get("action","")) == "run",
        "continuous PvE resumes running instead of staying in hurt")
    _check(is_equal_approx(float(battle.actors["real_monster"]["hp"]),1000.0),
        "presentation inspection does not change HP")
    iso.queue_free()
    jx.queue_free()
    print("PVE_VFX08_REACTION_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
