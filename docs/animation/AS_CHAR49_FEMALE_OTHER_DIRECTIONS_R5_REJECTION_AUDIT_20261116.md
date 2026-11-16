# AS-CHAR-49 — Direction source rejection gate R5 (2026-11-16)

**Result: No new correct Front/Back/Left animation was produced. 4/24 R4 Right candidates remain, 0/24 production approved.** This is an actual source audit, NOT a new animation pack.

## GitHub provenance

- Draft PR #72 existing branch `integration/pve-p0-playable-ui-20261103`.
- HEAD immediately preceding this documentation write: `5c1aa7040fdd5c83d478a3ae3895712efe63ef32`. Other writers may advance this branch.
- No new branch, merge, rigging, Codex or game code changes. Combat V2, SaveService, PvE/V6.3 unaffected.

## What happened

Owner approved continuing new **Front, Back, Left** directions using the female standard (dark indigo hair; white/blue flower; blue-silver robe and sword, Sword inside each frame). R4 source package was inspected and the four-view **static concept** reference was isolated direction-by-direction **for QA reference only**. These crops are NOT animation frames or source atlases.

Three genuine 8-frame GIF89a animation generation attempts specifically intended to start Front instead returned the wrong orientation/actions:

| attempted intended clip | actual inspection | original bytes SHA256 | disposition |
|---|---|---|---|
| Front initial attempt 1 | Right-facing Walk | `699af4c01eb6b33319163066486309abaf333f50f630200473aca11748d1bf25` | REJECT |
| Front initial attempt 2 | Right-facing Attack, **not** Front Idle | `c161b5a6480fee2f79643241f246abc497b7d162013fbba4d86a8047cd382660` | REJECT |
| Front initial attempt 3 | Right-facing Walk | `3e1b932ee4dcfb597f6885e0ce36322a7d25d47c78ee3098a588e5a2bc4f9f45` | REJECT |

All three are animated and may have transparent pixels; **that does not make them correct animation clips**. Do not rename them Front/Back/Left, do not mirror Right for Left, do not cut the four-view concept sheet into frame sources and do not count anything from the rejection folder as progress.

## Verifiable source QA package

The actual, preserved ZIP was uploaded successfully to personal ChatGPT Library:

`/TMB-Character-Art/AS_CHAR49_DIRECTION_REVIEW_R5_20261116.zip`

ZIP SHA256: `f68f12b63b38a71d333713cfb4d287dbfe84e44c7797f1e574ea2f5632f1b668` (13 entries; CRC verified).

Contents: four separate view reference images **REFERENCE ONLY**, all three unmodified rejected source GIFs in `rejected_NOT_PRODUCTION/`, original-animation SHA/frame manifest, color/face-placement orientation-precheck script `tools/verify_direction_intake.py`, visual sheet `evidence/DIRECTION_QA_ONLY_NOT_SOURCE.jpg`, actual selftest logs and a Vietnamese README.

The conservative checker inspected all eight real frames of each rejected GIF:
- Four reference images were correctly classified by their respective face placements (Front, Right, Back, Left) in **4/4 heuristic calibration checks**.
- Each attempt labeled Front received **0/8 frames classified Front**. Three source candidates were rejected, **3/3 negative tests PASS**.
- Face-cluster classification is **heuristic**, can fail or return UNKNOWN on fighting poses, and NEVER substitutes for human visual review or master identity certification.

The 4 existing R4 RIGHT animation candidates and their hashes were preserved separately; the R5 package does not duplicate/publish them as new clips. Raw bytes of original owner `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` remain inaccessible from Library, so original SHA/master remains **SOURCE_BLOCKED**. No Godot 4.7.2 native run or movie occurred in R5.

## Status and next constraint

- Right: **4 technical candidate clips (Idle/Walk/Attack/Cast)**, art continuity pending; no Right Hit/Death.
- Front/Back/Left: **0 genuine animation clips**. No derivative or fake 24-slot fill.
- Production: **0/24 approved**.
- Next permissible art operation is to obtain genuine separately authored correct-angle, multi-frame movement; inspect 8 actual frames + alpha/foot/weapon/identity before export. Do not keep pressing batch generator if it repeatedly returns wrong Right-angle Walk/Attack. Then run Godot 4.7.2 native 1280×720 at 1x/2x/3x and preserve exact-SHA evidence. Owner signoff remains required.
