extends SceneTree

const SKILL_ID := "tmb.skill.bow.liep_anh.active_01.human"
const CODEX_ID := "tmb.codex.bow.liep_anh.ch1_active_01.human.base"

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("V63_D4A_STATE_ROUNDTRIP_FAIL: "+message)
    quit(1)

func _run() -> void:
    var legacy := DiscipleState.from_dict({"id":"legacy_d4"})
    if not legacy.v63_learned_skill_nodes.is_empty() or not legacy.v63_equipped_skill_ids.is_empty():
        _fail("legacy disciple synthesized D4 personal skill records")
        return
    var legacy_dict := legacy.to_dict()
    if legacy_dict.has("v63_learned_skill_nodes") or legacy_dict.has("v63_equipped_skill_ids"):
        _fail("empty legacy D4 fields changed the old disciple save envelope")
        return
    var state := SimulationState.new()
    state.sect.v63_skill_combat_opt_in = true
    var disciple := DiscipleState.new({"id":"saved_d4"})
    disciple.v63_learned_skill_nodes[SKILL_ID] = {"source_codex_id":CODEX_ID,"learned_tick":12,"mastery_xp":25.0}
    disciple.v63_equipped_skill_ids = [SKILL_ID]
    state.disciples[disciple.id] = disciple
    var restored := SimulationState.from_dict(state.to_dict())
    if restored == null:
        _fail("SimulationState rejected an additive D4 save")
        return
    var copy: DiscipleState = restored.disciples[&"saved_d4"]
    if copy.v63_learned_skill_nodes != disciple.v63_learned_skill_nodes or copy.v63_equipped_skill_ids != disciple.v63_equipped_skill_ids:
        _fail("D4 personal knowledge/loadout did not round-trip")
        return
    if not restored.sect.v63_skill_combat_opt_in:
        _fail("per-save D4 opt-in did not round-trip")
        return
    if V63FeatureGates.is_enabled("human_skill_combat"):
        _fail("feature gate stopped defaulting OFF after state round-trip")
        return
    print("V63 D4-A STATE ROUNDTRIP PASS: legacy empty defaults and additive personal knowledge/loadout")
    quit(0)
