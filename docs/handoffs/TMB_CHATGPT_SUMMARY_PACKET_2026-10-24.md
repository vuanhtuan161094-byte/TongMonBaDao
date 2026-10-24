# TMB MASTER V3 — ChatGPT handoff summary

This is a provisional implementation branch, not canonical main.

- Repository: vuanhtuan161094-byte/TongMonBaDao
- Branch: integration/master-v3-combat-d7-uiux-20261024
- Base: PR #26 head 53ff0b223f4e77ccfbe5c77d2203496ac0cc37a9
- Tested code commit: 80ed0270d2b7370f8feff1ce829f167146f3f341
- Engine: Godot official 4.7.2.stable.official.ed1daf0bf
- PR #24/#25/#26 remain untouched, open, draft and unmerged; no FULL/CI.

## Completed with evidence

1. D7 foundation model and profile: 7 birth/current stats separated into Tam Căn and Tứ Tính; independent budget rolls; D7-specific potential scope; model2→D7 migration; provenance failure is fail-closed. CARE save wire v4 reads legacy v3. D7 test PASS with 139 checks.
2. Exact focused rerun: 20/20 PASS with exit 0/PASS marker and zero script/parse errors at tested code SHA. The first run was 19/20 with a fresh-roster failure in O9; the retry on clean userdata passed. Root cause of first-run variance is not established. Preserve both logs.
3. Combat trace fixture: PASS 62 groups × 20 seeds = 1,240 fights and 176,682 events. Diagnostic only; no balance target approved. It contains synthetic Boss scenarios, not a live CARE Boss mapping.
4. Real P3.2 GUI capture: 12 images at 1280×720 on exact code SHA. Actual CARE hit and skill at 4s, paid kill and COMMITTED receipt at 12s, post-loot HP 123.38/192.3, Injury 0, stock 1; SaveService reload retained paid_generation 1 and stock 1.
5. P3.2 portrait/profile presents 7 D7 axes and correct values. P4 map/worksite/combat HUD mockups remain static. Actual after screenshots show unresolved map-card overlap, long production panel, dense combat HUD/actor overlap. Owner visual acceptance is pending.

## Locked boundaries

No ×100 HP/damage/potion/economy rebalance, no new hunt EXP, no Injury duration change, no CARE/Combat V2 authority changes, no Source A/MAP25 edits, no merge, no FULL/CI, no push/merge of PR24/25/26. CARE remains runtime/save/reward owner; current P3.2 capture uses the V5 view already present on PR26.

## Key evidence

- Report: docs/handoffs/TMB_MASTER_V3_IMPLEMENTATION_REPORT_2026-10-24.md
- UI issue matrix: docs/handoffs/TMB_MASTER_V3_UI_ISSUE_MATRIX_2026-10-24.md
- Exact 20-test CSV: outputs/TMB_MASTER_V3_20261024/05_focused_tests/final_rerun_exact_commit_80ed027/focused_summary.csv
- Exact GUI log/manifest: outputs/TMB_MASTER_V3_20261024/03_actual_after_godot/commit_80ed027/
- Exact fixture: outputs/TMB_MASTER_V3_20261024/04_combat_fixtures/commit_80ed027/
- Screenshot comparisons: outputs/TMB_MASTER_V3_20261024/08_before_after_comparisons/
- ZIP: outputs/TMB_MASTER_V3_20261024/07_handoff/TMB_MASTER_V3_CODEX_HANDOFF_20261024.zip

## Pending gates

Owner visual and numeric balance approval, Windows manual mouse/play, Android device/touch, actual Injury120 UI frame, and live CARE Boss/AoE event mapping. Do not report any of these as passing.
