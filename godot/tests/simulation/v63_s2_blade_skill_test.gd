extends SceneTree

# S2 Dao candidate verification. Candidate behavior stays off the player path
# until the canonical Dao manual and balance are approved.
const Blade = preload("res://src/simulation/combat/v63_blade_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Registry = preload("res://src/simulation/combat/v63_content_registry.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const FeatureGates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> bool:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_S2_BLADE_FAIL " + label)
    return condition

func _run() -> void:
    var loaded: Dictionary = Blade.load_catalogue()
    _expect(bool(loaded.get("ok",false)), "Dao candidate catalogue loads: " + str(loaded.get("errors",[])))
    if not bool(loaded.get("ok",false)):
        _finish()
        return
    var catalogue: Dictionary = loaded.get("data",{})
    var skills: Array = catalogue.get("skills",[])
    _expect(skills.size()==183 and int(catalogue.get("branch_count",0))==3 and int(catalogue.get("human_skill_count",0))==35, "183 nodes, three branches and thirty-five family roots")
    _expect(int(catalogue.get("immortal_skill_count",0))==68 and int(catalogue.get("divine_skill_count",0))==80, "successor distribution follows the approved graph size")
    _expect(Blade.validate_catalogue(catalogue).is_empty(), "Blade graph, source-pending status and mechanics bounds validate")
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var tiers := {"human":0,"immortal":0,"divine":0}
    var branch_counts := {"cuong_dao":0,"tram_phach_dao":0,"tran_dao":0}
    for raw in skills:
        var skill: Dictionary = raw
        var id := str(skill.get("id",""))
        var name := str(skill.get("name",""))
        var family := str(skill.get("family_id",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var branch := str(skill.get("branch",""))
        _expect(not id.is_empty() and not ids.has(id), "unique Dao runtime ID: "+id)
        _expect(not name.is_empty() and not names.has(name), "unique Hán-Việt name: "+id)
        ids[id]=true
        names[name]=true
        families[family]=true
        tiers[tier]=int(tiers.get(tier,0))+1
        if branch_counts.has(branch):
            branch_counts[branch]=int(branch_counts[branch])+1
        _expect(str(skill.get("school",""))=="blade" and str(skill.get("element",""))=="metal", "school and element match catalog: "+id)
        _expect(str(skill.get("candidate_status",""))=="CANDIDATE_GATED_SOURCE_PENDING" and str(skill.get("balance_status",""))=="candidate_needs_qa", "source and balance remain unapproved: "+id)
        _expect(str(skill.get("source_codex_id","")).is_empty() and not bool(skill.get("archivable",true)), "no fake source or learnable flag: "+id)
        _expect(int(skill.get("hit_count",0))>=1 and int(skill.get("hit_count",0))<=3, "bounded hit count: "+id)
    _expect(families.size()==35 and tiers=={"human":35,"immortal":68,"divine":80}, "family and realm totals are exact")
    _expect(branch_counts=={"cuong_dao":59,"tram_phach_dao":59,"tran_dao":59}, "each branch has fifty-nine nodes")

    var source_rows: Dictionary = Presentation.load_authoring_sources()
    _expect(bool(source_rows.get("ok",false)), "S0/S1/S2 data and manifests load: "+str(source_rows.get("errors",[])))
    var manifest: Dictionary = source_rows.get("manifest",{})
    var entries: Dictionary = manifest.get("entries",{})
    _expect(entries.size()==370, "four S0 source samples and 366 candidate presentations coexist")
    var unique_flavor: Dictionary = {}
    var unique_short: Dictionary = {}
    var unique_motion: Dictionary = {}
    for raw in skills:
        var skill: Dictionary = raw
        var id := str(skill.id)
        var entry: Dictionary = entries.get(id,{})
        var lore := str(entry.get("school_lore_id",""))
        var branch_lore := str(entry.get("branch_lore_id",""))
        var text_fields := [str(entry.get("flavor_vi","")),str(entry.get("short_description_vi","")),str(entry.get("long_description_vi","")),str(entry.get("counterplay_vi",""))]
        var text_complete := true
        for prose in text_fields:
            text_complete = text_complete and not prose.strip_edges().is_empty() and not _contains_ascii_digit(prose)
        _expect(lore=="tmb.lore.school.blade" and branch_lore.begins_with("tmb.lore.branch.blade."), "Dao skill is linked to school and branch lore: "+id)
        _expect(text_complete, "Vietnamese flavor, gameplay copy and counterplay contain no undriven numeric promise: "+id)
        unique_flavor[str(entry.get("flavor_vi",""))]=true
        unique_short[str(entry.get("short_description_vi",""))]=true
        var brief: Dictionary = entry.get("vfx",{}).get("production_brief",{})
        unique_motion[str(brief.get("motion_profile",""))]=true
        _expect(brief.get("phases",[]).size()==7 and str(brief.get("asset_status",""))=="NOT_PRESENT" and str(brief.get("render_capture_status",""))=="NOT_CAPTURED" and str(entry.get("qa_status",{}).get("gui",""))=="PENDING", "VFX stages exist while asset/render/UI are honestly pending: "+id)
        var tooltip: Dictionary = Presentation.build_mechanics_tooltip(skill)
        _expect(bool(tooltip.get("ok",false)) and str(tooltip.get("text","")).contains("Tầm") and str(tooltip.get("text","")).contains("hồi chiêu"), "mechanics tooltip is derived from this node's numeric catalog row: "+id)
    _expect(unique_flavor.size()==183 and unique_short.size()==183, "every Dao node has distinct player-facing flavor and short text")
    _expect(unique_motion.size()==183, "each Dao node has an individual VFX motion profile")

    var registry_loaded: Dictionary = Registry.load_catalogue()
    _expect(bool(registry_loaded.get("ok",false)), "D1 registry accepts Sword plus Dao: "+str(registry_loaded.get("errors",[])))
    if bool(registry_loaded.get("ok",false)):
        var registry: Dictionary = registry_loaded.get("data",{})
        var registry_nodes := 0
        for family in registry.get("families",[]):
            registry_nodes += family.get("nodes",[]).size()
        _expect(registry.get("families",[]).size()==175 and registry.get("paths",[]).size()==15 and registry_nodes==915, "registry contains four existing schools plus two gated candidate schools")
        _expect(int(registry.get("skills_s1_candidate_count",0))==183 and int(registry.get("skills_s2_candidate_count",0))==183, "Sword and Dao source-pending coverage recorded separately")
    _expect(HSC.skill_definitions().size()==915, "shared combat definition index contains 549 existing plus 366 gated candidates")
    _expect(not FeatureGates.is_enabled("blade_skill_combat") and not bool(FeatureGates.DEFAULT_FLAGS.get("blade_skill_combat",true)), "V6.3 and Dao combat remain OFF by default")
    _expect(str(Blade.can_learn(Blade.skill_definition("tmb.skill.blade.cuong_dao.active_01.human")).get("reason",""))=="skill_source_pending", "player learning is blocked until canonical Dao manual exists")
    _expect(not Blade.can_cast(_actor("off","disciple",Vector2(2,2)), "tmb.skill.blade.cuong_dao.active_01.human"), "actor cannot cast candidate Dao skill without explicit preview override")

    var csv_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
    var csv := FileAccess.open(csv_path,FileAccess.READ)
    _expect(csv!=null, "the authoritative 2,196-row ledger opens")
    if csv!=null:
        var audit := Presentation.validate_all36_ledger(csv.get_as_text(),source_rows.get("catalogues",{}),registry_loaded.get("data",{}))
        _expect(bool(audit.get("ok",false)), "ledger statuses and candidate graph join: "+str(audit.get("errors",[])))
        var metrics: Dictionary = audit.get("metrics",{})
        _expect(int(metrics.get("existing",0))==549 and int(metrics.get("candidate_gated",0))==366 and int(metrics.get("not_authored",0))==1281 and int(metrics.get("runtime_catalogue_ids",0))==915, "ledger counts separate source IDs, gated candidates and un-authored slots")

    _exercise_multihit()
    _exercise_mark_ownership()
    _exercise_mobility()
    _exercise_weakest_ally_guard_and_reflect()
    _finish()

func _exercise_multihit() -> void:
    var battle := MapBattleV2.new(81201)
    var caster := _actor("dao_cuong","disciple",Vector2(3.0,4.0))
    var target := _actor("dummy_cuong","enemy",Vector2(5.0,4.0))
    var skill_id := "tmb.skill.blade.cuong_dao.active_02.human"
    caster["v63_combat_branch_id"]="cuong_dao"
    caster["v63_skill_loadout"]=[skill_id]
    caster["v63_blade_combat_enabled"]=true
    battle.actors[caster["id"]]=caster
    battle.actors[target["id"]]=target
    var before := float(target["hp"])
    _expect(HSC.try_cast(battle,caster,target,false), "Cuồng Đao AI selects available multi-hit skill")
    var pending: Dictionary = caster.get("v63_pending_cast",{})
    _expect(not pending.is_empty(), "multi-hit cast creates normal Combat V2 cast record")
    if pending.is_empty():
        return
    battle.now=float(pending.get("ready",0.0))
    battle._release_casts()
    _expect(float(target["hp"])<before and _count_events(battle,"v63_blade_swing_hit",skill_id)==2, "two visual swing events correspond to two committed hit settlements")
    var all_hits_confirmed := true
    for event in _events(battle,"v63_blade_swing_hit",skill_id):
        all_hits_confirmed = all_hits_confirmed and float(event.get("damage",0.0))>0.0 and int(event.get("hit_count",0))==2
    _expect(all_hits_confirmed, "each repeated-hit cue carries actual damage and catalog hit count")
    var renderer := Vfx.new()
    renderer.consume_battle_events(battle)
    _expect(renderer._cue_skill_id==skill_id and renderer._cue_kind=="v63_blade_swing_hit", "Cuồng Đao renderer consumes the latest real per-hit event")
    renderer.free()

func _exercise_mark_ownership() -> void:
    var battle := MapBattleV2.new(81202)
    var caster := _actor("dao_tram","disciple",Vector2(3.0,4.0))
    var target := _actor("dummy_tram","enemy",Vector2(4.0,4.0))
    var mark_skill := "tmb.skill.blade.tram_phach_dao.ultimate.human"
    caster["v63_combat_branch_id"]="tram_phach_dao"
    caster["v63_skill_loadout"]=[mark_skill]
    caster["v63_blade_combat_enabled"]=true
    battle.actors[caster["id"]]=caster
    battle.actors[target["id"]]=target
    _expect(HSC.try_cast(battle,caster,target,false), "Trảm Phách selects its mark ultimate")
    var pending: Dictionary=caster.get("v63_pending_cast",{})
    if pending.is_empty():
        _expect(false,"mark cast record exists")
        return
    battle.now=float(pending.get("ready",0.0))
    battle._release_casts()
    var marks: Dictionary=target.get("v63_marks",{})
    var owned: Dictionary=marks.get(caster["id"],{})
    _expect(not owned.is_empty() and str(owned.get("school",""))=="blade" and float(owned.get("damage_factor",1.0))>1.0, "mark is created only after direct hit and remains owner scoped")
    var foreign_factor := HSC.marked_damage_factor(caster,target,battle.now,"tmb.skill.sword.basic.human")
    _expect(is_equal_approx(foreign_factor,1.0) and target.get("v63_marks",{}).has(caster["id"]), "a non-Dao attack neither amplifies nor consumes the Dao mark")
    var before := float(target["hp"])
    var dao_skill := "tmb.skill.blade.cuong_dao.active_01.human"
    var dao_factor := HSC.marked_damage_factor(caster,target,battle.now,dao_skill)
    _expect(dao_factor>1.0, "only an owner's Dao strike can use the bounded mark")
    battle._deal_direct(caster,target,0.15,"v63_skill",false,"metal",false,dao_skill)
    _expect(float(target["hp"])<before and not target.get("v63_marks",{}).has(caster["id"]) and _has_event(battle,"mark_consumed",dao_skill), "real Dao damage consumes the mark exactly once")
    var renderer := Vfx.new()
    renderer.consume_battle_events(battle)
    _expect(renderer._cue_skill_id==dao_skill, "Trảm mark/owner strike remains connected to the VFX event stream")
    renderer.free()

func _exercise_mobility() -> void:
    var battle := MapBattleV2.new(81203)
    var caster := _actor("dao_mobility","disciple",Vector2(2.0,5.0))
    var target := _actor("dummy_mobility","enemy",Vector2(8.0,5.0))
    var skill_id := "tmb.skill.blade.tram_phach_dao.active_04.human"
    caster["v63_combat_branch_id"]="tram_phach_dao"
    caster["v63_skill_loadout"]=[skill_id]
    caster["v63_blade_combat_enabled"]=true
    battle.actors[caster["id"]]=caster
    battle.actors[target["id"]]=target
    var origin: Vector2=caster["position"]
    _expect(HSC.try_cast(battle,caster,target,false), "mobility action is chosen only within catalog range")
    _expect(caster["position"]!=origin and _has_event(battle,"v63_mobility",skill_id), "mobility updates the real actor position and emits its VFX cue")
    var renderer := Vfx.new()
    renderer.consume_battle_events(battle)
    _expect(renderer._cue_skill_id==skill_id and renderer._cue_kind=="v63_mobility", "mobility renderer follows actual movement event")
    renderer.free()

func _exercise_weakest_ally_guard_and_reflect() -> void:
    var battle := MapBattleV2.new(81204)
    var caster := _actor("dao_guard","disciple",Vector2(4.0,4.0))
    var ally := _actor("dao_guard_ally","disciple",Vector2(5.0,4.0))
    var enemy := _actor("dao_guard_enemy","enemy",Vector2(4.0,6.0))
    caster["party_id"]="party_a"
    ally["party_id"]="party_a"
    caster["v63_combat_branch_id"]="tran_dao"
    caster["v63_skill_loadout"]=["tmb.skill.blade.tran_dao.active_01.immortal.b"]
    caster["v63_blade_combat_enabled"]=true
    ally["v63_blade_combat_enabled"]=true
    ally["v63_passive_ids"]=["tmb.skill.blade.tran_dao.passive_05.rare_passive.b"]
    ally["stats"]["attack"]=10.0
    ally["hp"]=60.0
    battle.actors[caster["id"]]=caster
    battle.actors[ally["id"]]=ally
    battle.actors[enemy["id"]]=enemy
    _expect(HSC.try_cast(battle,caster,enemy,false), "Trấn Đao chooses the lowest-health same-party ally")
    var pending: Dictionary=caster.get("v63_pending_cast",{})
    if pending.is_empty():
        _expect(false,"guard cast record exists")
        return
    _expect(str(pending.get("target_id",""))==str(ally["id"]), "Hồi Sơn target policy selects the weakest eligible party member")
    battle.now=float(pending.get("ready",0.0))
    battle._release_casts()
    _expect(float(ally.get("learned_guard_until",-1.0))>battle.now and float(ally.get("learned_guard_factor",1.0))<1.0, "bounded guard is applied to the selected ally")
    var enemy_before := float(enemy["hp"])
    var ally_before := float(ally["hp"])
    var committed := battle._deal_direct(enemy,ally,1.0,"basic",false,"metal",false)
    _expect(committed>0.0 and float(ally["hp"])<ally_before, "incoming damage goes through the canonical Combat V2 resolver")
    var reflect_events := _events(battle,"v63_blade_guard_reflect")
    _expect(float(enemy["hp"])<enemy_before and reflect_events.size()==1 and float(reflect_events[0].get("absorbed_damage",0.0))>0.0 and float(reflect_events[0].get("damage",0.0))>0.0, "Hồi Sơn reflects only a true absorbed portion and only emits after actual reflected damage")
    var renderer := Vfx.new()
    renderer.consume_battle_events(battle)
    _expect(renderer._cue_skill_id=="tmb.skill.blade.tran_dao.passive_05.rare_passive.b" and renderer._cue_kind=="v63_blade_guard_reflect", "guard reflect VFX follows the committed reflection event")
    renderer.free()

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances: Dictionary={}
    for element in ["metal","wood","water","fire","earth","lightning","wind","ice","yang","nether"]:
        resistances[element]=0.0
    return {
        "id":actor_id,"side":side,"role":"melee","position":position,
        "hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,
        "stats":{"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
        "resistances":resistances,"status_effects":{},"context_sources":[],
        "v63_combat_enabled":true,"v63_blade_combat_enabled":false,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_skill":0.0
    }

func _events(battle: MapBattleV2, event_type: String, skill_id: String="") -> Array:
    var result: Array=[]
    for raw in battle.events:
        var event: Dictionary=raw
        if str(event.get("type",""))==event_type and (skill_id.is_empty() or str(event.get("skill_id",""))==skill_id):
            result.append(event)
    return result

func _count_events(battle: MapBattleV2, event_type: String, skill_id: String="") -> int:
    return _events(battle,event_type,skill_id).size()

func _has_event(battle: MapBattleV2, event_type: String, skill_id: String="") -> bool:
    return _count_events(battle,event_type,skill_id)>0

func _contains_ascii_digit(value: String) -> bool:
    for index in range(value.length()):
        var code := value.unicode_at(index)
        if code>=48 and code<=57:
            return true
    return false

func _finish() -> void:
    if _failures>0:
        print("V63_S2_BLADE_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
        quit(1)
        return
    print("V63_S2_BLADE_RESULT PASS checks="+str(_checks)+" nodes=183 branches=3 families=35 mechanics=preview-only source=SOURCE_PENDING balance=CANDIDATE gate=OFF")
    quit(0)
