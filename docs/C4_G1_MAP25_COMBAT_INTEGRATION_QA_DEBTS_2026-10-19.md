# C4 + G1/MAP25 — QA DEBT AND REAL-HUNT ROSTER FIX, 2026-10-19

**Status: CODE INTEGRATED ON DRAFT ISOLATED BRANCH; GODOT 4.7.2 INTEGRATED GATES PENDING. NO FULL/CI/MERGE.** Main `461caca1171462e0da092f21108c5c1733157ad9` has not been changed.

## Correct source choice

- Real accepted production/sect UI is **draft PR #20** `g1-disciple-radar-sourcea-pool-20261017` at `2219535fc3519ce811265ceed5cb85001efe5e45`, retaining all stacked Economy V2/Map25, real building controls and Source A actor/radar.
- Combat view/JX1 art/real hunting screen came from `c4-be01-hunting-playable-and-max-fixture-20261019`, originally forked from legacy `main`. The old BE01 standalone used P3.2's main-era map, causing a visibly incompatible production screen.
- Integration branch `integration/g1-map25-c4-real-hunt-20261019` forks **G1 PR20**, *not* main. Tree cherry-pick by original verified Git blobs brings **57 disjoint C4 files** (original source PNG/WebP checksums retained, scripts/tests/docs), then adds only `_open_real_hunting` + `world` dispatch to G1's 6,000+-line `godot/src/presentation/p3_2_landscape_sect.gd`. Existing Mine/Forest/Field instance workflow, G1 six-dimension radar, source actor, pan/zoom, economy, building GUI are not replaced. The combat arena uses `MapBattleWorldLayerV2` and original Source VL JX artwork; surrounding new control chrome uses G1 parchment/ink/green/gold palette.
- Neither G1 nor C4 changes were merged into main; no changes to `SimulationScheduler`, `SaveService`, `WarehouseSystem` or Economy parameters in this packet. A new branch can still find **simulation compatibility conflicts on official Godot tests**; do not claim runtime integration PASS from a clean Git blob diff.

## User reported: all disciples are disabled

Root cause in `HuntingPlayPanelV2`: backend PvE requires REAL independent canonical Tu Vi+Body coordinates, whereas P3.7 initial roster contains pre-V2 founders without a V2 birth/progression owner; initial panel also excluded injured/busy/worker-reserved without distinguishing cause. It incorrectly presented one undifferentiated "busy/low realm/injury" tooltip, giving no corrective action. Note **no level threshold** is enforced by `HuntingPveRunV2.begin`: a legal Tu Vi realm1/floor1 + Body realm1/floor1 recruit may hunt an appropriately selected zone; the issue is missing source data or an occupied job, not a high-level XP gate.

**Fix:** `_eligibility_reason` precisely prioritizes missing canonical profile, dead HP, Injury 1/120, active PvE, out-of-sect, current_action, active work cycle, spirit plot/timed recipe/body-training reservation; roster row and counts show specific grounded reason and `SẴN SÀNG` when eligible. A `Tuyển đệ tử V2 ở Dẫn Tiên Đài` button routes to the unchanged native G1 recruitment UI. NO fabricated cultivation values or silent P2→V2 upgrade. Valid V2 recruitment is already established by `DiscipleGeneratorOpenPoints.generate_candidate` → `RecruitmentSystem.accept_candidate`; focused UI smoke now calls this real path in **isolated** new-game fixture, selects genuine V2, opens and saves actual `HuntingPveRunV2` encounter, asserts no early reward, no user save touched.

**IMPORTANT follow-up:** active recruit availability depends on current_action and resource/region flags. Distinguish missing V2 from other blockers in evidence; no unlocking busy/injured workers by changing their status.

## Existing QA debt — canonical 17 entry ledger

The GitHub `docs/QA_DEBT_MASTER_AND_BACKEND_REDESIGN_HANDOFF_2026-10-13.md` defines Q01–Q17. **17 are category records, NOT 17 failing tests and NOT 17 remaining test runs.** Its latest top-of-file addenda supersede stale historical rows:

| Entries | Count | Evidence level and present closure |
|---|---:|---|
| Q01–Q04 | 4 | Windows automated regression groups: Injury focused, P3 scene, O6, P3.7 FULL. Linux/Windows PASS at **older named SHAs** in debt ledger; exact *new integrated SHA* unverified; O6 historical failure resolved for later Economy-A baseline, old failure attribution separately optional. Only rerun adjacent Injury/PvE and GUI now; no FULL unless evidenced regression |
| Q05–Q10 | 6 | Manual/physical: Injury GUI, Android touch/offline/fault, 100/500/1000/3000 disciple performance, ENV02A map/asset and FPS, P3.6 screenshots/workflow infrastructure, real device SAFE fault recovery. **Not auto-closable** by a Godot script or Windows-only screenshots |
| Q11–Q17 | 7 | Future scope/backlog: DV2-03 C–H **PAUSED**, one-active-job global reconciliation, extra building production governance, long-term economy balance, character effect coverage, land expansion, Source A/mobile final UX. **Not seven red tests**; separate authorized CODE/design packets required |

Additional phase evidence:
- G1/MAP25 PR19 at `5ce3c0f` has official Windows source art, renderer and performance PASS; PR20 has earlier **9/9 focused Windows PASS**, *not* evidence on latest `2219535` or integration.
- G1 acceptance requires 4 focused + three Mine/Forest/Field screenshots and owner UX approval; for current integrated SHA all are PENDING.
- Old `C4_BE01_HUNTING_MAX_QA_LOGS.zip` ran 3/10 focused PASS, stopped on now-corrected outdated 1x camera assert; next `C4_BE01_RECHECK_ONE_CLICK(1).zip` sent by owner is a **launcher ZIP**, not a QA result archive. There is **NO** evidence for the 8 remaining C4 checks, new real V2 selection UI, 30v40 stress, or GUI. Never assert they PASS.
- 7 deferred P2 learned non-damage skill consumers and Accuracy/Evasion + actual dodge AI are **feature debt**, not failed tests. They are outside Priority 1 and require own gameplay packet.

## Minimal one-time exact-SHA integrated Windows QA

On newest integration SHA run **17 focused independent scripts** (one 4.7.2 project import, isolated TEMP clone/save):
1. Four G1 acceptance: `sect_g1_disciple_radar_test.gd`, `sect_source_a_actor_pilot_test.gd`, `gui_workforce_v1_e2e_test.gd`, `gui_multiple_resource_instances_test.gd`.
2. Eleven C4 real battle tests: pilot effects, snapshot, group map, 1x view, source atlas, cast schema, GP01 damage receipts, rank/FX source, 30v40 MAX realm30/floor10 with only operational skill effects, five-level reward E2E, genuine V2 selection + live-hunt UI smoke.
3. One Map25 real scene source/workforce/camera test and one GP-02C1 Injury focused test (the actual shared code/return interaction); total **17** focused.
4. `--headless --quit-after 45` P3.2 scene smoke, then **one human 1280×720 game inspection**: production Mine/Forest/Field style remains, Thế Giới opens JX Combat screen, native Dẫn Tiên recruitment yields selected V2 and real PvE, close/reopen/claim where possible. Save is isolated. Request three screenshots G1 production and one combat screen, optional 30v40 visual pilot video; all owner acceptance PENDING.
5. No FULL/CI/MERGE. If focused parser/error, fix only failed integration contract, not balance or RNG. 30v40 max is in isolated fixture and should be paired with one realm1/floor1 real recruit.

Required final statuses: **exact-SHA focused**, **Windows manual appearance**, **Android physical FPS/touch**, **owner visual acceptance**. One doesn't imply any other.

## Rollback

Leave PR #20 unchanged. If integrated UI fails, verify G1 baseline `2219535fc3519ce811265ceed5cb85001efe5e45` in isolated clone. If isolated C4 fails, verify BE01 baseline `1f08938da9ebf5386d0fbceb8e5ae8e2fb0f6969` or its later roster correction on its separate branch. Neither baseline alters live local save/production `main`.
