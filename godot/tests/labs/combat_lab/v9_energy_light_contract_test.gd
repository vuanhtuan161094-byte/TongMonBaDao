extends SceneTree
# Script parse + runtime hierarchy/effect contract, not visual acceptance.
const FXS = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const STAGE = preload("res://labs/combat_lab/combat_lab_v9_light_showcase.tscn")
const ARENA = preload("res://labs/combat_lab/combat_lab_arena.gd")
const SWORD_V10 = preload("res://labs/combat_lab/combat_lab_v10_sword_fx.gd")
const SWORD_V11 = preload("res://labs/combat_lab/combat_lab_v11_sword_fx.gd")
const SWORD_V12 = preload("res://labs/combat_lab/combat_lab_v12_sword_fx.gd")
const SWORD_V13 = preload("res://labs/combat_lab/combat_lab_v13_sword_fx.gd")
const SWORD_V14 = preload("res://labs/combat_lab/combat_lab_v14_sword_fx.gd")
const SWORD_V15 = preload("res://labs/combat_lab/combat_lab_v15_sword_fx.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_check")

func ensure(cond: bool, label: String) -> void:
    if not cond:
        failures += 1
        push_error("VFX09_FAIL " + label)

func _check() -> void:
    var shader := load("res://labs/combat_lab/combat_lab_v9_energy_light.gdshader") as Shader
    ensure(shader != null, "compiled additive shader exists")
    if shader != null:
        ensure(shader.code.contains("blend_add"), "light compositing is additive")
    # The sword is a presentation module, deliberately not a V6.3 hit.
    var sword_script: Script = load("res://labs/combat_lab/combat_lab_v10_sword_fx.gd") as Script
    ensure(sword_script != null, "V10 sword is loadable as Godot script")
    if sword_script != null:
        var methods: Array[String] = []
        for method in sword_script.get_script_method_list():
            methods.append(str(method.get("name", "")))
        ensure(methods.has("render") and methods.has("_sword") and methods.has("_aoe_seal"),
            "V10 includes pointed blade, AOE telegraph, gradual fade renderer")
    var sword11: Script = load("res://labs/combat_lab/combat_lab_v11_sword_fx.gd") as Script
    ensure(sword11 != null, "V11 sword code art loads")
    if sword11 != null:
        var methods11: Array[String] = []
        for method in sword11.get_script_method_list():
            methods11.append(str(method.get("name", "")))
        ensure(methods11.has("render") and methods11.has("_sword"),
            "V11 normal-alpha forged steel renderer and 12-blade choreography")
    var v11_glow: Shader = load("res://labs/combat_lab/combat_lab_v11_arcane_circle.gdshader") as Shader
    ensure(v11_glow != null, "V11 procedural bounded glow shader compiles")
    if v11_glow != null:
        ensure(v11_glow.code.contains("blend_add"), "bounded ritual overlay is additive")
        ensure(v11_glow.code.contains("uniform float progress"),
            "ritual glow time is externally controlled and HOLD deterministic")
    # Deterministic 3x3 sword choreography, not nine fake hit events.
    var sword12: Script = load("res://labs/combat_lab/combat_lab_v12_sword_fx.gd") as Script
    ensure(sword12 != null, "V12 3-wave sword GDScript loads")
    if sword12 != null:
        var methods12: Array[String] = []
        for method in sword12.get_script_method_list():
            methods12.append(str(method.get("name", "")))
        ensure(methods12.has("render") and methods12.has("_blade") and
            methods12.has("_aoe") and methods12.has("flight_timing"),
            "V12 sword, AOE and phased missile renderer exist")
    ensure(SWORD_V12.flight_timing(3).x > SWORD_V12.flight_timing(0).x and
        SWORD_V12.flight_timing(6).x > SWORD_V12.flight_timing(3).x,
        "V12 nine swords launch in 3 separated waves")
    ensure(SWORD_V12.blade_opacity(0, 0.61) > 0.0 and
        SWORD_V12.blade_opacity(0, 0.78) <= 0.01,
        "V12 swords remain visible after impact then gradually disappear")
    ensure(SWORD_V12.blade_opacity(7, 0.20) <= 0.01,
        "V12 sword wave three cannot appear during initial charge")
    # Explicit target binding in the circle-shaped Sword ultimate's
    # LAB preview: all visible enemies need not be hit by an AoE.
    var demo_mobs := [
        Vector2(854, 320), Vector2(966, 320),
        Vector2(854, 422), Vector2(966, 422)
    ]
    for primary in demo_mobs:
        var selected: Array = SWORD_V13.preview_circle_targets(
            demo_mobs, primary, Vector2(130, 120), 3)
        ensure(selected.size() == 3 and selected.has(primary),
            "V13 locked primary AoE binds to exactly three approved targets")
        var diagonal: Vector2 = demo_mobs[3 - demo_mobs.find(primary)]
        ensure(not selected.has(diagonal),
            "V13 fourth diagonal mob receives no synthetic visual hit")
    ensure(SWORD_V13.preview_circle_targets(
        demo_mobs, Vector2(5000,5000), Vector2(130,120), 3).is_empty(),
        "V13 cannot invent targets for an empty AoE")
    ensure(SWORD_V13.preview_circle_targets(
        demo_mobs, demo_mobs[0], Vector2(130,120), 0).is_empty(),
        "V13 zero target limit never returns even a preview victim")
    ensure(SWORD_V13.visibility_after_contact(0.66,0.60) > 0.0 and
        SWORD_V13.visibility_after_contact(0.85,0.60) <= 0.001,
        "V13 sword remains after impact then dissolves to zero")
    # V14 must inherit exact canonical display targets, never synthesize
    # hits, while introducing new qi silhouette, curved wake and shock.
    var sword14: Script = load("res://labs/combat_lab/combat_lab_v14_sword_fx.gd") as Script
    ensure(sword14 != null, "V14 original layered sword qi source parses")
    if sword14 != null:
        var methods14: Array[String] = []
        for method in sword14.get_script_method_list():
            methods14.append(str(method.get("name", "")))
        ensure(methods14.has("render") and methods14.has("_qi_blade") and
            methods14.has("_trail") and methods14.has("_impact") and
            methods14.has("_aoe") and methods14.has("_wave_arc"),
            "V14 has blade silhouette, flowing qi cloth, AOEs and targeted hit")
    ensure(SWORD_V14.preview_circle_targets(
        [Vector2(854, 320), Vector2(966, 320), Vector2(854, 422), Vector2(966, 422)],
        Vector2(854, 320), Vector2(130, 120), 3).size() == 3,
        "V14 leaves fourth diagonal monster outside actual preview")
    ensure(SWORD_V14.visibility_after_contact(0.80, 0.70) > 0.0 and
        SWORD_V14.visibility_after_contact(0.96, 0.70) <= 0.001,
        "V14 sword retains form after contact then dissolves")
    # VFX15 art contract: ghost-light sword, stop BEFORE contact and
    # replace projectile with a visual hit. No gameplay-authority changes.
    var sword15: Script = load("res://labs/combat_lab/combat_lab_v15_sword_fx.gd") as Script
    ensure(sword15 != null, "VFX15 ghost-light renderer loads")
    if sword15 != null:
        var methods15: Array[String] = []
        for method in sword15.get_script_method_list():
            methods15.append(str(method.get("name", "")))
        ensure(methods15.has("render") and methods15.has("_light_blade") and
            methods15.has("_flow_trail") and methods15.has("_impact_burst") and
            methods15.has("contact_point") and methods15.has("contact_time") and
            methods15.has("projectile_tip"),
            "VFX15 implements light-blade and pre-contact transform")
        ensure(not sword15.source_code.contains("metal facets") and
            not sword15.source_code.contains("guard -"),
            "VFX15 is qi light art, not V14 solid sword geometry")
    ensure(SWORD_V15.contact_time(0) < SWORD_V15.flight_timing(0).y and
        SWORD_V15.contact_time(8) < SWORD_V15.flight_timing(8).y,
        "VFX15 first and third volley finish BEFORE old hit plane")
    ensure(SWORD_V15.contact_time(0) < SWORD_V15.contact_time(3) and
        SWORD_V15.contact_time(3) < SWORD_V15.contact_time(6),
        "VFX15 retains three successive attack waves")
    var monster15 := Vector2(854.0, 320.0)
    var stopped_tip: Vector2 = SWORD_V15.contact_point(monster15,
        Vector2.RIGHT, 1.0)
    ensure(stopped_tip.x <= monster15.x - 28.0 and
        stopped_tip.y < monster15.y - 17.0,
        "VFX15 tip stops outside monster silhouette, above feet")
    var caster15 := Vector2(325.0, 393.0)
    var last_tip: Vector2 = SWORD_V15.projectile_tip(0, caster15,
        monster15, SWORD_V15.contact_time(0), 1.0)
    ensure(last_tip.distance_to(SWORD_V15.contact_point(monster15,
        (monster15 - (caster15 + Vector2(37.0,-68.0))).normalized(),1.0)) < 0.01,
        "VFX15 curved projectile terminates exactly at safe contact bound")
    ensure(SWORD_V15.pre_contact_opacity(0.70) > 0.8 and
        SWORD_V15.pre_contact_opacity(0.98) < 0.06,
        "VFX15 sword turns into light during final flight, never after impact")
    for primary15 in demo_mobs:
        var selected15: Array = SWORD_V15.preview_circle_targets(
            demo_mobs, primary15, Vector2(130,120),3)
        ensure(selected15.size() == 3 and selected15.has(primary15),
            "VFX15 preserves target-locked 3 of 4 AoE behavior")
    var fx := FXS.new()
    fx.custom_minimum_size = Vector2(1280, 720)
    root.add_child(fx)
    ensure(fx.material is ShaderMaterial, "energy control installs additive shader")
    ensure(fx.demo_school == "serpent", "default organic light serpent")
    fx.set_mode("sword")
    ensure(fx.demo_school == "sword", "sword energy light mode")
    ensure(fx.material == null, "V11 metal body uses normal alpha, not additive shader")
    fx.set_mode("serpent")
    ensure(fx.demo_school == "serpent", "serpent light mode")
    ensure(fx.material is ShaderMaterial, "switching back to serpent restores additive shader")
    fx.set_live_mode()
    ensure(not fx.demo_mode, "live mode reads committed cues and does not animate fake damage")
    fx.queue_free()
    var stage := STAGE.instantiate() as Control
    ensure(stage != null, "actual Godot demonstration scene instantiates")
    if stage != null:
        root.add_child(stage)
        ensure(stage.get_node_or_null("AdditiveEnergyVFX") != null,
            "scene has additive VFX CanvasItem")
        ensure(stage.get_node_or_null("SwordArcaneCharge") != null and
            stage.get_node_or_null("SwordArcaneAOE") != null,
            "V11 glow layers instantiate behind normal-blend forged swords")
        ensure(int(stage.get("preview_hit_count")) == 3,
            "V13 scene preview initially binds three of four monsters")
        var effect13: Control = stage.get_node_or_null("AdditiveEnergyVFX")
        if effect13 != null:
            effect13.call("set_mode", "sword")
        stage.call("_set_preview_primary", 0)
        var mouse13 := InputEventMouseButton.new()
        mouse13.button_index = MOUSE_BUTTON_LEFT
        mouse13.pressed = true
        mouse13.position = Vector2(966, 402)
        stage.call("_input", mouse13)
        ensure(int(stage.get("preview_primary_index")) == 3,
            "V13 synthetic mouse click on monster 4 changes locked AoE center")
        ensure(int(stage.get("preview_primary_index")) == 3 and
            int(stage.get("preview_hit_count")) == 3,
            "V13 clicking a different monster relocks primary and hit targets")
        ensure(effect13 != null and
            effect13.get("sword_preview_hits") is Array and
            (effect13.get("sword_preview_hits") as Array).has(Vector2(966, 422)),
            "V13 renderer targets selected mob, not fixed visual grid")
        stage.queue_free()
    var lab := ARENA.new()
    root.add_child(lab)
    ensure(lab.get_node_or_null("V9AdditiveLightingOnly") != null,
        "existing Combat Lab contains new opt-in light overlay")
    lab.set_v9_preview_enabled(true)
    ensure(lab.v9_preview_enabled and not lab.v8_preview_enabled,
        "live V9 disables painted-image V8")
    lab.set_v8_preview_enabled(true)
    ensure(lab.v8_preview_enabled and not lab.v9_preview_enabled,
        "switching back to V8 disables new shader overlay")
    lab.queue_free()
    var skill := V63HumanSkillCombatSystem.skill_definition(
        "tmb.skill.poison.co_doc.active_02.human")
    ensure(not skill.is_empty() and str(skill.get("effect", "")) == "poison",
        "light-only serpent maps onto authored Co Doc actual poison skill")
    print("VFX09_FOCUSED_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
