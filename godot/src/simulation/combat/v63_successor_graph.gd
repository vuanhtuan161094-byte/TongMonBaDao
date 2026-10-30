class_name V63SuccessorGraph
extends RefCounted

# Read-only descendant graph. Never grants a skill, changes equip, or writes save.
static func node_by_id(family: Dictionary, node_id: String) -> Dictionary:
    for item in family.get("nodes", []):
        if str(item.get("id","")) == node_id:
            return item.duplicate(true)
    return {}

static func children_of(family: Dictionary, parent_id: String) -> Array[String]:
    var result: Array[String] = []
    for item in family.get("nodes", []):
        if str(item.get("parent","")) == parent_id:
            result.append(str(item.get("id","")))
    result.sort()
    return result

static func can_advance(family: Dictionary, current_id: String, next_id: String, known_nodes: Array) -> bool:
    if not known_nodes.has(current_id):
        return false
    var descendant: Dictionary = node_by_id(family,next_id)
    if descendant.is_empty():
        return false
    return str(descendant.get("parent","")) == current_id

static func valid_active_selection(catalogue: Dictionary, active_node_ids: Array) -> bool:
    var owner_of_node: Dictionary = {}
    for family in catalogue.get("families", []):
        for node in family.get("nodes", []):
            owner_of_node[str(node.get("id",""))] = str(family.get("id",""))
    var used_families: Dictionary = {}
    for raw_id in active_node_ids:
        var id := str(raw_id)
        if not owner_of_node.has(id):
            return false
        var family_id := str(owner_of_node[id])
        if used_families.has(family_id):
            return false
        used_families[family_id] = true
    return true
