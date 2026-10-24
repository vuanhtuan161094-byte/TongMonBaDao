extends SceneTree

# Read-only integration check: Combat V3-S1 state is presented from the real
# MapBattleV2 actor/event stream without advancing simulation or changing save.
func _init() -> void:
	call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
	if not ok:
		push_error("PR28 S1 PRESENTER FAIL: " + reason)
		quit(1)
	return ok

func _player(skills: Array) -> Dictionary:
	var stats: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)["stats"].duplicate(true)
	stats["max_hp"] = 10000.0
	stats["attack"] = 100.0
	stats["defense"] = 200.0
	return {"id":"d0","party_id":"p0","role":"ranged",
		"position":Vector2(10,10),"stats":stats,"hp":10000.0,
		"basic_range":1.9,"basic_interval":1.1,
		"skill_loadout":skills,"skill_factors":{}}

func _monster() -> Dictionary:
	var monster := MonsterCatalogueV2.create_actor("thanh_lang",1,1,"pres_s1_m")
	monster["id"] = "m0"
	monster["position"] = Vector2(12,10)
	monster["stats"] = monster["stats"].duplicate(true)
	monster["stats"]["max_hp"] = 100000.0
	monster["stats"]["attack"] = 1.0
	monster["hp"] = 100000.0
	return monster

func _battle(skill_id: String, seed: int) -> MapBattleV2:
	var battle := MapBattleV2.new(seed)
	if not bool(battle.setup("pr28_s1_status",[_player([skill_id])],[_monster()]).get("ok",false)):
		return null
	return battle

func _has_status(actor: Dictionary, status_id: String) -> bool:
	return (actor.get("status_effects",{}) as Dictionary).has(status_id)

func _run() -> void:
	var presenter := B3CareCombatV5Presenter.new()
	presenter.enable_source_vl_art = true
	root.add_child(presenter)

	var battle := _battle("hoa_cau",71001)
	if not _check(battle != null,"could not build canonical S1 fire battle"): return
	presenter.attach_session(battle)
	var applied := false
	var dot_hit := false
	for _step in range(120):
		battle.step()
		presenter._ingest_authority_events()
		if _has_status(battle.actors["m0"],"burn"):
			applied = true
		if not presenter._combat_text.is_empty():
			for receipt in presenter._combat_text:
				if str(receipt.get("category","")) == "burn_tick":
					dot_hit = str(receipt.get("label","" )).begins_with("BỎNG ")
		if dot_hit:
			break
	if not _check(applied,"real MapBattleV2 never applied burn"): return
	if not _check(dot_hit,"canonical dot hit did not create a single burn receipt"): return
	var burn_actor: Dictionary = battle.actors["m0"]
	var burn_text := presenter.s1_combat_status_summary(burn_actor)
	if not _check(burn_text.begins_with("BỎNG ") and burn_text.contains("s"),
		"active burn duration was not shown from battle.now: " + burn_text): return
	if not _check(presenter.latest_s1_status_feedback().contains("Hỏa Cầu")
		and presenter.latest_s1_status_feedback().contains("BỎNG"),
		"actual status_applied event was not exposed in recent feedback"): return
	var burn_receipt_count := 0
	for receipt in presenter._combat_text:
		if str(receipt.get("category","")) == "burn_tick":
			burn_receipt_count += 1
	if not _check(burn_receipt_count == 1,"dot tick was duplicated in presentation receipts"): return
	var battle_before: Dictionary = MapBattleSnapshotV2.save(battle)
	presenter.active_combat_status_tags(burn_actor)
	presenter.s1_combat_status_summary(burn_actor)
	presenter.latest_s1_status_feedback()
	if not _check(MapBattleSnapshotV2.save(battle) == battle_before,
		"status presentation mutated the canonical battle snapshot"): return

	var weak_battle := _battle("han_suong_an",71002)
	if not _check(weak_battle != null,"could not build canonical S1 weaken battle"): return
	presenter.attach_session(weak_battle)
	var weaken_applied := false
	for _step in range(80):
		weak_battle.step()
		presenter._ingest_authority_events()
		if _has_status(weak_battle.actors["m0"],"weaken"):
			weaken_applied = true
			break
	if not _check(weaken_applied,"real MapBattleV2 never applied weaken"): return
	if not _check(presenter.s1_combat_status_summary(weak_battle.actors["m0"]).begins_with("SUY YẾU "),
		"active weaken duration was not presented from canonical status state"): return
	print("PR28_S1_STATUS_PRESENTER_PASS")
	quit(0)
