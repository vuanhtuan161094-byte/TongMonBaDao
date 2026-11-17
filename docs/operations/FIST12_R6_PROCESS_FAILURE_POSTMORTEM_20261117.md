# FIST12 R6 — Production-process failure postmortem (2026-11-17)

**Owner feedback:** "rà soát lại quy trình làm vfx. sai bét rồi." This review supersedes any presentation of standalone FIST12 R6 as a completed VFX candidate.

## Observed and verifiable

- PR #72 was Draft; R5 at commit `f98315a0d2d811e710f9e53c8dd73ed4f106b9b2` had exact-SHA Godot technical success on run #43999710250 but failed art. **Do not overwrite or promote R5.**
- A local-only archive `TMB_FIST12_R6_ARTFIRST_GODOT_CANDIDATE_20261117.zip` was generated, **NOT COMMITTED** to this repository, using two 1536×1024 original **artboards**, not standalone transparent hero sprites.
- `tools/build_assets.py` in that local archive cropped 18 character poses from ~72×81-pixel rectangles, chroma-keyed qi and mark from labeled montage panels, and assembled 128px/96px cells. These are *poster extractions*, not properly authored and source-preserved full-size RGBA sprite keys. One qi_1 frame had only 7 pixels of alpha >16 (and static QA only required >0 pixels/frame), a concrete **false-positive quality gate**.
- The archive's `preview/FIST12_R6_OFFLINE_ART_PREVIEW_NOT_GODOT.mp4` was rendered OUTSIDE Godot at 1280×720, 24 fps, ~7.58 s. It is **NOT** genuine Godot capture, **NOT** V4 G3.5 evidence and **NOT** game-integrated VFX.
- The local QA `qa_result.json` explicitly says `STATIC_ALPHA_QA_PASS_ONLY`, `godot_native=NOT_EXECUTED`, `github_exact_sha_ci=NOT_EXECUTED`. No actual Godot import, target anchoring, source fidelity, scene runtime or performance was verified; archive `main.gd` alone does not prove a working project.
- At 1× offline stills, the character and qi are small/visually weak, the light appears as radial scratches, and mark sustain is barely legible; source poster background/matting was observable. There is no owner art approval.
- The exercise also expanded beyond the VFX deliverable into an unapproved *new 18-frame one-direction character source*, without an independently accepted Quyền Tu actor production packet.

**Final local classification:** `R6_SOURCE_ARTBOARD_REJECTED`, `G3_5_NOT_EXECUTED`, `G5_NATIVE_NOT_EXECUTED`, `G7_EXACT_SHA_NOT_EXECUTED`, `OWNER_ART_NOT_APPROVED`, `PVE_HOLD`. Do NOT use R6 for PvE or as the next skill's visual baseline.

## Why the process failed

The main failure was violating **existing** `AGENTS.md`, `TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md` + V4/V4.3, `TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md`, `docs/operations/vfx_packets/README.md` and the Fist playbook. It is an execution/compliance failure, not a need for another concept montage or bulk generation.

## Fail-closed operating corrections for every new/reworked skill

1. **G0 SOURCE CHECK:** current HEAD, approved/rejected owner decisions, exact catalogue/ledger ID and three-clock event/timing matrix. Treat runtime hit/mark receipt as UNKNOWN until wired. FIST12 is Nether MARK, one target, cast .45s, duration 6s, cooldown 8s, projectile_speed 0 and hit_count absent; three *visual* beats do not create three hits.
2. **G1 MOTION REFERENCES:** deconstruct observed source frames (material, action curve, color, attack silhouette, contact) and rights. Distinguish observed/inferred; no copyrighted game sprite reuse.
3. **G2 ONE DISTINCT STORYBOARD:** focus on one complete high-quality release/contact first. 5–6 beats only when appropriate. Get exact hand/chest/world anchors and scale. Do not create a decorative poster or a fictional standalone game.
4. **G3 TRUE MASTER:** create **isolated**, high-resolution first-party RGBA hero VFX, clean transparent edges, independently authored action key poses and separated MIX material / localized ADD hot core / low bloom / contact / residue. **Reject** text-labeled concept-sheet crop + threshold matte as final source, a single image repeated under transforms, generic vector curves or fake actor animation. A user-approved actor remains unchanged unless a separate actor art task is approved. No rig.
5. **G3.5 REAL NATIVE STOP:** provisional scene in **real Godot 4.7.2 GL Compatibility**, genuine 1280×720 charge / peak / contact frames **on a moving monster**, manual 1× fidelity and alpha/layer/silhouette review. If Godot unavailable, record **BLOCKED/NOT_EXECUTED and STOP** — an offline video is NOT a substitute and must not be handed off as skill evidence.
6. **G4 MOTION/ANCHORS:** verify stationary, independently moving left/right and crowd cases; test that visuals follow selected actor but do not invent hits. Asset frame checks must include empty-frame detection, visible-alpha bounding boxes, content scale, cropped edges, frame continuity, and actual motion. Hash/alpha-nonzero == file validity only.
7. **G5 NATIVE FULL MOTION:** only after G3.5 visual self-review, record short real Godot 1280×720 attack-through-fade MP4 and inspect >=12 meaningful checkpoints as warranted. Check dark/bright backgrounds and 1×. Probe six-second mark sustain/expiry separately; no mandatory GIF. Video fps encoding != physical device performance.
8. **G6–G8 INDEPENDENT GATES:** self-score at least 4/5 on critical silhouette, material, pure-color/light layering, movement, contact on moving target, occlusion, readability and fade. Use V4 school packet three-stage validator and Godot focused tests on exact SHA. `TECH_PASS` never equals `OWNER_VISUAL_APPROVED`. Do not claim deployability until explicit owner + separate PvE and device/performance approval.

**Deliverable policy:** never hand over a local poster-based demo, an unrun Godot source folder, or static-alpha PASS as if it were the requested VFX. If no real Godot evidence, report `NOT_EXECUTED` and return to G3 asset development. Keep prior owner-approved sources intact, no rig, Codex, branch, merge, Combat V2/SaveService/economy/V6.3/PvE modifications.

**Concurrency:** one writer per file path on the active PR #72 integration branch; this audit is documentation only, not a game implementation, CI result or art approval.
