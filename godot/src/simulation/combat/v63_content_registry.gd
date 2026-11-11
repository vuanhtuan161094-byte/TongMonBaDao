class_name V63ContentRegistry
extends RefCounted

# D1 read-only catalogue. No runtime import or live combat feature installation.
const CATALOGUE_PATH := "res://data/combat/v63_content_registry.json"
const SCHOOL_IDS := ["bow","fist","poison","sword"]
const VALID_TIERS := ["human","immortal","divine","rare_divine"]
const VALID_SLOTS := ["basic","mobility","active","ultimate","passive","innate"]

static func load_catalogue(path: String = CATALOGUE_PATH) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok":false,"errors":["cannot_open_catalogue"],"data":{}}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {"ok":false,"errors":["catalogue_not_object"],"data":{}}
    var data: Dictionary = parsed
    var errors := validate_catalogue(data)
    return {"ok":errors.is_empty(),"errors":errors,"data":data}

static func _valid_id(value: String) -> bool:
    if not value.begins_with("tmb.") or value.ends_with(".") or value.find("..") >= 0:
        return false
    for ch in value:
        if not "abcdefghijklmnopqrstuvwxyz0123456789_.".contains(ch):
            return false
    return true

static func validate_catalogue(data: Dictionary) -> Array[String]:
    var errors: Array[String] = []
    if int(data.get("schema_version",-1)) != 1 or bool(data.get("enabled",true)):
        errors.append("bad_schema_or_enabled")
    if typeof(data.get("families",null)) != TYPE_ARRAY or typeof(data.get("paths",null)) != TYPE_ARRAY or typeof(data.get("bosses",null)) != TYPE_ARRAY:
        errors.append("missing_registry_arrays")
        return errors
    var families: Array = data["families"]
    var paths: Array = data["paths"]
    var bosses: Array = data["bosses"]
    if families.size() != 140 or paths.size() != 12 or bosses.size() != 9:
        errors.append("wrong_content_counts")
    var path_ids: Dictionary = {}
    for path in paths:
        var id := str(path.get("id",""))
        if not _valid_id(id) or path_ids.has(id) or not SCHOOL_IDS.has(str(path.get("school",""))):
            errors.append("bad_path_id:"+id)
        path_ids[id] = true
        var lineage: Dictionary = path.get("lineages",{})
        if str(lineage.get("a","")).is_empty() or str(lineage.get("b","")).is_empty():
            errors.append("missing_lineage:"+id)
    var family_ids: Dictionary = {}
    var all_node_ids: Dictionary = {}
    var shared_count := 0
    var branch_count: Dictionary = {}
    var rare_count := 0
    var poison_rare_passive_count := 0
    var sword_rare_passive_count := 0
    for family in families:
        var id := str(family.get("id",""))
        var school := str(family.get("school",""))
        var branch := str(family.get("branch",""))
        var slot := str(family.get("slot",""))
        if not _valid_id(id) or family_ids.has(id) or not VALID_SLOTS.has(slot) or not SCHOOL_IDS.has(school):
            errors.append("bad_family_id:"+id)
        family_ids[id] = true
        if branch.is_empty():
            shared_count += 1
            if not ["basic","mobility"].has(slot):
                errors.append("bad_shared_slot:"+id)
        else:
            var path_id := "tmb.path."+school+"."+branch
            if not path_ids.has(path_id):
                errors.append("missing_family_path:"+id)
            branch_count[path_id] = int(branch_count.get(path_id,0))+1
        var family_nodes: Dictionary = {}
        for node in family.get("nodes",[]):
            var node_id := str(node.get("id",""))
            var tier := str(node.get("tier",""))
            var parent := str(node.get("parent",""))
            if not _valid_id(node_id) or not node_id.begins_with(id+".") or all_node_ids.has(node_id) or not VALID_TIERS.has(tier):
                errors.append("bad_node_id:"+node_id)
            if parent.is_empty():
                if tier != "human":
                    errors.append("nonhuman_root:"+node_id)
            elif not family_nodes.has(parent):
                errors.append("missing_parent_or_cycle:"+node_id)
            if tier=="rare_divine":
                if slot=="ultimate":
                    rare_count += 1
                elif school=="poison" and slot=="passive" and id.ends_with("passive_05"):
                    poison_rare_passive_count += 1
                elif school=="sword" and slot=="passive" and id.ends_with("passive_05"):
                    sword_rare_passive_count += 1
                else:
                    errors.append("bad_rare_successor:"+node_id)
                if not parent.contains(".divine."):
                    errors.append("bad_rare_parent:"+node_id)
            family_nodes[node_id] = true
            all_node_ids[node_id] = true
        var expected_nodes := 3 if branch.is_empty() else (7 if slot=="ultimate" or (slot=="passive" and id.ends_with("passive_05")) else 5)
        if family_nodes.size() != expected_nodes:
            errors.append("wrong_family_node_count:"+id)
    if shared_count != 8 or branch_count.size()!=12 or rare_count != 24 or poison_rare_passive_count != 6 or sword_rare_passive_count != 6:
        errors.append("wrong_family_distribution")
    for count in branch_count.values():
        if int(count)!=11:
            errors.append("branch_must_have_eleven_families")
    var boss_ids: Dictionary = {}
    var ability_ids: Dictionary = {}
    for boss in bosses:
        var id := str(boss.get("id",""))
        if not _valid_id(id) or boss_ids.has(id) or not id.begins_with("tmb.boss."):
            errors.append("bad_boss_id:"+id)
        boss_ids[id] = true
        var skills: Array = boss.get("abilities",[])
        if skills.size()!=4 or int(boss.get("summon_cap",-1))>4 or int(boss.get("summon_cap",-1))<0:
            errors.append("bad_boss_ability_count:"+id)
        if bool(boss.get("loot_ready",true)) or bool(boss.get("spawn_ready",true)):
            errors.append("boss_accidentally_enabled:"+id)
        var phases: Array = boss.get("phases",[])
        if phases != [0.7,0.35]:
            errors.append("bad_boss_phases:"+id)
        if float(boss.get("hp_peak_candidate",0))<=0 or float(boss.get("def_to_disciple_attack_candidate",0))<=0:
            errors.append("bad_boss_stats:"+id)
        var ultimate_count := 0
        for skill in skills:
            var skill_id := str(skill.get("id",""))
            if not _valid_id(skill_id) or ability_ids.has(skill_id) or not skill_id.begins_with("tmb.bossskill."):
                errors.append("bad_boss_skill:"+skill_id)
            ability_ids[skill_id] = true
            if str(skill.get("kind","")) == "ultimate":
                ultimate_count += 1
            if float(skill.get("cooldown_s",0))<=0 or float(skill.get("telegraph_s",-1))<0 or bool(skill.get("ready",true)):
                errors.append("bad_boss_skill_timing_or_ready:"+skill_id)
        if ultimate_count!=1:
            errors.append("boss_missing_one_ultimate:"+id)
    return errors

static func lookup_family(data: Dictionary, family_id: String) -> Dictionary:
    for family in data.get("families",[]):
        if str(family.get("id","")) == family_id:
            return family.duplicate(true)
    return {}

static func lookup_boss(data: Dictionary, boss_id: String) -> Dictionary:
    for boss in data.get("bosses",[]):
        if str(boss.get("id","")) == boss_id:
            return boss.duplicate(true)
    return {}
