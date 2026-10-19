# C4-BE01 — REAL HUNT GATE + MAX-LAB IMPLEMENTATION (2026-10-19)

**Status**: CODE WRITTEN on isolated branch; **Godot 4.7.2 official focused tests, 1280×720 and Android OWNER acceptance PENDING**. This is NOT a full-acceptance PASS. Owner explicitly authorized P0 real hunting integration and requested every test exercise max legal scenarios on 2026-10-19.

**Base**: `c4-jx1-rank-and-fx-source-20261019` at `f757c5f162f85ebccda936b06ba8a06b07eac003`; `main` observed `461caca1171462e0da092f21108c5c1733157ad9`. Code branch `c4-be01-live-hunt-maxlab-20261019`. Rollback is returning to base commit; no cherry-pick/merge into main until gate passes.

## CODE allowlist / ownership

- `godot/src/presentation/p3_2_landscape_sect.gd`: existing **Thế Giới** button opens the real expedition panel rather than the previous gate information notice; base SectMap environment/PR20 not otherwise edited.
- `godot/src/presentation/p3/hunting_expedition_entry_v2.gd`: *read-only* real V2 roster + canonical source realm/monster identity bridge, six-per-team grouping, stable collision-safe encounter identifiers.
- `godot/src/presentation/p3/hunting_expedition_screen_v2.gd`: actual choose region & map difficulty, max 30 eligible disciples, call `HuntingPveRunV2.begin/advance/finish/claim/resume_active`, view authoritative BattleWorldLayerV2, explicit `LiveGameRuntimeV2.save` on start/step/settle/claim/exit. **No GUI timer**; progress triggered by user via 10-tick or resolve-battle buttons, so there is no independent second combat scheduler. The mode is an integrated, manually controlled **first gameplay slice**, not the final unattended hunt simulation.
- `godot/tests/simulation/c4_be01_real_hunt_e2e_test.gd`: real generated V2 recruits in disposal factory state, inject temporary MAX QA values, all P2 skill IDs marked learned **only in that fixture**; stage5 → start → snapshot → replay → settle → once-only warehouse receipt → save/load receipt.
- `godot/tests/simulation/c4_be01_max_30v40_stress_test.gd`: exact max 30 disciples/40 monsters, 30/10 Tu Vi **and** Luyện Thể, five six-person groups, full legal 4 pilot slots/member covering all 5 source IDs, all 5 roots at 100, seeded view/offscreen deterministic match, mid-battle snapshot, 70-actor presentation hookup, terminal replay and bounded AoE/event journal.

Prohibited: all `godot/src/simulation/combat/`, `SimulationState`, `SectState`, `DiscipleState`, `SaveService`, `LiveGameRuntimeV2`, `SimulationScheduler`, RNG, Economy, Injury rules, PR20, and `main`. No new accuracy/evasion or auto-dodge, fake HP or synthetic world rewards.

## Important truth about max tests

Maximum legal P2 combat skill ownership is not the same as **4 active pilot slots**. These are two disjoint fixture channels: E2E test temporarily marks every known P2 skill as learned in isolated P37Factory state; the existing production V2 battle presently only executes the authored `effect=damage` consumers, others stay deferred. MAX-LAB 70-actor fixture fills exactly four explicit JX pilot skills per actor and cycles the fifth across the group, never violates `mixed_pilot_and_learned_active_slots`. It must not secretly teach these skills to real recruits. The production HuntingMapV2 authoring currently spawns at most **7** enemies on local difficulty 5; the 40-monster test is intentionally an independent stress lab against MapBattleV2.MAX_MONSTERS, not a false fifth-level hunting spawn.

## Guardrails / known limitations

1. The entry displays only genuine, complete V2 recruits with valid Tu Vi+Body tracks, living HP and no injury, PVE reservation, economy work-cycle or other reserved facility/plot. Legacy founders do not receive invented 30x10 cultivation automatically. Existing valid V2 equips are preserved by `DiscipleCombatLoadoutV2.build`; backend can reject further invalid occupation/room constraints.
2. MapBattleV2 authoritatively owns fight; HuntingPveRunV2 owns injury 0/1/120 recovery and warehouse exactly-once. UI is not an independent owner. Every action immediately requests save; reported SAVE ERROR blocks exit and warns rather than claiming persistence.
3. An active saved encounter is automatically resumed if the canonical snapshot is valid. Invalid snapshots are not deleted/replaced with a fake blank battle.
4. The GUI has manual 10-tick / finish controls, not real-time autonomous map hunt. Cross-screen continuous simulation/offline hunting and inherited scheduler can be implemented only after an owner-approved integration with one canonical time owner.
5. MAX-LAB checks correctness at full population; **real Android frame rate and memory performance are unmeasured** until physical device testing. UI crowd readability (70 full nameplates) requires visual acceptance.
6. Source JX1 visual/skill gap (#15/#159 incomplete clips, cast FX mappings, native font parity) remains from C4 pilot; no impact on canonical hunting payouts.

## Focused official Godot 4.7.2 QA plan (no CI, no FULL)

1. Run editor `--headless --editor --path godot --quit` in isolated clone and custom `user://`; fail on GDScript parse/warnings.
2. Run `res://tests/simulation/c4_be01_real_hunt_e2e_test.gd` and `res://tests/simulation/c4_be01_max_30v40_stress_test.gd` on exact commit.
3. Adjacent baselines: `dv2_02_five_level_pve_test.gd`, `dv2_02_group_map_battle_test.gd`, `dv2_02_battle_snapshot_test.gd`, `c4_jx_pilot_effects_test.gd`, `c4_gp01_combat_feedback_receipts_test.gd`.
4. Manual user:// isolated, 1280x720: World → map tier → select genuine V2 recruits → start → 10 ticks → exit/reopen → continue → resolve → claim → verify stock changes, duplicate blocked → save/reopen. Repeat with injured/work-assigned/uninitialized disciples to ensure fail closed.
5. Physical Android: 70 actors, nameplate density, memory, latency and accurate camera; no fabricated PASS until owner logs.

**Evidence to date:** GitHub connector file writes completed; JavaScript static readback checked syntax bracket/quote balance for 5 modified GDScript files and 10 source contracts, without Godot runtime. `main` and original C4 branch unchanged; official Godot tests remain PENDING.

## Next implementation

Do not migrate RNG for Accuracy/Evasion until separately authorized GP02-STAT with snapshot backward-compatibility. Do not silently move the 0.25-second fight into the one-minute economy scheduler. Do not increase monster counts in HuntingMapV2 to 40 simply to satisfy QA; an independent max-lab already does that.
