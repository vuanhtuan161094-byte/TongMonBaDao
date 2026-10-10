# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

**Bàn giao cập nhật: 10/10/2026 — thực trạng đã đối chiếu trực tiếp live `main`.**

**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **branch:** `main` · **engine:** Godot 4.7.2. **User yêu cầu thao tác bằng GitHub connector trực tiếp; KHÔNG Codex, KHÔNG Work.** Trước mọi sửa đổi phải fetch lại `main` vì SHA sẽ thay đổi sau các commit bàn giao. **SHA latest đã qua DV2-03 focused Step-2 test:** `5ecb3bbeb7d1adc7644a9aecc3b805d0fc6bb3fa`. Các commit sau đó chỉ cập nhật tài liệu/checkpoint; fetch live `main` trước khi sửa tiếp.

## ACTIVE PRIORITY UPDATE — 10/10/2026, DV2-03P2 (FOCUSED PASS)

**Explicit user choice A implemented:** Rèn Thân Đường is a separate V2 P3.7 building, Lv1 **two slots**, exactly **1 Sect Spirit Stone per actual paid training minute**, 1,500 **base Body EXP/minute** before Căn Cốt +0.20%/point. This is not a Tu Luyện Đài shared slot. New/live V2 worlds get the facility via idempotent `LiveGameRuntimeV2` bootstrap; old P3.7 fixtures are preserved. Player can explicitly reserve a slot with `DiscipleBodyTrainingFacilityV2.reserve_slot`; `DiscipleTrainingActionV2.request_training(...,"body")` queues the real `TRAIN_BODY` action; `SimulationScheduler` commits a minute only after the existing Sect Spirit Stone wallet has been debited, and refunds on failure. `body_focus` policy now chooses valid paid Rèn Thân, otherwise legal Tu Vi fallback. Sources remain one natural Body EXP/disciple/minute; no Expedition Stamina spent inside the sect.

**Official focused Godot 4.7.2 Linux PASS:** [run #38066113278](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38066113278) at gameplay SHA `6e10aca2d105f23f026a216f3404e5f9bbbbdf6d`, includes existing DV2-03 focused checks plus `dv2_03_ren_than_duong_integration_test.gd` and real active-mining Body XP integration. **P3.7 FAST/FULL gate:** [#38065668233](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38065668233), same gameplay code at workflow commit `0be59f86`, **PENDING at this handoff write**. Do not assert full cumulative green before fetching real results.

**Still blocked/next:** Rèn Thân post-Lv1 upgrade numbers and intensity tiers, exact 29 Thối Thể requirement packages, some future physically demanding production professions and expedition context, and the Rèn Thân UI map token/panel. **Windows user live/visual test NOT RUN.** UI recruitment Dẫn Tiên → accept → visible disciple → production is the next gameplay experience goal but must not be called implemented now. Current DV2-03 phase remains ACTIVE until closure criteria are verified.

**Unity benchmark rule:** Tông Môn Bá Đạo's own canonical runtime/specs are sole gameplay authority. Unity client is only benchmark/pattern/bug-finding reference, not formula owner.

## TRẠNG THÁI HIỆN TẠI — đọc mục này trước, không áp dụng các lịch sử bên dưới

- **Giai đoạn ACTIVE duy nhất: DV2-03 — Tu Vi và Luyện Thể V2.** DV2-01 birth **CLOSED**; DV2-02 combat/group PvE **CORE BACKEND LOCKED** *trong phạm vi stat/encounter proving*, **không phải live PvE hoàn tất**.
- **DV2-03M migration cleanup đã CODE trên main, CHƯA được gọi PASS trên code mới:** authentic V2 không fallback P2; live V2 HP ratio preservation; one floor-10 gate-cost authority; malformed saved V2 progress fail-closed. **Starting rule has since changed:** all NEW production V2 recruits now start Phàm Nhân 1 + Phàm Thân 1, both 0 EXP. The old Luyện Khí-index bridge remains development-save migration only.
- **LATEST LUYỆN THỂ (supersedes older notes):** `production` (real active mining) and `body_training` (real 2-slot paid Rèn Thân Đường) NOW HAVE CONSUMERS and focused Godot evidence in the priority section above. `TRAIN_BODY` and `body_focus` are real when access/cost verified; not generally free/automatic. `expedition` remains typed source-only until outside-map ownership is authorized.
- **LATEST Luyện Thể source contract:** one natural Body source/disciple/minute. Canonical references = **250 production / 1.500 dedicated Rèn Thân / 750 expedition EXP per simulation minute** before Căn Cốt/modifiers. Rèn Thân still requires a real facility/slot + committed minute cost.
- **STEP 1 RUNTIME INTEGRATION COMPLETE / FOCUSED PASS:** `LiveGameRuntimeV2` now boots/loads `P37Factory` live state through `SimulationRuntimeOwnerV2`; P3.1/P3.2 use that exact runtime-owned state. Old fresh `P212Factory` scene state, two-disciple demo recruitment and 0.55s `scheduler.step()` timer are removed. Polling UI every 1s and autosave every 15s do not alter authority: **60 real seconds = 1 simulation minute**. Save/load/offline, corrupt-save fail-closed and P3 binding are covered by latest focused tests.
- **STEP 2 DISCIPLE PRESENTATION SNAPSHOT COMPLETE / FOCUSED PASS:** new `DisciplePresentationSnapshotV2` is the single read-only UI snapshot. Authentic V2 uses `v2_birth_profile` + `v2_realm_progress` + `CombatStatsV2`; hidden Trait/Mutation/Bloodline/Physique/Destiny does not leak; malformed V2 progression never falls back to P2; P3.2 summary/status/tabs branch through snapshot; legacy P2 Bloodline/Physique buttons/actions are hidden/blocked for authentic V2 while legacy compatibility remains tested.
- **Historical Step-2-only focused evidence:** [DV2-03 #38038834727](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038834727), SHA `5ecb3bbeb7d1adc7644a9aecc3b805d0fc6bb3fa`, official Godot **4.7.2 Linux**, **PASS all focused steps**, including prior progression/runtime gates + unified presentation snapshot + authentic V2 profile UI + legacy P3.2 compatibility. P3.6A production UI [#38038282452](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038282452) **PASS**; cleanup rerun [#38038535562](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38038535562) **PASS**.
- **WINDOWS / USER VALIDATION: PENDING — CHƯA CHẠY.** User has not yet run Step 2 on Windows Godot 4.7.2, so do not claim Windows PASS or VISUAL ACCEPTED. When user is at the PC: `Sync-Main.cmd Verify-P3-6A-Playable-Slice.cmd`, then `Preview-P3-6A-Playable-Slice.cmd` for visual review.
- **Latest cumulative evidence for Step 1:** [P3.7 Backend #38037386848](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38037386848), SHA `150be2aeaf5c7092f594850bdffa2e349f7c03cf`, official Godot **4.7.2 Linux**, **FAST + FULL cumulative PASS**. This SHA contains the same Step-1 production runtime code; subsequent `35dd076` change is test-only.
- **DV2-03D1 policy scaffolding đã CODE nhưng CHƯA PASS latest runtime:** enum còn balanced/cultivation_focus/body_focus/manual; **body_focus hiện BLOCKED vì facility/cost consumer chưa tồn tại**, không phải vì source model chưa khóa.
- **DV2-03S Tu Vi source model đã CODE, runtime gate chưa xác minh:** natural Tu Vi mỗi phút mô phỏng; `CULTIVATE` = Chuyên Tu. Canonical balance now sets **1.000 Tu Vi/phút, Chuyên Tu ×2**. New recruit = Phàm Nhân 1 + Phàm Thân 1, 0/0 EXP.
- **Đơn vị balance/display:** Tu Vi/phút mô phỏng; typed natural Body sources cũng chuẩn hóa theo Body EXP/phút mô phỏng. 15s không phải balance law.
- **Đã CODE và focused Godot 4.7.2 Linux PASS:** hai hồ sơ Tu Vi + Luyện Thể V2 thật và độc lập (mỗi đường 30 đại cảnh × 10 tầng), đúng 60 tên đã khóa; EXP natural Tu Vi +0,25%/Tư Chất và Luyện Thể +0,20%/Căn Cốt, buff nguồn được nhận dạng rõ trên đúng channel; thưởng EXP fixed không nhân; EXP qua đủ tầng nhỏ tự tăng, tầng 10 dừng trước đột phá. `derive_stats` tính lại 16 combat stats + 10 kháng từ hai đường và Tiềm Lực, săn quái V2 không nhận cảnh giới giả.
- **Major gate balance đã khóa trong latest code:** 29 Tu Vi base chances chính thức + pity +5 điểm %/fail + −10% gate EXP on fail; canonical wrapper dùng đúng shared floor-cost table. Luyện Thể cả 29 gate deterministic: full gate EXP + verified Thối Thể requirements -> 100% advance, no RNG/pity/fail loss. Material packages/consumable consumers remain future content.
- **Progression balance latest (CODE + focused PASS):** shared 300-floor curve for Tu Vi + Body; totals r1 10,000,000 -> r30 10,240,200,000; natural Tu Vi 1.000/min, Chuyên Tu ×2; `LiveGameRuntimeV2` enables canonical V2 rules for the live state while authentic ownership still prevents legacy disciples from receiving V2 progression.
- **Đã CODE + focused PASS ở API lệnh người chơi:** `DiscipleTrainingActionV2.request_training(state, disciple_id, track)` xếp **một lần** activity, không tức thì cộng EXP và không ngắt đánh nhau/việc bận. **Chưa nối API này tới UI P3.2**; nút “Tu luyện” trong scene P3.2 vẫn qua `WorkforceSystem.COMMAND_CULTIVATE` legacy, không có nút Luyện Thể V2 thật.
- **Realtime now connected:** persistent live runtime owner + wall-clock mapping + offline catch-up + save/load are connected to P3.2 and focused PASS. **Still missing:** Windows live/visual evidence and V2-specific presentation/UI surfaces.
- **Số cân bằng progression chính thức đã có:** shared 300-floor curve, Tu Vi 1,000/min, Chuyên Tu ×2, Body reference 250/750/1,500, 29 Tu Vi chances, deterministic Body gate. Test `80/50/100` cũ vẫn chỉ là fixture và không được coi là authority.
- **Chưa kết nối đầy đủ:** V2 character HP live persistence/migration, V2 Equipment 10 ô/12 phẩm, Skills Nhân–Tiên–Thần và Trait/Mệnh/Linh Căn/Huyết Mạch/Thể Chất effects, outside-map live PvE/monster AI. Không coi design-only thành implemented.

**P3 static audit được sửa trong đợt bàn giao:** run [#37897313917](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897313917) **FAIL** vì hai mục `repo_source` motion/live-map thiếu `source_path`; đã bổ sung **đúng path mã nguồn tồn tại** vào `docs/P3_ASSET_REGISTRY.json`. Run kiểm lại [#37897882946](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37897882946) tại `cb8d5cfe` **PASS**. Đây là kiểm tra tài liệu/registry tĩnh của P3, không phải gate Godot hoặc UI Windows; không cần mở lại thiết kế P3.

## CI thực tế — KHÔNG ghi PASS nếu không có run

- **Focused DV2-03 PASS:** [Actions #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181), code SHA `e96df1832036c1232f9d0db69d1f37450d0265f9`, official **Godot 4.7.2 Linux**, từng bước Parse/2×300 realm test/`dv2_03_training_actions_test.gd` đều **success**. Bao gồm test lệnh `request_training`, chống EXP trùng, lưu/tải và bảo vệ action `COMBAT`.
- **Full cumulative P3.7 PASS có bằng chứng gần nhất:** [Actions #37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334), code SHA `5296f6106a2fd43d5c1a6f2523854702e9014d63`, fast + full cumulative đều success. **Chạy trước commits lệnh V2 `aa3122a`/test `e96df183`**. Vì vậy **CHƯA có full P3.7 PASS trên cùng source SHA `e96df183`**; đây là MISSING EVIDENCE, không phải FAIL.
- **Windows Godot gate của DV2-03:** **CHƯA CÓ BẰNG CHỨNG**. Không relabel Linux CI thành Windows PASS.
- Test references: `godot/tests/simulation/dv2_03_realm_body_progress_test.gd`, `godot/tests/simulation/dv2_03_training_actions_test.gd`; workflow `.github/workflows/dv2-03-realm-body-progress.yml`. Các commit chỉ chứa MD không tự chứng minh đã chạy lại gameplay CI.

## Thứ tự thực hiện kế tiếp (user đã chốt)

1. **Vẫn DV2-03. STEP 1 runtime + STEP 2 unified disciple presentation snapshot/profile đã focused PASS.**
2. **NEXT — Step 3: minimal real Rèn Thân consumer.** Nối typed `body_training` source vào một consumer facility/slot/cost thật tối thiểu, dùng canonical 1.500 Body EXP/phút trước Căn Cốt/modifiers; giữ `TRAIN_BODY`/body_focus blocked cho tới khi transaction cost + availability được commit thật. Không mở sâu building tree, không invent material catalogue ngoài nhu cầu tối thiểu đã được duyệt.
3. Chạy focused Godot 4.7.2, **FULL cumulative P3.7 trên cùng SHA code cuối DV2-03**, rồi Windows gate và cập nhật checkpoint nếu có bằng chứng. **Chỉ sau khi DV2-03 đóng** mới mở bước 3.
4. **Bước 3 (sau DV2-03):** Trang bị V2/12 phẩm/set, Công Pháp & Combat Skills Nhân–Tiên–Thần, Linh Căn, Đặc Chất, Mệnh Cách, Huyết Mạch, Thể Chất vào đúng runtime source/channel. Các phần chưa consumer phải BLOCKED.
5. **Bước 4 sau bước 3:** live outside-region map group PvE, 5 độ khó mỗi map (kể cả Ngoại Vi vẫn có Boss/Tinh Anh hiếm), AI, né/đỡ AoE, đánh quần công theo tổ đội ≤6 và cụm ≤30, rút lui, drop và cân bằng lại từ đệ tử đủ buff. Không thiết kế thêm quái/map lúc này.

## File bắt buộc đọc ở chat mới

Theo thứ tự: `AGENTS.md` → `docs/GAME_SYSTEM_ARCHITECTURE.md` → `CURRENT_CHECKPOINT.md` → `NEXT_CHAT_HANDOFF.md` → `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` → `docs/DISCIPLE_MASTER_SCHEMA.md` → `docs/REALM_LADDER_V2_SPEC.md` → `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` → `docs/BODY_CULTIVATION_V2_SPEC.md` → `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md` → code/test thực.

Nguồn code: `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `disciple_training_action_v2.gd`, `godot/src/simulation/core/simulation_scheduler.gd`, `godot/src/simulation/state/disciple_state.gd`, `sect_state.gd`, `godot/src/simulation/combat/hunting_pve_run_v2.gd`, `godot/src/presentation/p3_2_landscape_sect.gd`.

**Không hỏi lại các luật đã chốt; không Codex/Work; chỉ code GitHub connector, xác minh live main và gate thật.**

---

## PHỤ LỤC — lịch sử quyết định V2 ở các chat trước (KHÔNG dùng trạng thái ACTIVE/LATEST trong phần dưới làm checkpoint hiện tại)

## Disciple V2 design status

Design-closed:
- Spiritual Root / Ngũ Hành / Dị Linh Căn;
- Combat Stats;
- Disciple Characteristic Framework;
- Traits;
- Mệnh Cách;
- Bloodline;
- Realm Ladder;
- Luyện Thể core + Expedition Stamina;
- Physique base;
- Cultivation + Breakthrough;
- Công Pháp;
- Chủ Đạo / Đạo Lịch;
- Combat Skills;
- Kiếm Tu / Thể Tu / Pháp Tu combat language;
- three-wave Nhân → Tiên → Thần skill evolution.

Do not reopen those systems unless:
- a concrete contradiction is discovered; or
- the user explicitly changes a decision.

---

## Key new skill/path laws to preserve

### Công Pháp
- 1 Chủ Tu + 2 Phụ Tu active;
- inactive learned techniques keep mastery/history but ordinary effects are inactive;
- Tàng Kinh Các transmission is permanent after first archived full manual;
- personal mastery and Sect Nghiên Tu are separate;
- Diễn Hóa creates authored named successors.

### Chủ Đạo
- Chưa Định Đạo → Kiếm / Thể / Pháp;
- no class level;
- no generic class-stat growth;
- Đạo Lịch is lived history, not a free stat multiplier;
- active branches:
  - Kiếm: Ngự / Sát / Hộ;
  - Thể: Bá / Kim Cương / Huyết;
  - Pháp: Ngũ Hành / Y Đạo / Huyền Pháp;
- switching preserves learned content/mastery/history.

### Combat Skills
- mature loadout = 1 Thường + 4 Active + 6 Combat Passive;
- static self passives do not require combat slots;
- triggered/party passives do;
- Nhân Giới learns/opens the full foundational combat language;
- Tiên Giới evolves those families;
- Thần Giới evolves them again with bounded rule-changing effects;
- skill family successor replaces predecessor as active family source;
- skill basis = Tu Vi / Luyện Thể / Hybrid;
- AI = priority 1→4 + skill-specific validity;
- movement uses simple range profiles;
- no universal Mana/Rage/Kiếm Ý resource;
- Ngũ Hành and Tương Sinh are shared skill layers;
- effect tiers Nhân/Tiên/Thần protect control/cleanse/dispel/rule-changing interactions;
- party max 6;
- cluster max 30;
- 0 HP = Bị Hạ;
- monsters/bosses share the same combat primitives.

### Kiếm Cốt dependency
Combat Skills V2 has now defined:
- sword style tag direction;
- weapon requirement separation;
- cast/source/hit attribution.

Kiếm Cốt is **still blocked** until Weapon + Equipment V2 defines:
- canonical weapon types;
- sword equip semantics;
- weapon-requirement checks;
- whether any weapon mastery exists.

Do not enable Kiếm Cốt effectless.

---

## CURRENT NEXT-CHAT PRIORITY — COMPLETE A REAL DISCIPLE V2

The user **changed priority on 2026-10-09**: finish **disciple generation, complete meaningful attributes, real consumer/effects and one playable character** before further equipment forging/upgrading, Pháp Bảo or Phù design.

**Primary work authority:** `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`.

Required approach:
1. Audit live main and canonical V2 specs; produce `DV2-00` field → persisted source → derived channel → actual consumer → UI → test status matrix. Distinguish active C1 (validated) from P2 legacy and V2 design-only.
2. Prepare the **smallest first implementation slice**, `DV2-01`: deterministic ONE whole-person candidate/recruit, versioned identity persistence and no hidden rerolls. Then shared derived Combat Stats V2/RealmBodyCore and true progression/element/trait/fate/bloodline/physique/skill effects in tracked dependency order.
3. One recruited disciple must **really cultivate, train body, work and fight**, with stat values used by actual simulation and shown via existing P3.2 real disciple tabs. Any disabled/unimplemented mechanic must be labeled BLOCKED and cannot be shown as active. A real `combat_power` estimate is not the Combat Stats V2 authority.
4. Preserve P3.7C1 open-point lục-duy/recruitment and current Godot 4.7.2 locked baseline, old saves and deterministic generation. No new parallel stats, reroll-on-load or trait/physique grades resurrected as V2.
5. Focused Godot 4.7.2 gate for each slice; cumulative regression on cross-cutting changes and release; 1,000–3,000 disciple cache/perf acceptance; UI visual acceptance remains user-owned.

**Historical handoff at that time:** the user had not yet authorized gameplay code. **Superseded by explicit 2026-10-09 implementation instruction:** DV2-01 is now active; focused DV2-01A Godot 4.7.2 run #37876520342 PASS at commit 22f7d80e; later actual RecruitmentSystem accept-path test and cumulative P3.7 still need their own latest run. Do not claim whole DV2-01 PASS. to start `DV2-01` after audit if not already provided in the new chat; do not create a new numbered P3.x implementation phase without authorization.

**Locked subsystem context still valid:** `docs/DISCIPLE_V2_ROADMAP.md`/Ledger/Master. Realm/Luyện Thể = 30×10 each, Combat Skills = 1 basic + 4 active + 6 combat passive, Core Physique one active/no grades; Kiếm Cốt effect BLOCKED pending legitimate sword-tag/effect. Root/Bloodline/Destiny/Trait are not all implemented just because docs exist.

**Deferred without loss:** `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md` remains approved order but **NOT NEXT**. Equipment 10 slots, 12 phẩm, 24 sets remain locked *design*, no forging implementation. Pháp Bảo/Phù later. Mood/Loyalty/social/family expansion only after core character or smallest genuine dependency.

## Legacy design-document cleanup — 2026-10-08

Superseded legacy design Markdown files for Cultivation/Root/Công Pháp/Path/Combat Skills/Generation/Traits/Bloodline/Physique have been intentionally deleted from the repository.

Legacy runtime code, factories, tests and gates remain until their explicit V2 implementation/migration phases because they still protect regression and old-save compatibility.

Do not recreate or consult deleted legacy design specs as authority.

## 2026-10-09 — STAT-FIRST USER DECISION / NEW DOC AUTHORITIES

User approved correcting all three V2 conflicts: no in-sect Expedition Stamina consumption, no Trait V2 Grade 1–5 (profession talent grades remain), no Combat Power as V2 combat authority. **Design approved, legacy runtime not migrated or tested.**

User approved four-stage work order: base/derived stat audit → combat and production result contracts → effects-to-consumer map → implement canonical birth/character in phases after unresolved inputs are explicitly approved.

Read additionally, **before editing future V2 gameplay**:
- `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md` — core Lục Duy/Realm/Body, Combat Stats 14+resistance, production channels and open numeric gates;
- `docs/DISCIPLE_V2_EFFECT_SOURCE_MATRIX.md` — 53 original + 48 proposed Traits (101), 24 Fates, 10 Roots, 5 Bloodlines, 15 Physiques;
- `docs/DISCIPLE_V2_ROOT_ARCHITECTURE.md` — whole person/action/owner contract.

Canonical docs corrected: `docs/DISCIPLE_CHARACTERISTICS_STAT_FRAMEWORK_V2.md` (Stamina), `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md` (profession talent grade boundary), `docs/TRAITS_V2_SPEC.md` (Cuồng Công gated). Preserve existing backend P3.7C1 gate and old source until migration; `CURRENT_CHECKPOINT.md` is unchanged as no new code gate has run.

**Remaining user design gates:** exact Trait/Mệnh birth weighted eligible IDs + congenital special birth packages; Realm+Body numeric combat growth/Defense mitigation; production material/quantity/quality/rounding by content family; general HP ratio for non-Root sources; DV2-01 version/compatibility decisions. User is willing to reset disposable dev/test characters but has not authorized deleting actual user files automatically.


## DV2-01A REAL CODE/GATE SNAPSHOT — 2026-10-09

- **Active** DV2-01; the first partial integration adds default-off `SectState.disciple_v2_birth_enabled` and canonical `DiscipleBirthProfileV2` domain seeds/version/uninitialized layers. `CandidateState` → `RecruitmentSystem.accept_candidate` → `DiscipleState` save/load deep copies.
- **Godot 4.7.2 focused CI PASS:** [run #37876520342](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520342), code commit `22f7d80e`. Original nested JSON int→float failure fixed through normalized seed restore. More complete real-recruit path test at code commit `cbe5438d` awaits latest focused run.
- **P3.7 backend cumulative:** check latest run rather than assume PASS; previous official P3.7C1 closed baseline remains intact by design.
- Numeric proposal **NOT USER LOCKED**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`. Work result contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`.
- Never claim 101 active Traits or a complete V2 person yet. Exact per-ID Trait/Destiny weights and relevant birth overrides are still a design gate. Kiếm Cốt birth remains blocked.

**DV2-01A verification update:** official Godot 4.7.2 focused test including real `RecruitmentSystem.accept_candidate` **PASS** [Actions #37876666598](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876666598) (commit `cbe5438d`). Official **P3.7 full cumulative PASS** [Actions #37876520289](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37876520289) (last changed gameplay runtime commit `22f7d80e`). `CURRENT_CHECKPOINT.md` owns status. **DV2-01 still open**: only versioned identity envelope/seed domains are live under a default-off feature flag. No per-ID Trait/Fate V2 birth rolls, no V2 combat/production consumers. Numeric proposed curves: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`; production contract: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`; **full 101-Trait/24-Fate weighted birth pool V1 proposal**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md` (NOT USER LOCKED, do not activate until reviewed).

## FINAL HANDOFF 2026-10-09 — DV2-01B FULL BIRTH CODE

Current latest code adds `DiscipleBirthCatalogueV2` (101 Trait IDs/weights, 24 Fate IDs/weights, conflict sets), `DiscipleBirthRollV2` (five-root purity, rare mutation, visible/latent Traits, rare fate, Bloodline, Physique and profession talent), integrated into both `RecruitmentSystem.generate_candidate` and Dẫn Tiên `_generate_open_candidate_with_quality`. V2 flag is **OFF** for P3.7 baseline, P2 profile rolls are bypassed only for V2-opt-in new candidates, six foundations and C1 odds not altered. All unreadied effect consumers remain inactive. Latent IDs are stored, never rerolled.

- **Godot 4.7.2 focused/pass:** [Actions #37878256401](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878256401) — candidate→disciple, real ordinary recruitment and **real Dẫn Tiên**, save/load, 100K deterministic births, rates, collisions and no Kiếm Cốt/unsafe fate. Validated 100K samples: Roots 1..5 = [6879,18066,30016,28080,16959]; Bloodline 1969; Physique 2994; Fate 491; Mutation 210, 8 awakened; latent Traits 7986.
- **Cumulative P3.7 real Godot 4.7.2**: [Actions #37878271820](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878271820); consult live result and `CURRENT_CHECKPOINT.md` before closing DV2-01.
- **Numeric Combat V1 user-approved, code DV2-02 not yet begun**: `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`.
- **Trait/Fate weighted birth user-approved, generated by DV2-01B**: `docs/DV2_BIRTH_WEIGHTS_TRAIT_FATE_V1_PROPOSAL.md`.
- **Birth exclusions**: Sword Bone/Kiếm Cốt (weapon consumer missing); Sword Immortal reincarnation fate/Kiếm Tiên Chuyển Thế (birth override not authored); `Thương Binh Kinh Nghiệm` acquired only. Other gated identities can be stored inactive, not applied as buffs.
- **NEXT** after DV2-01 closes: DV2-02 canonical derived modifier engine + real stat-based Combat/Work channels according to the phase roadmap; one phase at a time, official gates mandatory. Legacy working-time stamina and trait grade runtime are migration debts for their applicable phases, not already fixed by births. No tests should be marked PASS without actual job conclusion.

## 2026-10-09 — DV2-02A COMBAT STATS IN PROGRESS (LATEST)

**DV2-01 is CLOSED** with focused [Godot run #37878652697](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652697) and full C1/P3.7 cumulative [#37878652738](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652738), both official Linux Godot 4.7.2 at code commit `e697c947a`.

**DV2-02 ACTIVE; DV2-02A focused stat kernel PASS** [Godot 4.7.2 #37880761726](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37880761726), relevant code commit `691e1216`. Code `godot/src/simulation/combat/combat_stats_v2.gd`, test `godot/tests/simulation/dv2_02_combat_stats_test.gd`, CI `.github/workflows/dv2-02-combat-stats.yml`, contract `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md`.

What exists: all 14 stats + 10 resistances, 300-floor Realm+Body approved numeric core, Tiềm Lực core-only, typed source validators/unique attribution, deterministic source breakdown, independent DR/resist stacking, stat-rate intervals, status/crit chance and Defense formula, HP ratio. **What does NOT exist yet:** actual monster/boss V2 stat profiles, character's persistent two independent 30×10 tracks (DV2-03 implementation later), skill family action adapters, combat-system migration from `combat_power`, all conditional Trait/Fate/etc effects, real cache/UI. Do not declare DV2-02 finished or pretend PvE uses new stats. Keep one active phase only. Next task stays **DV2-02 actual end-to-end consumer integration with explicit legitimate inputs**; do not jump into production or another character birth pass.

## LATEST 2026-10-09 — DV2-02B LIFESTEAL USER DECISION & ACTUAL HP SLICE

**Now 16 canonical headline Combat Stats (14 previous + 2 new):** `lifesteal` (**Hút Máu**) and `lifesteal_reduction` (**Giảm Hút Máu**). Both default 0; add/subtract via `percentage_points`. **Net Lifesteal = max(0, attacker Lifesteal − defender Anti-Lifesteal)**; calculate healing on **real HP damage lost after all mitigation**, capped by defender's pre-hit HP and attacker's missing HP. No hidden extra heal from overkill, no healing on zero/ineligible damage, no arbitrary 100% upper stat cap. Baseline direct hits allowed; DoT/proc/reflection/summons require explicit opt-in; Healing Done/Received separate.

`godot/src/simulation/combat/combat_stats_v2.gd` now derives **16 + 10 keyed resistances** and exposes `settle_damage_and_lifesteal`. `godot/src/simulation/combat/combat_system.gd` adds isolated `commit_v2_direct_hit` that *actually updates* two `DiscipleState.hp` values once per encounter hit ID without altering legacy P3.7 gameplay routing. Focused official Godot 4.7.2 [PASS #37881952009](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881952009). P3.7 cumulative CI for the actual CombatSystem touch: [Actions #37881991189](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881991189), check exact status before claiming anything. User-approved authority: `docs/COMBAT_STATS_V2_SPEC.md` §2.7 and `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md` §4A.

**Remain DV2-02 ACTIVE** until genuine character 2-track state, monster HP/ATK/DEF, skill/encounter routing, source activation and regression are complete. No DV2-03 progression implementation, no 101 Trait effect activation, no in-sect Stamina drains, no new production systems in this turn.

## LATEST 2026-10-09 — DV2-02C CONTEXT MODIFIERS / MONSTER FOUNDATION

**User request:** expand useful combat attributes **without diluting core game**, including bonus vs boss, bonus vs species, additional hit after basic attack, preserve future design space, and begin building monsters. **DV2-02 remains the only active phase.**

**Main Combat Stats unchanged:** 16 headlines including Lifesteal/Anti-Lifesteal; 10 keyed elemental resistances. **NEW CONTEXTUAL CHANNELS with real consumers:** `damage_vs_boss`, `damage_vs_elite`, `damage_vs_race/<race_id>`, `basic_followup_chance`, `basic_followup_damage`. Matching boss+race modifiers in same context bucket are **additive**; tiers mutually exclusive, one primary race; additional basic hit is maximum ONE, nonrecursive, noncrit/nonlifesteal/nonproc. Initial extra hit 60% is **pilot tuning, not final user-approved**.

**Monster code:** `CombatContextEffectsV2`, `MonsterCatalogueV2`, `MonsterEncounterV2` under `godot/src/simulation/combat/`; seven V2 species including all three old IDs and new elite/boss variants. Real monster HP/Attack/Defense scale over 30×10 using G as numeric basis and **provisional monster factors**, no `combat_power` damage. Same `CombatStatsV2.resolve_direct_hit` for outgoing and incoming; one hit-ID one payout; initial monster basic retaliation and player bonus basic hit on real HP. New loots and real AI phases not implemented. P0/P3.7 combat path unchanged.

**Focused actual Godot 4.7.2 PASS:** [Actions #37883140317](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37883140317), 16 core/lifesteal tests and 7-monster/300-floor/contextual/boss/extra-hit tests. Previous real P3.7 cumulative [Actions #37882134550](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37882134550) PASS before adding isolated MonsterV2 prototype files; do not pretend same-commit cumulative gate green for new files.

**NEXT work within DV2-02 only:** author actual monster action/AI/skill capability readiness (using shared Combat Skill primitives), contextual effects gate and race taxonomy consistency; then integrate monster stats/skill packets into an opt-in real encounter, with rewards/events/save/progression/readiness and cumulative regression. Do not turn `behavior_id` into an actually working AI merely by naming it, do not enable new item drops, and do not invent permanent birth stats. Written authority: `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md`.

## LATEST 2026-10-09 — DV2-02D GROUP MAP BATTLE (DO NOT ASSUME 1v1)

**User correction/requirements:** Disciples and monsters engage **as real groups on the outside-region map**, not as 1v1 instances. Support 6 disciples per actual party, up to 30 disciples (multiple parties) in a hunting cluster, multiple concurrent monsters. Balanced meaningful encounter challenge; player expects clear positioning, targeting, motion, support, attacks, skills, boss AoE and retreat.

**New source:** `godot/src/simulation/combat/map_battle_v2.gd` (one deterministic 2D arena/encounter with many actors, movement, range, threat via nearest selection, basic and existing `CombatStatsV2` damage, HP siphon, frontline guard, healer same-party heals, mage max-three AoE, elite/boss telegraphed max-three delayed AoE, downed/zero HP no ordinary revive, event trace); `godot/src/presentation/p3/map_battle_world_layer_v2.gd` + `godot/scenes/p3/map_battle_world_layer_v2.tscn` (`Node2D` rendering adapter; reads authoritative 2D positions, health bars, telegraphs; **no RNG/time consumption**, no map camera outcome influence; placeholder art). **Still NO real live outside-region map integration** or live scheduler/hunting group assignment, obstacle paths, rewards, monster AI content, battle save/reload. P0/P3.7 real PvE remains legacy and unchanged; DV2-02 is ACTIVE (NOT PASS).

**Tests:** `godot/tests/simulation/dv2_02_group_map_battle_test.gd` focused official Godot 4.7.2 Linux **PASS** [Actions #37884662844](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884662844); also earlier focused 16-stat and monster test in same CI. P3.6A scene parse smoke [#37884519447](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884519447) PASS. 30-member cluster test, 6/party rejection, no cross-party healing, input-order determinism, viewed-map/offscreen identical, real Node2D map position selection, boss area dodge, support and AoE, no permanent death.

**16-seed pilot balance per formation after real iteration:** 3v3 normal **16/16 win, 0 average downed, 15.72s**; 4v5 normal **16/16, 1 downed, 22.02s**; 6v6 elite **16/16, 2 downed, 24.03s**; 6v5 boss+4 guards **16/16, 2 downed, 23.64s**; weak 3v5 vs boss **0/16**; six disciples at +1 major realm vs boss **16/16**; six without healer vs boss **16/16** means build-role balance still needs meaningful work. These are **pilot inputs only**, not game-wide win guarantees. 16 samples do NOT mean a 100% universal win rate. First balance was grossly overtuned elite/boss 0/16, now pilot tier factors elite (HP1.35,ATK1.10,DEF1.10), boss (HP2.50,ATK1.30,DEF1.18). Frontline guard 35% remaining damage reduction for 4s when below 75%, cooldown 9s; healer 1.80×ATK heal every 5sec same party. All new skill numeric values are **PILOT NOT USER LOCKED**. Full report `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`.

**NEXT WITHIN DV2-02:** real outside-region map/session lifecycle + group assignment and P3.7 compatibility adapter; actual skill content/AI shared cast/projectile primitives; player-driven role/tactics, balanced different lineups/regions/levels; rewards/encounter ID journal, save-reload midbattle, strategic risk/reward. Before production migration, run FULL real Godot cumulative. Do not start unrelated DV2-03. Avoid assuming group pilot already replacing live combat.

## LATEST 2026-10-09 — USER CORRECTED OUTER MAP ELITES/BOSSES & PvE SCOPE

**USER:** “ê mà ngoại vi k có boss với tinh anh à. :v ==!. với lại đi đến pve là đúng chưa nhỉ.” This means earlier pilot spawning **incorrectly locked Boss out of L1–4 and Elite out of L1–2**; correct to **all five difficulty levels may contain Elite/Boss**. Outer tiers must be *rare*, not impossible. Difficulty controls their **encounter chance / number / stats / rewards**, never global monster-taxon eligibility.

**Implemented actual source:** `godot/src/simulation/combat/hunting_map_v2.gd`, five per-map selected levels; **L1 Elite 6%, Boss 1%**; **L2 Elite 14%, Boss 3%**; **L3 ≥1 Elite and Boss 8%**; **L4 ≥1 Elite and Boss 16%**; **L5 guaranteed Boss+2 Elite**. All rates explicitly **PILOT, not user-locked universal spawn rates**. At easy L1/2, a Boss removes optional Elite from that encounter to avoid stacking rare special encounters in a tiny group. Boss/Elite use same species + tier + difficulty modifier stat authority. Rare Boss still needs visible on-map warning/optional engagement/retreat before automated PvE; **not implemented yet**. Do not assert it was.

**Test fix:** `godot/tests/simulation/dv2_02_five_level_pve_test.gd` now tests 1,300 deterministic encounters per level for 1–4, must actually encounter Elite/Boss at each tier, while preserving mostly ordinary encounters L1–2; compare *the same monster species stat scaling*, not the random first monster slot (which may be an unexpected rare Boss). Official Godot 4.7.2 [PASS #37886852624](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852624): L1 Elite 87/Boss 14, L2 Elite 182/Boss 37, L3 Elite 1300/Boss 108, L4 Elite 1300/Boss 212 (out of 1300 seeds each).

**Priority/scope clarified:** proceeding to PvE **was correct to give the stat engine real group combat targets and a testable economy feedback loop**, but **NOT** correct to fully design/finalize the entire PvE system before the actual dual 30×10 Tu Vi/Luyện Thể tracks, 10-slot equipment V2, Nhân/Tiên/Thần Combat Skill runtime and activated innate effects exist. Keep DV2-02 active for the canonical stat consumer/monster contract, freeze extended world content, move to remaining character dependencies in planned sequence when DV2-02 is actually eligible to close, and do not call group simulator opt-in runtime "live P3 PvE". The five-map per-region difficulty, opt-in group combat and P3.7 warehouse reward slices remain useful staging code; final balance is OPEN.

**Docs:** `CURRENT_CHECKPOINT.md` and `docs/DV2_02_PVE_FIVE_LEVEL_RESOURCE_LOADOUT_CONTRACT.md`. Latest full P3.7 cumulative after spawn rarity change: GitHub [#37886852526](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852526), check current status. Focused latest is green; do not confuse the two.

## LATEST 2026-10-09 — DV2-03 REAL 2×300 TU VI/BODY PHASE (ACTIVE)

**User sequencing locked**: 1. DV2-02 *core* DONE (focused+full Godot), 2. DV2-03 real Tu Vi & Luyện Thể tracks **CURRENT**, 3. real V2 Equipment/skills/innate effect attachment, 4. expanded map PvE/AI/balance. No new monster species, maps or ungrounded EXP/chances.

**Code**: `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd`, `godot/src/simulation/state/disciple_state.gd` and `godot/src/simulation/combat/hunting_pve_run_v2.gd`. Genuine complete V2 birth profile required; real two *separate* 30 major realm ×10 floor states saved; natural gains +0.25% Tư Chất and +0.20% Căn Cốt/pt, explicit validated per-floor costs, deterministic same-channel named XP modifiers, fixed gains not boosted. Minor levels auto, only floor10 major gate requires verified authored requirements/chance. Tu Vi failure 10% gate XP lost, 5pp same-gate pity, no generic HP/stamina loss. Independent Luyện Thể gate requires verified authored Body conditions; no guessed material recipes or Tu Vi chance. Real CombatStatsV2 consumes both tracks; V2 group hunt refuses incoming fake realm coordinates and reads persisted character progress.

**Godot 4.7.2 focused PASS:** [Actions #37893363804](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893363804) at `522c72d8`, covers recruitment, 2×300, EXP laws, gate, status persistence, stat recompute, PvE anti-spoof. **P3.7 latest full cumulative:** [Actions #37893455770](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893455770), inspect completion before claiming PASS. `CURRENT_CHECKPOINT.md` is status authority.

**Still open within stage 2:** real Rèn Thân facility/cost consumer, production/expedition source hookups, exact Body gate material packages, persistent runtime/offline + interface. Shared 300-floor costs and 29 Tu Vi base chances are no longer open. The previous `CultivationSystem.STAGES` legacy XP/chance tables cannot be silently reused; no false "DV2-03 all done" claim. `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` explains code and limitations. Phase remains ACTIVE, not quietly switching to equipment/skill phase 3.

**Update 2026-10-09 DV2-03 focused gate:** all **60 locked realm names (Tu Vi 30 + Luyện Thể 30)** now exposed from persistent tracks, status [focused official Godot 4.7.2 PASS #37893767560](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767560) at `57fa72ae882b`. Previous full P3.7 [#37893455770](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893455770) PASS; latest [#37893767454](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37893767454) **running at last check**, verify before claiming full same-commit PASS. Explicitly **DV2-03 remains ACTIVE** until real authored XP/chance/body materials/action earning or an explicitly scoped core closeout; do not automatically move to Equipment V2. Detailed source: `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`.

## LATEST 2026-10-09 — DV2-03B REAL ACTION GAIN IN EXISTING SCHEDULER (CURRENT)

User approved continuing Tu Vi/Luyện Thể V2 before real equipment, skills and map AI. **Historical note:** this slice originally routed both `CULTIVATE` and provisional `TRAIN_BODY`. **Superseded 2026-10-09:** only Tu Vi has a live time-source contract (`base_tuvi_per_minute` + Chuyên Tu multiplier). `TRAIN_BODY` is fail-closed because Luyện Thể training mechanics were not actually locked. Body keeps only generic 30×10 progression/grant math for future authored sources. `SectState.v2_training_enabled` remains default-off and **canonical shared 300-floor EXP curve now exists**.

**FOCUSED real Godot 4.7.2 Linux PASS** [DV2-03 #37895517181](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895517181) at code `e96df183`, runs two-track + `dv2_03_training_actions_test.gd` test. Test values (e.g. 80/50 EXP action and 100 EXP floor cost) are **ONLY test fixtures**, not canonical game balance. Full P3.7 [#37895357334](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37895357334) **PASS** at scheduler code `5296f610`; newer player-request focused gate also PASS, but **not a full cumulative on identical latest SHA**. Detailed contract `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md`.

**Next within DV2-03:** deliberate approval of 300-floor per-track cost curves, real training EXP/action rates, 29 major Tu Vi baseline chances & breakthrough material conditions for Body, plus V2 actor autonomous training policy/priority, full old→V2 HP authority/scheduler transition. Keep phase **ACTIVE**, do not jump to equipment/skills or outside-map PvE, and do not claim finished V2 naturally scales through all 300 floors while default rules are empty.
