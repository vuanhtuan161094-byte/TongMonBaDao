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
	var frame_height := 384.0
	var idle := sprite_frames.get_frame_texture(&"stand",0) if sprite_frames != null and sprite_frames.has_animation(&"stand") else null
	if idle != null: frame_height=float(idle.get_height())
	offset=Vector2(0.0,frame_height*0.5-baseline_y)
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
	if sprite_frames==null or not sprite_frames.has_animation(clip_name): return false
	play(clip_name); _sync_weapon(); return true

func play_game_action(action: StringName) -> bool:
	var action_clip=""
	match str(action).to_lower():
		"idle","stand": action_clip="idle_front"
		"walk","move": action_clip="walk_front"
		"attack": action_clip="attack_front"
		"cast","skill": action_clip="cast_front"
		"hit","hurt": action_clip="hit_front"
		"down","downed": action_clip="downed_front"
		"death","dead": action_clip="death_front"
	return play_candidate_clip(StringName(action_clip)) if not action_clip.is_empty() else false

func _sync_weapon() -> void:
	if hand_mask!=null: hand_mask.visible=false
	if sword==null or sword.texture==null or resolver==null or sprite_frames==null: return
	var key="%s:%d" % [str(animation),frame]
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
