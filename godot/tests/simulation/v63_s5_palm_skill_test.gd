extends SceneTree

# S5 Chưởng candidate gate. Preview actors exercise real Combat V2 settlement,
# while source/manual, balance approval and production enablement remain OFF.
const Palm = preload("res://src/simulation/combat/v63_palm_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("V63_S5_PALM_FAIL " + label)

func _run() -> void:
	var loaded := Palm.load_catalogue()
	_expect(bool(loaded.get("ok", false)), "Chưởng catalogue validates: " + str(loaded.get("errors", [])))
	if not bool(loaded.get("ok", false)):
		_finish()
		return
	var catalogue: Dictionary = loaded.data
	var skills: Array = catalogue.get("skills", [])
	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var flavors: Dictionary = {}
	var shorts: Dictionary = {}
	var long_descriptions: Dictionary = {}
	var vfx_profiles: Dictionary = {}
	var branch_counts := {"liet_duong_chuong":0, "han_ngoc_chuong":0, "hoi_phong_chuong":0}
	var tier_counts := {"human":0, "immortal":0, "divine":0}
	var sources := Presentation.load_authoring_sources()
	_expect(bool(sources.get("ok", false)), "S0 source pins and additive Chưởng extension resolve: " + str(sources.get("errors", [])))
	if not bool(sources.get("ok", false)):
		_finish()
		return
	var catalogues: Dictionary = sources.catalogues
	var manifest: Dictionary = sources.manifest
	var registry: Dictionary = sources.registry
	var entries: Dictionary = manifest.get("entries", {})
	_expect(catalogues.has("palm") and catalogues.has("talisman") and catalogues.has("curse") and entries.size() == 1468, "the seven candidate-school extensions compose without collision")
	for raw in skills:
		var skill: Dictionary = raw
		var id := str(skill.get("id", ""))
		var entry: Dictionary = entries.get(id, {})
		var name := str(skill.get("name", ""))
		var flavor := str(entry.get("flavor_vi", ""))
		var short := str(entry.get("short_description_vi", ""))
		var long := str(entry.get("long_description_vi", ""))
		var counterplay := str(entry.get("counterplay_vi", ""))
		var brief: Dictionary = entry.get("vfx", {}).get("production_brief", {})
		_expect(not ids.has(id) and id.begins_with("tmb.skill.palm."), "stable unique skill id: " + id)
		_expect(not name.is_empty() and not names.has(name), "unique Hán-Việt name: " + id)
		_expect(not short.is_empty() and not long.is_empty() and not counterplay.is_empty(), "Vietnamese function, detail and counterplay: " + id)
		var prose_has_digit := false
		for digit in ["0","1","2","3","4","5","6","7","8","9"]:
			prose_has_digit = prose_has_digit or short.contains(digit) or long.contains(digit) or counterplay.contains(digit) or flavor.contains(digit)
		_expect(not prose_has_digit and not short.contains("TODO") and not long.contains("TODO"), "prose has no numeric token or draft marker: " + id)
		_expect(flavor.length() >= 50 and flavor.length() <= 110, "bounded individual xianxia flavor: " + id)
		_expect(str(entry.get("school_lore_id", "")) == "tmb.lore.school.palm" and str(entry.get("branch_lore_id", "")).begins_with("tmb.lore.branch.palm."), "school/branch story joins correctly: " + id)
		_expect(str(entry.get("availability", {}).get("status", "")) == "CANDIDATE_GATED_SOURCE_PENDING" and str(skill.get("source_codex_id", "")).is_empty(), "learning stays blocked without an authentic source manual: " + id)
		_expect(brief.get("phases", []).size() == 7 and str(brief.get("asset_status", "")) == "NOT_PRESENT" and str(brief.get("render_capture_status", "")) == "NOT_CAPTURED", "VFX phase profile is complete without falsely claiming authored art/render: " + id)
		_expect(bool(Presentation.presentation_for(id, manifest, catalogues).get("ok", false)), "runtime tooltip resolves: " + id)
		var mechanics_tooltip: Dictionary = Presentation.build_mechanics_tooltip(skill)
		_expect(bool(mechanics_tooltip.get("ok", false)) and not str(mechanics_tooltip.get("text", "")).is_empty(), "numeric tooltip derives from the exact runtime fields: " + id)
		ids[id] = true
		names[name] = true
		families[str(skill.get("family_id", ""))] = true
		flavors[flavor] = true
		shorts[short] = true
		long_descriptions[long] = true
		vfx_profiles[str(brief.get("motion_profile", ""))] = true
		var branch := str(skill.get("branch", ""))
		if branch_counts.has(branch):
			branch_counts[branch] = int(branch_counts[branch]) + 1
		var tier := str(skill.get("generation", ""))
		if tier_counts.has(tier):
			tier_counts[tier] = int(tier_counts[tier]) + 1
	_expect(ids.size() == 183 and names.size() == 183 and families.size() == 35, "183 unique names/IDs join 35 Chưởng families")
	_expect(branch_counts == {"liet_duong_chuong":59, "han_ngoc_chuong":59, "hoi_phong_chuong":59}, "each of three branches owns 59 nodes")
	_expect(tier_counts == {"human":35, "immortal":68, "divine":80}, "Human/Immortal/Divine distribution is 35/68/80")
	_expect(flavors.size() == 183 and shorts.size() == 183 and long_descriptions.size() == 183 and vfx_profiles.size() == 183, "every node has distinct flavor, function summary, detailed description and VFX key")
	_expect(int(registry.get("school_count", 0)) == 11 and int(registry.get("branch_count", 0)) == 33 and int(registry.get("skill_family_count", 0)) == 385, "additive registry reports eleven total schools, 33 branches and 350 families")
	_expect(HSC.skill_definitions().size() == 2013 and HSC.branch_definitions().size() == 33, "shared Combat V2 indexes compose existing plus eight candidate schools")
	_expect(not bool(catalogue.get("enabled", true)) and str(catalogue.get("release_gate", "")) == "OFF" and not Gates.is_enabled("palm_skill_combat"), "Palm release and global feature gates remain OFF")
	_expect(str(Palm.can_learn(Palm.skill_definition("tmb.skill.palm.han_ngoc_chuong.active_02.human")).get("reason", "")) == "skill_source_pending", "player learning remains blocked until canonical manual approval")
	var gate_actor := _actor("palm_gate_off", "disciple", Vector2(2, 2))
	_expect(not Palm.can_cast(gate_actor, "tmb.skill.palm.liet_duong_chuong.active_01.human"), "candidate actor cannot cast with default production gate")
	var csv_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
	var csv := FileAccess.open(csv_path, FileAccess.READ)
	_expect(csv != null, "all36 source/effect ledger remains readable")
	if csv != null:
		var ledger: Dictionary = Presentation.validate_all36_ledger(csv.get_as_text(), catalogues, registry)
		_expect(bool(ledger.get("ok", false)), "2,196-slot ledger joins eight candidate schools: " + str(ledger.get("errors", [])))
		var metrics: Dictionary = ledger.get("metrics", {})
		_expect(int(metrics.get("candidate_gated", 0)) == 1464 and int(metrics.get("not_authored", 0)) == 183 and int(metrics.get("runtime_catalogue_ids", 0)) == 2013, "ledger preserves existing, candidate and unauthored distinctions")
	await _exercise_slow_and_boss_resistance()
	await _exercise_heal_cleanse_and_vfx()
	await _exercise_capacity_guard()
	_finish()

func _exercise_slow_and_boss_resistance() -> void:
	var slow_id := "tmb.skill.palm.han_ngoc_chuong.active_02.human"
	var battle := MapBattleV2.new(99151)
	var caster := _actor("palm_slow_caster", "disciple", Vector2(3, 3))
	var target := _actor("palm_slow_target", "enemy", Vector2(5, 3))
	caster["v63_palm_combat_enabled"] = true
	caster["v63_skill_loadout"] = [slow_id]
	# An expired stronger effect must not block this new, weaker Palm slow.
	target["status_effects"]["slow"] = {"movement_factor":0.50, "until":-0.1}
	battle.actors[caster.id] = caster
	battle.actors[target.id] = target
	_expect(HSC.try_cast(battle, caster, target), "Hàn Ngọc enters the shared Combat V2 cast path")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	_expect(not pending.is_empty(), "slow creates a normal pending cast")
	if pending.is_empty():
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var slow: Dictionary = target.get("status_effects", {}).get("slow", {})
	_expect(str(slow.get("skill_id", "")) == slow_id and is_equal_approx(float(slow.get("movement_factor", 1.0)), 0.76), "real hit replaces the expired slow without stacking or losing provenance")
	_expect(is_equal_approx(battle._effective_move_speed(target), float(target.move_speed) * 0.76), "active slow changes the pathing speed actually used by MapBattleV2")
	_expect(not _events(battle, "v63_palm_slow_applied", slow_id).is_empty(), "slow event appears only after real damage settlement")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_kind == "v63_palm_slow_applied" and renderer._cue_skill_id == slow_id, "slow renderer chooses the committed Palm status event over generic hit")
	await _draw_renderer(renderer, "Hàn Ngọc event reaches CanvasItem draw")
	var boss_battle := MapBattleV2.new(99152)
	var boss_caster := _actor("palm_boss_slow_caster", "disciple", Vector2(3, 3))
	var boss := _actor("palm_slow_boss", "enemy", Vector2(5, 3))
	boss["tier"] = "boss"
	boss_caster["v63_palm_combat_enabled"] = true
	boss_caster["v63_skill_loadout"] = [slow_id]
	boss_battle.actors[boss_caster.id] = boss_caster
	boss_battle.actors[boss.id] = boss
	_expect(HSC.try_cast(boss_battle, boss_caster, boss), "boss-resisted Palm slow casts normally")
	var boss_pending: Dictionary = boss_caster.get("v63_pending_cast", {})
	if not boss_pending.is_empty():
		boss_battle.now = float(boss_pending.get("ready", 0.0))
		boss_battle._release_casts()
		var boss_slow: Dictionary = boss.get("status_effects", {}).get("slow", {})
		_expect(bool(boss_slow.get("boss_resisted", false)) and is_equal_approx(float(boss_slow.get("movement_factor", 1.0)), 0.916), "boss resistance weakens slow instead of hard-stunning")
		_expect(is_equal_approx(float(boss_slow.get("until", 0.0)), boss_battle.now + 0.96), "boss resistance shortens the application duration")
	else:
		_expect(false, "boss cast record exists")

func _exercise_heal_cleanse_and_vfx() -> void:
	var battle := MapBattleV2.new(99153)
	var healer := _actor("palm_healer", "disciple", Vector2(3, 4))
	var ally := _actor("palm_wounded_ally", "disciple", Vector2(4, 4))
	var foe := _actor("palm_heal_foe", "enemy", Vector2(5, 4))
	healer["party_id"] = "palm_party"
	ally["party_id"] = "palm_party"
	ally["hp"] = 100.0
	healer["v63_palm_combat_enabled"] = true
	healer["v63_skill_loadout"] = ["tmb.skill.palm.hoi_phong_chuong.active_01.human"]
	for actor in [healer, ally, foe]:
		battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(battle, healer, foe), "Hồi Phong chooses an injured real same-party ally")
	var pending: Dictionary = healer.get("v63_pending_cast", {})
	if pending.is_empty():
		_expect(false, "heal pending cast exists")
		return
	_expect(str(pending.get("target_id", "")) == str(ally.id), "support selection honors same-party target identity")
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	_expect(is_equal_approx(float(ally.hp), 120.0), "heal changes real HP by the catalogued amount and respects max HP")
	var heal_events := _events(battle, "heal", "tmb.skill.palm.hoi_phong_chuong.active_01.human")
	_expect(heal_events.size() == 1 and is_equal_approx(float(heal_events[0].get("amount", 0.0)), 20.0), "heal receipt matches the committed HP delta")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_kind == "heal" and renderer._cue_skill_id == "tmb.skill.palm.hoi_phong_chuong.active_01.human", "heal cue follows the actual heal event rather than the generic hit")
	await _draw_renderer(renderer, "Hồi Phong heal reaches CanvasItem draw")
	# Generate a real slow debuff with an enemy Palm cast, then remove that exact state.
	var debuff_battle := MapBattleV2.new(99154)
	var enemy_palm := _actor("palm_enemy", "enemy", Vector2(3, 4))
	var victim := _actor("palm_victim", "disciple", Vector2(4, 4))
	var cleaner := _actor("palm_cleanser", "disciple", Vector2(4, 5))
	var ally_foe := _actor("palm_cleanse_foe", "enemy", Vector2(5, 4))
	cleaner["party_id"] = "cleanse_party"
	victim["party_id"] = "cleanse_party"
	enemy_palm["v63_palm_combat_enabled"] = true
	enemy_palm["v63_skill_loadout"] = ["tmb.skill.palm.han_ngoc_chuong.active_02.human"]
	for actor in [enemy_palm, victim, cleaner, ally_foe]:
		debuff_battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(debuff_battle, enemy_palm, victim), "enemy Palm applies a real slow through combat")
	var slow_pending: Dictionary = enemy_palm.get("v63_pending_cast", {})
	if slow_pending.is_empty():
		_expect(false, "debuff slow pending exists")
		return
	debuff_battle.now = float(slow_pending.get("ready", 0.0))
	debuff_battle._release_casts()
	_expect(victim.get("status_effects", {}).has("slow"), "precondition slow exists from a committed hit")
	cleaner["v63_palm_combat_enabled"] = true
	cleaner["v63_skill_loadout"] = ["tmb.skill.palm.hoi_phong_chuong.active_03.human"]
	_expect(HSC.try_cast(debuff_battle, cleaner, ally_foe), "cleanser selects an eligible same-party ally carrying an actual debuff")
	var cleanse_pending: Dictionary = cleaner.get("v63_pending_cast", {})
	if cleanse_pending.is_empty():
		_expect(false, "cleanse pending exists")
		return
	_expect(str(cleanse_pending.get("target_id", "")) == str(victim.id), "cleanse targets the afflicted ally")
	debuff_battle.now = float(cleanse_pending.get("ready", debuff_battle.now))
	debuff_battle._release_casts()
	_expect(not victim.get("status_effects", {}).has("slow"), "cleanse removes the real slow status")
	_expect(not _events(debuff_battle, "cleanse", "tmb.skill.palm.hoi_phong_chuong.active_03.human").is_empty(), "cleanse event records committed status removal")
	var cleanse_renderer := Vfx.new()
	cleanse_renderer.consume_battle_events(debuff_battle)
	_expect(cleanse_renderer._cue_kind == "cleanse", "cleanse cue tracks actual status removal")
	await _draw_renderer(cleanse_renderer, "Hồi Phong cleanse reaches CanvasItem draw")

func _exercise_capacity_guard() -> void:
	var battle := MapBattleV2.new(99155)
	var guardian := _actor("palm_guardian", "disciple", Vector2(3, 3))
	var ally := _actor("palm_guarded_ally", "disciple", Vector2(4, 3))
	var enemy := _actor("palm_guard_enemy", "enemy", Vector2(5, 3))
	guardian["party_id"] = "guard_party"
	ally["party_id"] = "guard_party"
	ally["hp"] = 80.0
	enemy["stats"]["attack"] = 10.0
	guardian["v63_palm_combat_enabled"] = true
	guardian["v63_skill_loadout"] = ["tmb.skill.palm.hoi_phong_chuong.active_04.human"]
	for actor in [guardian, ally, enemy]:
		battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(battle, guardian, enemy), "Hồi Phong selects the weakest same-party ally for guard")
	var pending: Dictionary = guardian.get("v63_pending_cast", {})
	if pending.is_empty():
		_expect(false, "guard pending cast exists")
		return
	_expect(str(pending.get("target_id", "")) == str(ally.id), "capacity shield target is the wounded ally")
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var initial_capacity := float(ally.get("v63_capacity_shield_remaining", 0.0))
	_expect(is_equal_approx(initial_capacity, 20.0) and float(ally.get("v63_capacity_shield_until", -1.0)) > battle.now, "guard creates the catalogued finite shield and expiry")
	var before_hp := float(ally.hp)
	var absorbed := battle._deal_direct(enemy, ally, 1.0, "basic", false, "metal", false)
	_expect(is_equal_approx(absorbed, 0.0) and is_equal_approx(float(ally.hp), before_hp), "real hit is absorbed by capacity before HP")
	_expect(not _events(battle, "v63_palm_guard_absorbed", "tmb.skill.palm.hoi_phong_chuong.active_04.human").is_empty(), "capacity consumption emits a Palm-specific committed event")
	var renderer := Vfx.new()
	renderer.consume_battle_events(battle)
	_expect(renderer._cue_kind == "v63_palm_guard_absorbed", "shield renderer follows actual absorbed damage")
	await _draw_renderer(renderer, "Hồi Phong guard reaches CanvasItem draw")

func _draw_renderer(renderer: Control, label: String) -> void:
	renderer.size = Vector2(128, 128)
	var drew := {"value":false}
	renderer.draw.connect(func(): drew["value"] = true)
	get_root().add_child(renderer)
	renderer.queue_redraw()
	await process_frame
	_expect(bool(drew.value), label)
	renderer.queue_free()
	await process_frame

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0, "wood":0.0, "water":0.0, "fire":0.0, "earth":0.0, "lightning":0.0, "wind":0.0, "ice":0.0, "yang":0.0, "nether":0.0}
	return {"id":actor_id, "side":side, "party_id":"", "role":"melee", "position":position,
		"hp":200.0, "max_hp":200.0, "range":1.8, "move_speed":2.0, "tier":"normal",
		"stats":{"attack":40.0, "defense":0.0, "damage_reduction":0.0, "crit_chance":0.0,
		"crit_damage":1.5, "crit_resistance":0.0, "defense_penetration":0.0, "lifesteal":0.0,
		"lifesteal_reduction":0.0}, "resistances":resistances, "status_effects":{},
		"context_sources":[], "v63_combat_enabled":true, "v63_palm_combat_enabled":false,
		"v63_skill_ready":{}, "v63_skill_loadout":[], "v63_passive_ids":[],
		"v63_combat_clock":-1.0, "next_skill":0.0}

func _events(battle: MapBattleV2, event_type: String, skill_id: String = "") -> Array:
	var result: Array = []
	for event in battle.events:
		if str(event.get("type", "")) == event_type and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id):
			result.append(event)
	return result

func _finish() -> void:
	if _failures > 0:
		print("V63_S5_PALM_RESULT FAIL checks=" + str(_checks) + " failures=" + str(_failures))
		quit(1)
		return
	print("V63_S5_PALM_RESULT PASS checks=" + str(_checks) + " nodes=183 families=35 branches=3 source=SOURCE_PENDING balance=CANDIDATE code_drawn_vfx=event_verified authored_asset=NOT_PRESENT render=NOT_CAPTURED gate=OFF")
	quit(0)
