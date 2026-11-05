class_name MedicineCatalogueV2
extends RefCounted

# One canonical medicine identity shared by ResourceRegistry, Alchemy, B3 and UI.
# 30 major cultivation realms x 4 product qualities x two functional families.
# A definition is NOT proof of craftability: only authored, sourced recipes run.
# BAL-04A owner-approved 2026-11-05: Tu Vi potency now follows 0.1% of
# the canonical current realm XP total; healing and quality factors are unchanged.
# Version only marks new medicine receipts: old v1 receipts stay verifiable.
const VERSION := 2
const LEGACY_VERSION := 1
const TUVI_REALM_XP_FRACTION := 0.001
const MAX_REALM := 30
const MAX_QUALITY := 4
const FAMILY_HEAL := "heal"
const FAMILY_TUVI := "tuvi"
const REALMS := [
    "Phàm Nhân", "Luyện Khí", "Trúc Cơ", "Tử Phủ", "Kim Đan",
    "Nguyên Anh", "Hóa Thần", "Luyện Hư", "Hợp Thể", "Đại Thừa",
    "Nhân Tiên", "Địa Tiên", "Thiên Tiên", "Chân Tiên", "Huyền Tiên",
    "Kim Tiên", "Thái Ất Kim Tiên", "Đại La Kim Tiên", "Tiên Vương", "Tiên Đế",
    "Thần Nhân", "Chân Thần", "Thiên Thần", "Thần Quân", "Thần Vương",
    "Thần Hoàng", "Thần Đế", "Thần Tôn", "Hỗn Độn Thần", "Sáng Thế Chủ"
]
const QUALITIES := ["Hạ Phẩm", "Trung Phẩm", "Thượng Phẩm", "Cực Phẩm"]
const QUALITY_FACTORS := [1.0, 1.25, 1.55, 2.0]
const AUTHORED_RECIPE_REALMS := [1, 2]

static func item_id(family: String, realm: int, quality: int) -> StringName:
    if not [FAMILY_HEAL, FAMILY_TUVI].has(family) or realm < 1 or realm > MAX_REALM or quality < 1 or quality > MAX_QUALITY:
        return &""
    return StringName("sx02_%s_r%02d_q%d" % [family, realm, quality])

static func recipe_id(family: String, realm: int) -> StringName:
    if not [FAMILY_HEAL, FAMILY_TUVI].has(family) or realm < 1 or realm > MAX_REALM:
        return &""
    return StringName("sx02_recipe_%s_r%02d" % [family, realm])

static func parse_item(id: StringName) -> Dictionary:
    var tokens := str(id).split("_")
    if tokens.size() != 4 or tokens[0] != "sx02":
        return {}
    var family := str(tokens[1])
    var realm := int(str(tokens[2]).trim_prefix("r"))
    var quality := int(str(tokens[3]).trim_prefix("q"))
    if item_id(family, realm, quality) != id:
        return {}
    return {"family": family, "realm": realm, "quality": quality}

static func parse_recipe(id: StringName) -> Dictionary:
    var tokens := str(id).split("_")
    if tokens.size() != 4 or tokens[0] != "sx02" or tokens[1] != "recipe":
        return {}
    var family := str(tokens[2])
    var realm := int(str(tokens[3]).trim_prefix("r"))
    if recipe_id(family, realm) != id:
        return {}
    return {"family": family, "realm": realm}

# Historical deterministic potency is necessary to validate the last
# B3 receipt saved before BAL-04A. Never recompute an old receipt with V2 math.
static func potency_for_version(id: StringName, medicine_version: int) -> int:
    var data := parse_item(id)
    if data.is_empty() or medicine_version not in [LEGACY_VERSION, VERSION]:
        return 0
    var realm := int(data["realm"])
    var quality_factor := float(QUALITY_FACTORS[int(data["quality"]) - 1])
    if str(data["family"]) == FAMILY_HEAL or medicine_version == LEGACY_VERSION:
        var previous_base := 55.0 if str(data["family"]) == FAMILY_HEAL else 10000.0
        return roundi(previous_base * pow(1.65, float(realm - 1)) * quality_factor)
    var realm_xp := DiscipleProgressionBalanceV2.realm_total_xp(realm)
    if realm_xp <= 0:
        return 0
    return roundi(float(realm_xp) * TUVI_REALM_XP_FRACTION * quality_factor)


static func definition(id: StringName) -> Dictionary:
    var data := parse_item(id)
    if data.is_empty():
        return {}
    var realm := int(data["realm"])
    var quality := int(data["quality"])
    var family := str(data["family"])
    var potency := potency_for_version(id, VERSION)
    var period := "nhan" if realm <= 10 else ("tien" if realm <= 20 else "than")
    return {
        "name": "%s · %s · %s" % ["Hồi Nguyên Đan" if family == FAMILY_HEAL else "Tụ Linh Đan", REALMS[realm - 1], QUALITIES[quality - 1]],
        "family": "pill",
        "pill_family": family,
        "realm_grade": period,
        "realm_rank": realm,
        "quality": quality,
        "quality_name": QUALITIES[quality - 1],
        "potency": potency,
        "satiety_cost": 10 if family == FAMILY_HEAL else 25,
        "market_value": 0,
        "tags": ["pill", "alchemy_product", "healing" if family == FAMILY_HEAL else "cultivation", "medicine_realm_quality"],
        "craftable": AUTHORED_RECIPE_REALMS.has(realm)
    }

static func all_item_ids() -> Array[StringName]:
    var ids: Array[StringName] = []
    for realm in range(1, MAX_REALM + 1):
        for family in [FAMILY_HEAL, FAMILY_TUVI]:
            for quality in range(1, MAX_QUALITY + 1):
                ids.append(item_id(family, realm, quality))
    return ids

static func authored_recipes() -> Array[StringName]:
    var ids: Array[StringName] = []
    for realm in AUTHORED_RECIPE_REALMS:
        for family in [FAMILY_HEAL, FAMILY_TUVI]:
            ids.append(recipe_id(family, realm))
    return ids

# Higher realms remain discoverable but deliberately cannot be created from
# invented herbs or generic currency. A recipe must have a real input source.
static func recipe_definition(id: StringName) -> Dictionary:
    var parsed := parse_recipe(id)
    if parsed.is_empty() or not AUTHORED_RECIPE_REALMS.has(int(parsed["realm"])):
        return {}
    var realm := int(parsed["realm"])
    var family := str(parsed["family"])
    var requirements := {}
    if realm == 1:
        requirements = {"thanh_linh_thao": 3} if family == FAMILY_HEAL else {"thanh_linh_thao": 2, "linh_coc": 1}
    elif realm == 2:
        # Tử Vân Thảo is field-gated at Lv10 from BAL-04A. It must still be
        # earned through an actual planted harvest; this grants no free herbs.
        requirements = {"tu_van_thao": 2, "thanh_linh_thao": 2} if family == FAMILY_HEAL else {"tu_van_thao": 2, "linh_coc": 2}
    return {
        "name": str(definition(item_id(family, realm, 1)).get("name", "")),
        "inputs": requirements,
        "output_resource_id": str(item_id(family, realm, 1)),
        "output_quantity": 1,
        "required_profession_level": 0 if realm == 1 else 3,
        "required_hall_level": 1 if realm == 1 else 10,
        "base_cycle_ticks": 6 if realm == 1 else 10,
        "quality_enabled": true
    }

static func produced_quality(profession_level: int, hall_level: int) -> int:
    # Deliberately deterministic/fail-closed until recipe-specific RNG
    # tables and rare quality modifiers receive owner review.
    if profession_level >= 10 and hall_level >= 20:
        return 4
    if profession_level >= 5 and hall_level >= 10:
        return 3
    if profession_level >= 2 and hall_level >= 5:
        return 2
    return 1

static func output_for_job(recipe: StringName, profession_level: int, hall_level: int) -> StringName:
    var d := parse_recipe(recipe)
    if d.is_empty() or recipe_definition(recipe).is_empty():
        return &""
    return item_id(str(d["family"]), int(d["realm"]), produced_quality(profession_level, hall_level))

static func validate_catalogue() -> Array[String]:
    var errors: Array[String] = []
    if REALMS.size() != MAX_REALM or QUALITIES.size() != MAX_QUALITY:
        errors.append("medicine_realms_or_qualities_count")
    for id in all_item_ids():
        var item := definition(id)
        if item.is_empty() or int(item.get("potency", 0)) <= 0 or str(item.get("name", "")).is_empty():
            errors.append("medicine_item_invalid:" + str(id))
    for id in authored_recipes():
        var recipe := recipe_definition(id)
        if recipe.is_empty() or recipe["inputs"].is_empty():
            errors.append("medicine_recipe_unavailable:" + str(id))
    return errors
