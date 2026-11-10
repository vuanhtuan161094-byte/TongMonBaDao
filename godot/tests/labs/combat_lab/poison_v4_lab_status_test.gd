extends SceneTree

# Rejected preview != invalid fixture. Avoid a false "configuration invalid"
# banner in the genuine Godot Combat Lab movie.
const LabScene := preload("res://labs/combat_lab/combat_lab.tscn")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, what: String) -> void:
    if not ok:
        failures += 1
        push_error("POISON_V4_LAB_STATUS_FAIL: " + what)

func _run() -> void:
    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", "doc_cham")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "1")
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "single")
    var lab := LabScene.instantiate()
    root.add_child(lab)
    await process_frame
    # The UI must explain real skill semantics and separate decorative VFX
    # direction from combat authority. No silent substitution to another skill.
    _check(bool(lab.call("_select_poison_skill",
        "tmb.skill.poison.doc_cham.active_03.human")), "AoE art brief selectable")
    lab.call("_refresh_poison_skill_details")
    var details: Label = lab.get("poison_skill_detail_label")
    _check(details.text.contains("Bách Độc Tán Châm") and
        details.text.contains("bán kính 3.0 ô") and
        details.text.contains("tối đa 3 mục tiêu") and
        details.text.contains("MỸ THUẬT:"),
        "AoE UI displays true name/radius/hit cap and separate VFX description")
    _check(bool(lab.call("_select_poison_skill",
        "tmb.skill.poison.duoc_doc.active_02.human")) == false or
        details.text.contains("Bách Độc Tán Châm"),
        "different branch is not silently inserted into current-branch catalog")
    var battle: MapBattleV2 = lab.get("battle")
    _check(battle != null and battle.active, "a canonical Lab battle exists")
    if battle == null or not battle.active:
        quit(1)
        return
    var arena: Control = lab.get("arena")
    var status_before := str(arena.get("status_line"))
    _check(not status_before.contains("cấu hình chưa hợp lệ"),
        "valid fixture must have valid status before preview")
    lab.call("_set_preview_warning", "Test-only rejected command, no simulation mutation")
    _check(str(arena.get("status_line")) == status_before,
        "out-of-range/cooldown preview warning must not corrupt scene status")
    _check(battle.active, "rejected preview does not end canonical battle")
    print("POISON_V4_LAB_STATUS_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " failures=" + str(failures))
    quit(0 if failures == 0 else 1)
