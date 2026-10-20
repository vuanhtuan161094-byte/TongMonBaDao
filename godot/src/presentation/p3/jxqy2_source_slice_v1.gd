class_name Jxqy2SourceSliceV1
extends RefCounted

# Independent reader for the documented IMG/MAP byte layouts. No external
# engine code or binary art is bundled. Only exact pinned local sources load.
const MANIFEST := "res://data/combat/jxqy2_slice_v1.json"
const BASE_SCALE := 0.75
const ACTIONS := {"idle":"st","run":"wlk","attack":"at","hit":"bat","die":"die"}
var active := false
var error := ""
var manifest: Dictionary = {}
var assets: Dictionary = {}
var map_data: Dictionary = {}
var casts: Array[Dictionary] = []
var impacts: Array[Dictionary] = []
var _announced: Dictionary = {}
var verified_files := 0

func load_sources(root: String) -> Dictionary:
    active = false
    assets.clear()
    verified_files = 0
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
    if not (parsed is Dictionary):
        return _fail("invalid_source_manifest")
    manifest = parsed
    for entry in manifest["files"]:
        var path := str(entry["path"])
        var file := FileAccess.open(root.path_join(path),FileAccess.READ)
        if file == null:
            return _fail("missing_source:"+path)
        var bytes := file.get_buffer(file.get_length())
        if bytes.size() != int(entry["size_bytes"]) or blob_sha(bytes) != str(entry["git_blob_sha"]):
            return _fail("source_hash_mismatch:"+path)
        verified_files += 1
        if path.ends_with(".mpc"):
            var decoded := decode_mpc(bytes)
            if not bool(decoded.get("ok",false)):
                return _fail(path+":"+str(decoded.get("reason","invalid_mpc")))
            assets[path] = decoded
        elif path == str(manifest["map"]["path"]):
            map_data = decode_map(bytes)
            if not bool(map_data.get("ok",false)):
                return _fail("invalid_map")
    # Every layer/frame in the full source map must have its exact source.
    for y in range(int(manifest["map"]["size"][1])):
        for x in range(int(manifest["map"]["size"][0])):
            for layer in range(3):
                var tile := tile_at(x,y,layer)
                if int(tile["id"]) == 0:
                    continue
                var path := tile_path(int(tile["id"]))
                if not assets.has(path) or int(tile["frame"]) >= (assets[path]["frames"] as Array).size():
                    return _fail("ASSET_INCOMPLETE:map_frame:"+path+":"+str(tile["frame"]))
    active = true
    error = ""
    return {"ok":true,"verified_files":verified_files,"skill_status":manifest["skill"]["status"]}

func _fail(reason: String) -> Dictionary:
    error = reason
    return {"ok":false,"reason":reason}

static func blob_sha(bytes: PackedByteArray) -> String:
    var hashing := HashingContext.new()
    hashing.start(HashingContext.HASH_SHA1)
    var prefix := ("blob "+str(bytes.size())).to_utf8_buffer()
    prefix.append(0)
    hashing.update(prefix)
    hashing.update(bytes)
    return hashing.finish().hex_encode()

static func decode_mpc(bytes: PackedByteArray) -> Dictionary:
    if bytes.size() < 48 or bytes.slice(0,15).get_string_from_ascii() != "IMG File Ver1.0":
        return {"ok":false,"reason":"unsupported_img_header"}
    var count := bytes.decode_s32(16)
    var directions := bytes.decode_s32(20)
    var interval := bytes.decode_s32(24)
    if count < 1 or count > 4096 or directions < 0 or directions > 32 or interval < 0 or interval > 60000:
        return {"ok":false,"reason":"invalid_img_metadata"}
    var frames: Array[Dictionary] = []
    var offset := 48
    for index in range(count):
        if offset+16 > bytes.size():
            return {"ok":false,"reason":"truncated_frame_header"}
        var length := bytes.decode_s32(offset)
        var anchor := Vector2(bytes.decode_s32(offset+4),bytes.decode_s32(offset+8))
        offset += 16
        if length <= 0 or offset+length > bytes.size():
            return {"ok":false,"reason":"truncated_frame_png"}
        var image := Image.new()
        if image.load_png_from_buffer(bytes.slice(offset,offset+length)) != OK or image.get_width() > 2048 or image.get_height() > 2048:
            return {"ok":false,"reason":"invalid_frame_png"}
        frames.append({"texture":ImageTexture.create_from_image(image),"anchor":anchor,
            "size":Vector2(image.get_size()),"index":index})
        offset += length
    if offset != bytes.size():
        return {"ok":false,"reason":"unexpected_img_tail"}
    directions = maxi(1,directions)
    if count < directions:
        directions = 1
    return {"ok":true,"frames":frames,"directions":directions,
        "frames_per_direction":int(count/directions),"interval_ms":interval if interval > 0 else 16}

static func decode_map(bytes: PackedByteArray) -> Dictionary:
    if bytes.size() < 16512 or bytes.slice(0,15).get_string_from_ascii() != "MAP File Ver2.0":
        return {"ok":false,"reason":"unsupported_map_header"}
    var width := bytes.decode_s32(68)
    var height := bytes.decode_s32(72)
    var info := bytes.decode_s32(76)
    var name_size := bytes.decode_s32(80)
    if width < 1 or height < 1 or width > 1024 or height > 1024 or info != 64 or name_size != 32:
        return {"ok":false,"reason":"invalid_map_dimensions"}
    var data_at := 192+255*info
    if data_at+width*height*10 != bytes.size():
        return {"ok":false,"reason":"invalid_map_data_length"}
    var names: Dictionary = {}
    for i in range(255):
        var record := 192+i*info
        var text := bytes.slice(record,record+name_size)
        var zero := text.find(0)
        if zero >= 0:
            text = text.slice(0,zero)
        if not text.is_empty():
            names[bytes.decode_s32(record+name_size)] = text.get_string_from_utf8()
    return {"ok":true,"width":width,"height":height,"names":names,
        "cells":bytes.slice(data_at),"source_blob_sha":blob_sha(bytes)}

func tile_at(x: int, y: int, layer: int) -> Dictionary:
    var origin: Array = manifest["map"]["origin"]
    var index := ((y+int(origin[1]))*int(map_data["width"])+x+int(origin[0]))*10
    var cells: PackedByteArray = map_data["cells"]
    return {"frame":int(cells[index+layer*2]),"id":int(cells[index+layer*2+1]),
        "obstacle":int(cells[index+6]),"trap":int(cells[index+7])}

func tile_path(id: int) -> String:
    return str(manifest["map"]["folder"]).path_join(str(map_data["names"].get(id,"")))

func navigation_grid() -> Dictionary:
    if not active:
        return {}
    var blocked: Array = []
    var width := int(manifest["map"]["size"][0])
    var height := int(manifest["map"]["size"][1])
    for y in range(height):
        for x in range(width):
            blocked.append(1 if (int(tile_at(x,y,0)["obstacle"]) & 0xC0) != 0 else 0)
    return {"width":width,"height":height,"blocked":blocked,"source_blob_sha":map_data["source_blob_sha"],
        "source_map":"JXQY2:中都-矿山","origin":manifest["map"]["origin"]}

# Native staggered 64x32 tile centres; interpolation retains parity shifts.
func project(world: Vector2) -> Vector2:
    var y := world.y-0.5+float(manifest["map"]["origin"][1])
    var row := floori(y)
    var shift := lerpf(float(posmod(row,2))*32.0,float(posmod(row+1,2))*32.0,y-floorf(y))
    return Vector2((world.x-0.5)*64.0+shift,y*16.0)

func unproject(pixel: Vector2) -> Vector2:
    var y := pixel.y/16.0
    var row := floori(y)
    var shift := lerpf(float(posmod(row,2))*32.0,float(posmod(row+1,2))*32.0,y-floorf(y))
    return Vector2((pixel.x-shift)/64.0+0.5,y-float(manifest["map"]["origin"][1])+0.5)

func draw_map(canvas: CanvasItem, layer: int, projection: Callable, zoom: float, occluders: Array[Vector2] = [], viewport: Rect2 = Rect2(), inverse: Callable = Callable()) -> void:
    for command in map_commands(layer,projection,zoom,occluders,viewport,inverse):
        draw_map_command(canvas,command,zoom)

func draw_map_command(canvas: CanvasItem, command: Dictionary, zoom: float) -> void:
    _draw_frame(canvas,command["frame"],command["foot"],BASE_SCALE*zoom,command["tint"])

func map_commands(layer: int, projection: Callable, zoom: float, occluders: Array[Vector2], viewport: Rect2, inverse: Callable) -> Array[Dictionary]:
    var commands: Array[Dictionary] = []
    var low := Vector2.ZERO
    var high := Vector2(float(manifest["map"]["size"][0]),float(manifest["map"]["size"][1]))
    if inverse.is_valid() and viewport.has_area():
        low = Vector2(INF,INF)
        high = Vector2(-INF,-INF)
        for corner in [viewport.position,Vector2(viewport.end.x,viewport.position.y),viewport.end,Vector2(viewport.position.x,viewport.end.y)]:
            var world: Vector2 = inverse.call(corner)
            low = low.min(world)
            high = high.max(world)
        low = (low-Vector2(3,12)).max(Vector2.ZERO)
        high = (high+Vector2(3,12)).min(Vector2(float(manifest["map"]["size"][0]),float(manifest["map"]["size"][1])))
    for y in range(floori(low.y),ceili(high.y)):
        for x in range(floori(low.x),ceili(high.x)):
            var tile := tile_at(x,y,layer)
            if int(tile["id"]) == 0:
                continue
            var resource: Dictionary = assets[tile_path(int(tile["id"]))]
            var frame: Dictionary = resource["frames"][int(tile["frame"])]
            var foot: Vector2 = projection.call(Vector2(x+0.5,y+0.5))
            var tint := Color.WHITE
            if layer > 0:
                var bounds := Rect2(foot-(frame["anchor"] as Vector2)*BASE_SCALE*zoom,(frame["size"] as Vector2)*BASE_SCALE*zoom)
                for actor_foot in occluders:
                    # Clear the whole silhouette plus a margin. Tree pieces on
                    # either source object layer can cover the same actor.
                    var silhouette := Rect2(actor_foot-Vector2(38,96)*zoom,Vector2(76,112)*zoom)
                    if bounds.intersects(silhouette):
                        tint.a = 0.035
                        break
            if not viewport.has_area() or viewport.intersects(Rect2(foot-(frame["anchor"] as Vector2)*BASE_SCALE*zoom,(frame["size"] as Vector2)*BASE_SCALE*zoom)):
                commands.append({"frame":frame,"foot":foot,"tint":tint,"layer":layer})
    return commands

func actor_key(actor: Dictionary) -> String:
    return "hero" if str(actor.get("side","")) == "disciple" else ("boss" if str(actor.get("tier","")) == "boss" else "wolf")

func actor_resource(key: String, action: String) -> Dictionary:
    var suffix := str(ACTIONS.get(action,"st"))
    var clip_maps: Dictionary = manifest.get("actor_clips",{})
    if clip_maps.has(key):
        suffix = str(clip_maps[key].get(action,suffix))
    var path := "mpc/character/"+str(manifest["actors"][key])+"-"+suffix+".mpc"
    return assets.get(path,{})

func action_duration(key: String, action: String) -> float:
    var resource := actor_resource(key,action)
    return float(resource.get("frames_per_direction",1))*float(resource.get("interval_ms",100))/1000.0

func direction_index(facing_pixels: Vector2, directions: int) -> int:
    # Native NPC convention: direction 0 down, 2 left, 4 up, 6 right.
    # Horizontal scale is compensated by the source MapXRatio of 2.
    var angle := atan2(-facing_pixels.x/2.0,facing_pixels.y)
    return posmod(roundi(angle/TAU*float(directions)),directions)

func frame_at(resource: Dictionary, direction: int, age: float, once: bool) -> Dictionary:
    var per_direction := int(resource["frames_per_direction"])
    var local := maxi(0,floori(age*1000.0/float(resource["interval_ms"])))
    local = mini(local,per_direction-1) if once else posmod(local,per_direction)
    var index := posmod(direction,int(resource["directions"]))*per_direction+local
    return resource["frames"][index]

func draw_actor(canvas: CanvasItem, actor: Dictionary, clip: Dictionary,
        facing_pixels: Vector2, foot: Vector2, zoom: float) -> float:
    var action := str(clip["name"])
    var resource := actor_resource(actor_key(actor),action)
    var frame := frame_at(resource,direction_index(facing_pixels,int(resource["directions"])),float(clip["age"]),action in ["attack","cast","hit","die"])
    # Screen-space contrast stroke uses the same native silhouette, no new art.
    for offset in [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]:
        _draw_frame(canvas,frame,foot+offset,BASE_SCALE*zoom,Color(0.02,0.04,0.07,0.65))
    _draw_frame(canvas,frame,foot,BASE_SCALE*zoom)
    return -float((frame["anchor"] as Vector2).y)*BASE_SCALE*zoom-10.0

func _draw_frame(canvas: CanvasItem, frame: Dictionary, foot: Vector2, scale: float, tint: Color = Color.WHITE) -> void:
    canvas.draw_texture_rect(frame["texture"],Rect2(foot-(frame["anchor"] as Vector2)*scale,(frame["size"] as Vector2)*scale),false,tint)

func ingest(event: Dictionary, clock: float, battle: MapBattleV2) -> void:
    var kind := str(event.get("type",""))
    var source := str(event.get("actor_id",event.get("caster",event.get("attacker",""))))
    var target := str(event.get("target",""))
    var pair := source+"|"+target
    if kind == "skill_cast" and str(event.get("skill_id","")) == "ngu_kiem_thuat" and battle.actors.has(source) and battle.actors.has(target):
        if str(battle.actors[source].get("visual_weapon_path","")) != "sword":
            return # no verified JXQY2 actor/weapon binding for this visual
        casts.append({"caster":source,"target":target,"started":clock,
            "cast_time":float(CombatSkillSystem.SKILLS["ngu_kiem_thuat"]["cast_time"]),
            "duration":maxf(0.01,float(event["release_at"])-battle.now)})
    elif kind == "skill_hit" and str(event.get("skill_id","")) == "ngu_kiem_thuat":
        _announced[pair] = true
    elif kind == "hit" and str(event.get("kind","")) == "learned_skill":
        if _announced.has(pair) and float(event.get("damage",0.0)) > 0.0:
            impacts.append({"target":target,"started":clock})
            for i in range(casts.size()-1,-1,-1):
                if str(casts[i]["caster"]) == source and str(casts[i]["target"]) == target:
                    casts.remove_at(i)
        _announced.erase(pair)

func draw_effects(canvas: CanvasItem, projection: Callable, clock: float,
        battle: MapBattleV2, zoom: float, render_positions: Dictionary = {}) -> void:
    var skill: Dictionary = manifest["skill"]
    for i in range(casts.size()-1,-1,-1):
        var cue := casts[i]
        var caster: Dictionary = battle.actors.get(str(cue["caster"]),{})
        var target: Dictionary = battle.actors.get(str(cue["target"]),{})
        var age := clock-float(cue["started"])
        if caster.is_empty() or target.is_empty() or float(caster["hp"]) <= 0.0 or age > float(cue["duration"])+2.0:
            casts.remove_at(i)
            continue
        var from: Vector2 = projection.call(render_positions.get(str(cue["caster"]),caster["position"]))
        var to: Vector2 = projection.call(render_positions.get(str(cue["target"]),target["position"]))
        # The source image/icon is UI art. Casting is the actor's native
        # [magic] animation; never draw that static icon as invented VFX.
        if age >= float(cue["cast_time"]):
            var travel := maxf(0.01,float(cue["duration"])-float(cue["cast_time"]))
            var alpha := clampf((age-float(cue["cast_time"]))/travel,0.0,1.0)
            var resource: Dictionary = assets[skill["projectile"]]
            var direction := direction_index(to-from,int(resource["directions"]))
            var frame := frame_at(resource,direction,age-float(cue["cast_time"]),false)
            for offset in [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]:
                _draw_frame(canvas,frame,from.lerp(to,alpha)+offset,BASE_SCALE*zoom*1.25,Color(0.02,0.04,0.07,0.75))
            _draw_frame(canvas,frame,from.lerp(to,alpha),BASE_SCALE*zoom*1.25)
    for i in range(impacts.size()-1,-1,-1):
        var cue := impacts[i]
        var resource: Dictionary = assets[skill["impact"]]
        var age := clock-float(cue["started"])
        var duration := float(resource["frames_per_direction"])*float(resource["interval_ms"])/1000.0
        if age >= duration or not battle.actors.has(str(cue["target"])):
            impacts.remove_at(i)
            continue
        var target_id := str(cue["target"])
        _draw_frame(canvas,frame_at(resource,0,age,true),projection.call(render_positions.get(target_id,battle.actors[target_id]["position"])),BASE_SCALE*zoom*1.15)

func observed_skill_stage(clock: float) -> String:
    if not impacts.is_empty():
        return "NGỰ KIẾM THUẬT · TRÚNG ĐÍCH"
    if not casts.is_empty():
        var cue: Dictionary = casts.back()
        return "NGỰ KIẾM THUẬT · "+("THI TRIỂN (acMagic)" if clock-float(cue["started"]) < float(cue["cast_time"]) else "PHI KIẾM")
    return ""
