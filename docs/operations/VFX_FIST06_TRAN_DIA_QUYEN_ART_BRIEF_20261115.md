# FIST06 — Trấn Địa Quyền / Kim Cang / Human (2026-11-15)

## G0 catalogue truth and scope
- Exact ID: `tmb.skill.fist.kim_cang.active_01.human`, active_01 in branch `kim_cang`, school Fist, Human.
- Effect `damage`, element `earth`, shape `single_target`, target_limit 1, range 2.8, cast 0.45s, cooldown 8s, projectile_speed 8, damage_ratio 1.35 (metadata READ-ONLY); radius 0, no guard/AoE/mark.
- Only visual LAB; cannot change confirmed Combat V2 cast/hit/HP or projectile authority. V6.3/PvE OFF; only event-bound preview. No rig, Codex, branch/merge, SaveService/AI/economy changes.

## Art direction — not another Ba Quyen fire AOE
**One stone-crusted knuckle fist**, from angular earthen pressure to a short strike, then a localized rock fracture on ONE moving target. Ink-dark granite, muted ochre seams and mineral-gold pin highlights, not orange explosion star, stone pillar spam, talisman runes or a full glowing screen circle. Top-heavy velocity, very short contact flare and restrained gray-umber dust; the rest of the frame remains readable at 1× game scale.

## Production master / provenance
- An original source-code-drawn raster stone-fist hero, **not** ImageGen art, not a JX commercial source and not footage from a prior VFX.
- `tools/vfx/generate_fist06_tran_dia_quyen.py` generates two original PNG RGBA 256px-cell atlases: 16 pose MAIN (4 charge + 12 travel) in 4x4 1024x1024, 8 pose localized HIT in 4x2 1024x512. Full first-party deterministic source preserved. No rig, target remains a statically sized original UI scale stand-in.
- Main: knuckle geometry, mineral seam highlights, fractured palm facets and independent motes. Contact: different stone chips and airborne dust; localized to target torso.
- Both sheets share 2D textures; **6,291,456 bytes = 6.00 MiB raw RGBA**; uncompressed raw accounting is NOT physical mobile VRAM or a tested FPS. CI creates and hashes PNGs before Godot import.

## 60fps lab storyboard, not a Combat V2 timing receipt
- 0.00–0.45: stone knuckles compact at caster hand (charge)
- 0.45–0.72: one short earthy fist travels along a dynamic aim line to the moving target
- 0.72–0.96: one grounded contact flash, target full-sprite recoil PREVIEW ONLY
- 0.96–1.28: stone chips and earthen dust fall and clear
- 1.28–1.68: no VFX (full clear, loop)
- Native frame checkpoints at 0.12/0.34/0.44/0.51/0.62/0.70/0.74/0.80/0.93/1.04/1.18/1.38.

## QA / acceptance
Godot 4.7.2 GL Compatibility strict import, parse, focused contract, native film MP4 1280x720, GIF, 12 timecoded frames, original atlases and checksums on exact GitHub SHA. Visually reject if hero looks like a flat beige vector, if the actual attack loses its leading knuckles, if enemy is covered by an opaque cloud, if body reaction looks like fake hits, or if release lacks speed/weight. Keep tech PASS and visual quality separate; **OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / ANDROID_PHYSICAL_PENDING**. User-approved Ba Quyền labs remain untouched.

## R1 → R2 visual self-QA (native Godot, 2026-11-15)
- R1 [Actions #43711682696](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711682696) source SHA `857951d419cbf22f32200ed64d559b6628e8411b`: strict Godot import, parse and focused PASS, native 1280x720 112-frame MP4/GIF/12 shots. **Art FAIL:** native 0.51 and 0.62 shows a flat beige hand-like logo, 0.74–0.93 impact almost invisible, cast underweighted.
- R2 source patch: more independently generated granular rock facets/shadows, 10 irregular ember-mineral seams per frame, brighter controlled contact flash, 22px view-only victim recoil, 1.02× full hero scale and visible localized stone fragments. Retains 24 frames, two shared textures, 6.00MiB raw RGBA. Full-body actor remains unapproved static stand-in, no rig. R2 needs new exact-SHA Godot movie and 1× review.
- Never call tech PASS owner art approved; if still flat, must polish/painterly replace hero artwork before integration. PVE_INTEGRATION_HOLD.

## R3 — first-party painterly light-brush adoption
R2 actual 1280x720 Godot Actions #43712245581 source SHA `07d918f261b9e58d80ded406d87f20e29395740f` strict PASS. At native 0.62 fist geometry/texture was still too flat; contact at 0.80 is visible but remains mostly golden smoke. R3 **retains original Kim Cang rocky fist silhouette and individual faceted poses**, and imports **only sparse light-luminance pigment** from another project-owned first-party art master `godot/labs/combat_lab/fist03/assets/godfist_master.webp`, with transparent clipping to the NEW source mask; not a recolor/copy of the older master silhouette. Provenance is clearly shared original project art, not newly generated ImageGen art. No extra runtime resource: two 24-pose RGBA atlases total 6MiB remain. Independent beauty review required; no owner art approval inferred from approved FIST03 artwork or CI.


## R3 exact-SHA Godot evidence & artist review
- Exact tested source SHA **`47de774d72fdf4755fe9347becd79cfd990fdcd7`**; [official workflow #43712827253](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43712827253) **SUCCESS** on Godot **4.7.2.stable.official.ed1daf0bf**.
- Image generator: `FIST06_ATLAS_PASS frames=24 textures=2 raw_rgba_bytes=6291456 no_rig=true`; source alpha QA PASS. Godot strict import, parse, focused `VFX_FIST06_FOCUSED_RESULT=PASS failures=0`. 112-frame real native Godot 1280×720 MP4 encoded fixed-clock 60fps, GIF, twelve native PNG checkpoints, SHA256 and atlas artifact #14161765356. Fixed-clock 60fps is **NOT** actual Android FPS.
- Visually checked 0.12 / 0.34 charge, 0.51 / 0.62 travel, 0.70 release, 0.74 / 0.80 contact, 0.93 / 1.04 dust and 1.38 full clear, all 1× native screenshots. R3 has clearer molten mineral grain and more visible local impact than R1, but fist silhouette still reads somewhat icon-like; target response is a modest full-sprite recoil, not premium authored hit animation. This is only **LAB first art candidate**: self-rubric silhouette 3.0/5; material/light 3.4/5; timing/weight 3.2/5; readability 3.4/5; contact 3.2/5; fade 3.7/5; uniqueness 3.2/5. Below 4/5 art gate, so **ART_REWORK_REQUIRED / OWNER_VISUAL_PENDING**. Preserve all files and exact film evidence; do not silently graduate to PvE.
- Gameplay view-only, no changed Combat V2/SaveService, no rig, no branch, no merge. Android performance and full-game combat 30+40 stress **NOT measured**; 6.00 MiB is raw source RGBA, not measured VRAM.
