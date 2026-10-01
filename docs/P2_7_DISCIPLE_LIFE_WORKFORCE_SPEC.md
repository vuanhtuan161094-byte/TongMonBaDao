# P2.7 — Đời sống Đệ tử, Chuyên môn và Phân công Tông môn

Date: 2026-10-01
Status: IMPLEMENTED / AWAITING RUNTIME GATE

## Mục tiêu

P2.7 biến đệ tử từ các tác nhân chủ yếu xoay quanh săn/tu luyện thành **nhân sự tông môn có nghề nghiệp, lịch sống, ưu tiên công việc và quyền tự chủ**.

P2.7 phải giữ nhịp vận hành kiểu Evil Hunter Tycoon:

- đệ tử tự sống và tự xử lý việc thường ngày;
- Tông Chủ quản bằng chính sách, phân công và chuẩn bị;
- Tông Chủ vẫn có thể gọi một đệ tử và ra lệnh trực tiếp;
- micromanagement là quyền chọn, không phải nghĩa vụ.

## Kiến trúc đã triển khai

P2.7 hiện đã có `WorkforceSystem`, `P27Factory`, workforce state trong `DiscipleState`/`SectState`, integration vào `SimulationScheduler`, recruitment aptitude, persistence diagnostic, simulation contract test và interaction scene.

P2.6 vẫn là baseline khóa: `P26Factory` không bật workforce. Chỉ `P27Factory` mới gọi `WorkforceSystem.initialize()`.

## Ba lớp authority bắt buộc phải tách

### A. Địa vị tông môn — `sect_rank`

Vertical slice đầu tiên dùng `outer` làm mặc định. Schema mở cho `inner`, `core`, `deacon`, `elder`, `hall_master`, `grand_elder`, nhưng P2.7 **không tính rank là gameplay hoàn chỉnh** vì chưa có consequence riêng.

Tông Chủ là player authority, không phải một role assignment bình thường.

### B. Chuyên môn — `profession_xp`

Không class-lock. Mỗi đệ tử có XP độc lập theo nghề.

Schema có:

- `forging` — Luyện khí
- `alchemy` — Luyện đan
- `herbalism` — Dược/linh điền
- `mining` — Khai khoáng
- `logistics` — Kho/vận chuyển/hậu cần

Vertical slice chỉ kích hoạt gameplay thật cho **mining** và **forging**. Các nghề còn lại chưa được tính là hoàn thành.

Level nghề derive từ XP, không lưu class cứng.

### C. Vai trò chiến đấu — giữ riêng

P1.5 `hunter / logistics / guard` tiếp tục là vai trò tổ chức/chiến đấu cũ. P2.7 không dùng trường đó để chứa rank hoặc profession.

Một đệ tử có thể đồng thời là:

`Ngoại môn + Luyện Khí level 3 + thành viên đội săn`.

## Đặc tính cá nhân P2.7

Vertical slice kích hoạt **comprehension / Ngộ tính** làm aptitude học nghề thật.

Các trục như constitution, fortune, charisma chưa được thêm vào runtime vì chưa có consequence đủ rõ. Không thêm stat chỉ để trang trí.

## Trait / thiên phú nghề

P2.7 có các trait nhỏ có hậu quả thật:

- `forge_talent`;
- `miner_instinct`;
- `diligent`;
- `lazy`.

Trait tác động work speed và/hoặc learning multiplier. Không có rarity màu/gacha tổng lực.

## Hệ phân công

### `work_preferences`

Mỗi đệ tử có priority theo nghề:

- 0 = cấm làm;
- 1 = thấp;
- 2 = bình thường;
- 3 = cao;
- 4 = ưu tiên cao nhất.

### `work_group_id` + `work_groups`

Vertical slice có hai nhóm:

- `mining_crew` — Đội Khai Khoáng;
- `forge_hall` — Luyện Khí Đường.

Group cung cấp default priorities. Personal `work_preferences` override group default.

## Schedule

P2.7 dùng chu kỳ 20 tick, có ba pha:

- work;
- cultivate;
- recovery.

Policy:

- `balanced`;
- `production_push`;
- `cultivation_focus`.

Điểm khóa: phân nghề không được khiến đệ tử làm việc vô hạn. Lịch luôn có cửa cho cultivation/recovery.

## Thứ tự ưu tiên hành vi

Authority order đang triển khai:

1. **Emergency** — HP/stamina thấp trả quyền cho survival logic hiện có;
2. **Direct Sect Master command**;
3. **Schedule block**;
4. **Personal/group work priority**;
5. **Goal/personality + fallback autonomy** qua DecisionSystem cũ.

Mandatory event duty chưa có trong vertical slice.

## Direct Command — học từ Evil Hunter Tycoon

Runtime command state nằm trên từng `DiscipleState`, gồm kind, target, issued tick và expiry tick.

Vertical slice hỗ trợ:

- `WORK_PROFESSION`;
- `CULTIVATE`;
- `HUNT_REGION`;
- `RETURN_SECT`;
- `REST`;
- `HOLD_AT_SECT`.

Command tạm thời override autonomy. Work command tự clear khi hoàn tất một work completion; cultivate/rest/hunt/return clear theo completion tương ứng; command cũng có TTL.

## Hai công việc thật của vertical slice

### 1. Khai khoáng Thanh Thiết

- profession: mining;
- work progress phụ thuộc profession level, comprehension và trait;
- completion tăng mining XP;
- completion đưa **Thanh Thiết thật** vào `sect.forge_materials` của P2.6;
- miner level cao có thể tạo yield cao hơn.

### 2. Hỗ trợ Luyện Khí

- profession: forging;
- completion tăng forging XP;
- completion tạo `forge_support_points`;
- P2.6 `EquipmentSystem.craft()` chỉ khi workforce bật mới tiêu 1 support point;
- support point làm stat multiplier của món rèn kế tiếp tăng 5%;
- khi workforce tắt, P2.6 craft giữ nguyên hành vi đã khóa.

## Progression nghề

Khi hoàn thành work task:

`profession_xp += base_xp * comprehension_modifier * trait_modifier`

Profession level ảnh hưởng work speed và ở mining còn ảnh hưởng yield. Đây là consequence thật, không phải nhãn UI.

## Recruitment update

Candidate P2.7 có thêm:

- comprehension;
- 0-2 profession traits deterministic.

Candidate conversion giữ các thông tin này khi trở thành Disciple. Không có overall score duy nhất.

## Quan hệ với P2.6

P2.6 đã runtime PASS và phải giữ nguyên regression.

P2.7 không được phá:

- autonomous equipment;
- manual equip + lock;
- closed-money purchase;
- combat-stat equipment effects;
- exact persistence;
- deterministic continuation.

Vòng mở rộng:

`Săn/khai khoáng -> kho -> luyện khí -> shop/cấp đồ -> đệ tử mạnh hơn -> săn khó hơn`.

## Save/load và deterministic

Persistence hiện bao gồm:

- workforce feature flag/policy/groups;
- forge support points/event count;
- comprehension;
- sect rank schema;
- profession XP;
- profession traits;
- personal work preferences;
- work group;
- direct command;
- work progress.

Nested integer fields được canonical hóa sau JSON; float dùng SaveService v2 lossless encoding.

## Verification assets

- `godot/src/simulation/workforce/workforce_system.gd`
- `godot/src/simulation/core/p2_7_factory.gd`
- `godot/tests/simulation/p2_7_persistence_diagnostic.gd`
- `godot/tests/simulation/p2_7_workforce_test.gd`
- `godot/src/presentation/p2_7_workforce.gd`
- `godot/scenes/p2/p2_7_workforce.tscn`
- `tools/godot/Verify-P2-7.ps1`
- `Verify-P2-7.cmd`
- `Sync-P2-7.cmd`

## Gate P2.7

Gate phải chứng minh tối thiểu:

1. P2.6 factory không bật workforce.
2. P2.7 factory bật workforce mà không đổi P2.6 behavior khi feature off.
3. Same seed tạo cùng aptitude/trait/work-group state.
4. Miner kinh nghiệm cao outperform miner mới trong cùng số work action.
5. Mining tạo Thanh Thiết thật vào P2.6 forge store.
6. Làm việc tăng profession XP.
7. Balanced schedule có work/cultivate/recovery.
8. Cultivation/recovery có thể interrupt routine work theo schedule.
9. Direct Tông Chủ command override work preference.
10. Command hoàn tất trả đệ tử về autonomy.
11. Group assignment cung cấp default priority; personal priority override được.
12. Forging worker tạo support làm thay đổi stat món P2.6 craft thật.
13. Recruitment candidate có non-combat aptitude deterministic.
14. Save/load exact equality cho workforce state.
15. Post-load continuation deterministic.
16. Invariants cũ + workforce invariants PASS.
17. P0-P2.6 cumulative regression PASS.
18. Interaction scene chạy headless Godot 4.7.2.

## Chưa làm trong P2.7 vertical slice

- trưởng lão/đường chủ có AI quản cấp dưới;
- hệ lương/bổng/trung thành;
- tranh quyền/chính trị;
- tuổi thọ/tử vong;
- sư đồ;
- hôn nhân/song tu;
- morale toàn tông;
- active gameplay cho alchemy/herbalism/logistics;
- full building placement/pathfinding production simulation;
- workforce UI production hoàn chỉnh.

Các hệ trên phải dựa vào authority model P2.7, không dựng song song.
