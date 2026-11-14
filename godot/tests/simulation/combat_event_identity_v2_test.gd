extends SceneTree

const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Summon = preload("res://src/simulation/combat/v63_summon_skill_combat_system.gd")
const Snapshot = preload("res://src/simulation/combat/map_battle_snapshot_v2.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _expect(ok: bool, label: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("COMBAT_EVENT_IDENTITY_FAIL "+label)

func _run() -> void:
	var regular_a := _regular_cast_trace()
	var regular_b := _regular_cast_trace()
	print("COMBAT_EVENT_IDENTITY_TRACE regular_a="+JSON.stringify(regular_a))
	_expect(bool(regular_a.get("ok",false)) and bool(regular_b.get("ok",false)), "ordinary learned-skill cast resolves through Combat V2")
	if bool(regular_a.get("ok",false)) and bool(regular_b.get("ok",false)):
		_expect(regular_a.get("event_ids",[]) == regular_b.get("event_ids",[]), "same seed and encounter produce deterministic event identities")
		_expect(bool(regular_a.get("cast_chain",false)), "cast, release, committed hit and applied status share a concrete cast ID")
		_expect(bool(regular_a.get("unique",false)), "ordinary event journal has no duplicate or empty event IDs")
		_expect(bool(regular_a.get("resume_id_stable",false)), "continuous battle snapshot resumes the next fallback event ID exactly")
		_expect(bool(regular_a.get("resume_no_replay",false)), "restoring a resolved cast preserves HP and does not replay its committed hit")
		_expect(bool(regular_a.get("two_casts_unique",false)), "sequential casts by the same actor receive distinct deterministic IDs")
	await _exercise_summon_identity()
	_exercise_capacity_shield_identity()
	if _failures > 0:
		print("COMBAT_EVENT_IDENTITY_V2_RESULT FAIL checks=%d failures=%d" % [_checks,_failures])
		quit(1)
		return
	print("COMBAT_EVENT_IDENTITY_V2_RESULT PASS checks=%d cast_release_hit_status=PASS summon_create_attack_expire=PASS palm_absorb=PASS snapshot_resume=PASS v63_gate=OFF" % _checks)
	quit(0)

func _regular_cast_trace() -> Dictionary:
	var stats: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0).get("stats",{}).duplicate(true)
	if stats.is_empty():
		return {"ok":false}
	var caster := _basic_actor("event_caster","disciple",Vector2(4,4),stats)
	caster["skill_loadout"] = ["hoa_cau"]
	caster["skill_factors"] = {"hoa_cau":1.0}
	var target_stats := stats.duplicate(true)
	target_stats["max_hp"] = 100000.0
	var target := _basic_actor("event_target","monster",Vector2(7,4),target_stats)
	target["hp"] = 100000.0
	target["max_hp"] = 100000.0
	target["spawn_slot_id"] = "event_identity_target_slot"
	target["slot_generation"] = 1
	var battle := MapBattleV2.new(771234)
	var setup := battle.setup("event_identity_regular",[caster],[target],true)
	if not bool(setup.get("ok",false)):
		return {"ok":false,"reason":str(setup.get("reason","setup_failed"))}
	caster = battle.actors["event_caster"]
	target = battle.actors["event_target"]
	if not battle._try_learned_skill(caster,target):
		return {"ok":false,"reason":"cast_not_started"}
	var pending: Dictionary = battle.pending_casts[0]
	var cast_id := str(pending.get("cast_id",""))
	battle.now = float(pending.get("ready",battle.now))
	battle._release_casts()
	var cast_event: Dictionary = _find_event(battle,"skill_cast",cast_id)
	var release_event: Dictionary = _find_event(battle,"skill_release",cast_id)
	var hit_event: Dictionary = _find_event(battle,"hit",cast_id)
	var skill_hit_event: Dictionary = _find_event(battle,"skill_hit",cast_id)
	var status_event: Dictionary = _find_event(battle,"status_applied",cast_id)
	var chain_ok := not cast_id.is_empty() and not cast_event.is_empty() and not release_event.is_empty() \
		and not hit_event.is_empty() and float(hit_event.get("damage",0.0)) > 0.0 \
		and not skill_hit_event.is_empty() and float(skill_hit_event.get("damage",0.0)) > 0.0 \
		and not status_event.is_empty() and str(status_event.get("status","")) == "burn"
	var event_ids := _event_ids(battle.events)
	var unique := _all_unique_nonempty(event_ids)
	var committed_hp := float(battle.actors["event_target"].get("hp",0.0))
	var committed_hit_count := _count_events(battle.events,"hit")
	var saved := Snapshot.save(battle)
	var restored_result := Snapshot.load(saved)
	var resume_id_stable := false
	var resume_no_replay := false
	if bool(restored_result.get("ok",false)):
		var restored: MapBattleV2 = restored_result.get("battle")
		var restored_target: Dictionary = restored.actors.get("event_target",{})
		resume_no_replay = restored.pending_casts.is_empty() and \
			is_equal_approx(float(restored_target.get("hp",-1.0)),committed_hp) and \
			_count_events(restored.events,"hit") == committed_hit_count and \
			_event_ids(restored.events) == event_ids
		restored._release_casts()
		resume_no_replay = resume_no_replay and \
			is_equal_approx(float(restored.actors.get("event_target",{}).get("hp",-1.0)),committed_hp) and \
			_count_events(restored.events,"hit") == committed_hit_count
		battle._event("identity_probe",{})
		restored._event("identity_probe",{})
		resume_id_stable = str(battle.events.back().get("event_id","")) == str(restored.events.back().get("event_id",""))
	var first_cast_id := cast_id
	caster = battle.actors["event_caster"]
	target = battle.actors["event_target"]
	var ready: Dictionary = caster.get("skill_ready",{})
	ready["hoa_cau"] = battle.now
	caster["skill_ready"] = ready
	caster["next_skill"] = battle.now
	var second_cast_started := battle._try_learned_skill(caster,target)
	var second_cast_id := ""
	if second_cast_started and not battle.pending_casts.is_empty():
		second_cast_id = str(battle.pending_casts.back().get("cast_id",""))
		battle.now = float(battle.pending_casts.back().get("ready",battle.now))
		battle._release_casts()
	var two_casts_unique := not first_cast_id.is_empty() and not second_cast_id.is_empty() and \
		first_cast_id != second_cast_id and _all_unique_nonempty(_event_ids(battle.events))
	return {"ok":true,"event_ids":event_ids,"cast_chain":chain_ok,"unique":unique,
		"resume_id_stable":resume_id_stable,"resume_no_replay":resume_no_replay,
		"two_casts_unique":two_casts_unique,"cast_ids":[first_cast_id,second_cast_id]}

func _exercise_summon_identity() -> void:
	var skill_id := "tmb.skill.summon.kiem_linh.active_01.human"
	var skill := Summon.skill_definition(skill_id)
	var owner := _basic_actor("event_summon_owner","disciple",Vector2(2,3),_combat_actor_stats())
	owner["party_id"] = "event_summon_party"
	owner["v63_summon_combat_enabled"] = true
	owner["v63_skill_loadout"] = [skill_id]
	owner["v63_skill_ready"] = {}
	var second_owner := _basic_actor("event_summon_owner_2","disciple",Vector2(2,5),_combat_actor_stats())
	second_owner["party_id"] = "event_summon_party"
	second_owner["v63_summon_combat_enabled"] = true
	second_owner["v63_skill_loadout"] = [skill_id]
	second_owner["v63_skill_ready"] = {}
	var enemy := _basic_actor("event_summon_enemy","monster",Vector2(5,3),_combat_actor_stats())
	enemy["hp"] = 10000.0
	enemy["max_hp"] = 10000.0
	enemy["stats"]["max_hp"] = 10000.0
	var battle := MapBattleV2.new(881234)
	battle.encounter_id = "event_identity_summon"
	battle.active = true
	battle.outcome = "fighting"
	battle.actors[owner["id"]] = owner
	battle.actors[second_owner["id"]] = second_owner
	battle.actors[enemy["id"]] = enemy
	battle.step()
	owner = battle.actors["event_summon_owner"]
	second_owner = battle.actors["event_summon_owner_2"]
	var cast: Dictionary = owner.get("v63_pending_cast",{})
	var second_cast: Dictionary = second_owner.get("v63_pending_cast",{})
	_expect(not cast.is_empty() and not second_cast.is_empty(), "Combat V2 AI started two real summon casts in one encounter")
	if cast.is_empty() or second_cast.is_empty():
		return
	var origin_cast_id := str(cast.get("mastery_event_id",""))
	battle.now = maxf(float(cast.get("ready",battle.now)),float(second_cast.get("ready",battle.now)))
	battle._release_casts()
	var summon_ids: Array[String] = []
	for actor_id in battle.actors:
		if bool(battle.actors[actor_id].get("is_v63_summon",false)):
			summon_ids.append(str(actor_id))
	summon_ids.sort()
	var created_events := _events_of_type(battle.events,"v63_summon_created")
	_expect(summon_ids.size() == 2 and created_events.size() == 2, "two released casts create two real bounded summon actors")
	if summon_ids.is_empty():
		return
	var summon_id := summon_ids[0]
	var created := _find_event(battle,"v63_summon_created","")
	var created_ids: Array[String] = []
	var created_cast_ids: Array[String] = []
	for event in created_events:
		created_ids.append(str(event.get("event_id","")))
		created_cast_ids.append(str(event.get("cast_id","")))
	_expect(created_ids.size() == 2 and created_cast_ids.size() == 2 and
		_all_unique_nonempty(created_ids) and _all_unique_nonempty(created_cast_ids) and
		created_ids[0] != created_ids[1], "summon creation and source cast IDs do not collide across owners")
	var created_for_first: Dictionary = {}
	for event in created_events:
		if str(event.get("summon_id","")) == summon_id:
			created_for_first = event
	_expect(not created_for_first.is_empty() and str(created_for_first.get("event_id","")) == summon_id+"/created" and
		str(created_for_first.get("cast_id","")) == origin_cast_id and str(created_for_first.get("summon_id","")) == summon_id and
		created_for_first.get("summon_position",null) is Vector2,
		"summon creation event links its actual origin cast and spawn position")
	for _tick in range(60):
		battle.step()
	var attacks_for_first := _events_for_source(battle.events,"v63_summon_attack","summon_id",summon_id)
	var attack_ids: Array[String] = []
	var attack_links_ok := attacks_for_first.size() >= 2
	var attack: Dictionary = attacks_for_first[0] if not attacks_for_first.is_empty() else {}
	var linked_hit: Dictionary = {}
	for attack_event in attacks_for_first:
		var attack_event_id := str(attack_event.get("event_id",""))
		var hit_event_id := str(attack_event.get("hit_event_id",""))
		attack_ids.append(attack_event_id)
		var linked_hit_for_attack := _find_event_id(battle.events,hit_event_id)
		if linked_hit.is_empty():
			linked_hit = linked_hit_for_attack
		attack_links_ok = attack_links_ok and not attack_event_id.is_empty() and \
			not linked_hit_for_attack.is_empty() and float(attack_event.get("damage",0.0)) > 0.0 and \
			is_equal_approx(float(linked_hit_for_attack.get("damage",0.0)),float(attack_event.get("damage",-1.0))) and \
			str(linked_hit_for_attack.get("source_actor_id","")) == summon_id
	_expect(attack_links_ok and _all_unique_nonempty(attack_ids), "repeated summon attacks have unique IDs and each links one committed positive Combat V2 hit")
	if not attack.is_empty():
		_expect(str(attack.get("event_id","")) == summon_id+"/attack/1" and
			str(attack.get("hit_event_id","")) == summon_id+"/attack/1/hit/"+str(attack.get("target_id","")) and
			str(attack.get("origin_cast_id","")) == origin_cast_id,
			"autonomous summon attack has unique event identity without inventing a new cast")
	var summon: Dictionary = battle.actors.get(summon_id,{})
	if not summon.is_empty():
		battle.now = float(summon.get("summon_expires_at",battle.now))
		Summon.process_summons(battle)
	var expired := _find_event(battle,"v63_summon_expired","")
	_expect(not expired.is_empty() and str(expired.get("summon_id","")) == summon_id and
		str(expired.get("event_id","")) == summon_id+"/expired" and
		str(expired.get("origin_cast_id","")) == origin_cast_id,
		"expiry event identifies the removed summon and its original cast exactly once")
	_expect(_all_unique_nonempty(_event_ids(battle.events)), "summon timeline contains no repeated or empty event IDs")
	print("COMBAT_EVENT_IDENTITY_TRACE summon=%s" % JSON.stringify({
		"summon_ids":summon_ids,"created_event_ids":created_ids,"origin_cast_ids":created_cast_ids,
		"attack_event_ids":attack_ids,"attack_count_for_first_summon":attacks_for_first.size(),
		"created":_trace_event(created),"attack":_trace_event(attack),
		"hit":_trace_event(linked_hit),"expired":_trace_event(expired)}))

func _exercise_capacity_shield_identity() -> void:
	var battle := MapBattleV2.new(991155)
	battle.encounter_id = "event_identity_palm_shield"
	battle.active = true
	battle.outcome = "fighting"
	var guardian := _combat_actor("identity_guardian","disciple",Vector2(3,3))
	var ally := _combat_actor("identity_guarded_ally","disciple",Vector2(4,3))
	var enemy := _combat_actor("identity_guard_enemy","monster",Vector2(5,3))
	ally["party_id"] = "identity_party"
	ally["hp"] = 80.0
	enemy["stats"]["attack"] = 10.0
	guardian["party_id"] = "identity_party"
	guardian["v63_palm_combat_enabled"] = true
	guardian["v63_skill_loadout"] = ["tmb.skill.palm.hoi_phong_chuong.active_04.human"]
	for actor in [guardian,ally,enemy]:
		battle.actors[str(actor.get("id",""))] = actor
	_expect(HSC.try_cast(battle,guardian,enemy), "canonical Palm Combat V2 guard cast begins")
	var pending: Dictionary = guardian.get("v63_pending_cast",{})
	if pending.is_empty():
		return
	var origin_cast_id := str(pending.get("mastery_event_id",""))
	battle.now = float(pending.get("ready",0.0))
	battle._release_casts()
	var initial_capacity := float(ally.get("v63_capacity_shield_remaining",0.0))
	var hp_before := float(ally.get("hp",0.0))
	battle._deal_direct(enemy,ally,1.0,"basic",false,"metal",false)
	battle._deal_direct(enemy,ally,1.0,"basic",false,"metal",false)
	var absorbed_events := _events_of_type(battle.events,"v63_palm_guard_absorbed")
	var absorbed: Dictionary = absorbed_events[0] if not absorbed_events.is_empty() else {}
	_expect(initial_capacity > 0.0 and not absorbed.is_empty() and float(ally.get("hp",0.0)) == hp_before,
		"Palm shield events are emitted only for committed capacity absorption")
	_expect(str(absorbed.get("cast_id","")) == origin_cast_id and
		str(absorbed.get("origin_cast_id","")) == origin_cast_id and
		str(absorbed.get("attacker","")) == "identity_guard_enemy" and
		str(absorbed.get("target_id","")) == "identity_guarded_ally" and
		str(absorbed.get("incoming_cast_id","")) == "" and
		absorbed.get("target_position",null) is Vector2 and float(absorbed.get("absorbed_damage",0.0)) > 0.0,
		"Palm absorption distinguishes shield origin, real attacker, protected target and impact position")
	var shield_ids: Array[String] = []
	for event in absorbed_events:
		shield_ids.append(str(event.get("event_id","")))
	_expect(absorbed_events.size() == 2 and _all_unique_nonempty(shield_ids) and
		int(absorbed_events[0].get("absorption_sequence",0)) == 1 and
		int(absorbed_events[1].get("absorption_sequence",0)) == 2 and
		float(ally.get("hp",0.0)) == hp_before,
		"repeated Palm absorption advances identity without double-applying damage")
	_expect(_all_unique_nonempty(_event_ids(battle.events)), "Palm guard event IDs do not collide with cast or incoming hit events")
	print("COMBAT_EVENT_IDENTITY_TRACE palm_absorbed=%s" % JSON.stringify({
		"absorbed_event_ids":shield_ids,"first_event":_trace_event(absorbed)}))

func _find_event(battle: MapBattleV2, event_type: String, cast_id: String) -> Dictionary:
	for event in battle.events:
		if str(event.get("type","")) == event_type and (cast_id.is_empty() or str(event.get("cast_id","")) == cast_id):
			return event
	return {}

func _event_ids(events: Array) -> Array[String]:
	var ids: Array[String] = []
	for event in events:
		ids.append(str(event.get("event_id","")))
	return ids

func _count_events(events: Array, event_type: String) -> int:
	return _events_of_type(events,event_type).size()

func _events_of_type(events: Array, event_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in events:
		if str(event.get("type","")) == event_type:
			result.append(event)
	return result

func _events_for_source(events: Array, event_type: String, source_key: String, source_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in events:
		if str(event.get("type","")) == event_type and str(event.get(source_key,"")) == source_id:
			result.append(event)
	return result

func _find_event_id(events: Array, event_id: String) -> Dictionary:
	for event in events:
		if str(event.get("event_id","")) == event_id:
			return event
	return {}

func _trace_event(event: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in ["event_id","type","cast_id","origin_cast_id","summon_id","source_actor_id",
		"owner_id","target_id","hit_event_id","attacker","incoming_cast_id","skill_id",
		"status","damage","absorbed_damage","capacity_remaining","summon_position",
		"source_position","target_position","impact_position"]:
		if event.has(key):
			var value: Variant = event[key]
			result[key] = str(value) if value is Vector2 else value
	return result

func _all_unique_nonempty(ids: Array) -> bool:
	var seen: Dictionary = {}
	for value in ids:
		var event_id := str(value)
		if event_id.is_empty() or seen.has(event_id):
			return false
		seen[event_id] = true
	return true

func _basic_actor(actor_id: String, side: String, position: Vector2, stats: Dictionary) -> Dictionary:
	var row := {"id":actor_id,"side":side,"party_id":"identity_party","role":"mage","tier":"normal",
		"position":position,"hp":float(stats.get("max_hp",200.0)),"max_hp":float(stats.get("max_hp",200.0)),
		"range":7.5,"move_speed":2.0,"basic_ratio":1.0,"basic_interval":1.6,
		"stats":stats.duplicate(true),"resistances":_resistances(),"status_effects":{},
		"skill_loadout":[],"skill_factors":{},"skill_ready":{},"context_sources":[],
		"v63_combat_enabled":side == "disciple","v63_skill_loadout":[],"v63_skill_ready":{},"v63_passive_ids":[],
		"v63_combat_clock":-1.0,"next_skill":0.0,"next_basic":0.0,"hunt_policy":"auto",
		"hunt_after_move":"auto","hunt_radius":8.0,"guard_until":-1.0,
		"learned_guard_until":-1.0,"learned_guard_factor":1.0}
	if side == "monster":
		row["race_id"] = "yeu_thu"
	return row

func _combat_actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
	var row := _basic_actor(actor_id,side,position,_combat_actor_stats())
	row["v63_combat_enabled"] = true
	row["v63_summon_combat_enabled"] = false
	row["v63_palm_combat_enabled"] = false
	return row

func _combat_actor_stats() -> Dictionary:
	return {"max_hp":200.0,"attack":40.0,"defense":0.0,"damage_reduction":0.0,
		"crit_chance":0.0,"crit_damage":1.5,"crit_resistance":0.0,"defense_penetration":0.0,
		"lifesteal":0.0,"lifesteal_reduction":0.0}

func _resistances() -> Dictionary:
	return {"metal":0.0,"wood":0.0,"water":0.0,"fire":0.0,"earth":0.0,"lightning":0.0,
		"wind":0.0,"ice":0.0,"yang":0.0,"nether":0.0}
