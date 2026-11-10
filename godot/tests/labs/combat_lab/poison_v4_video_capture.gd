extends SceneTree

# Independent official Godot 4.7.2 V4-only video QA; uses real V6.3 events.
# Separate from V3, no state writes or production asset promotion.
# Actual Combat Lab UI + V6.3 skill engine + MapBattleV2 committed events.
const LabScene := preload("res://labs/combat_lab/combat_lab.tscn")
const SKILLS := {
    "doc_cham": "tmb.skill.poison.doc_cham.active_01.human",
    "co_doc": "tmb.skill.poison.co_doc.active_01.human",
    "duoc_doc": "tmb.skill.poison.duoc_doc.active_01.human",
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
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", branch)
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
    lab.call("_set_auto", true)
    # Frames are captured by Godot's Movie Maker, not composed from still assets.
    # Normal _process(delta) advances the real 0.25s battle tick and interpolated VFX.
    for _frame in range(FRAMES):
        await process_frame
    var cast_count := _event_count(battle, "skill_cast", requested_skill)
    var release_count := _event_count(battle, "skill_release", requested_skill)
    var hit_count := _event_count(battle, "skill_hit", requested_skill)
    var impact_count := _event_count(battle, "v63_skill_hit", requested_skill)
    var tick_count := 0
    for raw in battle.events:
        if raw is Dictionary and str(raw.get("type", "")) in ["status_tick", "damage_tick"]:
            tick_count += 1
    print("POISON_V4_VIDEO_EVIDENCE branch=%s requested=%s frames=%d cast=%d release=%d hit=%d v63_hit=%d status_ticks=%d total_events=%d" % [
        branch, requested_skill, FRAMES, cast_count, release_count, hit_count, impact_count, tick_count, battle.events.size()])
    if cast_count <= 0 or release_count <= 0:
        _failed("No real matching skill_cast + skill_release; video cannot be accepted as a combat skill demonstration")
    print("POISON_V4_VIDEO_ZOOM=" + requested_zoom)
    print("POISON_V4_VIDEO_RESULT=" + ("PASS_EVENTS_ONLY" if errors == 0 else "FAIL") + " errors=" + str(errors))
    quit(0 if errors == 0 else 6)
