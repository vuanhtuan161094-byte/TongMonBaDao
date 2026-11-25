# Liệt Địa Sát Văn — Art-First Source Gate

**Skill ID:** `tmb.skill.formation.sat_phat_tran.active_01.human`
**Revision packet:** Formation R1 work, source experiments R1–R3
**Repository branch:** `integration/pve-p0-playable-ui-20261103`
**Baseline checked before writing:** `cde55abb138d150d39e0eadce7a487c68e841fb7`
**Gate:** `G3_ART_REWORK_REQUIRED` · `G3.5_NATIVE_NOT_RUN` · `OWNER_VISUAL_PENDING` · `PVE_HOLD_V63_OFF`

## Canonical contract checked

`godot/data/combat/v63_formation_combat_catalog.json` defines this Human skill as `formation_zone`, circle radius 1.1, target cap 3, duration 3.2 seconds, one-second tick interval, cast time 0.6 seconds, Earth element, and `projectile_speed=0`. It does not damage when the field is created. The real zone system selects eligible living enemies in radius and resolves each scheduled tick; a tick has at most three target IDs. The source contains no projectile, initial damage burst, stun, or extra hit. The combat catalogue is still candidate gated and V6.3 remains off.

The school presentation manifest describes `skill_cast` and `skill_release` at the caster, the field at ground center, and tick cues only from `v63_formation_zone_tick`. The image sources are presentation studies only. A future renderer must anchor the field to the real zone and show a localized cue only for a real tick receipt and its listed target IDs.

## Art brief and scale

The proposed motif was an asymmetric set of earth fissures and jade mineral anchors, with a compact near-white core, translucent jade/teal body, restrained gold mineral detail, and an open center. No circle border, copied glyph, projectile, slash, damage on creation, or visual-only target effect. The intended phases were gathering, field deployment, quiet sustain between ticks, receipt-bound tick cue, and natural zone expiry.

The production world uses `HALF_W=25`, `HALF_H=13` in `SectIsometricWorldV1.project()` and the PVE camera defaults to zoom `0.55`. Projecting the catalogue radius of 1.1 cells gives an estimated default-view footprint of about **43×22 screen pixels** (about 78×40 px at zoom 1.0). This calculation is a scale estimate from code, not a native capture. The projected review sheet uses that footprint and is explicitly not Godot output.

## G3 result

Three image-generation iterations were reviewed. R1 and R2 looked faint or fragmented on light terrain; R3 gained a stronger jade stroke but read as a few small marks or a quick strike at the actual projected field size, not a sustained formation zone. The contact and expiry cues also did not read distinctly at their intended target scale. **No iteration meets the source-art bar.** The source-only review therefore stops at G3; no scene, script, atlas integration, native test, Actions run, or gameplay change was made.

| G3 rubric | Self-review | Finding |
|---|---:|---|
| 1× silhouette | 1/5 | At 43×22 px, the active field collapses to sparse points or thin strokes. |
| Luminous material | 2/5 | Jade and ivory are present, but the low-scale body is weak on light terrain. |
| Choreography | 1/5 | Generated stage variants do not form a sufficiently clear, distinct field lifecycle. |
| Composition | 2/5 | The open center is preserved, but the field footprint is hard to recognize. |
| Receipt-bound contact | 1/5 | The small tick accent is not yet a convincing, correctly scaled contact cue. |
| Expiry / fade | 1/5 | Expiry art remains too close to the seed pose at game scale. |
| School identity | 2/5 | Earth/jade material reads, but Formation is not yet distinct enough. |
| Crowd readability | 1/5 | Not demonstrated in a real moving-actor scene. |

The first review script pass at 60–180 px was only a large-scale comparison. The final projected review is [g3_projected_default_camera_1x.png](r2/review/g3_projected_default_camera_1x.png); it shows each selected source on dark and light backgrounds at the estimated 43×22 px field footprint and a 10×14 px tick accent. The smaller images confirmed the G3 failure. The utility contact sheets and manifests are under `r1/review`, `r2/review`, and `r3/review`; they state that they are source-only, not Godot proof or art approval.

## Provenance

Original RGBA PNG candidates were generated with the available ImageGen route and are marked `RECREATED`. No commercial game art, external images, or copied runes were used. Generated source PNGs, prompts, output IDs, SHA-256 hashes, dimensions, alpha checks, and source-review hashes are recorded in [generation_provenance.json](provenance/generation_provenance.json). The original ImageGen output files remain in `/workspace/generated_images`.

## Next gate

Rework the field silhouette at G2/G3 with a stronger small-scale authored form. Do not create a Godot LAB, run native VFX QA, connect the catalogue renderer, or represent any hit until a new original source set passes a dark/light review at the actual game scale. Owner approval and V6.3/PvE integration remain separate future gates.
