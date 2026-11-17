extends Control
## VIEW-ONLY in-project 4-style comparison. Real preexisting JX owner source
## vs the self-authored POI19 R3. No commercial asset redistribution or PvE.
const LAYER_SCRIPT=preload("res://labs/combat_lab/jx_reference_preview/r1/jx_effect_layer.gd")
const R3_SCENE=preload("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/phu_cot_co_tien_b.tscn")
const R3_SCRIPT=preload("res://labs/combat_lab/poison19_phu_cot_co_tien_b/r3/phu_cot_co_tien_b.gd")
const FX_ADAPTER=preload("res://src/presentation/p3/combat_v4_effect_atlas.gd")
const BACKGROUND: Texture2D=preload("res://labs/combat_lab/poison05/remake_r6/assets/immortal_valley.svg")
const DISCIPLE: Texture2D=preload("res://labs/character_family/assets/nu_doc_tu_v4_candidate/idle_4dir_APPROVED_UNCHANGED.png")
const MONSTERS: SpriteFrames=preload("res://assets/actors/v5_sa_monster_1113031_1/animations.tres")
const CASTER_FOOT:=Vector2(296.0,545.0)
const TARGET_BASE:=Vector2(895.0,548.0)
const DECOY_BASE:=Vector2(1090.0,556.0)
const MODE_SECONDS:=3.0
const STYLE_COUNT:=4
const TOTAL_SECONDS:=MODE_SECONDS*STYLE_COUNT
const LABELS = [
    "A  |  JX1 Võ Đang #158: thử giáng từ trên xuống",
    "B  |  JX1 Ngũ Độc #63: Impact (chỉ có atlas impact)",
    "C  |  Source VL: Kiếm - Cast → Impact",
    "D  |  POI19 R3: Linh lực Godot tự sản xuất"
]
const DESCRIPTIONS = [
    "10+17+8 frame gốc · quỹ đạo giáng xuống do LAB đặt, chưa xác thực chuyển động JX gốc",
    "Nguồn có sẵn trong repo · 13 frame impact · không bịa precast",
    "Nguồn có sẵn trong repo · 36 frame cast + 21 frame impact",
    "80 sprite RGBA + native gradient ADD · 1 mục tiêu · LAB only"
]
var clock: float=0.0
var manual_style: int=-1
var paused: bool=false
var current_mode: int=0
var current_local_t: float=0.0
var jx_layer: Control
var r3_layer: Control
var info_label: Label
var detail_label: Label

static func target_foot(t: float)->Vector2:
    return TARGET_BASE+Vector2(31.0*sin(2.0*t+.2),8.5*cos(1.3*t))
static func decoy_foot(t: float)->Vector2:
    return DECOY_BASE+Vector2(15.0*sin(2.7*t+1.1),7.0*cos(1.5*t))

func _ready()->void:
    custom_minimum_size=Vector2(1280,720)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    jx_layer=LAYER_SCRIPT.new()
    jx_layer.name="NativeReferenceAtlasEffectLayer"
    add_child(jx_layer)
    r3_layer=R3_SCENE.instantiate()
    r3_layer.name="OriginalPOI19GodotR3Comparison"
    add_child(r3_layer)
    r3_layer.paused=true
    r3_layer.visible=false
    info_label=Label.new()
    info_label.position=Vector2(20,14)
    info_label.add_theme_font_size_override("font_size",22)
    info_label.add_theme_color_override("font_color",Color(1,.91,1))
    add_child(info_label)
    detail_label=Label.new()
    detail_label.position=Vector2(22,49)
    detail_label.add_theme_font_size_override("font_size",15)
    detail_label.add_theme_color_override("font_color",Color(.78,.94,.88))
    add_child(detail_label)
    _sync(true)
    print("JX_VLTK_IN_GAME_AB_READY 4_styles_existing_owner_atlas=true original_source_not_redistributed=true R3_godot_baseline=true no_gameplay_mutation=true")

func _process(delta: float)->void:
    if not paused:
        clock=fposmod(clock+maxf(0.0,delta),TOTAL_SECONDS if manual_style<0 else MODE_SECONDS)
    _sync(false)

func _sync(_force: bool)->void:
    current_mode=(int(floor(clock/MODE_SECONDS))%STYLE_COUNT) if manual_style<0 else manual_style
    current_local_t=fposmod(clock,MODE_SECONDS)
    var target:=target_foot(current_local_t)
    var using_r3:=current_mode==3
    jx_layer.visible=not using_r3
    jx_layer.update_cue(current_mode,current_local_t,target)
    r3_layer.visible=using_r3
    if using_r3:
        r3_layer.clock=current_local_t
        if r3_layer.energy_flow!=null:
            r3_layer.energy_flow.set_visual_state(current_local_t,
                target,R3_SCRIPT.mark_anchor_at(current_local_t),
                R3_SCRIPT.projectile_pos(current_local_t),
                R3_SCRIPT.mark_gain(current_local_t))
        r3_layer.queue_redraw()
    info_label.text=LABELS[current_mode]
    detail_label.text=DESCRIPTIONS[current_mode]+"  |  1–4 chọn hiệu ứng · A tự chạy · Space bắt đầu lại"
    queue_redraw()

func _unhandled_input(event: InputEvent)->void:
    if not(event is InputEventKey) or not event.pressed or event.echo:return
    match event.keycode:
        KEY_1,KEY_2,KEY_3,KEY_4:
            manual_style=int(event.keycode)-int(KEY_1)
            clock=0.0
        KEY_A:
            manual_style=-1
            clock=0.0
        KEY_SPACE:
            clock=0.0
        KEY_P:
            paused=not paused

func _draw_actor()->void:
    draw_texture_rect_region(DISCIPLE,
        Rect2(CASTER_FOOT-Vector2(160,351)*.47,Vector2(320,384)*.47),
        Rect2(0,0,320,384),Color.WHITE)
func _draw_monster(pos: Vector2,t: float)->void:
    var count:=MONSTERS.get_frame_count("walk")
    var frame:=MONSTERS.get_frame_texture("walk",int(t*15)%maxi(count,1))
    draw_texture_rect(frame,Rect2(pos-Vector2(76,139),Vector2(152,139)),
        false,Color(1,1,1,.97))
func _draw()->void:
    # Existing Godot 1280x720 battle scene, not an external slideshow.
    draw_texture_rect(BACKGROUND,Rect2(0,0,1280,720),false,Color.WHITE)
    _draw_monster(target_foot(current_local_t),current_local_t)
    _draw_monster(decoy_foot(current_local_t),current_local_t+.22)
    _draw_actor()
    draw_rect(Rect2(7,3,1105,76),Color(.035,.027,.085,.70),true)
    draw_rect(Rect2(6,686,1268,26),Color(.025,.031,.07,.62),true)
    var font:=ThemeDB.fallback_font
    draw_string(font,Vector2(18,704),
        "VLTK/JX1: visual R&D nội bộ, chưa được xác minh quyền phát hành. KHÔNG làm thay đổi Combat V2/PvE.",
        HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color(.89,.82,1,.95))
