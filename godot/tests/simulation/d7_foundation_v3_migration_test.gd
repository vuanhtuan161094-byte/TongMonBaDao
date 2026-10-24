extends SceneTree

var failed := false
var checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("D7 V3 FAIL: "+message)

func _run() -> void:
	if not _test_generation() or not _test_migration_and_growth() or not _test_save_migration() or not _test_potential_scope():
		quit(1)
		return
	print("D7 FOUNDATION V3 MIGRATION/GENERATION/POTENTIAL SCOPE PASS checks=%d" % checks)
	quit(1 if failed else 0)

func _test_generation() -> bool:
	var state := SimulationState.new()
	state.seed = 20261024
	var generator := DiscipleGeneratorOpenPoints.new()
	var grades := DiscipleGeneratorV2.VALID_QUALITIES
	var sources := DiscipleGeneratorV2.VALID_SOURCES
	for source_index in range(sources.size()):
		for grade_index in range(grades.size()):
			var source := StringName(sources[source_index])
			var grade := StringName(grades[grade_index])
			var candidate := generator.generate_candidate(state,source,100+source_index*10+grade_index,grade)
			if candidate == null:
				_check(false,"forced-grade candidate generation")
				return false
			var tam_sum := candidate.aptitude+candidate.constitution+candidate.mind_nature
			var tetrad_sum := candidate.potential+candidate.comprehension+candidate.fortune+candidate.charisma
			var bounds := _pool_bounds(grade,tam_sum,tetrad_sum)
			_check(candidate.foundation_model_version == FoundationSystem.MODEL_D7,"new candidate uses model 3")
			_check(is_equal_approx(tam_sum,float(bounds[0])) and is_equal_approx(tetrad_sum,float(bounds[1])),"two budgets stay independent and exact")
			_check(candidate.disciple_quality == grade,"Q_birth remains in its source quality band")
			_check(_pool_points_valid([candidate.aptitude,candidate.constitution,candidate.mind_nature],int(tam_sum)),"Tam Can feasible allocation")
			_check(_pool_points_valid([candidate.potential,candidate.comprehension,candidate.fortune,candidate.charisma],int(tetrad_sum)),"Tu Tinh feasible allocation")
			_check(candidate.foundation_birth_values.has("mind_nature"),"birth provenance includes mind nature")
	var replay_a := generator.generate_candidate(state,DiscipleGeneratorV2.SOURCE_FATE,909,&"")
	var replay_b := generator.generate_candidate(state,DiscipleGeneratorV2.SOURCE_FATE,909,&"")
	_check(replay_a.to_dict() == replay_b.to_dict(),"profile/domain seed replay is deterministic")
	var source_rates := {
		"ordinary":[0.65,0.25,0.08,0.018,0.002],
		"gacha":[0.42,0.30,0.18,0.08,0.02],
		"fate":[0.50,0.28,0.14,0.06,0.02]
	}
	for source_name in source_rates.keys():
		var rng := GameRng.new(772024+int(DiscipleGeneratorOpenPoints.new()._stable_hash(source_name)))
		var observed := [0,0,0,0,0]
		for _sample in range(30000):
			var rolled := generator._roll_source_quality(rng,StringName(source_name))
			observed[DiscipleGeneratorV2.VALID_QUALITIES.find(rolled)] += 1
		for index in range(observed.size()):
			var rate := float(observed[index])/30000.0
			_check(absf(rate-float(source_rates[source_name][index])) <= 0.015,"preserved "+source_name+" quality odds tier "+str(index))
	return not failed

func _pool_bounds(grade: StringName, tam_sum: float, tu_sum: float) -> Array:
	match grade:
		DiscipleGeneratorV2.QUALITY_COMMON: return [int(tam_sum),int(tu_sum)] if tam_sum>=60 and tam_sum<=179 and tu_sum>=80 and tu_sum<=239 else [-1,-1]
		DiscipleGeneratorV2.QUALITY_OUTSTANDING: return [int(tam_sum),int(tu_sum)] if tam_sum>=180 and tam_sum<=299 and tu_sum>=240 and tu_sum<=399 else [-1,-1]
		DiscipleGeneratorV2.QUALITY_PRODIGY: return [int(tam_sum),int(tu_sum)] if tam_sum>=300 and tam_sum<=499 and tu_sum>=400 and tu_sum<=666 else [-1,-1]
		DiscipleGeneratorV2.QUALITY_PEERLESS: return [int(tam_sum),int(tu_sum)] if tam_sum>=500 and tam_sum<=899 and tu_sum>=667 and tu_sum<=1199 else [-1,-1]
		_: return [int(tam_sum),int(tu_sum)] if tam_sum>=900 and tu_sum>=1200 else [-1,-1]

func _pool_points_valid(values: Array, budget: int) -> bool:
	var count := values.size()
	var low := maxi(1,int(floor(float(budget)/(2.0*count))))
	var high := mini(int(floor(3.0*float(budget)/float(count))),budget-(count-1)*low)
	var sum := 0
	for value in values:
		if int(value)<low or int(value)>high: return false
		sum += int(value)
	return sum == budget

func _test_migration_and_growth() -> bool:
	var birth := {"aptitude":60.0,"constitution":60.0,"fortune":60.0,"comprehension":60.0,"charisma":60.0,"potential":60.0}
	var legacy_six := {"aptitude":70.0,"constitution":70.0,"fortune":70.0,"comprehension":70.0,"charisma":70.0,"potential":70.0}
	var disciple_data := legacy_six.duplicate(true)
	disciple_data.merge({"id":"d7_migration_disciple","name":"Migration Test","profile_seed":12345,"recruitment_source":"ordinary","foundation_model_version":FoundationSystem.MODEL_OPEN_POINTS,"foundation_birth_values":birth.duplicate(true),"disciple_quality":"outstanding"},true)
	var disciple := DiscipleState.new(disciple_data)
	var candidate_data := legacy_six.duplicate(true)
	candidate_data.merge({"id":"candidate_d7_migration","name":"Migration Candidate","profile_seed":12346,"recruitment_source":"ordinary","foundation_model_version":FoundationSystem.MODEL_OPEN_POINTS,"foundation_birth_values":birth.duplicate(true),"disciple_quality":"outstanding","age":20,"base_lifespan":100,"max_lifespan":100,"latent_identity_seed":777,"spiritual_root_elements":["wood"]},true)
	var candidate := CandidateState.new(candidate_data)
	var state := SimulationState.new()
	state.disciples[disciple.id] = disciple
	state.recruitment_candidates[candidate.id] = candidate
	var foundation := FoundationSystem.new()
	_check(foundation.enable_d7(state),"6D to D7 migration accepts complete provenance")
	_check(disciple.foundation_model_version == FoundationSystem.MODEL_D7 and candidate.foundation_model_version == FoundationSystem.MODEL_D7,"both disciples and candidates upgraded")
	_check(disciple.mind_nature == 60.0 and candidate.mind_nature == 60.0,"mind is mean of immutable six-stat birth")
	_check(disciple.aptitude == 70.0 and disciple.foundation_birth_values["aptitude"] == 60.0,"old current and birth stats preserved")
	_check(disciple.disciple_quality == "outstanding" and foundation.total_disciple(disciple) == 420.0,"quality/current baseline preserved exactly")
	_check(foundation.validate_disciple(disciple).is_empty() and foundation.validate_candidate(candidate).is_empty(),"migrated D7 invariants validate")
	var expected := foundation.total_disciple(disciple)
	for dimension in FoundationSystem.DIMENSIONS:
		_check(foundation.add_permanent_points(disciple,StringName(dimension),1.0),"permanent +1 accepted for "+str(dimension))
		expected += 1.0
		_check(is_equal_approx(foundation.total_disciple(disciple),expected),"+1 permanently adds exactly one quality point")
	var invalid := SimulationState.new()
	var missing := DiscipleState.new({"id":"missing_provenance","profile_seed":99,"foundation_model_version":FoundationSystem.MODEL_OPEN_POINTS,"aptitude":50.0,"constitution":50.0,"fortune":50.0,"comprehension":50.0,"charisma":50.0,"potential":50.0,"disciple_quality":"common"})
	invalid.disciples[missing.id] = missing
	_check(not foundation.enable_d7(invalid),"missing birth provenance fails closed")
	_check(missing.foundation_model_version == FoundationSystem.MODEL_OPEN_POINTS and missing.mind_nature == 0.0 and not invalid.sect.foundation_points_enabled,"failed migration leaves record unmutated")
	return not failed

func _test_potential_scope() -> bool:
	var result := CombatStatsV2.derive(1,1,1,1,1000.0,[],true)
	_check(bool(result.get("ok",false)),"D7 realm-only potential derives")
	if bool(result.get("ok",false)):
		var stats: Dictionary = result["stats"]
		_check(is_equal_approx(float(stats["max_hp"]),240.0),"potential scales Tu Vi core only; Body HP remains unchanged")
		_check(is_equal_approx(float(stats["attack"]),33.0),"potential scales Tu Vi attack only")
		_check(is_equal_approx(float(stats["defense"]),25.0),"potential scales Tu Vi defense only")
	return not failed

func _test_save_migration() -> bool:
	var state := P37Factory.create_state(731024)
	state.sect.disciple_capacity = maxi(state.sect.disciple_capacity,state.disciples.size()+1)
	state.sect.disciple_v2_birth_enabled = true
	var candidate := DiscipleGeneratorOpenPoints.new().generate_candidate(state,DiscipleGeneratorV2.SOURCE_ORDINARY,992010)
	if candidate == null or candidate.v2_birth_profile.is_empty():
		_check(false,"create authentic V2 migration candidate")
		return false
	state.recruitment_candidates[candidate.id] = candidate
	var accepted := RecruitmentSystem.new().accept_candidate(state,candidate.id)
	if not bool(accepted.get("ok",false)):
		_check(false,"recruit authentic V2 migration candidate")
		return false
	var disciple: DiscipleState = state.disciples[candidate.id]
	if not DiscipleRealmProgressV2.progression_ready(disciple):
		_check(false,"migration candidate owns canonical Realm/Body tracks")
		return false
	var birth_six := disciple.foundation_birth_values.duplicate(true)
	birth_six.erase("mind_nature")
	var quality_system := FoundationSystem.new()
	disciple.foundation_model_version = FoundationSystem.MODEL_OPEN_POINTS
	disciple.mind_nature = 0.0
	disciple.foundation_birth_values = birth_six
	disciple.disciple_quality = quality_system.quality_for_total(quality_system.total_values(
		disciple.aptitude,disciple.constitution,disciple.fortune,
		disciple.comprehension,disciple.charisma,disciple.potential
	))
	var old_profile := DiscipleRealmProgressV2.current(disciple)
	var old_stats := CombatStatsV2.derive(
		int(old_profile["cultivation"]["realm"]),int(old_profile["cultivation"]["floor"]),
		int(old_profile["body"]["realm"]),int(old_profile["body"]["floor"]),disciple.potential
	)
	disciple.max_hp = float(old_stats["stats"]["max_hp"])
	disciple.hp = disciple.max_hp*0.61
	var expected_mind := quality_system.birth_total(birth_six)/6.0
	var wire := state.to_dict()
	wire["save_version"] = 2
	var path := "user://d7_wire_v2_migration_test.json"
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null:
		_check(false,"create old wire v2 fixture")
		return false
	file.store_string(JSON.stringify(wire))
	file.close()
	var loaded := SaveService.new().load_from_path(path)
	_check(loaded != null,"old non-CARE wire v2 loads through D7 migration")
	if loaded != null:
		var restored: DiscipleState = loaded.disciples[disciple.id]
		_check(restored.foundation_model_version == FoundationSystem.MODEL_D7,"loaded old profile is model 3")
		_check(is_equal_approx(restored.mind_nature,expected_mind),"wire migration derives mind only from saved six-stat birth")
		_check(restored.foundation_birth_values["aptitude"] == birth_six["aptitude"],"wire migration preserves six-stat birth snapshot")
		var derived := DiscipleRealmProgressV2.derive_stats(restored)
		_check(bool(derived.get("ok",false)) and is_equal_approx(restored.max_hp,float(derived.get("stats",{}).get("max_hp",-1.0))),"D7 wire migration rederives HP under RealmCore-only potential saved=%s derived=%s reason=%s" % [str(restored.max_hp),str(derived.get("stats",{}).get("max_hp",-1.0)),str(derived.get("reason",""))])
		_check(is_equal_approx(restored.hp/restored.max_hp,0.61),"D7 HP migration preserves the old live HP ratio")
	var invalid_wire: Dictionary = wire.duplicate(true)
	for row in invalid_wire["disciples"]:
		if str(row.get("id","")) == str(disciple.id): row["foundation_birth_values"] = {}
	var invalid_path := "user://d7_wire_missing_provenance_test.json"
	file = FileAccess.open(invalid_path,FileAccess.WRITE)
	file.store_string(JSON.stringify(invalid_wire)); file.close()
	_check(SaveService.new().load_from_path(invalid_path) == null,"wire migration rejects missing birth provenance")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(invalid_path))
	return not failed
