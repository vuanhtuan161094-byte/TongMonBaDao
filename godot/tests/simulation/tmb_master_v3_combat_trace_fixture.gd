extends SceneTree

const SEEDS_PER_GROUP := 20
const REALMS := [1,2,5,10,20,30]
const PARTY_SIZES := [1,3,6]
const TARGETS := ["normal","elite","boss"]

var summary_rows: Array[Dictionary] = []
var group_rows: Array[Dictionary] = []
var event_rows := 0
var summary_file: FileAccess
var group_file: FileAccess
var event_file: FileAccess

func _init() -> void:
	call_deferred("_run")

func _assert(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false

func _csv(value: Variant) -> String:
	var raw := str(value).replace("\"", "\"\"")
	return "\"%s\"" % raw

func _csv_row(values: Array) -> String:
	var fields: Array[String] = []
	for value in values:
		fields.append(_csv(value))
	return ",".join(fields)+"\n"

func _party(count: int, cultivation_realm: int, body_realm: int, seed: int) -> Array:
	var rows: Array = []
	for i in range(count):
		var derived := CombatStatsV2.derive(cultivation_realm,1,body_realm,1,0.0)
		if not bool(derived.get("ok",false)):
			return []
		var role := "frontline"
		if count == 3:
			role = ["frontline","mage","healer"][i]
		elif count == 6:
			role = ["frontline","ranged","mage","healer","frontline","ranged"][i]
		else:
			role = "frontline"
		var skills: Array[String] = ["thanh_phong_tram"]
		if cultivation_realm >= 2:
			skills.append("ngu_kiem_thuat")
		var position := Vector2(8.0+float(i%3)*0.8,8.0+float(i/3)*0.9)
		var hp := float(derived["stats"]["max_hp"])
		if (count == 3 and i == 0) or (count == 6 and i == 0):
			hp *= 0.45
		rows.append({
			"id":"d_%02d" % i,"party_id":"party_0","stats":derived["stats"],
			"role":role,"position":position,"hp":hp,
			"skill_loadout":skills,"skill_factors":{},
			"context_sources":[],"fixture_seed":seed
		})
	return rows

func _monsters(target_kind: String, realm: int) -> Array:
	var species: Array[String] = []
	match target_kind:
		"normal": species = ["hac_lang","thanh_lang","truc_thu"]
		"elite": species = ["nham_giap_thu","huyet_lang_dau_dan","nham_giap_thu"]
		"boss": species = ["hac_lang_vuong","thanh_lang","truc_thu"]
	var rows: Array = []
	for i in range(species.size()):
		var actor := MonsterCatalogueV2.create_actor(species[i],realm,1,"fx_%s_%02d" % [target_kind,i])
		if not bool(actor.get("ok",false)):
			return []
		actor["id"] = "m_%02d" % i
		actor["position"] = Vector2(23.0+float(i%3)*0.8,8.0+float(i/3)*0.9)
		rows.append(actor)
	return rows

func _percentile(values: Array[float], q: float) -> float:
	if values.is_empty():
		return -1.0
	var sorted := values.duplicate()
	sorted.sort()
	var idx := clampi(int(ceil(q*float(sorted.size())))-1,0,sorted.size()-1)
	return sorted[idx]

func _record_event(scenario: String, seed: int, cultivation_realm: int, body_realm: int, party_size: int, target_kind: String, event: Dictionary) -> void:
	var actor := str(event.get("attacker",event.get("actor_id",event.get("caster",""))))
	var target := str(event.get("target",event.get("target_id","")))
	event_file.store_string(_csv_row([
		scenario,seed,cultivation_realm,body_realm,party_size,target_kind,
		float(event.get("time",0.0)),str(event.get("type","")),actor,target,
		str(event.get("kind","")),str(event.get("skill_id",event.get("skill",""))),
		float(event.get("damage",0.0)),bool(event.get("critical",false)),
		float(event.get("amount",0.0)),int(event.get("target_count",0)),
		float(event.get("release_at",event.get("until",0.0)))
	]))
	event_rows += 1

func _run_one(cultivation_realm: int, body_realm: int, party_size: int, target_kind: String, seed: int, track: String) -> bool:
	var scenario := "r%d_b%d_%s_%dp_%s_s%02d" % [cultivation_realm,body_realm,track,party_size,target_kind,seed]
	var battle := MapBattleV2.new(700000+seed*31+cultivation_realm*503+body_realm*97+party_size*11)
	var setup := battle.setup(scenario,_party(party_size,cultivation_realm,body_realm,seed),_monsters(target_kind,cultivation_realm))
	if not _assert(bool(setup.get("ok",false)),"Fixture setup failed: "+scenario):
		return false
	var result: Dictionary = battle.run(361,false)
	var events: Array = result.get("events",[])
	var outgoing := 0.0
	var incoming := 0.0
	var basic_hits := 0
	var followup_hits := 0
	var skill_casts := 0
	var skill_hits := 0
	var crits := 0
	var crit_eligible := 0
	var lifesteal := 0.0
	var heal_count := 0
	var healed := 0.0
	var requested_heal := 0.0
	var guard_events := 0
	var guard_seconds := 0.0
	var guard_until_by_actor: Dictionary = {}
	var aoe_releases := 0
	var aoe_targets := 0
	var telegraphs := 0
	var area_damage_events := 0
	var basics_at: Dictionary = {}
	var attack_intervals: Array[float] = []
	var burst_events: Array[Dictionary] = []
	for e_value in events:
		var event: Dictionary = e_value
		var event_type := str(event.get("type",""))
		if event_type == "hit":
			var attacker := str(event.get("attacker",""))
			var target := str(event.get("target",""))
			var amount := float(event.get("damage",0.0))
			var attacker_row: Dictionary = battle.actors.get(attacker,{})
			var target_row: Dictionary = battle.actors.get(target,{})
			if str(attacker_row.get("side","")) == "disciple":
				outgoing += amount
				burst_events.append({"time":float(event.get("time",0.0)),"damage":amount})
				if bool(event.get("critical",false)):
					crits += 1
				if str(event.get("kind","")) != "basic_followup":
					crit_eligible += 1
				lifesteal += float(event.get("lifesteal",0.0))
				if str(event.get("kind","")) == "basic":
					basic_hits += 1
					if basics_at.has(attacker):
						attack_intervals.append(float(event.get("time",0.0))-float(basics_at[attacker]))
					basics_at[attacker] = float(event.get("time",0.0))
				elif str(event.get("kind","")) == "basic_followup":
					followup_hits += 1
				if str(event.get("kind","")) == "area_burst":
					area_damage_events += 1
			if str(target_row.get("side","")) == "disciple":
				incoming += amount
		elif event_type == "skill_cast":
			skill_casts += 1
		elif event_type == "skill_hit":
			skill_hits += 1
		elif event_type == "heal":
			heal_count += 1
			var actual := float(event.get("amount",0.0))
			healed += actual
			var caster: Dictionary = battle.actors.get(str(event.get("caster","")),{})
			requested_heal += float(caster.get("stats",{}).get("attack",0.0))*1.8
		elif event_type == "guard":
			guard_events += 1
			var guard_id := str(event.get("actor_id",""))
			var start := float(event.get("time",0.0))
			var until := float(event.get("until",start))
			var covered_until := float(guard_until_by_actor.get(guard_id,start))
			guard_seconds += maxf(0.0,until-maxf(start,covered_until))
			guard_until_by_actor[guard_id] = maxf(covered_until,until)
		elif event_type == "area_release":
			aoe_releases += 1
			aoe_targets += int(event.get("target_count",0))
		elif event_type == "cast" and str(event.get("skill","")) == "area_burst":
			aoe_releases += 1
			aoe_targets += int(event.get("target_count",0))
		elif event_type == "telegraph":
			telegraphs += 1
		var is_discipline_action := event_type in ["move","skill_cast","skill_hit","hit","heal","guard","telegraph","area_release"]
		if is_discipline_action:
			_record_event(scenario,seed,cultivation_realm,body_realm,party_size,target_kind,event)
	var max_burst := 0.0
	for i in range(burst_events.size()):
		var at := float(burst_events[i]["time"])
		var total := 0.0
		for j in range(i,burst_events.size()):
			if float(burst_events[j]["time"])-at > 2.0:
				break
			total += float(burst_events[j]["damage"])
		max_burst = maxf(max_burst,total)
	var healed_over_cap := maxf(0.0,requested_heal-healed)
	var intervals_mean := 0.0
	for interval in attack_intervals:
		intervals_mean += interval
	if not attack_intervals.is_empty():
		intervals_mean /= float(attack_intervals.size())
	var record := {
		"scenario":scenario,"track":track,"cultivation_realm":cultivation_realm,"body_realm":body_realm,
		"party_size":party_size,"target_kind":target_kind,"seed":seed,"outcome":str(result.get("outcome","")),
		"active_seconds":float(result.get("time",0.0)),"won":str(result.get("outcome","")) == "win",
		"downed":int(result.get("downed_disciples",0)),"remaining_hp_ratio":float(result.get("disciple_remaining_hp_ratio",0.0)),
		"outgoing_damage":outgoing,"incoming_damage":incoming,"net_damage":outgoing-incoming,
		"dps":outgoing/maxf(0.25,float(result.get("time",0.0))),"max_burst_2s":max_burst,
		"basic_hits":basic_hits,"basic_followups":followup_hits,"mean_basic_interval":intervals_mean,
		"skill_casts":skill_casts,"skill_hits":skill_hits,"skill_hit_rate":float(skill_hits)/maxf(1.0,float(skill_casts)),
		"critical_hits":crits,"critical_rate":float(crits)/maxf(1.0,float(crit_eligible)),
		"lifesteal":lifesteal,"heals":heal_count,"healed":healed,"overheal_estimate":healed_over_cap,
		"guard_events":guard_events,"guard_coverage_seconds":guard_seconds,
		"aoe_releases":aoe_releases,"aoe_targets":aoe_targets,"elite_boss_telegraphs":telegraphs,
		"area_damage_hits":area_damage_events
	}
	summary_rows.append(record)
	summary_file.store_string(_csv_row([
		record.scenario,track,cultivation_realm,body_realm,party_size,target_kind,seed,record.outcome,
		record.active_seconds,record.won,record.downed,record.remaining_hp_ratio,record.outgoing_damage,
		record.incoming_damage,record.net_damage,record.dps,record.max_burst_2s,record.basic_hits,
		record.basic_followups,record.mean_basic_interval,record.skill_casts,record.skill_hits,record.skill_hit_rate,
		record.critical_hits,record.critical_rate,record.lifesteal,record.heals,record.healed,record.overheal_estimate,
		record.guard_events,record.guard_coverage_seconds,record.aoe_releases,record.aoe_targets,
		record.elite_boss_telegraphs,record.area_damage_hits
	]))
	return true

func _write_group_summaries() -> void:
	var grouped: Dictionary = {}
	for record in summary_rows:
		var key := "%s|%d|%d|%d|%s" % [record.track,record.cultivation_realm,record.body_realm,record.party_size,record.target_kind]
		if not grouped.has(key):
			grouped[key] = []
		grouped[key].append(record)
	for key in grouped.keys():
		var rows: Array = grouped[key]
		var wins := 0
		var downed := 0.0
		var dps := 0.0
		var burst := 0.0
		var all_times: Array[float] = []
		var win_times: Array[float] = []
		var skill_casts := 0
		var skill_hits := 0
		var heals := 0
		var aoe_targets := 0
		for row in rows:
			var time := float(row.active_seconds)
			all_times.append(time)
			if bool(row.won):
				wins += 1
				win_times.append(time)
			downed += float(row.downed)
			dps += float(row.dps)
			burst += float(row.max_burst_2s)
			skill_casts += int(row.skill_casts)
			skill_hits += int(row.skill_hits)
			heals += int(row.heals)
			aoe_targets += int(row.aoe_targets)
		var meta: Array = key.split("|")
		var group := {
			"track":meta[0],"cultivation_realm":int(meta[1]),"body_realm":int(meta[2]),
			"party_size":int(meta[3]),"target_kind":meta[4],"sample":rows.size(),"wins":wins,
			"win_rate":float(wins)/maxf(1.0,float(rows.size())),"ttk_win_p10":_percentile(win_times,0.10),
			"ttk_win_p50":_percentile(win_times,0.50),"ttk_win_p90":_percentile(win_times,0.90),
			"active_p50":_percentile(all_times,0.50),"avg_downed":downed/maxf(1.0,float(rows.size())),
			"avg_dps":dps/maxf(1.0,float(rows.size())),"avg_burst_2s":burst/maxf(1.0,float(rows.size())),
			"skill_casts":skill_casts,"skill_hits":skill_hits,"skill_hit_rate":float(skill_hits)/maxf(1.0,float(skill_casts)),
			"heals":heals,"aoe_targets":aoe_targets
		}
		group_rows.append(group)
		group_file.store_string(_csv_row([
			group.track,group.cultivation_realm,group.body_realm,group.party_size,group.target_kind,group.sample,
			group.wins,group.win_rate,group.ttk_win_p10,group.ttk_win_p50,group.ttk_win_p90,group.active_p50,
			group.avg_downed,group.avg_dps,group.avg_burst_2s,group.skill_casts,group.skill_hits,
			group.skill_hit_rate,group.heals,group.aoe_targets
		]))

func _run() -> void:
	var output_dir := OS.get_environment("TMB_V3_OUTPUT")
	if output_dir.is_empty() or not DirAccess.dir_exists_absolute(output_dir):
		_assert(false,"Set TMB_V3_OUTPUT to an existing output directory.")
		return
	summary_file = FileAccess.open(output_dir.path_join("combat_fixture_summary.csv"),FileAccess.WRITE)
	group_file = FileAccess.open(output_dir.path_join("combat_fixture_groups.csv"),FileAccess.WRITE)
	event_file = FileAccess.open(output_dir.path_join("combat_action_ledger.csv"),FileAccess.WRITE)
	if not _assert(summary_file != null and group_file != null and event_file != null,"Cannot open output CSV files."):
		return
	summary_file.store_string(_csv_row(["scenario","track","cultivation_realm","body_realm","party_size","target","seed","outcome","active_seconds","won","downed","remaining_hp_ratio","outgoing_damage","incoming_damage","net_damage","dps","max_burst_2s","basic_hits","basic_followups","mean_basic_interval","skill_casts","skill_hits","skill_hit_rate","critical_hits","critical_rate","lifesteal","heals","healed","overheal_estimate","guard_events","guard_coverage_seconds","aoe_releases","aoe_targets","telegraphs","area_damage_hits"]))
	group_file.store_string(_csv_row(["track","cultivation_realm","body_realm","party_size","target","sample","wins","win_rate","ttk_win_p10","ttk_win_p50","ttk_win_p90","active_p50","avg_downed","avg_dps","avg_burst_2s","skill_casts","skill_hits","skill_hit_rate","heals","aoe_targets"]))
	event_file.store_string(_csv_row(["scenario","seed","cultivation_realm","body_realm","party_size","target","time","event_type","actor","target_id","kind","skill_id","damage","critical","heal","target_count","release_at_or_guard_until"]))
	var realms := REALMS.duplicate()
	var party_sizes := PARTY_SIZES.duplicate()
	var targets := TARGETS.duplicate()
	var seeds := SEEDS_PER_GROUP
	if OS.get_environment("TMB_TRACE_SMOKE") == "1":
		realms = [1]; party_sizes = [3]; targets = ["boss"]; seeds = 1
	for realm in realms:
		for count in party_sizes:
			for target in targets:
				for seed in range(seeds):
					if not _run_one(realm,realm,count,target,seed,"equal_progress"):
						return
	# Explicitly separate Tu Vi and Body progression cases at two representative grades.
	if OS.get_environment("TMB_TRACE_SMOKE") != "1":
		for realm in [5,20]:
			var body_realm: int = int(realm)-2
			for count in [3,6]:
				for target in ["normal","boss"]:
					for seed in range(SEEDS_PER_GROUP):
						if not _run_one(realm,body_realm,count,target,seed,"body_minus_2"):
							return
	_write_group_summaries()
	summary_file.close(); group_file.close(); event_file.close()
	print("TMB_MASTER_V3_COMBAT_TRACE_FIXTURE PASS groups=%d battles=%d action_events=%d seeds_per_group=%d" % [group_rows.size(),summary_rows.size(),event_rows,SEEDS_PER_GROUP])
	quit(0)
