# TMB Kiếm Tu Nữ — visual authority and animation pipeline (2026-11-14)

## Purpose
Begin the female Sword Cultivator only after the male AS-CHAR-48 source package is preserved as the pipeline reference. Target is a standalone female character with its own silhouette, hair, clothing, weapon and motion; do not simply recolor/mirror the male.

## Source evidence and precedence
1. **Latest female four-view project source**: Library file `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` (created 2026-11-13, 962,165 bytes; Library file ID `libfile_c0003c44d8308191883e11aa9aa2e122`). Its four-direction preview identifies front/right/back/left and shows a female chibi swordswoman with deep violet/indigo hair in a high bun, floral white-blue hair ornament and long ribbons, pale blue/white layered robe, dark leggings/boots and a blue-silver sword. Use this as the latest female silhouette/weapon reference. Preview is a source reference only; no raw bytes could be materialized in this session, and no claim is made that its source APNG is production-ready.
2. `KIEM_TU_INTERACTIVE_QUALITY_REVIEW.html` (Library file ID `libfile_fb9713195c888191b63770ce77a4fed5`, 2026-11-13) records a female concept extracted from the approved B+C board: **dark blue/black hair, blue-white outfit, silver sword**. It explicitly says the female body and sword are still one PNG, with no source layers or new animation. The HTML is a browser preview, not Godot.
3. `Nữ kiếm tu sen tím huyền ảo.png` (Library file ID `libfile_1f0e7c57308c8191a52c15604a3b38be`, 2026-11-04) is a high-detail purple/white/gold illustration with lotus magic on green chroma. Treat as old mood/reference only; **not** the production sprite source and not the current chibi proportions.
4. The older 2026-11-04 proposal “Nữ Kiếm Tu Huyết Ngọc” (ruby hair/armor/sword, pink eyes) conflicts with the newer 2026-11-13 four-view blue/white female concept. Do not silently mix the ruby palette, lotus VFX, or tall anime proportions into the latest female source. If later owner instruction explicitly reopens Huyết Ngọc, revise this authority then.

## Female design target (candidate to owner review)
- Dark-fantasy Xianxia chibi; mature, sharp but graceful female face; approximately 3–3.5 heads high; strong readable silhouette.
- Hair: deep violet/indigo, high tied bun, long flowing rear hair, pale-blue/white floral ornament, blue ribbons; must remain recognizably female from back and side.
- Outfit: layered pale-blue/white/silver cultivation robe with restrained navy details, fitted dark inner trousers/leggings, practical low boots; elegant but battle-ready and not excessively revealing or covered in tiny dangling ornaments.
- Eyes: blue-violet; small, clean sword-sect forehead mark in cool blue/silver, not the male's red mark unless visual review proves the two should share it.
- Weapon: blue-silver straight sword from latest female four-view reference, physically in the hand and **baked into each animation frame** for this initial character set. Do not reuse the male's black-red sword. No floating/misaligned sword.
- Render: same high-detail Shadow Pixel-Chibi Xianxia finish as the male's AS-CHAR-48; hard clean silhouette, crisp clustered highlights, restrained antialiasing, high-resolution source. Never downsample a smooth illustration and label it native pixel art.

## Production contract
- Target **24 clips** = four directions (front/right/back/left) × Idle/Walk/Attack/Cast/Hit/Death.
- Keep source frame canvas **512×512 RGBA**, common foot root **(256,442)**, character target visible height around **320 px**. This matches the male AS-CHAR-48 technical package. Maintain margins for hair, ribbons, sword and action trails; do not crop original source motion.
- Frame-by-frame authored motion. **NO rig, Skeleton2D, Bone2D, skeletal interpolation, stretching, or fake motion from moving a static full-body PNG.**
- Preserve actual original GIF/APNG frames, inspect source format/magic before splitting; never slice a contact sheet as if it were an animation sheet. All atlas cells must be exact binary copies of exported source frames.
- Use the same six-state timing intent as the male, but allow direction-specific frame counts. Idle/Walk loops; Attack/Cast/Hit are one-shots; Death is non-looping and holds its final frame.
- Export each clip as standalone transparent PNG frames, per-clip atlas, GIF preview, Godot SpriteFrames resource, scene/project and a manifest of frame counts/unique poses/source hashes.
- No gameplay, SaveService, Combat V2, VFX runtime, economy, production actor wiring, branch creation or merge. Work only on current PR #72 branch and isolated QA project. Do not replace male assets.
- Before any production integration, run official Godot 4.7.2 import and actual GUI preview at 1280×720 and map zoom 1×/2×/3×; visually inspect hands, sword grip, foot contact, frame seam, alpha halos and crop margins. Owner visual approval remains required.

## Work order
1. Retrieve male AS-CHAR-48 ZIP from personal Library and preserve exact pipeline settings; do not recreate it.
2. Retrieve/read female APNG and preview sources when raw file access is available. Use the four-view female reference above to author a clean, high-res female master/turnaround. **Do not start 24 clips before this master passes identity/consistency review.**
3. Build genuine 9-frame Walk for each direction; inspect actual GIF frames and foot pivot.
4. Build Attack with sword arc, Cast with sword/hand seal and energy gather/release, Hit recoil/recovery, Death non-graphic fall/settle, and breathing Idle. No mislabeled actions or repeated stills to inflate coverage.
5. Export/QA 24 clips and compare directly to male AS-CHAR-48 at 1×/2×/3×. Keep candidate and production-approved counts separate.

## Initial status
`FEMALE_REFERENCE_FOUND` / `MASTER_NOT_CREATED` / `ANIMATION_NOT_STARTED` / `GODOT_NOT_RUN` / `OWNER_VISUAL_APPROVAL_PENDING`.
