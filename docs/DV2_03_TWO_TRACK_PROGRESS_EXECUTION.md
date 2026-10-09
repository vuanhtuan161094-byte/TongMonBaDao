# DV2-03 — Hai tiến độ Tu Vi và Luyện Thể V2 trên đệ tử THẬT

Ngày: 2026-10-09
Giai đoạn: **DV2-03 ACTIVE — mã lõi/hoạt động theo tick đã PASS focused Linux Godot 4.7.2; production realtime/UI/balance và cumulative trên SHA code mới nhất vẫn chưa đóng.**

## Bằng chứng mới nhất, 09/10/2026 — nguồn kiểm tra trên live main

**Mã runtime code mới nhất được kiểm thử focused:** `e96df1832036c1232f9d0db69d1f37450d0265f9`; [DV2-03 Actions #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), **completed/success**. Các bước: cài binary Godot **4.7.2 Linux**, parse cả project, chạy `dv2_03_realm_body_progress_test.gd` và `dv2_03_training_actions_test.gd`, **đều success**. Điều này chứng minh test trên engine thật của runner CI, **không phải máy Windows của người chơi**, không tự động chứng minh UI/gameplay ngoài bản đồ.

**FULL P3.7 cumulative gần nhất có chứng cứ:** [Actions #37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại mã `5296f6106a2fd43d5c1a6f2523854702e9014d63`, **completed/success** (fast + full cumulative). Chạy trước các commit thêm lệnh người chơi `aa3122a`, bài test lệnh `e96df183`. **Chưa có full cumulative PASS ở cùng code SHA `e96df183`**. Những commit tài liệu được push sau mã này không có bằng chứng tự động CI trên chính commit docs.

| Phạm vi | Trạng thái triển khai, không suy rộng |
|---|---|
| 30 cảnh giới × 10 tầng **cho từng đường** và tên 60 đại cảnh | **ĐÃ CODE + FOCUSED PASS**; lưu profile riêng `cultivation`/`body` trên đệ tử V2 hợp lệ |
| Nhận EXP và tăng tầng nhỏ | **ĐÃ CODE + FOCUSED PASS** khi có `floor_costs` và `base_xp_per_action` được khai báo; không tự chốt bảng EXP |
| Đột phá đại cảnh Tu Vi | **ĐÃ CODE + FOCUSED PASS ở hàm** với chi phí, xác suất, điều kiện truyền hợp lệ; không phải nút đột phá hay lịch auto thật |
| Đột phá đại cảnh Luyện Thể | **CHỈ CÓ hàm commit khi caller đã xác nhận điều kiện**; tỷ lệ/vật liệu/cách thử production **CHƯA TRIỂN KHAI** |
| Tick hành động `CULTIVATE`/`TRAIN_BODY` | **ĐÃ CODE + FOCUSED PASS** qua `SimulationScheduler.step()`; V2 riêng, opt-in; nguồn `CultivationSystem` P2 không được dùng thay V2 |
| Lệnh `request_training` | **ĐÃ CODE + FOCUSED PASS dưới dạng API một lần**; từ chối chen ngang combat; **chưa nối nút UI P3.2 V2** |
| Chống EXP trùng hai nhánh trong 1 tick | **ĐÃ CODE + FOCUSED PASS**: `last_training_tick` chung ở V2 profile + `last_training_event_id` theo track, kiểm tra owner/action |
| Lưu/tải EXP, tầng, policy, event và lịch sử | **ĐÃ CODE + FOCUSED PASS** trên `DiscipleState`/`SectState`, test JSON round-trip |
| Tính lại 16 chỉ số + 10 kháng sau tiến độ | **ĐÃ CODE + FOCUSED PASS** ở `derive_stats`/Hunting V2 proving adapter; **live HP P2 và màn nhân vật chính chưa di trú toàn bộ** |
| Thời gian thực 15s ngoài game, offline catch-up, AI tự tập luyện | **CHƯA XÁC NHẬN chạy end-to-end**. Scheduler test chạy tick bằng lệnh, không đo 15 giây đồng hồ thật; sandbox cũ còn timer riêng |
| EXP chuẩn 2×300, 29 tỷ lệ nền Tu Vi, vật liệu và điều kiện Luyện Thể | **CHƯA CÓ production balance được duyệt**; các số `80/50/100` trong test là fixture |
| Windows Godot 4.7.2 cho DV2-03 và chấp nhận UI trực quan | **CHƯA KIỂM THỬ/chưa có bằng chứng** |

**Vấn đề kỹ thuật cần giải quyết:** `request_training` chỉ kiểm tra `authority_id` và loại action trước khi xếp hàng; tính hợp lệ **toàn bộ** tốc độ/cost/sources được kiểm tra khi tick thực hiện. Vì vậy lệnh có thể xếp hàng thành công nhưng tick trả từ chối, **không cộng EXP**. Sự kiện V2 một action/tick là cam kết đã test; đây không phải lịch tự tu luyện liên tục hoặc thực hiện đột phá tự động. Demo P0 `p0_sandbox.gd` gọi `SimulationScheduler.step()` theo khoảng **0,18 giây mô phỏng demo**; tuyệt đối không dùng kết quả đó làm chứng cứ nhịp wall-clock 15s của game V2.


## Authority and user-approved order

1. DV2-02 core group PvE / Combat Stats V2 **CLOSED AS CORE ONLY**.
2. **DV2-03 current:** Tu Vi and Luyện Thể two independent permanent 30×10 progression tracks.
3. Next: all real equipment/skill/innate buffs attach to authored channels.
4. Last: live region map PvE, real monster AI/spawn/balance after the complete character is available.

No new maps, new species or speculative XP/chance/reward data in DV2-03.

## Canonical persistence and prerequisites

- `DiscipleState.v2_realm_progress`, introduced only for genuinely recruited **complete V2 birth profiles**. Legacy P0–P3.7 disciples have **empty** profiles by default and retain their P2 `cultivation_stage_index`, `combat_power`, HP and stamina.
- Independent persistent `cultivation` and `body` rows: `realm` 1–30; `floor` 1–10; `xp` nonnegative; `gate_failures`, `lifetime_failures`, `auto_breakthrough` policy, `breakthrough_history`.
- Both tracks are serialized through `DiscipleState.to_dict/from_dict` with JSON integer normalization; do not reroll birth data or infer V2 starting realm from P2 stage.
- `DiscipleRealmProgressV2.initialize` requires `DiscipleBirthProfileV2.valid_complete_birth`; it is a one-time operation and requires explicit starting coordinates (no random starting-grade guess).

## Progress law — true owner

- Global coordinate `(realm−1)×10 + floor` each track 1..300. **All 30 Tu Vi and 30 Luyện Thể realm names come verbatim from `docs/REALM_LADDER_V2_SPEC.md`.** `DiscipleRealmProgressV2.realm_name` and `current` expose the current label from the saved coordinate; Độ Kiếp and Thần Kiếp are gate events, not additional realms.
- `grant_xp(disciple, track, base_amount, gain_type, floor_costs, sources=[])`: requires **authored positive costs** for the current realm/floors, no fabricated universal 300-floor XP curve.
- Within one major realm, EXP automatically cascades across minor floors. At floor 10 EXP caps at the approved gate requirement. Surplus is **reported as unapplied overflow**; never silently converted to `Tích Tu`.
- `natural`: Tư Chất contributes +0.25% per point to Tu Vi, Căn Cốt +0.20% per point to Luyện Thể; active confirmed same-channel percentage source bonuses add on the base. Rejected: duplicate source ID, unknown channel, unhandled scope/condition/filter, nonfinite value. Dormant `enabled=false` is inert.
- `fixed`: stated flat EXP is given exactly, without those percentage bonuses.
- `set_auto_breakthrough`: stores player policy; **does not secretly schedule a roll**, consume medicine or bypass gate requirements. Scheduler consumer deferred until actual cost/chance/tick authority exists.
- No generic HP/Stamina expense on Tu Vi breakthrough, and Luyện Thể EXP does not auto-advance Tu Vi.

## DV2-03B — Hành động thực trên nhịp mô phỏng 15 giây (09/10/2026)

**Đã triển khai & tập trung kiểm thử, chưa khóa bảng cân bằng EXP:**

- `SectState.v2_training_enabled` mặc định **false**; `v2_training_rules` mặc định **rỗng**. Cả hai chỉ được lưu khi thực sự cấu hình. P0–P3.7 vẫn hoạt động như trước.
- `DiscipleTrainingActionV2.resolve` được gọi bởi **SimulationScheduler.step** trong hành động `CULTIVATE` hoặc `TRAIN_BODY`. Trường hợp đệ tử có hồ sơ sinh V2 đầy đủ nhưng chưa khởi tạo tiến độ không nhận lại Tu Vi P2. Mỗi action thực hiện trong **một tick chuẩn của bộ mô phỏng**, không có timer/nguồn EXP thứ hai.
- Mỗi đường đòi `authority_id` riêng, đúng tên hành động, `base_xp_per_action` dương và `floor_costs` có đủ các tầng từ hiện tại đến tầng 10 của đại cảnh đang ở. Đây là **dữ liệu được cung cấp tường minh**, KHÔNG phải bảng 300 tầng/tốc độ do assistant tự cân. Thiếu một yêu cầu → từ chối nguyên hành động, **không cấp phần thưởng một phần**.
- Sau hành động hợp lệ, XP được tính bằng `DiscipleRealmProgressV2.grant_xp`: Tư Chất/Căn Cốt + những nguồn cùng channel đã kích hoạt thật; tăng tầng nhỏ tự động, dừng ở cửa đại cảnh; EXP vượt cửa **không được tự vào Tích Tu**.
- Quyền hoạt động kiểm tra đối tượng đúng thuộc `SimulationState.disciples`, đúng `current_action`, còn sống, ở tông môn, tick hiện tại lớn hơn 0; cặp `last_training_tick` trên hồ sơ và `last_training_event_id` từng đường được lưu/tải. **Mỗi đệ tử chỉ được nhận một EXP hành động trong một tick**, kể cả giả đổi từ Tu Vi sang Luyện Thể trong cùng tick.
- `request_training(state, disciple_id, track)` là lệnh người chơi yêu cầu hoạt động **một lần**, không thưởng EXP tức thì và không cắt ngang `COMBAT` hay hoạt động đang bận. Giao diện P3.2 chưa được nối; đây là cầu nối cho lệnh UI.
- Luyện Thể không ăn XP Tu Vi, không tự trừ Thể Lực Viễn Chinh hoặc gây sát thương. Giai đoạn này chưa có lịch tự ưu tiên Luyện Thể so với nghề khác, thiết bị/công pháp/cơ sở vật chất chưa tự sinh bonus không có nguồn.
- **Godot 4.7.2 Linux FOCUSED PASS** [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), code commit `e96df183`; gồm `request_training`, cả bài 2×300 và real scheduler action/dedup test. **Full P3.7 PASS cũ hơn** [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại `5296f610` (trước API lệnh V2), không được gọi full cumulative của code SHA mới nhất.

**Còn thiếu cho gameplay hoàn chỉnh:** người chơi duyệt đường EXP/cost 300 tầng + tốc độ tăng dựa vào thời lượng, ưu tiên rèn thể của AI và giao diện hiển thị, điều kiện/vật phẩm và bảng xác suất đột phá 29 đại cảnh, nhịp tự đột phá, HP V2 lưu thật, chứng minh toàn bộ game trên máy Godot. Cầu nối action đã có nhưng **nếu chưa cung cấp bảng XP và tốc độ hợp lệ thì không được giả vờ nhân vật đang tự lên tầng**.

## Major gate

`attempt_cultivation_breakthrough`:
- Only 10th floor, not realm 30 ceiling.
- Requires authoritatively supplied **gate_required_xp**, **base_chance** (0–1), non-chance `requirements_verified`, stable `event_id` and `GameRng`. Those inputs are NOT currently supplied by production content; cannot roll as UI guess.
- On failure: lose 10% of gate requirement (do not go below zero); same-gate failure +1; lifetime failure +1. Next attempt adds 5 percentage points for each same-gate failure, clamped to [0,1].
- Must regain lost XP before reattempting. Do not generic-damage HP, reduce expedition stamina or start cooldown. On success advance **only Tu Vi** to next realm floor 1; clear same-gate failure count; keep lifetime history.
- Records event_id, chance and roll for audit; audit float labels stored as text because Godot JSON round-trip can change least-significant float bits. Active RNG source remains **GameRng**, not an audit text field.
- No generic spiritual-root quality, Tu Chat, Can Cot or Fate bonus on breakthrough chance without explicit approved effect consumer.

`commit_authorized_body_gate`:
- A deliberately **separate authorized gate commit** for Body, no guessed Tu Vi chance model or unapproved material recipe. Caller must have independently verified the Body gate requirements.
- It does **not** mean a production Luyện Thể material and breakthrough-resolution system already exists.

## Real combat consumer

- `DiscipleRealmProgressV2.derive_stats` calls **CombatStatsV2.derive** with actual persisted coordinates and real Tiềm Lực, so increases in either track produce recomputed Realm/Body HP/ATK/DEF cores.
- When an initialized V2 disciple enters `HuntingPveRunV2.begin`, the group combat actor reads the saved two tracks. A client-provided conflicting override fails with `contradictory_persisted_v2_progress`. Legacy P3.7-only test fixtures still require **explicit** V2 coordinates and do not gain profiles magically.
- The original P2 `DiscipleState.hp/max_hp` are not overwritten from provisional V2 battle HP until a properly authorized HP schema migration.
- The full ten-slot Equipment V2 and Nhân/Tiên/Thần skill consumers belong to the next user-approved step, not DV2-03.

## Gate evidence & remaining constraints

**FOCUSED PASS:** Godot 4.7.2 Linux, `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`: real recruitment, one-time initialization, independent 30×10 coordinates, natural/fixed XP and typed buffs, minor floors, gate fail/pity/re-cultivate/success, HP/stamina unaffected on failure, Body separate authorized gate, JSON normalization, combat stat recomputation and denial of spoofed PvE realm.

- **FOCUSED PASS mới nhất cho DV2-03:** [#37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) ở `e96df183` (cùng các bài 2×300, tên 60 cảnh giới, command và tick chống EXP trùng); các gate #37893767560, #37893363804 là bằng chứng lịch sử, không phải latest.
- **FULL cumulative P3.7 PASS được xác minh mới nhất:** [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại `5296f610`; không phải full PASS của mã API command `aa3122a` hay test `e96df183`.
- Full P3.7 cumulative MUST be verified for the latest relevant code commit before calling DV2-03 BACKEND LOCKED.

**Still NOT done:** complete authored 300-floor EXP tables and production rates (the real action bridge is implemented but remains **disabled without content**); per-major-realm Tu Vi base breakthrough chance; body-gate material/attempt policies; automatic breakthrough attempts after authored source/condition authorization; AI body-training priority; safe old character migration and V2 HP synchronization; user UI for the new two progression tracks. Keep this phase active unless its narrower core scope and tests are explicitly closed with evidence.
