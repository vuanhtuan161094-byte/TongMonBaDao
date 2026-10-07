> **LEGACY / COMPATIBILITY ONLY — SUPERSEDED FOR FUTURE DESIGN**
>
> Future Thể Chất authority is `docs/PHYSIQUE_V2_SPEC.md`.
> Keep this P2.12 contract only for existing regression evidence and old-save migration until an explicit tested V2 implementation replaces it.
> Do not extend grade / temper_level / latent_transformation / old special-physique rules for new gameplay.

# P2.12 — Thể Chất + Cấp Bậc + Tôi Thể + Cải Thể

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

## Hai trục riêng: loại + cấp bậc

**Loại thể chất** trả lời cơ thể vận hành theo kiểu gì:

- Kiếm Cốt;
- Kim Cương Bá Thể;
- Hàn Âm Thể;
- Hỏa Linh Thể;
- Vô Cấu Đạo Thể;
- hoặc không có loại đặc biệt.

**Cấp bậc thể chất** trả lời nền cơ thể mạnh đến mức nào:

1. `mortal_body` — **Phàm Thể**;
2. `spirit_body` — **Linh Thể**;
3. `mystic_body` — **Huyền Thể**;
4. `saint_body` — **Thánh Thể**;
5. `divine_body` — **Thần Thể**.

Hai trục không được gộp làm một.

Player-facing display:

- không có loại đặc biệt: chỉ hiện `Phàm Thể`, `Linh Thể`, `Huyền Thể`...;
- có loại đặc biệt: `Kiếm Cốt · Huyền Thể`, `Hỏa Linh Thể · Thánh Thể`, `Vô Cấu Đạo Thể · Thần Thể`.

Không hiển thị kiểu `Phàm Thể · Phàm Thể`.

Cấp bậc phải tác động stat thật. Cùng một Kiếm Cốt, Thần Thể phải có lợi ích Công/Thủ/Tu/Đột phá/XP mạnh hơn bản Phàm Thể.

Current grade stat scales:

- Phàm Thể: `0.85x` phần lợi ích dương;
- Linh Thể: `1.00x`;
- Huyền Thể: `1.20x`;
- Thánh Thể: `1.45x`;
- Thần Thể: `1.80x`.

Nhược điểm không bị nhân nặng thêm theo cấp bậc trong vertical slice. Cấp bậc cao làm ưu thế mạnh hơn, không biến drawback thành hình phạt lớn hơn.

## Xác suất cấp bậc

Cấp bậc được sinh deterministic từ seed và nguồn tuyển, tách khỏi roll loại thể chất.

| Cấp bậc | Tuyển thường | Chiêu Hiền | Nhân Duyên |
| --- | ---: | ---: | ---: |
| Phàm Thể | 58% | 40% | 28% |
| Linh Thể | 27% | 32% | 31% |
| Huyền Thể | 11% | 19% | 24% |
| Thánh Thể | 3,5% | 7% | 13% |
| Thần Thể | 0,5% | 2% | 4% |

Mỗi cột phải bằng 100%.

`Thần Thể` phải hiếm nhưng không độc quyền gacha. Tuyển thường vẫn có xác suất cực thấp; Nhân Duyên có xác suất cao nhất.

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
- `physique_grade`
- `initial_physique_id`
- `temper_level`
- `transformed`
- `latent_transformation`

Candidate -> disciple giữ nguyên character id nên profile phải giữ nguyên cả loại và cấp bậc. Reject phải xóa orphan profile.

## Các thể chất vertical slice

### Thân thể thường

Không phải đồ bỏ.

- có cấp bậc Phàm/Linh/Huyền/Thánh/Thần như mọi cơ thể khác;
- mặc định không có cơ chế đặc thù lớn;
- mỗi cấp Tôi thể tăng nhẹ Công/Thủ/Tu/Đột phá/Hồi phục và XP ba hướng;
- mọi thân thể thường V2 có một hướng cải thể deterministic đã khóa từ seed;
- hướng đó không reroll khi bấm cải thể;
- cải thể giữ nguyên `physique_grade`, chỉ đổi loại thể chất.

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

Same seed/source/index phải cho cùng profile, gồm cả `physique_id` và `physique_grade`.

Nguồn tuyển đổi cả:

- xác suất có loại thể chất đặc biệt;
- phân bố cấp bậc Phàm/Linh/Huyền/Thánh/Thần.

Current special-physique chance:

- ordinary: 15%;
- gacha: 28%;
- fate: 40%.

Nếu sinh ra thân thể thường, `latent_transformation` vẫn được khóa ngay từ seed. Player chưa cần thấy target trước khi cải thể.

## Tôi thể

Action: `temper_body()`

- tối đa cấp 5 trong vertical slice;
- mỗi lần tiêu hao **1 Yêu Đan** từ economy hiện có;
- tăng `temper_level`;
- stat profile phải mạnh lên thật theo cấp;
- không tự reroll loại hoặc cấp bậc;
- không tạo currency riêng.

## Cải thể

Action: `transform_body()`

Điều kiện:

- đang không có loại thể chất đặc biệt;
- Tôi thể >= 3;
- có latent transformation hợp lệ;
- có ít nhất **2 Linh Tủy**.

Kết quả:

- tiêu 2 Linh Tủy;
- đổi sang đúng `latent_transformation` đã sinh sẵn;
- `transformed = true`;
- giữ nguyên temper level;
- giữ nguyên cấp bậc thể chất;
- không reroll target hoặc grade.

## Thăng cấp bậc thể chất

P2.12 vertical slice **chưa tự động nâng Phàm -> Linh -> Huyền -> Thánh -> Thần chỉ bằng Tôi thể**.

Lý do: cấp bậc là nền chất lượng lớn, không nên farm 5 Yêu Đan rồi chắc chắn lên Thần Thể.

Cơ chế thăng cấp bậc về sau phải là một action riêng, tiêu thiên tài địa bảo/tài nguyên hiếm và có điều kiện cảnh giới/cơ duyên. Tuy nhiên schema và stat scaling đã sẵn sàng từ P2.12.

## Các hook hậu quả thật

- `CultivationSystem.effective_combat_power()` đọc Công Thể Chất.
- `CombatSystem` đọc Thủ Thể Chất qua incoming-damage multiplier.
- `CultivationSystem.add_progress()` đọc tốc tu Thể Chất.
- `CultivationSystem.breakthrough_success_chance()` đọc bonus đột phá.
- `NeedsSystem.apply_rest()` đọc hồi phục/nhược điểm hồi phục.
- `CultivationPathSystem.add_experience()` đọc thiên hướng XP Kiếm/Thể/Pháp.
- `PhysiqueSystem` scale các lợi ích dương theo Phàm/Linh/Huyền/Thánh/Thần.

## Luật overlap

Huyết Mạch + Thể Chất **phải stack**.

Ví dụ một đệ tử có Chân Long Huyết + Hỏa Linh Thể · Thánh Thể được phép nhận cả bonus Công/Tu từ các nguồn. Không vô hiệu bonus chỉ vì cùng tác động một stat.

Gate P2.12 có contract test riêng cho overlap này.

## Gate P2.12 phải chứng minh

1. P2.11 vẫn physique-disabled và không đổi state shape.
2. Same seed -> exact same physique profiles, gồm grade.
3. Thân thể thường ổn định, không reroll, có deterministic transformation route.
4. Cấp bậc hợp lệ: Phàm/Linh/Huyền/Thánh/Thần.
5. Xác suất grade mỗi nguồn cộng đúng 100%; Thần Thể tăng ordinary < gacha < fate.
6. Cùng loại thể chất, Thần Thể phải mạnh hơn Phàm Thể bằng stat thật.
7. Display contract: loại đặc biệt + grade; thân thường chỉ hiện grade.
8. Mỗi special physique có >= 2 lợi ích thật và có Công hoặc Thủ.
9. Tôi thể tiêu đúng 1 Yêu Đan và tăng hậu quả thật.
10. Cải thể tiêu đúng 2 Linh Tủy, dùng đúng latent target cũ và không reroll grade.
11. Kiếm Cốt tăng real Sword XP và có real recovery drawback.
12. Kim Cương Bá Thể tăng real defense và giảm real cultivation speed.
13. Hàn Âm Thể tương tác thật với Thủy linh căn.
14. Hỏa Linh Thể tương tác thật với Hỏa linh căn.
15. Bloodline + Physique stat overlap stack thật.
16. candidate accept preserves exact type + grade profile; reject removes profile.
17. exact save/load + deterministic continuation preserves grade.
18. cumulative P0-P2.11 remains green.
19. scene smoke passes.
