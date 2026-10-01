# P2.11 — Huyết Mạch + Thức Tỉnh + Độ Thuần

Date: 2026-10-01

## Mục tiêu

Huyết mạch là một lớp bẩm sinh riêng, không được gộp với Linh căn, Thể chất, Thiên Mệnh hay Đặc chất.

Một đệ tử có thể:

- không có huyết mạch đặc biệt;
- mang huyết mạch đặc biệt nhưng chưa bị phát hiện;
- đã lộ huyết mạch nhưng chưa thức tỉnh;
- thức tỉnh rồi và tiếp tục tăng độ thuần.

Identity được sinh một lần từ seed và giữ nguyên. Reveal/awakening không được reroll.

## Luật cốt lõi: huyết mạch phải mạnh bằng stat thật trước, mechanic riêng sau

Huyết mạch đặc biệt không được tồn tại chỉ để có flavor text, hồi phục, ăn nhiều hay một gimmick nhỏ.

Sau khi thức tỉnh, mỗi huyết mạch đặc biệt phải có:

1. ít nhất một ưu thế chiến đấu trực tiếp: Công hoặc Thủ;
2. ít nhất hai trục lợi ích gameplay thật trong các nhóm Công / Thủ / Tu luyện / Đột phá / Hồi phục;
3. hiệu quả tăng theo độ thuần;
4. mechanic/lore riêng chỉ là lớp bổ sung phía trên bộ stat nền.

Do đó việc huyết mạch cộng Công, Thủ, tốc tu, xác suất đột phá, hồi phục... là hợp canon và được khuyến khích. Không cần tránh cộng stat chỉ để ép mỗi huyết mạch phải có một gimmick kỳ lạ.

## Vertical slice P2.11

Các huyết mạch đầu tiên:

- `true_dragon` — Chân Long Huyết: Công + Thủ + tốc tu + đột phá;
- `phoenix` — Phượng Hoàng Huyết: Công + Thủ nhẹ + tốc tu + hồi phục rất cao + bonus đột phá nhỏ;
- `white_tiger` — Bạch Hổ Huyết: Công cao nhất, thiên sát phạt; thêm bonus tu luyện nhỏ;
- `black_tortoise` — Huyền Vũ Huyết: Thủ cao nhất, đồng thời có Công nền + tốc tu + hồi phục;
- `taotie_remnant` — Thao Thiết Tàn Huyết: Công + Thủ + tốc tu + hồi phục mạnh; đổi lại ăn thêm vật tư khi xuất môn. Đây là tradeoff hài/lore-valid, không phải giá trị chính duy nhất của huyết mạch.

`none` là kết quả hợp lệ và phổ biến.

## Nguồn tuyển

Tuyển thường, Chiêu Hiền và Nhân Duyên dùng cùng schema huyết mạch.

Nguồn tuyển chỉ thay phân bố xác suất:

- ordinary: special bloodline thấp nhất;
- gacha: cao hơn;
- fate: cao nhất.

Không nguồn nào được tạo một kiểu nhân vật riêng.

## Profile authority

P2.11 lưu hồ sơ huyết mạch trong:

`SectState.bloodline_profiles[character_id]`

Schema:

- `initialized`
- `bloodline_id`
- `purity`
- `revealed`
- `awakened`
- `refinement_count`

Candidate và disciple giữ cùng id, nên accept phải giữ y nguyên profile.

Reject phải xóa orphan profile.

## Reveal

Reveal là phát hiện huyết mạch đã tồn tại sẵn.

Vertical-slice conditions:

- Chân Long: `combats >= 3`;
- Phượng Hoàng: `defeats >= 1` và `rests >= 1`;
- Bạch Hổ: `wins >= 3`;
- Huyền Vũ: `retreats >= 2`;
- Thao Thiết: `rests >= 3`.

Một số candidate có thể được phát hiện huyết mạch sớm ngay lúc tuyển tùy seed/source, nhưng identity vẫn là cùng profile.

## Awakening

Sau khi reveal, Tông Chủ có thể dùng Yêu Đan để thức tỉnh.

P2.11 tái sử dụng `TechniqueSystem.MATERIAL_CORE` (`yeu_dan`) để tạo cạnh tranh tài nguyên thật, không thêm tiền mới.

Awakening:

- cần `revealed == true`;
- huyết mạch != none;
- tiêu hao 1 Yêu Đan;
- đặt `awakened = true`;
- toàn bộ stat/hiệu ứng huyết mạch chỉ bắt đầu sau awakening.

## Độ thuần

Sau awakening có thể tiếp tục dùng Yêu Đan để luyện huyết.

- độ thuần tăng có diminishing returns;
- Tiềm Lực ảnh hưởng hiệu quả tăng;
- cap vertical slice: 0.95;
- 100% tuyệt đối để dành cho đại cơ duyên/truyền thừa sau này;
- tăng độ thuần phải làm bộ stat huyết mạch mạnh lên thật, không chỉ tăng con số trang trí.

## Bộ stat vertical slice hiện tại

Các con số dưới đây là công thức runtime P2.11 hiện tại, có thể cân bằng lại sau khi có gameplay dài hạn.

### Chân Long Huyết

- Công: `2.5 + purity * 7.5` chiến lực;
- Thủ: giảm sát thương theo `0.98 - purity * 0.08`;
- Tu luyện: `1.03 + purity * 0.10`;
- Đột phá: `+0.010 + purity * 0.030` xác suất;
- Hồi phục: `1.05 + purity * 0.12`.

Vai trò: toàn diện, mạnh và ổn định.

### Phượng Hoàng Huyết

- Công: `1.5 + purity * 4.5` chiến lực;
- Thủ nhẹ: `0.99 - purity * 0.04` incoming damage multiplier;
- Tu luyện: `1.02 + purity * 0.07`;
- Đột phá: `+0.004 + purity * 0.010`;
- Hồi phục: `1.20 + purity * 0.50`.

Vai trò: sinh mệnh, hồi phục và phát triển bền bỉ, nhưng không còn chỉ là “nghỉ hồi nhanh”.

### Bạch Hổ Huyết

- Công: `3.0 + purity * 10.0` chiến lực — cao nhất trong slice;
- Tu luyện: `1.00 + purity * 0.025`;
- không có giảm sát thương riêng trong slice này.

Vai trò: sát phạt thuần túy.

### Huyền Vũ Huyết

- Công nền: `1.0 + purity * 3.0`;
- Thủ: `0.90 - purity * 0.24` incoming damage multiplier — mạnh nhất trong slice;
- Tu luyện: `1.01 + purity * 0.035`;
- Hồi phục: `1.08 + purity * 0.15`.

Vai trò: chống chịu cực mạnh nhưng vẫn là huyết mạch cao cấp, không phải chỉ là một passive phòng thủ nhỏ.

### Thao Thiết Tàn Huyết

- Công: `2.0 + purity * 5.5`;
- Thủ: `0.97 - purity * 0.07`;
- Tu luyện: `1.02 + purity * 0.05`;
- Hồi phục: `1.20 + purity * 0.40`;
- nhược điểm: khi xuất môn và còn vật tư, tiêu thêm 1 Supply.

Vai trò: rất khỏe và hồi phục mạnh. “Ăn nhiều” là tradeoff có tính hài, không phải toàn bộ giá trị của huyết mạch.

## UI

P2.11 interaction scene phải hiện trực tiếp các ưu thế sau khi thức tỉnh:

- + Công;
- % giảm sát thương;
- % tốc tu luyện;
- điểm % đột phá;
- % hồi phục;
- tradeoff riêng nếu có.

Người chơi không cần tự đoán huyết mạch mạnh ở đâu.

## Humor canon

Read `docs/XIANXIA_FLAVOR_CANON.md`.

Humor chỉ được nằm trên mechanic thật.

Ví dụ Thao Thiết có thể phát thông báo vui về ăn thêm lương khô vì runtime đã thực sự trừ thêm Supply. Nhưng hệ thống không được biến Huyết Mạch thành một joke system.

## Feature gate

`SectState.bloodlines_enabled`

Khi false:

- P2.10 và trước giữ nguyên behavior;
- không ghi bloodline state vào save;
- không có bloodline modifier.

## Gate P2.11 phải chứng minh

1. P2.10 vẫn bloodline-disabled.
2. Same seed/source/index -> exact same bloodline profile.
3. `none` là kết quả hợp lệ và không reroll.
4. reveal không đổi bloodline ID/purity.
5. bloodline chưa awaken không có effect.
6. awakening tiêu đúng 1 Yêu Đan.
7. mọi special bloodline có ít nhất một ưu thế Công/Thủ thật.
8. mọi special bloodline có ít nhất hai trục lợi ích gameplay thật.
9. Chân Long/Bạch Hổ ảnh hưởng real effective combat power.
10. Chân Long ảnh hưởng breakthrough chance.
11. Huyền Vũ ảnh hưởng real incoming damage multiplier.
12. Phượng Hoàng tăng real rest recovery nhưng đồng thời có core combat/cultivation stats.
13. Thao Thiết có core combat stats + recovery, còn extra Supply là tradeoff thật.
14. refinement tăng purity, dùng Yêu Đan, có diminishing returns và làm core stat mạnh lên.
15. candidate acceptance preserve exact profile; reject removes profile.
16. exact persistence + deterministic continuation.
17. cumulative P0-P2.10 remains green.
18. P2.11 interaction scene smoke passes.
