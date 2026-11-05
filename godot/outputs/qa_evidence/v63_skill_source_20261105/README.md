# V6.3 exact-SHA QA evidence

- Tested source commit: `08e854ae73f9c36f2bdd09d13f31072961ec915a`
- Git tree: `ea2522e612157da23cbd51793e3fd132c5cbf44b`
- Engine: Godot 4.7.2 stable official `ed1daf0bf` (Windows, headless regression; actual GUI startup smoke was separate).
- Focused exact-tree batch: 18/18 tests exit 0, all expected PASS markers or matrix summary; see `QA_MATRIX.csv` and `raw/`.
- UI fix validation: editor import and `v63_d3_learning_ui_test.gd` exit 0 at the same source tree.
- Full Cung/Bow simulation coverage: 183/183 catalogue IDs, 81 active/ultimate, 81 passive, 15 innate, 3 basic, 3 mobility; zero matrix failures. Six-disciple simulation confirms positive damage from all six and snapshot restoration.
- `SKILL_ID_MATRIX.csv` inventories all 549 Human/Immortal/Divine catalogue records. Only the 183 Cung IDs have a full per-ID matrix. Quyền/Độc are explicitly marked `NOT_EXHAUSTIVE`; focused samples do not imply all-ID coverage.
- Each Godot run emits a Windows root-certificate-store warning on stderr (`Failed to read the root certificate store`); all test exit codes are 0 and all expected markers are present. No test parse or assertion failures observed.
- GUI mouse acceptance and screenshot are **PENDING**: the Windows desktop automation target did not expose the Godot window. The Tàng Kinh UI test is automated/headless and is not physical GUI acceptance.
- Skill feature gates remain default OFF. `v63_content_registry.json` reports `D1_UNWIRED_NOT_PLAYABLE`; the archive catalog has `drop_profiles: []` and the validator rejects unauthorized live drop profiles. Therefore this evidence does **not** establish normal gameplay acquisition of skill manuals or a playable skill progression release.
- QA used an isolated profile and did not access or modify the player's save.

Files are raw stdout/stderr (paths redacted to `[QA_ROOT]`), exact-source matrix, 549-ID coverage ledger, and source SHA-256 manifest.