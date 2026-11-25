extends Control
## Preview-only native Godot LAB. The only damage shown comes from MapBattleV2
## release_cast and its real v63_spear_line_hit events. No rig or PvE session.

const HSC := preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const ASCHAR := preload("res://src/presentation/p3/pve_aschar_frame_renderer_v1.gd")
const SOURCE_ATLAS := preload("res://src/presentation/p3/combat_v5_source_a_atlas.gd")
const SKILL_ID := "tmb.skill.spear.long_thuong.active_01.human"
const SOCKET_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/actor_sockets/AS54_weapon_sockets_v9_3_candidate.json"
const WEAPON_LIBRARY_PATH := "res://assets/p3/baked_candidates/weapon_library_v1/candidate/ASCHAR_24_ACTOR_WEAPON_BINDINGS_V9_3_CANDIDATE.json"
const PREVIEW_ATTACHMENT_OVERRIDE := {
	"asset_id":"spear", "anchor_slot":"off_hand", "align_tip_to_slot":"main_hand",
	"asset_scale":0.82, "restore_hand_slots":["off_hand","main_hand"]
}
const ASCHAR_DISPLAY_SCALE := 0.25
const CHARGE_DISPLAY_SIZE := Vector2(52.0,36.0)
const CHARGE_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/charge_r1.png"
const PEAK_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/peak_r2.png"
const CONTACT_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/contact_r1.png"
const FADE_PATH := "res://labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/fade_r1.png"
const WINDUP_SECONDS := 0.38

var battle: MapBattleV2
var source_atlas: CombatV5SourceAAtlas
var targets: Dictionary = {}
var start_positions: Dictionary = {}
var end_positions := {
	"spear_lab_target_01":Vector2(5.8,2.15),
	"spear_lab_target_02":Vector2(7.2,2.35),
	"spear_lab_outside":Vector2(5.9,3.25)
}
var before_hp: Dictionary = {}
var receipts: Array[Dictionary] = []
var actor_socket_manifest: Dictionary = {}
var spear_weapon_info: Dictionary = {}
var run_state := "BLOCKED"
var run_error := ""
var cast_elapsed := 0.0
var impact_time := -1.0
var _cast_started_msec := 0
var charge_texture: Texture2D
var peak_texture: Texture2D
var contact_texture: Texture2D
var fade_texture: Texture2D
var _font: Font
var aschar_draw_success := false
var source_draw_success_by_actor: Dictionary = {}

func _ready() -> void:
	_font = ThemeDB.fallback_font
	charge_texture = load(CHARGE_PATH) as Texture2D
	peak_texture = load(PEAK_PATH) as Texture2D
	contact_texture = load(CONTACT_PATH) as Texture2D
	fade_texture = load(FADE_PATH) as Texture2D
	custom_minimum_size = Vector2(1280,720)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	set_process(true)
	_prepare_preview()
	queue_redraw()

func _prepare_preview() -> void:
	if charge_texture == null or peak_texture == null or contact_texture == null or fade_texture == null:
		_block("G3_SOURCE_FAIL: one or more authored RGBA masters did not load in Godot")
		return
	var parsed_socket: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOCKET_PATH))
	var parsed_library: Variant = JSON.parse_string(FileAccess.get_file_as_string(WEAPON_LIBRARY_PATH))
	if not (parsed_socket is Dictionary) or not (parsed_library is Dictionary):
		_block("ART_SOURCE_BLOCKED: existing AS54 socket or weapon library JSON is unavailable")
		return
	actor_socket_manifest = parsed_socket
	spear_weapon_info = Dictionary(parsed_library.get("asset_library",{})).get("spear",{})
	if spear_weapon_info.is_empty() or str(spear_weapon_info.get("owner_art_approval","")) != "PENDING":
		_block("ART_SOURCE_BLOCKED: existing spear prop is not the expected pending candidate")
		return
	source_atlas = SOURCE_ATLAS.new()
	if not source_atlas.has_actor("monster_1113031_1"):
		_block("ART_SOURCE_BLOCKED: supported Source A monster clips unavailable")
		return
	if not ResourceLoader.exists("res://assets/p3/baked_candidates/aschar54_candidate/AS54_SPEAR_CLIPS_CANDIDATE.tres", "SpriteFrames"):
		_block("ART_SOURCE_BLOCKED: AS54 candidate SpriteFrames unavailable")
		return
	var caster_row := _caster_row()
	var target_01 := _monster_row("spear_lab_target_01", Vector2(5.45,2.0))
	var target_02 := _monster_row("spear_lab_target_02", Vector2(6.85,2.15))
	var outside := _monster_row("spear_lab_outside", Vector2(5.55,3.5))
	if target_01.is_empty() or target_02.is_empty() or outside.is_empty():
		_block("ART_SOURCE_BLOCKED: MonsterCatalogueV2 could not create actors")
		return
	start_positions = {
		"spear_lab_target_01":target_01["position"],
		"spear_lab_target_02":target_02["position"],
		"spear_lab_outside":outside["position"]
	}
	battle = MapBattleV2.new(83711)
	var setup := battle.setup("spear_van_long_diem_thuy_preview", [caster_row],
		[target_01,target_02,outside])
	if not bool(setup.get("ok",false)):
		_block("ART_SOURCE_BLOCKED: MapBattleV2.setup failed: " + str(setup))
		return
	var caster: Dictionary = battle.actors["spear_lab_caster"]
	targets = {
		"spear_lab_target_01":battle.actors["spear_lab_target_01"],
		"spear_lab_target_02":battle.actors["spear_lab_target_02"],
		"spear_lab_outside":battle.actors["spear_lab_outside"]
	}
	for target_id in targets:
		before_hp[target_id] = float(targets[target_id].get("hp",0.0))
	var first_target: Dictionary = targets["spear_lab_target_01"]
	if not HSC.try_cast(battle,caster,first_target):
		_block("ART_SOURCE_BLOCKED: canonical Vân Long cast was rejected")
		return
	var pending: Dictionary = caster.get("v63_pending_cast",{})
	if str(pending.get("v63_skill_id","")) != SKILL_ID or str(pending.get("shape","")) != "line":
		_block("ART_SOURCE_BLOCKED: runtime pending cast does not match canonical line skill")
		return
	if _socket_rows("cast",0.0).is_empty() or _socket_rows("attack",WINDUP_SECONDS).is_empty():
		_block("ART_SOURCE_BLOCKED: existing AS54 candidate lacks cast-right or attack-right grip rows")
		return
	run_state = "WINDUP_MOVING_TARGETS"
	cast_elapsed = 0.0
	_cast_started_msec = Time.get_ticks_msec()
	queue_redraw()

func _process(delta: float) -> void:
	if run_state == "WINDUP_MOVING_TARGETS":
		cast_elapsed = minf(WINDUP_SECONDS,cast_elapsed+delta)
		var progress := clampf(cast_elapsed/WINDUP_SECONDS,0.0,1.0)
		for target_id in targets:
			var actor: Dictionary = targets[target_id]
			actor["position"] = (start_positions[target_id] as Vector2).lerp(
				end_positions[target_id],progress)
		if progress >= 1.0:
			_release_runtime_cast()
		queue_redraw()
	else:
		queue_redraw()

func _release_runtime_cast() -> void:
	var caster: Dictionary = battle.actors["spear_lab_caster"]
	var pending: Dictionary = caster.get("v63_pending_cast",{})
	battle.now = float(pending.get("ready",battle.now))
	for target_id in targets:
		(targets[target_id] as Dictionary)["position"] = end_positions[target_id]
	battle._release_casts()
	receipts.clear()
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type","")) == "v63_spear_line_hit" and str(event.get("skill_id","")) == SKILL_ID:
			receipts.append(event)
	var correct_targets := {}
	for event in receipts:
		correct_targets[str(event.get("target",""))] = true
	var expected := ["spear_lab_target_01","spear_lab_target_02"]
	var outside: Dictionary = targets["spear_lab_outside"]
	var ok := receipts.size() == 2 and correct_targets.has(expected[0]) and correct_targets.has(expected[1])
	ok = ok and is_equal_approx(float(outside.get("hp",0.0)),float(before_hp["spear_lab_outside"]))
	for event in receipts:
		ok = ok and int(event.get("target_limit",0)) == 2
	if not ok:
		print("SPEAR_LAB_DIAGNOSTIC receipts=%s target_hp=%s outside_before=%s outside_after=%s pending=%s" % [
			str(receipts),str({"t1":targets["spear_lab_target_01"].get("hp"),"t2":targets["spear_lab_target_02"].get("hp")}),
			str(before_hp["spear_lab_outside"]),str(outside.get("hp")),str(pending)])
		_block("ART_SOURCE_BLOCKED: live release failed 2-target line receipt contract")
		return
	run_state = "CONFIRMED_TWO_TARGET_RELEASE"
	impact_time = Time.get_ticks_msec()/1000.0
	print("SPEAR_LONG_THRUST_LAB_RUNTIME PASS receipts=%d target_limit=2 outside_hp=unchanged targets_moved_during_cast=true pve=OFF" % receipts.size())
	queue_redraw()

func _block(message: String) -> void:
	run_state = "ART_SOURCE_BLOCKED"
	run_error = message
	push_error(message)
	queue_redraw()

func _caster_row() -> Dictionary:
	var resistances := {}
	for element in ["metal","wood","water","fire","earth","lightning","wind","ice","yang","nether"]:
		resistances[element] = 0.0
	var actor := {
		"id":"spear_lab_caster","role":"frontline","position":Vector2(2,2),
		"hp":500.0,"max_hp":500.0,"range":1.8,"basic_range":1.8,"move_speed":2.0,
		"stats":{"max_hp":500.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,
			"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,
			"defense_penetration":0.0,"lifesteal":0.0,"lifesteal_reduction":0.0},
		"resistances":resistances,"context_sources":[],"skill_loadout":[],
		"v63_combat_enabled":true,"v63_spear_combat_enabled":true,
		"v63_skill_loadout":[SKILL_ID],"v63_skill_ready":{},"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0
	}
	return actor

func _monster_row(actor_id: String, position: Vector2) -> Dictionary:
	var created := MonsterCatalogueV2.create_actor("thanh_lang",1,1,actor_id)
	if not bool(created.get("ok",false)):
		return {}
	var actor: Dictionary = created
	actor["id"] = actor_id
	actor["position"] = position
	return actor

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("101820"))
	draw_rect(Rect2(0,130,size.x,590),Color("17252d"))
	draw_rect(Rect2(0,455,size.x,265),Color("24352f"))
	for y in range(462,720,36):
		draw_line(Vector2(0,y),Vector2(size.x,y),Color(0.46,0.59,0.51,0.09),1.0,true)
	for x in range(0,1280,64):
		draw_line(Vector2(x,455),Vector2(x,720),Color(0.46,0.59,0.51,0.06),1.0,true)
	draw_rect(Rect2(0,0,1280,130),Color("0c1319"))
	draw_string(_font,Vector2(34,48),"VÂN LONG ĐIỂM THỦY · THƯƠNG TU · LAB VFX R1",
		HORIZONTAL_ALIGNMENT_LEFT,-1,27,Color("e9ddbd"))
	draw_string(_font,Vector2(36,79),"CANDIDATE ART · PREVIEW ONLY · PvE RELEASE OFF · AS54 / WEAPON SOCKETS CANDIDATE",
		HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("9fb2b0"))
	var caster_position := _world_to_screen(Vector2(2,2))
	var first_position := _world_to_screen(_target_position("spear_lab_target_01"))
	var second_position := _world_to_screen(_target_position("spear_lab_target_02"))
	draw_line(caster_position+Vector2(105,0),_world_to_screen(Vector2(8.2,2.0)),
		Color(0.56,0.75,0.72,0.20),2.0,true)
	_draw_target("spear_lab_target_01","TARGET 01 · MONSTER RUNTIME",first_position)
	_draw_target("spear_lab_target_02","TARGET 02 · MONSTER RUNTIME",second_position)
	_draw_target("spear_lab_outside","OUTSIDE LINE · UNCHANGED",_world_to_screen(_target_position("spear_lab_outside")))
	var caster_action := "attack" if run_state == "CONFIRMED_TWO_TARGET_RELEASE" else "cast"
	var caster_age := 0.0 if _cast_started_msec == 0 else float(Time.get_ticks_msec()-_cast_started_msec)/1000.0
	aschar_draw_success = ASCHAR.draw_actor(self,"spear","male",caster_action,
		_world_to_screen(Vector2(2,2)),Vector2.RIGHT,caster_age,ASCHAR_DISPLAY_SCALE,WINDUP_SECONDS,
		PREVIEW_ATTACHMENT_OVERRIDE)
	_draw_receipt_fx()
	_draw_actor_status()

func _draw_target(actor_id: String, title: String, foot: Vector2) -> void:
	if targets.is_empty() or not targets.has(actor_id) or source_atlas == null:
		return
	var actor: Dictionary = targets[actor_id]
	var hit := _has_receipt(actor_id)
	var action := "hit" if hit else ("walk" if run_state == "WINDUP_MOVING_TARGETS" else "stand")
	var age := cast_elapsed if not hit else maxf(0.0,Time.get_ticks_msec()/1000.0-impact_time)
	source_draw_success_by_actor[actor_id] = source_atlas.draw_actor(self,
		"monster_1113031_1",action,foot,Vector2.LEFT,age,1.0)
	var bar_left := foot.x-47.0
	var bar_top := foot.y-106.0
	draw_rect(Rect2(bar_left,bar_top,94,7),Color("111519"))
	var ratio := clampf(float(actor.get("hp",0.0))/maxf(1.0,float(actor.get("max_hp",1.0))),0.0,1.0)
	draw_rect(Rect2(bar_left,bar_top,94*ratio,7),Color("8cae9a") if not hit else Color("c2b17b"))
	var label_color := Color("eee1c5") if hit else Color("b0beb2")
	var label_y := bar_top-12.0 if actor_id != "spear_lab_outside" else bar_top+24.0
	draw_string(_font,Vector2(foot.x-89,label_y),title,HORIZONTAL_ALIGNMENT_CENTER,178,12,label_color)

func _draw_receipt_fx() -> void:
	if run_state == "WINDUP_MOVING_TARGETS":
		# Anchor the existing charge master to the candidate weapon tip resolved
		# from the same two frame sockets used by the local preview override.
		if charge_texture != null:
			var progress := clampf(cast_elapsed / WINDUP_SECONDS, 0.0, 1.0)
			var alpha := 0.58 + 0.30 * sin(progress * PI)
			var tip := _candidate_spear_tip_screen("cast",cast_elapsed)
			var charge_center := tip-Vector2(CHARGE_DISPLAY_SIZE.x*0.26,0.0)
			draw_texture_rect(charge_texture,
				Rect2(charge_center-CHARGE_DISPLAY_SIZE*0.5,CHARGE_DISPLAY_SIZE),false,
				Color(1.0,1.0,1.0,alpha))
		return
	if run_state != "CONFIRMED_TWO_TARGET_RELEASE" or receipts.is_empty():
		return
	var age := maxf(0.0,Time.get_ticks_msec()/1000.0-impact_time)
	var alpha := clampf(1.0-age/1.15,0.0,1.0)
	if age < 0.62:
		var peak_alpha := minf(1.0,alpha*1.2)
		if peak_texture != null:
			var action_age := 0.0 if _cast_started_msec == 0 else float(Time.get_ticks_msec()-_cast_started_msec)/1000.0
			var tip := _candidate_spear_tip_screen("attack",action_age)
			var line_end := _world_to_screen(_target_position("spear_lab_target_02"))-Vector2(0,74)
			_draw_spear_beam(tip,line_end,peak_alpha)
	elif age < 1.15:
		if fade_texture != null:
			draw_texture_rect(fade_texture,Rect2(Vector2(405,362),Vector2(88,45)),false,Color(1,1,1,alpha))
	for event in receipts:
		var actor_id := str(event.get("target",""))
		var center := _world_to_screen(_target_position(actor_id))-Vector2(0,74)
		var size_px := Vector2(44,30) if age < 0.62 else Vector2(32,22)
		var texture: Texture2D = contact_texture if age < 0.62 else fade_texture
		if texture != null:
			draw_texture_rect(texture,Rect2(center-size_px*0.5,size_px),false,Color(1,1,1,alpha))

func _socket_rows(action: String,age: float) -> Array:
	var verb := "attack" if action == "attack" else "cast"
	var clip := verb+"_right"
	var found: Array = []
	for raw in actor_socket_manifest.get("body_frames",[]):
		if raw is Dictionary and str(raw.get("clip","")) == clip:
			found.append(raw)
	if found.is_empty():
		return []
	var frame_index := ASCHAR.frame_index(action,age,found.size(),WINDUP_SECONDS)
	return [found[frame_index]]

func _candidate_spear_tip_screen(action: String,age: float) -> Vector2:
	var rows := _socket_rows(action,age)
	if rows.is_empty() or spear_weapon_info.is_empty():
		return _world_to_screen(Vector2(2,2))+Vector2(105,-62)
	var row: Dictionary = rows[0]
	var grips: Dictionary = row.get("grip_sockets",{})
	var anchor_slot := str(PREVIEW_ATTACHMENT_OVERRIDE["anchor_slot"])
	var direction_slot := str(PREVIEW_ATTACHMENT_OVERRIDE["align_tip_to_slot"])
	var anchor_grip: Dictionary = grips.get(anchor_slot,{})
	var direction_grip: Dictionary = grips.get(direction_slot,{})
	var anchor_px: Array = anchor_grip.get("body_grip_px",[])
	var direction_px: Array = direction_grip.get("body_grip_px",[])
	var asset_grip: Array = spear_weapon_info.get("grip_px",[])
	var asset_tip: Array = spear_weapon_info.get("tip_px",[])
	if anchor_px.size() != 2 or direction_px.size() != 2 or asset_grip.size() != 2 or asset_tip.size() != 2:
		return _world_to_screen(Vector2(2,2))+Vector2(105,-62)
	var hand_axis := Vector2(float(direction_px[0])-float(anchor_px[0]),float(direction_px[1])-float(anchor_px[1]))
	var asset_axis := Vector2(float(asset_tip[0])-float(asset_grip[0]),float(asset_tip[1])-float(asset_grip[1]))
	if hand_axis.length_squared() < 0.001 or asset_axis.length_squared() < 0.001:
		return _world_to_screen(Vector2(2,2))+Vector2(105,-62)
	var rotation := hand_axis.angle()-asset_axis.angle()+deg_to_rad(float(PREVIEW_ATTACHMENT_OVERRIDE.get("rotation_offset_deg",0.0)))
	var canvas_size: Array = actor_socket_manifest.get("body_canvas_px",[384,384])
	var baseline := float(actor_socket_manifest.get("foot_baseline_y_px",359.0))
	var body_center := Vector2(float(canvas_size[0])*0.5,baseline)
	var actor_foot := _world_to_screen(Vector2(2,2))
	var anchor_screen := actor_foot+(Vector2(float(anchor_px[0]),float(anchor_px[1]))-body_center)*ASCHAR_DISPLAY_SCALE
	var weapon_scale := float(spear_weapon_info.get("asset_scale",0.0))
	if weapon_scale <= 0.0:
		weapon_scale = float(anchor_grip.get("scale_multiplier",0.30))
	weapon_scale = float(PREVIEW_ATTACHMENT_OVERRIDE.get("asset_scale",weapon_scale))
	return anchor_screen+asset_axis.rotated(rotation)*(weapon_scale*ASCHAR_DISPLAY_SCALE)

func _draw_spear_beam(from: Vector2,to: Vector2,alpha: float) -> void:
	var axis := to-from
	if axis.length() < 1.0:
		return
	var width := axis.length()+36.0
	var height := width*724.0/2172.0
	draw_set_transform((from+to)*0.5,axis.angle(),Vector2.ONE)
	draw_texture_rect(peak_texture,Rect2(Vector2(-width*0.5,-height*0.5),Vector2(width,height)),
		false,Color(1,1,1,alpha))
	draw_set_transform(Vector2.ZERO)

func _draw_actor_status() -> void:
	var line := ""
	var color := Color("e8d9b9")
	if run_state == "WINDUP_MOVING_TARGETS":
		line = "Windup %.2f / %.2fs · targets moving inside the actual MapBattle actor rows" % [cast_elapsed,WINDUP_SECONDS]
	elif run_state == "CONFIRMED_TWO_TARGET_RELEASE":
		line = "2 REAL LINE-HIT RECEIPTS · target_limit=2 · outside target HP unchanged"
		color = Color("c3d5b7")
	elif run_state == "ART_SOURCE_BLOCKED":
		line = run_error
		color = Color("edb0a0")
	else:
		line = "Runtime preview blocked"
	draw_string(_font,Vector2(35,666),line,HORIZONTAL_ALIGNMENT_LEFT,1210,17,color)
	draw_string(_font,Vector2(36,695),"Monster art is a generic Source A placeholder (species-to-art link unverified). Actor/weapon, source art and VFX are candidates; no owner approval.",
		HORIZONTAL_ALIGNMENT_LEFT,1205,12,Color("abb8b0"))

func _target_position(actor_id: String) -> Vector2:
	if targets.has(actor_id):
		return targets[actor_id].get("position",Vector2.ZERO)
	return Vector2.ZERO

func _world_to_screen(position: Vector2) -> Vector2:
	return Vector2(240.0+(position.x-2.0)*90.0,484.0+(position.y-2.0)*90.0)

func _has_receipt(actor_id: String) -> bool:
	for event in receipts:
		if str(event.get("target","")) == actor_id and str(event.get("skill_id","")) == SKILL_ID:
			return true
	return false
