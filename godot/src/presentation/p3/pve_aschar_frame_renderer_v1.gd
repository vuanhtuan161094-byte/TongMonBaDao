class_name PveASCharFrameRendererV1
extends RefCounted
## Presentation-only adapter: existing AS-CHAR SpriteFrames and per-frame weapon
## sockets. No rig, generation, Combat/Save authority or unlocked V6.3 skills.
const BRIDGE = preload("res://src/presentation/p3/sect_aschar_candidate_bridge_v1.gd")
const WEAPON_LIBRARY := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
static var _frames: Dictionary = {}
static var _sockets: Dictionary = {}
static var _weapons: Dictionary = {}
static var _library: Dictionary = {}
static var _clip_rows: Dictionary = {}
static var _cel_cache: Dictionary = {}
static var _cel_order: Array[String] = []
const MAX_CACHED_CELS := 160

static func _manifest(actor_id: int) -> Dictionary:
    if _sockets.has(actor_id):
        return _sockets[actor_id]
    var path := BRIDGE.SOCKET_ROOT+"/AS%d_weapon_sockets_v9_3_candidate.json" % actor_id
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
    _sockets[actor_id] = parsed if parsed is Dictionary else {}
    return _sockets[actor_id]

static func _sprite_frames(actor_id: int) -> SpriteFrames:
    if _frames.has(actor_id):
        return _frames[actor_id]
    var path := str(BRIDGE.SOURCE_PATHS.get(actor_id,""))
    var frames: SpriteFrames = null
    if ResourceLoader.exists(path,"SpriteFrames"):
        frames = ResourceLoader.load(path,"SpriteFrames") as SpriteFrames
    _frames[actor_id] = frames
    return frames

static func _direction(facing: Vector2) -> String:
    if absf(facing.y) > absf(facing.x):
        return "front" if facing.y >= 0.0 else "back"
    return "right" if facing.x >= 0.0 else "left"

static func resolve_clip(frames: SpriteFrames,action: String,facing: Vector2) -> String:
    var verb := "idle"
    match action:
        "run","walk": verb = "walk"
        "attack": verb = "attack"
        "cast": verb = "cast"
        "hit": verb = "hit"
        "die","death": verb = "downed"
    for candidate in [verb+"_"+_direction(facing),verb+"_front","idle_"+_direction(facing),"idle_front","stand"]:
        if frames.has_animation(StringName(candidate)) and frames.get_frame_count(StringName(candidate)) > 0:
            return candidate
    return ""

static func _weapon_info(manifest: Dictionary,asset_id: String) -> Dictionary:
    if _library.is_empty():
        var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(WEAPON_LIBRARY))
        if parsed is Dictionary:
            _library = Dictionary(parsed.get("asset_library",{}))
    if asset_id == "owner_liked_jian_existing":
        return Dictionary(manifest.get("weapon_asset",{}))
    return Dictionary(_library.get(asset_id,{}))

static func _cel(path: String) -> Texture2D:
    if _cel_cache.has(path):
        return _cel_cache[path]
    if not ResourceLoader.exists(path,"Texture2D"):
        return null
    var tex := ResourceLoader.load(path,"Texture2D",ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
    if tex != null:
        _cel_cache[path] = tex
        _cel_order.append(path)
        if _cel_order.size() > MAX_CACHED_CELS:
            _cel_cache.erase(_cel_order.pop_front())
    return tex

static func _rows(actor_id: int,manifest: Dictionary) -> Dictionary:
    if _clip_rows.has(actor_id):
        return _clip_rows[actor_id]
    var rows: Dictionary = {}
    for raw in manifest.get("body_frames",[]):
        if raw is Dictionary:
            var clip := str(raw.get("clip",""))
            if not rows.has(clip):
                rows[clip] = []
            rows[clip].append(raw)
    _clip_rows[actor_id] = rows
    return rows

static func draw_actor(canvas: CanvasItem,school: String,sex: String,action: String,
        foot: Vector2,facing: Vector2,age: float,scale: float,action_seconds: float = 0.0,
        preview_attachment_override: Dictionary = {}) -> bool:
    var actor_id := BRIDGE.actor_id(school,sex)
    if actor_id < 0:
        return false
    var manifest := _manifest(actor_id)
    if manifest.is_empty():
        return false
    var verb := "idle"
    match action:
        "run","walk": verb = "walk"
        "attack": verb = "attack"
        "cast": verb = "cast"
        "hit": verb = "hit"
        "die","death": verb = "downed"
    var direction := _direction(facing)
    var frames := _rows(actor_id,manifest)
    var clip := verb+"_"+direction
    var atlas: Dictionary = {}
    if not frames.has(clip):
        # AS48/49 carry 4-direction source atlases; sockets are front-only.
        atlas = Dictionary(manifest.get("directional_atlases",{})).get(direction,{})
        if atlas.is_empty() or not Dictionary(atlas.get("rows",{})).has(verb):
            clip = verb+"_front"
            atlas = {}
    if not frames.has(clip) and atlas.is_empty():
        clip = "idle_"+direction
    if not frames.has(clip) and atlas.is_empty():
        clip = "idle_front"
    var index := 0
    if not atlas.is_empty():
        var columns := maxi(1,int(atlas.get("grid_columns",4)))
        index = frame_index(action,age,columns,action_seconds)
        var sheet := _cel(str(atlas.get("path","")))
        if sheet == null:
            return false
        var size_data: Array = atlas.get("cell_px",[256,256])
        var cell := Vector2(float(size_data[0]),float(size_data[1]))
        var row_index := int(Dictionary(atlas.get("rows",{})).get(verb,0))
        var src := Rect2(Vector2(index*cell.x,row_index*cell.y),cell)
        # Side atlas cells can be 256px while authored front frames are
        # 384px. Match body-canvas height and foot baseline at the same PvE zoom.
        var canvas_size: Array = manifest.get("body_canvas_px",[384,384])
        var authored_height := maxf(1.0,float(canvas_size[1]))
        var atlas_scale := scale*authored_height/maxf(1.0,cell.y)
        var baseline := float(manifest.get("foot_baseline_y_px",359.0))*cell.y/authored_height
        canvas.draw_texture_rect_region(sheet,Rect2(foot-Vector2(cell.x*0.5,baseline)*atlas_scale,
            cell*atlas_scale),src)
        # Do not invent side-facing grip positions absent from the manifest.
        return true
    if not frames.has(clip):
        return false
    var items: Array = frames[clip]
    if items.is_empty():
        return false
    index = frame_index(action,age,items.size(),action_seconds)
    var row: Dictionary = items[index]
    var texture := _cel(str(row.get("path","")))
    if texture == null:
        return false
    var baseline := float(row.get("source_foot_baseline_y_px",manifest.get("foot_baseline_y_px",359.0)))
    var center := Vector2(texture.get_width()*0.5,baseline)
    _draw_props(canvas,manifest,row,foot,center,scale,true,preview_attachment_override)
    canvas.draw_texture_rect(texture,Rect2(foot-center*scale,texture.get_size()*scale),false)
    _draw_props(canvas,manifest,row,foot,center,scale,false,preview_attachment_override)
    if not preview_attachment_override.is_empty():
        _restore_preview_hands(canvas,row,texture,foot,center,scale,
            preview_attachment_override.get("restore_hand_slots",[]))
    return true

static func frame_index(action: String,age: float,count: int,action_seconds: float = 0.0) -> int:
    if count <= 1:
        return 0
    var index := int(maxf(age,0.0)*8.0)
    if action in ["attack","cast","hit"] and action_seconds > 0.0:
        index = int(clampf(age/action_seconds,0.0,1.0)*float(count))
    return index % count if action in ["idle","run","walk"] else mini(index,count-1)

static func aligned_weapon_rotation_deg(body_anchor_px: Array,body_direction_px: Array,
        weapon_grip_px: Array,weapon_tip_px: Array,fallback_deg: float = 0.0,
        offset_deg: float = 0.0) -> float:
    if body_anchor_px.size() != 2 or body_direction_px.size() != 2 or weapon_grip_px.size() != 2 or weapon_tip_px.size() != 2:
        return fallback_deg+offset_deg
    var hand_axis := Vector2(float(body_direction_px[0])-float(body_anchor_px[0]),
        float(body_direction_px[1])-float(body_anchor_px[1]))
    var asset_axis := Vector2(float(weapon_tip_px[0])-float(weapon_grip_px[0]),
        float(weapon_tip_px[1])-float(weapon_grip_px[1]))
    if hand_axis.length_squared() <= 0.001 or asset_axis.length_squared() <= 0.001:
        return fallback_deg+offset_deg
    return rad_to_deg(hand_axis.angle()-asset_axis.angle())+offset_deg

static func _draw_props(canvas: CanvasItem,manifest: Dictionary,row: Dictionary,
        foot: Vector2,center: Vector2,scale: float,behind: bool,
        preview_attachment_override: Dictionary = {}) -> void:
    var grips: Dictionary = row.get("grip_sockets",{})
    for attachment in manifest.get("attachments",[]):
        if not (attachment is Dictionary):
            continue
        var slot := str(attachment.get("slot",""))
        var asset_id := str(attachment.get("asset_id",""))
        var anchor_slot := slot
        if asset_id == str(preview_attachment_override.get("asset_id","")):
            anchor_slot = str(preview_attachment_override.get("anchor_slot",slot))
        var grip: Dictionary = grips.get(anchor_slot,{})
        if grip.is_empty():
            continue
        if not bool(row.get("weapon_visible",true)) and not slot.begins_with("hand_"):
            continue
        var back := str(grip.get("draw_order","")).contains("BEHIND")
        if back != behind:
            continue
        var info := _weapon_info(manifest,asset_id)
        var path := str(info.get("path",""))
        if not ResourceLoader.exists(path,"Texture2D"):
            continue
        if not _weapons.has(path):
            _weapons[path] = ResourceLoader.load(path,"Texture2D")
        var tex := _weapons[path] as Texture2D
        if tex == null:
            continue
        var anchor: Array = grip.get("body_grip_px",[center.x,center.y-100.0])
        var weapon_grip: Array = info.get("grip_px",info.get("asset_grip_px",[tex.get_width()*0.5,tex.get_height()*0.5]))
        var weapon_scale := float(info.get("asset_scale",0.0))
        if weapon_scale <= 0.0:
            weapon_scale = float(grip.get("scale_multiplier",0.30))
        if asset_id == str(preview_attachment_override.get("asset_id","")):
            weapon_scale = float(preview_attachment_override.get("asset_scale",weapon_scale))
        var at := foot+(Vector2(float(anchor[0]),float(anchor[1]))-center)*scale
        var rotation_deg := float(grip.get("rotation_deg",0.0))
        if asset_id == str(preview_attachment_override.get("asset_id","")):
            var asset_tip: Array = info.get("tip_px",[])
            var rotation_offset := float(preview_attachment_override.get("rotation_offset_deg",0.0))
            var direction_value: Variant = preview_attachment_override.get("align_tip_to_direction",[])
            var world_direction := Vector2.ZERO
            if direction_value is Vector2:
                world_direction = direction_value
            elif direction_value is Array and direction_value.size() == 2:
                world_direction = Vector2(float(direction_value[0]),float(direction_value[1]))
            if world_direction.length_squared() > 0.001:
                rotation_deg = aligned_weapon_rotation_deg([0.0,0.0],
                    [world_direction.x,world_direction.y],weapon_grip,asset_tip,
                    rotation_deg,rotation_offset)
            else:
                var direction_slot := str(preview_attachment_override.get("align_tip_to_slot",""))
                var direction_grip: Dictionary = grips.get(direction_slot,{})
                var direction_anchor: Array = direction_grip.get("body_grip_px",[])
                rotation_deg = aligned_weapon_rotation_deg(anchor,direction_anchor,weapon_grip,asset_tip,
                    rotation_deg,rotation_offset)
        canvas.draw_set_transform(at,deg_to_rad(rotation_deg),
            Vector2.ONE*scale*maxf(weapon_scale,0.01))
        canvas.draw_texture(tex,-Vector2(float(weapon_grip[0]),float(weapon_grip[1])))
        canvas.draw_set_transform(Vector2.ZERO)

static func _restore_preview_hands(canvas: CanvasItem,row: Dictionary,texture: Texture2D,
        foot: Vector2,center: Vector2,scale: float,slots: Array) -> void:
    var grips: Dictionary = row.get("grip_sockets",{})
    for raw_slot in slots:
        var grip: Dictionary = grips.get(str(raw_slot),{})
        var mask: Array = grip.get("hand_mask_rect_px",[])
        if mask.size() != 4:
            continue
        var source_rect := Rect2(Vector2(float(mask[0]),float(mask[1])),Vector2(float(mask[2]),float(mask[3])))
        var destination_rect := Rect2(foot+(source_rect.position-center)*scale,source_rect.size*scale)
        canvas.draw_texture_rect_region(texture,destination_rect,source_rect)
