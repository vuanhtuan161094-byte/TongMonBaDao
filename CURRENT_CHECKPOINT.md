# CURRENT CHECKPOINT — ONE GAME → MAIN (2026-11-04)

## SX-07B QA EVIDENCE UPDATE — 2026-11-09

- Latest source/test packet SHA: `98642da36abb25f260de0e3dcaba5762d35804c0`, same PR #72 branch. The updated focused test adds five ID provenance checks, non-tradeable value-status checks, actual level-gated source-routing checks, and a fail-closed placeholder assertion. Source code is **CODE PUSHED; GODOT NOT ACCEPTED**.
- **GitHub Actions actually ran and FAILED**, not merely unstarted: O9 at source SHA `ba891e0d09c43727085c38488323726552216e0f`, run [42585918532](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42585918532), completed failure. Its sole job lasted approximately 2 seconds and GitHub returned **zero step details**. Job-log retrieval returned 404 `BlobNotFound`. Seven workflows failed at this SHA. After the latest test-only packet, O9 [run 42586042509](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42586042509) also completed failure (approximately 2 seconds; zero returned steps). No valid Godot exit-0 proof exists; failure origin is **UNDETERMINED**. Do not assign it to GDScript or infrastructure without logs.
- The local working environment has no `godot`/`godot4` binary and no full playable GitHub checkout; therefore official 4.7.2 headless reruns were **NOT executed locally**. Static source/contract and 630×270 JSON consistency checks are distinct from engine tests.
- **NEXT RECOMMENDED:** obtain actual workflow logs or run official Godot 4.7.2 focused import/tests on a trusted available host; fix any deterministic compile/runtime defects before activating further recipe sources or widening the UI selection. Native Windows GUI/Android remain **PENDING USER**.

## SX-07B — PRESERVED MINE/FOREST SOURCE SLICE — 2026-11-09 — CODE PARTIAL / QA PENDING

- Source baseline `c80457834fc7eeb5534441cdfab9fae0fddded56`; code packet SHA `98642da36abb25f260de0e3dcaba5762d35804c0`. Owner explicitly authorized SX-07B on the existing PR #72 branch; no new branch, no merge or player-save changes.
- **CODE:** five V5.5-D-preserved item IDs registered with explicit non-tradeable design reference values. Mine selectors (Xích Đồng Lv1, Trúc Cốt Sa Lv10), Forest selectors (Thanh Trúc Lv1, Thanh Trúc Mộc + Lục Văn Sam Lv10); real existing timed/carry jobs freeze item/quantity, settle to canonical Warehouse, profession EXP and wage once. Old Forest saves default to Linh Mộc. Forest carry-cycle and timed-output validation updated.
- **SOFTLOCK PREVENTION:** current UI does not expose these five material selections; existing 8 early alchemy pilot BOMs preserved, G-proposed early Break r1 and Heal r2 ingredient substitutions **not activated**. No new 111 recipes unblocked.
- **PROVENANCE:** 630 G material IDs: 11 now registered (6 pre-existing, 5 newly coded); 619 unregistered = 112 V5.5-D-preserved + 507 unverified proposed. All 270 G source profiles still `DESIGN_MAPPING_NOT_RUNTIME`, not real sites. The original V5.4 source CSV is unavailable among verified sources; never claim 507 generated IDs were recovered.
- **TEST SOURCE ONLY:** `sx07b_preserved_source_job_test.gd` + GitHub workflow registration; tests cover five live-job selections, level gating, frozen job, cold Save/Load, exact Warehouse, EXP, wages and replay. No Godot 4.7.2 exit-0 evidence at `98642da36abb25f260de0e3dcaba5762d35804c0` yet. Read `docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md` for precise status and accepted vs deferred BOM.
- **NEXT OPTIONS:** (A) SX-07C explicitly authorize source selection UI+early G BOM activation after focused tests; (B) official Godot 4.7.2 focused QA for SX-07B and baseline Save; (C) continue source-name restoration from authoritative V5.4 files, keeping all unverified IDs DESIGN_HOLD. Windows GUI/Android physical gates = **PENDING USER**. No equipment, techniques, PvE overhaul, or merge.


## SX-07 SOURCE PROVENANCE — 2026-11-09 — CODE PARTIAL / QA PENDING

- Authorized packet: owner request SX-07 for the single PR #72 branch `integration/pve-p0-playable-ui-20261103`; **code baseline** `f5280d20614b6dc009a5df7662ad6d8288018958`; **code checkpoint** `c05b1aac9ffe186ebefe56395dfa4ec6abfe6556`. No new branch, no merge or player-save rewrite.
- **Fixed P0 source bug:** `MedicineCatalogueV2.recipe_definition()` had an unconditional premature `return {}` immediately before its real definition. That hid all eight early authored recipes. The dead return is removed. The 119 recipe IDs / 476 SKU metadata stay stable; only **8 early realm-1/2 recipes** are authored; 111 unverified recipes remain blocked.
- **Real source routing:** `MedicineResourceSourceV1` now reports canonical Mine (Thanh Thiết Lv1, Huyền Thiết Lv10), Linh Lâm (Linh Mộc), Linh Điền (three authored crops, Tử Vân Thảo requires Lv10), capped **paid** NPC purchases, instanced hunting drops, and distinct continuous-PvE P0 drop tables. A merchant purchase is **not** an earned PvE drop. New graded production jobs fail closed when any complete input BOM (including Q2-Q4 catalysts) lacks an actual route. Historical in-flight jobs keep their frozen costs and quantities.
- **BOM/cost check:** realm-1 Luyện Thể Đan uses 3 Linh Cốc + 2 Thanh Thiết + 1 Linh Mộc (V5.6-G early grade-mode BOM). Heal/TuVi early explicit-grade mineral/wood inputs remain in `BuildingSystem`. `alchemy_batch_cost_reference` supplies a **read-only** reference using actual ingredient `market_value` and current wage policy; this is **not** fully landed cost (excludes crop sowing, time, taxes and NPC markup) and never grants LT.
- **Source gap truth from owner-provided V5.6-G 630×270 JSON:** 630 distinct proposed material IDs; **6 match the 29 static registered resource IDs**, **624 lack runtime registry definitions**. 270 proposed source profiles (90 Mỏ, 90 Linh Lâm, 90 Linh Điền) are labelled `DESIGN_MAPPING_NOT_RUNTIME` and are NOT 270 live job sites. The 630 design positions include 507 new suggested IDs rather than recovered V5.4 originals. Eight beast/body material IDs referenced by 116 design BOM rows lie outside that 630 list, although those eight IDs already exist in the runtime resource registry. **Do not invent registry entries/loot or unlock the 111 recipes** before source-authorized implementation.
- **Test source committed:** `sx07_source_provenance_test.gd` checks 8 real recipes, 111 fail-closed, Mine/Forest/Field/NPC/PvE provenance, 32 Q1-Q4 input plans and cost/outputs; `sx02_medicine_catalogue_test.gd` now tests 476/8 and V3 B3 potency while preserving V1/V2 receipt oracles. Affected official Godot 4.7.2 workflow paths and steps are registered. **No official Godot test output at `c05b1aac9ffe186ebefe56395dfa4ec6abfe6556` is available**, so QA is PENDING (not PASS).
- **Still blocked:** original V5.4 naming/provenance for 507 proposed IDs; authoritative real source+unlock+yield for 270 profile entries across 30 realms; source-authorized 111 late recipes and final V5.6-G BOM reconciliation for five early pilot recipes; global LT2/T2/W2 profitability and 480-population throughput. Preserve one Warehouse, One Active Job, scheduler, progress, legacy medicine and SaveService.
- **Next code packet for owner approval:** SX-07B — reconcile unverified 624 material IDs against primary V5.4 origin and create first full additional realm source slice **with real timed jobs/earned drops, paid construction, Warehouse deliveries and old-save migration**, then extend the authored recipe list only for sources that pass. If original 507 IDs cannot be grounded, keep those slots DESIGN_HOLD; do not fill them with placeholder names.
- **Windows GUI Godot 4.7.2 / Android touch**: **PENDING USER**; prior Intel OpenGL launcher issue is not resolved by this source-audit packet. No R5 merge, no declaration of 30-realm production acceptance.


## MASTER BACKLOG INTAKE — 2026-11-06

The owner prompt/workbook are now available and hash-identified in [input status](docs/qa/PR72_MASTER_QA_20261106/INPUTS_STATUS.md). The full [requirement register](docs/qa/TMB_PR72_REQUIREMENT_REGISTER_20261106.md), [158-case matrix](docs/qa/TMB_PR72_FEATURE_ACCEPTANCE_MATRIX_20261106.csv), and [10 E2E journeys](docs/qa/TMB_PR72_E2E_JOURNEYS_20261106.md) retain 35 requirements, 158 cases in 18 systems, 10 journeys, and 15 source gaps. Matrix source fidelity check: all 158 rows × 11 original columns matched the workbook (0 mismatches); five execution fields are additional.

- PR #72 branch: `integration/pve-p0-playable-ui-20261103`; live HEAD at intake `857ce164442a3a845d554b6ab1315abf92c85281` (Draft; no merge/new branch).
- Runtime/test evidence SHA `5ef179b81dfef6f2d72a38d866e94fc828e179eb`; focused P3.2/density/P3.4B/O3 source SHA `374f2d47d887c828218e3a296b6c8370aff070e7`; production runtime files are unchanged across that later test/manifest-only delta.
- Matrix annotations: 11 `PASS_HEADLESS`, 2 `PASS_GUI_HARNESS`, 9 `IN_PROGRESS`, 136 `CHUA_NGHIEM_THU`. E2E: six `IN_PROGRESS`, two `BLOCKED_SOURCE`, two `CHUA_NGHIEM_THU`; complete E2E PASS 0/10.
- Gate A (P0 playable) is **not accepted**: the three-process isolated R3 headless save journey has logs, but native owner-session GUI/physical mouse is pending and this is not the full continuous player journey. Gate B is partial: logged focused regression evidence exists, but not the complete 158-case regression. Gate C source/design gaps stay open; Gate D viewport harness frames are not physical acceptance; Gate E full cumulative regression is not complete.
- No production/runtime code or player save changed in the master-register update. The existing running Godot PID 16616 was left untouched.

Continue from the unmet cases in the register; do not repeat passing tests unless their code/input changed, and do not relabel harness evidence as physical GUI PASS.

> **Only current status checkpoint.** Earlier contents were preserved verbatim in [the historical archive](docs/archive/checkpoints/CURRENT_CHECKPOINT_LEGACY_PRE_RELEASE_TRAIN_20261104.md). **Do not execute historical PR #52/#67 instructions or treat their test SHAs as live.** [Live coordination: Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) · [Release-train canonical](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).


## BAL-04A — code on PR #72, 2026-11-05; Godot QA OPEN

**Owner approved A**, exact in-scope source + test checkpoint before this document update: `e0e49e577482c9ce399ee2b6e81062dbfa8e3b5a`; re-fetch current HEAD before further writes. **No new branch or main merge.**

- **Code:** Hồi Xuân Đan legacy stays +55HP, automated SX01 and CARE now require effective recovery `min(55,missing_hp) / max_hp >= 2%`; user manual use unchanged.
- **Code:** ranked Tu Vi pill `potency=round(realm_total_xp * 0.001 * quality_factor)`; `MedicineCatalogueV2.VERSION=2`; v1 historical receipts retain the old `10000*1.65^(realm-1)*grade` verification. B3 rejects graded medicine above owner's current cultivation realm before Warehouse debit. B3 satiety remains 1,000,000/day; legacy 10,000 fixed Tu Khí Đan unaffected.
- **Code:** `tu_van_thao` crop unlock at Field Lv10 (previously Lv30); unchanged Spirit Field Lv10 upgrade needs one genuine Linh Tuyền Chi Tâm from 100 harvested fragments, base 5% per harvest; r2 alchemy still needs paid ingredients, Alchemy Hall Lv10 and profession ≥3. **No fabricated source/reward/recipe r3+**.
- **QA committed:** `sx01_pill_policy_test.gd`, `sx02_medicine_catalogue_test.gd`, `sx03_source_consumer_stage_contract_test.gd`, new `sx03_bal04a_legacy_save_medicine_test.gd`; existing B3 CARE/satiety + SX02 runtime registered in `.github/workflows/p3-o8-alchemy-loop.yml`. 30-realm independent math stage simulation in `docs/design/TMB_BAL04A_REALM_STAGE_SIMULATION_20261105.md`.
- **Evidence classification:** math/source assertions only; **no Godot 4.7.2 exit-0 evidence in this packet**, no native Windows mouse or Android. The most recent CI workflow runs in GitHub returned failure without usable job logs: cannot attribute them to gameplay vs infrastructure. **BAL-04A remains QA_PENDING**. R5 merge still blocked until official focused + affected regression + GUI acceptance.
- **Remaining design debt:** phase-wide natural New Game pace, r2 Field-Lv10/Heart farm duration, SX01 AUTO_DEMAND only handles legacy recipe demand, production Lv100 endgame scale versus sinks, later realm r3–30 ingredient sources. Do not silently code those under BAL-04A.

## Release ownership (verified 2026-11-04)

- Repo: `vuanhtuan161094-byte/TongMonBaDao`. Exact engine: **Godot 4.7.2.stable.official**. Target: 1280×720 landscape; canonical Windows workspace `E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao`.
- **One release candidate:** [PR #72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72), branch `integration/pve-p0-playable-ui-20261103`, **Draft / not merged**. Prior gameplay/QA source commit `e92ef09fc2c9b2ccb870910577b295881ccc6527`; code+QA-evidence checkpoint `e888c010d6cfb09a97ce48af19d1a2f42a401240`. **This document was updated in later documentation-only commits — always fetch the new live HEAD.**
- [PR #67](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/67) = base ancestor of #72; **do not merge separately**. `main` remains unreleased regarding this integration and has a divergent AGENTS.md change to reconcile before R5.
- [Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) controls the R0→R5 release sequence. There is **one gameplay/code writer** for overlapping shared paths. Do not create a new release branch to fix each defect.

## Verified, limited evidence

| Area | Evidence | Status |
|---|---|---|
| Import + 14 focused suites, Godot 4.7.2 | 15/15 exit 0 at exact source SHA `e92ef09` | **PASS headless**, not full interactive game |
| PvE distributed population | 20 areas, 30 independent hunters, 40 active monsters / 200 spawn slots | **PASS simulated**, not 30 recruited via real Windows GUI |
| Reward and persistence | 10 HP0 kills/10 receipts, Tu Vi/Luyện Thể + materials, respawn gen 2, separate-process cold Reload | **PASS headless**, not one-save whole journey |
| Windows launcher | First launch ran; second signal 11 `ig11icd64.dll` initializing GLES3; inaccessible PID | **BLOCKED** |
| Physical Windows mouse / 3 clean starts / one-save New Game→SX→PvE→Reload | No valid evidence yet | **PENDING — PLAYABLE NOT PASS** |
| Android/touch and owner art/UX | Not accepted | **PENDING** |
| Integration in `main` | PR #72 Draft | **NOT MERGED** |

Evidence: [QA matrix](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/e888c010d6cfb09a97ce48af19d1a2f42a401240/godot/outputs/qa_evidence/e92ef09_20261104/QA_MATRIX.csv), [PvE log](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/e888c010d6cfb09a97ce48af19d1a2f42a401240/godot/outputs/qa_evidence/e92ef09_20261104/raw/pve/pve_p0_natural_solo.stdout.log).

## Cleanup and release gates

- PR backlog at this checkpoint: **61 → 18 open; 43 closed, no branches/commits deleted and no changes merged into `main`**. 18 old PRs are Git ancestors of #72; 7 outdated docs/labs and 9 archived QA/preview/animation PRs are closed without a claim of functional inclusion. Review 14 still-open diverged production/UI PRs plus unique tests/assets from archived branches; [20-PR parity matrix](docs/operations/TMB_PR72_FUNCTION_PARITY_MATRIX_20261104.md) records concrete source and QA gaps; animation labs #71/#74 are not yet production. Exact lists in [the canonical register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).
- **R0 PASS (Codex evidence, 2026-11-04):** E: backup 196 working items + 94 save files verified at `E:\\TongMonBaDaoWorkspace\\90_Archive\\TMB_R0_BACKUP_20261104_145049`; SHA-256 `EA753053E1DFBFD490E725C7FDD86B26FF565EA4BB10920805AA74571EDEF509`. No user save overwritten.
- **R1 PASS for approved canonical loops (Codex evidence):** source code/test `b56b6fe8fa29ae663994a65098a56b60c3b42513`, docs head `171a2f28020a6aed23af994a48daa43c946e6a89`; Godot 4.7.2 import + 19 focused suites 20/20 exit 0. D7 Tam Căn(3)/Tứ Tính(4) presentation fixed, no extra Tâm Tính gameplay. Legacy bulk production/cap/FoundationGrowth remain DESIGN_HOLD (not approved for this release).
- **R2 NOT PASS:** resolve launcher/GLES3 Windows process blocker safely, 3 clean starts.
- **R3 NOT PASS:** one QA save from New Game → Residence/recruit → production/Warehouse → solo PvE real HP0/receipt/reward → cold reload → continue.
- **R4 NOT PASS:** full affected Godot 4.7.2/Windows GUI regression on exact source SHA.
- **R5 NOT PASS:** reconcile `main` divergence, merge approved one-game candidate once, test post-merge SHA, tag, and only then retire obsolete PRs.

**Next action / OWNER ORDER:** proceed **CONTINUOUSLY R2 → R3 → R4 → R5**, no artificial stop between gates. [Latest Codex execution order](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6627064335). `godot/project.godot` already sets `gl_compatibility`; investigate Intel driver/OpenGL, launcher `Start-TRI03Game.ps1` lifecycle and process overlap, then one-save physical GUI QA. Merge main only after required release-critical checks PASS.
