# VIS-07 R4 — Whole building-art inventory and owner-approved sprite ingest

Date: 2026-11-14 · PR #72 Draft · **Source inventory and binary SHA verified; Godot QA pending**
Owner approved **exactly the two original generated images** `tông_môn_đại_điện_xianxia.png` and `xianxia_mining_outpost_diorama.png`. Later generated images `jade_cloud_main_hall.png` / `jade_mountain_mining_outpost.png` are separate UNAPPROVED outputs and MUST NOT replace them.

## Production asset matrix

| Site / category | Repo artwork | Current renderer | Verdict |
| --- | --- | --- | --- |
| Main Hall / Đại Điện | Source A `510052.png` | `SectIsometricWorldV1.render_art` + `sect_facility_art_v2.gd` | Source A live until Owner-approved PNG is present in `tmb_approved_v4/`; new code uses reviewed sprite first |
| Mine / Mỏ Khoáng | MAP-D2 original vector worksite | `SectIsometricWorldV1.candidate_site_art` + P3.2 OperationArt | Placeholder live until reviewed PNG is present; Art05 overrides only on successful import |
| Residence / Đệ Tử Xá | Source A `510076.png` + older UI study + separately generated residence draft | `render_art` + TRI facility panel | Source A live; unapproved old draft is NOT promoted |
| Warehouse / Kho | Source A `510102.png` | `render_art` | Source A live |
| Forge / Luyện Khí | Source A `520081.png` | `render_art` | Source A live |
| Guidance / Dẫn Tiên | Source A `510111.png` + UI study | `sect_facility_art_v2.gd` and world source | Source A live |
| Linh Lâm | `reimagined_source_a_v3/linh_lam_{A,B}_{idle,active}.png` | `sect_building_art_variant_v3.gd`, actual map + panel | **4 real PNGs already integrated**, preserve |
| Linh Điền | `reimagined_source_a_v3/linh_dien_{A,B}_{idle,active}.png` | same | **4 real PNGs already integrated**, preserve |
| Luyện Đan Điện | `reimagined_source_a_v3/luyen_dan_{A,B}_{idle,active}.png` | same | **4 real PNGs already integrated**, preserve |
| Older alchemy sketch | `reimagined_source_a_v1/alchemy_hall_3q_v1.svg` | review-only | Rejected because of in-game overlap; NOT live |
| MAP-D2 forest/field/mine sketches | `map_d2_candidate/*.svg` | visual fallback for worksite | Non-approved backups, never user-approved art |
| VIS-07 R1/R2 vectors | `tmb_original_v1/*.svg` | no live visual mapping | Owner REJECTED, keep only for traceability |
| Nature/roads/stone | `source_a_env02a/env01_assets/{vegetation,roads,terrain}` | Verified source map | Source A currently live; no owner-approved replacement yet |

**No duplication:** all 12 canonical V3 PNGs, their A/B and real idle/active associations, runtime logic, and gameplay sources are untouched.

## R4 Owner approved artwork and target
- Hall: exact approved chat input `tông_môn_đại_điện_xianxia.png` (1448×1086, transparent RGBA). Normalized PNG 300×201; exact target `res://art/tmb_approved_v4/main_hall_approved_300x201.png`.
- Mine: exact approved chat input `xianxia_mining_outpost_diorama.png` (1448×1086, transparent RGBA). Normalized PNG 166×121; exact target `res://art/tmb_approved_v4/mine_approved_166x121.png`.
- Precise master/hash and alpha bbox belong to `VIS07_R4_OWNER_APPROVED_GODOT_ASSETS.zip`, generated in the owner's conversation. No repaint/re-generation.
- The source bundle provides 1× RGBA, 2× RGBA, original masters and SHA-256 manifest. Embed only the two named 1× PNGs in Godot.
- Native clip: Hall existing house drawing `p + Vector2(0,-target.y*0.28)-target*.5`; Mine existing site drawing `p-Vector2(size.x*.5,size.y*.79)`. No footprint, camera, hitboxes, door cells or depth changed.

**Binary transport completed**: both native RGBA PNGs transferred as Git blobs after verifying byte-for-byte Git SHAs. Hall blob `8353035eb8a8017fa2fb5c079afd5fccf75183b2` (78,030 bytes, PNG 300×201, SHA256 `00b013a12261f16152f51e3264d2ddfaafa60f830084006aaed567137773ca96`); Mine blob `5f9e86309f20bbc090a29a56e48f851b6e959184` (31,028 bytes, PNG 166×121, SHA256 `b04177001a63f472978ab1e4768c0b8ca9d46d7ee25a5305922c33b4c2978f25`). Art is switched live only from these exact paths; missing binaries preserve prior verified fallbacks. **Real Godot screenshot and final art QA pending exact-SHA run**; no composited screenshot can substitute engine evidence.

Keep Source A original SHA-gated files for historical audit and rollback; do not treat art-replacement intent as authorization to delete source copies. Existing other writer commits in this branch are unrelated, and no new branch / merge / rig / gameplay changes are needed.
