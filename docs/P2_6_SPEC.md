# P2.6 — Luyện Khí, Trang Bị và Kinh tế Trang Bị

## Mục tiêu

P2.6 nối săn quái, kho tông môn, sản xuất, kinh tế nội bộ và chiến đấu thành một vòng tycoon có hậu quả thật:

`Săn -> nguyên liệu -> Luyện Khí Đường -> trang bị -> bán/cấp -> đệ tử mạnh hơn -> săn vùng khó hơn`.

Mặc định đệ tử tự đánh giá và tự mua/nâng cấp trang bị, nhưng người chơi luôn có quyền can thiệp trực tiếp.

## Kiến trúc khóa

- `P25Factory` giữ `equipment_enabled == false`.
- `P26Factory` mới bật `EquipmentSystem`.
- P2.6 là opt-in; P2.5 không đổi hành vi khi feature tắt.
- Không có class-lock cứng. Kiếm/Thể/Pháp và ngũ hành thay đổi độ phù hợp/hiệu quả, không khóa quyền sử dụng.
- Mỗi món là instance riêng có ID ổn định, phẩm chất, slot, recipe, hướng tu, nguyên tố, stats, giá, vị trí và owner.
- Phẩm chất rèn deterministic từ seed + forge index + recipe.

## Nội dung vertical slice

Nguyên liệu:

- Linh Mộc
- Thanh Thiết
- Tinh Lang Bì
- Yêu Đan

Công thức:

- Thanh Thiết Kiếm — weapon / Kiếm / Kim
- Huyền Thiết Quyền Sáo — weapon / Thể / Thổ
- Linh Mộc Pháp Trượng — weapon / Pháp / Mộc
- Tinh Lang Giáp — armor / Thể / Thổ
- Hỏa Vân Ngọc — talisman / Pháp / Hỏa

Phẩm chất:

- Phàm phẩm
- Tinh phẩm
- Thượng phẩm

## AI tự chọn trang bị

AI đánh giá từ:

- sức mạnh thực sau hệ số tương thích;
- phòng thủ;
- skill effect;
- tốc/tầm/nhịp đánh;
- độ sâu Kiếm/Thể/Pháp;
- path công pháp đang dùng;
- combat skill đã học;
- linh căn/ngũ hành;
- personality/risk/survival;
- giá món đồ;
- spend bias + khoản tiền dự phòng;
- policy tông môn.

Cùng một món có thể có hiệu quả khác nhau trên hai build khác nhau.

## Quyền người chơi

- Auto equipment mặc định.
- Manual equip.
- Lock slot chặn AI.
- Return to auto bằng canonical unlock.
- Unequip về sect storage.

Manual locked slot luôn thắng AI.

## Tiền kín

Mua trang bị là giao dịch nội bộ:

`wallet đệ tử - giá = treasury tông môn + giá`

Tổng tiền simulation không đổi. Manual allocation không phải giao dịch mua bán.

## Tác động thật

P2.6 đã nối vào simulation thật:

- equipment power ảnh hưởng chọn vùng săn;
- equipment power ảnh hưởng real-time combat;
- defense reduction giảm damage nhận;
- move/basic speed, range, ratio thay đổi hành vi đánh thường;
- skill effect thay đổi direct skill damage và DoT tương thích;
- combat victory sinh forge materials;
- rèn tiêu nguyên liệu và tạo deterministic item instance.

## Persistence

Lưu chính xác:

- feature flag;
- forge materials;
- equipment instances;
- forge/event index;
- policy;
- equipped item per disciple;
- canonical locked slots;
- item location + owner;
- float stats qua SaveService v2.

Nested equipment instances được canonical hóa khi load để giữ exact equality (`price` int, stats float, identity/location/owner string ổn định).

## Runtime gate — PASS

Real Godot 4.7.2 cumulative evidence on 2026-10-01:

- P2.6 persistence diagnostic: PASS.
- Forge + autonomous/manual equipment contracts: PASS.
- Equipment combat-stat consequence contracts: PASS.
- Interaction scene smoke: PASS.
- `P2.6 FORGE + EQUIPMENT TYCOON GATE: PASS`.

P2.6 is now **LOCKED / PASS**.

## Deferred

- cường hóa +N;
- large random affix/reroll;
- set bonus;
- forge failure;
- tay nghề luyện khí sư;
- durability/repair;
- auction;
- pet equipment;
- artifact AI;
- multi-workstation crafting queues;
- undefined external money sources/sinks.
