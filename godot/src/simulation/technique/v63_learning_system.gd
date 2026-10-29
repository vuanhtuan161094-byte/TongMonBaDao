class_name V63LearningSystem
extends RefCounted

const CATALOGUE_PATH := "res://data/combat/v63_learning_catalog.json"
const MAX_OPERATION_ID_LENGTH := 160
const MAX_MASTERY_DELTA := 1000000.0
const VALID_SLOTS := ["main", "aux_1", "aux_2"]

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_learning_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {"ok":false,"errors":["learning_catalogue_not_object"],"data":{}}
    var data: Dictionary = parsed
    var errors := validate_catalogue(data)
    return {"ok":errors.is_empty(),"errors":errors,"data":data}

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version", -1)) != 1 or bool(data.get("enabled", true)):
        errors.append("bad_learning_schema_or_release_gate")
    if not (data.get("techniques", null) is Array) or not (data.get("mastery_thresholds_xp", null) is Array):
        errors.append("missing_learning_catalogue_arrays")
        return errors
    if str(data.get("balance_status", "")) != "candidate":
        errors.append("learning_economy_must_remain_candidate")
    var thresholds: Array = data.mastery_thresholds_xp
    if thresholds.size() != 5 or int(thresholds[0]) != 0:
        errors.append("learning_catalogue_requires_five_ordered_mastery_milestones")
    else:
        for index in range(1, thresholds.size()):
            if int(thresholds[index]) <= int(thresholds[index - 1]):
                errors.append("learning_mastery_thresholds_not_strictly_increasing")
                break
    var archive_codices: Dictionary = {}
    for raw_codex in V63SectArchiveSystem.codices():
        archive_codices[str(raw_codex.get("id", ""))] = raw_codex
    var rows: Array = data.techniques
    if rows.size() != 84:
        errors.append("wrong_v63_technique_count")
    var ids: Dictionary = {}
    for raw in rows:
        if not (raw is Dictionary):
            errors.append("learning_technique_not_object")
            continue
        var row: Dictionary = raw
        var technique_id := str(row.get("id", ""))
        var source_codex_id := str(row.get("source_codex_id", ""))
        if not _valid_content_id(technique_id) or not technique_id.begins_with("tmb.technique.") or ids.has(technique_id):
            errors.append("bad_or_duplicate_learning_technique_id:" + technique_id)
        ids[technique_id] = true
        if str(row.get("name", "")).is_empty() or not ["bow", "fist", "poison"].has(str(row.get("school", ""))):
            errors.append("bad_learning_technique_identity:" + technique_id)
        if not archive_codices.has(source_codex_id) or not bool(archive_codices.get(source_codex_id, {}).get("archivable", false)):
            errors.append("learning_source_is_not_an_archivable_codex:" + technique_id)
        if not (row.get("slot_types", null) is Array) or not row.get("slot_types", []).has("main") or not row.get("slot_types", []).has("aux"):
            errors.append("learning_technique_must_support_main_and_aux_slots:" + technique_id)
        if bool(row.get("combat_effects_enabled", true)) or str(row.get("balance_status", "")) != "candidate":
            errors.append("d3_technique_effect_or_balance_gate_invalid:" + technique_id)
        var cost = row.get("cost", {})
        if not (cost is Dictionary) or int(cost.get("contribution", -1)) < 0 or int(cost.get("spirit_stones", -1)) < 0:
            errors.append("bad_learning_candidate_cost:" + technique_id)
        if int(row.get("study_ticks", 0)) <= 0:
            errors.append("bad_learning_candidate_duration:" + technique_id)
        if not (row.get("prerequisite_technique_ids", null) is Array):
            errors.append("bad_learning_prerequisite_list:" + technique_id)
        if str(row.get("generation", "human")) == "immortal":
            var candidate_prerequisites = row.get("candidate_prerequisites", null)
            if not (candidate_prerequisites is Dictionary) or int(candidate_prerequisites.get("cultivation_realm", 0)) != 11 \
                or int(candidate_prerequisites.get("body_realm", 0)) != 11 or int(candidate_prerequisites.get("main_mastery_stage", -1)) != 3 \
                or int(candidate_prerequisites.get("human_active_skill_level", 0)) != 7 or int(candidate_prerequisites.get("human_ultimate_skill_level", 0)) != 4:
                errors.append("bad_immortal_learning_prerequisites:" + technique_id)
    for raw in rows:
        if not (raw is Dictionary):
            continue
        for prerequisite in raw.get("prerequisite_technique_ids", []):
            var prerequisite_id := str(prerequisite)
            if not ids.has(prerequisite_id) or prerequisite_id == str(raw.get("id", "")):
                errors.append("unknown_or_self_learning_prerequisite:" + str(raw.get("id", "")))
    return errors

static func techniques() -> Array[Dictionary]:
    var loaded := load_catalogue()
    var result: Array[Dictionary] = []
    if not bool(loaded.get("ok", false)):
        return result
    for raw in loaded.data.techniques:
        result.append(raw.duplicate(true))
    return result

static func definition(technique_id: StringName) -> Dictionary:
    var loaded := load_catalogue()
    if not bool(loaded.get("ok", false)):
        return {}
    for raw in loaded.data.techniques:
        if str(raw.get("id", "")) == str(technique_id):
            return raw.duplicate(true)
    return {}

static func mastery_thresholds() -> Array:
    var loaded := load_catalogue()
    return Array(loaded.data.get("mastery_thresholds_xp", [])).duplicate() if bool(loaded.get("ok", false)) else [0, 100, 400, 1000, 2500]

static func mastery_stage_for_xp(xp: float) -> int:
    var stage := 0
    var thresholds := mastery_thresholds()
    for index in range(thresholds.size()):
        if xp >= float(thresholds[index]):
            stage = index
    return stage

static func is_enabled(state: SimulationState, preview_overrides: Dictionary = {}) -> bool:
    return state != null and state.sect.v63_learning_opt_in \
        and V63FeatureGates.is_enabled("technique_learning", preview_overrides) \
        and V63SectArchiveSystem.is_enabled(state, preview_overrides)

static func has_active_job(disciple: DiscipleState) -> bool:
    return disciple != null and (disciple.active_job_id != &"" or not disciple.v63_study_job.is_empty())

func can_start_study(state: SimulationState, disciple: DiscipleState, technique_id: StringName,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state, preview_overrides):
        return _failure("technique_learning_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    var info := definition(technique_id)
    if info.is_empty():
        return _failure("unknown_v63_technique")
    if disciple.known_techniques.has(str(technique_id)):
        return _failure("already_known")
    if has_active_job(disciple):
        return _failure("another_active_job")
    var source_codex := str(info.get("source_codex_id", ""))
    if not V63SectArchiveSystem.transmission_available_for_disciple(state, disciple.id, source_codex, preview_overrides):
        return _failure("required_manual_not_archived")
    for prerequisite in info.get("prerequisite_technique_ids", []):
        if not disciple.known_techniques.has(str(prerequisite)):
            return _failure("technique_prerequisite_missing:" + str(prerequisite))
    if str(info.get("generation", "human")) == "immortal":
        var prerequisite_reason := _immortal_prerequisite_reason(disciple, info)
        if not prerequisite_reason.is_empty():
            return _failure(prerequisite_reason)
    if str(info.get("generation", "human")) == "divine":
        if not V63FeatureGates.is_enabled("divine_skill_combat", preview_overrides):
            return _failure("divine_skill_combat_disabled")
        var reason := _divine_prerequisite_reason(disciple, info)
        if not reason.is_empty():
            return _failure(reason)
    var buildings := BuildingSystem.new()
    if not disciple.active_pve_encounter_id.is_empty() or disciple.region_id != &"sect":
        return _failure("disciple_not_at_sect")
    if disciple.injury_level != 0 or disciple.hp <= 0.0:
        return _failure("disciple_not_eligible_by_life_state")
    if not [&"EVALUATE", &"IDLE", &"HOLD"].has(disciple.current_action):
        return _failure("disciple_has_conflicting_action")
    if not disciple.work_cycle_state.is_empty() \
        or buildings.disciple_has_active_spirit_plot(state, disciple.id) \
        or buildings.disciple_has_active_timed_recipe(state, disciple.id) \
        or disciple.work_group_id == &"body_training_crew" \
        or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state, disciple):
        return _failure("disciple_has_reserved_occupation")
    var cost: Dictionary = info.get("cost", {})
    if disciple.contribution_points < int(cost.get("contribution", 0)):
        return _failure("insufficient_contribution")
    if disciple.spirit_stones < int(cost.get("spirit_stones", 0)):
        return _failure("insufficient_personal_spirit_stones")
    return {"ok":true,"definition":info,"source_codex_id":source_codex,"cost":cost.duplicate(true)}

static func lineage_study_complete(disciple: DiscipleState, branch: String, lineage: String) -> bool:
    if disciple == null or lineage not in ["a", "b"]:
        return false
    var row: Dictionary = V63ImmortalSkillCombatSystem.branch_definitions().get(branch, {})
    if row.is_empty():
        return false
    var technique_id := str(row.get("lineage_technique_ids", {}).get(lineage, ""))
    return not technique_id.is_empty() and disciple.known_techniques.has(technique_id)

static func divine_lineage_stage(disciple: DiscipleState, branch: String, lineage: String) -> int:
    var row: Dictionary = V63DivineSkillCombatSystem.branch_definitions().get(branch, {})
    var ids: Array = row.get("divine_technique_ids", {}).get(lineage, [])
    var stage := 0
    for id in ids:
        if not disciple.known_techniques.has(str(id)):
            break
        stage += 1
    return stage

static func _divine_prerequisite_reason(disciple: DiscipleState, info: Dictionary) -> String:
    var stage := clampi(int(info.get("divine_stage", 1)), 1, 3)
    var realm: int = [21, 25, 29][stage - 1]
    var profile: Dictionary = disciple.v2_realm_progress
    if not DiscipleRealmProgressV2.valid_profile(profile) or maxi(int(profile.get("cultivation", {}).get("realm", 0)), int(profile.get("body", {}).get("realm", 0))) < realm:
        return "divine_realm_gate_required"
    var main := definition(disciple.active_technique_main)
    var knowledge: Dictionary = disciple.known_techniques.get(str(disciple.active_technique_main), {})
    if str(main.get("school", "")) != str(info.get("school", "")) or int(knowledge.get("mastery_stage", 0)) < 3:
        return "divine_compatible_main_mastery_3_required"
    if stage == 1:
        if str(main.get("generation", "")) != "immortal":
            return "divine_immortal_main_required"
        var ultimate := "tmb.skill.%s.%s.ultimate.immortal.%s" % [str(info.school), str(info.branch), str(info.lineage)]
        if int(disciple.v63_learned_skill_nodes.get(ultimate, {}).get("level", 0)) < 2:
            return "divine_immortal_ultimate_2_required"
    return ""

static func _immortal_prerequisite_reason(disciple: DiscipleState, info: Dictionary) -> String:
    var profile: Dictionary = disciple.v2_realm_progress
    if not DiscipleRealmProgressV2.valid_profile(profile):
        return "immortal_realm_profile_required"
    var cultivation: Dictionary = profile.get("cultivation", {})
    var body: Dictionary = profile.get("body", {})
    if int(cultivation.get("realm", 0)) < 11 and int(body.get("realm", 0)) < 11:
        return "immortal_realm_or_body_11_required"
    var school := str(info.get("school", ""))
    var main_id := str(disciple.active_technique_main)
    if main_id.is_empty() or not disciple.known_techniques.has(main_id):
        return "immortal_compatible_main_technique_required"
    var main_info := definition(StringName(main_id))
    var main_knowledge: Dictionary = disciple.known_techniques.get(main_id, {})
    if main_info.is_empty() or str(main_info.get("school", "")) != school \
        or not main_info.get("slot_types", []).has("main") or int(main_knowledge.get("mastery_stage", 0)) < 3:
        return "immortal_main_technique_mastery_stage_3_required"
    var branch := str(info.get("branch", ""))
    var active_id := "tmb.skill.%s.%s.active_01.human" % [school, branch]
    var ultimate_id := "tmb.skill.%s.%s.ultimate.human" % [school, branch]
    if not disciple.v63_learned_skill_nodes.has(active_id) or int(disciple.v63_learned_skill_nodes[active_id].get("level", 0)) < 7:
        return "human_branch_active_level_7_required"
    if not disciple.v63_learned_skill_nodes.has(ultimate_id) or int(disciple.v63_learned_skill_nodes[ultimate_id].get("level", 0)) < 4:
        return "human_branch_ultimate_level_4_required"
    return ""

func start_study(state: SimulationState, disciple: DiscipleState, technique_id: StringName,
        request_id: String, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state, preview_overrides):
        return _failure("technique_learning_disabled")
    if not _valid_operation_id(request_id):
        return _failure("invalid_request_id")
    var prior := _prior_operation(state, request_id, "study_started", str(disciple.id) if disciple != null else "", str(technique_id))
    if not prior.is_empty():
        return prior
    var check := can_start_study(state, disciple, technique_id, preview_overrides)
    if not bool(check.get("ok", false)):
        return check
    if state.sect.v63_learning_job_index >= 2147483647:
        return _failure("learning_job_index_overflow")
    var cost: Dictionary = check.cost
    var contribution_cost := int(cost.get("contribution", 0))
    var stone_cost := int(cost.get("spirit_stones", 0))
    var duration := int(check.definition.get("study_ticks", 0))
    if contribution_cost < 0 or stone_cost < 0 or duration <= 0:
        return _failure("invalid_learning_definition")
    var next_job_index := state.sect.v63_learning_job_index + 1
    var job_id := "study:%s:%06d" % [str(disciple.id), next_job_index]
    if not _valid_operation_id(job_id) or not _valid_operation_id("study:complete:" + job_id):
        return _failure("learning_job_id_too_long_or_invalid")
    state.sect.v63_learning_job_index = next_job_index
    var finish_tick := state.tick + duration
    var job := {
        "job_id":job_id,
        "technique_id":str(technique_id),
        "source_codex_id":str(check.source_codex_id),
        "start_request_id":request_id,
        "resume_action":str(disciple.current_action),
        "started_tick":state.tick,
        "finish_tick":finish_tick,
        "duration_ticks":duration,
        "progress_ticks":0,
        "last_processed_tick":state.tick,
        "reserved_cost":{"contribution":contribution_cost,"spirit_stones":stone_cost},
        "cost_committed":false
    }
    # Both personal balances are reserved atomically with the durable job receipt.
    disciple.contribution_points -= contribution_cost
    disciple.spirit_stones -= stone_cost
    disciple.active_job_id = StringName(job_id)
    disciple.v63_study_job = job
    disciple.current_action = &"STUDY"
    state.sect.v63_learning_active_jobs[str(disciple.id)] = job_id
    var receipt := {"request_id":request_id,"operation":"study_started","disciple_id":str(disciple.id),
        "technique_id":str(technique_id),"job_id":job_id,"tick":state.tick,
        "reserved_cost":{"contribution":contribution_cost,"spirit_stones":stone_cost}}
    state.sect.v63_learning_operation_receipts[request_id] = receipt
    state.sect.v63_learning_event_count += 1
    return {"ok":true,"reason":"study_started","job":job.duplicate(true),"receipt":receipt.duplicate(true)}

func cancel_study(state: SimulationState, disciple: DiscipleState, request_id: String,
        expected_job_id: String = "", preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state, preview_overrides):
        return _failure("technique_learning_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    if not _valid_operation_id(request_id):
        return _failure("invalid_request_id")
    var current_job_id := str(disciple.v63_study_job.get("job_id", ""))
    var target_job_id := expected_job_id if not expected_job_id.is_empty() else current_job_id
    if target_job_id.is_empty() and state.sect.v63_learning_operation_receipts.has(request_id):
        var old_receipt = state.sect.v63_learning_operation_receipts[request_id]
        if old_receipt is Dictionary:
            target_job_id = str(old_receipt.get("job_id", ""))
    var prior := _prior_operation(state, request_id, "study_cancelled", str(disciple.id), "", target_job_id)
    if not prior.is_empty():
        return prior
    if current_job_id.is_empty() or current_job_id != target_job_id:
        return _failure("no_matching_active_study_job")
    var job: Dictionary = disciple.v63_study_job.duplicate(true)
    if bool(job.get("cost_committed", false)):
        return _failure("study_cost_already_committed")
    var reserved: Dictionary = job.get("reserved_cost", {})
    var contribution_refund := int(reserved.get("contribution", 0))
    var stone_refund := int(reserved.get("spirit_stones", 0))
    if contribution_refund < 0 or stone_refund < 0:
        return _failure("invalid_reserved_cost")
    disciple.contribution_points += contribution_refund
    disciple.spirit_stones += stone_refund
    if disciple.active_job_id == StringName(current_job_id):
        disciple.active_job_id = &""
    if disciple.current_action == &"STUDY":
        disciple.current_action = StringName(job.get("resume_action", "EVALUATE"))
    disciple.v63_study_job.clear()
    state.sect.v63_learning_active_jobs.erase(str(disciple.id))
    var receipt := {"request_id":request_id,"operation":"study_cancelled","disciple_id":str(disciple.id),
        "technique_id":str(job.get("technique_id", "")),"job_id":current_job_id,"tick":state.tick,
        "lost_progress_ticks":int(job.get("progress_ticks", 0)),
        "refunded_cost":{"contribution":contribution_refund,"spirit_stones":stone_refund}}
    state.sect.v63_learning_operation_receipts[request_id] = receipt
    state.sect.v63_learning_event_count += 1
    return {"ok":true,"reason":"study_cancelled","receipt":receipt.duplicate(true)}

func process_tick(state: SimulationState, preview_overrides: Dictionary = {}) -> int:
    if state == null or state.sect.v63_learning_active_jobs.is_empty():
        return 0
    var learning_enabled := is_enabled(state, preview_overrides)
    var completed := 0
    var disciple_ids: Array = state.sect.v63_learning_active_jobs.keys()
    disciple_ids.sort()
    for raw_id in disciple_ids:
        var disciple_id := StringName(raw_id)
        if not state.disciples.has(disciple_id):
            continue
        var disciple: DiscipleState = state.disciples[disciple_id]
        if disciple.v63_study_job.is_empty():
            continue
        var job: Dictionary = disciple.v63_study_job.duplicate(true)
        if str(state.sect.v63_learning_active_jobs[str(disciple_id)]) != str(job.get("job_id", "")):
            continue
        var duration := int(job.get("duration_ticks", 0))
        if duration <= 0:
            continue
        var previous_tick := int(job.get("last_processed_tick", job.get("started_tick", state.tick)))
        if state.tick <= previous_tick:
            continue
        var elapsed := clampi(int(job.get("progress_ticks", 0)), 0, duration)
        if learning_enabled:
            elapsed = mini(elapsed + state.tick - previous_tick, duration)
        job["progress_ticks"] = elapsed
        job["last_processed_tick"] = state.tick
        job["finish_tick"] = state.tick + maxi(duration - elapsed, 0)
        disciple.v63_study_job = job
        if learning_enabled and duration > 0 and elapsed >= duration:
            var result := _complete_study(state, disciple, job)
            if bool(result.get("ok", false)):
                completed += 1
    return completed

func equip_slot(state: SimulationState, disciple: DiscipleState, slot: String, technique_id: StringName,
        preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state, preview_overrides):
        return _failure("technique_learning_disabled")
    if disciple == null or not state.disciples.has(disciple.id) or not disciple.active_pve_encounter_id.is_empty():
        return _failure("disciple_unavailable")
    if not VALID_SLOTS.has(slot):
        return _failure("invalid_technique_slot")
    var normalized_id := str(technique_id)
    if not normalized_id.is_empty():
        var info := definition(technique_id)
        if info.is_empty() or not disciple.known_techniques.has(normalized_id):
            return _failure("technique_not_known")
        var slot_kind := "main" if slot == "main" else "aux"
        if not info.get("slot_types", []).has(slot_kind):
            return _failure("technique_not_allowed_in_slot")
        if _is_equipped_in_other_slot(disciple, normalized_id, slot):
            return _failure("technique_already_equipped")
    match slot:
        "main": disciple.active_technique_main = technique_id
        "aux_1": disciple.active_technique_aux[0] = normalized_id
        "aux_2": disciple.active_technique_aux[1] = normalized_id
    return {"ok":true,"reason":"loadout_updated","slot":slot,"technique_id":normalized_id}

func record_mastery_event(state: SimulationState, disciple: DiscipleState, technique_id: StringName,
        event_id: String, xp_delta: float, preview_overrides: Dictionary = {}) -> Dictionary:
    if not is_enabled(state, preview_overrides):
        return _failure("technique_learning_disabled")
    if disciple == null or not state.disciples.has(disciple.id):
        return _failure("unknown_disciple")
    if not _valid_operation_id(event_id) or not _valid_operation_id("mastery:" + event_id) \
        or not is_finite(xp_delta) or xp_delta <= 0.0 or xp_delta > MAX_MASTERY_DELTA:
        return _failure("invalid_mastery_event")
    var request_id := "mastery:%s" % event_id
    var prior := _prior_operation(state, request_id, "mastery_recorded", str(disciple.id), str(technique_id), "", xp_delta)
    if not prior.is_empty():
        return prior
    var key := str(technique_id)
    if definition(technique_id).is_empty() or not disciple.known_techniques.has(key):
        return _failure("technique_not_known")
    var record: Dictionary = disciple.known_techniques[key].duplicate(true)
    var old_xp := float(record.get("mastery_xp", 0.0))
    if not is_finite(old_xp) or old_xp < 0.0 or old_xp > 1.0e12 - xp_delta:
        return _failure("mastery_xp_overflow")
    var new_xp := old_xp + xp_delta
    var new_stage := mastery_stage_for_xp(new_xp)
    record["mastery_xp"] = new_xp
    record["mastery_stage"] = new_stage
    disciple.known_techniques[key] = record
    var receipt := {"request_id":request_id,"operation":"mastery_recorded","disciple_id":str(disciple.id),
        "technique_id":key,"xp_delta":xp_delta,"mastery_xp":new_xp,"mastery_stage":new_stage,"tick":state.tick}
    state.sect.v63_learning_operation_receipts[request_id] = receipt
    state.sect.v63_learning_event_count += 1
    return {"ok":true,"reason":"mastery_recorded","receipt":receipt.duplicate(true)}

static func study_progress(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if state == null or disciple == null or disciple.v63_study_job.is_empty():
        return {"active":false,"progress":0.0,"remaining_ticks":0,"job":{}}
    var job: Dictionary = disciple.v63_study_job
    var duration := maxi(int(job.get("duration_ticks", 0)), 1)
    var elapsed := clampi(int(job.get("progress_ticks", 0)), 0, duration)
    return {"active":true,"progress":float(elapsed) / float(duration),
        "remaining_ticks":maxi(duration - elapsed, 0),
        "job":job.duplicate(true)}

static func validate_state(state: SimulationState) -> Array[String]:
    var errors: Array[String] = []
    if state == null:
        errors.append("V6.3 learning state is missing.")
        return errors
    var loaded := load_catalogue()
    if not bool(loaded.get("ok", false)):
        errors.append("V6.3 learning catalogue is invalid.")
        return errors
    if state.sect.v63_learning_job_index < 0 or state.sect.v63_learning_event_count < 0:
        errors.append("V6.3 learning counter is negative.")
    var definitions: Dictionary = {}
    for raw in loaded.data.techniques:
        definitions[str(raw.get("id", ""))] = raw
    var mapped_jobs: Dictionary = {}
    var seen_job_ids: Dictionary = {}
    for raw_id in state.sect.v63_learning_active_jobs.keys():
        var disciple_id := str(raw_id)
        var job_id := str(state.sect.v63_learning_active_jobs[raw_id])
        if not state.disciples.has(StringName(disciple_id)):
            errors.append("Learning job index references a missing disciple %s." % disciple_id)
            continue
        var owner: DiscipleState = state.disciples[StringName(disciple_id)]
        if owner.v63_study_job.is_empty() or str(owner.v63_study_job.get("job_id", "")) != job_id:
            errors.append("Learning job index does not match disciple state %s." % disciple_id)
        mapped_jobs[disciple_id] = job_id
    for raw_d in state.disciples.keys():
        var disciple: DiscipleState = state.disciples[raw_d]
        var seen_slots: Dictionary = {}
        var main_id := str(disciple.active_technique_main)
        if not main_id.is_empty():
            if not disciple.known_techniques.has(main_id):
                errors.append("Unknown main technique is equipped for %s." % disciple.id)
            seen_slots[main_id] = true
        if disciple.active_technique_aux.size() != 2:
            errors.append("Auxiliary technique slots must remain exactly two for %s." % disciple.id)
        for raw_aux in disciple.active_technique_aux:
            var aux_id := str(raw_aux)
            if aux_id.is_empty():
                continue
            if not disciple.known_techniques.has(aux_id):
                errors.append("Unknown auxiliary technique is equipped for %s." % disciple.id)
            if seen_slots.has(aux_id):
                errors.append("A technique is equipped more than once for %s." % disciple.id)
            seen_slots[aux_id] = true
        for raw_technique_id in disciple.known_techniques.keys():
            var technique_id := str(raw_technique_id)
            var row = disciple.known_techniques[raw_technique_id]
            if not definitions.has(technique_id) or not (row is Dictionary):
                errors.append("Unknown or malformed known technique %s for %s." % [technique_id, disciple.id])
                continue
            var xp := float(row.get("mastery_xp", -1.0))
            var stage := int(row.get("mastery_stage", -1))
            if not is_finite(xp) or xp < 0.0 or stage != mastery_stage_for_xp(xp):
                errors.append("Invalid personal mastery for %s on %s." % [disciple.id, technique_id])
            var source_codex_id := str(row.get("source_codex_id", ""))
            if source_codex_id != str(definitions[technique_id].get("source_codex_id", "")) \
                or not bool(state.sect.v63_archived_codices.get(source_codex_id, false)):
                errors.append("Known technique lost its archived manual source for %s." % technique_id)
        if not disciple.v63_study_job.is_empty():
            var job: Dictionary = disciple.v63_study_job
            var job_id := str(job.get("job_id", ""))
            var technique_id := str(job.get("technique_id", ""))
            var start_request_id := str(job.get("start_request_id", ""))
            if not definitions.has(technique_id) or not _valid_operation_id(job_id) or not _valid_operation_id(start_request_id):
                errors.append("Malformed active study job for %s." % disciple.id)
            else:
                if disciple.current_action != &"STUDY" or not [&"EVALUATE", &"IDLE", &"HOLD"].has(StringName(job.get("resume_action", ""))):
                    errors.append("Study does not own the disciple action for %s." % disciple.id)
                if seen_job_ids.has(job_id):
                    errors.append("Duplicate active study job id %s." % job_id)
                seen_job_ids[job_id] = true
                var started := int(job.get("started_tick", -1))
                var finish := int(job.get("finish_tick", -1))
                var duration := int(job.get("duration_ticks", 0))
                var progress := int(job.get("progress_ticks", -1))
                var reserved = job.get("reserved_cost", {})
                var last_processed := int(job.get("last_processed_tick", started))
                if started < 0 or finish < started or duration <= 0 or progress < 0 or progress >= duration or last_processed < started or last_processed > state.tick \
                    or not (reserved is Dictionary) or int(reserved.get("contribution", -1)) < 0 or int(reserved.get("spirit_stones", -1)) < 0 \
                    or bool(job.get("cost_committed", true)):
                    errors.append("Invalid active study job timing/cost for %s." % disciple.id)
                if str(job.get("source_codex_id", "")) != str(definitions[technique_id].get("source_codex_id", "")):
                    errors.append("Active study job source mismatch for %s." % disciple.id)
                var start_receipt = state.sect.v63_learning_operation_receipts.get(start_request_id, {})
                if not (start_receipt is Dictionary) or str(start_receipt.get("operation", "")) != "study_started" \
                    or str(start_receipt.get("job_id", "")) != job_id:
                    errors.append("Active study job has no start receipt for %s." % disciple.id)
                if str(state.sect.v63_learning_active_jobs.get(str(disciple.id), "")) != job_id:
                    errors.append("Active study job is missing from the One Active Job index for %s." % disciple.id)
                if str(disciple.active_job_id) != job_id:
                    errors.append("Disciple active job id does not match study for %s." % disciple.id)
                if not disciple.active_pve_encounter_id.is_empty() or not disciple.work_cycle_state.is_empty():
                    errors.append("Study overlaps a PvE or active work cycle for %s." % disciple.id)
                var buildings := BuildingSystem.new()
                if buildings.disciple_has_active_spirit_plot(state, disciple.id) or buildings.disciple_has_active_timed_recipe(state, disciple.id) or DiscipleBodyTrainingFacilityV2.has_reserved_slot(state, disciple):
                    errors.append("Study overlaps another reserved occupation for %s." % disciple.id)
                mapped_jobs[str(disciple.id)] = job_id
        elif disciple.active_job_id != &"":
            errors.append("Disciple active job id has no D3 study record for %s." % disciple.id)
        elif disciple.current_action == &"STUDY":
            errors.append("Study action has no active D3 job for %s." % disciple.id)
        if state.sect.v63_learning_active_jobs.has(str(disciple.id)) and disciple.v63_study_job.is_empty():
            errors.append("One Active Job index has stale study entry for %s." % disciple.id)
    var valid_operations := ["study_started", "study_cancelled", "study_completed", "mastery_recorded"]
    for raw_request_id in state.sect.v63_learning_operation_receipts.keys():
        var request_id := str(raw_request_id)
        var receipt = state.sect.v63_learning_operation_receipts[raw_request_id]
        if not _valid_operation_id(request_id) or not (receipt is Dictionary) or str(receipt.get("operation", "")) not in valid_operations:
            errors.append("Invalid learning operation receipt %s." % request_id)
            continue
        if str(receipt.get("request_id", "")) != request_id:
            errors.append("Learning receipt key mismatch %s." % request_id)
        if not state.disciples.has(StringName(str(receipt.get("disciple_id", "")))):
            errors.append("Learning receipt references a missing disciple %s." % request_id)
        var technique_id := str(receipt.get("technique_id", ""))
        if not definitions.has(technique_id):
            errors.append("Learning receipt references an unknown technique %s." % request_id)
        if str(receipt.get("operation", "")) == "study_completed":
            var owner: DiscipleState = state.disciples.get(StringName(str(receipt.get("disciple_id", ""))))
            if owner == null or not owner.known_techniques.has(technique_id):
                errors.append("Completed study receipt did not grant personal knowledge %s." % request_id)
    if state.sect.v63_learning_active_jobs.size() != mapped_jobs.size():
        errors.append("Learning active-job index size does not match disciple jobs.")
    return errors

func _complete_study(state: SimulationState, disciple: DiscipleState, job: Dictionary) -> Dictionary:
    var job_id := str(job.get("job_id", ""))
    var technique_id := str(job.get("technique_id", ""))
    var request_id := "study:complete:" + job_id
    var prior := _prior_operation(state, request_id, "study_completed", str(disciple.id), technique_id, job_id)
    if not prior.is_empty():
        return prior
    if definition(StringName(technique_id)).is_empty() or disciple.known_techniques.has(technique_id):
        return _failure("study_completion_conflict")
    var source_codex_id := str(job.get("source_codex_id", ""))
    if not bool(state.sect.v63_archived_codices.get(source_codex_id, false)):
        return _failure("required_manual_transmission_missing")
    var cost: Dictionary = job.get("reserved_cost", {})
    if int(job.get("progress_ticks", 0)) < int(job.get("duration_ticks", 0)) or bool(job.get("cost_committed", true)):
        return _failure("study_not_ready_or_cost_committed")
    # Knowledge and the cost commit share this saved completion receipt. The reserved
    # personal balances were deducted at start and are never charged a second time.
    disciple.known_techniques[technique_id] = {
        "mastery_xp":0.0,
        "mastery_stage":0,
        "learned_tick":state.tick,
        "source_codex_id":source_codex_id
    }
    job["cost_committed"] = true
    var receipt := {"request_id":request_id,"operation":"study_completed","disciple_id":str(disciple.id),
        "technique_id":technique_id,"job_id":job_id,"tick":state.tick,
        "committed_cost":cost.duplicate(true)}
    state.sect.v63_learning_operation_receipts[request_id] = receipt
    state.sect.v63_learning_active_jobs.erase(str(disciple.id))
    if disciple.active_job_id == StringName(job_id):
        disciple.active_job_id = &""
    if disciple.current_action == &"STUDY":
        disciple.current_action = StringName(job.get("resume_action", "EVALUATE"))
    disciple.v63_study_job.clear()
    state.sect.v63_learning_event_count += 1
    return {"ok":true,"reason":"study_completed","receipt":receipt.duplicate(true)}

func _prior_operation(state: SimulationState, request_id: String, operation: String,
        disciple_id: String, technique_id: String = "", job_id: String = "", xp_delta: float = -1.0) -> Dictionary:
    if not state.sect.v63_learning_operation_receipts.has(request_id):
        return {}
    var receipt = state.sect.v63_learning_operation_receipts[request_id]
    if not (receipt is Dictionary) or str(receipt.get("operation", "")) != operation \
        or str(receipt.get("disciple_id", "")) != disciple_id:
        return _failure("request_id_collision")
    if not technique_id.is_empty() and str(receipt.get("technique_id", "")) != technique_id:
        return _failure("request_id_collision")
    if not job_id.is_empty() and str(receipt.get("job_id", "")) != job_id:
        return _failure("request_id_collision")
    if xp_delta >= 0.0 and absf(float(receipt.get("xp_delta", -1.0)) - xp_delta) > 0.000001:
        return _failure("request_id_collision")
    return {"ok":true,"reason":"already_committed","duplicate":true,"receipt":receipt.duplicate(true)}

func _is_equipped_in_other_slot(disciple: DiscipleState, technique_id: String, slot: String) -> bool:
    if slot != "main" and str(disciple.active_technique_main) == technique_id:
        return true
    for index in range(disciple.active_technique_aux.size()):
        var other_slot := "aux_1" if index == 0 else "aux_2"
        if other_slot != slot and str(disciple.active_technique_aux[index]) == technique_id:
            return true
    return false

static func _valid_operation_id(value: String) -> bool:
    if value.is_empty() or value.length() > MAX_OPERATION_ID_LENGTH:
        return false
    for ch in value:
        if not "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:._-".contains(ch):
            return false
    return true

static func _valid_content_id(value: String) -> bool:
    if not value.begins_with("tmb.") or value.ends_with(".") or value.find("..") >= 0:
        return false
    for ch in value:
        if not "abcdefghijklmnopqrstuvwxyz0123456789_.".contains(ch):
            return false
    return true

static func _failure(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}

