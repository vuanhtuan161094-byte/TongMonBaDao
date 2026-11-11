# AS-CHAR-38 implementation status — 2026-11-12

PR: #72 · branch: integration/pve-p0-playable-ui-20261103  
Input HEAD fetched before this packet: bc3d2ccd3798b40914497f7772bbd5b980c4cfe1  
Scope: presentation-only sprite art tooling and isolated preview.

## Work completed

- Added two new neutral novice master turnarounds from the same image-generation pass family: male and female, four authored views each, transparent backgrounds. The V4 Nữ Độc Tu master is referenced only for quality/proportion/contour finish; its poison costume and identity were not copied.
- Exported one real static pose per direction to 512×128 RGBA atlases with 128×128 cells, direction order front/right/back/left, 70px visible body height and map pivot (64,104). No mirroring or motion frame synthesis is used.
- Added SpriteFrames assets with exactly one directional frame per static Idle and an isolated AnimatedSprite2D browser with branch, sex, direction, clip and zoom selection.
- Improved the isolated browser after visual inspection: alpha checkerboard, visible ground baseline and foot-pivot marker, explicit atlas/cell label, fixed 70px game body, and only 1×/6× inspection. The one-frame Idle is held with playback stopped; selecting Walk/Cast/Attack/Hit/Death never moves a frame.
- Added a versioned 38-group registry from the current visual-motif document. It maps 18 branch rows to the exact path candidate IDs present in the current V63 registry and leaves 18 rows explicitly design-only. The current V63 registry is disabled; these entries do not activate combat.
- Added a read-only resolver using canonical disciple_id, sex_id, v63_combat_branch_id, profile_seed, and an optional cosmetic seed. Unassigned disciples select their sex-compatible novice base. A known branch with missing art displays the matching branch status while rendering the novice fallback. Unknown IDs never map to a different branch. The adapter does not read or write latent_identity_seed, DiscipleState, simulation or save data.
- Added a deterministic, checksummed source-layer compositor. It alpha-composites only same-size RGBA layers matching the manifest's branch and sex; it does not recolor, transform or invent frames. Missing or unverified source returns ART_PENDING.
- Added focused Python tests for the registry, deterministic identity and compositor, invalid schema/hash, unknown branch, and missing asset. Added a Godot 4.7.2 smoke test for the read-only resolver and the 38-group load.

## Source and asset hashes

| Asset | SHA-256 | Export |
|---|---|---|
| Novice female turnaround source | 158977583fd3579202ad293d1c6f3b018258dcff6f90cd0164cf3c8609f1f68f | 1774×887 RGBA |
| Novice female static idle atlas | a3b850f5ba6b773875c709226924e27020cfd21a5e77710a570f3195b2b98629 | 512×128 RGBA, 4 one-frame directions |
| Novice male turnaround source | 840d0f22e60f3f909eb730b47d22af1d977eaabccb80ae0396db2754fe738240 | 1774×887 RGBA |
| Novice male static idle atlas | 3b17708f1eb3c1fc48c08552cd9a681bbf69aa3a65f34957fd00e1d5eb7b2e85 | 512×128 RGBA, 4 one-frame directions |
| Locked V4 identity/style anchor | 435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118 | Reference only; unchanged |

The atlas builder reports only 3 (female) and 18 (male) red-dominant replacements in its conservative alpha-boundary rule. At the 70px contact-sheet scale, no broad red outline is visually apparent; this was not treated as a reason to recolor the contour. The samples have not been visually approved by the owner. The contact sheets are static exports, not Godot GUI evidence. The interactive preview can inspect 60px and 75px body sizes as well.

## Gate status

| Gate | Status | Evidence |
|---|---|---|
| G0 live inventory | PARTIAL | Current V63 registry has 6 schools/18 path candidates, is disabled, and the motif document defines the 36 visual branch rows. Source A remains identity-unverified and is not reclassified. |
| G1 novice golden sample | PARTIAL / owner review pending | 2 transparent four-view static masters and direction atlases exist; 70px body size and shared pivot exported. No owner visual approval or Godot GUI review recorded. |
| G2 motion proof | ART_PENDING | No usable source motion clip or editable character layer pack is available in the checked inputs. Walk/Cast/Attack/Hit/Death remain pending. |
| G3 36-branch factory | STRUCTURE IMPLEMENTED / ART_PENDING | Full registry, resolver, source-gated compositor and focused tests exist. No branch layer packs, 12 unique style comparisons or 30 unique appearance roster are claimed. |
| G4 Godot game QA | PENDING | Official Godot 4.7.2 import, parse and isolated scene smoke are delegated to the focused PR workflow. The smoke now checks the actual preview scene, checkerboard, foot baseline/pivot, 70px body and 6× detail framing. Local GUI was not opened because other Godot processes were already present; no local FPS/RAM or screenshot is claimed. |

## Coverage metrics

- DESIGN_MAPPING: 38/38 groups.
- STATIC_DIRECTIONAL_IDLE_CANDIDATE: 2/38 groups (2 sexes represented).
- BRANCH_ART_RENDERED: 0/36, with male/female rows declared but both ART_PENDING.
- FULL_6CLIP_ART_APPROVED: 0/38.
- ROSTER_RENDER_COVERAGE: not measured; no production adapter or recruitable-roster integration is included.
- UNIQUE_12_VARIANTS / UNIQUE_30_ROSTER: pending source-backed art layers. No duplicated sprites are represented as unique art.

## Test evidence

Local scratch staging before commit: 14 focused Python tests passed using Python 3.12.10 and Pillow 11.3.0 against the exact registry/path fixture and exported PNGs. This does not replace the official Godot 4.7.2 workflow, which remains pending until the commit run finishes. Windows GUI and Android physical QA remain pending.
