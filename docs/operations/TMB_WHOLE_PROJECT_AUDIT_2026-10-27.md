# TÔNG MÔN BÁ ĐẠO — INDEPENDENT WHOLE-PROJECT AUDIT / 2026-10-27

> Evidence tier: **GitHub tree/source review and prior exact-SHA Windows QA logs**, NOT a fresh Godot/GUI test. User explicitly requests implementation/integration **later, after reopening Windows**. Keep this audit and any QA tool fixes isolated. No gameplay/SaveService or `main` merge authorized by this report.

## 0. Evidence baseline and measurable inventory

- GitHub repo: `vuanhtuan161094-byte/TongMonBaDao`.
- `main` = `29b5fba448b0178cb520a4ada44b375b4b934e31`; audit baseline `feature/pve-jx-continuous-world-20261026` = `6b3fd181392c96c2386e5aa85950d2e993d67dda`. Comparison reports feature **137 commits ahead, 0 behind**. This is not permission to merge all 137 commits.
- 39 OPEN PRs (all DRAFT) at review time, many stacked on unmerged intermediate branches: PR #24–#35 integration stack, AUX #44/#45, independent proposals #46/#47/#48. No latest runtime acceptance supersedes branches merely by commit count.
- Audit feature tree: 1,226 blob entries, about **116.4 MB of tracked blob content**; `godot/tests/**/*.gd` 139 scripts; 96 simulation GDScripts; 57 presentation GDScripts. Approximately **74.7 MB** is tracked under `outputs/` + `godot/outputs/` (artifacts including ~33.9 MB video). Do not delete/archive any of this before inventory+SHA+consumer scan; history cannot be shrunk by just removing working-tree files.
- Main P3.2 presentation script: `godot/src/presentation/p3_2_landscape_sect.gd` ~6,074 lines / ~297 KB; `SectIsometricWorldV1` ~1,251 lines; `BuildingSystem` ~1,588 lines. These are **maintainability risks**, not proven gameplay faults.
- `CURRENT_CHECKPOINT.md` ~226 KB, `NEXT_CHAT_HANDOFF.md` ~185 KB: chronological handoff pages are expensive to parse and may contain superseded instructions. `README.md` still says first P2.1 persistence regression is unresolved and suggests `Sync-P2-6.cmd`, despite the latest feature PvE integration. Root `AGENTS.md` authority rules are still binding; don't erase history. Propose one compact current-state index and archive-only navigation links.

## 1. Execution vs proposed systems (DO NOT CONFLATE)

| Area | Evidence in active feature baseline | Missing / acceptance |
| --- | --- | --- |
| Production/economy | Canonical P3.7 BuildingSystem/WorkforceSystem/WarehouseSystem and merged Economy-A code. Source A production map, real building IDs, progress/received receipts, worksite cue cap 4. | Owner visual acceptance of production UX; quantitative 30/30/40 and x100 Economy-V2 proposals are on independent DRAFT PR #6–#13, **not automatically feature/main-authoritative**. Compare actual rules and tick economics before adopting. |
| Disciple progression | Authentic V2 birth, D7 foundation, Tu Vi/body tracks, HP syncing; one-active-job/Injury 0/1/120 guarded across owners. | Endgame progression/Body gate/CPV2/Combat V3 design ≠ runtime completion. Test generated D7 save migration before changing stats/XP. |
| PvE/world | Source A 192×192 navigation, 20 camps, 6 real V2 members vs 10 enemies in focused integration; continuous saved world; Godot 4.7.2 headless logs at `7c79a77` report 79 sim seconds /153 actions/9 kills, live Save/Load. | Real mouse, Save/Return UI, physical capture, phase FPS and A/B logger still **PLAYABLE_BLOCKED**. The short integration did not reach zone-hop or Injury120. |
| Combat authority | MapBattleV2 0.25s tick, max 30 disciples/40 active monsters, V2 action/cooldown/HP0/kill-journal. Presentation adapters V5/Source A/JX #158 must remain consumers. | 200–400 respawn registry slots **are not** 200–400 active combat actors. Scale/zone-hop/Boss/AoE remain separate gates. |
| Reward/forge | P2.6 legacy EquipmentSystem has recipes, deterministic craft and player/AI item purchase. Economy-A canonical Warehouse has real receipts. | Continuous world explicitly reports `LOOT_PENDING`; per-monster/elite/Boss payouts are **not approved**. No proof that new P3.7 forge order/refine/enhance transactions exist just because P2.6 forge code exists. Avoid minting imaginary drops or claiming craft loop done. |
| Assets | Source A MAP25 environment/actors has provenance gates; JX #158 35 VFX frames audited by AUX-03 in Draft #44. | Source A extracted clip->prefab->skill binding not yet verified; AUX-03 adapter SaveService QA runtime still PENDING. Style remains Source A, not renderer rewrite. |
| Runtime QA | 139 Godot test scripts exist; AUX-01 50 Save/Return checks PASS, AUX-02 movement focus PASS but 2 separate failure findings, independent QA PRs prepared. | 139 scripts does NOT mean 139 PASS on current HEAD. GitHub Actions capacity is exhausted; Windows headless official Godot and manual input must supply new exact-SHA proof. |
| Android | Project configured for 1280×720 landscape and GL compatibility. | APK install, real touch targets, memory/thermal/rotation and storage interruption PENDING physical device. |

## 2. Confirmed blockers versus optimization hypotheses

### G0 / P0 — Protect player save + Playable GUI

**SAVE-01:** AUX-01 `dv2_03_runtime_clock_test.gd` at official Windows SHA `c26491c...` reports owner `save_to_path(...,2120)` => `{ok:false,error:1,steps_run:2,pending_minutes:0}` with tick2/wall2120. Clock advancing correctly does **not** prove the new state can be saved. `SaveService.save_to_path` may fail at stage validation *or* file/backup rename. Draft #48 has staged-wire/new/same-seed/cross-seed/D7 A/B/negative test; **run that before altering production SaveService**. Historical fixture directly changes a generated D7 recruit's `aptitude=0`, a plausible but **not yet confirmed** foundation integrity cause.

**GUI-01:** Main playable `Run-PVE-Play.cmd` uses a 130-disciple synthetic QA save; it is a usable integration trial **not proof of natural progression**. Latest owner checkpoint explicitly `PLAYABLE_BLOCKED` after Windows frame capture timeouts. Measure normal GUI both profiler OFF/ON on identical seed/steps, 15s production, team picker, 30–60s PvE/camera/commands, Save/Return, 10s post-return. Require exact SHA, GUI 1280x720, process exit, top frame spikes, P50/P95/P99, 1%-low FPS and RAM. Do not use MovieWriter FPS.

**QA-LAUNCHER-01 (confirmed code defect; QA-only fix committed on THIS audit branch):** `Run-PVE-FPS-QA.cmd` created timestamped `TMB_LOG` and computed exact SHA via Git but passed a fixed filename `normal_gui_<logger>.godot.log` to Godot, risking log overwrites; also the SHA variable must propagate to process with a fail-closed check. The audit branch uses the timestamped variable as `--log-file` and rejects missing Git SHA. This change has **NOT** been Godot-tested or merged. Runtime `pve_playable_perf_probe.gd` already records `phase_summary` with full `frame_gaps_ms`; use them for exact per-phase percentiles, never average 3s-window percentiles.

### G1 / P1 — Deterministic PvE movement and measurable stutter

**MOVE-01:** AUX-02 actual 1,744 checks found C17 sub-cell stall: (96.35806,168.0268) -> (96.5,168.5) is inside one cell but gap 0.494 > release threshold 0.45; BFS returns [] for same cell. Draft #46 contains proposed safe within-cell movement + targeted Save/Restore regression. **Godot on fix SHA pending**.

**MOVE-02:** AUX-02 found `MapBattleV2.order_group_move` could assign 3 destinations among six due to blocked-offset snap. P3.2 production handler uses separate six-slot algorithm and already demonstrated 6 unique destinations /2.83 min separation; don't mislabel this as confirmed physical-mouse bug. Draft #47 stages distinct walkable slots atomically with fail-closed regression. Shared file with #46; merge hunks only in temporary integration QA branch.

**ZONE-01:** AUX-02 full harness injected six move orders BEFORE combat and then reported `defeat, kills=0, camp=C01, injury_valid=true`. This is **not equal combat fixture** to original Codex active 9-kill short run; it does not prove a zone-hop regression. Keep full long-run zone/kills/injury gate red until a controlled same-state scenario reaches its intended transition.

**PERF-01 (source-backed hotspot candidate, NOT measured root cause):**
- `MapBattleV2.step` every 0.25s loops alive actors; within each actor `_count_alive` scans all actors, `_nearest_enemy` allocates/sorts `actors.keys()` and scans; `_world_path` BFS explores up to 192×192 cells on a path request. Enemy pursuit and waypoint movement can repeat these operations while positions change. With max 30+40 actors, the scaling concern is real; don't claim it caused observed 149ms spikes without trace.
- `_refresh_multicamp_hunt_panel` calls `HuntingPveRunV2.resume_active` -> `MapBattleSnapshotV2.load`, map `prepare_world`, and `show_open_world_snapshot`; cadence was reduced to 1s in latest feature. Saved snapshot must be decoded for authority, but presentation may cache **read-only snapshots keyed by persisted snapshot identity/version** only after exact determinism tests. A stale view must never become gameplay authority.
- Test CPU attribution with detailed profiler OFF/ON, source-map identity, no other Godot GUI on 8 GB RAM. Only if evidence ties spikes to a caller: batch/cached path requests with deterministic invalidation; precomputed sorted IDs/live counts per simulation step; zero gameplay order/outcome/RNG changes; test same-seed A/B 30×40 and 20-zone geometry and Save/Load.

### G2 / P1 — Reward/production progression before new combat content

**LOOT-01:** `HuntingPveRunV2._advance_open_world` reports `loot_disposition:LOOT_PENDING` and `rewards_granted:false`; `PveMultiCampPopulationV1.acknowledge_no_reward_receipt` explicitly closes slot without paying loot. This is deliberate current design. Before enabling drops, owner must approve species/tier/camp->material tables, receipt IDs and settlement anti-replay, stock caps/economy sinks, sample 1h/6h/24h simulations; regression duplicate kill/return/offline + unclaimed pending. No hypothetical XP/drops minted.

**FORGE-01:** Verify P2.6 legacy EquipmentSystem vs actual canonical P3.7 Warehouse and new Forge R1. Draft design specs and old EquipmentSystem are not evidence that Forge R1 GUI and materials transaction integrate now. Recommend minimal real one-recipe vertical loop with exactly-once material sink and single equip slot *only after loot/economy design approvals*.

**PRODUCTION-01:** Keep good Source A production renderer and bounded four worksite progress cues. Before x100 rebalance, quantify produced/hour, wage, warehouse reserves, inventory full, XP and game time; distinguish Economy-A currently merged from separate Economy-V2 stacked DRAFT proposals. Never silently activate mass production caps without a protected save migration.

### G3 / P2 — Maintainability and repository stewardship

**TECH-01:** 6,074-line P3.2 view, 1,588-line BuildingSystem and multiple nested authority adapters make regression hotspots easy to miss. After Playable and SaveService gates pass, extract read-only presentation components/formatters first under snapshot equivalence tests; don't reimplement renderer or simulation ownership in UI.

**DOC-01:** `README.md` and parts of handoffs contain historical version commands; 39 live drafts spread authority. Add a **one-page status/entrypoint index** with exact branch SHA, ready/blockers, player vs QA launcher, stable PR links. Keep historical docs as archive, not delete; `CURRENT_CHECKPOINT` remains append-only official record until owner-approved governance change.

**REPO-01:** `outputs/` and `godot/outputs/` account for ~74.7 MB tracked file bytes of the ~116.4 MB tree. Classify QA seed (required), validated manifest, source proof screenshots (keep), transient repeated logs and video (candidate archival). Plan proof bundle + SHA256 + retention matrix first; no deletion, no `git gc`, no forced history rewrite, no removal of user asset rights or E: files.

**LAUNCH-01:** `endgame_live_launcher.gd` accepts roster 130/200/500, but current checked Git tree contains only `godot/qa/endgame_qa_save.json`; its 200/500 paths `qa/endgame_qa_save_200.json` and `_500.json` are absent. **This is a source-level missing-fixture warning, not proof that externally generated/local seeds don't exist.** Fail cleanly and avoid representing those sizes as ready. Main `Run-PVE-Play.cmd` uses 130 regardless.

## 3. Prioritized proposal tickets (none auto-merged)

| ID | Priority | Proposed next work | Owner/overlap | Required PASS gate |
| --- | --- | --- | --- | --- |
| G0-01 | P0 | Classify SaveService error 1 via PR #48 A/B; if fixture-invalid fix fixture only | QA lane, Save authority guarded | D7 natural/zero aptitude, same/cross-seed, invalid stage, backup, recovery, unchanged gameplay |
| G0-02 | P0 | Measure PvE Windows physical mouse + FPS ON/OFF; QA launcher uniqueness patch | Codex primary + owner physical input | Exact-SHA, phase summaries, real screenshot/video, no GUI capture errors |
| G1-01 | P1 | Verify PR #46 C17 and #47 unique formations in combined scratch worktree | Single Combat V2 integration owner | Both new regressions, AUX-02 20-zone, PvE 6v10, Save reload |
| G1-02 | P1 | Test equivalent controlled 20-camp zone hop/defeat/Injury120 | PvE world QA | Authentic HP0/kills/zone/settlement, no fabricated rewards |
| G1-03 | P1 | Profile pathfinding and snapshot decode before caching/optimizing | Combat V2 perf + presentation separate | Same-seed replay parity and frame-spike measurement, 30v40 max |
| G2-01 | P1 | Design and approve per-monster loot transaction V1 | Economy/Combat cross-owner, design first | Loot source tables, canonical warehouse ledger, no duplicate replay, no softlock |
| G2-02 | P1 | Check producer economics 60/90/180min and caps/wages/warehouse | Economy research | 1h/6h/24h offline/online equivalence, full inventory, ledger invariants |
| G3-01 | P2 | Split read-only P3.2 view code after baseline | UI only | Pixel/behavior regression, 1280x720 / touch, no renderer rewrite |
| G3-02 | P2 | Clean status entrypoint and archived evidence manifest | Docs/tooling only | No history deletion, SHA manifest, no changes to production resources |
| G3-03 | P2 | Physical Android touch/memory regression | Owner device | Real APK evidence, Save/relaunch and landscape touch |

## 4. Integration control

- Read `AGENTS.md`, game architecture authority, current handoff and current **remote** SHAs before coding.
- Single write owner per shared core file; separate temporary worktrees. On 8 GB RAM run one Godot GUI/headless suite at a time.
- `main`, Codex feature branch and all 39 Draft PRs remain unmerged until targeted gates and owner approval.
- Merge conflicts are not resolved by deleting tests, replacing warehouse/clock authorities, or changing Source A visual style.
- Follow `docs/operations/TMB_2026-10-27_ONE_SESSION_WINDOWS_EXECUTION.md` for the morning sequence and exact evidence requirements.
