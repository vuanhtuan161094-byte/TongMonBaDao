extends Panel
class_name SectSchoolSkillsScreenV1
## Player-facing entry point for 12 schools / 36 authored branches.
## Assignment is a deliberate first-time choice after recruitment; combat
## learning/equipping remains bound to existing live V63 release gates.
signal close_requested()
signal branch_requested(disciple_id: StringName,branch_id: String)
signal skill_action_requested(disciple_id: StringName,skill_id: String,action: String)

var _state: SimulationState
var _disciple_id: StringName
var _school := "sword"
var _feedback := ""
var _skill_page := "basic"
var _skill_tier := "human"
var _preview_branch := ""
var _v63_defs_cache: Dictionary = {}
const SCHOOL_SEALS := preload("res://assets/p3/school_ui/school_seals_v1.svg")
const JADE := Color(0.032,0.143,0.146)
const GOLD := Color(0.94,0.76,0.43)
const IVORY := Color(0.96,0.94,0.85)
const SOFT := Color(0.75,0.83,0.75)

func attach(state: SimulationState,disciple_id: StringName) -> void:
    _state = state
    _disciple_id = disciple_id
    var d: DiscipleState = state.disciples.get(disciple_id)
    if d != null:
        var school := SectASCharCandidateBridgeV1.school_for_disciple(d)
        if not school.is_empty():
            _school = school

func _ready() -> void:
    add_theme_stylebox_override("panel",_style(Color(0.025,0.110,0.117),GOLD))
    refresh()

func _style(bg: Color,edge: Color) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = edge
    s.set_border_width_all(2)
    s.set_corner_radius_all(12)
    s.content_margin_left = 8
    s.content_margin_right = 8
    return s

func _label(host: Control,t: String,pos: Vector2,dims: Vector2,font: int,color: Color = IVORY) -> Label:
    var l := Label.new()
    l.text = t
    l.position = pos
    l.size = dims
    l.add_theme_font_size_override("font_size",font)
    l.add_theme_color_override("font_color",color)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    host.add_child(l)
    return l

func _button(host: Control,t: String,pos: Vector2,dims: Vector2,selected: bool = false) -> Button:
    var b := Button.new()
    b.text = t
    b.position = pos
    b.size = dims
    b.clip_text = true
    b.add_theme_font_size_override("font_size",14)
    b.add_theme_color_override("font_color",Color(0.045,0.12,0.12) if selected else IVORY)
    b.add_theme_stylebox_override("normal",_style(GOLD if selected else JADE,
        Color(0.99,0.90,0.64) if selected else Color(0.34,0.54,0.50)))
    b.add_theme_stylebox_override("hover",_style(Color(0.13,0.30,0.28),GOLD))
    host.add_child(b)
    return b

func show_feedback(message: String) -> void:
    _feedback = message

func _choose_school(school: String) -> void:
    _school = school
    _preview_branch = ""
    refresh()

func _choose_skill_page(page: String) -> void:
    _skill_page = page
    refresh()

func _choose_preview_branch(branch: String) -> void:
    _preview_branch = branch
    _skill_page = "v63"
    refresh()

func _choose_tier(tier: String) -> void:
    _skill_tier = tier
    _skill_page = "v63"
    refresh()

func _ask_branch(branch: String) -> void:
    branch_requested.emit(_disciple_id,branch)

func _ask_skill(skill: String,action: String) -> void:
    skill_action_requested.emit(_disciple_id,skill,action)

func refresh() -> void:
    if not is_inside_tree() or _state == null or not _state.disciples.has(_disciple_id):
        return
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var d: DiscipleState = _state.disciples[_disciple_id]
    var assigned := str(d.v63_combat_branch_id)
    var selected_school := SectASCharCandidateBridgeV1.school_for_branch(assigned)
    _label(self,"MÔN PHÁI · KỸ NĂNG",Vector2(24,12),Vector2(520,36),24,GOLD)
    _label(self,d.display_name+"   ·   "+("Chưa bái môn" if assigned.is_empty() else "Đã bái môn"),
        Vector2(25,48),Vector2(590,25),15,SOFT)
    var close := _button(self,"ĐÓNG",Vector2(1063,14),Vector2(99,41))
    close.pressed.connect(func(): close_requested.emit())
    var left := Panel.new()
    left.position = Vector2(20,81)
    left.size = Vector2(347,432)
    left.add_theme_stylebox_override("panel",_style(JADE,Color(0.37,0.63,0.60)))
    add_child(left)
    _label(left,"12 MÔN PHÁI",Vector2(14,13),Vector2(287,25),16,GOLD)
    var sex := str(DiscipleActorVisualCatalog.visual_sex_for_disciple(d))
    var portrait := TextureRect.new()
    portrait.name = "SchoolCandidatePortrait"
    portrait.position = Vector2(85,43)
    portrait.size = Vector2(174,172)
    portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
    portrait.texture = SectASCharCandidateBridgeV1.preview_texture(_school,sex)
    left.add_child(portrait)
    _label(left,SectASCharCandidateBridgeV1.SCHOOL_NAMES.get(_school,"")+" · Ngoại hình thử nghiệm",Vector2(45,212),Vector2(270,22),11,SOFT)
    var selector := GridContainer.new()
    selector.name = "SchoolSelectorGrid"
    selector.columns = 3
    selector.position = Vector2(11,247)
    selector.size = Vector2(329,172)
    selector.add_theme_constant_override("h_separation",5)
    selector.add_theme_constant_override("v_separation",5)
    left.add_child(selector)
    for school in SectASCharCandidateBridgeV1.SCHOOL_IDS:
        var b := Button.new()
        b.name = "SchoolChoice_"+school
        b.text = SectASCharCandidateBridgeV1.SCHOOL_NAMES[school]
        b.custom_minimum_size = Vector2(103,37)
        b.add_theme_font_size_override("font_size",12)
        b.add_theme_color_override("font_color",GOLD if school == _school else IVORY)
        b.icon = _school_seal(school)
        b.add_theme_constant_override("icon_max_width",22)
        b.tooltip_text = "Đã bái môn" if school == selected_school else "Xem môn phái"
        b.pressed.connect(Callable(self,"_choose_school").bind(school))
        selector.add_child(b)
    var mid := Panel.new()
    mid.position = Vector2(381,81)
    mid.size = Vector2(258,432)
    mid.add_theme_stylebox_override("panel",_style(JADE,Color(0.37,0.63,0.60)))
    add_child(mid)
    _label(mid,"CHỌN NHÁNH",Vector2(15,14),Vector2(226,26),17,GOLD)
    _label(mid,"3 nhánh mỗi môn phái",Vector2(15,45),Vector2(223,26),12,SOFT)
    var branches := SectASCharCandidateBridgeV1.branches_for(_school)
    var current_preview := _selected_preview_branch(branches)
    if _school == selected_school and _preview_branch.is_empty():
        current_preview = assigned
    _preview_branch = current_preview
    for i in range(mini(3,branches.size())):
        var branch: Dictionary = branches[i]
        var is_current := str(branch["id"]) == current_preview
        var b := _button(mid,str(branch["name"]),Vector2(13,78+i*74),
            Vector2(232,56),is_current)
        b.name = "SchoolBranch_"+str(branch["id"])
        b.tooltip_text = str(branch["id"])
        b.disabled = false
        b.pressed.connect(Callable(self,"_choose_preview_branch").bind(str(branch["id"])))
    var confirm := _button(mid,"BÁI MÔN" if assigned.is_empty() else "ĐÃ BÁI MÔN",
        Vector2(13,311),Vector2(232,42),true)
    confirm.name = "SchoolConfirmBranch"
    confirm.disabled = not assigned.is_empty() or current_preview.is_empty() \
        or d.region_id != &"sect" or not d.active_pve_encounter_id.is_empty()
    confirm.pressed.connect(Callable(self,"_ask_branch").bind(current_preview))
    _label(mid,"Xem kỹ năng trước khi chọn. Bái môn chỉ một lần."
        if assigned.is_empty() else "Đã bái môn. Các nhánh khác chỉ được tra cứu.",
        Vector2(15,363),Vector2(231,62),12,SOFT)
    var right := Panel.new()
    right.position = Vector2(654,81)
    right.size = Vector2(508,432)
    right.add_theme_stylebox_override("panel",_style(JADE,Color(0.37,0.63,0.60)))
    add_child(right)
    _label(right,"KỸ NĂNG CỦA ĐỆ TỬ",Vector2(15,12),Vector2(475,30),17,GOLD)
    var v63_live := V63HumanSkillCombatSystem.is_enabled(_state)
    _label(right,("Công pháp · nguồn học, chi phí và thành thạo" if _skill_page == "method" else "Kỹ năng P2 đang chơi dùng được trong PvE") if _skill_page != "v63"
        else ("Học và trang bị theo quyền V6.3" if v63_live
            else "V6.3 hiện KHÓA · xem trước, không cộng sức mạnh"),
        Vector2(15,43),Vector2(477,27),12,SOFT)
    var basic_tab := _button(right,"KỸ NĂNG P2",Vector2(12,77),
        Vector2(152,38),_skill_page == "basic")
    basic_tab.name = "SchoolBasicSkillTab"
    basic_tab.pressed.connect(Callable(self,"_choose_skill_page").bind("basic"))
    var advanced_tab := _button(right,"36 NHÁNH",Vector2(172,77),
        Vector2(152,38),_skill_page == "v63")
    advanced_tab.name = "SchoolV63SkillTab"
    advanced_tab.pressed.connect(Callable(self,"_choose_skill_page").bind("v63"))
    var method_tab := _button(right,"CÔNG PHÁP",Vector2(332,77),Vector2(160,38),_skill_page == "method")
    method_tab.name = "SchoolTechniqueTab"
    method_tab.pressed.connect(Callable(self,"_choose_skill_page").bind("method"))
    if _skill_page == "v63":
        for i in range(3):
            var tiers := ["human","immortal","divine"]
            var tier_names := ["NHÂN","TIÊN","THẦN"]
            var tier_button := _button(right,tier_names[i],Vector2(12+i*160,121),
                Vector2(154,33),_skill_tier == tiers[i])
            tier_button.name = "SchoolTier_"+tiers[i]
            tier_button.pressed.connect(Callable(self,"_choose_tier").bind(tiers[i]))
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(12,162 if _skill_page == "v63" else 121)
    scroll.size = Vector2(480,254 if _skill_page == "v63" else 295)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    right.add_child(scroll)
    var stack := VBoxContainer.new()
    stack.name = "SchoolSkillList"
    stack.custom_minimum_size.x = 454
    stack.add_theme_constant_override("separation",5)
    scroll.add_child(stack)
    var displayed := 0
    if _skill_page == "method":
        displayed = _append_techniques(stack,d)
    elif _skill_page == "basic":
        # Actual nine P2.5 combat skills; teach through the existing backend,
        # whose stage/feature gates and combat loadout already drive real PvE.
        var basic_system := CombatSkillSystem.new()
        var basic_ids: Array = CombatSkillSystem.SKILLS.keys()
        basic_ids.sort()
        for raw_id in basic_ids:
            var id := str(raw_id)
            var def: Dictionary = CombatSkillSystem.SKILLS[id]
            var known := bool(d.learned_combat_skills.get(id,false))
            var can_learn := basic_system.can_learn_skill(_state,d,StringName(id)) and _can_change_loadout(d)
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation",5)
            stack.add_child(row)
            var text := Label.new()
            text.custom_minimum_size = Vector2(326,48)
            text.text = str(def.get("name",id))+"\n"+str(def.get("path",""))+" · CD "+str(def.get("cooldown",0))+"s"
            text.add_theme_font_size_override("font_size",12)
            text.add_theme_color_override("font_color",IVORY)
            text.tooltip_text = id+" · "+str(def.get("effect",""))+" · Cần cảnh giới "+str(def.get("min_stage",0))
            row.add_child(text)
            var action := Button.new()
            action.name = "BasicSkillLearn_"+id
            action.custom_minimum_size = Vector2(118,42)
            action.text = "ĐÃ HỌC" if known else ("HỌC" if can_learn else "CHƯA ĐỦ")
            action.disabled = known or not can_learn
            var available_in_pve := str(def.get("effect","")) in ["damage","burn","weaken","guard"]
            action.tooltip_text = ("Đã học · dùng trong PvE" if available_in_pve else "Đã học · adapter PvE chưa hỗ trợ") if known else (
                "Không đủ điều kiện học" if not can_learn else ("Học bằng CombatSkillSystem thật" if available_in_pve else "Có thể học · adapter PvE chưa hỗ trợ"))
            action.pressed.connect(Callable(self,"_ask_skill").bind(id,"learn_basic"))
            row.add_child(action)
            displayed += 1
    else:
        if _v63_defs_cache.is_empty():
            _v63_defs_cache = V63HumanSkillCombatSystem.skill_definitions()
        var defs := _v63_defs_cache
        var ids: Array[String] = []
        for raw_id in defs.keys():
            var info: Dictionary = defs[raw_id]
            if str(info.get("school","")) != _school:
                continue
            if str(info.get("tier",info.get("generation",""))) != _skill_tier:
                continue
            var branch := str(info.get("branch",""))
            if not branch.is_empty() and branch != current_preview:
                continue
            ids.append(str(raw_id))
        ids.sort()
        for id in ids:
            var definition: Dictionary = defs[id]
            var row := HBoxContainer.new()
            row.add_theme_constant_override("separation",5)
            stack.add_child(row)
            var text := Label.new()
            text.custom_minimum_size = Vector2(326,64)
            var lineage := str(definition.get("lineage",""))
            var lineage_label := " · Nhánh "+lineage.to_upper() if lineage in ["a","b"] else ""
            text.text = str(definition.get("name",id))+lineage_label+"\n"+str(definition.get("slot",""))
            text.text += " · CD "+str(definition.get("cooldown",0))+"s"
            text.text += " · Tầm "+str(definition.get("range",0))
            text.text += "\n"+_effect_summary(definition)
            text.add_theme_font_size_override("font_size",12)
            text.add_theme_color_override("font_color",IVORY)
            text.tooltip_text = id+"\n"+str(definition.get("effect",""))
            text.tooltip_text += " · "+str(definition.get("damage_ratio",1.0))+"× sát thương"
            row.add_child(text)
            var known := d.v63_learned_skill_nodes.has(id)
            var equipped := d.v63_equipped_skill_ids.has(id)
            var action := Button.new()
            action.name = "SchoolSkillAction_"+str(displayed)
            action.custom_minimum_size = Vector2(118,42)
            action.text = "ĐÃ DÙNG" if equipped else ("TRANG BỊ" if known else "HỌC")
            var own_branch := _school == selected_school and (str(definition.get("branch","")).is_empty() or str(definition.get("branch","")) == assigned)
            action.disabled = not v63_live or assigned.is_empty() or not own_branch or equipped or not bool(definition.get("archivable",false))
            if not own_branch:
                action.text = "TRA CỨU"
            action.tooltip_text = "V6.3 chưa được phép phát hành" if not v63_live else id
            action.pressed.connect(Callable(self,"_ask_skill").bind(id,
                "equip" if known else "learn"))
            row.add_child(action)
            displayed += 1
    if displayed == 0:
        var empty := Label.new()
        empty.text = "Chưa có kỹ năng sẵn sàng."
        empty.add_theme_color_override("font_color",SOFT)
        stack.add_child(empty)
    _label(self,_feedback,Vector2(25,516),Vector2(1110,29),13,GOLD)

func _can_change_loadout(d: DiscipleState) -> bool:
    return d.region_id == &"sect" and d.active_pve_encounter_id.is_empty() and d.injury_level == 0 and d.hp > 0.0

func _append_techniques(stack: VBoxContainer,d: DiscipleState) -> int:
    var intro := Label.new()
    intro.text = "Cống hiến %d · Linh thạch cá nhân %d" % [d.contribution_points,d.spirit_stones]
    intro.add_theme_color_override("font_color",GOLD)
    stack.add_child(intro)
    var ready := _can_change_loadout(d)
    var count := 0
    if DiscipleRealmProgressV2.owns_v2_progression(d):
        var learner := V63LearningSystem.new()
        var live := V63LearningSystem.is_enabled(_state)
        if not live:
            var locked := Label.new()
            locked.text = "Công pháp V6.3 đang khóa phát hành. Chỉ tra cứu; không trừ tài nguyên."
            locked.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            locked.custom_minimum_size.x = 445
            stack.add_child(locked)
        if not d.v63_study_job.is_empty():
            var job: Dictionary = d.v63_study_job
            var row := _method_row(stack,"ĐANG HỌC · "+str(job.get("technique_id",""))+"\n%d/%d nhịp" % [int(job.get("progress_ticks",0)),int(job.get("duration_ticks",0))])
            _method_action(row,"HỦY HỌC",str(job.get("job_id","")),"cancel_method",live and ready)
        for definition in V63LearningSystem.techniques():
            var id := str(definition.get("id",""))
            var cost: Dictionary = definition.get("cost",{})
            var known := d.known_techniques.has(id)
            var check := learner.can_start_study(_state,d,StringName(id))
            var equipped := str(d.active_technique_main) == id
            var detail := str(definition.get("name",id))+"\n"+("%d cống hiến · %d linh thạch · %d nhịp" % [int(cost.get("contribution",0)),int(cost.get("spirit_stones",0)),int(definition.get("study_ticks",0))])
            var row := _method_row(stack,detail)
            var button := _method_action(row,"ĐANG DÙNG" if equipped else ("CHÍNH TU" if known else "HỌC"),id,"equip_method" if known else "study_method",ready and live and not equipped and (known or bool(check.get("ok",false))))
            button.tooltip_text = str(check.get("reason","")) if not known else "Trang bị vào ô chính tu"
            count += 1
        return count
    var system := TechniqueSystem.new()
    var ids: Array = TechniqueSystem.TECHNIQUES.keys()
    ids.sort()
    for raw in ids:
        var id := str(raw)
        var key := StringName(id)
        var known := d.learned_techniques.has(id)
        var archived := system.is_archived(_state,key)
        var detail := system.technique_name(key)
        var action := "learn_legacy_method"
        var caption := "HỌC"
        var enabled := ready and bool(system.learning_preview(_state,d,key).get("ok",false))
        if known:
            var mastery: Dictionary = d.learned_techniques[id]
            var level := int(mastery.get("level",1))
            var xp := float(mastery.get("xp",0.0))
            var need := system.mastery_required(level)
            detail += "\nLv%d · %.0f/%.0f EXP" % [level,xp,need]
            if d.active_technique_id != key:
                action = "equip_legacy_method"
                caption = "CHÍNH TU"
                enabled = ready and _state.sect.techniques_enabled
            else:
                action = "upgrade_legacy_method"
                caption = "NÂNG CẤP" if need > 0.0 else "TỐI ĐA"
                enabled = ready and need > 0.0 and xp+0.000001 >= need
                var costs := system.upgrade_material_cost(key,level)
                for resource in costs:
                    var stock := WarehouseSystem.new().available_quantity(_state,StringName(resource)) if _state.sect.p3_7_resources_enabled else int(_state.sect.technique_materials.get(resource,0))
                    enabled = enabled and stock >= int(costs[resource])
                    detail += " · %s %d/%d" % [ResourceRegistry.new().display_name(StringName(resource)),stock,int(costs[resource])]
        else:
            var definition := system.definition(key)
            detail += "\n%d cống hiến · %d linh thạch" % [int(definition.get("learn_contribution",0)),int(definition.get("learn_stones",0))]
            if not archived:
                caption = "CHƯA CÓ SÁCH"
                enabled = false
        _method_action(_method_row(stack,detail),caption,id,action,enabled)
        count += 1
    return count

func _method_row(stack: VBoxContainer,detail: String) -> HBoxContainer:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation",5)
    stack.add_child(row)
    var label := Label.new()
    label.custom_minimum_size = Vector2(326,48)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.text = detail
    label.add_theme_font_size_override("font_size",12)
    row.add_child(label)
    return row

func _method_action(row: HBoxContainer,caption: String,id: String,action: String,enabled: bool) -> Button:
    var button := Button.new()
    button.name = "MethodAction_"+action+"_"+id.sha256_text().substr(0,12)
    button.custom_minimum_size = Vector2(118,42)
    button.text = caption
    button.disabled = not enabled
    button.pressed.connect(Callable(self,"_ask_skill").bind(id,action))
    row.add_child(button)
    return button

func _school_seal(school: String) -> Texture2D:
    var index := SectASCharCandidateBridgeV1.SCHOOL_IDS.find(school)
    if index < 0:
        return null
    var icon := AtlasTexture.new()
    icon.atlas = SCHOOL_SEALS
    icon.region = Rect2((index % 4)*64,floori(float(index)/4.0)*64,64,64)
    return icon

func _effect_summary(definition: Dictionary) -> String:
    var effect := str(definition.get("effect",""))
    var names := {"damage":"Sát thương","guard":"Hộ thể","heal":"Hồi phục","cleanse":"Thanh tẩy","mobility":"Thân pháp","mark":"Đánh dấu","passive":"Bị động","innate":"Thiên phú","consume_poison":"Kích độc"}
    var summary := str(names.get(effect,effect))
    if effect == "damage":
        summary += " "+str(definition.get("damage_ratio",0))+"×"
        summary += " · "+str(definition.get("target_limit",1))+" mục tiêu"
    elif float(definition.get("duration",0)) > 0:
        summary += " · "+str(definition.get("duration",0))+"s"
    return summary

func _selected_preview_branch(branches: Array[Dictionary]) -> String:
    if branches.is_empty():
        return ""
    for branch in branches:
        if str(branch.get("id","")) == _preview_branch:
            return _preview_branch
    return str(branches[0]["id"])
