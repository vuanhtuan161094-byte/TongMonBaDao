# Master Recovery / Playable V1 — source and evidence report

## Branch and preservation

- Worktree: `E:/codex/2026-10-22/t-ng-m-n-b-o/work/TMB_MASTER_RECOVERY_PLAYABLE_V1_20261023`
- Branch: `integration/master-recovery-playable-v1-20261023`
- Base is PR #25 head `710137c0e3976e685613a86692e5eb128b8d3c62` (PR #25 itself targets CARE PR #24 at `4d08984f044bfa29a98070c8d68ee5a155256d3a`).
- Code commits: `087c58b70b9c4bec3847d8acc546d8b761d984fc` (selective MAP25/G1 and V5 adapter recovery), `f5715ad0d90ee38516b54f316b9dd6f1544c3723` (restore exact G1 full-width map camera contract and test it).
- No Source A/V5 source worktree, UI finalization worktree, PR #24, PR #25, CARE simulation authority, economy, scheduler, Warehouse, SaveService or main branch was reset or overwritten.

## Source recovery matrix

| Source | Verified source state | Reused in this branch | Not copied or still pending |
| --- | --- | --- | --- |
| MAP25 / PR #19 | Draft PR #19 head `5ce3c0f7ca4bd9eb0295f56b421ef96fca3a2bc7`; its scope and prior Windows evidence are retained on GitHub. | The G1 isometric/source-art modules, worksite cue UI and full-width camera setting. | The old branch was not merged. Historic device/owner visual gates remain separate. |
| G1 / PR #20 | Draft PR #20 head `2219535fc3519ce811265ceed5cb85001efe5e45`, based on PR #19. | `p3_2_landscape_sect.gd` concepts; `sect_production_worksite_cue.gd`, `sect_iso_map_model_v1.gd`, `sect_isometric_world_v1.gd`, `sect_map25_source_art.gd`, `disciple_six_dimension_radar.gd`, `disciple_source_a_visual_pool.gd`; 32 Source A PNGs; exact `VIEW_RECT=(0,72,1280,570)`. | G1 branch was not cherry-picked wholesale. Individual visual/system gates still require owner review. |
| Combat V5 / V5.1 | Local V5.1 worktree branch `feature/v5-1-sourcea-visual-finalization`, HEAD `ae3f397cef654cd3ff1936261b018476a132e7db`, dirty before and after this work. | V5 Source A atlas/manifest data and draw/animation routes through a new read-only CARE adapter. | V5 battle simulation, event/reward authority, pilot combat world, and six-test-actor roster were not brought into CARE. No fake disciples were made. |
| CARE / PR #25 | PR #25 remains open draft at the inspected head; tested local base `710137c0e3976e685613a86692e5eb128b8d3c62`. | Existing main-screen runtime, B3 world, Combat V2, care AUTO, canonical loot, Injury and SaveService remain the gameplay source of truth. | PR #24/#25 were not merged or changed. |

## Version comparison A / B / C

| Feature | A — G1/MAP25 source candidate | B — PR #25 playable base | C — recovered integration at `f5715ad` | Evidence/status |
| --- | --- | --- | --- | --- |
| Sect map | Source A ENV/PV buildings, terrain, roads and trees; camera intended for full-width map. | CARE is playable but inherited P3.2's 252 px left gutter and lacks restored MAP25 source art. | Verified Source A PNGs, building sprites, map decorations and full-width camera. | `01_main_map_source_a.png`; MAP25 art gate PASS; owner visual PENDING. |
| Production instance/timeline | G1 cue concept anchored to real production instance and workflow facts. | CARE integration does not restore G1 presentation. | Worksite cues and Mine/Linh Lâm/Linh Điền panels use real instance/state fields; G1 radar/production regressions pass. | `03`–`05` captures, `sect_g1_disciple_radar_test`, `sect_iso_main_integration_test`, `p3_o9_m2_production_rehearsal_test` PASS. |
| Disciple profile | Real V2 six-foundation radar/source-art pool. | Real CARE disciple and Tu Vi values, legacy presentation still present. | Same authentic V2 state shown with G1 Source A profile/radar; six-axis chart values and details are rendered from V2. | `07_v2_disciple_profile_luc_duy.png`; profile/radar tests PASS. |
| Hunt/combat | Not its gameplay authority. | Real CARE hunt, Combat V2, HP/Injury/AUTO, loot and persistence, placeholder battle view. | Same CARE lifecycle; Source A V5 actor/monster/floor view adapter reads CARE snapshot. | `08_care_combat_v5_source_a.png`; V5 view-only test PASS. |
| Loot/save/return | Not applicable to the G1 visual branch. | Canonical CARE loot and SaveService. | Preserved unchanged; return, reload and redeploy do not create another owner. | `b3_main_hunt_integration_test.log`: real committed receipts, Injury tick 120, same-world redeploy and next +1 receipt PASS. |

## Active V5 assets and adapter boundary

V5 visual manifest: `godot/assets/combat_v5_source_a/visual_manifest.json`.

- Active capture disciple: authentic V2 `candidate_73021` / Mạc Linh, mapped to `disciple_female` / Source A `1113028_1`.
- Active capture monster: CARE actor `wolf_0/1`, canonical B3 Thanh Lang, mapped to verified Source A `monster_1113031_1` / `1113031_1`.
- The tested clip routes are `idle`, `walk`, `attack`, `hit`, `die` (manifest clips `stand`, `run`, `attack1`, `hit`, `dead`). The test checks imported atlas regions, not a mock animation list.
- Male key `disciple_male` / `v5_sa_male_body_1110201` exists but is not in the final GUI capture. Add a human visual check before treating it as owner-accepted.
- Boss-slot `boss_slot_410041_1` has its manifest, atlas and clip frames, but the B3 CARE pilot has no boss event mapping (`boss_event_mapped=false`). No Boss/AoE is fabricated.
- Source A map art includes main hall `510052`, forge `520081`, Warehouse `510102`, terrain/roads, and the 32 gated ENV02A images. Runtime import is hash gated. The registry identifies them for internal authorized project use; this report does not grant broader asset rights.
- `outputs/MASTER_RECOVERY_INTEGRATION_20261023/source_asset_sha256.tsv` records 72 relevant Source A/actor texture and manifest hashes.

## Godot verification

Official engine: `4.7.2.stable.official.ed1daf0bf`, Windows, Intel Iris Plus/OpenGL 3.3 for GUI capture.

- **19/19 focused PASS** at exact final code/test SHA `f5715ad0d90ee38516b54f316b9dd6f1544c3723`; each exited 0, had a PASS marker, and had zero GDScript parse/script errors. Full per-test logs and isolated user data are in `logs/final_sha_f5715ad/`; summary: `focused_suite_summary.tsv`.
- The test list includes CARE/FASTTRACK/pills/Injury/Combat V2, P3 runtime/profile, camera/shell, MAP25 art/import, G1 profile/map, V5 view-only, and O9 production rehearsal.
- No FULL/CI run was started.

## GUI screenshot and video evidence

The capture script instantiated the actual `res://scenes/p3/p3_2_landscape_sect.tscn` and asserted a 1280×720 root viewport for every image. It used the live P3.2 runtime, canonically recruited a V2 disciple, began CARE's actual B3 hunt and switched presentation states for capture.

- 9 PNGs: `outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots/f5715ad/`.
- Version B reference frame from the tested PR #25 base: `outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots/baseline_pr25/b_pr25_playable_care_10dd287.png` (1280×720, source SHA `10dd287`, copied without changing the source artifact).
- Version A's historic PR #19/#20 screenshot package is not present in the checked worktrees or repository tree. The old PR notes describe the 12-image package, but the images were retained as Codex task output and are unavailable as files in this workspace. Therefore the code/source comparison A→C is documented, while an exact side-by-side A screenshot comparison remains pending retrieval of that prior evidence package.
- AVI: `master_recovery_p3_2_1280x720.avi`, 60 frames, 15 FPS, 4 seconds.
- Godot log: `outputs/MASTER_RECOVERY_INTEGRATION_20261023/logs/gui/master_recovery_visual_capture_f5715ad.log`.
- The capture JSON is a **post-return fixture state**, not an active combat ledger: tick 0, kill 0, Warehouse 0, AUTO off after return. The combat frame displays AUTO on. A kill/loot visual is not claimed from this scripted short capture; the CARE integration-test log proves real loot and Save/Load.
- This GUI proof is scripted in-engine capture, not manual mouse input, human playtest, Android, or owner approval.

The text source diff against PR #25 base, excluding PNG/WebP/import payloads, is `outputs/MASTER_RECOVERY_INTEGRATION_20261023/source_text.diff`. `changed_files.tsv` lists the full base-to-code-SHA file change set, including binary assets; `source_asset_sha256.tsv` supplies their relevant texture/manifest hashes.

## Outstanding acceptance

Windows manual play, Android device/touch, owner visual approval, male actor visual check, real Boss/AoE CARE event mapping, and cumulative FULL/CI are pending or not run. See the detailed checklist and provisional authority document for boundaries.
