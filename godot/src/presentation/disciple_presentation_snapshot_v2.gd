class_name DisciplePresentationSnapshotV2
extends RefCounted

# DV2-03 Step 2 presentation read-model.
#
# This object never owns gameplay truth and never mutates SimulationState.
# It normalizes the canonical persisted/runtime authorities into one snapshot
# that presentation can consume without re-deriving V2 rules in UI scripts.
#
# Authentic V2 characters NEVER fall back to P2 cultivation/combat/innate
# authority. Legacy characters receive an explicit compatibility snapshot.

const VERSION := 1

const FOUNDATION_KEYS := [
    "aptitude","constitution","mind_nature","potential","comprehension","fortune","charisma"
]
const FOUNDATION_LABELS := {
    "aptitude":"Tư Chất",
    "constitution":"Căn Cốt",
    "mind_nature":"Tâm Tính",
    "potential":"Tiềm Lực",
    "comprehension":"Thông Tuệ",
    "fortune":"Cơ Duyên",
    "charisma":"Mị Lực"
}
const ROOT_NAMES := {
    "metal":"Kim","wood":"Mộc","water":"Thủy","fire":"Hỏa","earth":"Thổ"
}
const MUTATION_NAMES := {
    "lightning":"Lôi","wind":"Phong","ice":"Băng","yang":"Dương","nether":"U Minh"
}
const BLOODLINE_NAMES := {
    "chan_long_huyet":"Chân Long Huyết",
    "phuong_hoang_huyet":"Phượng Hoàng Huyết",
    "bach_ho_huyet":"Bạch Hổ Huyết",
    "huyen_vu_huyet":"Huyền Vũ Huyết",
    "thao_thiet_tan_huyet":"Thao Thiết Tàn Huyết"
}
const PHYSIQUE_NAMES := {
    "kim_cuong_ba_the":"Kim Cương Bá Thể",
    "han_am_the":"Hàn Âm Thể",
    "hoa_linh_the":"Hỏa Linh Thể",
    "sinh_co_linh_the":"Sinh Cơ Linh Thể",
    "truong_sinh_the":"Trường Sinh Thể",
    "tu_la_chien_the":"Tu La Chiến Thể",
    "huyet_sat_chi_the":"Huyết Sát Chi Thể",
    "ngu_hanh_dao_the":"Ngũ Hành Đạo Thể",
    "van_doc_linh_the":"Vạn Độc Linh Thể",
    "huyen_nguyet_linh_the":"Huyền Nguyệt Linh Thể",
    "dau_chien_chi_the":"Đấu Chiến Chi Thể",
    "khong_linh_hu_the":"Không Linh Hư Thể",
    "van_phap_dao_the":"Vạn Pháp Đạo Thể",
    "vo_cau_dao_the":"Vô Cấu Đạo Thể"
}
const PROFESSION_TALENT_NAMES := {
    "forge_talent":"Thiên phú Luyện Khí",
    "miner_instinct":"Thiên phú Khai Khoáng",
    "herbalist_affinity":"Thiên phú Linh Thực"
}

static func build(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    if state == null or disciple == null:
        return {"ok":false,"reason":"snapshot_actor_missing"}
    if not state.disciples.has(disciple.id) or state.disciples[disciple.id] != disciple:
        return {"ok":false,"reason":"snapshot_actor_not_owned_by_state"}

    var authentic_v2 := DiscipleRealmProgressV2.owns_v2_progression(disciple)
    var result := {
        "ok":true,
        "version":VERSION,
        "disciple_id":str(disciple.id),
        "display_name":disciple.display_name,
        "authority":"authentic_v2" if authentic_v2 else "legacy_compatibility",
        "authentic_v2":authentic_v2,
        "identity":_identity(disciple),
        "foundations":_foundations(disciple),
        "life":_life(state,disciple),
        "work":_work(state,disciple),
        "learning":_learning(disciple),
        "v63":_v63_projection(state,disciple),
        "equipment":_equipment(state,disciple,authentic_v2),
        "relationships":_relationships(state,disciple),
        "metrics":disciple.metrics.duplicate(true)
    }

    if authentic_v2:
        result["innate"] = _v2_innate(disciple)
        result["progression"] = _v2_progression(disciple)
        result["combat"] = _v2_combat(disciple)
    else:
        result["innate"] = _legacy_innate(state,disciple)
        result["progression"] = _legacy_progression(disciple)
        result["combat"] = _legacy_combat(disciple)
    return result

static func _identity(disciple: DiscipleState) -> Dictionary:
    var quality_id := str(disciple.disciple_quality)
    var quality_name := quality_id
    if not quality_id.is_empty():
        quality_name = str(DiscipleGeneratorV2.QUALITY_NAMES.get(quality_id,quality_id))
    return {
        "profile_seed":disciple.profile_seed,
        "recruitment_source":str(disciple.recruitment_source),
        "race_id":str(disciple.race_id),
        "sex_id":str(disciple.sex_id),
        "origin_id":str(disciple.origin_id),
        "quality_id":quality_id,
        "quality_name":quality_name,
        "age":disciple.age,
        "base_lifespan":disciple.base_lifespan,
        "max_lifespan":disciple.max_lifespan,
        "personality_id":str(disciple.personality_id),
        "sect_rank":str(disciple.sect_rank)
    }

static func _foundations(disciple: DiscipleState) -> Dictionary:
    var current := {
        "aptitude":disciple.aptitude,
        "constitution":disciple.constitution,
        "mind_nature":disciple.mind_nature,
        "potential":disciple.potential,
        "comprehension":disciple.comprehension,
        "fortune":disciple.fortune,
        "charisma":disciple.charisma
    }
    var birth: Dictionary = {}
    for key in FOUNDATION_KEYS:
        if disciple.foundation_birth_values.has(key):
            birth[key] = float(disciple.foundation_birth_values[key])
    var delta: Dictionary = {}
    for key in FOUNDATION_KEYS:
        if birth.has(key):
            delta[key] = float(current[key])-float(birth[key])
    var result := {
        "model_version":disciple.foundation_model_version,
        "current":current,
        "birth":birth,
        "delta":delta,
        "labels":FOUNDATION_LABELS.duplicate(true)
    }
    if disciple.foundation_model_version >= FoundationSystem.MODEL_D7:
        result["tam_can"] = ["aptitude","constitution","mind_nature"]
        result["tu_tinh"] = ["potential","comprehension","fortune","charisma"]
        result["quality_birth_total"] = FoundationSystem.new().birth_total(birth)*(6.0/7.0)
        result["quality_current_total"] = FoundationSystem.new().total_disciple(disciple)
        result["quality_birth_id"] = str(FoundationSystem.new().quality_for_total(float(result["quality_birth_total"])))
        result["quality_current_id"] = str(FoundationSystem.new().quality_for_total(float(result["quality_current_total"])))
        result["mind_nature_effect"] = "not_implemented"
    return result

static func _life(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var ratio := 0.0
    if disciple.max_hp > 0.0:
        ratio = clampf(disciple.hp/disciple.max_hp,0.0,1.0)
    return {
        "hp":disciple.hp,
        "max_hp":disciple.max_hp,
        "hp_ratio":ratio,
        "injury_level":disciple.injury_level,
        "injury_remaining_ticks":maxi(0,disciple.injury_recover_at_tick-state.tick) if disciple.injury_level == 1 else 0,
        "in_v2_pve":not disciple.active_pve_encounter_id.is_empty(),
        # User lock: this is expedition stamina for V2, not ordinary-work fuel.
        "expedition_stamina":disciple.stamina,
        "wallet":disciple.wallet,
        "contribution_points":disciple.contribution_points,
        "personal_spirit_stones":disciple.spirit_stones,
        "current_action":str(disciple.current_action),
        "region_id":str(disciple.region_id),
        "target_region_id":str(disciple.target_region_id),
        "active_job_id":str(disciple.active_job_id)
    }

static func _work(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var workforce := WorkforceSystem.new()
    var professions: Dictionary = {}
    var ids: Array = WorkforceSystem.VALID_PROFESSIONS.duplicate()
    ids.sort_custom(func(a,b): return str(a) < str(b))
    for raw_id in ids:
        var profession_id := StringName(raw_id)
        var key := str(profession_id)
        professions[key] = {
            "xp":float(disciple.profession_xp.get(key,0.0)),
            "level":workforce.profession_level_for_state(state,disciple,profession_id),
            "preference":int(disciple.work_preferences.get(key,0)),
            "progress":float(disciple.work_progress.get(key,0.0))
        }
    var talents: Array = []
    var talent_ids: Array = disciple.profession_trait_grades.keys()
    talent_ids.sort()
    for raw_id in talent_ids:
        var id := str(raw_id)
        if not PROFESSION_TALENT_NAMES.has(id):
            continue
        talents.append({
            "id":id,
            "name":str(PROFESSION_TALENT_NAMES[id]),
            "grade":int(disciple.profession_trait_grades[id])
        })
    return {
        "group_id":str(disciple.work_group_id),
        "worksite_building_id":str(disciple.worksite_building_id),
        "direct_command":disciple.direct_command.duplicate(true),
        "cycle_state":disciple.work_cycle_state.duplicate(true),
        "professions":professions,
        "profession_talents":talents
    }

static func _learning(disciple: DiscipleState) -> Dictionary:
    return {
        # These are persisted compatibility/runtime records. Their V2 effect
        # consumers are not implied merely because the records exist.
        "learned_techniques":disciple.learned_techniques.duplicate(true),
        "active_technique_id":str(disciple.active_technique_id),
        "cultivation_path_xp":disciple.cultivation_path_xp.duplicate(true),
        "learned_combat_skills":disciple.learned_combat_skills.duplicate(true)
    }

static func _v63_projection(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var preview_overrides := V63FeatureGates.persisted_preview_overrides(state)
    var aux: Array = disciple.active_technique_aux
    return {
        "feature_gates":{
            "sect_codex":V63SectArchiveSystem.is_enabled(state,preview_overrides),
            "technique_learning":V63LearningSystem.is_enabled(state,preview_overrides),
            "human_skill_combat":V63FeatureGates.is_enabled("human_skill_combat",preview_overrides),
            "divine_skill_combat":V63FeatureGates.is_enabled("divine_skill_combat",preview_overrides)
        },
        "known_techniques":disciple.known_techniques.duplicate(true),
        "archived_codices":state.sect.v63_archived_codices.duplicate(true),
        "loadout":{
            "main":str(disciple.active_technique_main),
            "aux_1":str(aux[0]) if aux.size() > 0 else "",
            "aux_2":str(aux[1]) if aux.size() > 1 else ""
        },
        "study":V63LearningSystem.study_progress(state,disciple)
    }


static func _equipment(
    state: SimulationState, disciple: DiscipleState, authentic_v2: bool
) -> Dictionary:
    var items: Array = []
    var slots: Array = disciple.equipped_items.keys()
    slots.sort()
    for raw_slot in slots:
        var slot := str(raw_slot)
        var item_id := str(disciple.equipped_items[raw_slot])
        var item_data: Dictionary = {}
        var raw_item = state.sect.equipment_items.get(item_id,{})
        if raw_item is Dictionary:
            item_data = raw_item.duplicate(true)
        items.append({
            "slot":slot,
            "item_id":item_id,
            "item":item_data,
            "locked":bool(disciple.locked_equipment_slots.get(slot,false))
        })
    return {
        "authority":"legacy_compatibility" if authentic_v2 else "legacy",
        "v2_consumer_ready":false if authentic_v2 else true,
        "items":items,
        "equipped_item_ids":disciple.equipped_items.duplicate(true),
        "locked_slots":disciple.locked_equipment_slots.duplicate(true)
    }

static func _relationships(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    var rows: Array = []
    var raw_map = state.relationships.get(str(disciple.id),{})
    if raw_map is Dictionary:
        var ids: Array = raw_map.keys()
        ids.sort()
        for raw_target in ids:
            var relation = raw_map[raw_target]
            if not (relation is RelationshipState):
                continue
            var target_id := str(raw_target)
            var target_name := target_id
            if state.disciples.has(StringName(target_id)):
                target_name = (state.disciples[StringName(target_id)] as DiscipleState).display_name
            rows.append({
                "target_id":target_id,
                "target_name":target_name,
                "affinity":relation.affinity,
                "trust":relation.trust,
                "respect":relation.respect,
                "interactions":relation.interactions
            })
    var companion_id := str(state.companion_assignments.get(str(disciple.id),""))
    var companion_name := ""
    if not companion_id.is_empty() and state.disciples.has(StringName(companion_id)):
        companion_name = (state.disciples[StringName(companion_id)] as DiscipleState).display_name
    return {
        "rows":rows,
        "companion_id":companion_id,
        "companion_name":companion_name
    }

static func _v2_innate(disciple: DiscipleState) -> Dictionary:
    var layers: Dictionary = disciple.v2_birth_profile["layers"]
    var root: Dictionary = layers["spiritual_root"]
    var mutation: Dictionary = layers["root_mutation"]
    var traits: Dictionary = layers["traits"]
    var bloodline: Dictionary = layers["bloodline"]
    var physique: Dictionary = layers["physique"]
    var destiny: Dictionary = layers["destiny"]
    var talent: Dictionary = layers["profession_talent"]

    var visible_traits: Array = []
    for raw_trait in traits.get("visible",[]):
        if not (raw_trait is Dictionary):
            continue
        var trait_id := str(raw_trait.get("id",""))
        visible_traits.append({
            "id":trait_id,
            "name":_trait_name(trait_id),
            "nature":str(raw_trait.get("nature","")),
            "origin":str(raw_trait.get("origin","birth")),
            "effect_status":"identity_only"
        })

    var talent_rows: Array = []
    var talents = talent.get("talents",{})
    if talents is Dictionary:
        var talent_ids: Array = talents.keys()
        talent_ids.sort()
        for raw_id in talent_ids:
            var talent_id := str(raw_id)
            talent_rows.append({
                "id":talent_id,
                "name":str(PROFESSION_TALENT_NAMES.get(talent_id,talent_id)),
                "grade":int(talents[raw_id])
            })

    return {
        "authority":"v2_birth_profile",
        "spiritual_root":{
            "birth_values":_named_root_values(root.get("birth_values",{})),
            "current_values":_named_root_values(root.get("current_values",{})),
            "mutation":_sanitized_mutation(mutation),
            "effect_status":"identity_only"
        },
        # Latent traits are intentionally absent from a UI-facing snapshot.
        "traits":{
            "visible":visible_traits,
            "effect_status":"identity_only"
        },
        "profession_talents":talent_rows,
        "bloodline":_sanitized_bloodline(bloodline),
        "physique":_sanitized_physique(physique),
        "destiny":_sanitized_destiny(destiny),
        "consumer_status":{
            "spiritual_root":"identity_only",
            "traits":"identity_only",
            "bloodline":"identity_only",
            "physique":"identity_only",
            "destiny":"identity_only"
        }
    }

static func _named_root_values(value: Variant) -> Dictionary:
    var rows: Dictionary = {}
    if not (value is Dictionary):
        return rows
    var ids: Array = value.keys()
    ids.sort()
    for raw_id in ids:
        var id := str(raw_id)
        rows[id] = {
            "name":str(ROOT_NAMES.get(id,id)),
            "purity":int(value[raw_id])
        }
    return rows

static func _sanitized_mutation(row: Dictionary) -> Dictionary:
    var mutation_id := str(row.get("mutation_id","none"))
    if mutation_id == "none":
        return {"status":"none","revealed":false}
    if not bool(row.get("revealed",false)):
        # Do not expose latent ID, element, realm or provenance.
        return {"status":"unrevealed","revealed":false}
    return {
        "status":"revealed",
        "revealed":true,
        "id":mutation_id,
        "name":str(MUTATION_NAMES.get(mutation_id,mutation_id)),
        "base_element":str(row.get("base_element","")),
        "realm":str(row.get("mutation_realm","")),
        "effect_status":"identity_only"
    }

static func _sanitized_bloodline(row: Dictionary) -> Dictionary:
    var id := str(row.get("bloodline_id","none"))
    if id == "none":
        return {"status":"none","revealed":false,"effect_status":"none"}
    if not bool(row.get("revealed",false)):
        return {"status":"unrevealed","revealed":false,"effect_status":"identity_only"}
    return {
        "status":"revealed",
        "revealed":true,
        "id":id,
        "name":str(BLOODLINE_NAMES.get(id,id)),
        "birth_purity":int(row.get("birth_purity",0)),
        "current_purity":int(row.get("current_purity",0)),
        "awakened":bool(row.get("awakened",false)),
        "effect_status":"identity_only"
    }

static func _sanitized_physique(row: Dictionary) -> Dictionary:
    var id := str(row.get("physique_id","none"))
    if id == "none":
        return {"status":"none","revealed":false,"effect_status":"none"}
    if not bool(row.get("revealed",false)):
        return {"status":"unrevealed","revealed":false,"effect_status":"identity_only"}
    return {
        "status":"revealed",
        "revealed":true,
        "id":id,
        "name":str(PHYSIQUE_NAMES.get(id,id)),
        "effect_status":"identity_only"
    }

static func _sanitized_destiny(row: Dictionary) -> Dictionary:
    var id := str(row.get("destiny_id","none"))
    if id == "none":
        return {"status":"none","revealed":false,"effect_status":"none"}
    if not bool(row.get("revealed",false)):
        return {"status":"unrevealed","revealed":false,"effect_status":"identity_only"}
    return {
        "status":"revealed",
        "revealed":true,
        "id":id,
        "name":_fate_name(id),
        "effect_status":"identity_only"
    }

static func _trait_name(trait_id: String) -> String:
    for row in DiscipleBirthCatalogueV2.TRAITS:
        if row is Array and row.size() >= 2 and str(row[0]) == trait_id:
            return str(row[1])
    return trait_id

static func _fate_name(fate_id: String) -> String:
    for row in DiscipleBirthCatalogueV2.FATES:
        if row is Array and row.size() >= 2 and str(row[0]) == fate_id:
            return str(row[1])
    return fate_id

static func _v2_progression(disciple: DiscipleState) -> Dictionary:
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {
            "authority":"v2_realm_progress",
            "ready":false,
            "reason":"v2_realm_profile_not_ready"
        }
    var current := DiscipleRealmProgressV2.current(disciple)
    if not bool(current.get("ok",false)):
        return {
            "authority":"v2_realm_progress",
            "ready":false,
            "reason":str(current.get("reason","v2_realm_profile_not_ready"))
        }
    var profile: Dictionary = disciple.v2_realm_progress
    return {
        "authority":"v2_realm_progress",
        "ready":true,
        "training_policy":str(profile.get("training_policy","balanced")),
        "cultivation":_v2_track("cultivation",current["cultivation"]),
        "body":_v2_track("body",current["body"])
    }

static func _v2_track(track: String, row: Dictionary) -> Dictionary:
    var realm := int(row["realm"])
    var floor_index := int(row["floor"])
    var required := DiscipleProgressionBalanceV2.floor_cost(realm,floor_index)
    var xp := float(row["xp"])
    var at_gate := floor_index == DiscipleRealmProgressV2.MAX_FLOOR and xp+0.0000001 >= float(required)
    var result := {
        "realm":realm,
        "floor":floor_index,
        "global_floor":DiscipleRealmProgressV2.global_floor(realm,floor_index),
        "name":DiscipleRealmProgressV2.realm_name(track,realm),
        "xp":xp,
        "required_xp":required,
        "progress_ratio":clampf(xp/maxf(float(required),1.0),0.0,1.0),
        "at_major_gate":at_gate,
        "gate_failures":int(row.get("gate_failures",0)),
        "lifetime_failures":int(row.get("lifetime_failures",0)),
        "auto_breakthrough":bool(row.get("auto_breakthrough",false))
    }
    if track == "cultivation":
        var base := DiscipleBreakthroughBalanceV2.cultivation_base_chance(realm)
        result["gate_mode"] = "chance" if realm < DiscipleRealmProgressV2.MAX_REALM else "ceiling"
        result["base_breakthrough_chance"] = maxf(base,0.0)
        result["effective_breakthrough_chance"] = (
            clampf(base+0.05*float(result["gate_failures"]),0.0,1.0)
            if base >= 0.0 else 0.0
        )
    else:
        result["gate_mode"] = (
            DiscipleBreakthroughBalanceV2.BODY_GATE_MODE
            if realm < DiscipleRealmProgressV2.MAX_REALM else "ceiling"
        )
    return result

static func _v2_combat(disciple: DiscipleState) -> Dictionary:
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {
            "authority":"combat_stats_v2",
            "ready":false,
            "reason":"v2_realm_profile_not_ready"
        }
    # Step 2 intentionally supplies no innate/equipment sources: those V2
    # consumers are later phases. This is the canonical Realm+Body+Potential core.
    var derived := DiscipleRealmProgressV2.derive_stats(disciple,[])
    if not bool(derived.get("ok",false)):
        return {
            "authority":"combat_stats_v2",
            "ready":false,
            "reason":str(derived.get("reason","v2_combat_stats_unavailable"))
        }
    return {
        "authority":"combat_stats_v2",
        "ready":true,
        "stats":derived["stats"].duplicate(true),
        "resistances":derived["resistances"].duplicate(true),
        "core_breakdown":derived["core_breakdown"].duplicate(true),
        "applied_sources":derived["applied_sources"].duplicate(true),
        "source_scope":"realm_body_potential_core_only"
    }

static func _legacy_progression(disciple: DiscipleState) -> Dictionary:
    return {
        "authority":"legacy_p2",
        "ready":true,
        "cultivation":{
            "stage_index":disciple.cultivation_stage_index,
            "xp":disciple.cultivation_progress,
            "breakthrough_failures":disciple.breakthrough_failures
        },
        "body":{"ready":false,"reason":"legacy_body_track_absent"}
    }

static func _legacy_combat(disciple: DiscipleState) -> Dictionary:
    return {
        "authority":"legacy_compatibility",
        "ready":true,
        "combat_power":disciple.combat_power,
        "cultivation_combat_bonus":disciple.cultivation_combat_bonus,
        "cultivation_hp_bonus":disciple.cultivation_hp_bonus
    }

static func _legacy_innate(state: SimulationState, disciple: DiscipleState) -> Dictionary:
    return {
        "authority":"legacy_compatibility",
        "spiritual_root_elements":disciple.spiritual_root_elements.duplicate(),
        "spiritual_root_quality":str(disciple.spiritual_root_quality),
        "bloodline_profile":_duplicate_dict(state.sect.bloodline_profiles.get(str(disciple.id),{})),
        "physique_profile":_duplicate_dict(state.sect.physique_profiles.get(str(disciple.id),{})),
        "trait_profile":_duplicate_dict(state.sect.disciple_trait_profiles.get(str(disciple.id),{}))
    }

static func _duplicate_dict(value: Variant) -> Dictionary:
    return value.duplicate(true) if value is Dictionary else {}
