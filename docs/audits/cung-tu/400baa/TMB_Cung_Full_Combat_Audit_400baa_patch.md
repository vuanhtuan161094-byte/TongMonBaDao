# Cung Tu — patch and QA status on 400baa

**Status: PATCH CODED; GODOT RUNTIME NOT_RUN; CUNG TU NOT DONE.**

## Scope and baseline

- Repository: `vuanhtuan161094-byte/TongMonBaDao`
- Target: `integration/one-game-v65-20261030`
- Prior audit baseline: `095ff2f90df8260dd123c06964d20c4f9b571d32`
- Live integration HEAD before this patch: `400baa11403720fb816075d65f3cb74e8f4ad505`
- The baseline-to-live comparison was completed before creating the patch branch. The four intervening commits were HS-09 documentation/presentation/radar/test changes; Cung Combat V2, map combat, PvE adapter, save and P3.2 paths were unchanged.
- Dedicated branch: `codex2/cung-tu-fix-qa-20261031`
- The three audit artifacts from 095ff2 were uploaded unchanged to `docs/audits/cung-tu/095ff2/`. This preserves the original report, 183-row CSV and audit harness as historical evidence.

- Latest check before handoff: live integration HEAD is d921b082f831d60c6827e0a147600566f87fddc9. Since patch base 400baa, 79dab changes only godot/tests/presentation/hs09_disciple_profile_test.gd, 07d8 changes only CURRENT_CHECKPOINT.md, and d921 changes only NEXT_CHAT_HANDOFF.md. None overlap Cung runtime or tests. Integration QA reports 14 unrelated focused tests PASS at 79dab; New Game GUI PID 8136 remains open and real gameplay capture is pending. These are not evidence for this Cung patch. Codex 1 must review/apply against live d921.

## Source findings and code changes

The first three BUG IDs concern the same rule: mobility was explicitly rejected when `battle.world_mode` was true. Inspection of MapBattleV2 showed that world movement already uses an authoritative navigation grid: world bounds are checked, blocked cells reject movement, and deterministic BFS returns walkable cell paths. `_move_world_actor` advances by at most `move_speed * STEP_SECONDS`. Actor-to-actor collision avoidance is not part of that grid path contract.

The Cung patch routes world mobility through that existing path system. It requires a nonempty valid navigation grid; the BFS route must exist, exceed current attack range and remain within the skill's declared range. It schedules a path-following move order, evasion time, cooldown and a `v63_mobility` event. A disconnected route is rejected. This avoids direct teleporting and does not edit MapBattleV2 or P3.2.

For Liệp Ảnh's Divine B and rare B ultimates, catalogue cast range is 8.96 while line radius is 5.76. The resolver previously used radius as line length after the cast had already passed the range check. The patch carries range in the cast record and uses it as the resolve length only for those two exact IDs. Catalogue radius, ratio and other balance data are unchanged.

The prior audit also identified Linh Tiễn active_02 as a likely zero-heal cooldown use. The support-target selector now excludes full-health allies for heal effects. A regression test checks both the no-cast/no-cooldown full-party case and positive heal amount plus ally HP gain when injured.

Production code changes are limited to:

- `godot/src/simulation/combat/v63_human_skill_combat_system.gd`

Patch commit: `b5471633f485d65dccebec730910f9387b5dc756`  
New source blob: `c0690d3ca808525ad9707ae46127818c568783e0`

No balance coefficients or catalogue rows were changed. ONE GAME, MapBattleV2, HuntingPveRunV2, SaveService, P3.2 and presentation source were not modified.

## Coverage status

Updated CSV: `docs/audits/cung-tu/400baa/TMB_Cung_Skill_Coverage_400baa_patch.csv`

| Current label | IDs | Meaning |
|---|---:|---|
| PATCHED_NOT_RUN | 6 | Five confirmed audit BUG IDs plus the Linh Tiễn heal defect have a static patch and focused test source; runtime is unverified. |
| PARTIAL | 52 | Prior partial evidence retained; full per-ID functional proof remains outstanding. |
| NOT_TESTED | 125 | Prior status retained for all other IDs without sufficient evidence. Absence of evidence is not being reclassified as a bug. |
| VERIFIED | 0 | None satisfy the complete runtime proof bar. |

The six PATCHED_NOT_RUN IDs are three Human/Immortal/Divine mobility IDs, Liệp Ảnh Divine B and rare B ultimate, and Linh Tiễn Human active_02. The row-level test mapping and original audit status are preserved in the updated CSV.

## Added regression and matrix tests

All new tests are committed to the dedicated branch, but none have been executed:

- `v63_cung_world_mobility_test.gd`: all three realm mobility IDs; valid route around a wall, per-step blocked-cell/speed checks, snapshot restore and unreachable-route rejection.
- `v63_cung_line_range_test.gd`: both Liệp Ảnh B ultimates; target beyond radius but inside range takes HP damage, target beyond range is not cast/hit.
- `v63_cung_heal_target_test.gd`: full-health team does not consume the heal/cooldown; wounded ally receives positive healing and HP increases.
- `v63_cung_full_combat_matrix_test.gd`: expected counts for all 183 Cung IDs (81 active/ultimate, 81 passive, 15 innate, 3 basic, 3 mobility); per-action archive/learn/equip and effect evidence; passive/innate effective-stat deltas; cast/release hit, HP damage/heal, mark, AoE limits, cooldown schedule, projectile travel deadline, snapshot round-trip, multi-skill AI rotation and a continuous-battle skill kill receipt.
- `v63_cung_six_disciple_pve_test.gd`: six-member mixed Human, Immortal A/B and Divine A/B-rare battle; personal action loadouts, snapshot restore, positive skill HP deltas and AI use of more than one skill.

The existing D4-A PvE regression remains relevant prior evidence: six Human Liệp Ảnh disciples use one learned/equipped active_01 through a boss encounter and PvE adapter. It does not establish the full realm/lineage matrix and was not rerun on this patch.

## Static/mechanism gaps versus evidence gaps

**Confirmed code defects, now patched statically:** the five mobility/line-range BUG IDs, plus the full-health heal targeting defect. Their fixes still require Godot regression evidence.

**Mechanism present but not fully verified:** projectile speed currently contributes to the cast's release deadline; the combat kernel does not provide a separate simulated projectile object in the path reviewed here. The matrix checks cast-to-release travel timing. Real projectile/VFX animation and HUD feedback require runtime/presentation QA.

**Evidence still missing:** all 183 IDs need the matrix run and review; 177 rows retain their prior PARTIAL/NOT_TESTED status. Six-disciple mixed loadout, kill receipt, current PvE adapter, save-return-reload, New Game journey, Windows/Android gameplay, visual VFX and owner acceptance are not proven by static review.

## Test execution

**NOT_RUN — no Godot launch, compile or test PASS is claimed.**

The latest integration checkpoint (HEAD 07d8b211) records official Godot 4.7.2 import and 14 focused tests PASS at source 79dab92, plus an open New Game GUI process PID 8136. Issue #56 also retains a report of unknown Godot PID 15996. Neither run includes this Cung patch. In accordance with the user instruction, this task did not launch a second/heavy Godot session. Resume the focused gates only after Codex 1 releases or coordinates the open session; capture engine version, exact source SHA, command, stdout/stderr and exit code.






