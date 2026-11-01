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
