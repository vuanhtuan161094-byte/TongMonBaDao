# SWORD03 · VFX generation corrective action V2 · 2026-11-24

## Cause: this was both a prompting and a production QA error
1. Some prior **generation descriptions contained words that positively asked for a poster, title banner, technical panel, frame labels, or a grid-showcase composition**. The model did not independently invent every promotional layout; the authoring brief itself drifted.
2. "One highly polished 24-frame grid + typography + technical specs + perfect motion and transparency" is an over-constrained layout problem and encourages a visually coherent **presentation board** instead of game-ready alpha art. Changing only the word *poster* to *sprite sheet* does not remove this bias.
3. Asking for "a transparent checkerboard background" is wrong: a painted checkerboard/pale matte is not an alpha channel. Request actual transparent-background output in the image-generation control AND verify the decoded PNG alpha. Do not request a checkerboard graphic.
4. A PNG saved as RGBA can still carry opaque/semiopaque background pixels. 24 different hashes and 8px empty padding alone are not evidence of valid sprite transparency.
5. No approved production seed existed. Re-generating a full animation from scratch repeatedly led to inconsistent sword counts, overloaded decoration, drifting silhouettes, and poster formatting.
6. The prior G0 source workflow was green while SOURCE_PENDING. It verified canonical metadata, NOT a sprite/art pass.

## Evidence: actual historic files, not a guessed model internals diagnosis
- An explicitly poster-like sample `a_widescreen_concept_art_game_vfx_sprite_sheet_a.png` (1536×1024 RGBA) has 0% pixels with alpha <16.
- Prior bad pale source `a_clean_transparent_background_sprite_sheet_vfx.png` (1774×887 RGBA) has alpha 161–251 throughout and 0% alpha <16.
- R2A master `a_clean_transparent_png_sprite_sheet_image_atlas.png` has 72.32% pixels alpha <16; a technically usable sheet but not proof of four readable swords every frame.
- A **controlled production-style trial** made ONE standalone four-sword flying VFX with actual transparent-background generation requested; output `a_clean_transparent_png_game_vfx_asset_on_a_checke.png` (1635×962 RGBA) showed **76.51% alpha <16** and no promotional UI. This is one joint-change test (single asset + transparency control), NOT an isolated A/B proof about the exact causal weight of each factor.

## Production workflow (mandatory)
**Gate P0 — one VFX master first**
- Text instruction: one isolated **four-sword flight** VFX sprite; crisp silver-blue blades + modest azure trails; 2D production art; no UI, character or lettering.
- Generation control must request native transparent background; emit PNG RGBA. Do NOT ask for a contact sheet, marketing board, technical information, frame numbers, checkerboard, labels, or a character pose.
- Inspect the actual pixel alpha; export exact 1× (174 px) previews on BOTH light and dark backgrounds.
- Check simple readable blade silhouettes: four visual blades, not necessarily four gameplay hits; no ornament noise.
- Owner visual approval of this single source sprite before generating a strip.

**Gate P1 — anchored multi-frame strips**
- Start from the **owner-approved exact-SHA production seed**, not just its textual description.
- Produce one coherent *short animation strip per phase* (e.g., charge 6, release 9, contact 5, fade 4) using reference-image editing/whole-strip generation to preserve identity. Do not generate unrelated independent frames unless disclosed.
- Do not ask for 24 frames + storyboard + labels in a single unconstrained generation. Stage one short strip at a time; preserve original alpha.
- Grid slicing is allowed ONLY for source strips produced specifically for sprite animation, never for promotional posters; annotate provenance as a strip rather than pretending all frames were separately generated.

**Gate P2 — technical, then visual**
- Verify one master provenance (SHA-256), explicit native alpha, no chroma-key, no labels/actor, 24 frame hashes, atlas exact pixels, 8px border, and no dense rectangular matte.
- Automatic alpha tests catch common errors, but cannot certify the absence of lettering/actors or artistic quality by themselves. Those require direct visual review.
- Create source-only 1× GIF on dark/light, clearly label not-runtime; owner approves before Godot.
- Only after G3 source approval, test AS48 blade socket, 3 moving targets, true linear hit shape and exact-SHA browser runtime; never mark the gameplay skill complete based solely on alpha QA.

## Seed prompt text (positive, NOT marketing)
> One standalone 2D production-game VFX sprite: four slender silver-blue spirit swords flying rightwards in staggered lanes, sharp tips, white cutting edges, pale-blue transparent energy ribbons, subtle wisps, elegant simple blade silhouettes. Isolated effect only, no character, no environment, no text, no frame markers. Natural alpha around the entire painted effect. Sprite must be readable at 174px.

**Producer-side generation setting:** explicit `transparent_background=true`, PNG RGBA; this setting is **not** achieved by merely writing "transparent" in prose. Preserve alpha in all subsequent edits.

## Gate status
No prior or new VFX sprite is promoted by this policy-only change. Current SOURCE_PENDING remains true; the R2A 24-frame ZIP is still a local, unapproved review candidate. The fresh single-sprite test is visually promising but is NOT auto-committed and not an owner-approved replacement. Preserve R1E V2, PR #72 Draft, no merge, PvE HOLD, no Codex Cloud, no rig.
