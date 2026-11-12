extends SceneTree
# Focused V8 static/runtime contract. A SceneTree test does not prove pixels.
const Fx = preload("res://labs/combat_lab/combat_lab_vfx_v8_jian_serpent.gd")
const Stage = preload("res://labs/combat_lab/combat_lab_v8_showcase.tscn")
const Brief = preload("res://labs/combat_lab/combat_lab_poison_skill_art_brief.gd")
var errors := 0

func _initialize() -> void:
    call_deferred("_test")

func _check(condition: bool, label: String) -> void:
    if not condition:
        errors += 1
        push_error("VFX_V8_CONTRACT_FAIL " + label)

func _test() -> void:
    var cobra_id := "tmb.skill.poison.co_doc.active_02.human"
    var cobra_skill: Dictionary = V63HumanSkillCombatSystem.skill_definition(cobra_id)
    _check(not cobra_skill.is_empty(), "Co Doc actual V6.3 skill exists")
    _check(str(Brief.profile(cobra_id).get("motif", "")) == "serpent_bind",
        "V8 snake is bound to existing real event motif")
    var fx_method_names: Array[String] = []
    for method in Fx.get_script_method_list():
        fx_method_names.append(str(method.get("name", "")))
    _check(fx_method_names.has("cobra") and fx_method_names.has("cobra_impact"),
        "separate snake flight and impact renderers exist")
    _check(fx_method_names.has("jian") and fx_method_names.has("sword_array"),
        "distinct full sword and array renderer exist")
    var scene := Stage.instantiate()
    _check(scene is Control, "Godot V8 scene is an actual Control")
    if scene != null:
        root.add_child(scene)
        _check(scene.get_child_count() >= 2, "V8 scene builds live UI controls")
        scene.call("_select", 1)
        _check(int(scene.get("selected")) == 1, "sword preview is selectable")
        scene.call("_select", 0)
        _check(int(scene.get("selected")) == 0, "serpent preview is selectable")
        scene.queue_free()
    print("VFX_V8_FOCUSED_RESULT=" + ("PASS" if errors == 0 else "FAIL") + " errors=" + str(errors))
    quit(0 if errors == 0 else 1)
