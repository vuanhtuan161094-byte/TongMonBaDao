# Tán Linh Chỉ Nguyền — R2 source gate

Reviewed against branch HEAD `cde55abb138d150d39e0eadce7a487c68e841fb7`.

- `G0_CONTRACT_CONFIRMED` — same mechanic and receipt boundary as R1.
- `G3_SOURCE_FAIL` — the master still reads as a flower/spiral at 1×.
- `G3.5_NATIVE_NOT_ATTEMPTED` — G3 failed; no asset was copied into the project.
- `OWNER_VISUAL_PENDING`
- `PVE_HOLD_V63_OFF`

## Art brief

The target is a no-projectile, single-target, owner-scoped expiring mark. On the actual hit receipt, show one localized contact; after `v63_curse_mark_applied`, show a restrained target-center mark for its canonical 4.5-second duration. R2 attempted the requested non-radial eclipse/spiral reading: a compact cold-silver inner cut, translucent plum/violet shadow body and three uneven separated hooked strokes. No travel line, extra hit, pull, lettering, paper charm, closed ring or UI geometry.

The canonical mechanic, anchors and receipt are documented in the R1 blocker note. R2 made no changes to them or to runtime code.

## Source trial and 1× review

ImageGen output: `/workspace/generated_images/exec-ab8d356b-f56c-4e70-a4a2-b5923dc5495c.png`
SHA-256: `2e6ee2a74fb89f599b969f00d32dddb5ec703259d0b6408a139495c86839170f`
Size: 1254 × 1254 RGBA, alpha range 0–255; visible alpha bounding box `(213, 286, 928, 973)`.

Prompt used:

> Create a genuine transparent RGBA master for a small enemy-owned Curse mark in an original wuxia game. Target-centered mark, no projectile. The silhouette is an asymmetric open eclipse/spiral seal: one compact cold-silver inner cut shaped like a tiny diagonal slit (NOT a star or flare), held inside a translucent plum-violet shadow body that curls once but leaves a large gap. Exactly three uneven, separated hooked ink-light strokes lean inward from different unequal lengths; one short above-left, one medium lower-right, one long left. Keep all three hooked strokes clearly attached to the same open clockwise turn, irregular and non-radial. Deep plum pigment stays visible on pale sand, cool violet soft edge, restrained translucent bloom. Subject fills 58% of a square canvas, strong 1x silhouette at a 40–56px motif size. Hand-painted living ink-light, not geometric vector. No rays from center, no starburst, no flower, no arrowhead, no beam or slash, no text/lettering, no calligraphy, no paper/talisman, no rings or UI, no character or target body, no scenery, no border, no commercial-art imitation.

`tools/vfx/prepare_g3_source_review.py` rendered the source on dark and light surfaces at a 40px motif width; its contact sheet is `/tmp/curse_r2_review.png` (source-only, not Godot output). Both views remain readable, but the silhouette resolves into a compact flower/spiral with several radial lobes. That fails the required asymmetric hooked-mark read. No follow-up poses were generated after this G3 hard stop; no art, scene, renderer, catalogue, test, or gameplay file was added.

Next iteration needs a clearly non-radial, visibly open hooked contour around a small off-center silver cut. Recheck that silhouette at 1× before producing phase poses or a LAB.
