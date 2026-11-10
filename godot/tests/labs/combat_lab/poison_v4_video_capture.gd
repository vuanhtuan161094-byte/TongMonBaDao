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
    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", "duoc_doc" if branch == "duoc_heal" else branch)
    OS.set_environment("TMB_COMBAT_LAB_LINEAGE", "a")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "1")
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "single")
    OS.set_environment("TMB_COMBAT_LAB_ZOOM", requested_zoom)
    OS.set_environment("TMB_COMBAT_LAB_SCREENSHOT", "")
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
        var patient: Dictionary = battle.actors.get("lab_disciple_01", {})
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
    print("POISON_V4_VIDEO_RESULT=" + ("PASS_EVENTS_ONLY" if errors == 0 else "FAIL") + " errors=" + str(errors))
    quit(0 if errors == 0 else 6)
