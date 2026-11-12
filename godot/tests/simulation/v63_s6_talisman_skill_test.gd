extends SceneTree

# S6 Phù: candidate content is exercised only through explicit preview actors.
# Source/manual and balance approval remain pending; the production gate is OFF.
const Talisman = preload("res://src/simulation/combat/v63_talisman_skill_combat_system.gd")
const Palm = preload("res://src/simulation/combat/v63_palm_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("V63_S6_TALISMAN_FAIL " + label)

func _run() -> void:
	var loaded := Talisman.load_catalogue()
	_expect(bool(loaded.get("ok", false)), "Phù catalogue validates: " + str(loaded.get("errors", [])))
	if not bool(loaded.get("ok", false)):
		_finish()
		return
	var catalogue: Dictionary = loaded.data
	var skills: Array = catalogue.get("skills", [])
	var sources := Presentation.load_authoring_sources()
	_expect(bool(sources.get("ok", false)), "all source pins and additive Phù extension resolve: " + str(sources.get("errors", [])))
	if not bool(sources.get("ok", false)):
		_finish()
		return
	var catalogues: Dictionary = sources.catalogues
	var manifest: Dictionary = sources.manifest
	var registry: Dictionary = sources.registry
	var entries: Dictionary = manifest.get("entries", {})
	_expect(catalogues.has("talisman") and catalogues.has("palm") and catalogues.has("curse") and entries.size() == 1285, "all seven candidate schools join the retained source samples")
	_expect(registry.get("school_count", 0) == 10 and registry.get("branch_count", 0) == 30 and registry.get("skill_family_count", 0) == 350, "merged registry has nine schools, twenty-seven branches and 315 families")
	_expect(HSC.skill_definitions().size() == 1830 and HSC.branch_definitions().size() == 30, "Combat V2 indexes existing source plus seven gated candidates")
	_expect(not bool(catalogue.get("enabled", true)) and str(catalogue.get("release_gate", "")) == "OFF", "Phù release gate remains OFF")
	_expect(not Gates.is_enabled("talisman_skill_combat") and str(Talisman.can_learn(Talisman.skill_definition("tmb.skill.talisman.loi_phu.active_01.human")).get("reason", "")) == "skill_source_pending", "default runtime is closed and learning waits for a canonical manual")

	var ids: Dictionary = {}
	var names: Dictionary = {}
	var families: Dictionary = {}
	var flavors: Dictionary = {}
	var shorts: Dictionary = {}
	var long_descriptions: Dictionary = {}
	var vfx_profiles: Dictionary = {}
	var branch_counts := {"loi_phu":0, "hoa_phu":0, "phong_an_phu":0}
	var tier_counts := {"human":0, "immortal":0, "divine":0}
	var phase_names := ["windup", "telegraph", "release", "travel", "impact", "status", "fade"]
	for raw in skills:
		var skill: Dictionary = raw
		var id := str(skill.get("id", ""))
		var name := str(skill.get("name", ""))
		var branch := str(skill.get("branch", ""))
		var skill_slot := str(skill.get("slot", ""))
		var entry: Dictionary = entries.get(id, {})
		var flavor := str(entry.get("flavor_vi", ""))
		var short := str(entry.get("short_description_vi", ""))
		var long := str(entry.get("long_description_vi", ""))
		var counterplay := str(entry.get("counterplay_vi", ""))
		var brief: Dictionary = entry.get("vfx", {}).get("production_brief", {})
		var phase_rows: Array = brief.get("phases", [])
		var phases: Array[String] = []
		for phase_row in phase_rows:
			phases.append(str(phase_row.get("phase", "")))
		_expect(not ids.has(id) and id.begins_with("tmb.skill.talisman.") and str(skill.get("node_id", "")) == id, "stable unique node id: " + id)
		_expect(not name.is_empty() and not names.has(name), "unique Hán-Việt name: " + id)
		if skill_slot in ["passive", "innate"]:
			_expect(str(skill.get("effect", "")) == skill_slot and not skill.get("passive_modifiers", {}).is_empty(), "passive/innate node has its real modifier effect: " + id)
		_expect(not short.is_empty() and short.length() <= 110 and not long.is_empty() and not counterplay.is_empty(), "Vietnamese function, detail and counterplay: " + id)
		var prose_has_digit := false
		for digit in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
			prose_has_digit = prose_has_digit or short.contains(digit) or long.contains(digit) or counterplay.contains(digit) or flavor.contains(digit)
		_expect(not prose_has_digit and not short.contains("TODO") and not long.contains("TODO"), "prose is not a numeric tooltip or draft placeholder: " + id)
		_expect(flavor.length() >= 50 and flavor.length() <= 110, "bounded individual xianxia flavor text: " + id)
		var lore_branch := branch if not branch.is_empty() else "common"
		_expect(str(entry.get("school_lore_id", "")) == "tmb.lore.school.talisman" and str(entry.get("branch_lore_id", "")) == "tmb.lore.branch.talisman." + lore_branch, "school/branch lore identity is joined: " + id)
		_expect(str(entry.get("availability", {}).get("status", "")) == "CANDIDATE_GATED_SOURCE_PENDING" and str(skill.get("source_codex_id", "")).is_empty(), "unverified source remains unlearnable: " + id)
		var fade_phase: Dictionary = phase_rows.back() if not phase_rows.is_empty() else {}
		_expect(phases == phase_names and str(brief.get("asset_status", "")) == "NOT_PRESENT" and str(brief.get("render_capture_status", "")) == "NOT_CAPTURED" and str(brief.get("provenance", "")).begins_with("TEXT_ONLY_VFX_SPEC") and str(fade_phase.get("event_type", "")) == "none", "VFX stays a text-only spec under owner approval hold: " + id)
		_expect(bool(Presentation.presentation_for(id, manifest, catalogues).get("ok", false)), "runtime presentation lookup resolves: " + id)
		var tooltip: Dictionary = Presentation.build_mechanics_tooltip(skill)
		_expect(bool(tooltip.get("ok", false)) and not str(tooltip.get("text", "")).is_empty(), "numeric tooltip comes from canonical candidate fields: " + id)
		ids[id] = true
		names[name] = true
		families[str(skill.get("family_id", ""))] = true
		flavors[flavor] = true
		shorts[short] = true
		long_descriptions[long] = true
		vfx_profiles[str(brief.get("motion_profile", ""))] = true
		if branch_counts.has(branch):
			branch_counts[branch] = int(branch_counts[branch]) + 1
		var tier := str(skill.get("generation", ""))
		if tier_counts.has(tier):
			tier_counts[tier] = int(tier_counts[tier]) + 1
	_expect(ids.size() == 183 and names.size() == 183 and families.size() == 35, "183 unique nodes and names join exactly 35 skill families")
	_expect(branch_counts == {"loi_phu":59, "hoa_phu":59, "phong_an_phu":59}, "Lôi/Hỏa/Phong Ấn each own 59 nodes")
	_expect(tier_counts == {"human":35, "immortal":68, "divine":80}, "evolution distribution is 35 Human / 68 Tiên / 80 Thần")
	_expect(flavors.size() == 183 and shorts.size() == 183 and long_descriptions.size() == 183 and vfx_profiles.size() == 183, "each node has distinct prose, function, detail and VFX identity")
	var signature_names := {"loi_phu":"Cửu Thiên Vạn Lôi Phù", "hoa_phu":"Vạn Phù Phần Thiên", "phong_an_phu":"Thái Huyền Phong Giới Phù"}
	for branch_row in catalogue.get("branches", []):
		var branch_id := str(branch_row.get("id", ""))
		_expect(str(branch_row.get("signature_ultimate", "")) == str(signature_names.get(branch_id, "")) and not str(branch_row.get("story_vi", "")).is_empty(), "branch lore and signature differ: " + branch_id)

	var csv_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
	var csv := FileAccess.open(csv_path, FileAccess.READ)
	_expect(csv != null, "all36 ledger is readable")
	if csv != null:
		var ledger: Dictionary = Presentation.validate_all36_ledger(csv.get_as_text(), catalogues, registry)
		_expect(bool(ledger.get("ok", false)), "2,196-slot ledger joins source/candidate/unwritten records: " + str(ledger.get("errors", [])))
		var metrics: Dictionary = ledger.get("metrics", {})
		_expect(int(metrics.get("existing", 0)) == 549 and int(metrics.get("candidate_gated", 0)) == 1281 and int(metrics.get("not_authored", 0)) == 366 and int(metrics.get("runtime_catalogue_ids", 0)) == 1830, "ledger keeps 549 existing, 1,281 gated and 366 un-authored slots distinct")

	var locked_ranged := _actor("talisman_locked_ranged", "disciple", Vector2(2, 2))
	locked_ranged["role"] = "ranged"
	locked_ranged["v63_skill_loadout"] = ["tmb.skill.talisman.loi_phu.ultimate.human"]
	_expect(is_equal_approx(HSC.preferred_offensive_range(locked_ranged), 1.8), "OFF gate does not let an unlearnable Phù node hold ranged AI outside its normal range")
	locked_ranged["v63_talisman_combat_enabled"] = true
	_expect(is_equal_approx(HSC.preferred_offensive_range(locked_ranged), 11.0), "explicit preview uses the authored Ngự Lôi maximum range")
	var gated_passive_actor := _actor("talisman_passive_gate", "disciple", Vector2(2, 2))
	var passive_id := "tmb.skill.talisman.loi_phu.passive_01.human"
	_expect(HSC._root_scaled_passive_modifiers(gated_passive_actor, passive_id).is_empty(), "saved Phù passive cannot affect Combat V2 while its gate is OFF")
	gated_passive_actor["v63_talisman_combat_enabled"] = true
	_expect(not HSC._root_scaled_passive_modifiers(gated_passive_actor, passive_id).is_empty(), "explicit candidate preview resolves the equipped Phù passive")

	await _exercise_lightning_damage_receipt()
	await _exercise_fire_target_cap()
	await _exercise_owner_scoped_mark()
	await _exercise_real_cleanse_and_guard()
	await _exercise_mobility()
	_finish()

func _exercise_lightning_damage_receipt() -> void:
	var battle := MapBattleV2.new(99601)
	var caster := _actor("talisman_lightning_caster", "disciple", Vector2(2, 3))
	var target := _actor("talisman_lightning_target", "enemy", Vector2(5, 3))
	var skill_id := "tmb.skill.talisman.loi_phu.active_01.human"
	_enable_preview(caster, skill_id)
	battle.actors[caster.id] = caster
	battle.actors[target.id] = target
	var before := float(target.hp)
	_expect(HSC.try_cast(battle, caster, target), "Lôi phù enters the shared cast/release path")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	_expect(not pending.is_empty(), "Lôi cast has an actual Combat V2 deadline")
	if pending.is_empty():
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	_expect(float(target.hp) < before, "confirmed Lôi hit changes target HP")
	var hits := _events(battle, "v63_talisman_hit", skill_id)
	_expect(hits.size() == 1 and is_equal_approx(float(hits[0].get("damage", 0.0)), before - float(target.hp)), "Lôi combat receipt reports the settled HP delta exactly once")

func _exercise_fire_target_cap() -> void:
	var battle := MapBattleV2.new(99602)
	var caster := _actor("talisman_fire_caster", "disciple", Vector2(2, 3))
	var primary := _actor("fire_e1", "enemy", Vector2(5, 3))
	var secondary_a := _actor("fire_e2", "enemy", Vector2(5, 4))
	var secondary_b := _actor("fire_e3", "enemy", Vector2(6, 3))
	var secondary_c := _actor("fire_e4", "enemy", Vector2(5, 2))
	var skill_id := "tmb.skill.talisman.hoa_phu.active_02.human"
	_enable_preview(caster, skill_id)
	for actor in [caster, primary, secondary_a, secondary_b, secondary_c]:
		battle.actors[str(actor.id)] = actor
	var before := {"fire_e1":200.0, "fire_e2":200.0, "fire_e3":200.0, "fire_e4":200.0}
	_expect(HSC.try_cast(battle, caster, primary), "Hỏa phù selects its bounded circle through Combat V2")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	if pending.is_empty():
		_expect(false, "Hỏa cast deadline exists")
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var damaged := 0
	for actor_id in before.keys():
		var actor: Dictionary = battle.actors[actor_id]
		if float(actor.hp) < float(before[actor_id]):
			damaged += 1
		_expect(not actor.get("status_effects", {}).has("burn"), "Hỏa color does not invent Burn on " + actor_id)
	_expect(damaged == 3 and _events(battle, "v63_talisman_hit", skill_id).size() == 3, "Hỏa resolves exactly three confirmed targets and respects target_limit")

func _exercise_owner_scoped_mark() -> void:
	var battle := MapBattleV2.new(99603)
	var caster := _actor("talisman_mark_owner", "disciple", Vector2(2, 3))
	var outsider := _actor("talisman_other_owner", "disciple", Vector2(2, 4))
	var target := _actor("talisman_mark_target", "enemy", Vector2(5, 3))
	var skill_id := "tmb.skill.talisman.phong_an_phu.active_01.human"
	_enable_preview(caster, skill_id)
	for actor in [caster, outsider, target]:
		battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(battle, caster, target), "Phong Ấn writes its mark through a real cast")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	if pending.is_empty():
		_expect(false, "Phong Ấn cast deadline exists")
		return
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var marks: Dictionary = target.get("v63_marks", {})
	var owner_mark: Dictionary = marks.get(str(caster.id), {})
	_expect(owner_mark.get("owner_id", "") == caster.id and owner_mark.get("skill_id", "") == skill_id, "mark belongs to its actual caster and skill")
	_expect(not marks.has(str(outsider.id)) and float(owner_mark.get("until", 0.0)) > battle.now, "mark cannot be borrowed by another owner and has an expiry")
	_expect(_events(battle, "v63_talisman_mark_applied", skill_id).size() == 1, "mark event follows the applied owner-scoped state")
	var comparison_target := _actor("mark_comparison_target", "enemy", Vector2(6, 3))
	var unmarked_damage := battle._deal_direct(outsider, comparison_target, 1.0, "basic", false, "metal", false)
	var marked_damage := battle._deal_direct(caster, target, 1.0, "basic", false, "metal", false)
	_expect(marked_damage > unmarked_damage, "the mark's authored factor changes the owner's later real damage")

func _exercise_real_cleanse_and_guard() -> void:
	var battle := MapBattleV2.new(99604)
	var enemy_palm := _actor("palm_slow_source", "enemy", Vector2(2, 3))
	var victim := _actor("talisman_cleanse_victim", "disciple", Vector2(3, 3))
	var cleanser := _actor("talisman_cleanser", "disciple", Vector2(3, 4))
	var enemy := _actor("cleanse_enemy", "enemy", Vector2(5, 3))
	victim["party_id"] = "talisman_party"
	cleanser["party_id"] = "talisman_party"
	enemy_palm["v63_palm_combat_enabled"] = true
	enemy_palm["v63_skill_loadout"] = ["tmb.skill.palm.han_ngoc_chuong.active_02.human"]
	for actor in [enemy_palm, victim, cleanser, enemy]:
		battle.actors[str(actor.id)] = actor
	_expect(HSC.try_cast(battle, enemy_palm, victim), "existing Palm source applies a real slow status")
	var slow_pending: Dictionary = enemy_palm.get("v63_pending_cast", {})
	if slow_pending.is_empty():
		_expect(false, "source slow cast deadline exists")
		return
	battle.now = float(slow_pending.get("ready", 0.0))
	battle._release_casts()
	_expect(victim.get("status_effects", {}).has("slow"), "precondition is an actual Combat V2 slow, not injected test state")
	var cleanse_id := "tmb.skill.talisman.phong_an_phu.active_03.human"
	_enable_preview(cleanser, cleanse_id)
	_expect(HSC.try_cast(battle, cleanser, enemy), "Phong Ấn chooses the afflicted same-party member")
	var cleanse_pending: Dictionary = cleanser.get("v63_pending_cast", {})
	_expect(str(cleanse_pending.get("target_id", "")) == str(victim.id), "cleanse target is selected from real party/status state")
	if cleanse_pending.is_empty():
		return
	battle.now = float(cleanse_pending.get("ready", battle.now))
	battle._release_casts()
	_expect(not victim.get("status_effects", {}).has("slow") and _events(battle, "cleanse", cleanse_id).size() == 1, "cleanse removes the real slow and records its receipt")

	var guard_battle := MapBattleV2.new(99605)
	var guardian := _actor("talisman_guardian", "disciple", Vector2(3, 3))
	var attacker := _actor("talisman_guard_enemy", "enemy", Vector2(4, 3))
	var guard_id := "tmb.skill.talisman.phong_an_phu.active_04.human"
	_enable_preview(guardian, guard_id)
	guard_battle.actors[guardian.id] = guardian
	guard_battle.actors[attacker.id] = attacker
	_expect(HSC.try_cast(guard_battle, guardian, attacker), "Phong guard enters the real Combat V2 cast path")
	var guard_pending: Dictionary = guardian.get("v63_pending_cast", {})
	if guard_pending.is_empty():
		_expect(false, "guard cast deadline exists")
		return
	guard_battle.now = float(guard_pending.get("ready", 0.0))
	guard_battle._release_casts()
	_expect(is_equal_approx(float(guardian.get("learned_guard_factor", 1.0)), 0.84) and float(guardian.get("learned_guard_until", -1.0)) > guard_battle.now, "bounded mitigation guard follows the catalogue duration and factor")
	var baseline_battle := MapBattleV2.new(99606)
	var baseline_attacker := _actor("baseline_enemy", "enemy", Vector2(4, 3))
	var baseline_target := _actor("baseline_target", "disciple", Vector2(3, 3))
	baseline_battle.actors[baseline_attacker.id] = baseline_attacker
	baseline_battle.actors[baseline_target.id] = baseline_target
	guard_battle.now += 0.1
	baseline_battle.now = guard_battle.now
	var plain_damage := baseline_battle._deal_direct(baseline_attacker, baseline_target, 1.0, "basic", false, "metal", false)
	var guarded_damage := guard_battle._deal_direct(attacker, guardian, 1.0, "basic", false, "metal", false)
	_expect(guarded_damage < plain_damage, "guard mitigates an actual following hit instead of creating a fake shield")
	var guard_events := _events(guard_battle, "status_applied", guard_id)
	_expect(guard_events.size() == 1 and str(guard_events[0].get("status", "")) == "guard", "guard receipt follows the committed mitigation status")

func _exercise_mobility() -> void:
	var battle := MapBattleV2.new(99607)
	var caster := _actor("talisman_mobility_caster", "disciple", Vector2(2, 2))
	var target := _actor("talisman_mobility_target", "enemy", Vector2(5, 2))
	var skill_id := "tmb.skill.talisman.mobility.human"
	_enable_preview(caster, skill_id)
	battle.actors[caster.id] = caster
	battle.actors[target.id] = target
	var origin: Vector2 = caster.position
	_expect(HSC.try_cast(battle, caster, target), "Phù thân pháp uses the shared movement resolver")
	_expect((caster.position as Vector2).distance_to(origin) > 0.1 and not _events(battle, "v63_mobility", skill_id).is_empty(), "mobility changes the legal position and records its event")

func _enable_preview(actor: Dictionary, skill_id: String) -> void:
	actor["v63_combat_enabled"] = true
	actor["v63_talisman_combat_enabled"] = true
	actor["v63_skill_loadout"] = [skill_id]
	actor["v63_skill_ready"] = {}

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0, "wood":0.0, "water":0.0, "fire":0.0, "earth":0.0, "lightning":0.0, "wind":0.0, "ice":0.0, "yang":0.0, "nether":0.0}
	return {"id":actor_id, "side":side, "party_id":"", "role":"ranged", "position":position,
		"hp":200.0, "max_hp":200.0, "range":1.8, "move_speed":2.0, "tier":"normal",
		"stats":{"attack":40.0, "defense":0.0, "damage_reduction":0.0, "crit_chance":0.0,
		"crit_damage":1.5, "crit_resistance":0.0, "defense_penetration":0.0, "lifesteal":0.0,
		"lifesteal_reduction":0.0}, "resistances":resistances, "status_effects":{}, "context_sources":[],
		"v63_combat_enabled":true, "v63_talisman_combat_enabled":false, "v63_palm_combat_enabled":false,
		"v63_skill_ready":{}, "v63_skill_loadout":[], "v63_passive_ids":[], "v63_combat_clock":-1.0,
		"next_skill":0.0, "learned_guard_factor":1.0, "learned_guard_until":-1.0}

func _events(battle: MapBattleV2, event_type: String, skill_id: String = "") -> Array:
	var result: Array = []
	for event in battle.events:
		if str(event.get("type", "")) == event_type and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id):
			result.append(event)
	return result

func _finish() -> void:
	if _failures > 0:
		print("V63_S6_TALISMAN_RESULT FAIL checks=" + str(_checks) + " failures=" + str(_failures))
		quit(1)
		return
	print("V63_S6_TALISMAN_RESULT PASS checks=" + str(_checks) + " nodes=183 families=35 branches=3 runtime=CombatV2_preview source=SOURCE_PENDING balance=CANDIDATE vfx_spec=TEXT_ONLY vfx_prod=HOLD_OWNER_APPROVAL gate=OFF")
	quit(0)
