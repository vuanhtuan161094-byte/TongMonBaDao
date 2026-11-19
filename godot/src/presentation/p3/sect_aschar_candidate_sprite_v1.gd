extends AnimatedSprite2D
class_name SectASCharCandidateSpriteV1
## Candidate AS-CHAR held prop renderer: independent Sprite2D per socket,
## per authored keyframe; no rig, frame generation or VFX. The source manifests
## are read-only. A known missing grip is used as recorded fallback, not silently
## claimed as artist-approved.
@export_file("*.json") var socket_manifest_path := ""
const WEAPON_LIBRARY := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
var _socket_frames: Dictionary = {}
var _props: Dictionary = {}
var _body_baseline := 359.0
var _attachments: Array = []
var _asset_library: Dictionary = {}
var _source_weapon: Dictionary = {}

func _ready() -> void:
    centered = true
    var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(socket_manifest_path))
    if data is Dictionary:
        _body_baseline = float(data.get("foot_baseline_y_px",359.0))
        _attachments = Array(data.get("attachments",[]))
        _source_weapon = Dictionary(data.get("weapon_asset",{}))
        for row in data.get("body_frames",[]):
            if row is Dictionary:
                _socket_frames["%s:%d" % [str(row.get("clip","")),int(row.get("frame",-1))]] = row
    var library: Variant = JSON.parse_string(FileAccess.get_file_as_string(WEAPON_LIBRARY))
    if library is Dictionary:
        _asset_library = Dictionary(library.get("asset_library",{}))
    for attach in _attachments:
        if not (attach is Dictionary):
            continue
        var asset_id := str(attach.get("asset_id",""))
        var info: Dictionary = _asset_library.get(asset_id,{})
        if asset_id == "owner_liked_jian_existing":
            info = _source_weapon
        var path := str(info.get("path",""))
        if path.is_empty() or not ResourceLoader.exists(path,"Texture2D"):
            continue
        var texture := ResourceLoader.load(path,"Texture2D") as Texture2D
        if texture == null:
            continue
        var prop := Sprite2D.new()
        prop.name = "ASCHARHeld_"+asset_id
        prop.texture = texture
        prop.centered = false
        prop.mouse_filter = CanvasItem.MOUSE_FILTER_IGNORE if false else Control.MOUSE_FILTER_IGNORE
        add_child(prop)
        _props[str(attach.get("slot",""))] = {
            "node":prop,"asset":info,"slot":str(attach.get("slot",""))}
    frame_changed.connect(_aschar_frame_changed)
    animation_changed.connect(_aschar_frame_changed)
    _aschar_frame_changed()

func _aschar_frame_changed() -> void:
    if sprite_frames == null or not sprite_frames.has_animation(animation):
        return
    var tex := sprite_frames.get_frame_texture(animation,frame)
    if tex == null:
        return
    var source_action := str(animation)
    if source_action == "stand":
        source_action = "idle_front"
    elif source_action == "walk":
        source_action = "walk_front" if _socket_frames.has("walk_front:%d" % frame) else "idle_front"
    var raw: Dictionary = _socket_frames.get("%s:%d" % [source_action,frame],{})
    var grips: Dictionary = raw.get("grip_sockets",{})
    var baseline := float(raw.get("source_foot_baseline_y_px",
        430.0 if tex.get_size() == Vector2(400,440) else _body_baseline))
    offset = Vector2(0.0,tex.get_height()*0.5-baseline)
    var foot := Vector2(tex.get_width()*0.5,baseline)
    for row in _props.values():
        var prop: Sprite2D = row["node"]
        var slot := str(row.get("slot",""))
        var grip: Dictionary = grips.get(slot,{})
        if grip.is_empty() and slot != "main_hand":
            grip = grips.get("main_hand",{})
        if grip.is_empty():
            prop.visible = false
            continue
        var info: Dictionary = row["asset"]
        var anchor: Array = grip.get("body_grip_px",[foot.x,foot.y-100])
        var weapon_grip: Array = info.get("grip_px",
            info.get("asset_grip_px",[prop.texture.get_width()*0.5,prop.texture.get_height()*0.5]))
        var base_scale := float(info.get("asset_scale",0.0))
        var socket_scale := float(grip.get("scale_multiplier",0.30))
        if base_scale <= 0.0:
            base_scale = socket_scale
        prop.position = Vector2(float(anchor[0]),float(anchor[1]))-foot
        prop.scale = Vector2.ONE*maxf(base_scale,0.01)
        prop.offset = -Vector2(float(weapon_grip[0]),float(weapon_grip[1]))
        prop.rotation_degrees = float(grip.get("rotation_deg",0.0))
        prop.visible = bool(raw.get("weapon_visible",true)) or slot.begins_with("hand_")
        prop.show_behind_parent = str(grip.get("draw_order","")).contains("BEHIND")
