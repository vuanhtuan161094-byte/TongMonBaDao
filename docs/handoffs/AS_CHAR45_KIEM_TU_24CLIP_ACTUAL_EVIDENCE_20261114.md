# AS-CHAR-45 — Kiếm Tu nam 24-clip animation, audited honest progress (2026-11-14)

## Owner directive
**Complete all 24 clips for male Kiếm Tu before expanding to female / 11 other schools**, preserving the visually approved high-res silver-haired, blue-ribbon, blue-white layered robe, crimson forehead sword seal, independent owner red-black asymmetric sword. NO rig, Skeleton2D/Bone2D or fake idle/walk/attack/skill. No production import of invalid animation. PR #72 Draft, existing branch only, no branch/merge/gameplay/SaveService/Combat/V6.3/economy modifications.

## New action inspection and recovered motion
An archived source GIF whose filesystem name ends in `.png` (`animated_chibi_swordsman_battle_frames.png`) was visually inspected as a **9-frame mixed-action source**, GIF 508×337 and ~120ms/frame:
- F0 stand, F1–F2 move, F3 blade raised/windup, F4 red sword slash, F5 recover, F6 one cast pose, F7 falling, F8 collapsed.
- Extracted **Attack right, four genuine distinct source key poses** (F2/F3/F4/F5), clear wind-up/slash/recovery. This is a **concept-only, SWORD_BAKED** clip. Not a modular release. Not four-direction coverage.
- Extracted **Death right, three distinct source key poses** (F5/F7/F8). Visually missing fall intermediates, **SWORD_BAKED**, concept only. Not production.
- Extracted **Cast right single source pose** F6; **NOT A CLIP**.
- Retained existing sword-free nine-frame Walk RIGHT candidate and 4 previously liked STATIC stand views. Owner approval of an earlier sword-baked walk doesn't automatically approve this new candidate.

## Generation failure — no false clips
During this turn, a targeted Death image-generation request returned another WALK cycle. A targeted attempt for action keyframes returned a beautifully typeset presentation claiming 24 clips but **not 24 distinct animation sources**. **Both REJECTED; not included as valid actions.** Do not reproduce the infographic as a release claim.

## Exact source packet for future chats
Saved in owner personal ChatGPT Library:
- `/TMB-Character-Art/AS_CHAR45_KIEM_TU_ACTION_RECOVERY_20261114.zip` SHA256 `84cdc69474cfff651862d465070a446f43dd003856c4ea6c05874a547d4e90b1`, 21 files, archive CRC PASS.
- `/TMB-Character-Art/AS_CHAR45_WALK_ATTACK_DEATH_CONCEPT_REVIEW.mp4`, 1280×720 offline side-by-side video, NOT a Godot screen recording.
Retrieve actual bytes from Library (Files search) and inspect `CLIP_COVERAGE_V2.json`, original source GIF and GIFs. The archive was **NOT** committed into GitHub; this document is a retrieval map only.

## Actual coverage and QA
Target = **4 directions × [Idle, Walk, Attack, Cast, Hit, Death] = 24** unique authentic clips.
- Production visual/weapon/Godot accepted: **0/24**.
- 9-frame new unarmed Walk-right visual candidate: **1 slot**, independent sword only in previous pilot, grip/alpha QA pending.
- Attack-right four source keys and Death-right three source keys: **2 concept slots**, with baked sword and no missing-motion QA pass.
- Four independently authored directional STAND stills: **4 images, NOT 4 animated Idle clips**.
- One Cast-right **static pose**, NOT a completed Cast clip.
- All other clip slots: missing.
- Technical ZIP + SHA and GIF-frame distinctness verified; native 320px-style art resolution from source preserved for current reference; official Godot 4.7.2 **NOT RUN**, Android NOT RUN.

## What is needed before declaring complete
Finish all *genuinely authored* four-direction Idle/Walk/Attack/Cast/Hit/Death high-res frame sequences and retain exact locked character identity. Sword must remain separate during source/production, with verified per-frame grip and front/back occlusion. Reject merely moving a full-frame still, changing file names or synthetic loop padding to fake action. Godot official 4.7.2 QA at 1280×720/zoom1–3 and owner visual acceptance required. Avoid mass import until then.

**Status: OPEN — no 24/24 completion claim; no new source animation merged into production in this update.**
