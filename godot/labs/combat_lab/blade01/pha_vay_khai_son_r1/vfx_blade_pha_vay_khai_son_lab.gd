extends Control
## Preview-only LAB. Reuses the existing AS50 disciple, curved dao candidate,
## Source A enemy animation and an isolated real MapBattleV2 hit receipt.

const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const SOURCE_ATLAS := preload("res://src/presentation/p3/combat_v5_source_a_atlas.gd")
const SKILL_ID := "tmb.skill.blade.cuong_dao.active_01.human"
const SOCKET_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets/AS50_weapon_sockets_v9_3_candidate.json"
const WEAPON_LIBRARY_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
const ART_ROOT := "res://labs/combat_lab/blade01/pha_vay_khai_son_r1/source/production/"
const CHARGE_PATH := ART_ROOT + "pha_vay_khai_son_charge_r1.png"
const FLIGHT_PATH := ART_ROOT + "pha_vay_khai_son_flight_r1.png"
const CONTACT_PATH := ART_ROOT + "pha_vay_khai_son_contact_r1.png"
const FADE_PATH := ART_ROOT + "pha_vay_khai_son_fade_r1.png"
const CAST_TIME := 0.28
const PROJECTILE_SPEED := 10.0
const EXPECTED_RUNTIME_SECONDS := 0.68 # 0.28 s cast + 4.0 world-unit flight / 10.
const MOVEMENT_START_SECONDS := 0.12
const ATTACK_ACTION_SECONDS := 0.28
const ASCHAR_DISPLAY_SCALE := 0.25 # ~84.5 px visible body height from the authored 338 px.
const DAO_DISPLAY_SCALE := 0.68
const CHARGE_DISPLAY_FACTOR := 0.10083036773428232
const FLIGHT_DISPLAY_FACTOR := 0.11070110701107011
const CONTACT_DISPLAY_FACTOR := 0.0998003992015968
const FADE_DISPLAY_FACTOR := 0.3448275862068966
const CASTER_ID := "blade_lab_caster"
const TARGET_ID := "blade_lab_target_01"
const OUTSIDE_ID := "blade_lab_outside"
const CASTER_START := Vector2(2.0, 2.0)
const TARGET_START := Vector2(6.0, 2.0)
const TARGET_END := Vector2(5.6, 1.8)
const OUTSIDE_POSITION := Vector2(6.2, 3.5)
const MOVEMENT_MINIMUM_PX := 32.0

var battle: MapBattleV2
var source_atlas: CombatV5SourceAAtlas
var targets: Dictionary = {}
var start_positions: Dictionary = {}
var end_positions: Dictionary = {}
var before_hp: Dictionary = {}
var receipts: Array[Dictionary] = []
var actor_socket_manifest: Dictionary = {}
var dao_weapon_info: Dictionary = {}
var run_state := "BLOCKED"
var run_error := ""
var cast_elapsed := 0.0
var impact_time := -1.0
var post_hit_elapsed := 0.0
var pending_ready_seconds := -1.0
var caster_position := CASTER_START
var _cast_started_msec := 0
var charge_texture: Texture2D
var flight_texture: Texture2D
var contact_texture: Texture2D
var fade_texture: Texture2D
var _font: Font
var aschar_draw_success := false
var source_draw_success_by_actor: Dictionary = {}

func _ready() -> void:
	_font = ThemeDB.fallback_font
	charge_texture = load(CHARGE_PATH) as Texture2D
	flight_texture = load(FLIGHT_PATH) as Texture2D
	contact_texture = load(CONTACT_PATH) as Texture2D
	fade_texture = load(FADE_PATH) as Texture2D
	custom_minimum_size = Vector2(1280, 720)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_process(true)
	_prepare_runtime()
	queue_redraw()

func _prepare_runtime() -> void:
	if charge_texture == null or flight_texture == null or contact_texture == null or fade_texture == null:
		_block("G3_SOURCE_FAIL: one or more original RGBA masters did not load")
		return
	var parsed_socket: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOCKET_PATH))
	var parsed_library: Variant = JSON.parse_string(FileAccess.get_file_as_string(WEAPON_LIBRARY_PATH))
	if not (parsed_socket is Dictionary) or not (parsed_library is Dictionary):
		_block("ART_SOURCE_BLOCKED: existing AS50 socket or weapon library is unavailable")
		return
	actor_socket_manifest = parsed_socket
	if str(actor_socket_manifest.get("status", "")) != "CANDIDATE" or str(actor_socket_manifest.get("owner_art_approval", "")) != "PENDING":
		_block("ART_SOURCE_BLOCKED: AS50 candidate status changed; review its source before continuing")
		return
	var library: Dictionary = Dictionary(parsed_library.get("asset_library", {}))
	dao_weapon_info = Dictionary(library.get("curved_dao", {}))
	if str(dao_weapon_info.get("path", "")) != "res://assets/p3/baked_candidates/weapon_library_v1/candidate/weapons/curved_dao.png" or str(dao_weapon_info.get("owner_art_approval", "")) != "PENDING":
		_block("ART_SOURCE_BLOCKED: existing curved dao is unavailable or not the expected pending candidate")
		return
	var source_frames := ResourceLoader.load("res://assets/p3/baked_candidates/aschar50_candidate/AS50_FRONT_CLIPS_CANDIDATE.tres", "SpriteFrames") as SpriteFrames
	if source_frames == null or not source_frames.has_animation("attack_front") or source_frames.get_frame_count("attack_front") != 4:
		_block("ART_SOURCE_BLOCKED: existing AS50 candidate attack-front animation is unavailable")
		return
	source_atlas = SOURCE_ATLAS.new()
	if not source_atlas.has_actor("monster_1113031_1"):
		_block("ART_SOURCE_BLOCKED: Source A placeholder monster animation is unavailable")
		return
	var attachments: Array = actor_socket_manifest.get("attachments", [])
	var has_dao := false
	for raw_attachment in attachments:
		if raw_attachment is Dictionary and str(raw_attachment.get("asset_id", "")) == "curved_dao" and str(raw_attachment.get("slot", "")) == "main_hand":
			has_dao = true
		if has_dao:
			break
	if not has_dao:
		_block("ART_SOURCE_BLOCKED: AS50 candidate has no existing main-hand curved-dao binding")
		return

	var target_row := _monster_row(TARGET_ID, TARGET_START)
	var outside_row := _monster_row(OUTSIDE_ID, OUTSIDE_POSITION)
	if target_row.is_empty() or outside_row.is_empty():
		_block("ART_SOURCE_BLOCKED: MonsterCatalogueV2 could not create runtime targets")
		return
	start_positions = {TARGET_ID: target_row["position"], OUTSIDE_ID: outside_row["position"]}
	end_positions = {TARGET_ID: TARGET_END, OUTSIDE_ID: OUTSIDE_POSITION}
	battle = MapBattleV2.new(83951)
	var setup := battle.setup("blade_pha_vay_khai_son_preview", [_caster_row()], [target_row, outside_row])
	if not bool(setup.get("ok", false)):
		_block("ART_SOURCE_BLOCKED: MapBattleV2.setup failed: " + str(setup))
		return
	var caster: Dictionary = battle.actors[CASTER_ID]
	targets = {TARGET_ID: battle.actors[TARGET_ID], OUTSIDE_ID: battle.actors[OUTSIDE_ID]}
	for target_id in targets:
		before_hp[target_id] = float(targets[target_id].get("hp", 0.0))
	if not HSC.try_cast(battle, caster, targets[TARGET_ID], false):
		_block("ART_SOURCE_BLOCKED: canonical Phá Vây Khai Sơn cast was rejected")
		return
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	if str(pending.get("v63_skill_id", "")) != SKILL_ID or str(pending.get("target_id", "")) != TARGET_ID:
		_block("ART_SOURCE_BLOCKED: runtime cast does not match canonical single-target skill")
		return
	pending_ready_seconds = float(pending.get("ready", -1.0)) - battle.now
	if not is_equal_approx(pending_ready_seconds, EXPECTED_RUNTIME_SECONDS):
		_block("ART_SOURCE_BLOCKED: runtime cast deadline differs from cast plus projectile travel contract")
		return
	if _attack_rows().size() != 4 or _dao_tip_screen(ATTACK_ACTION_SECONDS).distance_to(_world_to_screen(CASTER_START)) < 5.0:
		_block("ART_SOURCE_BLOCKED: current AS50 hand socket or preview-only dao tip failed to resolve")
		return
	cast_elapsed = 0.0
	impact_time = pending_ready_seconds
	run_state = "CHARGING"
	_cast_started_msec = Time.get_ticks_msec()
	print("BLADE_PHA_VAY_KHAI_SON_LAB_READY actor=AS50_CANDIDATE dao=EXISTING_CURVED_DAO runtime=MapBattleV2 movement=true gate=OFF pve=OFF")

func _process(delta: float) -> void:
	if run_state in ["CHARGING", "PROJECTILE_IN_FLIGHT"]:
		cast_elapsed = minf(impact_time, cast_elapsed + maxf(0.0, delta))
		battle.now = cast_elapsed
		_update_moving_targets()
		run_state = "CHARGING" if cast_elapsed < CAST_TIME else "PROJECTILE_IN_FLIGHT"
		if cast_elapsed + 0.000001 >= impact_time:
			_release_runtime_cast()
	elif run_state == "CONFIRMED_SINGLE_TARGET_HIT":
		post_hit_elapsed += maxf(0.0, delta)
	queue_redraw()

func _update_moving_targets() -> void:
	if targets.is_empty():
		return
	var progress := clampf((cast_elapsed - MOVEMENT_START_SECONDS) / maxf(0.001, impact_time - MOVEMENT_START_SECONDS), 0.0, 1.0)
	for target_id in targets:
		var actor: Dictionary = targets[target_id]
		actor["position"] = (start_positions[target_id] as Vector2).lerp(end_positions[target_id], progress)

func _release_runtime_cast() -> void:
	var caster: Dictionary = battle.actors[CASTER_ID]
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	battle.now = float(pending.get("ready", battle.now))
	for target_id in targets:
		(targets[target_id] as Dictionary)["position"] = end_positions[target_id]
	battle._release_casts()
	receipts.clear()
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type", "")) == "v63_skill_hit" and str(event.get("skill_id", "")) == SKILL_ID:
			receipts.append(event)
	var affected := {}
	for event in receipts:
		affected[str(event.get("target", ""))] = true
	var outside: Dictionary = targets[OUTSIDE_ID]
	var ok := receipts.size() == 1 and affected.has(TARGET_ID) and not affected.has(OUTSIDE_ID)
	ok = ok and float(targets[TARGET_ID].get("hp", 0.0)) < float(before_hp[TARGET_ID])
	ok = ok and is_equal_approx(float(outside.get("hp", 0.0)), float(before_hp[OUTSIDE_ID]))
	ok = ok and int(receipts[0].get("target_hp_before", 0.0)) > int(receipts[0].get("target_hp_after", 0.0))
	if not ok:
		_block("ART_SOURCE_BLOCKED: real MapBattleV2 release failed the single-target receipt contract")
		return
	run_state = "CONFIRMED_SINGLE_TARGET_HIT"
	post_hit_elapsed = 0.0
	print("BLADE_PHA_VAY_KHAI_SON_LAB_RUNTIME PASS receipts=1 target_limit=1 hit_count=1 moved_target=true actor=AS50_CANDIDATE dao=EXISTING_CURVED_DAO pve=OFF")
	queue_redraw()

func _block(message: String) -> void:
	run_state = "ART_SOURCE_BLOCKED"
	run_error = message
	push_error(message)
	queue_redraw()

func _caster_row() -> Dictionary:
	var resistances := {}
	for element in ["metal", "wood", "water", "fire", "earth", "lightning", "wind", "ice", "yang", "nether"]:
		resistances[element] = 0.0
	return {
		"id": CASTER_ID, "side": "disciple", "role": "frontline", "position": CASTER_START,
		"hp": 500.0, "max_hp": 500.0, "range": 1.8, "basic_range": 1.8, "move_speed": 2.0,
		"stats": {"max_hp": 500.0, "attack": 40.0, "defense": 0.0, "damage_reduction": 0.0,
			"crit_chance": 0.0, "crit_damage": 1.5, "crit_resistance": 0.0,
			"defense_penetration": 0.0, "lifesteal": 0.0, "lifesteal_reduction": 0.0},
		"resistances": resistances, "context_sources": [], "skill_loadout": [],
		"v63_combat_enabled": true, "v63_blade_combat_enabled": true,
		"v63_combat_branch_id": "cuong_dao", "v63_combat_lineage": "base",
		"v63_skill_loadout": [SKILL_ID], "v63_skill_ready": {}, "v63_passive_ids": [],
		"v63_combat_clock": -1.0, "next_skill": 0.0
	}

func _monster_row(actor_id: String, position: Vector2) -> Dictionary:
	var created := MonsterCatalogueV2.create_actor("thanh_lang", 1, 1, actor_id)
	if not bool(created.get("ok", false)):
		return {}
	var actor: Dictionary = created
	actor["id"] = actor_id
	actor["position"] = position
	return actor

func _attack_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for raw in actor_socket_manifest.get("body_frames", []):
		if raw is Dictionary and str(raw.get("clip", "")) == "attack_front":
			rows.append(raw)
	return rows

func _attack_row(age: float) -> Dictionary:
	var rows := _attack_rows()
	if rows.is_empty():
		return {}
	return rows[ASCHAR.frame_index("attack", age, rows.size(), ATTACK_ACTION_SECONDS)]

func _weapon_direction() -> Vector2:
	if targets.is_empty():
		return Vector2.RIGHT
	return _world_to_screen(targets[TARGET_ID]["position"]) - _world_to_screen(caster_position)

func _dao_tip_screen(age: float) -> Vector2:
	var row := _attack_row(age)
	if row.is_empty():
		return _world_to_screen(caster_position)
	var grip_sockets: Dictionary = row.get("grip_sockets", {})
	var main_hand: Dictionary = grip_sockets.get("main_hand", {})
	var body_grip: Array = main_hand.get("body_grip_px", [])
	var weapon_grip: Array = dao_weapon_info.get("grip_px", [])
	var weapon_tip: Array = dao_weapon_info.get("tip_px", [])
	if body_grip.size() != 2 or weapon_grip.size() != 2 or weapon_tip.size() != 2:
		return _world_to_screen(caster_position)
	var path := str(row.get("path", ""))
	var texture := ResourceLoader.load(path, "Texture2D") as Texture2D
	if texture == null:
		return _world_to_screen(caster_position)
	var baseline := float(row.get("source_foot_baseline_y_px", actor_socket_manifest.get("foot_baseline_y_px", 359.0)))
	var body_center := Vector2(texture.get_width() * 0.5, baseline)
	var foot := _world_to_screen(caster_position)
	var hand := foot + (Vector2(float(body_grip[0]), float(body_grip[1])) - body_center) * ASCHAR_DISPLAY_SCALE
	var direction := _weapon_direction()
	var rotation_deg := ASCHAR.aligned_weapon_rotation_deg([0.0, 0.0], [direction.x, direction.y],
		weapon_grip, weapon_tip, float(main_hand.get("rotation_deg", 0.0)))
	var axis := Vector2(float(weapon_tip[0]) - float(weapon_grip[0]),
		float(weapon_tip[1]) - float(weapon_grip[1])).rotated(deg_to_rad(rotation_deg))
	return hand + axis * (ASCHAR_DISPLAY_SCALE * DAO_DISPLAY_SCALE)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("101820"))
	draw_rect(Rect2(0.0, 438.0, size.x, 282.0), Color("24352f"))
	for y in range(446, 720, 36):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.46, 0.59, 0.51, 0.09), 1.0, true)
	for x in range(0, 1280, 64):
		draw_line(Vector2(x, 438), Vector2(x, 720), Color(0.46, 0.59, 0.51, 0.06), 1.0, true)
	draw_rect(Rect2(0, 0, 1280, 122), Color("0c1319"))
	draw_string(_font, Vector2(34, 44), "PHÁ VÂY KHAI SƠN · ĐAO TU · LAB VFX R1",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("e9ddbd"))
	draw_string(_font, Vector2(36, 77), "AS50 EXISTING DISCIPLE + CURVED DAO CANDIDATE · PREVIEW ONLY · PvE RELEASE OFF",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("9fb2b0"))

	var caster_foot := _world_to_screen(caster_position)
	var target_foot := _world_to_screen(_target_position(TARGET_ID))
	var direction := _weapon_direction().normalized()
	var caster_action_age := minf(cast_elapsed, ATTACK_ACTION_SECONDS)
	var attachment_override := {
		"asset_id": "curved_dao", "anchor_slot": "main_hand", "asset_scale": DAO_DISPLAY_SCALE,
		"align_tip_to_direction": direction, "restore_hand_slots": ["main_hand"]
	}
	aschar_draw_success = ASCHAR.draw_actor(self, "blade", "male", "attack",
		caster_foot, direction, caster_action_age, ASCHAR_DISPLAY_SCALE,
		ATTACK_ACTION_SECONDS, attachment_override)
	_draw_target(TARGET_ID, "TARGET · SOURCE A PLACEHOLDER", target_foot)
	_draw_target(OUTSIDE_ID, "OUTSIDE TARGET · HP UNCHANGED", _world_to_screen(_target_position(OUTSIDE_ID)))
	_draw_skill_art(caster_foot, target_foot, direction)
	_draw_runtime_status()

func _draw_skill_art(caster_foot: Vector2, target_foot: Vector2, direction: Vector2) -> void:
	if run_state in ["CHARGING", "PROJECTILE_IN_FLIGHT"]:
		var release_tip := _dao_tip_screen(ATTACK_ACTION_SECONDS)
		if cast_elapsed < CAST_TIME:
			var pulse := 0.76 + 0.24 * sin(clampf(cast_elapsed / CAST_TIME, 0.0, 1.0) * PI)
			_draw_source_art(charge_texture, release_tip - direction * 17.0, CHARGE_DISPLAY_FACTOR, direction.angle(), pulse)
		else:
			var progress := clampf((cast_elapsed - CAST_TIME) / maxf(0.001, impact_time - CAST_TIME), 0.0, 1.0)
			var from := release_tip + direction * 12.0
			var to := target_foot + Vector2(0.0, -44.0)
			var projectile_center := from.lerp(to, progress)
			_draw_source_art(flight_texture, projectile_center, FLIGHT_DISPLAY_FACTOR, direction.angle(), 1.0)
	elif run_state == "CONFIRMED_SINGLE_TARGET_HIT":
		var after_hit := post_hit_elapsed
		var anchor := target_foot + Vector2(0.0, -45.0)
		if after_hit < 0.14:
			_draw_source_art(contact_texture, anchor, CONTACT_DISPLAY_FACTOR, direction.angle(), 1.0 - smoothstep(0.06, 0.14, after_hit))
		elif after_hit < 0.46:
			_draw_source_art(fade_texture, anchor, FADE_DISPLAY_FACTOR, direction.angle(), 1.0 - smoothstep(0.14, 0.46, after_hit))

func _draw_source_art(texture: Texture2D, center: Vector2, display_factor: float, angle: float, alpha: float) -> void:
	if texture == null or alpha <= 0.002:
		return
	draw_set_transform(center, angle, Vector2.ONE * display_factor)
	draw_texture(texture, -texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	draw_set_transform(Vector2.ZERO)

func _draw_target(actor_id: String, title: String, foot: Vector2) -> void:
	if targets.is_empty() or not targets.has(actor_id) or source_atlas == null:
		return
	var actor: Dictionary = targets[actor_id]
	var hit := _has_receipt(actor_id)
	var action := "hit" if hit else ("walk" if run_state in ["CHARGING", "PROJECTILE_IN_FLIGHT"] else "stand")
	var age := cast_elapsed if not hit else post_hit_elapsed
	source_draw_success_by_actor[actor_id] = source_atlas.draw_actor(self,
		"monster_1113031_1", action, foot, Vector2.LEFT, age, 1.0)
	var bar_left := foot.x - 47.0
	var bar_top := foot.y - 106.0
	draw_rect(Rect2(bar_left, bar_top, 94.0, 7.0), Color("111519"))
	var hp_ratio := clampf(float(actor.get("hp", 0.0)) / maxf(1.0, float(actor.get("max_hp", 1.0))), 0.0, 1.0)
	draw_rect(Rect2(bar_left, bar_top, 94.0 * hp_ratio, 7.0), Color("c2b17b") if hit else Color("8cae9a"))
	var label_y := bar_top - 12.0 if actor_id == TARGET_ID else bar_top + 24.0
	draw_string(_font, Vector2(foot.x - 92.0, label_y), title,
		HORIZONTAL_ALIGNMENT_CENTER, 184, 12, Color("eee1c5") if hit else Color("b0beb2"))

func _draw_runtime_status() -> void:
	var line := "Waiting for isolated MapBattleV2 receipt · production blade gate OFF"
	var color := Color("bdc4ba")
	if run_state == "CONFIRMED_SINGLE_TARGET_HIT":
		line = "1 REAL V63 BLADE HIT · target_limit=1 · target HP fell · outside HP unchanged · V63 gate OFF"
		color = Color("d8cba7")
	elif run_state == "ART_SOURCE_BLOCKED":
		line = "Preview blocked · " + run_error
		color = Color("edb0a0")
	draw_string(_font, Vector2(35, 663), line, HORIZONTAL_ALIGNMENT_LEFT, 1210, 17, color)
	draw_string(_font, Vector2(36, 692), "Source A monster art is generic and species mapping is unverified; AS50/dao and original VFX remain candidates pending owner review.",
		HORIZONTAL_ALIGNMENT_LEFT, 1205, 12, Color("abb8b0"))

func _target_position(actor_id: String) -> Vector2:
	if targets.has(actor_id):
		return targets[actor_id].get("position", Vector2.ZERO)
	return Vector2.ZERO

func _world_to_screen(position: Vector2) -> Vector2:
	return Vector2(240.0 + (position.x - 2.0) * 90.0, 484.0 + (position.y - 2.0) * 90.0)

func _has_receipt(actor_id: String) -> bool:
	for event in receipts:
		if str(event.get("target", "")) == actor_id and str(event.get("skill_id", "")) == SKILL_ID:
			return true
	return false
