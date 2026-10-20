class_name Jxqy2DemoProfileV1
extends RefCounted

# Explicit initial sandbox profile, never a migration or a new learning rule.
# The first factory hunter already owns a canonically crafted/equipped sword.
static func create() -> Dictionary:
    var built := DemoSandboxFactoryV1.create_max_state(DemoSandboxFactoryV1.SEED)
    if not bool(built.get("ok",false)):
        return built
    var state: SimulationState = built["state"]
    var id := StringName(str(built["hunter_ids"][0]))
    var hunter: DiscipleState = state.disciples[id]
    hunter.cultivation_stage_index = 9
    CultivationSystem.new().initialize(state)
    var skills := CombatSkillSystem.new()
    if not skills.learn_skill(state,hunter,&"ngu_kiem_thuat"):
        return {"ok":false,"reason":"jxqy2_profile_legal_skill_failed"}
    var weapon := EquipmentSystem.new().equipped_item(state,hunter,EquipmentSystem.SLOT_WEAPON)
    if str(weapon.get("path","")) != "sword":
        return {"ok":false,"reason":"jxqy2_profile_requires_existing_sword_visual"}
    built["source_hunter_id"] = str(id)
    built["source_profile_note"] = "Isolated initial P2 stage-9 seed, normalized by CultivationSystem, then learned through CombatSkillSystem. V2 tracks remain factory MAX 30.10/30.10."
    return built

static func policy(state: SimulationState, hunter: DiscipleState) -> Dictionary:
    var owned: Array = []
    var skills := CombatSkillSystem.new()
    for id in skills.usable_skills(state,hunter):
        if str(skills.definition(id).get("effect","")) == "damage":
            owned.append(str(id))
    var result := AutoSkillPolicyV2.default_policy(owned)
    for row in result["skills"]:
        row["enabled"] = str(row["canonical_skill_id"]) == "ngu_kiem_thuat"
        row["conditions"]["target_tiers"] = ["boss"]
    return {"owned":owned,"policy":result}
