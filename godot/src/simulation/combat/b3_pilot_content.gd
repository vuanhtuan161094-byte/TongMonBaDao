class_name B3PilotContent
extends RefCounted

# Explicitly opt-in VS1 content, not the finite HuntingMapV2 reward table.
const VERSION := 1
const ZONE := "bach_thach_khe"
const SPECIES := "thanh_lang"
const RESOURCE := &"tinh_lang_bi"
const QUANTITY := 1
const SLOT := "wolf_0"
const RESPAWN_SECONDS := 8.0

static func monster(world_id: String, generation: int) -> Dictionary:
    var region: Dictionary = HuntingMapV2.REGION_CONTENT[ZONE]
    var row := MonsterCatalogueV2.create_actor(
        SPECIES,int(region["realm"]),int(region["floor"]),
        "%s/%s/%d" % [world_id,SLOT,generation]
    )
    row["id"] = row["encounter_id"]
    row["position"] = Vector2(23,10)
    row["spawn_slot_id"] = SLOT
    row["slot_generation"] = generation
    return row

static func kill_id(world_id: String, generation: int) -> String:
    return "%s:slot:%s:g%d" % [world_id,SLOT,generation]
