# AN-04 — CODEX EXECUTION CONTRACT: Hắc Ảnh Kiếm Tu 2D cutout (2026-11-03)

**Status:** OWNER-AUTHORIZED 2D IMPLEMENTATION HANDOFF, NOT IMPLEMENTED/NOT QA PASS.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`  
**Dedicated branch:** `feature/an04-2d-cutout-rig-pilot-20261103`  
**Branch base:** PR #69 / `fix/an02-1-shadow-lab-qa-20261103` at exact `1f083854defb3324722a1f05d2780c69c9cd3dd0`.  
**Compare only:** PR #71 AN-03 3D, owner reports QA Godot 4.7.2 official (22 focused, 4 actual 1280x720 screenshots, 46 768px frames), reported HEAD `1ce57828c4d094c2206747c2ce04bd0386bedde8`. AN-03 remains draft and MUST NOT be edited.  
**Owner intent:** CODEX MUST DO THE WORK (find suitable owner-provided image, segment it, reconstruct hidden pixels, rig/animate/test/capture) rather than send the owner back to Git/PowerShell/Blender. Zero Tripo, zero paid render, zero purchase. One character, one camera/direction, three actions first.

## I. Required authority & safety, before touching files

1. Read `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/DISCIPLE_MASTER_SCHEMA.md`, `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`, `.agents/skills/tmb-sprite-animation/SKILL.md`, `.agents/skills/tmb-asset-gate/SKILL.md` and the AN-02/AN-03 visual/QA reports. Inspect current live GitHub refs. Earlier chat text is not engine/source proof.
2. Single writer for AN-04 only. Work from the isolated AN-04 branch using a NEW, non-conflicting worktree on E: (e.g. `E:\TongMonBaDaoWorkspace\QA_Evidence\AN04\repo`); inspect `git status`, `worktree list`, tracked/untracked and user saves BEFORE creating. Never clean/reset/force/overwrite an existing E: worktree or Codex session.
3. **Allowed:** AN-04 asset folders, AN-04 scripts/scenes/tests, AN-04 launcher in this branch, AN-04 documentation/checkpoint/handoff for evidence. **Forbidden:** `main`, PR #68/#69/#71 source branches, RC, PvE/Combat V2/SaveService/save/autoload, canonical main scene/project orientation, balance, existing Source A files, any merge or purchases. Godot 4.7.2 official, 1280×720 landscape.
4. Do not silently convert this request back into AN-03 3D, paid Tripo, Blender, image-per-pose AI sheets, pseudo eight-way animation, or a procedural capsule character labeled as the owner's Shadow. If any tool/workspace does not support a task, record a precise BLOCKED status rather than pretend completion.
5. Do not delete proprietary source files, replace a user's original image, or hide provenance. New/converted assets must have checksums and transformation notes.

## II. ASSET_GATE (this is the real bottleneck)

**Verified remote repo scan on 2026-11-03:** Tree of AN-03 branch contained original Source A actor atlases and AN-02 shader, but **NO independently identified high-resolution Hắc Ảnh Kiếm Tu original layered/single master PNG or GLB/FBX** in the repository. Concept screenshots generated/shared in this ChatGPT conversation are **NOT automatically available to Codex, GitHub or the local E: workspace**. Do not claim such image was transferred merely because this handoff exists.

**Execution order — CODEX must search, not push this onto owner automatically:**
- Inspect the local Windows E: game workspace, adjacent owner-provided art/asset staging directories and attachments actually visible to the Codex session. Search only reasonable image file extensions (`.png/.webp/.jpg/.jpeg/.psd/.ora`) without destructive operations; list exact candidate paths, dimensions, transparency, SHA-256 and small contact-sheet thumbnails for owner review when candidates are ambiguous. No external downloads or paid account calls.
- Candidate must be a full-body, high-resolution owner-approved **Hắc Ảnh Kiếm Tu** concept, ideally front-ish neutral with clearly separated arms and legs, no embedded sword/VFX. A 3D Tripo screenshot is NOT automatically a good rig source. Distinguish a portrait, pose sheet, composite image, or already animated sprite atlas.
- If a legitimate source is found: copy only to `godot/assets/characters/hac_anh_kiem_tu_2d/source/shadow_master.png` (convert losslessly when appropriate), record source origin, dimensions, SHA-256, transformation notes and verify that the owner permits committing the resulting asset. Keep original intact; do not auto-add gigabytes or unrelated artwork.
- If the usable master is MISSING: stop claiming visual/art success. **Still implement the reusable standalone AN-04 rig scene, asset schema, socket, tests and preview using explicitly labeled TECHNICAL PLACEHOLDERS only when worthwhile**, and produce `BLOCKED_SOURCE_ART` and a precise one-line request: 'Cần một PNG toàn thân Hắc Ảnh Kiếm Tu chất lượng cao, không cầm kiếm, gửi vào phiên Codex hoặc đặt tại [chỉ dẫn path thực có]'. Do not fabricate painted Shadow cutout parts from unrelated Source A or random AI images and call that the original character.
- If source exists but flattened/occluded: produce a transparent overlays diagnostic / map `source_coverage.json` with per-part AUTHOR_SOURCE / EXTRACTED / REPAINTED / UNRESOLVED, lost region, confidence and reference proof. Cropping transparent gaps is NOT reconstructing the occluded arm/leg/tunic.

## III. Real 2D parts + pivot/occlusion contract

Suggested root: `godot/assets/characters/hac_anh_kiem_tu_2d/`.
- `source/`: immutable master + provenance; `parts/`: transparent per-limb PNG; `metadata/`: pivots/z-index/bounds/occlusion/corrections manifest.
- At minimum: head, front_hair, back_hair, torso, left/right upper_arm, left/right forearm/hand, left/right thigh, shin, foot, front_coat_left/right, back_coat, chest_armor. Break into additional separate layers where silhouette requires it. Sword `sword.png` MUST be optional, physically separate from torso/hands/animations; do not paint a permanent weapon on the body.
- Every file must have true alpha, nonzero visible area, stable orientation, correct pivot, source-area tracing and exact checksum. Scale for a legible actor at 60–75px on map, while editing from the high-resolution master; avoid huge transparent margins with 70px character on a 768px canvas.
- Reconstruct missing pixels (back of shoulder, hidden forearm, back of coat, knees/legs occluded by hem) with minimal paint-over and explicit per-part provenance. NEVER call an auto mask a complete high-quality rig until joint boundaries/deformation have been viewed.
- For difficult cutout limbs, rigid Sprite2D segment parenting to Bone2D can be used as a first pilot, but must not be misrepresented as smooth mesh skinning. For soft cloak/hair, consider Polygon2D/2D mesh deformation + actual weights where achievable, otherwise honest rigid part with readable visual QA. No first-run requirement to install Blender.

## IV. Rig and weapon architecture

Implement a separate Godot 4.7.2 `Skeleton2D` rooted character, hierarchical `Bone2D` joint pivots for hip/torso/head, upper/lower arms and wrists, thigh/shin/feet, hair and coat tails. The character must begin **UNARMED**.

Build a distinct `Node2D` sword socket logically attached to right-hand bone (or reversible left hand when future class needs). For the sword: separate `Sprite2D` or interchangeable scene, with origin at grip, explicit equipment id (none/sample_sword), reversible equip/unequip, weapon follows the right hand in Idle/Walk/Attack, and **no independent gameplay damage, hitbox, loot or EXP**. Weapon visuals/VFX are separate from the body. No combat skill authority changes.

No false eight-direction claim: current AN-04 pilot is exactly **one authored directional view**. Mirroring, if needed, must be labeled mirrored, not an original angle.

## V. Three actual 2D animations — 1 view, not an AI pose collage

- **Idle:** purposeful subtle breathing, slight shoulder/head/arm shift, distinct trailing hair and robe motion (no body-wide image warp). Return to stable joints, avoid jitter or clipping.
- **Walk:** genuine alternating left/right footfall + counter-swing arms, body rise/fall, delayed hair/robe. Record foot anchor/stance; avoid obvious sliding, disappearing limbs, or motion that only cycles a single flat image.
- **Attack:** recognizable **wind-up → slash/strike → follow-through → recovery** with major arm/torso/leg pose changes; animated detachable sword follows the hand, not permanently drawn on the body. Record visual marker metadata only (not Combat V2 hit authority). Include an UNARMED preview as well.
- Export actual frames (if renderer works) from animated 2D rig to PNG with source_kind, clip fps, frame counts, transparent bounds and SHA-256 manifest. Do not invent exact final frame counts or PASS simply from writing scripts. A short genuine GIF/video optional, but authenticated Godot PNG frames and 1280×720 screenshots are required for visual comparison.

## VI. Proposed file layout (adapt names if justified, never overwrite AN-03)

- `godot/scenes/labs/an04_cutout_rig_lab.tscn`
- `godot/src/presentation/labs/an04_shadow_cutout_actor.gd`
- `godot/src/presentation/labs/an04_cutout_rig_lab.gd`
- `godot/tests/presentation/an04_cutout_rig_contract_test.gd`
- `godot/tests/presentation/an04_cutout_gui_capture.gd`
- `godot/tests/presentation/an04_cutout_rig_bake.gd` (only when actual renderer-ready)
- `MO_AN04_QA.cmd` / isolated Windows launcher; outputs `godot/outputs/an04_lab/` **ignored by git**, no user save or main launcher modified.
- `docs/animation/AN04_2D_CUTOUT_QA_REPORT.md` should record actual evidence, QA matrix and art-blocker.

Lab GUI 1280×720: actor preview large enough to inspect, Idle/Walk/Attack switch, play/pause/restart, speed, armed/unarmed, optional layers/bones overlay. Always show input source status, fallback status, rendered direction fidelity, no gameplay mutation. A static HTML/mockup/render from outside Godot is NOT an actual engine screenshot.

## VII. Required tests & closure gates

Run **official Godot 4.7.2** on an isolated worktree, record exact SHA, engine version, command line, exit code and full logs. At minimum:
1. import/parse focused, no new `SCRIPT ERROR` or GDScript runtime faults;
2. `Skeleton2D/Bone2D` hierarchy and neutral pivot checks; genuine differences between Idle, Walk, Attack transforms; ensure separate layers do not detach;
3. sword starts OFF; equip sample only, socket tracks the actual right wrist/hand through attack and remains correctly attached after switching clip; invalid weapon IDs rejected; no game economy/combat changes;
4. actual GUI 1280×720 screenshot for Idle/Walk/Attack, armed/unarmed, with body size readable. Validate true alpha, frame crop, clipping and articulation visually; distinct-image hashes alone do NOT establish quality;
5. input image and derived parts checksum, presence/opacity/occluded reconstruction matrix; clip timing, last frame, loop semantics, 60–75px gameplay-view legibility;
6. outputs and logs in isolated QA profile; no canonical save/load/default scene mutation; compare the AN-03 technical reference without relying on 3D source code.

Separate statuses:
- `STATIC_PASS`: metadata/schema/path/source review;
- `ENGINE_PASS`: official Godot focused runtime with logs;
- `VISUAL_PASS`: real on-engine captures inspected for clean joints and fidelity to actual source image;
- `OWNER_ART_PENDING`: always until owner accepts the result;
- `BLOCKED_SOURCE_ART`: source missing/unfit; may coexist with technical ENGINE_PASS on placeholders;
- `WINDOWS/ANDROID_PENDING`: if those environments were not actually exercised.
Never label a procedural/placeholder guide as a visually complete Hắc Ảnh Kiếm Tu.

## VIII. Handoff format (complete, concise and truthful)

Deliver all of: branch / final SHA / PR URL, source image path+hash+dimensions+permissions, parts manifest with AUTHOR_SOURCE/EXTRACTED/REPAINTED/UNRESOLVED for every part, real clip preview/captures if engine available, exact focused test commands/logs and PASS/FAIL/BLOCKED, elapsed parts missing/art defects, required owner action only when unavoidable, and one clear recommended next packet. Update checkpoint/handoff **on AN-04 branch only** after real evidence exists; keep PR draft and do NOT merge. If unavailable, Codex must explicitly say what it did not execute.

**Start coding now after reading this contract. Do not return only another generic prompt, drawing, task list, or request for the owner to learn Git/Blender.**
