extends SceneTree

# S8 Trận: Combat V2 candidate preview only. No source manual, balance, VFX asset,
# renderer, animation, or release gate is approved by this test.
const Formation = preload("res://src/simulation/combat/v63_formation_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Snapshot = preload("res://src/simulation/combat/map_battle_snapshot_v2.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_S8_FORMATION_FAIL " + label)

func _run() -> void:
    var loaded := Formation.load_catalogue()
    _expect(bool(loaded.get("ok", false)), "Trận candidate catalogue validates without enabling: " + str(loaded.get("errors", [])))
    if not bool(loaded.get("ok", false)):
        _finish()
        return
    var catalogue: Dictionary = loaded.data
    var skills: Array = catalogue.get("skills", [])
    var joined := Presentation.load_authoring_sources()
    _expect(bool(joined.get("ok", false)), "S0–S8 source pins and presentation/registry joins: " + str(joined.get("errors", [])))
    if not bool(joined.get("ok", false)):
        _finish()
        return
    var catalogues: Dictionary = joined.catalogues
    var registry: Dictionary = joined.registry
    var manifest: Dictionary = joined.manifest
    _expect(catalogues.has("formation") and manifest.get("entries", {}).size() == 1468,
        "Trận adds 183 presentations to the eight-school candidate ledger")
    _expect(int(registry.get("school_count", 0)) == 11 and int(registry.get("branch_count", 0)) == 33
        and int(registry.get("skill_family_count", 0)) == 385,
        "additive registry reaches eleven indexed schools, thirty-three paths and 385 families")
    _expect(HSC.skill_definitions().size() == 2013 and HSC.branch_definitions().size() == 33,
        "shared Combat V2 definitions include Trận while its gate remains closed")
    _expect(not Gates.is_enabled("formation_skill_combat") and not bool(catalogue.get("enabled", true))
        and str(catalogue.get("release_gate", "")) == "OFF",
        "Trận and V6.3 remain OFF by default")
    var blocked := Formation.can_learn(Formation.skill_definition("tmb.skill.formation.sat_phat_tran.active_01.human"))
    _expect(not bool(blocked.get("ok", true)) and str(blocked.get("reason", "")) == "skill_source_pending",
        "an unverified Trận manual cannot teach a candidate node")

    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var flavors: Dictionary = {}
    var short_texts: Dictionary = {}
    var long_texts: Dictionary = {}
    var branch_counts := {"tu_linh_tran":0, "phong_toa_tran":0, "sat_phat_tran":0}
    var tier_counts := {"human":0, "immortal":0, "divine":0}
    var phases_expected := ["windup", "telegraph", "release", "travel", "impact", "status", "fade"]
    for raw in skills:
        var skill: Dictionary = raw
        var id := str(skill.get("id", ""))
        var entry: Dictionary = manifest.get("entries", {}).get(id, {})
        var brief: Dictionary = entry.get("vfx", {}).get("production_brief", {})
        var phases: Array = brief.get("phases", [])
        var phase_names: Array[String] = []
        for phase in phases:
            phase_names.append(str(phase.get("phase", "")))
            _expect(str(phase.get("production_note", "")).contains("VFX_HOLD_OWNER_PER_SKILL_APPROVAL"),
                "per-skill VFX production hold is visible: " + id)
        _expect(id.begins_with("tmb.skill.formation.") and not ids.has(id)
            and str(skill.get("node_id", "")) == id, "unique Trận runtime ID: " + id)
        _expect(not names.has(str(skill.get("name", ""))) and not str(skill.get("name", "")).is_empty(),
            "unique Hán Việt name: " + id)
        _expect(str(skill.get("source_codex_id", "")).is_empty() and not bool(skill.get("archivable", true))
            and str(skill.get("candidate_status", "")) == "CANDIDATE_GATED_SOURCE_PENDING",
            "missing authentic transmission remains blocked: " + id)
        var short_text := str(entry.get("short_description_vi", ""))
        var long_text := str(entry.get("long_description_vi", ""))
        var flavor := str(entry.get("flavor_vi", ""))
        _expect(short_text.length() <= 110 and not short_text.is_empty() and not long_text.is_empty(),
            "Vietnamese function and detailed explanation are authored: " + id)
        _expect(flavor.length() >= 50 and flavor.length() <= 110 and not flavors.has(flavor),
            "unique xianxia flavor is concise: " + id)
        _expect(not short_texts.has(short_text) and not long_texts.has(long_text),
            "skill descriptions are individual rather than copied: " + id)
        _expect(phase_names == phases_expected and str(brief.get("asset_status", "")) == "NOT_PRESENT"
            and str(brief.get("render_capture_status", "")) == "NOT_CAPTURED"
            and str(brief.get("visual_acceptance_status", "")) == "PENDING"
            and str(brief.get("production_hold", "")) == "VFX_HOLD_OWNER_PER_SKILL_APPROVAL"
            and not brief.has("renderer_path") and not brief.has("art_source"),
            "seven-phase VFX brief is text-only; no unapproved renderer/art claim: " + id)
        var availability: Dictionary = entry.get("availability", {})
        _expect(str(availability.get("status", "")) == "CANDIDATE_GATED_SOURCE_PENDING"
            and str(availability.get("source_codex_id", "")).is_empty()
            and not bool(availability.get("archivable", true)),
            "presentation keeps learning source pending: " + id)
        var tooltip := Presentation.build_mechanics_tooltip(skill)
        _expect(bool(tooltip.get("ok", false)) and not str(tooltip.get("text", "")).is_empty(),
            "tooltip derives exact numbers from catalogue fields: " + id)
        _expect(bool(Presentation.presentation_for(id, manifest, catalogues).get("ok", false)),
            "presentation binds to canonical candidate node: " + id)
        if branch_counts.has(str(skill.get("branch", ""))):
            branch_counts[str(skill.get("branch", ""))] += 1
        tier_counts[str(skill.get("generation", ""))] += 1
        ids[id] = true
        names[str(skill.get("name", ""))] = true
        families[str(skill.get("family_id", ""))] = true
        flavors[flavor] = true
        short_texts[short_text] = true
        long_texts[long_text] = true
    _expect(ids.size() == 183 and names.size() == 183 and families.size() == 35,
        "183 unique nodes/names join exactly 35 families")
    _expect(branch_counts == {"tu_linh_tran":59, "phong_toa_tran":59, "sat_phat_tran":59},
        "Tụ Linh / Phong Tỏa / Sát Phạt each own 59 nodes")
    _expect(tier_counts == {"human":35, "immortal":68, "divine":80},
        "35 Nhân / 68 Tiên / 80 Thần candidate nodes")
    _expect(flavors.size() == 183 and short_texts.size() == 183 and long_texts.size() == 183,
        "all Trận nodes have unique flavor and mechanical prose")

    _exercise_guard_and_slow()
    _exercise_zone_combat_and_snapshot()
    _exercise_mapbattle_gate_copy()
    _finish()

func _exercise_guard_and_slow() -> void:
    var guard_battle := MapBattleV2.new(88301)
    var guardian := _actor("formation_guardian", "disciple", Vector2(3, 3))
    var ally := _actor("formation_guard_ally", "disciple", Vector2(4, 3))
    var foe := _actor("formation_guard_foe", "monster", Vector2(5, 3))
    guardian["party_id"] = "formation_party"
    ally["party_id"] = "formation_party"
    var guard_id := "tmb.skill.formation.tu_linh_tran.active_01.human"
    _enable_preview(guardian, guard_id)
    for actor in [guardian, ally, foe]:
        guard_battle.actors[str(actor.id)] = actor
    _expect(_cast_and_settle(guard_battle, guardian, foe, "Tụ Linh guard"),
        "Tụ Linh guard uses the shared Combat V2 cast path")
    _expect(float(ally.get("learned_guard_until", -1.0)) > guard_battle.now
        and float(ally.get("learned_guard_factor", 1.0)) < 1.0
        and _events(guard_battle, "status_applied", guard_id).size() >= 1,
        "a real same-party ally receives only finite mitigation")

    var slow_battle := MapBattleV2.new(88302)
    var slow_caster := _actor("formation_slow_caster", "disciple", Vector2(2, 3))
    var boss := _actor("formation_slow_boss", "monster", Vector2(5, 3))
    boss["tier"] = "boss"
    var slow_id := "tmb.skill.formation.phong_toa_tran.active_01.human"
    _enable_preview(slow_caster, slow_id)
    slow_battle.actors[slow_caster.id] = slow_caster
    slow_battle.actors[boss.id] = boss
    var hp_before := float(boss.hp)
    _expect(_cast_and_settle(slow_battle, slow_caster, boss, "Phong Tỏa slow"),
        "Phong Tỏa slow uses the shared Combat V2 cast path")
    var slow: Dictionary = boss.get("status_effects", {}).get("slow", {})
    _expect(float(boss.hp) < hp_before and not slow.is_empty()
        and float(slow.get("movement_factor", 1.0)) > float(Formation.skill_definition(slow_id).get("slow_movement_factor", 1.0))
        and _events(slow_battle, "v63_formation_slow_applied", slow_id).size() == 1,
        "slow follows a real hit and Boss resistance reduces strength without hard CC")

func _exercise_zone_combat_and_snapshot() -> void:
    var battle := MapBattleV2.new(88303)
    var caster := _actor("formation_zone_caster", "disciple", Vector2(2, 3))
    caster["party_id"] = "formation_zone_party"
    var targets: Array[Dictionary] = []
    for index in range(4):
        targets.append(_actor("formation_zone_target_%d" % index, "monster", Vector2(4.0 + float(index) * 0.1, 3)))
    var outside := _actor("formation_zone_outside", "monster", Vector2(6, 3))
    battle.actors[caster.id] = caster
    for target in targets:
        battle.actors[str(target.id)] = target
    battle.actors[outside.id] = outside
    battle.encounter_id = "formation_zone_snapshot"
    battle.active = true
    battle.outcome = "fighting"
    var zone_id := "tmb.skill.formation.sat_phat_tran.active_01.human"
    _enable_preview(caster, zone_id)
    var hp_before: Dictionary = {}
    for target in targets:
        hp_before[str(target.id)] = float(target.hp)
    var outside_hp := float(outside.hp)
    _expect(_cast_and_settle(battle, caster, targets[0], "Sát Phạt zone"),
        "Sát Phạt zone enters shared Combat V2 cast")
    _expect(targets[0].hp == hp_before[str(targets[0].id)]
        and _events(battle, "v63_formation_zone_created", zone_id).size() == 1,
        "zone is created at cast release and causes no immediate hidden damage")
    var zones: Array = caster.get("v63_formation_zones", [])
    _expect(zones.size() == 1 and zones[0] is Dictionary
        and zones[0].has("center_x") and zones[0].has("center_y")
        and not zones[0].has("center"),
        "active zone state is bounded and stores JSON-safe coordinates for snapshots")
    battle.now += float(zones[0].get("tick_interval", 1.0))
    Formation.process_zones(battle)
    var hp_after_first_tick := float(targets[0].hp) + float(targets[1].hp) + float(targets[2].hp) + float(targets[3].hp)
    var tick_events := _events(battle, "v63_formation_zone_tick", zone_id)
    var direct_hit_ids: Array[String] = []
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("attacker", "")) == str(caster.id) and str(event.get("kind", "")) == "v63_skill":
            direct_hit_ids.append(str(event.get("target", "")))
    _expect(tick_events.size() == 1 and tick_events[0].get("target_ids", []).size() <= 3
        and direct_hit_ids == tick_events[0].get("target_ids", [])
        and not direct_hit_ids.is_empty() and not is_equal_approx(hp_after_first_tick, 800.0),
        "zone tick uses matching real Combat V2 hit receipts; events=%d targets=%s hits=%s zone=%s now=%s hp=%s" % [tick_events.size(), str(tick_events[0].get("target_ids", []) if not tick_events.is_empty() else []), str(direct_hit_ids), str(zones[0]), str(battle.now), str(hp_after_first_tick)])
    _expect(is_equal_approx(float(outside.hp), outside_hp),
        "enemy outside radius takes no zone damage")
    var total_after_tick := hp_after_first_tick
    Formation.process_zones(battle)
    var total_after_duplicate_call := float(targets[0].hp) + float(targets[1].hp) + float(targets[2].hp) + float(targets[3].hp)
    _expect(_events(battle, "v63_formation_zone_tick", zone_id).size() == 1
        and is_equal_approx(total_after_tick, total_after_duplicate_call),
        "same-clock status polling cannot duplicate a scheduled zone tick")

    var saved := Snapshot.save(battle)
    var restored := Snapshot.load(saved)
    _expect(bool(restored.get("ok", false)), "cold battle snapshot round-trip succeeds: " + str(restored.get("reason", "")))
    if bool(restored.get("ok", false)):
        var restored_battle: MapBattleV2 = restored.get("battle")
        var restored_owner: Dictionary = restored_battle.actors.get("formation_zone_caster", {})
        var restored_zones: Array = restored_owner.get("v63_formation_zones", [])
        _expect(restored_zones.size() == 1 and is_equal_approx(float(restored_zones[0].get("center_x", NAN)), float(zones[0].get("center_x", 0.0)))
            and is_equal_approx(float(restored_zones[0].get("next_tick", NAN)), float(zones[0].get("next_tick", 0.0))),
            "cold snapshot preserves owner, anchor, timer and pending formation zone without object/vector serialization")
        restored_battle.now = float(restored_zones[0].get("next_tick", restored_battle.now))
        Formation.process_zones(restored_battle)
        _expect(_events(restored_battle, "v63_formation_zone_tick", zone_id).size() == 2,
            "restored finite zone resumes its next Combat V2 tick")
        var expiry := float(restored_zones[0].get("expires_at", restored_battle.now))
        restored_battle.now = expiry
        Formation.process_zones(restored_battle)
        _expect(_events(restored_battle, "v63_formation_zone_expired", zone_id).size() == 1
            and restored_owner.get("v63_formation_zones", []).is_empty(),
            "zone expires exactly once and removes its owner state")

func _exercise_mapbattle_gate_copy() -> void:
    var battle := MapBattleV2.new(88304)
    var caster := _actor("formation_mapbattle_copy", "disciple", Vector2(2, 2))
    caster["party_id"] = "formation_test_party"
    caster["v63_formation_combat_enabled"] = true
    caster["v63_skill_loadout"] = ["tmb.skill.formation.tu_linh_tran.active_01.human"]
    var stats: Dictionary = caster.get("stats", {}).duplicate(true)
    stats["max_hp"] = float(caster.get("max_hp", 0.0))
    caster["stats"] = stats
    var enemy := _actor("formation_mapbattle_enemy", "monster", Vector2(5, 2))
    var enemy_stats: Dictionary = enemy.get("stats", {}).duplicate(true)
    enemy_stats["max_hp"] = float(enemy.get("max_hp", 0.0))
    enemy["stats"] = enemy_stats
    var result := battle.setup("formation_mapbattle_copy", [caster], [enemy])
    _expect(bool(result.get("ok", false)), "MapBattle fixture starts: " + str(result.get("reason", "")))
    if bool(result.get("ok", false)):
        var copied: Dictionary = battle.actors.get("formation_mapbattle_copy", {})
        _expect(bool(copied.get("v63_formation_combat_enabled", false))
            and copied.get("v63_skill_loadout", []).has("tmb.skill.formation.tu_linh_tran.active_01.human"),
            "MapBattle preserves the explicitly supplied Formation preview gate and loadout")
        _expect(not Gates.is_enabled("formation_skill_combat"),
            "copying a preview fixture cannot activate production default")

func _cast_and_settle(battle: MapBattleV2, caster: Dictionary, target: Dictionary, label: String) -> bool:
    var started := HSC.try_cast(battle, caster, target)
    _expect(started, label + " starts")
    if not started:
        return false
    var pending: Dictionary = caster.get("v63_pending_cast", {})
    _expect(not pending.is_empty(), label + " owns a Combat V2 cast deadline")
    if pending.is_empty():
        return false
    battle.now = float(pending.get("ready", battle.now))
    battle._release_casts()
    return true

func _enable_preview(actor: Dictionary, skill_id: String) -> void:
    actor["v63_combat_enabled"] = true
    actor["v63_formation_combat_enabled"] = true
    actor["v63_skill_loadout"] = [skill_id]
    actor["v63_skill_ready"] = {}

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances := {"metal":0.0, "wood":0.0, "water":0.0, "fire":0.0, "earth":0.0,
        "lightning":0.0, "wind":0.0, "ice":0.0, "yang":0.0, "nether":0.0}
    var actor := {"id":actor_id,"side":side,"party_id":"","role":"ranged","position":position,
        "hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
        "stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
            "crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,
            "lifesteal_reduction":0.0},
        "resistances":resistances,"status_effects":{},"context_sources":[],
        "v63_combat_enabled":true,"v63_formation_combat_enabled":false,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_skill":0.0,"learned_guard_factor":1.0,
        "learned_guard_until":-1.0}
    if side == "monster":
        actor["race_id"] = "yeu_thu"
    return actor

func _events(battle: MapBattleV2, event_type: String, skill_id: String = "") -> Array:
    var result: Array = []
    for event in battle.events:
        if str(event.get("type", "")) == event_type and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id):
            result.append(event)
    return result

func _finish() -> void:
    if _failures > 0:
        print("V63_S8_FORMATION_RESULT FAIL checks=" + str(_checks) + " failures=" + str(_failures))
        quit(1)
        return
    print("V63_S8_FORMATION_RESULT PASS checks=" + str(_checks)
        + " nodes=183 families=35 branches=3 guard/slow/owned-zone=sampled "
        + "snapshot=JSON-safe release_gate=OFF source=SOURCE_PENDING vfx=TEXT_ONLY_HOLD")
    quit(0)
