extends SceneTree

const IDS: Array[String] = [
	"duong_mon_fx:m38_fly.webp",
	"thuy_yen_fx:m146_fly.webp",
	"vltk_native:01744d1a.webp",
]

var failures: Array[String] = []
var failure_events: Array[Dictionary] = []
var finished_handles: Dictionary = {}
var player: JXVfxPlayer
var stage: Node2D
var catalog := JXVfxCatalog.new()
var debug_info: Dictionary = {}
var performance_data: Dictionary = {"load_levels": []}

func _initialize() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	var watchdog := Timer.new()
	watchdog.wait_time = 25.0
	watchdog.one_shot = true
	watchdog.timeout.connect(func():
		printerr("focused runtime test watchdog expired")
		quit(2)
	)
	root.add_child(watchdog)
	watchdog.start()
	var result := {
		"engine_version": Engine.get_version_info(),
		"project_root": ProjectSettings.globalize_path("res://"),
		"checks": [],
		"failures": failures,
		"expected_failure_events": failure_events,
		"status": "RUNNING",
	}
	_check(catalog.load_index("res://catalog/library_index.json") == OK, "catalog_load")
	if failures.is_empty():
		_check(catalog.records.size() >= IDS.size(), "catalog_record_count")
		_check(_validate_metadata(), "metadata_geometry_timing")
		stage = Node2D.new()
		root.add_child(stage)
		player = JXVfxPlayer.new()
		root.add_child(player)
		player.set_catalog(catalog)
		player.effect_failed.connect(_on_effect_failed)
		player.effect_finished.connect(_on_effect_finished)
		_check(player.resource_manifest_reference_count >= 3, "static_resource_manifest_present")
		performance_data["godot_static_memory_before_preload_bytes"] = OS.get_static_memory_usage()
		var preload_started := Time.get_ticks_usec()
		var preload_failures := player.preload_effects(IDS)
		performance_data["three_effect_preload_elapsed_ms"] = float(Time.get_ticks_usec() - preload_started) / 1000.0
		performance_data["godot_static_memory_after_preload_bytes"] = OS.get_static_memory_usage()
		performance_data["texture_cache_entries_after_preload"] = player.texture_cache.size()
		_check(preload_failures == 0, "resource_loader_preload")
		var dmon_source_path := String(catalog.get_record(IDS[0]).get("texture_path", ""))
		var thuy_source_path := String(catalog.get_record(IDS[1]).get("texture_path", ""))
		_check(not player.texture_cache.has(dmon_source_path) and not player.texture_cache.has(thuy_source_path) and player.texture_cache.size() == 7, "runtime_preloads_pages_without_oversized_source_sheets")
		_check(_test_page_boundaries_and_alpha(), "page_boundaries_and_true_alpha")
		_check(_test_transparent_padding_preserves_source(), "transparent_padding_preserves_all_source_pixels")
		_check(await _test_multidirection_loop_and_stop(), "multidirection_loop_stop")
		_check(await _test_one_shot_completion(), "one_shot_completion")
		_check(_test_missing_resource_and_timing(), "missing_resource_and_timing_rejected")
		_check(_test_shared_texture_and_release(), "shared_texture_cache_lifecycle")
		_check(await _test_scene_lifecycle(), "scene_exit_releases_instances_and_cache")
		_check(await _test_load_levels(), "controlled_load_1_3_10_30")
	result["checks"] = _checks
	result["failures"] = failures.duplicate()
	result["expected_failure_events"] = failure_events.duplicate(true)
	result["debug"] = debug_info.duplicate(true)
	result["performance"] = performance_data.duplicate(true)
	result["status"] = "PASS" if failures.is_empty() else "FAIL"
	watchdog.stop()
	print("FOCUSED_RUNTIME_JSON=" + JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)

var _checks: Array[String] = []

func _check(condition: bool, check_name: String) -> void:
	_checks.append(check_name + ("=PASS" if condition else "=FAIL"))
	if not condition:
		failures.append(check_name)

func _validate_metadata() -> bool:
	var dmon: Dictionary = catalog.get_record(IDS[0]).get("animation", {})
	var thuy: Dictionary = catalog.get_record(IDS[1]).get("animation", {})
	var vltk: Dictionary = catalog.get_record(IDS[2]).get("animation", {})
	var dmon_anchor: Array = dmon.get("anchor_px", [])
	var thuy_anchor: Array = thuy.get("anchor_px", [])
	var dmon_regions: Array = dmon.get("frame_regions", [])
	var dmon_ok: bool = int(dmon.get("frames", 0)) == 34 and int(dmon.get("directions", 0)) == 1 and int(dmon.get("frame_ms", 0)) == 65 and dmon_anchor.size() == 2 and int(dmon_anchor[0]) == 132 and int(dmon_anchor[1]) == 391 and String(dmon.get("layout", "")) == "paged_rects" and dmon_regions.size() == 34
	var thuy_ok: bool = int(thuy.get("frames", 0)) == 3 and int(thuy.get("directions", 0)) == 16 and int(thuy.get("frame_ms", 0)) == 56 and thuy_anchor.size() == 2 and int(thuy_anchor[0]) == 54 and int(thuy_anchor[1]) == 58 and bool(thuy.get("source_dimensions_match", false)) and not String(thuy.get("runtime_texture_path", "")).is_empty()
	var vltk_rects: Array = vltk.get("rects", [])
	var nonuniform_rects := false
	if vltk_rects.size() == 96 and vltk_rects[0] is Array and vltk_rects[0].size() == 6:
		for rect in vltk_rects:
			if rect is Array and rect.size() == 6 and (rect[2] != vltk_rects[0][2] or rect[3] != vltk_rects[0][3]):
				nonuniform_rects = true
				break
	var vltk_ok: bool = int(vltk.get("frames", 0)) == 6 and int(vltk.get("directions", 0)) == 16 and int(vltk.get("frame_ms", 0)) == 55 and vltk_rects.size() == 96 and nonuniform_rects
	debug_info["metadata"] = {
		"dmon": {"frames": dmon.get("frames"), "directions": dmon.get("directions"), "frame_ms": dmon.get("frame_ms"), "anchor": dmon.get("anchor_px"), "layout": dmon.get("layout"), "regions": dmon.get("frame_regions", []).size(), "ok": dmon_ok},
		"thuy": {"frames": thuy.get("frames"), "directions": thuy.get("directions"), "frame_ms": thuy.get("frame_ms"), "anchor": thuy.get("anchor_px"), "source_dimensions_match": thuy.get("source_dimensions_match"), "runtime_texture_path": thuy.get("runtime_texture_path"), "ok": thuy_ok},
		"vltk": {"frames": vltk.get("frames"), "directions": vltk.get("directions"), "frame_ms": vltk.get("frame_ms"), "rect_count": vltk_rects.size(), "nonuniform": nonuniform_rects, "ok": vltk_ok},
	}
	return dmon_ok and thuy_ok and vltk_ok

func _test_multidirection_loop_and_stop() -> bool:
	var loop_handle := player.play(IDS[1], stage, Vector2(600, 350), {"loop": true, "direction": 15, "scale": 0.5})
	if loop_handle == 0:
		return false
	await create_timer(0.09).timeout
	var direction_ok := false
	if player.active.has(loop_handle):
		var loop_state: Dictionary = player.active[loop_handle]
		var sprite: Sprite2D = loop_state["sprite"]
		direction_ok = int(loop_state.get("direction", -1)) == 15 and int(loop_state.get("frame", 0)) >= 1 and sprite.region_rect.position == Vector2(212, 1065) and sprite.offset.is_equal_approx(Vector2(-54, -58))
	debug_info["multidirection_loop"] = {"active": player.active.has(loop_handle), "direction": int(player.active[loop_handle].get("direction", -1)) if player.active.has(loop_handle) else -1, "frame": int(player.active[loop_handle].get("frame", -1)) if player.active.has(loop_handle) else -1, "region": player.active[loop_handle]["sprite"].region_rect if player.active.has(loop_handle) else [], "direction_and_anchor_ok": direction_ok}
	player.stop(loop_handle)
	var stopped := not player.active.has(loop_handle)
	debug_info["multidirection_loop"]["stopped"] = stopped
	return direction_ok and stopped

func _test_one_shot_completion() -> bool:
	finished_handles.clear()
	var dmon_handle := player.play(IDS[0], stage, Vector2(180, 350), {"loop": false, "direction": 0, "scale": 0.18})
	if dmon_handle == 0:
		return false
	await create_timer(2.65).timeout
	var dmon_finished := not player.active.has(dmon_handle) and finished_handles.has(dmon_handle)
	var vltk_handle := player.play(IDS[2], stage, Vector2(950, 350), {"loop": false, "direction": 15, "scale": 0.6})
	if vltk_handle == 0:
		return false
	await create_timer(0.55).timeout
	var vltk_finished := not player.active.has(vltk_handle) and finished_handles.has(vltk_handle)
	return dmon_finished and vltk_finished

func _test_missing_resource_and_timing() -> bool:
	var missing_id := "test:missing_texture"
	catalog.records[missing_id] = {
		"record_id": missing_id,
		"texture_path": "textures/does_not_exist.webp",
		"animation": {"layout": "grid", "frames": 1, "directions": 1, "frame_size": [16, 16], "anchor_px": [8, 8], "frame_ms": 50, "timing_unit": "ms"},
	}
	var missing_handle := player.play(missing_id, stage, Vector2.ZERO)
	var missing_ok := missing_handle == 0
	var invalid_id := "test:invalid_timing"
	catalog.records[invalid_id] = {
		"record_id": invalid_id,
		"texture_path": "textures/does_not_exist.webp",
		"animation": {"layout": "grid", "frames": 1, "directions": 1, "frame_size": [16, 16], "anchor_px": [8, 8], "frame_ms": 0, "timing_unit": "ms"},
	}
	var invalid_handle := player.play(invalid_id, stage, Vector2.ZERO)
	var saw_missing := false
	var saw_timing := false
	for event in failure_events:
		if event.get("reason", "") == "TEXTURE_LOAD_FAILED":
			saw_missing = true
		if event.get("reason", "") == "TIMING_UNIT_UNVERIFIED_OR_MISSING":
			saw_timing = true
	return missing_ok and invalid_handle == 0 and saw_missing and saw_timing

func _test_shared_texture_and_release() -> bool:
	var id := IDS[2]
	var first := player.play(id, stage, Vector2(250, 350), {"loop": true})
	var second := player.play(id, stage, Vector2(350, 350), {"loop": true})
	if first == 0 or second == 0:
		return false
	var texture_a: Texture2D = player.active[first]["sprite"].texture
	var texture_b: Texture2D = player.active[second]["sprite"].texture
	var shared := texture_a == texture_b
	player.stop(first)
	player.stop(second)
	player.release_unused([id])
	return shared and player.texture_cache.size() == 1 and player.texture_cache_hits > 0

func _test_scene_lifecycle() -> bool:
	var handle := player.play(IDS[1], stage, Vector2(500, 350), {"loop": true})
	if handle == 0:
		return false
	player.queue_free()
	await process_frame
	var closed := player == null or not is_instance_valid(player)
	var stage_empty := stage.get_child_count() == 0
	player = JXVfxPlayer.new()
	root.add_child(player)
	player.set_catalog(catalog)
	var reopened := player.get_texture(IDS[2]) != null
	return closed and stage_empty and reopened

func _test_page_boundaries_and_alpha() -> bool:
	var dmon_texture := player.get_texture(IDS[0])
	var thuy_texture := player.get_texture(IDS[1])
	if dmon_texture == null or thuy_texture == null:
		return false
	var dmon_image := dmon_texture.get_image()
	var thuy_image := thuy_texture.get_image()
	if dmon_image.is_empty() or thuy_image.is_empty():
		return false
	var dmon_has_alpha := _has_transparent_and_visible_pixels(dmon_image)
	var thuy_has_alpha := _has_transparent_and_visible_pixels(thuy_image) and int(thuy_image.get_width()) == 318 and int(thuy_image.get_height()) == 1136 and thuy_image.get_pixel(317, 1135).a == 0.0
	var regions: Array = catalog.get_record(IDS[0]).get("animation", {}).get("frame_regions", [])
	var rect6: Array = regions[6].get("rect", []) if regions.size() > 7 else []
	var rect7: Array = regions[7].get("rect", []) if regions.size() > 7 else []
	var page_boundary_ok: bool = regions.size() == 34 and regions[6].get("texture_path") != regions[7].get("texture_path") and rect6.size() == 4 and rect7.size() == 4 and int(rect6[0]) == 1728 and int(rect6[1]) == 0 and int(rect6[2]) == 288 and int(rect6[3]) == 450 and int(rect7[0]) == 0 and int(rect7[1]) == 0 and int(rect7[2]) == 288 and int(rect7[3]) == 450
	debug_info["alpha_and_pages"] = {"dmon_visible_and_transparent": dmon_has_alpha, "thuy_visible_and_transparent": thuy_has_alpha, "m38_frame_6_page": regions[6].get("texture_path"), "m38_frame_7_page": regions[7].get("texture_path")}
	return dmon_has_alpha and thuy_has_alpha and page_boundary_ok

func _test_transparent_padding_preserves_source() -> bool:
	var row := catalog.get_record(IDS[1])
	var source_path := "res://" + String(row.get("texture_path", ""))
	var source_texture := ResourceLoader.load(source_path) as Texture2D
	var padded_texture := player.get_texture(IDS[1])
	if source_texture == null or padded_texture == null:
		return false
	var source_image := source_texture.get_image()
	var padded_image := padded_texture.get_image()
	if source_image.get_width() != 317 or source_image.get_height() != 1133 or padded_image.get_width() != 318 or padded_image.get_height() != 1136:
		return false
	source_image.convert(Image.FORMAT_RGBA8)
	padded_image.convert(Image.FORMAT_RGBA8)
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			if source_image.get_pixel(x, y) != padded_image.get_pixel(x, y):
				return false
	return padded_image.get_pixel(317, 1135).a == 0.0

func _has_transparent_and_visible_pixels(image: Image) -> bool:
	image.convert(Image.FORMAT_RGBA8)
	var has_transparent := false
	var has_visible := false
	for y in range(0, image.get_height(), 8):
		for x in range(0, image.get_width(), 8):
			if image.get_pixel(x, y).a == 0.0:
				has_transparent = true
			else:
				has_visible = true
			if has_transparent and has_visible:
				return true
	return false

func _test_load_levels() -> bool:
	for count in [1, 3, 10, 30]:
		var handles: Array[int] = []
		var started := Time.get_ticks_usec()
		for index in range(count):
			var effect_id := IDS[index % IDS.size()]
			var handle := player.play(effect_id, stage, Vector2(80 + index * 24, 420), {"loop": true, "direction": index % 16, "scale": 0.15})
			if handle == 0:
				for existing_handle in handles:
					player.stop(existing_handle)
				return false
			handles.append(handle)
		await create_timer(0.25).timeout
		var active_count := player.active.size()
		performance_data["load_levels"].append({
			"requested_instances": count,
			"active_instances": active_count,
			"spawn_elapsed_ms": float(Time.get_ticks_usec() - started) / 1000.0,
			"godot_static_memory_bytes": OS.get_static_memory_usage(),
			"godot_static_memory_peak_bytes": OS.get_static_memory_peak_usage(),
			"texture_cache_entries": player.texture_cache.size(),
			"engine_reported_fps": Engine.get_frames_per_second(),
		})
		for handle in handles:
			player.stop(handle)
		await process_frame
		if active_count != count or player.active.size() != 0:
			return false
	performance_data["godot_static_memory_after_stop_bytes"] = OS.get_static_memory_usage()
	performance_data["cache_entries_after_release"] = player.texture_cache.size()
	return true

func _on_effect_failed(effect_id: String, reason: String) -> void:
	failure_events.append({"effect_id": effect_id, "reason": reason})

func _on_effect_finished(effect_id: String, handle: int) -> void:
	finished_handles[handle] = effect_id
