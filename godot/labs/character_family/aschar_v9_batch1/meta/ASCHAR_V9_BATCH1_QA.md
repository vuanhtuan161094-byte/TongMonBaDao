# AS-CHAR V9 — Batch 1 candidate QA (AS-CHAR-48/49)

- Base PR HEAD when the local candidate work began: `5e0ffb83d85105a5e2e9b7a4a22c48882f8e0413`. PR #72 HEAD at the start of artifact upload was `95278e0120794590ee76176204301bb11abe9f51`; the branch continued receiving parallel VFX commits during upload. The asset commit is appended to the latest live head with an expected-SHA lease. The review project is a local isolated payload, not a native Git checkout; it does not modify or claim to reproduce the full PR tree.
- Official engine: Godot 4.7.2 stable `ed1daf0bf`, Windows OpenGL Compatibility, Intel Iris Plus (OpenGL 3.3).
- Native Godot renders: exit 0; viewport 1280×720. Final actual Godot MovieWriter outputs: AS48 review 180 frames/60 FPS/3.0s, AS49 Walk 180 frames/60 FPS/3.0s, AS49 Attack review 180 frames/60 FPS/3.0s. PNG captures were saved from `get_viewport().get_texture().get_image()`.
- SpriteFrames: four clips and 16 distinct authored/registered source poses across AS48/49. AS48: `Walk_Front` loop at 8 fps and body-only `Attack_Front` at 7 fps. AS49: `Walk_Front` loop at 8 fps and body-only `Attack_Front` at 7 fps. Each clip has four source poses. Frames are whole-body images; no rig, bones, or body-part split.
- AS49 Attack_Front source sequence is windup → draw initiation → release/contact pose → recovery. Godot verification exited 0: `AS49_ATTACK_VERIFY=PASS clips=2 frames=8 attack_sources=4 distinct=true rgba=true rig=none weapon_overlay=separate_pending`. Atlas and SpriteFrames builders exited 0 after an import was run between atlas generation and resource loading.
- Source-cel and atlas SHA-256 values are recorded per frame in the AS48/AS49 manifests; the package-wide file list and content fingerprint are under `meta/ASCHAR_V9_ARTIFACT_SHA256.csv` and `meta/ASCHAR_V9_CONTENT_FINGERPRINT.txt`.
- Map-scale preview uses the 400×440 cel at scale 0.17 (approximately 73–75 logical pixels tall); zoomed comparison is shown beside it.
- A visual pass found the review actors floated above their baseline. The review scenes now calculate the 430px cel baseline against the Node2D center; the native stills were recaptured and the feet align to both display baselines.
- Attack clip is body-only: no approved weapon overlay or measured per-frame grip metadata has been added. It is not ready for runtime combat integration.
- Coverage: **4/576 clips have technical evidence**, 572/576 remain not started; visual owner approval is 0/576. AS48 Attack and AS49 Attack are body-only; sword selection, overlay art and measured per-frame grip/pivot/occlusion metadata remain pending. Two masters are present in this review package (AS48/49); no master is owner-approved by this work.
- Native images include AS48 Walk/Attack, AS49 Walk and four AS49 Attack pose inspections. The earlier headless MovieWriter attempt failed (`texture_2d_get` null from the dummy renderer, exit `-1073741819`). Subsequent real OpenGL Compatibility MovieWriter runs passed; the earlier failure is retained in logs and not hidden.
- Godot import/runtime logs include environment warnings: Windows root certificate store unavailable; sandbox cannot write Godot `user://` logs/editor settings or shader cache; import returned exit 0. MovieWriter warned disk free space was about 7.70 GiB; all three final ~9.1 MB, 3.0-second movies completed.
- Prompt provenance: exact prompts are documented in `AS48_V9_PROMPTS.md` for the four Attack cels. The pre-existing AS-CHAR-48 Walk cels have their imagegen source hashes in the manifest; original verbatim prompts were not materialized into this staging folder, so that prompt archive remains a traceability debt. AS-CHAR-49 Walk prompt descriptions are archived in `AS49_V9_WALK_PROMPTS.md`.
- Production status: `CANDIDATE / OWNER_ART_APPROVAL_PENDING`. No gameplay, VFX, SaveService, economy, or production asset wiring was modified. This is not a full 12-school or 576-clip completion claim.

# AS-CHAR V9.1 — consistency audit / registration repair

**Scope:** the four existing Kiếm Tu Front candidate clips only. PR #72 was observed at `b95af5e5f77f2244f74e201101642ee7e33527bd` before this isolated package work. The test project is an isolated local review package, not a native full checkout of the live PR tree. No production renderer, gameplay, combat, VFX, SaveService, or economy files were touched.

## Identity and storyboard locks

Frozen master candidate hashes and identity keys are in `ASCHAR_V9_IDENTITY_LOCKS_V91.json`. They remain **OWNER_ART_APPROVAL_PENDING**. These are the existing V9 AS48/AS49 candidates, not a declaration that they are approved for the unified production family.

- Walk_Front: left contact → passing → right contact → passing → loop. Keep body center/pivot stable; contact feet land on the shared ground row; opposite arm swing; hair/sash follow the body.
- Attack_Front: windup → guard/draw rise → release/lunge → recovery. This is still **body-only**. It has no selected sword overlay, per-frame grip, rotation, front/back occlusion, or hit-contact metadata; it is not an integrated Attack asset.
- Stable visual review anchors: crown/hair shape, eye line and face width, shoulder line, waist/ornament, dominant hand/grip, plant-foot contact, trailing robe/sash. These are visual landmarks only, not a rig.

## Audit result and repair

Contact, close face and onion-skin sheets were made from the original registered cells. Manual comparison found no major identity changes in face, hair ornaments or costume palette across the 16 existing poses. The clear failures were registration:

| Clip | Original visible shoe rows by frame | Finding |
|---|---:|---|
| AS48 Walk | 429, 429, 429, 425 | final passing pose floated 4 px |
| AS48 Attack | 388, 424, 425, 422 | windup floated 41 px and was only 288 px high vs 338 px next pose |
| AS49 Walk | 411, 396, 408, 413 | all poses floated; variance 17 px |
| AS49 Attack | 426, 426, 429, 422 | recovery floated 7 px |

The original source cels and V1 atlases/resources were preserved unchanged. A separate V2 registration set aligns all visible shoe rows to 429 (pivot line y=430). Only AS48 Attack frame 00 was uniformly scaled 1.173611× to 338 px body height, centered, and anchored. Other corrections are whole-cel translations for pivot registration. No pose was synthesized, no body part was moved, and no in-between interpolation was used.

| Corrected clip | V2 shoe rows | Distinct RGBA cels |
|---|---:|---:|
| AS48 Walk | 429, 429, 429, 429 | 4/4 |
| AS48 Attack | 429, 429, 429, 429 | 4/4 |
| AS49 Walk | 429, 429, 429, 429 | 4/4 |
| AS49 Attack | 429, 429, 429, 429 | 4/4 |

The main contact/onion/face sheets and transition metrics are under `captures/`. The raw V1 frames remain available for direct comparison.

## Godot evidence

- Engine: official Godot `4.7.2.stable.official.ed1daf0bf`, Windows, OpenGL Compatibility 3.3, Intel Iris Plus.
- Import after V2 atlases: exit 0.
- V2 registered-cel/atlas builder: exit 0; 4 clips / 16 cels / 16 unique hashes / RGBA / baseline row 429.
- V2 SpriteFrames builder: exit 0; Walk 8 authored FPS and loop enabled; Attack 7 authored FPS and loop disabled.
- Focused Godot verifier: exit 0; original and corrected SpriteFrames loaded; 16/16 V2 cells are 400×440 RGBA, distinct, hash-matched and anchored at row 429.
- Two native Godot comparison videos were recorded at 1280×720, 60 capture FPS, 360 frames / 6 seconds each. Each puts original on the left and V2 on the right, displays both magnified at 0.50× and at map size 0.17×, and plays Walk then Attack. The authored clip rates remain 8/7 FPS; 60 FPS is only the movie capture rate.
- Native viewport screenshots were captured from `get_viewport().get_texture().get_image()` at walk and attack poses. The video is a Godot MovieWriter render, not physical mouse/desktop acceptance.

Logs: `logs/consistency_v2_import.*`, `logs/build_consistency_v2*`, `logs/verify_consistency_v2_final.*`, `logs/consistency_AS48_native.*`, `logs/consistency_AS49_native.*`.

## Gate status and limits

- Registration consistency: **TECHNICAL_PASS** for these four Front clips.
- Manual identity comparison: no obvious face/hair/costume drift in supplied contact sheets; still candidate art, not owner approval.
- Walk loop closure: checked by adjacent/onion sheets and the captured Godot playback. No extra frames were invented to improve similarity. Owner visual acceptance remains pending.
- Full motion quality / limb-level foot sliding: **PENDING_OWNER_REVIEW**. Fixed foot pivot removes whole-cel vertical float; it does not prove perfect local foot contact between poses.
- Sword overlay/grip/occlusion/contact: **PENDING**; no Attack is called weapon-complete.
- PHYSICAL_GUI: not performed. Native MovieWriter is not a physical desktop mouse test.
- Scope remains 4/576 existing clips technically evidenced; 572 clips not started. No 12-school completion claim, no owner-approved art claim, no production integration.

Environment warnings are unchanged from the prior review package: sandbox cannot write Godot `user://` logs/shader cache and Windows root certificate store is unavailable. Native GL runs exited 0. MovieWriter warned about ~7.08 GiB free on C:, but completed both videos successfully.

# AS-CHAR V9.1 — referenced-pose continuity and weapon overlay candidate

## Continuity pipeline proof

- Kept the original V1 source PNGs and their atlases/resources unchanged. The four V2 registered clips remain separate candidate resources.
- Added one new AS48 Attack_Front transition cel by referencing three images in the same generation call: the frozen AS48 master, adjacent key pose 01 (guard rise), and adjacent key pose 02 (release). The generated raw PNG is preserved beside its registered 400×440 candidate output. Metadata records the source/reference SHA-256 values, crop, scale, baseline and current approval state.
- The new cel is a real unique RGBA drawing, not an interpolation or mirrored pose. It was normalized by a single proportional crop/scale and placed at visible foot row 429. A 5-pose review-only SpriteFrames resource contains it; production resources were not changed.
- Godot native 1280×720 contact sheet and 6-second comparison video show the original 4-pose sequence beside the 5-pose candidate at authored 7 FPS. All 4 baseline and 5 candidate poses were visited. A manual visual check found the face, hair silhouette, costume colors and motifs visually consistent enough to continue review; this is not an owner art approval or proof of perfect motion.

## Weapon overlay technical slice

- Generated one original silver/navy/cyan Kiếm Tu jian candidate using the two owner-supplied weapon images only as craft/material references; the generated silhouette is different and remains `RECREATED / CANDIDATE_OWNER_ART_APPROVAL_PENDING`.
- The weapon stays an independent transparent PNG layer. Four per-frame hand anchors and rotations are recorded in `AS48_ATTACK_WEAPON_OVERLAY_CANDIDATE.json`; anchors were placed manually on the 400×440 poses and reviewed with visible markers in Godot. The sword is drawn behind the whole body cel to avoid splitting the body.
- Native 1280×720 capture and 6-second playback cover all four Attack poses at authored 7 FPS. The preview also shows a 0.17× map-scale view. No attack VFX, damage or Combat V2 event was added.
- Limitation: because the body is one unsegmented cel, the weapon cannot be partially hidden behind the wrist while remaining in front of the torso. The current full-body-behind order is a technical study; final grip/partial occlusion still needs art review and a compatible approved pose/mask strategy.

## Exact local QA scope and result

- Official engine: Godot `4.7.2.stable.official.ed1daf0bf`, Windows OpenGL Compatibility 3.3, Intel Iris Plus.
- Source limitation: all V9.1 work was run from the isolated review package, not from a native full-repository checkout. PR #72 live HEAD was read from GitHub as `5082201970f3d0335f577a661859e7cb74f36707` before publication. The commit added to PR will contain these exact package files, but this does not claim that full PR source was tested.
- `--headless --editor --path <review package> --quit`: exit 0; no parse failure. Environment warnings about user:// writes, editor settings and Windows root certificates remain.
- Registration verifier: exit 0; AS48/49, four clips, 16 distinct RGBA registered frames at baseline 429, Walk 8 FPS and Attack 7 FPS.
- Transition candidate builder and verifier: exit 0; 5 unique RGBA frames, 400×440, all baseline 429, Attack 7 FPS, reference chain recorded, production integration false.
- Native OpenGL Godot runs: (a) AS48/AS49 before/after consistency movies, 360 frames each at 60 capture FPS, clips remain authored 8/7 FPS; (b) AS48 weapon overlay movie, 360 frames at 60 capture FPS; (c) AS48 4-vs-5 reference-chain comparison, 360 frames at 60 capture FPS, Attack authored at 7 FPS. These are native MovieWriter renders, not physical mouse/desktop acceptance.
- PHYSICAL_GUI: PENDING. Art owner approval: PENDING. Four-direction masters, the other five actions, 11 other schools and the rest of 576 target clips: not complete. No 12-school completion claim.

Evidence files are referenced from the index and artifact SHA-256 manifest. Final stdout/stderr logs are in `logs/evidence/`; transient failed iterations remain local and are not presented as passing evidence.

The first overlay anchor verifier rejected the frame 01/02 points because they missed hand color regions. I re-measured the skin components on all four native cells, moved each anchor, re-rendered the 1280×720 preview/video and reran the anchor verifier: **4/4 near hand pixels PASS**. The per-frame body hashes remain unchanged.

## V9.1 GitHub delivery state

- The committed V9.1 assets and viewport captures are listed in meta/ASCHAR_V9_1_DELIVERY_SHA256.csv. The two 6-second before/after AVI files and supplemental weapon/transition AVIs remain in the isolated local review package; they are not listed as GitHub-hosted videos.
- The uploaded Godot viewport PNGs are real get_viewport().get_texture().get_image() captures. They are not physical Windows desktop or mouse evidence.
- Parent PR source identity at start of this publication: 5082201970f3d0335f577a661859e7cb74f36707. These animation tests were run against the isolated project payload, not the complete PR source tree.


## Final isolated-package rerun — 2026-11-18

- Official Godot 4.7.2 ed1daf0bf; import exit 0, no parse errors. The sandbox emitted root certificate store, user:// and editor-settings write warnings; they are preserved in paired stderr logs and are not treated as clean-environment evidence.
- verify_consistency_v2.gd: exit 0, PASS marker; 2 identities, 4 clips, 16 unique RGBA cells, baseline 429, Walk 8 FPS / Attack 7 FPS, V1 resources preserved.
- verify_attack_transition_candidate.gd: exit 0, PASS marker; 5 unique referenced cels, 400×440, no interpolation, candidate only.
- verify_weapon_overlay_candidate.gd: exit 0, PASS_LIMITED marker; 887×1774 RGBA hash match and 4/4 anchors near hand pixels. Whole-body ordering is the only occlusion demonstrated; partial hand-over-hilt occlusion remains pending.
- Exact scope is this isolated review payload; no claim of a full native PR checkout or full-project exact-SHA validation. Physical GUI, owner art approval and Android remain pending.


