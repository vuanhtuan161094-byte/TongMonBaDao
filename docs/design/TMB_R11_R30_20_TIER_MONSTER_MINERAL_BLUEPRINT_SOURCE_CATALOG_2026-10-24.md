# TÔNG MÔN BÁ ĐẠO — DANH MỤC NGUỒN RƠI VÀ BẢN VẼ R11–R30
## 20 cảnh giới Tiên/Thần: khoáng, lâm sản, quái thường, Tinh Anh, Boss, Bí Cảnh và vật tư tiêu thụ

**24/10/2026 · DOCS-ONLY · DESIGN PROPOSED / NO CODE / NO PR29 / NO UI / NO SOURCE A / NO MERGE.** Owner mới duyệt HƯỚNG nghiên cứu. Không khóa ID, tỷ lệ, giá, số lượng hay nội dung. HIẾM là baseline thử nghiệm rơi đồ, không được gộp với độ khó map hoặc xác suất rèn.
**Nguồn đã đọc:** main `29b5fba448b0178cb520a4ada44b375b4b934e31`: `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/REALM_LADDER_V2_SPEC.md`, `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`, `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`, `docs/P3_7_BUILDING_TREE_SPEC.md`, `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`, `godot/src/simulation/resource/{resource_registry,warehouse_system}.gd`, `godot/src/simulation/combat/{monster_catalogue_v2,hunting_map_v2}.gd`, `godot/src/simulation/workforce/workforce_system.gd`, `godot/src/simulation/economy/economy_system.gd`. Tài liệu cha nhánh `docs/equipment-r1-r30-ascension-chanvan-combatv2-review-20261024`. Báo cáo công thức: `docs/research/TMB_R11_R30_FORGE_RECIPE_SUPPLY_SOFTLOCK_ECONOMY_OWNER_REVIEW_2026-10-24.md`.
**Ký hiệu:** [LOCK] luật canon, [SOURCE] ID/code đang tồn tại, [SEED] tên nguyên liệu chủ đề từ tài liệu cũ, [P] hoàn toàn mới/chưa đăng ký, [D] thiếu consumer; **không ID nào bắt đầu bằng eqv2_ đã được đăng ký, không có actor R11–R30 nào được tạo ra**.

## 0. Ranh giới canonical và thực tế
- Trang bị = 10 ô thường, item realm R1..30 (Nhân1–10/Tiên11–20/Thần21–30) độc lập 12 phẩm; 24 set×4 piece và ngưỡng2/3/4, cùng generation, Hỗn Độn chỉ Thần. Pháp Bảo/Phù là hệ khác. Vật phẩm Sect-owned unique item, cùng một Warehouse và one active worker job, save/receipt exactly-once.
- Thanh Trúc Lâm = MỘT map mở20 camp và30 đệ tử deployed theo nghiên cứu mới; không phải 20 bản đồ, cũng không có 30 bản đồ `hunt_rNN` thực tế. Bảng `hunt_rNN` cũ là PROJECTED thematic content, không phải entity runtime. `frontier_rNN` dưới đây chỉ là nhãn quy hoạch nguồn, KHÔNG là map/scene ID hiện có.
- `ResourceRegistry` thực có các ID sơ cấp `linh_moc,thanh_thiet,huyen_thiet,tinh_lang_bi,yeu_dan,linh_tuy` và nhiều vật liệu R11+ như `kim_cot_thao,tien_tuy_lien,than_mach_tinh,hon_don_tuy_hoa` **nhưng các vật liệu sau được phân loại body_gate_material, KHÔNG phải vật tư Forge**. Ấn `an_nhan_gioi/an_tien_gioi/an_than_gioi` cũng là Ấn cổng Luyện Thể, không tự dùng để thăng bậc đồ. Đây là bằng chứng dữ liệu, không phải giấy phép chuyển công năng.
- `MonsterCatalogueV2` main có **7 species thấp**; Nham Giáp Thú/Hắc Lang Vương có `loot_ready=false` trong catalog; không có quái Tiên/Thần mới. Các nguồn giả lập dưới đây không có model/animation Source A. `HuntingMapV2` chỉ có ba khu đầu và năm cấp độ cho ENCOUNTER, không phải 20 loot-level hay bảng per-kill future.
- `WarehouseSystem` có `locked/reserve_min`, không có ledger reserve theo lệnh Forge; `EconomySystem.V2_MARKET_CATALOG` chỉ gồm `linh_moc,thanh_thiet,thanh_linh_thao,linh_coc`. Không bán vật liệu Thần bằng giá bịa.

## 1. Kiến trúc tuyến nguồn trước khi đạt gear đích — chống softlock
**Mỗi bậc R11–R30 [P] có ba nguồn cơ bản lặp lại được**: (M) quặng Mỏ R tại vùng tiếp cận của đoàn đang sử dụng gear R−1, (F) sợi/gỗ R từ node tương ứng, (N) phần vật liệu thường R từ *mỗi xác quái thật* (không phải nhận item trên mỗi lần render). Vùng biên `frontier_rNN` đề xuất cho phép tới M/F/N với đội R−1 đã luyện tốt dù độ nguy hiểm cao; các quái sâu hơn R hay Tinh Anh/Boss là rủi ro tùy chọn. *Không tạo hard entry lock cần phải mặc đồ R để lấy được tài nguyên đầu tiên R.*
**Tuyến hiếm riêng**: (E) lõi Tinh Anh từ đúng actor life/loot once, (B) di vật Boss từ ONE HP pool/receipt (dù 30 đệ tử cùng đánh), (D) Bí Cảnh có thật và biên nhận nghiên cứu/bản vẽ. E/B/D dành cho bộ/đồ đặc sắc/Chân Văn về sau; không cần Boss để chế 10 ô cơ bản.
**Mở kiến thức cơ bản từng R:** đề xuất `eqv2_bp_rNN_basic_catalog` là unlock Sect-wide đã HỌC một lần sau một lệnh nghiên cứu thật: chứng cứ nhận được ≥1 quặng R +≥1 vật liệu thường R, phải tiêu hao chúng đúng một lần (không phải 1 nhiệm vụ UI ảo), có worker/Forge/tick và receipt; 10 template cơ bản cùng R được mở. Điều này là [P] và chưa có archive/ID/consumer. Set piece blueprint `eqv2_bp_rNN_set_<lineage_id>_<canonical_slot>` là 1 quyền học riêng mỗi món thuộc bốn món/24 lineage, không phải token đổi bất kỳ set. Nguồn dự kiến: 2 piece từ khảo cứu/camp/di tích, 1 piece Tinh Anh, 1 piece Bí Cảnh/Boss (lựa chọn định rõ từng bộ khi author), nhưng Boss-exclusive chỉ hiếm và KHÔNG gate trang bị cơ bản.
**Mỗi R là một SOURCE PROFILE**, không đồng nghĩa một scene duy nhất hay 10 cổng sẵn. Trong một map, quái có thể khác realm, hệ metal/wood/water/fire/earth hoặc advanced lightning/wind/ice/yang/nether; các tag này là khóa Combat V2 đã có, không chế ra nguyên tố Hỗn Độn mới.

## 2. Bảng 20 bậc, vật liệu thông dụng (100% đề xuất)
| Bậc chuẩn | Khoáng R / Sợi-gỗ R (ID đề xuất, không tồn tại) | Quái thường và vật liệu | Hệ |
|---|---|---|---|
| **R11 Tiên · Nhân Tiên** | Tiên Thiết → `eqv2_r11_ore`; Vân Mộc → `eqv2_r11_fiber` | Vân Giác Lộc (`eqv2_mob_r11_normal`) → `eqv2_r11_beast` | `wood` |
| **R12 Tiên · Địa Tiên** | Địa Tiên Khoáng → `eqv2_r12_ore`; Địa Mạch Đằng → `eqv2_r12_fiber` | Địa Mạch Thạch Giải (`eqv2_mob_r12_normal`) → `eqv2_r12_beast` | `earth` |
| **R13 Tiên · Thiên Tiên** | Thiên Tiên Khoáng → `eqv2_r13_ore`; Thiên Vũ Thảo → `eqv2_r13_fiber` | Thiên Phong Ưng (`eqv2_mob_r13_normal`) → `eqv2_r13_beast` | `wind` |
| **R14 Tiên · Chân Tiên** | Chân Tiên Khoáng → `eqv2_r14_ore`; Chân Hỏa Đằng → `eqv2_r14_fiber` | Chân Viêm Hồ (`eqv2_mob_r14_normal`) → `eqv2_r14_beast` | `fire` |
| **R15 Tiên · Huyền Tiên** | Huyền Tiên Khoáng → `eqv2_r15_ore`; Huyền Sương Chi → `eqv2_r15_fiber` | Huyền Băng Xà (`eqv2_mob_r15_normal`) → `eqv2_r15_beast` | `ice` |
| **R16 Tiên · Kim Tiên** | Kim Tiên Khoáng → `eqv2_r16_ore`; Kim Khuyết Mộc → `eqv2_r16_fiber` | Kim Giáp Tê (`eqv2_mob_r16_normal`) → `eqv2_r16_beast` | `metal` |
| **R17 Tiên · Thái Ất Kim Tiên** | Thái Ất Khoáng → `eqv2_r17_ore`; Thái Ất Linh Đằng → `eqv2_r17_fiber` | Thái Ất Mộc Linh (`eqv2_mob_r17_normal`) → `eqv2_r17_beast` | `wood` |
| **R18 Tiên · Đại La Kim Tiên** | Đại La Khoáng → `eqv2_r18_ore`; Đại La Thủy Tảo → `eqv2_r18_fiber` | Đại La Thủy Giao (`eqv2_mob_r18_normal`) → `eqv2_r18_beast` | `water` |
| **R19 Tiên · Tiên Vương** | Tiên Vương Khoáng → `eqv2_r19_ore`; Vương Vực Hồn Thảo → `eqv2_r19_fiber` | Hư Ảnh Lang (`eqv2_mob_r19_normal`) → `eqv2_r19_beast` | `nether` |
| **R20 Tiên · Tiên Đế** | Tiên Đế Khoáng → `eqv2_r20_ore`; Đế Dương Chi → `eqv2_r20_fiber` | Đế Nhật Hỏa Điểu (`eqv2_mob_r20_normal`) → `eqv2_r20_beast` | `yang` |
| **R21 Thần · Thần Nhân** | Sơ Thần Khoáng → `eqv2_r21_ore`; Sơ Thần Linh Bì → `eqv2_r21_fiber` | Sơ Thần Thạch Nhân (`eqv2_mob_r21_normal`) → `eqv2_r21_beast` | `earth` |
| **R22 Thần · Chân Thần** | Chân Thần Khoáng → `eqv2_r22_ore`; Chân Thần Lôi Đằng → `eqv2_r22_fiber` | Chân Thần Lôi Thú (`eqv2_mob_r22_normal`) → `eqv2_r22_beast` | `lightning` |
| **R23 Thần · Thiên Thần** | Thiên Thần Khoáng → `eqv2_r23_ore`; Thiên Thần Phong Tàm → `eqv2_r23_fiber` | Thiên Thần Phong Điêu (`eqv2_mob_r23_normal`) → `eqv2_r23_beast` | `wind` |
| **R24 Thần · Thần Quân** | Thần Quân Khoáng → `eqv2_r24_ore`; Quân Thần Linh Mộc → `eqv2_r24_fiber` | Thần Quân Chiến Viên (`eqv2_mob_r24_normal`) → `eqv2_r24_beast` | `metal` |
| **R25 Thần · Thần Vương** | Thần Vương Khoáng → `eqv2_r25_ore`; Vương Thủy Linh Chi → `eqv2_r25_fiber` | Thần Vương Huyền Quy (`eqv2_mob_r25_normal`) → `eqv2_r25_beast` | `water` |
| **R26 Thần · Thần Hoàng** | Thần Hoàng Khoáng → `eqv2_r26_ore`; Hoàng Viêm Thần Đằng → `eqv2_r26_fiber` | Thần Hoàng Viêm Điểu (`eqv2_mob_r26_normal`) → `eqv2_r26_beast` | `fire` |
| **R27 Thần · Thần Đế** | Thần Đế Khoáng → `eqv2_r27_ore`; Đế U Linh Mộc → `eqv2_r27_fiber` | U Minh Thần Long (`eqv2_mob_r27_normal`) → `eqv2_r27_beast` | `nether` |
| **R28 Thần · Thần Tôn** | Thần Tôn Khoáng → `eqv2_r28_ore`; Tôn Hàn Linh Ti → `eqv2_r28_fiber` | Thần Tôn Băng Lân (`eqv2_mob_r28_normal`) → `eqv2_r28_beast` | `ice` |
| **R29 Thần · Hỗn Độn Thần** | Hỗn Độn Khoáng → `eqv2_r29_ore`; Hỗn Độn Linh Tảo → `eqv2_r29_fiber` | Hỗn Độn Cự Thú (`eqv2_mob_r29_normal`) → `eqv2_r29_beast` | `nether` |
| **R30 Thần · Sáng Thế Chủ** | Sáng Thế Khoáng → `eqv2_r30_ore`; Sáng Thế Linh Mộc → `eqv2_r30_fiber` | Sáng Thế Linh Thú (`eqv2_mob_r30_normal`) → `eqv2_r30_beast` | `yang` |

## 3. Tinh Anh / Boss / Bí Cảnh theo bậc (100% ứng viên, không phải nguồn đang chạy)
Một Boss chỉ có một actor world/event generation và một loot pool, không “thưởng cho từng người đánh”. Lõi Elite/Boss có candidate ID riêng nhưng **chưa chốt xác suất hoặc consumer**, không được coi đã rơi, cũng không phải nguyên liệu bắt buộc để có bộ cơ bản.
| R | Tinh Anh và lõi | Boss và di vật | Bí Cảnh, 2 dòng bộ ứng viên |
|---|---|---|---|
| **R11** | Mộc Giáp Lộc (`eqv2_mob_r11_elite`) → `eqv2_r11_elite_core` | Tiên Vân Lộc Vương (`eqv2_mob_r11_boss`) → `eqv2_r11_boss_relic` | Vân Môn Phế Tích; **Truy Phong / Mộc Linh** |
| **R12** | Mạch Tâm Giải (`eqv2_mob_r12_elite`) → `eqv2_r12_elite_core` | Địa Mạch Long Quy (`eqv2_mob_r12_boss`) → `eqv2_r12_boss_relic` | Cổ Mạch Địa Cung; **Hộ Sơn / Địa Mạch** |
| **R13** | Lôi Vũ Ưng (`eqv2_mob_r13_elite`) → `eqv2_r13_elite_core` | Thiên Phong Ưng Hoàng (`eqv2_mob_r13_boss`) → `eqv2_r13_boss_relic` | Thiên Vũ Điện; **Sát Tinh / Truy Phong** |
| **R14** | Viêm Vĩ Hồ (`eqv2_mob_r14_elite`) → `eqv2_r14_elite_core` | Chân Hỏa Hồ Vương (`eqv2_mob_r14_boss`) → `eqv2_r14_boss_relic` | Chân Hỏa Động; **Huyết Chiến / Đan Tâm** |
| **R15** | Băng Lân Xà (`eqv2_mob_r15_elite`) → `eqv2_r15_elite_core` | Huyền Thủy Giao (`eqv2_mob_r15_boss`) → `eqv2_r15_boss_relic` | Huyền Băng Cung; **Hàn Vân / Tịnh Thần** |
| **R16** | Thiết Bối Tê (`eqv2_mob_r16_elite`) → `eqv2_r16_elite_core` | Kim Giáp Thánh Tê (`eqv2_mob_r16_boss`) → `eqv2_r16_boss_relic` | Kim Tiên Chiến Trường; **Phá Cương / Thiên Công** |
| **R17** | Mộc Linh Hộ Pháp (`eqv2_mob_r17_elite`) → `eqv2_r17_elite_core` | Thái Ất Thụ Vương (`eqv2_mob_r17_boss`) → `eqv2_r17_boss_relic` | Thái Ất Động Thiên; **Thanh Linh / Mộc Linh** |
| **R18** | Thủy Hộ Giao (`eqv2_mob_r18_elite`) → `eqv2_r18_elite_core` | Đại La Hải Giao Vương (`eqv2_mob_r18_boss`) → `eqv2_r18_boss_relic` | Đại La Thủy Phủ; **Thiên Trận / Ngũ Hành** |
| **R19** | Ảnh Lang Thống Lĩnh (`eqv2_mob_r19_elite`) → `eqv2_r19_elite_core` | Tiên Vương Hồn Lang (`eqv2_mob_r19_boss`) → `eqv2_r19_boss_relic` | Vương Vực Tàn Thành; **Huyết Liệp / Trấn Yêu** |
| **R20** | Dương Diễm Hỏa Điểu (`eqv2_mob_r20_elite`) → `eqv2_r20_elite_core` | Đế Nhật Kim Ô (`eqv2_mob_r20_boss`) → `eqv2_r20_boss_relic` | Đế Giới Tàn Điện; **Thiên Kích / Tịnh Thần** |
| **R21** | Thạch Giáp Thần Vệ (`eqv2_mob_r21_elite`) → `eqv2_r21_elite_core` | Sơ Thần Sơn Quân (`eqv2_mob_r21_boss`) → `eqv2_r21_boss_relic` | Sơ Thần Cổ Địa; **Hộ Sơn / Hỗn Độn** |
| **R22** | Lôi Cốt Thần Vệ (`eqv2_mob_r22_elite`) → `eqv2_r22_elite_core` | Chân Thần Lôi Chủ (`eqv2_mob_r22_boss`) → `eqv2_r22_boss_relic` | Lôi Thiên Thần Điện; **Cửu Lôi / Thiên Kích** |
| **R23** | Phong Vũ Thần Vệ (`eqv2_mob_r23_elite`) → `eqv2_r23_elite_core` | Thiên Thần Phong Quân (`eqv2_mob_r23_boss`) → `eqv2_r23_boss_relic` | Phong Ấn Thiên Cung; **Truy Phong / Sát Tinh** |
| **R24** | Chiến Viên Thần Tướng (`eqv2_mob_r24_elite`) → `eqv2_r24_elite_core` | Thần Quân Chiến Chủ (`eqv2_mob_r24_boss`) → `eqv2_r24_boss_relic` | Thần Quân Chiến Trường; **Phá Cương / Thiên Công** |
| **R25** | Huyền Quy Trấn Thủy (`eqv2_mob_r25_elite`) → `eqv2_r25_elite_core` | Thần Vương Thủy Đế (`eqv2_mob_r25_boss`) → `eqv2_r25_boss_relic` | Thần Vương Di Giới; **Thiên Trận / Ngũ Hành** |
| **R26** | Viêm Vũ Thần Vệ (`eqv2_mob_r26_elite`) → `eqv2_r26_elite_core` | Thần Hoàng Chân Phượng (`eqv2_mob_r26_boss`) → `eqv2_r26_boss_relic` | Thần Hoàng Hỏa Địa; **Huyết Chiến / Đan Tâm** |
| **R27** | U Minh Đế Vệ (`eqv2_mob_r27_elite`) → `eqv2_r27_elite_core` | Thần Đế U Long (`eqv2_mob_r27_boss`) → `eqv2_r27_boss_relic` | Thần Đế Cấm Vực; **Huyền Ấn / Thực Cốt** |
| **R28** | Băng Phách Thần Vệ (`eqv2_mob_r28_elite`) → `eqv2_r28_elite_core` | Thần Tôn Hàn Chủ (`eqv2_mob_r28_boss`) → `eqv2_r28_boss_relic` | Thần Tôn Đạo Trường; **Hàn Vân / Tịnh Thần** |
| **R29** | Hỗn Độn Hộ Vệ (`eqv2_mob_r29_elite`) → `eqv2_r29_elite_core` | Hỗn Độn Thần Thú Vương (`eqv2_mob_r29_boss`) → `eqv2_r29_boss_relic` | Hỗn Độn Biên Vực; **Hỗn Độn / Trấn Yêu** |
| **R30** | Sáng Thế Thần Vệ (`eqv2_mob_r30_elite`) → `eqv2_r30_elite_core` | Sáng Thế Thiên Chủ (`eqv2_mob_r30_boss`) → `eqv2_r30_boss_relic` | Sáng Thế Nguyên Cảnh; **Thanh Linh / Hỗn Độn** |

## 4. Manifest 100 candidate vật liệu + 60 species mới + 20 archive unlock
Năm hậu tố tài nguyên cho mỗi R: `ore`, `fiber`, `beast` là vật tư nền từ node/quái thường; `elite_core` và `boss_relic` là nguồn chase và hiện CHỜ consumer. `eqv2_mob_rNN_normal/elite/boss` là **ID của species** dự kiến, KHÔNG phải vật phẩm Kho. `eqv2_bp_rNN_basic_catalog` là quyền học ở archive Sect, không phải một vật phẩm stackable. Hai nguồn bãi/bộ gợi ý mỗi R chỉ để chọn nội dung thực hiện sau, không mở đủ96 set template ở mọi bậc.
| Rank | Năm candidate Material IDs (đều chưa có trong Registry) | 4 candidate content IDs / quyền nghiên cứu |
|---|---|---|
| R11 | `eqv2_r11_ore`; `eqv2_r11_fiber`; `eqv2_r11_beast`; `eqv2_r11_elite_core`; `eqv2_r11_boss_relic` | `eqv2_mob_r11_normal`, `eqv2_mob_r11_elite`, `eqv2_mob_r11_boss`; `eqv2_bp_r11_basic_catalog` |
| R12 | `eqv2_r12_ore`; `eqv2_r12_fiber`; `eqv2_r12_beast`; `eqv2_r12_elite_core`; `eqv2_r12_boss_relic` | `eqv2_mob_r12_normal`, `eqv2_mob_r12_elite`, `eqv2_mob_r12_boss`; `eqv2_bp_r12_basic_catalog` |
| R13 | `eqv2_r13_ore`; `eqv2_r13_fiber`; `eqv2_r13_beast`; `eqv2_r13_elite_core`; `eqv2_r13_boss_relic` | `eqv2_mob_r13_normal`, `eqv2_mob_r13_elite`, `eqv2_mob_r13_boss`; `eqv2_bp_r13_basic_catalog` |
| R14 | `eqv2_r14_ore`; `eqv2_r14_fiber`; `eqv2_r14_beast`; `eqv2_r14_elite_core`; `eqv2_r14_boss_relic` | `eqv2_mob_r14_normal`, `eqv2_mob_r14_elite`, `eqv2_mob_r14_boss`; `eqv2_bp_r14_basic_catalog` |
| R15 | `eqv2_r15_ore`; `eqv2_r15_fiber`; `eqv2_r15_beast`; `eqv2_r15_elite_core`; `eqv2_r15_boss_relic` | `eqv2_mob_r15_normal`, `eqv2_mob_r15_elite`, `eqv2_mob_r15_boss`; `eqv2_bp_r15_basic_catalog` |
| R16 | `eqv2_r16_ore`; `eqv2_r16_fiber`; `eqv2_r16_beast`; `eqv2_r16_elite_core`; `eqv2_r16_boss_relic` | `eqv2_mob_r16_normal`, `eqv2_mob_r16_elite`, `eqv2_mob_r16_boss`; `eqv2_bp_r16_basic_catalog` |
| R17 | `eqv2_r17_ore`; `eqv2_r17_fiber`; `eqv2_r17_beast`; `eqv2_r17_elite_core`; `eqv2_r17_boss_relic` | `eqv2_mob_r17_normal`, `eqv2_mob_r17_elite`, `eqv2_mob_r17_boss`; `eqv2_bp_r17_basic_catalog` |
| R18 | `eqv2_r18_ore`; `eqv2_r18_fiber`; `eqv2_r18_beast`; `eqv2_r18_elite_core`; `eqv2_r18_boss_relic` | `eqv2_mob_r18_normal`, `eqv2_mob_r18_elite`, `eqv2_mob_r18_boss`; `eqv2_bp_r18_basic_catalog` |
| R19 | `eqv2_r19_ore`; `eqv2_r19_fiber`; `eqv2_r19_beast`; `eqv2_r19_elite_core`; `eqv2_r19_boss_relic` | `eqv2_mob_r19_normal`, `eqv2_mob_r19_elite`, `eqv2_mob_r19_boss`; `eqv2_bp_r19_basic_catalog` |
| R20 | `eqv2_r20_ore`; `eqv2_r20_fiber`; `eqv2_r20_beast`; `eqv2_r20_elite_core`; `eqv2_r20_boss_relic` | `eqv2_mob_r20_normal`, `eqv2_mob_r20_elite`, `eqv2_mob_r20_boss`; `eqv2_bp_r20_basic_catalog` |
| R21 | `eqv2_r21_ore`; `eqv2_r21_fiber`; `eqv2_r21_beast`; `eqv2_r21_elite_core`; `eqv2_r21_boss_relic` | `eqv2_mob_r21_normal`, `eqv2_mob_r21_elite`, `eqv2_mob_r21_boss`; `eqv2_bp_r21_basic_catalog` |
| R22 | `eqv2_r22_ore`; `eqv2_r22_fiber`; `eqv2_r22_beast`; `eqv2_r22_elite_core`; `eqv2_r22_boss_relic` | `eqv2_mob_r22_normal`, `eqv2_mob_r22_elite`, `eqv2_mob_r22_boss`; `eqv2_bp_r22_basic_catalog` |
| R23 | `eqv2_r23_ore`; `eqv2_r23_fiber`; `eqv2_r23_beast`; `eqv2_r23_elite_core`; `eqv2_r23_boss_relic` | `eqv2_mob_r23_normal`, `eqv2_mob_r23_elite`, `eqv2_mob_r23_boss`; `eqv2_bp_r23_basic_catalog` |
| R24 | `eqv2_r24_ore`; `eqv2_r24_fiber`; `eqv2_r24_beast`; `eqv2_r24_elite_core`; `eqv2_r24_boss_relic` | `eqv2_mob_r24_normal`, `eqv2_mob_r24_elite`, `eqv2_mob_r24_boss`; `eqv2_bp_r24_basic_catalog` |
| R25 | `eqv2_r25_ore`; `eqv2_r25_fiber`; `eqv2_r25_beast`; `eqv2_r25_elite_core`; `eqv2_r25_boss_relic` | `eqv2_mob_r25_normal`, `eqv2_mob_r25_elite`, `eqv2_mob_r25_boss`; `eqv2_bp_r25_basic_catalog` |
| R26 | `eqv2_r26_ore`; `eqv2_r26_fiber`; `eqv2_r26_beast`; `eqv2_r26_elite_core`; `eqv2_r26_boss_relic` | `eqv2_mob_r26_normal`, `eqv2_mob_r26_elite`, `eqv2_mob_r26_boss`; `eqv2_bp_r26_basic_catalog` |
| R27 | `eqv2_r27_ore`; `eqv2_r27_fiber`; `eqv2_r27_beast`; `eqv2_r27_elite_core`; `eqv2_r27_boss_relic` | `eqv2_mob_r27_normal`, `eqv2_mob_r27_elite`, `eqv2_mob_r27_boss`; `eqv2_bp_r27_basic_catalog` |
| R28 | `eqv2_r28_ore`; `eqv2_r28_fiber`; `eqv2_r28_beast`; `eqv2_r28_elite_core`; `eqv2_r28_boss_relic` | `eqv2_mob_r28_normal`, `eqv2_mob_r28_elite`, `eqv2_mob_r28_boss`; `eqv2_bp_r28_basic_catalog` |
| R29 | `eqv2_r29_ore`; `eqv2_r29_fiber`; `eqv2_r29_beast`; `eqv2_r29_elite_core`; `eqv2_r29_boss_relic` | `eqv2_mob_r29_normal`, `eqv2_mob_r29_elite`, `eqv2_mob_r29_boss`; `eqv2_bp_r29_basic_catalog` |
| R30 | `eqv2_r30_ore`; `eqv2_r30_fiber`; `eqv2_r30_beast`; `eqv2_r30_elite_core`; `eqv2_r30_boss_relic` | `eqv2_mob_r30_normal`, `eqv2_mob_r30_elite`, `eqv2_mob_r30_boss`; `eqv2_bp_r30_basic_catalog` |

## 5. Tuyến blueprint mỗi bậc và nguồn có tính kế hoạch
- Basic R: vật tư ore/fiber/beast khai thác từ frontier qua hoạt động thật; thu chứng cứ một ore+one beast qua receipt hợp lệ, làm research job có tiêu thụ, lần đầu unlock đủ 10 ô **trong cùng R**, tất cả những lần sau rèn phải trả material+work/time thật. Nếu người chơi có đoàn nghề không giao tranh, cần thêm một đường thật: Sect trade/ủy thác có giới hạn và chi phí vật chất tương đương **chỉ khi NPC market/commission consumer được tác giả hóa**, hiện tại không có.
- Set R: mỗi dòng 4 canonical positions, blueprint riêng từng vị trí, source map/camp and monster specific. Đề xuất cho từng bộ **một đường F30/F75 nếu work consumer thật**, 2 mảnh tra cứu từ Bí Cảnh/camp nghiên cứu, 1 từ Elite, Boss optional chase một vị trí. Hai dòng set trên mỗi bậc ở `3` chỉ là đề xuất chủ đề, KHÔNG có item template hoặc affix active. Thiên Cơ/Phù Văn chờ consumer nghề; Cửu Lôi/chuyên kỹ năng chờ skill thật; Hỗn Độn chỉ Thần.
- Premium R: Boss/Elite relic ONLY when named item recipe, rare grade9–12 source, individual Chân Văn inscription catalyst consumer and exactly-once loot registered. Không lấy generic Boss relic để đổi Chí Tôn/Chân Văn bất kỳ. Không tự nhân rare chance của HIẾM Thanh Trúc Lâm cho mọi Boss Tiên/Thần.
- Need minimum authoring per R: physical resource registry IDs; source spawn/biome/nav; species legal race/element/stats/behavior; genuine node and kill receipt; actual recipe & one-time blueprint archive; Forge worker/building; sale/salvage rules if needed; qualified access from R−1. Nếu thiếu một mắt xích, **BLOCKED FOR GAMEPLAY** chứ không bù bằng fictitious source.
- Other approved restrictions stay: Combat V2 canonical, one Warehouse & tick/One Active Job/Injury0/1/120, old P2 migration, 30 active hunters per proposed Thanh Trúc Lâm, never all 3,000 inside one map; no new price, item power or gear bonus locked.

## 6. Các quyết định cần OWNER duyệt
1. Chấp nhận mỗi R có ba nguồn baseline (ore/fiber/normal beast) ở vùng biên cho đội R−1, và E/B/D chỉ là chase; M/F/N không cần gear R để mở.
2. Duyệt hay sửa **cách đặt tên** 100 ứng viên ID vật liệu và 60 species, đồng thời không coi chúng có sẵn trong Source A hoặc runtime.
3. Đồng ý về NGUYÊN TẮC bản vẽ basic R học Sect-wide sau research thật, và từng set piece có blueprint theo canonical, chờ định nguồn từng món.
4. Không dùng cặp vật liệu/Ấn `body_gate` tự động vào Forge; các tài nguyên Tiên/Thần khác phải có registry, source, sink riêng.
5. Chưa khóa odds, rèn, phí, giá bán, item/stats, thời gian và không cho code. Xem companion nghiên cứu công thức, kinh tế, test fixture.
