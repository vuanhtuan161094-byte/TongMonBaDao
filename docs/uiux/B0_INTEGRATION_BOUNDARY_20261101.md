# B0 — B1 UI implementation boundary and QA proposal

**B0 complete: documentation only.** Codex B is not authorized by this document to write runtime. The user assigned Codex A as gameplay/TRI-01 integration writer; shared screens and canonical systems remain under A's ownership. A separate owner CODE packet naming exact SHA, paths, exclusions, rollback and tests is required before any B1 implementation.

## Verified starting refs

- Docs branch B0 base: `docs/dual-codex-sourcea-uiux-audit-20261101` @ `9ce65f6239d8d8659a9daa50c5ea338c7fd02ac7`.
- RC static baseline: `rc/one-game-playable-20261101` @ `970af33b23076c80d677cf5898a721a27504708f`.
- PR #64: open Draft, head `bf3ed0310899c554eea4e6b2e1967dcada2d68dd`; not compiled, playtested or merged per PR description.
- Source A reference repository: `ZQZS-Source-Knowledge@83cbc4ecbd83eb518a6d6f2b3894377d9d99254d`.
- Current playable checkpoint separately records automated New Game / save evidence at integration SHA `79dab92ccc95a93b39dcb563fe06c93a9aa422da`; in-game PvE/Save/Return/Reload GUI capture remains pending. This is checkpoint evidence, not a B0 rerun.

## Proposed B1-A — standalone Godot-native visual primitives

This is a **proposed new-file-only allowlist**, not an approval. It avoids P3.2 and every runtime authority file:

- `godot/src/presentation/uiux/sect_ui_theme_v1.gd` — original color/spacing/type constants and shared Control style helpers.
- `godot/src/presentation/uiux/sect_icon_badge_v1.gd` — original category/status badge; accepts icon/key/label from caller.
- `godot/src/presentation/uiux/sect_metric_chip_v1.gd` — compact value + unit + optional state marker.
- `godot/src/presentation/uiux/sect_resource_strip_v1.gd` — read-only cost/available quantity row, no economy calculation.
- `godot/src/presentation/uiux/sect_progress_track_v1.gd` — display-only progress bar/step markers, no time calculation.
- `godot/src/presentation/uiux/sect_portrait_slot_v1.gd` — neutral silhouette/approved texture display only.
- `godot/tests/presentation/sect_uiux_primitives_v1_test.gd` — scene/control geometry and state display tests at 1280×720.
- Generated `.uid` sidecars for new GDScript files and the new test, if required by Godot.

B1-A is intended to use no binary art, no save fields, no new dependencies and no simulation calls. Inputs are explicit presentation values and callback callables; all values/actions come from an existing real presentation snapshot/command. A later review may narrow this list after file collision and branch checks.

## Shared integration files remain with Codex A

These are not B1-B write permissions for Codex B. Codex A is the integration owner for any wiring and must own/authorize the shared diffs:

- `godot/src/presentation/p3_2_landscape_sect.gd`
- `godot/src/presentation/dai_dien_screen_v1.gd` (or its final integrated path)
- `godot/src/presentation/dan_tien_screen_v2.gd`
- `godot/src/presentation/p3/sect_isometric_world_v1.gd`
- `godot/src/presentation/disciple_presentation_snapshot_v2.gd`
- Scene files that instantiate or bind these controls.

Codex B must not edit those files while A owns TRI-01/gameplay integration. If B1-A primitives need an integration spike, A should wire one component in an explicitly approved packet or the owner should assign a single writer.

## Hard exclusions

No writes to simulation/state, SaveService, Scheduler/RuntimeClock, ResourceRegistry/Warehouse, BuildingSystem, MapBattleV2, HuntingPveRunV2, recruitment, Injury/CombatStats, feature gates, save schema, economy/balance, main scene, source branches, PR #52, PR #64, or main. No change to persistent data or real user saves. No Source A/JX/JXQY binary transport, import, atlas, prefab, font or animation until rights and exact dependency approval.

## B1 focused QA proposal

After a fresh CODE authorization and on an isolated QA checkout:

1. Run official Godot 4.7.2 import once on the exact approved source SHA.
2. Run the new primitive-control test at 1280×720: minimum hit areas, anchors/overflow, Vietnamese text, keyboard focus, empty/blocked/ready states, theme contrast. Include source SHA and full command/log path.
3. Run relevant existing presentation screens/tests unchanged, plus current authority regressions only where the packet wires a real state snapshot/command.
4. Capture actual Godot GUI at 1280×720 for Hall, Residence, Guidance and one crowded map/combat scene. Check clipping, readability, touch targets, icon meaning and real art fallback; never label a static HTML/wireframe as gameplay.
5. Owner visual review remains a separate acceptance gate. Android/device and whole-game FPS are separate later checks unless the future packet explicitly requires them.

Exact test paths and cumulative regressions must be decided in the future CODE packet after A's shared integration stabilizes. B0 has run no tests.

## Rollback and handoff

- B1-A rollback: revert the single B1-A commit containing only newly added controls/tests/UIDs. It has no state migration because the widgets are display-only.
- Shared wiring rollback: Codex A reverts only its integration commit after comparing with current HEAD; do not reset shared files to B0 or erase parallel work.
- B0 leaves all runtime and assets untouched. Owner review should choose whether B1-A may start, whether Source A rights are cleared, and who owns the shared-screen wiring.
