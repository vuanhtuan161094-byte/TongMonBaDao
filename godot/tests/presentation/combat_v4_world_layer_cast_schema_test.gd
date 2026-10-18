extends SceneTree

# C4-01 focused test: actual MapBattleV2 learned single-target cast and boss
# telegraph use distinct pending_casts schemas. Rendering never owns combat.
func _init() -> void:
    call_deferred("_run")

func _assert(condition: bool, message: String) -> bool:
    if not condition:
        push_error("C4-01: " + message)
        quit(1)
        return false
    return true

func _run() -> void:
    var stats_result := CombatStatsV2.derive(1,1,1,1,0.0)
    if not _assert(bool(stats_result.get("ok",false)), "Disciple stats unavailable."):
        return
    var disciple_stats: Dictionary = stats_result["stats"]
    var party: Array = [{
        "id":"disciple_00","party_id":"party_0","role":"frontline",
        "position":Vector2(10.0,10.0),"stats":disciple_stats,
        "skill_loadout":["thanh_phong_tram"]
    }]
    var boss := MonsterCatalogueV2.create_actor("hac_lang_vuong",1,1,"boss_00")
    if not _assert(bool(boss.get("ok",false)), "Real boss catalogue actor unavailable."):
        return
    boss["id"] = "boss_00"
    boss["position"] = Vector2(11.0,10.0)
    var battle := MapBattleV2.new(42017)
    if not _assert(bool(battle.setup("c4_01_schema",party,[boss]).get("ok",false)),
            "Cannot initialize a genuine group battle."):
        return

    var disciple: Dictionary = battle.actors["disciple_00"]
    var boss_actor: Dictionary = battle.actors["boss_00"]
    if not _assert(battle._try_learned_damage_skill(disciple,boss_actor),
            "Real learned single-target skill did not start casting."):
        return
    if not _assert(battle.pending_casts.size() == 1,
            "Expected one pending learned single-target cast."):
        return
    var single_cast: Dictionary = battle.pending_casts[0]
    if not _assert(single_cast.has("target_id") and single_cast.has("skill_id") and
            not single_cast.has("center") and not single_cast.has("radius"),
            "Test did not reproduce the missing center/radius schema."):
        return

    var scene := load("res://scenes/p3/map_battle_world_layer_v2.tscn") as PackedScene
    if not _assert(scene != null, "Actual map-world layer scene is missing."):
        return
    var layer := scene.instantiate() as MapBattleWorldLayerV2
    if not _assert(layer != null, "Actual map-world layer script failed to load."):
        return
    get_root().add_child(layer)
    layer.attach_session(battle)
    if not _assert(layer.aoe_warning_geometry().is_empty(),
            "Single-target skill generated a fabricated red AoE zone."):
        return

    battle._begin_telegraphed_aoe(boss_actor,disciple)
    if not _assert(battle.pending_casts.size() == 2 and
            not battle.pending_casts[1].has("target_id"),
            "Real boss telegraph packet was not queued alongside single-target cast."):
        return
    var boss_cast: Dictionary = battle.pending_casts[1]
    var zones := layer.aoe_warning_geometry()
    if not _assert(zones.size() == 1 and
            zones[0]["center"] == boss_cast["center"] and
            is_equal_approx(float(zones[0]["radius"]),float(boss_cast["radius"])),
            "Boss telegraph geometry was lost or changed."):
        return
    var center_pixel := layer.point_on_map(zones[0]["center"])
    if not _assert(layer.logical_from_map(center_pixel).distance_to(boss_cast["center"]) < 0.001,
            "Boss warning does not preserve original map-space center."):
        return

    # Rendering must ignore invalid/incomplete warning packets without
    # converting learned skills into a false AoE or changing the simulator.
    var valid_casts := battle.pending_casts.duplicate(true)
    battle.pending_casts.append({"caster":"boss_00","center":Vector2(10.0,10.0),
        "ready":1.0,"maximum":3}) # no radius
    battle.pending_casts.append({"caster":"boss_00","center":Vector2(10.0,10.0),
        "radius":0.0,"ready":1.0,"maximum":3}) # nonpositive
    battle.pending_casts.append({"caster":"boss_00","center":Vector2(10.0,10.0),
        "radius":"2.8","ready":1.0,"maximum":3}) # invalid type
    battle.pending_casts.append({"caster":"missing","center":Vector2(10.0,10.0),
        "radius":2.8,"ready":1.0,"maximum":3}) # no real caster
    battle.pending_casts.append({"caster":"boss_00","center":Vector2(10.0,10.0),
        "radius":2.8,"ready":-1.0,"maximum":3}) # past due
    battle.pending_casts.append({"caster":"disciple_00","target_id":"boss_00",
        "skill_id":"thanh_phong_tram","center":Vector2(10.0,10.0),
        "radius":2.8,"ready":1.0,"maximum":3}) # never infer AoE from single target
    battle.pending_casts.append("invalid_cast_packet")
    if not _assert(layer.aoe_warning_geometry() == zones,
            "Malformed or learned casts leaked into warning geometry."):
        return
    battle.pending_casts = valid_casts

    var before_time := battle.now
    var before_rng := battle.rng.snapshot_seed_state()
    var before_actors := battle.actors.duplicate(true)
    var before_casts := battle.pending_casts.duplicate(true)
    var before_events := battle.events.duplicate(true)
    layer.refresh_from_authority()
    layer.queue_redraw()
    await process_frame
    await process_frame
    if not _assert(layer.aoe_warning_geometry() == zones and
            battle.now == before_time and
            battle.rng.snapshot_seed_state() == before_rng and
            battle.actors == before_actors and
            battle.pending_casts == before_casts and
            battle.events == before_events,
            "Reading/drawing the overlay mutated combat or lost the warning."):
        return

    # Regression of existing release contract, not a new gameplay rule:
    # learned hit and monster AoE resolve at their real queued times.
    var hp_before := float(disciple["hp"])
    disciple["position"] = Vector2(0.0,0.0) # escape the announced boss area
    battle.now = 1.0
    battle._release_casts()
    var skill_hit := false
    var area_release := false
    for event_value in battle.events:
        var event: Dictionary = event_value
        if str(event.get("type","")) == "skill_hit":
            skill_hit = true
        if str(event.get("type","")) == "area_release":
            area_release = true
            if not _assert(int(event.get("target_count",-1)) <= MapBattleV2.MAX_TARGETS_AOE,
                    "AoE target cap changed unexpectedly."):
                return
    if not _assert(skill_hit and area_release and
            is_equal_approx(float(disciple["hp"]),hp_before) and
            battle.pending_casts.is_empty() and
            layer.aoe_warning_geometry().is_empty(),
            "Existing learned-hit, boss release or dodge semantics regressed."):
        return
    layer.queue_free()
    print("C4-01 WORLD CAST SCHEMA: SINGLE TARGET / BOSS AOE / INVALID CAST / PURE VIEW / RELEASE PASS")
    quit(0)
