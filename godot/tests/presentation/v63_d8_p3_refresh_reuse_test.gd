extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("V63_D8_P3_REFRESH_REUSE_FAIL: "+message)
	quit(1)

func _run() -> void:
	var state := SimulationState.new()
	var battle := MapBattleV2.new(808808)
	battle.encounter_id = "d8_refresh_reuse"
	battle.active = true
	battle.outcome = "active"
	for index in range(6):
		var actor_id := "d8_reuse_%02d" % index
		state.disciples[StringName(actor_id)] = DiscipleState.new({"id":actor_id,"name":"Đội %d" % index})
		battle.actors[actor_id] = {"id":actor_id,"side":"disciple","hp":80.0-float(index),"max_hp":100.0}
	for index in range(10):
		var actor_id := "d8_monster_%02d" % index
		battle.actors[actor_id] = {"id":actor_id,"side":"monster","species_id":"thanh_lang","hp":120.0,"max_hp":120.0}

	var hud := V63CombatHudV1.new()
	root.add_child(hud)
	await process_frame
	hud.set_authority(state,battle,true)
	var rows := hud.get("_rows") as VBoxContainer
	var party_rows: Array = hud.get("_party_rows")
	if rows == null or rows.get_child_count() != 6 or party_rows.size() != 6:
		_fail("HUD should allocate exactly six reusable party rows")
		return
	var row_ids: Array[int] = []
	for row in party_rows:
		row_ids.append((row as Control).get_instance_id())

	var map_script: Script = load("res://src/presentation/p3_2_landscape_sect.gd") as Script
	var map_view: Object = map_script.new()
	map_view.set("state",state)
	var registry := map_view.get("_v63_hunt_resource_registry") as ResourceRegistry
	if registry == null:
		_fail("P3.2 visual-row path has no reusable resource registry")
		return
	var registry_instance_id := registry.get_instance_id()
	var first_visual_rows: Dictionary = map_view.call("_b3_hunt_visual_rows",battle)
	for _iteration in range(5):
		var next_visual_rows: Dictionary = map_view.call("_b3_hunt_visual_rows",battle)
		if next_visual_rows != first_visual_rows:
			_fail("repeated P3.2 visual-row mapping changed its authored output")
			return
	if int((map_view.get("_v63_hunt_resource_registry") as ResourceRegistry).get_instance_id()) != registry_instance_id:
		_fail("P3.2 resource registry identity changed during repeated visual-row refreshes")
		return
	if first_visual_rows.size() != 16:
		_fail("P3.2 visual-row mapping should preserve all six disciples and ten monster rows")
		return
	for index in range(6):
		if not first_visual_rows.has("d8_reuse_%02d" % index):
			_fail("P3.2 visual-row mapping dropped disciple d8_reuse_%02d" % index)
			return
	for index in range(10):
		if not first_visual_rows.has("d8_monster_%02d" % index):
			_fail("P3.2 visual-row mapping dropped monster d8_monster_%02d" % index)
			return
	var first_id := "d8_reuse_00"
	battle.actors[first_id]["hp"] = 71.0
	state.disciples[StringName(first_id)].injury_level = 17
	hud.set_authority(state,battle,true)
	var updated_rows: Array = hud.get("_party_rows")
	for index in range(6):
		if (updated_rows[index] as Control).get_instance_id() != row_ids[index]:
			_fail("HUD party row %d was recreated during authority refresh" % index)
			return
	if not str((updated_rows[0] as Button).text).contains("HP 71/100") \
			or not str((updated_rows[0] as Button).text).contains("Injury 17"):
		_fail("reused party row did not refresh HP and Injury text")
		return
	if str(hud.get("_party_row_actor_ids")[0]) != first_id:
		_fail("reused row lost its selected actor identity")
		return

	for index in range(1,6):
		battle.actors.erase("d8_reuse_%02d" % index)
		state.disciples.erase(StringName("d8_reuse_%02d" % index))
	hud.set_authority(state,battle,true)
	if (updated_rows[0] as Control).get_instance_id() != row_ids[0] \
			or not (updated_rows[0] as Control).visible:
		_fail("HUD did not retain the visible row when party size changed")
		return
	for index in range(1,6):
		if (updated_rows[index] as Control).visible or not str(hud.get("_party_row_actor_ids")[index]).is_empty():
			_fail("unused HUD party row %d was not hidden and cleared" % index)
			return

	map_view.free()
	hud.queue_free()
	print("V63 D8 P3 REFRESH REUSE PASS: cached resource registry preserves visual rows; six HUD nodes update in place across refresh and roster-size changes")
	quit(0)
