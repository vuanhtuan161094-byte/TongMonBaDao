# Quyền Tu V6.5 GitHub handoff (unapplied)

Repository: `vuanhtuan161094-byte/TongMonBaDao`

Handoff branch: `codex/fist-combat-handoff-20261031`

Base at branch creation: live `integration/one-game-v65-20261030` ref `d921b082f831d60c6827e0a147600566f87fddc9` (documentation checkpoint). The latest tested ONE GAME source cited in Issue #56 is `79dab92ccc95a93b39dcb563fe06c93a9aa422da`.

## Packet contents

- `quyen_fist_v65_handoff.patch`: complete scratch production patch plus its fixture diff, kept as a review artifact; not applied.
- `quyen_183_coverage.csv`: all 183 catalogue rows (35 Human, 68 Immortal, 80 Divine).
- `quyen_fist_v65_audit_handoff.md`: source SHAs, findings, compatibility and rollback notes.
- `tmb_quyen_183_combat_handoff_test.gd`: standalone focused fixture from the patch.
- `quyen_183_test_evidence.txt`: prior isolated-harness commands, PASS markers and exit codes.

No ONE GAME production source or test path is added by this branch. No PR #52, main, SaveService, live checkout or save data is changed.

## Exact production paths inside the unapplied Quyền patch

1. `godot/src/simulation/combat/v63_human_skill_combat_system.gd`
2. `godot/src/simulation/combat/v63_immortal_skill_combat_system.gd`
3. `godot/src/simulation/combat/v63_divine_skill_combat_system.gd`
4. `godot/src/simulation/combat/map_battle_v2.gd` — shared PvE/combat adapter; Codex 1 must review it against current ONE GAME before applying.

The separate fixture path is `godot/tests/simulation/tmb_quyen_183_combat_handoff_test.gd`.

## Poison packet overlap

Compared against live ONE GAME at handoff time, the Poison handoff branch is `codex/poison-combat-handoff-095ff2-20261031`, SHA `fa0684019a17a01efe4e609a49fc1650dd8ef8c7` (merge base `400baa11403720fb816075d65f3cb74e8f4ad505`; branches diverged). Its patch changes these repository paths:

- `godot/data/combat/v63_divine_combat_catalog.json`
- `godot/src/simulation/combat/v63_human_skill_combat_system.gd`
- `godot/tests/simulation/v65_poison_combat_contract_test.gd`

The direct production-file collision is `v63_human_skill_combat_system.gd`, which both patches modify. Quyền also modifies `map_battle_v2.gd`; Poison's current packet does not, but this remains a shared integration surface and must be checked against the live combat adapter. `v63_immortal_skill_combat_system.gd` and `v63_divine_skill_combat_system.gd` have no path collision with this Poison patch. Poison's Divine catalogue annotation is a distinct path; preserve and test it when combining data changes. Its test file is separate from the Quyền fixture.

Codex 1 owns integration. Check each patch against the actual live tree, apply one at a time, inspect the resulting diff and ownership, and run tests on the exact combined SHA. Do not overwrite either runtime change.

## Truthful test boundary

The 183-row CSV plus fixture confirms dispatch/coverage for the catalogue records and exercises selected actual effect paths. It does **not** establish 183/183 independent per-skill behavioral PASS. Earlier Godot 4.7.2 focused scratch tests passed on an isolated harness based on source `095ff2f90df8260dd123c06964d20c4f9b571d32` with audited combat/catalogue overlays. They were not run on the current integrated SHA `d921b082f831d60c6827e0a147600566f87fddc9`.

The Kim Cang guard path currently reduces damage through CombatStatsV2. The approved finite shield, one-hit lethal-save with 90-second recipient ICD, and committed absorbed-damage reflection are not implemented by this patch. Shield capacity/reflection magnitude need approved design mapping before coding. GUI PvE, real combat VFX/animation sync and manual Save/Return/Reload remain separate integration QA.

## Current ONE GAME QA context from Issue #56

The latest checkpoint reports 14 focused HS-09/ONE GAME regressions PASS on tested source SHA `79dab92`; a fresh New Game GUI remains open. GUI PvE and manual Save/Return/Reload remain pending because screenshot/input capture timed out. These are separate from the Quyền scratch-harness evidence. Leave the active New Game session untouched.
