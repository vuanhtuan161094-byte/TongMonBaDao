class_name P0Content
extends RefCounted

const DISCIPLES := [
    {"id":"lam_thanh_vu", "name":"Lâm Thanh Vũ", "wallet":120, "combat_power":21.0, "risk_bias":0.82, "spend_bias":0.50, "survival_bias":0.35, "personality_id":"daring"},
    {"id":"tran_mac", "name":"Trần Mặc", "wallet":110, "combat_power":19.0, "risk_bias":0.18, "spend_bias":0.30, "survival_bias":0.88, "personality_id":"cautious"},
    {"id":"bach_nguyet", "name":"Bạch Nguyệt", "wallet":100, "combat_power":20.0, "risk_bias":0.50, "spend_bias":0.48, "survival_bias":0.58, "personality_id":"balanced"},
    {"id":"lam_an", "name":"Lâm An", "wallet":90, "combat_power":17.0, "risk_bias":0.24, "spend_bias":0.22, "survival_bias":0.72, "personality_id":"frugal_guarded"},
    {"id":"co_truong_phong", "name":"Cố Trường Phong", "wallet":80, "combat_power":24.0, "risk_bias":0.94, "spend_bias":0.58, "survival_bias":0.20, "personality_id":"reckless"},
    {"id":"trieu_linh_nhi", "name":"Triệu Linh Nhi", "wallet":130, "combat_power":18.5, "risk_bias":0.43, "spend_bias":0.62, "survival_bias":0.84, "personality_id":"prudent"}
]

const REGIONS := [
    {
        "id":"thanh_truc_lam",
        "name":"Thanh Trúc Lâm",
        "danger":1,
        "profit_modifier":0.85,
        "recommended_power":10.0,
        "monster_weights":{"truc_thu":0.65, "thanh_lang":0.30, "hac_lang":0.05}
    },
    {
        "id":"bach_thach_khe",
        "name":"Bạch Thạch Khê",
        "danger":2,
        "profit_modifier":1.00,
        "recommended_power":16.0,
        "monster_weights":{"truc_thu":0.25, "thanh_lang":0.60, "hac_lang":0.15}
    },
    {
        "id":"hac_phong_coc",
        "name":"Hắc Phong Cốc",
        "danger":3,
        "profit_modifier":1.25,
        "recommended_power":23.0,
        "monster_weights":{"truc_thu":0.10, "thanh_lang":0.45, "hac_lang":0.45}
    }
]

const MONSTERS := {
    "truc_thu":{"name":"Trúc Thử", "hp":34.0, "power":9.0, "loot":{"truc_linh_thao":1}},
    "thanh_lang":{"name":"Thanh Lang", "hp":58.0, "power":15.0, "loot":{"lang_bi":1, "lang_huyet":1}},
    "hac_lang":{"name":"Hắc Lang", "hp":82.0, "power":23.0, "loot":{"hac_lang_cot":1, "lang_huyet":1}}
}
