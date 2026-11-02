# TRI-03 OWNER FINAL — 2026-11-03

**Code source tested:** commit 84aa5bf53a7538aef93d7e7f2a64e2d78c4a9587; Git tree c2a9c67501fb72cb04d39172ef39fba365778f3b. Parent code chain: b123ac2 → 73560f6 → 84aa5bf. PR #67 was observed at base 27ed01cd8f377994e5e50bac9ede84e78e8895bd before publishing. No merge was performed.

## What is now playable in the branch source

- The New Game sect map uses a deliberate V2 composition and Source A art. At 1280×720 the fit view shows the Hall hub, Residence, Guidance, Warehouse/Forge wing, roads and map controls together. Before/after frames are under screenshots/before and screenshots/after.
- XÂY DỰNG opens the real P3.2 map placement flow. The only construction authority currently implemented is paid Đệ Tử Xá placement; the catalog says other building types do not support placement instead of exposing fake enabled buttons. The New Game state has Hall Lv1 and correctly shows the current Hall Lv11 gate; a new residence is not an immediate free build.
- The live P3.2 placement path selects a valid site through mouse-event hit testing, uses the canonical cost/receipt, shows the real map ghost, completes through canonical residence state, permits moving an eligible empty annex, blocks starter/occupied moves, and keeps replay exactly-once after relocation. The dedicated placement fixture seeds Hall Lv11 and resources only in memory; it does not edit a player save or change game balance.
- The Dẫn Tiên B1 screen shows the real queue, separate Tam/Tứ radar, canonical capacity, two-step accept/reject and recruitment-order state. A New Game screenshot confirms 6/8 disciples and 6/8 beds, with two real available places. The reveal names the new disciple, shows a mapped Source A portrait, and exposes Profile/Assignment/World actions. A SaveService roundtrip retains the new canonical roster identity.
- On a successful reveal, duplicate feedback no longer pushes the decision row below the 720px view. The Source A building art stays SHA-gated by the existing manifest.

## Verification

The matrix contains exact process exit codes and PASS markers. On code source 84aa5bf: Godot 4.7.2 import, B1 layout/contract/art/live recruitment, independent B1 reload, DD092, Hall/Housing, async SaveService, P3.6A, P3.7B1 Warehouse, live P3.2 build/relocation and independent relocation reload all exited 0. The first visual capture run executed the unchanged source content committed as 84aa5bf and exited 0, producing the listed 1280×720 frames and the successful Source A recruitment reveal. A retry after the commit stalled at scene_added and Windows marked the QA window not responding; that retry is explicitly recorded as HUNG, not PASS. The QA process was closed after WM_CLOSE failed; no user process was terminated.

Godot stderr reported the Windows environment warning “Failed to read the root certificate store”; focused scripts had no parse/script errors. The B1 art fixture reports anonymous_fallback for its deliberately unmapped test candidate; the captured newly recruited disciple resolved a mapped Source A portrait. Do not interpret the fixture fallback as approved portrait art.

## Acceptance still pending

- Physical Windows mouse playthrough and owner visual acceptance are PENDING_USER; UI capture uses injected Godot button/input events. Android/touch is PENDING_USER.
- Build placement is only supported for Residence because that is the only existing canonical construction authority. Other building types are initialized/upgradable but not map-buildable; adding their authorities would require separate system design and is outside this tested patch.
- New Game cannot place a second house until the canonical Hall Lv11 requirement is reached. No gate, economy, costs, or starting resources were changed. The placement proof uses an isolated in-memory prerequisite fixture, so the full natural progression to Hall Lv11 remains unverified here.
- The final repeated capture attempt hung at first scene startup, so Windows GUI stability needs owner confirmation despite the earlier identical-source render pass.

All QA saves used isolated profile paths. The user's default save was not opened or modified. E source sync was file-hash checked and the C2 versions were backed up in the adjacent backup_before_sync_* folders. E's Git HEAD itself remains 27ed01cd…; only selected source files were copied into its existing dirty checkout. Launcher path: E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao\CHOI-GAME.cmd, official Godot 4.7.2. It remains on its pre-existing local HEAD guard and uses a separate QA profile.
