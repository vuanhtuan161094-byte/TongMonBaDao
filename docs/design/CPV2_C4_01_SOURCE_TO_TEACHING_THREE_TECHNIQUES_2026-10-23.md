# CPV2-C4-01 — Ba chuỗi Công Pháp từ nguồn thật đến Tàng Kinh Các và học tập

**Ngày 2026-10-23 | DOCS ONLY | Gốc `main@29b5fba448b0178cb520a4ada44b375b4b934e31`**. Không code, merge, FULL/CI, không chạm PR#24/#25 hoặc Codex MASTER RECOVERY.  
**LOCKED OWNER:** C4 = định nghĩa họ/role/element/hiệu ứng thật trước, đếm số sau; **CP4=A** = kết hợp săn quái/Boss/mảnh/nghiên cứu/truyền thừa *tùy từng công pháp*, không phải mỗi cuốn phải có mọi nguồn. **CP1–CP3 và CP5 vẫn OPEN**; chưa khóa tỷ lệ Boss, tặng sách khởi đầu, nguyên liệu/timing.  
Authority: `AGENTS.md`, `GAME_SYSTEM_ARCHITECTURE`, `TECHNIQUE_V2_SPEC`, `COMBAT_SKILLS_V2_SPEC`, `P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC`, actual GDScript files. Hai tài liệu C4 trước là research **ở nhánh docs khác**, không phải main hay code.

## 1. Source ledger (những gì thực sự tồn tại)

| Entity | SOURCE thực | Điều có trong P2 / map | Không được ngộ nhận là có trong V2 |
|---|---|---|---|
| Dưỡng Khí Quyết `duong_khi_quyet` | `godot/src/simulation/technique/technique_system.gd`, `TECHNIQUES` | rarity `common`, `spell/wood/growth`; mảnh **8**; học **40 Cống Hiến + 15 Linh Thạch cá nhân**; `cultivation_per_level=0.05` P2 | Chưa có nghiên cứu V2, nguồn `thanh_lang` per-kill và V2 effect source; 0.05 không tự thành modifier của CombatStatsV2 |
| Huyền Giáp Công `huyen_giap_cong` | cùng tệp | `mysterious`, `body/earth/defense`; mảnh **12**; học **75 Cống Hiến + 30 Linh Thạch cá nhân**; `defense_per_level=.035`, `combat_per_level=.6` P2 | P2 defense multiplier là consumer P2, chưa chứng minh mapping tới Combat V2; không nhân hiệu quả theo cảnh giới |
| P2 lưu sách/học | `TechniqueSystem.craft_manual()`, `archive_manual()`, `learn_technique()` | đủ mảnh→manual, archive tiêu thụ bản đầu thành `sect.technique_library`, sau đó học không tiêu thêm sách; người học trả cá nhân và Linh Thạch chuyển về Sect; **max3 learned, one active** legacy | V2 cần learned-many, **1 Chủ Tu + 2 Phụ Tu**, năm mốc mastery và thời gian học; không được giả là đã code |
| P2 farm mảnh | `TechniqueSystem.roll_farm_loot()` và `deposit_special_inventory()` | 26/34/42% **mảnh per P2 farm invocation** theo danger1/2/3; gacha weights **38/20/18/10/9/5** chọn sách đủ điều kiện | KHÔNG phải tỷ lệ trên một `B3 paid kill`; không thanh toán hai root payout cho cùng reward |
| Thanh Trúc Lâm | `HuntingMapV2.REGION_CONTENT["thanh_truc_lam"]` | vùng R01/floor1 có chọn normal `truc_thu=0.65`, `thanh_lang=0.30`, `hac_lang=0.05` **trọng số một slot normal**; `HuntingMapV2.claim_reward` trao đồ **per encounter thắng** | Mảnh kỹ thuật theo `monster_species_id` chưa tồn tại; không coi 30% là drop chance |
| Nham Giáp Thú | `MonsterCatalogueV2.nham_giap_thu` + `HuntingMapV2` | ID quái **Elite earth** tồn tại trong Thanh Trúc Lâm, `loot_ready=false` | Huyền Giáp fragments từ elite mới là **PROPOSED** |
| Hắc Lang Vương | `MonsterCatalogueV2.hac_lang_vuong` | Boss ID tồn tại, `element=nether`, `loot_ready=false`, boss-phase pending | Bí tịch Boss **KHÔNG live**; nether không tự là Linh Căn thứ sáu |
| Nguyên liệu có ID | `ResourceRegistry` | `linh_moc` market_value=2, `linh_tuy` 14, `tinh_lang_bi` 10, `yeu_dan` 18 | Đây là reference value, không bảo đảm shop mua bán vô hạn; không tự sinh mảnh |

**Bất biến**: một Sect Warehouse, một clock, One Active Job, Combat V2, một trả thưởng B3/encounter-root hợp lệ và save exactly-once. Boss đa đội có **một HP + một Sect loot pool**, không last hit, không tự khóa split 60/40. Trả Tu Vi mỗi kill là authority khác loot và phải giữ chuẩn owner mới nhất.

## 2. Ba trường hợp content (mỗi trường hợp có vòng khép kín)

| Content | Trải nghiệm người chơi | Nguồn PROPOSED dựa trên ID thật | Nhận/đổi | Tác dụng cuối | Điều kiện triển khai |
|---|---|---|---|---|---|
| **Dưỡng Khí Quyết** — ID `duong_khi_quyet` SOURCE P2 | cơ sở tu luyện, chiếm Chủ Tu hay Phụ Tu nếu tác dụng đủ khác tank | `thanh_truc_lam/thanh_lang` normal, mảnh riêng **PROPOSED**; **hoặc** truyền thừa starter hợp lệ nếu owner duyệt CP2=A (chưa duyệt) | 8 mảnh chỉ là SOURCE P2 tham chiếu; `K` V2 chưa khóa; craft/research→bản hoàn chỉnh→archive→dạy | P2 `cultivation_gain_multiplier` có thật; V2 effect source và active-slot main/aux cần author/test, không copy P2 .05 tự động | nguồn per-kill, fragment ID, recipe/time, learning V2 còn BLOCKED |
| **Huyền Giáp Công** — ID `huyen_giap_cong` SOURCE P2 | chuyển lựa chọn sang Body/tanker, thay vì mọi người dùng sách tăng Tu Vi | mảnh bình thường từ `truc_thu` Thanh Trúc Lâm **PROPOSED**; mảnh bổ sung từ `nham_giap_thu` Elite **PROPOSED** | K=12 dùng P2 tham chiếu; đủ mảnh và vật liệu hợp lệ→nghiên cứu→archive→học thật | P2 `incoming_damage_multiplier` có thật, nhưng V2 cần real consumer/stack group, source tags, không dùng P2 `combat_power` làm ATK | Elite loot_ready=false; normal named fragment chưa đăng ký; chưa ghi nhận V2 effect |
| **Hắc Lang Hồn Quyết** — `cpv2_proposed_hac_lang_hon_quyet` **NEW/NOT LIVE** | công pháp Boss độc đáo **OPTIONAL**, không bắt buộc đột phá R02 hay mở nghề | nguyên bản CHỈ từ `hac_lang_vuong` khi loot thật được author; mảnh có thể từ chính Boss milestone nếu owner chọn CP3, không có loot toàn cục | full → lưu archive, hoặc named K fragments + real recipe → lưu; một Sect copy truyền dạy nhiều người có tư cách | **CONSUMER BLOCKED**: phải xác định một unique passive Combat V2/skill synergy có bằng chứng, nếu không loại khỏi catalog | monster loot_ready=false, không tự tạo passive/hệ nether/root mới; CP5 tỉ lệ Boss OPEN |

**C4 không ép** 3 cuốn này thành đúng 3 Phàm. Theo P2, Dưỡng=common, Huyền Giáp=mysterious; công pháp Boss mới chưa có phẩm, role hay hiệu ứng thật. Không dùng công thức cấp phẩm = cấp tu vi. Nếu Boss book không có vai trò riêng ngoài Huyền Giáp, **KHÔNG author** chỉ vì tên hiếm.

## 3. Cùng một pipeline có receipts riêng và không lặp tiền

```text
[event hợp lệ: paid normal kill / paid Elite kill / shared boss death]
 → lọc exact region/species/loot_kind; seeded chance từ event id + pool revision
 → ONE Sect-owned named fragment OR legal full manuscript; durable award receipt
 → accumulate named fragments in Sect state / Warehouse đúng loại; no carried loot bag
 → research order: K fragments + exact registered ingredients + authorized labor
 → durable research debit/settle ONCE = ONE complete manual
 → first book archive ONCE, Sect transmission permanent, duplicates retained
 → disciple eligible: actual time + personal Contribution + personal Stones
 → debit once (stones personal→Sect transfer only if policy), learned + mastery
 → active 1 main +2 aux and conflict/successor unique guard
 → real cultivation/Combat V2 consumer *only while active* → save/offline
```

Research, first archive and personal teaching are **three distinct transactions**, not một lần nhấn mở sách cộng cả ba. Nếu thoát giữa debit/settle: durable recipe+revision+root receipt quyết định hoàn tất/retry once, không mất mảnh, không nhân manual. SOURCE P2 six IDs and old learned records must survive migration. Mảnh đặt trong Sect archive item ledger + resources in canonical Warehouse, không spawn một `Loot Warehouse` thứ hai.

### 3.1 Mini-công thức nghiên cứu gắn nguyên liệu SOURCE, toàn bộ **PROPOSED**

| Sách | K named fragments | Input khác, ResourceRegistry SOURCE ID | Proxy thị giá nguồn | Time proposal | Ghi chú |
|---|---:|---|---:|---:|---|
| Dưỡng Khí | **8 là P2 fact**, V2 giả định | `linh_moc:2` | 2×2=**4** | **12 sim ticks** | không yêu cầu Linh Tủy hiếm để học nền; CP2 starter chưa duyệt |
| Huyền Giáp | **12 là P2 fact**, V2 giả định | `linh_tuy:1+tinh_lang_bi:2` | 14+2×10=**34** | **24 sim ticks** | Linh Tủy từ nguồn legacy encounter-win, không cấp đồng thời với per kill |
| Hắc Lang Hồn | **K=8 hoàn toàn PROPOSED** | `yeu_dan:1+linh_tuy:2` | 18+2×14=**46** | **36 sim ticks** | nguyên bản Boss thì KHÔNG cần recipe mảnh, chỉ archive |

Các time/tỉ lệ/số mảnh là design candidates; **P2 `craft_manual` chỉ tiêu mảnh không có material/time**. V2 Tàng Kinh Các worker/profession gate/nhà cấp bao nhiêu đều OPEN, không tự mở build mới. Tinh Lang Bì cũng cạnh tranh với G1 rèn trang bị và các cửa Luyện Thể; không coi stock kiếm mảnh công pháp tách khỏi kinh tế.

## 4. Nguồn khác phải tạo bản sắc, không phá exclusivity

- **Normal**, theo species/region: farming fragments phổ thông hoặc nhánh nghề/thuộc tính rõ ràng; named manual only when formally eligible.
- **Elite**: lượng mảnh nhiều/đặc thù hơn, nhưng phải có alternative normal/research nếu dòng cần cho progression; `loot_ready=false` ngăn quảng cáo đã farmable.
- **Boss**: rare full manuscript hoặc milestone thuộc **cùng Boss và Sect**, zero chance từ nguồn khác khi thực sự Boss-only.
- **Bí Cảnh**: mỗi `secret_id` phải có map/event thật; currently no such X1 candidate source in inspected main, nên **BLOCKED**; có thể dùng first-clear authored fragment/complete book sau khi triển khai.
- **Tông Môn/Nghiên cứu**: dùng duplicate/research/mảnh và thật sự trả costs, `Diễn Hóa` tạo authored successor không cộng chồng tiền nhiệm; personal discovery rồi Khắc Lục riêng.

Không ai được lấy global P2 `gacha_weight` 38/20/18/10/9/5 làm V2 monster drop percentage, hoặc biến các giá trị normal species selection thành độc lập free loot rolls.

## 5. Cổng nghiệm thu thiết kế (trước bất kỳ CODE nào)

- Dưỡng Khí: real source `thanh_lang` *có* trên map, **nhưng V2 fragment loot/source chưa có**; phải có non-Boss/research attainable path theo owner CP2 khi quyết định.
- Huyền Giáp: `truc_thu` hiện có, Elite Nham có nhưng `loot_ready=false`; không thể nói path ra sách đã CODED. Specific defensive V2 effect cần bằng chứng Combat V2 consumer.
- Hắc Lang: **không có** ID book/effect/live loot, có Boss species là chưa đủ; hoàn toàn optional và CONTENT BLOCKED cho đến khi có consumer.
- Mỗi route phải có (1) actual source ID, (2) eligible event root, (3) precise loot probability, (4) registered fragment/manual and research recipe, (5) legit Sect archive/teach, (6) real activated V2 consumer, (7) deterministic save/regression. Thiếu mắt xích nào thì **NOT CONTENT COMPLETE**, không fake UI.
- Godot4.7.2 runtime test/Windows visual/Android đều PENDING; nghiên cứu này chỉ docs/analytical.

**Bảng xác suất, thời gian và chính sách owner:** `docs/design/CPV2_C4_01_ACQUISITION_PROBABILITY_ECONOMY_AND_OWNER_OPTIONS_2026-10-23.md` (companion trên cùng branch).
