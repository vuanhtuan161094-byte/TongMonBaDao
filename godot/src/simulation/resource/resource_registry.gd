class_name ResourceRegistry
extends RefCounted

const REALM_PHAM := &"pham"
const REALM_LUYEN_KHI := &"luyen_khi"
const REALM_TRUC_CO := &"truc_co"
const REALM_KIM_DAN := &"kim_dan"

const TAG_CONSTRUCTION_WOOD := &"construction_wood"
const TAG_CONSTRUCTION_MINERAL := &"construction_mineral"
const TAG_BUILDING_COMPONENT := &"building_component"
const TAG_HERB := &"herb"
const TAG_MONSTER_CORE := &"monster_core"
const TAG_TECHNIQUE_MATERIAL := &"technique_material"

const DEFINITIONS := {
    "linh_moc": {
        "name": "Linh Mộc",
        "family": "wood",
        "realm_grade": "pham",
        "realm_rank": 0,
        "base_pham_luc": 2,
        "market_value": 2,
        "tags": ["construction_wood", "crafting_wood"]
    },
    "thanh_thiet": {
        "name": "Thanh Thiết",
        "family": "mineral",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 8,
        "market_value": 8,
        "tags": ["construction_mineral", "metal", "crafting_metal"]
    },
    "huyen_thiet": {
        "name": "Huyền Thiết",
        "family": "mineral",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "base_pham_luc": 40,
        "market_value": 34,
        "tags": ["construction_mineral", "metal", "technique_material"]
    },
    "tinh_lang_bi": {
        "name": "Tinh Lang Bì",
        "family": "beast_material",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 10,
        "market_value": 10,
        "tags": ["beast_hide", "crafting_leather"]
    },
    "yeu_dan": {
        "name": "Yêu Đan",
        "family": "monster_core",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 18,
        "market_value": 18,
        "tags": ["monster_core", "alchemy", "technique_material"]
    },
    "linh_tuy": {
        "name": "Linh Tủy",
        "family": "essence",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 12,
        "market_value": 14,
        "tags": ["essence", "technique_material"]
    },
    "tam_mach_ban": {
        "name": "Tầm Mạch Bàn",
        "family": "building_component",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 80,
        "market_value": 80,
        "tags": ["building_component", "mine_milestone"]
    },
    "thanh_linh_thao": {
        "name": "Thanh Linh Thảo",
        "family": "herb",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "base_pham_luc": 6,
        "market_value": 6,
        "tags": ["herb", "alchemy"]
    },
    "linh_tuyen_chi_tam": {
        "name": "Linh Tuyền Chi Tâm",
        "family": "building_component",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "base_pham_luc": 100,
        "market_value": 120,
        "tags": ["building_component", "spirit_field_milestone"]
    }
}

func has(resource_id: StringName) -> bool:
    return DEFINITIONS.has(str(resource_id))

func definition(resource_id: StringName) -> Dictionary:
    return DEFINITIONS.get(str(resource_id), {})

func display_name(resource_id: StringName) -> String:
    return str(definition(resource_id).get("name", resource_id))

func family(resource_id: StringName) -> StringName:
    return StringName(definition(resource_id).get("family", ""))

func realm_grade(resource_id: StringName) -> StringName:
    return StringName(definition(resource_id).get("realm_grade", "pham"))

func realm_rank(resource_id: StringName) -> int:
    return maxi(int(definition(resource_id).get("realm_rank", 0)), 0)

func base_pham_luc(resource_id: StringName) -> int:
    return maxi(int(definition(resource_id).get("base_pham_luc", 0)), 0)

func tags(resource_id: StringName) -> Array[StringName]:
    var result: Array[StringName] = []
    var raw = definition(resource_id).get("tags", [])
    if not (raw is Array):
        return result
    for item in raw:
        var tag := StringName(item)
        if tag != &"" and not result.has(tag):
            result.append(tag)
    result.sort_custom(func(a: StringName, b: StringName) -> bool: return str(a) < str(b))
    return result

func has_tag(resource_id: StringName, tag: StringName) -> bool:
    return tags(resource_id).has(tag)

func all_resource_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    var ids: Array = DEFINITIONS.keys()
    ids.sort()
    for raw_id in ids:
        result.append(StringName(raw_id))
    return result

func validate_definitions() -> Array[String]:
    var errors: Array[String] = []
    for resource_id in all_resource_ids():
        var data := definition(resource_id)
        if str(data.get("name", "")) == "":
            errors.append("Resource %s has no display name." % resource_id)
        if str(data.get("family", "")) == "":
            errors.append("Resource %s has no family." % resource_id)
        if int(data.get("base_pham_luc", 0)) <= 0:
            errors.append("Resource %s has invalid Phẩm Lực." % resource_id)
        if int(data.get("realm_rank", -1)) < 0:
            errors.append("Resource %s has invalid realm rank." % resource_id)
        if not (data.get("tags", []) is Array):
            errors.append("Resource %s has invalid tags." % resource_id)
    return errors
