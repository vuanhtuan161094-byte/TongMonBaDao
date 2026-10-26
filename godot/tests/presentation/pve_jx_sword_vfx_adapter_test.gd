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

func _monsters() -> Array:
	var monster: Dictionary = MonsterCatalogueV2.create_actor("thanh_lang",1,1,"vfx_real_wolf")
	monster["id"] = "vfx_real_wolf"
	monster["position"] = Vector2(14.0,10.0)
	monster["stats"] = monster["stats"].duplicate(true)
	monster["stats"]["max_hp"] = 200000.0
	monster["stats"]["attack"] = 1.0
	monster["hp"] = 200000.0
	monster["max_hp"] = 200000.0
	return [monster]

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
	var battle := MapBattleV2.new(20261026)
	if not _check(bool(battle.setup("pve_jx_sword_vfx",_party(),_monsters()).get("ok",false)),
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
	var restored_result := MapBattleSnapshotV2.load(snapshot_before)
	if not _check(bool(restored_result.get("ok",false)),"Combat V2 save snapshot could not restore for visual reload test"):
		return
	var after_reload_adapter = VFX_ADAPTER_SCRIPT.new()
	after_reload_adapter.observe_snapshot(restored_result["battle"])
	if not _check(after_reload_adapter.active_count() == 0,
		"loading old Combat V2 events replayed a JX attack or impact"):
		return
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
	print("PVE JX SWORD VFX ADAPTER PASS real_combat=ngu_kiem_thuat cast=true projectile=true positive_hit=true one_impact=true no_hit_explosion=false snapshot_unchanged=true save_load_no_replay=true forest_palette=verified")
	quit(0)
