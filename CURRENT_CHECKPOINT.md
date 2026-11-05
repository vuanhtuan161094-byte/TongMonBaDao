# CURRENT CHECKPOINT — ONE GAME → MAIN (2026-11-04)

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
