# TMB SPRITE STANDARD V1 — SHADOW PIXEL-CHIBI XIANXIA
Date: 2026-11-13 | AS-CHAR-38 | Issue #77 | PR #72
Status: AUTHORING CONTRACT, NOT a claim of asset approval, production integration or hardware QA.

## 1. Authority, scope and source provenance
Applies to two branch-neutral novice identities (male/female), followed after acceptance by 36 branch design groups (12 sects x 3). Read AGENTS.md, docs/animation/AS_CHAR38_SINGLE_ART_FAMILY_WEAPONS_20261112.md, TMB_DISCIPLE_UNIFIED_ART_BIBLE.md and Issue #77 before work. The latest owner-liked original three pixel GIFs are style/motion references; the subsequently generated large illustrations are not interchangeable pixel masters. The separately owner-approved male Poison Cultivator green-sword front image remains locked; it must not be replaced by a merely similar generated version.

Before treating any PNG as canonical, record exact original bytes, SHA-256, origin, source filename, dimensions, alpha, owning identity and exact owner visual approval. The image seen in chat is not automatically transferred to GitHub or Codex. Keep old sources intact; do not overwrite approved source or mistakenly attribute an old candidate to the owner. Production state must distinguish SOURCE_VERIFIED, ART_APPROVED, ANIMATION_APPROVED, ENGINE_TESTED and INTEGRATED.

One PR #72 Draft; one existing branch integration/pve-p0-playable-ui-20261103; no new branch/merge; no SaveService, combat/V6.3, economy, AI, canonical disciple state or player save modification. All work in isolated art lab until approved.

## 2. Pixel family, outline, alpha and palette standard
- Intentional high-quality Shadow Pixel-Chibi Xianxia: adults, approx. 3–3.5 heads, same facial proportions and pixel density across identity/direction/frame; deep tonal masses, upper-left lighting, compact layered robes and restrained ornaments.
- Map output: 128 x 128 RGBA at pivot foot_root=(64,104); visible 60–75 logical pixels at zoom 1.0. Separate combat output: 160 x 192 RGBA at pivot=(80,179), separately authored/registered, not a naive stretched map sprite.
- At native sprite resolution, OUTER_CONTOUR is usually one logical pixel in dark violet/charcoal ink, art-reference approximately #201B2C, hue- and lighting-adjusted. INNER_SEPARATION around #373444 where hair/cloth/skin/metal forms overlap; only selective 1-pixel light edge on upper-left lit facets. These are guideline colors, NOT an instruction to automatically recolor every alpha boundary.
- Rule: coherent pixel clusters, restrained staircase, no random single pixels, no doubled heavy outline, no broad smooth airbrush, no arbitrary AI pixel filter or downscaled anime approximation. Hair and cloth contours soft through cluster rhythm, hard metal edges have sharper controlled corners.
- External background and preview ground shadows remain TRANSPARENT in exported character PNG; shadows are optional separate layer. No baked checkerboard, dark matte, white halo, UI label, motion trail, projectile, magic circle or emitted VFX.
- Quality bar: at 1x game size must read silhouette/sex/outfit/weapon; at 6x nearest-neighbor inspect cluster, antialias, seam and alpha. Border pixels with uncontrolled alpha fringe are defects to correct, never auto-paint over the approved original.

## 3. Source layers and modular visual parts
Every accepted character requires real editable native layers. Preferred transport: ORA (open layered image), optionally .aseprite or Pixelorama .pxo authoring source when actually made; flattened PNG/GIF alone does not prove editability.

Back-to-front groups with per-direction and pose-specific z-order:
00_GUIDES (nonexport: canvas, safe-area, foot, face and sockets)
01_GROUND_SHADOW (nonexport from body)
02_HAIR_BACK
03_BODY_BASE (head, neck, torso, arms, legs, occluded areas reconstructed)
04_FACE_BASE, 04_EYES, 04_BROWS, 04_MOUTH, 04_MARK
05_INNER_CLOTH, TROUSERS_OR_SKIRT, BOOTS
06_OUTFIT_MAIN, OUTFIT_TRIM, SLEEVE_L, SLEEVE_R, TAILS, BELT, CAPE, ARMOR_L/R
07_FOREARM_HAND_L, FOREARM_HAND_R
08_HAIR_FRONT, HAIR_ORNAMENT
09_WEAPON_BACK, WEAPON_FRONT, WEAPON_SHEATH, HELD_PROP
10_FX_PREVIEW_ONLY (always excluded from production character atlas)

Outfit slots: inner, outer, sleeves_L/R, pants_skirt, shoes, belt, shoulder_L/R, headwear, cape, accessories. An outfit variant needs authored artwork for each supported view and motion pose, not merely a new recolored PNG or graphical overlay that tears during movement.
Expression slots: neutral, focused, angry, hurt, soft_smile, closed_eyes_cast, death. Separate eyes/brows/mouth masks where pixel-scale allows; at ~70px some expressions may need a higher-detail portrait-only counterpart. Back view has no visible face overlay. Face drawing and body identity remain immutable while expressions change.
Equipment: held weapon, hand contacts and sheath are separate authored layers; appearance follows canonical equipment only when mapping is verified. Initial green sword and lavender fan may be cosmetic demo props and do not grant item, class, damage or skill. No sex-locked item categories. Each of 36 branches will have distinct prop/gesture/motion families according to the canonical 12-school visual motif registry.

## 4. Direction and anchor contract
Four genuinely authored views: front, right, back, left, same hairstyle/face, seam topology, pigment, body-height and equipment handedness. Mirroring is not automatically safe for asymmetric designs. Fixed coordinate system: image origin top-left, full 128x128 canvas.
Per frame mandatory anchors: foot_root (64,104), head_center, face_origin if visible, hand_l_grip, hand_r_grip, weapon_pivot, weapon_tip, back_socket, cast_origin; null/hidden values allowed where authentic view makes a socket inapplicable. Store positions in integer canvas pixels, handedness and explicit weapon/body z-order. Only measure anchors from real source and pixels, not guessed metadata.
Do not trim each action differently without registration metadata; foot remains on ground through contact frames. All directions use same camera, scale, outlines and light direction.

## 5. Animation storyboard and true motion
Six states for every accepted visual variant: Idle, Walk, Cast, Attack, Hit, Death.
Idle: grounded, one still frame allowed, optional subtle real limb/head pose.
Walk: left foot contact, passing, right foot contact, passing; independent legs, opposite swinging arms and secondary robe/hair follow, no root skating.
Cast: anticipation, discrete hand/fan seal, release marker and grounded recovery; VFX externally synchronized with actual gameplay events.
Attack: wind-up, shoulder/hip weight shift, real arm + weapon arc, impact/release, follow-through and recovery.
Hit: grounded shoulder/elbow/head recoil, not a static PNG shifted in screen coordinates.
Death: collapse to contact then stay down, no looping recovery.
No whole-image wave, skew, stretchy deformation, repeated static frames substituted for action, separately regenerated inconsistent AI face per frame or VFX baked in frame. Frame count must match authored poses, not arbitrary quota. For each action record key poses, inbetweens, per-frame duration, loop flag, contacts and presentation cue timestamps.

## 6. Export contract and naming
Isolated staging area: godot/labs/character_family/as_char38/production_pilot_v1/<actor_id>/{sources,layers,frames,atlases,previews}.
Names: <actor>_<dir>_<state>_fNN.png, <actor>_<dir>_<state>_atlas.png, <actor>.spriteframes.tres, <actor>_outfit_<variant>.png, <actor>_expr_<name>.png.
Export both composited body+weapon atlas for fast default AnimatedSprite2D, plus editable body-only/weapon-only source frames for future swapping. Effects separate. Nearest filtering and clear alpha; avoid texture filtering/mipmap blur on real game-size pixel display unless tested.
Required manifest: schema_version, identity_id, source SHA256, original prompt/edit route/provenance, layered source hash, dimensions, pivot, direction, state, actual frame count/duration/loop, individual PNG and atlas hashes, per-frame sockets, weapon grip/z-order, alpha and occupied rectangle, expression/outfit variant ids, visual/engine statuses and approval evidence. The manifest is a status report, not art approval.
Use the current proven Godot 4.7.2 AnimatedSprite2D/SpriteFrames or compatible atlas renderer. Runtime Skeleton2D/Bone2D not required; authoring-only cutouts permitted where they yield genuine pixel-corrected frames.

## 7. Mandatory fail-closed review gates
G0 SOURCE: exact bytes, SHA256, gender/identity proven, no replacement of prior approved sources.
G1 1X ART: user selects exact two novice identities, unified pixel family, silhouette and material outline; style approved separately.
G2 4DIR: front/right/back/left true turnaround, anatomy, same hair/face/outfit and visible correct grip; no cropped feet/weapon.
G3 LAYERS: editable true body, hair, face, outfit and weapon; occluded reconstruction; preview live swap of outfit/eyes/weapon with no seam tear. Explicit failure if only flattened PNG.
G4 MOTION: real distinct key poses, true separate states/directions, no baked effects; GIF and actual transparent PNG frame review.
G5 GODOT: official Godot 4.7.2 strict import and actual isolated GUI 1280x720; 1x, zoom .75/1/1.35, FPS/frame time/texture memory on 6 and 30 actively visible actors. Windows/Android hardware only PASS when real physical tests done.
G6 PROD: only after owner art approval and source/code verification; readonly visual adapter, no combat/state modifications.

Reject known problems: GIF without real editable art, different gender/face/ornaments between frames, vanishing sword, changing fan, wrong weapon hand, alpha matte, outline halo, foot skate, fake loop, unstaged action, unsupported save/equip claim.
Report 38/38 design mapping separately from X/38 visually approved, Y/38 fully animated and Z/38 integrated. Do not call one 8-frame combo six completed clips.

## 8. Evidence and open tools
Godot official AnimatedSprite2D: https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html
Aseprite docs slices and pivots: https://www.aseprite.org/docs/slices/
Aseprite CLI layered/tagged sheet: https://www.aseprite.org/docs/cli/
LibreSprite open-source multilayer and onion skinning: https://github.com/LibreSprite/LibreSprite
Godot optional 2D skeletons: https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html
Respect upstream licenses; third-party workflows are process references, not permission to copy proprietary sprite images.
