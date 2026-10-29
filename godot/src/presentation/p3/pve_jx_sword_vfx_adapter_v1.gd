extends RefCounted

## View-only adapter for the verified JX #158 sword sheets.
## Combat V2 owns skill timing, target selection and damage; an impact is
## rendered only after its positive learned_skill hit event is observed.
const SKILL_ID := "ngu_kiem_thuat"
const PRECAST_FX := "jx_wudang_158_precast"
const PROJECTILE_FX := "jx_wudang_158_cast"
const IMPACT_FX := "jx_wudang_158_impact"
const MAX_ACTIVE_CUES := 12
const MAX_UNCONFIRMED_SECONDS := 0.42

var atlas := CombatV4EffectAtlas.new()
var comparison_style := "hybrid"
var _clock := 0.0
var _encounter_id := ""
var _event_count_seen := 0
var _last_event: Dictionary = {}
var _event_cursor_initialized := false
var event_rows_examined_total := 0
var _sequences: Array[Dictionary] = []
var _sequence_counter := 0
var counters := {"casts":0,"positive_hits":0,"impacts":0,"expired_without_hit":0,"duplicate_snapshots":0}


func reset() -> void:
	_encounter_id = ""
	_event_count_seen = 0
	_last_event.clear()
	_event_cursor_initialized = false
	event_rows_examined_total = 0
	_sequences.clear()
	_sequence_counter = 0
	_clock = 0.0
	counters = {"casts":0,"positive_hits":0,"impacts":0,"expired_without_hit":0,"duplicate_snapshots":0}


## The first snapshot after opening/restoring a world is a baseline. This
## deliberately avoids replaying old saved presentation events on load.
func observe_snapshot(battle: MapBattleV2) -> Array[Dictionary]:
	var new_events: Array[Dictionary] = []
	if battle == null:
		reset()
		return new_events
	if _encounter_id != battle.encounter_id:
		_encounter_id = battle.encounter_id
		_sequences.clear()
		_set_event_cursor(battle)
		return new_events
	var event_count := battle.events.size()
	var first_new_index := -1
	if not _event_cursor_initialized or event_count < _event_count_seen:
		# Save restore/replacement can rewind or replace the bounded event ring.
		# Treat it as a baseline and never replay historical visual effects.
		_sequences.clear()
		_set_event_cursor(battle)
		return new_events
	if event_count > _event_count_seen and event_count < MapBattleV2.MAX_EVENTS:
		# Before the ring fills, the immutable prefix remains in place and the
		# append cursor identifies new events in O(delta), not O(history).
		first_new_index = _event_count_seen
	elif event_count == 0:
		counters["duplicate_snapshots"] = int(counters["duplicate_snapshots"]) + 1
		return new_events
	elif battle.events[event_count-1] == _last_event:
		# The usual steady-state path inspects one small event row only. This
		# replaces stringify-all + suffix/prefix overlap on up to 2,400 rows.
		counters["duplicate_snapshots"] = int(counters["duplicate_snapshots"]) + 1
		return new_events
	elif event_count == MapBattleV2.MAX_EVENTS:
		# Once Combat V2's bounded ring rolls, find the prior cursor from the end.
		# If it was evicted, establish a fresh baseline without replaying history.
		if _event_count_seen == 0:
			first_new_index = 0
		else:
			var cursor_index := -1
			for index in range(event_count-2,-1,-1):
				if battle.events[index] == _last_event:
					cursor_index = index
					break
			if cursor_index < 0:
				_sequences.clear()
				_set_event_cursor(battle)
				return new_events
			first_new_index = cursor_index+1
	elif event_count > _event_count_seen:
		# The array crossed MAX_EVENTS between snapshots. Locate the previous tail
		# instead of assuming the pre-ring size is still a valid index.
		var cursor_index := -1
		for index in range(event_count-2,-1,-1):
			if battle.events[index] == _last_event:
				cursor_index = index
				break
		if cursor_index < 0:
			_sequences.clear()
			_set_event_cursor(battle)
			return new_events
		first_new_index = cursor_index+1
	else:
		# A same-sized, non-full array with a different tail is a replaced
		# snapshot, not a trustworthy append stream.
		_sequences.clear()
		_set_event_cursor(battle)
		return new_events
	for index in range(first_new_index,event_count):
		var event: Dictionary = battle.events[index]
		new_events.append(event)
		event_rows_examined_total += 1
		_ingest_authority_event(event,battle)
	_set_event_cursor(battle)
	return new_events

func _set_event_cursor(battle: MapBattleV2) -> void:
	_event_count_seen = battle.events.size()
	if _event_count_seen > 0 and battle.events.back() is Dictionary:
		var last_event: Dictionary = battle.events.back()
		_last_event = last_event.duplicate(true)
	else:
		_last_event.clear()
	_event_cursor_initialized = true

func consume_event_observation_metrics() -> Dictionary:
	var result := {"rows_examined":event_rows_examined_total}
	event_rows_examined_total = 0
	return result


func advance(delta: float) -> void:
	_clock += maxf(0.0,delta)
	for index in range(_sequences.size()-1,-1,-1):
		var cue: Dictionary = _sequences[index]
		var age := _clock-float(cue.get("started",_clock))
		var windup := float(cue.get("windup",0.5))
		var flight := float(cue.get("flight",0.2))
		if str(cue.get("phase","")) != "impact" and age >= windup+flight:
			if bool(cue.get("confirmed",false)):
				cue["phase"] = "impact"
				cue["impact_started"] = _clock
				counters["impacts"] = int(counters["impacts"]) + 1
			elif age >= windup+flight+MAX_UNCONFIRMED_SECONDS:
				counters["expired_without_hit"] = int(counters["expired_without_hit"]) + 1
				_sequences.remove_at(index)
				continue
			else:
				cue["phase"] = "await_hit"
		if str(cue.get("phase","")) == "impact":
			if _clock-float(cue.get("impact_started",_clock)) >= atlas.duration(IMPACT_FX):
				_sequences.remove_at(index)
				continue
		_sequences[index] = cue


func render_cues() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for cue in _sequences:
		var phase := str(cue.get("phase","precast"))
		var elapsed := _clock-float(cue.get("started",_clock))
		var at: Vector2 = cue.get("from",Vector2.ZERO)
		var effect := PRECAST_FX
		var frame_elapsed := elapsed
		if phase == "flight" or phase == "await_hit":
			effect = PROJECTILE_FX
			var flight_start := float(cue.get("windup",0.5))
			var flight := maxf(0.001,float(cue.get("flight",0.2)))
			var progress := clampf((elapsed-flight_start)/flight,0.0,1.0)
			var from: Vector2 = cue.get("from",Vector2.ZERO)
			var to: Vector2 = cue.get("to",from)
			var direction := to-from
			at = from.lerp(to,progress)
			if direction.length_squared() > 0.0001:
				at += direction.normalized().orthogonal()*sin(progress*PI)*0.34
			frame_elapsed = maxf(0.0,elapsed-flight_start)
		elif phase == "impact":
			effect = IMPACT_FX
			at = cue.get("to",Vector2.ZERO)
			frame_elapsed = _clock-float(cue.get("impact_started",_clock))
		if phase == "precast" and comparison_style == "hybrid":
			# The native Source A attack1 clip is the wind-up in the selected
			# hybrid. The JX precast remains available in comparison style `jx1`.
			continue
		result.append({
			"effect":effect,"phase":phase,"at":at,"from":cue.get("from",at),
			"to":cue.get("to",at),"elapsed":frame_elapsed,
			"scale":0.43 if phase == "precast" else (0.115 if phase in ["flight","await_hit"] else 0.78),
			"cast_key":str(cue.get("key","")),"confirmed":bool(cue.get("confirmed",false))
		})
	return result


func active_count() -> int:
	return _sequences.size()


func _ingest_authority_event(event: Dictionary,battle: MapBattleV2) -> void:
	var kind := str(event.get("type",""))
	if kind == "skill_cast" and str(event.get("skill_id","")) == SKILL_ID:
		var caster_id := str(event.get("actor_id",""))
		var target_id := str(event.get("target",""))
		if not battle.actors.has(caster_id) or not battle.actors.has(target_id) or caster_id == target_id:
			return
		var caster: Dictionary = battle.actors[caster_id]
		var target: Dictionary = battle.actors[target_id]
		if str(caster.get("side","")) != "disciple" or str(target.get("side","")) != "monster":
			return
		if _sequences.size() >= MAX_ACTIVE_CUES:
			return
		_sequence_counter += 1
		var from: Vector2 = caster.get("position",Vector2.ZERO)
		var to: Vector2 = target.get("position",Vector2.ZERO)
		var release_delay := maxf(0.2,float(event.get("release_at",float(event.get("time",battle.now))+0.8))-float(event.get("time",battle.now)))
		var windup := minf(atlas.duration(PRECAST_FX),maxf(0.18,release_delay*0.56))
		var flight := maxf(0.14,release_delay-windup)
		var key := "%s|%d|%s|%s|%s" % [battle.encounter_id,_sequence_counter,caster_id,target_id,str(event.get("time",battle.now))]
		_sequences.append({"key":key,"caster":caster_id,"target":target_id,
			"from":from,"to":to,"started":_clock,"windup":windup,"flight":flight,
			"phase":"precast","confirmed":false,"release_seen":false})
		counters["casts"] = int(counters["casts"]) + 1
	elif kind == "skill_hit" and str(event.get("skill_id","")) == SKILL_ID:
		var cue := _matching_cast(str(event.get("caster","")),str(event.get("target","")))
		if not cue.is_empty():
			cue["release_seen"] = true
	elif kind == "hit" and str(event.get("kind","")) == "learned_skill":
		var cue := _matching_cast(str(event.get("attacker","")),str(event.get("target","")))
		if cue.is_empty():
			return
		if float(event.get("damage",0.0)) <= 0.0:
			cue["resolved_without_damage"] = true
			return
		cue["confirmed"] = true
		cue["damage_receipt"] = float(event.get("damage",0.0)) # QA evidence only; never consumed by gameplay.
		var target_id := str(event.get("target",""))
		if battle.actors.has(target_id):
			cue["to"] = battle.actors[target_id].get("position",cue.get("to",Vector2.ZERO))
		counters["positive_hits"] = int(counters["positive_hits"]) + 1


func _matching_cast(caster_id: String,target_id: String) -> Dictionary:
	for index in range(_sequences.size()-1,-1,-1):
		var cue: Dictionary = _sequences[index]
		if str(cue.get("caster","")) == caster_id and str(cue.get("target","")) == target_id and not bool(cue.get("confirmed",false)):
			return cue
	return {}


