# SX-03A — INDEPENDENT SOURCE / SINK / LEVEL / ECONOMY AUDIT
**2026-10-31; AUTHOR: ChatGPT; STATIC CODE DERIVATION ONLY; BASELINE SHA `199f888c7fd690830728dfbf29b6b79276e3b283`.**

**Do not call this an in-game test.** Official Godot 4.7.2 actual Codex G0 test result is reported independently at Issue #56 comment `6545402638`: 14/14 PASS after fixing async awaiting in four focused test scripts on branch `codex/sx-master-01-g0-async-save-20261031`, Draft PR #59. This audit neither edits G0 tests nor changes ONE GAME game files.

## Produced verifiable work products
1. [`SX_RESOURCE_FULL_LINEAGE_20261031.csv`](SX_RESOURCE_FULL_LINEAGE_20261031.csv): **423 unique resource IDs**, machine-checked: 29 current base `ResourceRegistry.DEFINITIONS`, 154 dynamic V6.3 codex manual/fragment IDs in `godot/data/combat/v63_archive_catalog.json`, and 240 proposed graded pill IDs from Draft PR #58. For each: source, consumer, provisional status and reference. **Catalogue registration is NOT a verified obtainable source**.
2. [`SX_BUILDINGS_ALL_600_LEVEL_ROWS_20261031.csv`](SX_BUILDINGS_ALL_600_LEVEL_ROWS_20261031.csv): **600 rows** for 6 `BuildingSystem.DEFINITIONS` building types × target Levels 1–100; actual formulas and status, costs, worker slots, field plots, milestone components and *theoretical* production ceiling. The CSV generator was corrected to read the actual `const DEFINITIONS` (rather than earlier `MILESTONE_COMPONENTS` identically named keys) and spot-checked against source: Mỏ base 2 worker slots, wood4/ore6/stones20; Linh Điền base 4 worker/plot slots, wood6/ore3/stones18. Final published CSV is corrected; first intermediate wrong commit must not be used.

## P0 hard findings / evidence and exact action
**P0-01 Mỏ upgrade cannot reliably pass Lv9→10, Lv19→20 is CODE-BLOCKED.**
`BuildingSystem.MILESTONE_COMPONENTS["mine"]` only defines key 10 → `tam_mach_ban`; this component has a registered resource ID but **no normal player-acquisition route found** in checked `SpiritCropRegistry`, `AlchemyRecipeRegistry`, `EquipmentSystem.RECIPES`, Economy-A market and `HuntingMapV2.REGION_CONTENT`. `can_start_upgrade` fails for Lv19→20 with `milestone_component_not_defined` because `requires_milestone_component` defaults true. No higher Mine milestone is defined.
- **Fix acceptance:** source Tầm Mạch Bàn through a real authorized chain; author milestone schema for each required higher level or explicitly owner-approve equivalent gates. Test Lv9→10→Lv19→20 from **fresh unseeded** save with material acquisition receipts.
- Code: `godot/src/simulation/building/building_system.gd` `MILESTONE_COMPONENTS`, `_milestone_component`, `can_start_upgrade`.

**P0-02 Linh Lâm and Luyện Đan Điện upgrades are explicitly disabled on ONE GAME baseline.**
`BuildingSystem.DEFINITIONS.linh_forest.upgrade_enabled=false`, and `alchemy_hall.upgrade_enabled=false`. `ren_than_duong` remains explicitly `body_training_upgrade_content_pending`. Draft PR #58 changes the Alchemy Hall gate with **candidate generic costs**, which are NOT an owner-approved Lv1–100 economy design. Do not imply live release supports level 100 for these.
- **Fix acceptance:** source-backed scalable forest/Alchemy/Body work-station progression, author benefit per level (output/time/slots/recipes), no accidental cheaper skip of other gates, staged UI/Save tests.

**P0-03 Linh Điền heart progression is probabilistically extreme at default values.**
Per `BuildingSystem`: fragment 5% per completed harvest before `rare_factor`, 100 fragments →1 heart; milestones Lv10/20/30/50/75/100 require 1/2/3/5/8/10 hearts = **29 hearts** =2,900 fragments = **58,000 expected completed harvest rolls at p=0.05** (not a maximum, no guaranteed finite completion if RNG). This is a baseline expected value, not a gameplay runtime timer, and level increases/rare_factor/speeds affect timing. Current code grants at most 1 fragment per successful roll.
- **Fix acceptance:** propose owner-reviewed deterministic pity/fragment gain from meaningful PvE production, or adjust acquisition throughput only after measuring economy. Add multiple-seed p50/p95 time-to-milestone and no-deadlock tests.

**P0-04 Owner Lv100 yield ×10,000 is NOT the same as current code.**
`_resource_job_batch_units` is `base_batch_units + floor(level/10)`. Mỏ/Forest base2→12 per batch from Lv1 to Lv100 = **×6 per worker job**. Worker slots `2+floor(level/5)` = 2→22. Theoretical full-occupancy Economy-A at unchanged 10 ticks/job and speed=1: Lv1 2 slots×2×6=24 units/h vs Lv100 22×12×6=1,584 units/h, **×66**, *not* ×10,000. This is theoretical, not measured; real speed modifiers, job availability and staffing change the outcome. Forestry upgrade unavailable so Lv100 Forestry row is hypothetical.
- **Fix acceptance:** define total/worker yield metric and design scalable lawful curve aligned to owner demand ×10k; simulate entire upstream/downstream sinks before implementing multiplication to prevent massive inflation.

**P0-05 Funding mismatch, not proven complete-economy failure.**
Economy-A `V2_MARKET_CATALOG` restricts merchant sales to 4 commodities; baseline `market_daily_units=20`, max sell price 8 Stones (`thanh_thiet`) → at most **160 newly minted Sect Spirit Stones/day via THIS trading channel**. Body Hall costs **1 Stone/min per training disciple** → 1,440/day/person if always active. Other income/expense may exist; this is a lower-dimensional revenue–cost mismatch, not proof no other source. Paid seeds, wages and upgrades compound burden.
- **Fix acceptance:** measure all legal Stone ingress/outflows using **real** battle + market + wages + jobs, reject impossible economic service uptime for ordinary players, compare 90/200/480 roster cohorts.

**P0-06 Tier/grade catalogue is not a complete production/consumption network.**
PR #58 adds 240 metadata IDs (30 ×2 ×4) but only four Rank1/Rank2 `MedicineCatalogueV2.authored_recipes`. PR #57's `SX01PillPolicy.stock_plan` and `planned_recipe` target *legacy* HXD/TQD stacks only, not new 240 product stocks. No full auto-demand policy for every tier/grade, no complete ingredient sources or QA. `B3MedicalAutoplayV1.craft` mutates worker assignment and Hall standing recipe before later `perform_work` validates and commits; negative-case rollback/rejection test needed.
- **Fix acceptance:** canonical grouped demand forecast, no warehouse duplication, no grade mixing, stable Save/Offline, negative transaction test with invalid recipe/level, source-to-sink receipt and GUI consumption for two reachable ranks first.

**P0-07 Real PvE F3 supply distinguishes field bottlenecks.**
`HuntingMapV2.REGION_CONTENT["bach_thach_khe"].resources` explicitly includes **`tu_van_thao`: 2** in ordinary reward preview. Thus **false** to say Tử Vân Thảo *only* comes from Linh Điền Lv30. Field Lv30 is the *farming* unlock, and the F3 PvE source offers a conditional earlier alternative. Prove actual Bạch Thạch Khe encounter → settlement → Warehouse usable receipt (not merely `preview_reward`).
`linh_tuy` is included as Thanh Trúc Lâm rare with 4-win guarantee in code; confirm accessible in actual PvE before counting it as proven.
- **Fix acceptance:** exact per-kill or per-encounter payout and consumption, one receipt per monster/encounter, XP/Spirit Stone/loot invariants; distinguish `HuntingMapV2` F3 result from open-world `HuntingPveRunV2` generic LOOT_PENDING.

**P1-01 Recipe name contradicts inputs.**
`EquipmentSystem.RECIPES["huyen_thiet_quyen_sao"]` (Huyền Thiết Quyền Sáo) actually consumes 3 Thanh Thiết +1 Tinh Lang Bì, **no Huyền Thiết**. `huyen_thiet` has a rare PvE producer but no proved current recipe sink in the five `RECIPES`. UX and content inconsistency; owner-review nomenclature/recipe before changing saved items.

**P1-02 Metadata-only Body gate content cannot unlock C–H.**
`DiscipleBodyGateContentV2.CONTENT_AVAILABLE=false`, `DiscipleBodyGateTransactionV2` only authorizes source-backed early A/B (`HuntingMapV2.early_body_sources_ready`). Groups C–H and Seals are registered but do not have validated normal source and playable gate, so cannot claim 30×10 Body chain complete.

## Why game felt shallow — architectural correction
- A game system is NOT done because its type exists, its level=100 is displayed, its item ID is registered, or pilot/headless test passes. **A production feature becomes playable only with actual producer→transport→warehouse→consumer→effect→reinvestment→durable Save/Offline and GUI evidence.**
- Missing **design→code→QA coverage** allows new feature proposals to outrun actual source/sink authority. Existing Economy-A limits and unrelated V2/legacy ownership operate at incompatible scale.
- Every design decision should be registered as **LOCKED_OWNER / CANDIDATE_BALANCE / CODED_NOT_TESTED / RUNTIME_TESTED / GUI_TESTED / BLOCKED**, with exact SHA and milestone status. Superseded 39-month progression docs and gameplay priority are NOT sources for new code.
- Avoid separately invented economy module, money wallet or medicine list. Consolidate within WarehouseSystem, BuildingSystem, EconomySystem, B3 and canonical SaveService.

## ONE narrow next engineering task for Codex
**Do not interrupt Codex G1 work.** Once current task is complete, Codex should:
1. Read these exact two CSVs and report; verify against live integration HEAD and the most recent PR branches. Rebuild if code has advanced.
2. For **SX03-P0** first choose and implement *source-complete Mine upgrade Lv9→10→Lv19→20* + safe Forestry upgrade path, **only after owner has approved acquisition/balance**, with focused tests from fresh New Game, real no-seed suppliers and Save/Reload; do not move to general level100 rebalance until real supply exists.
3. Demonstrate two medicine families, ranks 1 & 2, ingredient sources including early PvE route, cap protected stock and usage, with original B3 compatibility.
4. Publish independent code SHA, stderr/stdout/exit, GPU/CPU/RAM evidence if measured and real GUI screenshot. If still pending, mark BLOCKED, not PASS.
5. Before work on many IDs, identify high-volume recurring data/AI/warehouse per-tick loops for 90/200/480 disciples; no automatic 423-ID scan every frame.

## Documentation precision
The two CSVs are source-derived **review artifacts**, not game-certified economic values. All rows indicate source SHA, and statuses distinguish RUNNABLE vs BLOCKED vs THEORETICAL. Any named source/consumer needs in-game test for release claims. PR #57/#58 remain Draft.

**GitHub audit branch**: `docs/sx04-master-audit-handoff-20261031`; source baseline `199f888c7fd690830728dfbf29b6b79276e3b283`.
