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


## 2026-11-24 — R2A direct RGBA artwork review, local-only candidate

Created a NEW **unlabelled, actor-free, direct AI-produced sprite sheet**, 6×4 source at 1536×1024, each painted cell 256px. This is **not** a promotional poster and is not a screenshot of the game.

Production of review candidate from the 24 painted cel positions was limited to original alpha-preserving sheet slicing, LANCZOS scale to 440px, transparent 36px padding to 512px, and regrouping into a 4×6 2048×3072 atlas. Crucially there was **no** alpha color key / thresholding, black-background removal, Python geometry painting, rigging or character cutout. This does not make each cel a separately generated master; all 24 belong to one original sprite-sheet master.

- Original RGBA master SHA-256: `5959932d662b478d954c18dc9d2b6329d576d928e8047d45f7b0165a3a6f6333`.
- Prepared atlas SHA-256: `fdc7ce0538d1d9134ed2b55c31d802cf28d870bf6f0da22b8813d076fa363920`.
- Local technical review: **24/24 frames** 512px RGBA, 24 unique SHA-256, safe transparent 8px borders, 4×6 atlas pixel-exact; interior alpha content density max 0.5262 (does not have the earlier solid rectangular matte). GIF preview: 174px dark/light @25fps / 0.96s, SOURCE ONLY.
- Visual limitations: in the flight and impact phases some blades overlap and fewer than four are clearly distinct; a dark smoke trail on pale maps remains noticeable. The G3 owner must review at 1× before declaring art accepted.

**SOURCE DELIVERY / GATE STATUS:** R2A is a local ChatGPT-conversation review ZIP/GIF, NOT yet uploaded to the repository. Therefore `ART_CONTRACT.json` accurately stays `SOURCE_PENDING` and the GitHub G3 workflow only proves G0/canonical checks, **not** source asset acceptance. After owner review the exact-SHA manifest + RGBA master/24 PNG/atlas/GIF can be staged. No Godot, Chromium, PvE, rig, Codex Cloud, SaveService or merge.


## 2026-11-24 — Root cause and generation fix

See `G3_GENERATION_FIX_V2.md` for prompt contamination, 24-frame overload, actual PNG alpha measurements, isolated transparent control experiment, and the corrected single-seed-to-short-strip production flow. G3 remains pending. Auto checks cannot prove no UI or aesthetic success; human 1× review is mandatory.
