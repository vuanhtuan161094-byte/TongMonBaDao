extends SceneTree

const MAIN_SCENE := "res://scenes/p3/p3_2_landscape_sect.tscn"
const QA_SEED_SAVE := "res://outputs/endgame_qa_20261026/gameplay/roster_130/endgame_capture_save_1792953798.json"
const PROBE_SCRIPT := preload("res://tools/qa/pve_playable_perf_probe.gd")
const CAPTURE_DURATION_SEC := 20.0

var game: Control
var probe: Node

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("V63_D8_PERF_RUNTIME_FAIL: "+message)
	await _shutdown()
	quit(1)

func _shutdown() -> void:
	if game != null and is_instance_valid(game):
		for property in ["runtime_poll_timer","autosave_timer"]:
			var timer := game.get(property) as Timer
			if timer != null:
				timer.stop()
		game.set("runtime_ready",false)
	if probe != null and is_instance_valid(probe):
		probe.queue_free()
		probe = null
	if game != null and is_instance_valid(game):
		var runtime := game.get("runtime_session") as LiveGameRuntimeV2
		if runtime != null:
			var save_result: Dictionary = await runtime.wait_for_pending_save(self)
			if not bool(save_result.get("ok",false)):
				push_error("V63_D8_PERF_RUNTIME: pending SaveService worker did not finish: "+str(save_result))
		game.queue_free()
		game = null
	await process_frame
	await process_frame

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		await _fail("requires a normal Godot GUI window")
		return
	var output_dir := OS.get_environment("TMB_D8_PERF_OUTPUT_DIR")
	if output_dir.is_empty():
		await _fail("missing isolated TMB_D8_PERF_OUTPUT_DIR")
		return
	var source_sha := OS.get_environment("TMB_SOURCE_SHA")
	var logger_enabled := OS.get_environment("TMB_PVE_PERF_LOG") == "1"
	var run_id := "%d_%d" % [int(Time.get_unix_time_from_system()),Time.get_ticks_usec()]
	var metrics_path := output_dir.path_join("metrics.jsonl")
	var screenshot_path := output_dir.path_join("p3_2_pve_1280x720.png")
	var save_path := output_dir.path_join("active_save.json")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if FileAccess.file_exists(metrics_path) or FileAccess.file_exists(save_path):
		await _fail("refusing to overwrite existing QA output")
		return
	var seed_state := SaveService.new().load_from_path(QA_SEED_SAVE)
	if seed_state == null or seed_state.disciples.size() != 130:
		await _fail("canonical 130-disciple SaveService QA seed did not validate")
		return
	seed_state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
	seed_state.runtime_unconsumed_wall_seconds = 0.0
	if SaveService.new().save_to_path(seed_state,save_path) != OK \
			or SaveService.new().load_from_path(save_path) == null:
		await _fail("could not create/reload an isolated SaveService QA copy")
		return
	ProjectSettings.set_setting("runtime/live_save_path",save_path)
	DisplayServer.window_set_size(Vector2i(1280,720))
	root.size = Vector2i(1280,720)
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		await _fail("production P3.2 scene failed to load")
		return
	game = packed.instantiate() as Control
	root.add_child(game)
	await process_frame
	await process_frame
	if not bool(game.get("runtime_ready")):
		await _fail("production P3.2 LiveGameRuntimeV2 did not start")
		return
	var state := game.get("state") as SimulationState
	if state == null or state.disciples.size() != 130:
		await _fail("P3.2 did not restore the 130-disciple QA roster")
		return
	var runtime_poll_timer := game.get("runtime_poll_timer") as Timer
	var autosave_timer := game.get("autosave_timer") as Timer
	if runtime_poll_timer == null:
		await _fail("P3.2 runtime poll timer is missing")
		return
	runtime_poll_timer.stop()
	if autosave_timer != null:
		autosave_timer.stop()

	var selected_id := StringName()
	var strongest_rating := -INF
	for raw_id in state.disciples.keys():
		var member: DiscipleState = state.disciples[StringName(raw_id)]
		if not DiscipleRealmProgressV2.progression_ready(member) \
				or not bool(game.call("_multicamp_member_eligible",member)):
			continue
		var rating := float(game.call("_multicamp_combat_rating",member))
		if rating > strongest_rating:
			strongest_rating = rating
			selected_id = member.id
	if selected_id.is_empty():
		await _fail("no real eligible V2 disciple exists in the QA roster")
		return
	var party: Array = game.call("_multicamp_party_for_selected",selected_id)
	if party.size() != 6:
		await _fail("production party picker did not return six canonical disciples")
		return
	game.call("_open_disciple",selected_id)
	var entry := game.get_node_or_null("PlayerBottomBar/PveHuntQuickEntry") as Button
	if entry == null or not entry.visible or entry.disabled:
		await _fail("production P3.2 Săn quái entry is unavailable")
		return
	entry.emit_signal("pressed")
	await process_frame
	var start := game.get_node_or_null("PvePartyPickerShade/PvePartyPicker/PvePartyPickerStart") as Button
	if start == null or not start.visible or start.disabled \
			or game.get("pve_party_selected_ids").size() != 6:
		await _fail("production six-member PvE picker is not ready")
		return
	start.emit_signal("pressed")
	await process_frame
	await process_frame
	var warmup_start := Time.get_ticks_msec()
	while float(Time.get_ticks_msec()-warmup_start)/1000.0 < 5.0:
		await process_frame
	var encounter := HuntingPveRunV2.active_multicamp_id(state)
	var restored := HuntingPveRunV2.resume_active(state,encounter) if not encounter.is_empty() else {"ok":false}
	if not bool(restored.get("ok",false)):
		await _fail("P3.2 did not enter a canonical continuous Combat V2 encounter")
		return
	var session: HuntingPveRunV2 = restored["session"]
	if session.battle._count_alive("disciple") != 6 \
			or session.battle._count_alive("monster") < 1:
		await _fail("live Combat V2 did not contain the six-member party and monsters")
		return
	var actions_before := session.battle.actions
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null or image.get_size() != Vector2i(1280,720) \
			or image.save_png(screenshot_path) != OK:
		await _fail("could not capture the actual P3.2 GUI viewport")
		return
	probe = PROBE_SCRIPT.new()
	probe.configure(game,metrics_path,run_id,logger_enabled)
	root.add_child(probe)
	state.runtime_last_wall_unix = int(Time.get_unix_time_from_system())
	state.runtime_unconsumed_wall_seconds = 0.0
	if autosave_timer != null:
		autosave_timer.start()
	runtime_poll_timer.start()
	print("V63_D8_PERF_RUNTIME_GUI_READY source_sha=%s engine=%s renderer=%s logger=%s run=%s roster=%d party=%d encounter=%s actions_before=%d screenshot=%s screenshot_sha256=%s metrics=%s" % [
		source_sha,Engine.get_version_info().get("string","unknown"),
		RenderingServer.get_video_adapter_name(),str(logger_enabled),run_id,
		state.disciples.size(),session.battle._count_alive("disciple"),encounter,
		actions_before,screenshot_path,FileAccess.get_sha256(screenshot_path),metrics_path])
	var started_msec := Time.get_ticks_msec()
	while float(Time.get_ticks_msec()-started_msec)/1000.0 < CAPTURE_DURATION_SEC:
		await process_frame
	runtime_poll_timer.stop()
	if autosave_timer != null:
		autosave_timer.stop()
	if probe != null and is_instance_valid(probe):
		probe.queue_free()
		probe = null
	await process_frame
	var after := HuntingPveRunV2.resume_active(state,encounter)
	if not bool(after.get("ok",false)):
		await _fail("the canonical encounter did not remain resumable for the runtime sample")
		return
	session = after["session"]
	var actions_after := session.battle.actions
	if actions_after <= actions_before:
		await _fail("Combat V2 did not advance actions during the 20-second GUI sample")
		return

	var pve_samples := 0
	var total_frames := 0
	var pve_summary: Dictionary = {}
	var logger_recorded := false
	var metrics := FileAccess.open(metrics_path,FileAccess.READ)
	if metrics == null:
		await _fail("passive probe metrics file is missing")
		return
	for line in metrics.get_as_text().split("\n",false):
		var parsed: Variant = JSON.parse_string(line)
		if not parsed is Dictionary:
			continue
		var row: Dictionary = parsed
		if str(row.get("kind","")) == "start":
			logger_recorded = bool(row.get("logger_enabled",false)) == logger_enabled
		elif str(row.get("kind","")) == "sample" and str(row.get("phase","")) == "pve":
			pve_samples += 1
			total_frames += int(row.get("frame_count",0))
		elif str(row.get("kind","")) == "phase_summary" and str(row.get("phase","")) == "pve":
			pve_summary = row
	if pve_samples == 0 or total_frames == 0 or pve_summary.is_empty() \
			or not logger_recorded:
		await _fail("probe did not record PVE phase metrics; samples=%d frames=%d summary=%s logger=%s" % [
			pve_samples,total_frames,str(not pve_summary.is_empty()),str(logger_recorded)])
		return
	var metrics_sha := FileAccess.get_sha256(metrics_path)
	print("V63_D8_PERF_RUNTIME_PASS source_sha=%s logger=%s duration_s=%.1f pve_samples=%d pve_frames=%d pve_frame_ms_p50=%.2f pve_frame_ms_p95=%.2f pve_frame_ms_p99=%.2f pve_frame_ms_max=%.2f pve_fps_1pct_low=%.2f process_ms_p95=%.2f process_ms_max=%.2f physics_ms_p95=%.2f physics_ms_max=%.2f static_memory_peak_mb=%.1f video_memory_peak_mb=%.1f actions=%d->%d metrics_sha256=%s" % [
		source_sha,str(logger_enabled),CAPTURE_DURATION_SEC,pve_samples,total_frames,
		float(pve_summary.get("frame_ms_p50",0.0)),float(pve_summary.get("frame_ms_p95",0.0)),
		float(pve_summary.get("frame_ms_p99",0.0)),float(pve_summary.get("frame_ms_max",0.0)),
		float(pve_summary.get("fps_1pct_low",0.0)),
		float(pve_summary.get("godot_process_ms_p95",0.0)),float(pve_summary.get("godot_process_ms_max",0.0)),
		float(pve_summary.get("godot_physics_ms_p95",0.0)),float(pve_summary.get("godot_physics_ms_max",0.0)),
		float(pve_summary.get("static_memory_peak_mb",0.0)),float(pve_summary.get("video_memory_peak_mb",0.0)),
		actions_before,actions_after,metrics_sha])
	await _shutdown()
	quit(0)
