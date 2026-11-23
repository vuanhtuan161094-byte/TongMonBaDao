# Kiếm Vũ Hồi Phong · Kiếm Tu / Ngự Kiếm / Nhân · R1C G3 Art-First V4
**SOURCE CANDIDATE ONLY · NOT OWNER APPROVED · NOT GODOT/WEB/COMBAT/PvE.**
Original skill: `tmb.skill.sword.ngu_kiem.active_02.human`. Canon: metal, damage, circle radius 1.4, up to 3 targets, cast 0.36s, cooldown 10s, projectile speed 8, damage ratio 0.82.

R1C extends the 12-cel R1B source study with a more legible 3-beat charge, faceted metal sword and guard, multilayer returning gyre (deep-outline/cyan/white core), clustered single-area contact shock, fracture sparks, and staged fade. Source sprites are **not three distinct target receipts**. R1B and Sword01 remain untouched.

The first-party, independently generated 512px RGBA cels / 2048×1536 atlas / 174px 1× light/dark preflight are produced from the source script in this directory. The source folder currently includes **readable Python**, 12 committed RGBA PNG poses, a 2048×1536 atlas, a 174px-on-screen dark/light contact sheet, and JSON manifest at the checked HEAD. This is source-art evidence only: no source-bake workflow result or Godot screenshot is implied by file presence. The raw source is a procedural digital-painting candidate, **not** an ImageGen-painted master or a Godot screenshot.

| Gate | Evidence / status |
| --- | --- |
| G0 | Canon confirmed; 3-target circular AoE unchanged |
| G3 technical | Check 12/12 alpha, 12/12 unique, 8px border, 1× dark/light source-only; actual workflow status to be verified |
| G3 art | **ART REVIEW PENDING**; require owner 1× review and organic volume/charge/contact improvements if needed |
| G3.5–G7 | NOT EXECUTED (hard stop before Godot, no alias, no web review) |
| Owner/PvE | OWNER_VISUAL_PENDING / HOLD |

**No Codex Cloud, no rig, no merge, no gameplay, no SaveService, no PvE integration.** A green source bake means technical checks only, not an artist approval.

## Independent 1x source-image review — 2026-11-23

**Observed PR #72 HEAD before review:** `ce3ac37b496d158205603833638bdcab59dec0ab`. Reference only source PNG contact sheets at this exact SHA: `r1b/source/G3_preflight_1x_dark_light.png` and `r1c/source/G3_preflight_1x_dark_light.png`. The files are source previews, **not in-engine screenshots**.

| Concern | Real observed R1B -> R1C result at 174px display | Review gate |
| --- | --- | --- |
| Charging (poses 01–03) | Larger concentric wind coils, brighter physical blade silhouette, but first charge is still small and primarily fine strands on dark terrain | **REWORK** — make core accumulation visibly weightier and continuous before release |
| Returning sword-light (04–08) | Tangent-aligned steel sword easier to read; extended cyan arc now suggests one continuous circular gyre, but the bright ribbon remains geometrical/uniform and needs irregular translucent internal volume and stronger blade-to-trail continuity | **REWORK** — painterly wind mass, not a neon Bézier stripe |
| Impact (09–10) | Contact burst and circle shock are larger and readable on both source backgrounds, but the hit lacks proof at enemy contact and center area stays homogeneous; no moving-target screenshot | **REWORK** — layered initial contact, fractured outward shock, and actual hit-point alignment |
| Bright/dark and fade (11–12) | Core blade/wind remains legible through main phases; fade on pale map is very weak, and the earliest charge is not immediately recognizable at 1× | **REWORK** — maintain silhouette through the final dissipating beat without opaque glow |
| Skill semantics | One AoE circle gyre is visible, not three separate homing swords. Runtime radius 1.4 / up to 3 enemies is documented but **not proven by source artwork alone** | **HOLD** — never claim 3-target runtime QA |

### Scope-separated QA

- **R1C technical manifest:** 12 distinct 512×512 RGBA poses; all report nonempty alpha and >=8px safe borders, 2048×1536 atlas; independently opened both R1B/R1C light/dark source contact sheets. This verifies **source existence and visual comparison**, not a rerun of source hashing or native regression.
- **G3 art self-assessment:** **REWORK REQUIRED / NOT APPROVED**. The contact sheet is materially better than R1B, but 1× charging, organic body and impact/fade remain below the intended benchmark.
- **CI/Actions:** No runs or commit statuses were returned by the available commit-scoped checks for the inspected HEAD. **CI is unverified**, not PASS or FAIL.
- **G3.5–G7, Godot, Web and PvE:** **NOT EXECUTED** due to G3 hard-stop. No actor/enemy contact or 3-target receipt QA; owner approval pending.
- **Do not infer** native performance, clean import, gameplay compatibility or a passed G3 gate from PNG hashes, the contact sheet or an illustrative concept image.

**Next permitted step:** rework the 12 transparent source poses and re-review *actual* 174px previews against dark/light terrain; only then seek G3 art approval. Preserve R1B, Sword01, gameplay, rig-free animation, and PR Draft (no merge, no Codex Cloud, no PvE).
