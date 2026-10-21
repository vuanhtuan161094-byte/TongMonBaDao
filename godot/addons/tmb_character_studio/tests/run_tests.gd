extends SceneTree

const Catalog = preload("res://addons/tmb_character_studio/core/source_a_catalog.gd")
const PresetSchema = preload("res://addons/tmb_character_studio/core/preset_schema.gd")
const SandboxPreview = preload("res://addons/tmb_character_studio/core/sandbox_preview.gd")
const SAMPLE_PATH := "res://addons/tmb_character_studio/presets/mau_phap_tu.json"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var catalog: TmbSourceACatalog = Catalog.new()
	catalog.refresh()
	_test_asset_availability(catalog)
	var parsed := PresetSchema.parse_json(FileAccess.get_file_as_string(SAMPLE_PATH))
	_expect(bool(parsed.get("ok", false)), "sample preset JSON parses")
	var preset: Dictionary = parsed.get("data", {})
	var validation := PresetSchema.validate(preset, catalog)
	_expect(validation.is_empty(), "sample preset validates against current rig/skill/equipment authorities: %s" % str(validation))
	_test_deterministic_preset(preset)
	_test_invalid_data(preset, catalog)
	_test_sandbox_preview_is_deterministic(preset, catalog)
	if _failures.is_empty():
		print("DEV CHARACTER STUDIO FOCUSED TESTS: PASS")
		quit(0)
	else:
		for failure in _failures:
			printerr("FAIL: " + failure)
		printerr("DEV CHARACTER STUDIO FOCUSED TESTS: FAIL (%d)" % _failures.size())
		quit(1)

func _test_asset_availability(catalog: TmbSourceACatalog) -> void:
	_expect(catalog.pool_status == "present", "Source A visual pool is available")
	_expect(catalog.rigs.size() == 3, "three verified disciple rigs are discovered")
	var ids := ["1113028_1", "body_1110201", "body_1120402"]
	for asset_id in ids:
		var rig := catalog.get_rig(asset_id)
		_expect(not rig.is_empty(), "rig %s is discoverable" % asset_id)
		var should_be_verified: bool = asset_id != "1113028_1"
		_expect(str(rig.get("asset_status", "")) == ("available" if should_be_verified else "unverified"), "%s integrity status reflects the current asset.json hashes" % asset_id)
		_expect(bool(catalog.validate_rig(asset_id).get("ok", false)) == should_be_verified, "%s SHA validation is honest" % asset_id)
		for clip_name in ["stand", "walk"]:
			_expect(catalog.clip_status(asset_id, clip_name) == ("present" if should_be_verified else "unverified"), "%s %s clip status reflects asset integrity" % [asset_id, clip_name])
		if should_be_verified:
			var actor := catalog.instantiate_actor(asset_id)
			_expect(actor is AnimatedSprite2D, "%s scene instantiates its authored AnimatedSprite2D" % asset_id)
			if actor is AnimatedSprite2D:
				var sprite := actor as AnimatedSprite2D
				_expect(sprite.sprite_frames != null and sprite.sprite_frames.has_animation("stand"), "%s SpriteFrames contains stand" % asset_id)
				_expect(sprite.sprite_frames != null and sprite.sprite_frames.has_animation("walk"), "%s SpriteFrames contains walk" % asset_id)
				actor.free()

func _test_deterministic_preset(preset: Dictionary) -> void:
	var first := PresetSchema.serialize(preset)
	var parsed := PresetSchema.parse_json(first)
	_expect(bool(parsed.get("ok", false)), "serialized preset round-trips")
	var second := PresetSchema.serialize(parsed.get("data", {}))
	_expect(first == second, "canonical preset JSON is deterministic after round-trip")
	var duplicate := preset.duplicate(true)
	_expect(first == PresetSchema.serialize(duplicate), "same preset input produces byte-identical JSON")

func _test_invalid_data(preset: Dictionary, catalog: TmbSourceACatalog) -> void:
	var bad := preset.duplicate(true)
	bad["schema_version"] = 99
	_expect(_has_validation_error(bad, catalog, "schema_version"), "unknown schema version is rejected")
	bad = preset.duplicate(true)
	bad["preset_id"] = "Bad ID!"
	_expect(_has_validation_error(bad, catalog, "preset_id"), "invalid ID is rejected")
	bad = preset.duplicate(true)
	bad["sex"] = "male" if str(preset.get("sex", "")) == "female" else "female"
	_expect(_has_validation_error(bad, catalog, "không tương thích rig"), "rig/sex mismatch is rejected")
	bad = preset.duplicate(true)
	bad["rig_id"] = "not_a_source_asset"
	_expect(_has_validation_error(bad, catalog, "Rig không có"), "unknown rig is rejected")
	bad = preset.duplicate(true)
	bad["asset_path"] = "res://../../private/actor.tscn"
	_expect(_has_validation_error(bad, catalog, "asset_path"), "unsafe asset path is rejected")
	bad = preset.duplicate(true)
	bad["owned_skill_ids"] = ["skill_that_does_not_exist"]
	_expect(_has_validation_error(bad, catalog, "CombatSkillSystem"), "unknown skill reference is rejected")
	bad = preset.duplicate(true)
	bad["owned_skill_ids"] = []
	_expect(_has_validation_error(bad, catalog, "chưa sở hữu"), "slot without owned skill is rejected")
	bad = preset.duplicate(true)
	bad["skill_slots"] = [{"slot": 1, "skill_id": "hoa_cau"}, {"slot": 1, "skill_id": "hoa_cau"}]
	_expect(_has_validation_error(bad, catalog, "duy nhất"), "duplicate skill slot is rejected")
	bad = preset.duplicate(true)
	bad["equipment_set"] = [{"slot": "armor", "recipe_id": "linh_moc_phap_truong"}]
	_expect(_has_validation_error(bad, catalog, "không tương thích slot"), "recipe in wrong equipment slot is rejected")
	bad = preset.duplicate(true)
	bad["profile_seed"] = 12345
	_expect(_has_validation_error(bad, catalog, "seed"), "production generation seed is rejected")
	bad = preset.duplicate(true)
	bad["accuracy"] = 75.0
	_expect(_has_validation_error(bad, catalog, "Accuracy/Evasion"), "Accuracy is not serialized as a runtime stat")
	bad = preset.duplicate(true)
	bad["unexpected_field"] = "not in schema"
	_expect(_has_validation_error(bad, catalog, "không thuộc schema"), "unknown JSON keys are rejected")
	bad = preset.duplicate(true)
	bad["display_scale"] = "large"
	_expect(_has_validation_error(bad, catalog, "display_scale phải là số"), "malformed JSON value types are rejected")
	bad = preset.duplicate(true)
	bad.erase("scope")
	_expect(_has_validation_error(bad, catalog, "Thiếu trường bắt buộc"), "missing required schema fields are rejected")

func _test_sandbox_preview_is_deterministic(preset: Dictionary, catalog: TmbSourceACatalog) -> void:
	var first := SandboxPreview.build(preset, catalog)
	var second := SandboxPreview.build(preset, catalog)
	_expect(bool(first.get("ok", false)) and bool(second.get("ok", false)), "sandbox preview uses the canonical consumers")
	var first_combat: Dictionary = first.get("combat", {})
	var second_combat: Dictionary = second.get("combat", {})
	_expect(JSON.stringify(first_combat.get("stats", {}), "", true) == JSON.stringify(second_combat.get("stats", {}), "", true), "preview stat breakdown is deterministic")
	_expect(not first_combat.get("stats", {}).has("accuracy") and not first_combat.get("stats", {}).has("evasion"), "Accuracy/Evasion are absent from runtime-derived preview stats")
	_expect(str(first.get("root_and_talents_status", "")) == "DESIGN-ONLY", "uninitialized V2 birth layers are labeled DESIGN-ONLY")
	_expect(str(first.get("accuracy_status", "")) == "DESIGN-ONLY" and str(first.get("evasion_status", "")) == "DESIGN-ONLY", "Accuracy/Evasion display status stays DESIGN-ONLY")

func _has_validation_error(preset: Dictionary, catalog: TmbSourceACatalog, fragment: String) -> bool:
	for message in PresetSchema.validate(preset, catalog):
		if str(message).to_lower().contains(fragment.to_lower()):
			return true
	return false

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
