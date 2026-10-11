# DV2-03 — Hai tiến độ Tu Vi và Luyện Thể V2 trên đệ tử THẬT

Ngày: 2026-10-09
Giai đoạn: **DV2-03 ACTIVE — mã lõi/hoạt động theo tick đã PASS focused Linux Godot 4.7.2; production realtime/UI/balance và cumulative trên SHA code mới nhất vẫn chưa đóng.**


## 2026-10-11 — DV2-03F PHƯƠNG ÁN A / SCOPE CORRECTION (LATEST, DOCS ONLY)

**User decision:** chọn phương án A để **giữ đúng roadmap Đệ Tử V2**, giữ nguyên **29 recipes + 8 groups + 3 Seals + EXP/rates/Body rules**; ưu tiên săn quái/Boss/vùng tài nguyên làm nguồn vật phẩm Thối Thể, chống kẹt bằng **hoạt động thật có giới hạn kết quả**, tinh giản toàn bộ ủy thác riêng/kinh tế cao giới và chưa design các events, Pháp Bảo, đan. **CHƯA CODE, CHƯA DESIGN LOCKED**. Xem `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **mục O** (được ưu tiên hơn mục N trước đó khi khác phạm vi).

**Nghĩa vụ DV2-03F hiện hành:** manifest 29 cổng và 19 ID chuẩn; preview/commit Body gate đúng EXP, tiêu gói nguyên liệu, HP ratio, kho lock/reserve, all-or-nothing, chống double claim, save/load; nối **nguồn kiếm thật A/B** (Tử Vân Thảo trước gate4 không yêu cầu Linh Điền Lv30; Linh Tủy không rare-only) với drop từ actual PvE/region activity; UI mở cổng khả dụng, high-tier thiếu nguồn phải báo `content_unavailable` và không hiện reward giả. **Các nguồn cấp cao còn để sau:** C–H là **6 nhóm với 12 ID vật liệu** và 3 Ấn đã duyệt tên/công thức nhưng **chưa có nguồn hoặc nội dung thực**; chỉ metadata trước, triển khai sources khi giai đoạn map tương ứng được chấp thuận. Không được khai báo 29/29 playable trong lát A/B.

**Thứ tự gói dự kiến (chưa cho phép code):** F0 audit/đo nguồn đã có → F1 29 manifests + 15 registered IDs mới → F2 gate atomic transaction → F3 earned hunting/region A/B source + chống kẹt → F4 giao diện cổng → F5 thử nghiệm A/B low-tier F05/F07/F10 thật với dải rộng → F6 focused/full same-SHA → F7 bàn giao trung thực scope; **không triển khai cùng lúc sang DV2-04**. Cân bằng EXP cao giới, full hunting automation, 1k/3k throughput, kỳ ngộ/pháp bảo/đan thuộc DV2-08/10 và các authority sau, không là rào cản cân bằng thấp giới. Nếu các gate cao chưa có nguồn mà quy tắc phase-close còn yêu cầu đủ, giữ DV2-03 ACTIVE và trình quyết định ranh giới closure.

**Evidence:** E3.1 prior official Linux focused/full PASS at gameplay SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`; phương án A mới chỉ là hợp đồng, không chạy CI/Godot, Windows còn PENDING USER. Các mục lịch sử C/D/E/F/G bên dưới giữ để truy nguyên, không tự ghi đè quyết định mới.

---

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
| EXP chuẩn 2×300, 29 tỷ lệ nền Tu Vi, Body gate | **CANONICAL BALANCE CODED:** shared 300-floor curve; Tu Vi 1,000/min, Chuyên Tu ×2; Body refs 250/750/1,500; 29 Tu Vi base chances; Body gates deterministic. Exact material packages still OPEN. |
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
- Canonical progression authority is now `DiscipleProgressionBalanceV2`. `DiscipleTrainingContentV2.canonical_rules()` exposes the approved Tu Vi rate/multiplier and shared 300-floor cost table; Body source consumers use the same costs. Missing/invalid authority still fails closed atomically.
- Sau hành động hợp lệ, XP được tính bằng `DiscipleRealmProgressV2.grant_xp`: Tư Chất/Căn Cốt + những nguồn cùng channel đã kích hoạt thật; tăng tầng nhỏ tự động, dừng ở cửa đại cảnh; EXP vượt cửa **không được tự vào Tích Tu**.
- Quyền hoạt động kiểm tra đối tượng đúng thuộc `SimulationState.disciples`, đúng `current_action`, còn sống, ở tông môn, tick hiện tại lớn hơn 0; cặp `last_training_tick` trên hồ sơ và `last_training_event_id` từng đường được lưu/tải. **Mỗi đệ tử chỉ được nhận một EXP hành động trong một tick**, kể cả giả đổi từ Tu Vi sang Luyện Thể trong cùng tick.
- `request_training(state, disciple_id, track)` là lệnh người chơi yêu cầu hoạt động **một lần**, không thưởng EXP tức thì và không cắt ngang `COMBAT` hay hoạt động đang bận. Giao diện P3.2 chưa được nối; đây là cầu nối cho lệnh UI.
- Luyện Thể không ăn XP Tu Vi, không tự trừ Thể Lực Viễn Chinh hoặc gây sát thương. Giai đoạn này chưa có lịch tự ưu tiên Luyện Thể so với nghề khác, thiết bị/công pháp/cơ sở vật chất chưa tự sinh bonus không có nguồn.
- **Godot 4.7.2 Linux FOCUSED PASS** [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), code commit `e96df183`; gồm `request_training`, cả bài 2×300 và real scheduler action/dedup test. **Full P3.7 PASS cũ hơn** [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại `5296f610` (trước API lệnh V2), không được gọi full cumulative của code SHA mới nhất.

**Còn thiếu cho gameplay hoàn chỉnh:** real Rèn Thân facility/cost consumer, production/expedition hookups, exact Body gate material packages, consumable modifiers, auto-breakthrough scheduling, persistent runtime/offline owner, UI and latest Godot evidence. Canonical XP/rates/chances are no longer missing.

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
- **DV2-03M update:** authentic V2 disciples now use Realm+Body-derived `CombatStatsV2.max_hp` as live `DiscipleState.max_hp`; current HP is rescaled by ratio on recruit/floor/gate/load so progression never grants a free full heal. Equipment/innate max-HP sources remain future source adapters.
- The full ten-slot Equipment V2 and Nhân/Tiên/Thần skill consumers belong to the next user-approved step, not DV2-03.

## Gate evidence & remaining constraints

**FOCUSED PASS:** Godot 4.7.2 Linux, `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`: real recruitment, one-time initialization, independent 30×10 coordinates, natural/fixed XP and typed buffs, minor floors, gate fail/pity/re-cultivate/success, HP/stamina unaffected on failure, Body separate authorized gate, JSON normalization, combat stat recomputation and denial of spoofed PvE realm.

- **FOCUSED PASS mới nhất cho DV2-03:** [#37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) ở `e96df183` (cùng các bài 2×300, tên 60 cảnh giới, command và tick chống EXP trùng); các gate #37893767560, #37893363804 là bằng chứng lịch sử, không phải latest.
- **FULL cumulative P3.7 PASS được xác minh mới nhất:** [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) tại `5296f610`; không phải full PASS của mã API command `aa3122a` hay test `e96df183`.
- Full P3.7 cumulative MUST be verified for the latest relevant code commit before calling DV2-03 BACKEND LOCKED.

**Still NOT done:** exact Body material packages; real Rèn Thân facility/cost consumer; production/expedition hookups; automatic policy/priority using real Body availability; presentation integration; full V2 UI; complete non-V2 old-character migration and later Equipment/Innate HP sources. **DV2-03M has already implemented authentic-V2 recruitment progress, identity-only old-V2 save migration, P2 isolation and live ratio-preserving V2 HP, but latest runtime gate evidence is still missing.**

---

## Kế hoạch thực thi còn lại (DV2-03C → DV2-03G) — audit live main 09/10/2026

**Mục đích:** đóng giai đoạn DV2-03 bằng gameplay V2 thực sự chạy được, không coi unit/focused gate hoặc P0 sandbox timer là full realtime. Đây là các **lát công việc thuộc cùng một phase đang ACTIVE**, không mở phase gameplay mới. **Audit cũ về request preflight đã được DV2-03C sửa; audit mới hơn phát hiện P2/V2 authority leakage và được xử lý trong DV2-03M.** `SimulationScheduler.step()` vẫn là nơi commit action; UI P3.2 vẫn chưa phải UI hai-track V2 hoàn chỉnh.

### C — Production EXP authority + validation trước khi nhận lệnh (STRUCTURE CODED; NUMERIC BALANCE DEFERRED)

1. **DONE in code, gate unverified:** canonical shared 300-floor progression; Tu Vi 1,000/min + Chuyên Tu ×2; typed Body sources with references 250 production / 750 expedition / 1,500 Rèn Thân per minute; 29 Tu Vi chances + deterministic Body gates.
2. Chuẩn bị bảng cân bằng có số liệu/đồ thị tăng trưởng để người dùng duyệt trước khi kích hoạt production. Thiếu giá trị đã duyệt thì giữ `v2_training_enabled=false` / fail-closed. Không chuyển `CultivationSystem.STAGES` P2 sang V2.
3. `request_training` phải chạy cùng preflight validation đầy đủ với `resolve` (nguồn, track, rate, cost của tầng hiện tại đến cổng, trạng thái đệ tử); không trả `ok=true` rồi lặng lẽ từ chối ở tick sau. Giữ nguyên thuộc tính: một lệnh xếp cho tick tới, không thưởng ngay, không chen ngang COMBAT/công việc bận.
4. Focused gate: cả 600 vị trí được khai báo/kiểm tra, cost thiếu hoặc sai từ chối *trước khi xếp*; EXP tăng tầng nhỏ chuẩn, cố định không nhân lục duy, natural cộng % đúng, không double P2.

### D — Thời gian thực, tiếp diễn tự động và save/offline

1. Tạo/đính vào **một runtime owner persistent** cho live game. `SimulationScheduler.step()` hiện mang semantics **1 phút mô phỏng** (1440 tick/ngày); wall-clock cadence KHÔNG phải balance authority và không được hard-code 15 giây như luật gameplay.
2. Định nghĩa rõ pause/resume, save timestamp/remaining accumulator, offline catch-up, giới hạn xử lý (nếu cần phải được người dùng duyệt), và quyền cấp EXP cho từng tick. Không đếm wall-clock hai lần khi reload/đổi màn. Mỗi tick có ID bất biến/ordering xác định.
3. AI/assignment trong phạm vi DV2-03: hỗ trợ ưu tiên Tu Vi/Luyện Thể liên tục khi đệ tử rảnh, tôn trọng hunt/combat/work/needs; player có thể chuyển policy mà không cấp EXP tức thì. Không tự gọi `auto_breakthrough` khi chưa có content cổng chính thức.
4. Gate: giả lập thời gian dài qua đúng driver; kiểm thử save trước/sau tick, thoát/reopen/catch-up, cùng seed cho online/offline cùng kết quả; benchmark 1.000–3.000 đệ tử mà không update UI/render mỗi tick cho toàn roster.

### E — UI thật P3.2 và feedback hành động

1. Nối nút **Tu luyện** và **Rèn thể** vào API V2 cho đệ tử có hồ sơ V2 hợp lệ; giữ P2 UI/command cho legacy (không nâng cấp ngầm).
2. Hiện đồng thời hai cảnh giới + tầng + EXP/cost + tên đại cảnh + trạng thái cổng; thời gian/gain dự kiến chỉ hiển thị nếu data thực được xác thực. Đưa lý do từ chối thực từ runtime vào UI; nút không được hiện thành công giả.
3. Hiển thị nguồn tăng chỉ số và HP dựa trên authority sau migrate, không lấy `combat_power` legacy làm Combat Stats V2. Test tương tác/UI headless tối thiểu và acceptance trực quan do người dùng duyệt.

### F — Cổng đột phá production + remaining combat/source sync

1. Tu Vi: content 29 cổng (base chance, `gate_required_xp`, điều kiện, item nếu có) và consumer xác thực; giữ luật đã khóa: thất bại mất 10% EXP yêu cầu, cộng 5 điểm phần trăm lần sau cùng cổng, ghi lịch sử, không tự mất HP/thể lực/cooldown.
2. Luyện Thể: author riêng điều kiện/vật liệu/cơ chế xác nhận; không sao chép roll/chance Tu Vi. Nếu chưa được duyệt phải BLOCKED có lý do, không giả đột phá thành công.
3. **HP core migration đã code ở DV2-03M:** Realm+Body-derived Max HP là live V2 authority và giữ current/max ratio qua floor/gate/save-load. F chỉ còn kiểm chứng combat/injury integration và nối các nguồn Max-HP V2 hợp lệ (Equipment/Innate khi phase của chúng mở), không làm lại HP core.
4. Test fail/success/pity replay, cổng tự động chỉ hoạt động khi policy và dữ liệu đã đủ, save/load trong các trạng thái cổng, vào trận sau up tầng đúng chỉ số.

### G — Closeout evidence (không tự gọi PASS)

- Focused Godot 4.7.2 phải xanh trên **commit code cuối** cho C/D/E/F; chạy **FULL P0 → P3.7 cumulative trên cùng commit** khi đóng phase; kiểm tra thêm Godot Windows live/visual thực tế khi có máy người dùng.
- Báo riêng: CI Linux PASS, Windows PASS/UNTESTED, UI acceptance PENDING/ACCEPTED, old-save migration PASS/FAIL, offline replay PASS/FAIL, 1k–3k roster benchmark. Mọi số liệu thời gian phải là số đo, không bịa.
- Khi đủ evidence, cập nhật `CURRENT_CHECKPOINT.md` trạng thái CLOSED và chỉ khi đó chuyển sang phase 3 (Equipment/Skill/Innate effects). PvE map production mở rộng để phase 4.

**Đường ưu tiên hiện tại sau audit 09/10:** **M — P2/V2 migration cleanup (CODED, gate unverified)** → **D1 — autonomous policy Tu Vi/Luyện Thể** → **D2 — một clock live + offline/catch-up** → **C-balance — duyệt rồi mới điền EXP production** → **E — UI V2** → **F — breakthrough content + remaining source/combat integration** → **G — focused/full/scale closeout**. Không quay lại các số EXP minh họa cũ trước khi duty-cycle/clock thật được xác định.


---

## DV2-03C — code snapshot: EXP preflight và 600-floor catalogue

**Status: CODE PUSHED / LATEST GODOT GATE NOT VERIFIED.** New code:
- `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`: `grant_xp(...,dry_run=true)` computes identical validated EXP/floors without changing the disciple; ordinary calls still commit.
- `godot/src/simulation/cultivation/disciple_training_action_v2.gd`: player `request_training` preflights rate, all costs from current floor through gate, sources and foundation with the same `grant_xp` logic as `resolve`. Invalid calls leave action/EXP intact. Combat interruption and 1 tick/one reward rules preserved.
- `godot/src/simulation/cultivation/disciple_training_content_v2.gd`: independent complete schema validator, exactly two 30×10 channels = 600 explicit cost cells, finite positive rates/costs, version ID and deterministic builder; building does NOT enable `SectState.v2_training_enabled`.
- `godot/tests/simulation/dv2_03_training_actions_test.gd`: coverage complete/short/bad catalogues, JSON restore, read-only preview, invalid rate/duplicate sources/missing floors rejected before player queue, existing scheduler/save/dedup regression; `.github/workflows/dv2-03-realm-body-progress.yml` watches changed code.

**No approved production EXP numbers have been applied.** Current 100/80/50 in QA are fixtures only. Even with validated schema, production remains default-OFF. The old focused PASS and previous full P3.7 PASS were at older code commits; the changes listed above require independent Godot 4.7.2 run evidence before being marked PASS.
### EXP balance status after DV2-03M

**Production progression balance is now approved in code.** Earlier illustrative `12 EXP/15s` / `0.75h ×1.23^(r−1)` notes remain RETIRED. Current authority: Tu Vi 1,000/min, Chuyên Tu ×2; Body references 250/750/1,500 per minute; shared frozen 300-floor curve in `DiscipleProgressionBalanceV2`.

---

## DV2-03M — P2/V2 authority cleanup (09/10/2026)

**CODE PUSHED; latest Godot runtime gate UNVERIFIED.**

- Authentic V2 identity is centralized through `owns_v2_progression`; progression mutation additionally requires `progression_ready`.
- V2 recruitment creates the two-track profile immediately at the **user-locked production start: Phàm Nhân tầng 1 + Phàm Thân tầng 1, both 0 EXP**. The old P3.7 Luyện Khí compatibility bridge remains only for pre-lock development-save migration.
- Identity-only pre-DV2-03 V2 saves migrate once through that bridge; a present malformed progression payload fails closed instead of rerolling.
- Scheduler/AI/workforce/combat cannot read/write P2 cultivation for authentic V2 characters: no P2 combat-win XP, P2 breakthrough, P2 realm combat bonus or P2 cultivate fallback.
- Authentic V2 ordinary work no longer owns a separate Tu Vi reward. Passive natural Tu Vi is resolved once per simulation minute by the cultivation/time authority during work/rest/travel/hunt/combat/etc.; in-sect work/rest/hold still do not spend/refill expedition stamina.
- V2 live Max HP comes from Realm+Body CombatStatsV2 and preserves current HP ratio on recruit/floor/gate/save-load.
- Floor-10 cost is the single EXP authority for major gates; no second numeric `gate_required_xp` argument.
- Strict birth identity validation again checks real Root/Mutation/Profession Talent/Trait/Bloodline/Physique/Destiny structure, while allowing lawful post-birth current-root growth.
- New focused isolation test covers the above, but **do not call PASS until official Godot 4.7.2 evidence for the latest code is available**.

---

## DV2-03D1 — autonomous training policy (09/10/2026)

**CODE PUSHED / RUNTIME GATE UNVERIFIED.**

- Persisted policy enum still contains `balanced`, `cultivation_focus`, `body_focus`, `manual` for compatibility.
- **Correction/current state:** Luyện Thể source model and rates are now user-locked, but the real facility/slot/cost consumer is still absent. Therefore `body_focus` remains BLOCKED until that consumer exists; balanced may not fabricate a training slot.
- Earlier lower-floor/lower-ratio/tie logic remains provisional scaffolding for the day when a real Luyện Thể action is approved; it is not current gameplay authority.
- `manual` disables autonomous selection only; explicit player `request_training` still works.
- `preview_training` is read-only and reuses the same authored rule validation. A full floor-10 track reports `major_gate_waiting`.
- Workforce cultivate schedule slots and `DecisionSystem` share one `DiscipleTrainingPolicyV2`; there is no second AI formula.
- Policy selection never grants EXP. It may queue approved `CULTIVATE`; `TRAIN_BODY` is fail-closed until Luyện Thể training mechanics are designed.
- Focused test: `godot/tests/simulation/dv2_03_training_policy_test.gd`. Workflow updated to execute it.

Latest gameplay code: `60e3da63a3329a8b9f37ce57552895dd95fcc454`.
Latest policy test: `583270cbd95c8c1fe96e0bfc7efa0ffd3c2e103f`.
Workflow update: `db758a56cdb5f9b97f5cfe3b61930380adf4031d`.

No current Godot 4.7.2 run ID/check is discoverable through the available private-repo connector path, therefore **do not call D1 PASS**.

### D2 live-time audit

Current main scene is still a presentation/demo runtime:
- `p3_2_landscape_sect.tscn` -> `p3_2_landscape_sect.gd` -> parent `p3_1_landscape_sect.gd`;
- parent creates `P212Factory.create_state(DEMO_SEED)` on every open;
- it calls `scheduler.step()` from a `Timer` every **0.55s**;
- P0 sandbox separately uses **0.18s**;
- `SaveService` can persist `SimulationState`, but this main scene does not load that persistent state.

Therefore neither existing timer may be relabeled as the canonical 15-second clock. D2 must introduce/attach a persistent runtime owner first, then save wall timestamp + remainder/backlog and use the same scheduler for online/offline ticks. Existing P3.7 `1440 simulation ticks/day` remains the sect-day semantic; **15 seconds is wall-clock cadence**, not a redefinition of game-day length.

---

## Source-model redesign lock — 2026-10-09

User-approved gameplay authority now supersedes the current action-only EXP bridge:

1. **Production V2 recruitment starts 1/1:** Phàm Nhân tầng 1 + Phàm Thân tầng 1, both 0 EXP. The temporary P2 Luyện Khí-floor compatibility bridge is migration/dev-save-only and must be removed from new V2 recruitment.
2. **Tu Vi is continuously passive:** every eligible disciple gains natural Tu Vi from elapsed simulation time during ordinary life/activity.
3. Ordinary work/combat/travel/hunting do **not** produce a second generic Tu Vi award. Existing `_grant_p3_7_work_cultivation()` behavior is now implementation debt and must be removed/reworked for authentic V2.
4. `CULTIVATE` becomes **Chuyên Tu**: acceleration of the same passive natural-Tu-Vi rate, not the existence condition for Tu Vi gain.
5. Monster combat grants no direct main-track EXP; monsters may drop **Tinh Nguyên**, whose absorption grants fixed +X Tu Vi.
6. Luyện Thể remains non-passive. Typed natural contexts are now locked as production / dedicated Rèn Thân / expedition; dedicated Rèn Thân is per-minute and cost-gated. Exact facility/content implementation remains separate.
7. **15s is not a balance law.** The runtime cadence may batch elapsed-time progression but equal elapsed time must yield equal progression online/offline regardless of commit frequency.

**Implementation status:** Tu Vi source-model refactor is CODE PUSHED. `DiscipleTuViFlowV2` grants one natural Tu Vi source per simulation minute; `CULTIVATE` only applies Chuyên Tu acceleration; separate work-Tu-Vi was removed; new recruitment starts 1/1. **Luyện Thể training is intentionally blocked**: provisional `TRAIN_BODY` cannot grant EXP, and body-focus auto policy cannot be activated until design is approved. Latest runtime Godot gate evidence is UNVERIFIED.

---

## DV2-03B2 — typed Luyện Thể source contract (2026-10-09)

**USER-LOCKED design scope:** Luyện Thể natural EXP has three distinct contexts: **production**, **dedicated Rèn Thân**, **expedition**.

**CODE PUSHED / RUNTIME GATE UNVERIFIED:**
- new `DiscipleBodyXpSourceV2` validates and commits one natural Body source per simulation minute;
- all three sources reuse the canonical Căn Cốt +0.20%/point natural-gain law and same-channel modifiers;
- production requires an owning consumer to prove active physical work;
- dedicated Rèn Thân requires verified training access plus proof that the current minute's economic cost was committed;
- expedition requires verified active expedition and an outside-map actor;
- production/Rèn Thân are sect sources; expedition is outside-map, preventing double classification;
- one actor/minute cannot receive two natural Body grants;
- fixed +X Body EXP still bypasses Căn Cốt through the existing `fixed` path;
- `last_body_xp_tick` is persisted for deterministic save/load anti-double-credit;
- `TRAIN_BODY` and `body_focus` remain fail-closed with `body_training_consumer_not_ready` until a real facility/cost consumer exists.

**Canonical reference balance is now locked:** production 250/min, expedition 750/min, dedicated Rèn Thân 1,500/min before Căn Cốt/modifiers. Profession eligibility, training grades/cost formulas and expedition pressure scaling remain OPEN content.

Focused test: `godot/tests/simulation/dv2_03_body_xp_source_test.gd`.

---

## DV2-03B3 — canonical progression and major gates (2026-10-09)

**CODE PUSHED / RUNTIME GATE UNVERIFIED.**

Canonical progression:
- shared Tu Vi + Body 300-floor cost curve in `DiscipleProgressionBalanceV2`;
- realm totals 10,000,000 -> 10,240,200,000 across 30 realms;
- within-realm weights 0.70/0.75/0.80/0.85/0.90/1.00/1.10/1.20/1.30/1.40;
- cumulative totals through realms 10/20/30 = 367,400,000 / 4,376,300,000 / 48,130,600,000;
- Tu Vi = 1,000/minute; Chuyên Tu ×2;
- Body reference rates = 250 production / 750 expedition / 1,500 dedicated Rèn Thân per minute.

Canonical gates:
- 29 Tu Vi base chances in `DiscipleBreakthroughBalanceV2`;
- same-gate pity +5pp/failure and −10% gate EXP on Tu Vi failure remain;
- all 29 Body gates deterministic after full gate EXP + verified Thối Thể requirements;
- no Body RNG/pity/failure loss.

New focused tests:
- `dv2_03_progression_balance_test.gd`;
- `dv2_03_breakthrough_balance_test.gd`.

Do not interpret old QA fixtures such as 80/50/100 as production balance.

---

## DV2-03D2 — persistent runtime clock/backend owner (2026-10-09)

**CODE PUSHED / RUNTIME GATE UNVERIFIED.**

- canonical wall mapping: **60 real seconds = 1 simulation minute**;
- `SimulationRuntimeClockV2` accumulates elapsed seconds and advances only through `SimulationScheduler.step()`;
- online and offline therefore share identical progression code;
- fractional seconds persist across save/load;
- optional bounded catch-up leaves pending whole minutes in the persisted backlog;
- backwards wall-clock movement is rejected without progression;
- `SimulationRuntimeOwnerV2` owns one state + one scheduler and catches up before save / after load;
- old saves without clock metadata initialize at first upgraded load without speculative historical offline credit;
- focused test compares one 5-minute offline jump with five one-minute online advances and requires identical V2 progression/RNG state.

**Presentation boundary:** the current P3.1/P3.2 0.55s demo timer is intentionally NOT rewired in this slice. A later presentation integration must consume `SimulationRuntimeOwnerV2` rather than create a second progression clock.

---

## DV2-03D3 — Step 1 live P3 runtime integration (2026-10-10)

**IMPLEMENTED and focused Linux Godot 4.7.2 PASS.**

Live-game ownership:
- NEW `LiveGameRuntimeV2` is the game-specific bootstrap over `SimulationRuntimeOwnerV2`;
- missing save -> create current `P37Factory` state, enable authentic future V2 birth + canonical V2 training rules, persist immediately;
- existing valid save -> load first, then catch up elapsed wall time through the same `SimulationScheduler`;
- existing corrupt save -> fail closed; do **not** silently replace it with a new game;
- P3.1/P3.2 no longer create `P212Factory` demo state, no longer append two presentation-only recruited disciples, and no longer own a 0.55s simulation timer;
- main P3 scene now references exactly the runtime owner's `SimulationState`;
- wall poll = 1s presentation cadence, autosave = 15s persistence cadence; gameplay remains **60 real seconds = 1 simulation minute**;
- save on autosave, application pause and scene exit; resume immediately performs wall-clock catch-up;
- test-only save path can be overridden through `runtime/live_save_path` so headless presentation tests never share production saves.

New gates:
- `dv2_03_live_runtime_integration_test.gd`: missing-save creation, canonical 1,000 Tu Vi/minute, 59s no-tick, 60s one tick, save/reopen +120s = exactly two offline minutes, no demo-roster mutation, no same-time duplicate, corrupt-save fail-closed;
- `dv2_03_p3_live_runtime_binding_test.gd`: P3.2 state is runtime-owner state, canonical V2 flags/rules active, old 0.55s timer absent, autosave present, deterministic +60s step and persisted state;
- P3.6A playable-slice test updated to advance the live runtime by one explicit wall minute instead of using the old test-only “one UI call = one scheduler tick” assumption.

Evidence:
- **DV2-03 Realm Body Progress #96** — commit `35dd076db146370e6fbadb4cd2d9ee0a9994f642` — official Godot **4.7.2 Linux** — project parse + all DV2-03 focused gates including both new live-runtime tests **PASS**.
- **P3.6A Preview #24** — commit `20ff9686464b09493adc2e4af740a10080d97333` — official Godot **4.7.2 Linux** — playable slice **PASS** after adopting the real wall-clock contract.
- **P3.7 Backend #151** — run [#38037386848](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037386848), commit `150be2aeaf5c7092f594850bdffa2e349f7c03cf` — **FAST + FULL cumulative PASS** on official Godot 4.7.2 Linux.
- Windows/graphics-local acceptance remains **UNTESTED** unless separately run on the user's Windows Godot 4.7.2 environment.

This completes **Step 1 runtime integration**, but does **not** complete DV2-03 as a whole. Real Rèn Thân/body consumers and V2 disciple presentation belong to the next planned slices.

---

## DV2-03E3.1 — Đóng lỗi chuyển slot / chặn nghề chen ngang (11/10/2026)

**Chốt áp dụng:** Slot Rèn Thân Đường là phân công công việc độc quyền khi còn hiệu lực; tỷ lệ 1.500 EXP nền/phút, một Linh Thạch/phút và đúng 2 slot cấp 1 giữ nguyên. Mỗi đệ tử V2 giữ slot được ưu tiên chính sách luyện thể trước lịch sản xuất nghề, kể cả khi đã có ưu tiên Luyện Khí từ trước. Nếu không đủ Linh Thạch, không phát EXP Luyện Thể tự do; fallback tu luyện hợp lệ hoặc HOLD, không âm ngân khố. Sức khỏe thấp và chỉ thị người chơi được ưu tiên hợp pháp.

- Đổi qua **Chuyên Tu**: validate Tu Vi mới trước → trả chỗ Rèn Thân cũ → xếp `CULTIVATE`, giữ lịch sử chi tiền/EXP trước đó; không để slot ma. Tất cả caller của `DiscipleTrainingActionV2.request_training` được bảo vệ, không riêng UI.
- Chuyển nghề/lệnh trực tiếp hợp lệ: `WorkforceSystem.issue_command` và `assign_group` giải phóng đúng slot; clear worksite của người đang luyện đồng thời clear group để tránh nhầm fallback primary-building.
- AI/Workforce: đường `next_action` xử lý slot riêng trước lịch nghề thông thường, nhưng sau kiểm tra HP và lệnh trực tiếp. Không giữ cưỡng chế EXP nếu thiếu phí/không hợp lệ.
- Test: `dv2_03_e3_1_training_priority_regression_test.gd` bao gồm 2 slot, lệnh invalid, Chuyên Tu, người thứ 3, save/load, chuyển nghề, clear worksite, ưu tiên Luyện Khí từ trước, nhiều phút scheduler/2 đệ tử/6 Linh Thạch, cạn tiền và cần chữa trị. Test UI E3 bổ sung chuyển Chuyên Tu → thay đệ tử thật.

**Godot 4.7.2 Linux focused:** [#38093450321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450321), **PASS** at code `3c7e9a76`. P3.7 FAST + FULL [#38093450298](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450298) **COMPLETED / PASS** at the same gameplay SHA `3c7e9a76` (official Godot 4.7.2 Linux). Windows visual NOT RUN.

---

## DV2-03E3 — Rèn Thân Đường clickable + quản lý 2 slot thật (10/10/2026)

**SCOPE CODED:** same active DV2-03; no new phase, no dummy NPC/warehouse/resources. Official map `SectMapPresentation.DEST_BODY_TRAINING` maps to `BuildingSystem.TYPE_BODY_TRAINING`, with independently clickable token and distinct `TRAIN_BODY` actor destination/status. `p3_1_landscape_sect.gd` builds the token; `p3_2_landscape_sect.gd` owns its real management UI.

**Playable:** on map tap Rèn Thân Đường, its building panel shows canonical building level, actual active/assigned slot count **2 at Lv1**, current Sect Spirit Stones, cost **1 per active simulated minute**, Body reference **1.500 EXP/min before Căn Cốt**, real per-building paid minutes and spent stones from `BuildingState.production_state`, per-disciple `TRAIN_BODY` action and last scheduler result if present. Management rows reflect two `BuildingSystem.active_worker_ids` actual reservations. Player can assign a V2 disciple through existing `DiscipleTrainingActionV2` V2 queue/real reservation, and explicitly release a slot (manual policy, no free refund), freeing it for another disciple. The UI shows up to 12 available V2 candidates in one management slice; larger-roster search/pagination remains future UX, never suggest all 3,000 are visible.

**Truth:** button press reserves/queues only, does not debit or award EXP. SimulationScheduler and the existing Rèn Thân owner debit before EXP on real eligible minute. Failed/full slot, no treasury, bad actor, Linh Điền reservation remain fail-closed. No created phantom Linh Thạch, UI-side EXP or new financial authority. `TRAIN_BODY` maps actor to dedicated Rèn Thân building, separate from Tu Luyện Đài. Save/load persists Rèn Thân group/worksite and already-paid counters. Legacy P2 UI remains separate. The visual token is existing Godot geometry/presentation, **not a newly authored game art asset**.

**Test:** `godot/tests/presentation/dv2_03_p3_body_training_building_ui_test.gd` instantiates the real P3.2 scene using isolated save, verifies clickable building token and mapping, 2 slots, real treasury, 3 authentic recruits, full-slot denial, release/reassign, exactly one paid Body minute and save/load. It is included in `.github/workflows/dv2-03-realm-body-progress.yml`. Latest focused official Godot 4.7.2 Linux [#38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) **PASS** at source commit `b8103b06`. Latest P3.7 full [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594) **PENDING at documentation time**; status must be refreshed before final closeout.

**Still open:** authenticated Dẫn Tiên UI/recruit flow, 29 exact Thối Thể material packages and user-approved breakthrough consumer, Rèn Thân upgrades/intensities, P3.6A upload artifact storage quota, real Windows/Godot visual test, and enhanced large-roster candidate selection. No false DV2-03 CLOSED claim.

---

## DV2-03E3 — Rèn Thân Đường playable map + live building panel (10/10/2026)

**Implementation scope:** same active phase DV2-03, no new balance. Real gameplay state remains sole authority. The E3 presentation changes reuse the approved separate `Rèn Thân Đường`, the real treasury `state.sect.spirit_stones`, the existing 2-slot `BuildingSystem` and canonical `DiscipleBodyTrainingFacilityV2`.

- P3.1 procedural map has **one** distinct clickable `ren_than_duong` token. `SectMapPresentation` maps `TRAIN_BODY` to the correct building world position and displays the active-action label.
- P3.2 building interaction opens the normal `BuildingOperationPanel`; read-model displays **real Lv1, 0–2 assigned slots, current active training actions, live Sect Spirit Stones, 1 stone/minute, canonical 1,500 base Body EXP/minute, persisted paid minutes/spent stones, last scheduler training result when present**.
- Slot rows show the **actual names** and activity states of the two assigned V2 disciples. The building panel's candidate buttons draw from the **real current V2 disciple roster at the sect**, bounded to 12 rendered candidates for larger rosters. For other disciples use the character profile's V2 training action; no fake roster or mock resources.
- Assign calls existing `_queue_v2_training("body", disciple_id)`: policy/availability checks → `reserve_slot` → `request_training`. The button **does not charge or award immediately**. Full slots, shortage of stones, blocked work and active Spirit Field plots fail closed with reason.
- Release uses one canonical `DiscipleBodyTrainingFacilityV2.release_slot`, clears both work-group and worksite (important because the primary-building fallback would otherwise keep counting a ghost slot), stops a queued `TRAIN_BODY` and returns that disciple to **manual** training policy so AI cannot silently re-queue paid training. Release never refunds or charges a finished minute.
- Source-backed UI refresh after a committed minute reflects remaining stones, paid minutes, source-awarded EXP and canonical actor status; nothing is inferred from the click event.
- `godot/tests/presentation/dv2_03_p3_body_training_building_ui_test.gd` exercises real Godot P3.2 scene, clicked map hit target, 3 authentic V2 recruits / 2 allowed slots, third denied, real release/reuse, one paid minute, treasury/counters, and state save/restore.
- **Focused Godot 4.7.2 Linux PASS:** [run #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) at source `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`, including E3 integration test. Full P3.7 cumulative on same source: [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594), status to be rechecked before final acceptance.
- P3.6A gameplay/preview capture script is not identical to artifact upload: previous P3.6A steps including Godot parse/smoke and capture passed, but GitHub storage **artifact quota** made upload-artifact fail on previous runs. This is not a Windows visual approval.
- **Windows Godot 4.7.2 / human visual review remain PENDING USER.** Neither preview-artifact retrieval nor Windows PASS is claimed.

**Next within DV2-03:** authorize specific 29 Thối Thể major-gate material rules before any recipe/consumer; do not invent materials or auto-complete gates. Dẫn Tiên playable recruitment and production assignment remain next after closing this phase.


## DV2-03E2 — UI lệnh Chuyên Tu / Rèn Thân Đường thật (10/10/2026)

**Phạm vi:** vẫn thuộc DV2-03; chưa triển khai Dẫn Tiên UI/phase mới. 2 nguồn tiến độ vẫn do runtime V2 làm chủ, còn Unity source chỉ là tham khảo.

- Hồ sơ đệ tử P3.2: tab **Thuộc tính** của authentic V2 có hai nút **Chuyên tu** / **Rèn thân**; legacy P2 không được hiển thị các nút đó.
- Summary trên bản đồ: lệnh **Tu luyện** của authentic V2 đi qua `DiscipleTrainingActionV2.request_training(..., "cultivation")`, không dùng lệnh P2/Workforce fallback. Shortcut **Rèn thân** chỉ hiển thị cho V2, thay thế shortcut legacy Luyện Khí ở cùng vị trí (legacy vẫn giữ).
- Một lần nhấn **Rèn thân**: chạy `DiscipleBodyTrainingFacilityV2.reserve_slot` với preflight work/action/treasury/gate, rồi `DiscipleTrainingActionV2.request_training(...,"body")`. Nếu thành công, ghi chính sách `body_focus` và bỏ direct command cũ; nếu từ chối, phản hồi thật từ backend thay vì báo thành công giả.
- **Không tự trừ 1 Linh Thạch/cộng 1.500 EXP trên UI.** Debit/award thuộc `SimulationScheduler` → `DiscipleBodyTrainingFacilityV2.commit_minute` khi đủ một phút mô phỏng thực.
- Action UI chỉ nhận authoritative V2 profile; core V2 không fallback P2. Lỗi backend phổ biến được map thành tiếng Việt (hết tài nguyên, hết slot, busy Linh Điền, đang công việc khác, tại major gate, không có công trình). Feedback của lệnh không bị xóa khi tab Thuộc tính rebuild.
- Focused UI regression thêm đường no-stone denial, slot reservation, queued Body action not instantly paid/rewarded, real paid minute via approved resolver, queued cultivation without instant EXP. Legacy P3.2 UI regression giữ nguyên.
- **Chưa có:** click Rèn Thân Đường như một building riêng trên sect map; Dẫn Tiên Đài tuyển đệ tử qua giao diện; nội dung 29 bộ Thối Thể và tất cả UI/visual acceptance trên Windows. Không gọi toàn bộ gameplay loop playable khi thiếu các đường này.

**Gate evidence:** CI cho code mới cần xác minh trước khi gọi PASS. Windows Godot 4.7.2 live visual = NOT RUN / PENDING USER.

---

## DV2-03E1 — Step 2 unified disciple presentation snapshot (2026-10-10)

**IMPLEMENTED / FOCUSED Linux Godot 4.7.2 PASS.**

New presentation authority:
- `DisciplePresentationSnapshotV2` is a pure read-model over live `SimulationState` + `DiscipleState`;
- authentic V2 and legacy compatibility are explicit branches;
- V2 progression always comes from `v2_realm_progress`; malformed V2 data fails closed rather than falling back to P2;
- V2 combat display comes from `CombatStatsV2` Realm+Body+Potential core only;
- no dormant/unimplemented innate or equipment effect is silently activated;
- latent Trait and unrevealed Mutation/Bloodline/Physique/Destiny values are removed from the UI-facing snapshot;
- presentation build is verified not to mutate simulation state.

P3.2 integration:
- summary and deep status show both Tu Vi and Luyện Thể for authentic V2;
- Thuộc tính shows canonical floor EXP/cost, gate status, six foundations, HP/Attack/Defense and Expedition Stamina;
- Root, visible Trait, Bloodline, Physique and Destiny identity are read from the same V2 birth profile;
- Công pháp/Trang bị/Quan hệ read normalized snapshot records; V2 compatibility records do not imply unfinished V2 effects;
- V2 Huyết Mạch/Thể Chất no longer expose P2 mutation buttons/actions;
- legacy P3.2 branch remains operational and uses canonical P3.7 Warehouse resources in its regression fixture.

Evidence:
- [DV2-03 #38038834727](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038834727), SHA `5ecb3bbeb7d1adc7644a9aecc3b805d0fc6bb3fa`: **PASS all focused steps**, including snapshot, authentic V2 profile UI and legacy compatibility.
- [P3.6A #38038282452](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038282452), production UI SHA `85639c14c5ff699f230e7ae5a713b32e54fca7d5`: **PASS**.
- [P3.6A #38038535562](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038535562): **PASS** after test-only runtime-clock cleanup.

**WINDOWS / USER VALIDATION: PENDING — user has not run Step 2 on Windows.**
Do not call Windows PASS or VISUAL ACCEPTED until the user actually runs/reviews it. Stable commands when requested: `Sync-Main.cmd Verify-P3-6A-Playable-Slice.cmd`, then `Preview-P3-6A-Playable-Slice.cmd`.

Step 2 is a presentation/read-model closure only. It does not complete V2 innate effect consumers or the real Rèn Thân facility/cost path.

