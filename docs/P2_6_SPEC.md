# P2.6 — Luyện Khí, Trang Bị và Kinh tế Trang Bị

## Mục tiêu

P2.6 nối săn quái, kho tông môn, sản xuất, kinh tế nội bộ và chiến đấu thành một vòng tycoon có hậu quả thật:

`Săn -> nguyên liệu -> Luyện Khí Đường -> trang bị -> bán/cấp -> đệ tử mạnh hơn -> săn vùng khó hơn`.

P2.6 không biến game thành hệ micromanagement bắt người chơi mặc từng món cho từng đệ tử. Mặc định đệ tử tự đánh giá và tự mua/nâng cấp trang bị, nhưng người chơi luôn có quyền can thiệp trực tiếp.

## Kiến trúc khóa

- `P25Factory` giữ `equipment_enabled == false`.
- `P26Factory` tạo toàn bộ P2.5 trước rồi mới bật `EquipmentSystem`.
- P2.6 là opt-in; các factory cũ không đổi hành vi.
- Trang bị không tạo class cứng. Kiếm/Thể/Pháp và ngũ hành chỉ thay đổi độ phù hợp/giá trị của món đồ.
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

Rèn tiêu nguyên liệu nhưng vertical slice chưa áp phí tiền bên ngoài. Điều này giữ rõ contract tiền kín; external money sinks chỉ được thêm khi có hệ thống kinh tế ngoài tông môn được định nghĩa rõ.

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

- sức mạnh thô của item;
- phòng thủ;
- hiệu quả skill;
- tốc/tầm/nhịp đánh;
- độ sâu Kiếm/Thể/Pháp đã tích lũy;
- path của công pháp đang dùng;
- các combat skill đã học;
- linh căn/ngũ hành;
- risk/survival bias;
- giá món đồ;
- spend bias và khoản tiền đệ tử muốn giữ lại;
- policy tông môn: balanced / combat / frugal.

AI chỉ mua khi món mới vượt món hiện tại đủ rõ và sau giao dịch vẫn còn khoản dự phòng phù hợp tính cách/chính sách.

## Tiền kín

Mua trang bị là giao dịch nội bộ:

`wallet đệ tử - giá = treasury tông môn + giá`.

Tổng tiền toàn simulation không đổi vì giao dịch này.

Rèn bằng nguyên liệu không tự sinh hoặc tự hủy tiền. Các nguồn/sink tiền bên ngoài phải được định nghĩa riêng nếu thêm về sau.

## Quyền người chơi

P2.6 hỗ trợ đồng thời:

1. **Auto equipment mặc định** — AI tự mua và thay món tốt hơn.
2. **Manual equip** — người chơi lấy một món trong kho/shop và cấp trực tiếp cho đệ tử; không phải giao dịch mua.
3. **Lock slot** — khi khóa, AI tuyệt đối không thay món trong slot đó.
4. **Return to auto** — bỏ khóa để trả quyền tối ưu slot lại cho AI.
5. **Unequip to storage** — thu hồi món về kho.

Manual control thắng auto control, nhưng người chơi không bắt buộc micromanage.

## Tác động gameplay và chiến đấu

Vertical slice đầu tiên nối `combat_power` của trang bị vào hai nơi có hậu quả thật:

- **AI chọn vùng săn:** `DecisionSystem` cộng sức mạnh trang bị vào effective power trước khi tính power-gap penalty. Một đệ tử được trang bị tốt có thể tự chuyển từ vùng an toàn sang vùng khó/lợi nhuận cao hơn.
- **P2.5 encounter:** `SimulationScheduler` chỉ cộng equipment combat power trong lúc resolver chạy rồi khôi phục base combat power chính xác, tránh drift hoặc cộng dồn sai qua nhiều trận.

Như vậy vòng `rèn đồ -> mạnh hơn -> dám săn khó hơn -> có cơ hội lấy nguyên liệu tốt hơn` tồn tại trong simulation, không chỉ trên UI.

Schema item đã chứa các stat dành cho các bước P2.6 tiếp theo như defense reduction, skill effect, move/basic speed, range và basic ratio. Các stat này chưa được coi là runtime-complete cho tới khi gate tương ứng chứng minh chúng thực sự tác động CombatSystem.

## Save/load và deterministic

Phải lưu chính xác:

- feature flag;
- forge materials;
- equipment instances;
- forge index;
- equipment event count;
- policy;
- equipped item per disciple;
- locked slots;
- item location + owner;
- float stats qua SaveService v2 lossless format.

## Gate P2.6

Gate phải chứng minh:

1. P2.5 không bị bật equipment.
2. Win combat sinh nguyên liệu rèn và đưa được về kho.
3. Cùng seed/index/recipe cho cùng kết quả rèn.
4. Rèn tiêu nguyên liệu và tạo item instance.
5. Hai build khác nhau đánh giá cùng item khác nhau.
6. AI mua đúng upgrade có ý nghĩa.
7. Mua đồ bảo toàn tổng tiền.
8. Manual equip hoạt động.
9. Lock slot chặn auto-equip.
10. Return-to-auto cho phép AI tiếp tục nâng đồ.
11. Trang bị thay đổi lựa chọn vùng săn có kiểm soát.
12. Trang bị thay đổi combat outcome có kiểm soát.
13. Save/load giữ toàn bộ P2.6 state.
14. Continuation sau load deterministic.
15. Invariants cũ + EquipmentSystem invariants PASS.
16. Interaction scene chạy headless trên Godot 4.7.2.

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
