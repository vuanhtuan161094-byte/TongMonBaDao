extends SceneTree

# S9 Triệu Hồi candidate-preview regression. It does not enable V6.3 or claim
# approved manuals, balance, external VFX assets, artistic approval, or physical GUI acceptance.
const Summon = preload("res://src/simulation/combat/v63_summon_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")
const Snapshot = preload("res://src/simulation/combat/map_battle_snapshot_v2.gd")
const Vfx = preload("res://src/presentation/p3/v63_original_combat_vfx_v1.gd")
const WorldLayer = preload("res://src/presentation/p3/map_battle_world_layer_v2.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_S9_SUMMON_FAIL " + label)

func _run() -> void:
    var loaded := Summon.load_catalogue()
    _expect(bool(loaded.get("ok",false)),"Summon candidate catalogue validates with release gate OFF: "+str(loaded.get("errors",[])))
    if not bool(loaded.get("ok",false)):
        _finish()
        return
    var catalogue: Dictionary = loaded.get("data",{})
    var skills: Array = catalogue.get("skills",[])
    var joined := Presentation.load_authoring_sources()
    _expect(bool(joined.get("ok",false)),"S0–S9 registry, manifest, CSV and exact source pins join: "+str(joined.get("errors",[])))
    if not bool(joined.get("ok",false)):
        _finish()
        return
    var catalogues: Dictionary = joined.get("catalogues",{})
    var registry: Dictionary = joined.get("registry",{})
    var manifest: Dictionary = joined.get("manifest",{})
    _expect(catalogues.has("summon") and manifest.get("entries",{}).size()==1651,
        "Summon adds 183 authored presentation entries to the S0–S8 cumulative source")
    _expect(int(registry.get("school_count",0))==12 and int(registry.get("branch_count",0))==36
        and int(registry.get("skill_family_count",0))==420,
        "runtime registry reaches twelve schools, thirty-six branches and 420 families")
    _expect(HSC.skill_definitions().size()==2196 and HSC.branch_definitions().size()==36,
        "shared Combat V2 catalogue joins all 2,196 nodes and 36 branch definitions")
    _expect(Gates.DEFAULT_FLAGS.has("summon_skill_combat") and not Gates.is_enabled("summon_skill_combat")
        and Gates.all_disabled() and not bool(catalogue.get("enabled",true))
        and str(catalogue.get("release_gate",""))=="OFF",
        "V6.3 and Summon remain disabled by default")
    var blocked := Summon.can_learn(Summon.skill_definition("tmb.skill.summon.kiem_linh.active_01.human"))
    _expect(not bool(blocked.get("ok",true)) and str(blocked.get("reason",""))=="skill_source_pending",
        "missing authentic transmission cannot teach a candidate summon")
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var flavors: Dictionary = {}
    var shorts: Dictionary = {}
    var longs: Dictionary = {}
    var branches := {"kiem_linh":0,"linh_thu":0,"khoi_loi_ho_phap":0}
    var tiers := {"human":0,"immortal":0,"divine":0}
    for raw in skills:
        var skill: Dictionary = raw
        var id := str(skill.get("id",""))
        var entry: Dictionary = manifest.get("entries",{}).get(id,{})
        var brief: Dictionary = entry.get("vfx",{}).get("production_brief",{})
        ids[id] = true
        names[str(skill.get("name",""))] = true
        flavors[str(skill.get("flavor_vi",""))] = true
        shorts[str(skill.get("short_description_vi",""))] = true
        longs[str(skill.get("long_description_vi",""))] = true
        if branches.has(str(skill.get("branch",""))):
            branches[str(skill.get("branch",""))] += 1
        if tiers.has(str(skill.get("generation",""))):
            tiers[str(skill.get("generation",""))] += 1
        var identity: Dictionary = entry.get("identity",{})
        _expect(id.begins_with("tmb.skill.summon.") and str(skill.get("node_id",""))==id
            and str(identity.get("skill_id",""))==id and str(identity.get("family_id",""))==str(skill.get("family_id","")),
            "runtime/presentation ID and family join: "+id)
        _expect(not str(skill.get("source_codex_id","")) and not bool(skill.get("archivable",true))
            and str(skill.get("candidate_status",""))=="CANDIDATE_GATED_SOURCE_PENDING",
            "source remains honestly blocked: "+id)
        _expect(str(entry.get("display_name_vi",""))==str(skill.get("name",""))
            and str(entry.get("short_description_vi",""))==str(skill.get("short_description_vi",""))
            and str(entry.get("long_description_vi",""))==str(skill.get("long_description_vi","")),
            "Vietnamese identity and function text match runtime: "+id)
        _expect(str(skill.get("flavor_vi","")).length()>=50 and str(skill.get("flavor_vi","")).length()<=110,
            "individual xianxia flavor fits the contract: "+id)
        var phases: Array = brief.get("phases",[])
        if str(skill.get("effect",""))=="summon":
            var create_matches := 0
            var attack_matches := 0
            for phase in phases:
                if str(phase.get("phase",""))=="impact" and str(phase.get("event_type",""))=="v63_summon_created":
                    create_matches += 1
                if str(phase.get("phase",""))=="status" and str(phase.get("event_type",""))=="v63_summon_attack":
                    attack_matches += 1
            _expect(create_matches==1 and attack_matches==1,
                "summon VFX maps creation and owner-attributed attack to separate real events: "+id)
        var phase_names: Array[String] = []
        for phase in phases:
            phase_names.append(str(phase.get("phase","")))
            _expect(str(phase.get("production_note","")).contains("VFX_HOLD_OWNER_PER_SKILL_APPROVAL"),
                "each authored VFX phase retains the owner approval hold: "+id)
            if str(phase.get("phase","")) in ["telegraph","travel"] and str(phase.get("event_type",""))=="none":
                _expect(str(phase.get("production_note","")).contains("No independent event"),
                    "unavailable telegraph/travel cue is honestly suppressed: "+id)
        _expect(phase_names==["windup","telegraph","release","travel","impact","status","fade"]
            and str(brief.get("renderer_status",""))=="CODE_IMPLEMENTED_EVENT_BOUND"
            and str(brief.get("asset_status",""))=="NO_EXTERNAL_ASSET_CODE_DRAWN"
            and str(brief.get("render_capture_status",""))=="REQUIRED_BY_EXACT_SHA_TEST"
            and str(brief.get("visual_acceptance_status",""))=="PENDING_OWNER"
            and str(brief.get("production_hold",""))=="VFX_HOLD_OWNER_PER_SKILL_APPROVAL"
            and str(brief.get("provenance","")).begins_with("CODE_DRAWN_EVENT_SPEC")
            and brief.get("renderer_paths",[]).size()==2,
            "seven-phase VFX maps to an actual code renderer without claiming owner art approval: "+id)
    _expect(ids.size()==183 and names.size()==183 and flavors.size()==183 and shorts.size()==183 and longs.size()==183,
        "all 183 names, flavor, short and long descriptions are individually authored")
    _expect(branches=={"kiem_linh":59,"linh_thu":59,"khoi_loi_ho_phap":59}
        and tiers=={"human":35,"immortal":68,"divine":80},
        "three branches each contain 59 nodes with the required generation split")
    await _exercise_branch("kiem_linh","blade_spirit")
    await _exercise_branch("linh_thu","covenant_beast")
    await _exercise_branch("khoi_loi_ho_phap","guardian_construct")
    _finish()

func _exercise_branch(branch_id: String, expected_form: String) -> void:
    var skill_id := "tmb.skill.summon.%s.active_01.human" % branch_id
    var battle := MapBattleV2.new(91009+branch_id.length())
    battle.encounter_id = "s9_"+branch_id
    battle.active = true
    battle.outcome = "fighting"
    var owner := _actor("owner_"+branch_id,"disciple",Vector2(2,3))
    owner["party_id"] = "party_"+branch_id
    owner["v63_summon_combat_enabled"] = true # explicit test-only candidate preview
    owner["v63_skill_loadout"] = [skill_id]
    owner["v63_skill_ready"] = {}
    var enemy := _actor("enemy_"+branch_id,"monster",Vector2(5,3))
    enemy["hp"] = 10000.0
    enemy["max_hp"] = 10000.0
    enemy["stats"]["max_hp"] = 10000.0
    battle.actors[str(owner.get("id",""))] = owner
    battle.actors[str(enemy.get("id",""))] = enemy
    var skill := Summon.skill_definition(skill_id)
    var default_gated_actor := _actor("default_gate_"+branch_id,"disciple",Vector2(2,3))
    _expect(not Summon.can_cast(default_gated_actor,skill_id),
        "Summon skill stays unavailable when the actor gate has no explicit preview override: "+branch_id)
    var tooltip := Presentation.build_mechanics_tooltip(skill)
    _expect(bool(tooltip.get("ok",false)) and str(tooltip.get("text","")).contains("Actor khế ước")
        and str(tooltip.get("text","")).contains("thời hạn hữu hạn"),
        "tooltip derives form, duration, HP and attack values from the summon profile")
    battle.step()
    var pending: Dictionary = owner.get("v63_pending_cast",{})
    var started := not pending.is_empty()
    _expect(started,"MapBattle simulation AI starts the authored summon cast for "+branch_id)
    if not started:
        return
    var cast_vfx := Vfx.new()
    cast_vfx.consume_battle_events(battle)
    _expect(str(cast_vfx.get("_cue_kind"))=="skill_cast" and str(cast_vfx.get("_cue_skill_id"))==skill_id,
        "windup animation is driven by the actual Combat V2 skill_cast event for "+branch_id)
    cast_vfx.free()
    _expect(float(pending.get("ready",-1.0))>=battle.now,"simulation AI cast has a real Combat V2 deadline for "+branch_id)
    battle.now = float(pending.get("ready",battle.now))
    battle._release_casts()
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    var summons: Array[Dictionary] = []
    for actor_id in actor_ids:
        var actor: Dictionary = battle.actors[actor_id]
        if bool(actor.get("is_v63_summon",false)) and str(actor.get("summon_owner_id",""))==str(owner.get("id","")):
            summons.append(actor)
    _expect(summons.size()==1,"one bounded actor is created by the released cast for "+branch_id)
    if summons.is_empty():
        return
    var summon: Dictionary = summons[0]
    _expect(str(summon.get("summon_form",""))==expected_form
        and float(summon.get("summon_expires_at",0.0))>battle.now
        and float(summon.get("hp",0.0))>0.0
        and str(summon.get("summon_skill_id",""))==skill_id,
        "form, HP, finite lifetime and source skill are real actor state for "+branch_id)
    var created_vfx := Vfx.new()
    created_vfx.consume_battle_events(battle)
    var created_event: Dictionary = created_vfx.get("_cue_event")
    _expect(str(created_vfx.get("_cue_kind"))=="v63_summon_created"
        and str(created_event.get("summon_id",""))==str(summon.get("id","")),
        "spawn animation follows the created actor event, not a cast request or predicted target: "+branch_id)
    created_vfx.free()
    _expect(battle._count_alive("disciple")==1,
        "summoned actor does not inflate the canonical disciple/player count for "+branch_id)
    _expect(not Summon.should_cast(battle,owner,skill),
        "per-owner actor cap prevents duplicate summon cast for "+branch_id)
    var hp_before := float(enemy.get("hp",0.0))
    for tick in range(12):
        battle.step()
        if float(enemy.get("hp",0.0))<hp_before:
            break
    _expect(float(enemy.get("hp",0.0))<hp_before,
        "autonomous summon simulation routes a real attack through MapBattle Combat V2 for "+branch_id)
    var attack_events: Array = []
    for event in battle.events:
        if str(event.get("type",""))=="v63_summon_attack" and str(event.get("owner_id",""))==str(owner.get("id","")):
            attack_events.append(event)
    _expect(not attack_events.is_empty() and str(attack_events[0].get("skill_id",""))==skill_id,
        "attack receipt is attributed to owner and source skill, without an independent reward")
    var vfx := Vfx.new()
    vfx.consume_battle_events(battle)
    _expect(str(vfx.get("_cue_kind"))=="v63_summon_attack"
        and str(vfx.get("_cue_skill_id"))==skill_id,
        "actual summon Combat V2 attack event reaches the in-game VFX renderer for "+branch_id)
    _expect(vfx.summon_branch_for_skill(skill_id)==branch_id,
        "skill ID selects the branch-specific code-drawn VFX family for "+branch_id)
    var world := WorldLayer.new()
    _expect(world.summon_visual_family(expected_form)==branch_id,
        "world renderer draws the matching summoned actor silhouette for "+branch_id)
    vfx.free()
    world.free()
    await _capture_godot_vfx_frame(battle,branch_id,skill_id,expected_form)
    if branch_id=="kiem_linh":
        var saved := Snapshot.save(battle)
        var restored := Snapshot.load(saved)
        _expect(bool(restored.get("ok",false)),"cold battle snapshot accepts bounded summon actor: "+str(restored.get("reason","")))
        if bool(restored.get("ok",false)):
            var restored_battle: MapBattleV2 = restored.get("battle")
            var restored_count := 0
            for actor_value in restored_battle.actors.values():
                if bool(actor_value.get("is_v63_summon",false)):
                    restored_count += 1
                    _expect(str(actor_value.get("summon_owner_id",""))==str(owner.get("id",""))
                        and is_equal_approx(float(actor_value.get("summon_expires_at",0.0)),float(summon.get("summon_expires_at",0.0))),
                        "cold snapshot preserves actor owner and finite expiry")
            _expect(restored_count==1,"cold snapshot preserves exactly one summoned actor")
        var duplicate_snapshot: Dictionary = saved.duplicate(true)
        var snapshot_payload: Variant = bytes_to_var(Marshalls.base64_to_raw(str(saved.get("payload",""))))
        var duplicate_row: Dictionary = {}
        if snapshot_payload is Dictionary:
            for row in snapshot_payload.get("actors",[]):
                if bool(row.get("is_v63_summon",false)):
                    duplicate_row = row.duplicate(true)
                    break
        if not duplicate_row.is_empty():
            duplicate_row["id"] = str(duplicate_row.get("id",""))+"_duplicate"
            snapshot_payload["actors"].append(duplicate_row)
            duplicate_snapshot["payload"] = Marshalls.raw_to_base64(var_to_bytes(snapshot_payload))
            var duplicate_restore := Snapshot.load(duplicate_snapshot)
            _expect(not bool(duplicate_restore.get("ok",true)) and str(duplicate_restore.get("reason",""))=="summon_owner_actor_cap_exceeded",
                "cold snapshot rejects duplicate live summon for a single owner")
        else:
            _expect(false,"cold snapshot contains the summon row needed for the duplicate-owner test")
        summon["hp"] = 1.0
        battle._deal_direct(enemy,summon,100.0,"basic",false,"metal",false)
        _expect(float(summon.get("hp",1.0))<=0.0 and battle.downed_disciples==0,
            "real Combat V2 damage can end a summon without counting disciple Injury/HP0")
        var remaining := Summon._living_summons(battle)
        _expect(remaining==0,"downed summon immediately leaves the active actor budget")
        Summon.process_summons(battle)
        _expect(not battle.actors.has(str(summon.get("id",""))),
            "downed summon is removed at the next deterministic summon tick")
        var expiry_vfx := Vfx.new()
        expiry_vfx.consume_battle_events(battle)
        var expiry_event: Dictionary = expiry_vfx.get("_cue_event")
        _expect(str(expiry_vfx.get("_cue_kind"))=="v63_summon_expired"
            and str(expiry_event.get("summon_id",""))==str(summon.get("id","")),
            "dismissal animation follows the actual expiry/removal event: "+branch_id)
        expiry_vfx.free()

func _capture_godot_vfx_frame(battle: MapBattleV2, branch_id: String, skill_id: String, expected_form: String) -> void:
    var root := get_root()
    root.size = Vector2i(1280,720)
    var start_event_count := battle.events.size()
    var world := WorldLayer.new()
    world.stage_rect = Rect2(Vector2(35,35),Vector2(1210,650))
    root.add_child(world)
    world.attach_session(battle)
    # Advance the same battle until its summon actor produces another actual Combat V2 event.
    var attack_event := {}
    for tick in range(20):
        battle.step()
        for index in range(start_event_count,battle.events.size()):
            var event: Dictionary = battle.events[index]
            if str(event.get("type",""))=="v63_summon_attack" and str(event.get("form",""))==expected_form:
                attack_event = event
                break
        if not attack_event.is_empty():
            break
    _expect(not attack_event.is_empty() and str(attack_event.get("skill_id",""))==skill_id,
        "render capture is driven by an additional real simulation attack event: "+branch_id)
    if attack_event.is_empty():
        world.free()
        await process_frame
        return
    world.refresh_from_authority()
    var event_only_battle := MapBattleV2.new(91098)
    event_only_battle.events = [attack_event.duplicate(true)]
    var vfx := Vfx.new()
    vfx.position = Vector2(920,50)
    vfx.size = Vector2(300,220)
    root.add_child(vfx)
    vfx.consume_battle_events(event_only_battle)
    var rendered_event: Dictionary = vfx.get("_cue_event")
    _expect(str(vfx.get("_cue_kind"))=="v63_summon_attack"
        and str(rendered_event.get("target_id",""))==str(attack_event.get("target_id","")),
        "render overlay consumes the same target-bound attack event: "+branch_id)
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    _expect(not image.is_empty() and image.get_width()==1280 and image.get_height()==720,
        "Godot viewport returned a rendered 1280x720 VFX frame")
    if image.is_empty():
        world.free()
        vfx.free()
        await process_frame
        return
    var output_dir := ProjectSettings.globalize_path("res://outputs")
    var dir_error := DirAccess.make_dir_recursive_absolute(output_dir)
    _expect(dir_error==OK or dir_error==ERR_ALREADY_EXISTS,"Godot VFX capture output directory exists")
    var output_path := ProjectSettings.globalize_path("res://outputs/v63_s9_summon_"+branch_id+"_vfx.png")
    var save_error := image.save_png(output_path)
    _expect(save_error==OK and FileAccess.file_exists(output_path),
        "Godot writes real rendered branch VFX to the CI artifact path: "+branch_id)
    if save_error==OK:
        print("V63_S9_VFX_RENDER_CAPTURE path="+output_path+" size=1280x720 branch="+branch_id+" event=v63_summon_attack target="+str(attack_event.get("target_id",""))+" renderer=GodotViewport")
    world.free()
    vfx.free()
    await process_frame

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances := {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,
        "lightning":0.0,"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
    var actor := {"id":actor_id,"side":side,"party_id":"","role":"ranged","position":position,
        "hp":200.0,"max_hp":200.0,"range":1.8,"move_speed":2.0,"tier":"normal",
        "stats":{"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,"crit_chance":0.0,
            "crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,"lifesteal":0.0,
            "lifesteal_reduction":0.0},
        "resistances":resistances,"status_effects":{},"context_sources":[],
        "v63_combat_enabled":true,"v63_summon_combat_enabled":false,
        "v63_skill_ready":{},"v63_skill_loadout":[],"v63_passive_ids":[],
        "v63_combat_clock":-1.0,"next_basic":0.0,"next_skill":0.0,"basic_ratio":1.0,
        "basic_interval":1.6,"guard_until":-1.0,"learned_guard_factor":1.0,
        "learned_guard_until":-1.0,"hunt_policy":"auto","hunt_after_move":"auto","hunt_radius":8.0,
        "home_position":position,"move_order_position":position,"move_order_active":false}
    if side=="monster":
        actor["race_id"]="yeu_thu"
    return actor

func _finish() -> void:
    if _failures>0:
        print("V63_S9_SUMMON_RESULT FAIL checks="+str(_checks)+" failures="+str(_failures))
        quit(1)
        return
    print("V63_S9_SUMMON_RESULT PASS checks="+str(_checks)+" nodes=183 branches=3 runtime_actor_cap=6 release_gate=OFF vfx=CODE_DRAWN_RENDER_TESTED_OWNER_VISUAL_PENDING gui=PENDING")
    quit(0)
