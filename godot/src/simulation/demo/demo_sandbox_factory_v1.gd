class_name DemoSandboxFactoryV1
extends RefCounted

# Creates the opt-in DEMO MAX sandbox with the same production V2 systems used
# by the game. The only accelerated progression is this private demo save.
const SEED := 31012026
const FIRST_DEMO_CANDIDATE := 1001
const HUNTER_COUNT := 6
const WORKER_COUNT := 6
const HUNTER_IDS := [
    "candidate_1001", "candidate_1002", "candidate_1003",
    "candidate_1004", "candidate_1005", "candidate_1006"
]
const WORKER_IDS := [
    "candidate_1007", "candidate_1008", "candidate_1009",
    "candidate_1010", "candidate_1011", "candidate_1012"
]
const IMPLEMENTED_DAMAGE_SKILLS := [&"thanh_phong_tram", &"ngu_kiem_thuat"]
const WEAPON_RECIPES := [
    &"thanh_thiet_kiem", &"huyen_thiet_quyen_sao", &"linh_moc_phap_truong"
]

static func hunter_ids() -> Array[String]:
    var result: Array[String] = []
    for id in HUNTER_IDS:
        result.append(str(id))
    return result

static func worker_ids() -> Array[String]:
    var result: Array[String] = []
    for id in WORKER_IDS:
        result.append(str(id))
    return result

static func pilot_root_values(disciple: DiscipleState) -> Dictionary:
    if disciple == null:
        return {}
    var layers: Dictionary = disciple.v2_birth_profile.get("layers", {})
    var root: Dictionary = layers.get("spiritual_root", {})
    var values: Dictionary = root.get("current_values", {})
    var result := {}
    for element in ["metal", "wood", "water", "fire", "earth"]:
        if values.has(element):
            var amount := int(values[element])
            if amount >= 1 and amount <= 100:
                result[element] = amount
    return result

static func create_max_state(seed: int = SEED) -> Dictionary:
    var state := P37Factory.create_state(seed)
    var configured := LiveGameRuntimeV2.new()._configure_live_state(state)
    if not bool(configured.get("ok", false)):
        return {"ok":false,"reason":str(configured.get("reason","runtime_config_failed"))}

    state.sect.disciple_v2_birth_enabled = true
    state.sect.disciple_capacity = maxi(
        state.sect.disciple_capacity,
        state.disciples.size() + HUNTER_COUNT + WORKER_COUNT
    )
    var combat_skills := CombatSkillSystem.new()
    combat_skills.initialize(state)
    var recruitment := RecruitmentSystem.new()
    var open_points := DiscipleGeneratorOpenPoints.new()
    var workforce := WorkforceSystem.new()
    var created_hunters: Array[String] = []
    var created_workers: Array[String] = []

    for index in range(HUNTER_COUNT + WORKER_COUNT):
        var generated_index := FIRST_DEMO_CANDIDATE + index
        var candidate := open_points.generate_candidate(
            state, DiscipleGeneratorV2.SOURCE_ORDINARY, generated_index
        )
        if candidate == null or not DiscipleBirthProfileV2.valid_complete_birth(candidate.v2_birth_profile):
            return {"ok":false,"reason":"authentic_v2_candidate_generation_failed","index":generated_index}
        state.recruitment_generation_index = maxi(state.recruitment_generation_index,generated_index)
        state.recruitment_candidates[candidate.id] = candidate
        workforce.ensure_p3_7_candidate_profile(state, candidate)
        var accepted := recruitment.accept_candidate(state, candidate.id)
        if not bool(accepted.get("ok", false)):
            return {"ok":false,"reason":"demo_v2_recruit_rejected","index":generated_index,"detail":accepted}

        var disciple_id := StringName(str(accepted.get("disciple_id", "")))
        var disciple: DiscipleState = state.disciples.get(disciple_id, null)
        if disciple == null or not DiscipleRealmProgressV2.progression_ready(disciple):
            return {"ok":false,"reason":"recruited_disciple_v2_progress_missing","id":str(disciple_id)}
        workforce.ensure_p3_7_disciple_profile(state, disciple)

        if index < HUNTER_COUNT:
            var maxed := _set_demo_max_progress(disciple)
            if not bool(maxed.get("ok", false)):
                return {"ok":false,"reason":"demo_max_progress_failed","id":str(disciple_id)}
            # Learn only the canonical P2 skills whose V2 damage consumers exist.
            for skill_id in IMPLEMENTED_DAMAGE_SKILLS:
                if combat_skills.can_learn_skill(state, disciple, skill_id):
                    combat_skills.learn_skill(state, disciple, skill_id)
            var equipped := _craft_demo_loadout(state, disciple, index)
            if not bool(equipped.get("ok", false)):
                return {"ok":false,"reason":"demo_gear_setup_failed","id":str(disciple_id),"detail":equipped}
            created_hunters.append(str(disciple_id))
        else:
            created_workers.append(str(disciple_id))

    if created_hunters.size() != HUNTER_COUNT or created_workers.size() != WORKER_COUNT:
        return {"ok":false,"reason":"demo_roster_incomplete"}

    var resources := _fund_demo_crafting(state)
    if not bool(resources.get("ok", false)):
        return resources
    # Craft the actual equipment recipes after canonical Warehouse deposits.
    # Earlier calls set up the loadout requests; now fulfill each by recipe.
    var gear := _equip_hunters(state, created_hunters)
    if not bool(gear.get("ok", false)):
        return gear
    var assigned_workers := _assign_resource_workers(state, created_workers)
    if not bool(assigned_workers.get("ok", false)):
        return assigned_workers

    # A low-HP ally guarantees that the real V2 pilot healer demonstrates its
    # verified JX1 precast cue during the first hunt. This is sandbox HP only.
    var demonstration_target: DiscipleState = state.disciples[StringName(created_hunters[3])]
    demonstration_target.hp = demonstration_target.max_hp * 0.55

    return {
        "ok":true,
        "state":state,
        "hunter_ids":created_hunters,
        "worker_ids":created_workers,
        "assigned_worker_ids":assigned_workers.get("assigned_worker_ids",[]),
        "mastery":"NOT_IMPLEMENTED",
        "usable_p2_skills":_count_usable_damage_skills(state,created_hunters)
    }

static func _set_demo_max_progress(disciple: DiscipleState) -> Dictionary:
    if not DiscipleRealmProgressV2.progression_ready(disciple):
        return {"ok":false,"reason":"not_v2_ready"}
    var progress := disciple.v2_realm_progress.duplicate(true)
    for track_id in ["cultivation", "body"]:
        var track: Dictionary = progress.get(track_id, {}).duplicate(true)
        track["realm"] = DiscipleRealmProgressV2.MAX_REALM
        track["floor"] = DiscipleRealmProgressV2.MAX_FLOOR
        track["xp"] = 0.0
        progress[track_id] = track
    disciple.v2_realm_progress = progress
    return DiscipleRealmProgressV2.sync_live_hp(disciple)

static func _craft_demo_loadout(state: SimulationState, disciple: DiscipleState, index: int) -> Dictionary:
    # Called once before crafting so every participant starts with real learned
    # V2 skills, not an invented ability list. Equipment is added below.
    if not state.sect.equipment_enabled or not state.sect.combat_skills_enabled:
        return {"ok":false,"reason":"canonical_combat_or_equipment_disabled"}
    return {"ok":true,"weapon_recipe":str(WEAPON_RECIPES[index % WEAPON_RECIPES.size()])}

static func _fund_demo_crafting(state: SimulationState) -> Dictionary:
    var warehouse := WarehouseSystem.new()
    if not warehouse.initialize(state):
        return {"ok":false,"reason":"canonical_warehouse_unavailable"}
    for resource_id in [&"thanh_thiet", &"linh_moc", &"tinh_lang_bi", &"yeu_dan"]:
        if not warehouse.add(state, resource_id, 200):
            return {"ok":false,"reason":"demo_crafting_resource_deposit_failed","resource":str(resource_id)}
    return {"ok":true}

static func _equip_hunters(state: SimulationState, hunter_ids_value: Array) -> Dictionary:
    var equipment := EquipmentSystem.new()
    var recipes := [&"thanh_thiet_kiem", &"huyen_thiet_quyen_sao", &"linh_moc_phap_truong"]
    for index in range(hunter_ids_value.size()):
        var disciple_id := StringName(str(hunter_ids_value[index]))
        var disciple: DiscipleState = state.disciples.get(disciple_id, null)
        if disciple == null:
            return {"ok":false,"reason":"hunter_missing_during_equipment","id":str(disciple_id)}
        var weapon_id := StringName(recipes[index % recipes.size()])
        for recipe_id in [weapon_id, &"tinh_lang_giap", &"hoa_van_ngoc"]:
            var item := equipment.craft(state, recipe_id, false)
            if item.is_empty() or not equipment.manual_equip(state, disciple_id, StringName(item["id"]), true):
                return {"ok":false,"reason":"canonical_craft_or_equip_failed","id":str(disciple_id),"recipe":str(recipe_id)}
    return {"ok":true}

static func _assign_resource_workers(state: SimulationState, ids: Array) -> Dictionary:
    var workforce := WorkforceSystem.new()
    var buildings := BuildingSystem.new()
    var assignments := [
        {"type":BuildingSystem.TYPE_MINE,"assign":Callable(workforce,"assign_mine_worker")},
        {"type":BuildingSystem.TYPE_LINH_FOREST,"assign":Callable(workforce,"assign_linh_forest_worker")},
        {"type":BuildingSystem.TYPE_SPIRIT_FIELD,"assign":Callable(workforce,"assign_spirit_field_worker")}
    ]
    var assigned: Array[String] = []
    for index in range(mini(assignments.size(),ids.size())):
        var building: BuildingState = buildings.primary_building(state,assignments[index]["type"])
        if building == null:
            continue
        var result: Dictionary = assignments[index]["assign"].call(
            state,StringName(str(ids[index])),building.id,true
        )
        if bool(result.get("ok",false)):
            assigned.append(str(ids[index]))
    if assigned.size() < 3:
        return {"ok":false,"reason":"fewer_than_three_canonical_resource_workers","assigned":assigned}
    return {"ok":true,"assigned_worker_ids":assigned}

static func _count_usable_damage_skills(state: SimulationState, ids: Array) -> int:
    var system := CombatSkillSystem.new()
    var count := 0
    for id in ids:
        var disciple: DiscipleState = state.disciples[StringName(str(id))]
        for skill in system.usable_skills(state,disciple):
            if str(system.definition(skill).get("effect","")) == "damage":
                count += 1
    return count
