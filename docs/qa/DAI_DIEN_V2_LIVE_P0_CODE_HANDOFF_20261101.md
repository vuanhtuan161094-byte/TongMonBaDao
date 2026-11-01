# TÔNG MÔN BÁ ĐẠO — DD-01..DD-05 Đại Điện × Đệ Tử Xá code audit & QA gate

**Date:** 2026-11-01 | **Owner requested direct implementation by ChatGPT, no Codex currently.**  
**STATUS: CODED ON FEATURE BRANCH / NOT COMPILED WITH GODOT / NOT REAL-GUI TESTED / NOT PLAYABLE ACCEPTED / DO NOT MERGE.**
**Base:** ONE GAME RC eb5e139d61adb5e9881ccb85d4cd823ad7a84263.  
**Branch:** feature/dai-dien-v2-live-p0-20261101; PR #64 (Draft), target RC.  
**Design:** docs/design/DAI_DIEN_V2_GOVERNANCE_FULL_IMPLEMENTATION_SPEC_20261101.md on design/dai-dien-v2-governance-20261101.

## 1. Actual CODE committed, not a mock

1. **Canonical main Hall:** id main_hall_001, real BuildingState Lv1–100, unique in LiveGameRuntimeV2; existing paid/material/time-based BuildingSystem upgrade, level gates on other construction. Physical 2.5D Hall image has canonical instance ID; Old non-V2 map retains landmark fallback.
2. **7 early offices:** Chưởng Môn / Tiếp Dẫn / Truyền Công unlock Hall Lv1; Nội Vụ Lv3; Hộ Pháp Lv5; Đan Đạo Lv7; Giới Luật Lv10. Appointments/dismissals and 1–10 mastery with per-disciple per-office XP, one event award per office/day persisted across reload/reappointments. One main office per disciple; Tiếp Dẫn directly shares RecruitmentSystem main_guide_id, with next-day snapshotted effective Mị Lực. Role suitability from D7 pair with 0.90..1.15 capped factor.
3. **Actually wired effects:** Chưởng Môn +8–14% personal natural Tu Vi and effective Tư Chất, +effective Tiềm Lực/HP source on PvE-derived combat snapshot (preserve HP ratio, never mutate permanent birth D7); Truyền Công +3–9% natural Tu Vi to all eligible disciples, fixed pill XP remains unmultiplied. Nội Vụ -2–8% start duration of eligible Mine/Forest resource-timer jobs; Đan Đạo same for actually started alchemy; Giới Luật +3–9% actual REST amounts; Hộ Pháp -2–6% incoming damage ONLY within deployed role holder's PvE party, frozen into battle actor stats when initiated. No unsupported full seven-dimension boost for stat channels without consumers.
4. **27 sect rank transaction:** Nhân1–9 / Tiên1–9 / Thần1–9, catalogue proposed population ceilings up to 90 / 200 / 480, gate by real Hall level, roster headcount, V2 cultivation realm, completed real production batches, prestige and real warehouse costs. Promotion consumes resources once with persisted request receipt; renown earned only on accepted recruitment, committed resource batches, and genuinely settled PvE victory. Boss NOT mandatory. All numbers are PROVISIONAL for balance and F2P 3/12/24-month pacing; NOT approved.
5. **Multiple actual De Tu Xa BuildingStates:** starting residence_001 Lv1 with 8 beds; Lv2 =10, per-house 8+2(Lv-1) through Lv100=206; House2+ require Hall allowed instance cap + money/material, create stable IDs with persisted receipts to prevent double debit. Auto bed assignment preserves existing reservations, manual assignment API and comfort tiers 20/50/75/100. Legacy +1 slot/8 generic supply disabled only when Hall V2 opted-in; older modes unchanged. Cap computed = min(rank admin cap, sum beds), grandfather overcapacity old roster but block further admission until legal. Both on-map 2.5D houses and Hall are individually pickable real ID-bearing managed buildings, fallback on old saves.
6. **Native Godot UI/UX (not HTML):** from map Hall/Residence, six tabs Tổng Quan, Chức Vụ, Nâng Cấp, Thăng Bậc, Chính Sách, Đệ Tử Xá; implemented selection by matching D7 suitability, live role preview, Source A stand portrait where real approved asset present, fallback when missing, real upgrade/recruitment/promotion/policies and per-house buttons. Selected candidate refresh bug and roof/house overlap corrected in source. Does not guarantee clipping/mobile layout is good before real render capture.
7. **Existing state codec + SaveService**: SectState.hall_governance opt-in stores assignments/mastery/rank/house receipts/bed reservations, new BuildingStates serialise with existing codec. Load checks malformed governance/rooms fail closed; use own QA profile, do not touch player's live save.

## 2. Source files changed from RC

- godot/src/simulation/governance/sect_hall_system_v1.gd (NEW)
- godot/src/simulation/governance/sect_residence_system_v1.gd (NEW)
- godot/src/simulation/building/building_system.gd
- godot/src/simulation/recruitment/recruitment_system.gd
- godot/src/simulation/needs/needs_system.gd
- godot/src/simulation/cultivation/disciple_tuvi_flow_v2.gd
- godot/src/simulation/combat/disciple_combat_loadout_v2.gd
- godot/src/simulation/combat/hunting_pve_run_v2.gd
- godot/src/simulation/state/{sect_state,simulation_state}.gd
- godot/src/simulation/core/live_game_runtime_v2.gd
- godot/src/presentation/{dai_dien_screen_v1,p3_2_landscape_sect}.gd
- godot/src/presentation/p3/sect_isometric_world_v1.gd
- godot/tests/dai_dien_v1_smoke.gd
- godot/tests/dai_dien_housing_full_loop_test.gd (NEW)
- godot/tests/presentation/p3_4c_building_system_actions_test.gd (updated to preserve BOTH legacy and new contract).

## 3. Actual checks performed vs pending

**Static only:** inspected exact branch diff against baseline. Balanced brackets/quotes + unique top-level functions across 17 changed GDScripts on first audit (all 0 anomalies), reviewed key transaction/cap and UI logic; fixed several source-level issues: candidate replacement selection resetting to incumbent; house annex sites overlapping in later rows; stale "D7/HP not implemented" UI description; Residence House ID absent from map; Hall map token not associated to canonical MainHall ID; pre-debit vs post-debit house ID collision check; double visual refresh; legacy bed purchase loophole, malformed saved state fallback. This is NOT a complete GDScript parse guarantee.

**NOT EXECUTED in this connector environment:** Official Godot 4.7.2 Windows import, any Godot GDScript SceneTree smoke, SaveService actual write/reload, GUI screenshot/render 1280x720, Source A portrait capture, actual click/tap, frame/RAM, Android APK, full gameplay story. Do not label these PASS. In particular, cross-class dependency graph (Hall ↔ Residence, Hall ↔ BuildingSystem, Hall ↔ Recruitment) requires REAL Godot parser verification. Need a fail-fast isolated QA test before main-branch integration.

## 4. Tests authored, pending execution

1. \`godot --headless --path <QA_GODOT> --editor --quit\` — parse/import.
2. \`godot --headless --path <QA_GODOT> --script res://tests/dai_dien_v1_smoke.gd\` — Hall singleton, early office appointment, additive natural/fixed XP separation, same-day mastery, codec, native UI replacement selection.
3. \`godot --headless --path <QA_GODOT> --script res://tests/dai_dien_housing_full_loop_test.gd\` — NewGame 6/8→8/8 blocked→Residence Lv2 10 beds→accept ninth→House2 paid construction and replay→27 rank gate/promotion→SaveService durable roundtrip→real isometric managed IDs→UI and corruption gate. Test fixtures deliberately fund materials and artificially level Hall, explicitly NON-PRODUCTION.
4. \`godot --headless --path <QA_GODOT> --script res://tests/presentation/p3_4c_building_system_actions_test.gd\` — legacy lodging + V2 Hall path.
5. Existing C2 Dẫn Tiên, SaveService/O8 Thread, SX-01/02, B3 CARE, injury, natural vs fixed TuVi, PvE loadout/MapBattle and Source A regressions all must run on same exact SHA.

**Acceptance:**
- 7 office unlock gates, one-holder uniqueness, manual reappointment and correct GUIDE snapshot; per-office buff channels demonstrated on real committed events, nonoverlapping once-per-day mastery even after swap or reload.
- Any Hall/Residence upgrade must debit once and complete after right scheduler ticks, show level/real bed impact, survive Save/Exit/Reload. No hidden admin grants.
- Cap constrained by both Hall sect rank and number of real beds; extra house creates ID + visible 2.5D entity, not a text-only increase.
- 27-rank content and gates tested; no required Boss.
- 6-tab Hall/Residence real screen photographed at 1280×720; Source A roles portrait tested with an actual eligible asset, no clipped controls or offscreen tap targets.
- Windows launcher/playtest with isolated profile and 8GB laptop memory telemetry.
- No false PASS from headless-only when GUI blocked.

## 5. Known remaining limits / blockers

- **NOT free placement**: House annexes use fixed authored candidate sites; editable footprint, doorway, A*, roads, move building, land purchase/expansion remain separate LAY authority/schema work. No fake drag-drop or costless expansion is claimed.
- **Not a final economy**: preliminary House/Hall upgrade prices, new House build price, population/production/renown gates, prestige production rates and mastery XP are provisional. A 24-month nonpaying progression simulation and materials source-sink audit remain required.
- **No standalone .exe/APK** or verified screenshot generated here. Existing ONE GAME RC shortcut still targets older tested branch, not this unverified code.
- Limited profile portrait display: existing verified Source A sprite where available, explicit fallback otherwise; no bespoke role art created.
- Missing owner manual acceptance; missing real UI touch and performance QA. Full completion/merge is NOT authorized until these gates are satisfied.

## 6. Merge and QA discipline

Keep current PR #64 as **one integrated candidate** against rc/one-game-playable-20261101, not dozens of experimental PRs. Do not merge into main, alter owner E: worktree, destroy saves, remove backup or relax assertions to secure PASS. If Godot parser/import fails, fix source in same branch and repeat both focused and full regressions, attach real logs plus real window screenshots. The user is not using Codex now; this handoff exists only for later optional local integration.


## 7. DD-06 direct-code hardening — 2026-11-01 (added after original P0 handoff)

**Code committed on the SAME PR #64 branch, not Codex. NOT Godot-compiled or runtime-tested.**
Changes (each link targets a real commit):
- [8b24cd1](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/8b24cd178801a2c44d8e88e9a9ae46b702b356b9) — direct Dẫn Tiên main-guide assignment now checks **all six OTHER Hall offices**, not only Master and Teacher. Prevents public non-UI API bypass of one-main-office rule.
- [cd59eb5](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/cd59eb5c3a60e3743ba9436446f19a38a2fefdde), [ff70d18](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/ff70d184ed467042f761592dfc343a3277c9b073) — reject extra/noncanonical Hall IDs before applying migration, disable orphaned office bonus when Hall missing/locked, validate raw saved sect rank instead of clamping errors away.
- [ed19c4f](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/ed19c4f749e9656518fb7970447f681da12b8149) — validate House ledgers and legacy bed credits before assigning rooms; enforce canonical starter residence identity on loaded housing states; malformed room dictionaries fail closed.
- [4d3b238](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/4d3b238b406887bc2d5edf2d16aa4915f6a8b7db), [e6477de](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/e6477de506e0e4c365893616653438acbf9c55f1), [0e156a4](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/0e156a4329b95bd9871595dcd0efa4cef7f1a961) — Hall overview shows actual Nhân/Tiên/Thần step, current canonical admission limit, remaining source material quantities, relevant bottleneck tab navigation. House management has native low-node-count manual resident/house selectors calling the actual authoritative `assign_room` transaction, not hundreds of disciple cards.
- [055fcc9](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/055fcc9f8ae9909d41ecadaf9e53bc93d6d963d8), [5794346](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/5794346d1fadba094510264821ad5411ab284e06), [521bf78](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/521bf786612f5d545d34ec830189cbe10d257335) — new focused `godot/tests/dai_dien_dd06_integrity_test.gd` checks conflicts for all 6 competing offices, rank boundaries and saved corruptions, duplicates and missing Hall; existing housing full loop tests the real Godot UI manual room transfer.

**Non-engine scan performed:** fetched the current PR file list and exact branch contents via GitHub, scanned **18 changed GDScripts** with a string/comment-aware balanced-bracket scanner plus duplicate-function name detector. Result: **0 structural anomalies found in this limited scan**. No GDScript grammar parser, Godot script import, runtime invocation or screenshot was available in this environment. Do not label these tests PASS. Godot 4.7.2 is not installed on the connected runtime, and it cannot access the user's E: workspace.

**QA to execute isolated (correct branch HEAD, dedicated user-data profile):**

```powershell
& $GodotExe --headless --path $QaGodot --editor --quit
& $GodotExe --headless --path $QaGodot --script res://tests/dai_dien_dd06_integrity_test.gd
& $GodotExe --headless --path $QaGodot --script res://tests/dai_dien_v1_smoke.gd
& $GodotExe --headless --path $QaGodot --script res://tests/dai_dien_housing_full_loop_test.gd
& $GodotExe --headless --path $QaGodot --script res://tests/presentation/p3_4c_building_system_actions_test.gd
```

Still required: C2 Dẫn Tiên regression; SaveService + O8 thread/offline; SX-01/SX-02/B3 CARE/Injury/PvE regressions; full GUI 1280×720 with actual Source A asset on Windows 8GB; check class resolution/recursion among Hall/Residence/BuildingSystem/Recruitment; portrait fallback, touch/scroll/clipping and real QA logs. No RC/main merge.

## 8. Preliminary F2P 3/12/24-month source/sink gate (static analytical calculation ONLY)

Amounts below are **resource debit requirements computed from the CURRENT prototype formulas**, not a validated progression simulation or guarantee of obtaining the resources. Model includes only Hall upgrade to the required rank's minimum level, 1 free starter House, the listed number of additional House constructions, House upgrades to the displayed levels, and the rank promotion stones. No discounted inventory, other building upgrades, academy, Tu Vi, recruit costs, normal upkeep, combat, alchemy or forge. House layouts are mathematical candidate arrangements, **not confirmed placement/land capacity**.

| Milestone | Hall + rank | Candidate housing capacity | Approximate core Linh Thạch sink | Mean sink over time |
|---|---|---|---:|---:|
| ~3 months (~90 d) | Hall Lv33, Nhân 9/9 | 3 Houses Lv12 = 90 beds | 198,077 | 2,201/day |
| ~12 months (~365 d) | Hall Lv73, Thần 1/9 | 6 Houses Lv17 = 240 beds | 1,179,057 | 3,230/day |
| ~24 months (~730 d) | Hall Lv100, Thần 9/9 | 10 Houses Lv21 = 480 beds | 2,943,071 | 4,032/day |

For the final 480-bed candidate, detailed known prototype sinks: Hall Lv1→100 = **109,092 Linh Mộc + 87,289 Thanh Thiết + 2,181,241 Linh Thạch**; ten House upgrade chains Lv1→21 = **31,880 Mộc + 22,770 Thiết + 454,130 Linh Thạch**; Houses #2–10 construction = **13,500 Mộc + 8,640 Thiết + 270,000 Linh Thạch**; 26 rank promotions = **7,540 Mộc + 4,524 Thiết + 37,700 Linh Thạch**. Combined subset = **162,012 Mộc + 123,223 Thiết + 2,943,071 Linh Thạch**; average **222 Mộc, 169 Thiết, 4,032 Linh Thạch/day** over 730 days, before any other spending. Milestone component rules, warehouse backpressure, actual offline clock, production yield, market receipts, player active time and cultivation/realm gates require engine-backed measurements.

**Conclusion of this audit:** 3/12/24-month goals remain **UNVERIFIED**. The current rank requirements have no elapsed-time gate; claimed months depend on actual source/sink throughput and cultivation gates. Before balance approval, run one reproducible multi-scenario simulation (new player, daily active, offline, no-purchase, roster/house availability, production, prestige, medical overhead) on the final authoritative cost tables. Never increase resource grants just to make a smoke pass.

## 9. Open high-impact implementation gaps after DD-06

- New House purchases are charged and activated immediately, **not a separately scheduled construction timer**; House upgrades have existing tick-based work. This discrepancy with the full design remains an explicit P1 gap.
- Free-placement, land expansion, persistent layout/footprint, AStar doorway collision and moving buildings are not implemented for annexes; fixed-sites are the only current authority.
- Long-run Lv100 and 27 promotions lack a full calibrated gameplay economy and durable longitudinal evidence.
- Engine import, real-pixel UI and playtest are BLOCKED/UNRUN in this connector environment. **PR must stay Draft.**


## 10. DD-08 P0 direct implementation — strict persistence and paid-action replay gate

**Scope:** The owner explicitly authorized continuing the DD-08 stabilization phase without Codex. This code was written directly on PR #64's existing branch; it was **not** merged to RC or main. These are **source-level fixes and authored tests only; NO official Godot 4.7.2 execution has occurred**. No screenshot, engine import PASS, FPS, RAM, Windows build or Android APK is claimed.

### Changes actually committed

1. **Fail-closed saved office dictionaries.** `SectHallSystemV1.validate` checks the saved types of `assignments`, `mastery`, `office_award_day` and `promotion_receipts` **before** calling `holder_id`, so malformed fields can fail through SaveService and allow recovery from a valid `.bak` rather than causing an unsafe cast. Also verify role keys and officer-ID types.
2. **Strict canonical House identities and cost receipts.** Residence invariants require `residence_001..residence_N` with matching instance indices and dictionary keys; paid Houses #2+ require a unique receipt referencing an existing House. A replay cannot report `already_settled` if its paid House has vanished. Raw saved legacy bed credits and Residence schema versions are checked with integral/finite type guards.
3. **Faster capacity queries.** `all_houses` filters actual Residence instances first, then sorts only the (max 10) matching records instead of sorting all keys of the production BuildingSystem. No second persistent index or duplicate bed authority was introduced. Earlier Hall O(1) lookup remains in place.
4. **Durable exactly-once Hall/Residence upgrade requests.** `BuildingSystem.start_upgrade(state,id,request_id)` now requires a nonempty request ID for Hall/Residence when Hall V2 is installed, validates replay identity and persists `hall_governance.upgrade_receipts` after a successful paid start. The same request, including a stale UI callback arriving AFTER upgrade completion, returns `already_settled` without starting the NEXT level. The native Godot UI binds per-building/per-target-level request IDs when the button is constructed; the old P3.7 non-Hall/Residence `start_upgrade` API remains backward-compatible. An empty upgrade-receipt dictionary is accepted for older V2 saves; new saves persist it.
5. **Save wire duplicate row guard.** `SaveService._is_payload_shape_valid` rejects duplicate/missing/wrong-type raw building or disciple IDs when an explicit Hall governance payload is present, before `SimulationState.from_dict` can silently overwrite rows in ID dictionaries. Unaffected legacy save payloads keep the original path.
6. **Strict Hall schema and upgrade receipt validation.** No string-to-int schema coercion, future/duplicate paid upgrade targets, or non-finite target values. Paid promotion receipt replay also rejects impossible future ranks in the direct API.

### Authored regression coverage (NOT RUN)

- `res://tests/dai_dien_dd07_save_recovery_test.gd`: corrupt Hall ledger types, paid House missing receipt, corrupt legacy bed credit, duplicate raw building/disciples IDs, staged SaveService rejection without damaging last-good save, `.bak` recovery.
- `res://tests/dai_dien_housing_full_loop_test.gd`: House and Hall upgrades both reject missing request IDs, charge precisely once, replay during work without a second debit, replay *after completion* without inadvertently starting the following level, and keep earlier House/build/rank/SaveService scenarios.
- Earlier `dai_dien_dd06_integrity_test.gd`, `dai_dien_v1_smoke.gd`, `p3_4c_building_system_actions_test.gd` remain in the focused suite.
- Static-only bracket/quote and duplicate-function scans are **not grammar or runtime tests**; there is still no engine executable in the connected environment.

### Minimum isolated Windows verification — official Godot 4.7.2

Run from a **separate clean QA checkout**, not an owner's playable checkout; set `$GodotExe` to the official executable and `$QaGodot` to the absolute path of that checkout's `godot` folder. Ensure the QA profile is separate from real APPDATA saves. Stop on first nonzero code and retain the full log.

```powershell
& $GodotExe --headless --path $QaGodot --editor --quit
if ($LASTEXITCODE -ne 0) { throw "DD08 engine import failed" }
foreach ($test in @(
  "res://tests/dai_dien_dd06_integrity_test.gd",
  "res://tests/dai_dien_dd07_save_recovery_test.gd",
  "res://tests/dai_dien_v1_smoke.gd",
  "res://tests/dai_dien_housing_full_loop_test.gd",
  "res://tests/presentation/p3_4c_building_system_actions_test.gd"
)) {
  & $GodotExe --headless --path $QaGodot --script $test
  if ($LASTEXITCODE -ne 0) { throw "DD08 FAIL: $test" }
}
```

**Do not merge when only focused headless tests pass.** Follow up with C2 Dẫn Tiên, SX01/02, O8/SaveService thread, Injuries/Care/PvE, real 1280×720 window interactions, Source A portraits, and memory/FPS at 90/200/480 roster. Record exact tested SHA, original logs and screenshots. No silent modification of main or owner saves.

### Still NOT implemented or calibrated

- Fixed-site Annexes still have no persistent land-ownership/footprint/doorway authority and no placement editing. Additional Houses activate immediately; their separate construction timing is DD-09, not DD-08.
- 27-rank headcount progression remains a prototype; the rank-gate formula and 3/12/24-month no-payment pacing still require source/sink and actual time simulation. A source-balanced economy is DD-10, not asserted solved.
- Full versioned `upgrade_receipts` migration rules for saves from *future* unrecognized formats, plus all cross-class parser checks, remain subject to official Godot QA.
- Do not claim that Godot GUI, Android landscape or player workflows have passed. **PR #64 remains Draft and DO NOT MERGE.**
