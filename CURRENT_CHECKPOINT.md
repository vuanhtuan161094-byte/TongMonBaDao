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

**ACTIVE: DV2-03 — TU VI V2 + LUYỆN THỂ V2.** DV2-01 **CLOSED**, DV2-02 **CORE BACKEND LOCKED** trong phạm vi tính chỉ số/chạy thử chiến đấu nhóm (không phải full PvE ngoài bản đồ). **DV2-03 FOCUSED GREEN, CHƯA BACKEND LOCKED FULL GAMEPLAY.** Không bắt đầu trang bị/kỹ năng/thuộc tính bẩm sinh V2 trước khi xác nhận xong phạm vi giai đoạn 2.

**Lần kiểm tra live main trước bàn giao:** `a3e9b6befee8117c50a797bb35c257acf08d156d` (chỉ là SHA nguồn tại thời điểm kiểm tra, **không phải SHA commit cuối bàn giao**; xem `main` và câu trả lời hoàn tất để lấy HEAD sau các commit tài liệu). **Mã gameplay cuối được thay đổi và kiểm thử focused:** `e96df1832036c1232f9d0db69d1f37450d0265f9`. Tất cả commit tiếp theo cho tới lúc rà soát ban đầu là tài liệu, không thay đổi logic chơi. Không ghi sai SHA code thành SHA HEAD.

### 5.1 Bằng chứng CI và Godot thực tế (trạng thái đã đọc trực tiếp)

| Gate | SHA source kiểm thử | Kết quả |
|---|---|---|
| [DV2-03 focused #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) | `e96df1832036c1232f9d0db69d1f37450d0265f9` | **PASS**: official Godot 4.7.2 Linux; project parse + `dv2_03_realm_body_progress_test.gd` + `dv2_03_training_actions_test.gd` đều success |
| [DV2-03 focused #37895489204](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895489204) | `aa3122a79e31c1d6b78664f3d07dd7dd4de4aa68` | **PASS**: API queue player request; sau đó `e96df183` bổ sung thêm test |
| [P3.7 FULL #37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) | `5296f6106a2fd43d5c1a6f2523854702e9014d63` | **PASS**: fast + full cumulative P3.7, code scheduler V2 theo tick tại SHA đó |
| P3.7 FULL trên **cùng SHA `e96df183`** | **Chưa có bằng chứng run đầy đủ** | **CHƯA KIỂM THỬ** (không suy từ full run cũ) |
| Godot **Windows** trực tiếp/đồ họa P3.2 với V2 | Chưa cung cấp | **CHƯA KIỂM THỬ**, không gọi Windows PASS |

**Không có FAIL chưa xử lý trong các job DV2-03 nêu trên:** chúng thực tế completed/success. Các FAIL thời điểm triển khai trước đó đã sửa (giả birth flag, normalize dữ liệu JSON; lỗi test/ownership). **Chưa có full cumulative cùng SHA mới không phải FAIL, chỉ là chưa có bằng chứng**.

### 5.2 Cơ chế đã có code và test focused PASS

- **Sở hữu nhân vật thật:** `DiscipleState.v2_birth_profile` chỉ khởi tạo bằng sinh/recruit V2; `v2_realm_progress` độc lập `cultivation` và `body`, 30 cảnh giới ×10 tầng mỗi đường, 60 tên khóa từ `docs/REALM_LADDER_V2_SPEC.md`. Old saves P0–P3.7 mặc định **không có** progress V2. Không tự biến `cultivation_stage_index`/legacy `combat_power` thành thông số V2.
- **EXP và tăng tầng:** `DiscipleRealmProgressV2.grant_xp` sử dụng **floor_costs được cung cấp hợp lệ**, tăng tầng nhỏ tự động, chặn đại cảnh tại tầng 10. Tu Vi natural = base × (1 + `0,0025 × Tư Chất` + sources hợp lệ), Luyện Thể natural = base × (1 + `0,0020 × Căn Cốt` + sources hợp lệ). Buff cùng channel cộng theo tỷ lệ, không chain-multiply. EXP `fixed` không nhân các nguồn thường. EXP vượt cổng chỉ báo `unapplied_overflow`, không tự đẩy vào `Tích Tu`.
- **Tu Vi đại cảnh:** `attempt_cultivation_breakthrough` thử bằng GameRng/EXP yêu cầu/base chance/điều kiện `requirements_verified`/event_id do consumer được duyệt truyền; thất bại mất **10% EXP yêu cầu** và thêm **5 điểm phần trăm** cơ hội lần sau cho cùng cổng, giữ lifetime history; thành công qua đại cảnh sau tầng 1. Không generic trừ HP/thể lực/cooldown. `auto_breakthrough` chỉ là policy lưu, **không tự thử trong scheduler**.
- **Luyện Thể đại cảnh:** `commit_authorized_body_gate` chỉ commit **khi yêu cầu thực đã được một consumer khác xác minh**; chưa phải hệ vật liệu/xác suất hoặc thất bại thân thể chính thức.
- **Action thật trong scheduler:** `SimulationScheduler.step()` chuyển hướng action `CULTIVATE` và `TRAIN_BODY` của V2 có opt-in tới `DiscipleTrainingActionV2.resolve`, dùng một nguồn tính EXP, không cấp P2 Tu Vi cùng action. `SectState.v2_training_enabled = false` và `v2_training_rules = {}` theo mặc định. Phải khai báo `authority_id`, đúng action, `base_xp_per_action` dương, floor-costs đủ từ tầng hiện tại tới tầng 10; thiếu nguồn → **FAIL-closed, không cộng EXP**. `TRAIN_BODY` không tự trừ HP/Thể Lực Viễn Chinh.
- **Lệnh player:** `DiscipleTrainingActionV2.request_training(state, disciple_id, track)` thực tế xếp action **một lần**, không thưởng tức thì, chặn ngắt `COMBAT`/việc bận và chỉ cho đệ tử được sở hữu, ở tông môn, còn HP. **Đã test API, chưa kết nối UI lệnh V2**: nút “Tu luyện” trên P3.2 hiện là `WorkforceSystem.COMMAND_CULTIVATE` đời cũ.
- **Chống EXP trùng**: cùng 1 disciple/tick **chỉ một action EXP kể cả đổi track**; `last_training_tick` dùng chung hồ sơ + `last_training_event_id` theo từng đường; validate `state.disciples`, đúng action, tick >0. `DiscipleState/SectState` JSON round-trip giữ 2 profile/tầng/EXP/history/policy/rate/ID; test xác nhận không nhận XP hai lần.
- **Tính lại chiến đấu:** `DiscipleRealmProgressV2.derive_stats` dùng hai tọa độ đã lưu + Tiềm Lực vào `CombatStatsV2` (16 combat stats + 10 kháng), `HuntingPveRunV2` không cho caller giả realm. **HP legacy P2 chưa được đồng bộ/migrate an toàn**, chủ đệ tử V2 trong các map proving slice chưa được đưa vào live PvE outside map.

### 5.3 Giới hạn quan trọng, CHƯA code production / CHƯA có bằng chứng

1. **Chưa có balance EXP production:** thiếu yêu cầu EXP cho **300 tầng × 2 đường**, tốc độ EXP natural/chu kỳ và điều kiện điều chỉnh theo thời gian/trải nghiệm. **80, 50, 100 EXP trong test chỉ là fixture**; tuyệt đối không copy thành luật game.
2. **Chưa có dữ liệu 29 lần đột phá Tu Vi:** `base_chance` theo cảnh giới, vật liệu/cấm/đan và verifier đầy đủ. **Luyện Thể** chưa có hệ thử đột phá, nguyên liệu, thất bại riêng; chỉ có authorized commit.
3. **Chưa có chạy realtime end-to-end**: scheduler test gọi `step()`, **không đo tick đồng hồ thật 15s**, không có chứng cứ catch-up khi thoát/offline hoặc auto-loop liên tục; `p0_sandbox.gd` còn demo step mỗi ~0,18 giây. Không suy diễn từ “test scheduler PASS” sang “realtime V2 đã chơi được”.
4. **Lệnh V2 chưa nối giao diện P3.2**: mới có API một lần; chưa có policy tự xếp việc rèn thể, UI 2 đường progress/gate, thông báo real-time, hoặc nút đột phá V2. Có thể request trả `ok=true` để xếp hàng nhưng khi `resolve` đến tick gặp `floor_costs` thiếu thì từ chối XP; cần UX báo lý do và kiểm tra trước khi xếp hàng.
5. **Chưa có full cumulative ở SHA code mới nhất** `e96df183` và **chưa Windows real gate**. Kế tiếp cần chạy/kiểm tra full regression sau khi nối source production và UI.
6. **V2 HP persistence/live sync chưa hoàn thành**; stats là nguồn tính ra, nhưng character HP authority game live vẫn có legacy. Bước 3 (10 ô trang bị/12 phẩm, Nhân–Tiên–Thần kỹ năng, Trait/Mệnh/Linh Căn/Huyết Mạch/Thể Chất) là **DESIGN/partial bridge** không tự gọi IMPLEMENTED. Bước 4 mới migrate live group PvE/outside-region map, spawn/AI/5 độ khó và cân lại với đầy đủ buff.

**Thứ tự tiếp theo không đổi:** (1) DV2-02 core DONE → **(2) DV2-03 ACTIVE**: chuẩn hóa dữ liệu EXP/xác suất/Body gate, nối nhịp thật, điều khiển V2, save/realtime, gate → (3) hiệu ứng trang bị/kỹ năng/innate V2 → (4) hoàn thiện PvE map nhóm và cân bằng. Tài liệu triển khai **duy nhất cho DV2-03**: `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`; không làm lại spec đã khóa.

**Danh sách source trọng yếu:** `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `disciple_training_action_v2.gd`, `godot/src/simulation/state/disciple_state.gd`, `sect_state.gd`, `godot/src/simulation/core/simulation_scheduler.gd`, `godot/src/simulation/combat/hunting_pve_run_v2.gd`, `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`, `dv2_03_training_actions_test.gd`, `.github/workflows/dv2-03-realm-body-progress.yml`.


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
