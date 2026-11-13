# VFX-REF-01 — Reference-film viewer for JX1 / Source VL / original V9

Owner instruction 2026-11-13: use JX VFX for R&D without reinventing geometric fake effects. Owner **rejected** Xà Ảnh Quấn Mạch R1–R5. Viewer exists to inspect actual source sprite timing/appearance, not claim that Wudu impact equals a serpent.

Authentic repo sources read using the original manifest frame rectangles and pivot offsets:
- JX1 Ngũ Độc #63, 1fffed7e.webp: 13 frames × 56 ms, impact only (NOT Xà Ảnh Quấn Mạch).
- JX1 Võ Đang #158, 3dfcabc2.webp 10×50 ms precast; aa93d577.webp 17×50 ms cast; 361b4525.webp 8×40 ms impact. These phases are **stitched in this reference viewer for inspection**, not established as the original game's cast clock.
- Source VL sword 150, wd_150_jianchuixinghe_a.webp 36×30 ms and _d.webp 21×30 ms; these are separate from JX1.
- Original internal Godot V9 light-serpent reference (2.5 s). No new artwork is fabricated here.

Controls: 1–4 focus an individual track, 0 all sources, P pause and Space replay. Godot GL Compatibility 4.7.2, preview 1280×720. Static code is view-only with no combat, target/HP, DoT, economy, SaveService, AI, V6.3 or live PvE changes. VFX from commercial game archives stays limited to owner-directed source review; redistribution licensing not verified. Do not auto-integrate these source sprites into a shipped build.

Next art gate: identify an actual serpent skill sprite/clip and analyze its frames before remaking Xà Ảnh Quấn Mạch. A colorful JX poison palm impact is NOT a correct snake reference. R5 remains ART_REWORK_REQUIRED and OWNER_VISUAL_REJECTED.

## Executed native QA / visual findings — 2026-11-13
- Exact tested source SHA: 197b6561b329d2dbeae7aa6f988ef35f188aa3bd.
- Official workflow [#43476720977](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43476720977) SUCCESS: Godot 4.7.2 stable GL Compatibility, strict import/parse PASS, focused SceneTree contract VFX_REF01_FOCUSED_RESULT=PASS failures=0, source image inventory loaded=7 issues=0.
- Genuine Godot --write-movie: 1280x720, 5.60 seconds, 336 frames, fixed encoded 60 fps (not physical hardware FPS). Twelve captured timestamps and filmstrip with SHA256 evidence.
- Workflow artifact: vfx-reference01-197b6561b329d2dbeae7aa6f988ef35f188aa3bd (artifact ID 14063641259).
- Directly reviewed video frames 0.40, 0.75, 1.05, 1.75s. JX1 Wudu #63 is a small animated green smoke/flame impact, **NOT a snake**. Source VL sword is a gold/black framed luminous cast and explosive hit, **NOT poison**. JX1 Wudang is silvery sword cast/impact. TMB V9 visually retains braided living-light motion but lacks snake anatomy.
- Decision: for the next single-target Xa Anh Quan Mach prototype, use a real independently authored serpent head/body/tail sprite animation and V9 motion as reference; use JX1 #63 only as contact-layer accent where appropriate. R5 remains OWNER_VISUAL_REJECTED. No PvE, Combat V2/HP/target/DoT/SaveService/economy/V6.3 code changed by this package.
