# NEXT ACTION — D8 measured refresh hotspot, exact-path approval granted

Current branch feature/v63-v64-full-combat-20261029 at 02a964e088414798d3dc18cac3d0e20c91af3457 before the preflight evidence commit. Runtime measurements and D6/D7 results are in the preceding current handoff.

Profiler follow-up scope proposed after AGENTS.md §3 owner approval:
1. Reuse a scene-owned ResourceRegistry in P3.2 live visual-row mapping rather than constructing/parsing one per monster on each refresh.
2. Reuse the six existing V6.5 party-row controls in place rather than queue_free/recreate each refresh.
3. Add v63_d8_p3_refresh_reuse_test.gd plus UID and rerun Godot import, focused HUD/P3.2 tests, 24 current affected tests, 20 D6 tests, and paired logger OFF/ON GUI measurements.

Exact source paths: godot/src/presentation/p3_2_landscape_sect.gd and godot/src/presentation/p3/v63_combat_hud_v1.gd. Exact new test path: godot/tests/presentation/v63_d8_p3_refresh_reuse_test.gd. Evidence/checkpoint paths: D8 evidence, coverage ledger, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md.

Owner approved the exact allowlist in the current session. Start only after this preflight commit is visible at the branch tip. No SaveService/schema, combat authority, injury, job, warehouse, scheduler, asset or main change. The current 9/9 D7 GUI matrix is a visual baseline. V6.5 remains incomplete.

---

# CURRENT HANDOFF — D6 regression verified; D7 GUI 9/9; D8 measured (2026-10-30)

Repository vuanhtuan161094-byte/TongMonBaDao. Continue on feature/v63-v64-full-combat-20261029 only. Feature HEAD before this evidence update is 53d6134ec7ecad5f10f29c2617869c6717958d4a; tested runtime source is 59f3903f37dc0260cf07059bf3bd24e0973168c6. Main c0c1382f119599497b52d8ee8abd9e830a883f1e unchanged. PR #52 remains Draft/open/unmerged at 2a99ed505c85a17f6d25f91891560ca51fa02d88; its base is feature/pve-jx-continuous-world-20261026.

## Completed and verified

- Official Godot 4.7.2 Windows import PASS, exit 0; log SHA-256 B728DE0C23F24D9AA31BC7608B177D7CA13857D7C3ACA862A08506D00675123B.
- D6 full regression PASS 20/20, sequential. Manifest E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\d6_regression_59f3903\d6_results_59f3903.json, SHA-256 6AE3CC0C708D76BD1E0D59875C03BD036E5F6B1059884905AA2D7FED66DDB93D.
- D7/D8/Save/PvE matrix PASS 24/24, sequential. Manifest E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D8_PERF_20261030\regression_59f3903\regression_results_59f3903.json, SHA-256 EA6DF0603FD27F4759FF1C8AD5538399664EDFFA48F9943766F830535374D739.
- Native Windows 1280×720 actual P3.2 Combat V2 GUI matrix covers all 9 branch skill samples and all 9 Bosses. Each cast/hit/telegraph receipt passes. Full hashes and nine pairings are in V65_D7_UI_VFX_EVIDENCE_20261030.md.
- D8 P3.2 performance capture ran on a loaded 130-disciple QA save, six-member team vs C01; Logger OFF/ON each yielded >1100 frames, exit 0 and 149 actions. Detailed stats and hashes are in V65_D8_INTEGRATED_QA_EVIDENCE_20261030.md.

## Still open — do not label complete

- D7: central actor/damage-number crowding remains visible; manual mouse and Save/Return GUI interaction plus owner visual review are pending. D6 rare-ultimate GUI matrix is also pending.
- D8 performance: frame P95 ~17.5 ms, but P99 68.48–68.94 ms, max 94.88–120.10 ms and 1%-low 12.02–12.44 FPS in paired runs. Keep REVIEW PENDING; optimize only after recording an exact-path D8 preflight, then rerun OFF/ON and affected regression.
- Android device verification is pending; no physical Android environment was available.
- Body realms 7–30 remain blocked by unavailable authored progression recipes/material sources. Do not invent or bypass.
- Overall V6.5 is INCOMPLETE. PR #52 stays Draft/unmerged; no main merge, branch creation, or data cleanup.

## Preserve and resume

Keep the canonical dirty E: worktree untouched. The isolated snapshot is E:\TongMonBaDaoWorkspace\01_Game\TMB_V65_D8_SYNC_20261030\godot; evidence outputs remain under E:\TongMonBaDaoWorkspace\QA_Evidence\. Source code has no changes after 59f3903; branch commit 53d6134 added only the D8 QA capture test/UID.

Before any new runtime-code edit, follow repository AGENTS.md §3 with an exact current-head/path/test/rollback preflight; the existing D8 preflight covers QA artifacts and docs, not a performance optimization in production presentation code. Continue with the narrow measured hotspot only after that gate. See CURRENT_CHECKPOINT.md and the D7/D8 evidence documents for exact metrics, 9-pair GUI hashes, test manifest hashes, and open gates.

---

# CURRENT HANDOFF — continue D7 visual coverage, then D8 QA

Repository `vuanhtuan161094-byte/TongMonBaDao`; branch `feature/v63-v64-full-combat-20261029`. Latest source commit: `5e1fc3043abe4fcd402ce226be7bb944d053cd0d`. Main `c0c1382f119599497b52d8ee8abd9e830a883f1e` is unchanged. PR #52 remains Draft/open/unmerged at `2a99ed505c85a17f6d25f91891560ca51fa02d88`; no merge/PR mutation.

## PASS

- Official Windows Godot 4.7.2 import, exit 0; combined affected regression 34/34, sequential, all exit 0. This includes the complete D6 20-script regression set, D8's 20 focused/cross-phase cases, and six D7 presentation/runtime checks.
- Current P3.2 Boss picker uses canonical existing map selection before Boss encounter start; Presenter attaches live Boss battles without the typed-array error.
- Scripted real GUI viewport capture: 1280×720 P3.2 Boss, six members, live telegraph, Liệp Ảnh cast/hit. Screenshot SHA-256 `59508487945305293EFD9360C1272EE194ABDCD11F2FB46700BAA281246BF07E`; log SHA-256 `D3FFB81E971B156EF2E6DE0E97808503895FDB37CFEEA81716FF7AA63933A0C4`.

## PENDING / BLOCKED

- PENDING: 8 remaining branch skill GUI captures and 8 remaining Boss captures; physical mouse/Save/Return and owner visual approval; measured FPS/RAM and Android.
- PENDING: visual review of overlapping combat numbers/nameplates in the Boss screenshot.
- BLOCKED: Body realms 7–30 lack authored gate content; keep that progression gate intact.
- Overall V6.5 remains INCOMPLETE.

## Continue

Continue the D7 matrix on this same feature branch, with one source writer and official Godot 4.7.2. Save a real screenshot/log for each additional branch/Boss and update the coverage ledger/checkpoint with exact SHA and hashes. Then continue the authorized D8 runtime/performance/endgame QA; do not invent production balance. Preserve the E: dirty worktree. Do not create branches/PRs, merge main or modify PR #52.

Full results and logs: `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7D8_20261030_boss_fixes\regression_results.json` (SHA-256 `3C7E4982B423CF3033C3E51AB08430B3F32F09B789F9C1687E6F330DA68D1032`).

---

# HANDOFF UPDATE — P3.2 BASELINE GUI CAPTURE; LATEST PATCH STILL UNTESTED

Current remote branch was dd15641068d4a251296956d30de681472bd572e7 when this note was prepared; current code/test patch is 63b5eaef9eae17ccc0fb71a1fa8b7524f50fc64f. It adds saved V6.5 preview-gate restore before offline catch-up and active combat resume plus v63_d8_preview_resume_gate_test.gd. The checkpoint explicitly marks Godot 4.7.2 engine/regression gates pending. Verify branch HEAD before further work.

A Windows Godot 4.7.2 non-headless P3.2 integration run completed with exit 0 and produced an actual 1280×720 viewport screenshot:
- Screenshot: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/GUI/pve_multicamp_live_1280x720.png; SHA-256 D61FAC6E805E3D648D4255B5C98AB4D12D759F50A83A43005D03910EC28F5710.
- Log: E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/GUI/pve_multicamp_live_gui.log; SHA-256 B3C312AE3D669C01B8C05135762C73777676771A0019AE82B55C4C060D60DA53.
- Evidence includes 130 loaded disciples, six live team members versus ten monsters, Source A map, pan/zoom and movement input, 18 Combat V2 actions, and SaveService save/load. HUD was V6.5 OFF; no V6.5 cast was shown.

This screenshot belongs to the earlier 9f7cebd3 baseline; it was run from dirty scratch HEAD 91cfc7e9. The harness scripted UI signals and viewport-routed mouse events; there was no physical mouse or owner review. D7 allowlist sources were content-checked after CRLF/EOF normalization, not from a clean full-tree checkout. Do not assign this capture to the new preview-resume patch.

Immediate next work: obtain a clean synchronized test tree for current remote HEAD without touching the dirty E: scratch or main checkout; run official Godot import, v63_d8_preview_resume_gate_test.gd, then the D3/D4/D5/D6/D7/D8 and Save/PvE regressions. Verify saved opt-in keeps a learned/equipped disciple casting during continuous PvE, Save/Return/Reload and offline catch-up, while legacy gate-OFF behavior stays unchanged. Capture the current-head opted-in cast path after tests. Nine-branch/nine-Boss visual matrix, owner review, FPS/RAM, Android, and realm 7–30 content remain pending/blocked. No merge or PR #52 changes.

---

# V6.5 D8 INTEGRATION PATCH — 2026-10-30 (CURRENT, UNTESTED)

- Existing feature branch only: `feature/v63-v64-full-combat-20261029`. Five same-branch source/test commits since D8 head `48ed10f750b08bc9ed5bbe74928ae8e60173a31f`, latest code+test SHA `63b5eaef9eae17ccc0fb71a1fa8b7524f50fc64f`.
- Discovered: `SimulationRuntimeClockV2._advance_multicamp()` omitted `scheduler.v63_preview_overrides` on `HuntingPveRunV2.resume_active()`; a personally learned/equipped V6.5 skill could turn OFF during a continuous runtime poll. `SimulationRuntimeOwnerV2.load_from_path()` also created the scheduler with empty overrides before offline catch-up, and P3.2 lacked opt-in rehydration after UI reload.
- Minimal patch: `V63FeatureGates.persisted_preview_overrides(state)` is now shared by UI and runtime; owner attach/load restores saved explicit archive+combat opt-in before catch-up, multicamp resume forwards it, P3.2 preserves the toggle on reopen. Legacy/partial opt-in stays OFF. Added `godot/tests/simulation/v63_d8_preview_resume_gate_test.gd`.
- Evidence status: **SOURCE COMMITTED / GODOT 4.7.2 ENGINE PENDING / GUI PENDING / OWNER PENDING**. The current chat environment cannot run Windows Godot or control the owner's E: session. Do not treat this code patch or its new test as PASS. No PR #52/main merge.
- **Next single action on Windows:** synchronize exact code tree, run Godot 4.7.2 import + new preview-resume test + original D3/D4/D5/D6/D7/D8 and PvE/save regressions; verify V6.5 enabled skilled disciple actually casts in 6-person continuous PvE, then Save/Return/Reload and offline catch-up, and gate-OFF legacy unchanged. Fix any failure on same feature branch and attach SHA/logs. Run 1280×720 *actual* GUI snapshots of Tàng Kinh Các, Human/Immortal/Divine skills, nine Bosses/VFX, then owner visual review. Compare feature with current RC52 file-by-file; no blind merge. Endgame Body realm 7–30 still content-blocked; don't invent gate costs/materials.
- Overall V6.5: **INCOMPLETE** pending playable QA, measured FPS/RAM and owner acceptance.

---

# NEXT CHAT HANDOFF — V6.5 D8 QA COMPLETE / RELEASE GATES OPEN — 2026-10-30

Repository `vuanhtuan161094-byte/TongMonBaDao`; branch `feature/v63-v64-full-combat-20261029`. Latest source/test checkpoint is `9f7cebd3aaa11ef53660497dfe5fc6bab30cb378` and the evidence/docs commit is the current branch tip (verify live ref before editing). Stable main `c0c1382f119599497b52d8ee8abd9e830a883f1e`; PR #52 Draft/open/unmerged, audited head `2a99ed505c85a17f6d25f91891560ca51fa02d88`. No merge, new branch/PR, reset, clean, or E: worktree cleanup.

## D8 result

Official Windows Godot 4.7.2 import PASS (exit 0). Final sequential D8 matrix 16/16 PASS plus cross-phase D2/D3/D6/D7 checks 4/4 PASS; full test names and log hashes are in [D8 evidence](docs/implementation/V65_D8_INTEGRATED_QA_EVIDENCE_20261030.md). D8 commit `9f7cebd3aaa11ef53660497dfe5fc6bab30cb378` is QA-only: three added tests and one existing progression test expectation correction. Initial sandbox/fixture/runner issues are disclosed in evidence; only corrected final runs count.

**Pending:** actual game GUI, real input/screenshots for nine branches and Boss cues, owner visual acceptance, measured FPS/RAM, and Android device checks. Godot 4.7.2 Project Manager appeared after explicit launch, but two state captures timed out on the frame channel; no gameplay input or GUI evidence was produced.

**Blocked:** the playable Body progression path beyond realms 1–6 is absent in authored content; realms 7–30 return `content_unavailable`. The cost table's 300 coordinates do not prove end-to-end progression. No balance/recipe values were invented.

## Next actions

1. Resume native Godot 4.7.2 GUI access and capture the actual P3.2 gameplay flow, Save/Return, branch/Boss cues, then obtain owner review; attach real evidence before changing these statuses.
2. Route the missing realm 7–30 gate recipes/material sources/progression numbers through an explicit authored-content and balance approval packet; don't bypass current gates.
3. Run real performance logger OFF/ON sequentially for production and PvE; record P50/P95/P99, 1%-low, RAM and spikes. Run Android only on a real available target.
4. Preserve Source A provenance, JX reference-only, Injury120, six-person PvE, 20 camps, One Active Job, one Warehouse/scheduler and SaveService/schema. Keep V6.5 INCOMPLETE and do not merge main/PR #52 without owner review.

## D8 evidence files

Matrix: `E:/TongMonBaDaoWorkspace/QA_Evidence/V65_D8_20261030/regression_results_final.json` (SHA-256 `3C435EC5E1A2BF50159E5BB870DF2BE336394D3966492850FEFD0DE14C917C75`). Cross-phase matrix: `extra_results.json` (SHA-256 `2E439B30D5465EB94E9A6221F6118FEDD858E8B465259EDFE7E3E77241702491`). Import log SHA-256 `4607CF35E6D6B82797968FE151305A9C35D23E7884FAE37D36A66CB249F87DB2`.

## Protected worktrees

Original owner E: checkout remains untouched. Scratch `E:/TongMonBaDaoWorkspace/01_Game/TMB_V65_D4A_20261029` contains unrelated existing uncommitted import/QA files; never reset, clean, stage-all, delete, or commit those files. Continue from a verified fresh snapshot of the published branch and exact next allowlist.

# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO / 30-10-2026

## Current handoff — D7 headless PASS; continue D8 QA now

Repo `vuanhtuan161094-byte/TongMonBaDao`; branch `feature/v63-v64-full-combat-20261029`. D7 source/test SHA `878b279b4ac536c1c28a36e4ed0e87251f43c2c9`; stable main `c0c1382f119599497b52d8ee8abd9e830a883f1e`; live PR #52 is Draft/open/unmerged at `2a99ed505c85a17f6d25f91891560ca51fa02d88`. Do not merge, close, create another branch/PR, or clean the E: worktrees.

D7 Windows Godot 4.7.2 import PASS and targeted presentation/runtime reruns PASS. D6 affected regression was 20/20 PASS. Logs, full test names, hashes, prior failed attempts and corrected reruns are in [D7 evidence](docs/implementation/V65_D7_UI_VFX_EVIDENCE_20261030.md) and `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D7_20261030_final`. The initial 26-test batch had two failures; report the later individually rerun checks as PASS, not a clean cumulative 26/26.

**D7 GUI/owner acceptance remains PENDING:** the official game window was visible to Windows, but Computer Use approval timed out before it exposed that window for actual mouse input or capture. No gameplay screenshots, all-branch/all-Boss visual acceptance or FULL PLAYABLE claim exists. Continue D8 independently; retry GUI using the approved native-app route when available and keep this gate pending until real captures and owner review.

### Immediate D8 task and exact initial allowlist

1. Add the two simulation tests `godot/tests/simulation/v63_d8_endgame_progression_test.gd` and `godot/tests/simulation/v63_d8_multiseed_camp_battle_test.gd`. Update only the existing `godot/tests/simulation/dv2_03_realm_body_progress_test.gd` expected CombatStatsV2 call to include the same model-version flag used by `DiscipleRealmProgressV2.derive_stats`; no production code change.
2. Add `godot/tests/presentation/v63_d8_performance_qa_contract_test.gd` for existing P3.2 performance/launcher observability; use the existing launcher/probe read-only.
3. Update `docs/implementation/V65_COMBAT_COVERAGE_LEDGER_20261029.json`, add `docs/implementation/V65_D8_INTEGRATED_QA_EVIDENCE_20261030.md`, and update this file plus CURRENT_CHECKPOINT.
4. Run official Windows Godot 4.7.2 import; focused tests and affected D1–D7, progression, save/recovery, One Active Job, Warehouse and PvE regressions sequentially; record command/exit/source SHA/log hashes. Inspect real GUI and runtime performance if Computer Use returns Godot. Device/Android remains PENDING if unavailable.
5. No numeric balance changes without simulation evidence and owner-approved values. Existing 300-floor cultivation/body sources and gates are authoritative; do not bypass a content gate with invented XP or recipes. Preserve six-person teams, 20 camps, Injury120, the single scheduler/Warehouse, SaveService/schema and legacy saves. If a real product bug requires a runtime file, first extend checkpoint with exact path, observed failure, narrow fix and rollback.
6. Keep source D7 limitations visible: only targeted tests have passed after fixes; initial full 26 batch was 24/26; GUI images for nine branches/Bosses and owner visual approval remain outstanding.

## D7 code commit files

`godot/data/presentation/v63_combat_vfx_manifest.json`; `godot/src/presentation/p2_3_techniques.gd`; new `godot/src/presentation/p3/v63_combat_hud_v1.gd`; new `godot/src/presentation/p3/v63_original_combat_vfx_v1.gd`; `godot/src/presentation/p3_2_landscape_sect.gd`; `godot/src/simulation/combat/hunting_pve_run_v2.gd`; `godot/src/simulation/core/simulation_runtime_clock_v2.gd`; `godot/tests/presentation/pve_multicamp_p3_2_live_integration_test.gd`; new D7 Archive/HUD/runtime-Boss tests. D7 code commit SHA `878b279b4ac536c1c28a36e4ed0e87251f43c2c9`; evidence follows in a separate docs commit.

## Protected state

Original owner E: checkout remains untouched. Scratch `E:\TongMonBaDaoWorkspace\01_Game\TMB_V65_D4A_20261029` has many pre-existing uncommitted implementation/import/QA files; do not reset, clean, stage-all or commit from it. Published commits use exact GitHub path allowlists. No main/PR #52 changes.

## Historical handoffs follow


# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO / 30-10-2026

## Current handoff — D6 PASS; continue D7 immediately

Repository `vuanhtuan161094-byte/TongMonBaDao`; branch `feature/v63-v64-full-combat-20261029`; current source/test SHA `eff8446b571f945c14799c48ecb8a1519e076e30`. Main `c0c1382f119599497b52d8ee8abd9e830a883f1e`; PR #52 latest audited `8a2860903a6b9e241d88ca13cbf9b64f37cdcfd0`, Draft/open/unmerged. No PR mutation, main merge, new branch or cleanup.

D6 official Windows Godot 4.7.2 import + 20 scripts: **21/21 PASS**, sequential. Matrix and hashes: [D6 evidence](docs/implementation/V65_D6_DIVINE_EVIDENCE_20261029.md), logs `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D6_20261030_final`. The exact 15 source/test Git blobs are recorded there; they match the tested scratch bytes. Keep the explicit limits in CURRENT_CHECKPOINT/coverage ledger: representative, not exhaustive 240-skill effect coverage; rare passive effect coverage partial; boss full release/kill/reward and all GUI visuals still pending. Candidate gates OFF; global V6.5 incomplete.

**Next action: implement D7 now** using the exact initial allowlist in the D6 section of CURRENT_CHECKPOINT. Keep the existing P3.2 landscape the sole gameplay surface. Add actual party/skill/Boss/archive UI and original event-tied VFX against the existing MapBattleV2 authority; preserve Source A provenance, read-only source assets, JX reference-only. Run focused and cumulative suite and start actual Godot 4.7.2 GUI at 1280×720; capture real input and all nine branch/Boss cues. Record any owner visual decision as PENDING until received.

D7 simulation scope is exactly the two pre-authorized paths in CURRENT_CHECKPOINT: (1) add the optional `{}` preview-gate parameter to `HuntingPveRunV2.begin_multicamp` and forward it; (2) in `SimulationRuntimeClockV2`, pass the single existing scheduler's `v63_preview_overrides` during multicamp resume and service an explicitly opted-in mode=encounter Boss run through the shared clock, existing persisted snapshot, `advance` and settlement path. Preserve frame/remainder/minute semantics, rewards and save schema; add no new scheduler or payout. The first path prevents begin from dropping gates; the second prevents runtime resume from disabling combat and gives actual P3.2 Boss runs a ticking path. Add the exact test `godot/tests/simulation/v63_d7_runtime_boss_encounter_test.gd`. All other simulation/economy/save/Warehouse/scheduler behavior is excluded. Preserve existing source art/manifests, main and PR #52; no merge, PR explosion or cleanup. Owner authorized D4→D8 in Issue #54 and the execution contract. Proceed sequentially; only stop for a real failing safety gate, missing asset provenance, or owner-only visual acceptance.

## Historical handoffs

## Current handoff — continue D6 Divine immediately

Repository `vuanhtuan161094-byte/TongMonBaDao`; active branch `feature/v63-v64-full-combat-20261029`; current D5 source/test tree `7821934ed8b4ac68634017b314cf14119f5959b7` (encoding repair commit after the initial D5 implementation `2f193644329ecabcd71d20bf3283972235bf47c1`). Stable `main` `c0c1382f119599497b52d8ee8abd9e830a883f1e` remains unchanged. PR #52 stays Draft/open at `f7c33d9c3baba3267a17021718b44f87acd62ef6`; no PR, merge, reset or history rewrite.

D5 is **HEADLESS_PASS**: official Windows Godot 4.7.2 import and sequential 18/18 focused/cumulative regressions exit 0. Evidence and log hashes: [D5 evidence](docs/implementation/V65_D5_IMMORTAL_EVIDENCE_20261029.md), local logs `E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D5_20261029`. Nine branch A/B pathways produced 18/18 Combat V2 casts; 3/3 Immortal bosses were counter-interrupted. Deterministic D5 study/save, D4, D2, D3, P2/P3.7 and PvE save/reward regressions passed. D5 gates remain OFF; candidate balance only.

Proceed without a phase-selection pause to D6 using the concrete allowlist, exclusions and tests at the top of `CURRENT_CHECKPOINT.md`. Build Divine I/II/III A/B paths, 18 rare ultimate replacements, authored rare passive successors and three real staged Divine bosses. Preserve Human/Immortal history, legacy saves, Injury120, One Active Job and the single Warehouse/scheduler. Keep new Divine effects gated OFF; do not approve candidate economy/HP coefficients.

D4 GUI/owner visual review, D7 original VFX/Source A presentation, Android and D8 performance/endgame remain **PENDING**. No playable/visual/FULL COMPLETE claim.


## Historical records follow

## Current handoff — continue D4-B automatically

Repository vuanhtuan161094-byte/TongMonBaDao; active branch feature/v63-v64-full-combat-20261029. Current published D4-A source SHA: 0af2af261e62960ffb4669c8d9d81feb153dd387. Stable main c0c1382f119599497b52d8ee8abd9e830a883f1e remains unchanged. PR #52 remains Draft/open at audited head f7c33d9c3baba3267a17021718b44f87acd62ef6; do not merge/change it.

D4-A code and the official Windows Godot 4.7.2 import plus all 14 focused/cumulative tests PASS with exit 0. Evidence and log hashes: docs/implementation/V65_D4A_HUMAN_COMBAT_EVIDENCE_20261029.md; E:\TongMonBaDaoWorkspace\QA_Evidence\V65_D4A_20261029_final. Actual P3.2 GUI capture is PENDING after Computer Use approval timed out; no GUI/owner acceptance is claimed. D4-A had no visual-file changes.

Next: execute D4-B code on the same feature branch, no extra branch/PR and no phase-permission pause. Build full Human actions for all nine branches, archived-manual learning, bounded/status-aware effects and three Human bosses. The exact write allowlist, protected authorities, rollback and regression plan are at the top of CURRENT_CHECKPOINT.md. Consult the six V6.3/V6.4 design documents, current V63 content registry and D4-A implementation before editing. Keep all gates OFF by default and candidate balance unlocked. GUI capture/owner visual acceptance must remain pending until actually performed; D7 carries the full visual integration matrix.

The original dirty E: checkout is untouched. The isolated E: scratch working copy contains the D4-A source files used by the final tested commit; its local Git HEAD remains at the preflight ref because the network path used GitHub API tree/commit operations. Generated Godot import artifacts and unrelated PowerShell changes were not committed or deleted.

## Historical records follow

Older preflight and D3 handoff notes below are preserved, but superseded when they conflict with the current status above.

---

## Historical D4-A preflight (superseded)

- Historical preflight status: code was not started at that checkpoint. Superseded by the current handoff above. Base HEAD `a9a7d5ab97c3b02de467c54b94d4d9c4c8d3d9ca`; isolated scratch is `E:\\TongMonBaDaoWorkspace\\01_Game\\TMB_V65_D4A_20261029`. Original dirty E: worktree is preserved.
- Exact D4-A allowlist and PR #52 conflict matrix are recorded at the top of `CURRENT_CHECKPOINT.md`. Additive V6.3 personal skill state is needed because the legacy skill dictionary accepts only P2 IDs; model-level serialization means SaveService and schema version stay unchanged.
- Implement learned/equipped Liệp Ảnh Human action and one Human Boss through an opted-in MapBattleV2 adapter. Legacy gate-off behavior remains unchanged; keep D2 reward receipts and D3 One Active Job guards.
- Tests planned: official Godot 4.7.2 import; new combat/boss and state round-trip tests; D1, D2, D3, P2.5, group MapBattle, PvE HP0 and save-return regressions, sequential. GUI capture from the existing P3.2 scene is required.
- Current tests/logs/GUI: PENDING. Next action: implement only the preflight allowlist, run evidence, then proceed automatically to D4-B.

## Older handoff archive (superseded)

## 29/10/2026 — Owner authorizes FULL V6.5 execution D4–D8

**Current owner instruction supersedes the previous 'D4 design-only, seek separate CODE permission' note** for the explicitly bounded phase packets in [the V6.5 execution contract](docs/operations/TMB_V65_FULL_COMBAT_EXECUTION_CONTRACT_20261029.md). Windows Codex should implement D4-A → D4-B → D5 → D6 → D7 → D8 consecutively on the existing `feature/v63-v64-full-combat-20261029` feature branch, with phase-specific allowlists, tests and logs. Do not merge or disturb PR #52. Resume only from new current HEAD after fetching; earlier audited head `bbac288acd14b0612414a458c43a4fa8a178e86f` is an anchor, not a frozen ref.

**Critical change:** PR #52 head has advanced to `f7c33d9c3baba3267a17021718b44f87acd62ef6`; full-combat feature and PR #52 have diverged. Compare and reconcile relevant PvE/Save files before altering them. Preserve four dirty EOF-only files in E: by using an isolated E: scratch worktree. D3 is only a gated headless-validated learning implementation; new skill combat / nine active bosses / approved visual gameplay are **NOT DONE**. Full approval requires runtime plus actual GUI & owner review. No automatic owner visual approval or main merge.



**Một stable `main`; một ứng viên PvE tích hợp `integration/pve-unified-rc-20261027`.** Không gọi các PR/nhánh cũ là game độc lập.

## Historical D3 checkpoint (superseded)

- Stable `main` remains `c0c1382f119599497b52d8ee8abd9e830a883f1e`; no merge occurred. Active feature branch is `feature/v63-v64-full-combat-20261029`.
- D3 implementation commit: `9bbc5edacf73388505a16c8db0e3b9097a41d55a`, based on approved feature head `4b914d05eb601d2788968a0419e5dda63c79b6fc`; follow-up persistence test commit: `677184c3f05eb84e31aed66e48ee42c383acc222`. Together they add gated personal study jobs, the D3 learning catalog/system, additive disciple/sect/save records, existing-screen study/loadout controls, and focused tests.
- Official Windows Godot `4.7.2.stable.official.ed1daf0bf` import and all 10 approved focused/cumulative scripts PASS, exit 0. The 14 source/catalog/test files tested locally match final D3 source/test commit `677184c3f05eb84e31aed66e48ee42c383acc222` exactly. Read [D3 evidence](docs/implementation/V63_D3_LEARNING_EVIDENCE_20261029.md) for each command and log SHA-256.
- `technique_learning` and `sect_codex` default OFF. Economy values remain candidate-only, no skill/combat effects are enabled, and legacy P2.3 knowledge/loadout are preserved without an identity crosswalk.
- The E: feature checkout retains its existing QA/import artifacts and four EOF-only uncommitted in-scope edits; it was left untouched. Physical GUI, Android and owner visual acceptance remain PENDING.
- PR #52 remains Draft/open. No new PR or merge to `main` was performed. Historical next step, superseded: D4-A is implemented and D4-B is the current authorized packet.


## Người mới tiếp quản phải đọc

1. `AGENTS.md` và `docs/GAME_SYSTEM_ARCHITECTURE.md` — luật gameplay/authority.
2. `CURRENT_CHECKPOINT.md` — trạng thái duy nhất hiện tại và điểm đã/chưa nghiệm thu.
3. [Issue #37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37), PR #51 (core PASS at own SHA), PR #50 (asset static PASS/runtime PENDING), PR #49 (docs), và Draft RC (nếu đã mở).
4. GitHub live HEAD của RC, `main`, feature; không lấy SHA cũ làm mặc định.

## Việc được hoàn thành

- Codex 1 `recovery/pve-core-a1-20261027`, commit `c217471bd3fbe88b95e6e7537b39dc07ae683e41`, [PR #51](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/51): 14/14 focused headless Godot 4.7.2 exit 0 theo báo cáo Codex; D7 invalid fixture (SaveService production đúng), C17/formation, C01→C02, HP0/respawn, Save/Reload, GP-02C1 Injury120 độc lập. CODEX1_GODOT_QA_RELEASE đã ghi trên #37.
- Codex 2 `recovery/pve-playable-visual-a1-20261027`, commit `59c6dea9041653026e02a55b0bc1f4e298976835`, [PR #50](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/50): Source A và JX provenance static PASS; focused test VFX SaveService→resume cập nhật nhưng chưa chạy; FPS launcher log timestamp sửa nguồn; không chụp GUI/FPS.
- PR #49 rút gọn checkpoint/handoff và chuẩn hóa một phiên bản, giờ áp dụng chọn lọc vào RC; bản cũ vẫn tra cứu bằng SHA.

## Còn lại trước khi đề xuất đưa RC vào main

1. Full regression headless 22/22 PASS trên RC; exact SHA, matrix và logs được liên kết từ Issue #37 và evidence branch audit.
2. PENDING USER/GUI: chuột thật 1280x720, chọn 6 đệ tử, di chuyển/combat/camera/minimap, Save/Return/Load; chụp ảnh/video thật. Computer-use hiện không liệt kê cửa sổ Godot dù Win32 có cửa sổ.
3. PENDING FPS: hai lượt logger OFF/ON tuần tự cho sản xuất 15 giây, PvE 30-60 giây, Save/Return; báo P50/P95/P99, 1%-low, spikes và RAM.
4. P3.2 integration headless ở roster 130 mất 252,956 giây cho 50 polls; cần đọc profiler và GUI performance trước khi chấp nhận. Injury120 riêng PASS, nhưng encounter ngắn chưa chạm Injury120. Loot remains LOOT_PENDING.
5. Mainline merge và C4 cleanup chờ owner duyệt rõ ràng. Không thay renderer Source A, Combat V2 damage, SaveService, Injury120, economy/loot hoặc nhánh PR khác.
**Không tạo nhánh permanent develop hoặc thêm nhiều phiên bản game.** Các PR #44–#51 là provenance/đầu nguồn, RC là ứng viên tích hợp DUY NHẤT, main là stable chính thức.

