extends Control
## Internal visual AB only: use 3 existing owner-provided repo VLTK/JX effects.
## Frames are pulled via the EXISTING CombatV4EffectAtlas, with exact source
## frame_ms/rect/anchor. No source binaries added, no gameplay state changes.
const ADAPTER = preload("res://src/presentation/p3/combat_v4_effect_atlas.gd")
const CASTER_HAND := Vector2(352.0,449.0)
var atlas: RefCounted = ADAPTER.new()
var current_style: int = 0
var local_time: float = 0.0
var selected_target: Vector2 = Vector2(895.0,548.0)

func _ready() -> void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_preset(Control.PRESET_FULL_RECT)
    var mat:=CanvasItemMaterial.new()
    mat.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD
    material=mat

func update_cue(style: int,t: float,target: Vector2) -> void:
    current_style=style
    local_time=t
    selected_target=target
    queue_redraw()

func _native(kind: String,position: Vector2,elapsed: float,art_scale: float) -> void:
    # Exact native atlas adapter; if a frame is out of bounds, it is skipped.
    atlas.draw_effect(self,kind,position,elapsed,art_scale)

func _draw() -> void:
    var t:=local_time
    var target_chest:=selected_target+Vector2(0.0,-77.0)
    match current_style:
        0:
            # Existing JX1 Wudang #158: 10 precast, 17 cast and 8 impact frames.
            if t < .50:
                _native("jx_wudang_158_precast",CASTER_HAND,t,.95)
            elif t<1.35:
                var progress:=clampf((t-.50)/.85,0,1)
                var moving_dest:=target_chest+Vector2(-20,-12)
                var at:=CASTER_HAND.lerp(moving_dest,progress)
                at+=Vector2(0,-55.0*sin(progress*PI))
                _native("jx_wudang_158_cast",at,t-.50,.47)
            elif t<1.67:
                _native("jx_wudang_158_impact",target_chest,t-1.35,1.12)
        1:
            # Existing Wudu #63 atlas is an IMPACT ONLY; no invented precast
            # or flight source frames are labelled original.
            if t>=1.15 and t<1.878:
                _native("jx_wudu_63_impact",target_chest,t-1.15,1.60)
        2:
            # Existing Source VL Jianchui Xinghe cast/hit, NOT POI19 gameplay.
            if t>=.30 and t<1.38:
                var progress:=clampf((t-.30)/1.08,0.0,1.0)
                var at:=CASTER_HAND.lerp(target_chest,progress)
                at+=Vector2(0,-47.0*sin(progress*PI))
                _native("sword_cast",at,t-.30,.67)
            elif t>=1.38 and t<2.01:
                _native("sword_hit",target_chest,t-1.38,1.15)
        _:
            pass
