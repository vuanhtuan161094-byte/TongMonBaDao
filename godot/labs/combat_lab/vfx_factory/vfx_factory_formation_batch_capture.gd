extends Node2D
## Native 1280×720 batch capture. Each scene uses one real MapBattleV2 test
## fixture; only its emitted, exact-skill events can trigger contact/status art.

const FACTORY_SCENE := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn")
const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const FORMATION := preload("res://src/simulation/combat/v63_formation_skill_combat_system.gd")
const MAP_BATTLE := preload("res://src/simulation/combat/map_battle_v2.gd")
const REGISTRY_PATH := "res://labs/combat_lab/vfx_factory/registry.json"
const CAST_FOOT := Vector2(300.0, 492.0)
const TARGET_FOOT := Vector2(690.0, 492.0)

var _school := "formation"
var _entries: Array[Dictionary] = []
var _index := 0
var _lab: Node2D
var _battle: MapBattleV2
var _caster_id := ""
var _events: Array[Dictionary] = []
var _event_index := 0
var _event_origin_time := 0.0
var _segment_elapsed := 0.0
var _segment_duration := 1.4
var _global_elapsed := 0.0
var _segment_start := 0.0
var _records: Array[Dictionary] = []
var _index_output_path := ""
var _finished := false

func _ready() -> void:
	get_window().size = Vector2i(1280, 720)
	_index_output_path = _read_user_argument("--tmb-vfx-index=", "")
	_school = _read_user_argument("--tmb-vfx-school=", "formation").strip_edges().to_lower()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (parsed is Dictionary):
		push_error("VFX_FACTORY_BATCH_REGISTRY_INVALID")
		_finish()
		return
	for raw in parsed.get("entries", []):
		if raw is Dictionary and str(raw.get("school", "")) == _school \
				and str(raw.get("native_batch", "")) == _school:
			_entries.append(raw)
	var expected_count := int(parsed.get("native_batches", {}).get(_school, {}).get("expected_count", 0))
	if _entries.is_empty() or (_school == "formation" and _entries.size() != 17) \
			or (_school != "formation" and expected_count > 0 and _entries.size() != expected_count):
		push_error("VFX_FACTORY_BATCH_ENTRY_COUNT_INVALID school=" + _school + " actual=" + str(_entries.size()))
		_finish()
		return
	set_process(true)
	_activate_skill(0)

func _read_user_argument(prefix: String, fallback: String) -> String:
	for raw_arg in OS.get_cmdline_user_args():
		var argument := str(raw_arg)
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return fallback

func _activate_skill(next_index: int) -> void:
	if _finished:
		return
	if _lab != null:
		remove_child(_lab)
		_lab.queue_free()
		_lab = null
	_index = next_index
	if _index >= _entries.size():
		_finish()
		return
	var entry: Dictionary = _entries[_index]
	var skill_id := str(entry.get("skill_id", ""))
	var fixture := _make_battle_fixture(skill_id, _index)
	_battle = fixture.get("battle") as MapBattleV2
	_caster_id = str(fixture.get("caster_id", ""))
	if _battle == null:
		push_error("VFX_FACTORY_BATCH_FIXTURE_FAILED " + skill_id)
		_records.append({"skill_id":skill_id,"fixture":"FAILED","native_capture":"SKIPPED"})
		call_deferred("_activate_skill", _index + 1)
		return
	_lab = FACTORY_SCENE.instantiate() as Node2D
	_lab.call("review_set_skill_id", skill_id)
	_lab.call("review_set_batch_capture_mode", true)
	add_child(_lab)
	var started_position: Vector2 = _battle.actors.get(_caster_id, {}).get("position", Vector2(2.0, 3.0))
	_lab.call("review_set_caster_screen_position", _world_to_screen(started_position))
	var target_id := str(fixture.get("target_id", ""))
	var target_data: Dictionary = _battle.actors.get(target_id, {})
	if not target_data.is_empty():
		var target_position: Vector2 = target_data.get("position", Vector2(5.0, 3.0))
		_lab.call("review_set_target_screen_position", _world_to_screen(target_position))
		_lab.call("review_record_actor_screen_position", target_id, _world_to_screen(target_position))
	_lab.call("review_record_actor_screen_position", _caster_id, _world_to_screen(started_position))
	var ally_id := str(fixture.get("ally_id", ""))
	if _battle.actors.has(ally_id):
		var ally_position: Vector2 = _battle.actors[ally_id].get("position", Vector2(4.0, 3.0))
		_lab.call("review_record_actor_screen_position", ally_id, _world_to_screen(ally_position))
		if str(entry.get("preview_target_kind", "")) == "ally":
			_lab.call("review_set_target_screen_position", _world_to_screen(ally_position))
	var encounter_id := _battle.encounter_id
	if not bool(_lab.call("review_begin_encounter", encounter_id)):
		push_error("VFX_FACTORY_BATCH_ENCOUNTER_BIND_FAILED " + skill_id)
	var binding_data: Dictionary = entry.get("receipt_manifest", {})
	var binding_rows: Array = binding_data.get("bindings", [])
	var allowed_types: Array[String] = []
	for raw_binding in binding_rows:
		if raw_binding is Dictionary:
			var event_type := str(raw_binding.get("event_type", ""))
			if not event_type.is_empty() and not allowed_types.has(event_type):
				allowed_types.append(event_type)
	_events.clear()
	for raw_event in _battle.events:
		if not (raw_event is Dictionary):
			continue
		var event: Dictionary = raw_event
		var is_basic_hit := skill_id == "tmb.skill.formation.basic.human" \
			and str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "basic" \
			and str(event.get("attacker", "")) == _caster_id \
			and str(_battle.actors.get(_caster_id, {}).get("v63_basic_skill_id", "")) == skill_id
		if allowed_types.has(str(event.get("type", ""))) \
			and (str(event.get("skill_id", "")) == skill_id or is_basic_hit):
			_events.append(event.duplicate(true))
	_event_index = 0
	_segment_elapsed = 0.0
	_event_origin_time = float(_events[0].get("time", 0.0)) if not _events.is_empty() else 0.0
	_segment_duration = _capture_duration(_events, _event_origin_time)
	_segment_start = _global_elapsed
	_records.append({
		"skill_id":skill_id,
		"name_vi":str(entry.get("name_vi", "")),
		"encounter_id":encounter_id,
		"fixture":"REAL_MAPBATTLE_VFX_TEST_FIXTURE",
		"event_count":_events.size(),
		"event_types":allowed_types.duplicate(),
		"video_start_seconds":_segment_start,
		"contact_frame_seconds":-1.0,
		"video_duration_seconds":_segment_duration,
		"receipt_feed":"PENDING"
	})

func _capture_duration(events: Array[Dictionary], origin_time: float) -> float:
	var last_time := 0.0
	for event in events:
		last_time = maxf(last_time, float(event.get("time", origin_time)) - origin_time)
		for end_key in ["until", "expires_at", "evasion_until"]:
			var end_value: Variant = event.get(end_key, null)
			if end_value is float or end_value is int:
				last_time = maxf(last_time, float(end_value) - origin_time)
	return maxf(1.4, last_time + 0.48)

func _process(delta: float) -> void:
	if _finished:
		return
	var step := maxf(0.0, delta)
	_segment_elapsed += step
	_global_elapsed += step
	while _event_index < _events.size():
		var event: Dictionary = _events[_event_index]
		var due_at := maxf(0.0, float(event.get("time", _event_origin_time)) - _event_origin_time)
		if due_at > _segment_elapsed:
			break
		_feed_receipt(event)
		_event_index += 1
	if _segment_elapsed >= _segment_duration:
		call_deferred("_activate_skill", _index + 1)

func _feed_receipt(event: Dictionary) -> void:
	var is_basic_hit := str(event.get("type", "")) == "hit" and str(event.get("kind", "")) == "basic"
	var actor_id := str(event.get("actor_id", event.get("caster", event.get("owner_id",
			event.get("attacker", "") if is_basic_hit else ""))))
	var caster: Dictionary = _battle.actors.get(actor_id, {})
	if not caster.is_empty():
		var caster_position: Vector2 = caster.get("position", Vector2.ZERO)
		var screen_position := _world_to_screen(caster_position)
		_lab.call("review_set_caster_screen_position", screen_position)
		_lab.call("review_record_actor_screen_position", actor_id, screen_position)
	var actor_targets: Array[String] = []
	var raw_target_ids: Variant = event.get("target_ids", [])
	if raw_target_ids is Array:
		for raw_target in raw_target_ids:
			var target_id := str(raw_target)
			if not target_id.is_empty() and not actor_targets.has(target_id):
				actor_targets.append(target_id)
	if actor_targets.is_empty():
		for key in ["target_id", "target", "zone_id"]:
			var target_id := str(event.get(key, ""))
			if not target_id.is_empty() and not actor_targets.has(target_id):
				actor_targets.append(target_id)
	if actor_targets.is_empty() and str(event.get("type", "")) == "v63_mobility" and not actor_id.is_empty():
		actor_targets.append(actor_id)
	var screen_position := TARGET_FOOT
	for target_id in actor_targets:
		var target_data: Dictionary = _battle.actors.get(target_id, {})
		var target_position: Vector2
		if not target_data.is_empty():
			target_position = target_data.get("position", Vector2.ZERO)
		elif event.get("center", null) is Vector2:
			target_position = event.get("center")
		else:
			target_position = _battle.actors.get(str(event.get("target", "")), {}).get("position", Vector2(5.0, 3.0))
		screen_position = _world_to_screen(target_position)
		_lab.call("review_record_actor_screen_position", target_id, screen_position)
	if str(event.get("type", "")) in ["skill_cast", "v63_skill_hit", "v63_talisman_hit", "v63_talisman_mark_applied", "skill_hit", "status_applied", "v63_formation_slow_applied", "v63_mobility"]:
		_lab.call("review_set_target_screen_position", screen_position)
	var skill_id := str(_entries[_index].get("skill_id", ""))
	var result: Dictionary
	if is_basic_hit and actor_id == _caster_id:
		result = _lab.call("review_feed_authoritative_basic_hit", event,
			str(_battle.actors.get(_caster_id, {}).get("v63_basic_skill_id", "")), actor_id)
	else:
		result = _lab.call("review_feed_authoritative_event", event)
	var record_index := _records.size() - 1
	if bool(result.get("ok", false)):
		_records[record_index]["receipt_feed"] = "REAL_MAPBATTLE_RECEIPT_ACCEPTED"
		if str(event.get("type", "")) in ["v63_skill_hit", "v63_talisman_hit", "v63_talisman_mark_applied", "skill_hit", "v63_formation_slow_applied", "v63_formation_zone_tick", "status_applied", "v63_mobility"] or is_basic_hit:
			if float(_records[record_index].get("contact_frame_seconds", -1.0)) < 0.0:
				# Keep the contact sheet close to the first receipt frame so the
				# phase's authored peak is not captured halfway through its fade.
				_records[record_index]["contact_frame_seconds"] = _global_elapsed + 0.02
		elif str(event.get("type", "")) == "skill_release" \
				and float(_records[record_index].get("release_frame_seconds", -1.0)) < 0.0:
			_records[record_index]["release_frame_seconds"] = _global_elapsed + 0.02
	else:
		push_error("VFX_FACTORY_BATCH_EVENT_REJECTED skill=" + skill_id + " event=" + str(event.get("type", "")) + " reason=" + str(result.get("reason", "")))

func _world_to_screen(world_position: Vector2) -> Vector2:
	return Vector2(
		clampf(CAST_FOOT.x + (world_position.x - 2.0) * 130.0, 90.0, 1190.0),
		clampf(CAST_FOOT.y + (world_position.y - 3.0) * 48.0, 440.0, 620.0)
	)

func _make_battle_fixture(skill_id: String, fixture_index: int) -> Dictionary:
	var battle: MapBattleV2 = MAP_BATTLE.new(88200 + fixture_index)
	battle.encounter_id = "vfx_factory_%s_capture_%02d" % [_school, fixture_index]
	battle.active = true
	battle.outcome = "fighting"
	var caster := _actor("caster_%02d" % fixture_index, "disciple", Vector2(2.0, 3.0))
	caster["party_id"] = "vfx_factory_%s_party" % _school
	caster["v63_combat_enabled"] = true
	caster["v63_skill_loadout"] = [skill_id]
	if _school == "formation":
		caster["v63_formation_combat_enabled"] = true
	else:
		caster["v63_talisman_combat_enabled"] = true
	var ally := _actor("ally_%02d" % fixture_index, "disciple", Vector2(4.0, 3.0))
	ally["party_id"] = "vfx_factory_%s_party" % _school
	var foe := _actor("foe_%02d" % fixture_index, "monster", Vector2(5.0, 3.0))
	if _school == "formation" and skill_id == "tmb.skill.formation.mobility.human":
		foe["position"] = Vector2(9.0, 3.0)
	elif _school == "formation" and skill_id == "tmb.skill.formation.basic.human":
		foe["position"] = Vector2(3.8, 3.0)
	var line_targets: Array[Dictionary] = [foe]
	if _school == "talisman":
		for target_index in range(1, 3):
			var line_foe := _actor("foe_%02d_%02d" % [fixture_index, target_index], "monster",
				Vector2(5.0 + float(target_index), 3.0))
			line_targets.append(line_foe)
	for actor in [caster, ally]:
		battle.actors[str(actor.get("id", ""))] = actor
	for line_foe in line_targets:
		battle.actors[str(line_foe.get("id", ""))] = line_foe
	var started := false
	if _school == "formation" and skill_id == "tmb.skill.formation.basic.human":
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
		return {"battle":null,"caster_id":str(caster.id),"target_id":str(foe.id),"ally_id":str(ally.id)}
	if not (_school == "formation" and skill_id in ["tmb.skill.formation.mobility.human", "tmb.skill.formation.basic.human"]):
		var pending: Dictionary = caster.get("v63_pending_cast", {})
		if pending.is_empty():
			return {"battle":null,"caster_id":str(caster.id),"target_id":str(foe.id),"ally_id":str(ally.id)}
		battle.now = float(pending.get("ready", battle.now))
		battle._release_casts()
	if _school == "formation" and skill_id.begins_with("tmb.skill.formation.sat_phat_tran.") and str(HSC.skill_definition(skill_id).get("effect", "")) == "formation_zone":
		var zones: Array = caster.get("v63_formation_zones", [])
		if not zones.is_empty():
			battle.now = float(zones[0].get("next_tick", battle.now + 1.0))
			FORMATION.process_zones(battle)
			battle.now = float(zones[0].get("expires_at", battle.now + 2.0))
			FORMATION.process_zones(battle)
	var target_id := str(ally.id) if str(HSC.skill_definition(skill_id).get("effect", "")) == "guard" else str(foe.id)
	return {"battle":battle,"caster_id":str(caster.id),"target_id":target_id,"ally_id":str(ally.id)}

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

func _finish() -> void:
	if _finished:
		return
	_finished = true
	var capture_index := {
		"schema":"tmb.vfx_factory_native_batch_capture.v1",
	"school":_school,
		"viewport_px":[1280,720],
		"renderer":"Godot 4.7.2 shared VFX Factory + existing AS-CHAR and Source A",
		"receipts":"REAL_MAPBATTLE_V2_TEST_FIXTURE_EVENTS_ONLY",
		"technical_status":"CAPTURE_PENDING_EXTERNAL_MOVIE_VALIDATION",
		"owner_approval":"PENDING",
		"pve":"HOLD",
		"skills":_records
	}
	if not _index_output_path.is_empty():
		var file := FileAccess.open(_index_output_path, FileAccess.WRITE)
		if file == null:
			push_error("VFX_FACTORY_BATCH_INDEX_WRITE_FAILED " + _index_output_path)
		else:
			file.store_string(JSON.stringify(capture_index, "\t") + "\n")
	print("VFX_FACTORY_" + _school.to_upper() + "_CAPTURE_COMPLETE skills=" + str(_records.size())
		+ " duration=" + str(snappedf(_global_elapsed, 0.01))
		+ " receipts=" + str(_accepted_receipt_count())
		+ " OWNER=PENDING PVE=HOLD")
	get_tree().quit(0)

func _accepted_receipt_count() -> int:
	var count := 0
	for row in _records:
		if str(row.get("receipt_feed", "")) == "REAL_MAPBATTLE_RECEIPT_ACCEPTED":
			count += 1
	return count
