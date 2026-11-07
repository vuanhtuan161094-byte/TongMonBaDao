extends SceneTree

const LabScene := preload("res://labs/combat_lab/combat_lab.tscn")

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("POISON_VISUAL_FAIL " + message)

func _run() -> void:
	OS.set_environment("TMB_COMBAT_LAB_BRANCH", "duoc_doc")
	OS.set_environment("TMB_COMBAT_LAB_LINEAGE", "a")
	var lab := LabScene.instantiate()
	root.add_child(lab)
	var battle: MapBattleV2 = lab.get("battle")
	_check(battle != null and battle.actors.size() == 7, "Lab initially opens with its real six-disciple Boss fixture")
	var branch_option: OptionButton = lab.get("branch_option")
	_check(str(branch_option.get_item_metadata(branch_option.selected)) == "duoc_doc",
		"capture preset selects a real Dược Độc branch through its ID")
	var buttons := lab.find_children("*", "Button", true, false)
	var aoe_button: Button
	var boss_adds_button: Button
	for candidate in buttons:
		if not candidate is Button:
			continue
		match str(candidate.text):
			"ĐỘC CHÂM · QUẦN CÔNG 3/4": aoe_button = candidate
			"ĐỘC TU · 6 vs BOSS + QUÁI": boss_adds_button = candidate
	_check(aoe_button != null and boss_adds_button != null, "quick Poison presets are present")
	if aoe_button != null:
		aoe_button.pressed.emit()
		battle = lab.get("battle")
		_check(battle.actors.size() == 5 and battle.actors.has("lab_aoe_00") and battle.actors.has("lab_aoe_outside"),
			"AOE quick preset creates 3 targets in its radius plus 1 outside")
	if boss_adds_button != null:
		boss_adds_button.pressed.emit()
		battle = lab.get("battle")
		_check(battle.actors.size() == 10 and battle.actors.has("lab_boss") and battle.actors.has("lab_boss_add_01"),
			"six Poison disciples can enter a real V6.3 Boss plus 3 minions scenario")
	var arena: Control = lab.get("arena")
	battle = lab.get("battle")
	arena.call("set_battle", battle, "bow")
	var rows: Array[Dictionary] = [
		{"type":"hit", "attacker":"lab_disciple_01", "target":"lab_boss", "kind":"v63_skill", "damage":20.0, "critical":true, "lifesteal":5.0},
		{"type":"v63_skill_hit", "caster":"lab_disciple_01", "target":"lab_boss", "effect":"damage", "damage":20.0},
		{"type":"hit", "attacker":"lab_disciple_01", "target":"lab_boss", "kind":"v63_poison", "damage":5.0},
		{"type":"status_tick", "caster":"lab_disciple_01", "target":"lab_boss", "status":"poison", "damage":5.0},
		{"type":"hit", "attacker":"lab_disciple_01", "target":"lab_boss", "kind":"dot", "damage":4.0},
		{"type":"damage_tick", "attacker":"lab_disciple_01", "target":"lab_boss", "damage":4.0}
	]
	arena.call("consume_events", rows)
	var kinds := {}
	var cues: Array = arena.get("cues")
	for raw_cue in cues:
		var cue: Dictionary = raw_cue
		var kind := str(cue.get("kind", ""))
		kinds[kind] = int(kinds.get(kind, 0)) + 1
	print("POISON_VFX_CUE_COUNTS=" + JSON.stringify(kinds))
	_check(int(kinds.get("impact", 0)) == 2 and int(kinds.get("heal", 0)) == 1
		and int(kinds.get("poison_tick", 0)) == 1 and cues.size() == 4,
		"committed hit/lifesteal/poison/dot render once; observed %s" % JSON.stringify(kinds))
	print("POISON_VISUAL_ACCEPTANCE_RESULT=" + ("PASS" if failures == 0 else "FAIL") + " failures=" + str(failures))
	quit(0 if failures == 0 else 1)
