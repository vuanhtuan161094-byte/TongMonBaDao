# AS-CHAR-49 V10 — partial source-verified candidate (2026-11-16)

**Status: 23/24 candidate clips, 0/24 Godot/production owner-approved.** This is NOT a 24/24 art-complete claim.

## Artifact & provenance

- Canonical ZIP saved in ChatGPT Library: `/TMB-Character-Art/AS_CHAR49_V10_23OF24_TECH_CANDIDATE_20261116.zip`.
- ZIP bytes: **146,058,581**; ZIP SHA256: `c8290077e0fc8ee9fd99f21b4e69038f2c3fecb9471bde253799bb4ef1fcd4fa`; entries: **636**; CRC PASS.
- V9 source ZIP original SHA256: `9939b1363d0c8d706f1d3f728ebbc18f6748528ce7253dbad6c2d88dcec8e9e8`. Original **144 RGBA 512² PNG frames** have identical SHA256 in V9 and this package; no rerender of accepted V9 candidates.
- Death handoff source ZIP original SHA256: `2581573b6a5639f686df073fbd8818caa15ddc8fedec6313d90d1bd6c0f27ea9`. Three *different* original 32-frame sequences used for Death_Front (source 02, slight 3/4 front), Death_Right (03), Death_Back (04). No mirroring, no rigging, no GIF renaming. 96 additional 512² RGBA PNG frames, individual four-column atlases, transparent GIFs, APNG, manifest per-frame SHA256, source GIF originals and offline MP4/contact proof.
- Total **23 clip candidates / 240 PNG frames**. `godot_lab/FemaleSwordV10.tres` and standalone 1280×720 Godot *source project* included; **Godot 4.7.2 binary not present**, so native import/capture and zoom 1×/2×/3× QA are **NOT_RUN**. Videos inside ZIP labelled `OFFLINE_NOT_GODOT`.

## Open gates

1. **Death_Left MISSING**: none of four source 32-frame GIFs establishes an independent left-facing fall/hold; front variants cannot be renamed or mirrored. Rejected source 05 ends standing up. No placeholder left GIF in the package. Do not mark 24/24.
2. **Art/identity pending**: three Death source GIFs differ in finish from V9 grids; owner needs to review frames at 1×/2×/3×. Current candidate ≠ accepted character animation.
3. **Source-border visual clipping not repaired**: Cast_Right frames 05–06, Cast_Back frame 04, Hit_Left frame 03 remain open; part of source painting is missing, cannot be restored by technical alpha/atlas validation alone. Sword edges on Attack also require art review.
4. **Engine/owner pending**: 0/24 production approved; no official Godot 4.7.2 test, no Windows/Android art gate.

## Repro checks performed

- V9 `tools/verify_v9.py`: `PASS V9: 20 clips, 144 frame SHA/alpha/atlases and 40 animated preview probes; 4 Death missing`.
- V10: all **240** PNGs 512×512 RGBA; per-frame SHA256 matches `CLIP_MANIFEST.json`; pixel-identical atlas cells; original 144 PNGs unchanged; three new GIFs (32 frames each) transparent; three APNG (32 each); ZIP CRC PASS; `MANIFEST_SHA256.txt` shipped.
- Offline review movie is NOT an engine movie, and no video/export has been presented as a native Godot capture.

Scope: only character sprite export/review package. **No new branch, merge, Codex, rig, Combat V2, SaveService, economy, PvE, V6.3, or production actor integration.**

Branch: `integration/pve-p0-playable-ui-20261103`; PR #72 Draft. HEAD inspected at start `00759b11aeccc4a0e4fd5ec1c6eefeb1217c46d4`; before documentation write `6dd9aaaae494dffed682eaecbb1a7753259ec9b3` (parallel writes present).
