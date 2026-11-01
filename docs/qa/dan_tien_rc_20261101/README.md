# Dẫn Tiên Đài — ONE GAME RC QA (2026-11-01)

## Source and scope

- RC base verified on GitHub immediately before publication: `rc/one-game-playable-20261101` at `eb5e139d61adb5e9881ccb85d4cd823ad7a84263`.
- Local gameplay tree used for Godot QA: `42fecb3ff98c706f3d6f1fc65704e54df5094585`, tree `74b9d9ac6c2f846b156ec1929597aa7e25c05cf4`.
- The base blobs for modified production files match the RC at `eb5e139d`: BuildingSystem `2c07608e...`, P3.2 map `a38710da...`, Dẫn Tiên V2 screen `d86824e1...`. The remote commit after this test base only changes `MO_GAME.cmd`.
- Runtime: official Godot `4.7.2.stable.official.ed1daf0bf`, Windows desktop renderer, Intel Iris Plus, 1280×720.
- No main merge, no balance formula changes, no owner save used. Upgrade stock was added only to isolated QA SimulationState via WarehouseSystem so the production BuildingSystem upgrade transaction could be exercised.

## Dẫn Tiên evidence

- New Game creates the labeled starting facility at Lv1, 6 founders, capacity 8, 3 candidates and 3 orders.
- Real P3.2 map click opens the operation panel; the D7 modal displays the actual Source A candidate portrait fully inside the dialog.
- Automated UI acceptance: 64 assertions, exit 0. Map, recruitment and upgrade controls are the actual P3.2/DanTienScreenV2 nodes; the guide is set through the real OptionButton signal and a busy disciple is omitted from eligible options.
- The reject confirmation's second simulated mouse click did not trigger, so the automated harness used keyboard focus/Enter for that confirmation. This is not physical-mouse acceptance; owner click remains pending.
- Same-process SaveService checks and a new-process reload passed. The reload verifier ran after the first Godot process exited: 29 assertions, exit 0; 8 roster IDs, 11 candidate IDs, 2 orders, capacity 8, selected guide, daily snapshot and no duplicate IDs were retained.
- Upgrades: real Lv1→2 button uses `BuildingSystem` costs and debits once; busy retry does not debit twice; an in-progress upgrade survives Save/Reload and finishes once. Isolated threshold fixtures pass Lv9→10 and Lv19→20. Lv21 is fail-closed pending approved Đại Điện/Tông Môn gate; Lv100 refuses further upgrade.
- The P3.O2 integration test was updated to the present DanTienScreenV2 UX (it previously required removed inline controls); it now waits for autosave before scene teardown and focuses the disciple before checking selected-only actor materialization. It passes without Thread warnings.
- No player-controlled build/placement/purchase flow exists. Lv1 is honestly labeled as a starting facility. Construction is still missing; no fake cost or placement was added.

## Result limits

- Godot import exits 0 with no parse errors, but editor logs Windows certificate-store diagnostics and cannot scan some pre-existing deep shader-cache subdirectories inside the old QA output profile. Runtime scenes and scripts load in the real renderer test.
- Focused regressions: 11 PASS, 1 FAIL. Remaining failure is the Forge action test (`p3_4c`): recipe material `thanh_thiet` was not consumed; no Forge/economy production code was changed here.
- GUI evidence is actual Godot 4.7.2 rendering at 1280×720, driven by engine input automation. Owner physical mouse playtest remains pending. No “owner playable accepted” claim is made.
- No FPS/performance claim is part of this Dẫn Tiên checkpoint.

## Playtest launcher

`tools/windows/run/Run-DanTien-RC-Playtest.cmd` starts this RC checkout with the official Godot 4.7.2 binary and a new isolated persistent profile under `godot/outputs/dan_tien_owner_playtest_profile`. It does not reuse or overwrite any other save. First launch is New Game; later launches reuse only that dedicated profile.

## Files

The GitHub JPEGs preserve the original 1280×720 dimensions (quality 80); original lossless PNG captures remain in the local QA evidence folder.

- `screenshots/01_dan_tien_building_1280x720.jpg`
- `screenshots/02_dan_tien_recruitment_1280x720.jpg`
- `screenshots/03_dan_tien_upgrade_1280x720.jpg`
- `matrix.csv`
- `logs/` contains redacted Godot import, live UI, cross-process Save/Reload, and focused regression output. Known certificate/cache errors are retained, not hidden.