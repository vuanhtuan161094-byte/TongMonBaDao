extends SceneTree

const Spear = preload("res://src/simulation/combat/v63_spear_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Registry = preload("res://src/simulation/combat/v63_content_registry.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const FeatureGates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("V63_S3_SPEAR_FAIL " + message)
	return ok

func _run() -> void:
	var loaded := Spear.load_catalogue()
	_expect(bool(loaded.get("ok", false)), "Thương runtime catalogue validates: " + str(loaded.get("errors", [])))
	if not bool(loaded.get("ok", false)):
		_finish()
		return
	var catalogue: Dictionary = loaded.data
	var skills: Array = catalogue.get("skills", [])
	_expect(skills.size() == 183 and catalogue.get("branches", []).size() == 3, "three paths and 183 evolution nodes are present")
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var unique_prose: Dictionary = {}
	var unique_vfx_profiles: Dictionary = {}
	var source_rows: Dictionary = Presentation.load_authoring_sources()
	_expect(bool(source_rows.get("ok", false)), "all authored catalogs, registry and presentation manifest load: " + str(source_rows.get("errors", [])))
	var manifest: Dictionary = source_rows.get("manifest", {})
	for raw in skills:
		var skill: Dictionary = raw
		var id := str(skill.get("id", ""))
		var name := str(skill.get("name", ""))
		_expect(not ids.has(id) and not name.is_empty() and not names.has(name), "Thương node has unique stable id and Hán-Việt name: " + id)
		ids[id] = true
		names[name] = true
		families[str(skill.get("family_id", ""))] = true
		_expect(str(skill.get("school", "")) == "spear" and str(skill.get("element", "")) == "metal", "Thương root and school identity are explicit: " + id)
		_expect(str(skill.get("source_codex_id", "")).is_empty() and not bool(skill.get("archivable", true)) and str(skill.get("candidate_status", "")) == "CANDIDATE_GATED_SOURCE_PENDING", "missing authentic manual keeps this node unlearnable: " + id)
		var entry: Dictionary = manifest.get("entries", {}).get(id, {})
		_expect(str(entry.get("school_lore_id", "")) == "tmb.lore.school.spear" and str(entry.get("long_description_vi", "")).strip_edges().length() > 30, "skill has school story and player-facing mechanics copy: " + id)
		var brief: Dictionary = entry.get("vfx", {}).get("production_brief", {})
		_expect(brief.get("phases", []).size() == 7 and str(brief.get("asset_status", "")) == "NOT_PRESENT" and str(brief.get("render_capture_status", "")) == "NOT_CAPTURED", "seven phase VFX record is honest about missing art capture: " + id)
		unique_prose[str(entry.get("short_description_vi", ""))] = true
		unique_vfx_profiles[str(brief.get("motion_profile", ""))] = true
		_expect(bool(Presentation.build_mechanics_tooltip(skill).get("ok", false)), "mechanics tooltip is derived from the runtime node: " + id)
	_expect(ids.size() == 183 and names.size() == 183 and families.size() == 35, "catalog totals remain 183 unique names across 35 families")
	_expect(unique_prose.size() == 183 and unique_vfx_profiles.size() == 183, "every node has distinct short description and VFX motion key")
	_expect(not bool(catalogue.get("enabled", true)) and str(catalogue.get("release_gate", "")) == "OFF" and not FeatureGates.is_enabled("spear_skill_combat"), "Spear and V6.3 remain disabled by default")
	_expect(str(Spear.can_learn(Spear.skill_definition("tmb.skill.spear.pha_tran_thuong.active_01.human")).get("reason", "")) == "skill_source_pending", "player cannot learn from an unauthenticated manual")
	_expect(not Spear.can_cast(_actor("gate_off", "disciple", Vector2(2, 2)), "tmb.skill.spear.pha_tran_thuong.active_01.human"), "actor cannot cast without candidate gate on its isolated preview actor")
	var registry_result := Registry.load_catalogue()
	_expect(bool(registry_result.get("ok", false)), "D1 registry joins Thương without enabling release: " + str(registry_result.get("errors", [])))
	if bool(registry_result.get("ok", false)):
		var registry: Dictionary = registry_result.data
		var node_count := 0
		for family in registry.get("families", []):
			node_count += family.get("nodes", []).size()
		_expect(registry.get("families", []).size() == 210 and registry.get("paths", []).size() == 18 and node_count == 1098, "registry includes current sources and three gated candidate schools")
	_expect(HSC.skill_definitions().size() == 1098 and HSC.branch_definitions().size() == 18, "shared runtime indexes all three candidates and eighteen branch identities")
	var matrix_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
	var matrix := FileAccess.open(matrix_path, FileAccess.READ)
	_expect(matrix != null, "all36 identity and effect matrix is available")
	if matrix != null and bool(registry_result.get("ok", false)):
		var audit := Presentation.validate_all36_ledger(matrix.get_as_text(), source_rows.get("catalogues", {}), registry_result.data)
		_expect(bool(audit.get("ok", false)), "all36 ledger joins three candidates without fake source rows: " + str(audit.get("errors", [])))
		var metrics: Dictionary = audit.get("metrics", {})
		_expect(int(metrics.get("candidate_gated", 0)) == 549 and int(metrics.get("not_authored", 0)) == 1098 and int(metrics.get("runtime_catalogue_ids", 0)) == 1098, "ledger retains distinct source, gated and unauthored counts")
	_exercise_line_attack()
	_exercise_capacity_shield()
	_finish()

func _exercise_line_attack() -> void:
	var battle := MapBattleV2.new(83711)
	var caster := _actor("spear_line_caster", "disciple", Vector2(2, 2))
	var on_line := _actor("spear_line_target", "enemy", Vector2(7, 2))
	var second_on_line := _actor("spear_line_target_2", "enemy", Vector2(8, 2.4))
	var outside_line := _actor("spear_line_outside", "enemy", Vector2(6, 3.1))
	var skill_id := "tmb.skill.spear.pha_tran_thuong.active_01.human"
	caster["v63_skill_loadout"] = [skill_id]
	caster["v63_spear_combat_enabled"] = true
	for actor in [caster, on_line, second_on_line, outside_line]:
		battle.actors[str(actor.id)] = actor
	var before_on_line := float(on_line.hp)
	var before_second := float(second_on_line.hp)
	var before_outside := float(outside_line.hp)
	_expect(HSC.try_cast(battle, caster, on_line), "Phá Trận AI creates a normal line cast from equipped candidate skill")
	var cast: Dictionary = caster.get("v63_pending_cast", {})
	_expect(str(cast.get("v63_skill_id", "")) == skill_id and str(cast.get("shape", "")) == "line", "cast record stores the actual line attack")
	if cast.is_empty():
		return
	battle.now = float(cast.get("ready", 0.0))
	battle._release_casts()
	_expect(float(on_line.hp) < before_on_line and float(second_on_line.hp) < before_second, "only enemies within the real line geometry take committed damage")
	_expect(is_equal_approx(float(outside_line.hp), before_outside), "enemy outside the narrow spear line takes no damage")
	_expect(_count_events(battle, "v63_spear_line_hit", skill_id) == 2, "impact events are emitted once per actual in-line damage settlement")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_skill_id == skill_id and renderer._cue_kind == "v63_spear_line_hit", "procedural spear VFX follows a confirmed line impact")
	renderer.free()

func _exercise_capacity_shield() -> void:
	var battle := MapBattleV2.new(83712)
	var caster := _actor("spear_guard_caster", "disciple", Vector2(4, 4))
	var ally := _actor("spear_guard_ally", "disciple", Vector2(5, 4))
	var foe := _actor("spear_guard_foe", "enemy", Vector2(4, 6))
	caster["party_id"] = "spear_party"
	tally_party(ally, "spear_party")
	tally_hp(ally, 60.0)
	foe["stats"]["attack"] = 20.0
	var skill_id := "tmb.skill.spear.ho_quan_thuong.active_01.human"
	caster["v63_skill_loadout"] = [skill_id]
	caster["v63_spear_combat_enabled"] = true
	for actor in [caster, ally, foe]:
		battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(battle, caster, foe), "Hộ Quân AI selects an eligible ally using the real support policy")
	var cast: Dictionary = caster.get("v63_pending_cast", {})
	_expect(str(cast.get("target_id", "")) == str(ally.id), "lowest-HP same-party ally is selected")
	if cast.is_empty():
		return
	battle.now = float(cast.get("ready", 0.0))
	battle._release_casts()
	var initial_capacity := float(ally.get("v63_capacity_shield_remaining", 0.0))
	_expect(initial_capacity > 0.0 and float(ally.get("v63_capacity_shield_until", -1.0)) > battle.now, "guard action creates a finite capacity shield with an expiry")
	var hp_before := float(ally.hp)
	var first_damage := battle._deal_direct(foe, ally, 1.0, "basic", false, "metal", false)
	var first_absorption := _events(battle, "v63_spear_shield_absorbed", skill_id)
	_expect(first_damage == 0.0 and is_equal_approx(float(ally.hp), hp_before) and not first_absorption.is_empty(), "shield absorbs a real resolved hit without reducing HP")
	var after_first_capacity := float(ally.get("v63_capacity_shield_remaining", 0.0))
	_expect(after_first_capacity < initial_capacity, "actual damage consumes bounded shield capacity")
	# Reduce the isolated test fixture's remaining budget to force an overflow hit.
	ally["v63_capacity_shield_remaining"] = 5.0
	var second_damage := battle._deal_direct(foe, ally, 1.0, "basic", false, "metal", false)
	_expect(second_damage > 0.0 and float(ally.hp) < hp_before, "damage beyond remaining shield capacity reaches HP")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_kind == "v63_spear_shield_absorbed" and renderer._cue_skill_id == skill_id, "shield VFX is driven by actual absorbed damage")
	renderer.free()
	battle.now = float(ally.get("v63_capacity_shield_until", 0.0)) + 0.01
	var expired_before := float(ally.hp)
	var after_expiry := battle._deal_direct(foe, ally, 1.0, "basic", false, "metal", false)
	_expect(after_expiry > 0.0 and float(ally.hp) < expired_before and float(ally.get("v63_capacity_shield_remaining", 0.0)) == 0.0, "expired capacity cannot continue absorbing hits")

func tally_party(actor: Dictionary, party_id: String) -> void:
	actor["party_id"] = party_id

func tally_hp(actor: Dictionary, hp: float) -> void:
	actor["hp"] = hp

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances: Dictionary = {}
	for element in ["metal", "wood", "water", "fire", "earth", "lightning", "wind", "ice", "yang", "nether"]:
		resistances[element] = 0.0
	return {"id":actor_id,"side":side,"role":"melee","position":position,"hp":200.0,"max_hp":200.0,
		"range":1.8,"move_speed":2.0,"stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,"v63_spear_combat_enabled":false,
		"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],"v63_combat_clock":-1.0,"next_skill":0.0}

func _events(battle: MapBattleV2, kind: String, skill_id: String = "") -> Array:
	var result: Array = []
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type", "")) == kind and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id):
			result.append(event)
	return result

func _count_events(battle: MapBattleV2, kind: String, skill_id: String = "") -> int:
	return _events(battle, kind, skill_id).size()

func _finish() -> void:
	if failures > 0:
		print("V63_S3_SPEAR_RESULT FAIL checks=" + str(checks) + " failures=" + str(failures))
		quit(1)
		return
	print("V63_S3_SPEAR_RESULT PASS checks=" + str(checks) + " nodes=183 families=35 branches=3 runtime=CombatV2 source=SOURCE_PENDING balance=CANDIDATE gates=OFF VFX=CODE_DRAWN_CAPTURE_PENDING")
	quit(0)
