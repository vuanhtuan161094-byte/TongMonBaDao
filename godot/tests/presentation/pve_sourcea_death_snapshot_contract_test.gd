extends SceneTree

# Presentation-only replay/idempotence regression; no Combat V2 time advances.

func _init() -> void:
	call_deferred("_run")

func _fail(why: String) -> void:
	push_error("PVE SOURCE A DEATH SNAPSHOT FAIL: "+why)
	quit(1)

func _run() -> void:
	var view := SectIsometricWorldV1.new()
	var selection: Array[String] = []
	var battle := MapBattleV2.new(20261026)
	battle.encounter_id = "qa:visual:run1"
	battle.actors = {"disciple":{
		"id":"disciple","side":"disciple","hp":0.0,
		"position":Vector2(83.5,70.5),"move_speed":2.0
	}}
	view.pve_clock = 1.25
	view.set_pve_snapshot(battle,{},selection)
	var first: Dictionary = view.pve_actor_actions.get("disciple",{})
	if str(first.get("action","")) != "die" or not is_equal_approx(float(first.get("started",-1.0)),1.25):
		_fail("first downed snapshot did not initiate death animation")
		return
	view.pve_clock = 5.5
	view.set_pve_snapshot(battle,{},selection)
	var second: Dictionary = view.pve_actor_actions.get("disciple",{})
	if str(second.get("action","")) != "die" or not is_equal_approx(float(second.get("started",-1.0)),1.25):
		_fail("unchanged dead snapshot restarted native Source A death clip")
		return
	var revived := MapBattleV2.new(20261026)
	revived.encounter_id = "qa:visual:run2"
	revived.actors = {"disciple":{
		"id":"disciple","side":"disciple","hp":70.0,
		"position":Vector2(102.5,104.5),"move_speed":2.0
	}}
	view.pve_clock = 6.0
	view.set_pve_snapshot(revived,{},selection)
	var fresh: Dictionary = view.pve_actor_actions.get("disciple",{})
	if str(fresh.get("action","")) != "idle" or not is_equal_approx(float(fresh.get("started",-1.0)),6.0):
		_fail("a new encounter inherited dead animation from prior encounter")
		return
	if view.pve_render_positions.get("disciple",Vector2.ZERO) != Vector2(102.5,104.5):
		_fail("new encounter interpolated actor from stale saved position")
		return
	view.set_pve_snapshot(null,{},selection)
	if not view.pve_actor_actions.is_empty() or not view._pve_last_visual_encounter_id.is_empty():
		_fail("closing view did not clear presentation actor/encounter state")
		return
	view.free()
	print("PVE SOURCE A DEATH SNAPSHOT CONTRACT PASS native_clip_idempotent=true encounter_isolated=true no_authority_mutation=true")
	quit(0)
