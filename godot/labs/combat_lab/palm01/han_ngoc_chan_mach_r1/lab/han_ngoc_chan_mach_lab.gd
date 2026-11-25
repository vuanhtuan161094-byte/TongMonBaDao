extends Node2D

const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const CASTER_FRAMES = preload("res://assets/p3/baked_candidates/aschar60_candidate/AS60_PALM_CLIPS_CANDIDATE.tres")
const MONSTER_SCENE = preload("res://assets/actors/v5_sa_monster_1113031_1/actor.tscn")
const CHARGE_TEXTURE = preload("res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/source/charge_r2.png")
const PEAK_TEXTURE = preload("res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/source/peak_r2.png")
const CONTACT_TEXTURE = preload("res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/source/contact_r1.png")

const SKILL_ID := "tmb.skill.palm.han_ngoc_chuong.active_01.human"
const CASTER_ID := "palm_lab_caster"
const TARGET_ID := "palm_lab_moving_monster"
const VIEWPORT_SIZE := Vector2(1280.0, 720.0)
const CASTER_SCREEN := Vector2(365.0, 438.0)
const TARGET_START_X := 765.0
const TARGET_END_X := 809.0
const TARGET_GROUND_Y := 588.0
const SCREEN_PIXELS_PER_WORLD_UNIT := 80.0

var battle: MapBattleV2
var caster_actor: Dictionary = {}
var target_actor: Dictionary = {}
var caster_visual: AnimatedSprite2D
var target_visual: AnimatedSprite2D
var charge_visual: Sprite2D
var peak_visual: Sprite2D
var contact_visual: Sprite2D
var status_label: Label
var details_label: Label
var elapsed := 0.0
var release_at := 0.55
var released := false
var capture_started := false
var cast_id := ""
var receipt_events: Array[Dictionary] = []

func _ready() -> void:
	_build_stage()
	_build_actors()
	_build_effects()
	_start_receipt_cast()
	set_process(true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color("101a2a"))
	draw_rect(Rect2(0.0, 594.0, 1280.0, 126.0), Color("182335"))
	draw_line(Vector2(0.0, 594.0), Vector2(1280.0, 594.0), Color("4d6071"), 2.0, true)
	for x in range(48, 1280, 96):
		draw_line(Vector2(x, 602.0), Vector2(x + 42, 602.0), Color(0.30, 0.39, 0.47, 0.28), 1.0, true)

func _build_stage() -> void:
	var title := _label("HÀN NGỌC CHẤN MẠCH · ART-FIRST LAB", Vector2(36.0, 24.0), 28, Color("f3e6c2"))
	add_child(title)
	var subtitle := _label("G3.5 PREVIEW ONLY · AS60 PALM CANDIDATE + REAL MOVING MONSTER · NO RIG · PVE OFF", Vector2(38.0, 66.0), 16, Color("b6c7d2"))
	add_child(subtitle)
	status_label = _label("INITIALIZING SUPPORTED PALM CAST / RECEIPT PATH…", Vector2(36.0, 648.0), 18, Color("b7e3e8"))
	add_child(status_label)
	details_label = _label("Visual path is preview-only; contact cue waits for the committed one-target hit receipt.", Vector2(38.0, 682.0), 14, Color("a0b1c0"))
	add_child(details_label)

func _build_actors() -> void:
	caster_visual = AnimatedSprite2D.new()
	caster_visual.name = "AS60_PalmCandidateCaster"
	caster_visual.sprite_frames = CASTER_FRAMES
	caster_visual.position = CASTER_SCREEN
	caster_visual.scale = Vector2(0.80, 0.80)
	caster_visual.centered = true
	caster_visual.z_index = 4
	add_child(caster_visual)
	caster_visual.play(&"cast_right")

	target_visual = MONSTER_SCENE.instantiate() as AnimatedSprite2D
	target_visual.name = "RealMovingMonsterTarget"
	target_visual.position = Vector2(TARGET_START_X, TARGET_GROUND_Y)
	target_visual.scale = Vector2(1.05, 1.05)
	target_visual.z_index = 3
	add_child(target_visual)
	target_visual.play(&"walk")

	var caster_tag := _label("AS60 · BODY-ONLY CANDIDATE · CAST_RIGHT → ATTACK_RIGHT", Vector2(220.0, 574.0), 13, Color("eadcb7"))
	caster_tag.z_index = 9
	add_child(caster_tag)
	var target_tag := _label("SOURCE SPINE MONSTER · WALK CLIP", Vector2(675.0, 574.0), 13, Color("d5c4e0"))
	target_tag.z_index = 9
	add_child(target_tag)

func _build_effects() -> void:
	charge_visual = _sprite_for(CHARGE_TEXTURE, 64.0, 618.0, "ChargeSeed")
	charge_visual.position = CASTER_SCREEN + Vector2(72.0, -13.0)
	charge_visual.z_index = 8
	add_child(charge_visual)

	peak_visual = _sprite_for(PEAK_TEXTURE, 120.0, 1363.0, "OpenPalmPressureWave")
	peak_visual.position = charge_visual.position
	peak_visual.visible = false
	peak_visual.z_index = 8
	add_child(peak_visual)

	contact_visual = _sprite_for(CONTACT_TEXTURE, 40.0, 496.0, "ReceiptBoundContactGlint")
	contact_visual.visible = false
	contact_visual.z_index = 10
	add_child(contact_visual)

func _sprite_for(texture: Texture2D, motif_width: float, visible_source_width: float, node_name: String) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = texture
	var scale_factor := motif_width / visible_source_width
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return sprite

func _start_receipt_cast() -> void:
	battle = MapBattleV2.new(20261125)
	battle.active = true
	battle.outcome = "fighting"
	battle.encounter_id = "palm01_han_ngoc_preview_only"
	caster_actor = _actor(CASTER_ID, "disciple", Vector2.ZERO)
	caster_actor["role"] = "mage"
	caster_actor["party_id"] = "palm_art_first_preview"
	caster_actor["stats"]["attack"] = 40.0
	caster_actor["v63_combat_enabled"] = true
	caster_actor["v63_palm_combat_enabled"] = true
	caster_actor["v63_skill_loadout"] = [SKILL_ID]
	target_actor = _actor(TARGET_ID, "enemy", _target_world_position(0.0))
	battle.actors[CASTER_ID] = caster_actor
	battle.actors[TARGET_ID] = target_actor

	var definition := HSC.skill_definition(SKILL_ID)
	if definition.is_empty() or str(definition.get("effect", "")) != "damage" or str(definition.get("shape", "")) != "single_target" or int(definition.get("target_limit", 0)) != 1:
		_fail("Runtime definition does not match the authorized Human single-target damage contract.")
		return
	if not HSC.try_cast(battle, caster_actor, target_actor):
		_fail("V63HumanSkillCombatSystem.try_cast did not select the supported Palm candidate.")
		return
	var pending: Dictionary = caster_actor.get("v63_pending_cast", {})
	if pending.is_empty():
		_fail("Real Palm cast returned no pending cast receipt.")
		return
	cast_id = str(pending.get("mastery_event_id", ""))
	release_at = float(pending.get("ready", 0.55))
	status_label.text = "CAST PENDING · 0.55 S WINDUP · MOVING TARGET REMAINS WITHIN 6.0-RANGE"
	details_label.text = "Charge source is visible at the caster palm; no telegraph event or status cue is invented."
	print("PALM_G35_CAST_PENDING id=", SKILL_ID, " cast_id=", cast_id, " ready=", release_at, " gate=OFF")

func _process(delta: float) -> void:
	if battle == null or released:
		return
	elapsed += delta
	var progress := clampf(elapsed / maxf(0.001, release_at), 0.0, 1.0)
	var target_x := lerpf(TARGET_START_X, TARGET_END_X, progress)
	target_visual.position = Vector2(target_x, TARGET_GROUND_Y)
	target_actor["position"] = _target_world_position(progress)
	battle.actors[TARGET_ID] = target_actor
	battle.now = elapsed
	if elapsed + 0.000001 < release_at:
		return
	_release_and_validate_receipts()

func _release_and_validate_receipts() -> void:
	if released:
		return
	released = true
	caster_visual.play(&"attack_right")
	battle.now = release_at
	battle._release_casts()
	var cast_events: Array[Dictionary] = []
	var release_events: Array[Dictionary] = []
	var hits: Array[Dictionary] = []
	var status_events: Array[Dictionary] = []
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("cast_id", "")) != cast_id:
			continue
		var event_type := str(event.get("type", ""))
		if event_type == "skill_cast":
			cast_events.append(event)
		elif event_type == "skill_release":
			release_events.append(event)
		elif event_type == "v63_skill_hit":
			hits.append(event)
		elif event_type in ["status_applied", "v63_palm_slow_applied", "heal", "cleanse"]:
			status_events.append(event)
	var positive_hits: Array[Dictionary] = []
	for hit in hits:
		if float(hit.get("damage", 0.0)) > 0.0 and str(hit.get("target", hit.get("target_id", ""))) == TARGET_ID:
			positive_hits.append(hit)
	var valid := (
		cast_events.size() == 1
		and release_events.size() == 1
		and positive_hits.size() == 1
		and hits.size() == 1
		and status_events.is_empty()
		and str(release_events[0].get("skill_id", "")) == SKILL_ID
		and str(release_events[0].get("shape", "")) == "single_target"
		and str(positive_hits[0].get("skill_id", "")) == SKILL_ID
		and float(target_actor.get("hp", 0.0)) < float(target_actor.get("max_hp", 0.0))
	)
	if not valid:
		_fail("Receipt validation failed; no Palm wave/contact effect was shown.")
		print("PALM_G35_RECEIPT_FAIL cast=", cast_events.size(), " release=", release_events.size(), " hits=", hits.size(), " positive_target_hits=", positive_hits.size(), " status=", status_events.size())
		return
	receipt_events = [cast_events[0], release_events[0], positive_hits[0]]
	_write_receipt_packet(_definition_summary(positive_hits[0], release_events[0]))
	status_label.text = "REAL RECEIPT PASS · 1 RELEASE · 1 POSITIVE HIT · 0 STATUS CUES"
	details_label.text = "Pressure fan/contact now play from the confirmed one-target event. LAB visual only; V6.3 stays OFF."
	print("PALM_G35_RECEIPT_PASS cast_id=", cast_id, " release=1 hit=1 target=", TARGET_ID, " damage=", positive_hits[0].get("damage", 0.0))
	_play_receipt_bound_wave()

func _definition_summary(hit: Dictionary, release_event: Dictionary) -> Dictionary:
	return {
		"skill_id": SKILL_ID,
		"cast_id": cast_id,
		"contract": {"effect": "damage", "shape": "single_target", "target_limit": 1, "hit_count": 1, "gate": "OFF"},
		"actual_events": _receipt_events_to_json(),
		"hit_target": str(hit.get("target", hit.get("target_id", ""))),
		"damage": float(hit.get("damage", 0.0)),
		"caster_position_at_cast": _vec_array(hit.get("caster_position_at_cast", Vector2.ZERO)),
		"target_position_at_cast": _vec_array(hit.get("target_position_at_cast", Vector2.ZERO)),
		"release_target_position": _vec_array(release_event.get("target_position", Vector2.ZERO)),
		"moving_target_start_screen_x": TARGET_START_X,
		"moving_target_end_screen_x": target_visual.position.x,
		"moving_target_release_world_position": _vec_array(target_actor.get("position", Vector2.ZERO)),
		"target_hp_after": float(target_actor.get("hp", 0.0)),
		"visual_rule": "contact glint only after this positive v63_skill_hit receipt",
		"preview_only": true,
		"save_service_used": false,
		"pve": "OFF"
	}

func _receipt_events_to_json() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for event in receipt_events:
		out.append({
			"type": str(event.get("type", "")),
			"event_id": str(event.get("event_id", "")),
			"cast_id": str(event.get("cast_id", "")),
			"skill_id": str(event.get("skill_id", "")),
			"target": str(event.get("target", event.get("target_id", ""))),
			"damage": float(event.get("damage", 0.0)),
			"shape": str(event.get("shape", "")),
			"caster_position": _vec_array(event.get("caster_position", Vector2.ZERO)),
			"target_position": _vec_array(event.get("target_position", Vector2.ZERO)),
			"caster_position_at_cast": _vec_array(event.get("caster_position_at_cast", Vector2.ZERO)),
			"target_position_at_cast": _vec_array(event.get("target_position_at_cast", Vector2.ZERO))
		})
	return out

func _play_receipt_bound_wave() -> void:
	charge_visual.visible = false
	peak_visual.global_position = charge_visual.global_position
	peak_visual.modulate.a = 0.94
	peak_visual.visible = true
	var target_center := target_visual.global_position + Vector2(0.0, -70.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(peak_visual, "global_position", target_center, 0.15)
	tween.tween_callback(_show_receipt_contact.bind(target_center))

func _show_receipt_contact(target_center: Vector2) -> void:
	peak_visual.visible = false
	contact_visual.global_position = target_center
	contact_visual.modulate.a = 0.95
	contact_visual.visible = true
	var tween := create_tween()
	tween.tween_interval(0.20)
	tween.tween_property(contact_visual, "modulate:a", 0.0, 0.24)
	call_deferred("_capture_pass")

func _capture_pass() -> void:
	if capture_started:
		return
	capture_started = true
	await get_tree().process_frame
	var path := ProjectSettings.globalize_path("res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/evidence/G3_5_NATIVE_1280x720.png")
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		print("PALM_G35_NATIVE_CAPTURE_BLOCKED reason=viewport_texture_unavailable_headless_dummy_renderer")
		get_tree().quit(2)
		return
	var image := viewport_texture.get_image()
	if image == null:
		print("PALM_G35_NATIVE_CAPTURE_BLOCKED reason=viewport_image_unavailable_headless_dummy_renderer")
		get_tree().quit(2)
		return
	var err := image.save_png(path)
	if err != OK:
		print("PALM_G35_CAPTURE_FAIL error=", err)
	else:
		print("PALM_G35_CAPTURE_SAVED ", path, " size=", image.get_width(), "x", image.get_height())
	await get_tree().create_timer(0.35).timeout
	get_tree().quit(0 if err == OK else 1)

func _write_receipt_packet(summary: Dictionary) -> void:
	var path := ProjectSettings.globalize_path("res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/evidence/G3_5_RECEIPT.json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("Could not write Palm-owned receipt evidence.")
		return
	file.store_string(JSON.stringify(summary, "  ", false) + "\n")
	file.close()

func _target_world_position(progress: float) -> Vector2:
	var screen_x := lerpf(TARGET_START_X, TARGET_END_X, clampf(progress, 0.0, 1.0))
	return Vector2((screen_x - CASTER_SCREEN.x) / SCREEN_PIXELS_PER_WORLD_UNIT, 0.0)

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {"metal": 0.0, "wood": 0.0, "water": 0.0, "fire": 0.0, "earth": 0.0, "lightning": 0.0, "wind": 0.0, "ice": 0.0, "yang": 0.0, "nether": 0.0}
	return {
		"id": actor_id,
		"side": side,
		"party_id": "",
		"role": "melee",
		"position": position,
		"hp": 200.0,
		"max_hp": 200.0,
		"range": 1.8,
		"move_speed": 2.0,
		"tier": "normal",
		"stats": {
			"attack": 40.0,
			"defense": 0.0,
			"damage_reduction": 0.0,
			"crit_chance": 0.0,
			"crit_damage": 1.5,
			"crit_resistance": 0.0,
			"defense_penetration": 0.0,
			"lifesteal": 0.0,
			"lifesteal_reduction": 0.0
		},
		"resistances": resistances,
		"status_effects": {},
		"context_sources": [],
		"v63_combat_enabled": true,
		"v63_palm_combat_enabled": true,
		"v63_skill_ready": {},
		"v63_skill_loadout": [],
		"v63_passive_ids": [],
		"v63_combat_clock": -1.0,
		"next_skill": 0.0,
		"learned_guard_factor": 1.0,
		"learned_guard_until": -1.0
	}

func _label(text_value: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.z_index = 12
	return label

func _vec_array(value: Variant) -> Array[float]:
	var vector: Vector2 = value
	return [vector.x, vector.y]

func _fail(message: String) -> void:
	status_label.text = "LAB BLOCKED · " + message
	status_label.add_theme_color_override("font_color", Color("ff9c91"))
	details_label.text = "No generated Palm effect is shown without a real valid receipt."
	push_error("PALM_G35_FAIL " + message)
	print("PALM_G35_RESULT FAIL ", message)
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(1)
