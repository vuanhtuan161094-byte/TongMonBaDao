# GUI-WORKFORCE V1 — Integration acceptance and runtime queue

## MAP25 update — 2026-10-16

Source code SHA `e64fbfe35ac08f8b5e8be62553a31811c2b40ce7`. The production main scene now owns a visual Node2D isometric 192×192 world with a real Camera2D/SubViewport and projected real building IDs; GUI Workforce card and scheduler authority remain unchanged. Procedural fallback houses/trees/road while the external ENV-02A art files are absent from GitHub. Two focused map regressions are written, **not run** on official Godot. This is not a released art pack or Windows/Android acceptance. No construction authority enabled.

## 2026-10-16 — LAY-V2 all-instance readiness (CODE SHA `2e6cdc2e67a456e4836dcf4d2f252773f486a9d9`)

Per-instance picker now enumerates saved canonical BuildingState IDs and routes resource worker, production plan, Field policy and Mine upgrading to the selected instance. Previous production costs and Warehouse/Scheduler unchanged. Hub exposes proposed Hall tiers and 13-region design without activating construction; status `preview_only=true`, Hall/land/building pricing and persistent layout authority PENDING owner/ENV-02A verification. Tests `economy_v2_expansion_cap_preview_test.gd`, `sect_land_region_preview_v2_test.gd`, `gui_multiple_resource_instances_test.gd` authored, **NOT RUN**. Their addition is not a legal build command. See `docs/LAY_V2_INTEGRATION_READINESS_2026-10-16.md` and PR #13 for blocked numeric approvals.

## Sect-Playable V1 navigation handoff (2026-10-16)

- Code/test checkpoint SHA: `d147477b184deff1ff266bcb2be90db2098be453`, same existing 1280×720 main scene; PR #18 remains draft.
- Top **Điều hành**, bottom **Tông Môn** now expose real roster capacity/tokens/Stones and status/warehouse per Mine, Forest, Field. One-tap navigation to existing Guidance recruitment, worker-card assignments, Kho/Phường Thị, deep Disciple profile, and save-current-state action (real runtime save).
- After real RecruitmentSystem accepted complete V2 candidate, **Phân công ngay** opens Mine's workforce picker prefiltered for accepted ID; no auto fake assignment or extra candidate.
- New `godot/tests/presentation/sect_playable_home_loop_test.gd` validates the live Godot scene route Guidance→recruit→Mine picker→Kho→autosave/reload→disciple profile. Test is **UNRUN**; requires Godot 4.7.2.
- QA not closed: official import, focused new test, prior GUI-Workforce full 3-producer test, O2/O3/O4/O6/O7/O8/O9, Injury/SAFE, cumulative FULL, Android/Windows visuals, offline recovery and sustained device load all PENDING. No change to locked backend authority or balance. 4 scripts source-structure checked only.

Date 2026-10-16. Draft PR #18 code/test SHA `7377a60d55f06bf22d14ff65e7a90eebdca375d1`. **Implementation complete at static code level only; runtime PENDING.**

## Player workflow
- Tap Mine / Linh Lâm / Linh Điền on existing Sect Map; existing right-side 440×552 management panel immediately shows current person, level, real job progress and real Warehouse stock.
- Tap **Chọn / Đổi**: open 660×535 centred selector in 1280×720 landscape. Search live by name or ID; 16 entries per page; eligible idle workers sort first. Busy workers are displayed with a disabled button and reason. Existing idle work-group membership can be atomically transferred.
- Tap **Giao việc** on a valid candidate: `WorkforceSystem.transfer_production_worker` validates complete availability of candidate and former worker, persists exact work group and worksite in one transaction; `issue_command` queues same profession WORK for the existing scheduler. If the newly assigned building cannot start, assignment still persists with an explicit notice and **Bắt đầu** remains available once prerequisites hold.
- **Bắt đầu** sends an authentic WORK command. Mine/Forest use existing Economy-A timer if enabled (explicit opt-in button for fresh legacy games); Field reuses real crop plot timer and per-plot Stone cost. **Gỡ người** uses `assign_group(...,&"")`, rejects during a committed timer or growing Field duty. Hidden **Nâng cao** exposes crop/plan policies and legacy management.
- For actual completion only: real Warehouse resource changes, profession EXP and Economy-A batch wage receipt; all are owned by old production code. Save/offline use existing SaveService + runtime clock and building.production_state.

## Runtime gate required (NOT RUN)
1. Launch Godot 4.7.2 with scene `res://scenes/p3/p3_2_landscape_sect.tscn`; inspect no errors or hidden/offscreen text/buttons at actual 1280×720 landscape; **must not be portrait**, both Android touch and Windows capture later.
2. `res://tests/presentation/gui_workforce_v1_e2e_test.gd`: real scene select/transfer, timer, idle remove/reassign, Field same worker plots, real SaveService roundtrip, restored Forest settlement.
3. `res://tests/presentation/economy_a_landscape_ui_test.gd`, `p3_o3_real_mine_loop_test.gd`, `p3_o4_spirit_field_loop_test.gd`, `p3_o7_linh_forest_test.gd`, `p3_o8_alchemy_loop_test.gd`, `p3_o9_m2_production_rehearsal_test.gd`.
4. One Active Job focused regressions, `gp_02b1_v2_occupation_guard_test.gd`, GP-02C1 injury, O6 `==4`, SAFE-01/02, Economy-V2 core/bulk, physical save/offline, P3.7 FULL. Check no second scheduler, output mint or hidden waitlist.
5. Mobile touch/large roster performance and visual acceptance PENDING USER, distinct from headless test success. None of these tests has been run in this session.

## Source boundaries
Only game presentation `godot/src/presentation/p3_2_landscape_sect.gd` and canonical `godot/src/simulation/workforce/workforce_system.gd` changed for GUI V1 plus tests and docs. Neither project main scene nor resource production/loot/currency/injury/Realm/Body/scheduler/save contracts were modified. O7 old slot assertion updated to 1 by owner-locked Economy V2 contract, not weakened. Static lexer checks do not demonstrate executable correctness.
