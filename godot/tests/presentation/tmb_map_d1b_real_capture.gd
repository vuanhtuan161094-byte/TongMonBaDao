extends SceneTree

# Genuine P3.2 capture helper. Instantiates the production scene and captures
# its root viewport; it never draws a substitute map or edits gameplay state.
const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const EXPECTED_VIEWPORT := Vector2i(1280,720)

var scene: Control

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 1:
		_fail("usage: -- <absolute-output-png> [optional-label]")
		return
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		_fail("production P3.2 scene could not be loaded")
		return
	scene = packed.instantiate() as Control
	if scene == null:
		_fail("production P3.2 root is not Control")
		return
	root.add_child(scene)
	for _frame in range(4):
		await process_frame
		await RenderingServer.frame_post_draw
	var viewport := root.get_viewport()
	if viewport == null or Vector2i(viewport.get_visible_rect().size) != EXPECTED_VIEWPORT:
		_fail("root viewport must be exactly 1280x720; got %s" % str(viewport.get_visible_rect().size if viewport != null else Vector2.ZERO))
		return
	var state := scene.get("state") as SimulationState
	var iso := scene.find_child("SectIsoWorld192",true,false) as SectIsometricWorldV1
	if state == null or not bool(scene.get("runtime_ready")) or iso == null:
		_fail("capture did not mount the real P3.2 runtime/map")
		return
	var state_before := state.to_dict().duplicate(true)
	var mode := str(args[1]) if args.size() > 1 else "default"
	if mode == "benchmark":
		await _run_benchmark(args[0],int(state_before.get("tick",0)))
		return
	if args.size() > 2:
		var snapshot_path := str(args[2])
		var snapshot := FileAccess.open(snapshot_path, FileAccess.WRITE)
		if snapshot == null:
			_fail("could not write state snapshot: %s" % snapshot_path)
			return
		snapshot.store_string(JSON.stringify(_canonical(state_before), "\t"))
		snapshot.close()
	if mode == "mine" or mode == "forest" or mode == "field":
		var wanted_type: StringName = BuildingSystem.TYPE_MINE if mode == "mine" else (BuildingSystem.TYPE_LINH_FOREST if mode == "forest" else BuildingSystem.TYPE_SPIRIT_FIELD)
		var target: BuildingState
		for raw_id in state.buildings.keys():
			var candidate: BuildingState = state.buildings[raw_id]
			if candidate.building_type == wanted_type:
				target = candidate
				break
		if target == null:
			_fail("no real %s BuildingState to capture" % mode)
			return
		var row: Dictionary = {}
		for item in iso.display_instances:
			if StringName(item["building_id"]) == target.id:
				row = item
				break
		if row.is_empty():
			_fail("real %s BuildingState is not mapped to a display row" % mode)
			return
		var tap := _screen_for_world(iso,row["world"]+Vector2(0,-36))
		if not SectMapCamera.is_map_screen_point(tap):
			scene.call("_pan_camera",Vector2(640,357)-tap)
			await process_frame
			tap = _screen_for_world(iso,row["world"]+Vector2(0,-36))
		if not bool(scene.call("_try_iso_map_pick",tap)):
			_fail("actual %s marker did not open its management panel" % mode)
			return
		await process_frame
		if StringName(scene.get("selected_production_instance_id")) != target.id:
			_fail("P3.2 selected a different producer than %s" % str(target.id))
			return
	elif mode == "panzoom":
		scene.call("_pan_camera",Vector2(-82,42))
		await process_frame
		scene.call("_zoom_at",Vector2(640,357),1.35,false)
		await process_frame
		await process_frame
	# Let the root Control tree redraw after a real producer pick/pan/zoom before
	# reading the framebuffer; SubViewport map updates are independent of root UI.
	for _redraw in range(2):
		await process_frame
		await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	if image == null or image.get_size() != EXPECTED_VIEWPORT:
		_fail("root viewport image has unexpected size")
		return
	var output := ProjectSettings.globalize_path(args[0]) if args[0].begins_with("user://") or args[0].begins_with("res://") else args[0]
	var dir := output.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var mkdir := DirAccess.make_dir_recursive_absolute(dir)
		if mkdir != OK:
			_fail("could not create capture directory: %s" % dir)
			return
	var save_error := image.save_png(output)
	if save_error != OK:
		_fail("Image.save_png failed: %s" % error_string(save_error))
		return
	var building_ids: Array[String] = []
	for raw_id in state.buildings.keys():
		building_ids.append(str(raw_id))
	building_ids.sort()
	var routes: Variant = iso.get("preview_routes")
	var route_count: int = routes.size() if routes is Dictionary else 0
	var layout_anchors: Dictionary = {}
	for kind in iso.TYPE_ANCHORS.keys():
		var cell: Vector2i = iso.TYPE_ANCHORS[kind]
		layout_anchors[str(kind)] = [cell.x,cell.y]
	var state_data := state.to_dict()
	var comparable_payload := state_data.duplicate(true)
	comparable_payload.erase("runtime_last_wall_unix")
	comparable_payload.erase("runtime_unconsumed_wall_seconds")
	# Recruitment candidates are serialized from a Dictionary-backed pool. The
	# pool's display/serialization order may vary across process launches; compare
	# the same candidate set by stable ID while retaining every candidate value.
	var candidates: Array = comparable_payload.get("recruitment_candidates", [])
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	comparable_payload["recruitment_candidates"] = candidates
	var manifest := {
		"label": args[1] if args.size() > 1 else "runtime",
		"scene": MAIN_SCENE,
		"godot": Engine.get_version_info(),
		"viewport": [image.get_width(),image.get_height()],
		"runtime_ready": bool(scene.get("runtime_ready")),
		"simulation_state_sha256": _stable_state_sha256(state_data),
		"simulation_payload_sha256_wall_clock_and_candidate_order_normalized": _stable_state_sha256(comparable_payload),
		"simulation_payload_normalization": "only runtime_last_wall_unix, runtime_unconsumed_wall_seconds, and recruitment_candidates array order by stable ID",
		"simulation_tick": state.tick,
		"runtime_last_wall_unix": state.runtime_last_wall_unix,
		"runtime_unconsumed_wall_seconds": state.runtime_unconsumed_wall_seconds,
		"state_unchanged_by_capture": state.to_dict() == state_before,
		"building_ids": building_ids,
		"camera_zoom": iso.camera.zoom.x,
		"camera_position": [iso.camera.position.x,iso.camera.position.y],
		"active_chunks": iso.active_chunks.size(),
		"route_count": route_count,
		"layout_anchors": layout_anchors,
		"road_cells": iso.preview_roads.size(),
		"decoration_count": iso.decoration_items.size(),
		"selected_building": str(scene.get("selected_building")),
		"selected_production_instance_id": str(scene.get("selected_production_instance_id")),
		"source_art": iso.art_source_status,
		"png_path": output,
		"png_sha256": FileAccess.get_sha256(output)
	}
	var manifest_path := output.get_basename()+".json"
	var file := FileAccess.open(manifest_path,FileAccess.WRITE)
	if file == null:
		_fail("could not write capture manifest")
		return
	file.store_string(JSON.stringify(manifest,"\t"))
	file.close()
	if not bool(manifest["state_unchanged_by_capture"]):
		_fail("capture mode changed SimulationState")
		return
	print("MAP D1B REAL P3.2 CAPTURE PASS %s %dx%d sha256=%s" % [manifest["label"],image.get_width(),image.get_height(),manifest["png_sha256"]])
	quit(0)

func _screen_for_world(map_world: SectIsometricWorldV1, world: Vector2) -> Vector2:
	return map_world.MAP_SCREEN_OFFSET+map_world.VIEW_SIZE*0.5+(world-map_world.camera.position)*map_world.camera.zoom.x

func _canonical(value: Variant) -> Variant:
	if value is Dictionary:
		var keys: Array = value.keys()
		keys.sort_custom(func(a: Variant,b: Variant) -> bool:
			return str(a) < str(b)
		)
		var result: Dictionary = {}
		for key in keys:
			result[str(key)] = _canonical(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item in value:
			result.append(_canonical(item))
		return result
	return value

func _stable_state_sha256(data: Dictionary) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(JSON.stringify(_canonical(data)).to_utf8_buffer())
	return context.finish().hex_encode()

func _run_benchmark(output_path: String, tick_before: int) -> void:
	# Warm the genuine production P3.2 scene, then measure 60 one-second windows.
	# This path records runtime telemetry; it does not use a screenshot FPS value.
	for _warmup in range(5):
		await process_frame
		await RenderingServer.frame_post_draw
	var fps_samples: Array[float] = []
	var process_ms_samples: Array[float] = []
	var physics_ms_samples: Array[float] = []
	var working_set_mib_samples: Array[float] = []
	var draw_call_samples: Array[int] = []
	var total_frames := 0
	var benchmark_start := Time.get_ticks_usec()
	for _second in range(60):
		var window_start := Time.get_ticks_usec()
		var frames_before := Engine.get_frames_drawn()
		var frames_after := frames_before
		while Time.get_ticks_usec() - window_start < 1000000:
			await process_frame
			frames_after = Engine.get_frames_drawn()
			process_ms_samples.append(float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0)
			physics_ms_samples.append(float(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)) * 1000.0)
		var elapsed_seconds := float(Time.get_ticks_usec() - window_start) / 1000000.0
		var window_frames := frames_after - frames_before
		fps_samples.append(float(window_frames) / maxf(elapsed_seconds,0.001))
		total_frames += window_frames
		working_set_mib_samples.append(float(OS.get_static_memory_usage()) / 1048576.0)
		draw_call_samples.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	var total_seconds := float(Time.get_ticks_usec() - benchmark_start) / 1000000.0
	var result := {
		"scene": MAIN_SCENE,
		"godot": Engine.get_version_info(),
		"viewport": [1280,720],
		"rendering_api": "OpenGL Compatibility; Intel Iris Plus GPU (from runtime log)",
		"warmup_seconds": 5,
		"measurement_seconds": roundf(total_seconds),
		"sample_windows": fps_samples.size(),
		"total_frames": total_frames,
		"average_fps": float(total_frames) / maxf(total_seconds,0.001),
		"fps_min_1s": _numeric_min(fps_samples),
		"fps_median_1s": _numeric_percentile(fps_samples,0.5),
		"fps_p05_1s": _numeric_percentile(fps_samples,0.05),
		"fps_max_1s": _numeric_max(fps_samples),
		"process_frame_ms_median": _numeric_percentile(process_ms_samples,0.5),
		"process_frame_ms_p95": _numeric_percentile(process_ms_samples,0.95),
		"physics_frame_ms_median": _numeric_percentile(physics_ms_samples,0.5),
		"godot_static_memory_mib_median": _numeric_percentile(working_set_mib_samples,0.5),
		"godot_static_memory_mib_max": _numeric_max(working_set_mib_samples),
		"draw_calls_per_sample_median": _numeric_percentile(draw_call_samples,0.5),
		"state_tick_before": tick_before,
		"runtime_wall_clock_profile": "isolated capture benchmark userdata",
		"process_id": OS.get_process_id()
	}
	var file := FileAccess.open(output_path,FileAccess.WRITE)
	if file == null:
		_fail("could not write benchmark JSON: %s" % output_path)
		return
	file.store_string(JSON.stringify(result,"\t"))
	file.close()
	print("MAP D1B WINDOWS BENCHMARK PASS seconds=%d fps_avg=%.2f fps_min_1s=%.2f fps_median_1s=%.2f godot_static_memory_max_mib=%.2f" % [int(result["measurement_seconds"]),float(result["average_fps"]),float(result["fps_min_1s"]),float(result["fps_median_1s"]),float(result["godot_static_memory_mib_max"])])
	quit(0)

func _numeric_values(values: Array) -> Array[float]:
	var result: Array[float] = []
	for value in values:
		result.append(float(value))
	return result

func _numeric_min(values: Array) -> float:
	var numeric := _numeric_values(values)
	return numeric.min() if not numeric.is_empty() else 0.0

func _numeric_max(values: Array) -> float:
	var numeric := _numeric_values(values)
	return numeric.max() if not numeric.is_empty() else 0.0

func _numeric_percentile(values: Array, percentile: float) -> float:
	var numeric := _numeric_values(values)
	if numeric.is_empty():
		return 0.0
	numeric.sort()
	var index := clampi(int(ceil(percentile * float(numeric.size()))) - 1,0,numeric.size() - 1)
	return numeric[index]

func _fail(message: String) -> void:
	push_error("MAP D1B REAL CAPTURE FAIL: "+message)
	quit(1)
