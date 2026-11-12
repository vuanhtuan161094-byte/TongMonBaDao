class_name V63SkillPresentationCatalogV1
extends RefCounted

# Additive player-facing metadata only. Combat JSON remains the numeric authority.
const MANIFEST_PATH := "res://data/presentation/v63_skill_presentation_manifest_v1.json"
const REGISTRY_PATH := "res://data/combat/v63_content_registry.json"
const DUAL_BLADE_CATALOG_PATH := "res://data/combat/v63_dual_blade_combat_catalog.json"
const DUAL_BLADE_REGISTRY_EXTENSION_PATH := "res://data/combat/v63_dual_blade_registry_extension.json"
const DUAL_BLADE_PRESENTATION_EXTENSION_PATH := "res://data/presentation/v63_dual_blade_presentation_manifest_v1.json"
const PALM_CATALOG_PATH := "res://data/combat/v63_palm_combat_catalog.json"
const PALM_REGISTRY_EXTENSION_PATH := "res://data/combat/v63_palm_registry_extension.json"
const PALM_PRESENTATION_EXTENSION_PATH := "res://data/presentation/v63_palm_presentation_manifest_v1.json"
const CATALOGUE_PATHS := {
	"human":"res://data/combat/v63_human_combat_catalog.json",
	"immortal":"res://data/combat/v63_immortal_combat_catalog.json",
	"divine":"res://data/combat/v63_divine_combat_catalog.json",
	"sword":"res://data/combat/v63_sword_combat_catalog.json",
	"blade":"res://data/combat/v63_blade_combat_catalog.json",
	"spear":"res://data/combat/v63_spear_combat_catalog.json"
}
const EXPECTED_S0_IDS := [
	"tmb.skill.bow.basic.human",
	"tmb.skill.bow.liep_anh.active_01.human",
	"tmb.skill.poison.co_doc.active_02.human",
	"tmb.skill.poison.doc_cham.active_01.human"
]
const ALL36_SCHOOLS := ["bow","fist","poison","sword","blade","dual_blade","spear","palm","formation","summon","curse","talisman"]
const VALID_SLOTS := ["basic","mobility","active","ultimate","passive","innate","active_01","active_02","active_03","active_04","passive_01","passive_02","passive_03","passive_04","passive_05"]
const VALID_TIERS := ["human","immortal","divine"]
const VALID_LINEAGES := ["base","a","b","rare_a","rare_b"]
const VALID_VARIANTS := ["BASE","SUCCESSOR","RARE"]

static func load_authoring_sources() -> Dictionary:
	var errors: Array[String] = []
	var catalogues: Dictionary = {}
	for key in CATALOGUE_PATHS.keys():
		var loaded := _read_json(str(CATALOGUE_PATHS[key]))
		if not bool(loaded.get("ok",false)):
			errors.append_array(loaded.get("errors",[]))
			continue
		var data: Dictionary = loaded["data"]
		if not (data.get("skills",null) is Array):
			errors.append("catalogue_skills_missing:"+str(key))
			continue
		catalogues[str(key)] = data
	var registry_result := _read_json(REGISTRY_PATH)
	var manifest_result := _read_json(MANIFEST_PATH)
	if not bool(registry_result.get("ok",false)):
		errors.append_array(registry_result.get("errors",[]))
	if not bool(manifest_result.get("ok",false)):
		errors.append_array(manifest_result.get("errors",[]))
	var registry: Dictionary = registry_result.get("data",{}).duplicate(true)
	var manifest: Dictionary = manifest_result.get("data",{}).duplicate(true)
	var dual_catalogue_result := _read_json(DUAL_BLADE_CATALOG_PATH)
	var dual_registry_result := _read_json(DUAL_BLADE_REGISTRY_EXTENSION_PATH)
	var dual_manifest_result := _read_json(DUAL_BLADE_PRESENTATION_EXTENSION_PATH)
	for result in [dual_catalogue_result, dual_registry_result, dual_manifest_result]:
		if not bool(result.get("ok", false)):
			errors.append_array(result.get("errors", []))
	if bool(dual_catalogue_result.get("ok", false)) and bool(dual_registry_result.get("ok", false)) and bool(dual_manifest_result.get("ok", false)):
		var dual_catalogue: Dictionary = dual_catalogue_result.get("data", {})
		var dual_registry_extension: Dictionary = dual_registry_result.get("data", {})
		var dual_manifest_extension: Dictionary = dual_manifest_result.get("data", {})
		var extension_errors := _validate_dual_blade_extensions(dual_catalogue, dual_registry_extension, dual_manifest_extension)
		errors.append_array(extension_errors)
		if extension_errors.is_empty():
			catalogues["dual_blade"] = dual_catalogue
			var school_rows: Array = registry.get("schools", [])
			var path_rows: Array = registry.get("paths", [])
			var family_rows: Array = registry.get("families", [])
			school_rows.append(dual_registry_extension.get("school", {}).duplicate(true))
			path_rows.append_array(dual_registry_extension.get("paths", []).duplicate(true))
			family_rows.append_array(dual_registry_extension.get("families", []).duplicate(true))
			registry["schools"] = school_rows
			registry["paths"] = path_rows
			registry["families"] = family_rows
			registry["school_count"] = school_rows.size()
			registry["branch_count"] = path_rows.size()
			registry["skill_family_count"] = family_rows.size()
			registry["skills_s4_candidate_count"] = 183
			registry["skills_s4_candidate_source_status"] = "AUTHENTIC_DUAL_BLADE_CODEX_SOURCE_PENDING"
			registry["total_runtime_candidate_nodes"] = int(registry.get("total_runtime_candidate_nodes", 0)) + 183
			registry["total_authored_runtime_nodes"] = int(registry.get("total_authored_runtime_nodes", 0)) + 183
			var entries: Dictionary = manifest.get("entries", {}).duplicate(true)
			var dual_entries: Dictionary = dual_manifest_extension.get("entries", {})
			for id in dual_entries.keys():
				if entries.has(id):
					errors.append("dual_blade_presentation_id_collision:" + str(id))
				else:
					entries[id] = dual_entries[id].duplicate(true)
			manifest["entries"] = entries
	var palm_catalogue_result := _read_json(PALM_CATALOG_PATH)
	var palm_registry_result := _read_json(PALM_REGISTRY_EXTENSION_PATH)
	var palm_manifest_result := _read_json(PALM_PRESENTATION_EXTENSION_PATH)
	for result in [palm_catalogue_result, palm_registry_result, palm_manifest_result]:
		if not bool(result.get("ok", false)):
			errors.append_array(result.get("errors", []))
	if bool(palm_catalogue_result.get("ok", false)) and bool(palm_registry_result.get("ok", false)) and bool(palm_manifest_result.get("ok", false)):
		var palm_catalogue: Dictionary = palm_catalogue_result.get("data", {})
		var palm_registry_extension: Dictionary = palm_registry_result.get("data", {})
		var palm_manifest_extension: Dictionary = palm_manifest_result.get("data", {})
		var palm_errors := _validate_palm_extensions(palm_catalogue, palm_registry_extension, palm_manifest_extension)
		errors.append_array(palm_errors)
		if palm_errors.is_empty():
			catalogues["palm"] = palm_catalogue
			var school_rows: Array = registry.get("schools", [])
			var path_rows: Array = registry.get("paths", [])
			var family_rows: Array = registry.get("families", [])
			school_rows.append(palm_registry_extension.get("school", {}).duplicate(true))
			path_rows.append_array(palm_registry_extension.get("paths", []).duplicate(true))
			family_rows.append_array(palm_registry_extension.get("families", []).duplicate(true))
			registry["schools"] = school_rows
			registry["paths"] = path_rows
			registry["families"] = family_rows
			registry["school_count"] = school_rows.size()
			registry["branch_count"] = path_rows.size()
			registry["skill_family_count"] = family_rows.size()
			registry["skills_s5_candidate_count"] = 183
			registry["skills_s5_candidate_source_status"] = "AUTHENTIC_PALM_CODEX_SOURCE_PENDING"
			registry["total_runtime_candidate_nodes"] = int(registry.get("total_runtime_candidate_nodes", 0)) + 183
			registry["total_authored_runtime_nodes"] = int(registry.get("total_authored_runtime_nodes", 0)) + 183
			var entries: Dictionary = manifest.get("entries", {}).duplicate(true)
			var palm_entries: Dictionary = palm_manifest_extension.get("entries", {})
			for id in palm_entries.keys():
				if entries.has(id):
					errors.append("palm_presentation_id_collision:" + str(id))
				else:
					entries[id] = palm_entries[id].duplicate(true)
			manifest["entries"] = entries
	return {
		"ok":errors.is_empty(),
		"errors":errors,
		"catalogues":catalogues,
		"registry":registry,
		"manifest":manifest
	}

static func _validate_palm_extensions(catalogue: Dictionary, registry_extension: Dictionary, presentation_extension: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	errors.append_array(V63PalmSkillCombatSystem.validate_catalogue(catalogue))
	if int(registry_extension.get("schema_version", -1)) != 1 or str(registry_extension.get("release_gate", "")) != "OFF":
		errors.append("palm_registry_extension_must_remain_off")
	if int(presentation_extension.get("schema_version", -1)) != 1 or str(presentation_extension.get("release_gate", "")) != "OFF":
		errors.append("palm_presentation_extension_must_remain_off")
	var base: Dictionary = registry_extension.get("base_registry", {})
	var presentation_base: Dictionary = presentation_extension.get("base_registry", {})
	if str(base.get("path", "")) != REGISTRY_PATH or str(presentation_base.get("path", "")) != REGISTRY_PATH:
		errors.append("palm_base_registry_path_mismatch")
	var actual_base_hash := git_blob_sha1(REGISTRY_PATH)
	if actual_base_hash.is_empty() or str(base.get("git_blob_sha", "")) != actual_base_hash or str(presentation_base.get("git_blob_sha", "")) != actual_base_hash:
		errors.append("palm_base_registry_pin_mismatch")
	var source: Dictionary = registry_extension.get("source_catalog", {})
	var presentation_source: Dictionary = presentation_extension.get("source_catalog", {})
	if str(source.get("path", "")) != PALM_CATALOG_PATH or str(presentation_source.get("path", "")) != PALM_CATALOG_PATH:
		errors.append("palm_catalogue_pin_path_mismatch")
	var actual_catalogue_hash := git_blob_sha1(PALM_CATALOG_PATH)
	if actual_catalogue_hash.is_empty() or str(source.get("git_blob_sha", "")) != actual_catalogue_hash or str(presentation_source.get("git_blob_sha", "")) != actual_catalogue_hash:
		errors.append("palm_catalogue_pin_mismatch")
	var extension_source: Dictionary = presentation_extension.get("registry_extension", {})
	var actual_extension_hash := git_blob_sha1(PALM_REGISTRY_EXTENSION_PATH)
	if str(extension_source.get("path", "")) != PALM_REGISTRY_EXTENSION_PATH or str(extension_source.get("git_blob_sha", "")) != actual_extension_hash:
		errors.append("palm_registry_extension_pin_mismatch")
	if str(registry_extension.get("extension_id", "")) != "tmb.v63.registry_extension.s5_palm" or str(presentation_extension.get("extension_id", "")) != "tmb.v63.presentation_extension.s5_palm":
		errors.append("palm_extension_identity_invalid")
	var paths: Variant = registry_extension.get("paths", null)
	var families: Variant = registry_extension.get("families", null)
	var skills: Array = catalogue.get("skills", [])
	var entries: Variant = presentation_extension.get("entries", null)
	if not (paths is Array) or paths.size() != 3 or not (families is Array) or families.size() != 35 or not (entries is Dictionary) or entries.size() != 183:
		errors.append("palm_extension_counts_invalid")
		return errors
	var registry_nodes: Dictionary = {}
	var family_ids: Dictionary = {}
	for family in families:
		var family_id := str(family.get("id", ""))
		family_ids[family_id] = true
		for node in family.get("nodes", []):
			var node_id := str(node.get("id", ""))
			if registry_nodes.has(node_id):
				errors.append("palm_registry_node_duplicate:" + node_id)
			registry_nodes[node_id] = node
	var skill_ids: Dictionary = {}
	for skill in skills:
		var id := str(skill.get("id", ""))
		var entry: Variant = entries.get(id, null)
		if skill_ids.has(id) or not (entry is Dictionary):
			errors.append("palm_presentation_join_missing:" + id)
			continue
		skill_ids[id] = true
		var identity: Dictionary = entry.get("identity", {})
		var branch := str(skill.get("branch", ""))
		var branch_lore := "tmb.lore.branch.palm." + (branch if not branch.is_empty() else "common")
		if not registry_nodes.has(id) or not family_ids.has(str(skill.get("family_id", ""))):
			errors.append("palm_registry_join_missing:" + id)
		if str(identity.get("skill_id", "")) != id or str(identity.get("family_id", "")) != str(skill.get("family_id", "")) or str(identity.get("school", "")) != "palm" or str(identity.get("branch", "")) != branch:
			errors.append("palm_identity_join_mismatch:" + id)
		if str(entry.get("school_lore_id", "")) != "tmb.lore.school.palm" or str(entry.get("branch_lore_id", "")) != branch_lore:
			errors.append("palm_lore_link_invalid:" + id)
		var flavor := str(entry.get("flavor_vi", ""))
		if flavor.length() < 50 or flavor.length() > 110 or str(entry.get("display_name_vi", "")) != str(skill.get("name", "")):
			errors.append("palm_flavor_or_name_invalid:" + id)
		var availability: Dictionary = entry.get("availability", {})
		if str(availability.get("status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(availability.get("archivable", true)) or not str(availability.get("source_codex_id", "")).is_empty():
			errors.append("palm_learning_must_remain_blocked:" + id)
		var vfx: Dictionary = entry.get("vfx", {}).get("production_brief", {})
		if vfx.get("phases", []).size() != 7 or str(vfx.get("asset_status", "")) != "NOT_PRESENT" or str(vfx.get("render_capture_status", "")) != "NOT_CAPTURED":
			errors.append("palm_vfx_provenance_invalid:" + id)
	if skill_ids.size() != 183 or registry_nodes.size() != 183:
		errors.append("palm_join_total_invalid")
	return errors

static func _validate_dual_blade_extensions(catalogue: Dictionary, registry_extension: Dictionary, presentation_extension: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	errors.append_array(V63DualBladeSkillCombatSystem.validate_catalogue(catalogue))
	if int(registry_extension.get("schema_version", -1)) != 1 or str(registry_extension.get("release_gate", "")) != "OFF":
		errors.append("dual_blade_registry_extension_must_remain_off")
	if int(presentation_extension.get("schema_version", -1)) != 1 or str(presentation_extension.get("release_gate", "")) != "OFF":
		errors.append("dual_blade_presentation_extension_must_remain_off")
	var registry_source: Dictionary = registry_extension.get("base_registry", {})
	var presentation_base: Dictionary = presentation_extension.get("base_registry", {})
	if str(registry_source.get("path", "")) != REGISTRY_PATH or str(presentation_base.get("path", "")) != REGISTRY_PATH:
		errors.append("dual_blade_base_registry_path_mismatch")
	var actual_base_hash := git_blob_sha1(REGISTRY_PATH)
	if actual_base_hash.is_empty() or str(registry_source.get("git_blob_sha", "")) != actual_base_hash or str(presentation_base.get("git_blob_sha", "")) != actual_base_hash:
		errors.append("dual_blade_base_registry_pin_mismatch")
	var catalogue_source: Dictionary = registry_extension.get("source_catalog", {})
	var presentation_catalogue_source: Dictionary = presentation_extension.get("source_catalog", {})
	if str(catalogue_source.get("path", "")) != DUAL_BLADE_CATALOG_PATH or str(presentation_catalogue_source.get("path", "")) != DUAL_BLADE_CATALOG_PATH:
		errors.append("dual_blade_catalogue_pin_path_mismatch")
	var actual_catalogue_hash := git_blob_sha1(DUAL_BLADE_CATALOG_PATH)
	if actual_catalogue_hash.is_empty() or str(catalogue_source.get("git_blob_sha", "")) != actual_catalogue_hash or str(presentation_catalogue_source.get("git_blob_sha", "")) != actual_catalogue_hash:
		errors.append("dual_blade_catalogue_pin_mismatch:expected=" + str(catalogue_source.get("git_blob_sha", "")) + ":presentation=" + str(presentation_catalogue_source.get("git_blob_sha", "")) + ":actual=" + actual_catalogue_hash)
	var extension_source: Dictionary = presentation_extension.get("registry_extension", {})
	var actual_extension_hash := git_blob_sha1(DUAL_BLADE_REGISTRY_EXTENSION_PATH)
	if str(extension_source.get("path", "")) != DUAL_BLADE_REGISTRY_EXTENSION_PATH or str(extension_source.get("git_blob_sha", "")) != actual_extension_hash:
		errors.append("dual_blade_registry_extension_pin_mismatch:expected=" + str(extension_source.get("git_blob_sha", "")) + ":actual=" + actual_extension_hash)
	if str(registry_extension.get("extension_id", "")) != "tmb.v63.registry_extension.s4_dual_blade" or str(presentation_extension.get("extension_id", "")) != "tmb.v63.presentation_extension.s4_dual_blade":
		errors.append("dual_blade_extension_identity_invalid")
	var paths: Variant = registry_extension.get("paths", null)
	var families: Variant = registry_extension.get("families", null)
	var skills: Array = catalogue.get("skills", [])
	var entries: Variant = presentation_extension.get("entries", null)
	if not (paths is Array) or paths.size() != 3 or not (families is Array) or families.size() != 35 or not (entries is Dictionary) or entries.size() != 183:
		errors.append("dual_blade_extension_counts_invalid")
		return errors
	var registry_nodes: Dictionary = {}
	var family_ids: Dictionary = {}
	for family in families:
		var family_id := str(family.get("id", ""))
		family_ids[family_id] = true
		for node in family.get("nodes", []):
			var node_id := str(node.get("id", ""))
			if registry_nodes.has(node_id):
				errors.append("dual_blade_registry_node_duplicate:" + node_id)
			registry_nodes[node_id] = node
	var skill_ids: Dictionary = {}
	for skill in skills:
		var id := str(skill.get("id", ""))
		var entry: Variant = entries.get(id, null)
		if skill_ids.has(id) or not (entry is Dictionary):
			errors.append("dual_blade_presentation_join_missing:" + id)
			continue
		skill_ids[id] = true
		var identity: Dictionary = entry.get("identity", {})
		if not registry_nodes.has(id) or not family_ids.has(str(skill.get("family_id", ""))):
			errors.append("dual_blade_registry_join_missing:" + id)
		if str(identity.get("skill_id", "")) != id or str(identity.get("family_id", "")) != str(skill.get("family_id", "")) or str(identity.get("school", "")) != "dual_blade":
			errors.append("dual_blade_identity_join_mismatch:" + id)
		if str(entry.get("school_lore_id", "")) != "tmb.lore.school.dual_blade" or str(entry.get("branch_lore_id", "")) != "tmb.lore.branch.dual_blade." + (str(skill.get("branch", "")) if not str(skill.get("branch", "")).is_empty() else "common"):
			errors.append("dual_blade_lore_link_invalid:" + id)
		var flavor := str(entry.get("flavor_vi", ""))
		if flavor.length() < 50 or flavor.length() > 110 or str(entry.get("display_name_vi", "")) != str(skill.get("name", "")):
			errors.append("dual_blade_flavor_or_name_invalid:" + id)
		for field in ["short_description_vi", "long_description_vi", "counterplay_vi"]:
			if str(entry.get(field, "")).strip_edges().is_empty():
				errors.append("dual_blade_player_text_missing:" + id + ":" + field)
		var vfx: Dictionary = entry.get("vfx", {}).get("production_brief", {})
		if vfx.get("phases", []).size() != 7 or str(vfx.get("asset_status", "")) != "NOT_PRESENT" or str(vfx.get("render_capture_status", "")) != "NOT_CAPTURED":
			errors.append("dual_blade_vfx_provenance_invalid:" + id)
		var availability: Dictionary = entry.get("availability", {})
		if str(availability.get("status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(availability.get("archivable", true)):
			errors.append("dual_blade_learning_must_remain_blocked:" + id)
	if skill_ids.size() != 183 or registry_nodes.size() != 183:
		errors.append("dual_blade_join_total_invalid")
	return errors

static func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null:
		return {"ok":false,"errors":["cannot_open:"+path],"data":{}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok":false,"errors":["json_not_object:"+path],"data":{}}
	return {"ok":true,"errors":[],"data":parsed}

static func git_blob_sha1(path: String) -> String:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null:
		return ""
	var bytes := file.get_buffer(file.get_length())
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA1) != OK:
		return ""
	var prefix := ("blob " + str(bytes.size())).to_utf8_buffer()
	prefix.append(0)
	context.update(prefix)
	context.update(bytes)
	return context.finish().hex_encode()

static func validate_sample_entries(manifest: Dictionary, catalogues: Dictionary, registry: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if int(manifest.get("schema_version",-1)) != 1:
		errors.append("presentation_manifest_schema_not_v1")
	if str(manifest.get("release_gate","")) != "OFF":
		errors.append("v63_release_gate_must_remain_off")
	if str(manifest.get("completion_status","")) not in ["S0_SAMPLE_ONLY","S1_SWORD_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED","S2_BLADE_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED","S3_SPEAR_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED"]:
		errors.append("unknown_presentation_manifest_status")
	var target_coverage: Variant = manifest.get("target_coverage",{})
	if str(manifest.get("completion_status","")) == "S1_SWORD_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED":
		if not (target_coverage is Dictionary) or int(target_coverage.get("existing_runtime_nodes",0)) != 549 or int(target_coverage.get("candidate_gated_runtime_nodes",0)) != 183 or int(target_coverage.get("not_authored_slots",0)) != 1464 or int(target_coverage.get("authored_presentation_entries",0)) != 187:
			errors.append("s1_manifest_coverage_counts_mismatch")
	elif str(manifest.get("completion_status","")) == "S2_BLADE_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED":
		if not (target_coverage is Dictionary) or int(target_coverage.get("existing_runtime_nodes",0)) != 549 or int(target_coverage.get("candidate_gated_runtime_nodes",0)) != 366 or int(target_coverage.get("not_authored_slots",0)) != 1281 or int(target_coverage.get("authored_presentation_entries",0)) != 370:
			errors.append("s2_manifest_coverage_counts_mismatch")
	elif str(manifest.get("completion_status","")) == "S3_SPEAR_CANDIDATE_AUTHORED_S0_SAMPLES_RETAINED":
		if not (target_coverage is Dictionary) or int(target_coverage.get("existing_runtime_nodes",0)) != 549 or int(target_coverage.get("candidate_gated_runtime_nodes",0)) != 549 or int(target_coverage.get("not_authored_slots",0)) != 1098 or int(target_coverage.get("authored_presentation_entries",0)) != 553:
			errors.append("s3_manifest_coverage_counts_mismatch")
	var sources: Variant = manifest.get("source_catalogs",{})
	if not (sources is Dictionary):
		errors.append("source_catalogs_not_object")
	else:
		for key in CATALOGUE_PATHS.keys():
			var source: Variant = sources.get(str(key),{})
			if not (source is Dictionary):
				errors.append("source_catalog_missing:"+str(key))
				continue
			if str(source.get("path","")) != str(CATALOGUE_PATHS[key]):
				errors.append("source_catalog_path_mismatch:"+str(key))
			var expected_hash := str(source.get("git_blob_sha",""))
			var actual_hash := git_blob_sha1(str(CATALOGUE_PATHS[key]))
			if expected_hash.is_empty() or actual_hash != expected_hash:
				errors.append("source_catalog_git_blob_hash_mismatch:"+str(key))
	var registry_source: Variant = manifest.get("source_registry",{})
	if not (registry_source is Dictionary):
		errors.append("source_registry_not_object")
	else:
		if str(registry_source.get("path","")) != REGISTRY_PATH:
			errors.append("source_registry_path_mismatch")
		if git_blob_sha1(REGISTRY_PATH) != str(registry_source.get("git_blob_sha","")):
			errors.append("source_registry_git_blob_hash_mismatch")
	var entries: Variant = manifest.get("entries",{})
	if not (entries is Dictionary):
		errors.append("presentation_entries_not_object")
		return errors
	for skill_id in EXPECTED_S0_IDS:
		if not entries.has(skill_id):
			errors.append("s0_sample_missing:"+skill_id)
	if entries.size() < EXPECTED_S0_IDS.size():
		errors.append("s0_sample_entry_count_below_four")
	for raw_id in entries.keys():
		var id := str(raw_id)
		var presentation: Variant = entries[raw_id]
		if not (presentation is Dictionary):
			errors.append("presentation_entry_not_object:"+id)
			continue
		_validate_presentation_entry(id,presentation,catalogues,registry,errors)
	return errors

static func presentation_for(skill_id: String, manifest: Dictionary, catalogues: Dictionary, actor_stats: Dictionary = {}, target_distance: float = -1.0) -> Dictionary:
	var entries: Variant = manifest.get("entries",{})
	if not (entries is Dictionary) or not entries.has(skill_id):
		return {"ok":false,"errors":["presentation_not_authored:"+skill_id]}
	var runtime := _find_runtime_skill(catalogues,skill_id)
	if runtime.is_empty():
		return {"ok":false,"errors":["runtime_skill_not_found:"+skill_id]}
	var presentation: Dictionary = entries[skill_id]
	var tooltip := build_mechanics_tooltip(runtime,actor_stats,target_distance)
	if not bool(tooltip.get("ok",false)):
		return {"ok":false,"errors":tooltip.get("errors",[])}
	return {"ok":true,"errors":[],"presentation":presentation.duplicate(true),"runtime_definition":runtime.duplicate(true),"mechanics_tooltip":str(tooltip.get("text",""))}

static func runtime_skill_definition(catalogues: Dictionary, skill_id: String) -> Dictionary:
	return _find_runtime_skill(catalogues,skill_id)

static func _validate_presentation_entry(skill_id: String, entry: Dictionary, catalogues: Dictionary, registry: Dictionary, errors: Array[String]) -> void:
	var catalogue_key := str(entry.get("catalogue_key",""))
	var catalogue: Variant = catalogues.get(catalogue_key,{})
	if not (catalogue is Dictionary):
		errors.append("presentation_catalogue_missing:"+skill_id)
		return
	var skill := _find_skill_in_catalogue(catalogue,skill_id)
	if skill.is_empty():
		errors.append("presentation_source_skill_missing:"+skill_id)
		return
	var identity: Variant = entry.get("identity",{})
	if not (identity is Dictionary):
		errors.append("presentation_identity_missing:"+skill_id)
		return
	var registry_node := _find_registry_node(registry,skill_id)
	if registry_node.is_empty():
		errors.append("presentation_registry_node_missing:"+skill_id)
	var identity_pairs := {
		"skill_id":skill_id,
		"family_id":str(skill.get("family_id","")),
		"school":str(skill.get("school","")),
		"branch":str(skill.get("branch","")),
		"slot":str(skill.get("slot","")),
		"tier":str(skill.get("tier","")),
		"source_codex_id":str(skill.get("source_codex_id",""))
	}
	for field in identity_pairs.keys():
		if str(identity.get(str(field),"")) != str(identity_pairs[field]):
			errors.append("presentation_identity_source_mismatch:"+skill_id+":"+str(field))
	if not registry_node.is_empty():
		if str(identity.get("lineage","")) != str(registry_node.get("lineage","")):
			errors.append("presentation_lineage_source_mismatch:"+skill_id)
		if str(identity.get("parent_skill_id","")) != str(registry_node.get("parent","")):
			errors.append("presentation_parent_source_mismatch:"+skill_id)
	if str(identity.get("lineage","")) == "base" and str(identity.get("variant","")) != "BASE":
		errors.append("presentation_base_variant_mismatch:"+skill_id)
	var evolution_delta: Variant = entry.get("evolution_delta",{})
	if not (evolution_delta is Dictionary) or str(identity.get("replaces_skill_id","")) != str(evolution_delta.get("replaces_skill_id","")):
		errors.append("presentation_replaces_source_mismatch:"+skill_id)
	if str(entry.get("display_name_vi","")) != str(skill.get("name","")):
		errors.append("presentation_name_must_match_runtime_name:"+skill_id)
	if str(skill.get("school","")) == "sword":
		var expected_branch_lore := "tmb.lore.branch.sword.common" if str(skill.get("branch","")).is_empty() else "tmb.lore.branch.sword."+str(skill.get("branch",""))
		if str(entry.get("school_lore_id","")) != "tmb.lore.school.sword" or str(entry.get("branch_lore_id","")) != expected_branch_lore:
			errors.append("sword_lore_link_missing_or_mismatched:"+skill_id)
		if str(entry.get("flavor_vi","")).strip_edges().is_empty():
			errors.append("sword_flavor_missing:"+skill_id)
		if str(entry.get("availability",{}).get("status","")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(entry.get("availability",{}).get("archivable",true)):
			errors.append("sword_source_must_remain_gated:"+skill_id)
	if str(skill.get("school","")) == "blade":
		var expected_blade_lore := "tmb.lore.branch.blade.common" if str(skill.get("branch","")).is_empty() else "tmb.lore.branch.blade."+str(skill.get("branch",""))
		if str(entry.get("school_lore_id","")) != "tmb.lore.school.blade" or str(entry.get("branch_lore_id","")) != expected_blade_lore:
			errors.append("blade_lore_link_missing_or_mismatched:"+skill_id)
		if str(entry.get("flavor_vi","")).strip_edges().is_empty():
			errors.append("blade_flavor_missing:"+skill_id)
		if str(entry.get("availability",{}).get("status","")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(entry.get("availability",{}).get("archivable",true)):
			errors.append("blade_source_must_remain_gated:"+skill_id)
	if str(skill.get("school","")) == "spear":
		var expected_spear_lore := "tmb.lore.branch.spear.common" if str(skill.get("branch","")).is_empty() else "tmb.lore.branch.spear."+str(skill.get("branch",""))
		if str(entry.get("school_lore_id","")) != "tmb.lore.school.spear" or str(entry.get("branch_lore_id","")) != expected_spear_lore:
			errors.append("spear_lore_link_missing_or_mismatched:"+skill_id)
		if str(entry.get("flavor_vi","" )).strip_edges().is_empty():
			errors.append("spear_flavor_missing:"+skill_id)
		if str(entry.get("availability",{}).get("status","")) != "CANDIDATE_SOURCE_PENDING_NO_PLAYER_LEARNING" or bool(entry.get("availability",{}).get("archivable",true)):
			errors.append("spear_source_must_remain_gated:"+skill_id)
	if str(skill.get("school", "")) == "dual_blade":
		var expected_dual_lore := "tmb.lore.branch.dual_blade.common" if str(skill.get("branch", "")).is_empty() else "tmb.lore.branch.dual_blade." + str(skill.get("branch", ""))
		if str(entry.get("school_lore_id", "")) != "tmb.lore.school.dual_blade" or str(entry.get("branch_lore_id", "")) != expected_dual_lore:
			errors.append("dual_blade_lore_link_missing_or_mismatched:" + skill_id)
		if str(entry.get("flavor_vi", "")).length() < 50 or str(entry.get("flavor_vi", "")).length() > 110:
			errors.append("dual_blade_flavor_length_invalid:" + skill_id)
		if str(entry.get("availability", {}).get("status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(entry.get("availability", {}).get("archivable", true)):
			errors.append("dual_blade_source_must_remain_gated:" + skill_id)
	if str(skill.get("school", "")) == "palm":
		var expected_palm_lore := "tmb.lore.branch.palm.common" if str(skill.get("branch", "")).is_empty() else "tmb.lore.branch.palm." + str(skill.get("branch", ""))
		if str(entry.get("school_lore_id", "")) != "tmb.lore.school.palm" or str(entry.get("branch_lore_id", "")) != expected_palm_lore:
			errors.append("palm_lore_link_missing_or_mismatched:" + skill_id)
		if str(entry.get("flavor_vi", "")).length() < 50 or str(entry.get("flavor_vi", "")).length() > 110:
			errors.append("palm_flavor_length_invalid:" + skill_id)
		if str(entry.get("availability", {}).get("status", "")) != "CANDIDATE_GATED_SOURCE_PENDING" or bool(entry.get("availability", {}).get("archivable", true)):
			errors.append("palm_source_must_remain_gated:" + skill_id)
	for field in ["short_description_vi","long_description_vi","counterplay_vi"]:
		var prose := str(entry.get(field,""))
		if prose.strip_edges().is_empty():
			errors.append("presentation_text_missing:"+skill_id+":"+field)
		if _contains_ascii_digit(prose):
			errors.append("presentation_prose_has_undriven_numeric_claim:"+skill_id+":"+field)
	if str(entry.get("short_description_vi","")).length() > 110:
		errors.append("presentation_short_text_exceeds_compact_line:"+skill_id)
	var qa_status: Variant = entry.get("qa_status",{})
	if not (qa_status is Dictionary) or str(qa_status.get("authoring","")) != "AUTHORING_COMPLETE" or str(qa_status.get("vfx_metadata","")) != "VFX_META_COMPLETE":
		errors.append("presentation_authoring_status_incomplete:"+skill_id)
	if str(qa_status.get("runtime","")) != "RUNTIME_CATALOG_PRESENT" or str(qa_status.get("behavior","")) != "NOT_AUDITED_PER_SKILL":
		errors.append("presentation_runtime_or_behavior_status_misleading:"+skill_id)
	if str(qa_status.get("asset","")) != "NOT_PRESENT" or str(qa_status.get("render","")) != "NOT_CAPTURED" or str(qa_status.get("gui","")) != "PENDING":
		errors.append("presentation_visual_status_misleading:"+skill_id)
	var roles: Variant = entry.get("role_tags",[])
	if not (roles is Array) or roles.is_empty():
		errors.append("presentation_roles_missing:"+skill_id)
	var element_rule: Variant = entry.get("element_rule",{})
	if not (element_rule is Dictionary):
		errors.append("presentation_element_rule_missing:"+skill_id)
	else:
		if str(element_rule.get("element_source","")) != "runtime.element" or str(element_rule.get("element_value","")) != str(skill.get("element","")):
			errors.append("presentation_element_not_runtime_sourced:"+skill_id)
		if str(element_rule.get("differential_bonus","")) != "NO_PRESENTATION_BONUS":
			errors.append("presentation_must_not_add_root_bonus:"+skill_id)
	var ai: Variant = entry.get("ai_policy",{})
	if not (ai is Dictionary) or str(ai.get("status","")) != "INHERITED_RUNTIME_POLICY_NOT_PER_SKILL_TUNED":
		errors.append("presentation_ai_policy_not_truthful:"+skill_id)
	var availability: Variant = entry.get("availability",{})
	if not (availability is Dictionary) or str(availability.get("source_codex_id","")) != str(skill.get("source_codex_id","")):
		errors.append("presentation_availability_source_mismatch:"+skill_id)
	var template: Variant = entry.get("mechanics_tooltip_template",{})
	if not (template is Dictionary) or str(template.get("mode","")) != "GENERATED_FROM_RUNTIME_CATALOG":
		errors.append("mechanics_tooltip_must_be_runtime_generated:"+skill_id)
	elif template.get("fields",null) is Array:
		for field in template["fields"]:
			if not skill.has(str(field)):
				errors.append("tooltip_field_absent_from_runtime:"+skill_id+":"+str(field))
	else:
		errors.append("mechanics_tooltip_fields_missing:"+skill_id)
	var vfx: Variant = entry.get("vfx",{})
	if not (vfx is Dictionary):
		errors.append("vfx_spec_missing:"+skill_id)
	else:
		var brief: Variant = vfx.get("production_brief",{})
		if not (brief is Dictionary):
			errors.append("vfx_production_brief_missing:"+skill_id)
		else:
			var phases: Variant = brief.get("phases",[])
			var expected_phases := ["windup","telegraph","release","travel","impact","status","fade"]
			if not (phases is Array) or phases.size() != expected_phases.size():
				errors.append("vfx_phase_count_not_seven:"+skill_id)
			else:
				for phase_index in range(expected_phases.size()):
					var phase_value: Variant = phases[phase_index]
					if not (phase_value is Dictionary):
						errors.append("vfx_phase_not_object:"+skill_id+":"+expected_phases[phase_index])
						continue
					for required_field in ["event_type","runtime_status","anchor","visual_direction","production_note"]:
						if str(phase_value.get(required_field,"")).strip_edges().is_empty():
							errors.append("vfx_phase_field_missing:"+skill_id+":"+expected_phases[phase_index]+":"+required_field)
			if str(brief.get("asset_status","")) != "NOT_PRESENT" or not (brief.get("asset_files",[]) is Array) or not brief.get("asset_files",[]).is_empty():
				errors.append("vfx_asset_status_not_honest:"+skill_id)
			if str(brief.get("render_capture_status","")) != "NOT_CAPTURED" or str(brief.get("visual_acceptance_status","")) != "PENDING":
				errors.append("vfx_render_status_must_remain_pending:"+skill_id)

static func build_mechanics_tooltip(skill: Dictionary, actor_stats: Dictionary = {}, target_distance: float = -1.0) -> Dictionary:
	var effect := str(skill.get("effect",""))
	if effect not in ["damage","poison","mark","guard","mobility","slow","heal","cleanse","passive","innate"]:
		return {"ok":false,"text":"","errors":["s0_tooltip_effect_not_yet_supported:"+effect]}
	for field in ["damage_ratio","power","duration","passive_modifiers","range","cast_time","cooldown","projectile_speed","shape","target_limit"]:
		if not skill.has(field):
			return {"ok":false,"text":"","errors":["runtime_fields_incomplete_for_tooltip:"+field]}
	var lines: Array[String] = []
	if effect in ["damage","poison","mark"]:
		lines.append("Sát thương trực tiếp: " + _format_number(float(skill.get("damage_ratio",0.0)),2) + "× ATK trước phòng thủ.")
	if effect == "mark":
		var mark_cap := 1.15 if str(skill.get("school","")) == "blade" else 1.5
		lines.append("Dấu ấn: hệ số đòn kế tiếp " + _format_number(clampf(float(skill.get("power",1.0)),1.0,mark_cap),2) + "× của người đặt; tồn tại tối đa " + _format_number(clampf(float(skill.get("duration",0.0)),0.5,12.0),2) + " giây.")
		if str(skill.get("school","")) == "blade":
			lines.append("Chỉ đòn Đao kế tiếp của cùng người đặt tiêu thụ dấu; không xuyên giáp.")
	elif effect == "poison":
		var tick_seconds := V63HumanSkillCombatSystem.POISON_TICK_INTERVAL_SECONDS
		var poison_duration := clampf(float(skill.get("duration",0.0)),1.0,10.0)
		var stacks := maxi(0,int(skill.get("poison_stacks",0)))
		lines.append("Độc duy trì: " + _format_number(float(skill.get("power",0.0))*100.0,3) + "% ATK mỗi " + _format_number(tick_seconds,2) + " giây, tối đa " + _format_number(poison_duration,2) + " giây; catalog cho phép thêm tối đa " + str(stacks) + " tầng mỗi lần thi triển (giới hạn runtime vẫn áp dụng).")
	elif effect == "guard":
		var reduction := clampf(float(skill.get("power",0.0)),0.05,0.8)
		var guard_duration := clampf(float(skill.get("duration",0.0)),0.5,12.0)
		if str(skill.get("school", "")) in ["spear", "palm"] and str(skill.get("guard_mode", "")) == "capacity_shield":
			lines.append("Hộ thuẫn sức chứa: " + _format_number(float(skill.get("guard_capacity_ratio",0.0))*100.0,2) + "% HP tối đa trong tối đa " + _format_number(guard_duration,2) + " giây; sát thương thực làm cạn sức chứa.")
		else:
			lines.append("Giảm sát thương nhận: " + _format_number(reduction*100.0,2) + "% trong " + _format_number(guard_duration,2) + " giây; mức áp dụng bị giới hạn bởi HSC.")
		if str(skill.get("school","")) in ["blade", "spear", "palm"] and str(skill.get("guard_target_policy","self")) == "weakest_ally":
			lines.append("Mục tiêu hộ: đồng đội cùng đội hình có tỷ lệ HP thấp nhất trong tầm; hòa thì dùng thứ tự ID ổn định.")
	elif effect == "slow":
		lines.append("Sát thương: " + _format_number(float(skill.get("damage_ratio",0.0)),2) + "× ATK; tốc độ di chuyển mục tiêu còn " + _format_number(clampf(float(skill.get("slow_movement_factor",1.0)),0.5,1.0)*100.0,2) + "% trong tối đa " + _format_number(clampf(float(skill.get("duration",0.0)),0.0,8.0),2) + " giây.")
		if str(skill.get("school", "")) == "palm":
			lines.append("Boss chỉ nhận " + _format_number(clampf(float(skill.get("boss_effect_strength_factor",0.35)),0.0,1.0)*100.0,2) + "% độ mạnh và " + _format_number(clampf(float(skill.get("boss_duration_factor",0.4)),0.0,1.0)*100.0,2) + "% thời lượng candidate.")
	elif effect == "heal":
		lines.append("Hồi tối đa " + _format_number(clampf(float(skill.get("power",0.0)),0.0,0.5)*100.0,2) + "% HP tối đa; chỉ ghi lượng HP thực còn thiếu, không hồi sinh.")
	elif effect == "cleanse":
		lines.append("Giải trừ tối đa " + str(clampi(int(skill.get("power",0.0)),0,3)) + " trạng thái xấu đang tồn tại trên mục tiêu hợp lệ.")
	elif effect == "damage" and int(skill.get("hit_count",1)) > 1:
		var hit_count := clampi(int(skill.get("hit_count",1)),1,3)
		lines.append("Số nhịp Đao: " + str(hit_count) + "; hệ số tổng chia đều theo nhịp, dừng khi mục tiêu hết HP.")
	elif effect == "mobility":
		lines.append("Lướt theo đường đi hợp lệ trong phạm vi " + _format_number(float(skill.get("range",0.0)),2) + " ô; cửa sổ né tránh: " + _format_number(maxf(MapBattleV2.STEP_SECONDS,float(skill.get("duration",1.0))),2) + " giây.")
	elif effect in ["passive","innate"]:
		var modifiers: Dictionary = skill.get("passive_modifiers",{})
		for key in modifiers.keys():
			var value := float(modifiers[key])
			if str(key) == "guard_factor":
				lines.append("Giảm sát thương nhận thêm: " + _format_number((1.0-clampf(value,0.5,1.0))*100.0,2) + "%.")
			elif str(key) == "absorbed_reflect_ratio":
				lines.append("Phản kích ứng viên: tối đa " + _format_number(clampf(value,0.0,0.3)*100.0,2) + "% phần sát thương thực sự bị guard giảm; feature gate tương ứng hiện OFF.")
			else:
				var label := str(key)
				var shown := value
				if str(key) == "lifesteal":
					label = "Hút máu"
					shown = value*100.0
				elif str(key) == "crit_bonus":
					label = "Tỷ lệ bạo kích"
					shown = value*100.0
				elif str(key) == "outgoing_factor":
					label = "Sát thương gây ra"
					shown = value*100.0
				elif str(key) == "attack_speed_factor":
					label = "Tốc đánh"
					shown = value*100.0
				elif str(key) == "cast_speed_factor":
					label = "Tốc thi triển"
					shown = value*100.0
				elif str(key) == "cooldown_recovery_factor":
					label = "Hồi chiêu"
					shown = value*100.0
				elif str(key) == "heal_factor":
					label = "Lượng hồi phục"
					shown = value*100.0
				elif str(key) == "poison_factor":
					label = "Hiệu lực Độc"
					shown = value*100.0
				lines.append(label + ": " + _format_number(shown,2) + "% theo modifier runtime.")
		if lines.is_empty():
			lines.append("Không có modifier số; node chỉ hoạt động khi được gắn đúng vị trí.")
	var element_names := {
		"metal":"Kim","wood":"Mộc","water":"Thủy","fire":"Hỏa","earth":"Thổ",
		"lightning":"Lôi","wind":"Phong","ice":"Băng","yang":"Dương","nether":"U Minh"
	}
	lines.append("Nguyên tố: " + str(element_names.get(str(skill.get("element","")),str(skill.get("element","")))) + ".")
	lines.append("Tầm: " + _format_number(float(skill.get("range",0.0)),2) + " ô; mục tiêu tối đa: " + str(int(skill.get("target_limit",0))) + "; phạm vi: " + _shape_name(str(skill.get("shape","")))+".")
	var cast_rate := maxf(0.1,1.0+float(actor_stats.get("cast_speed",0.0)))
	var cooldown_rate := maxf(0.1,1.0+float(actor_stats.get("cooldown_recovery",0.0)))
	var cast_time := float(skill.get("cast_time",0.0))/cast_rate
	var cooldown := float(skill.get("cooldown",0.0))/cooldown_rate
	lines.append("Thi triển: " + _format_number(cast_time,2) + " giây" + (" theo chỉ số hiện tại" if not actor_stats.is_empty() else " theo catalog") + "; hồi chiêu: " + _format_number(cooldown,2) + " giây" + (" theo chỉ số hiện tại" if not actor_stats.is_empty() else " gốc") + ".")
	var projectile_speed := float(skill.get("projectile_speed",0.0))
	if projectile_speed > 0.0:
		var projectile_line := "Tốc độ bay: " + _format_number(projectile_speed,2) + " ô/giây."
		if target_distance >= 0.0:
			projectile_line += " Thời gian bay tới mục tiêu hiện tại: " + _format_number(target_distance/projectile_speed,2) + " giây."
		lines.append(projectile_line)
	if str(skill.get("school","")) in ["sword","blade","spear","dual_blade","palm"] and str(skill.get("source_codex_id","")).is_empty():
		lines.append("Nguồn truyền thừa của nhánh này chưa có trong Kho; node vẫn bị khóa.")
	return {"ok":true,"text":"\n".join(lines),"errors":[]}
static func validate_all36_ledger(csv_text: String, catalogues: Dictionary, registry: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var normalized := csv_text.replace("\r\n","\n")
	var source_lines := normalized.split("\n",false)
	if source_lines.is_empty():
		return {"ok":false,"errors":["all36_ledger_empty"],"warnings":[],"metrics":{}}
	var headers := _parse_csv_line(source_lines[0])
	var required_headers := ["record_key","status","school","branch","family_key","slot","tier","lineage","variant","runtime_id","name","parent","replaces","element","effect","shape","range","cooldown","target_cap","cc","ai","animation","vfx","source_ref","qa"]
	for header in required_headers:
		if not headers.has(header):
			errors.append("all36_ledger_header_missing:"+header)
	var rows: Array[Dictionary] = []
	for line_index in range(1,source_lines.size()):
		var line := source_lines[line_index]
		if line.strip_edges().is_empty():
			continue
		var values := _parse_csv_line(line)
		if values.size() != headers.size():
			errors.append("all36_ledger_column_count_mismatch:line_"+str(line_index+1))
			continue
		var row: Dictionary = {}
		for field_index in range(headers.size()):
			row[str(headers[field_index])] = str(values[field_index])
		rows.append(row)
	if rows.size() != 2196:
		errors.append("all36_ledger_row_count_not_2196:"+str(rows.size()))
	var by_alias: Dictionary = {}
	var row_keys: Dictionary = {}
	var runtime_ids: Dictionary = {}
	var status_counts: Dictionary = {}
	var school_counts: Dictionary = {}
	var family_by_school: Dictionary = {}
	var branch_by_school: Dictionary = {}
	var family_seen: Dictionary = {}
	var branch_seen: Dictionary = {}
	var missing_registry_ids: Array[String] = []
	for row in rows:
		var key := str(row.get("record_key",""))
		if key.is_empty() or row_keys.has(key):
			errors.append("all36_duplicate_or_empty_record_key:"+key)
		else:
			row_keys[key] = true
			by_alias[key] = row
		var status := str(row.get("status",""))
		status_counts[status] = int(status_counts.get(status,0))+1
		var school := str(row.get("school",""))
		school_counts[school] = int(school_counts.get(school,0))+1
		var family := str(row.get("family_key",""))
		family_seen[family] = true
		if not family_by_school.has(school):
			family_by_school[school] = {}
		var school_families: Dictionary = family_by_school[school]
		school_families[family] = true
		family_by_school[school] = school_families
		var slot := str(row.get("slot",""))
		var tier := str(row.get("tier",""))
		var lineage := str(row.get("lineage",""))
		var variant := str(row.get("variant",""))
		if slot not in VALID_SLOTS:
			errors.append("all36_invalid_slot:"+key+":"+slot)
		if tier not in VALID_TIERS or lineage not in VALID_LINEAGES or variant not in VALID_VARIANTS:
			errors.append("all36_invalid_lineage_slot:"+key)
		var branch := str(row.get("branch",""))
		if branch.is_empty():
			if slot not in ["basic","mobility"]:
				errors.append("all36_empty_noncommon_branch:"+key)
		else:
			var branch_key := school+"/"+branch
			branch_seen[branch_key] = true
			if not branch_by_school.has(school):
				branch_by_school[school] = {}
			var school_branches: Dictionary = branch_by_school[school]
			school_branches[branch] = true
			branch_by_school[school] = school_branches
		if status == "EXISTING" or status == "CANDIDATE_GATED":
			var runtime_id := str(row.get("runtime_id",""))
			if runtime_id.is_empty() or runtime_ids.has(runtime_id):
				errors.append("all36_duplicate_or_empty_runtime_id:"+key)
			else:
				runtime_ids[runtime_id] = true
				by_alias[runtime_id] = row
			var skill := _find_runtime_skill(catalogues,runtime_id)
			if skill.is_empty():
				errors.append("all36_ledger_runtime_not_in_catalogue:"+runtime_id)
			else:
				_compare_ledger_runtime(row,skill,errors)
				var registry_node := _find_registry_node(registry,runtime_id)
				if registry_node.is_empty():
					missing_registry_ids.append(runtime_id)
			if str(row.get("name","")).strip_edges().is_empty():
				errors.append("all36_existing_name_missing:"+key)
		elif status == "NOT_AUTHORED":
			if not str(row.get("runtime_id","")).is_empty():
				errors.append("all36_not_authored_has_runtime_id:"+key)
		else:
			errors.append("all36_unknown_ledger_status:"+key+":"+status)
		if str(row.get("source_ref","")).strip_edges().is_empty():
			errors.append("all36_source_reference_missing:"+key)
	if status_counts.get("EXISTING",0) != 549 or status_counts.get("CANDIDATE_GATED",0) != 915 or status_counts.get("NOT_AUTHORED",0) != 732:
		errors.append("all36_authorship_counts_mismatch")
	if runtime_ids.size() != 1464:
		errors.append("all36_existing_runtime_count_mismatch:"+str(runtime_ids.size()))
	var actual_runtime_ids := _all_runtime_ids(catalogues)
	if actual_runtime_ids.size() != runtime_ids.size():
		errors.append("all36_runtime_catalogue_count_mismatch:"+str(actual_runtime_ids.size()))
	for id in runtime_ids.keys():
		if not actual_runtime_ids.has(id):
			errors.append("all36_runtime_catalogue_id_missing:"+str(id))
	for id in actual_runtime_ids.keys():
		if not runtime_ids.has(id):
			errors.append("all36_runtime_id_absent_from_ledger:"+str(id))
	if school_counts.size() != 12:
		errors.append("all36_school_count_not_twelve:"+str(school_counts.size()))
	for school in ALL36_SCHOOLS:
		if int(school_counts.get(school,0)) != 183:
			errors.append("all36_school_node_count_mismatch:"+school)
		if not (family_by_school.get(school,{}) is Dictionary) or family_by_school[school].size() != 35:
			errors.append("all36_family_count_mismatch:"+school)
		if not (branch_by_school.get(school,{}) is Dictionary) or branch_by_school[school].size() != 3:
			errors.append("all36_branch_count_mismatch:"+school)
	if family_seen.size() != 420:
		errors.append("all36_family_total_not_420:"+str(family_seen.size()))
	if branch_seen.size() != 36:
		errors.append("all36_branch_total_not_36:"+str(branch_seen.size()))
	if status_counts.get("EXISTING",0)+status_counts.get("CANDIDATE_GATED",0)+status_counts.get("NOT_AUTHORED",0) != 2196:
		errors.append("all36_status_total_mismatch")
	var lineage_errors := _validate_ledger_lineage(rows,by_alias)
	errors.append_array(lineage_errors)
	if not missing_registry_ids.is_empty():
		errors.append("all36_runtime_catalogue_ids_missing_from_registry:"+str(missing_registry_ids.size()))
	var metrics := {
		"rows":rows.size(),"existing":status_counts.get("EXISTING",0),
		"not_authored":status_counts.get("NOT_AUTHORED",0),"candidate_gated":status_counts.get("CANDIDATE_GATED",0),"schools":school_counts.size(),
		"families":family_seen.size(),"branches":branch_seen.size(),
		"runtime_catalogue_ids":actual_runtime_ids.size(),
		"registry_missing_runtime_ids":missing_registry_ids.size()
	}
	return {"ok":errors.is_empty(),"errors":errors,"warnings":warnings,"metrics":metrics}

static func _validate_ledger_lineage(rows: Array[Dictionary], by_alias: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var tier_order := {"human":0,"immortal":1,"divine":2}
	for row in rows:
		for field in ["parent","replaces"]:
			var reference := str(row.get(field,""))
			if reference.is_empty():
				continue
			var referenced: Variant = by_alias.get(reference,{})
			if not (referenced is Dictionary):
				errors.append("all36_lineage_reference_missing:"+str(row.get("record_key",""))+":"+field)
				continue
			if str(referenced.get("family_key","")) != str(row.get("family_key","")):
				errors.append("all36_cross_family_lineage_reference:"+str(row.get("record_key",""))+":"+field)
			if field == "parent":
				var parent_order := int(tier_order.get(str(referenced.get("tier","")),-1))
				var child_order := int(tier_order.get(str(row.get("tier","")),-1))
				if parent_order > child_order or (parent_order == child_order and str(row.get("variant","")) != "RARE"):
					errors.append("all36_parent_tier_order_invalid:"+str(row.get("record_key","")))
		var seen: Dictionary = {}
		var current: Dictionary = row
		while not str(current.get("parent","")).is_empty():
			var current_key := str(current.get("record_key",""))
			if seen.has(current_key):
				errors.append("all36_parent_cycle:"+current_key)
				break
			seen[current_key] = true
			var parent_key := str(current.get("parent",""))
			var next_value: Variant = by_alias.get(parent_key,{})
			if not (next_value is Dictionary):
				break
			current = next_value
	return errors

static func _compare_ledger_runtime(row: Dictionary, skill: Dictionary, errors: Array[String]) -> void:
	var pairs := {"name":"name","element":"element","effect":"effect","shape":"shape","range":"range","cooldown":"cooldown","target_cap":"target_limit"}
	for ledger_key in pairs.keys():
		var source_key := str(pairs[ledger_key])
		var actual := str(row.get(str(ledger_key),""))
		if actual.is_empty():
			errors.append("all36_existing_runtime_field_missing:"+str(row.get("runtime_id",""))+":"+str(ledger_key))
			continue
		var expected: Variant = skill.get(source_key,null)
		if expected == null:
			errors.append("all36_catalogue_field_missing:"+str(row.get("runtime_id",""))+":"+source_key)
		elif source_key in ["range","cooldown","target_limit"] and not is_equal_approx(float(actual),float(expected)):
			errors.append("all36_catalogue_numeric_field_mismatch:"+str(row.get("runtime_id",""))+":"+source_key)
		elif source_key not in ["range","cooldown","target_limit"] and actual != str(expected):
			errors.append("all36_catalogue_field_mismatch:"+str(row.get("runtime_id",""))+":"+source_key)

static func _find_skill_in_catalogue(catalogue: Dictionary, skill_id: String) -> Dictionary:
	for raw in catalogue.get("skills",[]):
		if raw is Dictionary and str(raw.get("id","")) == skill_id:
			return raw
	return {}

static func _find_runtime_skill(catalogues: Dictionary, skill_id: String) -> Dictionary:
	for key in catalogues.keys():
		var catalogue: Variant = catalogues[key]
		if catalogue is Dictionary:
			var found := _find_skill_in_catalogue(catalogue,skill_id)
			if not found.is_empty():
				return found
	return {}

static func _find_registry_node(registry: Dictionary, skill_id: String) -> Dictionary:
	for family_value in registry.get("families",[]):
		if not (family_value is Dictionary):
			continue
		for node_value in family_value.get("nodes",[]):
			if node_value is Dictionary and str(node_value.get("id","")) == skill_id:
				return node_value
	return {}

static func _all_runtime_ids(catalogues: Dictionary) -> Dictionary:
	var ids: Dictionary = {}
	for key in catalogues.keys():
		var catalogue: Variant = catalogues[key]
		if not (catalogue is Dictionary):
			continue
		for skill in catalogue.get("skills",[]):
			if skill is Dictionary:
				ids[str(skill.get("id",""))] = true
	return ids

static func _parse_csv_line(line: String) -> Array[String]:
	var fields: Array[String] = []
	var value := ""
	var quoted := false
	var index := 0
	while index < line.length():
		var character := line.substr(index,1)
		if quoted:
			if character == "\"" and index+1 < line.length() and line.substr(index+1,1) == "\"":
				value += "\""
				index += 1
			elif character == "\"":
				quoted = false
			else:
				value += character
		elif character == "\"":
			quoted = true
		elif character == ",":
			fields.append(value)
			value = ""
		else:
			value += character
		index += 1
	fields.append(value)
	return fields

static func _contains_ascii_digit(value: String) -> bool:
	for index in range(value.length()):
		var codepoint := value.unicode_at(index)
		if codepoint >= 48 and codepoint <= 57:
			return true
	return false

static func _format_number(value: float, decimals: int) -> String:
	var result := String.num(value,decimals)
	if result.contains("."):
		while result.ends_with("0"):
			result = result.left(result.length()-1)
		if result.ends_with("."):
			result = result.left(result.length()-1)
	return result.replace(".",",")

static func _shape_name(shape: String) -> String:
	match shape:
		"single_target": return "đơn mục tiêu"
		"circle": return "vùng tròn"
		"line": return "đường thẳng"
	return shape
