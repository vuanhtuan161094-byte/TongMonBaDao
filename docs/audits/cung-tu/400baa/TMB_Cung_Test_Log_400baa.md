# Cung Tu test log — 400baa patch branch

## Status

**NOT_RUN.** No Godot 4.7.2 import, compile, headless test, Windows gameplay or Android QA was launched from this task. There is no PASS result.

## Environment gate

The current integration checkpoint and next-chat handoff at HEAD `400baa11403720fb816075d65f3cb74e8f4ad505` state that Godot PID `15996` belongs to the active Codex 1 QA session, process ownership could not be established, available RAM is low, and a second Godot instance must not start. No process was terminated. This branch contains test source and static inspection only.

No process was terminated. This branch contains test source and static inspection only. A pre-handoff compare found live integration HEAD 79dab92ccc95a93b39dcb563fe06c93a9aa422da; its only change after 400baa is godot/tests/presentation/hs09_disciple_profile_test.gd, so no Cung source/test path overlaps.

## Test inventory

| Test | Intended coverage | Result |
|---|---|---|
| `v63_cung_world_mobility_test.gd` | Three realm IDs; path reachability, blocked-cell collision, speed-bounded movement, snapshot and disconnected route | NOT_RUN |
| `v63_cung_line_range_test.gd` | Divine B + rare B line resolve and cast range; numeric HP delta | NOT_RUN |
| `v63_cung_heal_target_test.gd` | Full-HP no-cast/cooldown; injured ally positive heal and HP delta | NOT_RUN |
| `v63_cung_full_combat_matrix_test.gd` | 183 IDs; per-skill impact/effect; passive/innate stat delta; AoE, cooldown, projectile timing, snapshot, AI rotation, kill receipt | NOT_RUN |
| `v63_cung_six_disciple_pve_test.gd` | Six mixed-generation/lineage disciples; snapshot, casts, positive target HP deltas, multi-skill AI | NOT_RUN |

## Static checks completed

- Compared old audit HEAD `095ff2f90df8260dd123c06964d20c4f9b571d32` with live integration HEAD `400baa11403720fb816075d65f3cb74e8f4ad505` before patch creation.
- Reviewed world navigation/path semantics and fixed the three mobility branch cases without changing shared MapBattleV2.
- Added exact-ID line-range resolution for the two Liệp Ảnh Divine B skills without changing catalogue balance.
- Added heal target filtering for full-health allies.
- Preserved original audit artifacts unchanged and prepared a row-preserving 183-ID coverage update.
- Reviewed test source statically. Static review is not a Godot parser/compiler result.

## Remaining gates

Run Godot import/compile and the five tests sequentially only after the active Codex 1 Godot session is released. Then run current PvE adapter + save/reload and required Windows/Android visual gameplay QA. Record each command, Godot version, source SHA, exit code and log. Do not mark Cung Tu DONE until these owner-required gates and functional evidence pass.


