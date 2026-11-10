extends SceneTree

# Independent official Godot 4.7.2 V4-only video QA; uses real V6.3 events.
# Separate from V3, no state writes or production asset promotion.
# Actual Combat Lab UI + V6.3 skill engine + MapBattleV2 committed events.
const LabScene := preload("res://labs/combat_lab/combat_lab.tscn")
const SKILLS := {
    "doc_cham": "tmb.skill.poison.doc_cham.active_01.human",
    "co_doc": "tmb.skill.poison.co_doc.active_01.human",
    "duoc_doc": "tmb.skill.poison.duoc_doc.active_01.human",
    "duoc_heal": "tmb.skill.poison.duoc_doc.active_02.human",
    "swarm_aoe": "tmb.skill.poison.doc_cham.active_03.human",
    "co_swarm": "tmb.skill.poison.co_doc.active_03.human",
}
const FRAMES := 192
var errors := 0

func _initialize() -> void:
    call_deferred("_run")

func _failed(message: String) -> void:
    errors += 1
    push_error("POISON_V4_VIDEO_FAIL " + message)

func _event_count(battle: MapBattleV2, kind: String, skill_id: String) -> int:
    var count := 0
    for raw in battle.events:
        if not raw is Dictionary:
            continue
        var row: Dictionary = raw
        var event_skill := str(row.get("skill_id", row.get("source_skill_id", "")))
        if str(row.get("type", "")) == kind and event_skill == skill_id:
            count += 1
    return count

func _run() -> void:
    var branch := OS.get_environment("TMB_POISON_V4_BRANCH").strip_edges().to_lower()
    var requested_zoom := OS.get_environment("TMB_POISON_V4_ZOOM").strip_edges()
    if not requested_zoom in ["1", "2", "4", "6"]:
        _failed("Invalid V4 zoom " + requested_zoom)
        quit(7)
        return
    OS.set_environment("TMB_POISON_V4_PREVIEW", "1")
    if not SKILLS.has(branch):
        _failed("Unknown branch " + branch)
        quit(2)
        return
    var requested_skill: String = SKILLS[branch]
    var swarm_mode := branch in ["swarm_aoe", "co_swarm"]
    var heal_ally_mode := branch == "duoc_heal"
    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    var desired_branch := "co_doc" if branch == "co_swarm" else ("doc_cham" if swarm_mode else ("duoc_doc" if heal_ally_mode else branch))
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", desired_branch)
    OS.set_environment("TMB_COMBAT_LAB_LINEAGE", "a")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "4" if swarm_mode else ("2" if heal_ally_mode else "1"))
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "poison_swarm" if swarm_mode else "single")
    OS.set_environment("TMB_COMBAT_LAB_ZOOM", requested_zoom)
    OS.set_environment("TMB_COMBAT_LAB_SCREENSHOT", "")
    OS.set_environment("TMB_POISON_V4_CINEMATIC", "1")
    var lab := LabScene.instantiate()
    root.add_child(lab)
    await process_frame
    lab.call("_set_auto", false)
    if not bool(lab.call("_select_poison_skill", requested_skill)):
        _failed("Skill absent from canonical catalog: " + requested_skill)
        quit(3)
        return
    lab.call("_load_selected_poison_skill")
    await process_frame
    lab.call("_set_auto", false)
    var battle: MapBattleV2 = lab.get("battle")
    if battle == null or not battle.active:
        _failed("MapBattleV2 never started real Lab encounter")
        quit(4)
        return
    # Isolated in-memory QA fixture only: a wounded ally is required for the
    # canonical heal consumer; the heal amount itself MUST come from V6.3.
    if branch == "duoc_heal":
        # Wound an actual QA ally rather than the caster so the jade
        # transfer ribbon has two distinct REAL in-world endpoints.
        var patient: Dictionary = battle.actors.get("lab_disciple_02", {})
        if patient.is_empty() or float(patient.get("max_hp", 0.0)) <= 0.0:
            _failed("No canonical disciple to create a wounded QA-only fixture")
            quit(8)
            return
        patient["hp"] = float(patient["max_hp"]) * 0.45
    var preview: OptionButton = lab.get("skill_preview_option")
    var found := false
    if preview != null:
        for index in range(preview.item_count):
            if str(preview.get_item_metadata(index)) == requested_skill:
                preview.select(index)
                found = true
                break
    if not found:
        _failed("Skill not equipped into active/ultimate preview slot: " + requested_skill)
        quit(5)
        return
    lab.call("_preview_selected_skill")
    # Only the V4 movie camera gets a presentation-only focus. At 4x/6x,
    # world-centered framing clipped the caster, target and impact out of view.
    var movie_caster := ""
    var movie_target := ""
    for raw_id in battle.actors.keys():
        var actor: Dictionary = battle.actors[raw_id]
        if str(actor.get("side", "")) == "disciple" and movie_caster.is_empty():
            movie_caster = str(raw_id)
        elif str(actor.get("side", "")) == "monster" and movie_target.is_empty():
            movie_target = str(raw_id)
    if heal_ally_mode:
        movie_caster = "lab_disciple_01"
        movie_target = "lab_disciple_02"
    if movie_caster.is_empty() or movie_target.is_empty():
        _failed("Cannot frame real caster and target for movie")
        quit(9)
        return
    var movie_arena: Control = lab.get("arena")
    # Swarm needs a static wide lens to display all four independent casters.
    # The one-caster cinematic focus is reserved for single-skill closeups.
    if not swarm_mode:
        movie_arena.call("set_v4_showcase_focus", movie_caster, movie_target)
    # QA-only isolation. The Lab preview temporarily equips this skill and
    # restores the full loadout. AUTO would then emit unrelated spells, making
    # the movie look like the wrong Độc Châm/Cổ Độc/Dược Độc effect.
    # Keep only the selected canonical V6.3 skill for every Lab disciple.
    # No combat math, Save or live player loadout is changed.
    for actor_id in battle.actors.keys():
        var observed: Dictionary = battle.actors[actor_id]
        if str(observed.get("side", "")) == "disciple":
            observed["v63_skill_loadout"] = [requested_skill]
            observed["skill_loadout"] = []
    # Isolated growth visualization: compare the SAME skill at novice and
    # genuine Human mastery XII, with 100 learned casts per level. This fixture
    # never enters SaveService/production and never grants extra hit targets.
    var mastery_mode := OS.get_environment("TMB_POISON_V4_MASTERY_QA")
    if mastery_mode == "master":
        for actor_id in battle.actors.keys():
            var actor: Dictionary = battle.actors[actor_id]
            if str(actor.get("side", "")) != "disciple":
                continue
            var linked := DiscipleState.new()
            linked.id = StringName(str(actor_id))
            linked.v63_learned_skill_nodes[requested_skill] = {
                "source_codex_id":str(V63HumanSkillCombatSystem.skill_definition(requested_skill).get("source_codex_id", "")),
                "learned_tick":0, "mastery_xp":1100.0, "level":12,
                "branch_id":desired_branch
            }
            actor["linked_disciple"] = linked
            var actor_stats: Dictionary = actor.get("stats", {}).duplicate(true)
            actor_stats["cast_speed"] = 1.0
            actor_stats["attack_speed"] = 1.0
            actor["stats"] = actor_stats
        print("POISON_V4_VIDEO_MASTERY=master level=12 cast_speed=1.0 QA_ONLY")
    lab.call("_set_auto", true)
    # Frames are captured by Godot's Movie Maker, not composed from still assets.
    # Normal _process(delta) advances the real 0.25s battle tick and interpolated VFX.
    for _frame in range(FRAMES):
        await process_frame
    var cast_count := _event_count(battle, "skill_cast", requested_skill)
    var release_count := _event_count(battle, "skill_release", requested_skill)
    var hit_count := _event_count(battle, "skill_hit", requested_skill)
    var impact_count := _event_count(battle, "v63_skill_hit", requested_skill)
    var unrelated_casts := 0
    for raw_event in battle.events:
        if raw_event is Dictionary and str(raw_event.get("type", "")) == "skill_cast":
            var observed_skill := str(raw_event.get("skill_id", ""))
            if observed_skill != requested_skill:
                unrelated_casts += 1
    if unrelated_casts > 0:
        _failed("QA movie contains %d unrelated skill_cast IDs" % unrelated_casts)
    var heal_count := _event_count(battle, "heal", requested_skill)
    if swarm_mode:
        var party_count := 0
        var monster_count := 0
        for observed_id in battle.actors.keys():
            var observed: Dictionary = battle.actors[observed_id]
            if str(observed.get("side", "")) == "disciple": party_count += 1
            if str(observed.get("side", "")) == "monster": monster_count += 1
        if party_count != 4 or monster_count != 8:
            _failed("Swarm film has wrong canonical actor counts")
        if impact_count <= 0:
            _failed("Swarm film has no real AoE V6.3 target hit")
        print("POISON_V4_SWARM_REAL_ACTORS party=%d monsters=%d skill_hits=%d" % [
            party_count, monster_count, impact_count])
    if branch == "duoc_heal" and heal_count <= 0:
        _failed("Canonical V6.3 heal event not observed for wounded QA ally")
    var tick_count := 0
    for raw in battle.events:
        if raw is Dictionary and str(raw.get("type", "")) in ["status_tick", "damage_tick"]:
            tick_count += 1
    print("POISON_V4_VIDEO_EVIDENCE branch=%s requested=%s frames=%d cast=%d release=%d hit=%d v63_hit=%d status_ticks=%d heals=%d total_events=%d" % [
        branch, requested_skill, FRAMES, cast_count, release_count, hit_count, impact_count, tick_count, heal_count, battle.events.size()])
    if cast_count <= 0 or release_count <= 0:
        _failed("No real matching skill_cast + skill_release; video cannot be accepted as a combat skill demonstration")
    print("POISON_V4_VIDEO_ZOOM=" + requested_zoom)
    if mastery_mode == "master":
        print("POISON_V4_VIDEO_MASTERY_RESULT=MASTER_LEVEL_12_FIXTURE")
    print("POISON_V4_VIDEO_RESULT=" + ("PASS_EVENTS_ONLY" if errors == 0 else "FAIL") + " errors=" + str(errors))
    quit(0 if errors == 0 else 6)
