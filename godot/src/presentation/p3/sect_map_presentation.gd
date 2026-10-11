class_name SectMapPresentation
extends RefCounted

const DEST_COURTYARD := &"courtyard"
const DEST_MAIN_HALL := &"main_hall"
const DEST_RESIDENCE := &"residence"
const DEST_CULTIVATION := &"cultivation"
const DEST_BODY_TRAINING := &"ren_than_duong"
const DEST_WAREHOUSE := &"warehouse"
const DEST_FORGE := &"forge"
const DEST_MEDICINE := &"medicine"
const DEST_MINE := &"mine"
const DEST_LINH_FOREST := &"linh_forest"
const DEST_SPIRIT_FIELD := &"spirit_field"
const DEST_GUIDANCE := &"guidance"
const DEST_GATE := &"gate"

const DESTINATION_POSITIONS := {
    "courtyard": Vector2(690.0, 388.0),
    "main_hall": Vector2(620.0, 192.0),
    "residence": Vector2(900.0, 212.0),
    "cultivation": Vector2(782.0, 350.0),
    "ren_than_duong": Vector2(376.0, 220.0),
    "warehouse": Vector2(1005.0, 386.0),
    "forge": Vector2(540.0, 492.0),
    "medicine": Vector2(815.0, 520.0),
    "mine": Vector2(350.0, 365.0),
    "linh_forest": Vector2(185.0, 370.0),
    "spirit_field": Vector2(190.0, 520.0),
    "guidance": Vector2(1135.0, 292.0),
    "gate": Vector2(1130.0, 515.0)
}

const ACTION_LABELS := {
    "EVALUATE": "Đang cân nhắc",
    "IDLE": "Đang rảnh",
    "HUNT": "Chuẩn bị xuất môn",
    "TRAVEL": "Đang di chuyển",
    "COMBAT": "Đang chiến đấu",
    "LOOT": "Đang thu chiến lợi phẩm",
    "RETURN_SECT": "Đang về tông",
    "SELL": "Đang nhập kho/bán",
    "BUY": "Đang lấy vật tư",
    "HEAL": "Đang trị thương",
    "REST": "Đang nghỉ",
    "CULTIVATE": "Đang tu luyện",
    "TRAIN_BODY": "Đang rèn thân",
    "WORK_MINING": "Đang khai khoáng",
    "WORK_FORGING": "Đang luyện khí",
    "WORK_HERBALISM": "Đang làm Linh Điền",
    "WORK_FORESTRY": "Đang làm Lâm Nghiệp",
    "HOLD": "Đang chờ lệnh",
    "BREAKTHROUGH": "Đang phá cảnh"
}

static func destination_for_action(action: StringName, previous: StringName = DEST_COURTYARD) -> StringName:
    match action:
        &"CULTIVATE", &"BREAKTHROUGH":
            return DEST_CULTIVATION
        &"TRAIN_BODY":
            return DEST_BODY_TRAINING
        &"WORK_MINING":
            return DEST_MINE
        &"WORK_HERBALISM":
            return DEST_SPIRIT_FIELD
        &"WORK_FORESTRY":
            return DEST_LINH_FOREST
        &"WORK_FORGING":
            return DEST_FORGE
        &"REST":
            return DEST_RESIDENCE
        &"HEAL":
            return DEST_MEDICINE
        &"SELL", &"BUY":
            return DEST_WAREHOUSE
        &"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT":
            return DEST_GATE
        &"HOLD":
            return DEST_COURTYARD
        &"EVALUATE", &"IDLE":
            return previous if DESTINATION_POSITIONS.has(str(previous)) else DEST_COURTYARD
        _:
            return previous if DESTINATION_POSITIONS.has(str(previous)) else DEST_COURTYARD

static func position_for_destination(destination: StringName) -> Vector2:
    return Vector2(DESTINATION_POSITIONS.get(str(destination), DESTINATION_POSITIONS["courtyard"]))

static func action_label(action: StringName) -> String:
    return str(ACTION_LABELS.get(str(action), str(action)))

static func is_outside_flow(action: StringName) -> bool:
    return action in [&"HUNT", &"TRAVEL", &"COMBAT", &"LOOT", &"RETURN_SECT"]
