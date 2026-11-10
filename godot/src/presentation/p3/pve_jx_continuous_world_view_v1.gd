class_name PveJxContinuousWorldViewV1
extends Control

signal move_ordered(actor_ids: Array, destination: Vector2)
signal selection_changed(actor_ids: Array)

const DEFAULT_SOURCE_ROOT := "E:/codex/work/jxqy2_slice/source"
const MAP_INSET := Rect2(Vector2(10.0,26.0),Vector2(1.0,1.0))
const MINIMAP_MARGIN := 12.0

var source: Jxqy2SourceSliceV1
var source_a_atlas := CombatV5SourceAAtlas.new()
var topology: Dictionary = {}
var source_root := ""
var source_error := ""
var battle: MapBattleV2
var population: Dictionary = {}
var camp_index := 0
var selected_actor_ids: Array[String] = []
var camera_center := Vector2(7.0,40.0)
var camera_zoom := 0.48
var _dragging := false
var _drag_position := Vector2.ZERO
var _drag_distance := 0.0
var _clock := 0.0
var _render_positions: Dictionary = {}
var _target_positions: Dictionary = {}
var _actor_visuals: Dictionary = {}
var _last_visual_event_time: Dictionary = {}
var _terrain_colors: Dictionary = {}
var _last_world_time := -1.0
var _disciple_names: Dictionary = {}
var _actor_view_rows: Dictionary = {}

func prepare_world() -> Dictionary:
    if source != null and source.active and not topology.is_empty():
        return {"ok":true,"topology":topology,"source_map":str(topology.get("source_map","")),"verified_files":source.verified_files}
    source_root = OS.get_environment("TMB_JXQY2_ASSET_ROOT")
    if source_root.is_empty():
        source_root = DEFAULT_SOURCE_ROOT
    source = Jxqy2SourceSliceV1.new()
    var loaded := source.load_sources(source_root)
    if not bool(loaded.get("ok",false)):
        source_error = str(loaded.get("reason","JX_SOURCE_UNAVAILABLE"))
        return {"ok":false,"reason":source_error,"root":source_root}
    topology = PveOpenWorldTopologyV1.build(source.navigation_grid())
    if not bool(topology.get("ok",false)):
        source_error = str(topology.get("reason","JX_TOPOLOGY_FAILED"))
        return {"ok":false,"reason":source_error}
    camera_center = topology["camp_positions"][0]
    source_error = ""
    queue_redraw()
    return {"ok":true,"topology":topology,"source_map":str(topology["source_map"]),"verified_files":source.verified_files}

func get_open_world_options() -> Dictionary:
    var prepared := prepare_world()
    if not bool(prepared.get("ok",false)):
        return prepared
    var options: Dictionary = topology.duplicate(true)
    # This is a visible pilot interval. Slot cooldowns advance only on the
    # shared Combat V2 simulation clock and are not final balance.
    options["respawn_delay_sim_seconds"] = 30.0
    options["auto_hunt"] = true
    return options

func show_authority_snapshot(snapshot: MapBattleV2, world_population: Dictionary = {}, current_camp_index: int = 0, disciples: Dictionary = {}, view_rows: Dictionary = {}) -> void:
    battle = snapshot
    population = world_population.duplicate(false)
    camp_index = clampi(current_camp_index,0,PveMultiCampPopulationV1.CAMP_COUNT-1)
    _actor_view_rows = view_rows.duplicate(true)
    _disciple_names.clear()
    for raw_id in disciples:
        var disciple: Variant = disciples[raw_id]
        if disciple is DiscipleState:
            _disciple_names[str(raw_id)] = str(disciple.display_name)
    if battle == null:
        _target_positions.clear()
        _render_positions.clear()
        selected_actor_ids.clear()
        _last_world_time = -1.0
        queue_redraw()
        return
    var current_disciples: Array[String] = []
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort()
    var current_ids: Dictionary = {}
    for raw_id in actor_ids:
        var id := str(raw_id)
        var actor: Dictionary = battle.actors[id]
        current_ids[id] = true
        var position: Vector2 = actor.get("position",Vector2.ZERO)
        _target_positions[id] = position
        if not _render_positions.has(id):
            _render_positions[id] = position
        if str(actor.get("side","")) == "disciple":
            current_disciples.append(id)
        _update_actor_visual(id,actor)
    for id in _render_positions.keys().duplicate():
        if not current_ids.has(str(id)):
            _render_positions.erase(id)
            _target_positions.erase(id)
            _actor_visuals.erase(id)
            _last_visual_event_time.erase(id)
    var valid_selected: Array[String] = []
    for id in selected_actor_ids:
        if current_disciples.has(id):
            valid_selected.append(id)
    if valid_selected.is_empty():
        valid_selected = current_disciples.duplicate()
    selected_actor_ids = valid_selected
    _last_world_time = battle.now
    queue_redraw()

func _update_actor_visual(actor_id: String, actor: Dictionary) -> void:
    var action := "idle"
    var event_time := -1.0
    var event_type := ""
    for event in battle.events:
        var when := float(event.get("time",-1.0))
        if when < event_time:
            continue
        var source_id := str(event.get("actor_id",event.get("attacker",event.get("caster",""))))
        var target_id := str(event.get("target",event.get("target_id","")))
        if source_id == actor_id and ["move","skill_cast","skill_hit","hit","basic_hit"].has(str(event.get("type",""))):
            event_time = when
            event_type = str(event.get("type",""))
        elif target_id == actor_id and str(event.get("type","")) == "status_applied" \
                and str(event.get("status","")) in ["stun","freeze","knockback","knock_up","stagger"]:
            # Damage and DoT must NOT force this actor into its whole-body
            # hurt atlas. Only authoritative control may interrupt movement.
            event_time = when
            event_type = "hurt"
    if float(actor.get("hp",0.0)) <= 0.0:
        action = "die"
    elif event_type == "hurt" and event_time >= 0.0 and battle.now-event_time <= 0.30:
        action = "hit"
    elif _render_positions.get(actor_id,actor.get("position",Vector2.ZERO)).distance_to(actor.get("position",Vector2.ZERO)) > 0.03:
        # Locomotion has visual priority over repeated basic-hit events.
        action = "run"
    elif event_time >= 0.0 and battle.now-event_time <= 0.65:
        if event_type in ["skill_cast","skill_hit","hit","basic_hit"]:
            action = "attack"
        elif event_type == "move":
            action = "run"
    var previous: Dictionary = _actor_visuals.get(actor_id,{})
    if event_time > float(_last_visual_event_time.get(actor_id,-1.0)):
        _last_visual_event_time[actor_id] = event_time
        _actor_visuals[actor_id] = {"action":action,"started":_clock,"event_time":event_time}
    elif action == "die" or action == "run":
        _actor_visuals[actor_id] = {"action":action,"started":float(previous.get("started",_clock)),"event_time":float(previous.get("event_time",-1.0))}
    elif float(actor.get("hp",0.0)) > 0.0 and _clock-float(previous.get("started",0.0)) > 0.95:
        _actor_visuals[actor_id] = {"action":"idle","started":_clock,"event_time":float(previous.get("event_time",-1.0))}

func _process(delta: float) -> void:
    _clock += delta
    if battle != null:
        for id in _render_positions.keys():
            if not _target_positions.has(id):
                continue
            var actor: Dictionary = battle.actors.get(str(id),{})
            var speed := maxf(0.1,float(actor.get("move_speed",3.0)))
            _render_positions[id] = (_render_positions[id] as Vector2).move_toward(_target_positions[id],speed*delta)
        queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func map_rect() -> Rect2:
    return Rect2(MAP_INSET.position,Vector2(maxf(1.0,size.x-20.0),maxf(1.0,size.y-36.0)))

func minimap_rect() -> Rect2:
    return Rect2(Vector2(maxf(MINIMAP_MARGIN,size.x-202.0),MINIMAP_MARGIN),Vector2(190.0,160.0))

func minimap_inner_rect() -> Rect2:
    var frame := minimap_rect()
    return Rect2(frame.position+Vector2(6.0,20.0),frame.size-Vector2(12.0,26.0))

func map_scale() -> float:
    return Jxqy2SourceSliceV1.BASE_SCALE*camera_zoom

func world_to_screen(world: Vector2) -> Vector2:
    if source == null or not source.active:
        return map_rect().get_center()
    return map_rect().get_center()+(source.project(world)-source.project(camera_center))*map_scale()

func screen_to_world(screen: Vector2) -> Vector2:
    if source == null or not source.active:
        return camera_center
    return source.unproject(source.project(camera_center)+(screen-map_rect().get_center())/maxf(map_scale(),0.001))

func minimap_world_to_screen(world: Vector2) -> Vector2:
    var inner := minimap_inner_rect()
    var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(50,100)))
    return inner.position+Vector2(world.x/bounds.size.x*inner.size.x,world.y/bounds.size.y*inner.size.y)

func minimap_screen_to_world(screen: Vector2) -> Vector2:
    var inner := minimap_inner_rect()
    var uv := (screen-inner.position)/inner.size
    var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(50,100)))
    return Vector2(clampf(uv.x,0.0,1.0)*bounds.size.x,clampf(uv.y,0.0,1.0)*bounds.size.y)

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
            _zoom_at(mouse.position,1.15)
            accept_event()
        elif mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
            _zoom_at(mouse.position,1.0/1.15)
            accept_event()
        elif mouse.button_index == MOUSE_BUTTON_RIGHT:
            _dragging = mouse.pressed
            _drag_position = mouse.position
            _drag_distance = 0.0
            accept_event()
        elif mouse.button_index == MOUSE_BUTTON_LEFT:
            if mouse.pressed and minimap_rect().has_point(mouse.position):
                camera_center = minimap_screen_to_world(mouse.position)
                _clamp_camera()
                queue_redraw()
                accept_event()
            elif not mouse.pressed and not _dragging and map_rect().has_point(mouse.position) and not minimap_rect().has_point(mouse.position):
                _select_or_move(mouse.position,mouse.shift_pressed)
                accept_event()
    elif event is InputEventMouseMotion and _dragging:
        var motion := event as InputEventMouseMotion
        camera_center = screen_to_world(_drag_position-motion.relative)
        _drag_distance += motion.relative.length()
        _drag_position = motion.position
        _clamp_camera()
        queue_redraw()
        accept_event()
    elif event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        if touch.pressed and minimap_rect().has_point(touch.position):
            camera_center = minimap_screen_to_world(touch.position)
            _clamp_camera()
            queue_redraw()
            accept_event()
        elif not touch.pressed and map_rect().has_point(touch.position):
            _select_or_move(touch.position,false)
            accept_event()
    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        camera_center = screen_to_world(drag.position-drag.relative)
        _clamp_camera()
        queue_redraw()
        accept_event()

func _select_or_move(screen: Vector2, shift: bool) -> void:
    var nearest_id := ""
    var nearest_distance := 28.0*28.0
    if battle != null:
        for actor_id in battle.actors:
            var actor: Dictionary = battle.actors[actor_id]
            if str(actor.get("side","")) != "disciple" or float(actor.get("hp",0.0)) <= 0.0:
                continue
            var point := world_to_screen(_render_positions.get(str(actor_id),actor.get("position",Vector2.ZERO)))
            var distance := point.distance_squared_to(screen)
            if distance < nearest_distance:
                nearest_distance = distance
                nearest_id = str(actor_id)
    if not nearest_id.is_empty():
        if shift:
            if selected_actor_ids.has(nearest_id):
                selected_actor_ids.erase(nearest_id)
            else:
                selected_actor_ids.append(nearest_id)
        else:
            selected_actor_ids = [nearest_id]
        selection_changed.emit(selected_actor_ids.duplicate())
        queue_redraw()
        return
    if selected_actor_ids.is_empty():
        return
    var destination := screen_to_world(screen)
    var navigation: Dictionary = battle.world_navigation if battle != null else topology.get("navigation",{})
    var target := PveOpenWorldTopologyV1._nearest_walkable(navigation,Vector2i(floori(destination.x),floori(destination.y)))
    if target.x >= 0:
        move_ordered.emit(selected_actor_ids.duplicate(),Vector2(target)+Vector2(0.5,0.5))

func _zoom_at(screen: Vector2, factor: float) -> void:
    var anchor := screen_to_world(screen)
    camera_zoom = clampf(camera_zoom*factor,0.18,1.15)
    camera_center = source.unproject(source.project(anchor)-(screen-map_rect().get_center())/maxf(map_scale(),0.001)) if source != null else camera_center
    _clamp_camera()
    queue_redraw()

func _clamp_camera() -> void:
    if source == null or not source.active:
        return
    var bounds: Rect2 = topology.get("bounds",Rect2(Vector2.ZERO,Vector2(50,100)))
    camera_center.x = clampf(camera_center.x,0.5,bounds.size.x-0.5)
    camera_center.y = clampf(camera_center.y,0.5,bounds.size.y-0.5)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO,size),Color("14201d"))
    # The source map has transparent tile margins; this cool rock/snow
    # underlay fills seams and map-edge gaps without painting over real art.
    draw_rect(map_rect(),Color("a8b5b9"))
    if source == null or not source.active:
        _draw_label(Vector2(24,56),"Không tải được map JX đã xác minh: "+source_error,15,Color("f0c177"))
        return
    var rect := map_rect()
    var projection := Callable(self,"world_to_screen")
    var inverse := Callable(self,"screen_to_world")
    var scale := map_scale()
    var feet: Array[Vector2] = []
    if battle != null:
        for actor_id in battle.actors:
            var actor: Dictionary = battle.actors[actor_id]
            feet.append(world_to_screen(_render_positions.get(str(actor_id),actor.get("position",Vector2.ZERO))))
    source.draw_map(self,0,projection,scale,[],rect,inverse)
    _draw_region_zones(false)
    source.draw_map(self,1,projection,scale,feet,rect,inverse)
    source.draw_map(self,2,projection,scale,feet,rect,inverse)
    _draw_actor_layer(false)
    draw_rect(rect,Color("aab6a5"),false,1.0)
    var header_rect := Rect2(rect.position+Vector2(8,6),Vector2(205,23))
    draw_rect(header_rect,Color(0.035,0.075,0.072,0.84))
    _draw_label(header_rect.position+Vector2(7,16),"JXQY2 · TRUNG ĐÔ / KHU MỎ",10,Color("f0d18c"))
    var footer_rect := Rect2(Vector2(rect.position.x+8.0,rect.end.y-26.0),Vector2(minf(420.0,rect.size.x-16.0),19.0))
    draw_rect(footer_rect,Color(0.035,0.075,0.072,0.84))
    _draw_label(footer_rect.position+Vector2(7,14),"Click đất: đi · Shift+click: chọn · Kéo phải: camera · Lăn: zoom",9,Color("f0f0df"))
    _draw_minimap()

func _draw_region_zones(minimap: bool) -> void:
    if minimap:
        return
    var centres: Array = topology.get("camp_positions",[])
    for index in range(centres.size()):
        var center: Vector2 = centres[index]
        var point := world_to_screen(center)
        if not map_rect().grow(70.0).has_point(point):
            continue
        var radius := maxf(8.0,4.0*map_scale())
        draw_circle(point,radius,Color(0.80,0.63,0.35,0.035))
        draw_arc(point,radius,0.0,TAU,24,Color(0.84,0.70,0.43,0.18),1.0,true)
        if index == camp_index:
            draw_arc(point,radius+2.0,0.0,TAU,24,Color("e4bb67"),1.4,true)

func _draw_actor_layer(minimap: bool) -> void:
    if battle == null or source == null:
        return
    var actor_ids: Array = battle.actors.keys()
    actor_ids.sort_custom(func(a: Variant,b: Variant) -> bool:
        var pa: Vector2 = _render_positions.get(str(a),battle.actors[a].get("position",Vector2.ZERO))
        var pb: Vector2 = _render_positions.get(str(b),battle.actors[b].get("position",Vector2.ZERO))
        return source.project(pa).y < source.project(pb).y)
    for raw_id in actor_ids:
        var id := str(raw_id)
        var actor: Dictionary = battle.actors[id]
        var world: Vector2 = _render_positions.get(id,actor.get("position",Vector2.ZERO))
        var side := str(actor.get("side",""))
        var alive := float(actor.get("hp",0.0)) > 0.0
        if minimap:
            var mini_point := minimap_world_to_screen(world)
            draw_circle(mini_point,2.1,Color("65ddc6") if side == "disciple" else Color("ed806b") if alive else Color("888a7e"))
            continue
        var foot := world_to_screen(world)
        if not map_rect().grow(70.0).has_point(foot):
            continue
        var visual: Dictionary = _actor_visuals.get(id,{"action":"idle","started":_clock})
        var action := str(visual.get("action","idle"))
        if not alive:
            action = "die"
        var direction := Vector2.RIGHT
        if _target_positions.has(id) and _render_positions.has(id):
            direction = (_target_positions[id] as Vector2)-(_render_positions[id] as Vector2)
            if direction.length_squared() < 0.001:
                direction = Vector2.RIGHT if side == "disciple" else Vector2.LEFT
        var clip := {"name":action,"age":maxf(0.0,_clock-float(visual.get("started",_clock)))}
        var visual_row: Dictionary = _actor_view_rows.get(id,{})
        var source_a_key := str(visual_row.get("source_a_visual_key",""))
        var source_a_drawn := side == "disciple" and not source_a_key.is_empty() and source_a_atlas.has_actor(source_a_key)
        if source_a_drawn:
            source_a_drawn = source_a_atlas.draw_actor(self,source_a_key,action,foot,direction,float(clip["age"]),camera_zoom*1.10)
        if not source_a_drawn:
            source.draw_actor(self,actor,clip,direction,foot,camera_zoom)
        if side == "disciple" and selected_actor_ids.has(id):
            draw_arc(foot+Vector2(0,3),14.0*camera_zoom,0.0,TAU,24,Color("ffe08a"),1.6,true)
        var width := 28.0*camera_zoom
        var hp_ratio := clampf(float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0))),0.0,1.0)
        draw_rect(Rect2(foot+Vector2(-width*0.5,4.0),Vector2(width,3.0)),Color(0.04,0.07,0.05,0.9))
        if hp_ratio > 0.0:
            draw_rect(Rect2(foot+Vector2(-width*0.5,4.0),Vector2(width*hp_ratio,3.0)),Color("85d884") if side == "disciple" else Color("e88372"))
        var label := ""
        if side == "monster" and camera_zoom >= 1.15:
            label = str(actor.get("species_id",id))
        elif side == "disciple" and selected_actor_ids.size() == 1 and selected_actor_ids.has(id):
            label = str(_disciple_names.get(id,id))
        if not label.is_empty():
            _draw_label(foot+Vector2(-28.0*camera_zoom,-20.0*camera_zoom),label,10,Color("f4f1dd") if alive else Color("aaa79c"))

func _draw_minimap() -> void:
    var frame := minimap_rect()
    draw_rect(frame,Color("09110e"))
    var inner := minimap_inner_rect()
    var nav: Dictionary = battle.world_navigation if battle != null and battle.world_mode else topology.get("navigation",{})
    var width := int(nav.get("width",0))
    var height := int(nav.get("height",0))
    var blocked = nav.get("blocked",[])
    if width > 0 and height > 0:
        var cell_size := Vector2(inner.size.x/float(width),inner.size.y/float(height))
        for y in range(height):
            for x in range(width):
                var tile := source.tile_at(x,y,0)
                var tile_id := int(tile.get("id",0))
                var color := Color("17201c") if tile_id == 0 else _terrain_color(int(tile["id"]),int(tile["frame"]))
                if int(blocked[y*width+x]) != 0:
                    color = color.darkened(0.52)
                draw_rect(Rect2(inner.position+Vector2(x,y)*cell_size,cell_size+Vector2(0.2,0.2)),color)
    var centres: Array = topology.get("camp_positions",[])
    for index in range(centres.size()):
        var center: Vector2 = centres[index]
        draw_circle(minimap_world_to_screen(center),2.0,Color("f2d385") if index == camp_index else Color(0.80,0.70,0.44,0.70))
    _draw_actor_layer(true)
    if source != null and source.active:
        var visible_world: Array[Vector2] = []
        for corner in [map_rect().position,Vector2(map_rect().end.x,map_rect().position.y),map_rect().end,Vector2(map_rect().position.x,map_rect().end.y)]:
            visible_world.append(screen_to_world(corner))
        var points := PackedVector2Array()
        for world in visible_world:
            points.append(minimap_world_to_screen(world))
        draw_colored_polygon(points,Color(0.94,0.77,0.35,0.08))
        draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[0]]),Color("f2d385"),1.3,true)
    draw_rect(frame,Color("d3c494"),false,1.0)
    draw_rect(Rect2(frame.position+Vector2(1,1),Vector2(frame.size.x-2,18)),Color(0.035,0.075,0.072,0.92))
    _draw_label(frame.position+Vector2(5,14),"MINIMAP · CLICK ĐỂ DỜI",9,Color("f1d488"))

func _terrain_color(tile_id: int, frame_index: int) -> Color:
    var key := "%d:%d" % [tile_id,frame_index]
    if _terrain_colors.has(key):
        return _terrain_colors[key]
    var decoded: Dictionary = source.assets.get(source.tile_path(tile_id),{})
    var frames: Array = decoded.get("frames",[])
    var color := Color("445344")
    if frame_index >= 0 and frame_index < frames.size():
        var texture: Texture2D = frames[frame_index].get("texture")
        if texture != null:
            var image := texture.get_image()
            var total := Color(0,0,0,0)
            var samples := 0
            for sy in range(1,6):
                for sx in range(1,6):
                    var point := Vector2i(roundi(float(image.get_width())*float(sx)/6.0),roundi(float(image.get_height())*float(sy)/6.0))
                    point.x = clampi(point.x,0,image.get_width()-1)
                    point.y = clampi(point.y,0,image.get_height()-1)
                    var pixel := image.get_pixelv(point)
                    if pixel.a > 0.25:
                        total += pixel
                        samples += 1
            if samples > 0:
                color = (total/float(samples)).darkened(0.08)
    _terrain_colors[key] = color
    return color

func _draw_label(position: Vector2, value: String, font_size: int, tint: Color) -> void:
    var font := ThemeDB.fallback_font
    if font == null:
        return
    draw_string_outline(font,position,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,2,Color(0.02,0.04,0.03,0.92))
    draw_string(font,position,value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,tint)
