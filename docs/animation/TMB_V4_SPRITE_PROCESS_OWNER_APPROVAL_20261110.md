# TMB Combat Art V4 — Owner-approved sprite workflow
Date: 2026-11-10 (VN time)
Scope: presentation-only, PR #72 on `integration/pve-p0-playable-ui-20261103`.

## Decision — OWNER APPROVED PROCESS (NOT ASSET RELEASE)
On 2026-11-10 the owner reviewed the four animated GIFs for **Nữ Độc Tu** (Cast, Attack, Hit, Death), judged the results *tạm ổn*, and explicitly **approved the sprite production process**. The owner wants **better action storyboards** for future iterations. Earlier the owner explicitly approved the new **Walk** look. Do not misstate this as approval of all final binaries, official Godot runtime, 8 directions, or full V6.3 skill/VFX synchronization.

**Hard visual anchor:** user-approved four-view Nữ Độc Tu image `image(20261109-102800).png`, SHA-256 `435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118`. Dark Shadow Pixel-Chibi, jade/black/antique-gold clothing, long black-violet hair, emerald forehead seal and eyes. Keep identical character identity across actions/directions. No unauthorized face, hair, costume, palette changes. Existing Walk selected by owner is the reference for motion readability.

## Approved authoring workflow
1. **Write the storyboard BEFORE drawing any frame.** For each state, specify character intention, anticipation → peak movement → follow-through → recovery, leg stance, hand/arm silhouette, torso/head, hair/robe drag, camera direction, contact point, and event timestamp. Plan which frames are distinct key poses and which are in-betweens; do not set frame count as an arbitrary production quota.
2. **Produce only one action sheet at a time**, with four coherent directions (front, left, right, back) registered to the same foot/root pivot and scale. Work from the same immutable approved MASTER. Do not invent independent character variants frame-by-frame or use whole-sprite wave/stretch; masked redraws/rigged layers/inbetweens are allowed where identity and articulation survive. Mirroring is permitted only if asymmetry and leg/hand motion stay correct and is labeled honestly.
3. **Inspect the sheet visually and extract playable animated GIF**, not only contact JPG. View at game-size 60–75px (1280×720 context), plus enlargement for seams. Verify start, peak, recovery, loop closure or final grounded pose; reject static-looking action or shape drift.
4. **Owner reviews GIF motion**. Feedback goes back into storyboard/key poses before increasing frames or expanding to the next actor. No claims of aesthetic PASS solely from hash, frame count or CI.
5. **Export clean transparent alpha PNG frames, atlases, manifest and source evidence**. White/grey matte, checkerboard baked into pixels, detached limbs, inconsistent feet, clipping, color changes and alpha halos are blockers.
6. **Godot 4.7.2 isolated visual lab QA** at verified exact SHA; record logs and *real* GUI capture. Only after this gate may production integration be evaluated. Keep gameplay/V6.3/SaveService and existing V3 unchanged.

## More expressive storyboards for the next revision
| State | Stage sequence, must be readable without FX |
| --- | --- |
| Idle | Firm grounded silhouette; no blink, global bob or unnecessary motion |
| Walk | L/R contact → passing → opposite contact; counter-swing arms; robe follows after feet; preserve owner-approved look |
| Cast | Lower center of gravity → draw both hands inward → form visible seal → hold/release at real combat event → recover; visually distinct from Attack |
| Attack (Độc Châm) | Focus/aim → shoulder-elbow wind-up → one decisive hand thrust/flick → visible follow-through → retract; projectile stays separate, tied to actual release/hit |
| Hit | Visible impact direction → head/torso recoil + protective arm → knee/weight response → grounded recovery; no whole-image shove |
| Death | Lose balance → knees buckle → hands/torso fall → contact → final still downed pose; no stand-up during Death |
| All directions | Front/side/back must each show the action; behind hair/robe cannot excuse hidden Cast/Attack/Hit/Death |

Storyboard should include concrete timings and main poses before frame generation. Timeline must not generate combat results by itself.

## Current approval and remaining gates
- **Process:** OWNER_APPROVED.
- **Walk:** OWNER_ACCEPTED for the visual direction. Preserve it.
- **Cast / Attack / Hit / Death GIFs:** OWNER_TENTATIVELY_ACCEPTED_AS_PROCESS_EXAMPLES; require stronger storyboard and finishing, **not final product PASS**.
- **Static identity / source:** LOCKED.
- **Transparency/pose continuity / 4-way pose QA:** FINAL QA PENDING.
- **Official Godot 4.7.2 import, animation recording, memory/FPS and V6.3 event timing:** NOT VERIFIED for this new package.
- **PR #72 source integration:** NOT DONE by this document.
- **Runway or any paid third-party service:** FORBIDDEN by current owner request. Use accessible in-chat art + existing open-source sprite tools instead.
- **No new branch, no merge, no V3 removal, no gameplay or SaveService edits.**

Historical docs marking failed earlier warped prototypes remain valid for those specific prototypes; this later owner approval authorizes the revised GIF-first storyboard-driven process, not retroactive validation of failed assets.
