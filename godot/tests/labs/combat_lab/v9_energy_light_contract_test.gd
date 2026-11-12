extends SceneTree
# Script parse + runtime hierarchy/effect contract, not visual acceptance.
const FXS = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const STAGE = preload("res://labs/combat_lab/combat_lab_v9_light_showcase.tscn")
const ARENA = preload("res://labs/combat_lab/combat_lab_arena.gd")
const SWORD_V10 = preload("res://labs/combat_lab/combat_lab_v10_sword_fx.gd")
const SWORD_V11 = preload("res://labs/combat_lab/combat_lab_v11_sword_fx.gd")
const SWORD_V12 = preload("res://labs/combat_lab/combat_lab_v12_sword_fx.gd")
const SWORD_V13 = preload("res://labs/combat_lab/combat_lab_v13_sword_fx.gd")
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
        var diagonal: Vector2 = demo_mobs[3] if primary == demo_mobs[0] else demo_mobs[0]
        ensure(not selected.has(diagonal),
            "V13 fourth diagonal mob receives no synthetic visual hit")
    ensure(SWORD_V13.preview_circle_targets(
        demo_mobs, Vector2(5000,5000), Vector2(130,120), 3).is_empty(),
        "V13 cannot invent targets for an empty AoE")
    ensure(SWORD_V13.visibility_after_contact(0.66,0.60) > 0.0 and
        SWORD_V13.visibility_after_contact(0.85,0.60) <= 0.001,
        "V13 sword remains after impact then dissolves to zero")
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
        stage.call("_set_preview_primary", 3)
        ensure(int(stage.get("preview_primary_index")) == 3 and
            int(stage.get("preview_hit_count")) == 3,
            "V13 clicking a different monster relocks primary and hit targets")
        var effect13: Control = stage.get_node_or_null("AdditiveEnergyVFX")
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
