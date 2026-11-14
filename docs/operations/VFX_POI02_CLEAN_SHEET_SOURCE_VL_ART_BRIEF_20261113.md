# POI-02 — Xà Ảnh Quấn Mạch clean-sheet Source VL-quality study

**Owner direction**: R1–R5 are definitively OWNER_VISUAL_REJECTED. This is a NEW isolated scene, not a version bump or reworked Gaussian path.

Canonical skill: tmb.skill.poison.co_doc.active_02.human / Poison / Cổ Độc / SINGLE_TARGET=1. A scene-fixed target dummy is used solely for preview. No damage/target-selection/timing/status/DoT/SaveService/economy/PvE mutation. No rig.

## New image-backed art and verified origin

- Original painted serpent: bespoke AI-generated wuxia concept illustrated in this session; manually extracted using chroma and spine masking into transparent full-body image, head / eyes / teeth / scales / tapered energy tail. Then remastered as six 512×179 sprite poses with small image-space tail undulations, packed as 1536×358 3×2 WebP flipbook (assets/serpent-flight-atlas.webp). Sprite alpha/mix, NOT procedural polyline snake or additive white noodle. No commercial JX serpent pixels in the snake.
- Original bind/coil spiritual light: masked/cut out of the same original concept art at the target, saved separately at 320×350 (assets/serpent-bind-energy.webp). Additive blending so the dark cutout reference actor does not obscure the actual Godot target. Art QA must explicitly check for ghost-actor contamination, rhythm and clipping. If quality remains poor, rework rather than promote.
- Actual JX1 Wudu #63 impact only: 13 frames at 56 ms, played on fixed preview target starting at CONTACT_AT=1.63, rects/pivots directly from fx_manifest.json. Not an actual verified snake. Rights of commercial JX sprite for any external redistribution remain unverified.
- Source VL sword 150: visual quality / sprite layering / staging reference (36×30ms cast, 21×30ms hit), not copied into this serpent.
- No imported skeleton / rig. Characters: original repo's unchanged approved 320×384 idle cell.

## Five stage contract / timing
0.00–0.54 charge; 0.54–1.63 flight 6-frame alpha sprite; 1.63–2.57 contact + animated spiritual bind (JX impact plays only 1.63–2.358); 2.57–3.45 dissolve; 3.45–4.10 rest/loop.

## Implementation / art hold
Scene: res://labs/combat_lab/poison02/xa_anh_source_vl_remake.tscn.
Godot GL Compatibility 4.7.2, native 1280×720 and 1x. All rendered stages must be inspected in movie. This is an experiment; OWNER_VISUAL_PENDING until explicit review. Do not enable V6.3/PvE or call this production-approved. Physical Windows/Android perf, scale/LOD 6v8 and 30x40 remain untested.
## Internal R1 native artistic inspection and immediate R2 correction

R1 exact source db93d6cff55ef128c791c12251d92271d8938259 / official run #43484906760 TECH PASS (Godot 4.7.2 import/parse/focused). Actual frames inspected at 1.30, 1.55, 1.70 and 1.92 seconds. Original painted serpent clearly reads with scales, cobra head and fangs at native 1x; its end pose was small. **ART REJECTED R1** because the 1.70–1.92 bind overlay retained a visually obvious duplicate source figure / contamination. That is not a valid contact VFX.

R2 replaces the binding asset with a masked energy-only cutout, hand-tracing the spiral strokes and removing the source actor. Removes hard seam with feathered alpha. Also boosts serpent hero scale late flight (0.96 -> 1.19), bind sprite footprint, adds short 140-ms single contact flash. The new art remains image-backed, alpha front / additive bind, target still has no gameplay side-effects. Verify by fresh exact-SHA Godot video before any subjective claim.

## R2 review / R3 head-and-bind polish

R2 code SHA 3dbdc81688209a85da182ded486aed44740db764 tested via official run #43485904270, Godot Compatibility source movie 1280x720, focused PASS. Real frames 1.30, 1.55, 1.70 and 1.92 reviewed: cobra flight now clearly has animal head/fangs/scales at native size; source-actor ghost was successfully removed from the bind art. Remaining defect: bind looks like disconnected translucent horizontal streaks and loses animal identity.

R3 reauthors bind WebP color contrast brighter jade, adds cropped alpha-head sprite asset (from the new original serpent, NOT a JX serpent), and keeps the cobra head visible at target shoulder while surrounding coils bind. This remains an original image-backed VFX lab, not physics rigging, not combat. Render/inspect native motion before art acceptance.

## R3 video review / R4 image-backed bind motion

R3 tested SHA 8cd107fe75a7f5907f8eee8938b38aa5d456995a / [official workflow #43486804186](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43486804186) TECH PASS. Native 1280x720 movie inspected as full timeline plus phase frames (1.30,1.55,1.70,1.92,2.15,2.38). Cobra head/fangs remain visible in contact; no embedded duplicate original target. Remaining objective visual defects: head floats above the dummy, binding strokes move too little across time.

R4 repositions authored painted head near target shoulders for a clear bite and animates the *already painted* binding sprite via a small non-rigging Godot CanvasItem UV swim shader with externally supplied paused clock. No new geometric snake, no combat cues. Retain owner visual gate pending video art inspection.

## R4 final executed evidence / visual QA (2026-11-13)

- Exact tested code SHA: `ea41c88cd710eb5f6e9eeb551e226d54a4c30b6d`.
- [Official Godot movie run #43487920474](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43487920474): SUCCESS. Godot `4.7.2.stable.official.ed1daf0bf`, Linux Mesa llvmpipe Compatibility, strict project import/parse/focused script exit 0 and `VFX_POI02_FOCUSED_RESULT=PASS failures=0`.
- Native `--write-movie` Godot output `1280×720`, 246 frames at fixed encoded `60 fps` (4.10s). These are NOT measured physical Windows or Android frame rates. Genuine source movie, 14 same-clock PNG checkpoints and native filmstrip; artifact `vfx-poi02-ea41c88cd710eb5f6e9eeb551e226d54a4c30b6d`, ID `14068092446`.
- Inspected charge, release, early flight, mid-flight, near-contact, impact, bind and dissolve on native footage and 20-frame timeline. R4 fixed R3's head placement relative to actual dummy and created subtle frame-continuous binding motion from image-backed additive texture. First-phase head/fangs/scales remain readable at native 1×. Fixed R1's duplicated target ghost remains absent.
- ART self-review: recognizable serpent flight 4/5; luminous image material 4/5; trajectory/wing-tail motion 3.5/5; on-target head contact 3.5/5; staged dissolve 3.5/5. Defects: energy tail can appear detached during parts of flight, bound body still more like separate spirit coils than an actual continuous snake, stage is a simple lab slate floor. The artistic bar of Source VL sword is a *reference*, not a proven parity claim. **OWNER_VISUAL_PENDING, not ART APPROVED**; recommended only as a distinctly improved candidate for owner viewing, not a production release asset.
- Scope: isolated `poison02` scene, 3 artist-supplied original sprite WebP assets, one Compatibility CanvasItem shader, separate test/CI/docs. R5 rejected unchanged. No actual Combat V2, HP, target, poison tick, MapBattle V2, V6.3, SaveService, economy, rig or PvE changes. 6v8/30×40 crowd and physical hardware remain pending. Separately failing unrelated v63-quyen-doc-matrix workflow is not part of this focused PASS.

## Owner positive feedback and bind-only R5 correction — 2026-11-14

Owner: overall fairly good and very satisfied with the visual result; small defect remains in Xà Ảnh quấn mạch bind. This is positive visual feedback, NOT explicit release/live PvE acceptance. Preserve successful serpent flight.

Real R4 frames at 1.92 and 2.15 seconds show painted coils sprawling left of victim and painted head hovering above shoulder. New POI02 R5 is intentionally bind-pose ONLY: tightened bind sprite around torso and lowered head nearer shoulder, with no changed sprite assets, V9/JX sources, shader, flight trajectory/timing, actors, gameplay, or save.

Official exact-source tested SHA `64d431c9426432c4ea3908a1197f139d5cac5cf0`; Godot 4.7.2 GL Compatibility [run #43538532134](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43538532134) SUCCESS: strict import/parse/focused `VFX_POI02_FOCUSED_RESULT=PASS failures=0`, 1280×720 native movie 4.10s (246 frames fixed/encoded 60 FPS, not hardware performance). Artifact `vfx-poi02-64d431c9426432c4ea3908a1197f139d5cac5cf0` ID 14091100152, 14 time checkpoints and filmstrip.

Side-by-side same-clock R4 vs R5 at 1.92s inspected. Bind is more closely anchored to torso and snake head is closer to shoulder. Still visually separate spiritual coil ribbons at some times, so do not claim finished anatomical wrap or full Source VL parity. Status `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD`; no live integration, no rig, no Codex, no merge/new branch. VFX-focused PASS does not erase unrelated v63-quyen-doc-matrix failure.

Reusable pipeline: source-quality storyboard -> recognizably painted sprite/flipbook -> light materials/impact on separate layers -> native Godot film -> 8+ clocked frames -> same-camera R4/R5 comparison -> only modify rejected motion segment while freezing approved flight. Technical PASS != visual approval.