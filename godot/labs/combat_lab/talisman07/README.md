# HF02 — Liên Diệm Phần Giới | Hỏa Phù active_02 Human

**Canonical skill ID:** `tmb.skill.talisman.hoa_phu.active_02.human` from `godot/data/combat/v63_talisman_combat_catalog.json`, read at PR #72 HEAD `7deae99b43aec996ec1730df05336954d08c1a73` (2026-11-15). Fire / damage / **circle** radius **2.1 world units**, cap **3**, single hit per target, cast **0.62s**, range **8.5**, cooldown **10.8s**, projectile_speed **0**. Candidate source / gated V6.3 OFF. These are read-only references; no simulation mutation.

## Distinct visual identity — Liên Hoa Hỏa Diễm

Not HF01's Hỏa Long shot and not an ultimate. Charge: three small burnt-ink talisman strips open over the caster hand; then *at the fixed previously selected circle position*, seven asymmetric multi-tongued fire-lotus petals unfold with a luminous short white-amber core. They are **original independent sprite poses** (not runtime GDScript circles, stock images or re-colored HF01 art). A restrained broken crack/scorch lies under the target group, and up to three compact local fire bites are drawn behind the **real walking monster SpriteFrames**, with only momentary tiny glows in front to keep faces legible. The target visual movement is QA-only, uses 3 locked stand-in IDs and deterministic current render coordinates; there is **NO projectile**, homing, auto target selection or invented extra damage. All phase timestamps are LAB only, not real hit receipts.

## First-party art sources / atlas contract

Recipe `tools/vfx/paint_tal07_lien_diem.py` paints original transparent RGBA with Pillow/NumPy **and** composites an independently alpha-extracted, edge-feathered 80×65 fire-arc fragment from an original ImageGen concept authored for this project (`art_sources/tal07_painted_fire_arc_png.b64`). This is a genuine transparent magic-material source fragment, not the poster/scene/character pasted into gameplay. Four differently rotated and per-pose animated fire arcs support the independently painted seven-tongue lotus. No commercial JX / Source A pixels, no rig. Output generated before Godot import; does not need or reuse any HF01 painted master:

| Asset | Frames | Cell | Atlas |
|---|---:|---|---|
| `tal07_lotus_flipbook.webp` | 12 | 512×384 | 2048×1152 |
| `tal07_seal_flipbook.webp` | 12 | 256×256 | 1024×768 |
| `tal07_ground_flipbook.webp` | 8 | 512×256 | 2048×512 |
| `tal07_contact_flipbook.webp` | 8 | 256×256 | 1024×512 |

All alpha and unique pose SHA256 checks are strict; authored source held in Python, actual WEBP image outputs are generated in GitHub CI artifacts and before any local Godot import. CI exact-SHA is the rendering authority for the generated sprites. Do not claim there are committed WEBP binaries if there are none.

## 1280×720 native Godot choreography / quality gate

- 0.04–0.62: hand talismans illuminate and ink completes
- 0.64–0.89: broken ground scorch rises under the preselected cluster
- 0.79–1.37: lotus petals grow, with no invented projectile
- 1.37–1.72: up to three local demo impacts on moving locked monsters, each demo hit count one
- 1.72–2.62: flame/ash falloff, no DoT/status
- 2.62+: empty/fade, no persistent gameplay effects

Real Godot 4.7.2 Compatibility 1280×720 movie fixed 60fps, 198 frames; >=14 timed PNGs incl .30/.43/.70/.90/1.13/1.38/1.49/1.62/2.22, GIF and checksum from exact source SHA. Review at 1× for rounded primitive appearance, flame silhouette, foot layering, local impact, alpha seams, color readability and monster movement. **Technical PASS is NOT artistic approval**. Status `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_PENDING`. Never pass the AI concept poster off as a Godot frame or publish its incorrect invented name; the only source pixels retained are an isolated fire-arc fragment, with independently baked alpha and pose animation. **Liên Diệm Phần Giới** is the only canonical HF02 name.

Files scoped to `talisman07/**`, its generator, focused test and isolated workflow. No Codex, rig, branch/merge, Combat V2/SaveService/PvE changes.

## R1 → R4 visual repair (15 November 2026)

R1 native 1280×720 QA run [43711337301](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711337301) passed TECH but was **self-rejected** visually because its seven tips looked like thin upright yellow wires. R2 [43711758547](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43711758547) widened organic petal masks and replaced the starburst contact with body-local fire, tech PASS, but full-screen motion still resembled seven candles. R3 [43712472741](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43712472741) layered a feathered original image-painted fire source into the independent poses, tech PASS. R4 native-scale adjustment enlarges ONLY the presented fire-lotus silhouette and hand seal to make it readable at 1×; never scales the gameplay world radius. **R4 must get a fresh exact-SHA native Godot movie; no art approval is inferred**. Owner visual pending.
