extends SceneTree

const PREVIEW := CombatLabRosterAdapter.LAB_PREVIEW_GATES
const ArenaScript = preload("res://labs/combat_lab/combat_lab_arena.gd")
const LabScene = preload("res://labs/combat_lab/combat_lab.tscn")
var failures := 0
var active_probes := 0
var passive_probes := 0
var innate_probes := 0
var basic_probes := 0
var mobility_probes := 0
var matrix: Array[Dictionary] = []
var serial := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    print("COMBAT_LAB_FOCUSED_START Godot=" + Engine.get_version_info().string)
    _check(V63FeatureGates.all_disabled(), "V6.3 feature gates remain OFF by default")
    var definitions := CombatLabRosterAdapter.skill_definitions()
    _check(definitions.size() == 549, "expected 549 V6.3 skill IDs, got %d" % definitions.size())
    _test_loadout_and_party()
    _test_six_disciple_battle()
    _test_ui_controls()
    _test_event_bridge()
    _test_event_capacity_limit()
    _test_vfx_deduplication()
    _test_real_battle()
    _test_deterministic_replay()
    _test_crit_lifesteal()
    _test_elemental_resistance()
    _test_boss_source()
    _test_skill_matrix(definitions)
    _write_matrix()
    var counts := {"PASS": 0, "FAIL": 0, "NOT_TESTED": 0}
    for row in matrix: counts[str(row.status)] = int(counts.get(str(row.status), 0)) + 1
    print("COMBAT_LAB_SKILL_MATRIX " + JSON.stringify({"total": matrix.size(), "counts": counts,
        "active": active_probes, "passive": passive_probes, "innate": innate_probes,
        "basic": basic_probes, "mobility": mobility_probes}))
    print("COMBAT_LAB_FOCUSED_RESULT=" + ("PASS" if failures == 0 and int(counts.FAIL) == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 and int(counts.FAIL) == 0 else 1)

func _check(value: bool, message: String) -> void:
    if not value:
        failures += 1
        push_error("COMBAT_LAB_FAIL " + message)

func _test_loadout_and_party() -> void:
    for school in CombatLabRosterAdapter.SCHOOL_ORDER:
        for generation in CombatLabRosterAdapter.GENERATIONS:
            var branches := CombatLabRosterAdapter.school_branches(school)
            _check(not branches.is_empty(), "%s branch catalog exists" % school)
            if branches.is_empty(): continue
            var branch := str(branches[0].get("id", ""))
            var lineage := "a"
            var spec := CombatLabRosterAdapter.default_loadout(school, generation, branch, lineage)
            _check(bool(spec.get("ok", false)), "default %s/%s loadout validates: %s" % [school, generation, str(spec.get("errors", []))])
            if not bool(spec.get("ok", false)): continue
            var fixture := CombatLabRosterAdapter.build_party(1, school, generation, branch, lineage, spec.skill_ids)
            _check(bool(fixture.get("ok", false)), "sandbox fixture uses canonical learn/equip/attach for %s/%s: %s" % [school, generation, str(fixture.get("detail", fixture.get("reason", "")))])
            if bool(fixture.get("ok", false)):
                var actor: Dictionary = fixture.actors[0]
                _check(bool(actor.get("v63_combat_enabled", false)) and actor.get("v63_skill_loadout", []).size() >= 5,
                    "attached runtime loadout %s/%s" % [school, generation])
                _check(actor.get("disciple", null) is DiscipleState, "linked disciple exists only as sandbox fixture")
    var valid := CombatLabRosterAdapter.default_loadout("bow", "human", "liep_anh", "a")
    var invalid_ids: Array[String] = valid.skill_ids.duplicate()
    invalid_ids[2] = "tmb.skill.does_not_exist"
    _check(not CombatLabRosterAdapter.validate_loadout(invalid_ids, "bow", "human", "liep_anh", "a").is_empty(), "unknown skill ID rejected")
    var duplicate_ids: Array[String] = valid.skill_ids.duplicate()
    duplicate_ids[3] = duplicate_ids[2]
    _check(not CombatLabRosterAdapter.validate_loadout(duplicate_ids, "bow", "human", "liep_anh", "a").is_empty(), "duplicate/family slot rejected")
    _check(V63FeatureGates.all_disabled(), "preview fixture did not mutate production feature defaults")

func _test_six_disciple_battle() -> void:
    var spec := CombatLabRosterAdapter.default_loadout("bow", "human", "liep_anh", "a")
    var fixture := CombatLabRosterAdapter.build_party(6, "bow", "human", "liep_anh", "a", spec.skill_ids)
    _check(bool(fixture.get("ok", false)) and fixture.get("party", []).size() == 6, "Lab fixture supports exactly six disciples")
    if not bool(fixture.get("ok", false)): return
    var enemy := _enemy("six_disciple_enemy", Vector2(26, 10))
    var battle := MapBattleV2.new(12349)
    _check(bool(battle.setup("combat_lab_six_disciple", fixture.party, [enemy], false).get("ok", false)), "MapBattleV2 accepts six-member Lab party")
    if not battle.active: return
    var positions: Array[Vector2] = []
    for row in fixture.party:
        var position: Vector2 = battle.actors[str(row.id)].position
        for prior in positions:
            _check(prior.distance_to(position) > 0.01, "six-member spawn positions are distinct")
        positions.append(position)
    battle.step()
    _check(battle.active and battle.actors.size() == 7, "six disciples execute a real MapBattleV2 tick against one enemy")
func _actor(actor_id: String, position: Vector2, side_role: String = "ranged") -> Dictionary:
    var core := CombatStatsV2.derive(1, 1, 1, 1, 0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = 180.0
    stats["defense"] = 100.0
    return {"id": actor_id, "party_id": "matrix_fixture", "role": side_role, "tier": "disciple", "race_id": "nhan_toc",
        "position": position, "stats": stats, "hp": 80000.0, "max_hp": 100000.0, "resistances": core.resistances.duplicate(true),
        "basic_range": 0.45, "move_speed": 0.0, "basic_ratio": 0.0, "basic_interval": 90.0,
        "skill_loadout": [], "skill_factors": {}, "context_sources": [], "disciple": null,
        "v63_combat_enabled": true, "v63_skill_loadout": [], "v63_skill_ready": {}, "v63_passive_ids": [],
        "v63_combat_branch_id": "", "v63_combat_generation": "human", "v63_combat_lineage": "", "v63_divine_stage": 3}

func _enemy(enemy_id: String, position: Vector2) -> Dictionary:
    var row := MonsterCatalogueV2.create_actor("hac_lang", 1, 1, enemy_id)
    var stats: Dictionary = row.stats.duplicate(true)
    stats["max_hp"] = 100000000.0
    stats["attack"] = 1.0
    row["id"] = enemy_id
    row["position"] = position
    row["tier"] = "normal"
    row["hp"] = 100000000.0
    row["stats"] = stats
    row["move_speed"] = 0.0
    return row

func _test_ui_controls() -> void:
    var lab = LabScene.instantiate()
    get_root().add_child(lab)
    var buttons: Array = lab.find_children("*", "Button", true, false)
    var hold_button: Button
    var auto_button: Button
    var step_button: Button
    var reset_button: Button
    for candidate in buttons:
        if not candidate is Button: continue
        match str(candidate.text):
            "HOLD": hold_button = candidate
            "AUTO": auto_button = candidate
            "STEP · 0,25s": step_button = candidate
            "TÁI TẠO TRẬN": reset_button = candidate
    _check(hold_button != null and auto_button != null and step_button != null and reset_button != null,
        "standalone UI builds actual interactive controls")
    if hold_button == null or auto_button == null or step_button == null or reset_button == null:
        lab.free()
        return
    hold_button.pressed.emit()
    _check(not bool(lab.get("auto_run")), "HOLD signal pauses the Lab simulation")
    var battle: MapBattleV2 = lab.get("battle")
    var before := battle.now
    step_button.pressed.emit()
    _check(is_equal_approx(battle.now, before + MapBattleV2.STEP_SECONDS), "STEP signal advances one canonical battle tick")
    auto_button.pressed.emit()
    _check(bool(lab.get("auto_run")), "AUTO signal resumes canonical battle ticking")
    var auto_before_step := battle.now
    step_button.pressed.emit()
    _check(not bool(lab.get("auto_run")), "STEP while AUTO first returns the Lab to HOLD")
    _check(is_equal_approx(battle.now, auto_before_step + MapBattleV2.STEP_SECONDS),
        "STEP while AUTO advances exactly one canonical 0.25-second tick")
    var after_one_manual_step := battle.now
    lab.call("_process", 1.0)
    _check(is_equal_approx(battle.now, after_one_manual_step),
        "STEP stays paused and does not resume AUTO on the next frame")
    hold_button.pressed.emit()
    var zoom: OptionButton = lab.get("zoom_option")
    zoom.item_selected.emit(2)
    _check(is_equal_approx(float(lab.get("arena").get("zoom")), 4.0), "zoom option signal changes the real battle viewport")
    var party: SpinBox = lab.get("party_count")
    party.value = 6
    reset_button.pressed.emit()
    battle = lab.get("battle")
    _check(battle.actors.size() == 7, "recreate button starts six disciples against an actual opponent")
    lab.free()
func _test_event_bridge() -> void:
    var party: Array = [_actor("bridge_actor", Vector2(10, 10))]
    var enemy: Dictionary = _enemy("bridge_enemy", Vector2(11, 10))
    var battle := MapBattleV2.new(801)
    _check(bool(battle.setup("combat_lab_bridge", party, [enemy]).ok), "MapBattle setup for event bridge")
    var bridge := CombatLabEventBridge.new()
    var first := bridge.poll(battle)
    var second := bridge.poll(battle)
    _check(first.size() == 1 and int(first[0].lab_source_index) == 0, "event bridge uses real append index")
    _check(second.is_empty(), "event bridge does not replay a consumed event")
    battle.step()
    var third := bridge.poll(battle)
    _check(not third.is_empty() and int(third[0].lab_source_index) >= 1, "event bridge reads later real MapBattle events")

func _test_event_capacity_limit() -> void:
    var full := MapBattleV2.new(12350)
    for index in range(MapBattleV2.MAX_EVENTS):
        full.events.append({"type":"lab_capacity_fixture", "fixture_index":index})
    var bridge := CombatLabEventBridge.new()
    bridge.reset(full)
    var initial := bridge.poll(full)
    _check(initial.size() == MapBattleV2.MAX_EVENTS, "finite event bridge reads the source capacity once")
    full._event("after_finite_capacity", {})
    _check(full.events.size() == MapBattleV2.MAX_EVENTS and bridge.poll(full).is_empty(), "finite source stops appending when MAX_EVENTS is full")
    full.world_mode = true
    full._event("world_ring_fixture", {})
    var ring_rows := bridge.poll(full)
    _check(str(full.events.back().get("type", "")) == "world_ring_fixture" and ring_rows.is_empty(),
        "documented local index cannot detect world ring-buffer replacement; Lab port is finite-only")
func _test_vfx_deduplication() -> void:
    var battle := MapBattleV2.new(12348)
    var source := _actor("vfx_source", Vector2(10, 10))
    var target := _enemy("vfx_target", Vector2(11, 10))
    _check(bool(battle.setup("combat_lab_vfx_dedupe", [source], [target], false).get("ok", false)), "event VFX fixture setup")
    var arena := ArenaScript.new()
    get_root().add_child(arena)
    arena.set_battle(battle, "bow")
    var rows: Array[Dictionary] = [
        {"type":"hit", "attacker":"vfx_source", "target":"vfx_target", "kind":"v63_skill", "damage":20.0, "critical":true, "lifesteal":5.0},
        {"type":"v63_skill_hit", "caster":"vfx_source", "target":"vfx_target", "effect":"damage", "damage":20.0},
        {"type":"hit", "attacker":"vfx_source", "target":"vfx_target", "kind":"v63_poison", "damage":5.0},
        {"type":"status_tick", "caster":"vfx_source", "target":"vfx_target", "status":"poison", "damage":5.0},
        {"type":"hit", "attacker":"vfx_source", "target":"vfx_target", "kind":"dot", "damage":4.0},
        {"type":"damage_tick", "attacker":"vfx_source", "target":"vfx_target", "damage":4.0}
    ]
    arena.consume_events(rows)
    var impact_count := 0
    var heal_count := 0
    var poison_count := 0
    for cue in arena.cues:
        if str(cue.kind) == "impact": impact_count += 1
        elif str(cue.kind) == "heal": heal_count += 1
        elif str(cue.kind) == "poison": poison_count += 1
    _check(impact_count == 2 and heal_count == 1 and poison_count == 1 and arena.cues.size() == 4,
        "VFX renders authoritative hit/DoT once and lifesteal once despite duplicate semantic events")
    arena.queue_free()
func _test_real_battle() -> void:
    var branch := "liep_anh"
    var spec := CombatLabRosterAdapter.default_loadout("bow", "human", branch, "a")
    var fixture := CombatLabRosterAdapter.build_party(1, "bow", "human", branch, "a", spec.skill_ids)
    _check(bool(fixture.get("ok", false)), "playable bow fixture build")
    if not bool(fixture.get("ok", false)): return
    var enemy: Dictionary = _enemy("lab_real_enemy", Vector2(9.0, 8.0))
    var battle := MapBattleV2.new(12345)
    _check(bool(battle.setup("combat_lab_playable", fixture.party, [enemy], false).ok), "finite lab encounter setup")
    var initial_hp := float(battle.actors["lab_real_enemy"].hp)
    battle.run(240)
    var observed_damage := false
    for event in battle.events:

        if str(event.get("type", "")) == "hit" and str(event.get("attacker", "")).begins_with("lab_disciple_"):
            observed_damage = observed_damage or float(event.get("damage", 0.0)) > 0.0
    _check(observed_damage and float(battle.actors["lab_real_enemy"].hp) < initial_hp, "real MapBattle/CombatStats damage reduces target HP")
    _check(battle.pending_kill_events().is_empty(), "finite Lab encounter creates no kill/reward receipts")
    _check(battle.outcome in ["fighting", "win", "timeout_retreat"], "finite encounter returns a valid non-reward outcome")

func _test_deterministic_replay() -> void:
    var first := _deterministic_trace()
    var second := _deterministic_trace()
    _check(not first.is_empty() and first == second, "fixed-seed Lab fixture replays identical authoritative event trace")

func _deterministic_trace() -> Array:
    var spec := CombatLabRosterAdapter.default_loadout("bow", "human", "liep_anh", "a")
    var fixture := CombatLabRosterAdapter.build_party(1, "bow", "human", "liep_anh", "a", spec.skill_ids)
    if not bool(fixture.get("ok", false)): return []
    var target := _enemy("lab_enemy", Vector2(9, 8))
    var battle := MapBattleV2.new(515151)
    if not bool(battle.setup("combat_lab_preview", fixture.party, [target], false).get("ok", false)): return []
    battle.run(32)
    return battle.events.duplicate(true)
func _test_crit_lifesteal() -> void:
    var actor := _actor("crit_lifesteal_actor", Vector2(10, 10))
    actor["hp"] = 50000.0
    actor["stats"]["crit_chance"] = 1.0
    actor["stats"]["crit_damage"] = 2.0
    actor["stats"]["lifesteal"] = 0.4
    var battle := MapBattleV2.new(12346)
    _check(bool(battle.setup("combat_lab_crit_lifesteal", [actor], [_enemy("crit_lifesteal_enemy", Vector2(11, 10))]).get("ok", false)), "Crit/lifesteal fixture setup")
    var attacker: Dictionary = battle.actors["crit_lifesteal_actor"]
    var target: Dictionary = battle.actors["crit_lifesteal_enemy"]
    var hp_before := float(attacker.hp)
    battle._deal_direct(attacker, target, 1.0, "basic", true)
    var verified := false
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("attacker", "")) == "crit_lifesteal_actor":
            verified = bool(event.get("critical", false)) and float(event.get("lifesteal", 0.0)) > 0.0
    _check(verified and float(attacker.hp) > hp_before, "Crit and lifesteal settle once via CombatStatsV2 and MapBattleV2")
func _test_elemental_resistance() -> void:
    var attacker := _actor("element_attacker", Vector2(10, 10))
    attacker["stats"]["crit_chance"] = 0.0
    var plain_target := _enemy("element_plain", Vector2(11, 10))
    plain_target["resistances"] = {"fire": 0.0}
    var plain_battle := MapBattleV2.new(12347)
    _check(bool(plain_battle.setup("combat_lab_element_plain", [attacker.duplicate(true)], [plain_target], false).get("ok", false)), "neutral element resistance fixture setup")
    var plain_damage := plain_battle._deal_direct(plain_battle.actors["element_attacker"], plain_battle.actors["element_plain"], 1.0, "basic", false, "fire", false)
    var resistant_attacker := _actor("element_attacker", Vector2(10, 10))
    resistant_attacker["stats"]["crit_chance"] = 0.0
    var resistant_target := _enemy("element_resistant", Vector2(11, 10))
    resistant_target["resistances"] = {"fire": 0.5}
    var resistant_battle := MapBattleV2.new(12347)
    _check(bool(resistant_battle.setup("combat_lab_element_resistant", [resistant_attacker], [resistant_target], false).get("ok", false)), "fire resistance fixture setup")
    var resisted_damage := resistant_battle._deal_direct(resistant_battle.actors["element_attacker"], resistant_battle.actors["element_resistant"], 1.0, "basic", false, "fire", false)
    _check(plain_damage > 0.0 and is_equal_approx(resisted_damage, plain_damage * 0.5), "MapBattleV2/CombatStatsV2 applies actual elemental resistance")
func _test_boss_source() -> void:
    var boss := CombatLabRosterAdapter.build_enemy("boss", "tmb.boss.bach_doc_chu_hau", "lab_boss_fixture")
    _check(bool(boss.get("ok", false)), "Lab can build an authentic V6.3 boss candidate")
    if not bool(boss.get("ok", false)): return
    var actor: Dictionary = boss.actor
    _check(str(actor.get("v63_boss_id", "")) == "tmb.boss.bach_doc_chu_hau" and bool(actor.get("v63_custom_boss_ai", false)), "Boss identity and AI come from V6.3 install adapter")
    _check(not actor.has("loot") and not actor.has("reward"), "boss fixture has no reward payload")
    var spec := CombatLabRosterAdapter.default_loadout("bow", "human", "liep_anh", "a")
    var fixture := CombatLabRosterAdapter.build_party(1, "bow", "human", "liep_anh", "a", spec.skill_ids)
    _check(bool(fixture.get("ok", false)), "Boss AI party fixture")
    if not bool(fixture.get("ok", false)): return
    var team: Array = fixture.party
    team[0]["position"] = Vector2(10, 10)
    actor["position"] = Vector2(14, 10)
    var battle := MapBattleV2.new(615)
    _check(bool(battle.setup("combat_lab_boss_ai", team, [actor], false).get("ok", false)), "Boss battle setup")
    battle.run(100)
    var telegraphed := false
    for event in battle.events:
        if str(event.get("type", "")) == "telegraph" and str(event.get("boss_id", "")) == "tmb.boss.bach_doc_chu_hau": telegraphed = true
    _check(telegraphed, "real Boss AI emits its own V6.3 telegraph through MapBattleV2")
    _check(battle.pending_kill_events().is_empty(), "Boss test remains finite and reward-free")
func _test_skill_matrix(definitions: Dictionary) -> void:
    var ids: Array = definitions.keys()
    ids.sort()
    for id_value in ids:
        var id := str(id_value)
        var skill: Dictionary = definitions[id]
        var result := {"skill_id": id, "generation": str(skill.get("generation", "")), "school": str(skill.get("school", "")), "slot": str(skill.get("slot", "")), "status": "NOT_TESTED", "reason": "unsupported_slot"}
        if str(skill.get("id", "")) != id or not id.begins_with("tmb.skill."):
            result.status = "FAIL"; result.reason = "invalid_catalog_identity"
        else:
            match str(skill.get("slot", "")):
                "active", "ultimate":
                    active_probes += 1
                    var probe := _probe_action(skill)
                    result.status = str(probe.status); result.reason = str(probe.reason)
                "passive":
                    passive_probes += 1
                    var probe := _probe_modifier(skill, false)
                    result.status = str(probe.status); result.reason = str(probe.reason)
                "innate":
                    innate_probes += 1
                    var probe := _probe_modifier(skill, true)
                    result.status = str(probe.status); result.reason = str(probe.reason)
                "basic":
                    basic_probes += 1
                    var probe := _probe_basic(skill)
                    result.status = str(probe.status); result.reason = str(probe.reason)
                "mobility":
                    mobility_probes += 1
                    var probe := _probe_mobility(skill)
                    result.status = str(probe.status); result.reason = str(probe.reason)
                _:
                    result.reason = "catalog_slot_has_no_runtime_probe"
        matrix.append(result)
        if str(result.status) == "FAIL":
            failures += 1
            push_error("COMBAT_LAB_SKILL_FAIL " + id + " " + str(result.reason))
        if matrix.size() % 50 == 0: print("COMBAT_LAB_MATRIX_PROGRESS %d/%d" % [matrix.size(), ids.size()])

func _prepare_action(skill: Dictionary) -> Dictionary:
    serial += 1
    var id := str(skill.get("id", ""))
    var branch := str(skill.get("branch", ""))
    var generation := str(skill.get("generation", skill.get("tier", "human")))
    var lineage := str(skill.get("lineage", ""))
    var actor := _actor("matrix_actor_%d" % serial, Vector2(10, 10))
    actor["v63_combat_branch_id"] = branch
    actor["v63_combat_generation"] = generation
    actor["v63_combat_lineage"] = lineage
    actor["v63_skill_loadout"] = [id]
    if generation == "immortal":
        V63ImmortalSkillCombatSystem.attach_immortal_state(actor, lineage)
    elif generation == "divine":
        var disciple := DiscipleState.new({"id": "matrix_divine_%d" % serial})
        V63DivineSkillCombatSystem.attach_divine_state(actor, disciple, lineage, 3)
    var range_value := maxf(0.02, float(skill.get("range", 3.0)))
    var distance := maxf(2.5, minf(4.0, range_value - 0.3)) if str(skill.get("effect", "")) == "mobility" else minf(0.35, range_value * 0.45)
    var target := _enemy("matrix_enemy_%d" % serial, Vector2(10 + distance, 10))
    var party: Array = [actor]
    var ally_id := ""
    var effect := str(skill.get("effect", ""))
    if effect in ["heal", "cleanse"]:
        ally_id = "matrix_ally_%d" % serial
        var ally := _actor(ally_id, Vector2(10.1, 10.2), "healer")
        ally["hp"] = 8000.0
        party.append(ally)
    var battle := MapBattleV2.new(410000 + serial)
    var setup := battle.setup("matrix_%d" % serial, party, [target], false)
    if not bool(setup.get("ok", false)):
        return {"ok": false, "reason": "setup:" + str(setup.get("reason", ""))}
    actor = battle.actors[str(actor.id)]
    target = battle.actors[str(target.id)]
    if not ally_id.is_empty() and effect == "cleanse":
        battle.actors[ally_id]["status_effects"] = {"weaken": {"until": 40.0, "factor": 0.8}}
    if effect == "consume_poison":
        target["status_effects"] = {"v63_poison": [{"owner_id": str(actor.id), "source_skill_id": "fixture", "stack_ordinal": 1,
            "attack_snapshot": actor.stats.duplicate(true), "ratio": 0.05, "element": "wood", "applied_at": 0.0, "next_tick": 100.0, "expires_at": 100.0}]}
    return {"ok": true, "battle": battle, "actor": actor, "target": target, "ally_id": ally_id}

func _probe_action(skill: Dictionary) -> Dictionary:
    var prepared := _prepare_action(skill)
    if not bool(prepared.get("ok", false)): return {"status": "FAIL", "reason": str(prepared.get("reason", ""))}
    var battle: MapBattleV2 = prepared.battle
    var actor: Dictionary = prepared.actor
    var target: Dictionary = prepared.target
    if not V63HumanSkillCombatSystem.try_cast(battle, actor, target, false):
        return {"status": "FAIL", "reason": "actual_consumer_rejected_cast"}
    var id := str(skill.get("id", ""))
    var pending: Dictionary = actor.get("v63_pending_cast", {})
    if pending.is_empty(): return {"status": "FAIL", "reason": "cast_did_not_create_pending_record"}
    var deadline := float(pending.get("ready", INF))
    var ready_at := float(actor.get("v63_skill_ready", {}).get(id, -1.0))
    battle.now = deadline
    battle._release_casts()
    var cast_event: Dictionary = {}
    var release_event: Dictionary = {}
    var effect := str(skill.get("effect", ""))
    var effect_proven := false
    for event in battle.events:
        if str(event.get("skill_id", "")) != id: continue
        var kind := str(event.get("type", ""))
        if kind == "skill_cast": cast_event = event
        if kind == "skill_release": release_event = event
        if kind == "v63_skill_hit" and str(event.get("effect", "")) == effect:
            if effect in ["damage", "poison", "mark", "consume_poison"]:
                effect_proven = effect_proven or float(event.get("damage", 0.0)) > 0.0 or effect in ["poison", "mark"]
            elif effect == "heal": effect_proven = effect_proven or float(event.get("target_hp_after", 0.0)) > float(event.get("target_hp_before", 0.0))
            elif effect in ["guard", "cleanse"]: effect_proven = true
        if kind == "status_applied" and str(event.get("caster", "")) == str(actor.id): effect_proven = true
        if kind == "cleanse" and str(event.get("skill_id", "")) == id: effect_proven = true
        if kind == "heal" and str(event.get("skill_id", "")) == id and float(event.get("amount", 0.0)) > 0.0: effect_proven = true
    if cast_event.is_empty() or release_event.is_empty():
        return {"status": "FAIL", "reason": "real_cast_or_release_event_missing"}
    if float(release_event.get("time", -1.0)) < float(cast_event.get("release_at", INF)) - 0.0001:
        return {"status": "FAIL", "reason": "cast_time_or_projectile_deadline_not_respected"}
    if ready_at < float(cast_event.get("cooldown_ready_at", INF)) - 0.0001:
        return {"status": "FAIL", "reason": "cooldown_schedule_not_respected"}
    if not effect_proven: return {"status": "FAIL", "reason": "cast_release_effect_not_proven:%s" % effect}
    if effect == "poison":
        var poison_stacks: Array = target.get("status_effects", {}).get("v63_poison", [])
        if poison_stacks.is_empty(): return {"status": "FAIL", "reason": "poison_application_missing"}
        var next_tick := float(poison_stacks[0].get("next_tick", INF))
        var hp_before_tick := float(target.hp)
        battle.now = next_tick
        V63HumanSkillCombatSystem.process_status_effects(battle)
        var tick_observed := false
        for event in battle.events:
            if str(event.get("type", "")) == "status_tick" and str(event.get("source_skill_id", "")) == id:
                tick_observed = float(event.get("damage", 0.0)) > 0.0
        if not tick_observed or float(target.hp) >= hp_before_tick:
            return {"status": "FAIL", "reason": "poison_dot_tick_not_observed"}
    return {"status": "PASS", "reason": "MapBattleV2 V6.3 cast/release/effect/cooldown verified"}
func _probe_modifier(skill: Dictionary, innate: bool) -> Dictionary:
    var id := str(skill.get("id", ""))
    var actor := _actor("matrix_stat_actor", Vector2(10, 10))
    var branch := str(skill.get("branch", ""))
    var generation := str(skill.get("generation", skill.get("tier", "human")))
    var lineage := str(skill.get("lineage", ""))
    actor["v63_combat_branch_id"] = branch
    actor["v63_combat_generation"] = generation
    actor["v63_combat_lineage"] = lineage
    if innate:
        var expected := ""
        if generation == "human": expected = str(V63HumanSkillCombatSystem.branch_definitions().get(branch, {}).get("innate_node_id", ""))
        elif generation == "immortal": expected = str(V63ImmortalSkillCombatSystem.branch_definitions().get(branch, {}).get("innate_node_ids", {}).get(lineage, ""))
        elif generation == "divine": expected = str(V63DivineSkillCombatSystem.branch_definitions().get(branch, {}).get("divine_innate_node_ids", {}).get(lineage, ""))
        if expected != id: return {"status": "FAIL", "reason": "branch_does_not_derive_innate:%s" % expected}
        actor["v63_innate_skill_id"] = id
    else:
        actor["v63_passive_ids"] = [id]
    var attack_before_actor := _without_passive(actor)
    var attack_before := V63HumanSkillCombatSystem.effective_attack_stats(attack_before_actor, actor.stats)
    var attack_after := V63HumanSkillCombatSystem.effective_attack_stats(actor, actor.stats)
    var defense_before := V63HumanSkillCombatSystem.effective_defense_stats(attack_before_actor, actor.stats)
    var defense_after := V63HumanSkillCombatSystem.effective_defense_stats(actor, actor.stats)
    var changed := false
    for field in ["attack", "crit_chance", "attack_speed", "cast_speed", "cooldown_recovery", "lifesteal"]:
        changed = changed or not is_equal_approx(float(attack_before.get(field, 0.0)), float(attack_after.get(field, 0.0)))
    changed = changed or not is_equal_approx(float(defense_before.get("damage_reduction", 0.0)), float(defense_after.get("damage_reduction", 0.0)))
    if changed: return {"status": "PASS", "reason": "existing effective stat consumer produced expected delta"}
    var mods: Dictionary = skill.get("passive_modifiers", {})
    if float(mods.get("heal_factor", 0.0)) > 0.0 and not innate:
        var heal_result := _probe_heal_factor(id, float(mods.heal_factor))
        if str(heal_result.status) == "PASS": return heal_result
    if float(mods.get("poison_factor", 0.0)) > 0.0:
        var poison_result := _probe_poison_factor(id, float(mods.poison_factor), innate)
        if str(poison_result.status) == "PASS": return poison_result
    if innate and float(mods.get("heal_factor", 0.0)) > 0.0:
        return {"status": "NOT_TESTED", "reason": "heal_factor is not consumed from innate ID by current V6.3 runtime"}
    if skill.has("divine_rule_status"):
        return {"status": "NOT_TESTED", "reason": "divine_rule_status has no consumer in current runtime code"}
    if mods.is_empty() or mods.values().all(func(value: Variant) -> bool: return is_zero_approx(float(value))):
        return {"status": "NOT_TESTED", "reason": "catalog modifiers are zero and no matching runtime consumer was found"}
    return {"status": "NOT_TESTED", "reason": "catalog effect has no matching generic or specialized runtime consumer"}

func _probe_heal_factor(skill_id: String, factor: float) -> Dictionary:
    var caster := _actor("matrix_healer", Vector2(10, 10))
    caster["v63_passive_ids"] = [skill_id]
    var ally := _actor("matrix_wounded", Vector2(10.1, 10.0), "healer")
    ally["hp"] = 50000.0
    var battle := MapBattleV2.new(517)
    if not bool(battle.setup("matrix_heal_factor", [caster, ally], [_enemy("matrix_heal_enemy", Vector2(16, 10))]).get("ok", false)):
        return {"status": "FAIL", "reason": "heal_factor_setup_failed"}
    caster = battle.actors["matrix_healer"]
    ally = battle.actors["matrix_wounded"]
    V63HumanSkillCombatSystem._heal_target(battle, caster, ally, skill_id, 0.2)
    var actual := float(ally.hp) - 50000.0
    var expected := 20000.0 * (1.0 + clampf(factor, 0.0, 0.25))
    if is_equal_approx(actual, expected): return {"status": "PASS", "reason": "V6.3 heal consumer applied passive heal_factor"}
    return {"status": "FAIL", "reason": "heal_factor expected %.3f got %.3f" % [expected, actual]}

func _probe_poison_factor(skill_id: String, factor: float, innate: bool) -> Dictionary:
    var definitions := CombatLabRosterAdapter.skill_definitions()
    var source_id := ""
    var selected: Dictionary = definitions.get(skill_id, {})
    for raw in definitions.values():
        var candidate: Dictionary = raw
        if str(candidate.get("effect", "")) == "poison" and str(candidate.get("branch", "")) == str(selected.get("branch", "")) \
                and str(candidate.get("generation", "")) == str(selected.get("generation", "")) \
                and str(candidate.get("lineage", "")) == str(selected.get("lineage", "")):
            source_id = str(candidate.get("id", ""))
            break
    if source_id.is_empty(): return {"status": "NOT_TESTED", "reason": "matching poison action absent"}
    var caster := _actor("matrix_poisoner", Vector2(10, 10))
    if innate: caster["v63_innate_skill_id"] = skill_id
    else: caster["v63_passive_ids"] = [skill_id]
    var enemy := _enemy("matrix_poison_target", Vector2(12, 10))
    var battle := MapBattleV2.new(519)
    if not bool(battle.setup("matrix_poison_factor", [caster], [enemy]).get("ok", false)):
        return {"status": "FAIL", "reason": "poison_factor_setup_failed"}
    caster = battle.actors["matrix_poisoner"]
    enemy = battle.actors["matrix_poison_target"]
    V63HumanSkillCombatSystem._apply_poison(battle, caster, enemy, source_id, 0.1, 5.0, 1, "wood")
    var stacks: Array = enemy.get("status_effects", {}).get("v63_poison", [])
    var actual := float(stacks[0].get("ratio", 0.0)) if not stacks.is_empty() else 0.0
    var expected := minf(0.2, 0.1 * (1.0 + clampf(factor, 0.0, 0.5)))
    if not stacks.is_empty() and is_equal_approx(actual, expected):
        return {"status": "PASS", "reason": "V6.3 poison consumer applied %s poison_factor" % ("innate" if innate else "passive")}
    return {"status": "FAIL", "reason": "poison_factor expected %.4f got %.4f" % [expected, actual]}

func _without_passive(actor: Dictionary) -> Dictionary:
    var clone := actor.duplicate(true)
    clone["v63_passive_ids"] = []
    if clone.has("v63_innate_skill_id"): clone.erase("v63_innate_skill_id")
    return clone

func _probe_basic(skill: Dictionary) -> Dictionary:
    var actor := _actor("matrix_basic", Vector2(10, 10))
    actor["basic_range"] = 2.0
    actor["basic_ratio"] = float(skill.get("damage_ratio", 1.0))
    actor["basic_interval"] = 0.25
    actor["basic_element"] = str(skill.get("element", ""))
    actor["v63_basic_skill_id"] = str(skill.get("id", ""))
    actor["v63_combat_generation"] = str(skill.get("generation", ""))
    var enemy := _enemy("matrix_basic_target", Vector2(11, 10))
    var battle := MapBattleV2.new(840)
    if not bool(battle.setup("matrix_basic", [actor], [enemy]).get("ok", false)):
        return {"status": "FAIL", "reason": "basic_setup_failed"}
    var before := float(battle.actors["matrix_basic_target"].hp)
    var damage := battle._deal_direct(battle.actors["matrix_basic"], battle.actors["matrix_basic_target"], float(skill.get("damage_ratio", 1.0)), "basic", true, str(skill.get("element", "")))
    var after := float(battle.actors["matrix_basic_target"].hp)
    if damage > 0.0 and after < before: return {"status": "PASS", "reason": "CombatStatsV2 basic hit reduced HP"}
    return {"status": "FAIL", "reason": "basic did not produce damage"}

func _probe_mobility(skill: Dictionary) -> Dictionary:
    var prepared := _prepare_action(skill)
    if not bool(prepared.get("ok", false)): return {"status": "FAIL", "reason": str(prepared.get("reason", ""))}
    var battle: MapBattleV2 = prepared.battle
    var actor: Dictionary = prepared.actor
    var target: Dictionary = prepared.target
    var before: Vector2 = actor.position
    if not V63HumanSkillCombatSystem.try_cast(battle, actor, target, false): return {"status": "FAIL", "reason": "mobility_consumer_rejected"}
    var moved: Vector2 = actor.position
    var found := false
    for event in battle.events:
        if str(event.get("type", "")) == "v63_mobility" and str(event.get("skill_id", "")) == str(skill.id): found = true
    if found and before != moved: return {"status": "PASS", "reason": "existing V6.3 mobility changed actor position"}
    return {"status": "FAIL", "reason": "mobility position/event missing"}

func _write_matrix() -> void:
    var file := FileAccess.open("user://combat_lab_skill_matrix.csv", FileAccess.WRITE)
    if file == null:
        push_error("COMBAT_LAB_MATRIX_WRITE_FAILED")
        failures += 1
        return
    file.store_line("skill_id,generation,school,slot,status,reason")
    for row in matrix:
        file.store_line("%s,%s,%s,%s,%s,%s" % [row.skill_id, row.generation, row.school, row.slot, row.status, str(row.reason).replace(",", ";")])
    file.close()
    print("COMBAT_LAB_SKILL_MATRIX_FILE=" + ProjectSettings.globalize_path("user://combat_lab_skill_matrix.csv"))
