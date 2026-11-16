# AS-CHAR-49 — Nữ Kiếm Tu R4: RIGHT 4 genuine animated source clips (2026-11-16)

**STATUS: CANDIDATE 4/24, PRODUCTION APPROVED 0/24; GODOT 4.7.2 NOT RUN.** No rig, no Codex, no gameplay, Combat V2, SaveService, V6.3 changes. No branch creation or merge.

## Exact-branch provenance

- Working draft PR #72, existing branch `integration/pve-p0-playable-ui-20261103`.
- HEAD checked before R4 work: `0fff0b39744d8cfd9da0eae40e596ba0b71b461b`; checked again before checkpoint: `d016bed6287d2bffae53c8ae4440bd96c231051b`. GitHub concurrency means branch HEAD may advance; avoid re-labeling a historical SHA.
- Female source Library `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` remains viewable but denied as raw bytes, hence its SHA256 and usable frame properties remain **UNVERIFIED**.
- R4 female 4-direction static image concept is a **reference only** and is **not cropped into motion frames**. Owner master not locked. This new visual source cannot prove original APNG identity.

## Real binary R4

Full ZIP in ChatGPT Library: `/TMB-Character-Art/AS_CHAR49_FEMALE_RIGHT_R4_4CLIPS_CANDIDATE_20261116.zip`.

ZIP: **20,044 KB (20.04 MB decimal)**; SHA256 `8d3490e7f3e156490f063b7f436fe656a62c6e473c651be04e068d264027b91d`; **99 entries**, ZIP CRC check passed. Source binaries are NOT in GitHub. Package contains:

- **Idle_Right**: original 8-frame GIF `imagegen_2_batch_1.gif`, 443×443, acquired from earlier partial image generation; subtle natural hair/robe motion, stationary character.
- **Walk_Right**: real 8-frame animated source **R3**, not derived from Idle; alpha/registration and bbox per-frame checked; body/garment differs from newer master in some details.
- **Attack_Right**: real 8-frame animated source R3, drawn sword and thrust, not Walk rebranded; candidate grip/anatomy/consistent cloth still requires art review.
- **Cast_Right**: original 8-frame GIF `imagegen_5_batch_4.gif`, 443×443, originally generated as a separate action from the same newer static concept. It visibly lifts a **free hand to form a seal then lowers it** while feet are planted; importantly this is NOT one of the rejected Walk-as-Cast outputs from R3.
- 32 actual frame PNG files, **512×512 RGBA**, alpha registered to common approximate foot root **(256,442)**; four **2048×1024** lossless atlas PNGs built from PNG frames; four GIF and four lossless APNG previews; four source GIFs preserved verbatim; JSON with a truthful **4 candidate / 20 missing** matrix; per-frame SHA256; isolated standalone Godot 4.7.2-compatible *source project* and SpriteFrames resource with only the four genuine clips, no fake placeholders; QA frame review grids, actual-size zoom 1x/2x/3x dark/light snapshots; and offline 1280×720 movie CLEARLY LABELED **OFFLINE NOT GODOT**.
- Note: Idle/Cast sword is mainly held at the waist while Walk/Attack holds it drawn; costume/sleeve and styling continuity at action transitions is **not final art approved**. 4 clip technical export ≠ 4 consistent production clips.

## Technical verification and visual blockers

- Independent local Python QA: **172/172 technical assertions PASS** checking GIF source magic, actual 8 decoded frames per clip, 512×512 RGBA output, alpha presence, per-PNG SHA, frame uniqueness, exact atlas cell pixel matches, clip count and manifest.
- Built-in reproducible self-check: `tools/verify_r4.py`, 32/32 PNG-SHA-atlas frames PASS.
- **Still missing:** 20 of 24 motion clips, 3 additional true directions, Hit and non-graphic downed/Death animation. A batch image-generation request previously failed with a safety-related refusal, and a subsequent edit generation attempt reported an unavailable usable image target. No fabricated frame or fake 24-slot animation was added.
- **ART GATE OPEN:** hand-hilt attachment, sleeves/hair/sword exact matching across all four clips, smooth playing loop, actual foot contact, and owner approval.
- **ENGINE QA OPEN:** Godot **4.7.2 executable not found** in this environment, native import/render/video and 1x/2x/3x Godot QA cannot be declared PASS; physical Windows and Android pending.
- No integration into production female actor; the previously rejected source variants remain excluded.

**Decision:** Preserve R4 as honest four-clip candidate pack. Next gate: recover approved female APNG bytes or direct attachment and unify identity/hair/robe/sword across actions before building remaining directions/actions; do not inflate quantity by recycling movements.
