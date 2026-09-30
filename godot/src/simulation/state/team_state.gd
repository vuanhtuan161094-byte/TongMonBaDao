class_name TeamState
extends RefCounted

var id: StringName
var display_name: String
var leader_id: StringName = &""
var member_ids: Array[StringName] = []

func _init(definition: Dictionary = {}) -> void:
    id = StringName(definition.get("id", "team"))
    display_name = str(definition.get("name", id))
    leader_id = StringName(definition.get("leader_id", ""))
    for raw_id in definition.get("member_ids", []):
        var member_id := StringName(raw_id)
        if member_id != &"" and not member_ids.has(member_id):
            member_ids.append(member_id)

func has_member(disciple_id: StringName) -> bool:
    return member_ids.has(disciple_id)

func to_dict() -> Dictionary:
    var members: Array[String] = []
    for member_id in member_ids:
        members.append(str(member_id))
    return {
        "id": str(id),
        "name": display_name,
        "leader_id": str(leader_id),
        "member_ids": members
    }

static func from_dict(data: Dictionary) -> TeamState:
    return TeamState.new(data)
