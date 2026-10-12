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
        "market_value": 2,
        "tags": ["construction_wood", "crafting_wood"]
    },
    "thanh_thiet": {
        "name": "Thanh Thiết",
        "family": "mineral",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 8,
        "tags": ["construction_mineral", "metal", "crafting_metal"]
    },
    "huyen_thiet": {
        "name": "Huyền Thiết",
        "family": "mineral",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "market_value": 34,
        "tags": ["construction_mineral", "metal", "technique_material"]
    },
    "tinh_lang_bi": {
        "name": "Tinh Lang Bì",
        "family": "beast_material",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 10,
        "tags": ["beast_hide", "crafting_leather"]
    },
    "yeu_dan": {
        "name": "Yêu Đan",
        "family": "monster_core",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 18,
        "tags": ["monster_core", "alchemy", "technique_material"]
    },
    "linh_tuy": {
        "name": "Linh Tủy",
        "family": "essence",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 14,
        "tags": ["essence", "technique_material"]
    },
    "tam_mach_ban": {
        "name": "Tầm Mạch Bàn",
        "family": "building_component",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 80,
        "tags": ["building_component", "mine_milestone"]
    },
    "thanh_linh_thao": {
        "name": "Thanh Linh Thảo",
        "family": "herb",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 6,
        "tags": ["herb", "alchemy"]
    },
    "hoi_xuan_dan": {
        "name": "Hồi Xuân Đan",
        "family": "pill",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 0,
        "tags": ["pill", "healing", "alchemy_product"]
    },
    "linh_coc": {
        "name": "Linh Cốc",
        "family": "crop",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 4,
        "tags": ["spirit_grain", "food"]
    },
    "tu_van_thao": {
        "name": "Tử Vân Thảo",
        "family": "herb",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "market_value": 16,
        "tags": ["herb", "alchemy", "advanced_crop"]
    },
    "linh_tuyen_chi_tam_manh": {
        "name": "Mảnh Linh Tuyền Chi Tâm",
        "family": "building_fragment",
        "realm_grade": "luyen_khi",
        "realm_rank": 1,
        "market_value": 2,
        "tags": ["spirit_field_milestone_fragment"]
    },
    "linh_tuyen_chi_tam": {
        "name": "Linh Tuyền Chi Tâm",
        "family": "building_component",
        "realm_grade": "truc_co",
        "realm_rank": 2,
        "market_value": 120,
        "tags": ["building_component", "spirit_field_milestone"]
    },
    "huyet_linh_sam": {
        "name": "Huyết Linh Sâm",
        "family": "herb",
        "realm_grade": "nhan",
        "realm_rank": 7,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_c"]
    },
    "huyet_thu_tinh_huyet": {
        "name": "Huyết Thú Tinh Huyết",
        "family": "beast_material",
        "realm_grade": "nhan",
        "realm_rank": 7,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_c"]
    },
    "kim_cot_thao": {
        "name": "Kim Cốt Thảo",
        "family": "herb",
        "realm_grade": "tien",
        "realm_rank": 11,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_d"]
    },
    "linh_thu_cot_ngoc": {
        "name": "Linh Thú Cốt Ngọc",
        "family": "beast_material",
        "realm_grade": "tien",
        "realm_rank": 11,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_d"]
    },
    "tien_tuy_lien": {
        "name": "Tiên Tủy Liên",
        "family": "herb",
        "realm_grade": "tien",
        "realm_rank": 15,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_e"]
    },
    "tien_thu_chan_cot": {
        "name": "Tiên Thú Chân Cốt",
        "family": "beast_material",
        "realm_grade": "tien",
        "realm_rank": 15,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_e"]
    },
    "bat_hoai_tuy_dich": {
        "name": "Bất Hoại Tủy Dịch",
        "family": "essence",
        "realm_grade": "tien",
        "realm_rank": 18,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_f"]
    },
    "dai_la_kim_cot": {
        "name": "Đại La Kim Cốt",
        "family": "beast_material",
        "realm_grade": "tien",
        "realm_rank": 18,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_f"]
    },
    "than_mach_tinh": {
        "name": "Thần Mạch Tinh",
        "family": "mineral",
        "realm_grade": "than",
        "realm_rank": 21,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_g"]
    },
    "than_thu_cot": {
        "name": "Thần Thú Cốt",
        "family": "beast_material",
        "realm_grade": "than",
        "realm_rank": 21,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_g"]
    },
    "hon_don_tuy_hoa": {
        "name": "Hỗn Độn Tủy Hoa",
        "family": "essence",
        "realm_grade": "than",
        "realm_rank": 26,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_main", "body_gate_h"]
    },
    "bat_diet_than_cot": {
        "name": "Bất Diệt Thần Cốt",
        "family": "beast_material",
        "realm_grade": "than",
        "realm_rank": 26,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_aux", "body_gate_h"]
    },
    "an_nhan_gioi": {
        "name": "Ấn Nhân Giới",
        "family": "body_gate_seal",
        "realm_grade": "nhan",
        "realm_rank": 10,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_seal", "body_gate_nhan"]
    },
    "an_tien_gioi": {
        "name": "Ấn Tiên Giới",
        "family": "body_gate_seal",
        "realm_grade": "tien",
        "realm_rank": 20,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_seal", "body_gate_tien"]
    },
    "an_than_gioi": {
        "name": "Ấn Thần Giới",
        "family": "body_gate_seal",
        "realm_grade": "than",
        "realm_rank": 29,
        "market_value": 0,
        "tags": ["body_gate_material", "body_gate_seal", "body_gate_than"]
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
        if int(data.get("realm_rank", -1)) < 0:
            errors.append("Resource %s has invalid realm rank." % resource_id)
        if not (data.get("tags", []) is Array):
            errors.append("Resource %s has invalid tags." % resource_id)
    return errors
