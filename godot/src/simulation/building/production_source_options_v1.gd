class_name ProductionSourceOptionsV1
extends RefCounted

# Single read-only source of the Mine/Forest selectable output tables.
# Used by BuildingSystem and MedicineResourceSourceV1 to avoid a script
# dependency cycle. Never grants resources or changes job/Save authority.
const MINE_ORE_OPTIONS := {
    "thanh_thiet": {"required_level": 1, "batch_percent": 100},
    "ore_r01_c2": {"required_level": 1, "batch_percent": 100},
    "huyen_thiet": {"required_level": 10, "batch_percent": 50},
    "ore_r02_c2": {"required_level": 10, "batch_percent": 50}
}
# Existing real forestry timer/carry-cycle output is controlled per BUILDING,
# not a new production authority. Legacy Forest defaults to Linh Moc.
const FOREST_MATERIAL_OPTIONS := {
    "linh_moc":{"required_level":1,"batch_percent":100},
    "forest_r01_wood2":{"required_level":1,"batch_percent":100},
    "forest_r02_wood":{"required_level":10,"batch_percent":100},
    "forest_r02_wood2":{"required_level":10,"batch_percent":100}
}
