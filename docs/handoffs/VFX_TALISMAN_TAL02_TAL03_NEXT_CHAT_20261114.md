# VFX PHÙ TU — BÀN GIAO TAL02/TAL03 14/11/2026
**Current GitHub checkpoint reviewed:** PR #72 Draft, branch `integration/pve-p0-playable-ui-20261103`, HEAD `fdc173158b5987259623b4802ecee17c2833440e` at handoff creation. Always re-fetch live HEAD; parallel chats may move it.

## Owner instruction and why a new chat
Owner wants to **rework TAL02 Thiên Lôi Dẫn Nét and TAL03 Lôi Văn Truy Ấn so the actual skill matches the attractive rendered formation and lightning-fracture textures**, then write that production method into shared VFX instructions. Current chat became noisy through repeated concept posters/intermediate sprite files, so consolidate at this GitHub truth. Do not treat poster images or generated artwork labelled "R6" as proven Godot render/merged GitHub commits.

## Verified latest actual committed status (not a plan)
| LAB | Latest path-specific revision | Exact SHA verified Godot Actions | Evidence |
| --- | --- | --- | --- |
| TAL02 `tmb.skill.talisman.loi_phu.active_02.human` | **R5**: `05dc27191c50e941caa3f180fd96aaf705ff3a27`; 10-pose painted current atlas, correct artwork anchor via baked x-dependent vertical shear; original alpha master and local painted fracture/underfoot | **PASS** [Actions #43585604728](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43585604728), artifact `vfx-tal02-05dc27191c50e941caa3f180fd96aaf705ff3a27` ID `14110132703` | Godot 4.7.2 strict import, parse, focused checks, 1280×720 video+GIF+stills by workflow. **Art not owner-approved**. |
| TAL03 `tmb.skill.talisman.loi_phu.active_03.human` | **R3**: `d67a3476926991d14bb640adb49a216fb4a8cfac`; painted 8-pose target mark, radius reduced to protect face/chest | **PASS** [Actions #43584912286](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43584912286), artifact `vfx-tal03-d67a3476926991d14bb640adb49a216fb4a8cfac` ID `14110500163` | Godot 4.7.2 strict import, parse, focused checks, 1280×720 video+GIF+stills by workflow. **Art not owner-approved**. |

TAL02 catalogue: lightning damage, `line`, max **3** targets, cast **0.62s**, range **9.5**, cooldown **10.8s**; 0 projectile speed in source.
TAL03 catalogue: `mark` on `single_target`, max **1**, cast **0.50s**, range **8.5**, cooldown **12.2s**, duration **6.0s**; VFX must **not** fabricate damage/DoT/ticks.

### Source-of-truth filenames
- `AGENTS.md`
- `docs/operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md`
- `docs/operations/TMB_VFX_SPRITE_FIRST_QUALITY_RULES_20261114.md`
- `docs/operations/TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md`
- `docs/operations/TMB_VFX_PAINTED_SOURCE_TO_GODOT_ASSET_GATE_20261114.md` (already committed; explains source provenance, black-background removal, alpha, painted 4×3/4×2 atlas, art QA, rebake corrections)
- `docs/operations/TMB_VFX_TALISMAN_PLAYBOOK_20261114.md`
- `godot/data/combat/v63_talisman_combat_catalog.json`
- `docs/operations/vfx_school_ledgers/02_talisman_183.csv`
- `godot/labs/combat_lab/talisman02/README.md`, `godot/labs/combat_lab/talisman03/README.md`
- `godot/labs/combat_lab/talisman02/thien_loi_dan_net.gd`, `godot/labs/combat_lab/talisman03/loi_van_truy_an.gd`
- `godot/labs/combat_lab/talisman02/assets/tal02_thunder_master.webp`, `tal02_thunder_flipbook.webp`, `tal02_fracture_impact.webp`, `talisman_foot_array.webp`
- `godot/labs/combat_lab/talisman03/assets/tal03_mark_master.webp`, `tal03_mark_flipbook.webp`
- `tools/vfx/rebake_tal02_from_master.py`
- `.github/workflows/vfx-tal-02-thien-loi-dan-net.yml`, `vfx-tal-03-loi-van-truy-an.yml`
- `godot/tests/labs/combat_lab/vfx_tal02_contract_test.gd`, `vfx_tal03_contract_test.gd`

## Required exact next work (execute, do not start over)
1. Download **the two verified latest artifacts** above and visually inspect full native Godot MP4, contact sheet, and 8+ timecode PNGs, with special attention TAL02 at **1.08s and 1.51s** (caster-palm origin / middle / target endpoint, diagonal tilt, poster crop edge, alpha, bright core, event geometry) and TAL03 at **1.08s and 5.03s** (face occlusion, stamp readability, residual six-second visual, alpha box/halos).
2. Preserve **painted raster pixels** as the primary spell silhouette. If corrections needed, rebake the actual source master/flipbook with clean feather alpha, true per-pose motion, corrected native-size texture coordinates/pivot; **do not go back to uniform GDScript neon lines or giant opaque vector circles**. Distinct underfoot ritual and fracture appear only where appropriate; no generic copy of skill's centerpiece.
3. Make **one safe scoped commit at a time**, only in TAL02/TAL03 code/art/test/workflow and relevant docs. Verify exact PR HEAD before each write; no force push, Codex, rig, new branch/merge; other chats own Poison/Fist and concurrent gameplay. Preserve view-only LAB; V6.3/PvE OFF.
4. Run exact-SHA Godot 4.7.2 strict import + parse + focused tests + genuine 1280×720 MP4/GIF/phase stills, then inspect the real rendered visuals **at 1×** before claiming quality. Compare before/after same timestamps; fix clipped edges, connection, occlusion and glow if defective.
5. Update common production docs with the **specific new lessons learned from actual render** (painted first-party source → transparent master → varied atlas → Godot layer orchestration, anchor validation, QA); shared method already documented, avoid duplicating another template.
6. Present both genuine Godot movies to owner for **visual acceptance**. `GODOT_TECH_PASS != OWNER_VISUAL_APPROVED`; no release/live gameplay integration.

## Known scope / status and pitfalls
- Earlier TAL02 R1/R2 code/SVG looked like a stiff neon tube. TAL02 R3 painted flipbook gained texture but came out short/disconnected. R4 broadened actual painted alpha. R5 introduced a vertical-shear rebake; latest technical PASS **does not prove this final movement has been fully artistically accepted**. Confirm video before next work.
- TAL03 original procedural rune looked flat and too large. R2 painted image improved material, R3 reduced initial and steady stamp radius to **52/40 px**. Mark remains a single-target effect.
- Original generative images produced in the chat are only visual references/provenance, not engine screenshots. Distinguish created files or detached local JSON/ZIP bundles from actual committed PR code. Check file existence on GitHub before claiming a new revision.
- Five Human Lôi Phù casts have technical LAB proofs in earlier record; TAL01 R6, TAL04 R2, TAL05 R2 exist. **Not five approved production effects**. Ignore peripheral work unless owner changes priority; TAL02 then TAL03 are the specific handoff scope.
- Physical Windows/Android QA pending, owner art gate pending, PvE integration HOLD, and 60fps encoded movie is not device performance evidence.

## Verified new continuation checkpoint — TAL02 R6 / TAL03 R4 (supersedes R5/R3 status table above for these two LABs)
- TAL02 `b2b21147b834a59b14fc16530d014c5e1e39f16d`: art-only 1x anchor placement fix; Godot 4.7.2 Actions [43604043517](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604043517) PASS; artifact ID **14117731601** (`vfx-tal02-b2b21147...`). Genuine 188-frame 1280×720 video and 14 frame stills reviewed at .73, 1.08, 1.51; original source WEBP atlas preserved. Owner visual pending; still view-only.
- TAL03 `7f141fefd7eee87f61a6a04fb446f1742cb7d798`: chest stamp native-scale refinement; Godot 4.7.2 Actions [43604383986](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43604383986) PASS; artifact ID **14117845899** (`vfx-tal03-7f141fef...`). Genuine 468-frame 1280×720 video reviewed at 1.08, 5.03, 6.85; mark6s/.26s fade; view-only, never damage/tick.
- Distinguish **TECH PASS** / **ART SELF REVIEW** / **OWNER ART PENDING** / **PVE HOLD**. Shared teaching updated in `TMB_VFX_SPRITE_LAYER_PIPELINE_20261114.md` and `TMB_VFX_PAINTED_SOURCE_TO_GODOT_ASSET_GATE_20261114.md`. No full/live game integration, no unrelated school edits, no rig/Codex/merge.
