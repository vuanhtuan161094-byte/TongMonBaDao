# SWORD03 — Tứ Phương Phi Nhận / Ngự Kiếm / Nhân
**G0 canonical checked; G3 direct-art source PENDING; not approved to enter Godot or Web.**

Source of truth: `godot/data/combat/v63_sword_combat_catalog.json` entry `tmb.skill.sword.ngu_kiem.active_03.human`.
- Metal / damage / **LINE**, damage ratio 1.0, range 8, radius 6 as catalog field, target limit **3**.
- Cast 0.44 s, cooldown 11 s, projectile speed 9. **No gameplay changes**.
- Four visible flying blades is a visual motif, **not four gameplay hits** or distinct targets.
- Only HUMAN authored now; Immortal and Divine may inherit HUMAN visually later, not treated as individually approved.

## Required art direction / 1× acceptance
A very legible **four-direction burst of silver-blue flying blades**: a compact focused charge at an AS-CHAR hand/socket, four simple elegantly shaped blades leaving in a forward **LINE** trajectory with staggered launch (no decorative engraving), narrow flowing pale-blue ribbons and white cores, a localized crisp contact fracture, then soft transparent tail. The four visual swords must not orbit as a circular AoE like R1E. No character embedded in artwork; no scenic background; no letters, labels, frames, watermark, full poster or cut-out from a poster. Alpha MUST be native from direct sprite source; do not fake transparent pixels by threshold-removing a black poster background.

JX/Võ Lâm is a **quality reference** for transparent layered sword qi, controlled acceleration, readable 1× contact and coherent timing; no asset/frame copying. Sprite-first: make RGBA VFX source with independent sprite cells; Godot later only aligns to sockets, frame timing, controlled additive bloom, moving-target collision, never draws the art in Bézier/rig.

Design target for isolated review: 24 output frames @25 fps / 0.96 s (NOT 0.44 s gameplay cast) in 4×6 atlas, transparent 512×512 each. Suggested beats: charge 01–06, forward flying blades 07–15, contact 16–20, fade 21–24. At least 12 **direct, originally painted VFX-only** source frames; derived inbetweens must be disclosed separately and never passed off as 24 AI-painted originals.

## G3 strict approval sequence
1. Verify each actual source image native RGBA, visible ink, transparent 8px border, unique hashes and tracked source provenance.
2. Build a **source-only** 1× GIF on pale/dark maps, 25fps; source GIF is not a Godot capture.
3. Owner reviews art: distinguish sword silhouette, staggered launches, crisp impact, no excessive glow/engraving. Explicit APPROVE required.
4. Only then bridge Front AS48 to isolated Combat Lab; exact-SHA native/Chromium/GIF; stay PvE HOLD until separate permission.

**Current result:** AI generation attempts were promotional grids/posters with labels and even the wrong name. They were rejected; **zero** frames from these were cropped, extracted or committed. The asset source is intentionally unpopulated. **Do not report G3 PASS** or attach a false GIF. R1E V2 approved reference remains untouched. PR #72 DRAFT; no Codex Cloud, rig, merge, SaveService/gameplay modification or PvE.

## 2026-11-24 — G3 correction: reject semi-opaque matte inside 'RGBA'
New AI attempts produced 24 VFX-only poses without text or characters, but the source had **RGBA alpha values of 161–251 across the sheet background**, i.e. an opaque-looking pale rectangular matte persists around the art. Cropping a genuine sprite sheet is distinguishable from cropping a poster, but is still **not sufficient** to make this usable as a game sprite. On dark 1× review maps this becomes 24 visible gray squares.

The unapproved source test was kept outside GitHub; **no candidate frames committed, no G3 art approval**. The fail-closed gate now also rejects semiopaque interior sheets (not just the outer 8px border), ensuring transparency is really present around the painted VFX. Never 'solve' this by chroma-key/threshold removal, or by hiding the error on a pale-only review. Native-alpha source frames must be clean on both bright and dark backgrounds before entering the repo. R1E V2 remains the accepted reference; SWORD03 source remains PENDING.
