# POI11 Vạn Độc Xuyên Tâm R9 — owner visual acceptance (2026-11-16)

## Explicit owner decision
In the Tông Môn Bá Đạo conversation, following the genuine R9 Godot 11-second 1280×720 movie, the owner replied: **"ok. chốt. mà sao giờ mà xuất 660 khung hình. chúng ta đi đúng hướng đấy chưa?"** This explicitly APPROVES the presented **R9 Human LAB artwork**. The previously criticized dark rectangular/square bounding matte of R7 is resolved for the owner-approved R9. Do **not** assume approval extends to unrendered Immortal/Divine variants or live PvE gameplay.

- Canonical skill: `tmb.skill.poison.doc_cham.ultimate.human`, poison/nether, circle radius 3, target cap 3, cast time 1.15 s, cooldown 36 s, poison status duration 8 s and stacks 2.
- Approved artwork: independent first-party painted vortex atlas `godot/labs/combat_lab/poison11/r1_original/assets/poison11_crown_10_r9.png`, alongside existing charge/flight/contact; 10+10+10+8 = **38 animation sprite poses**. Retain R7/R8 in history for visual provenance; do not replace accepted R9 without targeted owner request.
- R9 preflight tested `e1439ba846f0eff8ab3905739214e9a2a5ce6297`: [Godot V4 Actions #43838029107](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43838029107), native 160 frames, 1280×720, focused/asset/evidence technical PASS.
- Full native movie source `53e3d8c299f8f96fd79cc8b07ac771f0c6bcb9ac`: [Actions #43838672165](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43838672165), SUCCESS; 660 encoded movie frames, 11.0 s at fixed 60 FPS; MP4, GIF, 14 native checkpoints, SHA-256 manifest, artifact ID 14212525839. Film capture is **not** device FPS or 660 separately authored sprite files.
- Additional PR handoff [POI11 R9 full QA and square-matte resolution](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72#issuecomment-6912464358).

## Three clocks and efficiency note
**Combat authority:** cast 1.15 s; duration 8 s / two stacks; cooldown 36 s. Actual Combat V2 hit/poison receipt and world-distance mapping still UNKNOWN; do not infer from the LAB showcase.

**VFX action:** charge + cosmetic approach + expanding vortex + anchored contact + attack fade, **0–3.08 s** of the 11-second showcase. Target contacts at demo-only 2.20 / 2.28 / 2.36 seconds are not real hit receipts.

**QA movie:** 660 = **11.0 s × 60 encoded frames/s**. The rest after the attack visually checks the shared tiny poisoned badge's remaining-life simulation and replay gap. Video encoding does not add gameplay sprite frames, but exporting 11 seconds repeatedly wastes CI/render/storage time.

**Recommended future QA cadence (not an engine or gameplay change):**
1. G3.5 quick native 1280×720 proof at charge/peak/moving contact (3 images from a short capture) for every visual change.
2. One full-motion ~3.3–4.0 s **attack animation** video only after passing manual 1× art review. Choose runtime based on action fade, not a fixed video-length quota.
3. Verify eight-second persistent poison/status with **two or three timed screenshots or a separate compact status regression**, instead of eleven seconds of full video in every iteration.
4. Only create a full 11 s combined film when needed for owner demonstration or regression. Use motion-derived key poses (38 for approved POI11), source-preserved alpha masters, bounded draw/texture cost, and real hardware profiling before any Android performance claims.
5. Do not treat fixed encoded 60 FPS as physical FPS, nor technician PASS as owner aesthetic approval. Do not automatically mark upper tiers approved.

**Gates:** `OWNER_VISUAL_APPROVED_R9` (Human LAB only); `GODOT_V4_TECHNICAL_PASS` on evidence above; `PVE_INTEGRATION_HOLD`, `V63_OFF`, `RUNTIME_MAPPING_PENDING`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`. No rig, Codex, branches, merge or Combat V2/SaveService/economy/AI/PvE edits.

This source-of-truth record does not claim any new exact-SHA engine run on the documentation-only acceptance commit.
