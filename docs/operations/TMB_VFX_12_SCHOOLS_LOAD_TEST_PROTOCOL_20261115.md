# VFX performance protocol reusable for 12 schools (2026-11-15)

**Scope:** technical template, not blanket approval or existing Android measurements of every school. Implementation first verified in `godot/tests/labs/combat_lab/vfx_shared_load_benchmark.gd` at FIST05 tested SHA ff841d6888d5bab9cf2138ab976968dfbac56be3 and Actions #43687475435.

## Isolated scene test
Each school LAB must provide a scene that accepts `vfx_only_benchmark` (Boolean, skips duplicate demo backgrounds, actors and HUD but retains its original effect sprites) and `elapsed` preview phase; the scene must allow Control/CanvasItem position and scale. Script accepts optional `--scene=res://.../skill.tscn` user argument. 1, 6, 12 and 30 identical texture-cached VFX instances render in the viewport, with 15 warmup and 90 measured frames each. Record engine exact SHA, machine, renderer, sound driver and wall-frame times; require both `GODOT_STRICT_PASS` and `VFX_LOAD_BENCH_RESULT=PASS` markers. If scene lacks this interface, implement it in an isolated school LAB rather than editing Combat V2.

## Resource budget
Report actual atlas page width × height × raw pixel-channel bytes and disk compressed bytes separately; avoid multiplying shared texture memory by number of skill activations. Check alpha padding and overdraw (large transparent pixels still occupy raw atlas storage). Track actual simultaneous VFX instances; use lifecycle cleanup and texture reuse. Count visual CanvasItem layers, not claim them as hardware draw calls. Do not create animated effects as procedural UI rings, nor substitute code-only line art for painted hero sprites.

## Physical QA still required
For each target Android/Windows device, measure FPS distribution/frame-time percentiles, CPU/GPU time, memory residency/load stutter and thermal throttling with 1, 6, 12, 30 VFX-only instances, then repeat inside the actual combat scene with the intended squads, up to 30 disciples and 40 active monsters, camera/UI/real confirmed combat events. Suggested targets **to verify**: 60 FPS where possible and steady 30 FPS on representative mid-range Android devices. Never infer success from a fixed-FPS 1280×720 Godot capture or software-renderer Xvfb CI. No production PvE integration or V6.3 activation without explicit authorization and owner art approval.
