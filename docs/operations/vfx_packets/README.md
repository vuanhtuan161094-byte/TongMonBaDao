# VFX Production System V4 — machine-checkable school packets

Effective 2026-11-16 under the **existing canonical SOP**:
[Art-First SOP V3 + V4 addendum](../TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md). This directory is an implementation packet store, **not a new competing SOP**.

## Required every-school workflow

1. Check current PR #72 HEAD, AGENTS.md, .agents/skills/tmb-vfx-art-director/SKILL.md, canonical skill catalogue, ledger and school playbook. One writer per overlapping school paths.
2. Create one JSON V4 packet **per Human cast-master skill** (start from [HF02_V4_PREFLIGHT.json](HF02_V4_PREFLIGHT.json) as an example, but replace the skill/scene/proof markers with actual values). Confirm every declared contract field against the real canonical catalogue. Do not invent gameplay hits, status, projectiles, cooldowns or targets.
3. Distinguish **three clocks**: combat-authority cast/status/projectile/actual event receipt, local sprite/charge/peak/contact/fade, demo-only video/replay. State RUNTIME_MAPPING_PENDING when the real event mapping is unknown; LAB hit timing is not a gameplay hit.
4. Preserve original first-party or appropriately licensed art source permanently. Declare path and rights provenance for each master. A tiny concept crop can pass data integrity but still FAIL aesthetic quality; do not label it an approved hero sprite. Record independent key poses, alpha/cell geometry, displayed duration and true 1× visual scale; **do not** count unique frame hashes as motion quality.
5. Implement a school-owned G3.5 native Godot **mini render** at native 1280×720, screenshots **charge / peak / contact on moving target**, together with the focused moving-anchor/target contract. Label demo screenshots honestly; do not silently enable gameplay integration. Capture enough native frames that the last screenshot actually exists.
6. Run common technical validator at three stages:
   - \`python3 tools/qa/validate_vfx_v4_packet.py --stage packet --packet <school-packet.json>\`
   - \`python3 tools/qa/validate_vfx_v4_packet.py --stage assets --packet <school-packet.json>\`
   - \`python3 tools/qa/validate_vfx_v4_packet.py --stage evidence --packet <school-packet.json> --out <artifact-directory> --sha <40-char-GitHub-SHA>\`
7. The final evidence stage fails closed unless it has a true native MP4, exact 1280×720 PNG charge/peak/contact, matching native scene boot marker and successful moving-target focused contract. It writes **V4_MANIFEST.json** with SHA-256 of source masters, atlases, screenshots and video, plus manual-only ART and owner hold statuses. The \`proof_contract\` fields in the packet set the school's actual Godot test/native log markers; **do not paste HF02 markers into other schools**.
8. Review by a human the 3-stage visual fidelity, lighting, silhouette, occlusion, and actual continuous video. A technically successful preflight proves only an engine-rendered capture and valid structure. **It is NOT an automatic art PASS**. G3.5 visual failure STOPs full render; rework same skill. Only after art self-review, perform full movie/12 meaningful checkpoint review and separate exact-SHA QA.
9. Owner approval, actual Combat V2 receipt integration, physical Windows/Android performance remain **independent gates**. Preserve approved masters and update ledgers only from explicit owner decisions. No rig, Codex by default, new branch/merge, Combat V2, SaveService, PvE or V6.3 changes via this tooling.

## HF02 pilot

- Packet: [HF02_V4_PREFLIGHT.json](HF02_V4_PREFLIGHT.json).
- Workflow: [VFX V4 HF02 native preflight](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/workflows/vfx-v4-hf02-preflight.yml). This workflow is **HF02-specific**, while the validator is designed for other school packets; adapt school-owned workflows as each school onboards rather than claiming universal CI adoption.
- Initial exact-SHA native test: [run #43793572895](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43793572895), commit \`aa8d0b21117073a88078f6732079b70c08ead3e0\`, SUCCESS technical. Evidence includes 96-frame Godot video, 3 screenshots, file hashes, and a negative test deliberately omitting \`v4-contact.png\` which must fail.
- **Known visual warning:** R5 HERO source is a 320×91 original concept crop. Proof of first-party provenance or native screenshot fidelity does not fix its artistic/scale limitation. Owner remains \`OWNER_VISUAL_PENDING\`; direct comparison to user reference, motion quality and hit impact require manual review.
- Art SHA/proof may live in a 30-day Actions artifact; original reproducible sources/generators remain committed in repository. Do not call the expiring artifact a permanent release archive.

The initial HF02 pilot establishes **technical enforcement** only. This document does not authorize enabling V6.3/PvE or deploying VFX into the actual game.
