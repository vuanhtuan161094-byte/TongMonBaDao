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

## 5. Current implementation phase

**DV2-01 CLOSED; DV2-02 CORE BACKEND LOCKED (Godot 4.7.2 Linux CI) — DV2-03 TU VI + LUYEN THE V2 IS NEXT.**

### DV2-01 completion evidence
- **DV2-01B focused birth/recruitment/Dẫn Tiên/100,000 generated profiles:** [Actions #37878652697](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652697), successful, GitHub commit `e697c947a`.
- **Full P3.7 cumulative regression:** [Actions #37878652738](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37878652738), successful at the **same code commit** `e697c947a`.
- Both are official Godot **4.7.2 Linux CI**, **not Windows gate**. Opt-in `SectState.disciple_v2_birth_enabled` remains **false by default**.
- Canonical birthplace: `DiscipleBirthProfileV2` + `DiscipleBirthCatalogueV2` + `DiscipleBirthRollV2`, ordinary/Dẫn Tiên candidates, true recruitment, stable hidden identity, saved profile. Trait/Fate/Bloodline/Physique **effect consumers are not active** by mere birth.
- Eligible 14/15 Physiques (Kiếm Cốt blocked), 23/24 Fates (Kiếm Tiên Chuyển Thế birth override blocked), `Thương Binh Kinh Nghiệm` acquired-only. These are documented intentional content gates, **not invented active effects**.
- Final 100k sample: 1..5 roots 6,879 / 18,066 / 30,016 / 28,080 / 16,959; Traits 1/2/3 59,903 / 32,200 / 7,897, latent 7,986; Bloodline 1,969, Physique 2,994, Fate 491, mutation 210. Determinism, save/load and direct + Dẫn Tiên quota equality passed.
- Previous intermediate parse/serialization CI failures were corrected before these gates.

### DV2-02 — newly ACTIVE by user "làm việc tiếp theo" on 2026-10-09

**Scope (UPDATED USER DECISION 2026-10-09):** canonical **16 Combat Stats**, including new **Hút Máu** and **Giảm Hút Máu**, plus 10 elemental resistances derived from already approved RealmBodyCore numeric V1 + Tiềm Lực; typed modifiers, provenance, limits, crit/status/Defense/penetration/resistance/reduction and deterministic focused tests. Combat power is **not** stat/damage authority in V2. Keep existing P0–P3.7 combat behavior until the whole PvE/monster/skill consumer is gated; a stat calculator alone does **not** close DV2-02.

**DV2-02A — first focused code committed and tested:**
- `godot/src/simulation/combat/combat_stats_v2.gd` computes all 14 V2 primary stat channels + independent remaining-damage resistance map of 10 elements, Realm+Body 30×10 (G=1.65^(r-1)*1.03^(floor-1)), Tiềm Lực +0.05%/pt core-only, deterministic typed source validation and breakdown, HP-ratio scaling and a pure direct-hit resolver. No global Work Power or Combat Power.
- `godot/tests/simulation/dv2_02_combat_stats_test.gd` exercises base 190/23/19, fixed equipment+potential, time rate channels, 5%/1.50x critical baseline, status pp, special immunity ordering, 20%+10%=28% independent DR and fire resist 30%+20%=44%, defense factor K/(K+DEF), invalid/duplicate channels, no dormant source buff, and monotone 300-floor growth.
- `.github/workflows/dv2-02-combat-stats.yml` focused real **Godot 4.7.2 Linux CI PASS**, [Actions #37880761726](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37880761726), code commit `691e1216`. Earlier CI failed because the test compared buffed attack expectations against an unbuffed input; corrected before PASS. This is **not** a real Windows gate.
- Owner and numeric breakdown: `docs/DV2_02_COMBAT_STAT_EXECUTION_CONTRACT.md`.
- **Still not implemented:** actual V2 progression adapter/canonical two-track disciple state, real monster/boss ATK–DEF–HP, end-to-end skill/encounter integration, conditional source triggers, lazy stat caching/UI, relevant full cumulative regression after those migrations. Legacy P3.7 encounters still use old `combat_power` and are not mislabeled as V2. **DV2-02 remains ACTIVE; do not claim BACKEND LOCKED.**

**DV2-02B — Hút Máu và Giảm Hút Máu user-locked, implemented in staged V2 combat API:**
- Two new **headline stats `lifesteal` / `lifesteal_reduction`**, both default 0 and accept independent `percentage_points` sources; effective rate `max(0, lifesteal - target_lifesteal_reduction)`. No arbitrary 100% upper cap; negative final rate blocked.
- `CombatStatsV2.settle_damage_and_lifesteal`: heals on **actual target HP lost after all defenses and overkill cap**, never over attacker Max HP. Explicit hit eligibility; no ordinary lifesteal from preview, DoT, reflect, procs or summon damage unless later content permits. Do not automatically apply Healing Done/Received.
- `CombatSystem.commit_v2_direct_hit`: isolated tested **real DiscipleState HP** update, with per-encounter `hit_id` dedup. **Legacy P0/P3.7 battle routing is unchanged**; not yet a full monster/skills V2 consumer.
- **Godot 4.7.2 focused PASS**: [Actions #37881952009](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881952009), includes live disciple hit+heal+idempotence; 16 Combat Stats and 10 resistances, numeric core invariants. Earlier focused stat-only [#37881735064](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881735064) PASS.
- **Focused 16-stat/lifesteal + real HP-commit official Godot PASS**: [#37881952009](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881952009), at code commit `bfdbc2ee`.
- **Most recent stricter after-defense and additive anti-lifesteal tests: official Godot 4.7.2 focused PASS**: [Actions #37882134575](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37882134575), code commit `2de49b38`. This also includes real DiscipleState HP commit/once-per-hit lifesteal checks.
- **P3.7 cumulative on V2 combat source/test changes**: [Actions #37882134550](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37882134550), **PENDING** as of last status read. Earlier [#37881991189](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37881991189) also started with source change; check exact newest run outcome before any cumulative PASS claim. DV2-02 stays **ACTIVE**, no full monster/skill V2 consumer migration yet.

**DV2-02C — contextual damage and initial real monster foundations (2026-10-09):**
- User explicitly requested room for boss damage, racial damage, extra basic hits and future build variety. The **16 headline Combat Stats plus 10 resistance keys remain unchanged**; additional attributes are conditional registered sources with real target/attack consumers.
- `godot/src/simulation/combat/combat_context_effects_v2.gd`: **implemented pilot** `damage_vs_boss`, `damage_vs_elite`, `damage_vs_race/<race_id>`, `basic_followup_chance`, `basic_followup_damage`. A single exclusive tier and single primary race; additive same-context bonuses; ordinary basic can produce **at most one** nonrecursive follow-up (pilot base ratio 60%, balance **not user-locked**, no bonus-hit crit/lifesteal/proc). Unowned channels such as shield breaker/execute/boss-control/monster-break remain **FUTURE only** and cannot be activated by the engine.
- `godot/src/simulation/combat/monster_catalogue_v2.gd`: **seven seeded species definitions**: old P0 Trúc Thử/Thanh Lang/Hắc Lang and new U Hồn/Nham Giáp Thú/Huyết Lang Đầu Đàn/Hắc Lang Vương. Authored race, element, one tier normal/elite/boss, HP/ATK/DEF derived from Realm-scaling G with provisional monster-only tier/species multipliers; no fake universal `power`. New species rewards/AI actual behavior remain **not ready**.
- `godot/src/simulation/combat/monster_encounter_v2.gd`: isolated pilot using **real monster HP + real DiscipleState HP + CombatStatsV2 direct-hit primitive**, boss/race modifiers and one bounded basic followup; dedup by encounter hit ID; monster can retaliate with real ATK vs defender DEF. No change to legacy P0/P3.7 PvE encounter selection, reward economics or live routing.
- **Focused official Godot 4.7.2 Linux CI PASS**: [Actions #37883140317](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37883140317), new `godot/tests/simulation/dv2_02_monster_context_test.gd` checks 7×300 stat profiles, boss/race matching, extra-hit nonrecursion, idempotent HP and monster retaliation, plus preexisting 16-stat/lifesteal gate in the same workflow.
- Technical/design authority: `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md`; this is a **pilot foundation** and does NOT complete monster combat/AI, reward validation, real map-spawn integration or full DV2-02. **DV2-02 remains ACTIVE, NOT BACKEND LOCKED**. No unrelated gameplay phase opened.
- Previous P3.7 latest full cumulative [Actions #37882134550](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37882134550) successful for V2 real-HP `CombatSystem` touch; this newest monster pilot adds isolated source/scripts only, so no fresh *full* cumulative PASS is claimed.

**DV2-02D — GROUP-VS-GROUP COMBAT ON MAP (user explicitly corrected 1v1 assumptions 2026-10-09):**
- **Hard design law:** combat is **multi-disciple versus multi-monster on a real map**. Max **6 disciples per party**, up to **30 in a hunting cluster** (may comprise several parties), <=40 active monsters in this pilot. Legacy single-disciple `CombatSystem.resolve_encounter` does **NOT** satisfy V2 combat rules.
- `godot/src/simulation/combat/map_battle_v2.gd` — opt-in isolated active encounter, local 2D world coords, movement/range, deterministic nearest target with stable ID tie-break, multiple targets in one instance, role frontline timed guard, healer within same party, mage AoE capped at 3, elite/Boss area telegraphs/delayed AoE capped at 3, 0 HP downed nonrevivable by normal heal, event trace, view/offscreen identical behavior. Uses `CombatStatsV2` real ATK/DEF/HP and lifesteal.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd` and `godot/scenes/p3/map_battle_world_layer_v2.tscn` — Godot `Node2D` map/world overlay reads authoritative actor positions/HP/boss warning area only, **cannot advance RNG/time**. Visual fallback placeholders, **not** production art or live region-map hookup.
- `godot/tests/simulation/dv2_02_group_map_battle_test.gd` tests real 4v5, 6v5 Boss+guards, 30 cluster, 6/party, cross-party heal isolation, AoE caps/dodge, replay/view independence, hit/downed/guard/heal and map coordinate projection. **Official Godot 4.7.2 Linux focused PASS:** [Actions #37884662844](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884662844). P3.6A scene parse/preview gate also green [#37884519447](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884519447) for map view assets.
- **Balance pilot 16 seeds/formations:** 3v3 regular 16/16 wins (0 average downed, 15.72 sec), 4v5 regular 16/16 (1 downed, 22.02 sec), 6v6 incl elite 16/16 (2 downed, 24.03 sec), 6v5 incl boss 16/16 (2 downed, 23.64 sec). Weak 3v5 boss 0/16, six at one higher major realm boss 16/16; six without healer still boss 16/16 (role balance **OPEN**). Initial elite/boss excessive strength caused 0/16 wins; reduced provisional monster tier factors and implemented pilot frontline guard/healer skill. **These numbers are not user-locked general balancing laws.**
- Full detail `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md`; balance/scaling authorities for 7 starter species remain `docs/DV2_02_CONTEXT_STATS_MONSTER_FOUNDATION.md` and `MonsterCatalogueV2`.
- **STILL OPEN:** attach actual outside-region map to simulation active sessions and participant groups, monster skills and AI behavior variations, spawn composition/danger scaling, persistent encounter state/idempotent rewards, save/reload, position obstacles/navigation, real art, full P3.7+DV2-02 cumulative rerun on actual live consumer migration. **DV2-02 remains ACTIVE / NOT BACKEND LOCKED**; legacy 1v1 live P0/P3.7 combat is not misrepresented as V2.

**DV2-02E — FIVE PER-MAP DIFFICULTIES & CORRECTION TO MONSTER RARITIES (09/10/2026):**
- User expressly corrected the false assumption **"Ngoại Vi cannot have Elite or Boss"**. All levels 1–5 can spawn normal/Elite/Boss, with rare per-encounter probabilities at easy levels: **L1 Elite 6% / Boss 1%**, **L2 Elite 14% / Boss 3%**, L3 ≥1 Elite / Boss 8%, L4 ≥1 Elite / Boss 16%, L5 Boss 100% and 2 Elites. Values are **PILOT**, not final locked difficulty/density; Boss at L1/L2 excludes optional Elite to avoid unfair stacked spikes.
- Implemented in `godot/src/simulation/combat/hunting_map_v2.gd`, with `godot/tests/simulation/dv2_02_five_level_pve_test.gd` testing all five levels / per-map reward scaling / rare Boss presence and rarity. Critically, tests compare the **same species** under difficulty scaling, rather than treating a randomly selected rare tier as a stat regression.
- Godot 4.7.2 focused [Actions #37886852624](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852624) **PASS**: 1,300 seeded samples per level: L1 **87 Elite / 14 Boss**, L2 **182 Elite / 37 Boss**, L3 **1,300 Elite / 108 Boss**, L4 **1,300 Elite / 212 Boss**; no permanently excluded tier at any level. L5 guaranteed Boss tested.
- Actual DV2-02E separate workflow previously PASS on [#37886235478](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886235478), including a group challenge benchmark across 5 tiers and 3 maps, real owned P2 item effects, learned direct-damage skills, 5-level selection UI, warehouse actual-registered rewards and once-only persisted claims.
- **Full P3.7 cumulative for latest rarity code:** [Actions #37886852526](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37886852526) **check status before claiming PASS**.
- The user asked if PvE work is sequenced correctly. **Decision:** PvE is VALID as a **derived-stat and group-action consumer/proving slice** within DV2-02, NOT the next independent giant phase: 30×10 real dual-track Disciple V2 persistence (DV2-03), actual 10-slot Equipment V2 sources, Nhân/Tiên/Thần combat skills and traits/bloodline/physique consumers are still missing. Do not lock universal monster/player balance, "complete PvE", or switch legacy PvE into V2 before those dependencies. The existing active V2 map runner is an isolated opt-in path, not mounted on production outside-region scene/scheduler. Rare boss spawns need **visible avoidance/retreat** before live auto-hunting; not yet implemented.
- Design correction authority: `docs/DV2_02_PVE_FIVE_LEVEL_RESOURCE_LOADOUT_CONTRACT.md`. Keep **DV2-02 ACTIVE, NOT CLOSED**.

**DV2-02 CORE CLOSEOUT — USER-APPROVED STAGE 1 OF 4, 2026-10-09. THIS IS THE CURRENT IMPLEMENTATION AUTHORITY (supersedes historical PENDING notices above).**
- **FOCUSED Godot 4.7.2 Linux PASS** [Actions #37890274593](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37890274593), at code commit `bf7fe1f0df6c4932c22f51b921aa4f508d662be1`; tests 16 combat stats, 10 resistances, monster/race/boss/extra basic hit, multi-disciple group map, 5 map difficulty levels and group challenge, real P2 gear/learned skill effect adapters, warehouse once-only rewards.
- **FULL P3.7 cumulative Godot 4.7.2 Linux PASS** [Actions #37890274702](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37890274702), at the **same exact code commit** `bf7fe1f0df6c4932c22f51b921aa4f508d662be1`; this is real Linux Godot CI, **NOT a Windows machine gate**.
- NEW stabilized `MapBattleSnapshotV2`: versioned lossless typed Variant/base64 payload in JSON, full actor HP/position/stat/range/timers, pending casts, combat event journal and exact 64-bit RNG state. Direct float64 and RNG int64 JSON conversion was observed to lose precision; corrected. Typed deserialization rejects bad states and never restores object pointers; `dv2_02_battle_snapshot_test.gd` proves **bitwise-equal final game state, event order and RNG** after mid-battle JSON save/resume.
- NEW `HuntingPveRunV2.save_state/restore_state/resume_active` and `SectState.v2_pve_active_runs`: one authoritative opt-in running encounter checkpoint per ID; persisted on each step/finish; immutable region/difficulty/monster species provenance rechecked on reload; existing claim ledger prevents replaying loot; tests show SectState JSON recovery and duplicate-ID rejection.
- **SCOPE LOCK**: only canonical stat/conditional-effect calculator, deterministic multi-party in-map encounter **simulation core** and opt-in five-level hunt/warehouse proving consumer are DV2-02 core. **NOT** actual production outside-region map/scheduler/monster AI/VFX/balance or 10-slot Equipment V2, 30×10 persistent character tracks, all 101 Trait effects. Those are user-authorized NEXT STAGES, NOT silently declared shipped. Pilot numbers remain pilot; old P0/P3.7 live combat unchanged. This scoped closeout complies with latest explicit user step order.
- **NEXT STEP 2: DV2-03 Tu Vi + Luyen The 30×10**. Implement canonical **two independent persistent track states** on each real V2 disciple and connect their current indices to the existing `CombatStatsV2` snapshot. Respect minor-floor auto progression vs major-gate breakthrough, Căn Cốt/Tư Chất rules, no fabricated XP curve, no old legacy `combat_power` as stat authority. After DV2-03 PASS, step 3 is real gear/skills/innate effect consumers; step 4 is comprehensive live-map PvE / monster AI / rebalanced rewards. Read `docs/DV2_02_CORE_CLOSEOUT_AND_NEXT_ORDER.md`.

Canonical:
- `docs/COMBAT_STATS_V2_SPEC.md`;
- `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md` (**contents USER LOCKED, historical filename retained**);
- `docs/DISCIPLE_V2_STAT_CAUSAL_CONTRACT.md`.

**Do not implement DV2-03 (realm progression), DV2-05 Trait consumers or production changes ahead of DV2-02.** Those remain later phases.

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

**No implementation phase is active and no Spiritual Root V2 gameplay code is authorized yet.**

Legacy-cleanup note:
- the old P2.10 Spiritual Root design document has been removed because Spiritual Root V2 is the sole design authority;
- old `spiritual_root_system.gd` / `root_refinement_system.gd` remain temporarily only because locked P2 regressions and old-save migration still consume them;
- those legacy scripts are not V2 design authority and must not be extended for new Spiritual Root gameplay;
- dead legacy runtime may be physically removed only inside a tested V2 migration phase.

Combat Stats V2 design is now **LOCKED, NOT IMPLEMENTED**.

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

**Implementation phase still NONE; last backend PASS still P3.7C1.** No character gameplay code or test gate was changed by this planning commit. Next chat must fetch live main and begin with `DV2-00` audit. Do not relabel existing P2 character tabs as new full V2 PASS.
