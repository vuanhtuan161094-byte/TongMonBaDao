# PVE-PLAY-01.1 — Low-level six-person formation slots must be unique

**Source baseline:** `feature/pve-jx-continuous-world-20261026` at `6b3fd181392c96c2386e5aa85950d2e993d67dda`. Parent #37, AUX-02 #42. **Independent GitHub-only patch, QA pending.** This packet is separate from Draft PR #46 (C17 same-cell movement and SaveService diagnostic).

## Confirmed prior evidence
AUX-02 Windows Godot 4.7.2 tested `MapBattleV2.order_group_move` at real Source A click cell (92,68). Six participants were assigned only **three distinct destinations** after `_nearest_walkable_cell` resolved blocked formation offsets. This is a low-level API issue. The *production* P3.2 click handler has a separate six-slot allocator and its existing integration test verified six unique destinations with minimum spacing 2.83. Do **not** report a proven physical-mouse click duplication until a real GUI trial says so.

## Patch
- `godot/src/simulation/combat/map_battle_v2.gd`: when assigning a low-level world group move, reserve previously selected grid cells, choose nearest *unreserved* valid tile using deterministic ring order (existing neighbor priority), stage the complete requested formation, then atomically write six orders/events. Insufficient walkable tiles return `move_formation_has_insufficient_walkable_cells` **without modifying any actor orders or writing partial events**. No damage, HP, time, loot, Injury, SaveService, or renderer changes.
- `godot/tests/simulation/pve_group_move_unique_formation_test.gd`: synthetic 12×12 navigation with five blocked formation offsets, six authentic V2-compatible dictionary participants, determinism on replay, distinct passable goals, Save/Load preservation, and fail-closed with only two walkable cells. **Source A asset fidelity is not claimed by this synthetic test.**

## Run after taking a safe isolated Windows worktree
```powershell
E:\Godot_v4.7.2-stable_win64_console.exe --headless --path godot --script res://tests/simulation/pve_group_move_unique_formation_test.gd
```
Expected print marker: `PVE FORMATION UNIQUE: PASS`, exit 0. Also rerun current AUX-02 20-zone QA test from its isolated branch after **selectively** applying this fix and C17 fix (Draft PR #46). No merge into active Codex worktree/main without explicit approval.

**Status:** SOURCE_PATCHED / GIT_COMMITTED / GODOT_4_7_2_NOT_EXECUTED / REAL_MOUSE_NOT_TESTED / INTEGRATION_DEFERRED.

## Important integration note
This patch modifies `MapBattleV2.order_group_move` while Draft PR #46 modifies `MapBattleV2._move_world_actor`. Both are intentionally based on the same immutable Codex checkpoint; one cannot claim coverage by the other. On eventual integration review, reconcile these disjoint hunks against the latest Codex HEAD, run the new C17 and group unique tests together, and compare full AUX-02 contract failures. Keep the overall 6v10/Save authority unchanged.
