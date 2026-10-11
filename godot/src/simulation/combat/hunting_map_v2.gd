class_name HuntingMapV2
extends RefCounted

# Each existing map has FIVE selectable PvE grades; this is not a global
# Evil Hunter Tycoon-style difficulty switch. Monster and reward numbers PILOT.
# Encounter-level rare tier odds, NOT a global exclusion of Elite/Boss.
# ALL five levels can contain either type. These percentages are PILOT.
# Boss on L1/L2 displaces optional Elite to avoid unavoidable double-spikes.
const LEVELS := {
    1:{"name":"Ngoại Vi","hp":0.75,"attack":0.82,"defense":0.88,"yield":1.00,"rare":0.00,"count":3,"elite_chance":0.06,"boss_chance":0.01,"min_elites":0},
    2:{"name":"Thâm Nhập","hp":1.00,"attack":1.00,"defense":1.00,"yield":1.35,"rare":0.03,"count":4,"elite_chance":0.14,"boss_chance":0.03,"min_elites":0},
    3:{"name":"Hung Địa","hp":1.40,"attack":1.18,"defense":1.12,"yield":1.80,"rare":0.08,"count":5,"elite_chance":0.30,"boss_chance":0.08,"min_elites":1},
    4:{"name":"Hiểm Địa","hp":1.95,"attack":1.40,"defense":1.27,"yield":2.50,"rare":0.16,"count":6,"elite_chance":0.65,"boss_chance":0.16,"min_elites":1},
    5:{"name":"Tuyệt Địa","hp":2.70,"attack":1.65,"defense":1.45,"yield":3.50,"rare":0.26,"count":7,"elite_chance":0.00,"boss_chance":1.00,"min_elites":2}
}
# F3 A/B source PILOT; numeric payouts are not final locked balance.
const LINH_TUY_GUARANTEE_WINS := 4
const REGION_CONTENT := {
    "thanh_truc_lam":{
        "name":"Thanh Trúc Lâm","realm":1,"floor":1,
        "normal":{"truc_thu":0.65,"thanh_lang":0.30,"hac_lang":0.05},
        "elite":"nham_giap_thu","boss":"hac_lang_vuong",
        "resources":{"linh_moc":3,"thanh_thiet":1,"thanh_linh_thao":1},
        "rare":"linh_tuy"
    },
    "bach_thach_khe":{
        "name":"Bạch Thạch Khê","realm":1,"floor":3,
        "normal":{"truc_thu":0.25,"thanh_lang":0.60,"hac_lang":0.15},
        "elite":"huyet_lang_dau_dan","boss":"hac_lang_vuong",
        "resources":{"thanh_thiet":2,"tinh_lang_bi":2,"tu_van_thao":2},
        "rare":"huyen_thiet"
    },
    "hac_phong_coc":{
        "name":"Hắc Phong Cốc","realm":1,"floor":6,
        "normal":{"truc_thu":0.10,"thanh_lang":0.45,"hac_lang":0.45},
        "elite":"huyet_lang_dau_dan","boss":"hac_lang_vuong",
        "resources":{"tinh_lang_bi":2,"yeu_dan":2},
        "rare":"huyen_thiet"
    }
}

static func valid_choice(region_id: String, level: int) -> bool:
    return REGION_CONTENT.has(region_id) and LEVELS.has(level)

static func choose_level(state: SimulationState, region_id: String, level: int) -> Dictionary:
    if not state.sect.p3_7_resources_enabled or not valid_choice(region_id,level) or not state.regions.has(StringName(region_id)):
        return {"ok":false,"reason":"region_or_level_not_available"}
    state.sect.v2_pve_selected_levels[region_id] = level
    state.sect.v2_pve_enabled = true
    return {"ok":true,"region_id":region_id,"level":level}

static func selected_level(state: SimulationState, region_id: String) -> int:
    return int(state.sect.v2_pve_selected_levels.get(region_id,1))

static func overview(region_id: String) -> Dictionary:
    if not REGION_CONTENT.has(region_id):
        return {"ok":false,"reason":"unknown_map"}
    var data: Dictionary = REGION_CONTENT[region_id]
    var levels: Array = []
    for i in range(1,6):
        var level: Dictionary = LEVELS[i]
        levels.append({
            "level":i,"name":str(level["name"]),"monster_count":int(level["count"]),
            "monster_hp_factor":float(level["hp"]),
            "monster_attack_factor":float(level["attack"]),
            "monster_defense_factor":float(level["defense"]),
            "resource_yield_factor":float(level["yield"]),
            "rare_drop_chance":float(level["rare"]),
            "elite_encounter_chance":1.0 if int(level["min_elites"]) > 0 else float(level["elite_chance"]),
            "boss_encounter_chance":float(level["boss_chance"]),
            "min_elite_monsters":int(level["min_elites"])
        })
    return {"ok":true,"region_id":region_id,"name":str(data["name"]),"levels":levels,
        "normal_resources":data["resources"].duplicate(true),"rare_resource":data["rare"]}

static func spawn(region_id: String, level: int, encounter_id: String, seed: int) -> Dictionary:
    if not valid_choice(region_id,level) or encounter_id.is_empty():
        return {"ok":false,"reason":"unknown_region_level_or_encounter"}
    var content: Dictionary = REGION_CONTENT[region_id]
    var spec: Dictionary = LEVELS[level]
    var rng := GameRng.new(seed)
    var monsters: Array = []
    var total: int = int(spec["count"])
    # Rare boss/elite roll is made ONCE per encounter, not per frame or target.
    # A level-one boss is rare but is NOT forbidden. It occupies one monster
    # slot in the group; it does not silently spawn an extra 41st actor.
    var include_boss := rng.chance(float(spec["boss_chance"]))
    var elite_count := int(spec["min_elites"])
    if rng.chance(float(spec["elite_chance"])):
        elite_count += 1
    if level <= 2 and include_boss:
        elite_count = 0
    for i in range(total):
        var species_id := str(rng.weighted_pick(content["normal"]))
        if include_boss and i == 0:
            species_id = str(content["boss"])
        elif elite_count > 0 and i == 1:
            species_id = str(content["elite"])
        elif elite_count > 1 and i == 3:
            species_id = str(content["elite"])
        var instance := MonsterCatalogueV2.create_actor(
            species_id,int(content["realm"]),int(content["floor"]),
            "%s/mob_%02d" % [encounter_id,i]
        )
        if not bool(instance.get("ok",false)):
            return instance
        instance["id"] = "mob_%02d" % i
        instance["position"] = Vector2(23.0+float(i%3)*0.8,8.0+float(i/3)*0.9)
        instance["region_id"] = region_id
        instance["difficulty_level"] = level
        var stats: Dictionary = instance["stats"]
        for channel in ["max_hp","attack","defense"]:
            stats[channel] = float(stats[channel])*float(spec["hp" if channel == "max_hp" else channel])
        instance["hp"] = float(stats["max_hp"])
        monsters.append(instance)
    return {"ok":true,"encounter_id":encounter_id,"region_id":region_id,"level":level,
        "monsters":monsters,"reward_seed":seed,"resource_factor":float(spec["yield"]),
        "rare_chance":float(spec["rare"]),
        "has_boss":include_boss,"elite_count":elite_count}

# Preview is completely pure: showing the drop panel does NOT grant items.
# The reward contract uses only registered P3.7 materials and resolves once
# for a victorious, genuinely finished MapBattleV2 encounter.
static func preview_reward(spawn_data: Dictionary) -> Dictionary:
    if not bool(spawn_data.get("ok",false)):
        return {}
    var id := str(spawn_data.get("region_id",""))
    var level := int(spawn_data.get("level",0))
    if not valid_choice(id,level):
        return {}
    var content: Dictionary = REGION_CONTENT[id]
    var factor := float(LEVELS[level]["yield"])
    var result: Dictionary = {}
    var ids: Array = content["resources"].keys()
    ids.sort()
    for item_id in ids:
        var quantity := maxi(1,int(round(float(content["resources"][item_id])*factor)))
        result[str(item_id)] = quantity
    var rng := GameRng.new(int(spawn_data["reward_seed"])+7331)
    var rare_id := str(content["rare"])
    if rng.chance(float(LEVELS[level]["rare"])):
        result[rare_id] = int(result.get(rare_id,0))+1
    return result

# This source contract is derived from actual authored regions, never caller flags.
static func early_body_sources_ready(state: SimulationState, source_realm: int) -> bool:
    if state == null or not state.sect.p3_7_resources_enabled or source_realm < 1 or source_realm > 6:
        return false
    for location in ["thanh_truc_lam","bach_thach_khe","hac_phong_coc"]:
        if not state.regions.has(StringName(location)):
            return false
    var first: Dictionary = REGION_CONTENT["thanh_truc_lam"]
    var second: Dictionary = REGION_CONTENT["bach_thach_khe"]
    var third: Dictionary = REGION_CONTENT["hac_phong_coc"]
    var registry := ResourceRegistry.new()
    return (
        registry.has(&"thanh_linh_thao") and registry.has(&"tinh_lang_bi") and
        registry.has(&"tu_van_thao") and registry.has(&"linh_tuy") and
        int(first["resources"].get("thanh_linh_thao",0)) > 0 and
        int(second["resources"].get("tu_van_thao",0)) > 0 and
        int(second["resources"].get("tinh_lang_bi",0)) > 0 and
        int(third["resources"].get("tinh_lang_bi",0)) > 0 and
        str(first["rare"]) == "linh_tuy" and LINH_TUY_GUARANTEE_WINS > 0
    )

# This is a PURE estimate of guaranteed EXTRA loot if the encounter is won.
static func preview_body_guarantee(state: SimulationState, spawn_data: Dictionary) -> Dictionary:
    if state == null or str(spawn_data.get("region_id","")) != "thanh_truc_lam":
        return {}
    var old_wins := clampi(int(state.sect.v2_body_material_progress.get(
        "linh_tuy_thanh_truc_wins",0)),0,LINH_TUY_GUARANTEE_WINS-1)
    if old_wins+1 >= LINH_TUY_GUARANTEE_WINS:
        return {"linh_tuy":1}
    return {}

static func claim_reward(state: SimulationState, spawn_data: Dictionary, battle: MapBattleV2) -> Dictionary:
    if not state.sect.p3_7_resources_enabled or battle == null or battle.active:
        return {"ok":false,"reason":"not_final_or_warehouse_disabled"}
    if battle.outcome != "win" or not bool(spawn_data.get("ok",false)):
        return {"ok":false,"reason":"not_victorious"}
    var encounter_id := str(spawn_data.get("encounter_id",""))
    if encounter_id.is_empty() or encounter_id != battle.encounter_id:
        return {"ok":false,"reason":"wrong_encounter"}
    if state.sect.v2_pve_reward_claims.has(encounter_id):
        return {"ok":false,"reason":"duplicate_claim"}
    var items := preview_reward(spawn_data)
    var guaranteed := preview_body_guarantee(state,spawn_data)
    for item_id in guaranteed.keys():
        items[item_id] = int(items.get(item_id,0))+int(guaranteed[item_id])
    var registry := ResourceRegistry.new()
    var warehouse := WarehouseSystem.new()
    # Preflight ALL items before mutation: all-or-nothing, no partial payout.
    for item_id in items.keys():
        var count := int(items[item_id])
        if not registry.has(StringName(item_id)) or count <= 0:
            return {"ok":false,"reason":"unregistered_resource"}
        if count > warehouse.MAX_SAFE_STACK - warehouse.quantity(state,StringName(item_id)):
            return {"ok":false,"reason":"warehouse_overflow"}
    var ids: Array = items.keys()
    ids.sort()
    var old_items := state.sect.warehouse_resources.duplicate(true)
    var old_events := state.sect.warehouse_event_count
    for item_id in ids:
        if not warehouse.add(state,StringName(item_id),int(items[item_id])):
            state.sect.warehouse_resources = old_items
            state.sect.warehouse_event_count = old_events
            return {"ok":false,"reason":"warehouse_commit_failed"}
    # Counter advances only after the entire real victorious warehouse claim.
    if str(spawn_data.get("region_id","")) == "thanh_truc_lam":
        var progress := clampi(int(state.sect.v2_body_material_progress.get(
            "linh_tuy_thanh_truc_wins",0)),0,LINH_TUY_GUARANTEE_WINS-1)
        state.sect.v2_body_material_progress["linh_tuy_thanh_truc_wins"] = (
            (progress+1) % LINH_TUY_GUARANTEE_WINS
        )
    state.sect.v2_pve_reward_claims[encounter_id] = true
    return {"ok":true,"encounter_id":encounter_id,"region_id":spawn_data["region_id"],
        "level":spawn_data["level"],"items":items}
