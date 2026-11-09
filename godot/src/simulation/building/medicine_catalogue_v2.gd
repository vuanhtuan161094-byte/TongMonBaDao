class_name MedicineCatalogueV2
extends RefCounted

# One canonical medicine identity shared by ResourceRegistry, Alchemy, B3 and UI.
# 30 major cultivation realms x 4 product qualities x two functional families.
# A definition is NOT proof of craftability: only authored, sourced recipes run.
# BAL-04A owner-approved 2026-11-05: Tu Vi potency now follows 0.1% of
# the canonical current realm XP total; healing and quality factors are unchanged.
# Version only marks new medicine receipts: old v1 receipts stay verifiable.
const VERSION := 3
const PREVIOUS_VERSION := 2
const LEGACY_VERSION := 1
const TUVI_REALM_XP_FRACTION := 0.001
# Q1 B3: approved realm-specific fixed XP. Q2-Q4 retain the approved
# quality multipliers, including on Body XP. Historical V1/V2 receipts use
# their original algorithm and are NOT reinterpreted as V3.
const V56_B3_Q1_XP := [1166,1234,1334,1435,1516,1593,1729,1865,1974,2075,
    2184,2311,2464,2609,2761,2935,3112,3283,3470,3668,
    3879,4105,4339,4592,4864,5150,5450,5771,6108,6463]
const BREAKTHROUGH_BONUS_PP := [15,25,35,45]
const MAX_REALM := 30
const MAX_QUALITY := 4
const FAMILY_HEAL := "heal"
const FAMILY_TUVI := "tuvi"
const FAMILY_BODY := "body"
const FAMILY_BREAK := "break"
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
const AUTHORED_BODY_REALMS := [1, 2]
const AUTHORED_BREAK_REALMS := [1, 2]

static func item_id(family: String, realm: int, quality: int) -> StringName:
    if not [FAMILY_HEAL,FAMILY_TUVI,FAMILY_BODY,FAMILY_BREAK].has(family) or realm < 1 or realm > MAX_REALM or quality < 1 or quality > MAX_QUALITY or (family == FAMILY_BREAK and realm == MAX_REALM):
        return &""
    return StringName("sx02_%s_r%02d_q%d" % [family, realm, quality])

static func recipe_id(family: String, realm: int) -> StringName:
    if not [FAMILY_HEAL,FAMILY_TUVI,FAMILY_BODY,FAMILY_BREAK].has(family) or realm < 1 or realm > MAX_REALM or (family == FAMILY_BREAK and realm == MAX_REALM):
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
    if data.is_empty() or not [LEGACY_VERSION,PREVIOUS_VERSION,VERSION].has(medicine_version):
        return 0
    var realm := int(data["realm"])
    var family := str(data["family"])
    var quality := int(data["quality"])
    var factor := float(QUALITY_FACTORS[quality-1])
    if family == FAMILY_BREAK:
        return int(BREAKTHROUGH_BONUS_PP[quality-1]) if medicine_version == VERSION else 0
    if medicine_version < VERSION and family == FAMILY_BODY:
        return 0
    if family == FAMILY_HEAL or medicine_version == LEGACY_VERSION:
        var old_base := 55.0 if family == FAMILY_HEAL else 10000.0
        return roundi(old_base*pow(1.65,float(realm-1))*factor)
    if medicine_version == PREVIOUS_VERSION:
        var realm_xp := DiscipleProgressionBalanceV2.realm_total_xp(realm)
        return roundi(float(realm_xp)*TUVI_REALM_XP_FRACTION*factor) if realm_xp > 0 else 0
    return roundi(float(V56_B3_Q1_XP[realm-1])*factor)


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
        "name": "%s · %s · %s" % [{
            FAMILY_HEAL:"Hồi Nguyên Đan",FAMILY_TUVI:"Tụ Linh Đan",
            FAMILY_BODY:"Luyện Thể Đan",FAMILY_BREAK:"Đột Phá Đan"
        }.get(family,"Đan Dược"), REALMS[realm - 1], QUALITIES[quality - 1]],
        "family": "pill",
        "pill_family": family,
        "realm_grade": period,
        "realm_rank": realm,
        "quality": quality,
        "quality_name": QUALITIES[quality - 1],
        "potency": potency,
        "satiety_cost": 50 if family in [FAMILY_TUVI,FAMILY_BODY] else 0,
        "market_value": 0,
        "tags": ["pill","alchemy_product",family,"medicine_realm_quality"],
        "craftable": _is_authored(family,realm)
    }

static func all_item_ids() -> Array[StringName]:
    var ids: Array[StringName] = []
    for realm in range(1, MAX_REALM + 1):
        for family in [FAMILY_HEAL,FAMILY_TUVI,FAMILY_BODY,FAMILY_BREAK]:
            if family == FAMILY_BREAK and realm == MAX_REALM:
                continue
            for quality in range(1,MAX_QUALITY+1):
                ids.append(item_id(family,realm,quality))
    return ids

static func _is_authored(family: String, realm: int) -> bool:
    if family in [FAMILY_HEAL,FAMILY_TUVI]:
        return AUTHORED_RECIPE_REALMS.has(realm)
    if family == FAMILY_BODY:
        return AUTHORED_BODY_REALMS.has(realm)
    if family == FAMILY_BREAK:
        return AUTHORED_BREAK_REALMS.has(realm)
    return false

static func authored_recipes() -> Array[StringName]:
    var ids: Array[StringName] = []
    for realm in range(1,MAX_REALM+1):
        for family in [FAMILY_HEAL,FAMILY_TUVI,FAMILY_BODY,FAMILY_BREAK]:
            if _is_authored(family,realm):
                ids.append(recipe_id(family,realm))
    return ids

# All 119 recipes have stable identities. Only recipes with verified
# harvest/mining/NPC routes are eligible for production transactions.
static func all_recipe_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    for realm in range(1,MAX_REALM+1):
        for family in [FAMILY_HEAL,FAMILY_TUVI,FAMILY_BODY,FAMILY_BREAK]:
            var recipe := recipe_id(family,realm)
            if recipe != &"":
                result.append(recipe)
    return result

static func recipe_definition(id: StringName) -> Dictionary:
    var parsed := parse_recipe(id)
    if parsed.is_empty():
        return {}
    var realm := int(parsed["realm"])
    var family := str(parsed["family"])
    if not _is_authored(family,realm):
        return {}
    var inputs: Dictionary = {}
    if realm == 1:
        match family:
            FAMILY_HEAL: inputs = {"thanh_linh_thao":3,"linh_moc":1}
            FAMILY_TUVI: inputs = {"thanh_linh_thao":2,"linh_coc":1,"thanh_thiet":2,"linh_moc":1}
            FAMILY_BODY: inputs = {"thanh_linh_thao":3,"thanh_thiet":2,"linh_moc":1}
            FAMILY_BREAK: inputs = {"thanh_linh_thao":3,"tinh_lang_bi":1,"linh_moc":1}
    elif realm == 2:
        match family:
            FAMILY_HEAL: inputs = {"tu_van_thao":2,"thanh_linh_thao":2,"linh_moc":1}
            FAMILY_TUVI: inputs = {"tu_van_thao":2,"linh_coc":2,"huyen_thiet":1,"linh_moc":1}
            FAMILY_BODY: inputs = {"tu_van_thao":2,"huyen_thiet":2,"linh_moc":1}
            FAMILY_BREAK: inputs = {"tu_van_thao":3,"tinh_lang_bi":2,"linh_moc":1}
    if inputs.is_empty():
        return {}
    return {
        "name":str(definition(item_id(family,realm,1)).get("name","")),
        "inputs":inputs,
        "output_resource_id":str(item_id(family,realm,1)),
        "output_quantity":6 if family == FAMILY_BREAK else 36,
        "required_profession_level":0 if realm == 1 else 3,
        "required_hall_level":1 if realm == 1 else 10,
        "base_cycle_ticks":3,
        "quality_enabled":true
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
    if REALMS.size() != MAX_REALM or QUALITIES.size() != MAX_QUALITY or V56_B3_Q1_XP.size() != MAX_REALM or all_recipe_ids().size() != 119 or all_item_ids().size() != 476:
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
