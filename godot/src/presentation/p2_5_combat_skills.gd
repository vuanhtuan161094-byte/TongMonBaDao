extends Control

const TEST_SEED := 1425252

var state: SimulationState
var actor: DiscipleState
var skills := CombatSkillSystem.new()
var combat := CombatSystem.new()
var run_index := 0

var summary_label: Label
var result_label: Label
var skills_label: Label

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    state = P25Factory.create_state(TEST_SEED)
    actor = state.disciples.get(&"bach_nguyet")
    _seed_demo_actor()
    _build_ui()
    _run_demo(&"spell")

func _seed_demo_actor() -> void:
    actor.cultivation_stage_index = 9
    actor.spiritual_root_quality = SpiritualRootSystem.QUALITY_ORDINARY
    actor.spiritual_root_elements = ["fire"]
    actor.cultivation_path_xp = {"sword":600.0, "body":400.0, "spell":1200.0}
    actor.learned_techniques = {
        "thanh_phong_kiem_quyet":{"level":2, "xp":0.0},
        "huyen_giap_cong":{"level":2, "xp":0.0},
        "xich_viem_chan_quyet":{"level":2, "xp":0.0}
    }
    for skill_id in [
        &"thanh_phong_tram", &"truy_phong_bo", &"ngu_kiem_thuat",
        &"chan_son_quyen", &"kim_cuong_ho_the", &"bat_dong_than",
        &"hoa_cau", &"han_suong_an", &"liet_diem"
    ]:
        skills.learn_skill(state, actor, skill_id)

func _build_ui() -> void:
    var background := ColorRect.new()
    background.color = Color(0.055, 0.07, 0.065, 1.0)
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 14)
    margin.add_theme_constant_override("margin_right", 14)
    margin.add_theme_constant_override("margin_top", 18)
    margin.add_theme_constant_override("margin_bottom", 18)
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "TÔNG MÔN TYCOON — P2.5 CHIÊU THỨC CHIẾN ĐẤU"
    title.add_theme_font_size_override("font_size", 21)
    column.add_child(title)

    summary_label = Label.new()
    summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(summary_label)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    column.add_child(row)
    for data in [
        ["Thử Kiếm", &"sword"],
        ["Thử Thể", &"body"],
        ["Thử Pháp", &"spell"]
    ]:
        var button := Button.new()
        button.text = str(data[0])
        button.pressed.connect(_run_demo.bind(StringName(data[1])))
        row.add_child(button)

    skills_label = Label.new()
    skills_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(skills_label)

    result_label = Label.new()
    result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    column.add_child(result_label)

func _run_demo(path: StringName) -> void:
    match path:
        &"sword":
            actor.active_technique_id = &"thanh_phong_kiem_quyet"
        &"body":
            actor.active_technique_id = &"huyen_giap_cong"
        _:
            actor.active_technique_id = &"xich_viem_chan_quyet"

    actor.max_hp = 180.0
    actor.hp = actor.max_hp
    actor.region_id = &"hac_phong_coc"
    state.regions[&"hac_phong_coc"].monster_weights = {"hac_lang":1.0}
    run_index += 1
    var result := combat.resolve_encounter(state, actor, GameRng.new(TEST_SEED + run_index * 101))
    _refresh_ui(result)

func _refresh_ui(result: Dictionary) -> void:
    var profile := skills.style_profile(state, actor)
    var technique_name := TechniqueSystem.new().technique_name(actor.active_technique_id)
    summary_label.text = (
        "%s | Phong cách %s | cự ly ưa thích %.1fm | đánh thường %.2fs\n"
        + "Combat P2.5 là timeline thời gian thực trong simulation; UI chỉ hiển thị kết quả đã được engine quyết định."
    ) % [actor.display_name, str(profile.get("id", "balanced")), float(profile.get("preferred_distance", 0.0)), float(profile.get("basic_interval", 0.0))]

    var usable_names: Array[String] = []
    for skill_id in skills.usable_skills(state, actor):
        usable_names.append(skills.skill_name(skill_id))
    skills_label.text = "Công pháp nền: %s\nChiêu đã học độc lập: %s" % [technique_name, ", ".join(usable_names)]

    var important: Array[String] = []
    for event_value in result.get("trace", []):
        var event: Dictionary = event_value
        var event_type := str(event.get("type", ""))
        if event_type in ["cast_start", "projectile_launch", "projectile_hit", "buff", "debuff", "burn_tick", "victory", "defeat", "retreat"]:
            var skill_text := ""
            if event.has("skill_id"):
                skill_text = " " + skills.skill_name(StringName(event.get("skill_id", "")))
            important.append("%.2fs %s%s" % [float(event.get("time", 0.0)), event_type, skill_text])
        if important.size() >= 10:
            break

    result_label.text = (
        "Kết quả: %s | thời gian %.2fs | cự ly cuối %.2fm | đánh thường %d | dùng chiêu %d\n\n%s"
    ) % [
        str(result.get("outcome", "?")), float(result.get("elapsed", 0.0)), float(result.get("final_distance", 0.0)),
        int(result.get("basic_attacks", 0)), result.get("skills_used", []).size(), "\n".join(important)
    ]
