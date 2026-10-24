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
    var b := _basics(0.5)
    var c := _basics(1.0)
    if not _check(a < b and b < c,"attack cadence must improve monotonically, got %d/%d/%d" % [a,b,c]): return

    var casting := _battle(["thanh_phong_tram"],10003,0.0,1.0,1.0)
    casting.step()
    if not _check(casting.pending_casts.size()==1,"expected pending sword cast"): return
    if not _check(absf(float(casting.pending_casts[0]["ready"])-0.50)<0.00001,"cast_speed ignored"): return
    if not _check(absf(float(casting.actors["d0"]["skill_ready"]["thanh_phong_tram"])-1.65)<0.00001,"cooldown recovery ignored"): return

    var fire := _battle(["hoa_cau"],10004)
    fire.run(18,false)
    if not _check(_events(fire,"status_applied","burn")>=1 and _events(fire,"status_tick","burn")>=2,"burn did not tick"): return
    if not _check(not fire.actors["m0"].get("status_effects",{}).has("burn"),"burn failed to expire"): return

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
