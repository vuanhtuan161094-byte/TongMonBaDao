# Exact Sword Cultivator identity pair for mass disciple production (2026-11-17)

**USER CORRECTION:** Codex is benchmarking wrong character art. These are the two **existing real source PNGs** that the owner asked to show and use as identity comparators, not newly generated artwork.

| Role | Identifier | Exact repo reference PNG (512×512, original alpha, frame Idle_Front 0) | SHA-256 original PNG |
| --- | --- | --- | --- |
| Male Sword | AS-CHAR-48 | `docs/art_reference/sword_pair/AS_CHAR48_MALE_IDLE_FRONT_ORIGINAL.png` | `67e0c8c43fb67cb195f856424d9c1195613882de362a4ed97c95e10b31177449` |
| Female Sword | AS-CHAR-49 V10 | `docs/art_reference/sword_pair/AS_CHAR49_FEMALE_IDLE_FRONT_ORIGINAL.png` | `143dcdddeb2af9e42a1782d93e8d2ecbd02448557bcde57ac3acabe2ce33a6cf` |

## Original source packs (ChatGPT Library)
- Male: `/TMB-Character-Art/AS_CHAR48_KIEM_TU_MALE_24_CLIP_TECHNICAL_DRAFT_20261114.zip` — original 24 clips, 126 PNG frames, not production owner approved. Source exact front image archive path: `AS_CHAR48_KIEM_TU_MALE_24_CLIP_DRAFT_20261114/godot_project/assets/kiem_tu_male_baked_sword_v2/frames/idle_front_f00.png`.
- Female: `/TMB-Character-Art/AS_CHAR49_V10_23OF24_TECH_CANDIDATE_20261116.zip` — original 23/24 real candidate clips, 240 PNG, `Death_Left` missing, not production owner approved. Source exact front archive path: `frames/Idle_Front/frame_00.png`.
- For **four-direction** reference and SHA provenance, refer to `/TMB-Character-Art/SWORD_PAIR_ASCHAR48_49_EXACT_REFERENCE_FOR_CODEX.zip` (8 byte-identical original idle PNGs; manifest and two comparison contact sheets).
- If Codex cannot access ChatGPT Library, use the two **real PNG bytes directly committed here** for reference and request that user attach the full reference ZIP to the Codex task; do not silently substitute an unrelated design.

## What visually defines this pair now
- Male AS-CHAR-48: young fantasy chibi; silver hair tied upward with **blue ribbon**, blue/silver ceremonial robe, blue jewel and chest ornament, prominent **red-black sword**. Keep distinctive silhouette.
- Female AS-CHAR-49 V10: young chibi; long purple hair with white flower/hairpin and blue ribbons; white/light-blue ceremonial robe with blue waist ornament; smaller **silver-gray sword**. Keep distinct silhouette.
- **Warning:** The two original technical sources differ in artistic sharpness, silhouette proportions and weapon visual weight. Do NOT automatically claim that they already constitute a fully consistent final art standard.
- Owner explicitly complains that current weapon designs are **too basic / unattractive**. Their forms/color/identities are references to improve, **not frozen weapon aesthetics**. Research xianxia weapon construction on Pinterest as lawful reference; draw independently new original designs, with 4-direction readability and contrast vs robe. Do not paste/reference-license commercial art into game.
- No auto-generated same-face clone across schools. School recognition must include **weapon shape (primary), robe design/palette, insignia, ornament, silhouette**, not just hue changes. Align new 12-school/36-branch bible to these real assets and owner-approved other-school art, and require owner review of any new mass master.
- Frame-by-frame sprite, 4 directions, character/VFX separate, no rig, no hidden flip, preserve pivot/alpha. Known female Cast_Right F05–06 / Cast_Back F04 / Hit_Left F03 clipping and missing Death_Left remain QA issues; male Cast/Hit Right has only 2 genuine poses. Do not claim production PASS or 24/24 female completion.
- Existing PR #72 Draft; no branch/merge or edits to Combat V2, economy, SaveService, PvE/V6.3. This **reference-only** commit changes no gameplay.

## Codex immediate next step
Stop using the wrong sample now. Show the owner a side-by-side 1× comparison of the two repo PNGs (plus weapon detail), mark proposed common 2D visual standards, then verify other disciples' weapon silhouettes before bulk production. Maintain user-approved art sources unchanged until explicit approval.
