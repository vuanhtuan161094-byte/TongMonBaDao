extends SceneTree

const Sword = preload("res://src/simulation/combat/v63_sword_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Registry = preload("res://src/simulation/combat/v63_content_registry.gd")
const SuccessorGraph = preload("res://src/simulation/combat/v63_successor_graph.gd")
const FeatureGates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> bool:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_S1_FAIL " + label)
    return condition

func _run() -> void:
    var sword_loaded: Dictionary = Sword.load_catalogue()
    _expect(bool(sword_loaded.get("ok",false)), "Sword runtime catalogue loads and validates")
    if not bool(sword_loaded.get("ok",false)):
        _finish()
        return
    var sword: Dictionary = sword_loaded["data"]
    var skills: Array = sword.get("skills",[])
    _expect(skills.size()==183 and int(sword.get("human_skill_count",0))==35 and int(sword.get("immortal_skill_count",0))==68 and int(sword.get("divine_skill_count",0))==80, "183 skills split Human/Immortal/Divine as specified")
    _expect(not bool(sword.get("enabled",true)) and str(sword.get("release_gate",""))=="OFF" and str(sword.get("balance_status",""))=="candidate_needs_qa", "candidate content remains disabled and unapproved")
    var unique_ids: Dictionary = {}
    var unique_names: Dictionary = {}
    var tiers := {"human":0,"immortal":0,"divine":0}
    var branches := {"ngu_kiem":0,"sat_kiem":0,"ho_kiem":0}
    var by_id: Dictionary = {}
    var presentation_loaded: Dictionary = Presentation.load_authoring_sources()
    _expect(bool(presentation_loaded.get("ok",false)), "S0 and S1 authoring sources load once")
    var manifest: Dictionary = presentation_loaded.get("manifest",{})
    var presentation_entries: Dictionary = manifest.get("entries",{})
    for raw in skills:
        var skill: Dictionary = raw
        var id := str(skill.get("id",""))
        var tier := str(skill.get("generation",skill.get("tier","")))
        var branch := str(skill.get("branch",""))
        _expect(not id.is_empty() and not unique_ids.has(id), "unique Sword ID: " + id)
        _expect(not str(skill.get("name","")).is_empty() and not unique_names.has(str(skill.get("name",""))), "unique Hán Việt name: " + id)
        unique_ids[id] = true
        unique_names[str(skill.get("name",""))] = true
        by_id[id] = skill
        tiers[tier] = int(tiers.get(tier,0))+1
        if branches.has(branch):
            branches[branch] = int(branches[branch])+1
        _expect(str(skill.get("school",""))=="sword" and str(skill.get("element",""))=="metal", "Sword identity and metal root: " + id)
        _expect(str(skill.get("source_codex_id","")).is_empty() and not bool(skill.get("archivable",true)) and str(skill.get("candidate_status",""))=="CANDIDATE_GATED_SOURCE_PENDING", "authentic source absence is represented, not faked: " + id)
        _expect(["damage","guard","mobility","passive","innate"].has(str(skill.get("effect",""))), "effect is handled by shared combat core: " + id)
        var presentation: Dictionary = presentation_entries.get(id,{})
        var phase_count := int(presentation.get("vfx",{}).get("production_brief",{}).get("phases",[]).size())
        _expect(not presentation.is_empty() and str(presentation.get("school_lore_id",""))=="tmb.lore.school.sword" and str(presentation.get("branch_lore_id","")).begins_with("tmb.lore.branch.sword."), "lore link is present: " + id)
        _expect(str(presentation.get("flavor_vi","")).strip_edges()!="" and str(presentation.get("short_description_vi","")).strip_edges()!="" and str(presentation.get("long_description_vi","")).strip_edges()!="" and str(presentation.get("counterplay_vi","")).strip_edges()!="", "player-facing flavor, function and counterplay are present: " + id)
        _expect(phase_count==7 and str(presentation.get("vfx",{}).get("production_brief",{}).get("asset_status",""))=="NOT_PRESENT" and str(presentation.get("qa_status",{}).get("gui",""))=="PENDING", "seven-phase VFX metadata is truthful; visual acceptance pending: " + id)
        var tooltip: Dictionary = Presentation.build_mechanics_tooltip(skill)
        _expect(bool(tooltip.get("ok",false)) and str(tooltip.get("text","")).contains("Tầm") and str(tooltip.get("text","")).contains("hồi chiêu"), "tooltip derives combat fields from this runtime row: " + id)
    _expect(tiers=={"human":35,"immortal":68,"divine":80}, "tier totals exact")
    _expect(branches=={"ngu_kiem":59,"sat_kiem":59,"ho_kiem":59}, "branch totals exact")
    _expect(Sword.validate_catalogue(sword).is_empty(), "all 183 nodes pass Sword catalog validation")
    var signatures := {
        "ngu_kiem":{"name":"Vạn Kiếm Quy Tông","effect":"damage"},
        "sat_kiem":{"name":"Nhất Kiếm Đoạn Thiên","effect":"damage"},
        "ho_kiem":{"name":"Thiên Cương Kiếm Giới","effect":"guard"}
    }
    var story_ids: Dictionary={}
    for branch in sword.get("branches",[]):
        var branch_id:=str(branch.get("id",""))
        story_ids[str(branch.get("story_vi",""))]=true
        var sig: Dictionary=signatures.get(branch_id,{})
        var signature_found:=false
        for skill in skills:
            if str(skill.get("branch",""))==branch_id and str(skill.get("name",""))==str(sig.get("name","")) and str(skill.get("effect",""))==str(sig.get("effect","")) and str(skill.get("slot",""))=="ultimate":
                signature_found=true
        _expect(signature_found, branch_id+" signature ultimate has its intended shared effect")
    _expect(story_ids.size()==3, "each Sword branch has an individual cultivation story")

    var registry_loaded: Dictionary = Registry.load_catalogue()
    _expect(bool(registry_loaded.get("ok",false)), "D1 registry validates with Sword")
    if bool(registry_loaded.get("ok",false)):
        var registry: Dictionary = registry_loaded["data"]
        var registry_nodes := 0
        for family in registry.get("families",[]):
            registry_nodes += family.get("nodes",[]).size()
        _expect(registry.get("families",[]).size()==210 and registry.get("paths",[]).size()==18 and registry_nodes==1098, "base registry remains unchanged and retains its approved family graph")
        _expect(int(registry.get("skills_s1_candidate_count",0))==183 and str(registry.get("skills_s1_candidate_source_status","")).contains("SOURCE_PENDING"), "registry keeps Sword source pending")
        var sword_family: Dictionary=Registry.lookup_family(registry,"tmb.skill.sword.ngu_kiem.active_01")
        var human_id:=str(sword_family.get("nodes",[])[0].get("id",""))
        var a_b_children: Array[String]=SuccessorGraph.children_of(sword_family,human_id)
        _expect(a_b_children.size()==2 and not SuccessorGraph.valid_active_selection(registry,a_b_children), "Ngự Kiếm A/B evolutions are mutually exclusive")
        if a_b_children.size()==2:
            _expect(SuccessorGraph.valid_active_selection(registry,[a_b_children[0]]), "single Sword lineage is selectable in the graph")
    _expect(HSC.skill_definitions().size()==1830, "shared runtime definitions include 549 existing plus 1,281 gated candidate IDs")

    var manifest_result: Dictionary = presentation_loaded
    if bool(manifest_result.get("ok",false)):
        var joined_manifest: Dictionary = manifest_result["manifest"]
        var catalogs: Dictionary = manifest_result["catalogues"]
        _expect(joined_manifest.get("entries",{}).size()==1285, "four original S0 samples retained beside six gated 183-node candidate schools")
        var integrated_registry: Dictionary = presentation_loaded.get("registry",{})
        _expect(Presentation.validate_sample_entries(joined_manifest,catalogs,integrated_registry).is_empty(), "all four S0 samples and all current presentation joins validate")
        var matrix_path := ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv")
        var file := FileAccess.open(matrix_path,FileAccess.READ)
        _expect(file!=null, "authoritative all36 ledger opens")
        if file!=null:
            var ledger := Presentation.validate_all36_ledger(file.get_as_text(),catalogs,integrated_registry)
            _expect(bool(ledger.get("ok",false)), "S1 candidate rows join exact runtime identity and full lineage: "+str(ledger.get("errors",[])))
            var metrics: Dictionary=ledger.get("metrics",{})
            _expect(int(metrics.get("existing",0))==549 and int(metrics.get("candidate_gated",0))==1281 and int(metrics.get("not_authored",0))==366 and int(metrics.get("runtime_catalogue_ids",0))==1830, "ledger reports source, candidate and remaining rows separately")
    _expect(not FeatureGates.is_enabled("sword_skill_combat") and not bool(FeatureGates.DEFAULT_FLAGS.get("sword_skill_combat",true)), "Sword combat feature gate defaults OFF")
    _expect(str(Sword.can_learn(Sword.skill_definition("tmb.skill.sword.ngu_kiem.active_01.human")).get("reason",""))=="skill_source_pending", "no Sword skill can be learned without an authentic manual")
    _expect(not Sword.can_cast({}, "tmb.skill.sword.ngu_kiem.active_01.human"), "actor must opt in explicitly before candidate combat")

    _exercise_ranged_hold()
    _exercise_damage_branch("ngu_kiem","tmb.skill.sword.ngu_kiem.active_01.human",Vector2(2.0,2.0),Vector2(9.0,2.0))
    _exercise_damage_branch("sat_kiem","tmb.skill.sword.sat_kiem.active_01.human",Vector2(2.0,6.0),Vector2(4.0,6.0))
    _exercise_guard_reflect()
    _finish()

func _exercise_ranged_hold() -> void:
    var battle:=MapBattleV2.new(760)
    var archer:=_actor("sword_ngu_ai","disciple",Vector2(2.0,2.0))
    var target:=_actor("sword_ngu_target","monster",Vector2(9.0,2.0))
    var skill_id:="tmb.skill.sword.ngu_kiem.active_01.human"
    archer["role"]="ranged"
    archer["v63_combat_branch_id"]="ngu_kiem"
    archer["v63_skill_loadout"]=[skill_id]
    archer["v63_skill_ready"]={skill_id:100.0}
    archer["next_attack"]=100.0
    battle.actors[archer["id"]]=archer
    battle.actors[target["id"]]=target
    battle.active=true
    var before: Vector2=archer["position"]
    battle.step()
    _expect(archer["position"]==before, "Ngự Kiếm AI holds maximum skill range instead of rushing during cooldown")

func _exercise_damage_branch(branch: String, skill_id: String, from: Vector2, to: Vector2) -> void:
    var battle := MapBattleV2.new(761)
    var caster := _actor("sword_"+branch,"disciple",from)
    var target := _actor("dummy_"+branch,"enemy",to)
    caster["v63_combat_branch_id"]=branch
    caster["v63_skill_loadout"]=[skill_id]
    if branch=="ngu_kiem":
        caster["role"]="ranged"
    battle.actors[caster["id"]]=caster
    battle.actors[target["id"]]=target
    var before:=float(target["hp"])
    _expect(HSC.try_cast(battle,caster,target,false), branch+" AI selected an available active skill")
    var pending: Dictionary = caster.get("v63_pending_cast",{})
    if pending.is_empty():
            return
    var desired_range := float(Sword.skill_definition(skill_id).get("range",0.0))
    if branch=="ngu_kiem":
        _expect(is_equal_approx(HSC.preferred_offensive_range(caster),desired_range), "Ngự Kiếm AI holds the catalogued ranged reach")
    battle.now=float(pending.get("ready",0.0))
    battle._release_casts()
    _expect(float(target["hp"])<before and _has_event(battle,"v63_skill_hit",skill_id) and _count_events(battle,"v63_skill_hit",skill_id)==1, branch+" cast creates exactly one runtime-confirmed HP hit")
    _expect(_has_event(battle,"skill_cast",skill_id) and _has_event(battle,"skill_release",skill_id), branch+" VFX cues are attached to cast and release")
    var renderer := Vfx.new()
    renderer.consume_battle_events(battle)
    var cast_definition: Dictionary=HSC.skill_definition(skill_id)
    _expect(renderer._cue_skill_id==skill_id and renderer._cue_animation_key==str(cast_definition.get("animation_key","")) and renderer._cue_vfx_key==str(cast_definition.get("vfx_key","")), branch+" event selects the matching catalog animation/VFX profile")
    renderer.free()

func _exercise_guard_reflect() -> void:
    var battle := MapBattleV2.new(762)
    var defender := _actor("sword_guard","disciple",Vector2(5.0,5.0))
    var foe := _actor("sword_foe","enemy",Vector2(6.0,5.0))
    var guard_id := "tmb.skill.sword.ho_kiem.active_01.human"
    var passive_id := "tmb.skill.sword.ho_kiem.passive_05.human"
    defender["v63_combat_branch_id"]="ho_kiem"
    defender["v63_skill_loadout"]=[guard_id]
    defender["v63_passive_ids"]=[passive_id]
    battle.actors[defender["id"]]=defender
    battle.actors[foe["id"]]=foe
    _expect(HSC.try_cast(battle,defender,foe,false), "Hộ Kiếm AI casts its bounded guard")
    var pending: Dictionary=defender.get("v63_pending_cast",{})
    if pending.is_empty():
            return
    battle.now=float(pending.get("ready",0.0))
    battle._release_casts()
    _expect(float(defender.get("learned_guard_until",-1.0))>battle.now, "Hộ Kiếm guard changes real combat state")
    var foe_before:=float(foe["hp"])
    var defender_before:=float(defender["hp"])
    var unguarded: Dictionary=CombatStatsV2.resolve_direct_hit(foe["stats"],defender["stats"],defender["resistances"],1.0,false,"metal",1.0,false)
    var unguarded_damage:=float(unguarded.get("damage",0.0))
    var received:=battle._deal_direct(foe,defender,1.0,"basic",false,"metal",false)
    _expect(received>0.0 and received<unguarded_damage and is_equal_approx(defender_before-float(defender["hp"]),received), "guard uses real bounded damage settlement and reduces the same packet")
    _expect(float(foe["hp"])<foe_before and _has_event(battle,"v63_sword_guard_reflect",passive_id), "Hồi Kiếm reflects only committed absorbed damage and names its source passive")
    var renderer:=Vfx.new()
    renderer.consume_battle_events(battle)
    _expect(renderer._cue_kind=="v63_sword_guard_reflect", "reflection cue is driven by the actual combat event")
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
        "v63_combat_enabled":true,"v63_sword_combat_enabled":true,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_skill":0.0
    }

func _count_events(battle: MapBattleV2, event_type: String, skill_id: String="") -> int:
    var count:=0
    for raw in battle.events:
        var event: Dictionary=raw
        if str(event.get("type",""))==event_type and (skill_id.is_empty() or str(event.get("skill_id",""))==skill_id):
            count+=1
    return count

func _has_event(battle: MapBattleV2, event_type: String, skill_id: String="") -> bool:
    for raw in battle.events:
        var event: Dictionary=raw
        if str(event.get("type",""))!=event_type:
            continue
        if skill_id.is_empty() or str(event.get("skill_id",""))==skill_id:
            return true
    return false

func _finish() -> void:
    if _failures>0:
        print("V63_S1_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
        quit(1)
        return
    print("V63_S1_RESULT PASS checks="+str(_checks)+" skills=183 branches=3 families=35 runtime=GATED vfx=CODE_DRAWN source=SOURCE_PENDING gate=OFF")
    quit(0)
