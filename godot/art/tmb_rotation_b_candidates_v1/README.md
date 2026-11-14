# TMB VIS-10 · separately authored B rotation CANDIDATES
Date: 2026-11-14. ART STYLE not approved. These PNGs are **not exported or claimed to be the second camera for the owner's exact current A**.

Source: the separately generated 1536×1024 TMB art presentation sheet from this conversation, with individually segmented alpha silhouettes. NO Source A building pixels. A vs B silhouette/architecture inconsistencies remain (especially Hall/Mine); this is a visual candidate and is **not enough to prove a real rotate-ready sprite pack**.

Technical targets: Hall 300×201, Mine 166×121, Residence 174×135, Warehouse 162×138, Forge 205×164, Guidance 182×203, all non-flipped PNG-8 alpha.
The existing `SectIsometricWorldV1` map retains A by default. `set_visual_rotation_preview(id,&"B")` selects candidate art transiently for a valid building; `clear_visual_rotation_preview()` returns to A. No UI button, no rotation persisted in SaveService, no new gameplay or simulated production.
NOTE: V3 has 12 unique PNGs A/B x idle/active for Forest, Field, Alchemy; there is no need to generate them again.

Release-blocking art checks: SAME Hall A architecture, door/courtyard/pivot relation; original drawn oblique B view rather than mirrored copy; consistent source color/material and perspective; actual Godot GUI screenshots at 1x/0.75x; owner art acceptance. The cut-out B candidates are not automatically production-eligible.

Source A house display audit:
- Five historic static house model IDs remain metadata keys but renderer now uses `tmb_original_buildings_v5` / `tmb_handpaint_building_art_v6`, not Source A PNGs.
- Real Source A **environment** still renders: ENV01 19 vegetation IDs, six road patterns, four ground tiles. They are separate from buildings and must be rebuilt carefully; the previously rejected vector replacements are not suitable.
- Other possible Source A human/monster sprite atlases are outside this building presentation audit and must not be silently declared removed.
