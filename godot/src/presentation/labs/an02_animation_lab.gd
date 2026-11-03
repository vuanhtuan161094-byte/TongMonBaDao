extends Control
## AN-02: independent VIEW-ONLY animation comparison scene.
## Source A SpriteFrames are read through the existing CombatV5SourceAAtlas.
## No Combat V2 or SaveService references; all Shadow effects are lab-only.
const ATLAS := preload("res://src/presentation/p3/combat_v5_source_a_atlas.gd")
const SHADOW_SHADER := preload("res://src/presentation/labs/an02_shadow_mask.gdshader")
const MANIFEST := "res://assets/combat_v5_source_a/visual_manifest.json"
const ACTORS := [
    {"label":"Shadow Kiếm [THỬ NGHIỆM]","key":"disciple_male","shadow":true},
    {"label":"Nam — Source A","key":"disciple_male","shadow":false},
    {"label":"Nữ — Source A","key":"disciple_female","shadow":false},
    {"label":"Thanh Lang — Source A","key":"monster_1113031_1","shadow":false},
    {"label":"Boss Slot — Source A","key":"boss_slot_410041_1","shadow":false}
]
const ACTIONS := ["idle","walk","run","attack","hit","die","cast"]
const DIRECTIONS := ["Đông E","Đông Bắc NE","Bắc N","Tây Bắc NW","Tây W","Tây Nam SW","Nam S","Đông Nam SE"]
const PREVIEW_FOOT := Vector2(630.0, 485.0)
const PREVIEW_ENLARGE := 3.25
const GAMEPLAY_HEIGHT_MIN := 60
const GAMEPLAY_HEIGHT_MAX := 75

var _atlas = ATLAS.new()
var _sprite: Sprite2D
var _shadow_material: ShaderMaterial
var _actor_select: OptionButton
var _action_select: OptionButton
var _direction_select: OptionButton
var _speed_slider: HSlider
var _shadow_toggle: CheckButton
var _play_button: Button
var _info_label: Label
var _frame_label: Label
var _note_label: Label
var _elapsed := 0.0
var _speed := 1.0
var _playing := true
var _actor_index := 0
var _action_index := 0
var _direction_index := 0
var _shadow := true
var _clock := 0.0
var _clip_probe_cache: Dictionary = {}

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_STOP
    _sprite = Sprite2D.new()
    _sprite.name = "ActualSourceAFrame"
    _sprite.centered = false
    _sprite.z_index = 3
    add_child(_sprite)
    _shadow_material = ShaderMaterial.new()
    _shadow_material.shader = SHADOW_SHADER
    _build_ui()
    _apply_selection()
    set_process(true)

func _build_ui() -> void:
    _text("TÔNG MÔN BÁ ĐẠO  /  ANIMATION LAB", Vector2(25, 18), 27, Color(0.97,0.87,0.67))
    _text("AN-02  |  Source A thật + thử nghiệm Shadow  |  1280×720", Vector2(25, 59), 16, Color(0.72,0.68,0.88))
    _text("NHÂN VẬT",Vector2(18,125),16,Color(0.9,0.85,0.98))
    _actor_select = _select(ACTORS.map(func(row: Dictionary): return str(row["label"])), Vector2(18,157),Vector2(226,40),Callable(self,"_on_actor"))
    _text("HÀNH ĐỘNG",Vector2(18,219),16,Color(0.9,0.85,0.98))
    _action_select = _select(ACTIONS,Vector2(18,251),Vector2(226,40),Callable(self,"_on_action"))
    _text("HƯỚNG YÊU CẦU",Vector2(18,314),16,Color(0.9,0.85,0.98))
    _direction_select = _select(DIRECTIONS,Vector2(18,346),Vector2(226,40),Callable(self,"_on_direction"))
    _text("TỐC ĐỘ PHÁT",Vector2(18,408),16,Color(0.9,0.85,0.98))
    _speed_slider = HSlider.new()
    _speed_slider.position = Vector2(22,440)
    _speed_slider.size = Vector2(218,28)
    _speed_slider.min_value = 0.25
    _speed_slider.max_value = 2.0
    _speed_slider.step = 0.05
    _speed_slider.value = 1.0
    _speed_slider.value_changed.connect(_on_speed)
    add_child(_speed_slider)
    _shadow_toggle = CheckButton.new()
    _shadow_toggle.text = "Bóng tối + viền tím"
    _shadow_toggle.position = Vector2(16,487)
    _shadow_toggle.size = Vector2(228,35)
    _shadow_toggle.button_pressed = true
    _shadow_toggle.toggled.connect(_on_shadow)
    add_child(_shadow_toggle)
    _play_button = Button.new()
    _play_button.text = "Tạm dừng"
    _play_button.position = Vector2(18,547)
    _play_button.size = Vector2(106,43)
    _play_button.pressed.connect(_on_play)
    add_child(_play_button)
    var restart := Button.new()
    restart.text = "Phát lại"
    restart.position = Vector2(137,547)
    restart.size = Vector2(107,43)
    restart.pressed.connect(_on_restart)
    add_child(restart)
    _text("SOURCE A · ĐỌC FRAME THẬT",Vector2(1024,122),16,Color(0.92,0.85,0.98))
    _info_label = _text("",Vector2(1022,166),14,Color(0.83,0.88,0.97))
    _info_label.size = Vector2(242,216)
    _info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _frame_label = _text("",Vector2(1022,407),16,Color(0.91,0.66,1.0))
    _frame_label.size = Vector2(237,100)
    _frame_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _note_label = _text("Mẫu Shadow: tạo hình thử nghiệm, KHÔNG phải skill chính thức. Tám nút hướng chỉ kiểm tra facing/mirror, chưa có ảnh 8 hướng chuẩn.",Vector2(280,631),14,Color(0.89,0.78,0.96))
    _note_label.size = Vector2(966,76)
    _note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _text(value: String, pos: Vector2, font_size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = value
    label.position = pos
    label.add_theme_font_size_override("font_size",font_size)
    label.add_theme_color_override("font_color",tint)
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(label)
    return label

func _select(values: Array, pos: Vector2, dimensions: Vector2, callback: Callable) -> OptionButton:
    var select := OptionButton.new()
    select.position = pos
    select.size = dimensions
    for index in range(values.size()):
        select.add_item(str(values[index]),index)
    select.item_selected.connect(callback)
    add_child(select)
    return select

func _on_actor(index: int) -> void:
    _actor_index = index
    _shadow = bool(ACTORS[index]["shadow"])
    _shadow_toggle.set_pressed_no_signal(_shadow)
    _apply_selection()

func _on_action(index: int) -> void:
    _action_index = index
    _apply_selection()

func _on_direction(index: int) -> void:
    _direction_index = index
    _apply_selection()

func _on_speed(value: float) -> void:
    _speed = value
    _render_frame()

func _on_shadow(enabled: bool) -> void:
    _shadow = enabled
    _render_frame()

func _on_play() -> void:
    _playing = not _playing
    _play_button.text = "Tạm dừng" if _playing else "Tiếp tục"

func _on_restart() -> void:
    _elapsed = 0.0
    _playing = true
    _play_button.text = "Tạm dừng"
    _render_frame()

func _apply_selection() -> void:
    _elapsed = 0.0
    _render_frame()
    queue_redraw()

func _process(delta: float) -> void:
    _clock += maxf(0.0,delta)
    if _playing:
        _elapsed += maxf(0.0,delta) * _speed
        _render_frame()
    if _shadow:
        _shadow_material.set_shader_parameter("pulse",0.5 + 0.5 * sin(_clock * 2.0))
    queue_redraw()

func _facing() -> Vector2:
    var angle := float(_direction_index) * PI / 4.0
    return Vector2(cos(angle), -sin(angle))

func _key() -> String:
    return str(ACTORS[_actor_index]["key"])

func _action() -> String:
    return str(ACTIONS[_action_index])

func _probe_clip(actor_key: String, action: String) -> Dictionary:
    var cache_key := actor_key + "|" + action
    if _clip_probe_cache.has(cache_key):
        return _clip_probe_cache[cache_key]
    if not FileAccess.file_exists(MANIFEST):
        return {}
    var manifest = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not (manifest is Dictionary):
        return {}
    var actors: Dictionary = manifest.get("actors",{})
    var row: Dictionary = actors.get(actor_key,{})
    if row.is_empty():
        return {}
    var candidates: Array[String] = []
    match action:
        "attack","cast":
            candidates = ["attack1","attack"]
        "hit":
            candidates = ["hit"]
        "die":
            candidates = ["dead","die"]
        "walk","run":
            candidates = ["walk","run"]
        _:
            candidates = ["stand","idle1","idle","idle2"]
    var order := ["combat_asset","base_asset"] if action in ["attack","cast","hit","die"] else ["base_asset","combat_asset"]
    for field in order:
        var asset_id := str(row.get(field,""))
        if asset_id.is_empty():
            continue
        var asset_path := "res://assets/actors/%s/animations.tres" % asset_id
        if not ResourceLoader.exists(asset_path,"SpriteFrames"):
            continue
        var frames := load(asset_path) as SpriteFrames
        if frames == null:
            continue
        for candidate in candidates:
            if frames.has_animation(candidate) and frames.get_frame_count(candidate) > 0:
                var details := {
                    "asset":asset_id,
                    "clip":candidate,
                    "frames":frames.get_frame_count(candidate),
                    "fps":frames.get_animation_speed(candidate),
                    "duration":_clip_duration(frames,candidate),
                    "loop":frames.get_animation_loop(candidate),
                    "fallback":not _is_native_action(action,candidate)
                }
                _clip_probe_cache[cache_key] = details
                return details
    return {}

func _is_native_action(action: String, clip: String) -> bool:
    match action:
        "idle":
            return clip in ["stand","idle","idle1","idle2"]
        "die":
            return clip in ["dead","die"]
        "attack":
            return clip in ["attack1","attack"]
        _:
            return clip == action

func _clip_duration(frames: SpriteFrames, name: String) -> float:
    var total := 0.0
    var fps := maxf(0.001,frames.get_animation_speed(name))
    for n in range(frames.get_frame_count(name)):
        total += frames.get_frame_duration(name,n) / fps
    return total

func sample_evidence() -> Dictionary:
    var actual := _probe_clip(_key(),_action())
    var frame := _atlas.frame_region(_key(),_action(),_facing(),_elapsed)
    return {
        "actor_key":_key(),
        "requested_action":_action(),
        "requested_direction":str(DIRECTIONS[_direction_index]),
        "authored_eight_way":false,
        "direction_fidelity":"FACING_ONLY_MIRRORED",
        "shadow_prototype":_shadow,
        "source_clip":actual,
        "frame_index":int(frame.get("frame",-1)),
        "frame_loaded":not frame.is_empty() and frame.get("texture") != null,
        "presentation_only":true
    }

func configure_preview(actor_index: int, action_index: int, direction_index: int, shadow: bool) -> void:
    _actor_index = clampi(actor_index,0,ACTORS.size()-1)
    _action_index = clampi(action_index,0,ACTIONS.size()-1)
    _direction_index = clampi(direction_index,0,DIRECTIONS.size()-1)
    _shadow = shadow
    _elapsed = 0.0
    if is_node_ready():
        _actor_select.select(_actor_index)
        _action_select.select(_action_index)
        _direction_select.select(_direction_index)
        _shadow_toggle.set_pressed_no_signal(_shadow)
        _render_frame()

func _render_frame() -> void:
    if _sprite == null:
        return
    var actual := _probe_clip(_key(),_action())
    var frame := _atlas.frame_region(_key(),_action(),_facing(),_elapsed)
    if frame.is_empty() or actual.is_empty():
        _sprite.texture = null
        _info_label.text = "THIẾU ASSET / CLIP\n%s\n%s\nBLOCKED_BY_ASSET" % [_key(),_action()]
        _frame_label.text = "Không thể phát"
        return
    var texture: Texture2D = frame["texture"]
    var anchor: Vector2 = frame["anchor"]
    var ratio := float(frame["scale"]) * PREVIEW_ENLARGE
    var desired_left := _facing().x < -0.001
    var native_left := int(frame["source_face_x"]) < 0
    var mirrored := desired_left != native_left
    _sprite.texture = texture
    _sprite.flip_h = mirrored
    _sprite.scale = Vector2.ONE * ratio
    var source_x: float = texture.get_size().x - anchor.x if mirrored else anchor.x
    _sprite.position = PREVIEW_FOOT - Vector2(source_x,anchor.y) * ratio
    _sprite.material = _shadow_material if _shadow else null
    _sprite.modulate = Color.WHITE
    var fallback_text := "ADAPTER FALLBACK!" if bool(actual["fallback"]) else "Clip gốc phù hợp"
    _info_label.text = "Actor: %s\nAsset: %s\n\nClip thực: %s\nSố frame: %d\nFPS: %.1f\nDài: %.2f giây\n%s\n\nHướng: %s\nChỉ đổi facing/mirror" % [
        _key(),str(actual["asset"]),str(actual["clip"]),int(actual["frames"]),
        float(actual["fps"]),float(actual["duration"]),fallback_text,
        str(DIRECTIONS[_direction_index])]
    _frame_label.text = "FRAME %d / %d\nTốc độ %.2fx\n%s" % [
        int(frame.get("frame",0))+1,int(actual["frames"]),_speed,
        "SHADOW PROTOTYPE" if _shadow else "SOURCE A NGUYÊN BẢN"]

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO,Vector2(1280,720)),Color(0.035,0.042,0.075))
    draw_rect(Rect2(Vector2(255,105),Vector2(753,502)),Color(0.065,0.066,0.13))
    draw_rect(Rect2(Vector2(9,110),Vector2(244,505)),Color(0.075,0.08,0.13))
    draw_rect(Rect2(Vector2(1013,110),Vector2(259,505)),Color(0.075,0.08,0.13))
    draw_line(Vector2(255,105),Vector2(1008,105),Color(0.56,0.36,0.82),2.0)
    draw_line(Vector2(255,606),Vector2(1008,606),Color(0.36,0.25,0.58),2.0)
    for i in range(12):
        var xx := 275.0 + float(i)*62.0
        draw_line(Vector2(xx,116),Vector2(xx,603),Color(0.26,0.20,0.39,0.13),1.0)
    draw_arc(PREVIEW_FOOT + Vector2(0,18),130.0,0.0,TAU,72,
        Color(0.69,0.27,0.96,0.68 if _shadow else 0.25),2.5)
    draw_arc(PREVIEW_FOOT + Vector2(0,18),93.0,_clock * 0.4,_clock * 0.4+TAU*0.83,72,
        Color(0.72,0.35,1.0,0.48 if _shadow else 0.15),1.5)
    if _shadow and _action() in ["attack","cast"]:
        var alpha := 0.35 + 0.3 * sin(_clock * 4.0)
        draw_arc(PREVIEW_FOOT + Vector2(15,-142),175.0,-1.1,0.4,52,
            Color(0.75,0.28,1.0,alpha),7.0)
    draw_line(Vector2(PREVIEW_FOOT.x-22,PREVIEW_FOOT.y),
        Vector2(PREVIEW_FOOT.x+22,PREVIEW_FOOT.y),Color(0.3,0.95,0.78,0.65),2.0)
    draw_circle(PREVIEW_FOOT,4.0,Color(0.4,1.0,0.72,0.85))
