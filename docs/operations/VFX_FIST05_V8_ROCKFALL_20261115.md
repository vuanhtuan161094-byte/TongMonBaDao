# FIST05 V8 — correction after genuine V7 movie QA (2026-11-15)

V7 native Godot SHA `0e11ae23dce7a3e3f49e64b26201920810e9a2fb`, Actions #43690001843 had strict import/parse/test, movie and 1/6/12/30 VFX-only bench SUCCESS. **ART FAIL at t=1.93s:** splitting one large source image into six polygon masks introduced **large angular dark holes** in the upright burning slab. Test PASS did not make the result acceptable.

V8 intentionally **rejects the polygon-fracture source**, instead paints **eight small fully isolated material fragments**, varied in scale, rotation and location, with per-pose gravitational falling arcs; parent pillar becomes a low-opacity transition ghost only briefly. V7 grounded earthen dust is retained. No new runtime draw calls, same original alpha-painted sources, same 3 source textures, 24 frames, 7.0 MiB raw RGBA budget. Full GDScript contact authority, three-target cap, cast timing and live gameplay remain unchanged. No rig, Codex, branch, merge, PvE or V6.3 change.

**Acceptance:** scrutinize native Godot frames 1.55 (peak), 1.93 (breaking), 2.12 (fall), 2.40 (settled), 2.83 (clear). Any giant dark polygon cutout, cloned rock decals or floating rock lingering is art FAIL. CI only verifies technical evidence; OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD.
