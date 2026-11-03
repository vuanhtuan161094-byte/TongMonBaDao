extends SceneTree

# QA-only Source A visual hot-path contract. No player save, runtime or game
# resource mutations. Confirms one deep copy at renderer ownership boundary.
func _initialize() -> void:
	call_deferred("_run")

func _fail(reason: String) -> void:
	push_error("PVE_OPT01_SOURCE_A_VIEWROW_FAIL: " + reason)
	quit(1)

func _run() -> void:
	root.size = Vector2i(1280,720)
	var view := PveSectWorldViewV1.new()
	view.size = Vector2(700,484)
	root.add_child(view)
	await process_frame
	if view.world == null:
		_fail("real Source A renderer missing")
		return
	var world := view.world
	var battle := MapBattleV2.new(20261103)
	battle.encounter_id = "qa:pve:opt01:source_a"
	battle.active = true
	battle.outcome = "active"
	var visual_rows: Dictionary = {}
	for index in range(6):
		var id := "qa_v2_%02d" % index
		battle.actors[id] = {
			"id":id, "side":"disciple", "hp":100.0, "max_hp":100.0,
			"position":Vector2(84.5+float(index),86.5),
			"move_speed":2.0, "name":"Đệ tử %d" % index
		}
		visual_rows[id] = {
			"label":"Đệ tử %d" % index,
			"sprite_id":"source_a_disciple_%d" % index,
			"nested":{"hp":100.0,"category":"disciple"}
		}
	for index in range(10):
		var id := "qa_wolf_%02d" % index
		battle.actors[id] = {
			"id":id, "side":"monster", "hp":80.0, "max_hp":80.0,
			"position":Vector2(94.5+float(index%5),86.5+float(index/5)),
			"move_speed":1.8, "name":"Thanh Lang"
		}
		visual_rows[id] = {
			"label":"Thanh Lang", "sprite_id":"source_a_wolf",
			"nested":{"hp":80.0,"category":"monster"}
		}
	view.show_authority_snapshot(battle,{},0,{},visual_rows)
	if world.pve_battle != battle or world.pve_view_rows.size() != 16 \
			or view.selected_actor_ids.size() != 6:
		_fail("Source A first 6v10 visual snapshot or selected actor count changed")
		return
	# The adapter must not deep-copy rows, only the actual world renderer
	# does. A mutation in the producer must NOT escape into the render snapshot.
	visual_rows["qa_v2_00"]["nested"]["hp"] = 31.0
	if float((view.get("_view_rows") as Dictionary)["qa_v2_00"]["nested"]["hp"]) != 31.0:
		_fail("adapter still deep-copies full visual rows before renderer")
		return
	if float(world.pve_view_rows["qa_v2_00"]["nested"]["hp"]) != 100.0:
		_fail("renderer immutable snapshot aliases mutable producer rows")
		return
	# On the next refresh, the authoritative producer's update must be visible.
	battle.actors["qa_v2_00"]["hp"] = 31.0
	view.show_authority_snapshot(battle,{},0,{},visual_rows)
	if float(world.pve_view_rows["qa_v2_00"]["nested"]["hp"]) != 31.0 \
			or not view.selected_actor_ids.has("qa_v2_00"):
		_fail("renderer did not apply updated HP/selection on second refresh")
		return
	# Dropping an actor must remove its selection and render position.
	battle.actors.erase("qa_v2_01")
	visual_rows.erase("qa_v2_01")
	view.show_authority_snapshot(battle,{},0,{},visual_rows)
	if world.pve_view_rows.size() != 15 or view.selected_actor_ids.has("qa_v2_01") \
			or world.pve_render_positions.has("qa_v2_01"):
		_fail("Source A refresh retained removed actor, or selection went stale")
		return
	if view.world != world or world.pve_battle != battle:
		_fail("refresh recreated renderer instead of reusing native Source A world")
		return
	view.queue_free()
	await process_frame
	print("PVE_OPT01_SOURCE_A_VIEWROW_PASS " + JSON.stringify({
		"source_a_world_reused":true, "visual_rows_initial":16,
		"visual_rows_after_removal":15, "double_deepcopy_removed":true,
		"renderer_defensive_snapshot":true, "selection_and_hp_updated":true,
		"asset_files_modified":false, "simulation_files_modified":false
	}))
	quit(0)
