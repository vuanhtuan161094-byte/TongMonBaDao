# FIST14 R7 source-only decision — 2026-11-25

## Decision

**G3_SOURCE_FAIL. Stop before any native scene or LAB work.** All reviewed R7 source candidates fail the Human-first / Art-First V4 G3 visual gate at an intended 96 px motif width. The repository helper generated source-only dark/light contact sheets; those sheets are not Godot proofs and do not confer art approval. The manual verdict is a fail, not `ART=PASS`.

The current skill contract is `tmb.skill.fist.huyet_quyen.active_04.human`: `effect=mark`, `element=nether`, `target_type=single_target`, `target_limit=1`, `range=2.8`, `cast_time=0.45`, `cooldown=8`, `projectile_speed=0`, `duration=6`, `hit_count=null/undeclared`. This source work does not claim a mark event, extra hit, damage, status application, animation receipt, owner approval, PvE safety, or G3.5.

## Candidate verdicts

| Candidate | Source-only review | Manual G3 verdict |
|---|---|---|
| Initial R7 sheet (`source/f14_r7_original_pose_sheet_1536x1024.png`) | 96 px dark/light sheet: [review image](source/review/f14_r7_g3_source_1x_dark_light.png) | Fail. The energy resolves into thin claw/ribbon-like fragments rather than one coherent pressure body; release reads like a small comet and the phase silhouettes do not establish the intended close-contact pressure strike. |
| B (`source/candidate_b/`) | 96 px dark/light sheet: [review image](source/candidate_b/review/f14_r7b_g3_source_1x_dark_light.png) | Fail. The sharp, forward-pointing wedge reads as a dart/projectile, contrary to zero projectile speed and close-contact semantics. Charge/compress/release are too similar in silhouette. |
| C (`source/candidate_c/`) | 96 px dark/light sheet: [review image](source/candidate_c/review/f14_r7c_g3_source_1x_dark_light.png) | Fail. The supposed abstract energy mass reads as a clenched fist with stacked knuckles at 1×, directly violating the no-anatomical-fist lock. Charge/compress/release also remain too similar. |

All three retain an RGBA source with meaningful alpha and a ruby/red light direction, but that does not offset the silhouette and semantic failures. Candidate C's helper input was made by cropping each raw 512×512 pose to its alpha≥24 visible bounds; pixels inside that crop were not recolored or otherwise modified. Original pose crops remain under `source/candidate_c/poses/`.

## Next gate

Keep R7 failed and immutable. A new isolated source revision must first present a non-anatomical, non-projectile localized pressure silhouette with clearly distinct 1× key poses and pass the same manual G3 review. Only after G3 passes may the team assess whether a native LAB can honestly use real actors and a documented single mark event. G3.5, an actual Combat V2 receipt, the owner gate, and PvE remain separate later gates. No candidate art has been approved, and no scene, material, runner, or runtime adapter was created here.

## Scope of this decision

Only this R7-owned path was changed. No approved/provisional Fist revision, shared handoff, catalog, inventory, scene, or runtime file was edited. No Godot or CI test was run.
