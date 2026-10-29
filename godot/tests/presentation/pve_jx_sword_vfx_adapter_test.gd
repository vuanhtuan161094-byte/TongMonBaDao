extends SceneTree

const VFX_ADAPTER_SCRIPT := preload("res://src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd")

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool,message: String) -> bool:
	if condition:
		return true
	push_error("PVE JX SWORD VFX FAIL: "+message)
	quit(1)
	return false

func _party() -> Array:
	var stats: Dictionary = CombatStatsV2.derive(3,1,3,1,0.0)["stats"].duplicate(true)
	stats["max_hp"] = 2000.0
	stats["attack"] = 90.0
	return [{
		"id":"vfx_real_swordsman","party_id":"vfx_party","role":"frontline",
		"position":Vector2(10.0,10.0),"stats":stats,"hp":2000.0,
		"skill_loadout":["ngu_kiem_thuat"],"skill_factors":{"ngu_kiem_thuat":1.0}
	}]

func _run() -> void:
	var atlas := CombatV4EffectAtlas.new()
	for item in [
		{"id":"jx_wudang_158_precast","frames":10},
		{"id":"jx_wudang_158_cast","frames":17},
		{"id":"jx_wudang_158_impact","frames":8}
	]:
		var frame := atlas.frame_region(str(item["id"]),0.0)
		if not _check(not frame.is_empty() and frame.get("texture") != null,
			"verified JX #158 frame could not be loaded from Godot import: %s" % str(item["id"])):
			return
		if not _check(int(atlas.effects[item["id"]]["frames"]) == int(item["frames"]),
			"manifest frame count changed for %s" % str(item["id"])):
			return
	var forest := SectIsometricWorldV1.pve_forest_layout()
	var forbidden := ["570144","570397","570399"]
	for row in forest:
		if not _check(not forbidden.has(str(row.get("id",""))),
			"statue/flowerpot/lantern is misclassified as generic PvE forest art"):
			return
	var region_id := "thanh_truc_lam"
	var encounter_id := "pve_aux03_jx_sword_vfx"
	var encounter_seed := 20261026
	var spawn := HuntingMapV2.spawn(region_id,1,encounter_id,encounter_seed)
	if not _check(bool(spawn.get("ok",false)),"real PvE map fixture failed to spawn"):
		return
	var battle := MapBattleV2.new(encounter_seed)
	if not _check(bool(battle.setup(encounter_id,_party(),spawn["monsters"]).get("ok",false)),
		"real Combat V2 sword-vs-monster fixture failed setup"):
		return
	var adapter = VFX_ADAPTER_SCRIPT.new()
	adapter.comparison_style = "jx1" # Verify the full JX option independently of the selected hybrid.
	adapter.observe_snapshot(battle) # set cursor before live Combat V2 starts
	var saw_cast := false
	var saw_projectile := false
	var saw_positive_hit := false
	var original_damage := -1.0
	for _step in range(16):
		var result := battle.step(false)
		if not _check(bool(result.get("ok",false)),"Combat V2 fixture failed to advance"):
			return
		var new_events := adapter.observe_snapshot(battle)
		for event in new_events:
			if str(event.get("type","")) == "skill_cast" and str(event.get("skill_id","")) == "ngu_kiem_thuat":
				saw_cast = true
				if not _check(not adapter.render_cues().is_empty()
					and str(adapter.render_cues()[0].get("phase","")) == "precast",
					"actual Combat V2 cast did not start the JX precast cue"):
					return
			if str(event.get("type","")) == "hit" and str(event.get("kind","")) == "learned_skill":
				saw_positive_hit = float(event.get("damage",0.0)) > 0.0
				if saw_positive_hit:
					original_damage = float(event["damage"])
		adapter.advance(0.25)
		for cue in adapter.render_cues():
			if str(cue.get("phase","")) in ["flight","await_hit"]:
				saw_projectile = true
		if saw_positive_hit:
			break
	if not _check(saw_cast and saw_projectile and saw_positive_hit,
		"live Combat V2 did not produce cast → travelling JX sword → positive hit; cast=%s projectile=%s positive_hit=%s" % [str(saw_cast),str(saw_projectile),str(saw_positive_hit)]):
		return
	if not _check(int(adapter.counters["positive_hits"]) == 1 and int(adapter.counters["impacts"]) == 1,
		"one actual positive Combat V2 hit must produce exactly one impact cue"):
		return
	var impact_visible := false
	for cue in adapter.render_cues():
		if str(cue.get("phase","")) == "impact" and str(cue.get("effect","")) == "jx_wudang_158_impact":
			impact_visible = true
	if not _check(impact_visible,"positive hit did not end at the target impact cue"):
		return
	var snapshot_before := MapBattleSnapshotV2.save(battle)
	var hit_count_before := int(adapter.counters["positive_hits"])
	var impact_count_before := int(adapter.counters["impacts"])
	adapter.observe_snapshot(battle)
	adapter.observe_snapshot(battle)
	adapter.advance(0.12)
	if not _check(MapBattleSnapshotV2.save(battle) == snapshot_before,
		"VFX observation/animation mutated the authoritative Combat V2 snapshot"):
		return
	if not _check(int(adapter.counters["positive_hits"]) == hit_count_before
		and int(adapter.counters["impacts"]) == impact_count_before,
		"repeated snapshot observation duplicated the hit or its impact"):
		return
	# Persist the same active Combat V2 encounter through the canonical game save.
	# The roster and spawn envelope satisfy HuntingPveRunV2's production restore checks.
	var save_state := SimulationState.new()
	save_state.sect.p3_7_resources_enabled = true
	save_state.sect.v2_pve_enabled = true
	save_state.sect.v2_pve_selected_levels[region_id] = 1
	var region := RegionState.new({"id":region_id,"name":"Thanh Trúc Lâm"})
	save_state.regions[region.id] = region
	var disciple := DiscipleState.new()
	disciple.id = &"vfx_real_swordsman"
	disciple.display_name = "VFX QA Swordsman"
	disciple.max_hp = 2000.0
	disciple.hp = 2000.0
	disciple.region_id = &"sect"
	disciple.current_action = &"EVALUATE"
	save_state.disciples[disciple.id] = disciple
	var active_run := {
		"ok":true,"version":1,"region_id":region_id,"difficulty":1,
		"encounter_id":encounter_id,"reward_seed":encounter_seed,
		"battle":snapshot_before
	}
	save_state.sect.v2_pve_active_runs[encounter_id] = active_run
	var save_path := "user://pve_aux03_vfx_save_reload.json"
	var save_service := SaveService.new()
	var save_error: Error = save_service.save_to_path(save_state,save_path)
	if not _check(save_error == OK,
		"canonical SaveService could not persist the active Combat V2 VFX fixture; error=%d path=%s" % [save_error,ProjectSettings.globalize_path(save_path)]):
		return
	var loaded_state := save_service.load_from_path(save_path)
	if not _check(loaded_state != null,"canonical SaveService could not reload the active Combat V2 fixture"):
		return
	var restored_result := HuntingPveRunV2.resume_active(loaded_state,encounter_id)
	if not _check(bool(restored_result.get("ok",false)),
		"saved active Combat V2 run failed its production restore path: %s" % str(restored_result.get("reason","unknown"))):
		return
	var after_reload_adapter = VFX_ADAPTER_SCRIPT.new()
	after_reload_adapter.observe_snapshot(restored_result["session"].battle)
	if not _check(after_reload_adapter.active_count() == 0,
		"canonical Save/Reload replayed a historical Combat V2 cast, projectile or impact"):
		return
	if not _check(int(after_reload_adapter.counters["casts"]) == 0
		and int(after_reload_adapter.counters["impacts"]) == 0,
		"canonical Save/Reload counted historical Combat V2 events as new VFX"):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path + ".bak"))
	var miss_adapter = VFX_ADAPTER_SCRIPT.new()
	var miss_battle := MapBattleV2.new()
	miss_battle.encounter_id = "pve_jx_vfx_no_hit"
	miss_battle.actors = {
		"disciple":{"id":"disciple","side":"disciple","position":Vector2(1.0,1.0)},
		"monster":{"id":"monster","side":"monster","position":Vector2(3.0,1.0)}
	}
	miss_adapter.observe_snapshot(miss_battle)
	miss_battle.events.append({"type":"skill_cast","time":0.0,"encounter_id":miss_battle.encounter_id,
		"actor_id":"disciple","target":"monster","skill_id":"ngu_kiem_thuat","release_at":0.8})
	miss_adapter.observe_snapshot(miss_battle)
	miss_adapter.advance(2.0)
	if not _check(int(miss_adapter.counters["impacts"]) == 0
		and int(miss_adapter.counters["expired_without_hit"]) == 1,
		"a cast without a positive Combat V2 learned_skill hit must fade without an explosion"):
		return
	# A same-encounter save reload may replace the bounded VFX ring with
	# disjoint historical rows. Zero matching events is NOT continuity.
	var replay_adapter = VFX_ADAPTER_SCRIPT.new()
	var replay_battle := MapBattleV2.new(5501)
	replay_battle.encounter_id = "same_encounter_saved_reload"
	replay_battle.actors = {
		"disciple":{"id":"disciple","side":"disciple","position":Vector2(1.0,1.0)},
		"monster":{"id":"monster","side":"monster","position":Vector2(4.0,1.0)}
	}
	replay_battle.events = [
		{"type":"skill_cast","time":1.0,"actor_id":"disciple",
			"target":"monster","skill_id":"ngu_kiem_thuat","release_at":1.8}
	]
	replay_adapter.observe_snapshot(replay_battle)
	replay_battle.events = [
		{"type":"skill_cast","time":30.0,"actor_id":"disciple",
			"target":"monster","skill_id":"ngu_kiem_thuat","release_at":30.8}
	]
	var replaced := replay_adapter.observe_snapshot(replay_battle)
	if not _check(replaced.is_empty() and replay_adapter.active_count() == 0
			and int(replay_adapter.counters["casts"]) == 0,
			"disjoint saved event ring replayed historical JX #158 casts"):
		return
	replay_battle.events.append({
		"type":"skill_cast","time":31.0,"actor_id":"disciple",
		"target":"monster","skill_id":"ngu_kiem_thuat","release_at":31.8
	})
	var fresh_after_restore := replay_adapter.observe_snapshot(replay_battle)
	if not _check(fresh_after_restore.size() == 1
			and int(replay_adapter.counters["casts"]) == 1
			and replay_adapter.active_count() == 1,
			"disjoint-ring rebaseline dropped the next genuine live cast"):
		return
	var ring_adapter = VFX_ADAPTER_SCRIPT.new()
	var ring_battle := MapBattleV2.new(5502)
	ring_battle.encounter_id = "rolling_event_ring"
	ring_battle.actors = replay_battle.actors.duplicate(true)
	for index in range(MapBattleV2.MAX_EVENTS):
		ring_battle.events.append({"type":"other","time":float(index),"ordinal":index})
	ring_adapter.observe_snapshot(ring_battle)
	var old_scan_count: int = ring_adapter.event_rows_examined_total
	ring_battle.events.pop_front()
	ring_battle.events.append({"type":"skill_cast","time":3000.0,
		"actor_id":"disciple","target":"monster","skill_id":"ngu_kiem_thuat","release_at":3000.8})
	var rolling_events := ring_adapter.observe_snapshot(ring_battle)
	if not _check(rolling_events.size() == 1 and ring_adapter.active_count() == 1
			and ring_adapter.event_rows_examined_total == old_scan_count+1,
			"rolling ring must inspect only the newly appended event and preserve a genuine JX cast"):
		return
	ring_adapter.observe_snapshot(ring_battle)
	if not _check(int(ring_adapter.counters["duplicate_snapshots"]) > 0,
		"same rolling event-ring snapshot was not recognized as duplicate"):
		return
	print("PVE JX SWORD VFX ADAPTER PASS real_combat=ngu_kiem_thuat cast=true projectile=true positive_hit=true one_impact=true no_hit_explosion=false snapshot_unchanged=true canonical_save_service_reload_no_replay=true rolling_ring_new_events_only=true forest_palette=verified")
	quit(0)
