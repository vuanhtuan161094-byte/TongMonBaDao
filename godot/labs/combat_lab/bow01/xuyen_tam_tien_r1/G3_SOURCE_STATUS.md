# Xuyên Tâm Tiễn R1 — Art-First source review

**Skill:** `tmb.skill.bow.liep_anh.active_01.human`
**Contract:** `damage / single_target / target_limit 1`, metal; one arrow on one straight axis.
**Source status:** `G3_SOURCE_SELF_PASS` (self-review at 1×; not owner art approval).
**Native status:** `G3.5_HOLD_ACTOR_WEAPON_ANIMATION`
**PvE:** `HOLD_V63_OFF`

## Source reviewed

Three independent transparent RGBA sources are kept in `source/`: a compact charge arrow, a complete flight arrow, and a small directional contact glint. They are distinct poses in the attack sequence, not recolors of one generic vector. The contact glint is only permitted after a confirmed one-target receipt. The generated output IDs, original prompts, dimensions, hashes, and preserved design reference are recorded in `source/manifest.json`.

`review/G3_SOURCE_REVIEW_96PX_NOT_APPROVAL.png` shows charge and flight at a 96 px motif width on dark and light backgrounds. `review/G3_CONTACT_REVIEW_40PX_NOT_APPROVAL.png` shows the contact cue at a 40 px width on both backgrounds. The helper-generated JSON files carry the actual source hashes and alpha ranges. The helper reports `ART=MANUAL_PENDING`; the separate status here records the source-only visual self-review.

The arrow silhouette, single-axis travel, blue-white metal material, and fletching remain readable at the intended sizes. The 40 px contact cue reads as a narrow impact glint and must remain brief. No background matte, poster crop, actor, hit, target, or proprietary game pixel was added to the source files.

## G3.5 stop condition

The current AS56 content is a real 24-frame, four-direction candidate, but its existing Bow preview declares `BOW OVERLAY PENDING`. The available `attack_right` body cel is not a bow draw/release pose, and the candidate bundle has no accepted bow hand socket or matching frame-by-frame weapon layer. The Xuyên Tâm Tiễn LAB therefore cannot yet show a truthful archer release at native 1280×720. No substitute rig, guessed bow attachment, or fabricated hit was introduced.

Continue only when an actual AS56 bow draw/release clip and correctly registered bow overlay/socket are available for the actor used in the preview. Then verify the real moving target and bind the contact glint to the confirmed one-target hit receipt. Until then this skill is source-ready at G3 and blocked at G3.5; it is not a completed VFX or runtime feature.
