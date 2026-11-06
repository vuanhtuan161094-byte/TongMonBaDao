class_name CombatLabEventBridge
extends RefCounted

# MapBattleV2 appends into a bounded event array for a finite encounter. It does
# not issue event IDs; this adapter uses only the observed array index as a local
# cursor and resets whenever the source shrinks or the battle object changes.
var source_battle: MapBattleV2
var cursor: int = 0

func reset(battle: MapBattleV2) -> void:
    source_battle = battle
    cursor = 0

func poll(battle: MapBattleV2) -> Array[Dictionary]:
    if battle == null:
        return []
    if source_battle != battle or battle.events.size() < cursor:
        reset(battle)
    var result: Array[Dictionary] = []
    var end_index := battle.events.size()
    for index in range(cursor, end_index):
        var raw = battle.events[index]
        if raw is Dictionary:
            var row: Dictionary = raw.duplicate(true)
            row["lab_source_index"] = index
            result.append(row)
    cursor = end_index
    return result
