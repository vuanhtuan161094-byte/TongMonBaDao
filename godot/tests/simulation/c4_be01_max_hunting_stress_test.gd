extends SceneTree

# C4-BE01 MAX-STRESS: isolated memory-only battle, NEVER live user save.
# 30 disciples = five teams of six, 40 real monsters, Tu Vi and Body 30x10.
# Full *supported* active skill spectrum: five pilot JX1 types + two P2
# direct-damage types, with guarded non-damage P2 skills explicitly deferred.
func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, why: String) -> bool:
    if not ok:
        push_error("C4-BE01 MAX STRESS: "+why)
        quit(1)
    return ok

func _setup(seed: int) -> MapBattleV2:
    var party: Array = []
    var monsters: Array = []
    var cores: Dictionary = CombatStatsV2.derive(30,10,30,10,100.0)
    if not bool(cores.get("ok",false)):
        return null
    # At most four pilot slots; five different JX skills spread across
    # five real party members. The two authored P2 damage skills are
    # equipped on OTHER actors: no illegal mixed pilot + learned bar.
    var jx_skills := [
        ["jx_shaolin_15"],["jx_wudang_158","jx_wudang_159"],
        ["jx_wudu_63"],["jx_emei_93"],[]
    ]
    for i in range(MapBattleV2.MAX_DISCIPLES):
        var role := ["frontline","ranged","mage","healer","frontline","mage"][i%6]
        var actor := {
            "id":"max_disc_%02d" % i,
            "party_id":"max_team_%02d" % int(i/6),
            "role":role,
            "position":Vector2(2.0+float(i%6)*0.90,2.0+float(i/6)*3.0),
            "stats":cores["stats"].duplicate(true),
            "resistances":cores["resistances"].duplicate(true),
            "hp":float(cores["stats"]["max_hp"]),
            "move_speed":3.0,
            "pilot_skill_loadout":[],
            "skill_loadout":[]
        }
        if i < jx_skills.size():
            actor["pilot_skill_loadout"] = jx_skills[i].duplicate()
        elif i % 2 == 0:
            actor["skill_loadout"] = ["ngu_kiem_thuat","thanh_phong_tram"]
        party.append(actor)
    for i in range(MapBattleV2.MAX_MONSTERS):
        var species := "hac_lang_vuong" if i == 0 else (
            "nham_giap_thu" if i%8 == 0 else (
            "huyet_lang_dau_dan" if i%11 == 0 else "thanh_lang"))
        var creature := MonsterCatalogueV2.create_actor(
            species,30,10,"max_monster_%02d" % i)
        if not bool(creature.get("ok",false)):
            return null
        creature["id"] = "max_monster_%02d" % i
        creature["position"] = Vector2(19.0+float(i%8)*1.1,1.7+float(i/8)*3.4)
        monsters.append(creature)
    var battle := MapBattleV2.new(seed)
    if not bool(battle.setup("max_30v40_30x10",party,monsters).get("ok",false)):
        return null
    return battle

func _run() -> void:
    var source := _setup(1901940)
    if not _check(source != null,"max encounter setup or realm derivation failed"):
        return
    if not _check(source.actors.size() == 70 and
            JxPilotSkillsV1.SKILLS.size() == 5 and
            CombatSkillSystem.SKILLS.size() == 9,
            "full actor/skill catalogue fixture mismatch"):
        return
    var seen_pilot: Dictionary = {}
    var seen_learned: Dictionary = {}
    for actor in source.actors.values():
        if str(actor.get("side","")) != "disciple":
            continue
        for skill_id in actor.get("pilot_loadout",[]):
            seen_pilot[str(skill_id)] = true
        for skill_id in actor.get("skill_loadout",[]):
            seen_learned[str(skill_id)] = true
    if not _check(seen_pilot.size() == JxPilotSkillsV1.SKILLS.size() and
            seen_learned.has("ngu_kiem_thuat") and
            seen_learned.has("thanh_phong_tram"),
            "not all implemented active pilot/learned skills covered"):
        return
    # Important: seven P2 skills have real LEARN definitions but no
    # active effect consumer in MapBattleV2. Tests do NOT fake activation.
    var deferred_count := 0
    for skill in CombatSkillSystem.SKILLS.values():
        if str(skill.get("effect","")) != "damage":
            deferred_count += 1
    if not _check(deferred_count == 7,"unimplemented learned skill effects must remain explicit"):
        return

    # Check deterministic resume midfight at the ACTUAL maximum payload.
    for i in range(3):
        if source.active:
            source.step(false)
    var before_rng := source.rng.snapshot_seed_state()
    var snapshot := MapBattleSnapshotV2.save(source)
    if not _check(bool(snapshot.get("ok",false)),"max checkpoint not saved"):
        return
    var reloaded := MapBattleSnapshotV2.load(
        JSON.parse_string(JSON.stringify(snapshot)))
    if not _check(bool(reloaded.get("ok",false)),
            "max checkpoint not restored: "+str(reloaded.get("reason","unknown"))):
        return
    var replay: MapBattleV2 = reloaded["battle"]
    if not _check(replay.actors.size() == 70 and
            replay.rng.snapshot_seed_state() == before_rng,
            "max load lost actors or RNG"):
        return

    var first := source.run(400,false)
    var second := replay.run(400,true)
    if not _check(first == second,"30v40 max-level combat diverged across render flag/restore"):
        return
    if not _check(first["outcome"] in ["win","defeat","timeout_retreat"] and
            source.events.size() <= MapBattleV2.MAX_EVENTS,
            "invalid terminal outcome or journal cap at 30v40"):
        return
    var basic_or_skill_hits := 0
    for event in source.events:
        if str(event.get("type","")) == "hit":
            basic_or_skill_hits += 1
        if str(event.get("type","")) == "area_release" and \
                int(event.get("target_count",0)) > MapBattleV2.MAX_TARGETS_AOE:
            if not _check(false,"max AoE exceeded three real targets"):
                return
    if not _check(basic_or_skill_hits > 0,"max test performed no real combat"):
        return
    # Negative boundary: 31st disciple and 41st monster must be rejected.
    # Build from existing valid actor dictionaries, changing only actor count.
    var party_rows: Array = []
    var monster_rows: Array = []
    for actor_id in replay.actors.keys():
        var actor: Dictionary = replay.actors[actor_id]
        if str(actor.get("side","")) == "disciple":
            party_rows.append(actor.duplicate(true))
        else:
            monster_rows.append(actor.duplicate(true))
    var one_more_disciple: Dictionary = party_rows[0].duplicate(true)
    one_more_disciple["id"] = "overflow_disciple"
    one_more_disciple["party_id"] = "overflow_team"
    party_rows.append(one_more_disciple)
    var one_more_monster: Dictionary = monster_rows[0].duplicate(true)
    one_more_monster["id"] = "overflow_monster"
    monster_rows.append(one_more_monster)
    var rejected_party := MapBattleV2.new(1901)
    if not _check(not bool(rejected_party.setup("reject_party",party_rows,
            monster_rows.slice(0,40)).get("ok",true)),
            "31st disciple admitted past MAX_DISCIPLES"):
        return
    party_rows.pop_back()
    var rejected_monsters := MapBattleV2.new(1902)
    if not _check(not bool(rejected_monsters.setup("reject_monsters",party_rows,
            monster_rows).get("ok",true)),
            "41st monster admitted past MAX_MONSTERS"):
        return
    print("C4-BE01 MAX 30v40 / TUVI 30x10 / BODY 30x10 / LEGAL SKILLS / SAVE+REPLAY: PASS")
    quit(0)
