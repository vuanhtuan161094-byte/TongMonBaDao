# DV2-03 — Hai tiến độ Tu Vi và Luyện Thể V2 trên đệ tử THẬT

Ngày: 2026-10-09
Giai đoạn: **ACTIVE — FOCUSED TEST PASS; full gameplay closure NOT YET approved**

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
- **Godot 4.7.2 Linux PASS** [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), commit `e96df183`; chạy cùng bài 2×300 gốc và `dv2_03_training_actions_test.gd`: hành động scheduler, policy thiếu, EXP Tu Vi/Luyện Thể độc lập, natural vs fixed, source có danh tính, không lặp, không ngắt chiến đấu, lưu/tải. **Full P3.7 hồi quy ở `5296f610`** [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) đang chạy lúc kiểm tra gần nhất; chưa gọi full cùng bản PASS.

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

- **Latest focused official Godot 4.7.2 Linux PASS** [Actions #37893767560](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767560), code commit `57fa72ae882b`: full independent Tu Vi/Body coordinates, XP, gates, save/load, persisted-profile PvE and exact 60 named realms. Earlier green focused [#37893363804](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893363804) confirms core, now superseded by this newer gate.
- **Full P3.7 cumulative PASS** [Actions #37893455770](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893455770) for the tested V2 dual-track runtime preceding the latest 60-name label addition. **Newer full P3.7 run** [#37893767454](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767454) is pending/running as of last read; check its result before claiming same-commit cumulative PASS.
- Full P3.7 cumulative MUST be verified for the latest relevant code commit before calling DV2-03 BACKEND LOCKED.

**Still NOT done:** complete authored 300-floor EXP tables and production rates (the real action bridge is implemented but remains **disabled without content**); per-major-realm Tu Vi base breakthrough chance; body-gate material/attempt policies; automatic breakthrough attempts after authored source/condition authorization; AI body-training priority; safe old character migration and V2 HP synchronization; user UI for the new two progression tracks. Keep this phase active unless its narrower core scope and tests are explicitly closed with evidence.
