extends SceneTree

# PVE PERF-01: presentation-only cache and Combat V2 cue regression checks.
# Run with official Godot 4.7.2:
# godot --headless --path godot --script res://tests/presentation/pve_static_world_cache_contract_test.gd
# No production save, clock, Combat V2 formula or loot data is modified.

var view: PveSectWorldViewV1

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	view = PveSectWorldViewV1.new()
	view.size = Vector2(700.0,484.0)
	root.add_child(view)
	await process_frame
	if not _check(view.world != null and not view.world.pve_navigation.is_empty(),
			"Source A navigation did not initialize"):
		return
	var initial_minimap: Texture2D = view.world.pve_mini_texture
	var first: Dictionary = view.prepare_world()
	if not _check(bool(first.get("ok",false)) and view.topology_build_count == 1
			and str(first.get("source_map","")) == "sect_isometric_source_a_pve_v1",
			"first topology build/hash failed"):
		return
	var initial_sha := str(first["topology"]["source_blob_sha"])
	var initial_topology: Dictionary = view.topology
	for _index in range(80):
		var again := view.prepare_world()
		if not _check(bool(again.get("ok",false)) and view.topology_build_count == 1
				and str(again["topology"]["source_blob_sha"]) == initial_sha
				and view.world.pve_mini_texture == initial_minimap,
				"static world was rebuilt during an unchanged HUD refresh"):
			return
	if not _check(view.get_open_world_options().get("auto_hunt",false)
			and view.topology_build_count == 1 and view.topology == initial_topology,
			"one-time open-world options unexpectedly invalidated topology"):
		return

	# Changing the source revision must invalidate only the display cache;
	# the test then restores the original immutable geometry before cleanup.
	var original_nav := view.world.pve_navigation.duplicate(true)
	var revised_nav := original_nav.duplicate(true)
	revised_nav["source_blob_sha"] = initial_sha+"|cache-probe"
	view.world.pve_navigation = revised_nav
	var revised := view.prepare_world()
	if not _check(bool(revised.get("ok",false))
			and view.topology_build_count == 2
			and str(revised["topology"]["source_blob_sha"]) == initial_sha+"|cache-probe",
			"changing navigation SHA did not invalidate topology"):
		return
	view.world.pve_navigation = original_nav
	var restored := view.prepare_world()
	if not _check(bool(restored.get("ok",false))
			and view.topology_build_count == 3
			and str(restored["topology"]["source_blob_sha"]) == initial_sha,
			"restored source SHA was not rebuilt correctly"):
		return

	# Source A atlas clip metadata must be memoized, not rebuilt on every
	# SpriteFrames draw. Verify native action-duration and frame lookup agree.
	var atlas := CombatV5SourceAAtlas.new()
	if not _check(atlas.has_actor("disciple_male"),
			"required Source A disciple art is absent from test assets"):
		return
	var clip_seconds := atlas.action_duration("disciple_male","attack")
	if not _check(clip_seconds > 0.0 and atlas._clip_timing_cache.size() == 1,
			"Source A native combat clip timing did not memoize"):
		return
	var attack_first := atlas.frame_region("disciple_male","attack",Vector2.RIGHT,0.0)
	if not _check(not attack_first.is_empty(),
			"Source A combat clip cannot be sampled"):
		return
	var clip_cache_size := atlas._clip_timing_cache.size()
	for _sample in range(50):
		var attack_again := atlas.frame_region("disciple_male","attack",
			Vector2.RIGHT,clip_seconds*0.5)
		if not _check(not attack_again.is_empty()
				and atlas._clip_timing_cache.size() == clip_cache_size,
				"repeated Source A frame sampling re-created clip metadata"):
			return
	var during := SectIsometricWorldV1._display_action_for_elapsed(
		"attack",clip_seconds*0.5,clip_seconds,true)
	var after := SectIsometricWorldV1._display_action_for_elapsed(
		"attack",clip_seconds+0.01,clip_seconds,true)
	var hit_after := SectIsometricWorldV1._display_action_for_elapsed(
		"hit",clip_seconds+0.01,clip_seconds,true)
	var dead := SectIsometricWorldV1._display_action_for_elapsed(
		"die",clip_seconds+0.01,clip_seconds,false)
	if not _check(str(during["action"]) == "attack"
			and str(after["action"]) == "idle"
			and str(hit_after["action"]) == "idle"
			and str(dead["action"]) == "die",
			"one-shot attack/hit does not return to idle or death loses final frame"):
		return

	# The latest event wins, including target hit and source-first precedence.
	var event_rows := [
		{"type":"hit","attacker":"m1","target":"d1","time":1.0},
		{"type":"skill_cast","caster":"m1","target":"d1","time":2.0}
	]
	var latest := SectIsometricWorldV1._latest_pve_visual_actions(event_rows)
	if not _check(str(latest.get("d1",{}).get("action","")) == "hit"
			and str(latest.get("m1",{}).get("action","")) == "attack",
			"single-pass action lookup changed target/source event priority"):
		return

	# Repeated snapshots must not restart the same Source A cast animation.
	var battle := MapBattleV2.new()
	battle.encounter_id = "qa:pve:cache:first"
	battle.actors = {
		"d1":{"id":"d1","side":"disciple","hp":100.0,"max_hp":100.0,
			"position":Vector2(95.5,72.5),"move_speed":2.0}
	}
	battle.events = [{"type":"skill_cast","caster":"d1","time":3.0}]
	view.world.pve_clock = 10.0
	view.world.set_pve_snapshot(battle,{},["d1"])
	var start := float(view.world.pve_actor_actions["d1"]["started"])
	view.world.pve_clock = 10.7
	view.world.set_pve_snapshot(battle,{},["d1"])
	if not _check(is_equal_approx(float(view.world.pve_actor_actions["d1"]["started"]),start),
			"unchanged event restarted actor cast on HUD refresh"):
		return
	# Once the MAX_EVENTS ring shifts, the same event still has the same
	# content hash and should not restart merely due to array index changes.
	battle.events.push_front({"type":"other","time":2.0})
	view.world.pve_clock = 11.0
	view.world.set_pve_snapshot(battle,{},["d1"])
	if not _check(is_equal_approx(float(view.world.pve_actor_actions["d1"]["started"]),start),
			"event ring index shifted and restarted an unchanged cast"):
		return
	battle.events.append({"type":"hit","attacker":"d1","target":"m1","time":4.0})
	view.world.pve_clock = 12.0
	view.world.set_pve_snapshot(battle,{},["d1"])
	if not _check(is_equal_approx(float(view.world.pve_actor_actions["d1"]["started"]),12.0),
			"a new positive-hit event did not start a new animation cue"):
		return

	# The same actor ID can be reused by a different encounter; old render
	# coordinates and event timestamps must never bleed across runs.
	var next_battle := MapBattleV2.new()
	next_battle.encounter_id = "qa:pve:cache:next"
	next_battle.actors = {
		"d1":{"id":"d1","side":"disciple","hp":100.0,"max_hp":100.0,
			"position":Vector2(101.5,82.5),"move_speed":2.0}
	}
	view.world.set_pve_snapshot(next_battle,{},["d1"])
	if not _check(view.world.pve_render_positions["d1"] == Vector2(101.5,82.5)
			and str(view.world.pve_actor_actions["d1"]["action"]) == "idle",
			"new encounter inherited old actor interpolation/events"):
		return
	print("PVE STATIC CACHE CONTRACT PASS (80 unchanged refreshes, revision invalidation, visual event index + cue timestamp)")
	view.queue_free()
	quit(0)

func _check(ok: bool, why: String) -> bool:
	if ok:
		return true
	push_error("PVE STATIC CACHE CONTRACT FAIL: "+why)
	if view != null:
		view.queue_free()
	quit(1)
	return false
