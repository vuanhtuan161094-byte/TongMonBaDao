class_name DiscipleBirthCatalogueV2
extends RefCounted

# Canonical content IDs for the user-approved 2026-10-09 weighted birth catalogue.
# Index/order is deliberately static; saved characters store stable IDs, not names.
# Effect activation is owned by future V2 consumers, NEVER by this catalogue.
# Trait rows: [stable_id, Vietnamese display name, nature H/S/B, birth_weight].
const TRAITS = [
    [
        "ham_hoc",
        "Ham Học",
        "H",
        10
    ],
    [
        "nhat_tam",
        "Nhất Tâm",
        "H",
        4
    ],
    [
        "tri_nho_sau",
        "Trí Nhớ Sâu",
        "H",
        4
    ],
    [
        "suy_dien",
        "Suy Diễn",
        "S",
        4
    ],
    [
        "hoc_nhanh_lam_au",
        "Học Nhanh Làm Ẩu",
        "S",
        4
    ],
    [
        "cham_ma_chac",
        "Chậm Mà Chắc",
        "S",
        4
    ],
    [
        "tap_niem",
        "Tạp Niệm",
        "B",
        10
    ],
    [
        "kho_tiep_thu",
        "Khó Tiếp Thu",
        "B",
        10
    ],
    [
        "kinh_mach_on_dinh",
        "Kinh Mạch Ổn Định",
        "H",
        4
    ],
    [
        "kinh_mach_mong_manh",
        "Kinh Mạch Mong Manh",
        "B",
        10
    ],
    [
        "ngo_tinh",
        "Ngộ Tĩnh",
        "H",
        1
    ],
    [
        "tam_tinh_nhu_thuy",
        "Tâm Tĩnh Như Thủy",
        "H",
        4
    ],
    [
        "nong_voi_cau_thanh",
        "Nóng Vội Cầu Thành",
        "S",
        4
    ],
    [
        "can_man",
        "Cần Mẫn",
        "H",
        10
    ],
    [
        "cuong_cong",
        "Cuồng Công",
        "S",
        4
    ],
    [
        "luoi_nhac",
        "Lười Nhác",
        "B",
        10
    ],
    [
        "cau_tha",
        "Cẩu Thả",
        "S",
        10
    ],
    [
        "ti_mi",
        "Tỉ Mỉ",
        "S",
        10
    ],
    [
        "tiet_lieu",
        "Tiết Liệu",
        "H",
        4
    ],
    [
        "phung_phi",
        "Phung Phí",
        "S",
        4
    ],
    [
        "da_nhiem",
        "Đa Nhiệm",
        "H",
        4
    ],
    [
        "quen_tay",
        "Quen Tay",
        "H",
        4
    ],
    [
        "doi_nghe_kho",
        "Đổi Nghề Khó",
        "B",
        10
    ],
    [
        "ban_nang_chien_dau",
        "Bản Năng Chiến Đấu",
        "H",
        1
    ],
    [
        "linh_giac_sac_ben",
        "Linh Giác Sắc Bén",
        "H",
        4
    ],
    [
        "tam_than_kien_co",
        "Tâm Thần Kiên Cố",
        "H",
        4
    ],
    [
        "pha_giap_cam",
        "Phá Giáp Cảm",
        "H",
        4
    ],
    [
        "hap_tap",
        "Hấp Tấp",
        "S",
        10
    ],
    [
        "huyet_chien",
        "Huyết Chiến",
        "S",
        4
    ],
    [
        "bat_khuat",
        "Bất Khuất",
        "H",
        4
    ],
    [
        "tam_than_bat_on",
        "Tâm Thần Bất Ổn",
        "B",
        10
    ],
    [
        "tri_trong",
        "Trì Trọng",
        "S",
        10
    ],
    [
        "than_phap_nhe_nhang",
        "Thân Pháp Nhẹ Nhàng",
        "H",
        10
    ],
    [
        "phan_ung_nhanh",
        "Phản Ứng Nhanh",
        "H",
        10
    ],
    [
        "lao_luyen",
        "Lão Luyện",
        "H",
        10
    ],
    [
        "lieu_mang",
        "Liều Mạng",
        "S",
        10
    ],
    [
        "thua_thang_truy_kich",
        "Thừa Thắng Truy Kích",
        "H",
        1
    ],
    [
        "on_tran",
        "Ổn Trận",
        "H",
        10
    ],
    [
        "duoc_tam",
        "Dược Tâm",
        "H",
        4
    ],
    [
        "ho_tam",
        "Hộ Tâm",
        "H",
        4
    ],
    [
        "hoi_nguyen",
        "Hồi Nguyên",
        "H",
        4
    ],
    [
        "khi_huyet_kho_hop",
        "Khí Huyết Khó Hợp",
        "B",
        10
    ],
    [
        "duoc_ly_thong_thao",
        "Dược Lý Thông Thạo",
        "H",
        4
    ],
    [
        "thuong_binh_kinh_nghiem",
        "Thương Binh Kinh Nghiệm",
        "H",
        4
    ],
    [
        "cung_dau",
        "Cứng Đầu",
        "S",
        10
    ],
    [
        "ho_tri_ban_nang",
        "Hộ Trì Bản Năng",
        "H",
        1
    ],
    [
        "kiem_cam",
        "Kiếm Cảm",
        "H",
        1
    ],
    [
        "the_ngo",
        "Thể Ngộ",
        "H",
        1
    ],
    [
        "phap_cam",
        "Pháp Cảm",
        "H",
        1
    ],
    [
        "kiem_tam_on_dinh",
        "Kiếm Tâm Ổn Định",
        "H",
        4
    ],
    [
        "can_chien_lao_thanh",
        "Cận Chiến Lão Thành",
        "H",
        4
    ],
    [
        "phap_y_lien_mien",
        "Pháp Ý Liên Miên",
        "H",
        4
    ],
    [
        "tap_tu",
        "Tạp Tu",
        "S",
        10
    ],
    [
        "tham_an",
        "Tham Ăn",
        "S",
        10
    ],
    [
        "ken_an",
        "Kén Ăn",
        "S",
        10
    ],
    [
        "cu_dem",
        "Cú Đêm",
        "S",
        10
    ],
    [
        "ngu_nuong",
        "Ngủ Nướng",
        "S",
        10
    ],
    [
        "me_sach_se",
        "Mê Sạch Sẽ",
        "S",
        10
    ],
    [
        "bay_bua",
        "Bày Bừa",
        "S",
        10
    ],
    [
        "trom_an_vat",
        "Trộm Ăn Vặt",
        "B",
        10
    ],
    [
        "me_ngu_trua",
        "Mê Ngủ Trưa",
        "S",
        10
    ],
    [
        "mat_nhin_quang",
        "Mắt Nhìn Quặng",
        "H",
        1
    ],
    [
        "khuu_giac_linh_thao",
        "Khứu Giác Linh Thảo",
        "H",
        1
    ],
    [
        "thich_thu_nghiem",
        "Thích Thử Nghiệm",
        "S",
        4
    ],
    [
        "dem_tung_dong",
        "Đếm Từng Đồng",
        "S",
        10
    ],
    [
        "vua_lam_vua_hat",
        "Vừa Làm Vừa Hát",
        "S",
        10
    ],
    [
        "doi_viec_nhu_thay_ao",
        "Đổi Việc Như Thay Áo",
        "S",
        10
    ],
    [
        "hay_quen_dung_cu",
        "Hay Quên Dụng Cụ",
        "B",
        10
    ],
    [
        "hoc_qua_thuc_hanh",
        "Học Qua Thực Hành",
        "H",
        4
    ],
    [
        "ngo_dao_luc_quet_san",
        "Ngộ Đạo Lúc Quét Sân",
        "H",
        1
    ],
    [
        "be_quan_quen_ngay",
        "Bế Quan Quên Ngày",
        "S",
        4
    ],
    [
        "hoc_vet",
        "Học Vẹt",
        "S",
        10
    ],
    [
        "tri_nho_ca_vang",
        "Trí Nhớ Cá Vàng",
        "B",
        10
    ],
    [
        "me_suu_tam_cong_phap",
        "Mê Sưu Tầm Công Pháp",
        "S",
        4
    ],
    [
        "nua_dem_tinh_ngo",
        "Nửa Đêm Tỉnh Ngộ",
        "H",
        1
    ],
    [
        "so_dot_pha",
        "Sợ Đột Phá",
        "B",
        10
    ],
    [
        "nghe_giang_la_buon_ngu",
        "Nghe Giảng Là Buồn Ngủ",
        "S",
        4
    ],
    [
        "nhat_nhung_chay_nhanh",
        "Nhát Nhưng Chạy Nhanh",
        "S",
        10
    ],
    [
        "thu_dai",
        "Thù Dai",
        "H",
        4
    ],
    [
        "danh_hoi_dong",
        "Đánh Hội Đồng",
        "S",
        4
    ],
    [
        "chuyen_danh_len",
        "Chuyên Đánh Lén",
        "S",
        4
    ],
    [
        "ho_het_xung_phong",
        "Hò Hét Xung Phong",
        "S",
        4
    ],
    [
        "gia_chet_tai_tinh",
        "Giả Chết Tài Tình",
        "H",
        1
    ],
    [
        "tay_nhanh_hon_nao",
        "Tay Nhanh Hơn Não",
        "S",
        10
    ],
    [
        "vap_nhung_khong_nga",
        "Vấp Nhưng Không Ngã",
        "H",
        4
    ],
    [
        "lam_chuyen",
        "Lắm Chuyện",
        "S",
        10
    ],
    [
        "hay_mach_leo",
        "Hay Mách Lẻo",
        "S",
        10
    ],
    [
        "biet_tuot",
        "Biết Tuốt",
        "S",
        10
    ],
    [
        "hay_gay_su",
        "Hay Gây Sự",
        "S",
        10
    ],
    [
        "thich_khoe",
        "Thích Khoe",
        "S",
        10
    ],
    [
        "tot_bung_qua_da",
        "Tốt Bụng Quá Đà",
        "S",
        10
    ],
    [
        "me_lam_su_huynh",
        "Mê Làm Sư Huynh",
        "S",
        10
    ],
    [
        "cai_chay_cai_coi",
        "Cãi Chày Cãi Cối",
        "B",
        10
    ],
    [
        "lac_duong_co_duyen",
        "Lạc Đường Có Duyên",
        "S",
        1
    ],
    [
        "nhat_gi_cung_mang",
        "Nhặt Gì Cũng Mang",
        "S",
        4
    ],
    [
        "dung_gi_cung_mo",
        "Đụng Gì Cũng Mở",
        "S",
        4
    ],
    [
        "thinh_tai",
        "Thính Tai",
        "H",
        4
    ],
    [
        "xem_ban_do_nguoc",
        "Xem Bản Đồ Ngược",
        "B",
        10
    ],
    [
        "di_dau_cung_danh_dau",
        "Đi Đâu Cũng Đánh Dấu",
        "H",
        1
    ],
    [
        "so_ma",
        "Sợ Ma",
        "B",
        10
    ],
    [
        "li_don_khi_lac_rung",
        "Lì Đòn Khi Lạc Rừng",
        "H",
        4
    ]
]
# Fate rows: [stable_id, Vietnamese display name, birth_weight].
const FATES = [
    [
        "dai_khi_van_thanh",
        "Đại Khí Vãn Thành",
        3
    ],
    [
        "hong_tran_luyen_tam",
        "Hồng Trần Luyện Tâm",
        3
    ],
    [
        "pha_quan",
        "Phá Quân",
        3
    ],
    [
        "that_sat",
        "Thất Sát",
        3
    ],
    [
        "tham_lang",
        "Tham Lang",
        2
    ],
    [
        "thien_sat_co_tinh",
        "Thiên Sát Cô Tinh",
        2
    ],
    [
        "gap_du_hoa_lanh",
        "Gặp Dữ Hóa Lành",
        3
    ],
    [
        "thien_quyen_hong_phuc",
        "Thiên Quyến Hồng Phúc",
        3
    ],
    [
        "thon_thien",
        "Thôn Thiên",
        1
    ],
    [
        "van_phap_quy_nhat",
        "Vạn Pháp Quy Nhất",
        2
    ],
    [
        "kiem_tien_chuyen_the",
        "Kiếm Tiên Chuyển Thế",
        1
    ],
    [
        "duoc_vuong_tai_the",
        "Dược Vương Tại Thế",
        2
    ],
    [
        "tai_tinh_nhap_menh",
        "Tài Tinh Nhập Mệnh",
        2
    ],
    [
        "bach_kiep_bat_diet",
        "Bách Kiếp Bất Diệt",
        2
    ],
    [
        "thien_do_anh_tai",
        "Thiên Đố Anh Tài",
        1
    ],
    [
        "tuc_tue_chuyen_the",
        "Túc Tuệ Chuyển Thế",
        1
    ],
    [
        "doat_menh",
        "Đoạt Mệnh",
        1
    ],
    [
        "hau_tich_bac_phat",
        "Hậu Tích Bạc Phát",
        2
    ],
    [
        "nhat_niem_sinh_van_phap",
        "Nhất Niệm Sinh Vạn Pháp",
        1
    ],
    [
        "tu_bao_menh",
        "Tụ Bảo Mệnh",
        2
    ],
    [
        "bach_nghe_quy_tong",
        "Bách Nghệ Quy Tông",
        2
    ],
    [
        "tu_vi_de_menh",
        "Tử Vi Đế Mệnh",
        2
    ],
    [
        "thien_co_kha_khuy",
        "Thiên Cơ Khả Khuy",
        1
    ],
    [
        "thien_cong_khai_vat",
        "Thiên Công Khai Vật",
        1
    ]
]
# Kiếm Cốt (weight=12) is forbidden until a real sword/weapon consumer exists.
# Other physiques retain original proportions out of their 88 eligible weight.
const PHYSIQUES = [
    [
        "kim_cuong_ba_the",
        12
    ],
    [
        "han_am_the",
        10
    ],
    [
        "hoa_linh_the",
        10
    ],
    [
        "sinh_co_linh_the",
        8
    ],
    [
        "truong_sinh_the",
        8
    ],
    [
        "tu_la_chien_the",
        8
    ],
    [
        "huyet_sat_chi_the",
        7
    ],
    [
        "ngu_hanh_dao_the",
        6
    ],
    [
        "van_doc_linh_the",
        5
    ],
    [
        "huyen_nguyet_linh_the",
        4
    ],
    [
        "dau_chien_chi_the",
        3
    ],
    [
        "khong_linh_hu_the",
        3
    ],
    [
        "van_phap_dao_the",
        2
    ],
    [
        "vo_cau_dao_the",
        2
    ]
]
const BLOODLINES = ["chan_long_huyet","phuong_hoang_huyet","bach_ho_huyet","huyen_vu_huyet","thao_thiet_tan_huyet"]
const CONFLICTS = [
    [
        "kinh_mach_on_dinh",
        "kinh_mach_mong_manh"
    ],
    [
        "can_man",
        "luoi_nhac"
    ],
    [
        "cau_tha",
        "ti_mi"
    ],
    [
        "tiet_lieu",
        "phung_phi"
    ],
    [
        "hoi_nguyen",
        "khi_huyet_kho_hop"
    ]
]
const TRAIT_BIRTH_EXCLUSIONS = ["thuong_binh_kinh_nghiem"]
const FATE_BIRTH_EXCLUSIONS = ["kiem_tien_chuyen_the"]

static func valid_catalogue() -> bool:
    if TRAITS.size() != 101 or FATES.size() != 24 or PHYSIQUES.size() != 14 or BLOODLINES.size() != 5:
        return false
    var seen: Dictionary = {}
    for row in TRAITS:
        if row.size() != 4 or seen.has(str(row[0])) or int(row[3]) <= 0:
            return false
        seen[str(row[0])] = true
    for pair in CONFLICTS:
        if not seen.has(str(pair[0])) or not seen.has(str(pair[1])):
            return false
    return true

static func conflicts_with(trait_id: String, selected_ids: Array) -> bool:
    for pair in CONFLICTS:
        if pair[0] == trait_id and selected_ids.has(pair[1]):
            return true
        if pair[1] == trait_id and selected_ids.has(pair[0]):
            return true
    return false

static func weighted_trait_pool(nature: String, selected_ids: Array) -> Dictionary:
    var pool: Dictionary = {}
    for row in TRAITS:
        var identity := str(row[0])
        if str(row[2]) != nature or TRAIT_BIRTH_EXCLUSIONS.has(identity):
            continue
        if selected_ids.has(identity) or conflicts_with(identity, selected_ids):
            continue
        pool[identity] = int(row[3])
    return pool

static func weighted_fate_pool() -> Dictionary:
    var pool: Dictionary = {}
    for row in FATES:
        if FATE_BIRTH_EXCLUSIONS.has(str(row[0])):
            continue
        pool[str(row[0])] = int(row[2])
    return pool
