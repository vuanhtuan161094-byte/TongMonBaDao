extends SceneTree

const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const SKILL_ID := "tmb.skill.palm.han_ngoc_chuong.active_01.human"

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("PALM01_RECEIPT_TEST_FAIL " + message)

func _run() -> void:
	var battle := MapBattleV2.new(20261125)
	var caster := _actor("palm01_test_caster", "disciple", Vector2(0, 0))
	caster["role"] = "mage"
	caster["v63_combat_enabled"] = true
	caster["v63_palm_combat_enabled"] = true
	caster["v63_skill_loadout"] = [SKILL_ID]
	var made := MonsterCatalogueV2.create_actor("thanh_lang", 1, 1, "palm01_test_monster")
	_expect(bool(made.get("ok", false)), "a real MonsterCatalogueV2 actor is available")
	if not bool(made.get("ok", false)):
		_finish()
		return
	var monster: Dictionary = made
	monster["id"] = "palm01_test_monster"
	monster["position"] = Vector2(5.0, 0.0)
	var setup := battle.setup("palm01_han_ngoc_receipt_test", [caster], [monster])
	_expect(bool(setup.get("ok", false)), "MapBattleV2 accepts the isolated candidate caster and real monster")
	if not bool(setup.get("ok", false)):
		_finish()
		return
	caster = battle.actors["palm01_test_caster"]
	monster = battle.actors["palm01_test_monster"]
	_expect(HSC.skill_definition(SKILL_ID).size() > 0, "canonical Human skill definition resolves")
	_expect(HSC.try_cast(battle, caster, monster), "V63HumanSkillCombatSystem accepts the exact Palm candidate ID")
	var pending: Dictionary = caster.get("v63_pending_cast", {})
	_expect(str(pending.get("v63_skill_id", "")) == SKILL_ID, "pending cast carries the exact canonical ID")
	_expect(str(pending.get("shape", "")) == "single_target", "pending cast remains single target")
	if pending.is_empty():
		_finish()
		return
	var before_hp := float(monster.get("hp", 0.0))
	monster["position"] = Vector2(5.55, 0.0)
	battle.actors["palm01_test_monster"] = monster
	battle.now = float(pending.get("ready", 0.0))
	battle._release_casts()
	var casts := _events(battle, "skill_cast")
	var releases := _events(battle, "skill_release")
	var hits := _events(battle, "v63_skill_hit")
	var status_events := _events(battle, "status_applied") + _events(battle, "heal") + _events(battle, "cleanse")
	_expect(casts.size() == 1, "one skill_cast event is recorded")
	_expect(releases.size() == 1, "one skill_release event is recorded")
	_expect(hits.size() == 1, "one v63_skill_hit receipt is recorded")
	_expect(status_events.is_empty(), "damage skill emits no status, heal, or cleanse cue")
	if hits.size() == 1:
		_expect(str(hits[0].get("skill_id", "")) == SKILL_ID, "hit receipt carries the exact canonical ID")
		_expect(str(hits[0].get("target", hits[0].get("target_id", ""))) == "palm01_test_monster", "receipt stays on the moving monster")
		_expect(float(hits[0].get("damage", 0.0)) > 0.0, "receipt reports positive resolved damage")
		_expect(float(monster.get("hp", 0.0)) < before_hp, "resolved hit reduces only the target's HP")
	_expect(battle.outcome != "victory", "the isolated preview does not resolve a game encounter")
	_finish()

func _events(battle: MapBattleV2, kind: String) -> Array:
	var found: Array = []
	for raw in battle.events:
		var event: Dictionary = raw
		if str(event.get("type", "")) == kind:
			found.append(event)
	return found

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var resistances := {}
	for element in ["metal", "wood", "water", "fire", "earth", "lightning", "wind", "ice", "yang", "nether"]:
		resistances[element] = 0.0
	return {
		"id": actor_id, "side": side, "role": "mage", "position": position,
		"hp": 200.0, "max_hp": 200.0, "range": 2.6, "move_speed": 2.0,
		"stats": {"max_hp": 200.0, "attack": 40.0, "defense": 0.0,
			"damage_reduction": 0.0, "crit_chance": 0.0, "crit_damage": 1.5,
			"crit_resistance": 0.0, "defense_penetration": 0.0,
			"lifesteal": 0.0, "lifesteal_reduction": 0.0},
		"resistances": resistances, "status_effects": {}, "context_sources": [],
		"v63_combat_enabled": true, "v63_palm_combat_enabled": true,
		"v63_skill_ready": {}, "v63_skill_loadout": [SKILL_ID],
		"v63_passive_ids": [], "v63_combat_clock": -1.0, "next_skill": 0.0
	}

func _finish() -> void:
	if failures > 0:
		print("PALM01_RECEIPT_TEST_RESULT FAIL checks=", checks, " failures=", failures, " pve=OFF gate=OFF")
		quit(1)
		return
	print("PALM01_RECEIPT_TEST_RESULT PASS checks=", checks, " skill=", SKILL_ID, " one_positive_hit=true pve=OFF gate=OFF")
	quit(0)
