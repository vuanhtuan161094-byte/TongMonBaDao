# Kiếm Vũ Hồi Phong Nhân · R1E V2 · JX-inspired motion pass
**G3 ART CANDIDATE / OWNER REVIEW REQUIRED** — NOT replacement of R1E.

Goal: smoother sword-wind motion close to Wudang/Kunlun JX reference treatment, no copying commercial JX frames, no poster extraction, no procedural replacement art. Source-only phase: 12 existing OWNER ACCEPTED R1E VFX-only RGBA sprites are **identical bytes** and every second V2 sample is precisely that sprite. The other 12 samples are constrained bidirectional optical-flow alpha-premult interpolations (11) and a final alpha taper (1). These are **derived source-motion samples, not 24 new AI-painted cels**.

Production intent: 24 frames at 25 FPS (0.96 s) in isolated Front-direction Combat Lab. The original 1.54 s lab clock was only for art review; actual skill gameplay cast, cooldown, damage, range, 3 targets are untouched. Compare true 1× 174px GIF on light and dark. Keep sword bright enough to read, blue translucent volume, impact identifiable but do not max glow. No Godot before source/art checks. No rig, Codex Cloud, PvE, SaveService or merge.

Source: `source/kvhp_r1e_*.png`; generated V2 outputs in `v2_source`. Manifest is exact-SHA for 24 samples and original SHA. Owner approval of original R1E **does not transfer** to derived V2 or runtime.

## Owner approval (2026-11-24)
Owner: "Ok. Duyệt. Việc tiếp theo." Source artwork R1E V2 approved as 24-sample reference (12 original+12 derived), with immutable original R1E legacy available. Source approval does **not** prove in-engine motion. Default Web Lab is V2 at 25fps / 0.96s preview; compare using the in-panel V2↔R1E toggle. Front AS48 only, 3 moving monsters, no rig, no real combat receipts, PvE HOLD. Godot and Chromium exact-SHA required before runtime review gate; final art feel remains owner review after seeing motion.
