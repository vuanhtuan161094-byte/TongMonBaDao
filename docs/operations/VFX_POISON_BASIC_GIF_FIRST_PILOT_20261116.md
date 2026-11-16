# VFX Poison Basic — GIF-first pilot / current 16 Nov 2026

## Scope and status

One skill only: **tmb.skill.poison.basic.human** — Độc Châm Thường Thức, CAST_MASTER Human normal attack. `damage`, `metal`, `single_target`, target cap 1, `duration=0`, `poison_stacks=0`; **not a poison status and not heal or AoE**. Canonical Human `cast_time=0`, cooldown 1.6s, damage_ratio1.0; do not interpret a ~0.88s storyboard as the gameplay cast or hit time. Unknown real Combat V2 receipt mapping: `RUNTIME_MAPPING_PENDING`.

Owner asked to test a short GIF first and standardize the improvement if successful; did not request four character rigs or four sets of VFX assets. Original eight-frame 110ms ImageGen GIF created in the conversation, illustrated chibi Poison sorceress for motion reference. Character in the GIF **is not approved current game actor art**. Original GIF is a motion/storyboard source only; it cannot be committed into the production game unseparated.

## Local extraction prototype (not yet repository-native QA)

- Image source GIF: 443×443 px, 8 distinct frames, 110ms/frame, 0.88s loop; source `source_original_gif_8fr.gif`, SHA256 `5e99eb91034edfba1f42b0dfb17372165bf7086e7254b6a3a81ce627415205db`. Exact bytes belong to this conversation's user-facing downloadable source pack; they are not misrepresented as already existing inside this GitHub tree.
- Extracts a fixed preselected right-side VFX region and smooth alpha from the source; no original chibi actor imported. Eight transparent FX poses grouped as **3 charge, 2 flight, 3 impact/fade** in independent 256px/cell PNG atlases. The source remains preserved in the downloadable pack with extraction recipe, contact sheet and QA manifest. Source illustration has more bloom than the intended restrained basic attack; scale the contact to roughly 90–120 px at game 1× and inspect in-engine.
- The quick animated GIF and source extraction are **NOT Godot output**; do not label a Python contact sheet or ImageGen GIF as actual native Godot render. No Godot 4.7.2 exact-SHA test has been run for these new original bytes at time of record. First-party art origin, visual QA, and reuse permissions are documented in source pack. GitHub approval must require separately imported source PNG atlases and true Godot native 3-frame moving-monster evidence.

## Test acceptance stages

| Gate | Result |
| --- | --- |
| G0 catalogue Human / damage/metal/single target | Verified, same skill only |
| G2.5 GIF 8×110ms | **CREATED, VISUAL REVIEW PENDING** |
| G3 FX-only alpha extraction / ZIP source proof | **LOCAL PILOT CREATED**, not native engine |
| G3.5 native Godot 1280×720 charge/peak/contact on moving target | **NOT EXECUTED** |
| G5 full native attack-length movie, source fidelity 1x, actual target | **NOT EXECUTED** |
| Human art self-acceptance | **PENDING** |
| Owner art approval | **PENDING** |
| Immortal and Divine tiers | **NOT STARTED**, separate asset identities and owner gates |
| Combat V2 mapping, PvE/V6.3 and physical device QA | **HOLD / OFF / PENDING** |

The user can review the standalone GIF and alpha atlas pack and ask for repair without compromising already accepted Poison Human skills or altering the map/combat runtime. This is a **new** normal-attack master; do not confuse it with the 12 previous Poison dedicated spell LABs.


## Owner correction 16/11/2026 — GIF crop NOT acceptable final VFX

Owner assessed extracted GIF-to-alpha trial as **not sufficiently translucent, with colors losing their original vividness**, and clarified GIF must be **movement reference ONLY**. Therefore the historical 8-frame cropped alpha contact sheet / ZIP is **ART_REWORK_REQUIRED / NOT OWNER APPROVED / NOT GAME-READY**. Keep it as prototype/evidence of why direct GIF background removal is unsuitable. Recreate completely original translucent color-rich RGBA sprite sources for charge, needle, contact and fade; reserve white-hot center and soft colored bloom in separate layers, using approved character art independently. Native Godot import, moving-target three-shot, short full-motion video and exact-SHA remain NOT_EXECUTED for corrected basic attack. Human/Immortal/Divine basic visual approvals all still pending; no Combat V2, PvE or V6.3 changes.
