# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-11

This file contains **current truth only**.
It is not a historical changelog.

Read `docs/GAME_SYSTEM_ARCHITECTURE.md` for system structure and phase discipline.

## O1 IMPLEMENTATION — CANONICAL WAREHOUSE LANDSCAPE UI (2026-10-11)

**Authorized packet:** User expressly authorized **CODE O1 ONLY**. **Implemented on main** in `godot/src/presentation/p3_1_landscape_sect.gd` and `godot/src/presentation/p3_2_landscape_sect.gd` with one `WarehouseSystem` read-only projection: total `quantity`, spendable `available_quantity`, and explicit legacy fallback strictly when `state.sect.p3_7_resources_enabled=false`. Top bar / task stock cue / base building panels / P3.2 Mine, Forge, Kho, formula preview, legacy Bloodline and Physique material labels now show canonical P3.7 stock. Recipe preview agrees with `EquipmentSystem.can_craft` under reserve/lock; no replica warehouse or source changes, EXP/29 Body-gate recipes, currencies/economy and landscape 1280×720 untouched.

**Focused official runtime: PASS.** O1 scene-focused official Godot 4.7.2 Linux run [#38138929016](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138929016) **COMPLETED/SUCCESS**, commit `64fe81943f299fcfc69a62cdd2238a25540b46ac`. The new `godot/tests/presentation/p3_o1_canonical_warehouse_ui_test.gd` loaded the **real P3.2 landscape main scene**, verified same counted real stock in top-bar/warehouse/mine/forge/recipe, ran an actual P3.7 mining travel/work/haul completion deposited to canonical warehouse, verified post-production UI counts, blocked craft under real reserve and lock, consumed exactly three Thanh Thiết + one Linh Mộc for one actual equipment item via player-facing craft method, rejected duplicate/locked craft, and proved stock, locked status, equipment item count and UI reload from disk. Existing `p3_6a_playable_slice_test.gd` **PASS** in same focused workflow. Logs contain `P3 O1 CANONICAL WAREHOUSE UI TEST PASS` and `P3.6A PLAYABLE SLICE TEST PASS`. Early O1 workflow runs #38138844577 (class cache not imported) and #38138894260 (invalid YAML during restoration configuration) **FAILED and were corrected before #38138929016 PASS**; neither was falsely reported as gameplay acceptance.

**Cumulative P3.7 FAST:** [#38138746766](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138746766) at code commit `dfc4ac91d4e46a774831ae0ce94c8f301beea1d9` completed FAST success; its FULL cumulative gate was **IN PROGRESS as last queried** (check final result before closing O1). Later commits added only focused test and CI config, not changed gameplay scripts. DV2-03 focused [#38138746841](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138746841) completed/success at the same production code SHA. P3.6A preview script/capture PASS but artifact upload failed due GitHub artifact storage quota in [#38138746807](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38138746807); **not a game/render test failure**.

**Closure gate:** O1 focused **PASS**; **O1 overall CUMULATIVE PENDING** until #38138746766 FULL reports completed/success. No O2 code authorized or started. If cumulative PASS is verified, close O1 and offer **O2 real Disciple / Guidance recruitment entry and dynamic actor lifecycle** for explicit next authorization. If FAIL, repair only O1 regression before O2. O2–O9, long-run economy and visual approvals **NOT implemented or accepted**. New Windows 4.7.2 hands-on click/visual/packaging check **PENDING USER** (PC not available; Linux CI ≠ Windows PASS). Game remains mobile LANDSCAPE 1280×720.

---

## O0 AUDIT RESULT — FRESH OPENING FACTORY TRACED / NO NEW RUNTIME GATE (2026-10-11)

**Result:** O0 **READ-ONLY SOURCE AUDIT COMPLETED** at game source `47c39a7`; details in `docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md §O0 EXECUTED`. **This is SOURCE-VERIFIED, NOT an O0 official Godot runtime PASS.** No new gameplay code or CI run claimed; no Windows machine access. O1 was subsequently authorized and implemented; **see current O1 entry above**. `AGENTS.md §11` now mandates 2–3 **one-tap choices that submit complete next prompts** after each user-facing work result; recommended next action first, no typing required.

**Fresh start from actual factory chain:** main `p3_2_landscape_sect.tscn` → `LiveGameRuntimeV2` → `P37Factory` → P0..P2.12; `seed=31012026`; **6 named founders, capacity 8, 3 waiting candidates, 3 Chiêu Mộ Lệnh, treasury 1,000, 500 Sect Spirit Stones** (initialized by `P23Factory`/TechniqueSystem), plus **40 Linh Mộc and 40 Thanh Thiết** introduced by P3.7 before single canonical warehouse migration. Starter Forge/Mine groups: first 2 mine, next 2 forge, last 2 unassigned. Backend buildings include Mine, Spirit Field, Guidance and one V2 Body Training instance. Realtime = 60s/1 simulation minute; scene autosaves every 15s. Field Lv1 crop costs 3/4 Stones; **initial Field planting is financially feasible**. **Correction:** earlier "initial Stones=0 / Field possibly unfunded at fresh start" was a false risk inferred from a declaration's default, not the complete factory path; this risk is **CLOSED for genuinely new saves**, still not evidence of recurring income or all old saves.

**Remaining confirmed opening gaps:** scene tokens/management missing for Spirit Field and Dẫn Tiên; new recruit does not dynamically create map actor (`_spawn_all_disciples`/`_install_modular_live_actors` only at ready, sync skips unknown IDs). Existing backend save/plot/mine and older P3.6A smoke are not an end-to-end player production gate. **O1 focused Linux PASS as recorded above; O2→O6 and Windows visual acceptance NOT YET PASS, and O1 FULL remains pending.** Quantitative economy/balance deferred. No changes to DV2-03/EXP/29 recipes.

## LATEST PLANNING DECISION — FIRST PLAYABLE PRODUCTION, HYBRID PROVISIONAL (2026-10-11)

**User priority accepted for planning:** build a **playable opening game** with real disciples and real production **before** calculating/tuning economic coefficients, ROI and 1k–3k long-run balance. **Hybrid resource control accepted IN PRINCIPLE only:** Sect Master controls warehouse policy/reserves/strategic expenses; disciples execute eligible common work and use legitimate personal wealth within permissions. Ownership decisions already locked remain unchanged. Full provisional contract in `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md §30`; **not yet implemented / no numeric spending policy locked**.

**Single execution plan (updated):** [`docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md`](docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md), expanded at commit [`ed075a02`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/ed075a02b457794420e60d113223ca845eb0108f). **M1**: O0 initial clean-start authority/affordability; O1 canonical warehouse UI; O2 real disciple/recruitment path; O3 actual mining; O4 actual Spirit Field; O5 produced-resource consuming forge/available real upgrade; O6 complete main-scene/save+regression. **M2 later**, **not prerequisite to M1**: O7 Linh Lâm (renewable wood) → O8 minimal actual alchemy output+use → O9 integrated multi-production rehearsal. Numbers/economy/scale → **M3 later**. M1 first = running game, M2 = richer production, M3 = tuning. **None of O0–O9 gains PASS by the planning commits.**

**Non-deferrable integrity:** a legitimate affordable first production action; canonical warehouse balances equal UI/readiness; no double charges/output, actual disciple/worker/time, save/load. While `SectState.spirit_stones` defaults 0 at declaration, the fresh factory actually grants **500 Sect Stones** in `TechniqueSystem.initialize`; **first Field planting is funded** (3/4 Stone costs). Repeatable Stone earnings/old saves still require testing. Any needed starter resource/input change needs separate approval, not silent rebalance. No fabricated income. Code roles: `BuildingSystem` has actual Mine/Field/Guidance; `WorkforceSystem` has 5 profession constants but this does NOT make all 5 complete producers; Linh Lâm/Luyện Đan require later real contracts. Existing source benchmark ZQZS client work/manager/planStart→Complete confirmed, server output unknown.

**Current immediate action:** **O0 audit recorded**; next O1 only after scoped implementation authorization and targeted Godot tests. **No gameplay/code test changed in this planning pass; no new CI PASS.** DV2-03 ACTIVE, locked F0–F7/EXP/29 recipes preserved; Linux CI assistant-owned; **new Windows click-through, packaging and visual acceptance PENDING USER** (no PC available now). Never mark the first playable loop accepted without real scene+save test and later user Windows visual check.

## TOP DELIVERY TARGET — OPENING PLAYABLE SECT / REAL DISCIPLES / PRODUCTION (USER CORRECTION 2026-10-11)

**Controlling execution/acceptance plan (2026-10-11):** [`docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md`](docs/OPENING_SLICE_EXECUTION_AND_ACCEPTANCE_PLAN.md), **USER-PRIORITIZED / PLANNING ONLY**. P3.6/P3.6A are existing product/visual acceptance authorities; P3.7 and Disciple specs remain gameplay authorities. Ordered work packets **O0 clean-start baseline -> O1 canonical Warehouse UI -> O2 real roster/recruitment -> O3 Mine -> O4 Spirit Field -> O5 real consumption -> O6 integrated release rehearsal**. This is an integration workstream, **NOT** a new active gameplay phase; DV2-03 remains ACTIVE and F0–F7 stay untouched. **No O0–O6 gate PASS claimed**. Latest docs-only planning commit [`1f736df`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/1f736df7ab8e8225b10f72148a188448f0dc5b69). O0 read-only source audit COMPLETED; next proposed O1 code packet needs explicit authorization; no code authorization inferred from docs.

**Additional opening release blocker found in current source:** `p3_1_landscape_sect.gd` top bar/building text and `p3_2_landscape_sect.gd` Mine/Forge/Warehouse/recipe preview read legacy `forge_materials`/`technique_materials`; P3.7 `WarehouseSystem` owns canonical stacks, and `EquipmentSystem` consumes those canonical stacks. Live UI may therefore show incorrect quantity/spend readiness. Spirit Field and Dẫn Tiên building instances exist in backend but currently lack a main-map building token and management entry. Fresh-game Spirit Stone purchasing feasibility, post-recruit map actor insertion and full production-spend path remain UNVERIFIED. Details/verification checklist in the single plan; no economy numbers invented.



**Current user priority supersedes the post-F7 G1 hunting recommendation:** first ship/test an **actually runnable opening slice**: (1) launch living sect map; (2) genuine disciples visible, selectable and recruitable if recruitment is offered; (3) assign disciples to **real early production**, especially Mine and Spirit Field, with authentic timers/inputs; (4) real output reaches the canonical Sect Warehouse; (5) player sees building/resources and can consume output in an available building upgrade/craft action; (6) save, exit, reload and preserve production/progress. This is a player-operable vertical slice, **not** synthetic backend fixture success. Hunting, high-tier seals, full 29 Body gates and late economy are not prerequisites for first opening acceptance.

**Live evidence/readiness (not acceptance):** `godot/src/presentation/p3_1_landscape_sect.gd` starts `LiveGameRuntimeV2`, spawns real disciple map actors, polls world time and autosaves; `p3_2_landscape_sect.gd` exposes real Mine workforce assignment, Forge actions and disciple panel. `godot/tests/presentation/p3_6a_playable_slice_test.gd` already tests startup/actors/building interactions. P3.7A2 Spirit Field production, real plot reservations, 1 crop timer, warehouse harvest and save continuation have dedicated `godot/tests/simulation/p3_7a2_spirit_field_test.gd` backend coverage; **but current P3.2 building-control switch shows NO Spirit Field player-facing entry**. Main P3.1 bottom nav lists Tông Môn/Đệ Tử/Kho/Thế Giới, **not** a recruitment entry; recruitment UI from current opening scene is **NOT VERIFIED**. Mine-to-warehouse and building upgrade end-to-end through actual production UI still require integrated scene proof. Do not claim complete initial-play loop on backend checks alone.

| Opening acceptance checklist | Status | Owner |
|---|---|---|
| [x] Read-only ZQZS source benchmark for early workforce/production | **SOURCE PATTERN CHECKED**, not gameplay PASS: `ZQZS-Source-Knowledge` `main` `a9a638b6`; Lua `aiManager.beginWorkAI`, `disciplestatemanager planStart/planComplete`, `zongmenmodel pro_skill_id` compared with current Godot `WorkforceSystem`/`BuildingSystem`/P3.2 UI. Missing live Spirit Field management entry confirmed; output/production server authority in reference remains UNKNOWN. Details in `NEXT_CHAT_HANDOFF.md` Source-benchmark checkpoint. | ASSISTANT / GitHub |
| [ ] Real clean start → sect map + visible, selectable disciples | Existing scene and tests; **recheck integrated live opening gate** | ASSISTANT / GitHub + official Godot 4.7.2 CI |
| [ ] Real player recruitment in opening scene or clearly defined starting-disciple roster | **UI onboarding/entry NOT VERIFIED** | ASSISTANT / GitHub + official CI |
| [ ] Player assigns actual miners and obtains deposited output | Mine UI/backend exist separately; **integrated scene test required** | ASSISTANT / GitHub + official CI |
| [ ] Spirit Field accessible from opening UI, plants, advances timer, harvests to canonical warehouse | **Backend tested; UI entry missing from observed P3.2 control switch** | ASSISTANT / GitHub + official CI |
| [ ] Player reads stock, uses actual production stock to craft/upgrade, reloads consistently | **Partial UI/backend proofs; one complete loop NOT VERIFIED** | ASSISTANT / GitHub + official CI |
| [ ] Actual Windows start, click-through, visual acceptance | **PENDING USER; no PC access now** | USER LATER |

**Immediate next scope:** audit/correct only the opening production/disciple integration for the first runnable slice, in short reported packages. This correction **reorders delivery priority**, does not authorize arbitrary gameplay/balance changes, does not alter EXP or 29 Body recipes, and does not close active DV2-03. Post-F7 hunting G1–G4 findings below remain valid but are **DEFERRED from immediate opening-slice priority**. No new CI PASS claimed in this docs-only correction.

## POST-F7 LIVE CODE AUDIT — 2026-10-11 (AUDIT-ONLY, NO NEW GAMEPLAY COMMIT)

**Authority:** inspected live `main` `a206cc13a6a812c30a9da2fe07c91e4635aceea4`, AGENTS, architecture, handoff, DV2-03F §S, source and official CI. Diff `bfbf62c3..a206cc13` = 6 documentation-only commits (checkpoint/handoff/§S); focused [#38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) and cumulative FAST/FULL [#38121196717](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196717) **COMPLETED/SUCCESS at gameplay SHA `bfbf62c3`**. No newly claimed CI from this audit.

| Next practical dependency | Verified live source / status | Safe next action |
|---|---|---|
| [ ] **DV2-03G1 player-started V2 hunting** | **NOT CONNECTED**: `HuntingPveRunV2.begin/finish/claim` is exercised in tests, not mounted in `p3_2_landscape_sect.gd`; `HuntingLevelSelectorV2` is reusable but not mounted; `SimulationScheduler`'s `HUNT→COMBAT` calls legacy `CombatSystem.resolve_encounter`, **not** `HuntingPveRunV2`. A legacy `COMMAND_HUNT_REGION` is NOT a V2 battle/Body-material win claim. | Make a small real player UI → canonical region/5-level choice → eligible V2 party → unique encounter → authoritative combat/result → exactly-once warehouse claim → save/reload flow; include actual Godot scene and replay tests; do not simulate free wins or invent encounters. Auto-scheduler separately unverified. |
| [ ] **DV2-03G2 repeatable Sect Spirit Stone financing** | **UNVERIFIED / MISSING IN V2 HUNT:** `SectState.spirit_stones` initializes 0; `HuntingMapV2.preview_reward/claim_reward` yields material items, no Stone grant; real paid Rèn Thân costs 1 Stone/min and Spirit Field also spends Stones. `EconomySystem` handles ordinary treasury, **not** a confirmed conversion into Sect Stones. | Trace all funding/sinks and test repeatable earned funding with conservation, no negative balances, no double claim; numeric drop amount/split requires separate balance decision, no free timed mint. |
| [ ] **DV2-03G3 upper-realm genuine content** | **UNAVAILABLE**: only 3 authored Nhân hunt regions; 12 C–H material IDs + 3 Seal IDs and 29 exact recipe rows are registered but no real high-realm earned routes; gate source realms 7..29 remain `content_unavailable`. | Author map/monster/boss/Seal acquisition and balance in separately approved small realm bands; preserve closed gates until each source exists. |
| [ ] **DV2-03G4 full pacing/scale + player acceptance** | **NOT ACCEPTED**: F6 injects floor10 Body EXP via QA fixture, 80 wins are backend victories (not UI hunting), 1k/3k only projected; Linux focused/full green is not Windows visual acceptance. | Once true loop is connected, test natural EXP pacing + Stone sustain + full claim and save using official CI, then Windows 390×844/desktop click-through later. |
| [ ] **WINDOWS: UI smoke & visual acceptance** | **PENDING USER — PC unavailable**. No Windows Godot test, APK click-through, screenshot inspection or visual signoff claimed. | No action requested from user now; when PC available, provide exact `Sync-Main.cmd` / Godot 4.7.2 steps and retain evidence. |

**Historical post-F7 priority (SUPERSEDED by opening-slice user correction above):** G1 player-visible V2 hunt would have been the next dependency for an A/B hunt loop; it is **not** the current first-playable deliverable. G2 Stone sustain for advanced Rèn Thân remains a later dependency. G3 is high-world authored content, not a fake quick unlock. **This audit authorizes NO new gameplay code, no EXP/29-recipe tuning, no new high-tier reward, no DV2-03 closure; DV2-03 remains ACTIVE / DESIGN_LOCKED=false.**


**2026-10-11 — F1 LATEST CODE EVIDENCE:** User authorized **CODE DV2-03F F1 only** three times (repeat requests, one scoped authorization). F1 code `godot/src/simulation/cultivation/disciple_body_gate_content_v2.gd` holds **VERSION 1/29 immutable exact recipes**, 19 typed item references (A/B 4 existing, C–H 12 newly registered, 3 Seals newly registered); `resource_registry.gd` appended precisely those **15 definitions**, with typed family/grade/rank/tags and `market_value=0` unpriced placeholder. Negative validation, save JSON roundtrip, old registry unchanged, F1 availability remains `content_unavailable` for all gates, no actual loot/claim. See `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §Q. [DV2 focused official Godot 4.7.2 #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) at test SHA `1e0cf39f9122796c4c64a71d52f76b263d525051`: **COMPLETED/SUCCESS**, F1 29/562/143/3/19/15 PASS. [P3.7 FAST+FULL #38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) at test/config SHA `dec66e794a08a7ef70d9d43869441639b3a7fe06`: **FAST + FULL PASS VERIFIED** (later live GitHub run completed/success). A historical early F1 intermediate run #38117169945 failed due newly introduced GDScript parse error; corrected in later SHA `5c9e9997` and focused parse/test passed. **EXP untouched, F2–F7 not authorized, DV2-03 still ACTIVE, Windows PENDING USER/NO PC ACCESS.**

**F1 FINAL CI VERIFICATION / PLAYABLE MILESTONE — 2026-10-11:** [F1 focused #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) and [P3.7 FAST+FULL #38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) both **COMPLETED/SUCCESS on official Godot 4.7.2 Linux**. F1 data is finished and tested; not a playable material-gate feature. User-facing naming clarification: **Luyện Thể is the whole Body progression**, and **Thối Thể is its major-gate breakthrough**; label the future button **"Đột phá Luyện Thể"** (presentation proposal, not implemented or design-locked). **Minimal meaningful gameplay milestone:** a real V2 disciple earns legitimate Body EXP, earns A/B materials through actual completed activity with bounded anti-stuck, presses authorized breakthrough at current realm floor10, warehouse bundle deducted exactly once, Body advances, state saves/reloads, UI reflects real results. **F2 transaction + F3 actual earned A/B source + F4 UI must all be done and pass focused/full before claiming this playable slice**. F5/F6/F7 remain roadmap for scoped economy/regression/handoff; upper-realm C–H/3 Seals still require future real content and cannot be called playable yet. **No coding permission for F2–F7 from this status clarification**. **Windows PENDING USER, PC not available**.

**2026-10-11 — F2 LATEST AUTHORITATIVE IMPLEMENTATION STATUS:** User expressly authorized **CODE F2 ONLY** at 13:32 ICT. Gameplay: `godot/src/simulation/cultivation/disciple_body_gate_transaction_v2.gd` adds pure preview + atomic real P3.7 warehouse debit and Body realm advance, after-debit failure rollback and single per-gate receipt; `godot/src/simulation/state/sect_state.gd` stores compact receipt once and recreates O(1) request lookup after reload. QA-only subclass fixture exercises success; **production `content_unavailable` for all 29 gates**, F3 earns real A/B items later. No F3 drops, F4 UI, new EXP/29 formula, Ấn numerical or C–H maps. Full audited contract `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` **§R**. [Official Godot 4.7.2 F2 focused #38118632633](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632633) **completed/success at source/test SHA `8676590de2e499e9689e8548f3583ad704f2c6b0`**, includes test receipt + JSON/disk SaveService round-trip, locks/reserve, racing actors, Seal10, rollback; previous focused run #38118592396 failed only initial F2 test Variant inference and was corrected before success. [P3.7 FAST/FULL #38118632512](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632512) same SHA: **FAST PASS, FULL PENDING at writing**; check completed/success before marking FULL green. **Windows PC still unavailable — PENDING USER, no user action now. F3–F7 NOT AUTHORIZED, DV2-03 ACTIVE, DESIGN_LOCKED=false**. Direct SaveService still writes JSON to file and has not been upgraded for sudden power-cut atomic file replacement; do not claim filesystem crash recovery PASS.

**2026-10-11 — LATEST F3–F7 DIRECT USER AUTHORIZATION, CODE/EVIDENCE AND F7 TRUTHFUL HANDOFF:** User expressly authorized executing F3→F7 at 14:08 ICT. F3 changed `HuntingMapV2` early A/B real won-claim rewards (1 Thanh Linh Thảo Thanh Trúc win, 2 Tử Vân Thảo Bạch Thạch win; 1 guaranteed Linh Tủy/4 actual Thanh Trúc won claims), replay-safe saved `SectState.v2_body_material_progress`, and `DiscipleBodyGateTransactionV2` A/B source-readiness check. F4 P3.2 real Body gate button/preview with persistent canonical transaction after click. F5 measured arithmetic: **80 victorious claims** theoretical hunt-only input for first six gates, **NO proven self-sustaining Sect Stone source**, no actual elapsed-time/1k–3k scale claim. F6 real Godot regression **80 actual completed victories, all six A/B gate consumptions, one real paid Body EXP minute plus QA-injected floor10 EXP** (not full natural XP pacing), six saved gate receipts, 80 saved hunt claims, and high-tier fail closed. F7 exact evidence/boundary in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §S. [Official focused #38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) **COMPLETED/SUCCESS** at gameplay SHA `bfbf62c39341f71816bea877881b1137e75fdf03`. [P3.7 FAST+FULL #38121196717](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196717) same SHA: FAST PASS, **FULL PASS VERIFIED** (run completed/success, FAST and FULL job steps both success, official Linux Godot 4.7.2). P3.6A rendered preview PASS but artifact upload failed due GitHub quota in #38120846305; not a Windows UI acceptance. **PC unavailable / Windows PENDING USER. DV2-03 ACTIVE, DESIGN_LOCKED=false. No EXP or 29 recipe changes, no map/boss C–H/Ấn fabricated.**

## 2026-10-11 — DV2-03F ACTION + PC HANDOFF CHECKLIST (LATEST; USER CURRENTLY CANNOT OPEN WINDOWS PC)

**User situation:** Android/mobile only at present; no access to Godot Windows PC. Do not tell the user to run local commands now or treat Windows UI as PASS. All GitHub edits, static review, automated Godot 4.7.2 Linux CI, test evidence and docs handoff are **ASSISTANT-OWNED**; user local-PC steps are deferred and called out distinctly whenever actually needed. **User explicitly authorized F3–F7 on 11/10/2026; F0–F6 implemented and focused tested, F7 handoff recorded. DV2-03 parent remains ACTIVE. No Windows access; no local task now.**

| Check | Owner | Actual status | What to do / how to prove |
|---|---|---|---|
| [x] F0 — live main code+EXP+loot audit | Assistant/GitHub | **DONE** | F0 evidence in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §P |
| [x] F0 — Godot 4.7.2 focused | Assistant/GitHub Actions | **PASS** | [DV2 focused #38105919954](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105919954), completed success |
| [x] F0 — P3.7 FAST + FULL cumulative | Assistant/GitHub Actions | **PASS** | [P3.7 #38105926374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105926374), both job steps completed success at `cd52d4b97b673dc116606e0fb6b413aec16119b1` |
| [x] F1 — 29 immutable recipes + 12 C–H material IDs + 3 Seal IDs | Assistant/GitHub | **IMPLEMENTED, FOCUSED PASS** | `DiscipleBodyGateContentV2`, `ResourceRegistry` (15 added, 4 A/B unchanged), save/negative/F1 test; [focused #38117236823](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117236823) PASS. P3.7 cumulative [#38117245351](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38117245351) **FAST + FULL PASS VERIFIED (completed/success)** |
| [x] F2 — gate transaction+receipt | Assistant/GitHub | **CODED; FOCUSED PASS; P3.7 FAST PASS; FULL PENDING RESULT** | [Focused F2 #38118632633](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632633) PASS, [FAST/FULL #38118632512](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38118632512) FAST PASS; must recheck FULL completion; production gates fail-closed until F3 source content |
| [x] F3 — real A/B earned hunt drops + anti-stuck | Assistant/GitHub | **FOCUSED PASS; numeric yields PILOT** | Genuine won-claim Thanh Linh Thảo (Thanh Trúc), Tử Vân Thảo (Bạch Thạch), Linh Tủy guaranteed per 4 real Thanh Trúc wins, saved counter; [F3 focused #38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) PASS. No Lv30 field needed for B |
| [x] F4 — game-facing Body gate panel | Assistant/GitHub | **FOCUSED PASS; Windows PENDING** | P3.2 authentic V2 deep disciple attribute panel now displays named Body recipe, EXP, protected available stock and live `BodyGateRealCommit` button; [focused #38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) PASS |
| [x] F5 — low-tier actual source/demand arithmetic | Assistant/GitHub | **AUDIT PASS; sustained Stone economy UNVERIFIED** | 54 real Thanh Trúc + 26 Bạch victorious claims => 80 won encounters/Disciple for six A/B gates when hunt-only. 1k/3k are projections, not throughput; F05 numeric 1/2/4 rates are PILOT, not locked. Hunt Stone income is 0 in F0 baseline; no positive recurring source proof |
| [x] F6–F7 — focused/full regression and exact handoff | Assistant/GitHub | **FOCUSED + FAST + FULL PASS; F7 DOCUMENTED** | [Focused #38121196765](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196765) PASS: actual 80 won-claims, 6 real A/B Body gates with **QA floor10 EXP injection**, one real paid training minute, disk replay; [P3.7 full #38121196717](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38121196717) completed/success; C–H/Seals unavailable, PvE UI dispatch unverified |
| [ ] **Windows visual + interaction smoke** | **USER — PC REQUIRED LATER** | **PENDING, NO PC ACCESS** | When user can start Windows, assistant must give exact available Godot command/steps then. Check Godot 4.7.2 project launch, open actual sect map/P3.2, select genuine V2 disciple, Tu Vi+Body display, Rèn Thân 2 real slots and one committed paid minute; when F4 exists also Body gate button/shortage and denied high-tier content. User returns screenshots, errors and PASS/FAIL observations; do not invent Windows PASS |
| [ ] **Windows full regression only if needed** | **USER — PC REQUIRED LATER** | **NOT REQUESTED NOW** | GitHub Linux FULL already passes F0. Only ask for Windows headless regression if OS-specific bug or approval gate warrants it; avoid routine duplicate long test |
| [ ] **Future final visual acceptance** | **USER — PC REQUIRED LATER** | **PENDING** | Separate from technical CI; do not call gameplay visually accepted based on Linux |

**Next user action:** NO PC ACTION required now. F3–F7 authorization executed in sequence with F7 truthful handoff. **A/B Body gates source realm1..6 have tested real earned item sources and production transactions**, but F6 required QA-seeded floor10 EXP, full user-facing PvE dispatch/auto scheduler unverified, Linh Thạch recurring funding unverified, final rates PILOT, C–H and 3 Seals still unavailable. **Do not close parent DV2-03 or start DV2-04 automatically.** Windows remains `PENDING USER`. Do not overwrite locked EXP/29 recipes, register high-tier rewards or falsely close DV2-03.



**2026-10-11 — MOST RECENT DV2-03F STATUS F0-ONLY ACTUAL TEST:** User authorized **CODE F0 only** at 09:38 ICT (real runtime, Body EXP/loot audit, evidence, F0 tests). Implemented only `godot/tests/simulation/dv2_03_f0_source_baseline_test.gd` plus DV2-03/P3.7 CI workflow wiring. **No `godot/src/` or game/EXP/29-recipe change.** [DV2-03 official Godot 4.7.2 focused #38105919954](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105919954) at F0 test/workflow SHA `3c48bf7f763acf8b2d6cc6e52b25b81356b72de1` **PASS** including F0 audit. Log: real paid Rèn Thân minute **1,557 Body EXP** for test disciple, **−1 Sect Stone**; real victorious PvE warehouse claim **3 Linh Mộc + 1 Thanh Thiết**, **0 earned Sect stones**, persisted/double-claim rejected. Three existing low-level Nhân regions, zero early Tử Vân Thảo hunt source, Linh Tủy currently rare-only, no proof auto-expedition Body 750 scheduler. Exact factual matrix in `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §P. [P3.7 FAST+FULL #38105926374](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38105926374) at `cd52d4b97b673dc116606e0fb6b413aec16119b1`: FAST PASS; **FULL PASS VERIFIED (completed/success, official Godot 4.7.2 Linux; both FAST and FULL job steps success)**. **F1–F7 CODE NOT AUTHORIZED; DV2-03F DESIGN NOT LOCKED; DV2-03 ACTIVE; Windows PENDING USER.**



**2026-10-11 — LATEST DV2-03F OPTION A / NO CODE:** User expressly selected **A** after F01–F12 principle review: return to runnable Disciple V2 roadmap, **preserve 29 exact Body-gate formulas, 8 groups, 3 Seals, all locked EXP/rates/progression**, prioritize **actual hunting/elite/boss/region earned drops** and bounded **no-RNG-deadlock** for enabled gates. No requirement to implement 19 independent commission pipelines, C–H high-realm maps or 3 Seal-source worlds in F A/B slice; missing content = `content_unavailable`, not fabricated playable. `tu_van_thao` + `linh_tuy` have no guaranteed early route today (B blocker), must be solved **without Field Lv30** before gate4 is enabled. **F05 numeric rates PILOT/OPEN, F07 real low-tier stones proof required, F10 verify current real EXP source and keep high-realm balance UNVERIFIED** until high-tier activities/events/Pháp Bảo exist. No added EXP/item bonuses now.
**Scope authority:** `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §O (newest; §N is historical expanded plan); `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md` 11/10 priority amendment; `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` 11/10 scope correction. **DV2-03 remains ACTIVE; A/B-only playable and 29 technical fixture tests do not prove 29 high-tier gates playable or CLOSE DV2-03.** F0→F7 lean packets are *plans*, not implemented. **DESIGN LOCKED = NO; CODE AUTHORIZED = NO**. E3.1 Linux official Godot 4.7.2 focused/full previous PASS at gameplay `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`, no new CI/Godot/Windows tests in this documentation-only turn, Windows PENDING USER.



**11/10/2026 — DV2-03F DOCUMENTATION-ONLY DECISION (latest):** User has **approved F01–F12 in principle**, **NOT DESIGN LOCKED** and **NOT AUTHORIZED TO CODE**. Exact 29 Body gate quantities and existing XP remain unchanged; F05 rates are only **PILOT**, F07 recurring earned Sect-stone funding and F10 real high-realm Body EXP viability must be empirically verified. Technical implementation contract/order is `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` §N; decision handoff is `NEXT_CHAT_HANDOFF.md` top. **DV2-03 remains ACTIVE**. Latest E3.1 actual Godot source SHA with focused/full official Linux PASS remains `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`. Documentation commits after it do not implement or test DV2-03F and are not new PASS; Windows visual is still PENDING USER.


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

**Focused evidence:** official Godot 4.7.2 Linux [DV2-03 #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) at gameplay source `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`: **PASS**, including `dv2_03_p3_body_training_building_ui_test.gd` (real map token, two real assignments, overcapacity denied, release/reassign, one paid Body minute, save/load), existing focused and legacy profile gates. **P3.7 FAST + FULL cumulative:** [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594) at the same gameplay SHA **PASS** (confirmed completed/success on 11/10/2026). P3.6A earlier preview run had artifact-storage quota failure; do not confuse artifact upload with Windows visual PASS.

**Not yet approved / not implemented:** 29 exact Thối Thể recipes/consumable gate transaction, post-Lv1 building upgrade/intensity, large-roster UI search/pagination, Dẫn Tiên real recruitment UI, Windows visual. DV2-03 remains ACTIVE, never call game playable complete or Windows PASS. See `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` §DV2-03E3.

### 5.20 DV2-03F — BODY 29-GATE MATERIALS / TRANSACTION DESIGN (PRINCIPLE APPROVED, FINAL REVIEW PENDING — 11/10/2026)

**User approval is IN PRINCIPLE only:** 8 named material groups A–H, 29 per-gate quantities, and 3 repeatably obtainable consumed Seals at gates 10/20/29; deterministic 100% Body gate, no cultivation/body-level equality, multi-route guaranteed supply. **NO code, content registry, loot, new maps, transactions, CI, or Windows gate was changed/run in this design round.** Official focused/full evidence at gameplay SHA `3c7e9a76` remains previous E3.1 evidence.

**Exact final-review document (new canonical proposal, NOT DESIGN LOCKED):** `docs/DV2_03F_BODY_GATE_MATERIAL_TRANSACTION_FINAL_REVIEW.md` (main), 29 rows, 16 material types (4 existing/12 new) + 3 new Seal IDs, all 8 acquisition bands with pre-gate access, staged rollback + persistent idempotency ledger, warehouse lock/reserve handling, XP/HP authority, anti-replay tests, and SaveService direct-write crash-durability caveat. Total 562 main + 143 aux + 3 Seals per complete 29-gate journey (across distinct IDs).

**Verified production bottlenecks:** `tu_van_thao` needs Spirit Field Lv30 but gate 4 needs it; `linh_tuy` is rare chance-only in present Thanh Trúc Lâm L2–L5; present high-realm C–H material sources do not exist. Do not implement all 29 gates without every required legitimate registered source and deterministic guaranteed acquisition, or bypass `WarehouseSystem`. Need explicit user FINAL APPROVAL before authoring gameplay/content or changing EXP. Proposed acquisition throughput bands are balancing hypotheses, not locked rates.

**Next requested decision:** review the document and approve/adjust: (1) early real-quest guaranteed access to both B materials, (2) repeatable two-route Seals, (3) single owner atomically committing Body + canonical warehouse + saved receipt, manual first AI policy, (4) source throughput tuning via real source tests. Then implement only inside DV2-03F and use official Godot focused/full evidence. Windows real visual = PENDING USER.

### 5.19 DV2-03E3.1 — LOCKED TWO-SLOT TRAINING STABILIZATION (11/10/2026)

**Implement scope — USER ORDER:** fix two P1 defects documented in §5.18 without changing Lv1 two slots, 1 Sect Spirit Stone/simulation minute, 1,500 base Body EXP/minute or other V2 cultivation / Căn Cốt laws.

- `DiscipleBodyTrainingFacilityV2.has_reserved_slot` authenticates actual active group+worksite assignment and canonical 2-slot building; no fake reservation model. `DiscipleTrainingActionV2.request_training(...,"cultivation")` validates the requested V2 Chuyên Tu before releasing any real paid-training slot, returns its place to the queue, and only then queues the new action. An invalid training request does not vacate the original slot.
- `WorkforceSystem.next_action` checks a healthy, valid V2 Rèn Thân slot **after urgent injury and valid direct commands but before ordinary 20-step work schedule**. Dedicated Body policy therefore has precedence even with pre-existing per-disciple forge preferences; no accidental `WORK_FORGING` while occupying the paid slot. When finite funds block Body, fallback track is lawful or HOLD, never free Body grant. Emergency medicine/rest remains controlled by existing health decision.
- `WorkforceSystem.issue_command` releases Body reservation for any **valid** explicit user order; malformed/invalid commands do not evict. `assign_group` and `assign_worksite(...,&"")` avoid ghost slots caused by the original primary-building group-only fallback. Explicit release sets manual policy so Body does not silently restart. No retroactive stone refund and no immediate EXP grant on a command.
- The new `godot/tests/simulation/dv2_03_e3_1_training_priority_regression_test.gd` verifies invalid orders, Chuyên Tu two-to-one slot transfer, 3rd entrant, save/load, approved forged-work override, worksite clearing, active forge preferences not stealing Body training, 2 disciples across five real scheduler minutes, 6 committed paid minutes/6 stones, empty-wallet multiple additional minutes and urgent-health precedence. The existing E3 map UI integration additionally tests Chuyên Tu switch and reassign. Both focused and cumulative workflows trigger on changed code and test paths.

**Latest official focused (same gameplay/test code):** [DV2-03 #38093450321](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450321), gameplay SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c`, **PASS** (all DV2-03 focused tests, including E3.1 and original E3 map UI). **P3.7 FAST + FULL P0→P3.7 cumulative same-source:** [#38093450298](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38093450298), **COMPLETED / PASS** on official Godot 4.7.2 Linux, gameplay/test SHA `3c7e9a7691f549097dd0a67ed50ead8b7be18a4c` (both job steps success, verified 11/10/2026). Windows 4.7.2 real visual test NOT RUN / PENDING USER.

**E3.1 core implementation and focused/cumulative QA complete — no pending Windows PASS implied. Remaining E3/P2:** richer 1,000–3,000 roster search/paging and real finger/scroll review at 1280×720; no claim Windows PASS. DV2-03 overall still ACTIVE until 29 user-approved Thối Thể resources/real major-gate consumer are implemented and gated. DV2-03F should follow after cumulative result has been checked.

### 5.18 DV2-03E3 POST-PASS CODE/UX AUDIT — 11/10/2026 (REVIEW ONLY)

**Audit classification:** E3 remains **focused + FAST + FULL Linux PASS at gameplay/test SHA `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`**. Confirmed GitHub runs [focused #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) and [FAST + FULL #38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594) both completed/success. This review **did not change gameplay or run a new QA suite**; scenarios below are static source-path audit findings, not newly executed failing tests. **Windows Godot 4.7.2 / pixel visual review NOT RUN; preview artifact upload quota previously failed.**

**P1 — Stale training slot on switching to cultivation (confirmed code path; new regression test needed):** `P3_2LandscapeSect._queue_v2_training("cultivation")` changes current action and training policy, but does **not** release the `body_training_crew` and `worksite_building_id` reservation from an already placed trainee. `BuildingSystem.assigned_worker_ids/active_worker_ids` still counts that disciple, consuming one of the 2 limited slots. **Required fix:** atomically transfer/cancel old reservation when leaving Body training, never refund completed paid minutes, preserve existing manual release semantics; regression: reserve 2, switch one to cultivation, assert 1 free capacity, third trainee accepted, save/load unchanged.

**P1 — Training policy versus Workforce scheduled work (conditional code-path risk; needs reproduction test):** `WorkforceSystem.next_action` selects `schedule_phase` first, and in `work` phase `choose_work_profession` may use persistent per-disciple `work_preferences`. The `body_training_crew` work group has no blanket prohibition on legacy forging, and `BuildingSystem.work_available` returns true for non-P3.7-controlled professions. Thus a trainee with eligible positive forge preference may receive `WORK_FORGING` while reserving a Rèn Thân slot. **Required fix:** define and enforce the approved exclusive priority of an active, paid Rèn Thân assignment across work/AI scheduling, while keeping healing, explicit overrides, shortage and major-gate fail-closed. Regression: V2 trainee with pre-existing forge preference, 10+ scheduler minutes, no unintended work action or dual source, correct treasury/XP ledger.

**P2 — End-to-end resource depletion/offline test gap:** E3 UI test asserts a directly committed minute and JSON round-trip; separate focused simulator exercises scheduler and no-stone. No dedicated E3 UI scenario currently validates automatic continuation across several live wall-clock/offline minutes, running out of stone, and restoration/explicit stop. Add one saved-live-runtime test covering at least two trainees sharing finite treasury and no negative wallet/no duplicate minutes, and expose paused/blocked status.

**P2 — Large roster/selection and UX:** E3 building panel renders only the first 12 eligible V2 disciples in sorted ID order, creates controls on refresh and scrolls below a long detail label. No search/pagination; a relevant 13th+ disciple must use the separate profile shortcut. `BuildingSystem.active_worker_ids` and panel enumeration sort full roster. At 1,000–3,000 scale, add lightweight paged/filter UI, efficient slot indexing and scroll/refresh performance checks; do not claim scale verified.

**P2 — Visual acceptance gap:** E3 tests emit the map hit signal and inspect node/text/real state; they do not exercise finger hit accuracy, line wrapping/scroll visibility at 1280×720 on Windows, map camera overlap, or picture review. E3 art is procedural Godot geometry, not a final approved asset. Previous P3.6A preview artifact-storage limit is CI infrastructure, not proof of a visual PASS. Windows review remains user-owned.

**Priority decision:** fix P1 slot transfer + workforce exclusive priority and regression gates as **DV2-03E3.1 stabilization** before entering DV2-03F (29 Thối Thể material design). P2 UX/roster/long offline improvements can be separated after core blocking cases. Avoid declaring whole DV2-03 CLOSED before gates/content are authorized.

### 5.17 DV2-03E3 — MAP-CLICKABLE RÈN THÂN ĐƯỜNG AND 2-SLOT LIVE UI (10/10/2026)

**DV2-03 remains ACTIVE; E3 is a verified playable UI slice, not complete character/recruitment UI.**

- Previous full P3.7 cumulative [#38068119472](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38068119472) **PASS** at source `ca2f3077`; this was verified before starting E3.
- The P3.1 map now has one `ren_than_duong` hit target and distinct map destination for `TRAIN_BODY`. P3.2 exposes the real management panel with Lv1 2 slots, persisted occupied/empty status, actual disciple names/active actions, real treasury, 1 stone / 1 simulated minute, 1,500 base Body EXP / minute plus existing Căn Cốt, paid-minute audit counters and scheduler result when available.
- Real V2 disciple assignment uses current recruitment roster and existing `DiscipleTrainingActionV2`/paid `DiscipleBodyTrainingFacilityV2`, with no UI mint/debit/EXP. A third candidate cannot overbook. Slot release clears BOTH work group and worksite, ends pending `TRAIN_BODY` and switches to manual policy, never refunds paid minutes; freed slot is reusable.
- UI creates at most 12 candidate rows to keep large rosters bounded. Character profile can select other authentic V2 disciples.
- **Official Godot 4.7.2 Linux focused PASS:** [DV2-03 E3 #38070169637](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169637) at gameplay/test SHA `b8103b06b9e05af0391ff3e1cd007c07dc8b58df`. E3 test opens actual P3.2 scene/map hit, verifies two-slot capacity and refusal, release/reassign, treasury source and paid-minute/save-load.
- **P3.7 same-source FAST + FULL cumulative PASS:** [#38070169594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/38070169594), SHA `b8103b06`; both job steps completed/success. CI is Linux only; Windows / visual review PENDING.
- **P3.6A Godot parse/smoke and in-run image capture passed on previous UI source; workflow failed during optional screenshot upload because GitHub artifact storage quota was exceeded.** Screenshot artifact is not available for current E3, do not claim full preview workflow PASS. No local Windows execution/visual acceptance has happened.
- All user-approved economy/rate/slots remain unchanged. Exact Thối Thể material packages for 29 Body major gates, post-Lv1 upgrades/intensity, Dẫn Tiên recruitment UI, production-worker UI and Windows validation are **OPEN / NOT CLAIMED**.

See `docs/DV2_03_TWO_TRACK_PROGRESS_EXECUTION.md` §DV2-03E3 for detailed implementation/invariant notes.

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
