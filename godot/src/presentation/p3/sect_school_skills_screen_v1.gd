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
    if not selected_school.is_empty():
        _school = selected_school
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
    _label(left,"AS-CHAR · CANDIDATE",Vector2(75,212),Vector2(215,22),11,SOFT)
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
        b.disabled = not assigned.is_empty() and school != _school
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
    for i in range(mini(3,branches.size())):
        var branch: Dictionary = branches[i]
        var is_current := str(branch["id"]) == assigned
        var b := _button(mid,str(branch["name"]),Vector2(13,87+i*88),
            Vector2(232,62),is_current)
        b.name = "SchoolBranch_"+str(branch["id"])
        b.tooltip_text = str(branch["id"])
        b.disabled = not assigned.is_empty() or d.region_id != &"sect" or not d.active_pve_encounter_id.is_empty()
        if assigned.is_empty():
            b.pressed.connect(Callable(self,"_ask_branch").bind(str(branch["id"])))
    _label(mid,
        "Chọn 1 nhánh để bái môn.\nChỉ chọn một lần; kỹ năng vẫn phải học riêng."
        if assigned.is_empty() else "ĐÃ CHỌN\n"+assigned,
        Vector2(15,367),Vector2(231,58),12,SOFT)
    var right := Panel.new()
    right.position = Vector2(654,81)
    right.size = Vector2(508,432)
    right.add_theme_stylebox_override("panel",_style(JADE,Color(0.37,0.63,0.60)))
    add_child(right)
    _label(right,"KỸ NĂNG · NHÂN GIAI",Vector2(15,12),Vector2(475,30),17,GOLD)
    var live := V63HumanSkillCombatSystem.is_enabled(_state)
    _label(right,"Học / trang bị theo quyền mở khóa thật" if live
        else "V6.3 hiện KHÓA · xem trước, không cộng sức mạnh",
        Vector2(15,43),Vector2(477,32),12,SOFT)
    var scroll := ScrollContainer.new()
    scroll.position = Vector2(12,79)
    scroll.size = Vector2(480,337)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    right.add_child(scroll)
    var stack := VBoxContainer.new()
    stack.name = "SchoolSkillList"
    stack.custom_minimum_size.x = 454
    stack.add_theme_constant_override("separation",5)
    scroll.add_child(stack)
    var defs := V63HumanSkillCombatSystem.skill_definitions()
    var ids: Array[String] = []
    for raw_id in defs.keys():
        var info: Dictionary = defs[raw_id]
        if str(info.get("school","")) != _school:
            continue
        if str(info.get("tier",info.get("generation",""))) != "human":
            continue
        var branch := str(info.get("branch",""))
        if not branch.is_empty() and branch != assigned and branch != _selected_preview_branch(branches):
            continue
        ids.append(str(raw_id))
    ids.sort()
    var displayed := 0
    for id in ids:
        if displayed >= 10:
            break
        var definition: Dictionary = defs[id]
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation",5)
        stack.add_child(row)
        var text := Label.new()
        text.custom_minimum_size = Vector2(326,48)
        var label := str(definition.get("name",id))
        var slot := str(definition.get("slot",""))
        text.text = label+"\n"+slot+" · CD "+str(definition.get("cooldown",0))+"s"
        text.add_theme_font_size_override("font_size",12)
        text.add_theme_color_override("font_color",IVORY)
        text.tooltip_text = id+"\n"+str(definition.get("effect",""))+" · "
        text.tooltip_text += str(definition.get("damage_ratio",1.0))+"× sát thương"
        row.add_child(text)
        var known := d.v63_learned_skill_nodes.has(id)
        var equipped := d.v63_equipped_skill_ids.has(id)
        var action := Button.new()
        action.name = "SchoolSkillAction_"+str(displayed)
        action.custom_minimum_size = Vector2(118,42)
        action.text = "ĐÃ DÙNG" if equipped else ("TRANG BỊ" if known else "HỌC")
        action.disabled = not live or assigned.is_empty() or equipped
        action.tooltip_text = "Chưa mở kỹ năng V6.3" if not live else id
        action.pressed.connect(Callable(self,"_ask_skill").bind(id,
            "equip" if known else "learn"))
        row.add_child(action)
        displayed += 1
    if displayed == 0:
        _label(stack,"Chưa có chiêu thức ở nhánh này.",
            Vector2.ZERO,Vector2(444,55),14,SOFT)
    _label(self,_feedback,Vector2(25,516),Vector2(1110,29),13,GOLD)

func _selected_preview_branch(branches: Array[Dictionary]) -> String:
    if branches.is_empty():
        return ""
    return str(branches[0]["id"])
