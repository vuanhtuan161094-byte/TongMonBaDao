# TMB V4 — Nữ Độc Tu: full sprite asset handoff (2026-11-09)

**Owner direction:** Only final useful delivery, preserve the approved four-way Shadow Pixel-Chibi female, NO blink/whole-body sea-wave Idle; clear Walk/Cast/Attack; rigorous visual/technical QA. Scope is presentation-only; **DO NOT change V6.3 gameplay, SaveService or existing V3**. Work on Draft PR #72 only; no merge/new branch.

## Source authority

Approved four-way identity is user-supplied `image(20261109-102800).png` with SHA-256 `435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118`. **Do not use later unrelated purple character images.** Female neck/shoulder adjustment still requires a genuinely approved re-draw; do not alter face/robes/hairstyle while hiding that issue.

## Local user artifact (not uploaded to GitHub repository)

- Download file: `TMB_V4_NU_DOC_TU_4HUONG_6TRANGTHAI_240FRAME.zip`
- SHA-256: `ca9b4e0d2542242e811cfd3d010befb02cc81cf6aeb895a507c1db4e89196361`
- 31 entries. Four registered directions front/left/right/back; 6 states: Idle 8, Walk 12, Cast 12, Attack 12, Hit 6, Death 10 frames/direction = **240 animation cells**, 160x192 RGBA, logical foot pivot (80,179), 6 PNG atlases, generator source, SHA manifest, QA report, isolated Godot viewer code, self-contained HTML preview, 1280x720 MP4 rendering of raster animation.
- No independent AI frame redraw; articulation uses one approved registered raster source, mechanical shoulder/leg pivots, not source PSD/hand-painted complete skeletal animation.
- **Idle correction:** all eight Idle cells in each orientation are exact copies of approved registered view; no blink, no wave, no global translation.
- Cast and Attack key poses have visibly distinct limb extension, staged release marker at frame 7 (presentation only). Hit and Death supplied but require visual gameplay gate before production.
- `VERIFIED_QA.json`: **STATIC PASS** 240 frame cells, atlas SHA, alpha corners, no frame-edge clipping, unchanged Idle, Walk wrap check and non-identical Cast/Attack pose. ZIP integrity PASS. JS source syntax tested `node --check` PASS.
- Chromium visualization attempted, blocked by local `net::ERR_BLOCKED_BY_ADMINISTRATOR` for both file and localhost navigation. These attempts **do not count as browser PASS**.
- **Official Godot 4.7.2 / Android / real PR #72 V6.3 combat video: NOT EXECUTED.** No Godot executable available in current isolated local runtime, and binary files are attached to conversation only; they have NOT been pushed to source repo. The included Godot viewer is code pending import/parse test; it is not proof of runtime acceptance.
- **ART QA:** mechanical cutout technique leaves risk of unnatural arm/robe seams, especially rear view/Hit/Death. Technical tests are **NOT** 8/10 aesthetic acceptance; owner final approval remains PENDING. Do not replace existing production female/V3 art or claim polished playable sprite from numeric tests alone.

**Acceptance:** source identity LOCKED; full 4-way 6-clip sprite pack CREATED + STATIC TESTED; official Godot import/scene/combat visual acceptance PENDING. Gameplay, economy, SaveService and original VFX binaries unchanged.
