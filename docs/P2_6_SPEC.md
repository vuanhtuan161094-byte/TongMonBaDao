# P2.6 — Luyện Khí, Trang Bị và Kinh tế Trang Bị

## Mục tiêu

P2.6 nối săn quái, kho tông môn, sản xuất, kinh tế nội bộ và chiến đấu thành một vòng tycoon có hậu quả thật:

`Săn -> nguyên liệu -> Luyện Khí Đường -> trang bị -> bán/cấp -> đệ tử mạnh hơn -> săn vùng khó hơn`.

P2.6 không biến game thành hệ micromanagement bắt người chơi mặc từng món cho từng đệ tử. Mặc định đệ tử tự đánh giá và tự mua/nâng cấp trang bị, nhưng người chơi luôn có quyền can thiệp trực tiếp.

## Kiến trúc khóa

- `P25Factory` giữ `equipment_enabled == false`.
- `P26Factory` tạo toàn bộ P2.5 trước rồi mới bật `EquipmentSystem`.
- P2.6 là opt-in; các factory cũ không đổi hành vi khi feature tắt.
- Trang bị không tạo class cứng. Kiếm/Thể/Pháp và ngũ hành thay đổi độ phù hợp và hiệu quả, không khóa quyền sử dụng.
- Mỗi món là một instance riêng có ID ổn định, phẩm chất, slot, recipe, hướng tu, nguyên tố, stats, giá, vị trí và owner.
- Phẩm chất rèn được xác định deterministic từ seed + forge index + recipe; không dùng thời gian hệ thống.

## Nguyên liệu và rèn

Vertical slice có bốn nguyên liệu Luyện Khí:

- Linh Mộc;
- Thanh Thiết;
- Tinh Lang Bì;
- Yêu Đan.

Nguồn đầu tiên:

- Trúc Thử -> Linh Mộc;
- Thanh Lang -> Thanh Thiết + Tinh Lang Bì;
- Hắc Lang -> nhiều Thanh Thiết + Tinh Lang Bì + Yêu Đan.

Đệ tử thắng combat mang nguyên liệu về như loot. Khi trở lại tông môn, nguyên liệu P2.6 được chuyển vào kho Luyện Khí trước khi hàng thường được bán.

Rèn tiêu nguyên liệu nhưng vertical slice chưa áp phí tiền bên ngoài. External money sinks chỉ được thêm khi có hệ thống kinh tế ngoài tông môn được định nghĩa rõ.

Phẩm chất ban đầu:

- Phàm phẩm;
- Tinh phẩm;
- Thượng phẩm.

## Công thức vertical slice

- Thanh Thiết Kiếm — weapon / Kiếm / Kim;
- Huyền Thiết Quyền Sáo — weapon / Thể / Thổ;
- Linh Mộc Pháp Trượng — weapon / Pháp / Mộc;
- Tinh Lang Giáp — armor / thiên Thể / Thổ;
- Hỏa Vân Ngọc — talisman / thiên Pháp / Hỏa.

Đây là vertical slice kiến trúc, không phải danh sách trang bị cuối game.

## AI tự chọn trang bị

Mỗi đệ tử chấm cùng một món khác nhau. Điểm đánh giá dùng:

- sức mạnh thực của item sau hệ số tương thích;
- phòng thủ;
- hiệu quả combat skill;
- tốc/tầm/nhịp đánh;
- độ sâu Kiếm/Thể/Pháp đã tích lũy;
- path của công pháp đang dùng;
- combat skill đã học;
- linh căn/ngũ hành;
- risk/survival bias;
- giá món đồ;
- spend bias và khoản tiền đệ tử muốn giữ lại;
- policy tông môn: balanced / combat / frugal.

Cùng một món có hiệu quả combat khác nhau trên hai đệ tử khác build. AI chỉ mua khi món mới vượt món hiện tại đủ rõ và sau giao dịch vẫn còn khoản dự phòng phù hợp tính cách/chính sách.

## Tiền kín

Mua trang bị là giao dịch nội bộ:

`wallet đệ tử - giá = treasury tông môn + giá`.

Tổng tiền toàn simulation không đổi vì giao dịch này.

Manual allocation không phải mua bán. Rèn bằng nguyên liệu không tự sinh hoặc tự hủy tiền.

## Quyền người chơi

P2.6 hỗ trợ đồng thời:

1. **Auto equipment mặc định** — AI tự mua và thay món tốt hơn.
2. **Manual equip** — người chơi lấy một món trong kho/shop và cấp trực tiếp cho đệ tử.
3. **Lock slot** — khi khóa, AI tuyệt đối không thay món trong slot đó.
4. **Return to auto** — bỏ khóa bằng cách xóa canonical lock entry, trả quyền tối ưu lại cho AI.
5. **Unequip to storage** — thu hồi món về kho.

Manual control thắng auto control, nhưng người chơi không bắt buộc micromanage.

## Tác động gameplay và chiến đấu

P2.6 đã nối các nhóm chỉ số vertical slice vào simulation thật:

- **Combat power:** cộng theo độ phù hợp path/linh căn/skill/công pháp; ảnh hưởng cả chọn vùng săn và encounter P2.5.
- **Defense reduction:** giảm damage quái gây ra trong real-time resolver.
- **Move/basic speed, basic range, basic ratio:** sửa trực tiếp combat style dùng bởi P2.5, nên thay đổi khoảng cách, nhịp và hiệu quả đánh thường.
- **Skill effect:** nhân hiệu quả combat skill theo path/ngũ hành phù hợp, gồm direct hit và hiệu ứng damage theo thời gian như burn.

`SimulationScheduler` chỉ cộng equipment combat power vào `disciple.combat_power` trong lúc resolver chạy rồi khôi phục base power chính xác, tránh drift hoặc cộng dồn sai qua nhiều trận.

`DecisionSystem` cũng cộng equipment power vào effective power trước khi tính power-gap penalty, nên một đệ tử được trang bị tốt có thể tự chuyển sang vùng khó/lợi nhuận cao hơn.

Như vậy vòng `rèn đồ -> mạnh hơn -> dám săn khó hơn -> lấy nguyên liệu tốt hơn` tồn tại trong simulation, không chỉ trên UI.

## Save/load và deterministic

Phải lưu chính xác:

- feature flag;
- forge materials;
- equipment instances;
- forge index;
- equipment event count;
- policy;
- equipped item per disciple;
- canonical locked slots;
- item location + owner;
- float stats qua SaveService v2 lossless format.

## Gate P2.6

Gate phải chứng minh:

1. P2.5 không bị bật equipment.
2. Win combat sinh nguyên liệu rèn và đưa được về kho.
3. Cùng seed/index/recipe cho cùng kết quả rèn.
4. Rèn tiêu nguyên liệu và tạo item instance.
5. Hai build khác nhau đánh giá và nhận hiệu quả khác nhau từ cùng loại gear.
6. AI mua đúng upgrade có ý nghĩa.
7. Mua đồ bảo toàn tổng tiền.
8. Manual equip hoạt động.
9. Lock slot chặn auto-equip.
10. Return-to-auto cho phép AI tiếp tục nâng đồ và không để false lock entry gây lệch save/load.
11. Trang bị thay đổi lựa chọn vùng săn có kiểm soát.
12. Combat power trang bị thay đổi combat outcome có kiểm soát.
13. Armor `defense_reduction` giảm damage thật trong P2.5 resolver.
14. `skill_effect` tăng damage skill thật.
15. `basic_speed/basic_range` thay đổi hành vi đánh thường thật.
16. Save/load giữ toàn bộ P2.6 state chính xác.
17. Continuation sau load deterministic.
18. Invariants cũ + EquipmentSystem invariants PASS.
19. Interaction scene chạy headless trên Godot 4.7.2.

Các contract combat phụ được tách riêng trong `p2_6_equipment_combat_effects_test.gd` để lỗi stat wiring không bị lẫn với lỗi kinh tế/save-load.

## Chưa đưa vào vertical slice

- cường hóa +N;
- tẩy/random affix phức tạp;
- set bonus;
- thất bại khi rèn;
- tay nghề Luyện Khí Sư;
- durability/sửa đồ;
- đấu giá;
- trang bị pet;
- pháp bảo có AI riêng;
- hệ crafting queue nhiều workstation;
- nguồn/sink tiền bên ngoài chưa được định nghĩa.

Các phần này chỉ mở sau khi vòng `hunt -> forge -> sell/equip -> combat` runtime PASS.

## Trạng thái

`IMPLEMENTED / AWAITING RUNTIME GATE`.

Authoritative local command: `Sync-P2-6.cmd`.

Cumulative runtime hiện vẫn phải vượt blocker P2.1 persistence trước khi có thể đi tới P2.6 gate.
