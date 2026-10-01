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

## Vertical slice P2.11

Các huyết mạch đầu tiên:

- `true_dragon` — Chân Long Huyết: chiến lực + đột phá;
- `phoenix` — Phượng Hoàng Huyết: hồi phục mạnh;
- `white_tiger` — Bạch Hổ Huyết: thiên về công kích;
- `black_tortoise` — Huyền Vũ Huyết: giảm sát thương nhận;
- `taotie_remnant` — Thao Thiết Tàn Huyết: hồi phục rất tốt nhưng ăn thêm vật tư khi xuất môn. Đây là huyết mạch hài/lore-valid đầu tiên.

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
- hiệu ứng gameplay chỉ bắt đầu sau awakening.

## Độ thuần

Sau awakening có thể tiếp tục dùng Yêu Đan để luyện huyết.

- độ thuần tăng có diminishing returns;
- Tiềm Lực ảnh hưởng hiệu quả tăng;
- cap vertical slice: 0.95;
- 100% tuyệt đối để dành cho đại cơ duyên/truyền thừa sau này.

## Hậu quả thật

### Chân Long

- cộng chiến lực thật;
- cộng xác suất đột phá thật.

### Phượng Hoàng

- tăng hồi HP/thể lực khi nghỉ.

### Bạch Hổ

- cộng chiến lực thật mạnh hơn Chân Long, nhưng không có bonus đột phá.

### Huyền Vũ

- giảm sát thương nhận trong combat thật.

### Thao Thiết Tàn Huyết

- tăng hồi phục khi nghỉ;
- khi xuất môn và còn vật tư, tiêu thêm 1 Supply;
- đây là tradeoff thật, không chỉ joke text.

## Humor canon

Read `docs/XIANXIA_FLAVOR_CANON.md`.

P2.11 chỉ đưa humor vào nơi hợp lore. Ví dụ event/UI sau này có thể hiện:

`Bạch Phong ăn thêm một phần lương khô. Thao Thiết tàn huyết có vẻ không hiểu chữ “no”.`

Nhưng thông báo chỉ phát khi thật sự có extra supply consumption.

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
7. Chân Long/Bạch Hổ ảnh hưởng real effective combat power.
8. Chân Long ảnh hưởng breakthrough chance.
9. Huyền Vũ ảnh hưởng real incoming damage multiplier.
10. Phượng Hoàng tăng real rest recovery.
11. Thao Thiết tăng recovery nhưng tiêu thêm real supply khi departure.
12. refinement tăng purity, dùng Yêu Đan và có diminishing returns.
13. candidate acceptance preserve exact profile; reject removes profile.
14. exact persistence + deterministic continuation.
15. cumulative P0-P2.10 remains green.
16. P2.11 interaction scene smoke passes.
