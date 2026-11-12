extends SceneTree

# S7 Chú: candidate Combat V2 integration. Canonical source and balance
# remain pending; production feature gate and all skill-learning remain OFF.
const Curse = preload("res://src/simulation/combat/v63_curse_skill_combat_system.gd")
const Palm = preload("res://src/simulation/combat/v63_palm_skill_combat_system.gd")
const HSC = preload("res://src/simulation/combat/v63_human_skill_combat_system.gd")
const Presentation = preload("res://src/presentation/v63_skill_presentation_catalog_v1.gd")
const Gates = preload("res://src/simulation/combat/v63_feature_gates.gd")

var _checks := 0
var _failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _expect(condition: bool, label: String) -> void:
    _checks += 1
    if not condition:
        _failures += 1
        push_error("V63_S7_CURSE_FAIL " + label)

func _run() -> void:
    var loaded := Curse.load_catalogue()
    _expect(bool(loaded.get("ok", false)), "S7 Chú catalogue validates: " + str(loaded.get("errors", [])))
    if not bool(loaded.get("ok", false)):
        _finish()
        return
    var catalogue: Dictionary = loaded.data
    var skills: Array = catalogue.get("skills", [])
    var sources := Presentation.load_authoring_sources()
    _expect(bool(sources.get("ok", false)), "all S0–S7 source pins and additive extension join: " + str(sources.get("errors", [])))
    if not bool(sources.get("ok", false)):
        _finish()
        return
    var catalogues: Dictionary = sources.catalogues
    var registry: Dictionary = sources.registry
    var manifest: Dictionary = sources.manifest
    var entries: Dictionary = manifest.get("entries", {})
    _expect(catalogues.has("curse") and catalogues.has("talisman") and entries.size() == 1285,
        "Curse joins seven gated schools and the retained source samples")
    _expect(registry.get("school_count", 0) == 10 and registry.get("branch_count", 0) == 30
        and registry.get("skill_family_count", 0) == 350,
        "merged registry has ten schools, thirty paths and 350 families")
    _expect(HSC.skill_definitions().size() == 1830 and HSC.branch_definitions().size() == 30,
        "shared Combat V2 indexes existing and gated nodes with all branches")
    _expect(not bool(catalogue.get("enabled", true)) and str(catalogue.get("release_gate", "")) == "OFF",
        "Chú and V6.3 production stay disabled")
    var blocked := Curse.can_learn(Curse.skill_definition("tmb.skill.curse.tran_hon_chu.active_01.human"))
    _expect(not Gates.is_enabled("curse_skill_combat") and not bool(blocked.get("ok", true))
        and str(blocked.get("reason", "")) == "skill_source_pending",
        "default combat is closed and unverified manuals cannot teach a skill")

    var ids: Dictionary = {}
    var names: Dictionary = {}
    var families: Dictionary = {}
    var flavors: Dictionary = {}
    var short_texts: Dictionary = {}
    var long_texts: Dictionary = {}
    var motion_profiles: Dictionary = {}
    var branch_counts := {"tran_hon_chu":0, "phe_linh_chu":0, "ho_menh_chu":0}
    var tier_counts := {"human":0, "immortal":0, "divine":0}
    var phases_required := ["windup", "telegraph", "release", "travel", "impact", "status", "fade"]
    for raw_skill in skills:
        var skill: Dictionary = raw_skill
        var id := str(skill.get("id", ""))
        var name := str(skill.get("name", ""))
        var branch := str(skill.get("branch", ""))
        var slot := str(skill.get("slot", ""))
        var effect := str(skill.get("effect", ""))
        var entry: Dictionary = entries.get(id, {})
        var flavor := str(entry.get("flavor_vi", ""))
        var short := str(entry.get("short_description_vi", ""))
        var long := str(entry.get("long_description_vi", ""))
        var counterplay := str(entry.get("counterplay_vi", ""))
        var brief: Dictionary = entry.get("vfx", {}).get("production_brief", {})
        var phase_rows: Array = brief.get("phases", [])
        var actual_phases: Array[String] = []
        var phase_event: Dictionary = {}
        for phase_row in phase_rows:
            actual_phases.append(str(phase_row.get("phase", "")))
            phase_event[str(phase_row.get("phase", ""))] = str(phase_row.get("event_type", ""))
        _expect(not id.is_empty() and id.begins_with("tmb.skill.curse.") and not ids.has(id)
            and str(skill.get("node_id", "")) == id, "stable unique skill ID: " + id)
        _expect(not name.is_empty() and not names.has(name), "unique Vietnamese/Hán Việt name: " + id)
        _expect(str(skill.get("source_codex_id", "")).is_empty() and not bool(skill.get("archivable", true))
            and str(skill.get("candidate_status", "")) == "CANDIDATE_GATED_SOURCE_PENDING",
            "unknown manual stays non-archivable: " + id)
        _expect(not short.is_empty() and short.length() <= 110 and not long.is_empty()
            and not counterplay.is_empty() and not short.contains("TODO") and not long.contains("TODO"),
            "Vietnamese skill function, detailed explanation and counterplay: " + id)
        var prose_has_digit := false
        for digit in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
            prose_has_digit = prose_has_digit or (flavor.contains(digit) or short.contains(digit) or long.contains(digit) or counterplay.contains(digit))
        _expect(not prose_has_digit and flavor.length() >= 50 and flavor.length() <= 110,
            "brief xianxia flavor has no numeric placeholder: " + id)
        var lore_branch := branch if not branch.is_empty() else "common"
        _expect(str(entry.get("school_lore_id", "")) == "tmb.lore.school.curse"
            and str(entry.get("branch_lore_id", "")) == "tmb.lore.branch.curse." + lore_branch,
            "school and branch story identity joins: " + id)
        var availability: Dictionary = entry.get("availability", {})
        _expect(str(availability.get("status", "")) == "CANDIDATE_GATED_SOURCE_PENDING"
            and str(availability.get("source_codex_id", "")).is_empty()
            and not bool(availability.get("archivable", true)),
            "presentation cannot claim an absent canonical Chú manual: " + id)
        var qa_status: Dictionary = entry.get("qa_status", {})
        var ai_policy: Dictionary = entry.get("ai_policy", {})
        _expect(str(qa_status.get("authoring", "")) == "AUTHORING_COMPLETE"
            and str(qa_status.get("runtime", "")) == "CANDIDATE_GATED_RUNTIME"
            and str(qa_status.get("behavior", "")) == "PARTIAL_BRANCH_EXERCISE_PENDING_PER_ID"
            and str(qa_status.get("vfx_metadata", "")) == "TEXT_ONLY_SPEC_READY"
            and str(ai_policy.get("status", "")) == "CANDIDATE_RUNTIME_POLICY; SOURCE/BALANCE PENDING",
            "candidate status is precise; per-ID behavior remains unaudited: " + id)
        _expect(actual_phases == phases_required
            and str(brief.get("asset_status", "")) == "NOT_PRESENT"
            and str(brief.get("render_capture_status", "")) == "NOT_CAPTURED"
            and str(brief.get("visual_acceptance_status", "")) == "PENDING"
            and str(brief.get("provenance", "")).begins_with("TEXT_ONLY_VFX_SPEC"),
            "seven-phase VFX brief stays text-only under per-skill approval hold: " + id)
        _expect(str(phase_event.get("fade", "")) == "none" and str(phase_event.get("travel", "")) == "none",
            "no unimplemented travel or fade visual is claimed: " + id)
        _expect(bool(Presentation.presentation_for(id, manifest, catalogues).get("ok", false)),
            "presentation binds to the actual runtime node: " + id)
        var tooltip := Presentation.build_mechanics_tooltip(skill)
        _expect(bool(tooltip.get("ok", false)) and not str(tooltip.get("text", "")).is_empty(),
            "mechanics numbers derive from candidate runtime fields: " + id)
        if slot in ["passive", "innate"]:
            _expect(str(skill.get("effect", "")) == slot and not skill.get("passive_modifiers", {}).is_empty(),
                "passive/innate has its bounded consumed effect: " + id)
        ids[id] = true
        names[name] = true
        families[str(skill.get("family_id", ""))] = true
        flavors[flavor] = true
        short_texts[short] = true
        long_texts[long] = true
        motion_profiles[str(brief.get("motion_profile", ""))] = true
        if branch_counts.has(branch):
            branch_counts[branch] = int(branch_counts[branch]) + 1
        var tier := str(skill.get("generation", ""))
        if tier_counts.has(tier):
            tier_counts[tier] = int(tier_counts[tier]) + 1
        var expected_status_event := "none"
        if effect == "mark":
            expected_status_event = "v63_curse_mark_applied"
        elif effect == "slow":
            expected_status_event = "v63_curse_slow_applied"
        elif effect == "guard":
            expected_status_event = "v63_curse_guard_applied"
        elif effect == "heal":
            expected_status_event = "v63_curse_heal_applied"
        elif effect == "cleanse":
            expected_status_event = "v63_curse_cleanse_applied"
        _expect(str(phase_event.get("status", "")) == expected_status_event,
            "text-only status phase names the real receipt for " + id)
    _expect(ids.size() == 183 and names.size() == 183 and families.size() == 35,
        "183 unique runtime nodes/names resolve to exactly 35 families")
    _expect(branch_counts == {"tran_hon_chu":59, "phe_linh_chu":59, "ho_menh_chu":59},
        "Trấn Hồn / Phệ Linh / Hộ Mệnh each own 59 evolution nodes")
    _expect(tier_counts == {"human":35, "immortal":68, "divine":80},
        "evolution has 35 Human / 68 Tiên / 80 Thần nodes")
    _expect(flavors.size() == 183 and short_texts.size() == 183 and long_texts.size() == 183
        and motion_profiles.size() == 183, "individual text and VFX brief per node")
    var branch_signatures := {
        "tran_hon_chu":"Cửu U Trấn Hồn Đại Chú",
        "phe_linh_chu":"Vạn Hồn Phệ Linh",
        "ho_menh_chu":"Thái Thượng Hộ Mệnh Chú"
    }
    for branch_row in catalogue.get("branches", []):
        var branch_id := str(branch_row.get("id", ""))
        _expect(str(branch_row.get("signature_ultimate", "")) == str(branch_signatures.get(branch_id, ""))
            and str(branch_row.get("story_vi", "")).length() >= 200,
            "branch story and signature are authored: " + branch_id)

    var matrix := FileAccess.open(ProjectSettings.globalize_path("res://../docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv"), FileAccess.READ)
    _expect(matrix != null, "all36 ID/effect ledger is readable")
    if matrix != null:
        var ledger := Presentation.validate_all36_ledger(matrix.get_as_text(), catalogues, registry)
        _expect(bool(ledger.get("ok", false)), "2,196 ledger rows join runtime candidates and remaining slots: " + str(ledger.get("errors", [])))
        var metrics: Dictionary = ledger.get("metrics", {})
        _expect(int(metrics.get("existing", 0)) == 549 and int(metrics.get("candidate_gated", 0)) == 1281
            and int(metrics.get("not_authored", 0)) == 366 and int(metrics.get("runtime_catalogue_ids", 0)) == 1830,
            "source / 7 candidate schools / not-authored totals remain distinct")
    var ranged := _actor("curse_range", "disciple", Vector2(2, 2))
    ranged["role"] = "ranged"
    ranged["v63_skill_loadout"] = ["tmb.skill.curse.phe_linh_chu.active_02.human"]
    _expect(is_equal_approx(HSC.preferred_offensive_range(ranged), 1.8),
        "OFF curse gate cannot extend ranged AI distance")
    ranged["v63_curse_combat_enabled"] = true
    _expect(is_equal_approx(HSC.preferred_offensive_range(ranged), 8.5),
        "explicit preview range comes from the curse line skill")
    var passive := _actor("curse_passive", "disciple", Vector2(2, 2))
    var passive_id := "tmb.skill.curse.phe_linh_chu.passive_01.human"
    _expect(HSC._root_scaled_passive_modifiers(passive, passive_id).is_empty(),
        "saved curse passive has no effect while its school gate is OFF")
    passive["v63_curse_combat_enabled"] = true
    _expect(not HSC._root_scaled_passive_modifiers(passive, passive_id).is_empty(),
        "explicit candidate preview resolves the existing bounded passive channel")

    _exercise_mobility_and_ai()
    _exercise_slow_and_mark_receipts()
    _exercise_guard_and_heal_receipts()
    _exercise_cleanse_receipt()
    _exercise_mapbattle_gate_copy()
    _finish()

func _exercise_mobility_and_ai() -> void:
    var battle := MapBattleV2.new(99700)
    var caster := _actor("curse_mobility_caster", "disciple", Vector2(2, 3))
    var target := _actor("curse_mobility_target", "enemy", Vector2(8, 3))
    var skill_id := "tmb.skill.curse.mobility.human"
    _enable_preview(caster, skill_id)
    battle.actors[caster.id] = caster
    battle.actors[target.id] = target
    var before: Vector2 = caster.position
    var started := HSC.try_cast(battle, caster, target)
    _expect(started, "Chú mobility starts through the shared Combat V2 selector")
    _expect((caster.position as Vector2).distance_to(before) > 0.1,
        "mobility follows an allowed position rather than producing a fake damage event")
    var mobility_events := _events(battle, "v63_mobility", skill_id)
    _expect(mobility_events.size() == 1
        and str(mobility_events[0].get("actor_id", "")) == str(caster.id),
        "mobility receipt is emitted exactly once for the moved actor")
    var definition := Curse.skill_definition("tmb.skill.curse.tran_hon_chu.active_01.human")
    var enemy := _actor("curse_ai_enemy", "enemy", Vector2(5, 3))
    var guarded := _actor("curse_ai_guarded", "disciple", Vector2(2, 3))
    _enable_preview(guarded, str(definition.get("id", "")))
    battle.actors[guarded.id] = guarded
    battle.actors[enemy.id] = enemy
    _expect(Curse.should_cast(battle, guarded, enemy, definition),
        "AI selects Chú slow before a matching mark is active")
    guarded["v63_curse_combat_enabled"] = false
    _expect(not Curse.can_cast(guarded, str(definition.get("id", ""))),
        "default actor gate blocks Chú AI casts outside preview")
    guarded["v63_curse_combat_enabled"] = true

func _exercise_slow_and_mark_receipts() -> void:
    var slow_battle := MapBattleV2.new(99701)
    var slow_caster := _actor("curse_slow_caster", "disciple", Vector2(2, 3))
    var slow_target := _actor("curse_slow_target", "enemy", Vector2(5, 3))
    var slow_id := "tmb.skill.curse.tran_hon_chu.active_01.human"
    _enable_preview(slow_caster, slow_id)
    slow_battle.actors[slow_caster.id] = slow_caster
    slow_battle.actors[slow_target.id] = slow_target
    var hp_before := float(slow_target.hp)
    _expect(_cast_and_settle(slow_battle, slow_caster, slow_target, "Trấn Hồn slow"),
        "slow skill enters Combat V2 cast path")
    _expect(float(slow_target.hp) < hp_before
        and slow_target.get("status_effects", {}).has("slow"),
        "slow applies only after real direct damage and stores its movement status")
    var hit_events := _events(slow_battle, "v63_curse_hit", slow_id)
    _expect(hit_events.size() == 1
        and is_equal_approx(float(hit_events[0].get("damage", 0.0)), hp_before - float(slow_target.hp)),
        "curse hit receipt records actual damage exactly once")
    _expect(_events(slow_battle, "v63_curse_slow_applied", slow_id).size() == 1,
        "slow receipt only follows a committed status")
    var slow_definition := Curse.skill_definition(slow_id)
    _expect(not Curse.should_cast(slow_battle, slow_caster, slow_target, slow_definition),
        "AI avoids reapplying a stronger unexpired slow before its refresh window")

    var mark_battle := MapBattleV2.new(99702)
    var mark_caster := _actor("curse_mark_caster", "disciple", Vector2(2, 3))
    var mark_target := _actor("curse_mark_target", "enemy", Vector2(5, 3))
    var mark_id := "tmb.skill.curse.phe_linh_chu.active_01.human"
    _enable_preview(mark_caster, mark_id)
    mark_battle.actors[mark_caster.id] = mark_caster
    mark_battle.actors[mark_target.id] = mark_target
    _expect(_cast_and_settle(mark_battle, mark_caster, mark_target, "Phệ Linh owner mark"),
        "mark enters Combat V2 cast path")
    var owner_mark: Dictionary = mark_target.get("v63_marks", {}).get(mark_caster.id, {})
    _expect(str(owner_mark.get("skill_id", "")) == mark_id
        and _events(mark_battle, "v63_curse_mark_applied", mark_id).size() == 1,
        "mark receipt is owner-scoped and emitted after the mark object commits")
    var mark_definition := Curse.skill_definition(mark_id)
    _expect(not Curse.should_cast(mark_battle, mark_caster, mark_target, mark_definition),
        "AI avoids refreshing its own valid mark unnecessarily")

func _exercise_guard_and_heal_receipts() -> void:
    var guard_battle := MapBattleV2.new(99703)
    var guardian := _actor("curse_guardian", "disciple", Vector2(3, 3))
    var foe := _actor("curse_guard_foe", "enemy", Vector2(4, 3))
    var guard_id := "tmb.skill.curse.ho_menh_chu.active_01.human"
    _enable_preview(guardian, guard_id)
    guard_battle.actors[guardian.id] = guardian
    guard_battle.actors[foe.id] = foe
    _expect(_cast_and_settle(guard_battle, guardian, foe, "Hộ Mệnh guard"),
        "guard enters Combat V2 cast path")
    _expect(float(guardian.get("learned_guard_factor", 1.0)) < 1.0
        and _events(guard_battle, "v63_curse_guard_applied", guard_id).size() == 1,
        "guard receipt follows a changed real mitigation state")

    var heal_battle := MapBattleV2.new(99704)
    var healer := _actor("curse_healer", "disciple", Vector2(3, 3))
    var ally := _actor("curse_heal_ally", "disciple", Vector2(4, 3))
    var heal_foe := _actor("curse_heal_foe", "enemy", Vector2(5, 3))
    healer["party_id"] = "curse_test_party"
    ally["party_id"] = "curse_test_party"
    ally["hp"] = 100.0
    var heal_id := "tmb.skill.curse.ho_menh_chu.active_02.human"
    _enable_preview(healer, heal_id)
    for actor in [healer, ally, heal_foe]:
        heal_battle.actors[str(actor.id)] = actor
    var ally_hp := float(ally.hp)
    _expect(_cast_and_settle(heal_battle, healer, heal_foe, "Hộ Mệnh heal"),
        "heal selects a real injured party member")
    _expect(float(ally.hp) > ally_hp
        and _events(heal_battle, "v63_curse_heal_applied", heal_id).size() == 1,
        "healing receipt reports positive HP applied to the injured ally")

func _exercise_cleanse_receipt() -> void:
    var battle := MapBattleV2.new(99705)
    var palm_caster := _actor("palm_slow_source", "enemy", Vector2(2, 3))
    var victim := _actor("curse_cleanse_victim", "disciple", Vector2(3, 3))
    var cleanser := _actor("curse_cleanser", "disciple", Vector2(3, 4))
    var enemy := _actor("curse_cleanse_enemy", "enemy", Vector2(5, 3))
    victim["party_id"] = "curse_cleanse_party"
    cleanser["party_id"] = "curse_cleanse_party"
    palm_caster["v63_palm_combat_enabled"] = true
    palm_caster["v63_skill_loadout"] = ["tmb.skill.palm.han_ngoc_chuong.active_02.human"]
    for actor in [palm_caster, victim, cleanser, enemy]:
        battle.actors[str(actor.id)] = actor
    _expect(_cast_and_settle(battle, palm_caster, victim, "Palm slow precondition"),
        "test precondition applies slow through the real shared Combat V2 cast path")
    _expect(victim.get("status_effects", {}).has("slow"), "real slow status exists before cleanse")
    var cleanse_id := "tmb.skill.curse.ho_menh_chu.active_03.human"
    _enable_preview(cleanser, cleanse_id)
    var cast_started := HSC.try_cast(battle, cleanser, enemy)
    _expect(cast_started, "Hộ Mệnh cleanse enters shared Combat V2 AI path")
    var pending: Dictionary = cleanser.get("v63_pending_cast", {})
    _expect(str(pending.get("target_id", "")) == str(victim.id),
        "cleanse selects the same-party member with real debuff")
    if pending.is_empty():
        return
    battle.now = float(pending.get("ready", battle.now))
    battle._release_casts()
    _expect(not victim.get("status_effects", {}).has("slow")
        and _events(battle, "cleanse", cleanse_id).size() == 1
        and _events(battle, "v63_curse_cleanse_applied", cleanse_id).size() == 1,
        "cleanse removes the actual slow and emits one truthful receipt")

func _exercise_mapbattle_gate_copy() -> void:
    var battle := MapBattleV2.new(99706)
    var caster := _actor("curse_copy", "disciple", Vector2(2, 2))
    caster["party_id"] = "party_0"
    caster["v63_curse_combat_enabled"] = true
    caster["v63_skill_loadout"] = ["tmb.skill.curse.tran_hon_chu.active_04.human"]
    var enemy := _actor("curse_copy_enemy", "enemy", Vector2(5, 2))
    var result := battle.setup("curse_mapbattle_copy", [caster], [enemy])
    _expect(bool(result.get("ok", false)), "MapBattle fixture starts")
    if bool(result.get("ok", false)):
        var copied: Dictionary = battle.actors.get("curse_copy", {})
        _expect(bool(copied.get("v63_curse_combat_enabled", false))
            and copied.get("v63_skill_loadout", []).has("tmb.skill.curse.tran_hon_chu.active_04.human"),
            "MapBattle preserves only the provided V63 curse gate and loadout")

func _cast_and_settle(battle: MapBattleV2, caster: Dictionary, target: Dictionary, label: String) -> bool:
    var started := HSC.try_cast(battle, caster, target)
    _expect(started, label + " starts")
    if not started:
        return false
    var pending: Dictionary = caster.get("v63_pending_cast", {})
    _expect(not pending.is_empty(), label + " has a runtime cast deadline")
    if pending.is_empty():
        return false
    battle.now = float(pending.get("ready", battle.now))
    battle._release_casts()
    return true

func _enable_preview(actor: Dictionary, skill_id: String) -> void:
    actor["v63_combat_enabled"] = true
    actor["v63_curse_combat_enabled"] = true
    actor["v63_skill_loadout"] = [skill_id]
    actor["v63_skill_ready"] = {}

func _actor(actor_id: String, side: String, position: Vector2) -> Dictionary:
    var resistances := {"metal":0.0, "wood":0.0, "water":0.0, "fire":0.0, "earth":0.0,
        "lightning":0.0, "wind":0.0, "ice":0.0, "yang":0.0, "nether":0.0}
    return {"id":actor_id, "side":side, "party_id":"", "role":"ranged", "position":position,
        "hp":200.0, "max_hp":200.0, "range":1.8, "move_speed":2.0, "tier":"normal",
        "stats":{"attack":40.0, "defense":0.0, "damage_reduction":0.0, "crit_chance":0.0,
        "crit_damage":1.5, "crit_resistance":0.0, "defense_penetration":0.0, "lifesteal":0.0,
        "lifesteal_reduction":0.0}, "resistances":resistances, "status_effects":{},
        "context_sources":[], "v63_combat_enabled":true, "v63_curse_combat_enabled":false,
        "v63_palm_combat_enabled":false, "v63_skill_ready":{}, "v63_skill_loadout":[],
        "v63_passive_ids":[], "v63_combat_clock":-1.0, "next_skill":0.0,
        "learned_guard_factor":1.0, "learned_guard_until":-1.0}

func _events(battle: MapBattleV2, event_type: String, skill_id: String = "") -> Array:
    var result: Array = []
    for event in battle.events:
        if (str(event.get("type", "")) == event_type
            and (skill_id.is_empty() or str(event.get("skill_id", "")) == skill_id)):
            result.append(event)
    return result

func _finish() -> void:
    if _failures > 0:
        print("V63_S7_CURSE_RESULT FAIL checks=" + str(_checks) + " failures=" + str(_failures))
        quit(1)
        return
    print("V63_S7_CURSE_RESULT PASS checks=" + str(_checks)
        + " nodes=183 families=35 branches=3 runtime=CombatV2_preview source=SOURCE_PENDING"
        + " balance=CANDIDATE vfx_spec=TEXT_ONLY vfx_prod=HOLD_OWNER_APPROVAL gate=OFF")
    quit(0)
