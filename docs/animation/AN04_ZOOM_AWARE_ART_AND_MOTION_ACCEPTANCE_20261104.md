# AN-04 V3 — Zoom-aware animation quality gate and character scale (2026-11-04)

**Decision source:** The owner rejected using a tiny 70-px character as the overriding optimization target and remains unhappy with the rigid nine-large-piece composite. The player can zoom the in-game camera. Static coverage, 122 focused checks and 52 preview frames reported by Codex do not constitute animation/art acceptance.

**Priority:** Preserve the high-resolution original Hắc Ảnh visual identity and fluid motion at real gameplay zoom levels, while keeping hair/clothing sufficiently simple for reliable 2D production. Do NOT attempt pixel-perfect recreation of every cloth ornament. Do NOT compensate for rigid-looking motion with a static-overlay cover.

## 0. Current evidence / branch boundaries

- Owner-reported local Codex QA: official Godot 4.7.2, 122 focused assertions, six real 1280×720 screenshots, 52 preview frames Idle/Walk/Attack, no cosmetic/gameplay claims; rigid V2 from ~9 silhouette-derived large layers, v1 retained. Local branch `qa/an04-isolated-20261103`, HEAD reported `5e6fdd966bdf710b71e2a1539bb712e44069a4bb`; **not yet committed/pushed**. Do not confuse this checkout's SHA or stage any unrelated changes with the AN-04 GitHub branch.
- Remote PR #74 `feature/an04-2d-cutout-rig-pilot-20261103` was contract-only at `1a0c65fc85b734923d9bf9b46e9fd1463f1329ed` when checked. Actual local AN-04 source/PNG/scripts were NOT present on PR #74 yet.
- Explicitly leave unrelated dirty files including `godot/.gitignore` and `tools/godot/Verify-P3-6A-Playable-Slice.ps1` unchanged unless independently justified. Preserve previous AN-04 V1 and V2 as evidence; do not discard canonical image or paintover logs. Never reset/clean/merge canonical checkout.
- Forbidden: main, PR #68/#69/#71, RC, PvE, Combat V2, SaveService, balance, canonical saves, default main scene, Tripo purchase.

## 1. REDESIGN GOAL — quality at 1x AND camera zoom

- The game has a variable-zoom Camera2D. The existing old note “60–75px chibi” describes a past small-map view, **NOT a maximum source resolution, fixed future height, or sole art-acceptance gate**.
- Character graphics should originate from the highest usable master and part texture resolution. **Do not bake/downsample the rig input to 70 px, then upscale those pixels for zoom.**
- Capture the **real** game camera limits/zoom configuration before deciding the final on-map character-height policy. If inspecting actual game camera is out of AN-04 scope, **do not edit it**: use a separate lab camera with configurable scale/zoom and clearly label all measurements as pilot only.
- Visual QA must show character-height previews approximately **80, 140, 240, and 360 rendered pixels** in real 1280×720 Godot captures (or precisely report actual sizes if scene/camera constrains them). These four sizes are **comparison samples**, not forced permanent engine constants. At 80 px silhouette and eye glow must read; at 140 and 240 px arm, knee, sword, cloth silhouette and edge quality must remain credible; at 360 px verify closeup/detail and visible seams.
- Also capture true in-game camera zoom bounds and screenshots when this can be done non-destructively without changing gameplay. No invented camera zoom values. No unnatural camera stretch or cropping.
- At all scales preserve void face, bright violet eyes, gold-violet crown and armor, flowing but simplified black-purple hair, boots, and readable distinct weapon grip. Show **unarmed and armed**, separate from VFX.

## 2. V3 ART / RIG ARCHITECTURE — 14–18 sensible moving pieces, not 9 stiff panels, not 22 shredded crops

Keep an independently usable **master neutral** with visible A-pose shoulders, elbows, hips, knees and feet. Cut from a reconstructed layered illustration (paint behind joints), not a naive alpha silhouette crop. Aim for roughly 14–18 meaningful visual groups, adjusting to the character after viewing actual animation:

1. `head_face_hairfront` + attached crown (rigid, preserves eyes/face identity).
2. `hair_back` as one smooth mass, possibly a single separate short ponytail for small lag.
3. `torso_chest_armor_belt` as one main rigid chest/waist visual if its armor never animates.
4. left/right **upper arms**, separate left/right **forearms+hands** (4 distinct articulated arms).
5. left/right **thighs**, separate left/right **shins+feet** (4 distinct articulated legs); optional feet if testing shows ankle articulation is required.
6. one central front coat tab, left/right short coat tails attached at hip, optional back cape one continuous piece (3–4 cloth pieces).
7. optional detachable sword is **outside** the body part budget, attached to right wrist socket.

This is a recommended decomposition, not a hardcoded 18-file quota. Joints must have hidden painted overlap. Key design requirement: **separate elbow and knee rotational degrees of freedom**. Foot and sword must not appear disjointed. Hair and coat move subtly but cannot wrap around legs or obscure animated gait.

### Not acceptable
- V2's nine large parts unchanged except for z-order, decorative dust/smoke, or static underlay.
- Removing elbows/knees to make a test pass or claiming 122 asserts quantify beauty.
- Giant intricate strips hidden at 70px but revealing amputated joints at 240+ px.
- Misreporting multi-direction animation or inventing missing back-body pixels.
- Using a 70px exported sprite as master for 2x/3x rendering.

## 3. Frame-rate / animation quality gates

**Idle:** subtle breath, head/hair lag and cloth sway. Fewer moving parts are fine if motion is intentional and loops smoothly.

**Walk:** alternating thigh/shin articulation at real knee and hip pivots, arms swing in counterphase, step/foot plant readability, no obvious foot skating through stance. Animation must be observed at 80/140/240/360 px, including slow-motion review at 240+ px.

**Attack:** readable wind-up, slash/impact visual phase, follow-through and neutral recovery with elbow and torso articulation; sword remains on actual right-hand socket through the stroke. Sword/VFX separate from body, no combat events.

**Quality evidence** must include actual Godot screenshots AND at least one real short animated sequence per action (encoded video or frame strip with enough meaningful poses) at >= 240px scale, together with a representative small-map view. Static screenshots or all-frames-distinct hashes are not enough.

### Visual QA gates, independently reported
- `ENGINE_PASS`: import/parse/focused assertions 0 failing and genuine Godot screenshots/frames.
- `LAYER_PASS`: neutral recomposition from true complete PNG layers, no static-only hidden patch crutch; proper pivots, no holes or duplicate chest/hair.
- `MOTION_PASS`: clips visibly clean at 140/240/360px, knee/elbow bending convincing, feet don't clearly skate.
- `ZOOM_PASS`: readable original design and no catastrophic seams/clipping at the specified comparison sizes (or actual camera range), screenshot evidence with measured actor bounds.
- `OWNER_VISUAL_PENDING`: until owner explicitly approves reference imagery. No claiming OWNER PASS by code.
- `ANDROID_PENDING`: actual device not yet tested.

Do not require pixel-perfect alpha equality with one flattened master. Alpha-area coverage statistics may be retained as diagnostics, but do **not** substitute for visual correctness at zoom.

## 4. CODEX EXECUTION ORDER (do not send owner another general plan)

1. Inspect actual local AN-04 workspace and protect unrelated dirty files. Read Issue #73, PR #74, this file, prior cutout V1/V2 review, existing detailed rig scripts and source master provenance. Compare static V2 UI image with actual captured frames.
2. Implement **V3 art reconstruction in isolated local AN-04 path**, preserving V1/V2 output for comparison. Favor a small set of fully redrawn complete limbs and cloth assets (reasonable paint-over) rather than repeated fragment crops or a model redesign. Work from approved neutral Shadow artwork; preserve void face.
3. Add elbow/knee pivots and complete sprite geometry. Rebuild `Skeleton2D/Bone2D` with correct rest transforms and right-hand independent sword socket. Static coverage patches must not be needed during rotation. Do NOT edit PvE/Combat V2/SaveService/default game scene.
4. Update the standalone Lab to expose **zoom presets** (80/140/240/360 rendered actor height or similarly measured sizes), skeleton overlay, armed toggle, action switch, speed/pause, and optional side-by-side V2 vs V3. Capture at 1280x720 engine framebuffer, not composed mockup.
5. Run actual Godot 4.7.2 focused tests and **look at the frames** to improve IK/pose/transitions. Compare V2 versus V3 at small/default and zoomed sizes; prepare compact 3-clip video/GIF if possible. Do not declare visual PASS based on scripted checks alone.
6. On local QA branch, validate changed files and only AN-04-specific changes, then migrate/push to the AN-04 remote PR #74 branch using safe cherry-pick/rebase or patch application after verifying HEAD. Do not commit unrelated dirty files. Keep PR draft.
7. Report source SHA, actual screenshots/videos, created part files, repaint provenance, Godot console logs and PASS/FAIL/PENDING table. Recommend the smallest next concrete fix based on visual evidence.

**Owner target:** A clean, recognizable, high-resolution chibi that can be zoomed in naturally, not a tiny 70px technical rig. The result can use simpler hair/robe than the original, but must preserve the distinctive Shadow visual identity.
