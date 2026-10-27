# P3.5 — LIVING SECT CUES / TÔNG MÔN SỐNG TRÊN MAP

Date: 2026-10-04  
Status: REAL PASS / LOCKED ON WINDOWS GODOT 4.7.2

## Runtime implementation status

Implemented on `main`:

- `LivingCueResolver`:
  - pure/read-only state cue derivation;
  - real HP/stamina/retreat/breakthrough/workforce/equipment/lodging/medicine conditions;
  - deterministic primary-cue selection;
  - max 3 visible cues;
- `LivingCueTracker`:
  - presentation-only snapshots;
  - breakthrough/work/heal/return transient events;
  - no serialization/gameplay authority;
- `LivingCueLayer`:
  - world-space cue buttons under the transformed map;
  - follows moving actor targets;
  - cue tap routes only to P3.3/P3.4 contexts;
- live map integration in `p3_2_landscape_sect.gd`;
- dedicated core + map-integration tests and cumulative verifier.

Files:

- `godot/src/presentation/p3/living_cue_resolver.gd`;
- `godot/src/presentation/p3/living_cue_tracker.gd`;
- `godot/src/presentation/p3/living_cue_layer.gd`;
- `godot/tests/presentation/p3_5_living_cue_core_test.gd`;
- `godot/tests/presentation/p3_5_living_cue_map_integration_test.gd`;
- `tools/windows/qa/Verify-P3-5-Living-Cues.cmd`;
- `tools/godot/Verify-P3-5-Living-Cues.ps1`.

P3.5 is **REAL PASS** on Windows Godot 4.7.2: core resolver/tracker, live-map integration and scene smoke are green.

---

## 0. Mục tiêu

P3.5 làm cho người chơi **nhìn map là biết chuyện gì đang xảy ra**, không phải mở từng đệ tử/công trình để kiểm tra.

Trải nghiệm đích:

`simulation thay đổi -> cue ngắn xuất hiện đúng world target -> người chơi nhìn thấy vấn đề/cơ hội -> chạm cue -> focus + mở đúng panel P3.3/P3.4 -> xử lý`.

P3.5 là lớp trình bày/read-only đối với gameplay state.

Không tạo random speech để giả cảm giác sống.  
Không tạo quest/event/cảnh báo mới chỉ để có bubble.  
Không sửa HP, stamina, action, inventory, resource hoặc RNG.

---

# 1. Gate trước khi implement

P3.5 runtime chỉ bắt đầu sau khi:

1. P3.2 live modular female map gate đã green;
2. P3.3 disciple operational flow đã green;
3. P3.4 building management đã implemented + real Godot gate green.

Lý do: cue phải dẫn tới panel/action thật. Không làm notification trước khi nơi xử lý notification tồn tại.

---

# 2. UX principle

## 2.1. Map-first

Cue nằm trực tiếp trên actor/building.

Không dùng:

- notification center che map;
- danh sách toast dài;
- feed log chạy liên tục;
- popup modal tự bật;
- text paragraph trên world.

Mỗi cue chỉ gồm:

- icon/symbol đơn giản;
- 1 nhãn rất ngắn;
- severity;
- target.

Ví dụ:

- `Mệt`;
- `Bị thương`;
- `Đột phá!`;
- `Hết thuốc`;
- `Quá tải`;
- `Thiếu người`;
- `Nguy hiểm!`.

## 2.2. Giới hạn clutter

Ở 1280×720:

- tối đa **3 cue nổi bật đồng thời**;
- một target chỉ có **1 primary cue** tại một thời điểm;
- cue severity cao hơn đè cue thấp hơn;
- không hiển thị 8–12 bubble cùng lúc dù có 8–12 actor.

Nếu nhiều cue cùng severity:

1. critical trước;
2. actionable trước;
3. target đang ở trong viewport trước;
4. disciple/building gần camera center trước;
5. cuối cùng dùng target id ổn định để deterministic.

Không random thứ tự.

---

# 3. Hai loại cue

## 3.1. State cue — còn điều kiện thì còn hợp lệ

Suy ra trực tiếp từ state hiện tại.

Ví dụ:

- HP thấp;
- stamina thấp;
- đủ điều kiện đột phá;
- hết thuốc;
- quá tải chỗ nghỉ;
- không có người trong nhóm công việc.

State cue không cần save/load state mới.

## 3.2. Event cue — “vừa xảy ra”

Là presentation-only observation của thay đổi đã xảy ra trong simulation.

Ví dụ:

- hoàn thành khai khoáng;
- hoàn thành luyện khí;
- đột phá thành công/thất bại;
- trị thương xong;
- đệ tử vừa trở về tông.

Implementation sau này được phép giữ **snapshot/cooldown tạm trong UI** để nhận biết counter/state vừa đổi.

Snapshot này:

- không serialize vào save;
- không ảnh hưởng gameplay;
- không được dùng làm authority;
- reload game chỉ mất animation/bubble cũ, không mất gameplay.

---

# 4. Severity canonical

## S0 — CRITICAL

Cần người chơi chú ý ngay:

- đệ tử ngoài tông ở trạng thái nguy hiểm;
- đột phá thất bại vừa xảy ra nếu gây tổn thất;
- các trạng thái sinh tồn nghiêm trọng về sau.

## S1 — ACTIONABLE

Có quyết định hữu ích ngay:

- bị thương trong tông;
- có thể đột phá;
- Dược Phòng hết thuốc khi thực sự có người cần chữa;
- Đệ Tử Xá quá tải.

## S2 — OPERATIONAL

Ảnh hưởng hiệu quả nhưng chưa khẩn cấp:

- mệt;
- khu làm việc thiếu người;
- Luyện Khí thiếu vật liệu để craft;
- supply stock cạn/thấp khi có nhu cầu.

## S3 — INFO / POSITIVE EVENT

Xác nhận thế giới đang vận hành:

- khai khoáng hoàn thành;
- luyện khí hoàn thành;
- trị thương xong;
- đã về tông;
- đột phá thành công.

S3 không được chiếm slot nếu đang có S0/S1 quan trọng.

---

# 5. Disciple cues — điều kiện thật

## 5.1. `Bị thương`

Điều kiện canonical:

`hp / max_hp < 0.72`.

Đây chính là ngưỡng DecisionSystem hiện dùng để ưu tiên HEAL/REST trong tông.

Target:

- actor đệ tử nếu đang trong tông;
- nếu đang outside flow, xem mục `Nguy hiểm!`.

Severity: **S1**.

Tap:

- focus actor;
- mở P3.3 right summary.

Nếu đồng thời `Mệt`, chỉ hiện `Bị thương`.

## 5.2. `Mệt`

Điều kiện:

`stamina < 42`.

Đây là ngưỡng DecisionSystem/WorkforceSystem hiện dùng để ưu tiên nghỉ và chặn direct workforce action.

Severity: **S2**.

Không hiện nếu đang có:

- Bị thương;
- Nguy hiểm!;
- Đột phá event.

Tap -> disciple summary.

## 5.3. `Có thể đột phá`

Điều kiện:

`CultivationSystem.can_breakthrough(state, disciple) == true`.

Severity: **S1**.

Không tự gọi breakthrough.

Tap:

- focus disciple;
- mở disciple summary;
- summary/deep screen có thể dẫn người chơi tới Thuộc tính.

P3.5 không bổ sung command `BREAKTHROUGH`; đó là gameplay decision riêng nếu sau này user muốn điều khiển trực tiếp.

## 5.4. `Nguy hiểm!` ngoài tông

Áp dụng khi `region_id != "sect"`.

Critical nếu một trong hai đúng:

- `hp / max_hp <= disciple.retreat_hp_ratio()`;
- `stamina <= 22`.

Đây là đúng điều kiện DecisionSystem dùng để buộc quay về.

Severity: **S0**.

Vì outside disciple hiện được trình bày quanh Đại Môn, cue có thể neo vào actor/gate representation hiện hữu; không invent vị trí world-region giả.

Tap:

- focus actor/gate target;
- mở disciple summary để có nút `Về tông`.

---

# 6. Cultivation event cues

## 6.1. `Đột phá thành công!`

Nhận biết presentation-only khi:

- `metrics.breakthrough_successes` tăng so với snapshot trước;
- hoặc stage index tăng và last outcome = success.

Severity: **S3**, nhưng được phép ưu tiên hiển thị ngắn ngay sau event nếu không có S0.

Không tái phát mỗi refresh.

## 6.2. `Đột phá thất bại`

Khi:

- `metrics.breakthrough_failures` tăng;
- `last_breakthrough_outcome == "failure"`.

Severity: **S0** trong khoảng event ngắn vì HP/stamina/progress vừa chịu tổn thất.

Sau event duration, state cue `Bị thương`/`Mệt` tiếp quản nếu điều kiện vẫn còn.

---

# 7. Work-completion cues

Không duplicate công thức sản lượng ở presentation.

## 7.1. `Khai khoáng xong`

Trigger khi:

`metrics.mining_completions` tăng.

Không tự tính/ghi `+1` hay `+2 Thanh Thiết` trong cue, vì số lượng thuộc WorkforceSystem authority.

Nếu muốn hiển thị quantity sau này, phải lấy trực tiếp từ result/event authority chứ không copy công thức production sang UI.

Severity: **S3**.

Target: disciple hoặc Khu Khai Khoáng.

## 7.2. `Luyện khí xong`

Trigger khi:

`metrics.forging_completions` tăng.

Đây là hoàn thành workforce forging/support cycle, không đồng nghĩa `EquipmentSystem.craft()` đã chế tạo item.

Text phải tránh gây hiểu nhầm là đã sinh trang bị.

Severity: **S3**.

## 7.3. Craft item từ P3.4

Nếu người chơi bấm craft và `EquipmentSystem.craft()` trả item thật:

- P3.4 action result có thể phát presentation cue `Đã luyện chế`;
- cue lấy item name từ result thật;
- không tạo event trong simulation chỉ để vẽ bubble.

---

# 8. Recovery cues

## 8.1. `Đã trị thương`

Trigger nếu `metrics.heals` tăng.

Severity: **S3**.

Không cần show mỗi lần REST.

## 8.2. REST

REST xảy ra khá thường xuyên.

Không hiện `Đã nghỉ xong` cho mỗi chu kỳ vì sẽ spam.

Chỉ state cue `Mệt` là đủ.

---

# 9. Building cues

## 9.1. Dược Phòng — `Hết thuốc`

Chỉ hiện khi:

- `medicine_stock <= 0`;
- và tồn tại ít nhất một disciple trong tông có `hp/max_hp < 0.72`.

Không cảnh báo đỏ chỉ vì kho thuốc bằng 0 nếu không ai cần chữa.

Severity: **S1**.

Tap -> P3.4 Dược Phòng panel.

## 9.2. Đệ Tử Xá — `Quá tải`

Điều kiện:

`state.disciples.size() > lodging_capacity`.

Severity: **S1**.

Tap -> panel Đệ Tử Xá với action mở rộng thật.

## 9.3. Khai Khoáng — `Thiếu người`

Điều kiện:

- workforce enabled;
- không có disciple nào có `work_group_id == "mining_crew"`.

Không dùng “hiện tại không ai WORK_MINING” vì lịch tự trị có thể đang ở phase khác; thành viên đội vẫn tồn tại.

Severity: **S2**.

Tap -> panel Khai Khoáng, danh sách phân người.

## 9.4. Luyện Khí Đường — `Thiếu người`

Tương tự:

- workforce enabled;
- không có disciple thuộc `forge_hall`.

Severity: **S2**.

## 9.5. Luyện Khí Đường — `Thiếu vật liệu`

Điều kiện baseline:

- equipment enabled;
- không có recipe nào mà `EquipmentSystem.can_craft()` trả true.

Severity: **S2**.

Nếu cùng lúc `Thiếu người`, ưu tiên cue nào trực tiếp hơn theo context:

- không người -> `Thiếu người`;
- có người nhưng không recipe craftable -> `Thiếu vật liệu`.

## 9.6. Tu Luyện Đài — `Có người đột phá`

Nếu có ít nhất một disciple mà `can_breakthrough()` true.

Building cue chỉ hiện nếu individual disciple cue đó không nằm trong top visible set hoặc actor khó nhìn.

Không duplicate cả actor và building cùng một việc trong 3 slot.

Severity: **S1**.

## 9.7. Đại Môn — `Có người gặp nguy`

Nếu có outside disciple thỏa S0 `Nguy hiểm!`.

Nếu actor cue đang visible thì không cần cue gate duplicate.

Nếu nhiều outside disciple nguy hiểm, gate bubble được phép gộp:

`2 người gặp nguy`.

Số lượng phải tính trực tiếp từ state hiện tại.

Severity: **S0**.

## 9.8. Kho

P3.5 baseline **không cảnh báo kho đầy** vì simulation không có warehouse capacity.

Không invent cue `Kho đầy`.

## 9.9. Đại Điện

P3.5 baseline không tạo cue policy “chưa tối ưu” vì đó là đánh giá chủ quan, không phải invariant/game condition thật.

---

# 10. Cue selection / anti-spam

Mỗi refresh:

1. Resolver đọc state và tạo candidate list.
2. Loại cue duplicate semantic.
3. Với mỗi target, giữ cue severity cao nhất.
4. Sort deterministic.
5. Chọn tối đa 3.
6. Event cue có lifetime presentation-only.
7. State cue biến mất khi điều kiện hết.

## Re-trigger rule

Cùng một state cue không “nhảy lại” mỗi tick.

Presentation cache lưu:

- cue key;
- target key;
- active/inactive;
- last shown time.

Chỉ re-trigger animation khi:

- condition false rồi true lại;
- severity tăng;
- target được người chơi focus/tap.

Cache này không save.

---

# 11. Lifetime / motion

Target behavior để tránh nhấp nháy:

- state cue: tồn tại khi condition true, nhưng animation entrance chỉ chạy một lần;
- event cue: khoảng 2.0–3.5 giây;
- critical event có thể 4 giây;
- không loop bounce liên tục;
- không che mặt/actor;
- bubble bám world point của actor/building và scale phù hợp map zoom;
- text/icon vẫn readable ở zoom 0.75.

Nếu map zoom quá nhỏ, ưu tiên icon + severity marker; text có thể hiện khi focus/tap.

---

# 12. Interaction

Tap cue không trực tiếp thực hiện hành động nguy hiểm.

### Disciple cue

`tap -> focus target -> mở P3.3 right summary`.

Từ đó người chơi mới chọn:

- nghỉ;
- về tông;
- tu luyện;
- xem chi tiết;
- các lệnh thật khác.

### Building cue

`tap -> focus building -> mở P3.4 operation panel`.

Ví dụ:

- Hết thuốc -> Dược Phòng;
- Quá tải -> Đệ Tử Xá;
- Thiếu người -> Mine/Forge.

Cue là **điểm dẫn tới quyết định**, không phải auto-fix.

---

# 13. Implementation architecture target

Không implement bây giờ, nhưng architecture khóa trước để tránh nhét logic vào scene script.

## `LivingCueResolver`

Pure/read-only helper.

Input:

- `SimulationState`;
- systems cần để query: cultivation/equipment/workforce.

Output candidate dictionaries/value objects:

- `cue_id`;
- `target_kind` = disciple/building;
- `target_id`;
- `severity`;
- `text`;
- `reason`;
- `action_route`.

Không mutate state.

## `LivingCueTracker`

Presentation-only transient observer:

- snapshot metrics;
- snapshot region/action/stage transitions;
- phát hiện event cue;
- cooldown/dedupe;
- không serialize.

## `LivingCueLayer`

World rendering/input:

- tối đa 3 visible;
- bám actor/building;
- tap routing sang P3.3/P3.4;
- map zoom/pan compatible.

Không gắn simulation logic trực tiếp vào bubble node.

---

# 14. Contract tests

Dedicated P3.5 tests phải chứng minh:

1. resolver không mutate SimulationState;
2. HP < 72% -> Bị thương;
3. stamina < 42 -> Mệt;
4. Bị thương đè Mệt trên cùng target;
5. `can_breakthrough()` -> actionable cue;
6. outside personal retreat threshold / stamina <=22 -> critical cue;
7. medicine 0 **không** alert nếu không ai cần heal;
8. medicine 0 + injured disciple -> Dược Phòng alert;
9. overcapacity -> Residence alert;
10. mining/forge group empty -> correct `Thiếu người`;
11. no craftable recipe -> Forge material cue;
12. work metric delta produces one transient completion cue, không spam lại;
13. breakthrough metric delta produces correct success/failure event;
14. max visible cue count = 3;
15. ordering deterministic;
16. hidden Bloodline/Physique/trait không được dùng để tạo cue tiết lộ latent identity;
17. cue tap routes to real P3.3/P3.4 context;
18. pan/zoom không làm cue lệch khỏi target;
19. existing P3.3/P3.4 gates remain green.

---

# 15. Những gì P3.5 KHÔNG làm

- random NPC speech;
- relationship gossip bubble;
- story event generator;
- quest generator;
- fake emotion;
- fake building failure;
- fake production timers;
- auto-heal/auto-assign on cue tap;
- hidden identity leak;
- notification feed dài;
- persistent saved notification state;
- art polish làm blocker.

Các social/story bubble có thể là phase riêng sau khi gameplay management đã đủ mạnh.

---

# 16. Definition of success

P3.5 thành công khi người chơi nhìn map vài giây và trả lời được:

- ai đang gặp vấn đề;
- vấn đề gì cần xử lý trước;
- công trình nào thiếu nguồn lực/người;
- ai có cơ hội đột phá;
- vừa có hoạt động đáng chú ý nào xảy ra;

và chạm đúng cue là đi thẳng tới **nơi có action thật** để xử lý.

Không đánh giá P3.5 bằng số lượng bubble hoặc animation đẹp.
