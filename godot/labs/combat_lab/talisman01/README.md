# TAL01 / Phù Tu — Điện Quang Khai Phù (Human) / owner visual PENDING

**Canonical:** `tmb.skill.talisman.loi_phu.active_01.human`; `damage` + `lightning`, single-target cap 1, cast 0.50s, cooldown 9.40, range 8.50, projectile_speed 10.0. Numbers are **read-only catalogue references**, NOT implementation of Combat V2.

## Art direction / provenance
- Original TMB 12-pose painted parchment / ink / gilt / evolving electric-ink raster atlas. Individual frames vary paper geometry, foil illumination and current reveal. Authored in `tools/vfx/generate_talisman01_atlas.py`, deterministically generated as a 3x4 RGBA PNG 900x1440 (cell 300x360). **No commercial JX or Source A sprite used in the talisman.**
- The already-existing project backdrop and female character are **temporary neutral stand-ins for composition**, not claimed Phù Tu character art; they are unchanged. The live actors are not loaded in this LAB.
- White/lavender hot filament, deep violet field and rare forks; one lightning head remains connected to the caster through a lengthwise alpha-fading, curved ion conductor. Impact uses asymmetrical fracture strokes and five irregular motes, not a spoked star. Avoid giant opaque circles and fake multi-hit.
- Research: project `TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`, JX1 / Source VL inventories, original 4-skill HTML and V9 lightning for light/motion language only, no proprietary pixels imported.

## Choreography, LAB-only clock (not PvE event timing)

| Time (s) | Phase | Visual contract |
|---|---|---|
| 0.03–0.50 | ink_charge | Seven unequal quiet stars flow toward parchment; 12-pose ink begins illuminating |
| 0.50–0.72 | seal_release | Last strokes ignite; parchment leans and releases energy from caster's hand |
| 0.72–1.43 | electric_flight | One white-violet hot filament follows an arched path, 2 short forks max; head+fading whole-path source conductor |
| 1.43–1.76 | demo_contact | One impact-local flash on exactly one demo actor, *not* Combat V2 hit declaration |
| 1.76–2.66 | dissolve | Wisps and remaining current extinguish; no real status or effect persists |

**Control:** Space restarts preview; P pauses. Generate the atlas before opening in Godot:

```bash
python3 tools/vfx/generate_talisman01_atlas.py
```

Run the workflow `.github/workflows/vfx-tal-01-dien-quang-khai-phu.yml` for actual Godot 4.7.2 GL Compatibility 1280x720 video, GIF, 14 timecode PNGs, original PNG atlas, and strict QA. Workflow output (if green) proves scoped Godot rendering, **not** physical frame performance, owner art acceptance or PvE integration. Movie has native fixed 60 frame clock, not measured FPS.

## Allowed scope and state
- Can change only LAB `talisman01/`, associated test, generator, workflow and scoped art docs on this PR. The Poison writer owns all `poison*/` paths; **do not modify Poison labs**.
- No rig, Codex, new branch/merge, Combat V2 damage/HP/target/AI/SaveService/economy changes, feature gate or live PvE. `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / PHYSICAL_WINDOWS_ANDROID_PENDING`.
- Next: inspect actual 8+ Godot frames, fix visual defects on same skill, then ask owner to review genuine movie before any second Phù Tu skill.

## Native render inspection / R1 → R2 correction

- R1 workflow #43574121082 on `4231bc9316d46019d624e4274305c293c2538011` completed exact-SHA Godot 4.7.2 strict import/parse/test and 188-frame 1280x720 MP4 PASS. Downloaded and actually inspected frames 0.43, 1.08 and 1.51. Art R1 rejected internally: bolt visibly disconnected at 1.08, six symmetric impact spokes at 1.51 were too graphical.
- R2 changes only the LAB presentation: continuous tapered ion wake from the caster, brighter active head, 2 minor forks, off-axis fractured contact instead of symmetric spokes. Preserve original 12-pose parchment and read-only skill data. New exact-SHA video and actual frame review REQUIRED.

- R2 actual Godot 1280x720 movie #43574629565 (`fb5b32ef3f4337ca2fd2b5b3696e1143a84ed599`): strict import+parse+focused PASS. Visually examined 0.43, 1.08, 1.51 and full contact sheet. Reconnected bolt at 1.08 is readable; contact at 1.51 remained too straight and hard-edged. **R3** changes impact only: 3 unequal locally crackling currents, soft hotspot, 6 small motes, no six-spoke/diagonal hard icon. R3 Godot movie is separately required.

R4 ART RESET (2026-11-14): R1–R3 notebook-like talisman rejected by owner. Replace with 12 painted transparent poses derived from self-generated original art, a dense violet-white luminous conductor and image-mask impact. View-only, no combat integration. Master visual owner approval pending.

R4 original finished artwork: `assets/thunder_talisman_atlas.webp` (12 pose original generative illustration, alpha extracted and re-animated independently) + `assets/thunder_impact_burst.png` (independent procedural luminous shatter). Reference board is not a Godot screenshot. Visual check mandated at actual 1280x720.
