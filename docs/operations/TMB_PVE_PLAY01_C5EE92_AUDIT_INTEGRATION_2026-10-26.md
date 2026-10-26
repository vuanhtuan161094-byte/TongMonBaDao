# TÔNG MÔN BÁ ĐẠO — PVE-PLAY-01 checkpoint audit / selective integration

**Date:** 2026-10-26  
**Owner-requested reviewed checkpoint:** `c5ee92ed714b2fda8b15b6d6be52fd6a11ac1490` (Codex branch `feature/pve-jx-continuous-world-20261026`).  
**Additional checked Codex checkpoint:** `b91d60a66fd5afc94be8ce1b6b16fad81d3b3f6a` (contains SAVE identity guard/test; this is the immutable BASE of this audit integration branch).  
**Status:** GITHUB SOURCE-REVIEW + CODE COMMITTED; GODOT 4.7.2 NOT RUN; GUI FPS/VIDEO NOT VERIFIED HERE.

## Independent package reconciliation

| Independent source | Overlaps checkpoint | Decision |
|---|---|---|
| PERF-01.1 `2b455682`: navigation/topology/minimap caching; Source A clip timing; pve events | Codex now has `PveSectWorldViewV1` cached SHA/map, `topology_build_count`, `minimap_build_count`, immutable actor mesh culling, atlas `_clip_cache` and `_resolved_clip_cache`, one-pass VFX event adapter in live renderer. | **DO NOT cherry-pick old renderer/atlas**; doing so loses newer culling/JX timing. Remaining identified visual defect (restarting death clip) is fixed here as a minimal two-hunk change instead. |
| SAME-CLOCK-01 `7038e878`: old GUI harness used `visual_session.advance(true)` outside runtime owner | Still present in c5 test after Codex extensive GUI/VFX changes. New harness also calls OS time for terminal Save after manually injecting future runtime seconds. | **PORT SEMANTICS ONLY** into newer GUI harness: `runtime.poll(last_wall+1)` (4 * 0.25s Combat V2 frames), restore the active session after each poll, assert battle seconds == wall seconds, same-wall zero frames, durable SaveService battle clock/minute_phase parity, and terminal `runtime.save(state.runtime_last_wall_unix)`. Keep Codex's dedicated VFX screenshot/comparison code. |
| PVE-SAVE-01 `c90ab907`: cross-check source-map identity between battle navigation and spawn slots | Incorporated already into Codex checkpoint **b91d60a6**, including `pve_open_world_save_identity_contract_test.gd`. | **DO NOT port duplicate**; verify exact test at integrated SHA. No further changes to HuntingPveRunV2/SaveService in this branch. |
| PERF-02 `8c0582be`: normal GUI profiler | Codex has `Run-PVE-Play.cmd` and `TMB_PVE_PERF_LOG` but no phase-separated 3-sample FPS/p95 JSONL monitor or one-click independent FPS launcher in c5. | Add **QA-only** FPS files, *without replacing* the Codex playable launcher: `Run-PVE-FPS-QA.cmd`, `pve_playable_perf_launcher.gd`, `pve_playable_perf_probe.gd`, pure stats test and .gitignore rules. |

## Additional two code-reviewed defects (Codex checkpoint)

### VFX restore replay when rolling history is DISJOINT
`PveJxSwordVfxAdapterV1._suffix_prefix_overlap()` previously looped down to **amount = 0**, so it always returned >= 0: the `overlap < 0` branch in `observe_snapshot` intended to establish a new baseline **could never execute**. A replaced same-encounter ring was treated as fully fresh cast/hit events, risking fake JX sword VFX after restoring history. Fixed by returning `-1` when *both* signature arrays are nonempty but have no real suffix/prefix overlap; still return 0 for truly empty baselines (needed to observe the first authentic live cast). Focused regression extends `pve_jx_sword_vfx_adapter_test.gd`: swapped saved ring causes **zero** new casts/impacts, the following real appended cast yields one cue, and actual suffix overlap remains 1. Combat V2 events/damage unchanged.

### Source A death animation continually restarting
`SectIsometricWorldV1.set_pve_snapshot()` assigned `{"action":"die","started":pve_clock}` on **every 250 ms GUI snapshot** if HP<=0, preventing native death animation from reaching its later frames. Fixed to set `started` only upon entering the dead state; a genuine `downed` event still takes precedence. Also clear cosmetic actor position/cue dictionaries when `encounter_id` changes to prevent interpolation from stale death/position state. Focused test: `pve_sourcea_death_snapshot_contract_test.gd`.

## Combat V2 / clock / Save authority boundary

- No change to `MapBattleV2` damage, skill policies, HP0 journal, 0.25s step, or monster spawn; VFX only responds to existing Combat V2 events.
- No change to `SimulationRuntimeOwnerV2`, `SimulationRuntimeClockV2`, `SaveService`, injury 0/1 recovery 120, canonical warehouse or exactly-once claims.
- GUI harness changes only QA progression and injected timestamp; production P3.2 still uses real wall clock. The GUI visual capture may now observe 4 Combat V2 frames per injected second (rather than one direct frame). Capture precise JX render moment must still be visually verified in Windows Godot.
- `HuntingPveRunV2.saved_world_identity_matches` already included by Codex in `b91d60a6`; test on final integration.

## Windows 8GB integration / acceptance

This is an independent integration branch, not the active dirty Codex Windows worktree. **DO NOT cherry-pick/merge it blindly** while Codex is still writing local changes. At a safe checkpoint:
1. Record dirty `git status`, exact HEAD, branch, capture local backup; compare this branch against the newest Codex branch and manually port only missing hunks.
2. Headless official Godot 4.7.2: 
   - `res://tests/presentation/pve_multicamp_p3_2_live_integration_test.gd`
   - `res://tests/presentation/pve_jx_sword_vfx_adapter_test.gd`
   - `res://tests/presentation/pve_sourcea_death_snapshot_contract_test.gd`
   - `res://tests/presentation/pve_perf_probe_contract_test.gd`
   - `res://tests/simulation/pve_open_world_save_identity_contract_test.gd`
   - `res://tests/simulation/dv2_03_runtime_clock_test.gd`
   - `res://tests/simulation/dv2_03_live_runtime_integration_test.gd`
3. Live **real** P3.2 GUI: six real V2 disciples in Thanh Trúc Lâm, 10 actual monsters, click-to-move, real cast/positive hit/JX #158 impact, return sect, Save/Load, 1280x720 actual screenshots/video. Capture real GUI FPS separately from MovieWriter. Treat zone hop/Injury120 `NOT_REACHED` as unverified not pass.
4. FPS QA runner `Run-PVE-FPS-QA.cmd` uses the normal 130-disciple seed in an isolated save and logs 3-second JSONL samples in `godot/outputs/pve_perf_qa_20261026/metrics`. Keep `Run-PVE-Play.cmd` unchanged.
5. Publish exact tested SHA, logs, real screenshot/video and explicit blockers on Issue #37 before any main merge.

## Limits / risk

- No Godot 4.7.2 binary or Windows desktop graphics run in this cloud GitHub session. **All new QA tests PENDING**, no simulated PASS or claim of >30 FPS.
- The new VFX ring baseline behavior deliberately discards cosmetic effects if a whole capped ring is replaced with no overlapping events; this is safer than displaying fabricated casts. An actual single cast immediately after a discarded history still works when appended to that new baseline.
- QA injected wall seconds are deterministic only in the test and must NEVER enter the main game's runtime save path.
- Baseline was b91d60a6, not a merge into main. Re-evaluate against newer Codex commits before integrating into Windows.
