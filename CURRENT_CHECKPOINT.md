# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-07

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

## 5. Current implementation phase

**NONE — P3.7C1 IS CLOSED.**

Do not start another gameplay phase without a new explicit user instruction.

---

## 6. Disciple V2 design authorities prepared

Canonical design carryover files now exist:
- `docs/DISCIPLE_V2_DESIGN_LEDGER.md` — locked lục-duy/Dẫn Tiên rules, one-disciple-forever nurture law, pill satiety, future breakthrough rule, and distilled lessons from 《最强祖师》;
- `docs/DISCIPLE_V2_ROADMAP.md` — full disciple subsystem map, dependencies and preferred discussion order;
- `docs/DISCIPLE_MASTER_SCHEMA.md` — whole-person generation and fixed/update ownership.

These docs are design authorities, not implementation PASS evidence.

## 7. Disciple V2 design queue

Spiritual Root V2 **base core design is locked, not implemented**.

Canonical design:
- `docs/SPIRITUAL_ROOT_V2_SPEC.md`.

Locked design now covers:
- five base roots;
- 1–5 root generation rates;
- per-element purity 1–100;
- base cultivation/mastery/combat buffs;
- element-specific permanent passives;
- perfected-root Resonance through full five roots;
- elemental counter core;
- deterministic refinement;
- missing-root transformation path;
- resource-source/storage/migration contract.

Next Spiritual Root design subsection:
**Dị Linh Căn / mutation V2**.

No implementation phase is active and no Spiritual Root V2 code is authorized yet.
