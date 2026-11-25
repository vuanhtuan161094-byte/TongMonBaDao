extends SceneTree
## Focused native contract test for Vân Long Điểm Thủy's preview-only LAB.

const Spear := preload("res://src/simulation/combat/v63_spear_skill_combat_system.gd")
const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Gates := preload("res://src/simulation/combat/v63_feature_gates.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const SKILL_ID := "tmb.skill.spear.long_thuong.active_01.human"
const CHARGE_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/charge_r1.png"
const EXPECTED_TARGETS := ["spear_line_target_01","spear_line_target_02"]

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("SPEAR_LONG_THRUST_FAIL " + message)
	return ok

func _run() -> void:
	var definition := Spear.skill_definition(SKILL_ID)
	_expect(not definition.is_empty(), "exact Human skill row exists")
	_expect(str(definition.get("effect","")) == "damage" and str(definition.get("shape","")) == "line"
		and int(definition.get("target_limit",0)) == 2, "canonical contract is damage / line / target_limit 2")
	_expect(is_equal_approx(float(definition.get("cast_time",0.0)),0.38)
		and is_equal_approx(float(definition.get("projectile_speed",-1.0)),0.0),
		"release uses the authored 0.38s windup and no projectile travel")
	_expect(not Gates.is_enabled("spear_skill_combat"), "production Spear feature gate remains OFF")
	_expect(ResourceLoader.load(CHARGE_PATH) is Texture2D,
		"original RGBA charge pose is available to the pre-release candidate renderer")
	if failures > 0:
		_finish()
		return

	var battle := MapBattleV2.new(83711)
	var caster_row := _caster_row()
	var first_row := _monster_row("spear_line_target_01",Vector2(6.0,2.0))
	var second_row := _monster_row("spear_line_target_02",Vector2(7.6,2.3))
	var outside_row := _monster_row("spear_line_outside",Vector2(6.1,3.2))
	var setup := battle.setup("spear_long_thrust_receipt",[caster_row],[first_row,second_row,outside_row])
	_expect(bool(setup.get("ok",false)), "MapBattleV2 accepts a candidate caster and three MonsterCatalogueV2 actors")
	if not bool(setup.get("ok",false)):
		_finish()
		return
	var caster: Dictionary = battle.actors["spear_lab_caster"]
	var first: Dictionary = battle.actors["spear_line_target_01"]
	var second: Dictionary = battle.actors["spear_line_target_02"]
	var outside: Dictionary = battle.actors["spear_line_outside"]
	_expect(str(first.get("side","")) == "monster" and str(first.get("species_id","")) == "thanh_lang",
		"line targets are runtime monster actors, not presentation-only placeholders")
	var outside_hp := float(outside.get("hp",0.0))
	_expect(HSC.try_cast(battle,caster,first), "the exact equipped candidate skill creates a normal runtime cast")
	var cast: Dictionary = caster.get("v63_pending_cast",{})
	_expect(str(cast.get("v63_skill_id","")) == SKILL_ID and str(cast.get("shape","")) == "line"
		and int(cast.get("maximum",0)) == 2, "pending cast carries canonical line geometry and two-target cap")
	if cast.is_empty():
		_finish()
		return

	# Move all three real runtime actors during the actual cast interval.
	var ready_at := float(cast.get("ready",0.0))
	first["position"] = Vector2(6.1,2.15)
	second["position"] = Vector2(7.7,2.35)
	outside["position"] = Vector2(6.2,3.25)
	battle.now = ready_at
	battle._release_casts()
	var line_hits := _events(battle,"v63_spear_line_hit")
	var target_ids := {}
	for event in line_hits:
		target_ids[str(event.get("target",""))] = true
		_expect(int(event.get("target_limit",0)) == 2, "confirmed target receipt preserves target_limit=2")
	_expect(line_hits.size() == 2 and target_ids.has(EXPECTED_TARGETS[0]) and target_ids.has(EXPECTED_TARGETS[1]),
		"exactly two moved in-line monsters produce a committed damage receipt")
	_expect(float(first.get("hp",0.0)) < float(first.get("max_hp",0.0))
		and float(second.get("hp",0.0)) < float(second.get("max_hp",0.0)),
		"both actual in-line monster actors lose HP")
	_expect(is_equal_approx(float(outside.get("hp",0.0)),outside_hp),
		"the actual moved actor outside the line remains unchanged")
	_expect(_events(battle,"v63_skill_hit").size() == 2,
		"two normal skill-hit settlements accompany the line impact receipts")

	var bridge = load("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")
	var actor_id: int = bridge.actor_id("spear","male")
	var candidate_path := str(bridge.SOURCE_PATHS.get(actor_id,""))
	var frames := ResourceLoader.load(candidate_path,"SpriteFrames") as SpriteFrames
	_expect(actor_id == 54 and frames != null and frames.has_animation("attack_right")
		and frames.get_frame_count("attack_right") == 4,
		"renderer loads the actual AS54 candidate attack-right clip without a rig")
	var socket_path := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets/AS54_weapon_sockets_v9_3_candidate.json"
	var socket_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(socket_path))
	_expect(socket_data is Dictionary and str(socket_data.get("status","")) == "CANDIDATE"
		and str(socket_data.get("owner_art_approval","")) == "PENDING",
		"candidate body and two-hand spear sockets remain explicitly provisional")
	var weapon_path := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
	var weapon_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(weapon_path))
	var library: Dictionary = Dictionary(weapon_data.get("asset_library",{})) if weapon_data is Dictionary else {}
	var spear_info: Dictionary = library.get("spear",{})
	var attachments: Array = socket_data.get("attachments",[]) if socket_data is Dictionary else []
	var has_two_hand_spear := false
	for raw_attachment in attachments:
		if raw_attachment is Dictionary and str(raw_attachment.get("asset_id","")) == "spear" and str(raw_attachment.get("support_grip_slot","")) == "off_hand":
			has_two_hand_spear = true
	var attack_right_rows: Array = []
	if socket_data is Dictionary:
		for raw_row in socket_data.get("body_frames",[]):
			if raw_row is Dictionary and str(raw_row.get("clip","")) == "attack_right":
				attack_right_rows.append(raw_row)
	var alignment_ok := false
	var spear_grip: Array = spear_info.get("grip_px",[])
	var spear_tip: Array = spear_info.get("tip_px",[])
	if not attack_right_rows.is_empty() and spear_grip.size() == 2 and spear_tip.size() == 2:
		var grips: Dictionary = Dictionary(attack_right_rows[0].get("grip_sockets",{}))
		var off_hand: Dictionary = Dictionary(grips.get("off_hand",{}))
		var main_hand: Dictionary = Dictionary(grips.get("main_hand",{}))
		var off_px: Array = off_hand.get("body_grip_px",[])
		var main_px: Array = main_hand.get("body_grip_px",[])
		var rotation_deg := ASCHAR.aligned_weapon_rotation_deg(
			off_px,main_px,
			spear_grip,spear_tip)
		var asset_axis := Vector2(float(spear_tip[0])-float(spear_grip[0]),float(spear_tip[1])-float(spear_grip[1]))
		var aligned_axis := asset_axis.rotated(deg_to_rad(rotation_deg))
		var hand_axis := Vector2(float(main_px[0])-float(off_px[0]),float(main_px[1])-float(off_px[1]))
		var off_mask: Array = off_hand.get("hand_mask_rect_px",[])
		var main_mask: Array = main_hand.get("hand_mask_rect_px",[])
		alignment_ok = aligned_axis.normalized().dot(hand_axis.normalized()) > 0.9999 and off_mask.size() == 4 and main_mask.size() == 4
	_expect(has_two_hand_spear and str(spear_info.get("path","")) == "res://assets/p3/baked_candidates/weapon_library_v1/candidate/weapons/spear.png"
		and attack_right_rows.size() == 4 and alignment_ok,
		"the existing spear prop anchors at AS54 off-hand, points toward its main-hand socket, and restores both hands")
	var source_atlas := CombatV5SourceAAtlas.new()
	_expect(source_atlas.has_actor("monster_1113031_1"), "supported Source A placeholder actor pack loads")
	var frame := source_atlas.frame_region("monster_1113031_1","walk",Vector2.LEFT,0.12)
	_expect(not frame.is_empty() and frame.get("texture",null) is Texture2D,
		"moving-target LAB uses a real imported Source A walk clip")
	_finish()

func _caster_row() -> Dictionary:
	var resistances := _zero_resistances()
	return {
		"id":"spear_lab_caster","role":"frontline","position":Vector2(2,2),
		"hp":500.0,"max_hp":500.0,"range":1.8,"basic_range":1.8,"move_speed":2.0,
		"stats":{"max_hp":500.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,
			"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,
			"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"context_sources":[],"skill_loadout":[],
		"v63_combat_enabled":true,"v63_spear_combat_enabled":true,
		"v63_skill_loadout":[SKILL_ID],"v63_skill_ready":{},"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0
	}

func _monster_row(actor_id: String,position: Vector2) -> Dictionary:
	var result := MonsterCatalogueV2.create_actor("thanh_lang",1,1,actor_id)
	if not bool(result.get("ok",false)):
		return {}
	var actor: Dictionary = result
	actor["id"] = actor_id
	actor["position"] = position
	return actor

func _zero_resistances() -> Dictionary:
	var result := {}
	for element in ["metal","wood","water","fire","earth","lightning","wind","ice","yang","nether"]:
		result[element] = 0.0
	return result

func _events(battle: MapBattleV2,event_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type","")) == event_type and str(event.get("skill_id","")) == SKILL_ID:
			result.append(event)
	return result

func _finish() -> void:
	if failures > 0:
		print("SPEAR_LONG_THRUST_RECEIPT_RESULT FAIL checks=%d failures=%d" % [checks,failures])
		quit(1)
		return
	print("SPEAR_LONG_THRUST_RECEIPT_RESULT PASS checks=%d runtime=MapBattleV2 moving_targets=3 line_receipts=2 cap=2 actor=AS54_CANDIDATE source=SourceA_PLACEHOLDER pve=OFF gate=OFF" % checks)
	quit(0)
