class_name PveASCharFrameRendererV1
extends RefCounted
## Presentation-only adapter: existing AS-CHAR SpriteFrames and per-frame weapon
## sockets. No rig, generation, Combat/Save authority or unlocked V6.3 skills.
const BRIDGE = preload("res://src/presentation/p3/aschar_visual_identity_v1.gd")
const WEAPON_LIBRARY := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
static var _frames: Dictionary = {}
static var _sockets: Dictionary = {}
static var _weapons: Dictionary = {}
static var _library: Dictionary = {}
static var _clip_rows: Dictionary = {}
static var _cel_cache: Dictionary = {}
static var _cel_order: Array[String] = []
const MAX_CACHED_CELS := 160

# The actual PvE world presenter uses 0.22 for its 1x AS-CHAR drawing baseline
# (with camera/spectator zoom applied separately). Keep this shared and actor-
# agnostic; frame dimensions, baselines, sockets, weapon scale and pivots remain
# asset metadata owned by the renderer and its manifests.
const GAME_VIEW_SCALE_1X := 0.22

static func game_view_scale(spectator_zoom: float = 1.0) -> float:
    return GAME_VIEW_SCALE_1X * maxf(0.0, spectator_zoom)

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

## Resolve a display-space anchor from the same frame and metadata used by
## draw_actor(). Supported slots: foot, body_center, hand_r, hand_l, main_hand,
## off_hand, weapon_grip and weapon_tip. A result has `ok`, `position`, `slot`,
## `actor_id`, `clip`, `frame_index`, `scale`; weapon anchors also include
## `asset_id`, `weapon_scale`, `rotation_deg`, and `draw_order`. Missing authored
## socket/weapon metadata returns `{ok:false, reason:...}` instead of guessing.
static func resolve_preview_anchor(school: String,sex: String,action: String,
        facing: Vector2,age: float,foot: Vector2,scale: float,slot: String,
        action_seconds: float = 0.0,preview_attachment_override: Dictionary = {}) -> Dictionary:
    var actor_id := BRIDGE.actor_id(school,sex)
    if actor_id < 0:
        return {"ok":false,"reason":"unknown_actor_school","slot":slot}
    if slot == "foot":
        return {"ok":true,"position":foot,"slot":slot,"actor_id":actor_id,"clip":"foot","frame_index":0,"scale":scale}
    var manifest := _manifest(actor_id)
    if manifest.is_empty():
        return {"ok":false,"reason":"actor_socket_manifest_missing","slot":slot,"actor_id":actor_id}
    var verb := "idle"
    match action:
        "run","walk": verb = "walk"
        "attack": verb = "attack"
        "cast": verb = "cast"
        "hit": verb = "hit"
        "die","death": verb = "downed"
    var direction := _direction(facing)
    var frame_rows := _rows(actor_id,manifest)
    var clip := verb+"_"+direction
    var atlas: Dictionary = {}
    if not frame_rows.has(clip):
        # Match draw_actor()'s four-direction atlas fallback. Those atlases have
        # no hand sockets, so only their pixel-derived body center can be resolved.
        atlas = Dictionary(manifest.get("directional_atlases",{})).get(direction,{})
        if atlas.is_empty() or not Dictionary(atlas.get("rows",{})).has(verb):
            clip = verb+"_front"
            atlas = {}
    if not frame_rows.has(clip) and atlas.is_empty():
        clip = "idle_"+direction
    if not frame_rows.has(clip) and atlas.is_empty():
        clip = "idle_front"
    if not atlas.is_empty():
        if slot != "body_center":
            return {"ok":false,"reason":"directional_atlas_has_no_authored_socket","slot":slot,"actor_id":actor_id,"clip":clip}
        var columns := maxi(1,int(atlas.get("grid_columns",4)))
        var index := frame_index(action,age,columns,action_seconds)
        var sheet := _cel(str(atlas.get("path","")))
        if sheet == null:
            return {"ok":false,"reason":"directional_atlas_missing","slot":slot,"actor_id":actor_id,"clip":clip}
        var cell_data: Array = atlas.get("cell_px",[256,256])
        var cell := Vector2(float(cell_data[0]),float(cell_data[1]))
        var canvas_data: Array = manifest.get("body_canvas_px",[384,384])
        var authored_height := maxf(1.0,float(canvas_data[1]))
        var atlas_scale := scale*authored_height/maxf(1.0,cell.y)
        var baseline := float(manifest.get("foot_baseline_y_px",359.0))*cell.y/authored_height
        var body_center := foot+(Vector2(index*cell.x+cell.x*0.5,cell.y*0.5)-Vector2(index*cell.x+cell.x*0.5,baseline))*atlas_scale
        return {"ok":true,"position":body_center,"slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"scale":atlas_scale,"source_px":cell*0.5}
    if not frame_rows.has(clip):
        return {"ok":false,"reason":"actor_clip_missing","slot":slot,"actor_id":actor_id,"clip":clip}
    var items: Array = frame_rows[clip]
    if items.is_empty():
        return {"ok":false,"reason":"actor_clip_empty","slot":slot,"actor_id":actor_id,"clip":clip}
    var index := frame_index(action,age,items.size(),action_seconds)
    var row: Dictionary = items[index]
    var texture := _cel(str(row.get("path","")))
    if texture == null:
        return {"ok":false,"reason":"actor_frame_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index}
    var baseline := float(row.get("source_foot_baseline_y_px",manifest.get("foot_baseline_y_px",359.0)))
    var body_center_px := Vector2(texture.get_width()*0.5,texture.get_height()*0.5)
    var result := {"ok":true,"slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"scale":scale}
    if slot == "body_center":
        result["position"] = foot+(body_center_px-Vector2(texture.get_width()*0.5,baseline))*scale
        result["source_px"] = body_center_px
        return result
    var socket_slot := slot
    var attachment: Dictionary = {}
    var attachment_asset := str(preview_attachment_override.get("asset_id",""))
    if slot in ["weapon_grip","weapon_tip"]:
        if attachment_asset.is_empty():
            for raw_attachment in manifest.get("attachments",[]):
                if raw_attachment is Dictionary:
                    attachment = raw_attachment
                    attachment_asset = str(attachment.get("asset_id",""))
                    break
        else:
            for raw_attachment in manifest.get("attachments",[]):
                if raw_attachment is Dictionary and str(raw_attachment.get("asset_id","")) == attachment_asset:
                    attachment = raw_attachment
                    break
        if not attachment_asset.is_empty():
            socket_slot = str(preview_attachment_override.get("anchor_slot",attachment.get("slot","main_hand")))
    var grips: Dictionary = row.get("grip_sockets",{})
    var grip: Dictionary = grips.get(socket_slot,{})
    if grip.is_empty():
        return {"ok":false,"reason":"authored_grip_socket_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"socket_slot":socket_slot}
    var body_grip: Array = grip.get("body_grip_px",[])
    if body_grip.size() != 2:
        return {"ok":false,"reason":"authored_grip_position_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"socket_slot":socket_slot}
    if slot in ["weapon_grip","weapon_tip"] and bool(preview_attachment_override.get("suppress_attachments",false)):
        return {"ok":false,"reason":"attachments_suppressed","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"socket_slot":socket_slot}
    var hand_position := foot+(Vector2(float(body_grip[0]),float(body_grip[1]))-Vector2(texture.get_width()*0.5,baseline))*scale
    if slot not in ["weapon_grip","weapon_tip"]:
        result["position"] = hand_position
        result["source_px"] = Vector2(float(body_grip[0]),float(body_grip[1]))
        result["socket_slot"] = socket_slot
        result["socket_scale"] = float(grip.get("scale_multiplier",0.0))
        result["rotation_deg"] = float(grip.get("rotation_deg",0.0))
        result["draw_order"] = str(grip.get("draw_order",""))
        return result
    if attachment_asset.is_empty():
        return {"ok":false,"reason":"weapon_attachment_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"socket_slot":socket_slot}
    var weapon_info := _weapon_info(manifest,attachment_asset)
    var weapon_path := str(weapon_info.get("path",""))
    var weapon_texture := _cel(weapon_path)
    if weapon_info.is_empty() or weapon_texture == null:
        return {"ok":false,"reason":"weapon_asset_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"asset_id":attachment_asset}
    var weapon_grip: Array = weapon_info.get("grip_px",weapon_info.get("asset_grip_px",[weapon_texture.get_width()*0.5,weapon_texture.get_height()*0.5]))
    # AS48's existing Weapon Library manifest keeps the original field name
    # `asset_tip_px`; newer extracted assets use `tip_px`. Accept both so the
    # authored tip socket resolves without copying or rewriting the source.
    var weapon_tip: Array = weapon_info.get("tip_px",weapon_info.get("asset_tip_px",[]))
    if weapon_grip.size() != 2 or weapon_tip.size() != 2:
        return {"ok":false,"reason":"weapon_tip_or_grip_missing","slot":slot,"actor_id":actor_id,"clip":clip,"frame_index":index,"asset_id":attachment_asset}
    var weapon_scale := float(weapon_info.get("asset_scale",0.0))
    if weapon_scale <= 0.0:
        weapon_scale = float(grip.get("scale_multiplier",0.30))
    if attachment_asset == str(preview_attachment_override.get("asset_id","")):
        weapon_scale = float(preview_attachment_override.get("asset_scale",weapon_scale))
    var rotation_deg := float(grip.get("rotation_deg",0.0))
    if attachment_asset == str(preview_attachment_override.get("asset_id","")):
        var rotation_offset := float(preview_attachment_override.get("rotation_offset_deg",0.0))
        var direction_value: Variant = preview_attachment_override.get("align_tip_to_direction",[])
        var world_direction := Vector2.ZERO
        if direction_value is Vector2:
            world_direction = direction_value
        elif direction_value is Array and direction_value.size() == 2:
            world_direction = Vector2(float(direction_value[0]),float(direction_value[1]))
        if world_direction.length_squared() > 0.001:
            rotation_deg = aligned_weapon_rotation_deg([0.0,0.0],[world_direction.x,world_direction.y],weapon_grip,weapon_tip,rotation_deg,rotation_offset)
        else:
            var direction_slot := str(preview_attachment_override.get("align_tip_to_slot",""))
            var direction_grip: Dictionary = grips.get(direction_slot,{})
            var direction_anchor: Array = direction_grip.get("body_grip_px",[])
            rotation_deg = aligned_weapon_rotation_deg(body_grip,direction_anchor,weapon_grip,weapon_tip,rotation_deg,rotation_offset)
    var tip_px := Vector2(float(weapon_tip[0]),float(weapon_tip[1]))
    var grip_px := Vector2(float(weapon_grip[0]),float(weapon_grip[1]))
    var weapon_position := hand_position
    if slot == "weapon_tip":
        weapon_position += (tip_px-grip_px).rotated(deg_to_rad(rotation_deg))*scale*maxf(weapon_scale,0.01)
    result["position"] = weapon_position
    result["source_px"] = tip_px if slot == "weapon_tip" else Vector2(float(body_grip[0]),float(body_grip[1]))
    result["socket_slot"] = socket_slot
    result["asset_id"] = attachment_asset
    result["weapon_scale"] = weapon_scale
    result["metadata_scale"] = weapon_scale
    result["rotation_deg"] = rotation_deg
    result["draw_order"] = str(grip.get("draw_order",""))
    return result

## Resolve all anchors for a displayed AS-CHAR frame in one pass. Top-level
## `foot` and `body_center` are screen-space Vector2 values; authored hand and
## weapon entries appear in `slots` and as top-level aliases. Each slot entry
## includes screen-space `position`/`grip_position`, `draw_order`, rotation and
## metadata scale; weapon entries also include their selected asset and a
## `tip_position` when the weapon library supplies tip metadata. Unsupported
## anchors are omitted so callers can use a different authored anchor safely.
static func resolve_preview_anchors(school: String,sex: String,action: String,
        facing: Vector2,age: float,foot: Vector2,scale: float,
        action_seconds: float = 0.0,preview_attachment_override: Dictionary = {}) -> Dictionary:
    var center := resolve_preview_anchor(school,sex,action,facing,age,foot,scale,
        "body_center",action_seconds,preview_attachment_override)
    if not bool(center.get("ok",false)):
        return {"ok":false,"reason":str(center.get("reason","body_center_unavailable")),"foot":foot}
    var actor_id := int(center.get("actor_id",-1))
    var result := {
        "ok":true,
        "actor_id":actor_id,
        "clip":str(center.get("clip","")),
        "frame_index":int(center.get("frame_index",0)),
        "scale":scale,
        "foot":foot,
        "body_center":center.get("position",foot),
        "attachments_suppressed":bool(preview_attachment_override.get("suppress_attachments",false)),
        "slots":{}
    }
    var slot_names := ["hand_r","hand_l","main_hand","off_hand"]
    for slot_name in slot_names:
        var anchor := resolve_preview_anchor(school,sex,action,facing,age,foot,scale,
            str(slot_name),action_seconds,preview_attachment_override)
        if not bool(anchor.get("ok",false)):
            continue
        var slot_result := anchor.duplicate(true)
        slot_result["grip_position"] = anchor.get("position",foot)
        slot_result["metadata_scale"] = float(anchor.get("socket_scale",0.0))
        result["slots"][slot_name] = slot_result
        result[slot_name] = slot_result
    var weapon_grip := resolve_preview_anchor(school,sex,action,facing,age,foot,scale,
        "weapon_grip",action_seconds,preview_attachment_override)
    var weapon_tip := resolve_preview_anchor(school,sex,action,facing,age,foot,scale,
        "weapon_tip",action_seconds,preview_attachment_override)
    if bool(weapon_grip.get("ok",false)):
        var weapon_result := weapon_grip.duplicate(true)
        weapon_result["grip_position"] = weapon_grip.get("position",foot)
        weapon_result["metadata_scale"] = float(weapon_grip.get("weapon_scale",0.0))
        if bool(weapon_tip.get("ok",false)):
            weapon_result["tip_position"] = weapon_tip.get("position",foot)
        weapon_result["position"] = weapon_result["grip_position"]
        result["slots"]["weapon_grip"] = weapon_result
        result["weapon_grip"] = weapon_result
        if bool(weapon_tip.get("ok",false)):
            var tip_result := weapon_tip.duplicate(true)
            tip_result["grip_position"] = weapon_grip.get("position",foot)
            tip_result["tip_position"] = weapon_tip.get("position",foot)
            tip_result["metadata_scale"] = float(weapon_tip.get("weapon_scale",0.0))
            result["slots"]["weapon_tip"] = tip_result
            result["weapon_tip"] = tip_result
    return result

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
    if bool(preview_attachment_override.get("suppress_attachments",false)):
        return
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
