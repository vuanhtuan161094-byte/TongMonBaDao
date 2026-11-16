# POI10 — Độc Khí Phệ Tâm (Human) — radial light-first painted VFX

2026-11-16 · PR #72 Draft · `integration/pve-p0-playable-ui-20261103` · isolated Combat Lab ONLY.

## Latest owner style correction, permanent production rule
The owner shared 3 Võ Lâm game VFX sprite sheets for observation, then explicitly stated that the **Poison school skill effects with glowing energy expanding in irregular round bursts** were beautiful. Preserve that spirit while improving light purity, luminous core, material and contact timing. Do NOT homogenize every skill into the same perfect circular decal, giant flat neon SVG or UI disc. **Keep a distinctive per-skill sprite subject**, arrange painted energy into an asymmetrical outward expanding corona, bright pinpoint impact and gentle vaporized residue. Deep violet + jade green + brief white-hot focus, with hierarchical brightness. Reference sheets are comparative observations only and **NOT** imported game assets. This is reusable craft guidance for later TMB VFX; skill-specific `OWNER_VISUAL_APPROVED` is never inherited.

## G0 — Canonical Human mechanical authority
`tmb.skill.poison.doc_cham.active_04.human` Độc Khí Phệ Tâm: branch `doc_cham`, `effect=poison`, `element=nether`, `shape=circle`, `radius=2.6`, `target_limit=3`, `range=7`, `cast_time=0.65`, `cooldown=12`, `projectile_speed=8`, `damage_ratio=0.9`, `duration=6`, `poison_stacks=1`. These are catalogue READ-ONLY values; any unrelated numbers written on concept posters are not authoritative.

## G1–G3 — Original first-party painted source
Created a new original first-party illustrated POI10 concept poster in this conversation, source filename `a_detailed_cinematic_game_style_vfx_skill_showcas.png`, SHA256 `dc0b42f83b913113c794fdc944fd1a86e06db0f1cc4e95fbe13abd3db014aa37`. It is **not** a Godot screenshot, gameplay footage, or an approved/accurate QA report: promotional text, UI, characters, purported FPS and mechanical values in the poster are NOT used in the engine. All actual production VFX master images are independently matted original painted-light pixels (no assets from JX/Võ Lâm/Source A) committed under `godot/labs/combat_lab/poison10/r1_painted/assets/master/`.

- `venom_core.webp` crop (579,172,661,271), 82×99, purple energy core.
- `venom_tendrils.webp` crop (679,190,870,300), 191×110, asymmetrical flowing poison vapors.
- `heart_puncture.webp` crop (994,445,1116,511), 122×66, localized violet-white rupture.
- `heart_corona.webp` crop (1135,322,1340,389), 205×67, green-violet ground corona carefully alpha masked.
- `heart_hotspot.webp` crop (578,205,623,252), 45×47, original source-white hot focal light.

Crops are explicitly alpha-matted using hue/luma and feathered fade to exclude actors, background, UI text and stats. These are **image-backed painted source pixels**, not screenshots pasted into Godot. Source code `tools/vfx/generate_poi10_painted.py` bakes non-rigidly varying frames, rotates and composes non-identical painted fragments into expanding organic circular pulses. It does not draw perfect vector circles or skeletal-rig the character.

## G3 — 46 authored frame RGBA8 atlas budget
- `devour_charge_r1_12.png`: 12 poses × 224×192, atlas 896×576.
- `devour_corona_r1_12.png`: 12 poses × 224×224, atlas 896×672.
- `devour_contact_r1_10.png`: 10 poses × 192×160, atlas 768×480.
- `devour_mark_r1_12.png`: 12 poses × 160×160, atlas 640×480.
- Total **7,176,192 bytes, 6.84375 MiB raw RGBA8**, excludes Godot runtime buffers/other effects/actor textures, and does NOT establish Android FPS.
- QA must ensure all 46 poses are distinct, all frames contain painted alpha, every cell edge fully transparent.

## G4 — Combat Lab choreography; no gameplay mutation
`res://labs/combat_lab/poison10/r1_painted/doc_khi_phe_tam_r1.tscn` draws an accepted Stage A actor and **three moving mock stand-ins** on existing Combat Lab immortal-valley background. VFX:
1. 0–0.65 s purple-jade toxin core converges at caster palm.
2. 0.65–1.30 s ONE toxic light wave goes straight to area centroid (not three reused needles).
3. 1.30–2.23 s radial nonuniform poisonous corona blooms across selected circle; localized contacts at t≈1.47,1.58,1.69 on moving chests.
4. Each target has ONE cosmetic mark for exactly 6s + .35s visual dissolve; mark follows chest when moving.
5. Full preview loop 8.55s (513 frames at fixed 60 fps movie clock).

**No actual poison receipt, HP write, AoE target resolution, gameplay damage, V6.3, real PvE integration or SaveService call.** 2.6 is a catalogue WORLD-radius parameter, not empirically converted to an arbitrary screen-space pixel radius here.

## G5–G7 QA and owner gate
`.github/workflows/vfx-poi-10-r1-painted-native.yml` uses SHA256-pinned Godot 4.7.2 GL Compatibility, generates original alpha atlases, strict import/parse, tests exact skill contract and no bleed/cap, records native H.264 1280×720 MP4 (513 frames), GIF and 14 timed stills, stores checksums, commits output sprite atlases safely on same PR branch and reruns QA at final exact SHA. CI PASS means engine and contract only.

**State at creation: OWNER_VISUAL_PENDING; PVE_INTEGRATION_HOLD; V63_OFF; PHYSICAL_ANDROID_WINDOWS_QA_PENDING.** Never report 60fps video encoding as real device FPS or claim POI10 art was approved before owner sees actual Godot footage. Preserve POI06 R11, POI07 R7, POI08 R4, POI09 R1, Combat V2, SaveService and other school art.
