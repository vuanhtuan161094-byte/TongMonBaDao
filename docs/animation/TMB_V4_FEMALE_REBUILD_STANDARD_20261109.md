# TMB V4 — Nữ Độc Tu: standardized rebuild gate (owner correction 2026-11-09)

**Status:** REBUILD_REQUIRED; prior 176-frame warp prototype REJECTED. The later 240-frame cutout handoff is not a Godot/visual acceptance and was NOT automatically imported into the repository. Do not ship either as a production actor.

## Single visual identity

The exact owner-approved reference is the 4-way still image \`image(20261109-102800).png\`, RGBA 1448x1086, SHA-256 \`435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118\`. Maintain four directions (front, left, right, back), violet-black large-volume hair with emerald/gold hair ornament, vivid jade eyes and poison forehead seal, black-green heavy robe with antique-gold trims. Female identity is LOCKED. A slightly forward head/neck axis is an identified correction target, **not** a license to redesign face, costume, or palette. Preserve reference metadata; do not overwrite reference with later AI concepts.

## Skill routing actually used

- \`agent-sprite-forge-chatgpt/generate2dsprite\`: one approved master, transparent alphas, registered frame rects, pivots, atlas manifest.
- \`agent-sprite-forge-chatgpt/video2dsprite\`: real continuous video → extraction only when an actual video route/source exists; **NO_VIDEO_ROUTE** in this ChatGPT environment for image-to-video.
- \`agent-sprite-forge-chatgpt/generate2dmedia\`: separate created-image/prototype/engine/owner approvals; preserve hashes and provenance.
- \`tmb-project-copilot/tmb-asset-gate\`: actual visual inspection, immutable reference identity, four orientations, real semantic clips.
- \`tmb-project-copilot/tmb-godot-evidence\`: official Godot 4.7.2 exact-SHA video evidence, not fabricated footage or a passed static harness.

## Non-negotiable animation production rules

1. **No more whole-image vertical waves, deformation, or slideshow of near-identical frames.** Do not use independent text-to-image prompts for each frame; they cannot hold character identity across 4 directions.
2. **Idle:** rooted feet and torso (static permitted), **no blinking**. Idle may be a single clean still until genuinely artist-accepted hair breathing layers exist. No fake 8-frame duplicates just to hit a count.
3. **Walk:** four observable phases—left/right contact and left/right passing; **two independently articulated legs** and arm counter-swing. Every step must be readable at actual 60–75 px in the 1280x720 viewport; phase root registration and both loop seams tested.
4. **Cast:** anticipation (hands meet / seal), active hand extension, **separate skill/VFX release event**, recovery. Real arm/elbow pivots; no luminous projectile merged into the character's permanent atlas.
5. **Attack:** 1–2 anticipation poses, decisive strike silhouette, recover; distinct from Cast/Idle. Real shoulders and elbows with a consistent body shape.
6. **Hit:** clear recoil and recovery, not a color flash alone. **Death:** weight transfer, collapse and final grounded pose; hair/robe remain attached and coherent.
7. **Layer authoring (separate drawings, not arbitrary crop segmentation):** head, neck, torso, hair, left/right upper arms, forearms and hands, left/right thighs, lower legs and feet, and main robe masses. Enforce overlap at joints; no holes or ghosting. Use single consistent master as reference for all drawings.
8. **Geometry/metadata:** sprite cell initial reference 160×192 RGBA and logical pivot (80,179), reassess only with measured engine footage and recorded migration. Keep all four directions identical height, alpha/nearest filtering, uniform target footprint. Frame counts and FPS follow *real pose duration*, not a quota of 240.
9. **Skill presentation:** 4-way Cast/Attack frames can be generic, while real poison effect visuals (Độc Châm / Cổ Độc / Dược Độc) are authored separately by V6.3 skill ID and cast/release/hit events; never add gameplay-side damage or buffs.
10. **Git discipline:** only add new isolated assets, QA, docs or a viewer until authorized integration. Preserve current V3, gameplay/SaveService, Godot project production scene, all E: user saves. One PR #72 branch, no merge or new branch.

## Acceptance matrix (fail closed)

| Gate | Required | Current 176 prototype |
| --- | --- | --- |
| Correct approved source SHA | Required | PASS |
| Four approved views and registered pivots | Required | PASS |
| Real authored body/limb joint layers | Required | FAIL |
| All Idle/Walk/Cast/Attack/Hit/Death | Required | FAIL (only four states) |
| Readable walk contacts and arm key poses | Required | FAIL |
| Idle has no body bob/blink | Required | FAIL |
| Full visual scrutiny at real game scale | Required | NOT ACCEPTED |
| Official Godot 4.7.2 import / actual GUI video | Required | NOT RUN |
| No SCRIPT ERROR in Godot visual lab | Required | NOT PROVEN |
| Owner final visual acceptance | Required | PENDING |

Run \`python tools/art/v4_female_sprite_gate.py <package.zip> --owner-master <owner.png> --report <qa.json>\` on any candidate pack. Exit nonzero blocks deployment, not merely records a warning. Since no real approved 4-way body rig is present, **do not declare completion or release a fake 'final' pack**.

**Next art packet:** draw independently articulated modules from the approved female reference; register four directions; assemble demonstrably different walk/cast/attack/hit/death key poses, then interpolate and render. Final evidence must be an actual moving Godot clip and source atlas; no intermediate contact sheet is a substitute.

**Gameplay, economy, production, SaveService, PR merge: UNCHANGED.**
