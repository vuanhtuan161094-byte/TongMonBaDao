extends SceneTree

const FACTORY_SCENE := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn")
const FACTORY_SCRIPT := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const REGISTRY_PATH := "res://labs/combat_lab/vfx_factory/registry.json"
const FORMATION_MANIFEST_PATH := "res://labs/combat_lab/formation01/factory_batch1_20261125/manifest.json"
const FORMATION_CATALOG_PATH := "res://data/combat/v63_formation_combat_catalog.json"
const TALISMAN_CATALOG_PATH := "res://data/combat/v63_talisman_combat_catalog.json"
const CURSE_CATALOG_PATH := "res://data/combat/v63_curse_combat_catalog.json"
const PALM_CATALOG_PATH := "res://data/combat/v63_palm_combat_catalog.json"
const SPEAR_CATALOG_PATH := "res://data/combat/v63_spear_combat_catalog.json"
const BLADE_CATALOG_PATH := "res://data/combat/v63_blade_combat_catalog.json"
const HUMAN_CATALOG_PATH := "res://data/combat/v63_human_combat_catalog.json"
const FIST_BATCH_MANIFEST_PATH := "res://labs/combat_lab/fist_factory_batch1_20261125/manifest.json"
const SWORD_CATALOG_PATH := "res://data/combat/v63_sword_combat_catalog.json"
const SWORD_BATCH_MANIFEST_PATH := "res://labs/combat_lab/sword_factory_batch1_20261125/manifest.json"

var failures := 0
var checked := 0
var skill_count := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, note: String) -> void:
	checked += 1
	if not ok:
		failures += 1
		push_error("VFX_FACTORY_REVIEW_FAIL " + note)

func _run() -> void:
	var registry: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(FORMATION_MANIFEST_PATH))
	var catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(FORMATION_CATALOG_PATH))
	var talisman_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(TALISMAN_CATALOG_PATH))
	var curse_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(CURSE_CATALOG_PATH))
	var palm_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(PALM_CATALOG_PATH))
	var spear_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(SPEAR_CATALOG_PATH))
	var blade_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(BLADE_CATALOG_PATH))
	var human_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(HUMAN_CATALOG_PATH))
	var fist_manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIST_BATCH_MANIFEST_PATH))
	var sword_catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(SWORD_CATALOG_PATH))
	var sword_manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(SWORD_BATCH_MANIFEST_PATH))
	_check(registry is Dictionary and manifest is Dictionary and catalog is Dictionary and talisman_catalog is Dictionary
		and curse_catalog is Dictionary and palm_catalog is Dictionary and spear_catalog is Dictionary and blade_catalog is Dictionary
		and human_catalog is Dictionary and fist_manifest is Dictionary and sword_catalog is Dictionary and sword_manifest is Dictionary,
		"all source registries parse")
	if not (registry is Dictionary and manifest is Dictionary and catalog is Dictionary and talisman_catalog is Dictionary
		and curse_catalog is Dictionary and palm_catalog is Dictionary and spear_catalog is Dictionary and blade_catalog is Dictionary
		and human_catalog is Dictionary and fist_manifest is Dictionary and sword_catalog is Dictionary and sword_manifest is Dictionary):
		_finish()
		return
	var formation_by_id: Dictionary = {}
	for row in manifest.get("skills", []):
		formation_by_id[str(row.get("skill_id", ""))] = row
	var canonical_by_id: Dictionary = {}
	for row in catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in talisman_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in curse_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in palm_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in spear_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in blade_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in human_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	for row in sword_catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	var cases: Array = registry.get("entries", [])
	skill_count = cases.size()
	_check(cases.size() == 82, "shared registry retains 17 Formation, 15 Talisman, 16 Poison, 11 Fist, 17 Sword and other school candidates")
	var fist_capture: Dictionary = fist_manifest.get("native_capture", {})
	var fist_batch_status := str(fist_manifest.get("status", ""))
	var fist_native_status := str(fist_capture.get("technical_status", ""))
	_check(fist_manifest.get("skills", []).size() == 11
		and (fist_batch_status.begins_with("CANDIDATE; NATIVE_PENDING")
			or fist_native_status.begins_with("NATIVE_TECH_PASS_GODOT_4.7.2_1280x720"))
		and str(fist_capture.get("owner_approval", "")) == "PENDING"
		and str(fist_capture.get("pve", "")) == "HOLD",
		"Fist source/native technical state remains separate from owner approval and PvE")
	var sword_capture: Dictionary = sword_manifest.get("native_capture", {})
	var sword_batch_status := str(sword_manifest.get("status", ""))
	var sword_native_status := str(sword_capture.get("technical_status", ""))
	_check(sword_manifest.get("skills", []).size() == 17
		and (sword_batch_status.begins_with("CANDIDATE; NATIVE_PENDING")
			or sword_native_status.begins_with("NATIVE_TECH_PASS_GODOT_4.7.2_1280x720"))
		and str(sword_capture.get("owner_approval", "PENDING")) == "PENDING"
		and str(sword_capture.get("pve", "HOLD")) == "HOLD",
		"Sword Factory batch contains 17 Human cast masters with separate native, owner and PvE states")
	var ground_scale := FACTORY_SCRIPT.phase_texture_scale(Vector2(512.0, 512.0),
		{"display_width_px":488.0,"display_height_px":238.0})
	_check(absf(ground_scale.x - 488.0 / 512.0) < 0.0001
		and absf(ground_scale.y - 238.0 / 512.0) < 0.0001,
		"shared texture phases accept data-driven ground-plane perspective scale")
	_check(formation_by_id.size() == 17, "all 17 source atlas records remain available")
	for entry in cases:
		var skill_id := str(entry.get("skill_id", ""))
		var is_formation := skill_id.begins_with("tmb.skill.formation.")
		var is_tinh_ban_r2 := skill_id == "tmb.skill.formation.tu_linh_tran.active_02.human"
		var is_talisman := skill_id.begins_with("tmb.skill.talisman.")
		var is_curse := skill_id == "tmb.skill.curse.basic.human"
		var is_blade := skill_id == "tmb.skill.blade.cuong_dao.active_01.human"
		var is_palm := skill_id == "tmb.skill.palm.han_ngoc_chuong.active_01.human"
		var is_spear := skill_id == "tmb.skill.spear.long_thuong.active_01.human"
		var is_sword: bool = skill_id.begins_with("tmb.skill.sword.") and entry.get("native_batch", "") == "sword"
		var is_poison := skill_id.begins_with("tmb.skill.poison.")
		var is_fist: bool = skill_id.begins_with("tmb.skill.fist.") and entry.get("native_batch", "") == "fist"
		var lab := FACTORY_SCENE.instantiate() as Node2D
		lab.call("review_set_skill_id", skill_id)
		root.add_child(lab)
		await process_frame
		var state: Dictionary = lab.call("review_state")
		_check(str(state.get("skill_id", "")) == skill_id, "selected data row " + skill_id)
		_check(absf(float(state.get("actor_scale", 0.0)) - ASCHAR.game_view_scale()) < 0.0001,
			"shared real 1x actor scale " + skill_id)
		_check(str(state.get("receipt_state", "")) == "NO_RECEIPT",
			"no synthetic receipt is fed " + skill_id)
		_check(int(state.get("receipt_target_count", 0)) == 0
			and int(state.get("persistent_receipt_target_count", 0)) == 0
			and int(state.get("contact_receipt_target_count", 0)) == 0,
			"no fabricated hit or status cue " + skill_id)
		for method in ["review_replay", "review_set_paused", "review_set_moving", "review_set_fx",
			"review_set_bright", "review_set_map_zoom", "review_set_speed", "review_seek_phase",
			"review_begin_encounter", "review_feed_authoritative_event", "review_feed_authoritative_basic_hit",
			"review_record_actor_screen_position"]:
			_check(lab.has_method(method), "shared Web Review contract " + method + " " + skill_id)
		if is_formation:
			var source_row: Dictionary = formation_by_id.get(skill_id, {})
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not source_row.is_empty() and not canonical.is_empty(), "source and runtime catalogue join " + skill_id)
			_check(str(state.get("canonical_effect", "")) == str(canonical.get("effect", "")),
				"canonical effect remains data-owned " + skill_id)
			_check(str(state.get("canonical_shape", "")) == str(canonical.get("shape", "")),
				"canonical shape remains data-owned " + skill_id)
			_check(int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0)),
				"canonical target limit remains data-owned " + skill_id)
			if is_tinh_ban_r2:
				_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 16,
					"R2 loads four authored RGBA poses for each of four phases " + skill_id)
				var r2_path := "res://labs/combat_lab/formation01/factory_batch1_20261125/source/rework_tinh_ban_r2/tinh_ban_ho_tam_r2_16pose_rgba.png"
				for phase in ["charge", "release", "contact", "fade"]:
					var phase_source: Dictionary = entry.get("phase_sources", {}).get(phase, {})
					_check(str(phase_source.get("path", "")) == r2_path
						and phase_source.get("frames", []).size() == 4
						and float(phase_source.get("fps", 0.0)) == 16.0,
						"R2 phase uses four source-backed animated poses " + phase)
			else:
				_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 4,
					"four distinct phase poses load from the original RGBA atlas " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 68,
				"Formation preview resolves existing male AS68 source " + skill_id)
			if is_tinh_ban_r2:
				_check(str(state.get("motion_status", "")).begins_with("16_CODE_PAINTED_RGBA_POSES; 4_PER_PHASE;"),
					"R2 source count is explicit without overstating continuous animation " + skill_id)
				_check(str(state.get("source_g3", "")).begins_with("ART_SOURCE_SELF_REVIEWED_R2_ATTACK_MORPHOLOGY;"),
					"damage morphology self-review stays separate from native art review " + skill_id)
				var native_state := str(state.get("native_status", ""))
				_check(native_state == "NATIVE_CAPTURE_PENDING"
					or native_state.begins_with("NATIVE_TECH_PASS_GODOT_4.7.2_1280x720"),
					"R2 native technical state is pending or recorded accurately " + skill_id)
			else:
				_check(str(state.get("motion_status", "")) == "FOUR_PHASE_POSES_NOT_FRAME_BY_FRAME",
					"pose sequence is not misreported as continuous animation " + skill_id)
				_check(str(state.get("native_status", "")) == "NATIVE_TECH_PASS_GODOT_4.7.2_1280x720",
					"native batch technical result is explicit and separate from owner review " + skill_id)
			_check(str(state.get("owner_status", "")) == "OWNER_VISUAL_PENDING",
				"owner approval remains separate " + skill_id)
			_check(str(entry.get("draw_layer", "")) == "BEHIND"
				and bool(entry.get("preview_attachment_override", {}).get("suppress_attachments", false)),
				"ground formation art is behind AS68 and has no invented weapon " + skill_id)
			_check(FACTORY_SCRIPT.phase_draws_front(entry, "contact") == entry.has("phase_layers"),
				"receipt contact uses its configured front/ground layer " + skill_id)
			if not is_tinh_ban_r2:
				_check(str(state.get("source_g3", "")) == "SOURCE_ALPHA_AND_CONTACT_SHEET_SELF_PASS",
					"source alpha and both contrast sheets are self-reviewed " + skill_id)
		elif is_talisman:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Talisman runtime catalogue join " + skill_id)
			_check(str(state.get("canonical_effect", "")) == str(canonical.get("effect", ""))
				and str(state.get("canonical_shape", "")) == str(canonical.get("shape", ""))
				and int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0)),
				"Talisman canonical effect, shape and cap remain data-owned " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 64,
				"Talisman preview resolves existing AS64 source " + skill_id)
			var minimum_frame_count := 8
			var expected_phase_source_count := 4
			if skill_id in ["tmb.skill.talisman.phong_an_phu.active_01.human",
				"tmb.skill.talisman.phong_an_phu.active_02.human"]:
				minimum_frame_count = 4
			if skill_id == "tmb.skill.talisman.phong_an_phu.ultimate.human":
				expected_phase_source_count = 5
				minimum_frame_count = 56
			if skill_id == "tmb.skill.talisman.phong_an_phu.active_02.human":
				expected_phase_source_count = 5
				minimum_frame_count = 5
			_check(int(state.get("phase_sources_loaded", 0)) == expected_phase_source_count
				and int(state.get("frame_count", 0)) >= minimum_frame_count,
				"source-backed Factory phases load with explicit still-frame limits " + skill_id)
			if skill_id in ["tmb.skill.talisman.phong_an_phu.active_01.human",
				"tmb.skill.talisman.phong_an_phu.active_02.human"]:
				_check(str(entry.get("motion_status", "")).contains("STATIC")
					or str(entry.get("motion_status", "")).contains("TWO_SOURCE_STILLS"),
					"limited PAF source motion is reported truthfully " + skill_id)
			var talisman_native_status := str(entry.get("native_status", ""))
			if talisman_native_status == "NATIVE_CAPTURE_PENDING":
				_check(str(entry.get("native_batch", "")) == "talisman"
					and not bool(entry.get("native_ready", true)),
					"Talisman capture-pending candidate stays gated " + skill_id)
			else:
				_check(str(entry.get("native_batch", "")) == "talisman"
					and talisman_native_status.begins_with("NATIVE_TECH_PASS_GODOT_4.7.2_1280x720"),
					"Talisman native technical capture is recorded separately from art review " + skill_id)
			var binding_types: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				binding_types.append(str(binding.get("event_type", "")))
			if skill_id == "tmb.skill.talisman.phong_an_phu.active_02.human":
				_check(binding_types.has("skill_cast") and binding_types.has("skill_release")
					and not binding_types.has("v63_talisman_mark_applied"),
					"PAF02 preview accepts cast/release only while its real mark receipt is absent " + skill_id)
			elif skill_id == "tmb.skill.talisman.phong_an_phu.ultimate.human":
				_check(binding_types.has("skill_cast") and binding_types.has("skill_release")
					and binding_types.has("v63_talisman_mark_applied")
					and not binding_types.has("v63_talisman_hit"),
					"PAF05 contact and seven-second status use only the real mark receipt " + skill_id)
				_check(str(entry.get("source_g3", "")).contains("R5E_OWNER_PROVISIONAL")
					and str(entry.get("source_g3", "")).contains("R5F_CHARGE_ONLY_CANDIDATE"),
					"PAF05 preserves R5E while isolating the R5F charge candidate " + skill_id)
			elif str(canonical.get("effect", "")) == "mark":
				_check(binding_types.has("v63_talisman_mark_applied")
					and not binding_types.has("v63_talisman_hit"),
					"mark only appears after the authoritative owner-scoped mark receipt " + skill_id)
			elif str(canonical.get("effect", "")) == "mobility":
				_check(binding_types.has("v63_mobility")
					and not binding_types.has("v63_talisman_hit"),
					"mobility start/end cue follows only the authoritative movement receipt " + skill_id)
			elif str(canonical.get("slot", "")) == "basic":
				_check(binding_types.has("hit")
					and not binding_types.has("v63_talisman_hit"),
					"basic contact uses exact MapBattle basic-hit receipt and actor loadout " + skill_id)
			else:
				_check(binding_types.has("v63_talisman_hit"),
					"damage contact remains bound to a real exact-skill hit " + skill_id)
			_check(not str(entry.get("owner_status", "")).contains("OWNER_VISUAL_APPROVED"),
				"current Factory adapter does not inherit historical source approval " + skill_id)
		elif is_curse:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Curse canonical skill contract joins " + skill_id)
			_check(str(state.get("canonical_effect", "")) == "damage"
				and str(state.get("canonical_shape", "")) == "single_target"
				and int(state.get("canonical_target_limit", 0)) == 1,
				"Curse effect, shape and target cap remain canonical-data-owned " + skill_id)
			_check(float(canonical.get("projectile_speed", -1.0)) == 0.0,
				"direct Curse basic has no projectile travel " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 66,
				"Curse uses the existing AS66 actor resolved by the shared bridge " + skill_id)
			var curse_anchors: Dictionary = ASCHAR.resolve_preview_anchors("curse", "male", "cast",
				Vector2.RIGHT, 0.2, Vector2(300.0, 492.0), ASCHAR.game_view_scale(), 0.32,
				{"suppress_attachments":true})
			_check(curse_anchors.get("slots", {}).has("hand_r"),
				"Curse charge anchor resolves the existing authored right-hand socket " + skill_id)
			_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 9,
				"selected nontravel RGBA frames load across four shared Factory phases " + skill_id)
			_check(str(entry.get("native_capture_mode", "")) == "REVIEW_STORYBOARD_ONLY"
				and str(entry.get("review_timeline", {}).get("clock", "")) == "REVIEW_STORYBOARD_ONLY"
				and str(entry.get("native_status", "")).begins_with("NATIVE_STORYBOARD_TECH_PASS_GODOT_4.7.2_1280x720"),
				"native preview is a storyboard and creates no gameplay receipt " + skill_id)
			_check(entry.get("receipt_manifest", {}).get("bindings", []).is_empty()
				and str(entry.get("native_batch", "")) == "curse",
				"no Curse hit/status binding is fabricated while its release gate is off " + skill_id)
			_check(str(entry.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and not bool(entry.get("native_ready", true)),
				"candidate remains owner-pending and not runtime-ready " + skill_id)
			lab.call("review_seek_phase", "contact")
			var contact_wait: Dictionary = lab.call("review_state")
			_check(str(contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
				and int(contact_wait.get("contact_receipt_target_count", -1)) == 0,
				"contact stays hidden without a real Curse receipt " + skill_id)
		elif is_blade:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Blade canonical runtime catalogue joins " + skill_id)
			_check(str(state.get("canonical_effect", "")) == "damage"
				and str(state.get("canonical_shape", "")) == "single_target"
				and int(state.get("canonical_target_limit", 0)) == 1
				and float(canonical.get("projectile_speed", 0.0)) == 10.0,
				"Blade projectile effect, shape, speed and target cap stay canonical-data-owned " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 50,
				"Blade uses the existing AS50 disciple at shared 1x scale " + skill_id)
			_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 4,
				"all four original RGBA Blade phases load through the shared renderer " + skill_id)
			_check(str(entry.get("native_batch", "")) == "blade"
				and str(entry.get("native_capture_mode", "")) != "REVIEW_STORYBOARD_ONLY",
				"Blade native capture is bound to a real receipt fixture " + skill_id)
			var blade_bindings: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				blade_bindings.append(str(binding.get("event_type", "")))
			_check(blade_bindings.has("skill_cast") and blade_bindings.has("v63_skill_hit"),
				"Blade charge and contact are tied to real MapBattleV2 events " + skill_id)
			var blade_anchors: Dictionary = ASCHAR.resolve_preview_anchors("blade", "male", "attack",
				Vector2.RIGHT, 0.2, Vector2(300.0, 492.0), ASCHAR.game_view_scale(), 0.28,
				entry.get("preview_attachment_override", {}))
			_check(blade_anchors.get("slots", {}).has("weapon_tip")
				and str(blade_anchors["weapon_tip"].get("asset_id", "")) == "curved_dao",
				"Blade charge uses the existing AS50 main-hand DAO tip socket " + skill_id)
			_check(str(entry.get("phase_anchors", {}).get("contact", "")) == "target_chest"
				and str(entry.get("phase_anchors", {}).get("fade", "")) == "target_chest",
				"Blade contact and fade sit on the target torso, matching its native lab " + skill_id)
			_check(str(entry.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and not bool(entry.get("native_ready", true)),
				"Blade remains a candidate with owner and production gates pending " + skill_id)
			lab.call("review_seek_phase", "contact")
			var contact_wait: Dictionary = lab.call("review_state")
			_check(str(contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
				and int(contact_wait.get("contact_receipt_target_count", -1)) == 0,
				"Blade contact stays hidden before a real skill hit receipt " + skill_id)
		elif is_palm or is_spear:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Palm/Spear canonical runtime catalogue join " + skill_id)
			_check(str(state.get("canonical_effect", "")) == "damage"
				and str(state.get("canonical_shape", "")) == str(canonical.get("shape", ""))
				and int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0))
				and float(canonical.get("projectile_speed", -1.0)) == 0.0,
				"direct damage mechanic, target cap and no projectile remain canonical-data-owned " + skill_id)
			var expected_actor_id := 60 if is_palm else 54
			_check(int(state.get("actor_asset_id", -1)) == expected_actor_id,
				"existing school-specific AS-CHAR cast/weapon source resolves " + skill_id)
			var expected_targets := 1 if is_palm else 2
			_check(int(state.get("preview_target_count", 0)) == expected_targets,
				"configured real-target fixture matches the canonical cap " + skill_id)
			_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 4,
				"RGBA phase masters load through the shared renderer " + skill_id)
			_check(str(entry.get("native_batch", "")) == ("palm" if is_palm else "spear"),
				"batch capture uses the shared school runner " + skill_id)
			_check(str(entry.get("native_status", "")).begins_with(
				"NATIVE_TECH_PASS_GODOT_4.7.2_1280x720_H264_FULL_DECODE")
				and not bool(entry.get("native_ready", true)),
				"native decode pass stays separate from runtime readiness " + skill_id)
			var binding_types: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				binding_types.append(str(binding.get("event_type", "")))
			_check(binding_types.has("skill_cast") and binding_types.has("skill_release")
				and binding_types.has("v63_skill_hit"),
				"charge, release and contact use exact V63 cast/release/hit events " + skill_id)
			if is_palm:
				var palm_anchors: Dictionary = ASCHAR.resolve_preview_anchors("palm", "male", "cast",
					Vector2.RIGHT, 0.2, Vector2(300.0, 492.0), ASCHAR.game_view_scale(), 0.32,
					{"suppress_attachments":true})
				_check(palm_anchors.get("slots", {}).has("hand_r"),
					"Palm charge and release use the existing AS60 right-hand socket " + skill_id)
			else:
				var spear_anchors: Dictionary = ASCHAR.resolve_preview_anchors("spear", "male", "attack",
					Vector2.RIGHT, 0.2, Vector2(300.0, 492.0), ASCHAR.game_view_scale(), 0.32, {})
				_check(spear_anchors.get("slots", {}).has("weapon_tip"),
					"Spear release originates from the candidate AS54 Weapon Library tip socket " + skill_id)
				_check(str(entry.get("phase_spans", {}).get("release", {}).get("to_actor_id", ""))
					== "factory_spear_target_02",
					"Spear line release ends at the second configured target " + skill_id)
			_check(str(state.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and not bool(entry.get("native_ready", true)),
				"Factory integration remains a candidate pending owner approval " + skill_id)
			lab.call("review_seek_phase", "contact")
			var contact_wait: Dictionary = lab.call("review_state")
			_check(str(contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
				and int(contact_wait.get("contact_receipt_target_count", -1)) == 0,
				"contact remains hidden until the native runner supplies a real skill hit " + skill_id)
		elif is_sword:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Sword Human catalogue joins " + skill_id)
			_check(str(state.get("canonical_effect", "")) == str(canonical.get("effect", ""))
				and str(state.get("canonical_shape", "")) == str(canonical.get("shape", ""))
				and int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0)),
				"Sword effect, shape and target cap remain canonical-data-owned " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 48,
				"Sword resolves the existing AS48 actor through the school bridge " + skill_id)
			var phase_rows: Dictionary = entry.get("phase_sources", {})
			var expected_frames := 0
			for phase_name in phase_rows:
				expected_frames += phase_rows[phase_name].get("frames", []).size()
			_check(int(state.get("phase_sources_loaded", 0)) == phase_rows.size()
				and int(state.get("frame_count", 0)) == expected_frames and expected_frames > 0,
				"Sword source frames load through the shared renderer " + skill_id)
			var sword_fixture_position: Array = entry.get("fixture_target_position", [])
			var sword_fixture_distance := INF
			if sword_fixture_position.size() == 2:
				sword_fixture_distance = Vector2(2.0, 3.0).distance_to(
					Vector2(float(sword_fixture_position[0]), float(sword_fixture_position[1])))
			_check(sword_fixture_position.size() == 2 and sword_fixture_distance > 0.0
				and sword_fixture_distance < float(canonical.get("range", 0.0)),
				"Sword exact-skill fixture target stays inside canonical range " + skill_id)
			var sword_override: Dictionary = entry.get("preview_attachment_override", {})
			var sword_anchors: Dictionary = ASCHAR.resolve_preview_anchors("sword", "male", "attack",
				Vector2.DOWN, 0.2, Vector2(300.0, 492.0), ASCHAR.game_view_scale(), 0.35, sword_override)
			var sword_slots: Dictionary = sword_anchors.get("slots", {})
			var sword_grip: Dictionary = sword_slots.get("weapon_grip", {})
			var sword_tip: Dictionary = sword_slots.get("weapon_tip", {})
			var sword_grip_position: Vector2 = sword_grip.get("grip_position", Vector2.ZERO)
			var sword_tip_position: Vector2 = sword_tip.get("tip_position", Vector2.ZERO)
			_check(sword_tip.has("asset_id")
				and str(sword_tip.get("asset_id", "")) == "owner_liked_jian_existing"
				and sword_tip_position.x > sword_grip_position.x,
				"Sword release resolves the existing Jian and aims the AS48 tip toward its target " + skill_id)
			_check(str(entry.get("source_owner_gate", "")).length() > 0
				and str(entry.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and (str(entry.get("native_status", "")) == "NATIVE_PENDING"
					or str(entry.get("native_status", "")).begins_with("NATIVE_TECH_PASS_"))
				and not bool(entry.get("native_ready", true)),
				"Sword source gate, native result and owner review remain separate " + skill_id)
			var sword_bindings: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				sword_bindings.append(str(binding.get("event_type", "")))
			if str(canonical.get("effect", "")) == "guard":
				_check(sword_bindings.has("status_applied") and not sword_bindings.has("v63_skill_hit"),
					"Sword guard shows only its real status receipt " + skill_id)
			elif str(canonical.get("effect", "")) == "mobility":
				_check(sword_bindings.has("v63_mobility") and not sword_bindings.has("v63_skill_hit"),
					"Sword mobility follows only its real movement receipt " + skill_id)
			else:
				_check(sword_bindings.has("skill_cast") and sword_bindings.has("skill_release")
					and sword_bindings.has("v63_skill_hit"),
					"Sword damage contact uses exact MapBattle hit receipt " + skill_id)
				if int(canonical.get("target_limit", 1)) > 1:
					_check(entry.get("preview_targets", []).size() == int(canonical.get("target_limit", 1)),
						"Sword multi-target fixture matches canonical target cap " + skill_id)
				lab.call("review_seek_phase", "contact")
				var sword_contact_wait: Dictionary = lab.call("review_state")
				_check(str(sword_contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
					and int(sword_contact_wait.get("contact_receipt_target_count", -1)) == 0,
					"Sword contact remains hidden without a real receipt " + skill_id)
		elif is_fist:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Fist Human catalogue joins " + skill_id)
			_check(str(state.get("canonical_effect", "")) == str(canonical.get("effect", ""))
				and str(state.get("canonical_shape", "")) == str(canonical.get("shape", ""))
				and int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0)),
				"Fist effect, shape and target cap remain canonical-data-owned " + skill_id)
			var fixture_target_position: Array = entry.get("fixture_target_position", [])
			var fixture_distance := INF
			if fixture_target_position.size() == 2:
				fixture_distance = Vector2(2.0, 3.0).distance_to(
					Vector2(float(fixture_target_position[0]), float(fixture_target_position[1])))
			_check(fixture_target_position.size() == 2 and fixture_distance > 0.0
				and fixture_distance < float(canonical.get("range", 0.0)),
				"Fist fixture target stays inside the canonical skill range " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 58,
				"Fist resolves the existing AS58 actor through the school bridge " + skill_id)
			var phase_rows: Dictionary = entry.get("phase_sources", {})
			var expected_frames := 0
			for phase_name in phase_rows:
				expected_frames += phase_rows[phase_name].get("frames", []).size()
			_check(int(state.get("phase_sources_loaded", 0)) == phase_rows.size()
				and int(state.get("frame_count", 0)) == expected_frames and expected_frames > 0,
				"Fist source frames load through the shared renderer " + skill_id)
			_check(str(entry.get("source_lab_visual_status", "")) == "NOT_ART_APPROVED"
				and str(entry.get("source_owner_gate", "")) == "OWNER_VISUAL_PENDING"
				and str(entry.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and (str(entry.get("native_status", "")) == "NATIVE_PENDING"
					or str(entry.get("native_status", "")).begins_with("NATIVE_TECH_PASS_"))
				and not bool(entry.get("native_ready", true)),
				"source and owner gates stay separate from Factory candidates " + skill_id)
			var fist_bindings: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				fist_bindings.append(str(binding.get("event_type", "")))
			if str(canonical.get("effect", "")) == "guard":
				_check(fist_bindings.has("status_applied") and not fist_bindings.has("v63_skill_hit"),
					"Fist guard shows only its real status receipt " + skill_id)
			else:
				_check(fist_bindings.has("skill_cast") and fist_bindings.has("skill_release")
					and fist_bindings.has("v63_skill_hit"),
					"Fist contact is bound to its exact MapBattle skill hit " + skill_id)
			if str(canonical.get("effect", "")) == "mark":
				_check(fist_bindings.has("status_applied"),
					"Fist mark sustain uses its exact status receipt " + skill_id)
			if skill_id == "tmb.skill.fist.huyet_quyen.active_04.human":
				_check(str(entry.get("source_revision", "")).begins_with("FIST14_R5")
					and not str(entry.get("source_paths", [])).contains("r7_luminous")
					and not str(entry.get("source_paths", [])).contains("r8_pressure_knot"),
					"Fist14 reuses only the R5 candidate and preserves the R7/R8 G3 failures")
			lab.call("review_seek_phase", "contact")
			var fist_contact_wait: Dictionary = lab.call("review_state")
			_check(str(fist_contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
				and int(fist_contact_wait.get("contact_receipt_target_count", -1)) == 0,
				"Fist contact remains hidden without a real receipt " + skill_id)
		elif is_poison:
			var canonical: Dictionary = canonical_by_id.get(skill_id, {})
			_check(not canonical.is_empty(), "Poison Human catalogue joins " + skill_id)
			_check(str(state.get("canonical_effect", "")) == str(canonical.get("effect", ""))
				and str(state.get("canonical_shape", "")) == str(canonical.get("shape", ""))
				and int(state.get("canonical_target_limit", 0)) == int(canonical.get("target_limit", 0)),
				"Poison effect, shape and target cap remain canonical-data-owned " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 62,
				"Poison uses the existing AS62 actor through the shared bridge " + skill_id)
			var phase_rows: Dictionary = entry.get("phase_sources", {})
			var expected_frames := 0
			for phase_name in phase_rows:
				expected_frames += phase_rows[phase_name].get("frames", []).size()
			_check(int(state.get("phase_sources_loaded", 0)) == phase_rows.size()
				and int(state.get("frame_count", 0)) == expected_frames and expected_frames > 0,
				"Poison source frame sequences load through the shared renderer " + skill_id)
			_check(str(entry.get("owner_status", "")) == "OWNER_VISUAL_PENDING"
				and not str(entry.get("source_owner_gate", "")).is_empty()
				and not bool(entry.get("native_ready", true)),
				"Factory approval stays pending while the original source gate is preserved " + skill_id)
			var poison_bindings: Array[String] = []
			for binding in entry.get("receipt_manifest", {}).get("bindings", []):
				poison_bindings.append(str(binding.get("event_type", "")))
			var effect := str(canonical.get("effect", ""))
			if str(canonical.get("slot", "")) == "basic":
				_check(poison_bindings.has("hit") and not poison_bindings.has("v63_skill_hit"),
					"Poison basic contact uses the exact MapBattle basic receipt " + skill_id)
			elif effect in ["damage", "poison", "mark"]:
				_check(poison_bindings.has("skill_cast") and poison_bindings.has("skill_release")
					and poison_bindings.has("v63_skill_hit"),
					"Poison cast and contact use real exact-skill events " + skill_id)
				if effect in ["poison", "mark"]:
					_check(poison_bindings.has("status_applied"),
						"Poison or mark state needs its exact status receipt " + skill_id)
			elif effect == "heal":
				_check(poison_bindings.has("heal") and entry.has("fixture_setup"),
					"Poison heal is receipt-bound after separately recorded fixture setup " + skill_id)
			elif effect == "cleanse":
				_check(poison_bindings.has("cleanse") and entry.has("fixture_setup"),
					"Poison cleanse is receipt-bound after separately recorded fixture setup " + skill_id)
			elif effect == "mobility":
				_check(poison_bindings.has("v63_mobility"),
					"Poison mobility uses the authoritative movement receipt " + skill_id)
			lab.call("review_seek_phase", "contact")
			var poison_contact_wait: Dictionary = lab.call("review_state")
			_check(str(poison_contact_wait.get("receipt_state", "")) == "WAITING_FOR_REAL_RECEIPT"
				and int(poison_contact_wait.get("contact_receipt_target_count", -1)) == 0,
				"Poison contact remains hidden without a real receipt " + skill_id)
		else:
			_check(str(state.get("canonical_effect", "")) == "damage",
				"existing candidate canonical effect preserved " + skill_id)
			_check(int(state.get("phase_sources_loaded", 0)) == 3 and int(state.get("frame_count", 0)) == 3,
				"existing candidate phase sources remain intact " + skill_id)
		lab.queue_free()
		await process_frame
	_finish()

func _finish() -> void:
	print("VFX_FACTORY_REVIEW_RESULT=" + ("PASS" if failures == 0 else "FAIL")
		+ " cases=" + str(checked) + " skills=" + str(skill_count)
		+ " formation=17 talisman=15 poison=16 fist=11 AS58=resolved AS62=resolved curse=AS66_storyboard blade=AS50 receipt palm=AS60 spear=AS54 failures=" + str(failures))
	quit(0 if failures == 0 else 1)
