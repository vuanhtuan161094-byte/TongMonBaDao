extends AnimatedSprite2D
class_name BakedDiscipleAnimationAdapter

const MAIN_SOCKET_SCRIPT := "res://labs/character_family/aschar_v9_batch1/scripts/aschar_weapon_socket_v1.gd"
const LOCAL_SOCKET_SCRIPT := "res://scripts/aschar_weapon_socket_v1.gd"
const MAIN_LAB_ROOT := "res://labs/character_family/aschar_v9_batch1"

@export_file("*.json") var socket_metadata_path := ""
@export_file("*.png") var sword_texture_path := ""
@export var visible_height_px := 338.0

var resolver: Script
var socket_index: Dictionary = {}
var weapon_contract: Dictionary = {}
var canvas_px := Vector2(384.0,384.0)
var baseline_y := 360.0
var facing_direction: StringName = &"front"
var current_action: StringName = &"idle"
var authored_scale := Vector2.ONE
var body_origin := Vector2(-192.0,-360.0)
@onready var sword: Sprite2D = get_node_or_null("Sword") as Sprite2D
@onready var hand_mask: Sprite2D = get_node_or_null("HandMask") as Sprite2D

static func packed_candidate_scene(scene_path: String) -> PackedScene:
	return load(scene_path) as PackedScene

static func attach_to_modular_actor(actor: Node, scene_path: String) -> bool:
	var packed := packed_candidate_scene(scene_path)
	if actor == null or packed == null or not actor.has_method("set_baked_visual"):
		return false
	return bool(actor.call("set_baked_visual",packed))

func _ready() -> void:
	centered = true
	var socket_script_path := LOCAL_SOCKET_SCRIPT if ResourceLoader.exists(LOCAL_SOCKET_SCRIPT) else MAIN_SOCKET_SCRIPT
	resolver = load(socket_script_path) as Script
	if sword == null:
		sword=Sprite2D.new(); sword.name="Sword"; add_child(sword)
	if hand_mask == null:
		hand_mask=Sprite2D.new(); hand_mask.name="HandMask"; hand_mask.centered=false; hand_mask.region_enabled=true; add_child(hand_mask)
	_load_contract()
	_sync_frame_geometry()
	sword.centered=true
	sword.show_behind_parent=true
	sword.z_index=0
	hand_mask.z_index=0
	hand_mask.visible=false
	frame_changed.connect(_sync_weapon)
	animation_changed.connect(_sync_weapon)
	_sync_weapon()

func _load_contract() -> void:
	var raw=FileAccess.get_file_as_string(socket_metadata_path) if not socket_metadata_path.is_empty() else ""
	var data: Variant=JSON.parse_string(raw) if not raw.is_empty() else null
	if not data is Dictionary:
		push_error("BAKED_DISCIPLE_SOCKET_METADATA_INVALID path=%s" % socket_metadata_path); return
	canvas_px=Vector2(float(data.get("body_canvas_px",[384,384])[0]),float(data.get("body_canvas_px",[384,384])[1]))
	baseline_y=float(data.get("foot_baseline_y_px",360.0))
	body_origin=Vector2(-canvas_px.x*0.5,-baseline_y)
	weapon_contract=data.get("weapon_asset",{})
	for frame_data in data.get("body_frames",[]):
		var key="%s:%d" % [str(frame_data.get("clip","")),int(frame_data.get("frame",-1))]
		socket_index[key]=frame_data
	var path=sword_texture_path
	if path.is_empty(): path=str(weapon_contract.get("path",""))
	if path.is_empty() or not ResourceLoader.exists(path):
		path=MAIN_LAB_ROOT+"/assets/weapons/AS48_KIEMTU_JIAN_CANDIDATE.png"
	sword.texture=load(path) as Texture2D
	if sword.texture==null: push_error("BAKED_DISCIPLE_WEAPON_LOAD_FAIL path=%s" % path)
	print("BAKED_DISCIPLE_ADAPTER_READY identity=%s clips=%d sockets=%d weapon=%s" % [str(data.get("identity","unknown")),sprite_frames.get_animation_names().size() if sprite_frames!=null else 0,socket_index.size(),path])

func play_candidate_clip(clip_name: StringName) -> bool:
	if sprite_frames == null or not sprite_frames.has_animation(clip_name):
		return false
	var parts := str(clip_name).split("_")
	if parts.size() >= 2 and str(parts[parts.size() - 1]) in ["front", "right", "back", "left"]:
		facing_direction = StringName(str(parts[parts.size() - 1]))
		current_action = StringName("_".join(parts.slice(0, parts.size() - 1)))
	elif str(clip_name) == "stand":
		current_action = &"idle"
		facing_direction = &"front"
	elif str(clip_name) == "walk":
		current_action = &"walk"
		facing_direction = &"front"
	play(clip_name)
	_sync_weapon()
	return true

func set_facing_direction(direction: StringName) -> bool:
	var value := str(direction).to_lower()
	if value not in ["front", "right", "back", "left"]:
		return false
	facing_direction = StringName(value)
	var clip := StringName(str(current_action) + "_" + value)
	if sprite_frames != null and sprite_frames.has_animation(clip):
		play(clip)
		_sync_weapon()
	return true

func play_game_action(action: StringName, direction: StringName = &"") -> bool:
	if not str(direction).is_empty():
		var value := str(direction).to_lower()
		if value not in ["front", "right", "back", "left"]:
			return false
		facing_direction = StringName(value)
	var action_name := ""
	match str(action).to_lower():
		"idle", "stand":
			action_name = "idle"
		"walk", "move":
			action_name = "walk"
		"attack":
			action_name = "attack"
		"cast", "skill":
			action_name = "cast"
		"hit", "hurt":
			action_name = "hit"
		"down", "downed", "death", "dead":
			action_name = "downed"
	if action_name.is_empty():
		return false
	current_action = StringName(action_name)
	var clip := StringName(action_name + "_" + str(facing_direction))
	if sprite_frames == null or not sprite_frames.has_animation(clip):
		clip = StringName(action_name + "_front")
	return play_candidate_clip(clip)

# The old Walk/Attack sprites use 400x440 (foot row 429), while the
# newer front poses use 384x384 (foot row 359). Match socket coordinates
# to the real texture's canvas each frame, including its foot registration.
func _sync_frame_geometry() -> void:
	if sprite_frames == null or not sprite_frames.has_animation(animation):
		return
	var tex: Texture2D = sprite_frames.get_frame_texture(animation, frame)
	if tex == null:
		return
	var size: Vector2 = tex.get_size()
	var key := "%s:%d" % [str(animation), frame]
	var frame_data: Dictionary = socket_index.get(key, {})
	var default_foot_y := 430.0 if size == Vector2(400.0, 440.0) else baseline_y
	var foot_y := float(frame_data.get("foot_baseline_y_px", default_foot_y))
	canvas_px = size
	body_origin = Vector2(-size.x * 0.5, -foot_y)
	offset = Vector2(0.0, size.y * 0.5 - foot_y)
	# Directional cels use 256px source cells but share the 384px body footprint.
	# Front candidate frames retain their authored 384px / legacy 400x440 scale.
	var registration_scale := 384.0 / size.y if size.y > 0.0 and size.y < 384.0 else 1.0
	scale = authored_scale * registration_scale

func _sync_weapon() -> void:
	_sync_frame_geometry()
	if hand_mask!=null: hand_mask.visible=false
	if sword==null or sword.texture==null or resolver==null or sprite_frames==null: return
	var clip_name := str(animation)
	if clip_name == "stand": clip_name = "idle_front"
	elif clip_name == "walk": clip_name = "walk_front"
	var key="%s:%d" % [clip_name,frame]
	if not socket_index.has(key): sword.visible=false; return
	var frame_data: Dictionary=socket_index[key]
	if not bool(frame_data.get("weapon_visible",false)): sword.visible=false; return
	var socket_map: Dictionary=frame_data.get("grip_sockets",{})
	var part: Dictionary=weapon_contract.duplicate(true)
	if not part.has("path") or str(part.get("path","")).is_empty(): part["path"]=sword_texture_path
	var result: Dictionary=resolver.call("resolve_weapon_part_transform",part,socket_map,body_origin,1.0)
	if result.is_empty(): sword.visible=false; return
	var socket: Dictionary=result.get("frame_socket",{})
	var grip_world: Vector2=result.get("grip_world",Vector2.ZERO)
	var asset_grip: Vector2=result.get("asset_grip_px",Vector2.ZERO)
	var center:=Vector2(sword.texture.get_width(),sword.texture.get_height())*0.5
	var scale_value=float(result.get("world_scale",1.0))
	var angle=deg_to_rad(float(result.get("rotation_deg",0.0)))
	sword.position=grip_world-(asset_grip-center).rotated(angle)*scale_value
	sword.rotation=angle; sword.scale=Vector2.ONE*scale_value; sword.visible=true
	sword.show_behind_parent=str(socket.get("draw_order",""))=="WEAPON_BEHIND_BODY"
	_sync_hand_mask(socket)

func _sync_hand_mask(socket: Dictionary) -> void:
	if hand_mask==null or str(socket.get("draw_order",""))!="WEAPON_FRONT_WITH_HAND_MASK":
		if hand_mask!=null: hand_mask.visible=false
		return
	var rect: Variant=socket.get("hand_mask_rect_px",[])
	if not rect is Array or rect.size()!=4: hand_mask.visible=false; return
	var texture=sprite_frames.get_frame_texture(animation,frame)
	if texture==null: hand_mask.visible=false; return
	hand_mask.texture=texture
	hand_mask.region_rect=Rect2(Vector2(float(rect[0]),float(rect[1])),Vector2(float(rect[2]),float(rect[3])))
	hand_mask.position=hand_mask.region_rect.position-canvas_px*0.5+offset
	hand_mask.visible=true
