extends SceneTree

# E: normalized HUMAN-tier runtime measurements for every indexed school branch.
# Isolated actors are fixtures; this does not unlock candidate skills or grant rewards.
const SEED := 20261110
const BATTLE_STEPS := 300
const NORMALIZED_ATK := 180.0
var failures := 0
var profiles := 0
var trials := 0
var rows: Array = []

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, reason: String) -> void:
    if not condition:
        failures += 1
        push_error("GAMEPLAY_E_COMBAT_FAIL " + reason)

func _make_caster(school: String, branch: String, tier: String, lineage: String) -> Dictionary:
    var core := CombatStatsV2.derive(11, 1, 10, 1, 0.0)
    var stats: Dictionary = core.stats.duplicate(true)
    stats["max_hp"] = 100000.0
    stats["attack"] = NORMALIZED_ATK
    stats["defense"] = 100.0
    var generation := "divine" if tier == "rare" else tier
    var path_suffix := "human" if generation == "human" else generation + "." + lineage
    var actions: Array = []
    var passives: Array = []
    for ordinal in range(1, 5):
        actions.append("tmb.skill.%s.%s.active_%02d.%s" % [school, branch, ordinal, path_suffix])
    var ultimate_suffix := path_suffix if tier != "rare" else "rare." + lineage
    actions.append("tmb.skill.%s.%s.ultimate.%s" % [school, branch, ultimate_suffix])
    for ordinal in range(1, 6):
        var passive_suffix := path_suffix
        if tier == "rare" and ordinal == 5:
            passive_suffix = "rare_passive." + lineage
        passives.append("tmb.skill.%s.%s.passive_%02d.%s" % [school, branch, ordinal, passive_suffix])
    var innate_id := "tmb.skill.%s.%s.innate.%s" % [school, branch, path_suffix]
    var basic_suffix := "human" if generation == "human" else generation + ".base"
    var basic_id := "tmb.skill.%s.basic.%s" % [school, basic_suffix]
    for id in actions + passives + [innate_id, basic_id]:
        _check(not V63HumanSkillCombatSystem.skill_definition(str(id)).is_empty(), "missing catalog skill " + str(id))
    var role := "frontline" if school in ["fist","sword","blade","spear","dual_blade","palm"] else "healer" if branch == "duoc_doc" else "ranged"
    var hero := {
        "id":"skill_all_caster", "party_id":"skill_all_measurement_party",
        "role":role, "tier":"disciple", "race_id":"nhan_toc", "position":Vector2(7.0,6.0),
        "stats":stats, "hp":100000.0, "max_hp":100000.0,
        "resistances":core.resistances.duplicate(true),
        "basic_range":float(V63HumanSkillCombatSystem.skill_definition(basic_id).get("range", 1.8)),
        "basic_ratio":float(V63HumanSkillCombatSystem.skill_definition(basic_id).get("damage_ratio", 1.0)),
        "basic_interval":1.6, "move_speed":2.7,
        "skill_loadout":[], "skill_factors":{}, "context_sources":[],
        "v63_skill_loadout":actions, "v63_skill_ready":{},
        "v63_passive_ids":passives, "v63_combat_enabled":true,
        "v63_combat_branch_id":branch, "v63_combat_lineage":lineage,
        "v63_combat_generation":generation, "v63_innate_skill_id":innate_id,
        "v63_basic_skill_id":basic_id, "basic_element":str(V63HumanSkillCombatSystem.skill_definition(basic_id).get("element","nether")), "v63_divine_stage":1
    }
    hero["v63_"+school+"_combat_enabled"] = true
    return hero

func _make_target(index: int) -> Dictionary:
    var actor: Dictionary = MonsterCatalogueV2.create_actor("truc_thu", 11, 1, "skill_all_target_%d" % index)
    var stats: Dictionary = actor.get("stats", {}).duplicate(true)
    stats["max_hp"] = 3000000.0
    stats["attack"] = NORMALIZED_ATK
    stats["defense"] = 100.0
    actor["stats"] = stats
    actor["hp"] = 3000000.0
    actor["max_hp"] = 3000000.0
    actor["position"] = Vector2(11.0 + float(index) * 0.5, 6.0 + float(index) * 0.5)
    actor["move_speed"] = 0.0
    return actor

func _trial(school: String, branch: String, tier: String, lineage: String, target_count: int) -> void:
    var hero := _make_caster(school, branch, tier, lineage)
    var monsters: Array = []
    for index in range(target_count):
        monsters.append(_make_target(index))
    var battle := MapBattleV2.new(SEED)
    var identifier := "skill_all_%s_%s_%s_%s_%d" % [school, branch, tier, lineage, target_count]
    var started := battle.setup(identifier, [hero], monsters)
    _check(bool(started.get("ok", false)), identifier + " setup " + str(started))
    if not bool(started.get("ok", false)):
        return
    battle.run(BATTLE_STEPS)
    var damage_by_kind: Dictionary = {}
    var healing := 0.0
    var cast_count := 0
    var distinct: Dictionary = {}
    var hit_count := 0
    for event in battle.events:
        var typ := str(event.get("type", ""))
        if typ == "skill_cast" and str(event.get("actor_id", "")) == "skill_all_caster":
            cast_count += 1
            distinct[str(event.get("skill_id", ""))] = true
        elif typ == "hit" and str(event.get("attacker", "")) == "skill_all_caster":
            var kind := str(event.get("kind", "unknown"))
            damage_by_kind[kind] = float(damage_by_kind.get(kind, 0.0)) + float(event.get("damage", 0.0))
            hit_count += 1
        elif typ == "heal" and str(event.get("caster", "")) == "skill_all_caster":
            healing += float(event.get("amount", 0.0))
    var total_damage := 0.0
    for value in damage_by_kind.values():
        total_damage += float(value)
    _check(cast_count > 0, identifier + " never cast a combat skill")
    _check(total_damage > 0.0 and hit_count > 0, identifier + " produced no committed hit damage")
    var elapsed := maxf(0.25, battle.now)
    var record := {
        "school":school, "branch":branch, "profile":tier + "." + lineage,
        "targets":target_count, "battle_seconds":elapsed,
        "cast_count":cast_count, "unique_cast_skill_ids":distinct.size(),
        "damage_total":total_damage, "damage_by_kind":damage_by_kind, "heal_hp":healing,
        "normalized_dps_per_atk":total_damage / elapsed / NORMALIZED_ATK,
        "normalized_hps_per_maxhp":healing / elapsed / 100000.0,
        "fixture":"MapBattleV2/MonsterCatalogueV2; normalized ATK180/DEF100; target HP3M",
        "seed":SEED
    }
    rows.append(record)
    trials += 1

func _boss_matrix() -> int:
    var seen: Dictionary = {}
    var catalogues := [V63HumanSkillCombatSystem.load_catalogue(),
        V63ImmortalSkillCombatSystem.load_catalogue(),V63DivineSkillCombatSystem.load_catalogue()]
    for catalogue in catalogues:
        _check(bool(catalogue.get("ok",false)),"boss source unavailable")
        for raw in catalogue.get("data",{}).get("bosses",[]):
            var boss: Dictionary = raw
            var id := str(boss.get("id",""))
            _check(not id.is_empty() and not seen.has(id),"duplicate boss "+id)
            seen[id] = true
            var spawn := HuntingMapV2.spawn("thanh_truc_lam",1,"gameplay_e_boss_"+id,SEED)
            var installed := V63HumanSkillCombatSystem.install_boss_spawn(spawn,id,true)
            _check(bool(installed.get("ok",false)),"boss spawn "+id+" "+str(installed))
            if not bool(installed.get("ok",false)):
                continue
            var actor: Dictionary = installed["boss_actor"]
            var coords := V63HumanSkillCombatSystem.boss_challenge_coordinates(boss)
            _check(int(actor.get("realm_index",0)) == coords.x and int(actor.get("floor_index",0)) == coords.y,"boss tier coordinates "+id)
            var definitions := V63HumanSkillCombatSystem.boss_skill_definitions(id)
            _check(str(actor.get("v63_boss_id","")) == id and str(actor.get("tier","")) == "boss","boss identity "+id)
            for skill_id in boss.get("skill_ids",[]):
                _check(definitions.has(str(skill_id)),"boss missing action "+str(skill_id))
            print("GAMEPLAY_E_BOSS_SPAWN "+JSON.stringify({"boss":id,"skill_count":definitions.size(),"hp":actor.get("hp",0),"tier":boss.get("tier_band",""),"fixture":"canonical spawn only; not Boss victory or production UI acceptance"}))
    return seen.size()

# A real personal learned/equipped record and Save serialization for each
# candidate branch. No injected resources, XP, mastery or fake archive manual.
func _sect_instruction_matrix(branches: Dictionary) -> int:
    var count := 0
    var ids: Array = branches.keys()
    ids.sort()
    for raw_id in ids:
        var branch: Dictionary = branches[raw_id]
        var school := str(branch.get("school",""))
        if school not in V63HumanSkillCombatSystem.SECT_TRAINING_SCHOOLS:
            continue
        var branch_id := str(raw_id)
        var state := P37Factory.create_state(SEED)
        var disciple: DiscipleState = state.disciples.values()[0]
        var selected := SectASCharCandidateBridgeV1.assign_branch(state,disciple,branch_id)
        _check(bool(selected.get("ok",false)),"branch assignment "+branch_id)
        if not bool(selected.get("ok",false)):
            continue
        var basic := "tmb.skill.%s.basic.human" % school
        var active := "tmb.skill.%s.%s.active_01.human" % [school,branch_id]
        var rejected := V63HumanSkillCombatSystem.learn_skill(state,disciple,basic)
        _check(not bool(rejected.get("ok",false)),"default gate leaked "+branch_id)
        state.sect.v63_archive_opt_in = true
        state.sect.v63_skill_combat_opt_in = true
        state.sect.v63_learning_opt_in = true
        var overrides := V63FeatureGates.persisted_preview_overrides(state)
        var before := state.sect.spirit_stones
        var contribution := disciple.contribution_points
        for id in [basic,active]:
            var learned := V63HumanSkillCombatSystem.learn_skill(state,disciple,id,overrides)
            _check(bool(learned.get("ok",false)),"learn "+id+" "+str(learned))
            var duplicate := V63HumanSkillCombatSystem.learn_skill(state,disciple,id,overrides)
            _check(bool(duplicate.get("duplicate",false)),"learn replay "+id)
            var equipped := V63HumanSkillCombatSystem.equip_skill(state,disciple,id,overrides)
            _check(bool(equipped.get("ok",false)),"equip "+id+" "+str(equipped))
        _check(state.sect.spirit_stones == before and disciple.contribution_points == contribution,"free instruction mutated currency "+branch_id)
        var cross := V63HumanSkillCombatSystem.learn_skill(state,disciple,"tmb.skill.poison.basic.human",overrides)
        # Cross-school legacy learning must not have a valid archived manual in New Game.
        _check(not bool(cross.get("ok",false)),"foreign skill learned "+branch_id)
        var restored := DiscipleState.from_dict(disciple.to_dict())
        state.disciples[disciple.id] = restored
        _check(V63HumanSkillCombatSystem.validate_state(state).is_empty(),"personal Save validation "+branch_id)
        var actor := {"id":str(restored.id)}
        var attached := V63HumanSkillCombatSystem.attach_disciple_loadout(state,actor,overrides)
        _check(bool(attached.get("ok",false)) and actor.get("v63_skill_loadout",[]).has(active) and bool(actor.get("v63_"+school+"_combat_enabled",false)),"canonical loadout "+branch_id)
        print("GAMEPLAY_E3_INSTRUCTION "+JSON.stringify({"branch":branch_id,"basic":basic,"active":active,"attached":attached.get("attached",false)}))
        count += 1
    return count

func _run() -> void:
    var branches := V63HumanSkillCombatSystem.branch_definitions()
    var instructed := _sect_instruction_matrix(branches)
    _check(instructed == 27,"expected 27 local instruction branches")
    var branch_ids: Array = branches.keys()
    branch_ids.sort()
    var schools: Dictionary = {}
    for raw_id in branch_ids:
        var row: Dictionary = branches[raw_id]
        var school := str(row.get("school",""))
        var branch := str(raw_id)
        _check(not school.is_empty(),"missing branch school "+branch)
        schools[school] = true
        _trial(school,branch,"human","base",1)
        _trial(school,branch,"human","base",3)
        profiles += 1
    _check(schools.size() == 12 and branches.size() == 36,"expected 12 schools / 36 branches")
    _check(profiles == 36 and trials == 72,"expected 72 fixed-target trials")
    var bosses := _boss_matrix()
    _check(bosses == 9,"expected nine registered bosses")
    _check(V63FeatureGates.all_disabled(),"default release gates must remain unchanged")
    for record in rows:
        print("GAMEPLAY_E_COMBAT_PROFILE "+JSON.stringify(record))
    print("GAMEPLAY_E_COMBAT_SUMMARY "+JSON.stringify({"schools":schools.size(),"branches":branches.size(),"profiles":profiles,
        "trials":trials,"instruction_branches":instructed,"boss_spawns":bosses,"failures":failures,"source_sha":OS.get_environment("GITHUB_SHA"),
        "label":"NORMALIZED HUMAN COMBAT FIXTURE; BOSS SPAWN CONTRACT; NOT LIVE PLAYER ACCEPTANCE"}))
    quit(0 if failures == 0 else 1)
