class_name MonsterCatalogueV2
extends RefCounted

# DV2-02 initial MONSTER STAT authority. Values are PILOT balance, not global
# user-locked encounter balance. This does NOT mutate legacy P0Content.MONSTERS.
const TIERS := {
    "normal":{"max_hp":1.0,"attack":1.0,"defense":1.0},
    "elite":{"max_hp":1.35,"attack":1.10,"defense":1.10},
    "boss":{"max_hp":2.50,"attack":1.30,"defense":1.18}
}
# Only actual IDs present in the live P0 item registry may be awarded by its
# legacy loot owner. Newly-authored enemy species deliberately have NO drops yet.
const SPECIES := {
    "truc_thu":{
        "name":"Trúc Thử","race_id":"yeu_thu","tier":"normal","element":"wood",
        "hp_factor":0.70,"attack_factor":0.68,"defense_factor":0.55,
        "behavior_id":"skittish","loot_ready":true
    },
    "thanh_lang":{
        "name":"Thanh Lang","race_id":"yeu_thu","tier":"normal","element":"wood",
        "hp_factor":0.90,"attack_factor":0.88,"defense_factor":0.72,
        "behavior_id":"pack_hunter","loot_ready":true
    },
    "hac_lang":{
        "name":"Hắc Lang","race_id":"yeu_thu","tier":"normal","element":"nether",
        "hp_factor":1.00,"attack_factor":1.00,"defense_factor":0.85,
        "behavior_id":"aggressive","loot_ready":true
    },
    "nham_giap_thu":{
        "name":"Nham Giáp Thú","race_id":"yeu_thu","tier":"elite","element":"earth",
        "hp_factor":1.30,"attack_factor":0.90,"defense_factor":1.50,
        "behavior_id":"armored_brute","loot_ready":false
    },
    "u_hon":{
        "name":"U Hồn","race_id":"quy_toc","tier":"normal","element":"nether",
        "hp_factor":0.70,"attack_factor":1.15,"defense_factor":0.60,
        "behavior_id":"debuff_caster","loot_ready":false
    },
    "huyet_lang_dau_dan":{
        "name":"Huyết Lang Đầu Đàn","race_id":"yeu_thu","tier":"elite","element":"fire",
        "hp_factor":1.10,"attack_factor":1.15,"defense_factor":0.85,
        "behavior_id":"pack_leader","loot_ready":false
    },
    "hac_lang_vuong":{
        "name":"Hắc Lang Vương","race_id":"yeu_thu","tier":"boss","element":"nether",
        "hp_factor":1.15,"attack_factor":1.15,"defense_factor":1.00,
        "behavior_id":"boss_phase_authoring_pending","loot_ready":false
    }
}

static func validate_species() -> bool:
    for id in SPECIES.keys():
        var row: Dictionary = SPECIES[id]
        if str(row.get("name","")).is_empty() or not CombatContextEffectsV2.RACES.has(str(row.get("race_id",""))):
            return false
        if not TIERS.has(str(row.get("tier",""))) or not CombatStatsV2.ELEMENTS.has(str(row.get("element",""))):
            return false
        for key in ["hp_factor","attack_factor","defense_factor"]:
            if not row.has(key) or float(row[key]) <= 0.0:
                return false
        if str(row.get("behavior_id","")).is_empty():
            return false
    for old_id in P0Content.MONSTERS.keys():
        # Each historical P0 monster must retain a stable counterpart.
        if not SPECIES.has(old_id):
            return false
    return true

static func create_actor(
    species_id: String, realm_index: int, floor_index: int, encounter_id: String
) -> Dictionary:
    if not SPECIES.has(species_id) or encounter_id.is_empty():
        return {"ok":false,"reason":"unknown_species_or_encounter"}
    if realm_index < 1 or realm_index > 30 or floor_index < 1 or floor_index > 10:
        return {"ok":false,"reason":"invalid_monster_scale"}
    var definition: Dictionary = SPECIES[species_id]
    var tier := str(definition["tier"])
    var factor: Dictionary = TIERS[tier]
    # This is a monster-specific level scale, NOT a disciple cultivation/body
    # roll. Shared G scale keeps PVE numbers comparable at each realm.
    var growth := pow(1.65,realm_index-1)*pow(1.03,floor_index-1)
    var core: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)
    if not bool(core.get("ok",false)):
        return {"ok":false,"reason":"monster_stat_core_error"}
    var stats: Dictionary = core["stats"].duplicate(true)
    stats["max_hp"] = 190.0*growth*float(definition["hp_factor"])*float(factor["max_hp"])
    stats["attack"] = 23.0*growth*float(definition["attack_factor"])*float(factor["attack"])
    stats["defense"] = 19.0*growth*float(definition["defense_factor"])*float(factor["defense"])
    for stat in ["max_hp","attack","defense"]:
        if is_nan(float(stats[stat])) or is_inf(float(stats[stat])) or float(stats[stat]) <= 0.0:
            return {"ok":false,"reason":"nonfinite_monster_stat"}
    return {
        "ok":true,"encounter_id":encounter_id,"species_id":species_id,
        "name":str(definition["name"]),"race_id":str(definition["race_id"]),
        "tier":tier,"element":str(definition["element"]),
        "realm_index":realm_index,"floor_index":floor_index,
        "behavior_id":str(definition["behavior_id"]),
        "behavior_ready":false,"loot_ready":bool(definition["loot_ready"]),
        "hp":float(stats["max_hp"]),"stats":stats,
        "resistances":core["resistances"].duplicate(true),
        "v2_hit_ids":{}
    }
