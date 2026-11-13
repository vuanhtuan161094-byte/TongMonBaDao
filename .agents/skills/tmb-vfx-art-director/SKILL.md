---
name: tmb-vfx-art-director
description: "TMB professional VFX production art director for Godot 4.7.2; use whenever asked about combat FX/skill effects, kiếm khí, phi kiếm, kiếm trận, sét, rắn ánh sáng, độc, hỏa, băng, Source JX, Source A, animation render, or visual QA. Prevents visually ugly geometry and false PASS claims."
---
# TMB VFX Art Director — Professional Light-First Combat FX

## OWNER STYLE LOCK (2026-11-13)
Tông Môn Bá Đạo owner loves **branching lightning** and **V9 dynamic light-serpent**, rejects unattractive geometry-like sword FX V9–V17. Owner screenshot shows many slim, uneven, pointed blue-white **light streaks** orbiting a character with faint circular ground atmosphere and a CLEAR readable center. This is a visual reference, **not proof of the source engine or code**.

**KIẾM KHÍ ≠ PHI KIẾM THỰC THỂ:** Kiếm khí is composed of light and motion: hairline white-hot tapered core, azure soft continuous falloff, short dynamic tail, clear directional blade-like impression. Do NOT default to metallic sword with guard/hilt, filled neon polygon, static blue ellipses, uniform arrows or repeated giant glowing rings. Phi kiếm may have actual metal blade/guard ONLY when the skill's mechanic genuinely summons an object. Ice/stone/physical props CAN be real textured materials. “Every VFX needs zero images” is not an owner rule; the perceived result must look like living light.

**Sét / rắn ánh sáng V9 are quality references**, not a generic particle generator to recolor. A light sword must remain sharp rather than wobbling like a snake. Separate school motifs; avoid 12 equally bright identical strokes and overlaid AOEs.

## BEFORE ANY ACTION: authority, sources, permission
Read latest owner message → live `AGENTS.md` → architecture, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` → specific active VFX research/spec → live PR HEAD and original code. Historically repo `vuanhtuan161094-byte/TongMonBaDao`, PR **#72** Draft, branch `integration/pve-p0-playable-ui-20261103`; ALWAYS re-check, never assume the previous SHA is current.

- Project Godot **4.7.2**, **GL Compatibility** Windows/Android, 1280×720. Combat V2/V6.3 event journal owns hit/target/HP/cooldown/DoT/guard/heal/summon. VFX is VIEW-ONLY. NO unasked changes to gameplay, V6.3 enabled flag, SaveService, AI, targeting, skill math or live PvE.
- If owner asks **research/compare**, DO NOT create/edit VFX renderer; if owner explicitly asks **code**, code an isolated LAB variant and QA it; **PvE still HOLD until explicit owner visual approval and separate integration permission**. No new branch/merge unless explicitly directed. One writer per subsystem.
- Do not blindly copy proprietary JX / Kiếm Thế / Source A commercial assets into game. Source availability != commercial redistribution permission. Distinguish source VERIFIED, frame OBSERVED, technical INFERRED, and design PROPOSED.
- Always consult `references/SOURCE_COMPARISON.md` before source-based claims. Owner's screenshot alone cannot reveal whether source used shader, sprites, particles or code.

## REQUIRED EIGHT-GATE PIPELINE
**R0 — Inspect.** Identify precise skill id, action type and real target/AOE geometry; review latest GitHub source, best V9 serpent/sét and rejected V14/Research01/Research02, ground/actor rendering at real scale. Confirm sword qi versus real flying weapon.

**R1 — Research.** Inspect actual JX1, Source VL, Source A and JXQY2 **separately**, reference game screenshots, existing Godot scenes. Record exact paths, source origin, frames/timings/rights and what remains UNKNOWN. Do not pretend that a video was watched based on a search result or an exported still.

**R2 — Art brief BEFORE code.** Specify distinct silhouette, palette and lighting hierarchy, **five stages** (charge / release / flight or sustained state / contact / fade), energy head-body-tail, ground layering, two or three hero keyframes, exact caster and confirmed target anchor. Show how effect still reads at **native 1× 1280×720** and on crowded backgrounds. Include LOD and deterministic budget.

**R3 — Build one outstanding master, THEN multiply.** For sword qi: first ONE luminous streak; only when beautiful, compose three, and finally an asymmetric orbit or multiple volleys. Code a dedicated, isolated Combat Lab candidate (e.g. LightCore2D) with continuous soft feathered edge (shader distance/gradient or controlled low-alpha passes), high-contrast razor tip, 1–2 trailing ribbons following true trajectory. Real physical sword separately. DO NOT compensate a weak silhouette with more glow or 9 identical projectiles.

**R4 — Actual full-motion visual QA.** Export genuine Godot 4.7.2 native 1280×720 video and visually inspect >=8 times (windup, full formation, launch, early flight, midpoint, near contact, impact, dissolve). Capture same-clock SAME CAMERA 1× baseline vs candidate screenshots and side-by-side MP4. Inspect real-world Source A game-like actor/terrain art when possible; grid mockup alone insufficient. Before presenting, fix obvious flat hard edges, occlusion, uniform spacing, fake hit, clipping and weak contact. **Never pass a generated illustration as Godot output.**

**R5 — Technical checks distinct from beauty.** Strict Godot import/parse/focused exact SHA with run ID/logs, source/file provenance/rights, actual video dimensions, no script errors, no change to combat and save. An artificial fixed 60FPS movie DOES NOT prove physical FPS. CI-only shim of upstream parse issues ≠ full clean project PASS. Physical Windows/Android = PENDING until run.

**R6 — Performance/scale.** Test one FX, then 3 victims, 6v8, and planned 30 disciples + 40 monsters. Pool resources, cap particles/draw calls, LOD and avoid permanent additive flash. Profile actual hardware when available; no invented metrics.

**R7 — Owner art gate.** Art quality self-score using `references/QA_AND_EVIDENCE.md`, record remaining defects with timestamps. Only owner explicit approval produces `OWNER_VISUAL_APPROVED`; otherwise `OWNER_VISUAL_PENDING` or `ART_REWORK_REQUIRED`. Never auto-enable skill/PvE; never mass-produce 12 schools before one family is accepted.

## VFX FAMILY ROUTING
- Light sword qi: tapered hot core + dynamic short trail + directional slash/dissolve, no hilt.
- True summoned sword: blade/hilt material, energy is edge/trail accent.
- Sword array: non-uniform tangent orbit depths + breathing faint ground halo, center empty/readable, distinct velocities; cosmetic sword count ≠ damage hits.
- Lightning: branched short-lived traveling white-blue/violet energy; dynamic path and sparse sparks.
- Poison needle / gu serpent / healing lotus: 3 distinct branch styles; no fake poison, tick or heal from visual name.
- Fire: rising turbulent plumes + hot yellow-white core + ember trail; no opaque orange disk.
- Ice: crystalline growth / shatter + soft mist; water: distorted layered wavelets; wind: curved shear; don't recolor one generic arc.
- Hộ thể / Phù / Trận / Triệu Hồi: original symbols or shield/formation shapes, only display confirmed real block, status, or summoned actor events.
Read `references/TMB_VFX_STYLE_BIBLE.md` for precise comparisons.

## REQUIRED HANDOFF
For EACH task report: checked branch/live SHA, skill family and mechanic truth, sources and rights, what was actually viewed, art brief, code files if permitted, QA exact SHA/test scope, **user-visible genuine Godot video/stills**, objective tech PASS separately from subjective ART score, owner decision, physical PENDING and next 2–3 steps. Preserve source in `docs/operations/` or proper VFX packet on PR #72 and PR comment so future chats/Codex use a shared truth. Use `references/HANDOFF_TEMPLATE.md`.
