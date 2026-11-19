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
        foot: Vector2,facing: Vector2,age: float,scale: float) -> bool:
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
    var fps := 8.0
    var index := int(maxf(age,0.0)*fps)
    if not atlas.is_empty():
        var columns := maxi(1,int(atlas.get("grid_columns",4)))
        index = mini(index,columns-1) if action in ["die","death"] else index % columns
        var sheet := _cel(str(atlas.get("path","")))
        if sheet == null:
            return false
        var size_data: Array = atlas.get("cell_px",[256,256])
        var cell := Vector2(float(size_data[0]),float(size_data[1]))
        var row_index := int(Dictionary(atlas.get("rows",{})).get(verb,0))
        var src := Rect2(Vector2(index*cell.x,row_index*cell.y),cell)
        var baseline := float(cell.y)*0.935
        canvas.draw_texture_rect_region(sheet,Rect2(foot-Vector2(cell.x*0.5,baseline)*scale,
            cell*scale),src)
        # Do not invent side-facing grip positions absent from the manifest.
        return true
    if not frames.has(clip):
        return false
    var items: Array = frames[clip]
    if items.is_empty():
        return false
    index = mini(index,items.size()-1) if action in ["die","death"] else index % items.size()
    var row: Dictionary = items[index]
    var texture := _cel(str(row.get("path","")))
    if texture == null:
        return false
    var baseline := float(row.get("source_foot_baseline_y_px",manifest.get("foot_baseline_y_px",359.0)))
    var center := Vector2(texture.get_width()*0.5,baseline)
    _draw_props(canvas,manifest,row,foot,center,scale,true)
    canvas.draw_texture_rect(texture,Rect2(foot-center*scale,texture.get_size()*scale),false)
    _draw_props(canvas,manifest,row,foot,center,scale,false)
    return true

static func _draw_props(canvas: CanvasItem,manifest: Dictionary,row: Dictionary,
        foot: Vector2,center: Vector2,scale: float,behind: bool) -> void:
    var grips: Dictionary = row.get("grip_sockets",{})
    for attachment in manifest.get("attachments",[]):
        if not (attachment is Dictionary):
            continue
        var slot := str(attachment.get("slot",""))
        var grip: Dictionary = grips.get(slot,{})
        if grip.is_empty() and slot != "main_hand":
            grip = grips.get("main_hand",{})
        if grip.is_empty():
            continue
        if not bool(row.get("weapon_visible",true)) and not slot.begins_with("hand_"):
            continue
        var back := str(grip.get("draw_order","")).contains("BEHIND")
        if back != behind:
            continue
        var asset_id := str(attachment.get("asset_id",""))
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
        var at := foot+(Vector2(float(anchor[0]),float(anchor[1]))-center)*scale
        canvas.draw_set_transform(at,deg_to_rad(float(grip.get("rotation_deg",0.0))),
            Vector2.ONE*scale*maxf(weapon_scale,0.01))
        canvas.draw_texture(tex,-Vector2(float(weapon_grip[0]),float(weapon_grip[1])))
        canvas.draw_set_transform(Vector2.ZERO)
