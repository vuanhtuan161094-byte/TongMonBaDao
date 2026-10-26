# PVE-PLAY-01.1 — Static stutter hotspot audit, exact source `b91d60a`

**Status:** static code finding only. No Godot profiler trace was run here, so the following is a **measurement hypothesis, not a confirmed source of the user's hitch**. The Windows Codex session owns runtime fixes; do not overwrite its local edits.

## Confirmed recurring work (source references)

1. `godot/src/presentation/p3_2_landscape_sect.gd:3165–3184`: while the hunt overlay is open, `_process()` calls `_refresh_b3_hunt_panel()` every `B3_HUNT_REFRESH_SECONDS=0.25`. Its existing optional `performance_hunt_refresh_usec_max` can be compared against top frame spikes.
2. Same file `:4231–4276`: multicamp refresh calls `HuntingPveRunV2.resume_active(state, encounter)` and `b3_pve_world_view.prepare_world()`; topology is cached by Source A identity on Codex b91, but the **battle restoration is not bypassed**.
3. `godot/src/simulation/combat/hunting_pve_run_v2.gd:790–796,842–900`: `resume_active` invokes `restore_state`, which decodes battle payload, calls `HuntingMapV2.spawn` and runs `PveMultiCampPopulationV1.verify_structure`.
4. `godot/src/simulation/combat/map_battle_snapshot_v2.gd:69–119`: the read path runs `Marshalls.base64_to_raw`, `bytes_to_var`, `MapBattleV2.new`, `world_navigation.duplicate(true)`, and navigation validation.
5. `godot/src/simulation/combat/pve_multi_camp_population_v1.gd:202–226`: the registry validation iterates all 20 camps and all per-camp slots on restore.
6. `godot/src/presentation/p3_2_landscape_sect.gd:4325+`: `_set_hunt_presentation_layout(true)` is also called every hunt HUD refresh, repeatedly assigning anchors/styles/text. `pve_sect_world_view_v1.gd:171–196` duplicates visual rows and queues overlay redraw on every snapshot.

**Performance hypothesis H1 (highest priority to *measure*):** repeatedly rehydrating a whole authoritative 192×192 PvE battle *for display* at up to 4 Hz may still cause large allocation/validation spikes even after topology/minimap caching. This is not evidence that `resume_active` is incorrect: restoration is essential on Save/Load and currently preserves validated identities.

## Profiler isolation

- Timestamp separately: `resume_active` (including decode), `prepare_world` cache hit, `show_open_world_snapshot`, `_set_hunt_presentation_layout`, 250ms HUD full refresh.
- Correlate measured stage durations with GUI frame-time top spikes (timestamps and phase); log top 5 and count >33.3/50/100ms. Do the same 15s sect, 30–60s PvE, Save/Return 10s with instrumentation OFF/ON.
- Inspect Godot built-in script/process/render profiling and CPU/GPU upload as available. A slow HUD call implicates CPU; an unrelated render/GPU stall must be investigated separately. Instrumentation itself can cause stalls (the QA `pve_playable_perf_probe.gd` flushes log output every 3 seconds).
- Only after evidence, consider reusing a *read-only current-session snapshot* or reducing repetitive cosmetic work while ensuring canonical Combat V2 owner clock and SaveService remain unchanged. **Do not cache a stale battle snapshot across battle ticks or skip identity validation for actual Save/Load.**

**No code modifications recommended without normal-GUI profiler evidence on Codex's next exact SHA.**
