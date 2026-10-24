extends SceneTree

# S1 focused fixture: intended for official Godot 4.7.2, isolated userdata.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, reason: String) -> bool:
    if not ok:
        push_error("COMBAT_V3_S1_FAIL: "+reason)
        quit(1)
    return ok

func _player(skills: Array, speed: float = 0.0, cast_rate: float = 0.0, cd_rate: float = 0.0, fraction: float = 1.0) -> Dictionary:
    var stats: Dictionary = CombatStatsV2.derive(1,1,1,1,0.0)["stats"].duplicate(true)
    stats["max_hp"] = 10000.0
    stats["attack"] = 100.0
    stats["defense"] = 200.0
    stats["attack_speed"] = speed
    stats["cast_speed"] = cast_rate
    stats["cooldown_recovery"] = cd_rate
    return {"id":"d0","party_id":"p0","role":"ranged",
        "position":Vector2(10,10),"stats":stats,"hp":10000.0*fraction,
        "basic_range":1.9,"basic_interval":1.1,
        "skill_loadout":skills,"skill_factors":{}}

func _monster() -> Dictionary:
    var m := MonsterCatalogueV2.create_actor("thanh_lang",1,1,"s1_m")
    m["id"] = "m0"
    m["position"] = Vector2(12,10)
    m["stats"] = m["stats"].duplicate(true)
    m["stats"]["max_hp"] = 100000.0
    m["stats"]["attack"] = 1.0
    m["hp"] = 100000.0
    return m

func _battle(skills: Array, seed: int = 10001, speed: float = 0.0, cast_rate: float = 0.0, cd_rate: float = 0.0, fraction: float = 1.0) -> MapBattleV2:
    var b := MapBattleV2.new(seed)
    if not bool(b.setup("s1_case",[_player(skills,speed,cast_rate,cd_rate,fraction)],[_monster()]).get("ok",false)):
        push_error("S1 fixture setup invalid")
        quit(1)
    return b

func _events(b: MapBattleV2, typ: String, id: String = "") -> int:
    var count := 0
    for e in b.events:
        if str(e.get("type","")) != typ:
            continue
        if not id.is_empty() and str(e.get("status",e.get("skill_id",""))) != id:
            continue
        count += 1
    return count

func _basics(speed: float) -> int:
    var b := _battle([],10002,speed)
    b.run(120,false)
    var count := 0
    for e in b.events:
        if str(e.get("type","")) == "hit" and str(e.get("attacker","")) == "d0" and str(e.get("kind","")) == "basic":
            count += 1
    return count

func _run() -> void:
    var a := _basics(0.0)
    var b := _basics(0.2)
    var c := _basics(0.5)
    var d := _basics(1.0)
    if not _check(a < b and b < c and c < d,"attack cadence must improve monotonically, got %d/%d/%d/%d" % [a,b,c,d]): return
    if not _check(_basics(-0.5) < a and _basics(-1.0) == 0,
        "negative attack speed must slow cadence, and -100% must not become max-speed attacks"): return
    var extreme := _battle([],10012,10.0)
    extreme.run(120,false)
    var times := {}
    var duplicate_step := false
    for event in extreme.events:
        if str(event.get("type","")) != "hit" or str(event.get("attacker","")) != "d0" or str(event.get("kind","")) != "basic":
            continue
        var time_key := str(event.get("time",-1.0))
        if times.has(time_key):
            duplicate_step = true
        times[time_key] = true
    if not _check(not duplicate_step and times.size() <= 120,
        "extreme attack speed must remain capped at one basic hit per simulation step"): return

    var cadence_live := _battle([],10014,0.5)
    cadence_live.run(7,false)
    var cadence_snapshot := MapBattleSnapshotV2.save(cadence_live)
    var cadence_restored := MapBattleSnapshotV2.load(cadence_snapshot)
    if not _check(bool(cadence_restored.get("ok",false)),"mid-cadence snapshot restore failed"): return
    cadence_live.run(40,false)
    var cadence_resume: MapBattleV2 = cadence_restored["battle"]
    cadence_resume.run(40,false)
    if not _check(MapBattleSnapshotV2.save(cadence_live)==MapBattleSnapshotV2.save(cadence_resume),
        "fractional attack deadline diverged after save/load"): return

    var casting := _battle(["thanh_phong_tram"],10003,0.0,1.0,1.0)
    casting.step()
    if not _check(casting.pending_casts.size()==1,"expected pending sword cast"): return
    if not _check(absf(float(casting.pending_casts[0]["ready"])-0.50)<0.00001,"cast_speed ignored"): return
    if not _check(absf(float(casting.actors["d0"]["skill_ready"]["thanh_phong_tram"])-1.65)<0.00001,"cooldown recovery ignored"): return
    if not _check(absf(float(casting.pending_casts[0]["ratio"])-1.35)<0.00001,
        "Thanh Phong Trảm attack multiplier changed"): return
    var basic_hits_during_cast := 0
    for event in casting.events:
        if str(event.get("type","")) == "hit" and str(event.get("attacker","")) == "d0" and str(event.get("kind","")) == "basic":
            basic_hits_during_cast += 1
    if not _check(basic_hits_during_cast == 0,
        "basic attack was not held while the learned cast was pending"): return
    var cast_saved := MapBattleSnapshotV2.save(casting)
    var cast_loaded := MapBattleSnapshotV2.load(cast_saved)
    if not _check(bool(cast_loaded.get("ok",false)),"pending learned cast snapshot restore failed"): return
    casting.run(12,false)
    var cast_resume: MapBattleV2 = cast_loaded["battle"]
    cast_resume.run(12,false)
    if not _check(MapBattleSnapshotV2.save(casting)==MapBattleSnapshotV2.save(cast_resume),
        "pending learned cast diverged after save/load"): return

    var sword := _battle(["ngu_kiem_thuat"],10008)
    sword.actors["m0"]["position"] = Vector2(17,10)
    sword.step()
    if not _check(sword.pending_casts.size()==1,"Ngự Kiếm Thuật did not cast at its range boundary"): return
    if not _check(absf(float(sword.pending_casts[0]["ratio"])-1.70)<0.00001 and
        absf(float(sword.pending_casts[0]["ready"])-1.60)<0.00001,
        "Ngự Kiếm Thuật ratio/projectile delay changed"): return
    sword.run(7,false)
    if not _check(_events(sword,"skill_hit","ngu_kiem_thuat")==1,
        "Ngự Kiếm Thuật projectile failed to release exactly once"): return

    var out_of_range := _battle(["ngu_kiem_thuat"],10009)
    out_of_range.actors["m0"]["position"] = Vector2(17.1,10)
    out_of_range.step()
    if not _check(out_of_range.pending_casts.is_empty() and _events(out_of_range,"skill_cast")==0,
        "Ngự Kiếm Thuật cast beyond its authored range"): return

    var dead_target := _battle(["thanh_phong_tram"],10010,0.0,1.0)
    dead_target.step()
    dead_target.actors["m0"]["hp"] = 0.0
    dead_target.step()
    if not _check(_events(dead_target,"skill_hit","thanh_phong_tram")==0 and
        dead_target.pending_casts.is_empty(),"cast released against a dead target"): return

    var dead_caster := _battle(["thanh_phong_tram"],10011,0.0,1.0)
    dead_caster.step()
    dead_caster.actors["d0"]["hp"] = 0.0
    dead_caster.step()
    if not _check(_events(dead_caster,"skill_hit","thanh_phong_tram")==0 and
        dead_caster.pending_casts.is_empty(),"pending cast released after its caster was downed"): return

    var fire := _battle(["hoa_cau"],10004)
    fire.actors["m0"]["resistances"]["fire"] = 0.5
    var expected_dot: Dictionary = CombatStatsV2.resolve_direct_hit(
        fire.actors["d0"]["stats"],fire.actors["m0"]["stats"],
        fire.actors["m0"]["resistances"],0.16,false,"fire",1.0,false
    )
    fire.run(18,false)
    if not _check(_events(fire,"status_applied","burn")>=1 and _events(fire,"status_tick","burn")>=2,"burn did not tick"): return
    if not _check(not fire.actors["m0"].get("status_effects",{}).has("burn"),"burn failed to expire"): return
    var dot_damage := -1.0
    var tick_times: Array[float] = []
    for event in fire.events:
        if str(event.get("type","")) == "hit" and str(event.get("kind","")) == "dot" and dot_damage < 0.0:
            dot_damage = float(event.get("damage",0.0))
        if str(event.get("type","")) == "status_tick" and str(event.get("status","")) == "burn":
            tick_times.append(float(event.get("time",-1.0)))
    if not _check(absf(dot_damage-float(expected_dot.get("damage",-100.0)))<0.00001,
        "burn did not use canonical direct damage with fire resistance"): return
    for index in range(1,tick_times.size()):
        if not _check(absf(tick_times[index]-tick_times[index-1]-1.0)<0.00001,
            "burn tick cadence must be one combat second"): return

    var weak := _battle(["han_suong_an"],10005)
    weak.run(10,false)
    if not _check(_events(weak,"status_applied","weaken")>=1,"debuff missing"): return

    var guard := _battle(["kim_cuong_ho_the"],10006,0.0,0.0,0.0,0.70)
    guard.run(5,false)
    if not _check(_events(guard,"status_applied","guard")>=1,"learned guard missing"): return
    if not _check(float(guard.actors["d0"].get("learned_guard_factor",1.0))<=0.62,"learned guard mitigation missing"): return

    var live := _battle(["hoa_cau"],10007)
    live.run(8,false)
    var snap := MapBattleSnapshotV2.save(live)
    var restored := MapBattleSnapshotV2.load(snap)
    if not _check(bool(restored.get("ok",false)),"failed to restore status snapshot"): return
    var resume: MapBattleV2 = restored["battle"]
    live.run(8,false)
    resume.run(8,false)
    if not _check(MapBattleSnapshotV2.save(live)==MapBattleSnapshotV2.save(resume),"status replay diverged"): return
    print("COMBAT_V3_S1_FOCUSED_PASS")
    quit(0)
