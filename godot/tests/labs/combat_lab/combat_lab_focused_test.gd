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
var pending_probes := 0
var matrix: Array[Dictionary] = []
var serial := 0
var poison_only := false
var poison_damage_rows: Array[Dictionary] = []

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    print("COMBAT_LAB_FOCUSED_START Godot=" + Engine.get_version_info().string)
    poison_only = OS.get_environment("TMB_COMBAT_LAB_POISON_ONLY").strip_edges() == "1"
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
    _test_poison_atlas_assets()
    _test_skill_matrix(definitions)
    if poison_only:
        _test_poison_damage_matrix()
        _test_poison_aoe_and_single_target()
        _test_poison_support_effects()
    _write_matrix()
    _write_poison_damage_report()
    var counts := {"PASS": 0, "FAIL": 0, "NOT_TESTED": 0}
    for row in matrix: counts[str(row.status)] = int(counts.get(str(row.status), 0)) + 1
    print("COMBAT_LAB_SKILL_MATRIX " + JSON.stringify({"total": matrix.size(), "counts": counts,
        "active": active_probes, "passive": passive_probes, "innate": innate_probes,
        "basic": basic_probes, "mobility": mobility_probes, "design_pending": pending_probes,
        "poison_only": poison_only}))
    print("COMBAT_LAB_FOCUSED_RESULT=" + ("PASS" if failures == 0 and int(counts.FAIL) == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 and int(counts.FAIL) == 0 else 1)

func _check(value: bool, message: String) -> void:
    if not value:
        failures += 1
        push_error("COMBAT_LAB_FAIL " + message)

func _test_poison_atlas_assets() -> void:
    var path := "res://labs/combat_lab/assets/nu_doc_tu_grok_01/manifest.json"
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    _check(parsed is Dictionary and parsed.get("animations", null) is Dictionary,
        "six user-provided Poison animation sheets have a readable manifest")
    if not (parsed is Dictionary and parsed.get("animations", null) is Dictionary):
        return
    var animations: Dictionary = parsed.animations
    for clip in ["idle", "walk", "cast", "attack", "hit", "defeated"]:
        var row: Dictionary = animations.get(clip, {})
        var sheet := str(row.get("sheet", ""))
        var absolute := ProjectSettings.globalize_path(sheet)
        var exists := not sheet.is_empty() and FileAccess.file_exists(sheet)
        _check(exists, "Poison %s atlas sheet exists at %s" % [clip, sheet])
        if not exists:
            continue
        _check(FileAccess.get_sha256(absolute) == str(row.get("sheet_sha256", "")),
            "Poison %s atlas SHA-256 matches its manifest" % clip)
        var texture: Resource = ResourceLoader.load(sheet)
        _check(texture is Texture2D and (texture as Texture2D).get_width() >= int(row.get("columns", 0)) * int(row.get("cell_width", 0))
            and (texture as Texture2D).get_height() >= int(row.get("rows", 0)) * int(row.get("cell_height", 0)),
            "Poison %s atlas imports and covers all manifest cells" % clip)
        _check(CombatLabPoisonAtlasV1.frame_index(clip, 1.0, 1.0) >= 0,
            "Poison %s manifest maps to a real animation frame" % clip)

func _test_poison_damage_matrix() -> void:
    var cases := [
        ["human_direct", "tmb.skill.poison.doc_cham.active_01.human", 1, 0, 0, 1.0],
        ["human_poison_direct", "tmb.skill.poison.doc_cham.active_02.human", 1, 0, 0, 1.0],
        ["immortal_lineage_a", "tmb.skill.poison.doc_cham.active_01.immortal.a", 1, 0, 0, 1.0],
        ["immortal_lineage_b", "tmb.skill.poison.doc_cham.active_01.immortal.b", 1, 0, 0, 1.0],
        ["divine_a_stage1", "tmb.skill.poison.doc_cham.active_01.divine.a", 1, 0, 0, 1.0],
        ["divine_a_stage2", "tmb.skill.poison.doc_cham.active_01.divine.a", 2, 0, 0, 1.0],
        ["divine_a_stage3", "tmb.skill.poison.doc_cham.active_01.divine.a", 3, 0, 0, 1.0],
        ["divine_b_stage3", "tmb.skill.poison.doc_cham.active_01.divine.b", 3, 0, 0, 1.0],
        ["co_doc_mark", "tmb.skill.poison.co_doc.active_01.immortal.b", 1, 0, 0, 1.0],
        ["co_doc_owned_consume", "tmb.skill.poison.co_doc.active_02.immortal.b", 1, 2, 1, 1.12],
        ["duoc_doc_damage", "tmb.skill.poison.duoc_doc.active_01.human", 1, 0, 0, 1.0]
    ]
    for entry in cases:
        var row := _probe_poison_damage(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]), int(entry[4]), float(entry[5]))
        poison_damage_rows.append(row)
        _check(str(row.get("status", "FAIL")) == "PASS",
            "independent expected damage matches real settlement for %s: %s" % [str(entry[1]), str(row.get("detail", ""))])
    var dot_row := _probe_poison_dot_tick()
    poison_damage_rows.append(dot_row)
    _check(str(dot_row.get("status", "FAIL")) == "PASS",
        "independent DoT oracle matches real poison tick: %s" % str(dot_row.get("detail", "")))

func _probe_poison_damage(label: String, skill_id: String, stage: int, owned_stacks: int,
        foreign_stacks: int, mark_factor: float) -> Dictionary:
    var skill: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
    if skill.is_empty() or str(skill.get("divine_rule_status", "")) == "DESIGN_PENDING":
        return {"scenario":label,"skill_id":skill_id,"status":"FAIL","detail":"missing or DESIGN_PENDING skill"}
    var prepared := _prepare_action(skill)
    if not bool(prepared.get("ok", false)):
        return {"scenario":label,"skill_id":skill_id,"status":"FAIL","detail":"fixture:" + str(prepared.get("reason", ""))}
    var battle: MapBattleV2 = prepared.battle
    var actor: Dictionary = prepared.actor
    var target: Dictionary = prepared.target
    actor["stats"]["attack"] = 240.0
    actor["stats"]["crit_chance"] = 0.0
    actor["stats"]["defense_penetration"] = 0.0
    actor["v63_divine_stage"] = clampi(stage, 1, 3)
    target["stats"]["defense"] = 120.0
    target["stats"]["damage_reduction"] = 0.10
    target["resistances"] = {"nether":0.20,"wood":0.0,"fire":0.0,"ice":0.0,"lightning":0.0,"physical":0.0}
    target["max_hp"] = 1000000.0
    target["hp"] = 1000000.0
    target["stats"]["max_hp"] = 1000000.0
    if owned_stacks + foreign_stacks > 0:
        var stacks: Array[Dictionary] = []
        for index in range(owned_stacks + foreign_stacks):
            stacks.append({"owner_id":str(actor.id) if index < owned_stacks else "foreign_owner",
                "source_skill_id":"fixture_source", "stack_ordinal":index + 1, "ratio":0.01,
                "element":"nether", "next_tick":100.0, "expires_at":100.0})
        target["status_effects"] = {"v63_poison":stacks}
    if mark_factor > 1.0:
        target["v63_marks"] = {str(actor.id):{"owner_id":str(actor.id),"skill_id":"fixture_mark",
            "damage_factor":mark_factor,"until":100.0}}
    var hp_before := float(target.hp)
    if not V63HumanSkillCombatSystem.try_cast(battle, actor, target, false):
        return {"scenario":label,"skill_id":skill_id,"status":"FAIL","detail":"actual V6.3 cast rejected"}
    var pending: Dictionary = actor.get("v63_pending_cast", {})
    var cast_started := float(pending.get("ready", -1.0))
    if pending.is_empty():
        return {"scenario":label,"skill_id":skill_id,"status":"FAIL","detail":"cast did not schedule a real release"}
    battle.now = cast_started
    battle._release_casts()
    var hp_after := float(target.hp)
    var hit_count := 0
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("attacker", "")) == str(actor.id) and str(event.get("target", "")) == str(target.id) and str(event.get("kind", "")) == "v63_skill":
            hit_count += 1
    var ratio := float(skill.get("damage_ratio", 0.0))
    var generation := str(skill.get("generation", skill.get("tier", "human")))
    if generation == "divine":
        ratio *= [1.0, 1.12, 1.24][clampi(stage, 1, 3) - 1]
    if str(skill.get("effect", "")) == "consume_poison":
        ratio += minf(0.75, float(owned_stacks) * 0.05)
    ratio *= mark_factor
    var attack := float(actor.stats.get("attack", 0.0))
    var defense := float(target.stats.get("defense", 0.0)) * (1.0 - clampf(float(actor.stats.get("defense_penetration", 0.0)), 0.0, 1.0))
    var defense_factor := 2.0 * attack / maxf(0.000001, 2.0 * attack + defense)
    var resistance := clampf(float(target.resistances.get(str(skill.get("element", "")), 0.0)), 0.0, 1.0)
    var reduction := clampf(float(target.stats.get("damage_reduction", 0.0)), 0.0, 1.0)
    # Independent contract oracle: raw ATK × authored ratio × defense factor × elemental mitigation × damage reduction.
    var expected := minf(hp_before, attack * ratio * defense_factor * (1.0 - resistance) * (1.0 - reduction))
    var actual := hp_before - hp_after
    var ok := hit_count == 1 and is_equal_approx(actual, expected)
    if str(skill.get("effect", "")) == "consume_poison":
        var retained: Array = target.get("status_effects", {}).get("v63_poison", [])
        ok = ok and retained.size() == foreign_stacks and _event_count(battle, "poison_consumed") == 1
    return {"scenario":label,"skill_id":skill_id,"name":str(skill.get("name", "")),"generation":generation,
        "lineage":str(skill.get("lineage", "")),"divine_stage":str(stage),"target_id":str(target.id),
        "hp_before":str(hp_before),"hp_after":str(hp_after),"expected_damage":str(expected),
        "actual_damage":str(actual),"error":str(actual - expected),"status":"PASS" if ok else "FAIL",
        "detail":"MapBattleV2 hit=%d; independent ratio/DEF/resistance/reduction oracle%s" % [hit_count,
            "; owned stacks consumed, foreign stack retained" if str(skill.get("effect", "")) == "consume_poison" else ""]}

func _test_poison_aoe_and_single_target() -> void:
    _run_poison_aoe_case("aoe_three_in_plus_one_outside", 3)
    _run_poison_aoe_case("aoe_five_in_over_limit_plus_one_outside", 5)
    _test_poison_single_target_case()

func _run_poison_aoe_case(label: String, inside_count: int) -> void:
    var skill_id := "tmb.skill.poison.doc_cham.active_03.human"
    var skill: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
    var caster := _actor("aoe_caster", Vector2(6.0, 7.5))
    caster["v63_skill_loadout"] = [skill_id]
    caster["v63_combat_branch_id"] = "doc_cham"
    var ally := _actor("aoe_ally", Vector2(12.2, 10.0))
    var monsters: Array = []
    var points: Array[Vector2] = [Vector2(12.0, 10.0), Vector2(10.2, 8.5), Vector2(10.4, 11.6),
        Vector2(13.7, 8.1), Vector2(13.8, 11.7)]
    for index in range(inside_count):
        var monster := _enemy("aoe_enemy_%02d" % index, points[index])
        monster["hp"] = 1000000.0
        monster["max_hp"] = 1000000.0
        monster["stats"]["max_hp"] = 1000000.0
        monster["stats"]["attack"] = 1.0
        monster["stats"]["defense"] = 120.0
        monster["stats"]["damage_reduction"] = 0.10
        monster["resistances"] = {"nether":0.20,"wood":0.0,"fire":0.0,"ice":0.0,"lightning":0.0,"physical":0.0}
        monsters.append(monster)
    var outside := _enemy("aoe_enemy_outside", Vector2(16.5, 10.0))
    outside["hp"] = 1000000.0
    outside["max_hp"] = 1000000.0
    outside["stats"]["max_hp"] = 1000000.0
    outside["stats"]["attack"] = 1.0
    outside["stats"]["defense"] = 120.0
    outside["stats"]["damage_reduction"] = 0.10
    outside["resistances"] = {"nether":0.20,"wood":0.0,"fire":0.0,"ice":0.0,"lightning":0.0,"physical":0.0}
    monsters.append(outside)
    var battle := MapBattleV2.new(880000 + inside_count)
    _check(bool(battle.setup(label, [caster, ally], monsters, false).get("ok", false)), label + " MapBattle setup")
    if not battle.active:
        return
    caster = battle.actors.aoe_caster
    ally = battle.actors.aoe_ally
    var primary: Dictionary = battle.actors.aoe_enemy_00
    caster["stats"]["attack"] = 240.0
    caster["stats"]["crit_chance"] = 0.0
    caster["stats"]["defense_penetration"] = 0.0
    var cast_started := V63HumanSkillCombatSystem.try_cast(battle, caster, primary, false)
    _check(cast_started, label + " actual V6.3 cast starts")
    if not cast_started:
        return
    var pending: Dictionary = caster.v63_pending_cast
    var selected := V63HumanSkillCombatSystem._cast_targets(battle, caster, pending, "poison")
    var selected_ids: Array[String] = []
    for row in selected: selected_ids.append(str(row.id))
    _check(selected.size() == int(skill.target_limit), label + " _cast_targets respects catalog target_limit")
    _check(selected_ids.has("aoe_enemy_00") and not selected_ids.has("aoe_enemy_outside"),
        label + " selects in-radius targets and excludes the outside target")
    _check(not selected_ids.has("aoe_ally"), label + " never selects an ally in the radius")
    var before_hp: Dictionary = {}
    for raw_id in battle.actors:
        if str(battle.actors[raw_id].get("side", "")) == "monster":
            before_hp[str(raw_id)] = float(battle.actors[raw_id].hp)
    battle.now = float(pending.ready)
    battle._release_casts()
    var hit_ids: Array[String] = []
    var direct_hits := 0
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "v63_skill" and str(event.get("attacker", "")) == "aoe_caster":
            direct_hits += 1
            hit_ids.append(str(event.get("target", "")))
    var target_errors := 0
    for raw_id in battle.actors:
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side", "")) != "monster":
            continue
        var actual := float(before_hp[str(raw_id)]) - float(actor.hp)
        if hit_ids.has(str(raw_id)):
            var attack := float(caster.stats.attack)
            var defense := float(actor.stats.defense)
            var expected := minf(float(before_hp[str(raw_id)]), attack * float(skill.damage_ratio) * (2.0 * attack / (2.0 * attack + defense)) * 0.8 * 0.9)
            if not is_equal_approx(actual, expected): target_errors += 1
        elif not is_zero_approx(actual):
            target_errors += 1
    _check(direct_hits == int(skill.target_limit) and hit_ids.size() == direct_hits,
        label + " has one committed hit per selected target and no hit beyond the limit")
    _check(target_errors == 0, label + " HP deltas match independent formula; unselected HP is unchanged")
    _check(_event_count(battle, "status_applied") == int(skill.target_limit),
        label + " applies poison once per actually hit target")
    var arena := ArenaScript.new()
    get_root().add_child(arena)
    arena.set_battle(battle, "poison")
    arena.set_visual_time(battle.now)
    var events_before_visual := battle.events.size()
    arena.consume_events(CombatLabEventBridge.new().poll(battle))
    var clouds := 0
    var projectiles := 0
    var impacts := 0
    var poison_marks := 0
    for cue in arena.cues:
        if str(cue.get("skill_id", "")) != skill_id:
            continue
        match str(cue.get("kind", "")):
            "venom_cloud":
                clouds += 1
                _check(is_equal_approx(float(cue.get("radius", 0.0)), float(skill.radius)), label + " poison cloud radius matches authored skill radius")
            "projectile": projectiles += 1
            "impact": impacts += 1
            "poison_apply": poison_marks += 1
    _check(clouds == 1 and projectiles == 1 and impacts == direct_hits and poison_marks == direct_hits,
        label + " event-only Poison VFX follows real cast/projectile/hit/apply records")
    _check(battle.events.size() == events_before_visual and int(arena.cues.size()) <= ArenaScript.MAX_CUES,
        label + " presentation neither writes combat events nor settles extra damage")
    poison_damage_rows.append({"scenario":label,"skill_id":skill_id,"name":str(skill.name),
        "generation":"human","lineage":"","divine_stage":"","target_id":"multiple",
        "hp_before":"per-target in event fixture","hp_after":"selected %d; excluded %d" % [direct_hits, monsters.size() + 1 - direct_hits],
        "expected_damage":"manual ATK/DEF/nether-resistance/reduction oracle per selected target",
        "actual_damage":"%d MapBattleV2 hits; %d poison applications" % [direct_hits, direct_hits],"error":"0" if target_errors == 0 else str(target_errors),
        "status":"PASS" if target_errors == 0 and direct_hits == int(skill.target_limit) else "FAIL",
        "detail":"_cast_targets real radius %.2f, limit %d, VFX anchored at authored center" % [float(skill.radius), int(skill.target_limit)]})
    arena.queue_free()

func _test_poison_single_target_case() -> void:
    var skill_id := "tmb.skill.poison.doc_cham.active_01.human"
    var caster := _actor("single_caster", Vector2(6.0, 7.5))
    caster["v63_skill_loadout"] = [skill_id]
    var enemies: Array = []
    for index in range(3):
        enemies.append(_enemy("single_enemy_%02d" % index, Vector2(12.0 + float(index) * 0.5, 10.0)))
    var battle := MapBattleV2.new(880010)
    _check(bool(battle.setup("poison_single_target", [caster], enemies, false).get("ok", false)), "single Poison scenario MapBattle setup")
    if not battle.active: return
    caster = battle.actors.single_caster
    var target: Dictionary = battle.actors.single_enemy_00
    var selected := V63HumanSkillCombatSystem._cast_targets(battle, caster,
        {"shape":"single_target","target_id":str(target.id),"maximum":1}, "damage")
    _check(selected.size() == 1 and str(selected[0].id) == str(target.id), "single-target Poison skill does not select nearby enemies")
    _check(V63HumanSkillCombatSystem.try_cast(battle, caster, target, false), "single-target Poison V6.3 cast starts")
    var pending: Dictionary = caster.v63_pending_cast
    battle.now = float(pending.ready)
    battle._release_casts()
    var hit_ids: Array[String] = []
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "v63_skill":
            hit_ids.append(str(event.get("target", "")))
    _check(hit_ids == [str(target.id)], "single-target Poison scene commits damage to exactly the chosen target")

func _test_poison_support_effects() -> void:
    _probe_poison_support("poison_heal", "tmb.skill.poison.duoc_doc.active_02.human", true)
    _probe_poison_support("poison_cleanse", "tmb.skill.poison.duoc_doc.active_03.human", false)

func _probe_poison_support(label: String, skill_id: String, is_heal: bool) -> void:
    var skill: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
    var prepared := _prepare_action(skill)
    if not bool(prepared.get("ok", false)):
        _check(false, label + " fixture failed")
        return
    var battle: MapBattleV2 = prepared.battle
    var caster: Dictionary = prepared.actor
    var ally_id := str(prepared.get("ally_id", ""))
    var ally: Dictionary = battle.actors.get(ally_id, {})
    if ally.is_empty():
        _check(false, label + " ally missing")
        return
    if is_heal:
        ally["hp"] = 40000.0
    else:
        ally["status_effects"] = {"weaken":{"until":30.0,"factor":0.8}}
    var hp_before := float(ally.hp)
    var expected_heal := minf(float(ally.max_hp) * clampf(float(skill.power), 0.0, 0.5), float(ally.max_hp) - hp_before) if is_heal else 0.0
    var enemy: Dictionary = prepared.target
    var cast_started := V63HumanSkillCombatSystem.try_cast(battle, caster, enemy, false)
    _check(cast_started, label + " V6.3 support AI selects a valid ally")
    if not cast_started: return
    var pending: Dictionary = caster.v63_pending_cast
    _check(str(pending.get("target_id", "")) == ally_id, label + " cast targets the ally, not the enemy")
    battle.now = float(pending.ready)
    battle._release_casts()
    if is_heal:
        var actual_heal := float(ally.hp) - hp_before
        var ok := is_equal_approx(actual_heal, expected_heal)
        _check(ok, "Dược Độc actual heal equals authored power × ally max HP, capped by missing HP")
        poison_damage_rows.append({"scenario":label,"skill_id":skill_id,"name":str(skill.name),"generation":"human","lineage":"","divine_stage":"",
            "target_id":ally_id,"hp_before":str(hp_before),"hp_after":str(ally.hp),"expected_damage":str(expected_heal),
            "actual_damage":str(actual_heal),"error":str(actual_heal - expected_heal),"status":"PASS" if ok else "FAIL",
            "detail":"real heal event and ally-target selection"})
    else:
        var cleared: bool = not ally.get("status_effects", {}).has("weaken")
        _check(cleared and _event_count_for_skill(battle, "cleanse", skill_id) == 1,
            "Dược Độc cleanse removes an actual debuff and emits one canonical event")
        poison_damage_rows.append({"scenario":label,"skill_id":skill_id,"name":str(skill.name),"generation":"human","lineage":"","divine_stage":"",
            "target_id":ally_id,"hp_before":str(hp_before),"hp_after":str(ally.hp),"expected_damage":"—","actual_damage":"—",
            "error":"—","status":"PASS" if cleared else "FAIL","detail":"real cleanse event removed weaken from ally"})

func _event_count_for_skill(battle: MapBattleV2, event_type: String, skill_id: String) -> int:
    var result := 0
    for event in battle.events:
        if str(event.get("type", "")) == event_type and str(event.get("skill_id", "")) == skill_id:
            result += 1
    return result

func _event_count(battle: MapBattleV2, event_type: String) -> int:
    var result := 0
    for event in battle.events:
        if str(event.get("type", "")) == event_type:
            result += 1
    return result

func _write_poison_damage_report() -> void:
    var output_path := OS.get_environment("TMB_COMBAT_LAB_DAMAGE_PATH").strip_edges()
    if output_path.is_empty(): return
    var file := FileAccess.open(output_path, FileAccess.WRITE)
    if file == null:
        push_error("COMBAT_LAB_POISON_DAMAGE_REPORT_WRITE_FAILED")
        failures += 1
        return
    var columns := PackedStringArray(["scenario","skill_id","name","generation","lineage","divine_stage","target_id",
        "hp_before","hp_after","expected_damage","actual_damage","error","status","detail"])
    file.store_line(",".join(columns))
    for row in poison_damage_rows:
        var cells := PackedStringArray()
        for column in columns:
            cells.append('"' + str(row.get(column, "")).replace('"', '""') + '"')
        file.store_line(",".join(cells))
    file.close()
    print("COMBAT_LAB_POISON_DAMAGE_REPORT=" + output_path)

func _test_loadout_and_party() -> void:
    for school in CombatLabRosterAdapter.SCHOOL_ORDER:
        for generation in CombatLabRosterAdapter.GENERATIONS:
            var branches := CombatLabRosterAdapter.school_branches(school)
            _check(not branches.is_empty(), "%s branch catalog exists" % school)
            if branches.is_empty(): continue
            var branch := str(branches[0].get("id", ""))
            var lineage := "a"
            var spec := CombatLabRosterAdapter.default_loadout(school, generation, branch, lineage)
            if school == "poison" and generation == "divine" and not bool(spec.get("ok", false)):
                _check(spec.get("errors", []).has("active_catalog_below_four") or spec.get("errors", []).has("passive_catalog_below_five"),
                    "Poison Divine DESIGN_PENDING nodes cannot be silently used to fill a Lab loadout")
                continue
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
    var aoe_preset_button: Button
    var boss_preset_button: Button
    for candidate in buttons:
        if not candidate is Button: continue
        match str(candidate.text):
            "HOLD": hold_button = candidate
            "AUTO": auto_button = candidate
            "STEP · 0,25s": step_button = candidate
            "TÁI TẠO TRẬN": reset_button = candidate
            "ĐỘC CHÂM · QUẦN CÔNG 3/4": aoe_preset_button = candidate
            "ĐỘC TU · 6 vs BOSS + QUÁI": boss_preset_button = candidate
    _check((hold_button != null and auto_button != null and step_button != null and reset_button != null
        and aoe_preset_button != null and boss_preset_button != null),
        "standalone UI builds actual interactive controls")
    if (hold_button == null or auto_button == null or step_button == null or reset_button == null
        or aoe_preset_button == null or boss_preset_button == null):
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
    aoe_preset_button.pressed.emit()
    battle = lab.get("battle")
    _check(battle.actors.size() == 5 and battle.actors.has("lab_aoe_00") and battle.actors.has("lab_aoe_outside"),
        "one-tap Poison AOE preset creates three in-radius targets and one outside")
    boss_preset_button.pressed.emit()
    battle = lab.get("battle")
    _check(battle.actors.size() == 10 and battle.actors.has("lab_boss") and battle.actors.has("lab_boss_add_01")
        and int(lab.get("party_count").value) == 6, "one-tap Poison preset creates six disciples versus a real V6.3 Boss and three adds")
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
        elif str(cue.kind) == "poison_tick": poison_count += 1
    _check(impact_count == 2 and heal_count == 1 and poison_count == 1 and arena.cues.size() == 4,
        "VFX renders authoritative hit/Poison tick/DoT once and lifesteal once despite duplicate semantic events")
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
    var target_hp_before := float(target.hp)
    battle._deal_direct(attacker, target, 1.0, "basic", true)
    var verified := false
    var hit_event: Dictionary = {}
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("attacker", "")) == "crit_lifesteal_actor":
            verified = bool(event.get("critical", false)) and float(event.get("lifesteal", 0.0)) > 0.0
            hit_event = event
    var attacker_stats := V63HumanSkillCombatSystem.effective_attack_stats(attacker, attacker.stats)
    var target_stats := V63HumanSkillCombatSystem.effective_defense_stats(target, target.stats)
    var attack := float(attacker_stats.get("attack", 0.0))
    var defense := float(target_stats.get("defense", 0.0)) * (1.0 - clampf(float(attacker_stats.get("defense_penetration", 0.0)), 0.0, 1.0))
    var expected_damage := attack * maxf(1.0, float(attacker_stats.get("crit_damage", 1.5))) * 2.0 * attack / maxf(0.000001, 2.0 * attack + defense)
    expected_damage *= 1.0 - clampf(float(target_stats.get("damage_reduction", 0.0)), 0.0, 1.0)
    expected_damage = minf(target_hp_before, expected_damage)
    var net_lifesteal := maxf(0.0, float(attacker_stats.get("lifesteal", 0.0)) - float(target_stats.get("lifesteal_reduction", 0.0)))
    var expected_heal := minf(expected_damage * net_lifesteal, float(attacker.max_hp) - hp_before)
    var actual_damage := target_hp_before - float(target.hp)
    var actual_heal := float(attacker.hp) - hp_before
    var oracle_pass := verified and is_equal_approx(actual_damage, expected_damage) and is_equal_approx(actual_heal, expected_heal)
    _check(oracle_pass, "Independent crit damage and lifesteal oracle matches committed HP settlement")
    poison_damage_rows.append({"scenario":"crit_lifesteal_direct", "skill_id":"lab.basic.crit_lifesteal",
        "name":"Crit + lifesteal · CombatStatsV2", "generation":"lab", "lineage":"", "divine_stage":"",
        "target_id":"crit_lifesteal_enemy", "hp_before":str(target_hp_before), "hp_after":str(target.hp),
        "expected_damage":str(expected_damage), "actual_damage":str(actual_damage), "error":str(actual_damage - expected_damage),
        "status":"PASS" if oracle_pass else "FAIL",
        "detail":"crit multiplier 2.0; expected heal %.9f, actual heal %.9f; event=%s" % [expected_heal, actual_heal, JSON.stringify(hit_event)]})

func _probe_poison_dot_tick() -> Dictionary:
    var skill_id := "tmb.skill.poison.doc_cham.active_02.human"
    var skill: Dictionary = V63HumanSkillCombatSystem.skill_definition(skill_id)
    if skill.is_empty() or str(skill.get("effect", "")) != "poison":
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"catalog skill is not a real poison action"}
    var prepared := _prepare_action(skill)
    if not bool(prepared.get("ok", false)):
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"fixture:" + str(prepared.get("reason", ""))}
    var battle: MapBattleV2 = prepared.battle
    var actor: Dictionary = prepared.actor
    var target: Dictionary = prepared.target
    actor["stats"]["attack"] = 240.0
    actor["stats"]["crit_chance"] = 0.0
    actor["stats"]["defense_penetration"] = 0.0
    target["stats"]["defense"] = 120.0
    target["stats"]["damage_reduction"] = 0.10
    target["resistances"] = {"nether":0.20,"wood":0.0,"fire":0.0,"ice":0.0,"lightning":0.0,"physical":0.0}
    target["max_hp"] = 1000000.0
    target["hp"] = 1000000.0
    target["stats"]["max_hp"] = 1000000.0
    if not V63HumanSkillCombatSystem.try_cast(battle, actor, target, false):
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"real poison cast rejected"}
    var pending: Dictionary = actor.get("v63_pending_cast", {})
    if pending.is_empty():
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"real cast did not schedule release"}
    battle.now = float(pending.get("ready", 0.0))
    battle._release_casts()
    var stacks: Array = target.get("status_effects", {}).get("v63_poison", [])
    var source_stack: Dictionary = {}
    for value in stacks:
        if value is Dictionary and str(value.get("source_skill_id", "")) == skill_id:
            source_stack = value
            break
    if source_stack.is_empty():
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"cast did not apply an owned stack"}
    var valid_count := stacks.size()
    var effective_count := float(mini(valid_count, 12)) + float(clampi(valid_count - 12, 0, 12)) * 0.5 + float(maxi(0, valid_count - 24)) * 0.25
    var diminishing := effective_count / maxf(1.0, float(valid_count))
    var hp_before := float(target.hp)
    battle.now = float(source_stack.get("next_tick", INF))
    V63HumanSkillCombatSystem.process_status_effects(battle)
    var tick_event: Dictionary = {}
    for event in battle.events:
        if str(event.get("type", "")) == "status_tick" and str(event.get("source_skill_id", "")) == skill_id:
            tick_event = event
            break
    if tick_event.is_empty():
        return {"scenario":"poison_dot_tick", "skill_id":skill_id, "status":"FAIL", "detail":"real source-owned poison tick missing"}
    var snapshot: Dictionary = source_stack.get("attack_snapshot", {})
    var attack := float(snapshot.get("attack", 0.0))
    var penetration := clampf(float(snapshot.get("defense_penetration", 0.0)), 0.0, 1.0)
    var effective_defense := float(target.stats.get("defense", 0.0)) * (1.0 - penetration)
    var defense_factor := 2.0 * attack / maxf(0.000001, 2.0 * attack + effective_defense)
    var element := str(source_stack.get("element", "nether"))
    var resistance := clampf(float(target.resistances.get(element, 0.0)), 0.0, 1.0)
    var reduction := clampf(float(target.stats.get("damage_reduction", 0.0)), 0.0, 1.0)
    var expected := minf(hp_before, attack * float(source_stack.get("ratio", 0.0)) * diminishing * defense_factor * (1.0 - resistance) * (1.0 - reduction))
    var actual := float(tick_event.get("damage", 0.0))
    var hp_delta := hp_before - float(target.hp)
    var dot_hit: Dictionary = {}
    for event in battle.events:
        if str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "v63_poison" and str(event.get("damage_source", "")) == "poison_dot":
            dot_hit = event
            break
    var no_crit_or_leech := not dot_hit.is_empty() and not bool(dot_hit.get("critical", false)) and is_zero_approx(float(dot_hit.get("lifesteal", 0.0)))
    var ok := is_equal_approx(actual, expected) and is_equal_approx(hp_delta, expected) and no_crit_or_leech
    return {"scenario":"poison_dot_tick", "skill_id":skill_id, "name":str(skill.get("name", "")), "generation":"human", "lineage":"", "divine_stage":"",
        "target_id":str(target.id), "hp_before":str(hp_before), "hp_after":str(target.hp), "expected_damage":str(expected),
        "actual_damage":str(actual), "error":str(actual - expected), "status":"PASS" if ok else "FAIL",
        "detail":"real owner stack tick; independent ratio/DEF/element/reduction+diminishing oracle; no crit/lifesteal"}
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
        if poison_only and str(skill.get("school", "")) != "poison":
            continue
        var result := {
            "skill_id": id,
            "name": str(skill.get("name", "")),
            "branch": str(skill.get("branch", "")),
            "generation": str(skill.get("generation", skill.get("tier", "human"))),
            "lineage": str(skill.get("lineage", "")),
            "required_divine_stage": str(skill.get("required_divine_stage", "")),
            "school": str(skill.get("school", "")),
            "slot": str(skill.get("slot", "")),
            "effect": str(skill.get("effect", "")),
            "damage_ratio": str(skill.get("damage_ratio", "")),
            "power": str(skill.get("power", "")),
            "element": str(skill.get("element", "")),
            "range": str(skill.get("range", "")),
            "shape": str(skill.get("shape", "")),
            "radius": str(skill.get("radius", "")),
            "target_limit": str(skill.get("target_limit", "")),
            "cast_time": str(skill.get("cast_time", "")),
            "cooldown": str(skill.get("cooldown", "")),
            "projectile_speed": str(skill.get("projectile_speed", "")),
            "duration": str(skill.get("duration", "")),
            "poison_stacks": str(skill.get("poison_stacks", "")),
            "combat_trait": str(skill.get("combat_trait", "")),
            "divine_rule": str(skill.get("divine_rule", "")),
            "divine_rule_status": str(skill.get("divine_rule_status", "")),
            "balance_status": str(skill.get("balance_status", "")),
            "source_codex_id": str(skill.get("source_codex_id", "")),
            "animation_key": str(skill.get("animation_key", "")),
            "vfx_key": str(skill.get("vfx_key", "")),
            "status": "NOT_TESTED",
            "reason": "unsupported_slot"
        }
        if str(skill.get("id", "")) != id or not id.begins_with("tmb.skill."):
            result.status = "FAIL"; result.reason = "invalid_catalog_identity"
        elif str(skill.get("divine_rule_status", "")) == "DESIGN_PENDING":
            result.status = "DESIGN_PENDING"
            result.reason = "owner-deferred Divine rule; catalog fields audited, combat semantics not executed"
            pending_probes += 1
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
    var output_path := OS.get_environment("TMB_COMBAT_LAB_MATRIX_PATH").strip_edges()
    if output_path.is_empty(): output_path = "user://combat_lab_skill_matrix.csv"
    var file := FileAccess.open(output_path, FileAccess.WRITE)
    if file == null:
        push_error("COMBAT_LAB_MATRIX_WRITE_FAILED")
        failures += 1
        return
    var columns := PackedStringArray([
        "skill_id", "name", "branch", "generation", "lineage", "required_divine_stage", "school", "slot", "effect",
        "damage_ratio", "power", "element", "range", "shape", "radius", "target_limit", "cast_time", "cooldown",
        "projectile_speed", "duration", "poison_stacks", "combat_trait", "divine_rule", "divine_rule_status",
        "balance_status", "source_codex_id", "animation_key", "vfx_key", "status", "reason"
    ])
    file.store_line(",".join(columns))
    for row in matrix:
        var cells := PackedStringArray()
        for column in columns:
            var value := str(row.get(column, "" )).replace('"', '""')
            cells.append('"' + value + '"')
        file.store_line(",".join(cells))
    file.close()
    print("COMBAT_LAB_SKILL_MATRIX_FILE=" + ProjectSettings.globalize_path(output_path) if output_path.begins_with("user://") else "COMBAT_LAB_SKILL_MATRIX_FILE=" + output_path)

