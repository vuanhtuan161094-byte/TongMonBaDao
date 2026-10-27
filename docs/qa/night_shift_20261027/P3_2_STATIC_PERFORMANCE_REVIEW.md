# P3.2 static performance review — RC tree 485d79b

Scope: static call-path review of the tracked file tree matching remote PR #52 HEAD `0bc96348e6ef1a2eb945e9713e3faeb8912fb07d` (tree `485d79b3060f22a8b552b52c3e0352f34ccaefb1`). The local staging Git HEAD is synthetic, and no Godot profiler was run in this shift. These are hotspots/suspects, not measured causal attribution for the owner’s 2.17 FPS observation.

## Highest-confidence recurring PvE cost candidate: poll → persistent save

1. `godot/src/presentation/p3_1_landscape_sect.gd:7-8,77-92,547-562` sets a one-second runtime wall-clock poll and a 15-second autosave. P3.2 delegates `_advance_simulation()` to this runtime path.
2. `godot/src/simulation/core/live_game_runtime_v2.gd:78-81` routes each poll to `SimulationRuntimeOwnerV2.update_to()`.
3. With a live multicamp, `godot/src/simulation/core/simulation_runtime_clock_v2.gd:125-165` advances Combat V2 frames and persists the current battle snapshot after each advanced frame. After the poll returns, `godot/src/simulation/core/simulation_runtime_owner_v2.gd:91-107` calls `HuntingPveRunV2.commit_owner()` once while a multicamp was or remains active.
4. `godot/src/simulation/combat/hunting_pve_run_v2.gd:523-529` calls canonical `SaveService.save_to_path`. `godot/src/simulation/save/save_service.gd:8-68` converts the whole state to a dictionary, JSON encodes, writes/flushes a staged file, parses/validates the staged save, validates the old primary when present, rotates `.bak`, then installs the new primary. `SimulationState.to_dict()` includes all roster rows (`godot/src/simulation/state/simulation_state.gd:226-230`); each disciple row copies nested fields (`disciple_state.gd:215-255`).
5. The integration test explicitly performs 50 one-second `runtime.poll()` calls (`godot/tests/presentation/pve_multicamp_p3_2_live_integration_test.gd:625-640`). That deterministically exercises many complete save/validation cycles. It is a strong explanation for a long headless wall-time test, although the share attributable to serialization, filesystem, Combat V2 and other work has not been measured.

This cadence may also produce visible PvE spikes approximately once per wall-clock second. The invariant/atomic-save contract is protected, so this report does **not** change cadence, SaveService or gameplay.

## Rendering candidates during an active hunt

- `godot/src/presentation/p3/pve_sect_world_view_v1.gd:71-99` creates the live-world `SubViewport` with `UPDATE_ALWAYS`. The world therefore has a continuous render path while the live map is visible.
- `godot/src/presentation/p3/sect_isometric_world_v1.gd:902-928,980-1015` redraws visible ground chunks, terrain/road overlays and PVE accents; it caches the static depth queue, which is good. `_draw_pve_stream()` still creates/project 63 points and issues three polyline draws each render (`:1058-1066`). The dynamic world actors are merged with the cached queue (`:1018-1043`). This could be a GPU or draw-call cost; no GPU profiler evidence was collected.
- P3.2 refreshes the open hunt panel once per second (`p3_2_landscape_sect.gd:8,3466-3482,4870-4889,4668-4713`). It restores a battle snapshot, duplicates actor view rows and pushes a new authoritative snapshot to the renderer. Existing performance counters include hunt refresh and maximum time (`:3515-3551`), making this measurable on a safe future GUI run.

## Factors that appear bounded, not primary per-frame suspects

- P3.2 deliberately avoids building a P3.1 actor-control subtree for every roster member; `_spawn_all_disciples()` records virtual destinations only (`p3_2_landscape_sect.gd:273-285`). It materializes only selected/visible actors later.
- `_sync_actor_positions()` does sort/scan the roster and calculate idle slots (`:1425-1431`), but it is called on refresh paths, not unconditionally each rendered frame. Treat its measured max from the existing logger as evidence, not its O(n) scan alone.
- The main sect `iso_viewport` is marked `UPDATE_ONCE` on refresh (`:3599-3613`) while the PvE view has its own continuous viewport; main-map and active-PvE costs should be compared separately.

## Safe next measurement (not run)

When available RAM is at least 2,200 MiB, CPU stays below 70% for 60 seconds, no Godot/asset conversion worker is active, and the owner-approved Windows session is available:

1. On an actual local checkout at exact remote SHA `0bc963…`, capture normal GUI frames with logger OFF and ON separately.
2. During each run, record the existing `TMB_P3_2_FRAME_METRIC` fields (frame p50/p95/p99 and 1%-low from passive probe, worst frame, `runtime_poll_max_ms`, `save_max_ms`, `hunt_refresh_max_ms`, `production_iso_refresh_max_ms`, actor count) and process RAM.
3. Correlate spikes around one-second polls and 15-second autosaves. Only then decide whether a narrowly scoped optimization can preserve canonical SaveService guarantees.

Current result: **STATIC_REVIEW_DONE / FPS_CAUSE_UNPROVEN / GUI_AND_FPS_PENDING**.
