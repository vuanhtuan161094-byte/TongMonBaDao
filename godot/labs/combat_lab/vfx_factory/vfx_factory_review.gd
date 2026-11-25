extends Node2D
## One data-driven, presentation-only scene shared by eligible VFX candidates.
## Canonical effect/shape/limits come from the Human combat catalogue; this
## renderer only reads source art, AS-CHAR anchors, and receipt-bound cues.

const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const SOURCE_ATLAS := preload("res://src/presentation/p3/combat_v5_source_a_atlas.gd")
const RECEIPT_BRIDGE := preload("res://labs/visual_bridge_v1/asset_vfx_readonly_bridge_v1.gd")
const REGISTRY_PATH := "res://labs/combat_lab/vfx_factory/registry.json"
const MECHANIC_TEMPLATES := [
	"projectile", "melee", "line", "circle_aoe", "multi_target", "shield",
	"buff", "debuff", "mobility", "heal", "summon", "formation", "status"
]
const VIEW_SIZE := Vector2(1280.0, 720.0)
const CAST_FOOT := Vector2(300.0, 492.0)
const TARGET_BASE := Vector2(690.0, 492.0)
const OUTSIDE_BASE := Vector2(844.0, 598.0)
const MONSTER_ID := "monster_1113031_1"

var _skill_id := ""
var _registry: Dictionary = {}
var _config: Dictionary = {}
var _phase_frames: Dictionary = {}
var _receipt_bridge: AssetVfxReadOnlyBridgeV1
var _receipt_manifest: Dictionary = {}
var _receipt_event: Dictionary = {}
var _receipt_target_ids: Array[String] = []
var _receipt_local_time := -1.0
var _receipt_duration := 0.0
var _persistent_event: Dictionary = {}
var _persistent_target_ids: Array[String] = []
var _persistent_local_time := -1.0
var _persistent_duration := 0.0
var _contact_event: Dictionary = {}
var _contact_target_ids: Array[String] = []
var _contact_local_time := -1.0
var _timeline_event_phase := ""
var _timeline_event_local_time := -1.0
var _authoritative_clock_started := false
var _screen_positions: Dictionary = {}
var _last_actor_asset_id := -1
var _source_atlas: CombatV5SourceAAtlas
var _elapsed := 0.0
var _target_screen_position := TARGET_BASE
var _paused := false
var _batch_capture_mode := false
var _moving := true
var _show_vfx := true
var _bright := false
var _zoomed := false
var _speed := 1.0
var _last_receipt_result := "NO_RECEIPT"
var _font: Font

func review_set_skill_id(skill_id: String) -> void:
	_skill_id = skill_id
	if is_inside_tree():
		_load_entry()
		queue_redraw()

func _ready() -> void:
	_font = ThemeDB.fallback_font
	_source_atlas = SOURCE_ATLAS.new()
	set_process(true)
	_load_registry()
	_load_entry()
	queue_redraw()

func _load_registry() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) if FileAccess.file_exists(REGISTRY_PATH) else null
	if not (parsed is Dictionary) or str(parsed.get("schema", "")) != "tmb.vfx_factory_registry.v1":
		_registry = {}
		push_error("VFX_FACTORY_REGISTRY_INVALID")
		return
	_registry = parsed

func _load_entry() -> void:
	_config = {}
	_phase_frames.clear()
	_clear_receipts()
	_screen_positions.clear()
	_target_screen_position = TARGET_BASE
	_receipt_bridge = RECEIPT_BRIDGE.new()
	if _registry.is_empty() or _skill_id.is_empty():
		return
	for raw in _registry.get("entries", []):
		if raw is Dictionary and str(raw.get("skill_id", "")) == _skill_id:
			_config = raw.duplicate(true)
			break
	if _config.is_empty():
		push_error("VFX_FACTORY_CONFIG_MISSING " + _skill_id)
		return
	var configured_target: Array = _config.get("target_screen_position", [TARGET_BASE.x, TARGET_BASE.y])
	if configured_target.size() == 2:
		_target_screen_position = Vector2(float(configured_target[0]), float(configured_target[1]))
	var mechanic := str(_config.get("mechanic_template", ""))
	var mechanics: Array = _config.get("mechanic_templates", [mechanic])
	if not MECHANIC_TEMPLATES.has(mechanic) or mechanics.is_empty():
		push_error("VFX_FACTORY_MECHANIC_TEMPLATE_INVALID " + mechanic)
	for mechanic_tag in mechanics:
		if not MECHANIC_TEMPLATES.has(str(mechanic_tag)):
			push_error("VFX_FACTORY_MECHANIC_TEMPLATE_INVALID " + str(mechanic_tag))
	var sources: Dictionary = _config.get("phase_sources", {})
	for phase in sources:
		var row: Dictionary = sources[phase]
		var frames: Array[Dictionary] = []
		var frame_paths: Array = row.get("frames", [])
		if frame_paths.is_empty() and not str(row.get("path", "")).is_empty():
			frame_paths = [{"path": row.get("path", "")}]
		for raw_frame in frame_paths:
			var frame_def: Dictionary = raw_frame if raw_frame is Dictionary else {"path": str(raw_frame)}
			var path := str(frame_def.get("path", ""))
			if path.begins_with("res://") and ResourceLoader.exists(path, "Texture2D"):
				var texture := ResourceLoader.load(path, "Texture2D") as Texture2D
				if texture != null:
					var region := Rect2(Vector2.ZERO, texture.get_size())
					var region_data: Variant = frame_def.get("region", [])
					if region_data is Array and region_data.size() == 4:
						region = Rect2(float(region_data[0]), float(region_data[1]), float(region_data[2]), float(region_data[3]))
					if region.size.x > 0.0 and region.size.y > 0.0 and Rect2(Vector2.ZERO, texture.get_size()).encloses(region):
						frames.append({"texture": texture, "region": region})
		if not frames.is_empty():
			_phase_frames[str(phase)] = frames
	_receipt_manifest = Dictionary(_config.get("receipt_manifest", {})).duplicate(true)
	var definition := _read_canonical_definition()
	if not definition.is_empty():
		# Read gameplay contract from its authoritative catalogue without loading the
		# combat simulation subsystem into the isolated Web Review project.
		_config["canonical_effect"] = str(definition.get("effect", ""))
		_config["canonical_shape"] = str(definition.get("shape", ""))
		_config["canonical_target_limit"] = int(definition.get("target_limit", 0))
		_config["canonical_cast_time"] = float(definition.get("cast_time", 0.0))
		_config["canonical_duration"] = float(definition.get("duration", 0.0))
		_config["canonical_radius"] = float(definition.get("radius", 0.0))
	else:
		push_error("VFX_FACTORY_CANONICAL_SKILL_MISSING " + _skill_id)

func _read_canonical_definition() -> Dictionary:
	var path := str(_config.get("catalog_path", ""))
	if not path.begins_with("res://") or not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary):
		return {}
	for raw_skill in parsed.get("skills", []):
		if raw_skill is Dictionary and str(raw_skill.get("id", "")) == _skill_id:
			return raw_skill.duplicate(true)
	return {}

func _clear_receipts() -> void:
	_receipt_event.clear()
	_receipt_target_ids.clear()
	_receipt_local_time = -1.0
	_receipt_duration = 0.0
	_persistent_event.clear()
	_persistent_target_ids.clear()
	_persistent_local_time = -1.0
	_persistent_duration = 0.0
	_contact_event.clear()
	_contact_target_ids.clear()
	_contact_local_time = -1.0
	_timeline_event_phase = ""
	_timeline_event_local_time = -1.0
	_authoritative_clock_started = false

func _process(delta: float) -> void:
	if not _paused:
		_elapsed += maxf(0.0, delta) * _speed
		var end_time := float(_config.get("review_timeline", {}).get("loop_seconds", 2.0))
		if not _batch_capture_mode and end_time > 0.0 and _elapsed >= end_time:
			_elapsed = fmod(_elapsed, end_time)
			_clear_receipts()
			_last_receipt_result = "NO_RECEIPT"
	queue_redraw()

func review_replay() -> void:
	_elapsed = 0.0
	_clear_receipts()
	_screen_positions.clear()
	_last_receipt_result = "NO_RECEIPT"
	queue_redraw()

func review_set_paused(value: bool) -> void:
	_paused = value

func review_set_batch_capture_mode(value: bool) -> void:
	_batch_capture_mode = value

func review_set_caster_screen_position(screen_position: Vector2) -> void:
	_config["caster_screen_position"] = [screen_position.x, screen_position.y]
	queue_redraw()

func review_set_target_screen_position(screen_position: Vector2) -> void:
	_target_screen_position = screen_position
	queue_redraw()

func review_set_moving(value: bool) -> void:
	_moving = value

func review_set_fx(value: bool) -> void:
	_show_vfx = value

func review_set_bright(value: bool) -> void:
	_bright = value

func review_set_map_zoom(value: bool) -> void:
	_zoomed = value

func review_set_speed(value: float) -> void:
	_speed = clampf(value, 0.25, 2.0)

func review_begin_encounter(encounter_id: String) -> bool:
	if _receipt_manifest.is_empty() or str(_receipt_manifest.get("schema", "")) != "tmb.vfx_bindings.v1":
		_last_receipt_result = "RECEIPT_BINDING_UNCONFIGURED"
		return false
	if not _receipt_bridge.begin_encounter(encounter_id):
		_last_receipt_result = "ENCOUNTER_ID_MISSING"
		return false
	_receipt_manifest["encounter_id"] = encounter_id
	return true

func review_set_receipt_manifest(manifest: Dictionary) -> bool:
	if str(manifest.get("schema", "")) != "tmb.vfx_bindings.v1" or str(manifest.get("skill_id", "")) != _skill_id:
		_last_receipt_result = "RECEIPT_MANIFEST_MISMATCH"
		return false
	_receipt_manifest = manifest.duplicate(true)
	return true

func review_seek_phase(phase: String) -> void:
	var timeline: Dictionary = _config.get("review_timeline", {})
	var key := phase
	if phase == "projectile":
		key = str(_config.get("delivery_phase", "flight"))
	if phase == "contact":
		key = "contact"
	if phase == "start":
		key = "release"
	if phase == "end":
		key = "fade"
	if phase in ["start", "sustain", "end"] and _persistent_event.is_empty():
		_last_receipt_result = "WAITING_FOR_REAL_RECEIPT"
		queue_redraw()
		return
	if phase in ["contact", "fade"] and _contact_event.is_empty():
		_last_receipt_result = "WAITING_FOR_REAL_RECEIPT"
		queue_redraw()
		return
	var time_key := key + "_at"
	var default_time := float(timeline.get("release_at", 0.0))
	_elapsed = float(timeline.get(time_key, timeline.get(key, default_time)))
	_paused = true
	queue_redraw()

func review_feed_authoritative_event(raw_event: Dictionary) -> Dictionary:
	if _receipt_bridge == null or _receipt_manifest.is_empty():
		_last_receipt_result = "RECEIPT_BINDING_UNCONFIGURED"
		return {"ok": false, "reason": _last_receipt_result}
	var event := raw_event.duplicate(true)
	if str(event.get("encounter_id", "")) != str(_receipt_manifest.get("encounter_id", "")):
		_last_receipt_result = "ENCOUNTER_MISMATCH"
		return {"ok": false, "reason": _last_receipt_result}
	var routed := _receipt_bridge.route_authoritative_event(event, _receipt_manifest)
	if not bool(routed.get("ok", false)):
		_last_receipt_result = str(routed.get("reason", "UNBOUND_EVENT"))
		return routed
	var admitted: bool = false
	var target_ids: Array[String] = []
	for emission in routed.get("emissions", []):
		if str(emission.get("skill_id", "")) != _skill_id:
			continue
		if str(emission.get("event_id", "")) != str(event.get("event_id", "")):
			continue
		_receipt_event = event
		_receipt_event["visual_phase"] = str(emission.get("visual_phase", ""))
		var target_id := str(emission.get("target_id", ""))
		if not target_id.is_empty() and not target_ids.has(target_id):
			target_ids.append(target_id)
		_receipt_local_time = _elapsed
		admitted = true
	if admitted:
		_receipt_target_ids = target_ids
		var event_end: Variant = event.get("until", event.get("expires_at", event.get("evasion_until", null)))
		var event_start: Variant = event.get("time", event.get("at", null))
		if (event_end is float or event_end is int) and (event_start is float or event_start is int):
			_receipt_duration = maxf(0.0, float(event_end) - float(event_start))
		var visual_phase := str(_receipt_event.get("visual_phase", ""))
		if visual_phase in ["charge", "release"]:
			_timeline_event_phase = visual_phase
			_timeline_event_local_time = _elapsed
			_authoritative_clock_started = true
		elif visual_phase in ["start", "sustain", "end"]:
			_persistent_event = _receipt_event.duplicate(true)
			_persistent_target_ids = target_ids.duplicate()
			_persistent_local_time = _elapsed
			_persistent_duration = _receipt_duration
			_authoritative_clock_started = true
		elif visual_phase == "contact":
			_contact_event = _receipt_event.duplicate(true)
			_contact_target_ids = target_ids.duplicate()
			_contact_local_time = _elapsed
			_authoritative_clock_started = true
	_last_receipt_result = "RECEIPT_BOUND" if admitted else "EVENT_UNBOUND"
	queue_redraw()
	return {"ok": admitted, "reason": _last_receipt_result}

func review_feed_authoritative_basic_hit(raw_event: Dictionary, actor_basic_skill_id: String,
		actor_id: String) -> Dictionary:
	if str(raw_event.get("type", "")) != "hit" or str(raw_event.get("kind", "")) != "basic":
		_last_receipt_result = "NOT_A_MAPBATTLE_BASIC_HIT"
		return {"ok": false, "reason": _last_receipt_result}
	if actor_basic_skill_id != _skill_id or str(raw_event.get("attacker", "")) != actor_id:
		_last_receipt_result = "BASIC_SKILL_OR_ATTACKER_MISMATCH"
		return {"ok": false, "reason": _last_receipt_result}
	var event := raw_event.duplicate(true)
	# MapBattle V2 emits an actual `hit` with `kind=basic`; the exact skill is
	# resolved from that attacker's real v63_basic_skill_id loadout field.
	# This adds no damage, status, or combat event; it only labels the receipt.
	event["skill_id"] = actor_basic_skill_id
	event["actor_id"] = actor_id
	event["target_id"] = str(raw_event.get("target", ""))
	var result := review_feed_authoritative_event(event)
	if bool(result.get("ok", false)):
		_last_receipt_result = "BASIC_HIT_BOUND_FROM_REAL_MAPBATTLE_AND_ACTOR_LOADOUT"
		result["reason"] = _last_receipt_result
	return result

func review_record_actor_screen_position(actor_id: String, screen_position: Vector2) -> void:
	if not actor_id.strip_edges().is_empty():
		_screen_positions[actor_id] = screen_position

func review_state() -> Dictionary:
	var actor_asset_id := int(_last_actor_asset_id)
	if actor_asset_id < 0:
		actor_asset_id = ASCHAR.BRIDGE.actor_id(str(_config.get("school", "")), str(_config.get("actor_sex", "male")))
	return {
		"skill_id": _skill_id,
		"mechanic_template": str(_config.get("mechanic_template", "")),
		"mechanic_templates": Array(_config.get("mechanic_templates", [_config.get("mechanic_template", "")])).duplicate(),
		"canonical_effect": str(_config.get("canonical_effect", "")),
		"canonical_shape": str(_config.get("canonical_shape", "")),
		"canonical_target_limit": int(_config.get("canonical_target_limit", 0)),
		"receipt_state": _last_receipt_result,
		"phase_sources_loaded": _phase_frames.size(),
		"frame_count": _phase_frame_count(),
		"receipt_target_count": _receipt_target_ids.size(),
		"receipt_duration": _receipt_duration,
		"persistent_receipt_target_count": _persistent_target_ids.size(),
		"contact_receipt_target_count": _contact_target_ids.size(),
		"actor_scale": ASCHAR.game_view_scale(2.0 if _zoomed else 1.0),
		"actor_asset_id": actor_asset_id,
		"source_g3": str(_config.get("source_g3", "PENDING")),
		"motion_status": str(_config.get("motion_status", "NOT_REVIEWED")),
		"native_status": str(_config.get("native_status", "NOT_RUN")),
		"owner_status": str(_config.get("owner_status", "OWNER_VISUAL_PENDING"))
	}

func _phase_frame_count() -> int:
	var count := 0
	for frames in _phase_frames.values():
		count += frames.size()
	return count

func _target_foot() -> Vector2:
	var foot := _target_screen_position
	if str(_config.get("preview_target_kind", "monster")) == "ally":
		return foot
	if _moving and bool(_config.get("showcase_moving_target", true)):
		foot += Vector2(sin(_elapsed * 1.4) * 45.0, sin(_elapsed * 0.85) * 12.0)
	return foot

func _moving_monster_foot() -> Vector2:
	var foot := Vector2(980.0, 492.0)
	if _moving and bool(_config.get("showcase_moving_target", true)):
		foot += Vector2(sin(_elapsed * 1.15) * 34.0, sin(_elapsed * 0.75) * 10.0)
	return foot

func _draw() -> void:
	var dark := Color("101820")
	var ground := Color("24352f")
	if _bright:
		dark = Color("c4c6bb")
		ground = Color("a1aa91")
	draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), dark)
	draw_rect(Rect2(0.0, 438.0, VIEW_SIZE.x, 282.0), ground)
	for y in range(446, 720, 36):
		draw_line(Vector2(0.0, y), Vector2(VIEW_SIZE.x, y), Color(0.46, 0.59, 0.51, 0.10), 1.0, true)
	var school := str(_config.get("school", ""))
	var sex := str(_config.get("actor_sex", "male"))
	var action := str(_config.get("actor_action", "idle"))
	var actor_scale := ASCHAR.game_view_scale(2.0 if _zoomed else 1.0)
	var facing_data: Array = _config.get("facing_vector", [1.0, 0.0])
	var facing := Vector2(float(facing_data[0]), float(facing_data[1])) if facing_data.size() == 2 else Vector2.RIGHT
	if facing.length_squared() < 0.001:
		facing = Vector2.RIGHT
	var action_seconds := maxf(0.01, float(_config.get("review_timeline", {}).get("actor_action_seconds", 0.35)))
	var attachment_override: Dictionary = _config.get("preview_attachment_override", {}).duplicate(true)
	var actor_age := _elapsed
	var cast_position_data: Array = _config.get("caster_screen_position", [CAST_FOOT.x, CAST_FOOT.y])
	var actor_foot := Vector2(float(cast_position_data[0]), float(cast_position_data[1])) if cast_position_data.size() == 2 else CAST_FOOT
	var target_foot := _target_foot()
	var target_actor_id := str(_config.get("target_actor_id", "review_target"))
	var outside_actor_id := str(_config.get("outside_actor_id", "review_outside"))
	if not _screen_positions.has(target_actor_id):
		_screen_positions[target_actor_id] = target_foot
	if not _screen_positions.has(outside_actor_id):
		_screen_positions[outside_actor_id] = OUTSIDE_BASE
	var anchors: Dictionary = ASCHAR.resolve_preview_anchors(school, sex, action,
		facing, actor_age, actor_foot, actor_scale, action_seconds, attachment_override)
	_last_actor_asset_id = int(anchors.get("actor_id", -1))
	if _show_vfx:
		_draw_phase_art(anchors, actor_foot, target_foot, false)
	var actor_ok := ASCHAR.draw_actor(self, school, sex, action, actor_foot,
		facing, actor_age, actor_scale, action_seconds, attachment_override)
	var preview_target_kind := str(_config.get("preview_target_kind", "monster"))
	if preview_target_kind == "ally":
		ASCHAR.draw_actor(self, school, sex, "idle", target_foot, Vector2.DOWN,
			_elapsed, actor_scale, action_seconds, attachment_override)
		if _source_atlas != null and _source_atlas.has_actor(MONSTER_ID):
			_source_atlas.draw_actor(self, MONSTER_ID, "walk", _moving_monster_foot(),
				Vector2.LEFT, _elapsed, 1.0)
			_source_atlas.draw_actor(self, MONSTER_ID, "walk", OUTSIDE_BASE,
				Vector2.LEFT, _elapsed + 0.23, 1.0)
	else:
		if _source_atlas != null and _source_atlas.has_actor(MONSTER_ID):
			_source_atlas.draw_actor(self, MONSTER_ID, "walk", target_foot,
				Vector2.LEFT, _elapsed, 1.0)
			_source_atlas.draw_actor(self, MONSTER_ID, "walk", OUTSIDE_BASE,
				Vector2.LEFT, _elapsed + 0.23, 1.0)
	if _show_vfx:
		_draw_phase_art(anchors, actor_foot, target_foot, true)
	_draw_overlay(actor_ok, school, target_foot)

func _draw_phase_art(anchors: Dictionary, actor_foot: Vector2,
		target_foot: Vector2, front_layer: bool) -> void:
	var timeline: Dictionary = _config.get("review_timeline", {})
	var persistent_phase := _persistent_phase_at_time(timeline)
	if not persistent_phase.is_empty():
		if phase_draws_front(_config, persistent_phase) == front_layer:
			_draw_bound_phase(persistent_phase, _persistent_target_ids, _persistent_phase_age(persistent_phase, timeline),
				_persistent_duration, front_layer)
	var contact_phase := _contact_phase_at_time(timeline)
	if not contact_phase.is_empty():
		if phase_draws_front(_config, contact_phase) == front_layer:
			_draw_bound_phase(contact_phase, _contact_target_ids,
				maxf(0.0, _elapsed - _contact_local_time), 0.0, front_layer)
	if not persistent_phase.is_empty() or not contact_phase.is_empty():
		return
	var phase := _phase_at_time(timeline)
	if phase in ["waiting", ""]:
		return
	if phase_draws_front(_config, phase) != front_layer:
		return
	var phase_anchors: Dictionary = _config.get("phase_anchors", {})
	var anchor_name := str(phase_anchors.get(phase, _config.get("source_anchor", "review_stage")))
	var anchor_result := _resolve_configured_anchor(anchor_name, anchors, actor_foot)
	if not bool(anchor_result.get("ok", false)) and phase in ["charge", "release", "flight", "sustain", "start", "end"]:
		return
	var start: Vector2 = anchor_result.get("position", Vector2.ZERO)
	var center := start
	if phase in ["flight", "travel"]:
		var progress := clampf((_elapsed - float(timeline.get("flight_at", timeline.get("release_at", 0.25)))) /
			maxf(0.01, float(timeline.get("contact_at", 0.90)) - float(timeline.get("flight_at", timeline.get("release_at", 0.25)))), 0.0, 1.0)
		center = start.lerp(target_foot + Vector2(0.0, -36.0), progress)
	var source_key := _phase_source_name(phase)
	if phase == "travel":
		source_key = "flight" if _config.get("phase_sources", {}).has("flight") else "release"
	_draw_texture_phase(source_key, center, front_layer)

static func phase_draws_front(configuration: Dictionary, phase: String) -> bool:
	var phase_layers: Dictionary = configuration.get("phase_layers", {})
	var layer := str(phase_layers.get(phase, configuration.get("draw_layer", "FRONT"))).to_upper()
	return layer == "FRONT"

func _draw_bound_phase(phase: String, target_ids: Array[String], phase_age: float,
		duration: float, front_layer: bool) -> void:
	var source_key := _phase_source_name(phase)
	if not _phase_frames.has(source_key):
		return
	for target_id in target_ids:
		if not _screen_positions.has(target_id):
			continue
		var anchor_name := str(_config.get("phase_anchors", {}).get(phase, "target_foot"))
		var position: Vector2 = _screen_positions[target_id]
		if anchor_name == "target_chest":
			position += Vector2(0.0, -36.0)
		_draw_texture_phase(source_key, position, front_layer, phase_age, duration)

func _phase_source_name(phase: String) -> String:
	var aliases: Dictionary = _config.get("phase_aliases", {})
	return str(aliases.get(phase, phase))

func _resolve_configured_anchor(anchor_name: String, anchors: Dictionary, actor_foot: Vector2) -> Dictionary:
	if anchor_name == "target_foot":
		return {"ok": true, "position": _target_foot()}
	if anchor_name == "ground":
		return {"ok": true, "position": actor_foot}
	if anchor_name == "review_stage":
		return {"ok": true, "position": actor_foot + Vector2(105.0, -45.0), "review_only": true}
	var slots: Dictionary = anchors.get("slots", {})
	var raw: Variant = slots.get(anchor_name, anchors.get(anchor_name, {}))
	if raw is Dictionary and raw.has("position") and raw["position"] is Vector2:
		return {"ok": true, "position": raw["position"], "metadata": raw}
	if raw is Vector2:
		return {"ok": true, "position": raw}
	return {"ok": false, "reason": "AUTHORED_ANCHOR_MISSING:" + anchor_name}

func _draw_texture_phase(phase: String, center: Vector2, _front_layer: bool,
		phase_age: float = -1.0, receipt_duration: float = 0.0) -> void:
	var source_phase := phase
	var frames: Array = _phase_frames.get(source_phase, [])
	if frames.is_empty():
		return
	var phase_row: Dictionary = _config.get("phase_sources", {}).get(source_phase, {})
	var phase_time := maxf(0.0, phase_age) if phase_age >= 0.0 else _phase_elapsed(source_phase)
	var fps := maxf(1.0, float(phase_row.get("fps", 12.0)))
	var frame_index := mini(int(floor(phase_time * fps)), frames.size() - 1)
	if bool(phase_row.get("loop", false)):
		frame_index = posmod(int(floor(phase_time * fps)), frames.size())
	var frame: Dictionary = frames[frame_index]
	var texture := frame.get("texture") as Texture2D
	if texture == null:
		return
	var source: Rect2 = frame.get("region", Rect2(Vector2.ZERO, texture.get_size()))
	var desired_width := _source_display_width(phase_row)
	var scale_factor := desired_width / maxf(1.0, float(source.size.x))
	var alpha := 1.0
	var timeline: Dictionary = _config.get("review_timeline", {})
	var fade_seconds := maxf(0.08, float(phase_row.get("fade_seconds", timeline.get("fade_window_seconds", 0.22))))
	if phase == "fade" or phase == "end":
		alpha = 1.0 - smoothstep(0.0, fade_seconds, maxf(0.0, phase_age))
	elif phase == "contact":
		var contact_window := maxf(0.01, float(timeline.get("contact_window_seconds", 0.18)))
		alpha = 1.0 - smoothstep(contact_window, contact_window + fade_seconds, maxf(0.0, phase_age))
	elif phase == "sustain" and receipt_duration > 0.0 and phase_age > receipt_duration:
		alpha = 1.0 - smoothstep(receipt_duration, receipt_duration + fade_seconds, phase_age)
	draw_set_transform(center, float(phase_row.get("angle_radians", 0.0)), Vector2.ONE * scale_factor)
	draw_texture_rect_region(texture, Rect2(-source.size * 0.5, source.size), source,
		Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	draw_set_transform(Vector2.ZERO)

func _source_display_width(phase_row: Dictionary) -> float:
	if phase_row.has("display_width_px"):
		return maxf(1.0, float(phase_row.get("display_width_px", 80.0)))
	var radius := float(_config.get("canonical_radius", 0.0))
	var basis := ASCHAR.game_view_scale(2.0 if _zoomed else 1.0) * 550.0
	return clampf(maxf(0.85, radius) * basis, 88.0, 240.0)

func _phase_elapsed(phase: String) -> float:
	if not _receipt_event.is_empty() and _receipt_local_time >= 0.0:
		return maxf(0.0, _elapsed - _receipt_local_time)
	var timeline: Dictionary = _config.get("review_timeline", {})
	var start := float(timeline.get(phase + "_at", timeline.get("release_at", 0.0)))
	return maxf(0.0, _elapsed - start)

func _phase_at_time(timeline: Dictionary) -> String:
	var charge_end := float(timeline.get("release_at", 0.25))
	var contact_at := float(timeline.get("contact_at", 0.90))
	var persistent_phase := _persistent_phase_at_time(timeline)
	if not persistent_phase.is_empty():
		return persistent_phase
	var contact_phase := _contact_phase_at_time(timeline)
	if not contact_phase.is_empty():
		return contact_phase
	if not _timeline_event_phase.is_empty() and _timeline_event_local_time >= 0.0:
		var event_age := _elapsed - _timeline_event_local_time
		var event_window := float(timeline.get("charge_window_seconds", 0.18)) if _timeline_event_phase == "charge" else float(timeline.get("release_window_seconds", 0.12))
		if event_age < maxf(0.04, event_window):
			return _timeline_event_phase
		if _authoritative_clock_started:
			return "waiting"
	if _authoritative_clock_started:
		return "waiting"
	if _elapsed < charge_end:
		return "charge"
	if _elapsed < contact_at:
		var delivery := str(_config.get("delivery_phase", "flight"))
		if delivery == "release" and _config.get("phase_sources", {}).has("release"):
			return "release"
		if delivery == "sustain" and _config.get("phase_sources", {}).has("sustain"):
			return "sustain"
		if _config.get("phase_sources", {}).has("flight"):
			return "flight"
		if _config.get("phase_sources", {}).has("release"):
			return "release"
	return "waiting"

func _persistent_phase_at_time(timeline: Dictionary) -> String:
	if _persistent_event.is_empty() or _persistent_local_time < 0.0:
		return ""
	var event_phase := str(_persistent_event.get("visual_phase", ""))
	var receipt_age := _elapsed - _persistent_local_time
	var start_window := maxf(0.04, float(timeline.get("start_window_seconds", 0.18)))
	var end_window := maxf(0.04, float(timeline.get("end_window_seconds", 0.20)))
	if event_phase == "end":
		return "end" if receipt_age < end_window else ""
	if event_phase == "start" and receipt_age < start_window and _phase_frames.has(_phase_source_name("start")):
		return "start"
	if _persistent_duration > receipt_age:
		return "sustain" if _phase_frames.has(_phase_source_name("sustain")) else ""
	if _persistent_duration > 0.0 and receipt_age < _persistent_duration + end_window:
		return "end" if _phase_frames.has(_phase_source_name("end")) else ""
	return ""

func _persistent_phase_age(phase: String, timeline: Dictionary) -> float:
	var age := maxf(0.0, _elapsed - _persistent_local_time)
	if phase == "end" and str(_persistent_event.get("visual_phase", "")) != "end":
		return maxf(0.0, age - _persistent_duration)
	return age

func _contact_phase_at_time(timeline: Dictionary) -> String:
	if _contact_event.is_empty() or _contact_local_time < 0.0:
		return ""
	var age := _elapsed - _contact_local_time
	var contact_window := maxf(0.01, float(timeline.get("contact_window_seconds", 0.18)))
	var fade_window := maxf(0.08, float(timeline.get("fade_window_seconds", 0.22)))
	if age < contact_window:
		return "contact" if _phase_frames.has(_phase_source_name("contact")) else ""
	if age < contact_window + fade_window:
		return "fade" if _phase_frames.has(_phase_source_name("fade")) else ""
	return ""

func _draw_overlay(actor_ok: bool, school: String, target_foot: Vector2) -> void:
	var fg := Color("eee1c5") if not _bright else Color("1b2420")
	var secondary := Color("b9c7bd") if not _bright else Color("424b44")
	var id_line := _skill_id + " · " + str(_config.get("name_vi", ""))
	draw_string(_font, Vector2(35.0, 43.0), "VFX FACTORY · DATA REVIEW · 1× GAME SCALE", HORIZONTAL_ALIGNMENT_LEFT, 940.0, 22, fg)
	draw_string(_font, Vector2(36.0, 72.0), id_line, HORIZONTAL_ALIGNMENT_LEFT, 930.0, 14, secondary)
	draw_string(_font, Vector2(35.0, 116.0), "CASTER · " + school.to_upper() + " · " + str(_config.get("actor_action", "idle")).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 350.0, 12, secondary)
	var target_label := "ALLY TARGET 01" if str(_config.get("preview_target_kind", "monster")) == "ally" else "MONSTER TARGET 01 · MOVING"
	draw_string(_font, Vector2(target_foot.x - 110.0, target_foot.y - 95.0), target_label, HORIZONTAL_ALIGNMENT_CENTER, 220.0, 12, secondary)
	if str(_config.get("preview_target_kind", "monster")) == "ally":
		var moving_monster := _moving_monster_foot()
		draw_string(_font, Vector2(moving_monster.x - 100.0, moving_monster.y - 95.0), "MONSTER MOVING", HORIZONTAL_ALIGNMENT_CENTER, 200.0, 12, secondary)
	draw_string(_font, Vector2(35.0, 642.0), "TEMPLATE: " + str(_config.get("mechanic_template", "unassigned")).to_upper() + " · SOURCE: " + str(_config.get("source_g3", "PENDING")) + " · NATIVE: " + str(_config.get("native_status", "NOT_RUN")), HORIZONTAL_ALIGNMENT_LEFT, 1205.0, 14, fg)
	var canonical := "effect=" + str(_config.get("canonical_effect", _config.get("effect", "unknown"))) + "  shape=" + str(_config.get("canonical_shape", _config.get("shape", "unknown"))) + "  target_limit=" + str(_config.get("canonical_target_limit", _config.get("target_limit", 0)))
	draw_string(_font, Vector2(36.0, 667.0), canonical + " · owner=" + str(_config.get("owner_status", "OWNER_VISUAL_PENDING")) + " · motion=" + str(_config.get("motion_status", "NOT_REVIEWED")), HORIZONTAL_ALIGNMENT_LEFT, 1205.0, 13, secondary)
	var receipt_text := "CONTACT WAITING FOR REAL RECEIPT" if _contact_event.is_empty() else "CONTACT RECEIPT: " + str(_contact_event.get("type", ""))
	if not _persistent_event.is_empty():
		receipt_text += " · STATE RECEIPT: " + str(_persistent_event.get("type", ""))
	if str(_config.get("review_timeline", {}).get("clock", "")) == "REVIEW_STORYBOARD_ONLY":
		receipt_text += " · CAST TIMELINE: REVIEW ONLY"
	if not actor_ok:
		receipt_text += " · ACTOR SOURCE UNAVAILABLE"
	if not bool(_config.get("native_ready", false)):
		receipt_text += " · PREVIEW ONLY / SOCKET OR RUNTIME GATE PENDING"
	draw_string(_font, Vector2(36.0, 696.0), receipt_text, HORIZONTAL_ALIGNMENT_LEFT, 1205.0, 12, Color("d3b47e"))
