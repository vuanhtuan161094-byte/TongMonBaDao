# CURRENT CHECKPOINT — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-25 (Asia/Ho_Chi_Minh). Owner request: consolidate the project and remove obsolete instructions. Documentation cleanup only; runtime and branch integration are unchanged.

## 1. Read this before choosing a branch

**There is no single branch containing all current work.** Official trunk is `main@29b5fba448b0178cb520a4ada44b375b4b934e31`. The newest locally verified sect-map candidate is PR #32; PR #33, PR #34 and CODE-R0 are separate unverified descendants of older integration points. A newer timestamp does not make one of them the complete game.

This file is the project status entrypoint. `NEXT_CHAT_HANDOFF.md` contains continuation instructions; subsystem specs define rules, not progress. Old checkpoints embedded on research/feature branches are historical unless explicitly reconciled here. Fetch the exact branch HEAD before editing; the table below is a dated snapshot.

## 2. Current branch and evidence matrix

| Workstream | Exact snapshot | What exists | Evidence / remaining boundary |
| --- | --- | --- | --- |
| Official trunk | `main@29b5fba4` | Economy-A merged via #1; six TMB skills merged via #23 | Does not contain the unmerged CARE → D7 → S1 → map stack |
| Integrated gameplay | [PR #31](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/31), HEAD `9eb4fd55`; tested code `4b02a0c61a2771d9d4638129d96b68ad292270dc` | P3.2, CARE continuous hunt/recovery, D7, Source A view, Combat V3-S1 statuses | 28/28 focused + 56 S1 checks; automated real-scene evidence; no release/human acceptance |
| Sect map Option B | [PR #32](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/32), HEAD `c6bde70f` | MAP-D1B functional zoning on the existing sect map | Report + 29/29 raw focused results; owner visual/Android pending |
| Sect map candidate | [PR #33](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/33), HEAD `7a551ca4` | MAP-D2 candidate worksite SVGs, scenery, static overlay/index/navigation caching on #32 | CODE COMMITTED; official Godot import/tests/screenshots/benchmark pending |
| PvE presentation | [PR #34](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/34), HEAD `dae86efd`, based on #31 | CARE forest scenery; separate 20-camp topology preview | CODE COMMITTED, UNVERIFIED; preview is not a live 300-monster world |
| Reward isolation | `code/code-clean-finite-reward-20261025@5fbdbc6309c3f1386f0d8b619831e007c5a52824`, based on #31 | Finite/continuous reward boundary guards | Source committed; no official Godot QA PASS |
| Baseline QA | `qa/code-r0-finite-world-20261025@c87f659e2648f258553a901cfce3fe4e3eafa7fa`, based on CODE-CLEAN | Static scan, 21-test workflow and local runner, infrastructure investigation | Native git grep not executed; Godot 0/21 executed; QA BLOCKED |

All #24–#34 are OPEN/DRAFT/UNMERGED at this snapshot. #29 and #30 supplied selected S1 code/fixes already carried by value into #31; they are not a second feature bundle to apply blindly.

Ancestry: main → #24 CARE → #25 playable CARE → #26 MAP25/G1 recovery → #27 D7 → #28 UI/verified assets → #31 S1 integration → #32 Option B → #33 MAP-D2. #34 and CODE-CLEAN/R0 each branch independently from #31. **Neither #33 nor #34 contains CODE-CLEAN/R0; R0 does not contain #32/#33/#34.**

## 3. Runtime established by the current integration evidence

- Official Godot 4.7.2; Android landscape design baseline 1280×720.
- Gameplay truth remains in SimulationState/runtime, one scheduler, canonical Warehouse, SaveService and One Active Job. Combat V2 math/state remains the base; the integrated V3-S1 effects have real consumers. Combat V5 is a presentation adapter, not a second combat authority.
- PR31's real P3.2 capture records a genuine V2 recruit, Mine stock 37→39, S1 burn/weaken/guard, one Thanh Lang kill/warehouse receipt, same-world respawn, return and same-build save reload without duplicate payout. Capture setup is an isolated acceptance fixture, not player progression balance.
- B3 CARE is a continuous hunting **pilot**, with real recovery and Injury 0/1/120 ticks. It does not establish a completed 30-hunter/300-monster world.
- D7 foundation V3 is in the integration candidate and its regression is included in the scoped results. Do not restore older foundation formulas from chat summaries.
- Pill satiety pilot: 1,000,000 points/disciple/simulation day; day from canonical tick/1440, shared across pill types. Hồi Xuân costs 10 and restores 55 HP; Tụ Khí costs 25 and grants 10,000 fixed explicit-source Tu Vi. These are early pilot pills; stronger-realm content is separate. No kill-to-XP feature is established by this status cleanup.
- Two independent Tu Vi / Luyện Thể tracks retain 30 realms ×10 floors. Existing finite legacy/save/material consumers still exist and must not be deleted just because continuous hunting is the selected product direction.

## 4. Map and art boundaries

Sect map: 192×192, chunks 16×16, starter 48×48. PR32 changes visual composition/routes in the real P3.2 scene while preserving gameplay state. Its report records a 60-second Windows benchmark on Intel Iris Plus; that result does not certify #33 or target-device performance.

Verified MAP25 set: **32 hash-gated Source A PNGs**. Three building sprites are Main Hall 510052, Warehouse 510102, Forge 520081. The verified set does not supply a complete Mine/Forest/Field building family. PR33's three original SVGs are unapproved candidates, not restored Source A masters or production animations.

PvE: current CARE battle coordinates 36×20 and the separate proposed Thanh Trúc Lâm world 256×192/20 camps/300 normal monsters are different contracts. PR34's topology preview has no authoritative 300-monster simulation, farming AI, Boss loop or new loot economy.

## 5. Work that remains open

| Area | Current disposition |
| --- | --- |
| #33 and #34 | Official Godot import/parse/focused QA and real captures on each final tree; performance claims require measurement |
| CODE-R0 | Recover execution; run native grep + 21 configured tests, fix only reproducible in-scope defects; R1–R6 are not started |
| GitHub Actions | R0 evidence update proves runner_id=0 and steps=[] across multiple workflows, logs 404 BlobNotFound; exact account/platform restriction remains UNKNOWN |
| Combined candidate | No tested tree yet combines #33 + #34 + CODE-CLEAN; integration and main cutover require their own scope/evidence |
| Device/release | Owner visual, human Windows input, Android touch/device, physical interruption/storage faults, 1k–3k population profiling remain pending |
| Older QA administration | GP-02C1 overall QA remains OPEN; DV2-03 historical PAUSED NOT CLOSED is retained as administrative debt, not proof that all later Body/progression work is absent |
| Content design | C4 Công Pháp, equipment/Forge R1–R30, R11/R21 frontier/source economy, direct-kill Tu Vi and multi-camp world research remain separate design streams; individual approved rules are not implementation proof |

Do not relabel previous scoped PASS as latest-tree FULL, CI, Android or human visual PASS. Do not weaken old tests, remove finite receipts/material sources, erase valid goods or manufacture rewards to make cleanup appear complete.

## 6. Evidence to open directly

- [PR31 integration report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/9eb4fd55733bb49bbb069240b8e332d37d22aced/docs/handoffs/2026-10-24/TMB_PR28_S1_END_TO_END_INTEGRATION_REPORT_2026-10-24.md) and [28-test raw CSV](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/9eb4fd55733bb49bbb069240b8e332d37d22aced/docs/handoffs/2026-10-24/evidence/packet-b/sha4b02/focused_results.csv).
- [PR32 implementation/benchmark report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/c6bde70f6e98f482c91cd6d2c386e58437877209/docs/handoffs/2026-10-25/TMB_MAP_D1B_OPTION_B_IMPLEMENTATION_REPORT_2026-10-25.md) and [29-test raw CSV](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/c6bde70f6e98f482c91cd6d2c386e58437877209/outputs/map_d1b/logs/final_29_verified/focused_results.csv).
- [PR33 implementation](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/7a551ca4f8f9b15f3069652c5f557e0fbc29833e/docs/handoffs/2026-10-25/TMB_MAP_D2_DIRECT_CHATGPT_PARTIAL_IMPLEMENTATION_2026-10-25.md) and [latest optimization/status report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/7a551ca4f8f9b15f3069652c5f557e0fbc29833e/docs/handoffs/2026-10-25/TMB_ACTIVE_BRANCH_INDEX_SAFE_CLEANUP_AND_PERFORMANCE_2026-10-25.md).
- [PR34 implementation and preview limits](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/dae86efd37a61e2e82c64ea00608fc062c4b423c/docs/handoffs/2026-10-25/TMB_PVE_MAP_PRESENTATION_AND_20_CAMP_PREVIEW_CHECKPOINT_2026-10-25.md).
- [R0 evidence, including 06:09 UTC investigation update](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/c87f659e2648f258553a901cfce3fe4e3eafa7fa/docs/handoffs/TMB_CODE_R0_BASELINE_QA_EXECUTION_EVIDENCE_2026-10-25.md).
- [CODE-CLEAN boundary report](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/5fbdbc6309c3f1386f0d8b619831e007c5a52824/docs/handoffs/TMB_COMBAT_CODE_CLEAN_FINITE_WORLD_BOUNDARY_2026-10-25.md).

These are existing remote evidence, re-read for this consolidation; **no new Godot test run was performed**.

## 7. Historical evidence and cleanup record

Economy-A #1 was merged on 2026-10-15 with accepted 18/18 official Windows automated evidence at gameplay/test SHA `95bf06ecfd2c7fce5026d4485af55a5a3c40d909`. Skills #23 was merged on 2026-10-22. Requests to implement Economy-A from scratch or await skills integration are obsolete.

Detailed historical PASS/FAIL/SHA and unique earlier decisions remain recoverable from the [pre-cleanup checkpoint](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/29b5fba448b0178cb520a4ada44b375b4b934e31/CURRENT_CHECKPOINT.md) and [pre-cleanup handoff](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/29b5fba448b0178cb520a4ada44b375b4b934e31/NEXT_CHAT_HANDOFF.md), plus their subsystem contracts. Their old ACTIVE/LATEST/NEXT labels are not current work orders.

Removal rationale and precise file fingerprints: [PROJECT_CLEANUP_2026-10-25.md](docs/PROJECT_CLEANUP_2026-10-25.md). No legacy gameplay/asset/test/branch was removed by this documentation cleanup.
