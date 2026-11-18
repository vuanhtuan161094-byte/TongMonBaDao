# D1 — TÂM TÍNH V2: CHIẾN ĐẤU VÀ CHUYÊN TU TU VI

Cập nhật: 18/11/2026 · Gói thiết kế D1 · Draft PR #72.

**THAY THẾ BẢN D1-MOOD CŨ:** Theo yêu cầu người dùng, không đưa Tâm Trạng, shock_mood, hành động nghỉ hồi mood, Tu Tâm Đường hay Tâm Cảnh vào thiết kế Tâm Tính hiện tại. Tâm Trạng từng được nhắc trong tài liệu framework về living state, không phải chức năng đã triển khai hoặc user yêu cầu thêm. Các đề xuất D1-M2/M3/M4 trước đây đã RÚT khỏi phạm vi, không được giao coding.

## 1. Phân định chỉ số — giữ nguyên D7 và 16 Combat Stats

| Chỉ số | Kênh gameplay | Tình trạng |
|---|---|---|
| Tư Chất | Tu Vi tự nhiên +0,25%/điểm (kênh cultivation_gain) | Luật đã chốt |
| Căn Cốt | EXP Luyện Thể +0,20%/điểm (kênh body_training_gain) | Luật đã chốt |
| Tâm Tính | +0,01 điểm % Kháng Hiệu Ứng/điểm, tối đa +8 điểm % | D1-A2 ĐÃ DUYỆT THIẾT KẾ, CHƯA NỐI PvE CHÍNH |
| Tâm Tính | Hiệu suất Chuyên Tu Tu Vi +0,05%/điểm, cap +25% | D1-CULT1 ỨNG VIÊN MỚI, CHƯA DUYỆT CON SỐ |

Chỉ số nền mind_nature đã có trong FoundationSystem MODEL_D7; DiscipleState đã lưu/tải. Chưa có source buff thực. Không thêm chỉ số chiến đấu thứ 17, không thêm Tu Vi track thứ ba.

## 2. D1-A2 — Kháng Hiệu Ứng, thiết kế ĐÃ CHỐT

bonus_effect_resistance_pp = min(8, 0.01 × max(0, Tâm_Tính)); fractional = min(0.08, 0.0001 × Tâm_Tính).

Nguồn duy nhất trong CombatStatsV2: source_id foundation_mind_nature, channel effect_resistance, mode percentage_points. 100 điểm → +1 điểm %, 500 → +5 điểm %, 800+ → +8 điểm %.

Ví dụ: đối thủ có 45% gốc +10 điểm % Chính Xác Hiệu Ứng; người phòng thủ Tâm Tính 500 có +5 điểm % Kháng, Trait Tâm Thần Kiên Cố +10 điểm % Kháng: xác suất bị trúng status thường = 45+10−5−10=40%. Không tác động guaranteed/immune theo luật skill. Không giảm duration đã trúng, không buff Crit, không thay Injury.

ĐÂY LÀ DESIGN LOCK, KHÔNG GỌI RUNTIME PASS.

## 3. D1-CULT1 — Định Tâm khi Chuyên Tu (ĐỀ XUẤT, chưa duyệt hệ số)

### Ý nghĩa

Một đệ tử có Tâm Tính cao tận dụng tốt hơn **thời gian Chuyên Tu Tu Vi**. Họ không được thêm Tu Vi khi đứng yên, làm mỏ, gieo trồng, săn quái hoặc dùng Tu Vi Đan. Hiệu ứng này CHỈ xuất hiện khi thật sự có Chuyên Tu trong DiscipleTuViFlowV2.

### Hệ số ứng viên

mind_focus_bonus = min(0.25, 0.0005 × max(0, mind_nature))

focused_multiplier = authored_cultivate_multiplier × (1 + mind_focus_bonus)

tuvi_gain_per_sim_min = authored_base_tuvi_per_min × (specialized ? focused_multiplier : 1.0) × (1 + 0.0025 × aptitude + valid_source_bonus)

- Giữ nguyên authored_base_tuvi_per_min=1.000 và authored_cultivate_multiplier=2.0 trong DiscipleProgressionBalanceV2.
- valid_source_bonus là nguồn Tu Vi tự nhiên hợp lệ hiện có trong grant_xp(), không tự áp thêm sau lần đầu.
- Chỉ số Tu Vi/s là bình quân theo 60 giây thực = 1 phút mô phỏng; EXP thật được grant một lần/tick.
- Không tạo mới một lần grant_xp thứ hai để cộng phần Tâm Tính. Đề xuất chèn multiplier có điều kiện vào cả preview_rate() và resolve_minute() trước khi gọi grant_xp() đang có.
- Mốc 500 chỉ là **bão hòa hiệu ứng Chuyên Tu**, không phải giới hạn điểm D7. Mốc 800 vẫn là trần của Kháng Hiệu Ứng.

| Tâm Tính | Thưởng thêm so với Chuyên Tu gốc | Chuyên Tu tổng (gốc ×2) |
|---:|---:|---:|
| 0 | 0% | ×2,00 |
| 100 | +5% | ×2,10 |
| 300 | +15% | ×2,30 |
| 500 | +25% | ×2,50 |
| 800 | +25% | ×2,50 |

### Ví dụ với Tư Chất 100, KHÔNG buff khác

| Chế độ | Tâm Tính | Bình quân Tu Vi/phút | Bình quân Tu Vi/giây |
|---|---:|---:|---:|
| Tu Vi tự nhiên | mọi mức | 1.250 | 20,83 |
| Chuyên Tu gốc | 0 | 2.500 | 41,67 |
| Chuyên Tu | 100 | 2.625 | 43,75 |
| Chuyên Tu | 300 | 2.875 | 47,92 |
| Chuyên Tu | 500 | 3.125 | 52,08 |

Giá trị ví dụ là thiết kế giả lập, không phải current game EXP/s; khi đủ cấp/nội dung/buff khác thì giá trị game có thể khác.

### Điều kiện để một đệ tử được hưởng

1. v2_training_enabled=true, actor hợp lệ và specialized=true do scheduler/policy thực tế chọn. Không tự bật chuyên tu.
2. Giữ guard last_passive_tuvi_tick, event_id, không cấp lặp khi reload hoặc catch-up.
3. Không cộng thưởng cho fixed Tu Vi Đan, XP từ đánh quái, EXP nghề, Luyện Thể hoặc các tick lao động thông thường.
4. Không thay xác suất đột phá, thưởng Đột Phá Đan hay hình phạt thất bại đã chốt.
5. Đề xuất source_id foundation_mind_nature_focus tách biệt foundation_mind_nature của combat; **không lưu buff như một permanent stat thứ hai**, chỉ tính từ mind_nature hiện tại.
6. Preview và commit phải cùng công thức; áp một lần trước khi gọi existing grant_xp natural factor. Không chồng các hệ số tương đương của 101 Trait khi chưa có source/cap authority.
7. Mặc định nếu chưa triển khai: +0% từ nguồn mới, không âm thầm sửa gameplay P0 hiện hữu.

### Người chơi nhìn thấy

Tại hồ sơ Đệ Tử: Tâm Tính 300 → Kháng Hiệu Ứng +3 điểm % (thiết kế đã chốt) và Định Tâm: Chuyên Tu +15% (đề xuất, chưa code).

Ở màn điều khiển Chuyên Tu (khi tương lai triển khai): hiện breakdown base 1.000/phút, Tư Chất +25%, Chuyên Tu gốc ×2 và Định Tâm +15%; tổng 2.875/phút = bình quân 47,92/s. Khi chuyển sang làm việc hoặc tu luyện tự nhiên thì không có dòng Định Tâm.

## 4. Không đưa Tâm Trạng vào D1

- Không thêm thanh mood, stress, "tâm ma" random, nghỉ phục hồi tinh thần hoặc công trình mới.
- Tâm Tính không buộc người chơi phải quản lý một chỉ số tinh thần thứ hai.
- Tâm Cảnh và Tu Tâm Đường trong tài liệu quá khứ không thuộc quyết định hiện tại; không xóa lịch sử thiết kế nhưng không đưa vào hệ cần code.
- Không phát sinh tác dụng thứ ba nếu người dùng chưa yêu cầu.

## 5. Test bắt buộc khi triển khai sau khi duyệt — không chạy gameplay trong đợt thiết kế

- Tâm Tính 0/100/300/500/800: Chuyên Tu ×2/×2,10/×2,30/×2,50/×2,50; natural unchanged.
- Tư Chất 100, Tâm Tính 500: natural=1.250/phút, focus=3.125/phút nếu không có nguồn khác.
- Preview/commit/catch-up thống nhất, no double-grant; fixed pills unchanged.
- D7 migration, nonfinite input, birth snapshots, source disabled và flag V2 OFF không đổi giá trị cũ.
- Kháng Hiệu Ứng A2 được cộng source một lần cùng Trait có source khác.
- Chưa có Godot QA cho tính năng mới, không merge Draft PR #72.

## 6. Quyết định

D1-A2 Kháng Hiệu Ứng: APPROVED DESIGN ONLY.

D1-CULT1 Chuyên Tu: NGƯỜI DÙNG ĐÃ YÊU CẦU BỔ SUNG TÁC DỤNG TU LUYỆN; mức +0,05%/điểm và cap +25% mới là **PHƯƠNG ÁN ĐỂ XEM VÀ ĐIỀU CHỈNH**, chưa được coi đã duyệt số. Nơi xem tập trung: Tàng Kinh Các, mục Đệ tử & đặc tính.

Nguồn: godot/src/simulation/cultivation/disciple_tuvi_flow_v2.gd, disciple_progression_balance_v2.gd, disciple_realm_progress_v2.gd, docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md.
