# D1 — TÂM TÍNH V2: HỢP ĐỒNG HIỆU ỨNG VÀ LỐI CHƠI

Ngày: 18/11/2026. Dự án: Tông Môn Bá Đạo, Draft PR #72.
Nguồn kế thừa: docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md, docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md, docs/COMBAT_STATS_V2_SPEC.md, docs/TRAITS_V2_SPEC.md.

> QUYẾT ĐỊNH OWNER ĐÃ CHỐT (D1-A2): Giữ nguyên 16 Combat Stats chính. Tâm Tính là chỉ số nền thứ ba trong Tam Căn của D7; đóng góp duy nhất trực tiếp lên Combat Stats là Kháng Hiệu Ứng theo +0,01 điểm phần trăm / 1 Tâm Tính, tối đa +8 điểm phần trăm. Không cộng cơ chế kháng mental và giảm thời lượng của đề xuất D1-A cũ. KHÔNG ngụ ý gameplay đã triển khai.
>
> CÁC CƠ CHẾ SINH HOẠT DƯỚI ĐÂY (D1-M2/M3/M4) LÀ ỨNG VIÊN ĐỂ OWNER QUYẾT SAU. KHÔNG coi chốt D1-A2 đồng nghĩa duyệt những hệ số khác.

## 1. Ba khái niệm riêng, không thêm cảnh giới vô tội vạ

| Thuộc tính | Bản chất | Nguồn sở hữu | Chức năng |
|---|---|---|---|
| Tâm Tính (mind_nature) | Chỉ số nền có điểm, tăng vĩnh viễn theo quyền FoundationSystem | DiscipleState.mind_nature, snapshot sinh và points của D7 | Định lực: kháng hiệu ứng khi Combat V2 kết nối; mở rộng về phản ứng tâm lý nếu có event |
| Tâm Trạng (mood) | Trạng thái tạm thời 0–100 theo framework, KHÔNG thuộc Tam Căn | Hệ living state/sự kiện thực tế, chưa xác nhận consumer runtime | Buồn/giận/hứng khởi theo sự kiện, đổi ưu tiên hành vi khi có AI consumer |
| Tâm Cảnh | Thành tựu tu tâm (6 mốc từng đề xuất) | Chưa có quyền triển khai, không có tiến trình XP hợp lệ | OPTIONAL, không dùng để chặn kháng hiệu ứng D1-A2; chưa tạo một đường tu luyện 30×10 |

**Ranh giới:** Tâm Tính cao không luôn vui; vẫn có thể buồn, bị thương, thất bại, bỏ cuộc. Tâm Tính giúp **giữ vững tinh thần và hồi phục hợp lý**, không thay tính cách hoặc khiến người chơi vô địch.

## 2. D1-A2 — hiệu ứng chiến đấu ĐÃ KHÓA THIẾT KẾ

- Nguồn: mind_nature hiện tại thuộc Foundation D7, không đọc birth snapshot để tặng thêm; giá trị không âm và hữu hạn.
- Công thức điểm phần trăm: bonus_pp = min(8, 0.01 × max(0, Tâm_Tính)).
- Công thức fractional đưa vào CombatStatsV2: bonus_fraction = min(0.08, 0.0001 × max(0, Tâm_Tính)).
- Đúng một nguồn hệ thống: source_id = foundation_mind_nature; channel = effect_resistance; mode = percentage_points; value = bonus_fraction.
- 100 điểm → +1 pp; 300 → +3 pp; 500 → +5 pp; 800 → +8 pp; 1200 → vẫn +8 pp. **800 là mốc bão hòa hiệu ứng, không phải trần điểm Tâm Tính D7**.
- Kháng Hiệu Ứng cuối: P(hiệu ứng) = clamp(P_gốc + Chính Xác Hiệu Ứng_caster − Kháng Hiệu Ứng_target, 0, 1), chỉ cho status check thường; miễn nhiễm / guaranteed theo quyền skill.
- Áp dụng cho tất cả status cần roll kiểm tra, không chỉ mental, vì đây là kênh effect_resistance chung. **Không giảm thời lượng** của status đã trúng.
- Tâm Thần Kiên Cố (+10 pp) hoặc Trait khác có source riêng. Hai nguồn cộng theo **điểm phần trăm**, rồi clamp xác suất cuối. Không thêm vào Crit Resistance.
- Không tăng Công/Thủ/HP, EXP Tu Vi, EXP Luyện Thể, EXP công pháp, xác suất đột phá, Crit, sát thương hoặc giảm HP trực tiếp.
- Khi Combat Stats V2 chưa được nối vào encounter, UI ghi CHƯA TÍCH HỢP, không bơm +8 pp ngầm vào hệ combat_power cũ.

### Ví dụ xác suất hiệu ứng

A có kỹ năng gây Choáng: cơ hội gốc 45%, Chính Xác Hiệu Ứng +10 pp. B có Tâm Tính 500 (+5 pp kháng) và Trait Tâm Thần Kiên Cố (+10 pp kháng).
→ P(Choáng B) = 45 + 10 − 5 − 10 = 40%.
Nếu B chỉ có Tâm Tính 500: xác suất = 50%.
Nếu B có Tâm Tính 0 và không Trait: xác suất = 55%.

Nếu skill được bảo đảm trúng thì không tự trừ xuống 40%; nếu target miễn nhiễm thì status không trúng. **Tâm Tính không tạo miễn nhiễm tuyệt đối.**

## 3. D1-M2 — Ổn định cảm xúc khi gặp biến cố (ĐỀ XUẤT, CHƯA DUYỆT)

**Mục đích:** Tâm Tính có ý nghĩa đời sống, không chỉ một dòng Kháng Hiệu Ứng.

- Trigger chỉ từ event có thật: thua trận hợp lệ, thất bại đột phá, mất đồng đội, mâu thuẫn quan hệ, kỷ luật / biến cố có ID.
- Chỉ giảm mức giảm **Tâm Trạng (mood)** của event gắn tag emotional_shock. Không đổi HP, Injury, Trung Thành, vật phẩm, cơ hội đột phá hoặc hình phạt −10% tiểu cảnh đã khóa.
- Công thức ứng viên: shock_factor = max(0.60, 1 − min(Tâm_Tính,800)/2000); delta_mood_thật = delta_mood_gốc × shock_factor khi delta_mood_gốc âm và event emotional_shock hợp lệ.
- Tâm Tính 100: chịu 95% mức giảm Tâm Trạng; 500: chịu 75%; 800+: chịu 60%. Không phải miễn nhiễm cảm xúc.
- Ví dụ một thất bại có delta_mood_gốc = −20: Tâm Tính 0 mất 20, 500 mất 15, 800 mất 12. **−20 chỉ là ví dụ thiết kế**, không phải giá trị runtime hiện có.
- Sự kiện tích cực không được nhân đôi; một event_id chỉ áp dụng mood delta một lần, chống trùng khi save/reload.
- Gate: mood 0–100, event owner, actor/target và AI consumer phải có thật. Thiếu → DESIGN_GATED, không tạo random sự kiện buồn bã mỗi tick.

## 4. D1-M3 — Tĩnh Tâm / hồi phục tinh thần bằng hành động (ĐỀ XUẤT)

**Mục đích:** Có hoạt động chủ động thay vì nhìn mood giảm mà không làm gì.

- "Tĩnh Tâm" là lựa chọn trong lịch nghỉ / tu tâm có thời lượng thực do scheduler sở hữu. **Không** là đường EXP mới, không cộng Tu Vi tự nhiên, không tạo Tu Tâm Đường ngay lập tức.
- Một ca nghỉ hợp lệ hoàn tất: hồi mood cơ bản theo định nghĩa hành động; bonus_mood ứng viên = min(4, floor(max(0, Tâm_Tính)/200)), mood_after = min(100, mood_before + base_rest_mood + bonus_mood).
- Tâm Tính 100 → +0 mood thêm, 200 → +1, 500 → +2, 800 → +4. Chỉ thưởng khi rest_completed, **không** hồi mood trên mỗi tick đứng yên hay khi mở lại Save.
- Bị thương vẫn chịu Injury gate; nghỉ không tự xóa Injury hoặc hồi HP khi thiếu nguồn HP recovery thật.
- Scheduler phải ngăn một đệ tử vừa nghỉ vừa đi làm/săn cùng thời gian. Quyền điều khiển của người chơi ưu tiên hơn AI.
- Nếu chưa có mood event hoặc action consumer thì Wiki ghi thiết kế mở rộng, không hiện nút giả trong game.

## 5. D1-M4 — Tu Tâm và khắc phục đặc tính (ĐỀ XUẤT ĐỊNH HƯỚNG)

Tận dụng Tu Tâm Đường đã đề xuất tại TRAITS_V2_SPEC.md §12.2, **không tạo Tâm Cảnh 30×10**:

1. Chọn mục tiêu hợp lệ: khắc phục Trait xấu có removable=true, giải quyết xung đột, bồi dưỡng Trait có consumer và nguồn học đã duyệt.
2. Hoạt động cần lịch/slot, thời gian, lịch sử hành vi và **Linh Thạch thực**. Đủ điều kiện thì kết quả deterministic, không roll thất bại để tiêu phí thêm.
3. Tâm Tính không tự sinh Trait Tâm Thần Kiên Cố, không miễn phí loại bỏ Trait xấu và không nhân đôi điểm Lục Duy.
4. Bonus giảm thời gian ứng viên: time_factor = 1 − min(0.15, Tâm_Tính/6000); 600 điểm → giảm 10% thời gian; từ 900 → giảm tối đa 15%. Chỉ tác động thời gian của **đúng job Tu Tâm Đường**, không tăng tất cả work speed.
5. Khắc phục vẫn giữ lịch sử Trait bẩm sinh/hậu thiên trong hồ sơ, không xóa snapshot sinh.
6. Không tự tạo tỷ lệ "đốn ngộ" hoặc thanh EXP Tâm Cảnh nếu chưa có authority/source thật.

## 6. Tương tác với gameplay

| Tình huống | D1-A2 ĐÃ DUYỆT | M2/M3/M4 CHỈ ĐỀ XUẤT |
|---|---|---|
| Bị debuff/khống chế có roll | +Kháng Hiệu Ứng, giảm P(trúng) | Không giảm duration đã trúng |
| PvE thua / đồng môn bị thương | Không đổi Injury | Có thể giảm sốc tâm lý từ event mood hợp lệ |
| Đột phá thất bại | Không đổi cơ hội base, thuốc và −10% tiểu cảnh | Có thể giảm sự chán nản từ event thất bại, không giảm hình phạt |
| Tu Vi/s, Luyện Thể/s | Không cộng hệ số | Không thêm hệ XP |
| Nghỉ có lịch | Không tự hồi HP/EXP | Có thể hồi mood khi rest_completed |
| Khắc phục Trait bất lợi | Không xóa Trait | Giảm thời gian Tu Tâm Đường nếu đủ điều kiện sau này |
| Combat AI / tính cách | Không sửa risk_bias / survival_bias | Mood có thể đổi ưu tiên với AI consumer, không override an toàn |
| Cảnh giới | Không có Tâm Cảnh mới | Chỉ xem xét sau khi D1/D2 có đủ source |

## 7. Hồ sơ đệ tử và Tàng Kinh Các

- Hiển thị Tâm Tính (số điểm) và +X điểm % Kháng Hiệu Ứng (thiết kế đã duyệt). Trạng thái runtime riêng: CHỜ TÍCH HỢP V2.
- Trong breakdown Kháng Hiệu Ứng, nguồn foundation_mind_nature chỉ được tính **một lần**, các Trait/Pháp Bảo/skill có ID riêng.
- Tâm Trạng chưa có consumer → hiển thị "Đề xuất", không bịa mood cho đệ tử đang chơi.
- Sự kiện chỉ hiển thị lịch sử khi có nguồn thật; không tự tạo "tâm ma công kích" ngẫu nhiên.
- Tách BA trạng thái: THIẾT KẾ ĐÃ DUYỆT (A2) / PHƯƠNG ÁN ĐỀ XUẤT (M2/M3/M4) / CHƯA TRIỂN KHAI GAMEPLAY.
- Người chơi đọc trong mục "Đệ tử & đặc tính" của Tàng Kinh Các duy nhất, có bảng ví dụ và phép tính.

## 8. Hợp đồng giao coding trong đợt sau (không code ở đợt thiết kế)

- Migrating D7 từ model 6 dùng luật FoundationSystem._mean_six_birth() hiện có, không roll lại Tâm Tính, không sửa birth snapshot.
- Khi mind_nature được tăng qua FoundationSystem.increase_dimension, invalidate snapshot CombatStatsV2; derived stats KHÔNG là nguồn save thứ hai.
- Dùng nguồn foundation_mind_nature đúng một lần; test mind=0,100,500,800,900, không hữu hạn, source off, Trait Tâm Thần Kiên Cố và save/migrate.
- Combat legacy vẫn sử dụng luật cũ cho tới khi tích hợp V2 theo gate, không âm thầm sửa combat_power bằng buff này.
- Mood/job candidate test chỉ sau owner phê duyệt M2/M3/M4 và có event/scheduler authority thật.
- Chưa có sửa mã gameplay, chưa nghiệm thu Godot 4.7.2.

## 9. Trạng thái quyết định

- **D1-A2 APPROVED — DESIGN LOCK ONLY.** +0,01 điểm % Kháng Hiệu Ứng / điểm Tâm Tính, tối đa +8 pp; không thêm chỉ số chiến đấu. Người dùng chốt trong hội thoại 18/11/2026.
- **D1-M2, M3, M4: DESIGN CANDIDATE, chưa được phê duyệt.**
- Tâm Cảnh là OPTION LATER, không bật tự động.
- Thiết kế D1-A cũ gồm kháng riêng mental và giảm thời lượng đã **bị thay thế** bởi A2, không áp cả hai.

Không merge PR #72. Không điều chỉnh Save, Combat, kinh tế hay VFX ở giai đoạn thiết kế.
