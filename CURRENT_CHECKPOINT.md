# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-09

This file contains **current truth only**.
It is not a historical changelog.

Read `docs/GAME_SYSTEM_ARCHITECTURE.md` for system structure and phase discipline.

---

## 1. Locked earlier baseline

Real Windows Godot 4.7.2 locked baseline:
- P0–P2.12;
- P3.1 landscape/living-sect shell;
- P3.2 map camera/selection + real disciple tabs;
- P3.2 live modular female map integration;
- P3.3 disciple operational flow;
- P3.4 building management;
- P3.5 living-sect cues;
- P3.6A runtime slice.

P3.6A final visual acceptance remains user-owned.
It is not a blocker for backend P3.7.

Do not reopen these phases without actual regression evidence.

---

## 2. P3.7 backend foundation completed

### P3.7A1 — Building Authority + Mine

Status: **BACKEND LOCKED**

Implemented:
- generic `BuildingState` / `BuildingSystem`;
- stable building identity;
- Lv1–100;
- worker slots;
- timed upgrades;
- Mine travel -> work batch -> haul/deposit;
- save/load + deterministic continuation.

### P3.7A2R — Spirit Field / Linh Điền Completion

Status: **BACKEND LOCKED**

Canonical runtime:
- one plot = one authoritative timer;
- no seed item;
- no detailed backend walking/tending/harvest/haul phases;
- planting consumes Sect Spirit Stones;
- cancel has no default refund;
- multiple plots and multiple field instances;
- **one active plot reserves exactly one disciple until harvest resolves**;
- passive crop countdown grants no work Tu Vi;
- worker slots = plot slots;
- Lv1 = 4 slots, +1 every 5 levels;
- AUTO_DEMAND / PRIORITY / FIXED policies;
- Thanh Linh Thảo / Linh Cốc / Tử Vân Thảo;
- lucky harvest and Linh Tuyền Chi Tâm fragment path;
- direct deposit to canonical Sect Warehouse;
- save/load + deterministic continuation.

### P3.7B1 — Resource Registry + canonical Sect Warehouse

Status: **BACKEND LOCKED**

Implemented:
- explicit resource IDs/families/realm grades;
- no Phẩm Lực;
- one canonical stackable-resource warehouse;
- no gameplay storage-capacity ceiling;
- reserve/lock rules;
- atomic consumption;
- legacy P3.7 material migration;
- building, Mine, Spirit Field, crafting, technique, root, bloodline and physique consumers use canonical storage where migrated.

### P3.7C1 — Open-point Lục Duy + Dẫn Tiên Đài

Status: **BACKEND LOCKED — official Godot 4.7.2 fast + full cumulative CI green**

Canonical six lục duy:
- Tư Chất;
- Căn Cốt;
- Cơ Duyên;
- Thông Tuệ;
- Mị Lực;
- Tiềm Lực.

Locked architecture:
- no permanent hard cap;
- procedural birth first rolls Total Birth Lục Duy;
- ordinary birth distribution keeps each stat around `floor(total/12)` to `floor(total/2)`;
- Mệnh Cách/future rare rules may break the birth envelope;
- after birth, six values grow independently without that envelope;
- immutable birth snapshot is persisted;
- current quality derives from current permanent total and may promote through growth;
- working quality thresholds: <360 / 360–599 / 600–999 / 1000–1799 / >=1800;
- Nghịch Thiên has a long tail and no hard total cap.

Starting balance constants:
- Tư Chất: +0.25% base cultivation gain / point;
- Căn Cốt: +0.20% body-training XP / point;
- Thông Tuệ: +0.15% learning XP / point;
- Tiềm Lực authority: +0.05% future Realm+Body growth / point;
- Cơ Duyên: `RNG(0..9999) + Cơ Duyên - Difficulty`, tier thresholds 6000/8500/9500/9900;
- Mị Lực: social-power authority plus Dẫn Tiên-specific recruitment rules.

P3.7 same-channel percentage bonuses are additive on base rather than chained multipliers:
`final = base × (1 + sum(bonuses))`.
Fixed-value rewards remain fixed; lục duy does not silently multiply an item that states an exact +X reward.

Dẫn Tiên Đài:
- real Lv1–100 building;
- current guide-slot curve: 1 at Lv1, +1 at Lv20/40/60/80/100, max 6;
- exactly one Main Guide affects quality odds;
- assistant guides affect daily arrival quantity only;
- Main-guide Mị Lực itself is not hard-capped by Dẫn Tiên;
- the **quality table** reaches its ceiling at 2,500 Main-guide Mị Lực: Nghịch Thiên max 5%, Tuyệt Luân max 15%, no tier becomes 0%;
- current normal rates: 65 / 25 / 8 / 1.8 / 0.2%;
- current maximum boosted rates: 35 / 25 / 20 / 15 / 5%;
- enhanced Nghịch Thiên daily allowance = `ceil(Main Guide Mị Lực / 625)` for positive Mị Lực, so 2,500 -> 4/day, 10,000 -> 16/day;
- once that enhanced allowance is consumed, the whole quality table returns to normal for the rest of that day;
- normal-rate Nghịch Thiên may still appear;
- the counter advances on appearance, not acceptance;
- daily snapshot prevents swapping Main Guide to reset the advantage;
- assistant Mị Lực is uncapped for quantity; each 500 assistant Mị Lực adds +1 arrival/day;
- base arrivals currently = `5 + 3 × floor(Dẫn Tiên level / 10)`, from 5/day at Lv1 to 35/day at Lv100;
- Chiêu Mộ Lệnh uses the same Dẫn Tiên daily quality/quota authority.

Premium-currency direction from reference research:
- ordinary recruitment premium spending should buy Chiêu Mộ Lệnh through an explicit limited shop when this project has canonical premium-currency authority;
- C1 does **not** invent Tiên Ngọc / Tiên Ngọc Khóa wallet fields;
- special limited/named recruitment, if later added, uses a separate explicit token/pool and is outside C1.

P2 factories remain on the old normalized model for regression compatibility.
Old P3.7 saves migrate deterministically to open-point foundations and receive the new building authority.

---

## 3. Verification evidence

Official Godot 4.7.2 GitHub CI closing evidence:

- workflow: `P3.7 Backend`;
- run: **#75**;
- run id: `37491065054`;
- job id: `112363619374`;
- tested commit: `948997f3d101fcd23361cd318ffa130ae97f7e77`;
- P3.7C1 focused gate: **PASS**;
- full cumulative P0 -> P2.12 + P3.7 A1 + A2R + B1 + C1: **PASS**.

The full run explicitly includes:
- P0–P2.12 gates;
- P3.7A1 full;
- P3.7A2R full;
- P3.7B1 full;
- P3.7C1 six-foundation + Dẫn Tiên contract.

Persistent C1 commands:
- `Verify-P3-7C1-Foundation-Dan-Tien.cmd`;
- `Verify-P3-7C1-Foundation-Dan-Tien-Full.cmd`.

This is GitHub CI evidence on official Godot 4.7.2.
Do not describe it as Windows evidence.

The separate P3 Presentation Audit is not evidence for C1 and may remain red for unrelated presentation/asset-registry checks. Do not claim all workflows green.

---

## 4. Important implementation boundaries

C1 does **not** claim the following are finished:
- final Luyện Thể progression;
- final ATK/DEF/HP stat migration for Tiềm Lực;
- migration of every old Cơ Duyên percentage consumer to the new Luck Score;
- final social/relationship systems;
- premium-currency wallet/shop;
- limited named-character banners.

These future systems must consume the C1 authority instead of inventing another lục-duy model.

Current old percentage consumers may use a bounded compatibility bridge where needed to protect earlier locked gameplay.

---

## 5. Trạng thái triển khai mới nhất — bàn giao DV2-03 ngày 09/10/2026

**ACTIVE: DV2-03 — TU VI V2 + LUYỆN THỂ V2.** DV2-01 **CLOSED**; DV2-02 **CORE BACKEND LOCKED** trong phạm vi stat/encounter. **Latest DV2-03P2 real Mine Body EXP + paid Rèn Thân Đường + Linh Điền reservation guard focused official Godot 4.7.2 Linux PASS at source `6e10aca2`** (see §5.15). Previous full P3.7 PASS is older-source evidence; latest same-source FULL #38066113295 PASS on official Godot 4.7.2 Linux (see §5.15). Windows/user visual still untested. Do not open next gameplay phase before closure criteria.

**Lần kiểm tra live main trước bàn giao:** `a3e9b6befee8117c50a797bb35c257acf08d156d` (chỉ là SHA nguồn tại thời điểm kiểm tra, **không phải SHA commit cuối bàn giao**; xem `main` và câu trả lời hoàn tất để lấy HEAD sau các commit tài liệu). **Mã gameplay cuối được thay đổi và kiểm thử focused:** `e96df1832036c1232f9d0db69d1f37450d0265f9`. Tất cả commit tiếp theo cho tới lúc rà soát ban đầu là tài liệu, không thay đổi logic chơi. Không ghi sai SHA code thành SHA HEAD.

### 5.1 Bằng chứng CI và Godot thực tế (trạng thái đã đọc trực tiếp)

| Gate | SHA source kiểm thử | Kết quả |
|---|---|---|
| [DV2-03 focused #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) | `e96df1832036c1232f9d0db69d1f37450d0265f9` | **PASS**: official Godot 4.7.2 Linux; project parse + `dv2_03_realm_body_progress_test.gd` + `dv2_03_training_actions_test.gd` đều success |
| [DV2-03 focused #37895489204](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895489204) | `aa3122a79e31c1d6b78664f3d07dd7dd4de4aa68` | **PASS**: API queue player request; sau đó `e96df183` bổ sung thêm test |
| [P3.7 FULL #37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) | `5296f6106a2fd43d5c1a6f2523854702e9014d63` | **PASS**: fast + full cumulative P3.7, code scheduler V2 theo tick tại SHA đó |
| P3.7 FULL trên **cùng SHA `e96df183`** | **Chưa có bằng chứng run đầy đủ** | **CHƯA KIỂM THỬ** (không suy từ full run cũ) |
| Godot **Windows** trực tiếp/đồ họa P3.2 với V2 | Chưa cung cấp | **CHƯA KIỂM THỬ**, không gọi Windows PASS |

**P3 Presentation Audit ngoài phạm vi DV2-03:** [Actions #37897313917](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897313917) tại `b3854215` từng **FAIL**: `P3_ASSET_REGISTRY.json` assets[21]/[22] đặt `repo_source` nhưng thiếu `source_path`. Đã đối chiếu và bổ sung **đường dẫn tệp có thật** (`godot/src/presentation/p3/female_normal_v1_motion_library.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`) vào `docs/P3_ASSET_REGISTRY.json`, không sửa gameplay/art. **P3 STATIC AUDIT PASS** [Actions #37897882946](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897882946) tại `cb8d5cfe66c10e47769bf20d9e62e36eeb0ad18a`. Đây là static registry check, **không phải Godot runtime hay Windows PASS**.

**Không có FAIL chưa xử lý trong các job DV2-03 nêu trên:** chúng thực tế completed/success. Các FAIL thời điểm triển khai trước đó đã sửa (giả birth flag, normalize dữ liệu JSON; lỗi test/ownership). **Chưa có full cumulative cùng SHA mới không phải FAIL, chỉ là chưa có bằng chứng**.

### 5.2 Cơ chế đã có code và test focused PASS

- **Sở hữu nhân vật thật:** `DiscipleState.v2_birth_profile` chỉ khởi tạo bằng sinh/recruit V2; `v2_realm_progress` độc lập `cultivation` và `body`, 30 cảnh giới ×10 tầng mỗi đường, 60 tên khóa từ `docs/REALM_LADDER_V2_SPEC.md`. Old saves P0–P3.7 mặc định **không có** progress V2. Không tự biến `cultivation_stage_index`/legacy `combat_power` thành thông số V2.
- **EXP và tăng tầng:** `DiscipleRealmProgressV2.grant_xp` sử dụng **floor_costs được cung cấp hợp lệ**, tăng tầng nhỏ tự động, chặn đại cảnh tại tầng 10. Tu Vi natural = base × (1 + `0,0025 × Tư Chất` + sources hợp lệ), Luyện Thể natural = base × (1 + `0,0020 × Căn Cốt` + sources hợp lệ). Buff cùng channel cộng theo tỷ lệ, không chain-multiply. EXP `fixed` không nhân các nguồn thường. EXP vượt cổng chỉ báo `unapplied_overflow`, không tự đẩy vào `Tích Tu`.
- **Tu Vi đại cảnh:** `attempt_cultivation_breakthrough` thử bằng GameRng/EXP yêu cầu/base chance/điều kiện `requirements_verified`/event_id do consumer được duyệt truyền; thất bại mất **10% EXP yêu cầu** và thêm **5 điểm phần trăm** cơ hội lần sau cho cùng cổng, giữ lifetime history; thành công qua đại cảnh sau tầng 1. Không generic trừ HP/thể lực/cooldown. `auto_breakthrough` chỉ là policy lưu, **không tự thử trong scheduler**.
- **Luyện Thể đại cảnh:** `commit_authorized_body_gate` chỉ commit **khi yêu cầu thực đã được một consumer khác xác minh**; chưa phải hệ vật liệu/xác suất hoặc thất bại thân thể chính thức.
- **Scheduler V2 hiện tại:** Tu Vi dùng passive source + Chuyên Tu. Luyện Thể đã có typed source contract (`production/body_training/expedition`) nhưng **consumer thật chưa nối**; provisional `TRAIN_BODY` vẫn fail-closed cho tới khi có facility/slot/cost consumer. `SectState.v2_training_enabled=false` theo mặc định.
- **Lệnh player:** `DiscipleTrainingActionV2.request_training(state, disciple_id, track)` thực tế xếp action **một lần**, không thưởng tức thì, chặn ngắt `COMBAT`/việc bận và chỉ cho đệ tử được sở hữu, ở tông môn, còn HP. **Đã test API, chưa kết nối UI lệnh V2**: nút “Tu luyện” trên P3.2 hiện là `WorkforceSystem.COMMAND_CULTIVATE` đời cũ.
- **Chống EXP trùng**: cùng 1 disciple/tick **chỉ một action EXP kể cả đổi track**; `last_training_tick` dùng chung hồ sơ + `last_training_event_id` theo từng đường; validate `state.disciples`, đúng action, tick >0. `DiscipleState/SectState` JSON round-trip giữ 2 profile/tầng/EXP/history/policy/rate/ID; test xác nhận không nhận XP hai lần.
- **Tính lại chiến đấu:** `DiscipleRealmProgressV2.derive_stats` dùng hai tọa độ đã lưu + Tiềm Lực vào `CombatStatsV2` (16 combat stats + 10 kháng), `HuntingPveRunV2` không cho caller giả realm. **HP legacy P2 chưa được đồng bộ/migrate an toàn**, chủ đệ tử V2 trong các map proving slice chưa được đưa vào live PvE outside map.

### 5.3 Giới hạn quan trọng, CHƯA code production / CHƯA có bằng chứng

1. **Balance progression production đã khóa trong latest code:** shared 300-floor curve, Tu Vi 1.000/phút, Chuyên Tu ×2, Body reference 250/750/1.500 EXP/phút cho production/expedition/Rèn Thân. Các số 80/50/100 ở test cũ vẫn chỉ là fixture và không phải authority.
2. **Chưa có dữ liệu 29 lần đột phá Tu Vi:** `base_chance` theo cảnh giới, vật liệu/cấm/đan và verifier đầy đủ. **Luyện Thể** chưa có hệ thử đột phá, nguyên liệu, thất bại riêng; chỉ có authorized commit.
3. **Chưa có chạy realtime end-to-end**: scheduler test gọi `step()`, **không đo tick đồng hồ thật 15s**, không có chứng cứ catch-up khi thoát/offline hoặc auto-loop liên tục; `p0_sandbox.gd` còn demo step mỗi ~0,18 giây. Không suy diễn từ “test scheduler PASS” sang “realtime V2 đã chơi được”.
4. **Lệnh V2 chưa nối giao diện P3.2**: mới có API một lần; chưa có policy tự xếp việc rèn thể, UI 2 đường progress/gate, thông báo real-time, hoặc nút đột phá V2. Có thể request trả `ok=true` để xếp hàng nhưng khi `resolve` đến tick gặp `floor_costs` thiếu thì từ chối XP; cần UX báo lý do và kiểm tra trước khi xếp hàng.
5. **Chưa có full cumulative ở SHA code mới nhất** `e96df183` và **chưa Windows real gate**. Kế tiếp cần chạy/kiểm tra full regression sau khi nối source production và UI.
6. **V2 HP persistence/live sync chưa hoàn thành**; stats là nguồn tính ra, nhưng character HP authority game live vẫn có legacy. Bước 3 (10 ô trang bị/12 phẩm, Nhân–Tiên–Thần kỹ năng, Trait/Mệnh/Linh Căn/Huyết Mạch/Thể Chất) là **DESIGN/partial bridge** không tự gọi IMPLEMENTED. Bước 4 mới migrate live group PvE/outside-region map, spawn/AI/5 độ khó và cân lại với đầy đủ buff.

**Thứ tự tiếp theo không đổi:** (1) DV2-02 core DONE → **(2) DV2-03 ACTIVE**: chuẩn hóa dữ liệu EXP/xác suất/Body gate, nối nhịp thật, điều khiển V2, save/realtime, gate → (3) hiệu ứng trang bị/kỹ năng/innate V2 → (4) hoàn thiện PvE map nhóm và cân bằng. Tài liệu triển khai **duy nhất cho DV2-03**: `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`; không làm lại spec đã khóa.

**Danh sách source trọng yếu:** `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `disciple_training_action_v2.gd`, `godot/src/simulation/state/disciple_state.gd`, `sect_state.gd`, `godot/src/simulation/core/simulation_scheduler.gd`, `godot/src/simulation/combat/hunting_pve_run_v2.gd`, `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`, `dv2_03_training_actions_test.gd`, `.github/workflows/dv2-03-realm-body-progress.yml`.


### 5.5 DV2-03C — EXP preflight + catalogue schema (CODE PUSHED, GATE UNVERIFIED)

- `DiscipleRealmProgressV2.grant_xp(..., dry_run=true)` now supports identical read-only validation/preview. Existing commit path remains the default; invalid cost/source numeric types fail closed.
- `DiscipleTrainingActionV2.request_training` validates real rate, floor costs and named EXP modifiers *before* changing `current_action`; rejects malformed input rather than returning false-positive success, while `resolve` rechecks on execution.
- New `DiscipleTrainingContentV2` validates explicitly authored `300 cultivation + 300 body` positive cost entries, rates, version and catalogue identity. `build_rules` is read-only and does not enable production.
- Focused test file and workflow updated for 600 coverage, JSON version normalization, no-mutation preview, bad-rate/duplicated-buff/missing-floor preflight, and earlier scheduler/save/dedup regression.
- **CI/latest code status: CHƯA XÁC MINH.** This is code committed to `main`, not a new claim of Godot PASS. Existing CI #37895517181 focused PASS at older source `e96df183`; full P3.7 #37895357334 PASS still older at `5296f610`. No latest full cumulative/Windows evidence. Recheck official Godot 4.7.2 jobs before closing C.
- Numeric 2×300 EXP/content rates are **not yet approved/activated**; a **comparison-only pacing proposal** was added to `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`. Test fixtures `80/50/100` are NOT balance. No change to `SectState.v2_training_enabled=false` default.
- DV2-03 remains ACTIVE. NEXT: obtain Godot-focused evidence, review/approve EXP pacing, generate and wire 600 production values, then proceed D realtime/AI/offline. Do not start equipment/skills or full-map PvE.


### 5.6 DV2-03M — P2/V2 progression isolation + live HP migration (CODE PUSHED, GATE UNVERIFIED)

**Latest gameplay HEAD for this slice:** `0267eeb80eda0a506329860da31a0bbfba761797` plus later documentation commits only after this section is written. This slice intentionally fixes migration/runtime authority before EXP balance, autonomous Tu Vi/Body policy, realtime/offline or UI.

Implemented:
- One V2 identity boundary: `DiscipleRealmProgressV2.owns_v2_progression()`; mutation APIs require authentic complete V2 birth identity + valid V2 realm profile, not a spoofed realm dictionary.
- `valid_complete_birth()` again validates actual Root/Mutation/Trait/Bloodline/Physique/Destiny structure, while permitting lawful post-birth current-root growth/reveal/awakening state changes.
- Real V2 candidate acceptance creates exactly one two-track realm profile. Temporary **explicit compatibility** maps current P3.7 Luyện Khí stage index 0..8 -> V2 Luyện Khí floor 1..9; Body starts Phàm Thân floor 1. This preserves current new-recruit start semantics only; it is NOT the final V2 starting distribution and does not import P2 EXP/chance tables.
- Pre-DV2-03 saves with complete V2 birth identity but no realm profile migrate once through the same compatibility bridge. A present malformed V2 progress payload is never silently rerolled/reset.
- V2 scheduler cannot fall back to P2 cultivate/breakthrough. Legacy combat wins no longer award P2 cultivation to V2; legacy combat compatibility no longer adds P2 realm power to V2 characters.
- V2 work-time cultivation writes the V2 Tu Vi track using authored current-realm floor costs. In-sect ordinary work/mining, REST and HOLD no longer spend/refill expedition stamina for V2 characters. Legacy characters retain old behavior.
- Old workforce/UI `COMMAND_CULTIVATE` may route to V2 training when content is ready; if V2 training is unavailable it clears/rejects the compatibility command instead of creating an endless HOLD loop or falling back to P2.
- `CombatStatsV2` Realm+Body Max HP is now the live V2 HP authority. Recruitment, floor changes, successful major gates and save/load rescale current HP by ratio; no free full heal on progression.
- Major-gate required EXP now comes from the same authored `floor_costs["realm:10"]` used by floor progression; the second free numeric gate-cost authority was removed for both Tu Vi and Body commit APIs.
- AI no longer exposes/uses P2 cultivation stage/progress for V2. Full autonomous Tu Vi-vs-Body training policy remains deliberately **NOT implemented** in this cleanup slice.

New/updated focused tests:
- `dv2_03_realm_body_progress_test.gd`: recruitment-owned progression, one gate-cost authority, live HP ratio on floor/gate and save/load.
- `dv2_03_training_actions_test.gd`: training uses recruitment-created profile.
- NEW `dv2_03_p2_isolation_test.gd`: malformed birth rejection, old V2 save migration/corrupt fail-closed, no P2 AI/progress/breakthrough/combat realm bonus, V2 work Tu Vi, no in-sect expedition stamina drain/refill, UI cultivate compatibility routing/rejection.
- Focused workflow watches AI/workforce/needs/combat/recruitment/birth-validator and runs all three DV2-03 tests.

**Gate status: UNVERIFIED on latest code.** The available GitHub connector can fetch jobs only when a workflow run ID is already known and its commit-run lookup currently exposes PR-triggered runs, not these push-triggered private-repo runs. Therefore no new Godot PASS is claimed. Previous focused #37895517181 and full #37895357334 are older-code evidence only. Windows remains UNTESTED.

**NEXT only after runtime gate evidence:** DV2-03 autonomous Tu Vi/Luyện Thể policy and real time/offline loop. Do not resume EXP balance, Equipment/Skills/innate effects or expanded PvE before this migration slice is verified.



### 5.7 DV2-03D1 — autonomous Tu Vi / Luyện Thể policy (CODE PUSHED, GATE UNVERIFIED)

**Latest gameplay code for D1:** `60e3da63a3329a8b9f37ce57552895dd95fcc454`. Focused test commit `583270cbd95c8c1fe96e0bfc7efa0ffd3c2e103f`; workflow update `db758a56cdb5f9b97f5cfe3b61930380adf4031d`.

Implemented without adding production EXP numbers:
- Per-disciple persisted policy enum vẫn có `balanced`, `cultivation_focus`, `body_focus`, `manual` để tương thích; **body_focus hiện BLOCKED** vì chưa khóa hoạt động Luyện Thể.
- `DiscipleTrainingPolicyV2.set_policy` changes policy only; it grants no EXP and does not force an immediate action.
- `balanced` has no hidden Tu Vi/Body weighting: lower 1..300 global floor first; if tied, lower authored current-floor progress ratio; exact ties alternate deterministically from simulation tick + stable disciple ID without consuming gameplay RNG.
- Focus policies are priorities, not deadlocks: if the preferred track is full at a major gate or otherwise unavailable, the other valid track may train.
- `manual` blocks autonomous training only; explicit `request_training` remains legal.
- `DiscipleTrainingActionV2.preview_training` is read-only and reuses the same authored rule validation; a full floor-10 gate reports `major_gate_waiting` so AI cannot burn ticks on capped EXP.
- Workforce cultivate schedule slots now consume the same V2 policy. If workforce owns no action, `DecisionSystem` consumes the same policy; no parallel AI formula.
- Policy chỉ được xếp hành động đã có authority; hiện có thể xếp `CULTIVATE`. `TRAIN_BODY` không phải gameplay authority và fail-closed.
- Save/load normalization defaults old valid V2 profiles to `balanced` and persists later player policy.

New focused test:
- `godot/tests/simulation/dv2_03_training_policy_test.gd`: lower-floor/lower-ratio balancing, deterministic tie behavior, focus fallback at full gate, manual mode, no immediate EXP on policy/request, JSON persistence, workforce queue-then-commit, DecisionSystem shared policy.
- `.github/workflows/dv2-03-realm-body-progress.yml` watches the new policy code/test and runs this fourth DV2-03 gate.

**Runtime evidence:** still **MISSING**, not PASS/FAIL. Current connector exposes no push-triggered run IDs/checks for this private repo; commit workflow/status lookup returns empty. Do not claim Godot 4.7.2 PASS for D1 or the preceding DV2-03M code until an actual run/job is available.

**D2 read-only audit result:** current main scene `p3_2_landscape_sect.tscn` inherits `p3_1_landscape_sect.gd`, which always creates `P212Factory.create_state(DEMO_SEED)` and advances `SimulationScheduler.step()` on a **0.55s presentation timer**. P0 sandbox separately advances at **0.18s**. Neither is the requested 15s live authority. `SaveService` can persist `SimulationState`, but the main scene does not currently load a save/runtime state. Therefore offline/catch-up must be attached to a canonical persistent runtime owner, not patched into either demo timer. Existing P3.7 day semantics are 1440 simulation ticks/day; 15s is wall-clock cadence and must not silently redefine sect-day length.

**Next implementation after runtime gate evidence:** D2 persistent clock/runtime owner: 15s wall cadence, saved accumulator/timestamp, pause/resume, backlog-preserving offline catch-up (no dropped-time cap), then benchmark before choosing any performance cap. Daily expedition-stamina reset remains with map runtime per locked Body spec and must not be faked through legacy REST/HOLD.



### 5.8 DV2-03S — source-model refactor: Tu Vi/phút + 1/1 production start (CODE PUSHED, GATE UNVERIFIED)

**User lock 09/10/2026:** 15 giây không phải balance unit. Display/balance uses **Tu Vi per simulation minute**. Existing P3.7 semantics define 1440 scheduler ticks/day, therefore one `SimulationScheduler.step()` is one simulation minute for the current Tu Vi authority. **Luyện Thể action/time unit is NOT locked yet.**

Implemented:
- NEW `DiscipleTuViFlowV2`: authentic V2 disciples receive exactly one natural Tu Vi source per simulation minute whenever V2 progression content is enabled, regardless of ordinary work/travel/hunt/combat/rest/body training.
- `CULTIVATE` is now **Chuyên Tu** only: it applies authored `cultivate_multiplier` to the same natural Tu Vi minute. It no longer grants a second direct cultivation EXP event.
- Training content schema is now version 3: cultivation owns `base_tuvi_per_minute` + `cultivate_multiplier`; Body only carries progression cost authority and `training_mechanic="unresolved"` until Luyện Thể design is approved.
- Passive Tu Vi dedup persists as `last_passive_tuvi_tick`. Provisional `TRAIN_BODY` cannot grant Body EXP; no Body time/rate authority exists yet.
- Authentic V2 ordinary work no longer grants separate work-Tu-Vi. `WorkforceSystem._grant_p3_7_work_cultivation()` returns 0 for V2; legacy path remains unchanged.
- Every **new production V2 recruit** now initializes at **Phàm Nhân tầng 1 + Phàm Thân tầng 1, both 0 EXP**. Tư Chất/Căn Cốt alter growth after recruitment, not starting level. `initialize_recruited_compat` remains only for pre-lock development-save migration.
- `DiscipleTuViFlowV2.preview_rate()` exposes `base_tuvi_per_minute`, `effective_tuvi_per_minute`, natural factor and Chuyên Tu multiplier for future UI without mutating progress.
- Updated focused tests cover 1/1 starts, Tu Vi minute schema, ordinary passive Tu Vi, Chuyên Tu single-source acceleration, no same-minute passive duplicate, **blocked Body training**, no work double-credit, save/load and P2-isolation regression.
- Focused workflow watches `disciple_tuvi_flow_v2.gd`.

**Tinh Nguyên design status:** user locked monster-dropped Tinh Nguyên as a future **fixed +X Tu Vi** consumable/resource source. Exact resource IDs/grades/drop tables/+X values are **not yet authored**, therefore no fake production Tinh Nguyên content was added in this slice.

**Latest runtime evidence:** **MISSING, not FAIL.** Available connector still returns no push-triggered workflow run/check for the new commits. Previous focused/full runs remain older-code evidence and do not prove DV2-03S. Windows is UNTESTED.

**Still OPEN:** consumer thật cho Rèn Thân (facility/slot/cost), danh sách nghề nặng, expedition pressure/content scaling, material package cụ thể cho Body gate, consumable modifier cho Tu Vi gate, persistent live runtime/offline catch-up và V2 UI.


### 5.9 DV2-03B2 — Luyện Thể typed source contract (CODE PUSHED, GATE UNVERIFIED)

**User lock 09/10/2026:** natural Luyện Thể has three distinct contexts: **Sản xuất / Rèn Thân / Viễn Chinh**. Rèn Thân is per simulation minute and will use a real future training facility with selectable intensity/grade; higher grade may raise EXP and cost. Exact building/content/cost numbers are not part of this slice.

Implemented:
- NEW `DiscipleBodyXpSourceV2` with source kinds `production`, `body_training`, `expedition`;
- all natural Body sources reuse the canonical Căn Cốt law (+0.20%/point) and typed `body_xp_gain` modifiers;
- production requires verified **active physical work**, not passive assignment/countdown;
- Rèn Thân requires verified training access and proof that the minute's economic cost was committed before EXP can be granted;
- expedition requires verified active outside-map context; it cannot be claimed while in the sect;
- production/Rèn Thân are in-sect sources; expedition is outside-map, preventing overlap;
- **one natural Body source per disciple per simulation minute** via persisted `last_body_xp_tick`;
- fixed +X Body EXP still uses the existing `fixed` grant path and bypasses Căn Cốt;
- provisional `TRAIN_BODY` and `body_focus` remain fail-closed as `body_training_consumer_not_ready` until a real facility/cost consumer is connected;
- new focused test `dv2_03_body_xp_source_test.gd`; workflow updated to watch/run it.

Balance direction only, no numeric table yet: **production < expedition < dedicated Rèn Thân** in normal comparable content. Test rates are fixtures only.

Still deliberately NOT implemented: eligible production-profession list, actual training building/slots, grade count/unlocks, Linh Thạch/material IDs or prices, expedition pressure table, and production Body EXP rates.

**Latest Godot evidence for this slice: MISSING, not FAIL.** Do not call PASS until an official Godot 4.7.2 run for latest code is available.


### 5.10 DV2-03B3 — canonical progression + 29 major gates (CODE PUSHED, GATE UNVERIFIED)

**Canonical balance now exists in code:**
- `DiscipleProgressionBalanceV2`;
- shared Tu Vi/Luyện Thể 300-floor EXP curve;
- realm totals r1..r30: `10,000,000` -> `10,240,200,000`, ~1.27 realm growth, exact integer table frozen;
- floor weights: `0.70 / 0.75 / 0.80 / 0.85 / 0.90 / 1.00 / 1.10 / 1.20 / 1.30 / 1.40`;
- Tu Vi base = **1,000/minute**;
- Chuyên Tu = **×2.0**;
- Body reference rates = **250/min production, 750/min expedition, 1,500/min dedicated Rèn Thân**;
- cumulative EXP through realms 10/20/30 = **367,400,000 / 4,376,300,000 / 48,130,600,000**.

**Canonical major gates now exist in code:**
- `DiscipleBreakthroughBalanceV2`;
- 29 Tu Vi base chances:
  `100,95,90,85,80,75,70,65,60,50 / 90,85,80,75,70,65,60,55,50,35 / 80,75,70,65,60,55,50,45,35`%;
- same-gate pity remains +5 percentage points/failure;
- Tu Vi failure remains −10% floor-10 EXP requirement; no generic HP/Stamina/cooldown penalty;
- all 29 Luyện Thể gates are deterministic: full floor-10 EXP + externally verified Thối Thể requirements -> 100% next realm;
- no Body RNG/pity/failure loss.

Production wrappers now use canonical tables:
- `attempt_canonical_cultivation_breakthrough()`;
- `commit_canonical_body_gate()`.

Focused tests added:
- `dv2_03_progression_balance_test.gd`;
- `dv2_03_breakthrough_balance_test.gd`.

**Not implemented here:** Tu Vi breakthrough pills/material consumers, exact Thối Thể material packages, Rèn Thân building/content, profession eligibility and expedition pressure tables.

**Latest runtime evidence:** MISSING, not FAIL. Do not call latest DV2-03 PASS until official Godot 4.7.2 evidence exists.


### 5.11 DV2-03D2 — persistent online/offline clock owner (CODE PUSHED, GATE UNVERIFIED)

Implemented:
- `SimulationState` persists `runtime_clock_version`, `runtime_last_wall_unix`, `runtime_unconsumed_wall_seconds`;
- `SimulationRuntimeClockV2`: **60 real seconds = 1 simulation minute**, same scheduler for online/offline;
- sub-minute remainder survives save/load;
- bounded catch-up preserves unprocessed whole-minute backlog;
- backwards wall clock grants no progression;
- `SimulationRuntimeOwnerV2` owns state+scheduler, catches up before save and after load;
- old saves without timestamp initialize at first upgraded load with no speculative past credit;
- `dv2_03_runtime_clock_test.gd` compares offline 5-minute jump vs five online one-minute advances and checks identical V2 progression/RNG, chunked catch-up and owner save/load.

**Superseded 10/10/2026 by §5.12:** the P3 live scene is now connected to the persistent runtime owner and the 0.55s simulation loop has been removed.


### 5.12 DV2-03D3 — STEP 1 LIVE RUNTIME INTEGRATION (FOCUSED PASS)

**Implemented 10/10/2026:**
- `LiveGameRuntimeV2` is now the live-game bootstrap over `SimulationRuntimeOwnerV2`;
- new game uses `P37Factory`, enables authentic future V2 recruitment and canonical V2 progression rules, then persists immediately;
- valid save loads before catch-up; corrupt existing save fails closed without overwrite;
- P3.1/P3.2 now use the runtime-owned state and no longer create a fresh `P212Factory` demo state;
- removed presentation-only two-disciple demo recruitment/capacity mutation;
- removed the old **0.55s = scheduler.step()** main-scene loop;
- main scene polls wall clock every 1s, autosaves every 15s, saves on pause/exit and catches up on resume; these polling/save cadences do not change the canonical **60 real seconds = 1 simulation minute** rule;
- test save path is isolated by ProjectSettings override;
- stale breakthrough test call was corrected to the already-canonical single `floor_costs` authority; no gameplay formula was changed.

**Official Godot 4.7.2 Linux evidence:**
- DV2-03 focused [#38037470018](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037470018), code SHA `35dd076db146370e6fbadb4cd2d9ee0a9994f642`: **PASS**. Project parse plus all focused progression, action, P2/V2 isolation, policy, Body source, canonical balance/gates, online/offline clock, live save/load and P3 binding steps succeeded.
- P3.6A Preview [#38037339761](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037339761), SHA `20ff9686464b09493adc2e4af740a10080d97333`: **PASS** with the live wall-clock contract.
- P3.7 Backend [#38037386848](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037386848), SHA `150be2aeaf5c7092f594850bdffa2e349f7c03cf`: **PASS** both latest FAST backend gate and **FULL cumulative P0→P3.7 gate** on official Godot 4.7.2 Linux. Commits `20ff968`→`150be2a` after the runtime production code are test-only corrections, so this run exercises the same Step-1 gameplay/runtime implementation.
- Windows Godot 4.7.2 live/visual gate remains **UNTESTED**.

**Step 1 result:** persistent P3 state + real save/load + wall-clock/offline catch-up is connected. **Step 2 presentation snapshot/profile integration is now also focused PASS; see §5.13.** DV2-03 remains ACTIVE because the real Rèn Thân/body consumer and later effect consumers are still incomplete.

### 5.13 DV2-03E1 — STEP 2 UNIFIED DISCIPLE PRESENTATION SNAPSHOT (FOCUSED PASS)

**Implemented 10/10/2026:**
- NEW `DisciplePresentationSnapshotV2` is the read-only presentation authority for one disciple;
- snapshot explicitly separates `authentic_v2` from `legacy_compatibility`;
- authentic V2 UI reads immutable/current identity, six foundations, Tu Vi + Luyện Thể, live HP/Expedition Stamina, CombatStatsV2 Realm+Body+Potential core, work/profession state, learning/equipment compatibility records and relationships from one normalized surface;
- hidden latent Trait, unrevealed Root Mutation, Bloodline, Physique and Destiny are redacted; no hidden ID/purity/provenance leaks to UI;
- authentic V2 with malformed progression **fails closed** and does not fall back to P2 cultivation/combat;
- authentic V2 Combat snapshot deliberately applies **no Equipment/Trait/Bloodline/Physique sources yet** because their V2 effect consumers are not implemented;
- P3.2 summary, deep status and tabs Thuộc tính/Công pháp/Trang bị/Huyết Mạch/Thể Chất/Quan hệ now branch through the snapshot;
- authentic V2 no longer shows or accepts legacy P2 `Thức tỉnh/Luyện huyết/Tôi thể/Cải thể` actions;
- V2 UI labels Stamina correctly as **Thể lực viễn chinh** and shows both Phàm Nhân/… Tu Vi and Phàm Thân/… Luyện Thể tracks;
- legacy P3.2 behavior remains explicitly compatibility-only and was regression-tested using a generated P3.7 legacy fixture plus canonical Warehouse resources.

**Official Godot 4.7.2 Linux evidence:**
- DV2-03 focused [#38038834727](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038834727), SHA `5ecb3bbeb7d1adc7644a9aecc3b805d0fc6bb3fa`: **PASS**. Project parse and all prior DV2-03 gates plus:
  - unified disciple presentation snapshot;
  - authentic V2 disciple profile UI;
  - legacy P3.2 disciple UI compatibility.
- P3.6A Preview [#38038282452](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038282452), production UI SHA `85639c14c5ff699f230e7ae5a713b32e54fca7d5`: **PASS**.
- P3.6A Preview [#38038535562](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038535562), test-hygiene SHA `eb620ecbffc33d2fbc8efe2c86eadd3693e804ba`: **PASS** after synthetic-clock exit-save noise cleanup.

**WINDOWS / USER VALIDATION: PENDING — CHƯA CHẠY.**
- User has not yet run Step 2 on Windows Godot 4.7.2.
- Therefore **Windows PASS / VISUAL ACCEPTED are NOT claimed**.
- When the user is at the computer, stable repo checks are:
  - `Sync-Main.cmd Verify-P3-6A-Playable-Slice.cmd`;
  - `Preview-P3-6A-Playable-Slice.cmd` for visual inspection.
- Authentic-V2-specific profile correctness already has Linux headless coverage; final player-facing visual acceptance remains user-owned.

**Step 2 result:** one canonical, non-leaking presentation snapshot now feeds the disciple UI. This does **not** mean Root/Trait/Destiny/Bloodline/Physique/Equipment effects are implemented; inactive identities remain shown honestly as unavailable. DV2-03 remains ACTIVE.

### 5.14 DV2-03P1 — REAL P3.7 ACTIVE MINING BODY EXP (FOCUSED PASS, 10/10/2026)

**Current active implementation phase remains DV2-03, NOT CLOSED.** Source Unity is benchmark only; gameplay authority remains this repository's V2 design and runtime.

The actual P3.7 mining action now consumes the previously locked `DiscipleBodyXpSourceV2` accounting contract:
- Only an authentic V2 disciple performing the `WORK_MINING` action, with a valid real Mine worker slot and a successfully executed `mining` (extraction) phase, receives the canonical 250 base Body EXP per simulation minute before Căn Cốt (+0.20%/point).
- `travel_out`, `haul_back`, passive assignments, non-mining professions, legacy/P2 profiles and blocked jobs do NOT earn this Body source.
- The runtime uses the existing canonical Body floor-cost rule, per-disciple/per-minute dedup and the existing HP-rescale-on-floor implementation. No second Tu Vi reward or expenditure of Expedition Stamina is added. Training sources other than the valid mining action remain unchanged.
- `WorkforceSystem._perform_p3_7_mining` is the integration owner, using the real result of `BuildingSystem.perform_mining_step`. The focused integration test exercises real Mine phases, worksite assignment, correct source rate/foundation modifier, non-mining exclusion and saved dedup identity.
- Gameplay latest SHA: `e8f571533846453b7e2f40bab8c5e7f306d6e1fc`; latest focused test/source SHA: `efd4f8005dcdb6bf9c376da75c6c416ef8efe4c4`.
- **Official Godot 4.7.2 Linux focused PASS:** [DV2-03 #38064309354](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38064309354) at `efd4f800`. It includes project parse, all existing DV2-03 focused tests and new `dv2_03_mine_body_xp_integration_test.gd`.
- **Not yet claimed:** FULL cumulative on this new gameplay SHA; Windows runtime/visual acceptance.

**Superseded by §5.15:** the user approved dedicated Rèn Thân Đường, two Lv1 slots, 1 Sect Spirit Stone/min and 1,500 base Body EXP/min on 10/10/2026. These decisions are now implemented and focused-tested; only the remaining unlocked content/visual gates are open.

**Do not open DV2-04/full Equipment/Skill/UI production phases while DV2-03 is active.**

### 5.17 DV2-03E3 — MAP RÈN THÂN ĐƯỜNG TWO SLOT MANAGEMENT (10/10/2026)

**USER REQUEST IMPLEMENTED IN CODE:** separate map-clickable `Rèn Thân Đường` token and `TRAIN_BODY` actor destination; the P3.2 real management panel reads Lv1 **2 actual slots**, current Sect Spirit Stones, **1 stone/active minute**, **1,500 base Body EXP/min**, committed minutes/stone-spend from the building production state, per-disciple action/scheduler result. Two real worker IDs are shown, not any demo recruits. Player may assign a genuine V2 disciple to a free slot (via existing approved V2 reserve + `request_training`) and explicitly release that slot for another disciple (manual training policy, no refund for past minutes). Button press never debits stones/grants XP. No fake item/warehouse or economy. Only first 12 eligible V2 roster rows are presented in this slice, not a claimed 3,000-disciple browse UX.

**Focused evidence:** official Godot 4.7.2 Linux [DV2-03 #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) at gameplay source `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`: **PASS**, including `dv2_03_p3_body_training_building_ui_test.gd` (real map token, two real assignments, overcapacity denied, release/reassign, one paid Body minute, save/load), existing focused and legacy profile gates. **P3.7 FAST + FULL cumulative:** [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594) at same gameplay SHA **PENDING at this writing**, not assumed green. P3.6A earlier preview run had artifact-storage quota failure; do not confuse artifact upload with Windows visual PASS.

**Not yet approved / not implemented:** 29 exact Thối Thể recipes/consumable gate transaction, post-Lv1 building upgrade/intensity, large-roster UI search/pagination, Dẫn Tiên real recruitment UI, Windows visual. DV2-03 remains ACTIVE, never call game playable complete or Windows PASS. See `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` §DV2-03E3.

### 5.16 DV2-03E2 — PLAYER-FACING V2 TWO-TRACK TRAINING UI (10/10/2026)

**ACTIVE phase still DV2-03, not CLOSED.** In the main P3.2 Godot disciple profile, authentic V2 can now select **Chuyên tu** or **Rèn thân** from the attributes tab, and the map-side summary uses V2 request/preview for Chuyên Tu and offers the V2 Rèn Thân shortcut instead of the old P2 forge shortcut. P2 legacy behavior remains separate.

The new route is **UI → existing V2 command boundary → SimulationScheduler**; it never mints immediate XP, pays an economic cost on button press or uses P2 cultivation authority. Rèn Thân reservation checks existing runtime's real building/2 slots, no action interruption, same Sect Spirit Stones and major-gate availability before changing work assignment. On successful request only, update persisted policy and clear stale direct command; on rejection show reason, including no Spirit Stone, no building/slot, active Spirit Field plot or busy work. The panel keeps real action feedback through its own redraw. See `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` §DV2-03E2.

**Evidence at UI source SHA `ca2f3077d2c2e6d89cb8e11924e7c89fe95e09f9`:**
- [Focused #38068119502](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119502) **PASS** on official Godot 4.7.2 Linux, including updated `dv2_03_p3_v2_disciple_profile_test.gd`. An initial test on earlier UI SHA `1a68f2e9` exposed a real cleared-feedback bug, which has been corrected and verified green; do not cite the earlier failure as latest.
- [P3.6A #38068119466](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119466) **PASS** on same UI SHA.
- [P3.7 FAST/FULL #38068119472](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119472), same UI source, **PENDING at checkpoint update**. Subsequent documentation/workflow commits change HEAD but not gameplay source.
- **Windows visual/live gate NOT RUN; user currently does not need to open PC.**

**Remaining DV2-03 slices:** Rèn Thân Đường map-clickable UI + 2-slot/treasury panel, exact user-approved Thối Thể materials/requirements, major-gate real content consumer, then full release/Windows validation. Dẫn Tiên recruitment/visible disciple and production UX is the next playable-loop priority **after** DV2-03 is closed; do not assert it exists on UI yet. The locked canonical 29 Tu Vi chances / 29 deterministic Body gates already exist; avoid inventing ingredient recipes.

### 5.15 DV2-03P2 — RÈN THÂN ĐƯỜNG REAL PAID CONSUMER (FOCUSED PASS, 10/10/2026)

**User choice: A LOCKED.** Dedicated `Rèn Thân Đường`, two Lv1 training slots, one **Sect Spirit Stone per active simulation minute**, 1,500 **base Body EXP/minute** before Căn Cốt. Canonical Tu Vi natural gain continues independently; no in-sect Expedition Stamina spent. Building uses existing P3.7 BuildingState/Workforce assignment and the Sect Spirit Stone wallet; there is no second warehouse or fabricated economy.

Implemented on live `main`:
- `BuildingSystem.TYPE_BODY_TRAINING` and an idempotent `ensure_body_training_facility`, invoked by `LiveGameRuntimeV2` for new and existing live V2 saves. Old P3.7 backend factories are not silently given a new V2 feature.
- A dedicated `DiscipleBodyTrainingFacilityV2` with explicit `reserve_slot`, real Lv1 two-slot capacity/authorization, read-only EXP/cost preview, fail-closed when busy/upgrading/missing/unavailable/at major gate, one-minute treasury debit **before** `DiscipleBodyXpSourceV2.commit_minute`, exact rollback on commit failure, persisted paid-minute/stone counters, existing per-minute Body dedup and HP stat recalculation.
- Slot checks are blocked for disciples reserved by active Linh Điền plots; non-trainees are rejected in O(1) before expensive roster-wide slot scans (important for 1,000–3,000 scale).
- `DiscipleTrainingActionV2` now supports legitimate body `preview_training`/`request_training`/`resolve`. `SimulationScheduler` routes `TRAIN_BODY` through that one consumer. `DiscipleTrainingPolicyV2.body_focus` can select it with a reserved slot/affordable cost; otherwise chooses legitimate Tu Vi fallback.
- Only an approved basic intensity is active. Building max Lv100 preserves generic identity, but **upgrade recipe / post-Lv1 slot scaling remain BLOCKED** until authored; no arbitrary rates or grade levels added. 29 exact Thối Thể material packages remain unapproved/blocked. Expedition pressure source and other heavy jobs also remain unconnected unless context verified.
- New integration test `godot/tests/simulation/dv2_03_ren_than_duong_integration_test.gd` checks 2 slots/third rejected, live economic debit and expected Căn Cốt, dedup, player commands, policy selection, scheduler action, save/load and insufficient-stone failure. Mining focused test remains active.

**Latest focused verified:** [DV2-03 official Godot 4.7.2 Linux #38066113278](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38066113278), gameplay SHA `6e10aca2d105f23f026a216f3404e5f9bbbbdf6d`, **PASS all DV2-03 focused tests**, including Rèn Thân, active Spirit Field plot mutual exclusion, fast reject of non-trainees, mining and presentation integrations.

**Full cumulative required for phase close:** [P3.7 Backend #38065668233](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38065668233) **PASS at earlier implementation SHA** `0be59f86`; **latest** [#38066113295](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38066113295) at gameplay SHA `6e10aca2` **PASS both P3.7 FAST and FULL P0→P3.7 cumulative** on official Godot 4.7.2 Linux. This is the same source as focused #38066113278. Windows Godot 4.7.2 live/visual remains **UNTESTED**, and unapproved Body gate/resource content remains BLOCKED.

**Next priority:** verify cumulative gate, update status evidence; then implement next user-approved playable disciple/recruitment UI phase while maintaining one phase at a time. The P3 map does not yet expose a dedicated Rèn Thân Đường clickable building or player-facing assignment panel, and full V2 UI closure has not been claimed.

### 5.4 Chuẩn bị lát triển khai tiếp theo — audit 09/10/2026

**DV2-03 vẫn ACTIVE — chưa có code gameplay/gate mới trong lượt chuẩn bị này.** GitHub `main` đã được rà: action `request_training` kiểm tra sơ bộ nhưng không preflight `base_xp_per_action`/`floor_costs`; do đó có thể trả `ok=true` để xếp việc, rồi `resolve` fail-closed ở tick sau. Scheduler `step()` làm chủ cấp EXP, không phải driver wall-clock được chứng thực. Workflow focused của code `e96df183` PASS; FULL P3.7 chỉ có bằng chứng PASS tại `5296f610`. **Không có bằng chứng full same-code SHA hay realtime 15s/offline/Windows V2.**

**Kế hoạch thực thi có thể làm ngay trong cùng DV2-03** (chi tiết đã lưu vào `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`): C — EXP production/validator + preflight command; D — driver 15s live, AI policy, save/catch-up không trùng; E — UI hai đường P3.2; F — dữ liệu 29 cổng Tu Vi, Luyện Thể riêng, HP V2 sync; G — focused/full regression và benchmark roster. EXP/chance/item chưa duyệt **không tự đưa vào code**. DV2-02 core giữ nguyên, chưa sang trang bị/kỹ năng/innate/PvE map production.


---

## 6. Disciple V2 design authorities prepared

Canonical design carryover files now exist:
- `docs/DISCIPLE_V2_DESIGN_LEDGER.md` — locked lục-duy/Dẫn Tiên rules, one-disciple-forever nurture law, pill satiety, future breakthrough rule, and distilled lessons from 《最强祖师》;
- `docs/DISCIPLE_V2_ROADMAP.md` — full disciple subsystem map, dependencies and preferred discussion order;
- `docs/DISCIPLE_MASTER_SCHEMA.md` — whole-person generation and fixed/update ownership.

These docs are design authorities, not implementation PASS evidence.

## 7. Disciple V2 design queue

Spiritual Root V2 **full design is locked, not implemented**.

Canonical design:
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`.

Locked design covers:
- five base roots and 1–5 birth distribution;
- per-element purity 1–100;
- base cultivation/mastery/combat buffs;
- element-specific permanent passives;
- perfected-root Resonance through full five roots;
- elemental counter core;
- deterministic refinement and missing-root transformation;
- 0.20% congenital Dị-Linh-Căn model;
- Lôi/Phong/Băng/Dương/U Minh V1;
- Thức Tỉnh → Thuế Biến → Viên Mãn progression and five matching Bản Nguyên resources;
- combat mechanic timing/proc/AoE/multi-hit/basic-attack/boss/team/AI rules;
- cả năm Dị Căn Viên Mãn Ngũ Dị Quy Nhất;
- persistence/resource-source/migration/test contracts.

Important dependency:
mutation combat requires Skill/Combat V2 primitives that do not all exist in live runtime yet.
Do not invent temporary root-only Crit/Effect-Hit/DoT/control/stat authority.

**Lưu ý design:** phần Spiritual Root V2 ở đây là thiết kế; phase đang triển khai là **DV2-03**. Consumer Linh Căn V2 chưa được nghiệm thu, không triển khai vượt phase.

Legacy-cleanup note:
- the old P2.10 Spiritual Root design document has been removed because Spiritual Root V2 is the sole design authority;
- old `spiritual_root_system.gd` / `root_refinement_system.gd` remain temporarily only because locked P2 regressions and old-save migration still consume them;
- those legacy scripts are not V2 design authority and must not be extended for new Spiritual Root gameplay;
- dead legacy runtime may be physically removed only inside a tested V2 migration phase.

**Trạng thái đúng:** Combat Stats V2 đã **CODE + FOCUSED PASS trong lõi DV2-02**; phần dưới chỉ ghi quyết định thiết kế. Phần consumer live character/PvE vẫn chưa hoàn tất.

Canonical authority:
`docs/COMBAT_STATS_V2_SPEC.md`

The locked registry is:
- Max HP / Attack / Defense;
- Movement / Basic Attack / Cast / Cooldown Recovery;
- Crit Chance / Crit Damage / Crit Resistance;
- Defense Penetration;
- Effect Hit / Effect Resistance;
- Damage Reduction;
- keyed elemental resistances.

No gameplay code was implemented for Combat Stats V2.

Disciple Characteristics & Stat Framework V2 is now **LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md`

Locked framework:
- persistent sources / runtime state / derived channels / contextual outcomes are separate;
- Lục Duy remains the only general permanent foundation-stat block;
- Personality is separate from Trait;
- living state = HP / normalized Thể Lực / named Thương Thế / Tâm Trạng / Trung Thành / Age-Lifespan;
- specialized combat channels include Healing Done / Healing Received / Shield Effect / DoT Potency / Skill Effect / Control Duration and filtered damage/effect channels;
- derived values require deterministic source breakdown and are not independent save truth;
- future Trait/Bloodline/Physique/Mệnh Cách/equipment must consume this authority.

No gameplay runtime code was added for this design lock.

Traits V2 is now **LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/TRAITS_V2_SPEC.md`

Locked highlights:
- ordinary birth-visible Trait count = 1/2/3 at 60/32/8%;
- ordinary latent Trait rate = 8%, max one;
- nature weights = 50% Hữu Ích / 30% Song Diện / 20% Bất Lợi;
- no universal Grade 1–5;
- no lifetime Trait cap;
- deterministic reveal/acquisition/removal;
- no generic removal fail chance;
- Personality and profession talent are separate;
- future-system effects must be consumer-gated.

No Trait V2 runtime code has been added.

Mệnh Cách V2 is now **LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/DESTINY_V2_SPEC.md`

Locked congenital distribution:
- 99.50% none;
- 0.45% latent;
- 0.05% already revealed;
- total **0.50% ≈ 1/200 generated people**.

Locked architecture:
- multiple compatible Mệnh Cách may coexist;
- no Chủ-Mệnh slot and no lifetime hard cap;
- no universal Khai/Hóa/Chứng ladder;
- Mệnh effects are high-impact and build-defining;
- Mệnh Nguyên has first-clear + deterministic repeat acquisition;
- every hậu thiên Mệnh has an explicit feat/event + resource recipe;
- significant-history retroactivity prevents lost-history traps;
- explicit anti-farm attribution and personal Đoạt-Mệnh fragments;
- explicit Mệnh Cục registry and Mệnh Phổ direction.

No Mệnh Cách V2 runtime code has been added.

Huyết Mạch V2 is now **LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/BLOODLINE_V2_SPEC.md`

Locked highlights:
- ordinary congenital distribution = 98.00% none / 1.60% latent / 0.40% revealed;
- ordinary birth has at most one congenital special Bloodline;
- current purity is integer 1–100; birth purity/provenance is preserved;
- awakened purity >=50 derives Chân Huyết; purity 100 derives Phản Tổ;
- no universal lifetime Bloodline hard cap;
- post-birth Ban Huyết / Hoán Huyết / explicit Dung Huyết are supported;
- deterministic +1 refinement with rising resource cost, no diminishing purity gain;
- Huyết Tinh / Tổ Huyết / lineage-specific Huyết Nguyên are the V2 resource concepts;
- five initial lineages: Chân Long / Phượng Hoàng / Bạch Hổ / Huyền Vũ / Thao Thiết Tàn Huyết;
- effects feed canonical V2 channels/mechanics; legacy `combat_power_bonus` is not V2 authority;
- inheritance architecture is reserved, but exact parent-child formula is deferred to Family V2;
- Huyết Mạch Khai Tổ is a future hook only;
- P2.11 is compatibility-only and must not be extended for new V2 gameplay.

No Huyết Mạch V2 runtime code has been added.

Realm Ladder V2 and Luyện Thể V2 core are now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authorities:
- `docs/REALM_LADDER_V2_SPEC.md`;
- `docs/BODY_CULTIVATION_V2_SPEC.md`.

Locked:
- Tu Vi = 30 đại cảnh ×10 tầng = 300 floors;
- Luyện Thể = 30 đại cảnh ×10 tầng = 300 floors;
- three macro bands: Nhân Giới / Tiên Giới / Thần Giới;
- both tracks are independent; row alignment is a content/power-band reference, not a hard equality lock;
- Căn Cốt remains +0.20% natural/base Luyện Thể XP per point;
- Tiềm Lực remains +0.05% retroactive Realm+Body ATK/DEF/HP core growth per point;
- Thể Lực is now explicitly **Expedition Stamina only**;
- ordinary sect production does not consume or read it;
- base daily Expedition Stamina = 100;
- it resets daily without allowing a mid-expedition double-refill exploit;
- normal-map exact body-floor match targets ~18h unbuffed endurance;
- +10 body floors ≈ ×1.20 endurance before cap;
- Luyện Thể alone caps ordinary body endurance at 22h;
- food/pills/facilities/special effects may bridge toward the ordinary 24h expedition cap;
- map body recommendation is soft: undertrained disciples may still enter but sustain shorter trips.

No Realm Ladder V2 or Luyện Thể V2 gameplay code has been added.

Physique / Thể Chất V2 base design is now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/PHYSIQUE_V2_SPEC.md`

Locked:
- no V2 physique grade, purity or `temper_level`;
- ordinary congenital baseline = 97.00% none / 2.70% revealed special / 0.30% latent special;
- one active Core Physique;
- 15 weighted base identities;
- 14 base effect sets use canonical Combat/Root/Expedition channels;
- Kiếm Cốt identity is locked; Combat Skills V2 now defines sword style/weapon-requirement separation and cast attribution, but the effect remains BLOCKED until Weapon + Equipment V2 closes the remaining weapon dependency;
- deterministic Cải Thể / Tái Tạo / Tiến Hóa / Dung Thể architecture;
- no generic fusion blender and no stacking predecessor effects;
- Physique history/provenance is preserved;
- P2.12 is compatibility/migration only and must not be extended.

No Physique V2 gameplay code has been added.

Cultivation + Breakthrough V2 is now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`

Locked highlights:
- minor floors auto-advance without RNG;
- only major-realm gates use breakthrough chance;
- default failure loses 10% gate requirement;
- same-gate failure gives +5 percentage points;
- max 3 breakthrough consumables;
- no generic HP/Stamina/cooldown consequence;
- no generic Tư Chất/Căn Cốt/Cơ Duyên/Root/Physique breakthrough chance;
- auto-breakthrough, Tích Tu/Hậu Tích and special authored breakthrough identities are covered.

No Cultivation/Breakthrough V2 runtime code has been added.

Công Pháp V2 is now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/TECHNIQUE_V2_SPEC.md`

Locked highlights:
- Công Pháp and combat skills are separate;
- 1 Chủ Tu + 2 Phụ Tu active;
- learned inactive techniques retain mastery/history but ordinary effects are inactive;
- Sect transmission through Tàng Kinh Các;
- five personal mastery milestones;
- Sect Nghiên Tu separate from personal mastery;
- authored Diễn Hóa successors/branches;
- personal discovery + Khắc Lục.

No Công Pháp V2 runtime code has been added.

Chủ Đạo / Cultivation Path V2 is now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/CULTIVATION_PATH_V2_SPEC.md`

Locked highlights:
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- branches Ngự/Sát/Hộ, Bá/Kim Cương/Huyết, Ngũ Hành/Y Đạo/Huyền Pháp;
- no class level or generic class-stat growth;
- Đạo Lịch is history, not a generic stat multiplier;
- deterministic Định Đạo / Diễn Đạo;
- switching preserves learned content/mastery/history.

No Chủ Đạo V2 runtime code has been added.

Combat Skills V2 is now **DESIGN LOCKED, NOT IMPLEMENTED**.

Canonical authority:
`docs/COMBAT_SKILLS_V2_SPEC.md`

Locked highlights:
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- slots open gradually through Nhân Giới;
- three-wave lifecycle = Nhân foundation → Tiên evolution → Thần evolution;
- named skill-family successors rather than +level feeding;
- mastery Sơ Học → Nhập Môn → Tiểu Thành → Đại Thành → Viên Mãn;
- Tu Vi / Luyện Thể / Hybrid skill basis;
- priority AI 1→4 with per-skill validity;
- simple distance profiles;
- cooldown/cast/projectile/ICD separation;
- explicit stacking and Nhân/Tiên/Thần effect tiers;
- Ngũ Hành + Tương Sinh cross-class framework;
- party max 6 / hunting cluster max 30;
- 0 HP = Bị Hạ;
- monster/boss use the same combat primitives;
- Kiếm Tu, Thể Tu and Pháp Tu base languages/branches are design-closed.

No Combat Skills V2 runtime code has been added.

Weapon + Equipment V2 **STRUCTURE DESIGN LOCKED, NOT IMPLEMENTED**.

Current canonical design authorities:
- `docs/WEAPON_EQUIPMENT_V2_SPEC.md` — 10 ordinary item slots, 12 phẩm, ordinary/rare stat/individual Chân Văn 6+2+1.
- `docs/EQUIPMENT_SETS_V2_SPEC.md` — 18 combat + 6 work sets, 4 item slots per family, cumulative 2/3/4 and both 3-piece bonuses in 3+3.
- `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md` — source/map **planning only**; one map has 10 specialty clusters, but the proposed 30-main-map content count has NOT independently been approved.

The old "5 ordinary + 3 Phù + 2 Pháp Bảo = 10" and 2/3-set-only direction is **RETIRED**. All gear is Sect-owned. No new Godot implementation was made.

Next design work is the **forge-to-upgrade pipeline**, not Pháp Bảo/Phù. Detailed plan authority:
`docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`.
Approval covers **discussion order only**, not forge/upgrade mechanics, %, rates, level caps or implementation.

## Legacy design-document cleanup — 2026-10-08

Superseded legacy design Markdown files for Cultivation/Root/Công Pháp/Path/Combat Skills/Generation/Traits/Bloodline/Physique have been intentionally deleted from the repository.

Legacy runtime code, factories, tests and gates remain until their explicit V2 implementation/migration phases because they still protect regression and old-save compatibility.

Do not recreate or consult deleted legacy design specs as authority.


## Equipment V2 user-approved structure — 2026-10-08 (DESIGN ONLY)

Canonical: `docs/WEAPON_EQUIPMENT_V2_SPEC.md` and `docs/EQUIPMENT_SETS_V2_SPEC.md`. 10 ordinary slots separate from 3 Phù + 2 Pháp Bảo + 4 consumable positions; 12 grades with max 6 normal stat sub-lines + 2 rare specialized stat lines + one individual Chân Văn; 18 combat and six work sets, four authored pieces each in six eligible set positions, cumulative 2/3/4 stat bonuses, legal 3+3 activates both families; 3-generation set identity; all gear 100% Sect-owned. Sets do **not** generate standalone combat mechanics or a Chân Văn Cộng Hưởng. **No new gameplay runtime, gate or PASS**. Gear numerical values, enhancement cap, crafting/refining costs, loot source probabilities and individual Chân Văn catalog remain OPEN. The 30-map content grid is a proposal, not independently approved.

## Equipment V2 forge/upgrade design queue — DEFERRED on 2026-10-09

The previously approved forging/upgrade discussion order remains preserved at `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` but is **NOT current next-work priority**. User expressly prioritized **a fully functional Disciple V2 character**; Pháp Bảo V2, Phù V2 and additional item design follow later. No forge mechanics/numerical balance/implementation were approved by the plan.


## Priority handoff — COMPLETE DISCIPLE V2 (2026-10-09)

New canonical IMPLEMENTATION **PLAN**, NOT gameplay implementation: `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`. User's priority is **recruit one real whole-person V2 disciple, persist ALL applicable approved visible/hidden identity attributes, derive actual Combat Stats V2 using RealmBodyCore/Tiềm Lực, connect genuine cultivation/work/combat effects, make P3.2 disciple UI read identical authoritative values, and prove deterministic old-save/large-roster tests**. Ordered planning slices `DV2-00` read-only audit → `DV2-01` whole-person birth → derived channels → Realm+Body → Root/Dị → Trait/Destiny → Bloodline/Physique → Techniques/Combat Skills → actual action loop → UI → cumulative/scale gate. Some advanced trigger mechanics depend on common combat event support and must be marked BLOCKED rather than shipped effectless. All earlier equipment/design locks remain; forging, Pháp Bảo, Phù DEFERRED.

**LƯU Ý LỊCH SỬ:** Đoạn roadmap trên được viết trước khi có code V2. Trạng thái hiện tại là **DV2-03 ACTIVE, focused PASS** (xem mục 5). Chat mới tiếp tục DV2-03, **KHÔNG** quay lại DV2-00. P3.2 tab cũ không tương đương UI Tu Vi/Luyện Thể V2 đã PASS.
