extends RefCounted
class_name JXVfxCatalog

var root_path := ""
var records: Dictionary = {}
var all_records: Array = []

func load_index(index_path: String) -> Error:
	var file := FileAccess.open(index_path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary) or not (parsed.get("records", []) is Array):
		return ERR_PARSE_ERROR
	root_path = index_path.get_base_dir().get_base_dir()
	all_records = parsed.get("records", [])
	records.clear()
	for record in all_records:
		if record is Dictionary and record.has("record_id"):
			records[String(record["record_id"])] = record
	return OK

func get_record(effect_id: String) -> Dictionary:
	return records.get(effect_id, {})

func get_texture_path(effect_id: String) -> String:
	var record := get_record(effect_id)
	if record.is_empty():
		return ""
	return root_path.path_join(String(record.get("texture_path", "")))

