class_name CombatLabRosterAdapter
extends RefCounted

const LAB_PREVIEW_GATES := {
    "sect_codex": true,
    "technique_learning": true,
    "human_skill_combat": true,
    "divine_skill_combat": true,
    "skill_successors": true,
    "boss_encounters": true
}
const SCHOOL_ORDER := ["bow", "fist", "poison"]
const GENERATIONS := ["human", "immortal", "divine"]
const ACTIVE_LIMIT := 4
const PASSIVE_LIMIT := 5
const MAX_SKILLS := 12

static var _skill_cache: Dictionary = {}

static func skill_definitions() -> Dictionary:
    if _skill_cache.is_empty():
        _skill_cache = V63HumanSkillCombatSystem.skill_definitions()
    return _skill_cache

static func school_branches(school: String) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    for raw in V63HumanSkillCombatSystem.branch_definitions().values():
        if str(raw.get("school", "")) == school:
            rows.append(raw.duplicate(true))
    rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
    return rows

static func skill_options(school: String, generation: String, slot: String, branch: String, lineage: String) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    for raw in skill_definitions().values():
        var row: Dictionary = raw
        if str(row.get("school", "")) != school or str(row.get("generation", row.get("tier", "human"))) != generation:
            continue
        if str(row.get("slot", "")) != slot:
            continue
        if slot in ["active", "ultimate", "passive", "innate"] and str(row.get("branch", "")) != branch:
            continue
        var row_lineage := str(row.get("lineage", ""))
        if generation in ["immortal", "divine"] and slot in ["active", "ultimate", "passive"] and row_lineage != lineage:
            continue
        # Divine Poison nodes whose mechanics are explicitly owner-deferred are
        # browseable in the catalog UI, but must not enter a Lab loadout/AI cast.
        if school == "poison" and str(row.get("divine_rule_status", "")) == "DESIGN_PENDING":
            continue
        if bool(row.get("archivable", false)) == false and slot not in ["basic", "mobility"]:
            continue
        rows.append(row.duplicate(true))
    rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        var a_order := int(a.get("order", a.get("index", 0)))
        var b_order := int(b.get("order", b.get("index", 0)))
        return a_order < b_order if a_order != b_order else str(a.get("id", "")) < str(b.get("id", ""))
    )
    return rows

static func default_loadout(school: String, generation: String, branch: String, lineage: String) -> Dictionary:
    var ids: Array[String] = []
    var errors: Array[String] = []
    for slot in ["basic", "mobility"]:
        var shared := skill_options(school, generation, slot, branch, lineage)
        if shared.is_empty():
            errors.append("missing_%s_skill" % slot)
        else:
            ids.append(str(shared[0].get("id", "")))
    var active := skill_options(school, generation, "active", branch, lineage)
    var ultimate := skill_options(school, generation, "ultimate", branch, lineage)
    var passives := skill_options(school, generation, "passive", branch, lineage)
    if active.size() < ACTIVE_LIMIT:
        errors.append("active_catalog_below_four")
    if ultimate.is_empty():
        errors.append("ultimate_catalog_missing")
    if passives.size() < PASSIVE_LIMIT:
        errors.append("passive_catalog_below_five")
    for index in range(mini(ACTIVE_LIMIT, active.size())):
        ids.append(str(active[index].get("id", "")))
    if not ultimate.is_empty():
        ids.append(str(ultimate[0].get("id", "")))
    for index in range(mini(PASSIVE_LIMIT, passives.size())):
        ids.append(str(passives[index].get("id", "")))
    var validation := validate_loadout(ids, school, generation, branch, lineage)
    errors.append_array(validation)
    return {"ok": errors.is_empty(), "skill_ids": ids, "errors": errors}

static func validate_loadout(ids: Array, school: String, generation: String, branch: String, lineage: String) -> Array[String]:
    var errors: Array[String] = []
    var definitions := skill_definitions()
    var seen: Dictionary = {}
    var families: Dictionary = {}
    var counts := {"basic": 0, "active": 0, "ultimate": 0, "mobility": 0, "passive": 0}
    if ids.size() > MAX_SKILLS:
        errors.append("skill_count_exceeds_twelve")
    for raw_id in ids:
        var id := str(raw_id)
        if seen.has(id):
            errors.append("duplicate_skill_id:" + id)
            continue
        seen[id] = true
        if not definitions.has(id):
            errors.append("unknown_skill_id:" + id)
            continue
        var def: Dictionary = definitions[id]
        var slot := str(def.get("slot", ""))
        if school == "poison" and str(def.get("divine_rule_status", "")) == "DESIGN_PENDING":
            errors.append("poison_design_pending_not_loadable:" + id)
        if str(def.get("school", "")) != school or str(def.get("generation", def.get("tier", "human"))) != generation:
            errors.append("skill_school_or_generation_mismatch:" + id)
        if slot in ["active", "ultimate", "passive"] and str(def.get("branch", "")) != branch:
            errors.append("skill_branch_mismatch:" + id)
        if generation in ["immortal", "divine"] and slot in ["active", "ultimate", "passive"] and str(def.get("lineage", "")) != lineage:
            errors.append("skill_lineage_mismatch:" + id)
        if not bool(def.get("archivable", false)) and slot not in ["basic", "mobility"]:
            errors.append("skill_not_owned_or_archivable:" + id)
        if counts.has(slot):
            counts[slot] = int(counts[slot]) + 1
        var family := str(def.get("family_id", ""))
        if not family.is_empty() and families.has(family):
            errors.append("skill_family_conflict:" + family)
        families[family] = id
    for slot in counts:
        var limit := ACTIVE_LIMIT if slot == "active" else (PASSIVE_LIMIT if slot == "passive" else 1)
        if int(counts[slot]) > limit:
            errors.append("slot_limit_exceeded:" + slot)
    if counts.basic != 1 or counts.mobility != 1:
        errors.append("basic_or_mobility_slot_missing")
    return errors

static func _seed_lineage(disciple: DiscipleState, generation: String, branch_id: String, lineage: String) -> void:
    if generation == "immortal":
        var branch: Dictionary = V63ImmortalSkillCombatSystem.branch_definitions().get(branch_id, {})
        var technique_id := str(branch.get("lineage_technique_ids", {}).get(lineage, ""))
        if not technique_id.is_empty():
            disciple.known_techniques[technique_id] = {"mastery_xp": 0.0, "mastery_stage": 0, "learned_tick": 0}
    elif generation == "divine":
        var branch: Dictionary = V63DivineSkillCombatSystem.branch_definitions().get(branch_id, {})
        for raw_id in branch.get("divine_technique_ids", {}).get(lineage, []):
            disciple.known_techniques[str(raw_id)] = {"mastery_xp": 0.0, "mastery_stage": 0, "learned_tick": 0}

static func _archive_codex(state: SimulationState, codex_id: String) -> bool:
    if codex_id.is_empty():
        return false
    var codex := V63SectArchiveSystem.codex_definition(codex_id)
    if codex.is_empty() or not bool(codex.get("archivable", false)):
        return false
    var manual_id := StringName(str(codex.get("manual_item_id", "")))
    var warehouse := WarehouseSystem.new()
    if not warehouse.registry.has(manual_id) or not warehouse.add(state, manual_id, 1):
        return false
    return bool(V63SectArchiveSystem.archive_manual(state, codex_id, LAB_PREVIEW_GATES).get("ok", false))

static func _make_lab_state(disciple: DiscipleState, school: String, generation: String, branch: String, lineage: String, ids: Array[String]) -> Dictionary:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 32
    state.p3_7_buildings_enabled = true
    state.sect.p3_7_resources_enabled = true
    state.sect.v63_archive_opt_in = true
    state.sect.v63_learning_opt_in = true
    state.sect.v63_skill_combat_opt_in = true
    state.disciples[disciple.id] = disciple
    _seed_lineage(disciple, generation, branch, lineage)
    var definitions := skill_definitions()
    for id in ids:
        var def: Dictionary = definitions.get(id, {})
        if def.is_empty():
            continue
        if bool(def.get("archivable", false)):
            var codex_id := str(def.get("source_codex_id", ""))
            if not V63SectArchiveSystem.transmission_available_for_disciple(state, str(disciple.id), codex_id, LAB_PREVIEW_GATES):
                _archive_codex(state, codex_id)
            var learned := V63HumanSkillCombatSystem.learn_skill(state, disciple, id, LAB_PREVIEW_GATES)
            if not bool(learned.get("ok", false)):
                return {"ok": false, "reason": "fixture_learning_failed", "skill_id": id, "detail": learned}
            var equipped := V63HumanSkillCombatSystem.equip_skill(state, disciple, id, LAB_PREVIEW_GATES)
            if not bool(equipped.get("ok", false)):
                return {"ok": false, "reason": "fixture_equip_failed", "skill_id": id, "detail": equipped}
    disciple.v63_equipped_skill_ids.sort()
    return {"ok": true, "state": state}

static func build_party(count: int, school: String, generation: String, branch: String, lineage: String, selected_ids: Array[String] = []) -> Dictionary:
    if count < 1 or count > 6 or not SCHOOL_ORDER.has(school) or not GENERATIONS.has(generation):
        return {"ok": false, "reason": "invalid_party_selection"}
    var loadout := {"ok": true, "skill_ids": selected_ids.duplicate(), "errors": []}
    if selected_ids.is_empty():
        loadout = default_loadout(school, generation, branch, lineage)
    if not bool(loadout.get("ok", false)):
        return {"ok": false, "reason": "invalid_loadout", "errors": loadout.get("errors", [])}
    var ids: Array[String] = loadout.skill_ids
    var validation := validate_loadout(ids, school, generation, branch, lineage)
    if not validation.is_empty():
        return {"ok": false, "reason": "invalid_loadout", "errors": validation}
    var core := CombatStatsV2.derive(2, 3, 2, 3, 0.0)
    if not bool(core.get("ok", false)):
        return {"ok": false, "reason": "combat_stats_derive_failed"}
    var party: Array = []
    var states: Array[SimulationState] = []
    var actors: Array[Dictionary] = []
    for index in range(count):
        var id := "lab_disciple_%02d" % (index + 1)
        var disciple := DiscipleState.new({"id": id, "name": "Đệ tử Lab %02d" % (index + 1)})
        disciple.v63_combat_branch_id = StringName(branch)
        var state_result := _make_lab_state(disciple, school, generation, branch, lineage, ids)
        if not bool(state_result.get("ok", false)):
            return {"ok": false, "reason": "fixture_state_failed", "actor_id": id, "detail": state_result}
        var state: SimulationState = state_result.state
        var role: String = str(["ranged", "frontline", "mage", "healer", "ranged", "frontline"][index])
        var actor := {
            "id": id, "party_id": "combat_lab_fixture", "role": role, "tier": "disciple", "race_id": "nhan_toc",
            "position": Vector2(6.0 + float(index % 3) * 2.7, 7.5 + float(index / 3) * 5.0),
            "stats": core.stats.duplicate(true), "hp": float(core.stats.max_hp), "max_hp": float(core.stats.max_hp),
            "resistances": core.resistances.duplicate(true), "basic_range": 5.5 if school == "bow" else 1.65,
            "move_speed": 2.15, "basic_ratio": 1.0, "basic_interval": 1.6,
            "skill_loadout": [], "skill_factors": {}, "context_sources": [], "disciple": disciple,
            "v63_combat_generation": generation, "v63_combat_lineage": lineage,
            "lab_fixture": true
        }
        var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state, actor, LAB_PREVIEW_GATES)
        if not bool(attached.get("ok", false)) or not bool(attached.get("attached", false)):
            return {"ok": false, "reason": "v63_attach_failed", "actor_id": id, "detail": attached}
        states.append(state)
        actors.append(actor)
        party.append(actor)
    return {"ok": true, "party": party, "states": states, "actors": actors, "skill_ids": ids, "lab_only": true}

static func build_enemy(kind: String, boss_id: String, id: String = "lab_enemy") -> Dictionary:
    if kind == "boss":
        if V63HumanSkillCombatSystem.boss_definition(boss_id).is_empty():
            return {"ok": false, "reason": "unknown_v63_boss_id"}
        var spawn := HuntingMapV2.spawn("thanh_truc_lam", 1, "combat_lab_boss", 515151)
        var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawn, boss_id)
        if not bool(installed.get("ok", false)):
            return {"ok": false, "reason": "v63_boss_install_failed", "detail": installed}
        var boss: Dictionary = installed.boss_actor.duplicate(true)
        boss["position"] = Vector2(28.0, 10.0)
        boss["hp"] = float(boss.stats.max_hp)
        boss["tier"] = "boss"
        return {"ok": true, "actor": boss}
    var species := "hac_lang" if kind == "normal" else "nham_giap_thu"
    var enemy := MonsterCatalogueV2.create_actor(species, 1, 2, id)
    if not bool(enemy.get("ok", false)):
        return {"ok": false, "reason": "monster_catalogue_failed", "detail": enemy}
    enemy["id"] = id
    enemy["position"] = Vector2(26.0, 10.0)
    enemy["tier"] = "normal" if kind == "normal" else "elite"
    enemy["move_speed"] = 1.4
    enemy["v63_combat_enabled"] = false
    return {"ok": true, "actor": enemy}

static func stat_breakdown(actor: Dictionary) -> Dictionary:
    var stats: Dictionary = actor.get("stats", {})
    var attack := V63HumanSkillCombatSystem.effective_attack_stats(actor, stats)
    var defense := V63HumanSkillCombatSystem.effective_defense_stats(actor, stats)
    return {"max_hp": float(stats.get("max_hp", 0.0)), "attack": float(attack.get("attack", 0.0)),
        "defense": float(defense.get("defense", 0.0)), "crit_chance": float(attack.get("crit_chance", 0.0)),
        "lifesteal": float(attack.get("lifesteal", 0.0)), "cast_speed": float(attack.get("cast_speed", 0.0)),
        "cooldown_recovery": float(attack.get("cooldown_recovery", 0.0)), "effect_hit": float(attack.get("effect_hit", 0.0))}

