# VFX-BATCH-01 — 12-school bulk production foundation, exact 2,196 skill IDs
Date 2026-11-14. Source branch PR #72 Draft: integration/pve-p0-playable-ui-20261103. Godot 4.7.2 Compatibility GL.

## Owner production directive
The owner approves Cổ Vụ Mê Tung R3's visual direction and authorizes producing effects **in large batches rather than one approval per skill**. This changes the studio production cadence, **not** the quality bar, Combat V2 authority, V6.3 release gate, redistribution rights, or requirement to distinguish placeholder artwork from accepted VFX.

## Source-grounded inventory and hard gates
- `godot/labs/vfx_batch/manifest.json`: 2,196 exact canonical skill IDs from 12 CSV ledgers, 420 unique family IDs, 204 cast families, 216 passive/innate families with **NO FAKE CAST**. Per school 183 IDs / 17 cast families / 18 events. The source release gates remain OFF.
- The **three owner-approved existing Human LAB skills** Phụ Cốt Cổ, Xà Ảnh Quấn Mạch, Cổ Vụ Mê Tung remain LOCKED and linked by their own scene paths. Only *their Human LAB presentation* had an owner visual decision; higher variants not inferred approved.
- **201 other cast families** are selectable by exact ID from the batch preview, not 201 individually approved complete commercial-grade VFX. Batch naming is `BATCH_PREVIEW_UNREVIEWED`; no automatic ledger `OWNER_VISUAL_APPROVED` mutation, no existing skill scene overwritten.
- **216 passive/event families** are indexed but get no idle/fake cast. A passive VFX may only be made after an authentic Combat V2 proc/innate event contract is verified.
- 794 distinct declared VFX keys are metadata, not complete renderer assets. Chú Tu text_pending keys remain text_pending. No fake release readiness.

## Genuine implementation
- New isolated `res://labs/vfx_batch/tmb_vfx_batch_preview.tscn` + `tmb_vfx_batch_preview.gd`: loads all 2,196 ID mappings and 420 family descriptors; supports 12 school motifs, 2 medicinal Poison motifs and reuse of three **original** earlier TMB asset themes (Gu beetle, gu moth, poisonous mist). Per-family seed and effect/shape/slot influence preview arc, focal hierarchy, target layout, size and timing.
- 12 unique authored silhouette sources: needle, talisman, sword qi, spirit bow/arrow, fist burst, broad blade slash, dual blades, spear, palm, curse sigil, formation sigil, spectral summon; two additional Poison healing/medicinal motifs (lotus and vial). All new assets authored for this LAB as RGBA-compatible SVG with alpha/mix, compact soft-light accents, no rig. **These are reference-quality prototype motifs, NOT polished unique final skill atlases for all families.** Source VL and JX visual principles studied; no proprietary pixels copied into these new assets.
- The effect/shape presets are intentionally distinct (`poison`, `damage`, `heal`, `cleanse`, `guard`, `summon`, `mark`, `mobility`, `formation_zone`) and do NOT execute actual hit, heal, shield, summon, move, mark or damage. Drawn dummy targets merely illustrate source geometry and target_limit.
- Case: `TMB_VFX_BATCH_MODE=poison` previews 14 new Poison cast masters and **skips** three approved LAB originals. `TMB_VFX_BATCH_MODE=schools` previews two school/branch examples across all 12 schools (24 samples). `TMB_VFX_BATCH_MODE=all` enables the complete 201 unreviewed cast family list for local browsing. A single exact family/skill ID can be selected using `TMB_VFX_BATCH_MODE=single` + `TMB_VFX_BATCH_SKILL_ID=<id>`. SPACE replay, P pause, LEFT/RIGHT page.
- The 2×2 reel gallery is a **production-review overview**: small thumbnails do not equal actual combat 1× visual/performance acceptance. Open single-scene preview and actual target actor/camera for release QA. The new demo is a LAB only and never acts as a live Combat V2 presentation adapter.

## Mandatory QA gates
- New read-only focused contract `res://tests/labs/combat_lab/vfx_batch_01_contract_test.gd` verifies 2,196 unique ID mappings, 420 families, 204 cast / 216 passive, 12 school counts, three approved scene links, 14 + 24 reel queues and all 201 callable preview masters; detects false passive cast and gameplay/save mutation calls.
- Workflow `.github/workflows/vfx-batch-01-godot.yml` uses SHA256-pinned official Godot 4.7.2, restores preexisting immutable Stage A dependency, strict import and parse, then real native Godot 1280×720 movies `poison.mp4` (14.4s; 864 frames) and `schools.mp4` (21.6s; 1296 frames). Checkpoint PNGs, GIFs, timelines, SHA256 sums and logs archived. Fixed 60fps output is NOT hardware performance or clean game-wide QA.
- Actual artwork QA must inspect at least 8 sample frames and whole motion. **No owner mass approval** is implied by technical PASS. The bulk status is a fast way to identify weak art groups and repair by theme/family without repeatedly asking for 204 separate approvals.
- Before shipping: create truly unique image-backed flipbook/weapon/wings/coil motifs for individual standout skills, stage and event receipts, 3 target positions, 6v8, 30 disciples/40 active monsters; Windows+Android FPS; legal rights. Until that work, `PVE_INTEGRATION_HOLD`, all V6.3 catalogues disabled.

## Source and integration boundaries
Only new LAB scene, manifest, original SVGs, test, workflow and docs. No changes to Combat V2, Skill Registry production gates, HP, targeting, economy, AI, SaveService, real source JX asset manifests or any of the three existing owner-approved effect scenes. No Codex, no new branch, no rig, no merge.

## Audit output — fill from exact-SHA Actions after running
Status: CI / movie visual evidence not yet recorded at creation of this brief. Do not manufacture PASS, artifact IDs, media links or owner approval. After Actions, append source SHA and run, observed issues and the specific preview adjustments.
