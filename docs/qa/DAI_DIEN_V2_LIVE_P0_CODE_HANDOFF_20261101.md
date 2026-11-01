# DD-01 CODE HANDOFF — ĐẠI ĐIỆN V2 first playable vertical slice (2026-11-01)

**STATUS: CODED / UNCOMPILED IN THIS ENVIRONMENT / NOT GUI ACCEPTED / DO NOT MERGE.**
Base ONE GAME RC SHA: eb5e139d61adb5e9881ccb85d4cd823ad7a84263.
Feature branch: feature/dai-dien-v2-live-p0-20261101.
Source design spec: design/dai-dien-v2-governance-20261101 / docs/design/DAI_DIEN_V2_GOVERNANCE_FULL_IMPLEMENTATION_SPEC_20261101.md.

## What I actually coded

- New opt-in governance authority in SectState.hall_governance, persisted via to_dict/from_dict with conservative version check.
- New singleton main_hall_001 BuildingState, idempotent creation in live V2 boot, uses existing BuildingSystem upgrade transactions, no separate resource or save ledger.
- SectHallSystemV1 for Chưởng Môn, Tiếp Dẫn, Truyền Công. Chưởng Môn / Truyền Công assignments persisted in Hall; **Tiếp Dẫn reads and writes the existing RecruitmentSystem Main Guide ID**, not another ledger. All three seats obey no-two-main-offices rule; Dẫn Tiên assignment guards conflicts. Appointments do not cancel existing production/PvE work.
- Actual natural Tu Vi channel from DiscipleTuViFlowV2.preview_rate and resolve_minute. Master +8–14% *personal natural cultivation*; Teacher +3–9% sect-wide *natural cultivation*. Sources are independent additive records passed to DiscipleRealmProgressV2.grant_xp. Fixed-value pills remain unchanged. Preview and committed XP share the same sources. No D7 birth mutation, no fictional instant permanent attribute points.
- Per disciple+role mastery Lv1–10, +5 XP at most once per simulation day from a genuine committed natural Tu Vi event, bounded per-day memory record, persists through removal/save/reload.
- Native DaiDienScreenV1 modal through live P3.2 Main Hall building panel: overview, office assignment and dismissal, mastery/bonus readout, cost/time for real Hall upgrade, honest unimplemented Sect Rank tab.
- New focused Godot SceneTree smoke for Hall singleton, two offices, additive natural XP, fixed XP exemption, mastery replay, roundtrip, native UI nodes, dismissal.

## Explicitly NOT coded (must not be represented as complete)
- Real permanent/effective 7-attribute projection and Chưởng Môn +HP to combat stats. Only natural Tu Vi office effects are actually wired.
- Other offices at Hall levels 3/5/7/10+ and their actual production/PvE/alchemy/REST consumers.
- 27-rank sect promotion transactions, Uy Danh authority, full costs/rank gates.
- Multi-Residence BuildingState, real construction/placement/land schema, rank-based admission capacity; P12 cap=8 and P16 lodging=6 remain separate.
- Source A office portraits, six fully functional Hall tabs, role comparison, UX art QA, mobile APK, FPS profiling and owner's real mouse playtest.
- Godot 4.7.2 import/compile/test execution: **not available in this remote connector session**, so no PASS claims. Existing RC launcher not repointed.

## Codex local commands and acceptance gate

Use an **isolated QA checkout** on E:; do not touch live worktree, owner save or existing Godot processes. Fetch feature SHA and compare against then-current RC. Use exact Godot 4.7.2 official path and capture stdout/stderr:

1. \`godot --headless --path <QA_GODOT_PATH> --editor --quit\` — import/parser
2. \`godot --headless --path <QA_GODOT_PATH> --script res://tests/dai_dien_v1_smoke.gd\` — DD-01 focused.
3. Re-run original \`dan_tien_c2_smoke.gd\`, \`p3_4c_building_system_actions_test.gd\`, TuVi/natural-vs-fixed, P0 Save/Reload, O8 Thread, Injury, SX01/SX02, PvE focused suites; a failing test must be diagnosed, not loosened.
4. Godot real GUI 1280x720: Main Hall token -> launch modal -> appoint Master/Teacher/Guide -> confirm display & actual TuVi → dismiss→ Save/Reload → Hall upgrading, consumed resources and tick completion; record genuine screenshots (not screenshots of HTML).
5. Verify source registration: new class_name scripts must parse in the QA Godot build, path and scene imports succeed, candidate UI remains reachable after Hall overlay closes. Verify that Guide selected in Dẫn Tiên is the exact same disciple selected in Đại Điện.
6. Validate actual XP on one complete live New Game save, vs dry_run, and fixed pills unchanged. Repeated 1440-day tick snapshots must not duplicate mastery. Safe disabled if injured.
7. If any static/scene/parser issue arises, fix it on the **same feature branch**, exact commits and raw logs. Never cherry-pick untested scripts directly onto the stable owner's RC.

## Next code packets AFTER DD-01 is technically verified

DD-02: permanent/effective D7 + HP projection with HP ratio preservation and Source A roster office badge.
DD-03: full early office catalogue & actual domain effect consumers for factory, PvE, Alchemy and REST.
DD-04: 27 sect rank/renown/promotion with real owned gates and exactly-once costs.
DD-05: Residence multi-instance and canonical capacity/land/build UI with safe legacy migrations, then six complete Hall management tabs.
DD-06: ONE GAME end-to-end real gameplay and source/cap/FPS/Windows desktop acceptance.

Do not mark **FULL ĐẠI ĐIỆN COMPLETE** until DD-01..DD-06 pass. Avoid PR proliferation and hidden unverified balances.
