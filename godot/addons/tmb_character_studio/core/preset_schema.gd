@tool
class_name TmbCharacterPresetSchema
extends RefCounted

const VERSION := 1
const SCOPE := "dev_character_studio_sandbox"
const ROLES := ["frontline", "ranged", "mage", "healer"]
const FOUNDATION_KEYS := ["aptitude", "constitution", "fortune", "comprehension", "charisma", "potential"]
const TRACKS := ["cultivation", "body"]
const PRESET_KEYS := ["schema_version", "scope", "preset_id", "name", "sex", "role", "rig_id", "asset_path", "display_scale", "pivot_offset", "attributes", "progression", "skill_stage_index", "owned_skill_ids", "skill_slots", "equipment_set"]
const SkillSystem = preload("res://src/simulation/combat/combat_skill_system.gd")
const GearSystem = preload("res://src/simulation/equipment/equipment_system.gd")
const RealmProgress = preload("res://src/simulation/cultivation/disciple_realm_progress_v2.gd")

static func default_preset(catalog: TmbSourceACatalog) -> Dictionary:
	var rig_id := ""
	var sex := "female"
	if catalog != null and not catalog.rigs.is_empty():
		for candidate in catalog.rigs:
			var candidate_id := str(candidate.get("asset_id", ""))
			if bool(catalog.validate_rig(candidate_id).get("ok", false)):
				rig_id = candidate_id
				sex = str(candidate.get("sex", "female"))
				break
		if rig_id.is_empty():
			rig_id = str(catalog.rigs[0].get("asset_id", ""))
			sex = str(catalog.rigs[0].get("sex", "female"))
	var rig := catalog.get_rig(rig_id) if catalog != null and not rig_id.is_empty() else {}
	return {
		"schema_version": VERSION,
		"scope": SCOPE,
		"preset_id": "test_adept",
		"name": "Mẫu Đệ Tử",
		"sex": sex,
		"role": "frontline",
		"rig_id": rig_id,
		"asset_path": str(rig.get("scene_path", "")),
		"display_scale": 0.34,
		"pivot_offset": [0.0, 0.0],
		"attributes": {
			"aptitude": 20.0,
			"constitution": 20.0,
			"fortune": 20.0,
			"comprehension": 20.0,
			"charisma": 20.0,
			"potential": 20.0
		},
		"progression": {
			"cultivation": {"realm": 1, "floor": 1},
			"body": {"realm": 1, "floor": 1}
		},
		"skill_stage_index": 0,
		"owned_skill_ids": [],
		"skill_slots": [],
		"equipment_set": []
	}

static func normalize(raw: Dictionary) -> Dictionary:
	var result := default_preset(null)
	result["schema_version"] = int(raw.get("schema_version", 0))
	result["scope"] = str(raw.get("scope", ""))
	result["preset_id"] = str(raw.get("preset_id", "")).strip_edges()
	result["name"] = str(raw.get("name", "")).strip_edges()
	result["sex"] = str(raw.get("sex", "")).strip_edges()
	result["role"] = str(raw.get("role", "")).strip_edges()
	result["rig_id"] = str(raw.get("rig_id", "")).strip_edges()
	result["asset_path"] = str(raw.get("asset_path", "")).strip_edges()
	result["display_scale"] = float(raw.get("display_scale", 0.34))
	var raw_pivot: Variant = raw.get("pivot_offset", [0.0, 0.0])
	result["pivot_offset"] = [float(raw_pivot[0]), float(raw_pivot[1])] if raw_pivot is Array and raw_pivot.size() == 2 else [0.0, 0.0]
	var raw_attributes: Variant = raw.get("attributes", {})
	var attributes: Dictionary = {}
	for key in FOUNDATION_KEYS:
		attributes[key] = float(raw_attributes.get(key, 0.0)) if raw_attributes is Dictionary else 0.0
	result["attributes"] = attributes
	var raw_progression: Variant = raw.get("progression", {})
	var progression: Dictionary = {}
	for track in TRACKS:
		var row: Variant = raw_progression.get(track, {}) if raw_progression is Dictionary else {}
		progression[track] = {
			"realm": int(row.get("realm", 1)) if row is Dictionary else 1,
			"floor": int(row.get("floor", 1)) if row is Dictionary else 1
		}
	result["progression"] = progression
	result["skill_stage_index"] = int(raw.get("skill_stage_index", 0))
	var owned: Array[String] = []
	var raw_owned: Variant = raw.get("owned_skill_ids", [])
	if raw_owned is Array:
		for skill_id in raw_owned:
			owned.append(str(skill_id))
	owned.sort()
	result["owned_skill_ids"] = owned
	var slots: Array[Dictionary] = []
	var raw_slots: Variant = raw.get("skill_slots", [])
	if raw_slots is Array:
		for slot in raw_slots:
			if slot is Dictionary:
				slots.append({"slot": int(slot.get("slot", 0)), "skill_id": str(slot.get("skill_id", ""))})
	slots.sort_custom(func(a, b): return int(a["slot"]) < int(b["slot"]))
	result["skill_slots"] = slots
	var equipment: Array[Dictionary] = []
	var raw_equipment: Variant = raw.get("equipment_set", [])
	if raw_equipment is Array:
		for item in raw_equipment:
			if item is Dictionary:
				equipment.append({"slot": str(item.get("slot", "")), "recipe_id": str(item.get("recipe_id", ""))})
	equipment.sort_custom(func(a, b): return GearSystem.VALID_SLOTS.find(StringName(a["slot"])) < GearSystem.VALID_SLOTS.find(StringName(b["slot"])) )
	result["equipment_set"] = equipment
	return result

static func serialize(raw: Dictionary) -> String:
	return JSON.stringify(normalize(raw), "  ", true)

static func parse_json(source: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(source) != OK or not (parser.data is Dictionary):
		return {"ok": false, "error": "JSON không hợp lệ hoặc gốc không phải object.", "data": {}}
	return {"ok": true, "error": "", "data": parser.data.duplicate(true)}

static func validate(raw: Variant, catalog: TmbSourceACatalog) -> Array[String]:
	var errors: Array[String] = []
	if not (raw is Dictionary):
		errors.append("Preset phải là JSON object.")
		return errors
	var preset: Dictionary = raw
	var shape_errors := _validate_shape(preset)
	if not shape_errors.is_empty():
		return shape_errors
	if int(preset.get("schema_version", 0)) != VERSION:
		errors.append("schema_version không được hỗ trợ; cần %d." % VERSION)
	if str(preset.get("scope", "")) != SCOPE:
		errors.append("Preset phải thuộc sandbox Dev Character Studio.")
	if preset.has("profile_seed") or preset.has("latent_identity_seed"):
		errors.append("Không lưu seed sinh đệ tử vào preset studio.")
	if preset.has("accuracy") or preset.has("evasion"):
		errors.append("Accuracy/Evasion chỉ DESIGN-ONLY, không được ghi vào preset runtime.")
	var preset_id := str(preset.get("preset_id", ""))
	var id_regex := RegEx.new()
	id_regex.compile("^[a-z][a-z0-9_]{1,47}$")
	if id_regex.search(preset_id) == null:
		errors.append("preset_id chỉ dùng a-z, 0-9, dấu gạch dưới; bắt đầu bằng chữ thường.")
	var display_name := str(preset.get("name", "")).strip_edges()
	if display_name.is_empty() or display_name.length() > 64:
		errors.append("Tên nhân vật phải dài 1–64 ký tự.")
	if not ["male", "female"].has(str(preset.get("sex", ""))):
		errors.append("Giới tính phải là male hoặc female.")
	if not ROLES.has(str(preset.get("role", ""))):
		errors.append("Vai trò không thuộc DiscipleCombatLoadoutV2.")

	var rig_id := str(preset.get("rig_id", ""))
	var rig := catalog.get_rig(rig_id) if catalog != null else {}
	if rig_id.is_empty() or rig.is_empty():
		errors.append("Rig không có trong DiscipleSourceAVisualPool hiện có.")
	else:
		if str(rig.get("sex", "")) != str(preset.get("sex", "")):
			errors.append("Giới tính preset không tương thích rig %s." % rig_id)
		var path := str(preset.get("asset_path", ""))
		if path != str(rig.get("scene_path", "")) or path.contains("..") or not path.begins_with("res://assets/actors/"):
			errors.append("asset_path không khớp rig hoặc nằm ngoài assets/actors.")
		var rig_validation := catalog.validate_rig(rig_id)
		for message in rig_validation.get("errors", []):
			errors.append("Rig/manifest: %s" % str(message))
	var scale_value := float(preset.get("display_scale", 0.0))
	if is_nan(scale_value) or is_inf(scale_value) or scale_value < 0.05 or scale_value > 2.0:
		errors.append("display_scale phải nằm trong 0.05–2.0.")
	var pivot: Variant = preset.get("pivot_offset", null)
	if not (pivot is Array) or pivot.size() != 2:
		errors.append("pivot_offset phải có hai tọa độ.")
	else:
		for value in pivot:
			if is_nan(float(value)) or is_inf(float(value)) or absf(float(value)) > 768.0:
				errors.append("pivot_offset nằm ngoài canvas asset 768×768.")
				break

	var attributes: Variant = preset.get("attributes", null)
	if not (attributes is Dictionary):
		errors.append("attributes phải là object sáu nền tảng.")
	else:
		for key in FOUNDATION_KEYS:
			if not attributes.has(key) or is_nan(float(attributes.get(key, -1.0))) or is_inf(float(attributes.get(key, -1.0))) or float(attributes.get(key, -1.0)) < 0.0:
				errors.append("Thiếu hoặc sai thuộc tính nền tảng %s." % key)
		if attributes.has("accuracy") or attributes.has("evasion"):
			errors.append("Không đưa Accuracy/Evasion vào runtime preset.")

	var progression: Variant = preset.get("progression", null)
	if not (progression is Dictionary):
		errors.append("progression phải có hai track V2.")
	else:
		for track in TRACKS:
			var row: Variant = progression.get(track, null)
			if not (row is Dictionary):
				errors.append("Thiếu track %s." % track)
				continue
			if not RealmProgress.valid_coordinates(int(row.get("realm", 0)), int(row.get("floor", 0))):
				errors.append("Tọa độ cảnh giới/tầng %s không hợp lệ." % track)

	var skill_stage := int(preset.get("skill_stage_index", -1))
	if skill_stage < 0:
		errors.append("skill_stage_index không hợp lệ.")
	var owned: Variant = preset.get("owned_skill_ids", null)
	var slots: Variant = preset.get("skill_slots", null)
	var owned_seen: Dictionary = {}
	if not (owned is Array):
		errors.append("owned_skill_ids phải là array.")
	else:
		for raw_skill_id in owned:
			var skill_id := str(raw_skill_id)
			if owned_seen.has(skill_id):
				errors.append("Kỹ năng sở hữu bị lặp: %s." % skill_id)
			owned_seen[skill_id] = true
			var definition: Dictionary = SkillSystem.SKILLS.get(skill_id, {})
			if definition.is_empty():
				errors.append("Kỹ năng không có trong CombatSkillSystem: %s." % skill_id)
			elif skill_stage >= 0 and skill_stage < int(definition.get("min_stage", 0)):
				errors.append("Kỹ năng %s chưa đủ điều kiện min_stage hiện hành." % skill_id)
	if not (slots is Array):
		errors.append("skill_slots phải là array.")
	else:
		var slot_seen: Dictionary = {}
		var slotted_skills: Dictionary = {}
		for item in slots:
			if not (item is Dictionary):
				errors.append("Mục skill slot phải là object.")
				continue
			var slot_number := int(item.get("slot", 0))
			var skill_id := str(item.get("skill_id", ""))
			if slot_number <= 0 or slot_seen.has(str(slot_number)):
				errors.append("Skill slot phải là số dương duy nhất.")
			slot_seen[str(slot_number)] = true
			if not owned_seen.has(skill_id):
				errors.append("Skill slot trỏ tới kỹ năng chưa sở hữu trong sandbox: %s." % skill_id)
			if slotted_skills.has(skill_id):
				errors.append("Không gán một kỹ năng vào nhiều slot: %s." % skill_id)
			slotted_skills[skill_id] = true

	var equipment: Variant = preset.get("equipment_set", null)
	if not (equipment is Array):
		errors.append("equipment_set phải là array tham chiếu recipe.")
	else:
		var gear_slots: Dictionary = {}
		for item in equipment:
			if not (item is Dictionary):
				errors.append("Mục equipment phải là object.")
				continue
			var slot := StringName(item.get("slot", ""))
			var recipe_id := StringName(item.get("recipe_id", ""))
			var recipe: Dictionary = GearSystem.RECIPES.get(str(recipe_id), {})
			if not GearSystem.VALID_SLOTS.has(slot) or gear_slots.has(str(slot)):
				errors.append("Equipment slot sai hoặc bị lặp: %s." % slot)
			gear_slots[str(slot)] = true
			if recipe.is_empty():
				errors.append("Recipe equipment không tồn tại: %s." % recipe_id)
			elif StringName(recipe.get("slot", "")) != slot:
				errors.append("Recipe %s không tương thích slot %s." % [recipe_id, slot])
	return errors

static func _validate_shape(preset: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for forbidden in ["profile_seed", "latent_identity_seed"]:
		if preset.has(forbidden):
			errors.append("Không lưu seed sinh đệ tử vào preset studio.")
	for stat in ["accuracy", "evasion"]:
		if preset.has(stat):
			errors.append("Accuracy/Evasion chỉ DESIGN-ONLY, không được ghi vào preset runtime.")
	for key in preset.keys():
		if not PRESET_KEYS.has(str(key)) and not ["profile_seed", "latent_identity_seed", "accuracy", "evasion"].has(str(key)):
			errors.append("Trường JSON không thuộc schema preset: %s." % str(key))
	for key in PRESET_KEYS:
		if not preset.has(key):
			errors.append("Thiếu trường bắt buộc: %s." % key)
	if not errors.is_empty():
		return errors
	if not _is_integer_number(preset["schema_version"]):
		errors.append("schema_version phải là integer.")
	for key in ["scope", "preset_id", "name", "sex", "role", "rig_id", "asset_path"]:
		if typeof(preset[key]) != TYPE_STRING:
			errors.append("%s phải là string." % key)
	if not _is_number(preset["display_scale"]):
		errors.append("display_scale phải là số.")
	if typeof(preset["pivot_offset"]) != TYPE_ARRAY or preset["pivot_offset"].size() != 2:
		errors.append("pivot_offset phải có hai tọa độ.")
	else:
		for value in preset["pivot_offset"]:
			if not _is_number(value):
				errors.append("pivot_offset chỉ nhận tọa độ số.")
				break
	if typeof(preset["attributes"]) != TYPE_DICTIONARY:
		errors.append("attributes phải là object sáu nền tảng.")
	else:
		for key in FOUNDATION_KEYS:
			if not preset["attributes"].has(key) or not _is_number(preset["attributes"].get(key)):
				errors.append("attributes.%s phải có giá trị số." % key)
		for key in preset["attributes"].keys():
			if not FOUNDATION_KEYS.has(str(key)):
				errors.append("Thuộc tính không thuộc schema: %s." % str(key))
	if typeof(preset["progression"]) != TYPE_DICTIONARY:
		errors.append("progression phải có hai track V2.")
	else:
		for track in TRACKS:
			var row: Variant = preset["progression"].get(track, null)
			if typeof(row) != TYPE_DICTIONARY:
				errors.append("progression.%s phải là object." % track)
				continue
			for coordinate in ["realm", "floor"]:
				if not _is_integer_number(row.get(coordinate, null)):
					errors.append("progression.%s.%s phải là integer." % [track, coordinate])
		for track in preset["progression"].keys():
			if not TRACKS.has(str(track)):
				errors.append("Track progression không thuộc schema: %s." % str(track))
	if not _is_integer_number(preset["skill_stage_index"]):
		errors.append("skill_stage_index phải là integer.")
	if typeof(preset["owned_skill_ids"]) != TYPE_ARRAY:
		errors.append("owned_skill_ids phải là array.")
	else:
		for skill_id in preset["owned_skill_ids"]:
			if typeof(skill_id) != TYPE_STRING:
				errors.append("owned_skill_ids chỉ nhận string ID.")
	if typeof(preset["skill_slots"]) != TYPE_ARRAY:
		errors.append("skill_slots phải là array.")
	else:
		for item in preset["skill_slots"]:
			if typeof(item) != TYPE_DICTIONARY or not _is_integer_number(item.get("slot", null)) or typeof(item.get("skill_id", null)) != TYPE_STRING:
				errors.append("Mỗi skill slot cần slot integer và skill_id string.")
	if typeof(preset["equipment_set"]) != TYPE_ARRAY:
		errors.append("equipment_set phải là array.")
	else:
		for item in preset["equipment_set"]:
			if typeof(item) != TYPE_DICTIONARY or typeof(item.get("slot", null)) != TYPE_STRING or typeof(item.get("recipe_id", null)) != TYPE_STRING:
				errors.append("Mỗi equipment reference cần slot và recipe_id dạng string.")
	return errors

static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

static func _is_integer_number(value: Variant) -> bool:
	return _is_number(value) and float(value) == float(int(value))
