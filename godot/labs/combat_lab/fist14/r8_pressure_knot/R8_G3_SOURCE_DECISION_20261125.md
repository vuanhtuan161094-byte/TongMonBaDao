# FIST14 R8 source-only decision — 2026-11-25

## Decision

**G3_SOURCE_FAIL / ART_SOURCE_BLOCKED. This closes the R8 attempt lane. No further R8 generation, native scene, or LAB work.** The source-only dark/light contact sheet was made by `tools/vfx/prepare_g3_source_review.py` at an intended 96 px motif width. Its `ART=MANUAL_PENDING` output is a preview, not an art decision or Godot proof. Manual review at 1× rejects the concept.

The requested silhouette is a compact bright pressure knot from four fused translucent ruby ridges around a tight near-white core. The generated source instead reads as a red flower/rosette: four petal-like folds curl radially around a central core. Most of the six poses remain nearly the same flower-like mass; only the contact frame's flattened edge is clearly distinct. This violates the explicit no-flower / no-radial-explosion rule. The silhouette is neither anatomical nor projectile-like, but those successes do not resolve the central read failure.

## Contract boundary

Canonical skill: `tmb.skill.fist.huyet_quyen.active_04.human`. Contract held for this source attempt: `effect=mark`, `element=nether`, `target=single_target` with limit 1, no projectile (`projectile_speed=0`), no declared `hit_count`, and mark duration 6 seconds. The six frames are only unintegrated art sources; they do not claim a runtime mark event, additional hits, damage, status application, animation receipt, G3.5, Combat V2 receipt, owner approval, or PvE safety.

## Source-only review

Preview: [96 px dark/light sheet](source/review/f14_r8_g3_source_1x_dark_light.png). Original six RGBA pose cells are under `source/poses/`; complete ImageGen output is `source/f14_r8_pressure_knot_original_1536x1024.png`. Crops are direct 512×512 cells from the 1536×1024 source sheet; no pose pixels were redrawn, recolored, or reconstructed in code.

## Next gate

Preserve this R8 failure. The R8 attempt lane is closed; no further generation or LAB work is authorized in this lane. Any separately authorized future attempt would need a new isolated source revision with an asymmetrical, localized, non-radial pressure mass whose silhouette reads as compressed energy at 96 px and whose charge, peak, contact, recoil, and status-hold poses are clearly distinct. Do not build a native scene/LAB on this rejected art. G3.5, an actual Combat V2 receipt, owner approval, and PvE remain independent later gates.

## Scope

Only `godot/labs/combat_lab/fist14/r8_pressure_knot/` was created. R1–R7 and all approved/provisional Fist assets, handoffs, catalog, inventory, scenes, and runtime files were not edited. No Godot, CI, or LAB test was run. The rejected candidate remains untracked by Git; no files were staged.
