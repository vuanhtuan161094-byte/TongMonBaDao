extends SceneTree

const EXPECTED_COUNTS := {"human":105,"immortal":204,"divine":240}
const VALID_EFFECTS := ["damage","poison","guard","heal","cleanse","mark","consume_poison","mobility","passive","innate"]
var failures := 0
var rows: Array = []

func _init() -> void:
    call_deferred("_run")

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures += 1
        push_error("SKILL_ALL_CATALOGUE_FAIL " + message)

func _run() -> void:
    var catalogues := [
        {"tier":"human","result":V63HumanSkillCombatSystem.load_catalogue()},
        {"tier":"immortal","result":V63ImmortalSkillCombatSystem.load_catalogue()},
        {"tier":"divine","result":V63DivineSkillCombatSystem.load_catalogue()}
    ]
    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var counts := {"human":0,"immortal":0,"divine":0}
    for entry in catalogues:
        var tier := str(entry.get("tier",""))
        var result: Dictionary = entry.get("result",{})
        _check(bool(result.get("ok",false)), "catalogue load failed for " + tier + ": " + str(result.get("errors",[])))
        var data: Dictionary = result.get("data",{})
        _check(not bool(data.get("enabled",true)), "catalogue gate became public/live: " + tier)
        for raw in data.get("skills",[]):
            if not (raw is Dictionary):
                _check(false, "non-dictionary skill in " + tier)
                continue
            var skill: Dictionary = raw
            rows.append(skill)
            var id := str(skill.get("id",""))
            var family_id := str(skill.get("family_id",""))
            var name := str(skill.get("name","")).strip_edges()
            var actual_tier := str(skill.get("generation",skill.get("tier","")))
            var effect := str(skill.get("effect",""))
            _check(not id.is_empty(), "empty skill ID in " + tier)
            if ids.has(id):
                _check(false, "duplicate V63 ID " + id)
            ids[id] = true
            _check(not name.is_empty(), "empty player-facing skill name " + id)
            if names.has(name):
                _check(false, "duplicate player-facing name '%s': %s / %s" % [name,str(names[name]),id])
            names[name] = id
            _check(not family_id.is_empty(), "missing family ID " + id)
            families[family_id] = true
            _check(actual_tier == tier, "generation/tier mismatch " + id + " -> " + actual_tier)
            _check(VALID_EFFECTS.has(effect), "unsupported effect " + id + " -> " + effect)
            counts[tier] = int(counts.get(tier,0)) + 1
    for raw in rows:
        var skill: Dictionary = raw
        var parent_id := str(skill.get("parent_skill_id",""))
        if parent_id.is_empty():
            continue
        var parent := {}
        for candidate in rows:
            if str(candidate.get("id","")) == parent_id:
                parent = candidate
                break
        _check(not parent.is_empty(), "orphan skill parent " + str(skill.get("id","")) + " -> " + parent_id)
        if not parent.is_empty():
            _check(str(parent.get("family_id","")) == str(skill.get("family_id","")),
                "cross-family evolution edge " + str(skill.get("id","")) + " -> " + parent_id)
    var branches := V63HumanSkillCombatSystem.branch_definitions()
    _check(rows.size() == 549 and ids.size() == 549, "expected 549 unique V63 nodes; got " + str(rows.size()) + "/" + str(ids.size()))
    _check(counts == EXPECTED_COUNTS, "tier counts changed: " + str(counts))
    _check(families.size() == 105, "expected 105 unique families, got " + str(families.size()))
    # The nine original branches plus three Sword and three Dao branches are authored on this integration line.
    _check(branches.size() == 15, "expected 15 authored branches, got " + str(branches.size()))
    _check(names.size() == 549, "all 549 player-facing names must be unique")
    _check(V63FeatureGates.all_disabled(), "V63 release gates must remain disabled by default")
    _check(CombatSkillSystem.SKILLS.size() == 9, "legacy CombatSkillSystem baseline changed; audit separately")
    _check(TechniqueSystem.TECHNIQUES.size() == 6, "legacy TechniqueSystem baseline changed; audit separately")
    var sample := V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.human")
    var expected_name := str(sample.get("name",""))
    sample["name"] = "mutated-test-copy"
    _check(str(V63HumanSkillCombatSystem.skill_definition("tmb.skill.poison.doc_cham.active_01.human").get("name","")) == expected_name,
        "skill_definition returned a shared mutable catalogue row")
    print("SKILL_ALL_CATALOGUE_SUMMARY " + JSON.stringify({
        "v63_ids":ids.size(),"families":families.size(),"branches":branches.size(),
        "tiers":counts,"unique_names":names.size(),"failures":failures,
        "legacy_combat_skill_entries":CombatSkillSystem.SKILLS.size(),
        "legacy_technique_entries":TechniqueSystem.TECHNIQUES.size(),
        "release_gates":"OFF",
        "status":"PASS_CATALOGUE_ONLY_NOT_FULL_RUNTIME_OR_GUI_ACCEPTANCE"
    }))
    quit(0 if failures == 0 else 1)
