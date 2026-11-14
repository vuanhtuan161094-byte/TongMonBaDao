# TMB VIS-07 R3 — SOURCE A FAMILY LOCK / WORKFLOW RECOVERY
Date: 2026-11-14 · PR #72 Draft · Visual status: **SOURCE STUDIED / R3 REPLACEMENTS NOT APPROVED**

## Correction
Owner explicitly rejected R1/R2 original SVG architecture and R3 generic fantasy concepts. Prioritise **matching source art at native map size** over cinematic detail. The reference is the actual Source A PNG family, NOT the preceding generated concept screens. Do not output another whole game-screen illustration when the deliverable is an independent building sprite.

Source reference artifact: [exact 10 PNGs verified at commit ec14ec3](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43549938103); action SUCCESS, originals independently SHA-checked against the manifest. Files are kept for visual analysis and historical provenance. This does not grant third-party redistribution rights.

## Source A visual evidence inspected
| Role | Source A PNG | Native dimensions | Notes |
| --- | --- | --- | --- |
| Hall | `godot/art/source_a_env02a/pv01_assets/main_hall/510052.png` | **1104×740 RGBA** | hand-inked asymmetrical low-rise pagoda hall; 2/3 roof masses; pale muted slate tile, terracotta pillars, light beige walls, **low rectangular stone plinth**, two exterior lanterns, natural planting; isometric 3/4; no gigantic stairs |
| Residence | `pv01_assets/residence/510076.png` | **536×416 RGBA** | ~1–2 roof levels; wooden domestic terrace, yellow fabric, garden |
| Warehouse | `pv01_assets/warehouse/510102.png` | **420×380 RGBA** | straw store with timber entrance, pale earthy furniture and vegetation |
| Forge | `pv01_assets/forge/520081.png` | **548×560 RGBA** | stacked small workshop with localized fire, not giant steampunk machinery |
| Guidance | `pv01_assets/guidance/510111.png` | **532×592 RGBA** | narrow, single-purpose portal with contained jade emissive lines |
| Trees | `env01_assets/vegetation/570036.png`, `570037.png`, `570041.png` | 296×316, 304×224, 80×184 | washed jade-green/olive hand-painted brushwork, irregular branch silhouettes |
| Paving | `env01_assets/terrain/stone_courtyard.png`, `env01_assets/roads/stone_cross.png` | 256×130, 185×97 | light warm gray stone, translucent edge shading, restrained contour |

Hall raw SHA256: `b6bf88c35e3edc33aba822124296af15a5c8491a05c28f6b5d7b342d20d5325c`; mine is **NOT in 34 SHA-verified MAP25 Source A textures**. Source-model `520051/520091` was historically mentioned as a Mine/Field candidate; presence, identification and usable art bytes require separate recovery, not assumption.

Older asset authority `docs/P3_ASSET_BUILDINGS.md` identifies eight historically visually-approved buildings with **S3 missing exact source**; the later Source A PNG families are real S0 visual references but **not retroactively those eight approved original binaries**.

## Art direction locked for new candidate sprites
1. **2D hand-painted watercolor/ink game map art**: preserve slight sketch-like contour, limited smooth gradients, irregular brush/line weight and lightly aged edges. Never photoreal/3D/metal-heavy/VFX-dominant.
2. **Structure follows source**: Hall remains low-rise hall with one broad main roof, secondary wings/porch, visible dark tiled roof, modest pale-stone stairs, light stucco walls and terracotta supports; keep the same 3/4 isometric camera and diagonal plinth. This is an improvement pass, **not a palace redesign**.
3. **Measured palette**: slate gray blue roof, dusty burnt umber wood, muted jade foliage, pale limestone/plaster, occasional subdued warm lantern yellow and tiny local cool-jade light. No fluorescent blue mine field or giant violet halo; no gold armor roofing, banners on every eave or full-screen sky.
4. **Mine functional silhouette**: compact gravel/stone worksite, one dark excavation portal, wooden gantry/support, ore sacks/cart, a few raw-ore cues. Single-source family drawing style; no castle, railway empire, waterfall diorama or huge crystal forest. Its original Source A counterpart is UNVERIFIED; create only an independently authored derivative style study.
5. **Map integration and screen-size first**: Hall real display target `300×201` in `SectIsometricWorldV1.HOUSE_SIZES`; Mine real target `166×121` in `MAP_D2_SITE_SIZE`. Artwork should read at default zoom 1.00 and 0.75, preserve alpha, foot base, anchor/depth and existing hitboxes; don't enlarge footprint or alter `BuildingState`. 
6. **One building sprite per image, transparent**: isolated angled architecture only, no HUD/text, no panoramic mountain plate, no checkerboard rendered into the pixels. Keep foreground tree/ground deco light and optional, avoiding source painting copied over a different background.
7. **Quality gate**: compare actual original PNG adjacent to improved candidate at 1:1 native map dimensions and in a real 1280×720 Godot scene. Verify alpha edge halos, no jagged resizing, roof orientation, warm/cool balance, building depth order, no overlap with actor/click areas. Physical Android remains separate. Rework image before discussing implementation PASS.
8. **Provenance**: preserve Source A original bytes/hash immutable; separately identify any independently authored candidate, and review licensing/redistribution before shipment.

## Previous workable pipeline recovered
Past production approach: `catalogue/source identity -> SHA256 -> separate asset import or shared Building Preview Lab -> Godot render -> alpha/scale/pivot/footprint/depth check -> 1280×720 screenshot -> visual PASS/FAIL -> integration`. Previous 2026-10-12 Main Hall's `1104×740` texture/import passed technical examination; native visual/alpha/pivot still required honest evidence, and the historical 8 visual approvals remain independent.

## R3 source-baseline action
The rejected VIS07 vector Hall/trees/stone are not kept as defaults. This commit temporarily **restores exact Source A map Hall/trees/stone** as stylistic baseline; the rejected Mine SVG is replaced by the previous MAP-D2 explicit candidate placeholder, not falsely labelled Source A. All rejected artwork remains archived; no gameplay, economics, routing, SaveService, sprite actor, rig or combat changes.

Until a source-matched replacement is artistically accepted, the user sees the historical real Source A family rather than a fake new production art. **Long-term Source A retirement remains the owner goal; no new art accepted yet.**
