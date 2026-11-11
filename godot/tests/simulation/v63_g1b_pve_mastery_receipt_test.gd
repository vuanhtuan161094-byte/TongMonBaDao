extends SceneTree

# G1B: real HuntingPveRunV2 has no linked DiscipleState inside battle.
# These focused tests do not grant real loot or enable V6.3 release flags.
const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"
const CODEX_ID := "tmb.codex.bow.liep_anh.ch1_active_01.human.base"
const PREVIEW := {"human_skill_combat": true}
const SAVE_PATH := "user://v63_g1b_pve_mastery_isolated.json"

var checks := 0
var failures := 0

func _init() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> bool:
    checks += 1
    if not ok:
        failures += 1
        push_error("V63_G1B_MASTERY_FAIL " + label)
    return ok

func _run() -> void:
    _cleanup()
    if not _receipt_unit_edges():
        _finish()
        return
    if not _real_pve_and_disk_replay():
        _finish()
        return
    _finish()

func _receipt_unit_edges() -> bool:
    var state := SimulationState.new()
    state.sect.disciple_capacity = 6
    var disciple := DiscipleState.new({"id":"g1b_unit_archer","name":"G1B Unit"})
    state.disciples[disciple.id] = disciple
    var encounter := "g1b_receipt_unit"
    disciple.active_pve_encounter_id = encounter
    disciple.v63_learned_skill_nodes[SKILL_ID] = {
        "source_codex_id":CODEX_ID,"learned_tick":0,
        "mastery_xp":0.0,"level":1,"mastery_cast_receipts":{}
    }
    var actor := {
        "id":str(disciple.id),"side":"disciple","linked_disciple":null,
        "v63_combat_enabled":true,"v63_skill_loadout":[SKILL_ID],"skill_factors":{}
    }
    var battle := MapBattleV2.new(8714)
    battle.encounter_id = encounter
    battle.actors[str(disciple.id)] = actor
    var event_id := encounter + "/" + str(disciple.id) + "/1"
    if not _check(V63HumanSkillCombatSystem.record_cast_mastery(actor, SKILL_ID, event_id),
            "detached PvE actor must create a real receipt instead of discarding mastery"):
        return false
    var old_xp := float(disciple.v63_learned_skill_nodes[SKILL_ID]["mastery_xp"])
    if not _check(old_xp == 0.0 and actor.get("linked_disciple", null) == null,
            "combat must not mutate persistent disciple or link unsafe pointer"):
        return false
    var saved_pending: Dictionary = actor.get("v63_pending_mastery", {}).duplicate(true)
    if not _check(saved_pending.size() == 1 and saved_pending.has(event_id),
            "battle actor must retain the exact cast receipt"):
        return false
    if not _check(not V63HumanSkillCombatSystem.record_cast_mastery(actor, SKILL_ID, event_id),
            "duplicated in-flight receipt must be rejected"):
        return false
    var committed := V63PveMasteryReceipts.settle(state, battle)
    if not _check(bool(committed.get("ok",false)) and int(committed.get("awarded",0)) == 1,
            "canonical owner must settle one meaningful cast"):
        return false
    var first_xp := float(disciple.v63_learned_skill_nodes[SKILL_ID]["mastery_xp"])
    if not _check(is_equal_approx(first_xp,1.0) and
            disciple.v63_learned_skill_nodes[SKILL_ID].get("mastery_cast_receipts",{}).has(event_id) and
            not actor.has("v63_pending_mastery"), "mastery receipt must be durable and ACKed"):
        return false
    # A stale, otherwise valid saved snapshot can present the same pending
    # receipt after a crash/reload; the personal receipt prevents double XP.
    actor["v63_pending_mastery"] = saved_pending.duplicate(true)
    var replay := V63PveMasteryReceipts.settle(state, battle)
    if not _check(bool(replay.get("ok",false)) and int(replay.get("awarded",-1)) == 0
            and is_equal_approx(float(disciple.v63_learned_skill_nodes[SKILL_ID]["mastery_xp"]),first_xp),
            "stale snapshot replay must not award a second mastery point"):
        return false
    var reconstructed := DiscipleState.from_dict(disciple.to_dict())
    if not _check(reconstructed.v63_learned_skill_nodes[SKILL_ID]["mastery_cast_receipts"].has(event_id),
            "cold DiscipleState reconstruction must retain exactly-once receipt"):
        return false
    actor["v63_pending_mastery"] = {"forged": {"skill_id": SKILL_ID, "xp_delta": 1.0}}
    var before_invalid := disciple.v63_learned_skill_nodes.duplicate(true)
    var rejected := V63PveMasteryReceipts.settle(state, battle)
    if not _check(not bool(rejected.get("ok",true)) and before_invalid == disciple.v63_learned_skill_nodes,
            "invalid provenance must fail closed without partial mastery mutation"):
        return false
    actor.erase("v63_pending_mastery")
    # Element identity must be from actual source, never a test-only
    # invented monster affinity or a mutation alias.
    var wood := MonsterCatalogueV2.create_actor("truc_thu",1,1,encounter)
    var earth := MonsterCatalogueV2.create_actor("nham_giap_thu",1,1,encounter)
    var nether := MonsterCatalogueV2.create_actor("hac_lang",1,1,encounter)
    if not _check(str(wood.get("element","")) == "wood"
            and str(earth.get("element","")) == "earth"
            and str(nether.get("element","")) == "nether",
            "real monster catalogue must own true elemental identity"):
        return false
    if not _check(is_equal_approx(V63SpiritualRootEvaluator.elemental_matchup_factor("metal",str(wood.element)),1.25)
            and is_equal_approx(V63SpiritualRootEvaluator.elemental_matchup_factor("wood",str(earth.element)),1.25)
            and is_equal_approx(V63SpiritualRootEvaluator.elemental_matchup_factor("metal",str(nether.element)),1.0),
            "counter logic must respect real base roots and neutral advanced roots"):
        return false
    return true

func _real_pve_and_disk_replay() -> bool:
    var state := P37Factory.create_state(872903)
    state.sect.disciple_capacity = maxi(int(state.sect.disciple_capacity), 24)
    state.sect.v2_pve_enabled = true
    state.sect.v63_skill_combat_opt_in = true
    state.sect.v2_pve_selected_levels["thanh_truc_lam"] = 1
    state.regions[&"thanh_truc_lam"] = RegionState.new({
        "id":"thanh_truc_lam","name":"Thanh Trúc Lâm","danger":1
    })
    var ids: Array[String] = []
    var party: Array = []
    for index in range(6):
        var disciple := DiscipleState.new({"id":"g1b_real_%02d" % index,"name":"G1B Archer"})
        disciple.v63_learned_skill_nodes[SKILL_ID] = {
            "source_codex_id":CODEX_ID,"learned_tick":0,
            "mastery_xp":0.0,"level":1,"mastery_cast_receipts":{}
        }
        disciple.v63_equipped_skill_ids = [SKILL_ID]
        disciple.v63_combat_branch_id = &"liep_anh"
        state.disciples[disciple.id] = disciple
        ids.append(str(disciple.id))
        party.append({"disciple_id":str(disciple.id),"party_id":"g1b_real",
            "role":"ranged","position":Vector2(8.0+float(index%3)*1.5,
                8.0+float(int(index/3))*1.5),
            "realm":1,"floor":1,"body_realm":1,"body_floor":1})
    var run := HuntingPveRunV2.new()
    var begun := run.begin(state,"thanh_truc_lam","g1b_real_mastery_run",872904,party,"",PREVIEW)
    if not _check(bool(begun.get("ok",false)),
            "authentic HuntingPveRunV2.begin must work: " + str(begun)):
        return false
    for disciple_id in ids:
        if not _check(run.battle.actors[disciple_id].get("linked_disciple",null) == null,
                "live PvE actor must remain detached from DiscipleState"):
            return false
    var authentic_monsters := 0
    for actor_value in run.battle.actors.values():
        var opponent: Dictionary = actor_value
        if str(opponent.get("side","")) != "monster":
            continue
        authentic_monsters += 1
        var source: Dictionary = MonsterCatalogueV2.SPECIES.get(str(opponent.get("species_id","")),{})
        if not _check(not source.is_empty()
                and str(opponent.get("primary_element","")) == str(source.get("element",""))
                and CombatStatsV2.ELEMENTS.has(str(source.get("element",""))),
                "real HuntingPveRunV2 target must inherit actual species element"):
            return false
    if not _check(authentic_monsters > 0, "real PvE encounter must spawn catalogue monsters"):
        return false
    var finished := run.finish(400)
    if not _check(bool(finished.get("ok",false)) or
            str(finished.get("reason","")) == "encounter_still_active",
            "PvE run failed before mastery settlement: " + str(finished)):
        return false
    var awards := 0
    var original_xp: Dictionary = {}
    for disciple_id in ids:
        var xp := float(state.disciples[StringName(disciple_id)].v63_learned_skill_nodes[SKILL_ID].get("mastery_xp",0.0))
        original_xp[disciple_id] = xp
        if xp > 0.0:
            awards += 1
    if not _check(awards > 0, "real PvE casts must settle mastery on at least one disciple"):
        return false
    var repeat_settlement := V63PveMasteryReceipts.settle(state,run.battle)
    if not _check(bool(repeat_settlement.get("ok",false)) and
            int(repeat_settlement.get("awarded",-1)) == 0,
            "PvE receipt ACK must be idempotent"):
        return false
    for disciple_id in ids:
        if not _check(is_equal_approx(original_xp[disciple_id],
                float(state.disciples[StringName(disciple_id)].v63_learned_skill_nodes[SKILL_ID]["mastery_xp"])),
                "duplicate settlement changed persisted mastery"):
            return false
    var save_result := SaveService.new().save_to_path(state,SAVE_PATH)
    if not _check(save_result == OK, "isolated canonical SaveService cold-write failed"):
        return false
    var loaded := SaveService.new().load_from_path(SAVE_PATH)
    if not _check(loaded != null, "isolated canonical SaveService cold-read failed"):
        return false
    for disciple_id in ids:
        var original: DiscipleState = state.disciples[StringName(disciple_id)]
        var cold: DiscipleState = loaded.disciples[StringName(disciple_id)]
        var cold_record: Dictionary = cold.v63_learned_skill_nodes[SKILL_ID]
        var live_record: Dictionary = original.v63_learned_skill_nodes[SKILL_ID]
        if cold_record != live_record:
            print("V63_G1B_COLD_DIFF " + JSON.stringify({
                "disciple_id":disciple_id,
                "cold":cold_record,"live":live_record,
                "cold_xp":float(cold_record.get("mastery_xp",-1.0)),
                "live_xp":float(live_record.get("mastery_xp",-1.0)),
                "cold_receipts":cold_record.get("mastery_cast_receipts",{}),
                "live_receipts":live_record.get("mastery_cast_receipts",{})
            }))
        # SaveService's JSON represents integral scalars as 0.0/1.0 on read.
        # Normalize ONLY the schema-declared integer fields and still compare
        # every field, every mastery receipt ID and the exact mastery XP.
        var canonical_disk_record := cold_record.duplicate(true)
        for key in ["learned_tick","level"]:
            var raw_value = cold_record.get(key, null)
            if not _check((raw_value is int or raw_value is float)
                    and is_finite(float(raw_value))
                    and absf(float(raw_value)-float(int(raw_value))) < 0.000001,
                    "cold SaveService changed an integer mastery field: " + key):
                return false
            canonical_disk_record[key] = int(raw_value)
        if not _check(canonical_disk_record == live_record,
                "cold SaveService must preserve every per-skill field and exact receipt history"):
            return false
    if not _check(V63FeatureGates.all_disabled(), "release gates must remain OFF"):
        return false
    return true

func _cleanup() -> void:
    for path in [SAVE_PATH, SAVE_PATH + ".tmp", SAVE_PATH + ".bak"]:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _finish() -> void:
    print("V63_G1B_PVE_MASTERY_SUMMARY " + JSON.stringify({
        "checks": checks,"failures": failures,
        "status": "PASS" if failures == 0 else "FAIL",
        "scope": "detached live PvE mastery, receipt replay, source elements, isolated SaveService"
    }))
    _cleanup()
    quit(1 if failures > 0 else 0)
