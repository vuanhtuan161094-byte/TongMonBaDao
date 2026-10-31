# SX-MASTER-01 — Codex execution handoff: Production · Buildings Lv1–100 · Economy · Medicine · Cultivation · PvE
Date: 2026-10-31. Status: **OWNER-REQUESTED IMPLEMENTATION / QA GATED**. This is an instruction/evidence document, NOT a green release or numeric balance lock.

## 0. Read this first — authoritative source anchors
- Repository: https://github.com/vuanhtuan161094-byte/TongMonBaDao
- Current ONE GAME integration reference **as verified in this audit**: branch `integration/one-game-v65-20261030`, SHA `199f888c7fd690830728dfbf29b6b79276e3b283`. **Re-fetch live HEAD immediately; do not assume this remains current**.
- Codex SX-00 measured runtime report: https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56#issuecomment-6544823995
- Owner priority reset: https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56#issuecomment-6542812897
- Owner SX-01 pill automation decision: https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56#issuecomment-6543033055
- **SX-01 Draft PR #57**: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/57 (head `7d5887cb5f5db452177f06649806dbf44c21e461`, based on old ONE GAME; tests NOT executed at drafting).
- **SX-02 Draft PR #58**: https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/58 (head `30aa335f70fafb6382e4448ca77ebe1f6991db7d`, targets SX-01 branch; **unverified**, ~240 tier/grade items, only 4 authored recipe IDs).
- Root-cause code ledger PR #58: https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/feature/sx02-realm-grade-medicine-20261031/docs/qa/SX02_MEDICINE_ROOT_CAUSE_AND_DESIGN_CODE_LEDGER_20261031.md
- Canonical technical source contracts to compare: `docs/DV2_PRODUCTION_RESULT_CONTRACT_V1.md`; `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`; `docs/REALM_LADDER_V2_SPEC.md`; `docs/DISCIPLE_V2_DESIGN_LEDGER.md`. Beware their earlier incompatible scales and superseded proposals.

**Priority:** production, cultivation, economy and six-member PvE playable first. **Pause** NPC factions, politics, warfare, optional online PvP, broad art redesign, organizational progression implementation and unrelated skills.

**Ownership:** ONE integration writer at a time. The running Codex session finishes its existing job first; this file is NOT automatically delivered to a live terminal. Codex must fetch and acknowledge reading this file. Separate QA E:\ checkouts, never edit live saves, `main`, legacy PR #52, or another worker's branch. No merge without owner review and measured QA.

## 1. CODEx SX-00 observations — evidence vs hypotheses

### Confirmed
Official Windows Godot **4.7.2** reported import **PASS exit 0, 30.58 sec / 103 steps** on exact source SHA `199f888`. **10/14 focused tests passed, 4/14 FAILED (exit 1)**:
- `p3_o3_real_mine_loop_test.gd`: Mỏ `haul_back` state not intact after reload.
- `p3_o7_linh_forest_test.gd`: Linh Lâm `haul_back` not intact.
- `p3_o8_alchemy_loop_test.gd`: pending timed recipe lost/restarted on reload.
- `p3_o9_m2_production_rehearsal_test.gd`: simulation tick changed after reload.

The four test scripts invoke `ui.call("_autosave_runtime")` without awaiting completion and then dispose/reload. stderr includes unfinished Thread. **Likely asynchronous test-harness race; NOT yet proof against a production SaveService defect**. `SAFE-01` malformed JSON stderr is an EXPECTED negative fixture with its own PASS marker, do not misclassify.

10 PASS: O1 Warehouse UI, O4 Spirit Field, P3.7A1, P3.7A2, P3.7B1, Economy-A playable/UI, SaveService async roundtrip, SAFE-01, SAFE-02 (as summarized by Codex). GUI input/capture **BLOCKED**: no gameplay screenshot, user new game/continue or real units/hr evidence.

Local Codex evidence **exists only on user's Windows drive and is not readable from the GitHub text**:
`E:\TongMonBaDaoWorkspace\QA_Evidence\SX00_199f888c7fd690830728dfbf29b6b79276e3b283_RUNTIME_EVIDENCE_20261031\`. Ask Codex to publish sanitized full log matrix and code-repro to a docs/evidence branch or GitHub issue; don't pretend assistant already read the local logs.

Research cross-check: Godot 4.x `await` is necessary to wait for a coroutine's result; threads should be joined with `wait_to_finish()` before disposal. Documentation: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html and https://docs.godotengine.org/en/stable/classes/class_thread.html . Verify actual project's SaveService barrier API; do not blindly insert a guessed await.

## 2. ROOT CAUSES — fix at authority boundaries, not just numbers

**RC-1: Design ≠ runtime**: many specifications for 30 cultivation realms, 100-level facilities, 10+ gear slots, alchemy quality and economy were disconnected from producer–consumer data. Narrow B3 pilot hard-coded 2 recipes, basic stack item ids and +55/+10,000 effects. Passing pilot tests does NOT certify game completeness.

**RC-2: No source→consumer traceability:** `ResourceRegistry` includes higher-level materials with no complete real earning path. `tam_mach_ban` required at Mine Lv10 but no ordinary acquisition path found; `linh_tuyen_chi_tam` needs 100 fragments each with baseline 5% crop-drop, expected 2000 harvests/heart before modifiers; compare gates and failure tails. `tu_van_thao` unlocks only Field Lv30 but PR #58 uses it for realm-2 medicine. Risk of unreasonable dead zone / impossible progression until physical route proven.

**RC-3: Incomplete upgrade authority:** ONE GAME integration `BuildingSystem.DEFINITIONS` explicitly disables upgrade for `linh_forest` and `alchemy_hall`. PR #58 introduces *provisional* upgrade coefficients for `alchemy_hall`; this is not a finalized economy/content plan. Mine/Field milestone component gates need live supplier tests. Forge remains old instant recipe and V2 equipment contract isn't implemented.

**RC-4: Economy and sinks disconnected:** Economy-A Market default only 20 units/day tradable among 4 materials; max among these has 8 Spirit Stones unit sale, implying **up to 160/day** from this specific channel, while continuous Body Hall costs **1,440 Spirit Stones/day per person**. This does not prove full money production lacks other sources, but establishes a severe potential throughput mismatch. Compare whole cashflow before balance changes.

**RC-5: Incomplete independent QA:** 4/14 tests fail, true GUI blocked, source-only rates are not game-measured throughput. Need full real Player Journey + Save/Offline + Android landscape, not 240 registered IDs as proxy.

**RC-6: Design authority drift:** older doc targets 1,000–3,000 disciples / five hunters, current owner target ~90 Human /200 Immortal/400–500 Divine and SIX per PvE team. The earlier 39-month roadmap is superseded by **cumulative** ~3 months to finish Human, ~12 months enter Divine, ~24 months finish Divine for normal non-paying progression. 27 Sect ranks (9 per macro-world) != 30 individual Cultivation major realms ×10 floors. Organizational scale remains PAUSED, do not implement now.

## 3. PREMERGE CRITICAL REVIEW OF PR #57 / #58 — NOT VERIFIED PASS

Before importing PR #57/#58, inspect exact code and author regression tests for these likely/visible issues:
1. **Save/async persistence:** All O3/O7/O8/O9 awaits must use actual durable SaveService completion signal, no fire-and-forget on scene dispose, no thread leak. Then re-run on pristine 199f888 baseline: **if 4 still fail, investigate product bug**, not just test.
2. **Tier/grade vs real crafting:** PR #58 registers **30 × 4 × 2 = 240** individual items, but only realms 1–2 × 2 lines have recipes. Realm 3–30 **CONTENT_PENDING**. Do not label complete, do not invent a generic resource to bypass missing tiers.
3. **Upgrade softlock:** Realm-2 `tu_van_thao` requires Field Lv30; Field Lv10 needs a `linh_tuyen_chi_tam` and Mine Lv10 needs `tam_mach_ban` with no verified source. Prove reachable with zero QA seed, or change source contract after explicit balancing review.
4. **Production planning mismatch:** `SX01PillPolicy.stock_plan` counts only legacy `hoi_xuan_dan` and `tu_khi_dan`; new graded stacks and in-flight outputs are not aggregated into targets. `planned_recipe` auto mode only selects original two recipes. Thus auto policy cannot yet manage tier/grade demand end-to-end. Implement canonical per-family/per-tier/per-grade stock targets with existing Warehouse reserves, without writing a second store or discarding fixed mode.
5. **B3 craft mutation order:** `B3MedicalAutoplayV1.craft` assigns group/worksite and changes Hall recipe BEFORE `workforce.perform_work` validates professional prerequisites/building level and commits input. If that later returns failure, verify no hidden lasting assignments/recipe change or add transaction preflight/rollback. Test invalid upper realm/job, consumed input zero, worker not stolen.
6. **Quality generation:** `MedicineCatalogueV2.produced_quality` uses deterministic profession/hall thresholds. The FOUR grade labels and potency multipliers 1.00/1.25/1.55/2.00 are **provisional NOT owner locked**; test grade provenance, no silent universal RNG or bonus. No fake high-grade outputs from unattainable Hall levels.
7. **B3 receipt migration:** Legacy HXD +55, old TQD +10,000 fixed, 10/25 saturation, 1,000,000/day and Injury120 **must remain byte-compatible on old saves**. New graded receipts must survive save, reload, versioned consistency checks, replay, corrupt receipt rejection, impossible HP/XP/gate overflow. One Active Job/Disciple; safe Chuyên Tu use must not permit production/Body/PvE contamination, active `worksite_building_id` and command gates deserve explicit tests.
8. **Medicine allocation policy:** `MedicineAllocationV2.best_available` currently only considers stock at rank <= user's cultivation realm. Whether over-tier use is forbidden or waste-capped is unapproved; DO NOT silently lock that design as a permanent rule. Test low-tier high-realm insufficient healing, high-tier low-realm policy, near breakthrough XP overflow and locked/reserved items.
9. **GUI:** The 1280×720 map must remain primary. No giant dynamically generated controls for 240 pills; prioritize filters by family, cultivation tier, grade and stock, empty/locked/shortage reasons, and icons prepared for actual PNG. Screenshots **only from real Godot**.
10. **Danger of underspecified economy numbers:** Only owner-locked direction is 30 major medicine tiers and medicine having **phẩm**. Grade count/coefficient, potency scaling 1.65, hall upgrade pricing/quality thresholds, crop rate and tier2 ingredients are trial candidates needing simulation/review. Do not rewrite canon merely to pass tests.

## 4. Authorized execution stages (ONE WRITER; commit each focused phase)

### G0: Evidence/control baseline — REPRODUCE FOUR FAILS FIRST
- Confirm currently running Codex task is complete and remote/local exact HEAD. Make immutable source+test snapshot; create isolated E:\ QA worktree + clean `user://` profile with no production saves.
- Run exact Godot 4.7.2 import and 14 existing tests with exit code and marker. Publish full `SX00_TEST_MATRIX.csv` and sanitized logs SHA.
- Correct O3/O7/O8/O9 test-harness async wait + proper SaveService join, WITHOUT masking data assertions. Run same four tests before/after and an independent SaveService diagnostic. If still failing, pinpoint in production code with a minimal reproduction and fix the **actual persistence source**. Stop if cannot pass or if save integrity cannot be proven.
- Gate: **14/14 baseline tests runtime PASS** (or explicitly separate confirmed unrelated baseline FAIL with owner risk acceptance). No inferred PASS and no force-close external Godot window.

### G1: SX-01/02 code hardening — PR review before integration
- Review both Draft PRs separately against correct ancestry; fix compile/import errors on an isolated QA branch; no cherry-pick onto busy integration branch.
- Unit+runtime regressions: `sx01_pill_policy_test.gd`, `sx02_medicine_catalogue_test.gd`, `sx02_medicine_runtime_test.gd`, legacy `b3_pill_satiety_test.gd`, `b3_care_pills_autohunt_test.gd`, O4/O8, GP occupation, V2 cultivation, async SaveService. Include all 10 high-risk cases above.
- Real loop: **paid Field planting → harvest → real Alchemy worker/time → graded Warehouse pill → B3 manual / auto use → HP/Tu Vi changed → Save/Continue/Offline once**; test absence of item inputs, locks and reserve. No fixture-only trial can count as a full economy loop.
- Gate: official Godot import, all focused and regressions PASS + no old-save damage; no merge until interactive proof.

### G2: SX-building + upgrades Lv1–100 — reachable progression
- Audit **Mine, Linh Lâm, Linh Điền, Luyện Đan Điện, Luyện Khí, Rèn Thân and all required support buildings**, test at Lv1/9→10/19→20/29→30/49→50/74→75/99→100. Keep distinction facility-level 1–100 vs disciple cultivation 1–30 vs sect org rank 1–27.
- Export for EACH level: inputs, time, throughput per actor, slots, output, unlocked recipes/crops, source of milestone special component, price, expected earning time, sink(s) and condition/softlock.
- Examine locked owner target **Lv100 common-resource yield ×10,000**: define mathematically consistent production function and test early/mid/endgame without making lv1 produce endgame-sized rewards. Do not push arbitrary economy multipliers as final without measurements/owner review.
- Solve real supplier path for `tam_mach_ban`, Spirit Field Hearts (100 fragments per; base5% currently), `tu_van_thao`, higher herbs, artisan/forge ingredients with non-RNG fallback or guaranteed progression as approved. Document recipes as **blocked** until real source exists. Do not grant test resources in gameplay.
- Gate: no dead-end milestone in tested reachable route; tech unlocks have meaningful consumers.

### G3: Whole Economy + Cultivation + PvE loop
- Generate `SX_RESOURCE_SOURCE_CONSUMER_MATRIX.csv` for **EVERY ResourceRegistry ID**: authoritative producer and conditions, probabilistic rate/expected&tail risk, warehouse/locked/reserve, conversion recipe, end consumers, current stage actually achievable, and status `LIVE / SOURCE_MISSING / SINK_MISSING / BOTH_MISSING / DEFERRED`. Dynamic 240 medicine IDs may be rolled up for reporting but must be systematically covered.
- One economy ledger for Spirit Stones and personal wallets: crops, wages, Mining/Forestry, Alchemy, Forge, Body Hall, upgrades, Market caps, real PvE rewards, shipping, lost sales; compare 1h/1d/7d and 90/365/730d scenarios to agreed no-pay pacing, but do NOT enforce hard real-time waits.
- Tu Vi/Body V2: trace XP-source→B3 / Body training→major gate, exact 30×10 lines, proper fixed vs percent bonuses, no overflow and no double use; Injury120 separate.
- PvE 6-person normal→elite→boss loot → Warehouse + Spirit Stones + EXP direct; `LOOT_PENDING` means no claim of full reward loop until coded/tested. Do not add unapproved drop numbers; propose a source-backed loot table and get owner approval before broad implementation.
- Forge V2 10 regular +3 Fu +2 relics +4 consumables, 12 qualities and 24 sets is design direction; legacy 3-slot forge is NOT a finished implementation. Handle in separately scoped packet, don't produce huge untested patch.
- Gate: first **actual playable loop** from new save demonstrates production→medicine/cultivation→PvE→return loot→reinvestment; full endgame balancing later.

### G4: UX/Save/Offline/performance
- Real Windows 1280×720 mouse/touch GUI capture, labels visible and selectable; if Computer Use cannot target window, **report GUI_BLOCKED**, use a separately authorized reliable local capture path (e.g. user-run screenshot), never fabricate.
- Save mid-mine haul, mid-forest haul, mid-field growth, mid-alchemy, before and after pill debit, mid-upgrade, PvE settlement, offline catch-up, Return/Reload (different restarts), double click, interrupted threads and checksum recovery.
- Low-RAM official Godot4.7.2: sequential processes, isolated `E:\` QA with free RAM gates, no forced global Godot kill, no fake crash PASS. FPS/memory benchmark at 6/90/200/480 disciples with offscreen sim and representative real workers, avoiding quadratic UI loops.

## 5. Stop conditions / no-go contract
Stop current phase and report `BLOCKED`, without switching to magical shortcuts, when:
- local checkout is wrong SHA/dirty/cannot auth (use official GitHub download or owner-provided checkout, not another tree);
- SAVE thread is unresolved, save corruption or mismatched ledger;
- a key ingredient only exists through test fixture, no legal acquisition route;
- a recipe has no signed-off balance/original provenance but is treated as final;
- B3/Cultivation/One Active Job/legacy receipt regression occurs;
- GUI is inaccessible (mark `GUI_BLOCKED`), or no exact code/test SHA;
- machine RAM threshold fails; use focused import/tests one process at a time.

**Do NOT declare FULL DONE** from registry IDs, headless imports or 10/14 tests alone. G0 precedes G1; later G2–G4 require owner review at each evidence checkpoint.

## 6. Mandatory deliverables to GitHub (not only local paths)
Produce on ONE separate Codex QA branch, push after focused commits:
1. `docs/qa/SX_MASTER_IMPLEMENTATION_STATUS.md` — exact branch, code SHA, test SHA, Windows Godot version, per-gate PASS/FAIL/BLOCKED, known debt.
2. `docs/qa/SX_MASTER_TEST_MATRIX.csv` — each test command, time, exit, PASS marker, old/new SHA, evidence path.
3. `docs/qa/SX_RESOURCE_SOURCE_CONSUMER_MATRIX.csv` — every resource family/item, producer, recipe, uses, unlock, bottleneck.
4. `docs/qa/SX_BUILDING_LV1_100_BALANCE.csv` — all construction level costs, upgrade work/time, milestone component source, number of workers, output/h at realistic tick and profession rate.
5. `docs/qa/SX_ECONOMY_LEDGER.csv` — by time period, resource in/out, personal/sect Stones and sinks, 6/90/200/480 actor scenarios.
6. `docs/qa/SX_MEDICINE_SOURCE_QUALITY_MATRIX.csv` — 30 realms × two families × grades, whether actually craftable/obtainable, quality origin, potency cost, safe B3 consumer, blockers.
7. `docs/qa/SX_SAVE_OFFLINE_PARITY.md` — durable exactly once, same seed same results, online/offline and sample UI evidence links.
8. `docs/qa/SX_OPEN_DEFECTS.md` — P0/P1/P2, file+line+repro+impact+fix owner, no hand-wavy PASS.
9. An issue #56 update with links, explicit next recommended Codex packet and remaining owner approvals. Archive local evidence manifest or sanitized ZIP where feasible; don't publish private files/saves or secrets.

## 7. Exit criterion
**Production is complete only if the real player on a fresh profile can** assign a worker→grow/harvest/mining/forestry→warehouse→produce a **real graded pill with lawful materials**→use it with exact shared satiety and HP/Tu Vi effect→progress cultivation/Body under gates→hunt with six members→receive legitimate monster/elite/boss rewards→craft/upgrade using that reward→save/quit/reload/offline with no missing or duplicated debits/credits. A prototype limited to Human realm may pass *Human vertical slice*; that must not be called 30-realm complete.

**Review scope:** This handoff does NOT authorize speculative full equipment/NPC systems or blanket rebalance. Numeric laws not explicitly owner locked remain candidates. Code must follow evidence and owner authority.
