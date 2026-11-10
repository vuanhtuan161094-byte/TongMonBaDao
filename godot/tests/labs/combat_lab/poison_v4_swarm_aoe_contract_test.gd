extends SceneTree

# Four real Lab party actors / eight canonical monsters. Geometry and receipts
# are read from MapBattleV2 and V6.3; this script never writes SaveService.
const LabScene = preload("res://labs/combat_lab/combat_lab.tscn")
const AOE_ID := "tmb.skill.poison.doc_cham.active_03.human"
const CENTER := Vector2(18.0, 10.0)

var checks := 0
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("POISON_V4_SWARM_AOE_FAIL " + label)

func _run() -> void:
    OS.set_environment("TMB_POISON_V4_PREVIEW", "1")
    OS.set_environment("TMB_COMBAT_LAB_SCHOOL", "poison")
    OS.set_environment("TMB_COMBAT_LAB_GENERATION", "human")
    OS.set_environment("TMB_COMBAT_LAB_BRANCH", "doc_cham")
    OS.set_environment("TMB_COMBAT_LAB_PARTY", "4")
    OS.set_environment("TMB_COMBAT_LAB_ENEMY", "normal")
    OS.set_environment("TMB_COMBAT_LAB_ENCOUNTER", "poison_swarm")
    var lab := LabScene.instantiate()
    root.add_child(lab)
    await process_frame
    lab.call("_set_auto", false)
    var battle: MapBattleV2 = lab.get("battle")
    _check(battle != null and battle.active, "real MapBattleV2 swarm encounter starts")
    if battle == null or not battle.active:
        quit(1)
        return
    var actor_positions: Array[Vector2] = [
        Vector2(12.4, 7.4), Vector2(12.4, 12.6),
        Vector2(23.6, 7.4), Vector2(23.6, 12.6)]
    for index in range(4):
        var hero_id := "lab_disciple_%02d" % (index + 1)
        _check(battle.actors.has(hero_id), "real cultivator " + hero_id)
        if battle.actors.has(hero_id):
            var hero: Dictionary = battle.actors[hero_id]
            _check(hero["position"] == actor_positions[index], "corner world-space " + hero_id)
            _check(str(hero.get("side", "")) == "disciple" and
                is_equal_approx(float(hero.get("range", 0.0)), 6.0),
                "canonical poison role and normal range " + hero_id)
    var definition: Dictionary = V63HumanSkillCombatSystem.skill_definition(AOE_ID)
    _check(str(definition.get("shape", "")) == "circle" and
        is_equal_approx(float(definition.get("radius", 0.0)), 2.8) and
        int(definition.get("target_limit", 0)) == 3,
        "V6.3 authored radius 2.8, three-target cap (not six hits)")
    var inside := 0
    var outside := 0
    for index in range(8):
        var monster_id := "lab_swarm_%02d" % (index + 1)
        _check(battle.actors.has(monster_id), "real catalog monster " + monster_id)
        if not battle.actors.has(monster_id):
            continue
        var monster: Dictionary = battle.actors[monster_id]
        _check(str(monster.get("side", "")) == "monster", "real opponent side " + monster_id)
        if (monster["position"] as Vector2).distance_to(CENTER) <= float(definition.get("radius", 0.0)):
            inside += 1
        else:
            outside += 1
    _check(inside == 6 and outside == 2, "six inside and two outside geometry")
    var caster: Dictionary = battle.actors.get("lab_disciple_01", {})
    var lead: Dictionary = battle.actors.get("lab_swarm_01", {})
    _check(not caster.is_empty() and not lead.is_empty(), "real caster and center target")
    if caster.is_empty() or lead.is_empty():
        quit(2)
        return
    _check((caster["position"] as Vector2).distance_to(CENTER) <= float(definition.get("range", 0.0)),
        "AoE caster starts inside authored casting range")
    var selection := {
        "shape":"circle", "center":CENTER, "radius":float(definition.get("radius", 0.0)),
        "maximum":int(definition.get("target_limit", 0))}
    var selected: Array = V63HumanSkillCombatSystem._cast_targets(battle, caster, selection, "poison")
    _check(selected.size() == 3, "engine selects only authored target_limit")
    for target in selected:
        _check((target["position"] as Vector2).distance_to(CENTER) <= float(definition.get("radius", 0.0)),
            "engine never selects outside the AoE circle")

    # Drive one actual V6.3 cast, without authoring synthetic HP or on-hit events.
    # Other Lab disciples are only stopped from auto-casting in this isolated
    # oracle so that their attacks cannot kill the target before the cast releases.
    for index in range(2, 5):
        var ally: Dictionary = battle.actors["lab_disciple_%02d" % index]
        ally["v63_skill_loadout"] = []
        ally["skill_loadout"] = []
        ally["basic_interval"] = 9999.0
        ally["next_basic"] = 9999.0
    var preview: OptionButton = lab.get("skill_preview_option")
    var selection_found := false
    for index in range(preview.item_count):
        if str(preview.get_item_metadata(index)) == AOE_ID:
            preview.select(index)
            selection_found = true
            break
    _check(selection_found, "V6.3 circle skill selectable in real Lab loadout")
    if selection_found:
        lab.call("_preview_selected_skill")
        var pending: Dictionary = caster.get("v63_pending_cast", {})
        _check(str(pending.get("v63_skill_id", "")) == AOE_ID,
            "preview begins real requested AoE cast")
        _check(pending.get("center", null) is Vector2 and pending.get("center", null) == CENTER,
            "V6.3 cast locks center before projectile travel")
        var arena: Control = lab.get("arena")
        var snapshots: Dictionary = arena.get("locked_aoe_center_by_caster")
        var snapshot: Dictionary = snapshots.get("lab_disciple_01", {})
        _check(snapshot.get("center", null) == CENTER, "renderer caches original cast center")
        var painted_center := false
        var seen_v4_cues: Array[String] = []
        for _step in range(16):
            lab.call("_step_battle")
            # Inspect each committed step: the VFX cue can age out before
            # the final assertion in a crowded 4v8 fight.
            for cue in arena.cues:
                var cue_kind := str(cue.get("kind", ""))
                if not seen_v4_cues.has(cue_kind):
                    seen_v4_cues.append(cue_kind)
                if cue_kind == "venom_cloud" and str(cue.get("source_actor_id", "")) == "lab_disciple_01":
                    painted_center = painted_center or cue.get("position", Vector2.ZERO) == CENTER
        var real_hits := 0
        var outside_hits := 0
        var releases := 0
        for raw in battle.events:
            if not raw is Dictionary:
                continue
            var event: Dictionary = raw
            if str(event.get("caster", "")) != "lab_disciple_01" or str(event.get("skill_id", "")) != AOE_ID:
                continue
            if str(event.get("type", "")) == "skill_release":
                releases += 1
            if str(event.get("type", "")) == "v63_skill_hit":
                real_hits += 1
                if str(event.get("target", "")) in ["lab_swarm_07", "lab_swarm_08"]:
                    outside_hits += 1
        _check(releases >= 1, "real authoritative skill_release observed")
        _check(real_hits >= 1 and real_hits <= 3, "one AoE cast hits at most three real monsters")
        _check(outside_hits == 0, "no AoE skill receipt for either outside monster")
        if not painted_center:
            print("POISON_V4_SWARM_DEBUG seen_cue_kinds=" + str(seen_v4_cues) +
                " locked_center=" + str(snapshot))
        _check(painted_center, "AoE ring draws original 3-tile engine center")
    print("POISON_V4_SWARM_AOE_RESULT=" + ("PASS" if failures == 0 else "FAIL") +
        " checks=" + str(checks) + " failures=" + str(failures))
    lab.queue_free()
    quit(0 if failures == 0 else 1)
