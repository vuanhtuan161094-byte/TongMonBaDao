extends SceneTree

const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var loaded := Presentation.load_authoring_sources()
	_expect(bool(loaded.get("ok",false)),"catalogues, registry and S0 manifest load")
	if not bool(loaded.get("ok",false)):
		for error in loaded.get("errors",[]):
			push_error("V63_S0_LOAD "+str(error))
		_finish()
		return
	var catalogues: Dictionary = loaded["catalogues"]
	var registry: Dictionary = loaded["registry"]
	var manifest: Dictionary = loaded["manifest"]
	var manifest_errors := Presentation.validate_sample_entries(manifest,catalogues,registry)
	_expect(manifest_errors.is_empty(),"four real skill presentations match runtime source and Git blob hashes")
	for error in manifest_errors:
		push_error("V63_S0_MANIFEST "+str(error))
	var matrix_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
	var matrix_file := FileAccess.open(matrix_path,FileAccess.READ)
	_expect(matrix_file != null,"authoritative 2,196-row coverage matrix is readable")
	if matrix_file != null:
		var coverage := Presentation.validate_all36_ledger(matrix_file.get_as_text(),catalogues,registry)
		_expect(bool(coverage.get("ok",false)),"all36 ledger/runtime identity/lineage audit")
		var metrics: Dictionary = coverage.get("metrics",{})
		_expect(int(metrics.get("rows",0)) == 2196,"ledger rows = 2,196")
		_expect(int(metrics.get("existing",0)) == 549,"existing source rows = 549")
		_expect(int(metrics.get("not_authored",0)) == 1281,"remaining unauthored rows = 1,281")
		_expect(int(metrics.get("candidate_gated",0)) == 366,"Sword and Dao candidate rows = 366 and remain gated")
		_expect(int(metrics.get("runtime_catalogue_ids",0)) == 915,"549 existing plus 366 gated catalogue IDs = 915")
		_expect(int(metrics.get("families",0)) == 420,"families = 420")
		_expect(int(metrics.get("branches",0)) == 36,"non-common branches = 36")
		_expect(int(metrics.get("registry_missing_runtime_ids",-1)) == 0,"all existing runtime IDs are represented by the registry")
		_expect(coverage.get("warnings",[]).is_empty(),"coverage audit has no unresolved registry warnings")
		for error in coverage.get("errors",[]):
			push_error("V63_S0_LEDGER "+str(error))
		for warning in coverage.get("warnings",[]):
			print("V63_S0_LEDGER_WARNING "+str(warning))
		print("V63_S0_LEDGER_METRICS "+JSON.stringify(metrics))
	var entries: Dictionary = manifest.get("entries",{})
	_expect(entries.size() == 370,"four retained S0 samples plus Sword and Dao candidate presentations")
	var basic_id := "tmb.skill.bow.basic.human"
	var arrow_id := "tmb.skill.bow.liep_anh.active_01.human"
	var poison_id := "tmb.skill.poison.co_doc.active_02.human"
	var needle_id := "tmb.skill.poison.doc_cham.active_01.human"
	var basic := Presentation.runtime_skill_definition(catalogues,basic_id)
	var arrow := Presentation.runtime_skill_definition(catalogues,arrow_id)
	var poison := Presentation.runtime_skill_definition(catalogues,poison_id)
	var needle := Presentation.runtime_skill_definition(catalogues,needle_id)
	var basic_tip := Presentation.build_mechanics_tooltip(basic)
	var arrow_tip := Presentation.build_mechanics_tooltip(arrow)
	var poison_tip := Presentation.build_mechanics_tooltip(poison)
	var needle_tip := Presentation.build_mechanics_tooltip(needle)
	var joined_poison := Presentation.presentation_for(poison_id,manifest,catalogues)
	_expect(bool(joined_poison.get("ok",false)) and str(joined_poison.get("presentation",{}).get("display_name_vi","")) == "Xà Ảnh Quấn Mạch" and str(joined_poison.get("mechanics_tooltip","")).contains("2,2% ATK"),"runtime API joins Vietnamese presentation to canonical poison mechanics")
	_expect(bool(basic_tip.get("ok",false)) and str(basic_tip.get("text","")).contains("1× ATK") and str(basic_tip.get("text","")).contains("9 ô"),"Cung basic tooltip is generated from canonical values")
	_expect(bool(arrow_tip.get("ok",false)) and str(arrow_tip.get("text","")).contains("1,35× ATK") and str(arrow_tip.get("text","")).contains("8 giây"),"Xuyên Tâm Tiễn tooltip uses source ratio and cooldown")
	_expect(bool(poison_tip.get("ok",false)) and str(poison_tip.get("text","")).contains("2,2% ATK") and str(poison_tip.get("text","")).contains("8 giây") and str(poison_tip.get("text","")).contains("1 tầng"),"Xà Ảnh tooltip derives poison power, duration and stack count")
	_expect(bool(needle_tip.get("ok",false)) and str(needle_tip.get("text","")).contains("1,45× ATK") and not str(needle_tip.get("text","")).contains("Độc duy trì"),"Xuyên Cốt Độc Châm remains direct damage, not a DoT")
	var adjusted_tip := Presentation.build_mechanics_tooltip(arrow,{"cast_speed":0.5,"cooldown_recovery":1.0},8.0)
	_expect(bool(adjusted_tip.get("ok",false)) and str(adjusted_tip.get("text","")).contains("0,3 giây") and str(adjusted_tip.get("text","")).contains("4 giây") and str(adjusted_tip.get("text","")).contains("1 giây."),"tooltip derives actor timing and projectile flight when context is supplied")
	var vfx_honest := true
	for id in [basic_id,arrow_id,poison_id,needle_id]:
		var entry: Dictionary = entries.get(id,{})
		var brief: Dictionary = entry.get("vfx",{}).get("production_brief",{})
		vfx_honest = vfx_honest and str(brief.get("asset_status","")) == "NOT_PRESENT"
		vfx_honest = vfx_honest and str(brief.get("render_capture_status","")) == "NOT_CAPTURED"
		vfx_honest = vfx_honest and str(brief.get("visual_acceptance_status","")) == "PENDING"
		var qa_status: Dictionary = entry.get("qa_status",{})
		vfx_honest = vfx_honest and str(qa_status.get("behavior","")) == "NOT_AUDITED_PER_SKILL"
		vfx_honest = vfx_honest and str(qa_status.get("vfx_metadata","")) == "VFX_META_COMPLETE"
		vfx_honest = vfx_honest and brief.get("phases",[]).size() == 7
	_expect(vfx_honest,"all sample VFX briefs contain seven production phases and do not claim assets/render acceptance")
	_expect(str(entries.get(needle_id,{}).get("long_description_vi","")).contains("không đặt trạng thái Độc"),"Vietnamese description distinguishes the poison-named damage skill")
	_expect(not Presentation.validate_sample_entries(manifest,catalogues,registry).has("v63_release_gate_must_remain_off"),"V6.3 presentation data does not unlock the combat feature")
	_finish()

func _expect(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("V63_S0_FAIL "+label)

func _finish() -> void:
	if _failures > 0:
		print("V63_S0_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
		quit(1)
		return
	print("V63_S0_RESULT PASS checks="+str(_checks)+" samples=4 sword_candidate=183 blade_candidate=183 existing=549 not_authored=1281 ledger=2196 release_gate=OFF")
	quit(0)
