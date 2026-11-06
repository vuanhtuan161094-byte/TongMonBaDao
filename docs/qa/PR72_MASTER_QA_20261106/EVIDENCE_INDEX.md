# PR #72 QA evidence — 2026-11-06

Current code/test commit: `5ef179b81dfef6f2d72a38d866e94fc828e179eb` on `integration/pve-p0-playable-ui-20261103`; Draft PR #72. The previous `374f2d4`→`5ef179b` delta changes the source-pin manifest and stale Warehouse UI assertions only; no production gameplay/runtime implementation changed in this test-fix commit.

- [Execution matrix subset](EXECUTION_MATRIX_SUBSET.csv) records exact commands/results and evidence paths. It is not the missing master matrix.
- [Master input status](INPUTS_STATUS.md) records why the 35/158/10 register cannot be truthfully built yet.
- `logs/r3/`: three independent Godot processes over one isolated QA save (40/146/4 checks, all exit 0).
- `logs/production/`: O1 Warehouse, O4 Linh Điền, O7 Linh Lâm, launcher safety and original stale-assertion failures.
- `logs/focused/`: P3.2 map, density, P3.4B assignment, and O3 mine loop. These ran at `374f2d4`, whose later delta contains no production runtime change.
- `logs/source_verify.txt`: source verifier on exact `5ef179b`, 167/167 pins, exit 0.
- `logs/visual/`: exact-SHA capture result and the failed headless dummy-renderer probe.

## Viewport captures

These are **real Godot GUI renderer viewport captures** (`get_viewport().get_texture().get_image()`), all 1280×720, Intel Iris Plus OpenGL 3.3 Compatibility, produced at `5ef179b`. The harness drives screen/panel methods; it is not physical mouse input and the combat image is a state/setup capture, not proof of a paid kill.

- [Main map](screenshots/01_main_map_source_a.png)
- [Idle walk and dialogue](screenshots/01b_main_map_idle_walk_dialogue.png)
- [Map pan and zoom](screenshots/02_main_map_pan_zoom.png)
- [Mine production](screenshots/03_mine_production.png)
- [Linh Lam production](screenshots/04_linh_lam_production.png)
- [Linh Dien production](screenshots/05_linh_dien_production.png)
- [Canonical Warehouse](screenshots/06_canonical_warehouse.png)
- [Disciple profile](screenshots/07_v2_disciple_profile_luc_duy.png)
- [CARE combat screen](screenshots/08_care_combat_v5_source_a.png)
- [Return to sect](screenshots/09_main_map_after_hunt_return.png)

Physical Windows mouse/UI remains `PENDING`; Computer Use could not initialize (`failed to write kernel assets`). No player save or default profile was used.
Screenshot integrity manifest: [SCREENSHOT_SHA256.csv](SCREENSHOT_SHA256.csv) records the 10 viewport PNGs, each at 1280×720, with byte size and SHA-256. Visual review confirms the map/idle NPC frame and production/Warehouse panels render; the Linh Lam frame has no assigned workers and is a status-panel capture, not proof of a completed production cycle. O7 and R3 logs carry the functional production/save evidence.
