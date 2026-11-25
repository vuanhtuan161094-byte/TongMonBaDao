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
var _movie_time_offset := -1.0
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
	if str(entry.get("native_capture_mode", "")) == "REVIEW_STORYBOARD_ONLY":
		_activate_storyboard_skill(entry, skill_id)
		return
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
	var capture_start_position: Vector2 = fixture.get("caster_start_position", started_position)
	_lab.call("review_set_caster_screen_position", _world_to_screen(capture_start_position))
	var target_id := str(fixture.get("target_id", ""))
	var target_data: Dictionary = _battle.actors.get(target_id, {})
	if not target_data.is_empty():
		var target_position: Vector2 = target_data.get("position", Vector2(5.0, 3.0))
		_lab.call("review_set_target_screen_position", _world_to_screen(target_position))
		_lab.call("review_record_actor_screen_position", target_id, _world_to_screen(target_position))
	for raw_preview_target in entry.get("preview_targets", []):
		if not (raw_preview_target is Dictionary):
			continue
		var preview_target_id := str(raw_preview_target.get("id", ""))
		var preview_target_data: Dictionary = _battle.actors.get(preview_target_id, {})
		if preview_target_data.is_empty():
			continue
		var preview_target_position: Vector2 = preview_target_data.get("position", Vector2(5.0, 3.0))
		var preview_target_screen := _world_to_screen(preview_target_position)
		_lab.call("review_record_actor_screen_position", preview_target_id, preview_target_screen)
		if preview_target_id == str(entry.get("target_actor_id", "")):
			_lab.call("review_set_target_screen_position", preview_target_screen)
	var outside_preview: Dictionary = entry.get("preview_outside", {})
	var outside_preview_id := str(outside_preview.get("id", ""))
	var outside_preview_data: Dictionary = _battle.actors.get(outside_preview_id, {})
	if not outside_preview_data.is_empty():
		_lab.call("review_record_actor_screen_position", outside_preview_id,
			_world_to_screen(outside_preview_data.get("position", Vector2(6.0, 5.0))))
	_lab.call("review_record_actor_screen_position", _caster_id, _world_to_screen(capture_start_position))
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
		var is_factory_basic_skill := skill_id in ["tmb.skill.formation.basic.human", "tmb.skill.talisman.basic.human"]
		var is_basic_hit := is_factory_basic_skill \
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
	_segment_start = _movie_seconds()
	var recorded_event_types: Array[String] = []
	for event in _events:
		var event_type := str(event.get("type", ""))
		if not recorded_event_types.has(event_type):
			recorded_event_types.append(event_type)
	_records.append({
		"skill_id":skill_id,
		"name_vi":str(entry.get("name_vi", "")),
		"encounter_id":encounter_id,
		"fixture":"REAL_MAPBATTLE_VFX_TEST_FIXTURE",
		"event_count":_events.size(),
		"synthetic_events":0,
		"event_types":recorded_event_types,
		"configured_event_types":allowed_types.duplicate(),
		"event_trace":[],
		"accepted_event_count":0,
		"video_start_seconds":_segment_start,
		"release_frame_seconds":-1.0,
		"contact_frame_seconds":-1.0,
		"video_duration_seconds":_segment_duration,
		"receipt_feed":"PENDING"
	})

func _activate_storyboard_skill(entry: Dictionary, skill_id: String) -> void:
	# Presentation-only capture for candidates whose gameplay gate is off or
	# whose real receipt contract is not available. No battle or synthetic event
	# is created, and the renderer keeps receipt-bound contact art hidden.
	_battle = null
	_caster_id = "storyboard_caster_%02d" % _index
	_lab = FACTORY_SCENE.instantiate() as Node2D
	_lab.call("review_set_skill_id", skill_id)
	_lab.call("review_set_batch_capture_mode", true)
	_lab.call("review_set_moving", true)
	add_child(_lab)
	_lab.call("review_set_caster_screen_position", CAST_FOOT)
	_lab.call("review_set_target_screen_position", TARGET_FOOT)
	_lab.call("review_record_actor_screen_position", _caster_id, CAST_FOOT)
	_lab.call("review_record_actor_screen_position", "review_target", TARGET_FOOT)
	var encounter_id := "vfx_factory_%s_storyboard_%02d" % [_school, _index]
	if not bool(_lab.call("review_begin_encounter", encounter_id)):
		push_error("VFX_FACTORY_STORYBOARD_ENCOUNTER_BIND_FAILED " + skill_id)
	_events.clear()
	_event_index = 0
	_segment_elapsed = 0.0
	_event_origin_time = 0.0
	_segment_duration = maxf(1.2, float(entry.get("review_timeline", {}).get("loop_seconds", 1.4)))
	_segment_start = _movie_seconds()
	_records.append({
		"skill_id":skill_id,
		"name_vi":str(entry.get("name_vi", "")),
		"encounter_id":encounter_id,
		"fixture":"PRESENTATION_ONLY_STORYBOARD_NO_BATTLE_EVENTS",
		"event_count":0,
		"event_types":[],
		"configured_event_types":[],
		"accepted_event_count":0,
		"synthetic_events":0,
		"video_start_seconds":_segment_start,
		"release_frame_seconds":_segment_start + float(entry.get("review_timeline", {}).get("release_at", 0.12)) + 0.08,
		"contact_frame_seconds":-1.0,
		"video_duration_seconds":_segment_duration,
		"receipt_feed":"NO_GAMEPLAY_RECEIPT_CONFIGURED",
		"native_capture_mode":"REVIEW_STORYBOARD_ONLY",
		"contact_status":"HIDDEN_WAITING_FOR_REAL_RECEIPT"
	})

func _capture_duration(events: Array[Dictionary], origin_time: float) -> float:
	var last_time := 0.0
	var release_time := 0.0
	for event in events:
		var event_age := float(event.get("time", origin_time)) - origin_time
		last_time = maxf(last_time, event_age)
		if str(event.get("type", "")) == "skill_release":
			release_time = maxf(release_time, event_age)
		for end_key in ["until", "expires_at", "evasion_until"]:
			var end_value: Variant = event.get(end_key, null)
			if end_value is float or end_value is int:
				last_time = maxf(last_time, float(end_value) - origin_time)
	var release_window := maxf(0.08, float(_entries[_index].get("review_timeline", {}).get("release_window_seconds", 0.18)))
	var release_tail := release_time + release_window + 0.32 if release_time > 0.0 else 0.0
	return maxf(maxf(1.4, last_time + 0.48), release_tail)

func _process(delta: float) -> void:
	if _finished:
		return
	var step := maxf(0.0, delta)
	if _movie_time_offset < 0.0 and step > 0.0:
		_movie_time_offset = step
	_segment_elapsed += step
	_global_elapsed += step
	while _event_index < _events.size():
		var event: Dictionary = _events[_event_index]
		var due_at := maxf(0.0, float(event.get("time", _event_origin_time)) - _event_origin_time)
		if due_at > _segment_elapsed:
			break
		_feed_receipt(event)
		_event_index += 1
		# Preserve one render frame between receipts that share a combat tick, so
		# cast, release and contact stages remain readable in the combined movie.
		if _event_index < _events.size():
			var next_event: Dictionary = _events[_event_index]
			var next_due_at := maxf(0.0, float(next_event.get("time", _event_origin_time)) - _event_origin_time)
			if next_due_at <= _segment_elapsed:
				break
	if _segment_elapsed >= _segment_duration:
		call_deferred("_activate_skill", _index + 1)

func _feed_receipt(event: Dictionary) -> void:
	var skill_id := str(_entries[_index].get("skill_id", ""))
	var is_factory_basic_skill := skill_id in ["tmb.skill.formation.basic.human", "tmb.skill.talisman.basic.human"]
	var is_basic_hit := is_factory_basic_skill and str(event.get("type", "")) == "hit" \
		and str(event.get("kind", "")) == "basic"
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
	var result: Dictionary
	if is_basic_hit and actor_id == _caster_id:
		result = _lab.call("review_feed_authoritative_basic_hit", event,
			str(_battle.actors.get(_caster_id, {}).get("v63_basic_skill_id", "")), actor_id)
	else:
		result = _lab.call("review_feed_authoritative_event", event)
	var record_index := _records.size() - 1
	var review_state: Dictionary = _lab.call("review_state")
	var raw_trace_target_ids: Variant = event.get("target_ids", [])
	var trace_target_ids: Array = raw_trace_target_ids.duplicate(true) if raw_trace_target_ids is Array else []
	var trace_target_id := str(event.get("target_id", event.get("target", "")))
	if not trace_target_id.is_empty() and not trace_target_ids.has(trace_target_id):
		trace_target_ids.append(trace_target_id)
	var event_trace: Array = _records[record_index].get("event_trace", [])
	event_trace.append({
		"event_type":str(event.get("type", "")),
		"event_id":str(event.get("event_id", "")),
		"capture_frame_seconds":_movie_seconds(),
		"simulation_event_time_seconds":float(event.get("time", -1.0)),
		"skill_id":str(event.get("skill_id", "")),
		"caster_id":actor_id,
		"target_ids":trace_target_ids,
		"accepted":bool(result.get("ok", false)),
		"reason":str(result.get("reason", "")),
		"contact_receipt_target_count":int(review_state.get("contact_receipt_target_count", 0))
	})
	_records[record_index]["event_trace"] = event_trace
	if bool(result.get("ok", false)):
		_records[record_index]["receipt_feed"] = "REAL_MAPBATTLE_RECEIPT_ACCEPTED"
		_records[record_index]["accepted_event_count"] = int(_records[record_index].get("accepted_event_count", 0)) + 1
		if str(event.get("type", "")) == "v63_mobility":
			_records[record_index]["mobility_frame_seconds"] = _movie_seconds() + 0.02
			_records[record_index]["start_frame_seconds"] = _movie_seconds() + 0.02
		elif str(event.get("type", "")) in ["v63_skill_hit", "v63_talisman_hit", "v63_talisman_mark_applied", "skill_hit", "v63_formation_slow_applied", "v63_formation_zone_tick", "status_applied"] or is_basic_hit:
			if float(_records[record_index].get("contact_frame_seconds", -1.0)) < 0.0:
				# Keep the contact sheet close to the first receipt frame so the
				# phase's authored peak is not captured halfway through its fade.
				var visual_phase := ""
				for binding in _entries[_index].get("receipt_manifest", {}).get("bindings", []):
					if str(binding.get("event_type", "")) == str(event.get("type", "")):
						visual_phase = str(binding.get("visual_phase", ""))
						break
				_records[record_index]["contact_frame_seconds"] = _movie_seconds() + (0.10 if visual_phase == "start" else 0.02)
		elif str(event.get("type", "")) == "skill_release" \
				and float(_records[record_index].get("release_frame_seconds", -1.0)) < 0.0:
			# Sample the frame rendered immediately after this receipt. Delaying by
			# half the release window can land on a same-tick contact and hide the peak.
			_records[record_index]["release_frame_seconds"] = _movie_seconds()
	else:
		push_error("VFX_FACTORY_BATCH_EVENT_REJECTED skill=" + skill_id + " event=" + str(event.get("type", "")) + " reason=" + str(result.get("reason", "")))

func _world_to_screen(world_position: Vector2) -> Vector2:
	return Vector2(
		clampf(CAST_FOOT.x + (world_position.x - 2.0) * 130.0, 90.0, 1190.0),
		clampf(CAST_FOOT.y + (world_position.y - 3.0) * 48.0, 440.0, 620.0)
	)

func _movie_seconds() -> float:
	return maxf(0.0, _global_elapsed - maxf(0.0, _movie_time_offset))

func _make_battle_fixture(skill_id: String, fixture_index: int) -> Dictionary:
	var battle: MapBattleV2 = MAP_BATTLE.new(88200 + fixture_index)
	battle.encounter_id = "vfx_factory_%s_capture_%02d" % [_school, fixture_index]
	battle.active = true
	battle.outcome = "fighting"
	var entry: Dictionary = _entries[fixture_index]
	var caster := _actor("caster_%02d" % fixture_index, "disciple", Vector2(2.0, 3.0))
	var caster_origin_position: Vector2 = caster.get("position", Vector2(2.0, 3.0))
	caster["party_id"] = "vfx_factory_%s_party" % _school
	caster["v63_combat_enabled"] = true
	caster["v63_skill_loadout"] = [skill_id]
	match _school:
		"formation": caster["v63_formation_combat_enabled"] = true
		"talisman": caster["v63_talisman_combat_enabled"] = true
		"palm": caster["v63_palm_combat_enabled"] = true
		"spear": caster["v63_spear_combat_enabled"] = true
	var ally := _actor("ally_%02d" % fixture_index, "disciple", Vector2(4.0, 3.0))
	ally["party_id"] = "vfx_factory_%s_party" % _school
	var line_targets: Array[Dictionary] = []
	var preview_target_rows: Array = entry.get("preview_targets", [])
	var foe: Dictionary
	if not preview_target_rows.is_empty():
		for raw_target_row in preview_target_rows:
			if not (raw_target_row is Dictionary):
				continue
			var row_position: Array = raw_target_row.get("fixture_position", [5.0, 3.0])
			var monster := _actor(str(raw_target_row.get("id", "factory_target")), "monster",
				Vector2(float(row_position[0]), float(row_position[1])) if row_position.size() == 2 else Vector2(5.0, 3.0))
			line_targets.append(monster)
		if not line_targets.is_empty():
			foe = line_targets[0]
	else:
		foe = _actor("foe_%02d" % fixture_index, "monster", Vector2(5.0, 3.0))
		if _school == "formation" and skill_id == "tmb.skill.formation.mobility.human":
			foe["position"] = Vector2(9.0, 3.0)
		elif _school == "formation" and skill_id == "tmb.skill.formation.basic.human":
			foe["position"] = Vector2(3.8, 3.0)
		line_targets.append(foe)
	if _school == "talisman" and preview_target_rows.is_empty():
		for target_index in range(1, 3):
			var line_foe := _actor("foe_%02d_%02d" % [fixture_index, target_index], "monster",
				Vector2(5.0 + float(target_index), 3.0))
			line_targets.append(line_foe)
	for actor in [caster, ally]:
		battle.actors[str(actor.get("id", ""))] = actor
	for line_foe in line_targets:
		battle.actors[str(line_foe.get("id", ""))] = line_foe
	var outside_row: Dictionary = entry.get("preview_outside", {})
	if not outside_row.is_empty():
		var outside_position: Array = outside_row.get("fixture_position", [6.0, 5.2])
		var outside_actor := _actor(str(outside_row.get("id", "factory_outside")), "monster",
			Vector2(float(outside_position[0]), float(outside_position[1])) if outside_position.size() == 2 else Vector2(6.0, 5.2))
		battle.actors[str(outside_actor.get("id", ""))] = outside_actor
	var started := false
	if skill_id in ["tmb.skill.formation.basic.human", "tmb.skill.talisman.basic.human"]:
		var basic_definition: Dictionary = HSC.skill_definition(skill_id)
		caster["v63_basic_skill_id"] = skill_id
		caster["basic_ratio"] = float(basic_definition.get("damage_ratio", 0.0))
		caster["basic_element"] = str(basic_definition.get("element", "earth"))
		caster["range"] = float(basic_definition.get("range", 2.1))
		caster["basic_range"] = float(basic_definition.get("range", 2.1))
		battle.step()
		started = true
	else:
		started = HSC.try_cast(battle, caster, foe)
	if not started:
		return {"battle":null,"caster_id":str(caster.id),"target_id":str(foe.id),"ally_id":str(ally.id)}
	var immediate_factory_skill := skill_id in ["tmb.skill.formation.mobility.human", "tmb.skill.formation.basic.human",
		"tmb.skill.talisman.basic.human", "tmb.skill.talisman.mobility.human"]
	if not immediate_factory_skill:
		var pending: Dictionary = caster.get("v63_pending_cast", {})
		if pending.is_empty():
			return {"battle":null,"caster_id":str(caster.id),"target_id":str(foe.id),"ally_id":str(ally.id)}
		for raw_target_row in preview_target_rows:
			if not (raw_target_row is Dictionary):
				continue
			var target_actor: Dictionary = battle.actors.get(str(raw_target_row.get("id", "")), {})
			var motion: Array = raw_target_row.get("fixture_motion_delta", [0.0, 0.0])
			if not target_actor.is_empty() and motion.size() == 2:
				target_actor["position"] = target_actor.get("position", Vector2.ZERO) + Vector2(float(motion[0]), float(motion[1]))
		var outside_motion: Array = outside_row.get("fixture_motion_delta", [0.0, 0.0])
		var outside_target: Dictionary = battle.actors.get(str(outside_row.get("id", "")), {})
		if not outside_target.is_empty() and outside_motion.size() == 2:
			outside_target["position"] = outside_target.get("position", Vector2.ZERO) + Vector2(float(outside_motion[0]), float(outside_motion[1]))
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
	return {"battle":battle,"caster_id":str(caster.id),"target_id":target_id,"ally_id":str(ally.id),
		"caster_start_position":caster_origin_position}

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
		"lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
	var actor := {"id":actor_id,"side":side,"party_id":"","role":"ranged","position":position,
		"hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
		"stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
			"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"status_effects":{},"context_sources":[],"v63_combat_enabled":true,
		"v63_formation_combat_enabled":false,"v63_talisman_combat_enabled":false,
		"v63_palm_combat_enabled":false,"v63_spear_combat_enabled":false,
		"v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0,"next_basic":0.0,
		"learned_guard_factor":1.0,"learned_guard_until":-1.0}
	if side == "monster":
		actor["race_id"] = "yeu_thu"
	return actor

func _finish() -> void:
	if _finished:
		return
	_finished = true
	var has_storyboard := false
	var has_real_fixture := false
	for row in _records:
		if str(row.get("native_capture_mode", "")) == "REVIEW_STORYBOARD_ONLY":
			has_storyboard = true
		else:
			has_real_fixture = true
	var receipt_scope := "REAL_MAPBATTLE_V2_TEST_FIXTURE_EVENTS_ONLY"
	if has_storyboard and not has_real_fixture:
		receipt_scope = "STORYBOARD_ONLY_NO_COMBAT_EVENTS"
	elif has_storyboard:
		receipt_scope = "MIXED_REAL_FIXTURE_AND_STORYBOARD; NO_SYNTHETIC_EVENTS"
	var capture_index := {
		"schema":"tmb.vfx_factory_native_batch_capture.v1",
	"school":_school,
		"viewport_px":[1280,720],
		"renderer":"Godot 4.7.2 shared VFX Factory + existing AS-CHAR and Source A",
		"receipts":receipt_scope,
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
		+ " skills_with_bound_receipts=" + str(_accepted_receipt_count())
		+ " OWNER=PENDING PVE=HOLD")
	get_tree().quit(0)

func _accepted_receipt_count() -> int:
	var count := 0
	for row in _records:
		if str(row.get("receipt_feed", "")) == "REAL_MAPBATTLE_RECEIPT_ACCEPTED":
			count += 1
	return count
