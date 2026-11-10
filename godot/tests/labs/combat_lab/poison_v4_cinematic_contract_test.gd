extends SceneTree

# Cinematic VFX is a presentation-only opt-in. The actual Lab still owns
# MapBattleV2 and the real 4v8 encounter; no HP, catalog or Save mutation.
const LabScene := preload("res://labs/combat_lab/combat_lab.tscn")
var checks := 0
var failures := 0

func _check(ok: bool, description: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("POISON_V4_CINEMATIC_FAIL " + description)

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    OS.set_environment("TMB_POISON_V4_PREVIEW", "1")
    OS.set_environment("TMB_POISON_V4_CINEMATIC", "1")
    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", "doc_cham")
    OS.set_environment("TMB_COMBAT_LAB_LINEAGE", "a")
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "poison_swarm")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "4")
    var lab: Control = LabScene.instantiate()
    root.add_child(lab)
    await process_frame
    await process_frame
    lab.call("_set_auto", false)
    var arena: Control = lab.get("arena")
    var size_now := arena.size
    var world_center := Vector2(18.0, 10.0)
    var center_screen: Vector2 = arena.call("_world_to_local", world_center)
    var edge_x: Vector2 = arena.call("_world_to_local", world_center + Vector2(3.0, 0.0))
    var edge_y: Vector2 = arena.call("_world_to_local", world_center + Vector2(0.0, 3.0))
    var radii: Vector2 = arena.call("_aoe_radii_px", 3.0)
    _check(absf(radii.x - (edge_x.x - center_screen.x)) < 0.01 and
        absf(radii.y - (edge_y.y - center_screen.y)) < 0.01,
        "radius-3 visual ellipse matches actual world-to-screen projection")
    _check(size_now.x >= 0.80 * float(root.size.x) and
        size_now.y >= 0.80 * float(root.size.y),
        "real battle viewport fills 80%+ of 1280x720 instead of 630px panel")
    var column := arena.get_parent()
    _check(not column.get_child(1).visible and not column.get_child(2).visible,
        "bottom buttons and debug HUD hidden, retained for logic")
    _check(bool(lab.call("_select_poison_skill",
        "tmb.skill.poison.doc_cham.active_03.human")), "real AoE skill selectable")
    lab.call("_load_selected_poison_skill")
    await process_frame
    var name_label: Label = lab.get("cinematic_skill_title")
    var mechanics_label: Label = lab.get("cinematic_mechanics")
    _check(name_label != null and name_label.text == "Bách Độc Tán Châm",
        "cinematic title updates to real equipped catalog skill after load")
    _check(mechanics_label != null and
        mechanics_label.text.contains("bán kính 3.0 ô") and
        mechanics_label.text.contains("tối đa 3 mục tiêu"),
        "cinematic title protects canonical AoE footprint and target cap")
    var battle: MapBattleV2 = lab.get("battle")
    _check(battle != null and battle.active, "canonical combat authority remains active")
    if battle != null:
        var ally_count := 0
        var monster_count := 0
        for raw_actor in battle.actors.values():
            var actor: Dictionary = raw_actor
            if str(actor.get("side", "")) == "disciple": ally_count += 1
            if str(actor.get("side", "")) == "monster": monster_count += 1
        _check(ally_count == 4 and monster_count == 8,
            "cinematic presentation keeps all four live disciples and eight actual monsters")
    print("POISON_V4_CINEMATIC_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    lab.queue_free()
    quit(0 if failures == 0 else 1)
