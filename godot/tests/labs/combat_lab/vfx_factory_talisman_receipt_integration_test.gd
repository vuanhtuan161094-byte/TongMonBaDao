extends SceneTree

## School-level fixture: only real MapBattleV2 events may trigger Talisman art.

const FACTORY_SCENE := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn")
const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const MAP_BATTLE := preload("res://src/simulation/combat/map_battle_v2.gd")
const REGISTRY_PATH := "res://labs/combat_lab/vfx_factory/registry.json"
const SKILL_IDS := [
	"tmb.skill.talisman.basic.human",
	"tmb.skill.talisman.loi_phu.active_02.human",
	"tmb.skill.talisman.loi_phu.active_03.human",
	"tmb.skill.talisman.loi_phu.active_04.human",
	"tmb.skill.talisman.loi_phu.ultimate.human",
	"tmb.skill.talisman.hoa_phu.active_02.human",
	"tmb.skill.talisman.hoa_phu.active_03.human",
	"tmb.skill.talisman.hoa_phu.active_04.human",
	"tmb.skill.talisman.hoa_phu.ultimate.human",
	"tmb.skill.talisman.mobility.human"
]
const CAST_FOOT := Vector2(300.0, 492.0)
const TARGET_FOOT := Vector2(690.0, 492.0)

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, note: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("VFX_FACTORY_TALISMAN_RECEIPT_FAIL " + note)

func _run() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	_check(parsed is Dictionary, "shared registry parses")
	if not (parsed is Dictionary):
		_finish()
		return
	var entries: Dictionary = {}
	for raw in parsed.get("entries", []):
		if raw is Dictionary and str(raw.get("school", "")) == "talisman":
			entries[str(raw.get("skill_id", ""))] = raw
	_check(entries.size() == SKILL_IDS.size(), "all source-backed Talisman skills share this runner")
	for index in range(SKILL_IDS.size()):
		var skill_id: String = SKILL_IDS[index]
		_check(entries.has(skill_id), "registry row exists " + skill_id)
		if not entries.has(skill_id):
			continue
		_check(await _exercise(skill_id, entries[skill_id], index), "real cast/release receipt binds " + skill_id)
	_finish()

func _exercise(skill_id: String, config: Dictionary, fixture_index: int) -> bool:
	var battle: MapBattleV2 = MAP_BATTLE.new(99020 + fixture_index)
	battle.encounter_id = "vfx_factory_talisman_receipt_%02d" % fixture_index
	battle.active = true
	battle.outcome = "fighting"
	var caster := _actor("talisman_caster_%02d" % fixture_index, "disciple", Vector2(2.0, 3.0))
	var caster_origin: Vector2 = caster.get("position", Vector2(2.0, 3.0))
	caster["v63_combat_enabled"] = true
	caster["v63_talisman_combat_enabled"] = true
	caster["v63_skill_loadout"] = [skill_id]
	var foes: Array[Dictionary] = []
	for i in range(3):
		var foe := _actor("talisman_foe_%02d_%d" % [fixture_index, i], "monster", Vector2(5.0 + float(i), 3.0))
		foes.append(foe)
		battle.actors[str(foe.id)] = foe
	battle.actors[str(caster.id)] = caster
	var is_basic := skill_id == "tmb.skill.talisman.basic.human"
	var is_mobility := skill_id == "tmb.skill.talisman.mobility.human"
	var cast_started := false
	if is_basic:
		var basic_definition: Dictionary = HSC.skill_definition(skill_id)
		caster["v63_basic_skill_id"] = skill_id
		caster["basic_ratio"] = float(basic_definition.get("damage_ratio", 0.0))
		caster["basic_element"] = str(basic_definition.get("element", "wind"))
		caster["range"] = float(basic_definition.get("range", 1.8))
		caster["basic_range"] = float(basic_definition.get("range", 1.8))
		battle.step()
		cast_started = true
	else:
		cast_started = HSC.try_cast(battle, caster, foes[0])
	_check(cast_started, "Combat V2 accepts candidate fixture cast " + skill_id)
	if not cast_started:
		return false
	if is_basic or is_mobility:
		_check(not battle.events.is_empty(), "immediate basic/mobility receipt exists " + skill_id)
	else:
		var pending: Dictionary = caster.get("v63_pending_cast", {})
		_check(not pending.is_empty(), "real pending cast exists " + skill_id)
		if pending.is_empty():
			return false
		battle.now = float(pending.get("ready", battle.now))
		battle._release_casts()

	var lab := FACTORY_SCENE.instantiate() as Node2D
	lab.call("review_set_skill_id", skill_id)
	root.add_child(lab)
	await process_frame
	var opened := bool(lab.call("review_begin_encounter", battle.encounter_id))
	lab.call("review_record_actor_screen_position", str(caster.id), CAST_FOOT)
	for i in range(foes.size()):
		lab.call("review_record_actor_screen_position", str(foes[i].id), TARGET_FOOT + Vector2(float(i) * 20.0, 0.0))
	var accepted := 0
	var bindings: Array = config.get("receipt_manifest", {}).get("bindings", [])
	var allowed_types: Array[String] = []
	for binding in bindings:
		var event_type := str(binding.get("event_type", ""))
		if not allowed_types.has(event_type):
			allowed_types.append(event_type)
	for raw_event in battle.events:
		if not (raw_event is Dictionary):
			continue
		var event: Dictionary = raw_event
		var is_basic_hit := is_basic and str(event.get("type", "")) == "hit" \
			and str(event.get("kind", "")) == "basic" \
			and str(event.get("attacker", "")) == str(caster.id) \
			and str(caster.get("v63_basic_skill_id", "")) == skill_id
		if not (str(event.get("skill_id", "")) == skill_id or is_basic_hit) \
			or not allowed_types.has(str(event.get("type", ""))):
			continue
		if is_mobility and str(event.get("type", "")) == "v63_mobility":
			var destination: Variant = event.get("position", caster.get("position", caster_origin))
			if destination is Vector2:
				var destination_screen := _world_to_screen(destination)
				lab.call("review_set_caster_screen_position", destination_screen)
				lab.call("review_record_actor_screen_position", str(caster.id), destination_screen)
		var target_id := str(event.get("target_id", event.get("target", "")))
		if not target_id.is_empty():
			for foe in foes:
				if str(foe.id) == target_id:
					var pos: Vector2 = foe.get("position", Vector2.ZERO)
					lab.call("review_record_actor_screen_position", target_id,
						TARGET_FOOT + Vector2((pos.x - 5.0) * 20.0, 0.0))
		var result: Dictionary
		if is_basic_hit:
			result = lab.call("review_feed_authoritative_basic_hit", event, skill_id, str(caster.id))
		else:
			result = lab.call("review_feed_authoritative_event", event)
		if bool(result.get("ok", false)):
			accepted += 1
	var state: Dictionary = lab.call("review_state")
	var required_receipts := 1 if is_basic or is_mobility else 2
	_check(opened and accepted >= required_receipts, "actual exact-skill receipts bind " + skill_id)
	if str(HSC.skill_definition(skill_id).get("effect", "")) == "mark":
		_check(int(state.get("persistent_receipt_target_count", 0)) == 1
			and is_equal_approx(float(state.get("receipt_duration", 0.0)), 6.0),
			"actual owner-scoped mark receipt controls full six-second sustain and end " + skill_id)
		_check(int(state.get("contact_receipt_target_count", 0)) == 0,
			"mark art is not relabelled as damage contact " + skill_id)
	elif is_mobility:
		var mobility_events := 0
		for event in battle.events:
			if str(event.get("type", "")) == "v63_mobility" and str(event.get("skill_id", "")) == skill_id:
				mobility_events += 1
		_check(mobility_events == 1 and (caster.get("position", caster_origin) as Vector2).distance_to(caster_origin) > 0.1,
			"exact mobility receipt follows the real caster destination " + skill_id)
		_check(int(state.get("persistent_receipt_target_count", 0)) == 1
			and is_equal_approx(float(state.get("receipt_duration", 0.0)), 0.25),
			"mobility start/sustain/end is bound to v63_mobility.evasion_until " + skill_id)
		_check(int(state.get("contact_receipt_target_count", 0)) == 0,
			"mobility cue never becomes a damage contact " + skill_id)
	else:
		var actual_hit_targets: Array[String] = []
		for event in battle.events:
			var is_damage_receipt := str(event.get("skill_id", "")) == skill_id \
				and str(event.get("type", "")) == "v63_talisman_hit"
			if is_basic:
				is_damage_receipt = str(event.get("type", "")) == "hit" \
					and str(event.get("kind", "")) == "basic" \
					and str(event.get("attacker", "")) == str(caster.id)
			if is_damage_receipt:
				var raw_target_ids: Variant = event.get("target_ids", [])
				if raw_target_ids is Array and not raw_target_ids.is_empty():
					for raw_target_id in raw_target_ids:
						var target_id := str(raw_target_id)
						if not target_id.is_empty() and not actual_hit_targets.has(target_id):
							actual_hit_targets.append(target_id)
				else:
					var target_id := str(event.get("target_id", event.get("target", "")))
					if not target_id.is_empty() and not actual_hit_targets.has(target_id):
						actual_hit_targets.append(target_id)
		_check(int(state.get("contact_receipt_target_count", 0)) == actual_hit_targets.size(),
			"damage contact count equals unique targets in exact real hit receipts, with no fabricated contacts " + skill_id)
	lab.queue_free()
	await process_frame
	return opened and accepted >= required_receipts

func _world_to_screen(world_position: Vector2) -> Vector2:
	return Vector2(CAST_FOOT.x + (world_position.x - 2.0) * 130.0,
		CAST_FOOT.y + (world_position.y - 3.0) * 48.0)

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
		"lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
	return {"id":actor_id,"side":side,"party_id":"","role":"ranged","position":position,
		"hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
		"stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
			"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,
		"v63_talisman_combat_enabled":false,"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0,"next_basic":0.0,
		"learned_guard_factor":1.0,"learned_guard_until":-1.0,"race_id":"yeu_thu" if side == "monster" else ""}

func _finish() -> void:
	print("VFX_FACTORY_TALISMAN_RECEIPT_RESULT=" + ("PASS" if _failures == 0 else "FAIL")
		+ " skills=10 checks=" + str(_checks) + " synthetic_events=0 failures=" + str(_failures))
	quit(0 if _failures == 0 else 1)
