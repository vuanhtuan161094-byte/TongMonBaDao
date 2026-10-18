# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / JX1 13 PHÁI × 30 CẢNH GIỚI × COMBAT STATS V2

**Ngày:** 2026-10-18  
**Trạng thái:** DESIGN RESEARCH PROPOSAL — **NOT CODE AUTHORIZATION**; chưa khóa số ratio/CD/unlock. Không sửa source, không nhập asset, không CI/FULL/merge.

**Nguồn authority được đọc:**
- [Danh mục Source VL thực tế 260 mục](COMBAT_V4_JX1_SOURCE_260_SKILLS_INDEX_2026-10-18.md) từ `data/vltk/faction-coverage.json` — 13 phái / 260 skill roots / 118 source web playable.
- `data/vltk-fx.json` đã giải mã (270 VFX/skill source profiles) có JX SkillId, stage, raw external asset refs, không đồng nghĩa 270 Godot skill; `js/engine.js` chỉ là JS game web, không là Combat authority.
- `docs/REALM_LADDER_V2_SPEC.md` — 30 đại cảnh×10 tầng Tu Vi và 30×10 Luyện Thể; `docs/COMBAT_SKILLS_V2_SPEC.md` — 3 wave Nhân/Tiên/Thần, 1 Thường+4 Active+6 triggered Passive, mastery 5 bậc, không Mana chung; `docs/CULTIVATION_PATH_V2_SPEC.md` — một soft Chủ Đạo, 3×3 branch, không class level.
- `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/COMBAT_STATS_V2_SPEC.md`, live `godot/src/simulation/combat/combat_stats_v2.gd` and `disciple_combat_loadout_v2.gd` — 16 V2 stats, base formula and real skill consumers.
- Existing design C (birth martial inclination can differ from freely chosen school) and legend exclusive option A remain independent locks.
- Cross-check official/community VLTK1 material from VNG and class guides identifies ten classic schools by five elements. Source's Hoa Sơn / Vũ Hồn / Tiêu Dao are extension content; do not present as classic ten.

## 1. Source JX is not Tu Vi unlock data

- Source coverage numeric `level` fields (mostly 20, 27, 30) are **source skill/profile data**, not cultivation realm indices; **DO NOT** create arbitrary unlock e.g. skill 158 at realm 20.
- Source labels: 118/260 playable **inside separate JS web game**; 63 passive excluded, 55 support pending, 3 hybrid pending, 21 attack pending. `sourceIncomplete=54` is overlapping flags. They are not implemented in Tông Môn Bá Đạo.
- Exactly ten classic factions 0–9 are phase-1 curriculum candidates; extension factions 10–12 are research/phase-later. Sources and role names are evidence; combat mechanics below are **our authored proposal** and require real Combat V2 implementation.
- Five faction thematic roots Kim/Mộc/Thủy/Hỏa/Thổ are NOT additional global buffs or elemental counter factors. A **specific skill** has its own primary element or neutral element. No double ×1.25 school counter. One actor can choose a school different from root inclination (model C).

## 2. 13-phái curriculum matrix — SOURCE names versus PROPOSED mechanisms

| # | Trường phái | Gợi ý hành | Mapping Chủ Đạo V2 (not class lock) | Nền tảng/kiểu chơi | SkillId + TÊN THẬT TRONG SOURCE | Gameplay ĐỀ XUẤT | Gate thực hiện |
|---:|---|---|---|---|---|---|---|
| 01 | Thiếu Lâm | Kim | Thể Tu/Kim Cương hoặc Bá Thể | Quyền, Côn, Đao; phòng thủ, quần chiến, chấn nhiếp | 10 Kim Cang Phục Ma; 11 Hoành Tảo Lục Hợp; 20 Sư Tử Hống; 21 Dịch Cân kinh (passive) | Đòn nặng/đa mục tiêu → kiểm soát ngắn → thủ hộ/threat đã implement | JX Sư Tử Hống có kỹ năng tấn công nhưng không được mặc định stun xuyên Boss; support riêng pending |
| 02 | Thiên Vương | Kim | Thể Tu/Bá Thể hoặc Kim Cương | Thương, Đao, Chùy; áp sát và duy trì đứng tuyến đầu | 40 Đoạn Hồn Thích; 41 Huyết Chiến Bát Phương; 42 Kim Chung Tráo (support pending); 1060 Bá Vương Tạm Kim | Xuyên thủng → quét nhóm → tự vệ/hút máu qua channel thật | Không mặc định nhận Hút Máu, Taunt, Guard nếu effect runtime chưa có |
| 03 | Đường Môn | Mộc | Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Huyền Pháp | Ám khí, phi tiêu, nỏ, bẫy; cấu rỉa và mục tiêu ưu tiên | 50 Truy Tâm Tiễn; 54 Mạn Thiên Hoa Vũ; 58 Thiên La Địa Võng; 249 Tiểu Lý Phi Đao | Projectiles/đánh dấu → nhiều đạn có target cap → zone/trap có engine thật | Không cho projectile nhiều mũi nhân số lần damage ngoài packet/target cap |
| 04 | Ngũ Độc | Mộc | Pháp Tu/Ngũ Hành hoặc Huyền Pháp | Chưởng độc, đao độc, yểm chú; DoT/giảm kháng | 63 Độc Sa chưởng; 355 Huyền Âm Trảm; 384 Bách Độc Xuyên Tâm; 73 Vạn Độc Thực Tâm (support pending) | Đặt độc → refresh/stack đúng luật → chiêu khai thác target đã nhiễm | Chưa bật dot thật khi status engine chưa implemented; poison khác Hỏa Burn |
| 05 | Nga Mi | Thủy | Pháp Tu/Y Đạo hoặc Kiếm Tu/Hộ Kiếm | Kiếm, chưởng, hỗ trợ; hồi máu/bảo vệ/giải hiệu ứng | 80 Phiêu Tuyết Xuyên Vân; 91 Phật Quang Phổ Chiếu (source role attack); 93 Từ Hàng Phổ D (support pending); 332 Phổ Độ Chúng Sinh (support pending) | Cấu rỉa băng → heal thực/cleanse khi được authored riêng → bảo hộ đồng đội | Tên Phật Quang không đủ chứng minh skill 91 là hồi máu; không fake revive |
| 06 | Thúy Yên | Thủy | Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Ngũ Hành | Đơn/Song đao, băng thủy, cơ động | 99 Phong Hoa Tuyết Nguyệt; 102 Phong Quyển Tàn Tuyết; 111 Bích Hải Triều Sinh; 336 Băng Tung Vô ảnh | Tấn công nhanh → slow/hàn ấn hợp lệ → bùng nổ theo trạng thái | Không tự cấp freeze từ tên Băng; cần resistant/status test |
| 07 | Cái Bang | Hỏa | Thể Tu/Bá Thể hoặc Pháp Tu/Ngũ Hành | Bổng, chưởng, quần kích; áp lực tuyến trước | 125 Bổng Đả ác Cẩu; 128 Kháng Long Hữu Hối; 357 Phi Long Tại Thiên; 359 Thiên Hạ Vô Cẩu | Đòn gần/tầm trung → shockwave → hỏa AoE hoặc pressure Boss | Không sao chép nguyên ratio/source MMO hay vượt baseline AoE max3 |
| 08 | Thiên Nhẫn | Hỏa | Kiếm Tu/Sát Kiếm hoặc Pháp Tu/Ngũ Hành | Đao, mâu, hỏa thuật; sát thương dồn và trạng thái | 135 Tàn Dương Như Huyết; 141 Liệt Hỏa Tình Thiên; 148 Ma Diệm Thất Sát; 362 Thiên Ngoại Lưu Tinh | Dồn sát thương → Burn hợp lệ → kết liễu có điều kiện | Không có miễn khống chế/bất tử hay tăng ATK tự do vì nhãn môn phái |
| 09 | Võ Đang | Thổ | Kiếm Tu/Ngự Kiếm hoặc Pháp Tu/Huyền Pháp | Kiếm khí tầm xa, nội công, kiếm trận | 158 Kiếm Phi Kinh Thiên; 165 Vô Ngã Vô Kiếm; 368 Nhân Kiếm Hợp Nhất; 157 Tọa Vọng Vô Ngã (support pending) | Kiếm khí projectile → liên kích → kiếm trận, ngắt thi pháp chính xác | C4-VP01 dùng ảnh VFX analog cho ngu_kiem_thuat, CHƯA ánh xạ một-một JX skillId158 |
| 10 | Côn Lôn | Thổ | Pháp Tu/Ngũ Hành hoặc Huyền Pháp | Phong/Lôi phù pháp, khống chế khu vực | 169 Hô Phong Pháp; 179 Cuồng Lôi Chấn Địa; 182 Ngũ Lôi Chánh Pháp; 392 Thúc Phược Chú (support pending) | Gió đẩy/định vị → lôi kích nhiều nhịp → khống chế có EffectHit thật | Lôi là thuộc tính kỹ năng mở rộng; không tự cho đệ tử Lôi Linh Căn |
| 11 | Hoa Sơn (mở rộng) | Chưa gắn Kim/Mộc/Thủy/Hỏa/Thổ cố định | Kiếm Tu/Sát Kiếm hoặc Ngự Kiếm | Kiếm Tông/Khí Tông, kiếm thuật linh hoạt | 1347 Bạch Hồng Quán Nhật; 1351 Kim Nhạn Hoành Không; 1360 Thương Tùng Nghênh Khách; 1349 Kiếm Tông Tổng Quyết (passive) | Combo kiếm chi tiết và chuyển thế trong giới hạn skill slot | Source web có 6/20 skill playable; không coi toàn phái ready |
| 12 | Vũ Hồn (mở rộng) | Chưa khóa | Thể Tu/Bá Thể hoặc Kim Cương | Thuẫn, đao, quân trận, uy hiếp | 1963 Triều Thiên Khuyết (attack pending); 1964 Vũ Hồn Thuẫn Pháp (passive); 1972 Đoạt cờ (attack pending); 1982 Vũ Mục Di Thư (support pending) | Chiến trường phòng tuyến, phản kích, threat nếu có engine | 0/18 source-web playable: chỉ nghiên cứu; KHÔNG cho vào playable pilot |
| 13 | Tiêu Dao (mở rộng) | Chưa khóa | Kiếm Tu/Ngự Kiếm hoặc Pháp Tu/Huyền Pháp | Kiếm và cầm, tiết tấu, control/support | 2114 Ngô Câu Sương Tuyết; 2120 ỷ Kiếm Phất Thiên; 2124 Kiếm Quyết Phù Vân; 2137 Tiêu Dao Cầm Pháp (passive) | Kiếm ảnh → nhạc thuật debuff → hồi chiêu có điều kiện | 3/17 source-web playable, nhiều thứ thiếu nguồn; cần gate binary/status |

**Quy tắc ánh xạ:** Các cột Source là tên/ID được chứng thực trong bảng Drive; cột gameplay là bản chuyển thể tự thiết kế, **không khẳng định cơ chế y hệt JX**. Kiểu vũ khí (kiếm/đao/côn/thương/chùy/ám khí) và trường phái học vấn khác với một soft Chủ Đạo; Đao/Thương không tự biến thành Kiếm Tu. Nếu yêu cầu ngoại lệ weapon/branch, author skill tags cụ thể.

## 3. Luật gia phả kỹ năng xuyên suốt 30 cảnh giới

**KHÓA từ Combat Skill V2:** 1 Thường Kỹ + tới 4 Chủ Động + tới 6 Bị Động Chiến Đấu (trigger/party). Hệ **Nhân 1–10 / Tiên 11–20 / Thần 21–30**, có tiến hóa successor bằng tên; mastery 5 bậc **Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn**; học qua Tàng Kinh Các/bí kíp hợp lệ hoặc tự lĩnh ngộ. Đây không phải class XP.

**ĐỀ XUẤT cấu trúc gia phả của MỖI nhánh trường phái (content target, không phải số chiêu đã code):**
- A: kỹ năng tấn công chủ lực (đơn/đa mục tiêu) — Nhân A→ Tiên A→ Thần A.
- B: kỹ năng kỹ thuật (phòng thủ/control/mobility/heal) — Nhân B→ Tiên B→ Thần B.
- C: kỹ năng đặc trưng trường phái (kiếm trận/độc/ám khí/bổng/hỏa/lôi) — Nhân C→ Tiên C→ Thần C.
- D: 1 Thường Kỹ/đánh cơ bản có successor tương ứng; E: hệ passive tự thân, triggered và đội hình được phân loại đúng V2. Tác giả có thể thêm gia phả sau pilot.
- Same family successor can replace predecessor in active slot; không có hai hậu duệ mutually exclusive cùng equip. Một tiến hóa đòi nguồn truyền thừa, mastery, Tu Vi/Luyện Thể và chi phí thật. Đạt cảnh giới chỉ **mở điều kiện**, không tự cấp kỹ năng.
- Tuyệt kỹ cá nhân đệ tử truyền kỳ (Model A) là **một gia phả riêng vĩnh viễn owner-bound**; không trộn thành bí kíp trường phái, không copy ra truyền thừa. Nếu active phải chiếm một trong 4 slot hợp lệ.

## 4. Ma trận 30 cảnh giới — mục tiêu unlock candidate, CHƯA KHÓA balance

| # | Cảnh giới Tu Vi CANONICAL | Nội dung đề xuất có thể mở | Ràng buộc |
|---:|---|---|---|
| 1 | Phàm Nhân | Thường Kỹ phổ thông; hướng nghề chưa Định Đạo | Không cấp miễn phí kỹ năng môn phái |
| 2 | Luyện Khí | Định Đạo hợp lệ; mở Active 1 (đề xuất), học chiêu tấn công A | Manual hoặc lĩnh ngộ thực tế |
| 3 | Trúc Cơ | Mở Active 2 (đề xuất), học kỹ thuật phòng ngự/đơn mục tiêu B | Điều kiện Tu Vi/Luyện Thể riêng theo skill |
| 4 | Tử Phủ | Học status đầu (độc, slow, guard, buff) hoặc utility theo trường phái | Status cần runtime thật |
| 5 | Kim Đan | Kỹ năng gia phả A có biến thể đánh đa mục tiêu | Không tăng không hạn chế target |
| 6 | Nguyên Anh | Học kỹ thuật AoE/khống chế/khoanh vùng C | AoE max3 trừ khi explicit exception |
| 7 | Hóa Thần | Mở Active 3 (đề xuất), mở combo hai kỹ năng | Chỉ trigger từ sự kiện thật |
| 8 | Luyện Hư | Học phản đòn/giải trạng thái/di chuyển chiến thuật | Không cast chồng hành động |
| 9 | Hợp Thể | Mở Active 4 (đề xuất), bộ chiêu đạt đủ vai trò | Tối đa 4 active dùng một lúc |
| 10 | Đại Thừa | Lĩnh ngộ tuyệt học Nhân Giới của nhánh đã học | Không cấp tự động khi đột phá |
| 11 | Nhân Tiên | Gia phả A tiến hóa đời Tiên đầu tiên | Đời sau thay/điều chỉnh tiền nhiệm |
| 12 | Địa Tiên | Tinh chỉnh range/target/timing thuộc họ kỹ năng B | Dựa trên balance riêng, không thêm ATK vô điều kiện |
| 13 | Thiên Tiên | Nâng cấp kháng trạng thái hoặc điều kiện khống chế | Không hard CC Boss vô thời hạn |
| 14 | Chân Tiên | Combo hỗ trợ party/mark mục tiêu có source attribution | Các buff party trong 6 người |
| 15 | Huyền Tiên | Mở kiếm trận/độc trận/lôi trận/trấn trận Tiên | Zone phải có duration và cap |
| 16 | Kim Tiên | Gia phả phòng thủ/support tiến hóa đời Tiên | Heal effective, shield actual absorb |
| 17 | Thái Ất Kim Tiên | Đòn công phá đa nhịp/hiệu ứng phụ có giới hạn | Một cast ID, không nhân proc vô hạn |
| 18 | Đại La Kim Tiên | Cơ chế đòn phản công/trạng thái tương tác mới | Status stack policy trước code |
| 19 | Tiên Vương | Nắm nhánh tuyệt học Tiên Giới; tối ưu AI tự chọn target | Mastery/Đạo Lịch/Trang bị hợp lệ |
| 20 | Tiên Đế | Đỉnh Tiên: danh xưng đời Tiên của gia phả cốt lõi | Không mở slot combat thứ 5 |
| 21 | Thần Nhân | Gia phả A tiến hóa đời Thần đầu tiên | Pháp Tắc hữu hạn, không vô địch |
| 22 | Chân Thần | Áp chế/đột phá kháng theo bộ kỹ năng riêng | Không bypass miễn nhiễm Boss mặc định |
| 23 | Thiên Thần | Tương tác hiếm giữa Ngũ Hành/Dị Căn nếu có kỹ năng tương thích | Không kích hoạt toàn bộ combo tự động |
| 24 | Thần Quân | Thi triển thế trận/điểm khống chế đẳng cấp Thần | Giới hạn cảnh báo và số mục tiêu |
| 25 | Thần Vương | Thân pháp/bảo hộ/điều kiện cứu nguy nâng cấp | Không tự mở hồi sinh miễn phí |
| 26 | Thần Hoàng | Phản chế trận pháp, purge/cleanse cao cấp | Chỉ xoá hiệu ứng được phép |
| 27 | Thần Đế | Chuyển pha/đợt chém/thần lôi nhiều nhịp đã cài bounded | Event/hit nhất quán determinism |
| 28 | Thần Tôn | Gia phả phòng thủ/chống chết giới hạn encounter | Không mở kháng tất cả |
| 29 | Hỗn Độn Thần | Thần kỹ cực hạn, kết hợp cơ chế chủ đạo đã đầu tư | Không duplicate damage source |
| 30 | Sáng Thế Chủ | Bản hoàn thiện Thần Giới của bộ tuyệt học đã chọn | Endgame bounded, không auto-learn |

**10 tầng mỗi cảnh giới:** tầng 1–10 là tăng trưởng `G(r,f)` và có thể đặt gate học/mastery trong data; **không tạo một chiêu mới ở từng tầng**. Luyện Thể có 30 cảnh riêng trong `REALM_LADDER_V2_SPEC.md`, kiểm tra riêng theo basis: Tu Vi skill / Luyện Thể skill / Hybrid, không ép hai trục cùng cảnh giới.

**Phân phối slot ĐỀ XUẤT để QA dễ test:** Active 1 khi đủ điều kiện ở cảnh 2, Active 2 ở 3, Active 3 ở 7, Active 4 ở 9; triggered combat passives có thể trải tới cảnh 10. Đây là proposal riêng, spec V2 chỉ khóa số slot trưởng thành, chưa khóa mốc mở. `Phàm Nhân`/chưa Định Đạo có Thường Kỹ và khả năng luyện tập, không bị gán môn phái miễn phí. Chốt mốc này phải có approval balance.

## 5. Ví dụ tiến hóa xuyên cảnh giới (không lấy tên successor làm JX gốc)

| School / family | Nhân 1–10: SOURCE skill inspiration | Tiên 11–20: newly-authored upgrade | Thần 21–30: newly-authored upgrade | Effect runtime dependency |
|---|---|---|---|---|
| Võ Đang / kiếm khí | Source #158 Kiếm Phi Kinh Thiên → skill Godot nguồn gốc mới | Phi kiếm nhiều nhịp + target mark (Tiên đời A) | Kiếm Vực hữu hạn 3 mục tiêu + pháp tắc cooldown riêng (Thần đời A) | Projectile/skill cast/hit, no false hits |
| Ngũ Độc / độc công | #63 Độc Sa chưởng → một DoT độc hợp lệ | Mở chuỗi refresh độc, tiêu hao/đánh dấu khi chạm giới hạn (Tiên) | Lĩnh vực độc hữu hạn, ưu tiên mục tiêu Boss có kháng (Thần) | Poison DoT engine + stacking source attribution REQUIRED |
| Nga Mi / Y Đạo | Source #93 Từ Hàng Phổ D là support-pending; hồi máu phải authored riêng theo V2 | Cấp bảo hộ/giải bất lợi sau hồi phục thật | Hộ Mệnh cứu nguy theo encounter-bound gate, không revive miễn phí | Heal effective, shield, cleanse, no overheal mastery |
| Thiếu Lâm / thủ vệ | #10 Kim Cang Phục Ma, #20 Sư Tử Hống → sát thương/cảnh báo | Hộ thể party + threat có cap | Pháp Thân phòng tuyến giới hạn thời gian | Threat/Guard chưa implement đầy đủ |
| Đường Môn / ám khí | #50 Truy Tâm Tiễn, #54 Mạn Thiên Hoa Vũ | Multi-projectile bounded, dấu ấn phá phòng | Cơ quan trận có timeout, cap | Projectile packets once-only, trap rules REQUIRED |
| Côn Lôn / Lôi | #182 Ngũ Lôi Chánh Pháp | Lôi trận 2 nhịp + short control | Thiên Lôi cơ chế Dị Căn nếu thực có Lôi căn | Không cho Lôi căn miễn phí |

**Tính tương khắc**: Kim→Mộc→Thổ→Thủy→Hỏa→Kim khắc; matchup default favorable ×1.25, unfavorable ×0.85, neutral ×1.0 theo `COMBAT_SKILLS_V2_SPEC.md`/`SPIRITUAL_ROOT_V2_SPEC.md`. Tương Sinh Mộc→Hỏa→Thổ→Kim→Thủy→Mộc chỉ được kích hoạt khi từng kỹ năng opt-in; không tự đồng đội cộng vô hạn.

## 6. Chỉ số chiến đấu — GIỮ nguyên CombatStatsV2 đang live

**16 stat channels:**
- Max HP (`max_hp`), ATK (`attack`), DEF (`defense`);
- Tốc di chuyển (`move_speed`), Tốc đánh thường (`attack_speed`), Tốc thi pháp (`cast_speed`), Hồi chiêu (`cooldown_recovery`);
- Bạo kích (`crit_chance`), Sát thương bạo kích (`crit_damage`), Kháng bạo kích (`crit_resistance`);
- Xuyên phòng (`defense_penetration`), Chính xác hiệu ứng (`effect_hit`), Kháng hiệu ứng (`effect_resistance`);
- Giảm sát thương (`damage_reduction`), Hút máu (`lifesteal`), Giảm hút máu (`lifesteal_reduction`);
- Ngoài 16 primary là bản đồ **kháng nguyên tố** (5 căn thường + các element nâng cao theo registry), **không roll trực tiếp một bộ stat thứ 2**.

**Công thức live đã khóa, không thay bằng hệ số môn phái:**

```text
G(r,f) = 1.65^(r-1) × 1.03^(f-1)  ; r = 1..30, f = 1..10
Realm core base = (HP 100, ATK 20, DEF 12)
Body  core base = (HP 90,  ATK 3,  DEF 7)
P = 1 + 0.0005 × current_Tiem_Luc
CORE[c] = (RealmBase[c] × G(tu_vi_r, tu_vi_floor) + BodyBase[c] × G(luyen_the_r, luyen_the_floor)) × P
FINAL[c] = max_nonnegative((CORE[c] + SUM_same_channel_flat) × (1 + SUM_same_channel_percent_add))
```

Không nhân thêm multiplier nền ×1.5 cho môn phái; công pháp, Linh Căn, trang bị, Traits, Mệnh Cách phải cấp nguồn qua đúng channel có owner, không buff ảo trong UI. Birth inclination trong school model C chỉ ảnh hưởng chi phí/thời gian học đề xuất, **không phải CombatStats free bonus**.

**Ảnh hưởng Lục Duy theo Master Schema:** Tư Chất: +0,25%/điểm tốc Tu Vi; Căn Cốt: +0,20%/điểm tốc Luyện Thể; Cơ Duyên: event/roll; Thông Tuệ: +0,15%/điểm học/mastery; Mị Lực: social/tuyển; Tiềm Lực: +0,05%/điểm Realm+Body core. Mức pilot này không tự buff ATK từ Tư Chất, Thông Tuệ hay Mị Lực.

### 6.1 Ví dụ GIÁ TRỊ TÍNH TỪ CÔNG THỨC LIVE, KHÔNG phải balance mới

**Giả định:** cùng Tu Vi+Luyện Thể, cùng tầng, Tiềm Lực 100 trừ hàng đầu = 0, không trang bị/traits/skill/buff/kháng. Là ảnh chụp công thức chứ không là cap nhân vật hay đề xuất hệ số JX.

| Tu Vi / Luyện Thể | Tầng | Tiềm Lực | HP xấp xỉ | ATK xấp xỉ | DEF xấp xỉ |
|---|---:|---:|---:|---:|---:|
| Phàm Nhân/Phàm Thân (1/1) | 1/1 | 0 | 190 | 23 | 19 |
| Kim Đan/Đoán Cốt (5/5) | 1/1 | 100 | 1.479 | 179 | 148 |
| Đại Thừa/Linh Thân (10/10) | 10/10 | 100 | 23.596 | 2.856 | 2.360 |
| Nhân Tiên/Kim Thân (11/11) | 1/1 | 100 | 29.839 | 3.612 | 2.984 |
| Tiên Đế/Đế Thân (20/20) | 10/10 | 100 | 3.529.172 | 427.216 | 352.917 |
| Sáng Thế Chủ/Sáng Thế Thần Thể (30/30) | 10/10 | 100 | 527.852.162 | 63.897.893 | 52.785.216 |

Mọi giá trị các hàng được tính từ chính công thức, không lấy làm số cố định cho skill authoring. Ở r30 bộ core lớn là định hướng V2 đã khóa, không cộng các chỉ số class-level nhân lại.

### 6.2 Trúng đòn trực tiếp: live formula và đúng thứ tự

```text
Attacker Attack = A; target Defense = D; Pen = defense_penetration
D_eff = max(0,D × (1-Pen))  ; after eligible Defense debuffs
defense_factor = (2A)/(2A+D_eff)             ; A>0
damage = A × skill_ratio × (crit_damage if eligible crit else 1)
         × defense_factor × elemental_matchup × (1-element_resistance) × (1-damage_reduction)
actual_damage = min(damage, target_remaining_HP)
lifesteal_rate = max(0, lifesteal - target_lifesteal_reduction)
heal_from_lifesteal = min(actual_damage × rate, attacker_missing_HP)
```

Eligible basic/direct attack starts at crit 5%, crit_damage ×1.50; no universal Accuracy/Evasion roll; Effect Hit/Resistance affect specified debuff/control only. DoT, reflect and summons need explicit separate eligible crit/lifesteal flags. Knockback, stun, poison and threat do not appear by rendering a VFX.

### 6.3 Realtime: distinct timing stats

`effective_interval = base_interval / (1+rate_bonus)` separately for basic attack/cast/cooldown. Move speed factor defaults to 1.0; do NOT use turn order Speed. Combat V2 steps at 0.25s, one active cast, AoE default max3, six per party, 30 per encounter cluster and currently up to 40 monsters. VFX frames render independently, never change RNG or damage.

## 7. Implementation reality and next coding gates (not authorized here)

- Live CombatSkillSystem currently has **9 definitions**, but DiscipleCombatLoadoutV2 dispatches learned skills with `effect=damage` only (**2 learned damage skills**); dash/guard/weaken/burn/fire_combo are *deferred*. Static schema and JX source rows are not runnable skill mechanics.
- School selection, path/branch eligibility, training cost, 30-realm successor registry, status engines and original JX VFX binding 1:1 are **design/not yet code**. C4-VP01 is an isolated 6v5 visual pilot with two imported Võ Đang-themed FX atlases as analogy and runtime QA PENDING. It is not a ten-school game mode.
- **Phase 0:** source proof + metadata/ownership (this document/index). **Phase 1:** author 4 school pilot families Võ Đang kiếm khí, Thiếu Lâm guard, Ngũ Độc poison, Nga Mi heal; effects must be true before visuals. **Phase 2:** 10 classic schools. **Phase 3:** 3 expansions when source coverage/skill primitives permit.
- Separate owner authorization needed before any gameplay or balance code. First packet should map skill families to canonical Combat V2 events and slot eligibility with seeded focused tests, without touching Economy/Save/PR20/G1.
- Any exclusive signature character skill is owner-bound per locked option A; not transferred through Tàng Kinh Các. VFX file rights, exact source character matching and Android GPU memory/UX must be tested separately.

## 8. To approve later (explicit balance decisions only)

- Slot unlock r2/r3/r7/r9 and triggered passive milestones? V2 currently only locks maximum capacity, not exact timing.
- School curriculum training source (Tàng Kinh Các + transmission/self-comprehension), school-switch time and fees (without permanent class nerf)?
- Assign source IDs to newly authored Godot skill mechanics; decide precise 13×A/B/C starter families, ratio/cast/cooldown/status stack, valid high-realm successor names.
- Confirm status engine code/AI tests before declaring poison, heal, trap, threat, freezing, lightning and Fate/Legendary functioning.

**END:** detailed research/design only. No gameplay code or PR changes.