# POI06 R11 — isolated Combat Lab staging; binary art upload required
Date: 2026-11-14

The user accepted the visual direction of the *local* R11 preview. This is **not a Godot QA pass**.

- Branch: integration/pve-p0-playable-ui-20261103; PR #72 Draft; no new branch/merge.
- R11 48-frame approved source atlas exists in the conversation pack, NOT in the repository yet. Expected path: `godot/labs/combat_lab/poison06/r11_candidate/assets/realm_vortex_r11_48.png`, RGBA, 2048x1536, 8 columns x 6 rows, 256x256 per cell.
- Exact PNG SHA256: `1d3c8adbee16e48973998a66f3692f12366dd64e8b9582ecf090ccfcb00299f8`.
- This staging commit adds the dedicated Godot scene/script, explicit R11 test and pinned 4.7.2 Compatibility native-movie workflow. **Do not claim native scene or visual QA PASS until the exact PNG arrives and official workflow executes against its SHA.**
- The new workflow auto-triggers on the exact atlas upload or can be started manually; if the atlas is missing, it intentionally fails rather than substitute older R10 imagery.
- R10's `poison06/van_co_phe_gioi.gd` and `.tscn` are untouched. R11 uses cosmetic three targets, real 48 pose atlas and 5.55s view-only animation. No Combat V2/SaveService/HP/poison/status writes. PvE HOLD, V63 OFF, physical Windows/Android QA PENDING.
- Asset upload blocker in the current session: GitHub connection supports UTF-8 text and Git blobs by string but cannot directly transfer the local multi-megabyte PNG archive. The PNG must be uploaded as the *exact* validated file from the user's local R11 ZIP, not regenerated, replaced by R10, or faked using geometry.

Next run: stage the exact asset and verify GitHub Actions movie 1280x720/333 frames, 14 checkpoints, 1x art inspection, verify actual run/artifact ID and SHA. Do not call Python preview Godot footage.
