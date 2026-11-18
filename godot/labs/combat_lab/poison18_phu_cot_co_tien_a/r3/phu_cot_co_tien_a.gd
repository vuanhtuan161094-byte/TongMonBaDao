extends "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r2/phu_cot_co_tien_a.gd"
## POI18 R3: isolated gu-flight remaster; R2C gather/burst/mark remain unchanged.
const R3_GU_ATLAS := "res://labs/combat_lab/poison18_phu_cot_co_tien_a/r3/assets/poi18_gu_16.png"
func _ready() -> void:
    super._ready()
    if not ResourceLoader.exists(R3_GU_ATLAS):
        push_error("POI18_R3_GU_MISSING "+R3_GU_ATLAS)
        set_process(false)
        return
    var tex:=load(R3_GU_ATLAS) as Texture2D
    if tex==null or tex.get_size()!=Vector2(1280,1024):
        push_error("POI18_R3_GU_BAD_ATLAS")
        set_process(false)
        return
    gu_frames.clear()
    for i in range(16):
        gu_frames.append(_atlas(tex,i,Vector2(320,256)))
    print("POI18_PHU_COT_CO_TIENA_R3_READY original_gu_poses=16 frozen_r2_other_phases=true moving_target_mark=true gameplay_receipt=false owner_art_pending=true")
    queue_redraw()
