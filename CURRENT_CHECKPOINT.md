# CURRENT CHECKPOINT — ONE GAME → MAIN (2026-11-04)

> **Only current status checkpoint.** Earlier contents were preserved verbatim in [the historical archive](docs/archive/checkpoints/CURRENT_CHECKPOINT_LEGACY_PRE_RELEASE_TRAIN_20261104.md). **Do not execute historical PR #52/#67 instructions or treat their test SHAs as live.** [Live coordination: Issue #56](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56) · [Release-train canonical](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).

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

- PR backlog at this checkpoint: **61 → 36 open; 25 closed, no branches/commits deleted and no changes merged into `main`**. 18 old PRs are Git ancestors of #72; 7 outdated docs/labs closed as historical, not claimed integrated. Review 30 diverged non-release PRs and the 4 animation labs before final release. Exact lists in [the canonical register](docs/operations/TMB_ONE_GAME_RELEASE_TRAIN_CANONICAL_20261104.md).
- **R0 NOT PASS:** must verify backup of ~196 existing dirty/untracked E: items + saves, SHA/hash manifest, and remaining PR parity. This GitHub-only documentation cleanup does NOT touch E:.
- **R1 NOT PASS:** forward-port only genuinely missing approved functionality (especially #61 policy, #64 Hall/Residence, #66 B1 UI), without overwriting newer canonical code; retain Tam Căn/Tứ Tính naming requirements after authority review.
- **R2 NOT PASS:** resolve launcher/GLES3 Windows process blocker safely, 3 clean starts.
- **R3 NOT PASS:** one QA save from New Game → Residence/recruit → production/Warehouse → solo PvE real HP0/receipt/reward → cold reload → continue.
- **R4 NOT PASS:** full affected Godot 4.7.2/Windows GUI regression on exact source SHA.
- **R5 NOT PASS:** reconcile `main` divergence, merge approved one-game candidate once, test post-merge SHA, tag, and only then retire obsolete PRs.

**Next action:** Continue R0 local backup + 30 diverged PR functional review; do not start new development or claim PLAYABLE/merge PASS until R2–R5 evidence.
