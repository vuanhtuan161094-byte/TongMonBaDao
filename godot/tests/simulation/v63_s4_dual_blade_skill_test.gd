extends SceneTree

# S4 Song Đao: source/balance remain pending and the production gate stays OFF.
# Explicitly gated preview fixtures exercise the actual Combat V2 cast/release path.
const Dual = preload("res://src/simulation/combat/v63_dual_blade_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Registry = preload("res://src/simulation/combat/v63_content_registry.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("V63_S4_DUAL_BLADE_FAIL " + label)

func _run() -> void:
	var loaded: Dictionary = Dual.load_catalogue()
	_expect(bool(loaded.get("ok", false)), "candidate combat catalogue validates: " + str(loaded.get("errors", [])))
	if not bool(loaded.get("ok", false)):
		_finish()
		return
	var catalogue: Dictionary = loaded.get("data", {})
	var skills: Array = catalogue.get("skills", [])
	_expect(skills.size() == 183 and catalogue.get("branches", []).size() == 3, "Song Đao has three branches and 183 evolution nodes")
	_expect(Dual.branch_definitions().size() == 3, "branch runtime definitions are indexed")
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var flavors: Dictionary = {}
	var shorts: Dictionary = {}
	var motions: Dictionary = {}
	var root_counts := {"human":0, "immortal":0, "divine":0}
	var branch_counts := {"anh_nhan":0, "lien_hoan":0, "huyet_nguyet":0}
	var sources: Dictionary = Presentation.load_authoring_sources()
	_expect(bool(sources.get("ok", false)), "S0 with S4 additive extension loads and verifies source pins: " + str(sources.get("errors", [])))
	var catalogues: Dictionary = sources.get("catalogues", {})
	var manifest: Dictionary = sources.get("manifest", {})
	var registry: Dictionary = sources.get("registry", {})
	var entries: Dictionary = manifest.get("entries", {})
	_expect(catalogues.has("dual_blade") and catalogues.has("palm") and catalogues.has("talisman") and entries.size() == 1102, "Song Đao, Chưởng and Phù additive entries join the earlier presentations")
	for raw in skills:
		var skill: Dictionary = raw
		var id := str(skill.get("id", ""))
		var entry: Dictionary = entries.get(id, {})
		_expect(not ids.has(id), "unique evolution ID: " + id)
		_expect(not names.has(str(skill.get("name", ""))), "unique Hán-Việt node name: " + id)
		ids[id] = true
		names[str(skill.get("name", ""))] = true
		families[str(skill.get("family_id", ""))] = true
		root_counts[str(skill.get("generation", ""))] = int(root_counts.get(str(skill.get("generation", "")), 0)) + 1
		if branch_counts.has(str(skill.get("branch", ""))):
			branch_counts[str(skill.get("branch", ""))] = int(branch_counts[str(skill.get("branch", ""))]) + 1
		var flavor := str(entry.get("flavor_vi", ""))
		var short := str(entry.get("short_description_vi", ""))
		var long := str(entry.get("long_description_vi", ""))
		_expect(flavor.length() >= 50 and flavor.length() <= 110, "individual xianxia flavor length: " + id)
		_expect(not short.is_empty() and not long.is_empty() and str(entry.get("counterplay_vi", "")).length() > 0, "mechanics/counterplay copy exists: " + id)
		_expect(str(entry.get("school_lore_id", "")) == "tmb.lore.school.dual_blade", "school lore link: " + id)
		_expect(str(entry.get("availability", {}).get("status", "")) == "CANDIDATE_GATED_SOURCE_PENDING", "learning remains source-gated: " + id)
		var phases: Array = entry.get("vfx", {}).get("production_brief", {}).get("phases", [])
		_expect(phases.size() == 7 and str(entry.get("qa_status", {}).get("asset", "")) == "NOT_PRESENT" and str(entry.get("qa_status", {}).get("render", "")) == "NOT_CAPTURED", "VFX phase/provenance is explicit and does not claim art/render: " + id)
		flavors[flavor] = true
		shorts[short] = true
		motions[str(entry.get("vfx", {}).get("production_brief", {}).get("motion_profile", ""))] = true
		var presentation: Dictionary = Presentation.presentation_for(id, manifest, catalogues)
		_expect(bool(presentation.get("ok", false)), "runtime-generated tooltip resolves for node: " + id)
	_expect(ids.size() == 183 and names.size() == 183 and families.size() == 35, "183 unique IDs/names cover 35 skill families")
	_expect(root_counts == {"human":35, "immortal":68, "divine":80}, "Human/Immortal/Divine evolution distribution is 35/68/80")
	_expect(branch_counts == {"anh_nhan":59, "lien_hoan":59, "huyet_nguyet":59}, "each Song Đao branch owns 59 nodes")
	_expect(flavors.size() == 183 and shorts.size() == 183 and motions.size() == 183, "every node has distinct flavor, functional summary and motion profile")
	var base_registry: Dictionary = Registry.load_catalogue().get("data", {})
	_expect(base_registry.get("families", []).size() == 210 and registry.get("families", []).size() == 315 and registry.get("paths", []).size() == 27, "additive extensions compose candidate families/paths without rewriting canonical base registry")
	_expect(HSC.skill_definitions().size() == 1647 and HSC.branch_definitions().size() == 27, "Human skill and branch indexes include the gated candidate catalogue")
	_expect(not Gates.is_enabled("dual_blade_skill_combat") and not bool(Gates.DEFAULT_FLAGS.get("dual_blade_skill_combat", true)), "Song Đao production feature gate remains OFF")
	_expect(str(Dual.can_learn(Dual.skill_definition("tmb.skill.dual_blade.lien_hoan.active_01.human")).get("reason", "")) == "skill_source_pending", "learning stays blocked until an authentic manual is registered")
	_expect(not Dual.can_cast(_actor("gate_off", "disciple", Vector2(2, 2)), "tmb.skill.dual_blade.lien_hoan.active_01.human"), "candidate cannot cast without explicit preview fixture")
	_expect(is_equal_approx(Dual.preferred_offensive_range(_actor("range_off", "disciple", Vector2(2, 2))), 0.0), "AI range stays at the non-Song-Dao value while its feature gate is OFF")
	var csv_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
	var csv := FileAccess.open(csv_path, FileAccess.READ)
	_expect(csv != null, "authoritative 2,196-row ID ledger is readable")
	if csv != null:
		var ledger: Dictionary = Presentation.validate_all36_ledger(csv.get_as_text(), catalogues, registry)
		_expect(bool(ledger.get("ok", false)), "S4 ledger/runtime/registry joins: " + str(ledger.get("errors", [])))
		var metrics: Dictionary = ledger.get("metrics", {})
		_expect(int(metrics.get("existing", 0)) == 549 and int(metrics.get("candidate_gated", 0)) == 1098 and int(metrics.get("not_authored", 0)) == 549 and int(metrics.get("runtime_catalogue_ids", 0)) == 1647, "ledger separates implemented sources, candidate nodes and remaining slots")
	await _exercise_combo_and_cued_renderer()
	await _exercise_mobility_and_ai_range()
	await _exercise_bounded_hp_trade()
	_finish()

func _exercise_combo_and_cued_renderer() -> void:
	var battle := MapBattleV2.new(91401)
	var caster := _actor("songdao_combo", "disciple", Vector2(3.0, 4.0))
	var target := _actor("songdao_dummy", "enemy", Vector2(5.0, 4.0))
	var skill_id := "tmb.skill.dual_blade.lien_hoan.active_02.human"
	caster["v63_dual_blade_combat_enabled"] = true
	caster["v63_skill_loadout"] = [skill_id]
	battle.actors[caster["id"]] = caster
	battle.actors[target["id"]] = target
	var before := float(target["hp"])
	_expect(HSC.try_cast(battle, caster, target, false), "Liên Hoàn is selected through the shared AI cast loop under explicit preview")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	_expect(not pending.is_empty(), "Liên Hoàn creates a normal Combat V2 pending cast")
	if pending.is_empty():
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var hits: Array = _events(battle, "v63_dual_blade_hit", skill_id)
	var committed_sum := 0.0
	for hit in hits:
		committed_sum += float(hit.get("damage", 0.0))
	_expect(hits.size() == 3 and float(target["hp"]) < before, "three real hit settlements are emitted and HP changes")
	_expect(is_equal_approx(committed_sum, before - float(target["hp"])), "per-hit VFX records sum exactly to committed target HP loss")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_skill_id == skill_id and renderer._cue_kind == "v63_dual_blade_hit", "Liên Hoàn renderer consumes the final actual-hit event")
	var draw_signal := {"seen":false}
	renderer.size = Vector2(128.0, 128.0)
	renderer.draw.connect(func(): draw_signal["seen"] = true)
	get_root().add_child(renderer)
	renderer.queue_redraw()
	await process_frame
	_expect(bool(draw_signal["seen"]), "Liên Hoàn motif reached Godot's real CanvasItem draw notification")
	renderer.queue_free()
	await process_frame

func _exercise_mobility_and_ai_range() -> void:
	var actor := _actor("songdao_mobility", "disciple", Vector2(2.0, 5.0))
	actor["v63_dual_blade_combat_enabled"] = true
	actor["v63_skill_loadout"] = ["tmb.skill.dual_blade.mobility.human", "tmb.skill.dual_blade.anh_nhan.active_02.human"]
	_expect(is_equal_approx(Dual.preferred_offensive_range(actor), 2.6), "AI holds the catalog offensive range and mobility does not pull it past melee range")
	var battle := MapBattleV2.new(91402)
	var target := _actor("songdao_mobility_dummy", "enemy", Vector2(5.0, 5.0))
	var origin: Vector2 = actor["position"]
	battle.actors[actor["id"]] = actor
	battle.actors[target["id"]] = target
	var mobility_id := "tmb.skill.dual_blade.anh_nhan.active_01.human"
	actor["v63_skill_loadout"] = [mobility_id]
	_expect(HSC.try_cast(battle, actor, target, false), "Ảnh Nhẫn mobility is cast via Combat V2's existing movement action")
	_expect(actor["position"] != origin and _has_event(battle, "v63_mobility", mobility_id), "candidate movement changes the actor position and emits an event")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_skill_id == mobility_id and renderer._cue_kind == "v63_mobility", "mobility VFX follows the real movement event")
	var draw_signal := {"seen":false}
	renderer.size = Vector2(128.0, 128.0)
	renderer.draw.connect(func(): draw_signal["seen"] = true)
	get_root().add_child(renderer)
	renderer.queue_redraw()
	await process_frame
	_expect(bool(draw_signal["seen"]), "Ảnh Nhẫn mobility reached Godot's real CanvasItem draw notification")
	renderer.queue_free()
	await process_frame

func _exercise_bounded_hp_trade() -> void:
	var skill_id := "tmb.skill.dual_blade.huyet_nguyet.active_02.human"
	var battle := MapBattleV2.new(91403)
	var caster := _actor("songdao_huyet", "disciple", Vector2(3.0, 4.0))
	var target := _actor("songdao_huyet_dummy", "enemy", Vector2(4.5, 4.0))
	caster["v63_dual_blade_combat_enabled"] = true
	caster["v63_skill_loadout"] = [skill_id]
	caster["hp"] = 100.0
	caster["stats"]["lifesteal"] = 0.5
	battle.actors[caster["id"]] = caster
	battle.actors[target["id"]] = target
	var target_before := float(target["hp"])
	_expect(HSC.try_cast(battle, caster, target, false), "Huyết Nguyệt chooses a costed attack while HP can pay")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	if pending.is_empty():
		_expect(false, "Huyết Nguyệt cast record exists")
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var trade_events := _events(battle, "v63_dual_blade_hp_trade", skill_id)
	_expect(float(target["hp"]) < target_before and trade_events.size() == 1, "HP trade occurs only after target receives real damage")
	if trade_events.size() == 1:
		var trade: Dictionary = trade_events[0]
		var expected_cost := float(caster["max_hp"]) * float(Dual.skill_definition(skill_id).get("health_cost_ratio", 0.0))
		_expect(float(trade.get("hp_before", 0.0)) > 100.0, "Combat V2 lifesteal occurs before the fixed HP price")
		_expect(is_equal_approx(float(trade.get("hp_cost", -1.0)), expected_cost) and is_equal_approx(float(trade.get("hp_after", 0.0)), float(trade.get("hp_before", 0.0)) - expected_cost), "trade charges its fixed cost once after lifesteal and preserves the price")
		_expect(is_equal_approx(float(caster["hp"]), float(trade.get("hp_after", -1.0))) and float(caster["hp"]) >= 1.0, "user survives and actor HP equals the committed trade event")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_kind == "v63_dual_blade_hp_trade" and renderer._cue_skill_id == skill_id, "blood crescent is cued only by an actual HP-cost event")
	var draw_signal := {"seen":false}
	renderer.size = Vector2(128.0, 128.0)
	renderer.draw.connect(func(): draw_signal["seen"] = true)
	get_root().add_child(renderer)
	renderer.queue_redraw()
	await process_frame
	_expect(bool(draw_signal["seen"]), "Huyết Nguyệt trade reached Godot's real CanvasItem draw notification")
	renderer.queue_free()
	await process_frame
	var weak := _actor("songdao_weak", "disciple", Vector2(3.0, 4.0))
	weak["v63_dual_blade_combat_enabled"] = true
	weak["v63_skill_loadout"] = [skill_id]
	weak["hp"] = 5.0
	var weak_battle := MapBattleV2.new(91404)
	var weak_target := _actor("songdao_weak_dummy", "enemy", Vector2(4.5, 4.0))
	weak_battle.actors[weak["id"]] = weak
	weak_battle.actors[weak_target["id"]] = weak_target
	_expect(not HSC.try_cast(weak_battle, weak, weak_target, false), "cast is refused if fixed cost would reduce the caster below one HP")
	_expect(is_equal_approx(float(weak["hp"]), 5.0) and is_equal_approx(float(weak_target["hp"]), 200.0), "unaffordable trade changes neither HP nor target")

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0, "wood":0.0, "water":0.0, "fire":0.0, "earth":0.0, "lightning":0.0, "wind":0.0, "ice":0.0, "yang":0.0, "nether":0.0}
	return {"id":actor_id, "side":side, "role":"melee", "position":position, "hp":200.0, "max_hp":200.0,
		"range":1.8, "move_speed":2.0, "stats":{"attack":40.0, "defense":0.0, "damage_reduction":0.0, "crit_chance":0.0, "crit_damage":1.5, "crit_resistance":0.0, "defense_penetration":0.0, "lifesteal":0.0, "lifesteal_reduction":0.0},
		"resistances":resistances, "status_effects":{}, "context_sources":[], "v63_combat_enabled":true,
		"v63_dual_blade_combat_enabled":false, "v63_skill_ready":{}, "v63_skill_loadout":[], "v63_passive_ids":[], "v63_combat_clock":-1.0, "next_skill":0.0}

func _events(battle: MapBattleV2, event_type: String, skill_id: String = "") -> Array:
	var result: Array = []
	for event in battle.events:
		if str(event.get("type", "")) == event_type and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id):
			result.append(event)
	return result

func _has_event(battle: MapBattleV2, event_type: String, skill_id: String = "") -> bool:
	return not _events(battle, event_type, skill_id).is_empty()

func _finish() -> void:
	if _failures > 0:
		print("V63_S4_DUAL_BLADE_RESULT FAIL checks=" + str(_checks) + " failures=" + str(_failures))
		quit(1)
		return
	print("V63_S4_DUAL_BLADE_RESULT PASS checks=" + str(_checks) + " nodes=183 families=35 branches=3 source=SOURCE_PENDING balance=CANDIDATE code_drawn_vfx=event_verified authored_asset=NOT_PRESENT render=NOT_CAPTURED gate=OFF")
	quit(0)
