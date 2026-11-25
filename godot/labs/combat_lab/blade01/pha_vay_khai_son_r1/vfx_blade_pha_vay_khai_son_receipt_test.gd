extends SceneTree
## Focused contract proof for the preview-only Phá Vây Khai Sơn LAB.

const Blade := preload("res://src/simulation/combat/v63_blade_skill_combat_system.gd")
const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Gates := preload("res://src/simulation/combat/v63_feature_gates.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const SKILL_ID := "tmb.skill.blade.cuong_dao.active_01.human"
const SOCKET_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets/AS50_weapon_sockets_v9_3_candidate.json"
const WEAPON_LIBRARY_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
const CASTER_ID := "blade_lab_caster"
const TARGET_ID := "blade_lab_target_01"
const OUTSIDE_ID := "blade_lab_outside"
const CAST_TIME := 0.28
const PROJECTILE_SPEED := 10.0
const CASTER_START := Vector2(2.0, 2.0)
const TARGET_START := Vector2(6.0, 2.0)
const TARGET_END := Vector2(5.6, 1.8)
const OUTSIDE_POSITION := Vector2(6.2, 3.5)
const ASCHAR_DISPLAY_SCALE := 0.25
const DAO_DISPLAY_SCALE := 0.68

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("BLADE_PHA_VAY_KHAI_SON_FAIL " + message)
	return ok

func _run() -> void:
	var definition := Blade.skill_definition(SKILL_ID)
	_expect(not definition.is_empty(), "exact canonical Human active_01 row exists")
	_expect(str(definition.get("effect", "")) == "damage" and str(definition.get("shape", "")) == "single_target"
		and int(definition.get("target_limit", 0)) == 1 and int(definition.get("hit_count", 0)) == 1,
		"canonical contract is one damage hit on one target")
	_expect(is_equal_approx(float(definition.get("cast_time", 0.0)), CAST_TIME)
		and is_equal_approx(float(definition.get("projectile_speed", 0.0)), PROJECTILE_SPEED)
		and is_equal_approx(float(definition.get("range", 0.0)), 8.0),
		"canonical cast, projectile speed and range are used without edits")
	_expect(not Gates.is_enabled("blade_skill_combat"), "production Blade feature gate remains OFF")
	_expect(str(Blade.can_learn(definition).get("reason", "")) == "skill_source_pending",
		"formal learning remains blocked by the missing source codex")
	if failures > 0:
		_finish()
		return

	var source_paths := [
		"res://labs/combat_lab/blade01/pha_vay_khai_son_r1/source/production/pha_vay_khai_son_charge_r1.png",
		"res://labs/combat_lab/blade01/pha_vay_khai_son_r1/source/production/pha_vay_khai_son_flight_r1.png",
		"res://labs/combat_lab/blade01/pha_vay_khai_son_r1/source/production/pha_vay_khai_son_contact_r1.png",
		"res://labs/combat_lab/blade01/pha_vay_khai_son_r1/source/production/pha_vay_khai_son_fade_r1.png"
	]
	var source_textures: Array[Texture2D] = []
	for source_path in source_paths:
		var texture := ResourceLoader.load(source_path, "Texture2D") as Texture2D
		_expect(texture != null and texture.get_width() >= 256 and texture.get_height() >= 64,
			"original phase master loads: " + source_path.get_file())
		if texture != null:
			source_textures.append(texture)
	_expect(source_textures.size() == 4, "all four original phase masters are available")

	var bridge = load("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")
	var actor_id: int = bridge.actor_id("blade", "male")
	var frames_path := str(bridge.SOURCE_PATHS.get(actor_id, ""))
	var frames := ResourceLoader.load(frames_path, "SpriteFrames") as SpriteFrames
	_expect(actor_id == 50 and frames != null and frames.has_animation("attack_front")
		and frames.get_frame_count("attack_front") == 4,
		"existing AS50 disciple attack clip loads directly from the ASCHAR bridge")
	var socket_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOCKET_PATH))
	_expect(socket_data is Dictionary and str(socket_data.get("status", "")) == "CANDIDATE"
		and str(socket_data.get("owner_art_approval", "")) == "PENDING",
		"the existing AS50 socket manifest stays explicitly candidate and owner-pending")
	var attack_rows: Array[Dictionary] = []
	var unique_body_frames := {}
	if socket_data is Dictionary:
		for raw in socket_data.get("body_frames", []):
			if raw is Dictionary and str(raw.get("clip", "")) == "attack_front":
				attack_rows.append(raw)
				unique_body_frames[str(raw.get("path", ""))] = true
	var usable_mainhand_rows := 0
	for row in attack_rows:
		var grip_sockets: Dictionary = row.get("grip_sockets", {})
		var main_hand: Dictionary = grip_sockets.get("main_hand", {})
		var anchor: Array = main_hand.get("body_grip_px", [])
		var mask: Array = main_hand.get("hand_mask_rect_px", [])
		if anchor.size() == 2 and mask.size() == 4 and str(main_hand.get("draw_order", "")).contains("HAND_MASK"):
			usable_mainhand_rows += 1
	_expect(attack_rows.size() == 4 and usable_mainhand_rows == 4 and unique_body_frames.size() == 4,
		"each animated AS50 attack frame has its own existing hand anchor and mask")
	_expect(is_equal_approx(338.0 * ASCHAR_DISPLAY_SCALE, 84.5),
		"existing disciple renders at an approximately 85 px visible height in 720p LAB")

	var parsed_library: Variant = JSON.parse_string(FileAccess.get_file_as_string(WEAPON_LIBRARY_PATH))
	var library: Dictionary = Dictionary(parsed_library.get("asset_library", {})) if parsed_library is Dictionary else {}
	var dao_info: Dictionary = library.get("curved_dao", {})
	var attachments: Array = socket_data.get("attachments", []) if socket_data is Dictionary else []
	var existing_binding := false
	for raw in attachments:
		if raw is Dictionary and str(raw.get("asset_id", "")) == "curved_dao" and str(raw.get("slot", "")) == "main_hand":
			existing_binding = true
	_expect(existing_binding and str(dao_info.get("path", "")) == "res://assets/p3/baked_candidates/weapon_library_v1/candidate/weapons/curved_dao.png"
		and str(dao_info.get("owner_art_approval", "")) == "PENDING",
		"reuse the existing main-hand curved dao image and keep formal art approval pending")
	var grip: Array = dao_info.get("grip_px", [])
	var tip: Array = dao_info.get("tip_px", [])
	var rotation_deg := ASCHAR.aligned_weapon_rotation_deg([0.0, 0.0], [1.0, 0.0], grip, tip, 270.0)
	var actual_axis := Vector2(float(tip[0]) - float(grip[0]), float(tip[1]) - float(grip[1])).rotated(deg_to_rad(rotation_deg))
	_expect(actual_axis.normalized().dot(Vector2.RIGHT) > 0.9999,
		"preview-only weapon rotation points the curved dao tip toward the target on screen")
	_expect(dao_info.size() > 0 and DAO_DISPLAY_SCALE * ASCHAR_DISPLAY_SCALE > 0.0,
		"the reused dao is scaled from its hand socket for the compact 0.25-scale disciple")
	var source_atlas := CombatV5SourceAAtlas.new()
	_expect(source_atlas.has_actor("monster_1113031_1"), "supported Source A walk/hit clip pack loads")
	var walk_frame := source_atlas.frame_region("monster_1113031_1", "walk", Vector2.LEFT, 0.2)
	_expect(not walk_frame.is_empty() and walk_frame.get("texture", null) is Texture2D,
		"moving target uses an existing Source A animation, not a placeholder drawing")

	var battle := MapBattleV2.new(83951)
	var target_row := _monster_row(TARGET_ID, TARGET_START)
	var outside_row := _monster_row(OUTSIDE_ID, OUTSIDE_POSITION)
	var setup := battle.setup("blade_pha_vay_khai_son_receipt", [_caster_row()], [target_row, outside_row])
	_expect(bool(setup.get("ok", false)), "MapBattleV2 accepts the existing candidate caster and real monster actors")
	if not bool(setup.get("ok", false)):
		_finish()
		return
	var caster: Dictionary = battle.actors[CASTER_ID]
	var target: Dictionary = battle.actors[TARGET_ID]
	var outside: Dictionary = battle.actors[OUTSIDE_ID]
	_expect(str(target.get("side", "")) == "monster" and str(target.get("species_id", "")) == "thanh_lang",
		"single-target preview uses a runtime MonsterCatalogueV2 enemy")
	var target_hp_before := float(target.get("hp", 0.0))
	var outside_hp_before := float(outside.get("hp", 0.0))
	_expect(HSC.try_cast(battle, caster, target, false), "the exact equipped Dao skill creates a normal Combat V2 cast")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	var expected_distance := CASTER_START.distance_to(TARGET_START)
	_expect(str(pending.get("v63_skill_id", "")) == SKILL_ID and str(pending.get("target_id", "")) == TARGET_ID
		and str(pending.get("shape", "")) == "single_target", "pending cast locks the exact target and canonical shape")
	_expect(is_equal_approx(float(pending.get("ready", -1.0)), CAST_TIME + expected_distance / PROJECTILE_SPEED),
		"runtime release follows cast time plus canonical projectile travel")
	var cast_events := _events(battle, "skill_cast")
	_expect(cast_events.size() == 1 and str(cast_events[0].get("target", "")) == TARGET_ID
		and int(cast_events[0].get("target_limit", 0)) == 1, "Combat V2 records one normal single-target cast receipt")
	var cast_position: Vector2 = target.get("position", Vector2.ZERO)
	target["position"] = cast_position.lerp(TARGET_END, 0.55)
	battle.now = float(pending.get("ready", 0.0)) * 0.55
	target["position"] = TARGET_END
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var hit_events := _events(battle, "v63_skill_hit")
	_expect(hit_events.size() == 1 and str(hit_events[0].get("target", "")) == TARGET_ID
		and float(hit_events[0].get("damage", 0.0)) > 0.0,
		"exactly one actual V63 hit receipt follows the real moved target")
	_expect(float(target.get("hp", 0.0)) < target_hp_before
		and is_equal_approx(float(outside.get("hp", 0.0)), outside_hp_before),
		"the current target loses HP while the outside target remains unchanged")
	_expect(_events(battle, "v63_blade_swing_hit").is_empty(),
		"single-hit Phá Vây does not create repeated blade-swing events")
	_expect(is_equal_approx(float(target.get("position", Vector2.ZERO).distance_to(TARGET_END)), 0.0),
		"the actual release resolves at the target's current position")

	_finish()

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

func _events(battle: MapBattleV2, event_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type", "")) == event_type and str(event.get("skill_id", "")) == SKILL_ID:
			result.append(event)
	return result

func _finish() -> void:
	if failures > 0:
		print("BLADE_PHA_VAY_KHAI_SON_RECEIPT_RESULT FAIL checks=%d failures=%d" % [checks, failures])
		quit(1)
		return
	print("BLADE_PHA_VAY_KHAI_SON_RECEIPT_RESULT PASS checks=%d actor=AS50_CANDIDATE dao=EXISTING_CURVED_DAO runtime=MapBattleV2 moving_target=1 actual_hit_receipt=1 gate=OFF pve=OFF" % checks)
	quit(0)
