# D1 — TÂM TÍNH V2: TU LUYỆN VÀ KHÁNG HIỆU ỨNG

Cập nhật: 18/11/2026. **Thay thế bản D1 cũ nói +8 điểm phần trăm đã chốt và mô tả “Chuyên Tu” như thể có một chế độ riêng.**

## 1. Điều người dùng thực sự yêu cầu

1. Chưa từng phê duyệt hệ số +0,01 điểm %/điểm và trần +8 điểm % trong các đề xuất trước. Lần gọi đó là “OWNER APPROVED” **sai**; rút tuyên bố phê duyệt.
2. Kháng Hiệu Ứng do **Tâm Tính có thể đạt trần +50%**. **Mức trần +50 điểm phần trăm từ riêng Tâm Tính là yêu cầu cần dùng để thiết kế**. Hệ số leo thang tới trần là ứng viên cân bằng, chưa được duyệt.
3. Tâm Tính phải **có ích cho hoạt động Tu Luyện sẵn có**; không thêm một hoạt động “Chuyên Tu”, Tâm Trạng, Tâm Cảnh, Tu Tâm Đường hoặc hệ EXP mới.
4. Giữ phân biệt hoạt động: Đi Săn / Rèn Thân / **Tu Luyện** / Sản Xuất / Rảnh; không biến tất cả thành một công việc tu luyện.

## 2. Kiểm chứng cách mã hiện đang hoạt động

- `DiscipleTrainingActionV2.request_training(...,"cultivation")` chuyển `disciple.current_action` thành `CULTIVATE`, **không** tạo một job/cảnh giới mới.
- `SimulationScheduler` gọi `DiscipleTuViFlowV2.resolve_minute(state, disciple, disciple.current_action == &"CULTIVATE")` **một lần mỗi phút mô phỏng** khi V2 training bật. Trong code nội bộ `specialized=true` chỉ là CÓ chọn Tu Luyện.
- `DiscipleProgressionBalanceV2.CULTIVATE_MULTIPLIER = 2.0` là hệ số gốc cho hoạt động Tu Luyện, không phải nút/mode tu luyện thứ hai.
- Tu Vi tự nhiên bình thường có thể đi kèm các hoạt động khác theo quyền scheduler; **phần thưởng Tâm Tính mới chỉ kích hoạt cho hành động Tu Luyện**. Không nhân thưởng này vào Tu Vi khi đi săn, làm việc, rảnh hoặc Rèn Thân.
- Chính `DiscipleRealmProgressV2.grant_xp` tính Tư Chất +0,25%/điểm cho EXP Tu Vi tự nhiên; chỉ số Căn Cốt +0,20%/điểm dành cho Luyện Thể. Giữ nguyên.

## 3. Kháng Hiệu Ứng: trần 50, hệ số tăng chưa chốt

**Định hướng đã xác nhận từ người dùng:** Trần đóng góp của riêng Tâm Tính cần có thể **đạt +50 điểm phần trăm**, không giữ mức +8.

**Ứng viên D1-COMBAT-R2 (CHƯA DUYỆT HỆ SỐ):**
- `mind_effect_resist_pp = min(50, max(0, mind_nature) * 0.10)`.
- Quy đổi vào CombatStatsV2: `value = mind_effect_resist_pp / 100`, `mode="percentage_points"`, `channel="effect_resistance"`, `source_id="foundation_mind_nature"`.
- Ví dụ: Tâm Tính 0→0 pp; 100→+10 pp; 200→+20 pp; 300→+30 pp; 500+→+50 pp.
- **50 là trần từ Tâm Tính**, không tự áp trần 50 cho toàn bộ kháng từ Trait/trang bị/skill. Bài toán cộng dồn và giới hạn tổng cần duyệt khi cân bằng PvE.
- Kháng Hiệu Ứng trong combat theo hợp đồng hiện có dùng **trừ điểm phần trăm** khỏi xác suất áp status, có thể khiến skill xác suất thấp về 0% khi đối thủ quá mạnh về kháng. Đó không đồng nghĩa “miễn nhiễm tuyệt đối” trước mọi nguồn: status guaranteed và immunity có luật riêng; hiệu ứng có +Chính Xác vẫn có thể trúng.
- Ví dụ có status cơ bản 60%, người thi triển +20 pp Chính Xác, phòng thủ có 300 Tâm Tính (+30 pp) và không có kháng khác → 60+20−30=50%. 500 Tâm Tính (+50 pp) → 30%.
- Nếu cân bằng cho thấy +0,10 pp/điểm quá nhanh, thay hệ số nhưng **giữ mục tiêu cap50** trừ khi người dùng quyết định khác. Không tự tuyên bố 0,10 được duyệt.
- Không đổi tỷ lệ Crit, HP, DEF, Công, damage reduction hay trạng thái bị thương.

**Lưu ý QA:** source Tâm Tính mới **chưa tích hợp** vào PvE chính. Không gọi thiết kế mới là gameplay đã code.

## 4. Tác dụng vào hoạt động TU LUYỆN hiện có

**Ứng viên D1-CULT-R2 (CHƯA DUYỆT HỆ SỐ):** Trong hành động `CULTIVATE` hiện có, tăng hiệu suất nhận Tu Vi theo Tâm Tính, không tạo thêm chế độ.

`mind_cultivation_bonus = min(0.25, max(0,mind_nature) * 0.0005)` (tức +0,05%/điểm, tối đa +25%).

`cultivation_multiplier = 2.0 * (1 + mind_cultivation_bonus)` **chỉ khi `current_action == CULTIVATE`**.

Bình thường: `base_tuvi * (1 + 0.0025*aptitude + valid_natural_sources)`. Khi TU LUYỆN: cùng nền Tu Vi tự nhiên × `cultivation_multiplier`. Thưởng Tâm Tính chỉ tác động dòng công việc Tu Luyện; ở các hành động khác hệ số vẫn bằng 1.0.

| Tâm Tính | Thưởng hoạt động Tu Luyện | Hệ số Tu Luyện tổng (gốc ×2) | Kháng Hiệu Ứng R2 ứng viên |
|---:|---:|---:|---:|
| 0 | 0% | ×2,00 | +0 điểm % |
| 100 | +5% | ×2,10 | +10 điểm % |
| 200 | +10% | ×2,20 | +20 điểm % |
| 300 | +15% | ×2,30 | +30 điểm % |
| 500 | +25% | ×2,50 | +50 điểm % |
| 800 | +25% | ×2,50 | +50 điểm % |

**Ví dụ** với Tư Chất 100, base 1.000 Tu Vi/phút, không có buff khác:
- Rảnh/đi săn/sản xuất: phần Tu Vi tự nhiên (nếu nguồn đã được scheduler cho phép) vẫn ở 1.250/phút; không nhận thưởng Tâm Tính.
- Tu Luyện với Tâm Tính 0: 2.500/phút.
- Tu Luyện với Tâm Tính 300: 2.875/phút.
- Tu Luyện với Tâm Tính 500: 3.125/phút.

**Không được cộng EXP trùng:** dùng `DiscipleTuViFlowV2.preview_rate()` và `resolve_minute()` đang có, không gọi `grant_xp` thêm lần; giữ `last_passive_tuvi_tick`, Save/Reload, job ownership và cờ V2 OFF. Cơ chế Rèn Thân tiếp tục của `TRAIN_BODY`/công trình riêng; Đột Phá không có thưởng xác suất từ Tâm Tính.

## 5. UI phải thật dễ hiểu

Hồ sơ Đệ Tử:
- **Tâm Tính: 300**.
- **Kháng Hiệu Ứng: +30 điểm %** — *ứng viên hệ số R2, chờ chốt*.
- **Khi Tu Luyện: +15% hiệu quả nhận Tu Vi** — *ứng viên hệ số, chờ chốt*.

Màn tác vụ chỉ có các hoạt động **Đi Săn / Rèn Thân / Tu Luyện / Sản Xuất / Rảnh**. KHÔNG thêm nút "Chuyên Tu". Gọi `specialized` là trạng thái nội bộ của action `CULTIVATE`, không phải một chế độ người chơi phải hiểu.

Tàng Kinh Các và danh mục nguồn phải ghi:
- `DESIGN_DIRECTION_CONFIRMED`: user yêu cầu tối đa 50 từ Tâm Tính và tăng hiệu quả TU LUYỆN.
- `DESIGN_CANDIDATE`: +0,10 điểm % kháng/điểm; +0,05% Tu Vi/điểm, cap25. **Chưa được xác nhận các hệ số.**
- `GAMEPLAY_NOT_CODED`: cả hai hiệu ứng riêng Tâm Tính mới vẫn chưa hoạt động trong game.
- Không có Tâm Trạng/Tâm Cảnh hoặc hệ thứ ba.

## 6. Các điều kiện để về sau có thể triển khai

(1) Không thay dữ liệu sinh D7, (2) tính nguồn `foundation_mind_nature` trong combat V2 một lần, (3) áp thưởng cultivation chỉ `CULTIVATE`, (4) preview bằng commit, (5) giữ mốc bảo vệ mỗi tick, (6) không chồng thưởng từ các Trait có cùng channel, (7) kiểm thử các mức 0,100,200,300,500,800 và khi tắt V2, (8) sau khi owner duyệt hệ số mới được sửa mã game.

**Tình trạng:** chỉ sửa thiết kế, dữ liệu trình bày của Tàng Kinh Các và test nguồn. PR #72 Draft, không merge, không sửa gameplay trong gói này.
