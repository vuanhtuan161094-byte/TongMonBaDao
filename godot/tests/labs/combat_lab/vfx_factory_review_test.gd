extends SceneTree

const FACTORY_SCENE := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.tscn")
const FACTORY_SCRIPT := preload("res://labs/combat_lab/vfx_factory/vfx_factory_review.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const REGISTRY_PATH := "res://labs/combat_lab/vfx_factory/registry.json"
const FORMATION_MANIFEST_PATH := "res://labs/combat_lab/formation01/factory_batch1_20261125/manifest.json"
const FORMATION_CATALOG_PATH := "res://data/combat/v63_formation_combat_catalog.json"

var failures := 0
var checked := 0

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
	_check(registry is Dictionary and manifest is Dictionary and catalog is Dictionary,
		"all source registries parse")
	if not (registry is Dictionary and manifest is Dictionary and catalog is Dictionary):
		_finish()
		return
	var formation_by_id: Dictionary = {}
	for row in manifest.get("skills", []):
		formation_by_id[str(row.get("skill_id", ""))] = row
	var canonical_by_id: Dictionary = {}
	for row in catalog.get("skills", []):
		canonical_by_id[str(row.get("id", ""))] = row
	var cases: Array = registry.get("entries", [])
	_check(cases.size() == 19, "shared registry retains 2 existing cues and adds 17 Formation candidates")
	_check(formation_by_id.size() == 17, "all 17 source atlas records remain available")
	for entry in cases:
		var skill_id := str(entry.get("skill_id", ""))
		var is_formation := skill_id.begins_with("tmb.skill.formation.")
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
			_check(int(state.get("phase_sources_loaded", 0)) == 4 and int(state.get("frame_count", 0)) == 4,
				"four distinct phase poses load from the RGBA atlas " + skill_id)
			_check(int(state.get("actor_asset_id", -1)) == 68,
				"Formation preview resolves existing male AS68 source " + skill_id)
			_check(str(state.get("motion_status", "")) == "FOUR_PHASE_POSES_NOT_FRAME_BY_FRAME",
				"pose sequence is not misreported as continuous animation " + skill_id)
			_check(str(state.get("native_status", "")) == "NATIVE_IMPORT_CAPTURE_PENDING",
				"native result remains pending until shared batch capture " + skill_id)
			_check(str(state.get("owner_status", "")) == "OWNER_VISUAL_PENDING",
				"owner approval remains separate " + skill_id)
			_check(str(entry.get("draw_layer", "")) == "BEHIND"
				and bool(entry.get("preview_attachment_override", {}).get("suppress_attachments", false)),
				"ground formation art is behind AS68 and has no invented weapon " + skill_id)
			_check(FACTORY_SCRIPT.phase_draws_front(entry, "contact") == entry.has("phase_layers"),
				"receipt contact uses its configured front/ground layer " + skill_id)
			if skill_id == "tmb.skill.formation.tu_linh_tran.active_02.human":
				_check(str(state.get("source_g3", "")).begins_with("ART_SEMANTIC_REVIEW_REQUIRED"),
					"damage-versus-shield visual mismatch remains flagged")
			else:
				_check(str(state.get("source_g3", "")) == "SOURCE_ALPHA_AND_CONTACT_SHEET_SELF_PASS",
					"source alpha and both contrast sheets are self-reviewed " + skill_id)
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
		+ " cases=" + str(checked) + " skills=" + str(19)
		+ " formation=17 AS68=resolved contact_fixture=NONE failures=" + str(failures))
	quit(0 if failures == 0 else 1)
