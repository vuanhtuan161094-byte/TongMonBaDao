extends SceneTree
# Script parse + runtime hierarchy/effect contract, not visual acceptance.
const FXS = preload("res://labs/combat_lab/combat_lab_v9_energy_fx.gd")
const STAGE = preload("res://labs/combat_lab/combat_lab_v9_light_showcase.tscn")
const ARENA = preload("res://labs/combat_lab/combat_lab_arena.gd")
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
    var fx := FXS.new()
    fx.custom_minimum_size = Vector2(1280, 720)
    root.add_child(fx)
    ensure(fx.material is ShaderMaterial, "energy control installs additive shader")
    ensure(fx.demo_school == "serpent", "default organic light serpent")
    fx.set_mode("sword")
    ensure(fx.demo_school == "sword", "sword energy light mode")
    fx.set_mode("serpent")
    ensure(fx.demo_school == "serpent", "serpent light mode")
    fx.set_live_mode()
    ensure(not fx.demo_mode, "live mode reads committed cues and does not animate fake damage")
    fx.queue_free()
    var stage := STAGE.instantiate() as Control
    ensure(stage != null, "actual Godot demonstration scene instantiates")
    if stage != null:
        root.add_child(stage)
        ensure(stage.get_node_or_null("AdditiveEnergyVFX") != null,
            "scene has additive VFX CanvasItem")
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
