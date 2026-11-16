# AS-CHAR-49 V8 — Approved Attack four-view source exported (2026-11-16)

**Delivery: technical candidate 13/24 clips, 88 authored frame PNGs; Godot native NOT_RUN; 0/24 production-approved.** User explicitly approved the 4×8 female Attack source image visually, **not** all 24 production animations.

## Provenance
- Scope: draft PR #72, existing `integration/pve-p0-playable-ui-20261103`. HEAD checked immediately before checkpoint: `fb274eff9c2bf6b5f93db4253bcce43280d5e18a`; concurrent writers may advance branch.
- Original approved-by-user attached Attack source: `image(20261116-061041).png`, **1774×887 RGBA**, four independent direction rows **Front, Right, Back, Left**, eight genuine poses per row. SHA256 `d30d30bfe28c6a7b2fe8297bd3c3c59f0e5a31d509c175c60edcc1fa12b74d59`.
- Original raw frame grid retained unmodified in ZIP as `sources/ATTACK_4DIR_OWNER_APPROVED_VISUAL_SOURCE_20261116.png`. The ChatGPT Library original female APNG remains inaccessible as raw bytes; cannot claim exact original master identity.
- V7 4×Idle, 4×Walk, Cast_Right retained; **Attack_Right replaced** with this same approved 4-view Attack source for cross-direction consistency. Newly added Attack_Front, Attack_Back, Attack_Left.

## Deliverable
- Personal Library only, **not binary-committed to GitHub**: `/TMB-Character-Art/AS_CHAR49_V8_ATTACK_4DIR_CANDIDATE_20261116.zip`.
- ZIP SHA256 **`9a272f71b1bfe43eb6bb050ee875d4fcbf4a1450bdbaae56828cba1294809a45`**, 56,847,557 bytes, **255 entries**, ZIP CRC PASS.
- **13 real clip candidates**: Idle 4/4, Walk 4/4, Attack 4/4, Cast 1/4, Hit 0/4, Death 0/4. **11 still missing**, no fabricated placeholders. **88** PNG 512×512 RGBA (16 Idle + 32 Walk + 32 Attack + 8 Cast); 13 pixel-matched 4-column atlases; preview GIFs; manifests/source SHA; Godot 4.7.2 *unrun source project* and local `OPEN_PREVIEW.html`.
- Independent checker `tools/verify_v8.py` PASS: **88 SHA256 hashes and exact atlas frame matching**, 13 clip presence and 11 absences, alpha/nonempty. Four Attack GIFs each have **8 real frames**, 512², transparency; original timing durations 140/105/90/85/75/90/135/175 milliseconds (GIF playback rounded to 10ms).
- QA image: `qa/Attack_Four_Directions_Frame_04_OFFLINE.png`; animated synchronized review: `qa/Attack_FOUR_DIRECTIONS_OFFLINE.gif`. They are **offline previews, not Godot screenshots**.

## Defects, gates, unaccepted material
- Three detached alpha fragments in user source were removed at export, without rig or changing body poses. Six source-grid cells touch source cell borders on large sword swings (Right frames 4–5, Back 3–5, Left 4); possible sword-tip truncation **ART QA OPEN**.
- Three additional image generations trying to produce Cast/Hit/Death returned mislabeled sword swings, mixed directions or non-falling animations: **REJECTED, EXCLUDED**. These do not increment source counts or clip coverage.
- Actual motion join/weapon hand, pivot/foot contact, native 1280×720 at 1×/2×/3×, Android performance and owner final clip review still **PENDING**.
- Official Godot 4.7.2 executable is not available in current environment: **engine NOT_RUN**, not technical CI PASS. No actor integration, gameplay/Combat V2/SaveService/PvE/V6.3 edits, Codex, rig, new branch or merge.

## Next gate
Recover/recreate authentic *four-direction* Cast, Hit and non-graphic fallen Death **one complete action at a time**, retaining female identity; refuse random mixed-view sword-swing GIFs and promotional posters. Inspect actual moving animation in Godot 4.7.2 on exact SHA before production release.
