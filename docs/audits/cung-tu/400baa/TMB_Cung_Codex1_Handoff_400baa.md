# Codex 1 handoff — Cung Tu patch

## Source and branch

- Feature branch: codex2/cung-tu-fix-qa-20261031
- Patch commit: b5471633f485d65dccebec730910f9387b5dc756
- Patch base at creation: integration/one-game-v65-20261030 @ 400baa11403720fb816075d65f3cb74e8f4ad505
- Latest live integration HEAD checked before handoff: d921b082f831d60c6827e0a147600566f87fddc9
- From 400baa to d921, only the HS-09 presentation test, checkpoint document and next-chat handoff changed. None touches Cung source/tests. Integration reports 14 focused tests PASS at 79dab; GUI PID 8136 remains open and gameplay capture is pending. This does not test the Cung patch. Apply/review against live d921.
- Runtime status: NOT_RUN. Cung Tu is not DONE.

Production file to review/apply: godot/src/simulation/combat/v63_human_skill_combat_system.gd. This is the only production path changed. No shared MapBattleV2, HuntingPveRunV2, SaveService, P3.2 or ONE GAME edits are proposed.

## Test order after Godot is released

Godot 4.7.2 import, then run these tests sequentially. Capture exact source SHA, command, stdout/stderr and exit code:

1. tests/simulation/v63_cung_world_mobility_test.gd
2. tests/simulation/v63_cung_line_range_test.gd
3. tests/simulation/v63_cung_heal_target_test.gd
4. tests/simulation/v63_cung_full_combat_matrix_test.gd
5. tests/simulation/v63_cung_six_disciple_pve_test.gd

Then rerun the current HuntingPveRunV2 + Save/Return/Reload focused gates and the required Windows/Android gameplay/VFX QA. Do not call DONE from catalogue counts or source-only review.

Rollback the production change on this feature branch with:
git revert b5471633f485d65dccebec730910f9387b5dc756

If Codex 1 cherry-picks onto a new integration commit, record the resulting cherry-pick SHA and revert that resulting commit if a regression is found.

## Short prompt for Codex 1

> Fetch the live integration HEAD (last checked at d921b082f831d60c6827e0a147600566f87fddc9), then review branch codex2/cung-tu-fix-qa-20261031 and patch commit b5471633f485d65dccebec730910f9387b5dc756. Apply only the Cung kernel change after checking the source diff; do not alter shared MapBattleV2/PvE/Save/P3.2 without a separate proposed patch. After Codex 1 releases or coordinates the open Godot session (checkpoint lists GUI PID 8136; issue #56 also retains PID 15996), run the five sequential tests above plus current PvE Save/Return/Reload gates, save Godot 4.7.2 logs and exit codes, and keep Cung Tu NOT DONE until all functional and owner QA gates pass. If the cherry-pick regresses, revert its resulting commit; on the feature branch, revert b5471633f485d65dccebec730910f9387b5dc756.




