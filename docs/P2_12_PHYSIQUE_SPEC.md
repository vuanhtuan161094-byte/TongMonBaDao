# P2.12 — Thể Chất + Tôi Thể + Cải Thể

Date: 2026-10-01

## Mục tiêu

Thể Chất là **cấu tạo và cơ chế vận hành của cơ thể hiện tại**. Nó tách biệt với:

- Huyết Mạch — nguồn gốc/dòng máu;
- Linh căn — hấp thu/điều khiển linh khí;
- Đặc chất — tính chất cá nhân;
- Công pháp — thứ đã học;
- Trang bị — vật ngoài thân;
- Thiên Mệnh — luật hiếm của cá nhân.

Không sợ trùng stat. Thể Chất được phép cộng Công, Thủ, tốc tu, đột phá, hồi phục và thiên hướng Kiếm/Thể/Pháp nếu hợp logic.

## Luật cơ chế toàn game áp dụng

Read `CURRENT_CHECKPOINT.md`.

Mỗi thể chất đặc biệt phải có:

1. lợi ích gameplay rõ ràng;
2. ít nhất một trục Công/Thủ hoặc sức mạnh trực tiếp;
3. ít nhất hai trục lợi ích thật;
4. hậu quả đo được bằng simulation;
5. nhược điểm/điều kiện nếu có phải là thật, không chỉ lore.

Overlap với Huyết Mạch/Linh căn/Công pháp/Trang bị là hợp lệ và phải cộng dồn khi logic cho phép.

## Feature gate

`SectState.physiques_enabled`

Storage:

`SectState.physique_profiles[character_id]`

Profile schema:

- `initialized`
- `physique_id`
- `initial_physique_id`
- `temper_level`
- `transformed`
- `latent_transformation`

Candidate -> disciple giữ nguyên character id nên profile phải giữ nguyên. Reject phải xóa orphan profile.

## Các thể chất vertical slice

### Phàm Thể

Không phải đồ bỏ.

- mặc định không có bonus lớn;
- mỗi cấp Tôi thể tăng nhẹ Công/Thủ/Tu/Đột phá/Hồi phục và XP ba hướng;
- mọi Phàm Thể V2 có một hướng cải thể deterministic đã khóa từ seed;
- hướng đó không reroll khi bấm cải thể.

### Kiếm Cốt

Vai trò: cơ thể sinh ra hợp Kiếm đạo.

- +Công;
- +tốc tu;
- +đột phá nhẹ;
- +Kiếm đạo XP rõ rệt;
- có một ít Thủ;
- nhược điểm: hồi phục hơi kém trước khi Tôi thể cao.

### Kim Cương Bá Thể

Vai trò: thân thể chiến đấu/trấn thủ.

- +Công;
- +Thủ rất cao;
- +hồi phục;
- +Thể đạo XP rất cao;
- nhược điểm: tu luyện linh khí chậm hơn.

### Hàn Âm Thể

Vai trò: thể chất có điều kiện tương thích.

Nếu có Thủy linh căn:

- +Công;
- +Thủ;
- +tốc tu mạnh;
- +đột phá;
- +hồi phục;
- +Pháp đạo XP.

Nếu không có Thủy linh căn:

- vẫn có chút Công/Thủ;
- tốc tu giảm;
- hồi phục giảm do hàn khí không được dẫn đúng đường;
- đây là mismatch thật.

### Hỏa Linh Thể

Vai trò: công kích/pháp tu thiên Hỏa.

Nếu có Hỏa linh căn:

- +Công rất cao;
- +tốc tu mạnh;
- +đột phá;
- +Pháp đạo XP mạnh;
- Thủ/hồi phục không phải thế mạnh.

Nếu không có Hỏa linh căn, các bonus trên giảm rõ rệt.

### Vô Cấu Đạo Thể

Vai trò: cực hiếm, toàn diện.

- +Công;
- +Thủ;
- +tốc tu rất cao;
- +đột phá;
- +hồi phục;
- +XP cả Kiếm/Thể/Pháp;
- không có nhược điểm lớn trong vertical slice;
- xác suất innate/latent rất thấp, Nhân Duyên cao hơn các nguồn khác.

## Sinh thể chất

Same seed/source/index phải cho cùng profile.

Nguồn tuyển chỉ đổi phân bố:

- ordinary: special physique thấp nhất;
- gacha: cao hơn;
- fate: cao nhất.

Nếu sinh ra Phàm Thể, `latent_transformation` vẫn được khóa ngay từ seed. Player chưa cần thấy target trước khi cải thể.

## Tôi thể

Action: `temper_body()`

- tối đa cấp 5 trong vertical slice;
- mỗi lần tiêu hao **1 Yêu Đan** từ economy hiện có;
- tăng `temper_level`;
- stat profile phải mạnh lên thật theo cấp;
- không tạo currency riêng.

## Cải thể

Action: `transform_body()`

Điều kiện:

- đang là Phàm Thể;
- Tôi thể >= 3;
- có latent transformation hợp lệ;
- có ít nhất **2 Linh Tủy**.

Kết quả:

- tiêu 2 Linh Tủy;
- đổi sang đúng `latent_transformation` đã sinh sẵn;
- `transformed = true`;
- giữ nguyên temper level;
- không reroll target.

## Các hook hậu quả thật

- `CultivationSystem.effective_combat_power()` đọc Công Thể Chất.
- `CombatSystem` đọc Thủ Thể Chất qua incoming-damage multiplier.
- `CultivationSystem.add_progress()` đọc tốc tu Thể Chất.
- `CultivationSystem.breakthrough_success_chance()` đọc bonus đột phá.
- `NeedsSystem.apply_rest()` đọc hồi phục/nhược điểm hồi phục.
- `CultivationPathSystem.add_experience()` đọc thiên hướng XP Kiếm/Thể/Pháp.

## Luật overlap

Huyết Mạch + Thể Chất **phải stack**.

Ví dụ một đệ tử có Chân Long Huyết + Hỏa Linh Thể được phép nhận cả bonus Công/Tu từ hai nguồn. Không vô hiệu bonus chỉ vì cùng tác động một stat.

Gate P2.12 có contract test riêng cho overlap này.

## Gate P2.12 phải chứng minh

1. P2.11 vẫn physique-disabled và không đổi state shape.
2. Same seed -> exact same physique profiles.
3. Phàm Thể ổn định, không reroll, có deterministic transformation route.
4. Mỗi special physique có >= 2 lợi ích thật và có Công hoặc Thủ.
5. Tôi thể tiêu đúng 1 Yêu Đan và tăng hậu quả thật.
6. Cải thể tiêu đúng 2 Linh Tủy và dùng đúng latent target cũ.
7. Kiếm Cốt tăng real Sword XP và có real recovery drawback.
8. Kim Cương Bá Thể tăng real defense và giảm real cultivation speed.
9. Hàn Âm Thể tương tác thật với Thủy linh căn.
10. Hỏa Linh Thể tương tác thật với Hỏa linh căn.
11. Bloodline + Physique stat overlap stack thật.
12. candidate accept preserves exact profile; reject removes profile.
13. exact save/load + deterministic continuation.
14. cumulative P0-P2.11 remains green.
15. scene smoke passes.
