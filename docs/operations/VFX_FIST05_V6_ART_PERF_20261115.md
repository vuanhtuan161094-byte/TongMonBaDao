# FIST05 / Địa Mạch Liên Chấn — V3–V6 art + performance rework
Date: 2026-11-15 | PR #72 Draft | original Godot 4.7.2 Compatibility LAB only

## Contract and status
Canonical `tmb.skill.fist.ba_quyen.active_04.human`: damage/fire/circle/radius 3/cap 3/cast 0.45s/range 4/projectile speed 8. Source parameters read-only. V6 simulation still view-only: hit cues do NOT write damage or status or represent confirmed Combat V2 events. No rig, new branch, Codex, gameplay/save/economy changes, V6.3 OFF.

**Owner rejected V2**: tiled giant orange ground carpet, hard rectangular/mushy rock edge, high alpha overdraw. The original three painted WebP geology masters remain preserved and unchanged; the new optimizer lives in `tools/vfx/generate_fist05_v3_optimized.py` and its output is generated for CI, not copied from commercial source pixels.

## V3–V6 progress and visual gate
- V3 code SHA `f6f1eb42462d0e4b9bcb629c4694d163ba6cbef9`, Actions #43686056160: reduced visual asset page count and created one continuous fractured terrain strip; Godot technical PASS, but native frames were too sparse and art self-review FAIL. Earlier stress printed numbers but strict wrapper complained about Xvfb ALSA driver; NOT a valid accepted performance gate.
- V4 code SHA `c3d85f6ee038de51bf146574cb83941d1c9fb6b7`, Actions #43686672705: crop the actual painted silhouette before packing so rock is not shrunk by empty WebP margins, and add explicit Godot `--audio-driver Dummy`. Official Godot strict/stress PASS.
- V5 code SHA `58161a06ef56d27909938a9d641d680e1c9dd129`, Actions #43687206646: paint directional per-target sparks/stone at torso, bounded to three view-only contacts, tech/stress PASS. 1x art inspection still found primary eruption too small.
- **V6 final tested code SHA** `ff841d6888d5bab9cf2138ab976968dfbac56be3`: enlarge original single painted stone burst to recover scale, with no new texture/draw layer; official [Godot Actions #43687475435](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43687475435) SUCCESS. Strict import, script parse, `VFX_FIST05_FOCUSED_RESULT=PASS failures=0`, genuine 185-frame native 1280×720 MP4, GIF, 13 timecoded PNGs and SHA256 asset manifest. Native 0.75/1.13/1.55 compare with V2 shows cleaner one-piece fissure, one readable central painted stone, and individual target contacts. V6 still has visible old source-image art style and is NOT automatically owner-approved.

## RGBA texture-footprint calculation (not measured VRAM)
- Previous V2: 40 frames × 384² px × 4 bytes = **23,592,960 bytes (22.50 MiB)** across four atlas textures.
- V6: 1024×1024 core page (4 charge+12 eruption), 1024×512 contact atlas (8 poses), 1024×256 contiguous fissure strip = **7,340,032 bytes (7.00 MiB)** across three source textures = **68.89% raw pixel reduction** and 24 total discrete pose frames.
- V6 peak visual texture layers are typically one fissure + one main eruption + up to three per-target contact cues; these are canvas texture draws, NOT certified OpenGL draw-call counts. Share texture cache between instances; avoid repeated padded textures or overlapping huge alpha layers.
- Disk PNG compression, mobile import texture compression/mipmapping, actual GPU residency, and load/unload behavior differ and are not captured by raw-pixel accounting. Avoid claiming 7 MiB Android VRAM without measuring.

## Bench: software CI only, not real Android/game FPS
Shared test script: `godot/tests/labs/combat_lab/vfx_shared_load_benchmark.gd`; 15 warm-up, 90 measured wall-frame samples each at 1/6/12/30 VFX-only instances using identical preloaded atlas pages and skipping duplicate terrain/actor/HUD. Environment: official Godot 4.7.2 Compatibility, Ubuntu GitHub runner, Xvfb, **Mesa llvmpipe software renderer**, audio driver Dummy, no Android hardware.

V6 run #43687475435 verified both `VFX_LOAD_BENCH_RESULT=PASS cases=1,6,12,30` and `GODOT_STRICT_PASS`, with **observed mean wall frame durations**:

| VFX-only instances | Ubuntu Xvfb llvmpipe ms/frame (90 samples) |
|---:|---:|
| 1 | 1.715 |
| 6 | 2.309 |
| 12 | 2.971 |
| 30 | 5.031 |

These are only comparable CI timings for this shader/texture workload; do not infer Android 60 FPS or overall game 30-disciples/40-monsters frame time. Fixed-clock 60-FPS MP4 proves correct animation capture, not live 60 FPS. A physical Android and a realistic full-game stress scene remain PENDING.

**Current gates:** CODE_LAB_READY; GODOT_FOCUSED_PASS; NATIVE_MOVIE_CAPTURED; CI_VFX_ONLY_STRESS_PASS; FRAMES_REVIEWED; **OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / ANDROID_PERFORMANCE_PENDING**.
