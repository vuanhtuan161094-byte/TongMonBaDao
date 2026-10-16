# GUI-WORKFORCE V1 — Integration acceptance and runtime queue

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
