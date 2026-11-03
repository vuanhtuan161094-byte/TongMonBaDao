extends Node3D
## AN-03 isolated technical preview: real procedural Skeleton3D motions.
## The model is a geometry guide only. Original owner's Shadow 3D mesh not present.
const ACTOR := preload("res://src/presentation/labs/an03_modular_character.gd")
const ACTIONS := ["idle","walk","attack"]
var _actor
var _clock_label: Label
var _status_label: Label
var _action_select: OptionButton
var _weapon_checkbox: CheckButton
var _speed_slider: HSlider
var _play_button: Button

func _ready() -> void:
    _make_stage()
    _actor = ACTOR.new()
    _actor.name = "ModularRigGuide"
    add_child(_actor)
    _make_interface()
    _refresh()
    set_process(true)

func _make_stage() -> void:
    var environment := WorldEnvironment.new()
    environment.name = "LabEnvironment"
    environment.environment = Environment.new()
    environment.environment.background_mode = Environment.BG_COLOR
    environment.environment.background_color = Color(0.040,0.036,0.068)
    add_child(environment)
    var camera := Camera3D.new()
    camera.name = "AN03Camera"
    camera.projection = Camera3D.PROJECTION_ORTHOGONAL
    camera.size = 3.9
    camera.position = Vector3(2.3,2.1,5.5)
    add_child(camera)
    camera.look_at(Vector3(0.0,1.17,0.0),Vector3.UP)
    camera.current = true
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-48.0,-24.0,0.0)
    light.light_energy = 1.5
    add_child(light)
    var fill := OmniLight3D.new()
    fill.position = Vector3(-1.8,3.2,3.2)
    fill.light_color = Color(0.54,0.29,1.0)
    fill.light_energy = 2.2
    add_child(fill)
    var floor := MeshInstance3D.new()
    floor.name = "VisualOnlyPlatform"
    var disc := CylinderMesh.new()
    disc.top_radius = 1.15
    disc.bottom_radius = 1.15
    disc.height = 0.045
    floor.mesh = disc
    floor.position = Vector3(0,-0.16,0)
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.16,0.09,0.25)
    floor.material_override = floor_mat
    add_child(floor)

func _make_interface() -> void:
    var layer := CanvasLayer.new()
    layer.name = "AN03ViewOnlyHUD"
    add_child(layer)
    var hud := Control.new()
    hud.name = "PanelRoot"
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(hud)
    _panel(hud,Vector2(16,16),Vector2(310,686))
    _panel(hud,Vector2(938,20),Vector2(323,675))
    _label(hud,"TÔNG MÔN BÁ ĐẠO",Vector2(31,35),23,Color(0.97,0.86,0.69))
    _label(hud,"AN-03  /  MODULAR RIG LAB",Vector2(31,75),16,Color(0.68,0.51,1.0))
    _label(hud,"Chuyển động xương thật, KHÔNG phải",Vector2(31,118),14,Color(0.91,0.78,0.98))
    _label(hud,"model Hắc Ảnh Kiếm Tu hoàn thiện.",Vector2(31,139),14,Color(0.91,0.78,0.98))
    _label(hud,"HÀNH ĐỘNG",Vector2(31,210),17,Color.WHITE)
    _action_select = OptionButton.new()
    _action_select.position = Vector2(30,247)
    _action_select.size = Vector2(272,43)
    for motion in ACTIONS:
        _action_select.add_item(motion.to_upper())
    _action_select.item_selected.connect(_on_action_selected)
    hud.add_child(_action_select)
    _weapon_checkbox = CheckButton.new()
    _weapon_checkbox.text = "Gắn kiếm vào socket tay"
    _weapon_checkbox.position = Vector2(28,329)
    _weapon_checkbox.button_pressed = false
    _weapon_checkbox.toggled.connect(_on_weapon_toggle)
    hud.add_child(_weapon_checkbox)
    _label(hud,"TỐC ĐỘ PHÁT",Vector2(31,414),16,Color.WHITE)
    _speed_slider = HSlider.new()
    _speed_slider.position = Vector2(35,450)
    _speed_slider.size = Vector2(265,28)
    _speed_slider.min_value = 0.25
    _speed_slider.max_value = 2.0
    _speed_slider.step = 0.05
    _speed_slider.value = 1.0
    _speed_slider.value_changed.connect(_on_speed_changed)
    hud.add_child(_speed_slider)
    _play_button = Button.new()
    _play_button.text = "Tạm dừng"
    _play_button.position = Vector2(30,510)
    _play_button.size = Vector2(131,44)
    _play_button.pressed.connect(_on_play_clicked)
    hud.add_child(_play_button)
    var restart := Button.new()
    restart.text = "Phát lại"
    restart.position = Vector2(170,510)
    restart.size = Vector2(132,44)
    restart.pressed.connect(_on_restart_clicked)
    hud.add_child(restart)
    _label(hud,"KIẾN TRÚC MÔ-ĐUN",Vector2(956,45),18,Color.WHITE)
    _label(hud,"01  Skeleton3D humanoid chung",Vector2(957,103),14,Color(0.88,0.81,1.0))
    _label(hud,"02  Tóc / áo / giáp là skin slot",Vector2(957,144),14,Color(0.88,0.81,1.0))
    _label(hud,"03  Kiếm là vật thể riêng",Vector2(957,185),14,Color(0.88,0.81,1.0))
    _label(hud,"04  VFX độc lập với đòn đánh",Vector2(957,226),14,Color(0.88,0.81,1.0))
    _label(hud,"05  Một camera / một model",Vector2(957,267),14,Color(0.88,0.81,1.0))
    _label(hud,"Không có dữ liệu Tripo/GLB:",Vector2(957,354),15,Color(0.98,0.72,0.44))
    _label(hud,"đây là mẫu xương + mesh guide.",Vector2(957,380),14,Color(0.88,0.81,1.0))
    _status_label = _label(hud,"",Vector2(957,441),15,Color(0.89,0.75,1.0))
    _status_label.size = Vector2(286,155)
    _status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _clock_label = _label(hud,"",Vector2(32,591),14,Color(0.83,0.66,1.0))
    _label(hud,"VIEW ONLY · KHÔNG CÓ DAMAGE / SAVE",Vector2(955,643),
        12,Color(0.95,0.59,0.82))

func _panel(parent: Control, position: Vector2, dimensions: Vector2) -> void:
    var surface := ColorRect.new()
    surface.color = Color(0.085,0.065,0.14,0.88)
    surface.position = position
    surface.size = dimensions
    surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(surface)

func _label(parent: Control, value: String, position: Vector2,
        size: int, color: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.position = position
    label.add_theme_font_size_override("font_size",size)
    label.add_theme_color_override("font_color",color)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(label)
    return label

func _on_action_selected(index: int) -> void:
    _actor.select_motion(ACTIONS[index])
    _actor.play()
    _play_button.text = "Tạm dừng"
    _refresh()

func _on_weapon_toggle(enabled: bool) -> void:
    _actor.equip_weapon("practice_sword" if enabled else "none")
    _refresh()

func _on_speed_changed(value: float) -> void:
    _actor.set_playback_speed(value)

func _on_play_clicked() -> void:
    if _actor.is_playing():
        _actor.pause()
        _play_button.text = "Tiếp tục"
    else:
        _actor.play()
        _play_button.text = "Tạm dừng"

func _on_restart_clicked() -> void:
    _actor.seek(0.0)
    _actor.play()
    _play_button.text = "Tạm dừng"
    _refresh()

func _process(_delta: float) -> void:
    _refresh()

func _refresh() -> void:
    if _actor == null or _clock_label == null:
        return
    var evidence: Dictionary = _actor.get_lab_evidence()
    _clock_label.text = "Clip: %s  |  t = %.2f / %.2fs" % [
        str(evidence["action"]),float(evidence["seconds"]),
        float(evidence["duration"])]
    _status_label.text = "%d xương thật\nSocket tay phải: %s\nKiếm: %s\nTám hướng: CHƯA\nGLB/FBX: CHƯA CÓ" % [
        int(evidence["bone_count"]),
        "OK" if bool(evidence["right_hand_socket"]) else "MISSING",
        "ON" if bool(evidence["weapon_equipped"]) else "OFF"]

func configure_for_capture(motion: String, weapon: bool, seconds: float) -> void:
    _actor.select_motion(motion)
    _actor.equip_weapon("practice_sword" if weapon else "none")
    _actor.pause()
    _actor.seek(seconds)
    _action_select.select(ACTIONS.find(motion))
    _weapon_checkbox.set_pressed_no_signal(weapon)
    _play_button.text = "Tiếp tục"
    _refresh()

func get_sample_actor() -> Node3D:
    return _actor

func sample_evidence() -> Dictionary:
    return _actor.get_lab_evidence()
