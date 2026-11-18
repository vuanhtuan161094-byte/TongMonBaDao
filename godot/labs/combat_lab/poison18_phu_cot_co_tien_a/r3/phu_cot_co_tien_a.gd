extends "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r2/phu_cot_co_tien_a.gd"
## POI18 R3.1 — Ngoc To Linh Co: revised ONLY gu-flight master and local transition.
## All 32 accepted R2C gather/burst/seal poses unchanged; LAB is render-only.
const R3_GU_ATLAS := "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r3/assets/poi18_gu_16.png"
const R31_HEAD_LOCAL := Vector2(80.0,-8.0) # Original 320x256 key-pose coordinates relative to center.
const R31_IMPLODE_SECONDS := 0.16

static func head_offset(dim: Vector2) -> Vector2:
    return Vector2(R31_HEAD_LOCAL.x*dim.x/320.0,R31_HEAD_LOCAL.y*dim.y/256.0)

func _ready() -> void:
    super._ready()
    if not ResourceLoader.exists(R3_GU_ATLAS):
        push_error("POI18_R31_GU_MISSING "+R3_GU_ATLAS)
        set_process(false)
        return
    var tex:=load(R3_GU_ATLAS) as Texture2D
    if tex==null or tex.get_size()!=Vector2(1280,1024):
        push_error("POI18_R31_GU_BAD_ATLAS")
        set_process(false)
        return
    gu_frames.clear()
    for i in range(16):
        gu_frames.append(_atlas(tex,i,Vector2(320,256)))
    print("POI18_PHU_COT_CO_TIENA_R31_READY gu_poses=16 head_atlas_anchor=(80,-8) frozen_r2_other_phases=true moving_target_mark=true gameplay_receipt=false owner_art_pending=true")
    queue_redraw()

func _pose(frames: Array[AtlasTexture],pos: Vector2,dim: Vector2,frame_f: float,opacity: float) -> void:
    # Only the new 16-pose gu artwork gets a tip-aligned pivot. This honors
    # the unchanged R2C 8/12/12 pose positions and the existing moving target.
    if frames.size()==16:
        super._pose(frames,pos-head_offset(dim),dim,frame_f,opacity)
    else:
        super._pose(frames,pos,dim,frame_f,opacity)

func _draw() -> void:
    super._draw()
    # Local visual bridge, not a new hit, damage/mark or real Combat V2 receipt.
    # End of the gu silk draws into its own head for 160 ms and then reveals
    # unchanged R2C contact burst; decoy is never marked.
    if gu_frames.size()!=16: return
    var t:=clock
    if t>=CONTACT_AT and t<CONTACT_AT+R31_IMPLODE_SECONDS:
        var q:=smoothstep(CONTACT_AT,CONTACT_AT+R31_IMPLODE_SECONDS,t)
        var dim:=Vector2(204.0,154.0)*(1.0-.62*q)
        _pose(gu_frames,target_foot(t)+Vector2(-13.0,-70.0),dim,15.0,.55*(1.0-q))
