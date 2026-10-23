# Master Recovery / Playable V1 — focused acceptance checklist

**Branch:** `integration/master-recovery-playable-v1-20261023`  
**Exact code/test SHA:** `f5715ad0d90ee38516b54f316b9dd6f1544c3723`  
**Engine:** official Windows Godot `4.7.2.stable.official.ed1daf0bf`  
**Scope:** focused regressions only. FULL/CI was not run.

## Verified on the exact final SHA

All 19 focused checks exited 0, emitted their PASS marker, and had zero script/parse errors. Per-test stdout and isolated APPDATA roots are retained in `outputs/MASTER_RECOVERY_INTEGRATION_20261023/logs/final_sha_f5715ad/`; the summary is `focused_suite_summary.tsv`.

- `b3_main_hunt_integration_test`
- `b3_fasttrack_hunt_test`
- `b3_care_pills_autohunt_test`
- `b3_pill_satiety_test`
- `b3_ph0_continuous_kernel_test`
- `dv2_02_battle_snapshot_test`
- `dv2_02_group_map_battle_test`
- `dv2_02_five_level_pve_test`
- `gp_02c1_injury_settlement_test`
- `dv2_03_p3_v2_disciple_profile_test`
- `gp_02a_v2_cultivation_panel_test`
- `p3_2_map_camera_test` (includes full-width G1 camera assertion)
- `p3_1_landscape_shell_test`
- `sect_iso_projection_contract_test`
- `sect_map25_verified_art_gate_test`
- `sect_iso_main_integration_test`
- `sect_g1_disciple_radar_test`
- `b3_care_combat_v5_presenter_test`
- `p3_o9_m2_production_rehearsal_test`

The main CARE integration log demonstrates paid kills and committed loot receipts, return after defeat, Injury recovery at tick 120, same-world redeployment, another exactly-once loot receipt, and canonical Warehouse values. The V5 view test demonstrates the actual P3.2 runtime and authentic V2 recruit are attached to the view, checks active Source A disciple/monster clips, verifies the Boss asset, and records `boss_event_mapped=false`.

## In-engine GUI proof

- Actual P3.2 scene, 1280×720, OpenGL 3.3 on Intel Iris Plus.
- Nine screenshots and a 60-frame / 15 FPS / 4-second AVI are under `outputs/MASTER_RECOVERY_INTEGRATION_20261023/screenshots/f5715ad/`.
- The capture log is `outputs/MASTER_RECOVERY_INTEGRATION_20261023/logs/gui/master_recovery_visual_capture_f5715ad.log`.
- The combat screenshot shows AUTO on, the real V2 disciple and canonical B3 monster, Source A floor/vegetation, true HP/Injury/Tu Vi, battle count, Warehouse and pill facts.
- The capture fixture does not run long enough to show a kill: `capture_state.json` is the post-return fixture state and records tick 0, paid kills 0, Warehouse 0, AUTO false. Loot is proven by the real CARE integration-test log, not by that frame or JSON.

This is scripted scene/state capture, not physical mouse input or human playtest.

## Source-preservation record

- V5 reference worktree was inspected and left intact at `E:/codex/2026-10-21/t-ng-m-n-b-o-2/work/TongMonBaDao-v5-1`, branch `feature/v5-1-sourcea-visual-finalization`, HEAD `ae3f397cef654cd3ff1936261b018476a132e7db`; it remains dirty with the source branch's pre-existing edits/untracked files.
- The earlier UI worktree remains intact at `E:/codex/2026-10-22/t-ng-m-n-b-o/work/TMB_UIUX_FINALIZATION_V1_20261023`, HEAD `d0c002ceffe408251fe2655aad5ba51ebe89d0bf`; it remains dirty.
- Recovery integration used selective copies/adapters and did not reset, clean, overwrite, cherry-pick, push or merge either source worktree/PR.

## Still pending

- **Windows manual:** owner mouse review of selection, hunt, return, Save/Load and further play; no physical mouse path was automated here.
- **Android:** exported APK, device/touch, rotation and landscape layout acceptance.
- **Owner visual:** final approval of restored MAP25/G1/V5 integration; the screenshots are evidence, not owner approval.
- **A/B/C image comparison:** the tested PR #25 image (B) and current capture (C) are retained, but the historic PR #19/#20 image package (A) is absent from the checked worktrees/repository. Retrieve that prior package before claiming a complete visual regression comparison.
- **Boss/AoE:** actual CARE B3 authoritative Boss/event mapping is absent; source Boss-slot art is present only.
- **FULL/CI:** intentionally not run.
- **PR:** new integration PR should remain draft and unmerged; PR #24/#25 remain draft and unchanged.

## Suggested manual play path

1. Open the branch's `godot/project.godot` with official Godot 4.7.2 at 1280×720.
2. Select an authentic V2 disciple from the sect map/profile and choose the existing `Đi săn` command.
3. Confirm the V5 actor matches that disciple and the B3 creature; toggle AUTO and observe HP, Injury, Tu Vi, kills, Warehouse and pills.
4. Return to sect, verify the canonical Warehouse, save/load, then redeploy to the same CARE world.
5. Repeat using a male V2 disciple and record separately whether the male atlas route is visually accepted.

Do not use a test fixture's screenshot or generated V2 recruit as evidence of manual play.
