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

## R1C-A · painterly source-art revision (2026-11-23) — G3 recheck

New source-only improvement over the independently observed R1C at 174px:
- Charge 01–03: enlarged layered wind accumulation around the upright physical blade; cyan/deep-blue/ice internal separation and directional in-flow.
- Release/gyre 04–08: irregular translucent gas volume and fragmented off-axis feathers following **one** returning sword, not 3 independent homing weapons.
- Contact 09–10: visible central hit energy + radial fracture field and expanding single-area shock; source-only, real target collision and radius NOT verified.
- Fade 11–12: residual wind mass with a safe transparent taper, visibly stronger on pale maps than R1C baseline.

Source names remain R1C so downstream Godot integration paths are unchanged; new reversible enhancer is `source/enhance_r1c_artfirst_v4.py`, with a deterministic compressed transport copy. The original baseline comparison is `source/G3_preflight_R1C_baseline_1x.png`. Review `source/G3_R1C_to_R1CA_comparison_1x.png` and `source/R1CA_G3_source_1x_review.gif`. **GIF timing is an art-review clock, not 0.36s gameplay cast timing.**

**Local source-only preflight before GitHub push:** 12/12 nonempty alpha, 12/12 distinct frame hashes, all safe 8px transparent borders, 2048×1536 atlas and dark/light 174px review. G3 still **VISUAL / OWNER REVIEW PENDING**, not automatic PASS; in-engine 3-target contact, AS-CHAR, renderer glow and runtime not tested. No Godot, no PvE, no rig, no merge. Existing R1B and Sword01 unchanged. QA results for the GitHub-generated exact SHA must be read from the R1C-A source-bake workflow separately.

### GitHub exact-SHA source bake verification
- Staging source commit: `9999f52dde37648cad4cdc44553dc8937495e095` (parent `921b4d053a4cf331213092ab390455373cd933c7`).
- Generated RGBA source commit: `9bf82fafd57d71f2e69125b00bd5ab57d79282da`.
- [R1C-A G3 source-only Actions run 45126278520](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45126278520): **SUCCESS**. The job verified 12/12 nonempty alpha, 12 distinct poses, 12/12 safe 8px borders and shape=circle/target_limit=3 in the manifest. Generated atlas recorded SHA256: `4409e67ab62c4a053ff8483014eb2f32b2af63ac64bfe15ea649e87aca4eb950`.
- The CI proof is SOURCE_TECH_PASS only. **G3 ART: IMPROVED / REVIEW REQUIRED**, G3.5+ not run, Owner=PENDING, PvE=HOLD. No Game runtime proof.

## R1C-B — owner feedback: sword sprite simplicity (2026-11-23)
The owner reports the R1C-A blade is *too detailed and ugly at 1×*: reduce unnecessary ornament and keep the weapon **a genuinely good readable sprite** instead of increasing polygon count or drawing finely engraved decorations.

Changes limited to VFX source `facets` painter:
- Remove 7 engraved zigzag veins, 5 grip-wrap ticks, ornamental highlights and excessive blade mini-facets.
- Use one clean dark outline, a flat silver upper blade, cyan lower plane, one crisp cutting edge, a short wing guard and minimal pommel.
- Preserve tangent direction, dimensions, charge timing, circular gyre and area-impact phases; export an isolated transparent `kiem_vu_hoi_phong_sword_clean_master_rgba.png` to judge actual sprite clarity.
- Save the previous R1C-A 174px source preview immutably as `G3_preflight_R1CA_before_sword_1x.png` and generate `G3_sword_R1CA_vs_R1CB_1x.png` + `R1CB_G3_source_1x_review.gif` on dark/light ground.

Local art-only preflight: 12 frames nonempty, distinct, safe eight-pixel borders; the non-weapon shock/fade frames 10–12 are byte-identical in pixel content before vs after. Source aesthetic is **candidate for owner review, not approved**. Technical source QA and Godot runtime are separate gates. **G3 ART=REVIEW PENDING; PvE HOLD; no Codex Cloud, rig or merge.**

## Owner checkpoint — 2026-11-23: R1C-B provisional visual acceptance

Owner feedback: **"Ok. Tạm đc. Chốt vậy."** Freeze **R1C-B clean sword sprite** as the current chosen visual baseline, not R1C-A's ornate sword. The sword must remain **simple, attractive and readable as a sprite at gameplay 1×**; never add engraving or micro-details merely for complexity.

**Approval scope:** provisional art-direction acceptance of the R1C-B *source preview*, not an unconditional G3 native/runtime PASS. Preserve the 12 RGBA frames, the current atlas and exported review assets with the confirmed source SHA `c6b8b7ed18271bf6722c2e5942d3d7164f4324ea`. No additional VFX embellishment unless owner requests it.

**Gate:** OWNER_VISUAL=PROVISIONAL_ACCEPT_R1CB; G3=SOURCE_ART_BASELINE_FROZEN / runtime verification NOT EXECUTED; G3.5–G7=NOT EXECUTED; PvE=HOLD; PR #72=DRAFT. Do not merge, use rig, Codex Cloud, change gameplay or activate PvE. The source manifest's `owner=PENDING` is an older generated technical-manifest label; this dated owner checkpoint governs visual choice pending any later automated manifest update.
