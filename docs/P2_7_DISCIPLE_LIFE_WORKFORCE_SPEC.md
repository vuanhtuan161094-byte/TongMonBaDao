# P2.7 — Đời sống Đệ tử, Chuyên môn và Phân công Tông môn

Date: 2026-10-01
Status: DESIGN LOCK CANDIDATE / NOT IMPLEMENTED

## Mục tiêu

P2.7 biến đệ tử từ các tác nhân chủ yếu xoay quanh săn/tu luyện thành **nhân sự tông môn có nghề nghiệp, lịch sống, ưu tiên công việc và quyền tự chủ**.

P2.7 phải giữ nhịp vận hành kiểu Evil Hunter Tycoon:

- đệ tử tự sống và tự xử lý việc thường ngày;
- Tông Chủ quản bằng chính sách, phân công và chuẩn bị;
- Tông Chủ vẫn có thể gọi một đệ tử và ra lệnh trực tiếp;
- micromanagement là quyền chọn, không phải nghĩa vụ.

## Vấn đề của kiến trúc hiện tại

### 1. `role_assignments` đang gộp sai khái niệm

P1.5 hiện có `hunter / logistics / guard`. Đây là vai trò hành vi/đội chiến đấu, không thể tiếp tục dùng chung cho:

- ngoại môn/nội môn/chân truyền/trưởng lão;
- đường chủ/chấp sự;
- luyện khí/luyện đan/trồng trọt/khai khoáng.

P2.7 phải tách authority model.

### 2. Recruitment còn quá mỏng

Candidate hiện chủ yếu có:

- combat power;
- risk/spend/survival bias;
- personality archetype;
- spiritual root ở các phase sau.

Chưa đủ để tạo câu hỏi quản lý kiểu "người này nên giữ lại vì làm gì tốt?".

### 3. GoalSystem hiện chỉ xử lý mục tiêu ngắn hạn

Các goal hiện tại như Recover/Wealth/Glory/Security/Prepare/Growth hữu ích, nhưng chưa có:

- công việc ưu tiên;
- ca làm việc;
- lịch tu luyện;
- mệnh lệnh Tông Chủ;
- công việc phát sinh từ công trình.

### 4. DecisionSystem đang biết quá nhiều action cụ thể

Nếu tiếp tục thêm mỗi nghề như một nhánh hard-code, hệ sẽ phình nhanh. P2.7 cần một lớp `Work/Assignment authority` riêng, còn DecisionSystem chỉ arbitrate giữa nhóm nhu cầu lớn.

## Ba lớp authority bắt buộc phải tách

### A. Địa vị tông môn — `sect_rank`

Vertical slice đầu tiên:

- `outer` — Ngoại môn
- `inner` — Nội môn
- `core` — Chân truyền

Chưa cần ngay Trưởng lão/Đường chủ ở P2.7 vertical slice, nhưng schema phải mở cho:

- `deacon`
- `elder`
- `hall_master`
- `grand_elder`

Tông Chủ là player authority, không phải một role assignment bình thường.

### B. Chuyên môn — `profession_xp`

Không class-lock. Mỗi đệ tử có XP độc lập theo nghề.

P2.7 vertical slice đề xuất 5 nghề nền:

- `forging` — Luyện khí
- `alchemy` — Luyện đan
- `herbalism` — Dược/linh điền
- `mining` — Khai khoáng
- `logistics` — Kho/vận chuyển/hậu cần

Các nghề sau mở tiếp:

- commerce
- medicine
- construction
- formations
- talismans
- administration

Level nghề được derive từ XP, không lưu class cứng.

### C. Vai trò chiến đấu — giữ riêng

P1.5 `hunter / logistics / guard` không được dùng làm nghề hoặc địa vị.

Có hai lựa chọn triển khai:

1. đổi tên storage hiện tại thành `combat_role_assignments`;
2. giữ compatibility field cũ nhưng expose semantic mới qua migration/accessor.

Ưu tiên không phá save cũ.

## Đặc tính cá nhân P2.7

Không copy bộ 6 thuộc tính của 最强祖师 nguyên xi. Game mình đã có personality + root + cultivation nên chỉ thêm các trục còn thiếu và có tác dụng rõ.

Vertical slice đề xuất:

- `comprehension` — Ngộ tính: tăng tốc học chuyên môn và một phần tu hành về sau;
- `constitution` — Căn cốt: liên quan stamina/physical workload, về sau có thể nối luyện thể;
- `fortune` — Cơ duyên: chưa dùng nếu chưa có event system; có thể seed nhưng không active gameplay ở P2.7;
- `charisma` — Mị lực: chưa cần active nếu chưa có recruitment/social jobs.

P2.7 chỉ nên kích hoạt **comprehension** trước để chứng minh sản xuất specialization. Các trục còn lại có thể tồn tại schema nhưng không được tính là complete cho tới khi có consequence.

## Trait / thiên phú nghề

Mỗi đệ tử có thể có 0-N trait nhỏ, ví dụ:

- `forge_talent`
- `alchemy_talent`
- `field_hand`
- `miner_instinct`
- `workaholic`
- `lazy`

Trait không được chỉ là label. Nó phải tác động:

- tốc độ tích XP nghề;
- tốc độ hoàn thành việc;
- chất lượng/yield;
- stamina/mood cost;
- xác suất tự ưu tiên một số việc.

Không tạo rarity màu chỉ để sưu tầm trong P2.7.

## Hệ phân công

### `work_preferences`

Mỗi đệ tử có priority theo nghề/action:

- 0 = cấm làm;
- 1 = thấp;
- 2 = bình thường;
- 3 = cao;
- 4 = ưu tiên tuyệt đối khi đủ điều kiện.

Player có thể set trực tiếp một người.

### `assignment_group`

Để scale lên nhiều người, P2.7 phải có group/template.

Ví dụ:

- `Luyện Khí Đường`
- `Dược Viên`
- `Đội khai khoáng`

Group chứa default priorities. Cá nhân có override riêng.

Đây là phiên bản chuẩn hóa từ ưu điểm "gán chức danh rồi đặt công việc" của The Lost Village, nhưng không đồng nhất group với địa vị tông môn.

## Schedule

P2.7 vertical slice không cần đồng hồ 24h chi tiết, nhưng cần **time budget** theo chu kỳ.

Mỗi chu kỳ dài có quota:

- work budget;
- cultivation budget;
- recovery budget.

Ví dụ policy cân bằng:

- 50% work
- 30% cultivate
- 20% recovery/free

Policy có thể có preset:

- `balanced`
- `production_push`
- `cultivation_focus`

Điểm quan trọng: một đệ tử được phân nghề không được làm nghề 100% vô hạn. Đây là lỗi phải tránh từ The Lost Village.

## Thứ tự ưu tiên hành vi

Authority order đề xuất:

1. **Emergency** — HP/stamina/critical need;
2. **Direct Sect Master command** — lệnh tạm thời có TTL hoặc điều kiện hoàn tất;
3. **Mandatory sect duty** — nhiệm vụ bắt buộc/event;
4. **Schedule block** — work/cultivate/recover;
5. **Personal/group work priority**;
6. **Personal goal/personality**;
7. **Fallback autonomous activity**.

Direct command không xóa personality; nó chỉ override trong thời gian lệnh còn hiệu lực.

## Direct Command — học từ Evil Hunter Tycoon

P2.7 phải có command state chung, thay vì mỗi UI nút viết logic riêng.

Vertical slice commands:

- `WORK_PROFESSION(profession_id)`
- `CULTIVATE`
- `HUNT_REGION(region_id)`
- `RETURN_SECT`
- `REST`
- `HOLD_AT_SECT`

Command có:

- issued_tick;
- expiry/timeout;
- target/completion condition;
- player_locked flag nếu cần.

Sau khi hoàn tất hoặc hết hạn, đệ tử quay về autonomy.

## Work task model

Không hard-code nghề trực tiếp vào DecisionSystem.

Đề xuất `WorkTaskState`:

- id;
- profession_id;
- source_type/source_id;
- required_workers;
- assigned_worker_ids hoặc dynamic eligibility;
- progress;
- duration;
- input materials;
- output materials/item/action;
- priority;
- enabled.

### Vertical slice phải thật nhỏ

P2.7 chỉ cần 2 task thật để chứng minh kiến trúc:

1. **Khai khoáng Thanh Thiết**
   - Mining profession;
   - hoàn thành tạo Thanh Thiết vào kho Luyện Khí;
   - proficiency/talent thay đổi thời gian/yield.

2. **Hỗ trợ Luyện Khí**
   - Forging profession;
   - không thay toàn bộ P2.6 craft thành queue ngay;
   - worker được phân tại Luyện Khí Đường tạo một deterministic production bonus nhỏ cho craft kế tiếp hoặc giảm work-time của order P2.7.

Nếu integration vào P2.6 forge làm complexity tăng quá mạnh, vertical slice có thể dùng một `forge preparation order` riêng nhưng phải ảnh hưởng kết quả/tốc độ rèn thật.

## Progression nghề

Khi hoàn thành work task:

`profession_xp += base_xp * comprehension_modifier * trait_modifier`

Level derive từ XP theo threshold table.

Level nghề ảnh hưởng ít nhất một consequence thật:

- completion time;
- yield;
- quality support;
- material efficiency.

Không dùng một chỉ số `+1% production` duy nhất cho mọi nghề lâu dài; mỗi nghề sau này có thể có consequence riêng.

## Quan hệ với P2.6

P2.6 đã runtime PASS và phải giữ nguyên regression.

P2.7 không được phá:

- autonomous equipment;
- manual equip + lock;
- closed-money purchase;
- combat-stat equipment effects;
- exact persistence;
- deterministic continuation.

P2.7 sẽ làm nguyên liệu P2.6 có thêm **nguồn nội bộ từ lao động**, bên cạnh săn quái.

Vòng mới:

`Săn/khai khoáng -> kho -> luyện khí -> shop/cấp đồ -> đệ tử mạnh hơn -> săn khó hơn`

## Quan hệ với OrganizationSystem

P1.5 team/combat organization vẫn có giá trị.

Refactor mục tiêu:

- `teams` = combat/adventure teams;
- `combat_role_assignments` = hunter/guard/support-like behavior;
- `sect_rank` = địa vị;
- `work_group_id` = nhóm lao động/đường;
- `profession_xp` = kỹ năng nghề.

Không dùng team để mô phỏng một đường sản xuất.

## Recruitment update

P2.7 phải nâng candidate generation để khi tuyển người, player có bài toán lựa chọn thật.

Candidate preview nên có:

- combat potential hiện tại;
- personality;
- spiritual root;
- comprehension;
- 0-2 profession traits;
- có thể 1 flaw/quirk.

Không hiển thị một `overall score` duy nhất vì sẽ giết bài toán quản lý.

Ví dụ:

A: chiến đấu 24, ngộ tính 35, không thiên phú nghề.
B: chiến đấu 15, ngộ tính 82, Luyện Khí kỳ tài.

Player phải có lý do hợp lý để chọn B nếu tông môn thiếu thợ rèn.

## UI/UX requirement

P2.7 phải thiết kế cho 6 người nhưng không khóa ở 6 người.

Danh sách đệ tử cần hỗ trợ về sau:

- filter theo rank;
- filter theo nghề;
- filter theo combat team;
- filter theo idle/working/cultivating/injured;
- sort theo proficiency;
- bulk assign group;
- cảnh báo thiếu người/overworked.

Không cần hoàn thiện production UI ở vertical slice, nhưng state/API phải hỗ trợ bulk actions.

## Anti-patterns bắt buộc tránh

1. Một `role` duy nhất chứa tất cả chức vụ/nghề/combat.
2. Gán nghề khiến đệ tử không bao giờ tu luyện.
3. Nghề không có XP hoặc consequence thật.
4. Candidate chỉ hơn kém nhau ở combat_power.
5. Người chơi phải click từng người để làm việc lặp lại.
6. AI tự ý thay manual direct command.
7. Hệ thống group biến thành class-lock.
8. Thêm hàng chục nghề trước khi 2 nghề đầu có loop thật.

## Gate P2.7 đề xuất

Gate phải chứng minh tối thiểu:

1. P2.6 factory không bật workforce.
2. P2.7 factory bật workforce mà không đổi P2.6 behavior khi feature off.
3. Same seed tạo cùng aptitude/trait/proficiency state.
4. Hai đệ tử khác aptitude hoàn thành cùng nghề với hiệu quả khác nhau.
5. Làm việc tăng profession XP.
6. Profession XP làm thay đổi hiệu quả công việc sau thời gian đủ dài.
7. Work priority thay đổi lựa chọn hành vi.
8. Schedule vẫn dành thời gian cho cultivation/recovery; không có endless work lock.
9. Emergency override work.
10. Direct Tông Chủ command override autonomy tạm thời.
11. Command hoàn tất/hết hạn trả đệ tử về autonomy.
12. Group assignment áp default priority cho nhiều người.
13. Personal override thắng group default.
14. Mining thật sự đưa Thanh Thiết vào forge store.
15. Forging worker thật sự tác động một P2.6 production consequence.
16. Save/load exact equality cho workforce state.
17. Post-load continuation deterministic.
18. P0-P2.6 regression PASS.

## Chưa làm trong P2.7 vertical slice

- trưởng lão/đường chủ có AI quản cấp dưới;
- hệ lương/bổng;
- tranh quyền/chính trị;
- tuổi thọ/tử vong;
- sư đồ;
- hôn nhân/song tu;
- morale toàn tông;
- hàng chục profession;
- full building placement/pathfinding production simulation;
- workforce UI hoàn thiện.

Các hệ trên sẽ dựa vào authority model của P2.7, không được dựng song song.
