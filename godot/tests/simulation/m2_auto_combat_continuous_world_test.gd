extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _assert(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
		quit(1)
		return false
	return true

func _party(skill_policy: Dictionary = {}) -> Array:
	var stats: Dictionary = CombatStatsV2.derive(1, 1, 1, 1, 0.0)["stats"]
	return [{
		"id":"m2_hunter", "party_id":"m2_party", "role":"ranged",
		"position":Vector2(8.0, 8.0), "stats":stats, "hp":float(stats["max_hp"]),
		"skill_loadout":["ngu_kiem_thuat"] if not skill_policy.is_empty() else [],
		"skill_factors":{"ngu_kiem_thuat":1.0} if not skill_policy.is_empty() else {},
		"auto_skill_policy":skill_policy
	}]

func _monsters() -> Array:
	var monster := MonsterCatalogueV2.create_actor("truc_thu", 1, 1, "m2_world_mob")
	monster["id"] = "m2_mob"
	monster["position"] = Vector2(12.0, 8.0)
	return [monster]

func _policy(enabled: bool = true, target_tiers: Array = ["normal", "elite", "boss"]) -> Dictionary:
	return {
		"schema":AutoSkillPolicyV2.SCHEMA,
		"basic_fallback":true,
		"skills":[{
			"canonical_skill_id":"ngu_kiem_thuat", "enabled":enabled, "priority":0,
			"conditions":{
				"actor_hp_at_or_below":1.0, "target_hp_at_or_below":1.0,
				"min_range":0.0, "max_range":7.0,
				"target_tiers":target_tiers, "minimum_enemies_near_target":1
			}
		}]
	}

func _run() -> void:
	var json_policy: Variant = JSON.parse_string(JSON.stringify(_policy()))
	var normalized_policy := AutoSkillPolicyV2.normalize(json_policy, ["ngu_kiem_thuat"])
	if not _assert(bool(normalized_policy.get("ok", false)),
		"JSON-persisted integer priorities/nearby conditions failed canonical policy validation."):
		return
	var skill_battle := MapBattleV2.new(20261020)
	if not _assert(bool(skill_battle.setup("m2_policy", _party(_policy()), _monsters()).get("ok", false)),
		"A valid learned/equipped V2 damage skill policy was rejected."):
		return
	skill_battle.step()
	var emitted_skill := false
	for event in skill_battle.events:
		if str(event.get("type", "")) == "skill_cast" and str(event.get("skill_id", "")) == "ngu_kiem_thuat":
			emitted_skill = true
	if not _assert(emitted_skill, "Enabled learned V2 skill did not produce its real cast event."):
		return
	var blocked := MapBattleV2.new(20261020)
	var unowned_policy := _policy()
	unowned_policy["skills"][0]["canonical_skill_id"] = "hoa_cau"
	if not _assert(not bool(blocked.setup("m2_unowned", _party(unowned_policy), _monsters()).get("ok", false)),
		"An auto policy for a skill absent from the learned/equipped loadout was accepted."):
		return
	var target_filtered := MapBattleV2.new(20261020)
	if not _assert(bool(target_filtered.setup("m2_target_filter", _party(_policy(true, ["boss"])), _monsters()).get("ok", false)),
		"A valid target-tier condition was rejected."):
		return
	target_filtered.step()
	for event in target_filtered.events:
		if not _assert(str(event.get("type", "")) != "skill_cast",
			"Skill condition ignored its Boss-only target filter."):
			return

	var world := MapBattleV2.new(20261021)
	if not _assert(bool(world.setup("m2_continuous", _party(), _monsters(), {"continuous_world":true}).get("ok", false)),
		"Continuous V2 hunting region failed to start."):
		return
	for actor in world.actors.values():
		actor["next_basic"] = 10000.0
		actor["next_skill"] = 10000.0
	for _tick in range(400):
		world.step(true)
	if not _assert(world.active and world.now >= 100.0 and world.outcome == "fighting",
		"Continuous world incorrectly stopped at the old 90-second encounter limit."):
		return
	for actor in world.actors.values():
		if str(actor.get("side", "")) == "monster":
			actor["hp"] = 0.0
	world.step(true)
	if not _assert(world.world_waves_completed == 1 and world.active,
		"Clearing the authored monster group did not preserve the continuous session."):
		return
	for _tick in range(12):
		world.step(true)
	if not _assert(world._count_alive("monster") == 1 and world.active,
		"The same authored monster group did not return after its short respawn delay."):
		return
	var checkpoint := MapBattleSnapshotV2.save(world)
	var restored := MapBattleSnapshotV2.load(JSON.parse_string(JSON.stringify(checkpoint)))
	if not _assert(bool(restored.get("ok", false)), "Continuous world checkpoint did not restore: " + str(restored.get("reason", "unknown"))):
		return
	var resumed: MapBattleV2 = restored["battle"]
	if not _assert(resumed.continuous_world and resumed.world_waves_completed == 1 and resumed.now > MapBattleV2.MAX_SECONDS,
		"Continuous-world flags, wave count or elapsed time were lost in save/resume."):
		return
	var returned := resumed.request_return()
	if not _assert(bool(returned.get("ok", false)) and returned.get("outcome") == "win" and not resumed.active,
		"Manual return after a cleared wave did not produce one terminal victory."):
		return
	print("M2 AUTO-SKILL + CONTINUOUS ROAMING V2: PASS")
	quit(0)
