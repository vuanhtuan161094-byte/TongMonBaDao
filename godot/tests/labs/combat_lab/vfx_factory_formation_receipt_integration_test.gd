extends SceneTree

const FACTORY_SCENE := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn")
const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const FORMATION := preload("res://src/simulation/combat/v63_formation_skill_combat_system.gd")
const MAP_BATTLE := preload("res://src/simulation/combat/map_battle_v2.gd")
const CAST_FOOT := Vector2(300.0, 492.0)
const TARGET_FOOT := Vector2(690.0, 492.0)

var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("VFX_FACTORY_FORMATION_RECEIPT_FAIL " + note)

func _run() -> void:
	_check(await _exercise("tmb.skill.formation.phong_toa_tran.active_01.human", "slow"),
		"real slow receipt binds")
	_check(await _exercise("tmb.skill.formation.sat_phat_tran.active_01.human", "zone"),
		"real formation zone create/tick receipts bind")
	_check(await _exercise("tmb.skill.formation.sat_phat_tran.active_03.human", "damage"),
		"real damage receipt binds")
	_check(await _exercise("tmb.skill.formation.tu_linh_tran.active_01.human", "guard"),
		"real guard receipt binds to actual protected ally")
	_check(await _exercise("tmb.skill.formation.mobility.human", "mobility"),
		"real mobility receipt binds without inventing relocation art")
	_check(await _exercise("tmb.skill.formation.basic.human", "basic"),
		"real basic-hit receipt binds through the actor's exact basic-skill loadout")
	print("VFX_FACTORY_FORMATION_RECEIPT_RESULT=" + ("PASS" if failures == 0 else "FAIL")
		+ " checks=" + str(checks) + " mechanics=6 synthetic_events=0 failures=" + str(failures))
	quit(0 if failures == 0 else 1)

func _exercise(skill_id: String, mechanic: String) -> bool:
	var battle: MapBattleV2 = MAP_BATTLE.new(77190 + checks)
	battle.encounter_id = "vfx_factory_receipt_" + mechanic
	battle.active = true
	battle.outcome = "fighting"
	var caster := _actor("caster_" + mechanic, "disciple", Vector2(2.0, 3.0))
	caster["party_id"] = "vfx_factory_party"
	_enable_preview(caster, skill_id)
	var ally := _actor("ally_" + mechanic, "disciple", Vector2(4.0, 3.0))
	ally["party_id"] = "vfx_factory_party"
	var foe_position := Vector2(5.0, 3.0)
	if mechanic == "mobility":
		foe_position = Vector2(9.0, 3.0)
	elif mechanic == "basic":
		foe_position = Vector2(3.8, 3.0)
	var foe := _actor("foe_" + mechanic, "monster", foe_position)
	for actor in [caster, ally, foe]:
		battle.actors[str(actor.id)] = actor
	var started := false
	if mechanic == "basic":
		var basic_definition: Dictionary = HSC.skill_definition(skill_id)
		caster["v63_basic_skill_id"] = skill_id
		caster["basic_ratio"] = float(basic_definition.get("damage_ratio", 0.0))
		caster["basic_element"] = str(basic_definition.get("element", "earth"))
		caster["range"] = float(basic_definition.get("range", 2.1))
		battle.step()
		started = true
	else:
		started = HSC.try_cast(battle, caster, foe)
	if not started:
		return false
	if mechanic != "mobility" and mechanic != "basic":
		var pending: Dictionary = caster.get("v63_pending_cast", {})
		if pending.is_empty():
			return false
		battle.now = float(pending.get("ready", battle.now))
		battle._release_casts()
	if mechanic == "zone":
		var zones: Array = caster.get("v63_formation_zones", [])
		if zones.is_empty():
			return false
		battle.now = float(zones[0].get("next_tick", battle.now + 1.0))
		FORMATION.process_zones(battle)

	var lab := FACTORY_SCENE.instantiate() as Node2D
	lab.call("review_set_skill_id", skill_id)
	root.add_child(lab)
	await process_frame
	_check(bool(lab.call("review_begin_encounter", battle.encounter_id)), "real encounter opened " + mechanic)
	lab.call("review_record_actor_screen_position", str(caster.id), CAST_FOOT)
	lab.call("review_record_actor_screen_position", str(ally.id), TARGET_FOOT)
	lab.call("review_record_actor_screen_position", str(foe.id), TARGET_FOOT)
	var accepted := 0
	var key_types: Array = {
		"slow":["v63_formation_slow_applied"],
		"zone":["v63_formation_zone_created", "v63_formation_zone_tick"],
		"damage":["v63_skill_hit"],
		"guard":["status_applied"],
		"mobility":["v63_mobility"],
		"basic":["hit"]
	}.get(mechanic, [])
	var target_offset := 0.0
	for raw_event in battle.events:
		var event: Dictionary = raw_event
		var event_type := str(event.get("type", ""))
		if event_type not in key_types:
			continue
		var is_exact_basic := mechanic == "basic" and event_type == "hit" \
			and str(event.get("kind", "")) == "basic" \
			and str(event.get("attacker", "")) == str(caster.id) \
			and str(caster.get("v63_basic_skill_id", "")) == skill_id
		if str(event.get("skill_id", "")) != skill_id and not is_exact_basic:
			continue
		var target_id := str(event.get("target_id", event.get("target", event.get("zone_id", event.get("actor_id", "")))))
		if not target_id.is_empty():
			lab.call("review_record_actor_screen_position", target_id, TARGET_FOOT + Vector2(target_offset, 0.0))
			target_offset += 18.0
		var result: Dictionary
		if is_exact_basic:
			result = lab.call("review_feed_authoritative_basic_hit", event, skill_id, str(caster.id))
		else:
			result = lab.call("review_feed_authoritative_event", event)
		if bool(result.get("ok", false)):
			accepted += 1
		if mechanic == "zone" and event_type == "v63_formation_zone_created":
			var zone_id := str(event.get("zone_id", ""))
			if not zone_id.is_empty():
				lab.call("review_record_actor_screen_position", zone_id, TARGET_FOOT)
	var state: Dictionary = lab.call("review_state")
	var state_ok := false
	match mechanic:
		"slow", "guard", "zone":
			state_ok = int(state.get("persistent_receipt_target_count", 0)) > 0
		"damage", "mobility", "basic":
			state_ok = int(state.get("contact_receipt_target_count", 0)) > 0
	_check(accepted > 0 and state_ok, "actual MapBattle receipts accepted for " + mechanic)
	lab.queue_free()
	await process_frame
	return accepted > 0 and state_ok

func _enable_preview(actor: Dictionary, skill_id: String) -> void:
	actor["v63_combat_enabled"] = true
	actor["v63_formation_combat_enabled"] = true
	actor["v63_skill_loadout"] = [skill_id]
	actor["v63_skill_ready"] = {}

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
		"lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
	var actor := {"id":actor_id,"side":side,"party_id":"","role":"ranged","position":position,
		"hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
		"stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
			"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,
		"v63_formation_combat_enabled":false,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0,"next_basic":0.0,
		"learned_guard_factor":1.0,"learned_guard_until":-1.0}
	if side == "monster":
		actor["race_id"] = "yeu_thu"
	return actor
