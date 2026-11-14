# AS-CHAR-49 R2 — Female Sword Right Walk/Attack source QA (2026-11-15)

**FAIL CLOSED: 2/24 exported motion candidates, 0/24 approved for production.** R1 retained intact. Independent art production only; no rig, Codex, gameplay/Combat V2/SaveService/V6.3 changes.

## Authority and fresh branch inspection
- Target: Draft PR #72, existing branch `integration/pve-p0-playable-ui-20261103`.
- Branch HEAD verified before R2 work: `cb8cf8e9726f66bbe11611fc448ceb77b394035a`; checked again immediately prior to this documentation edit: `6983e0693f9bc11fdf3675d84857e495a312e2b0`. Concurrent writer changed HEAD, no branch creation or force push by AS-CHAR-49.
- Existing mandatory docs/Issue #77, R1 AS-CHAR49 status and original Library reference were reviewed. The Library file `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` was found, and **its four-view preview displayed** with dark indigo hair, blue-white floral ornament, blue-white layered robe and blue-silver sword. However `files.materialize` **still denies original bytes**; original APNG SHA256, exact frame count, master identity and raw-alpha characteristics remain UNVERIFIED. Do not claim source recovery.

## Actual independent R2 binary package in personal ChatGPT Library
`/TMB-Character-Art/AS_CHAR49_FEMALE_RIGHT_R2_QA_CANDIDATE_20261115.zip`  
SHA256: `48d2f309692839d4a6449f1b52920c616c696db821b38719a0c718b728ce8ea5`  
ZIP: **56 entries**, 8,432,083 bytes, CRC validated. **Actual binaries are in Library, not this GitHub commit.**

The two animation sources were regenerated frame-by-frame as true GIF89a multi-frame images; names `.png` returned by the image tool are misleading. Both raw source GIF bytes were preserved with correct file extensions. They are **new visual candidates**, not an extraction of owner APNG.

- **Walk_Right**: source GIF **443×443, 8 distinct real decoded frames**, source SHA256 `ec5d5a7d6e0365f616acacc9bebdaf4d56119fd105e97a9ac297b069798f73ff`. Per-frame timing 105/105/110/75/80/110/120/125 ms; loop. **ART FAIL**: raised-knee poses at frames 03–04 still read as run/jump, foot plant not convincing. Do not integrate.
- **Attack_Right**: source GIF **444×444, 8 distinct real decoded frames**, source SHA256 `a7b97473c35c134ae63d9ec38efa130e5d29dc86bc203d10c30d65d24c1eaf2e`. Timing 145/105/85/65/75/90/130/185 ms; one-shot. **ART PENDING/NOT APPROVED**: identifiable guard/rise/attack/recovery, but hand/blue-silver sword hilt geometry and exact identity continuity still require owner signoff.
- Independently decoded into 16 actual 512×512 RGBA PNG frames, 2 exact-cell 2048×1024 atlases, two exported 8-frame GIF previews, `SpriteFrames` resource, 1280×720 **standalone unrun Godot project**, CSV-free JSON manifest with frame hashes, reproducible file QA script.
- Frame registration: fixed horizontal origin per clip; bottom alpha contact registered to Y=442; reference pivot (256,442). This proves canvas registration, **not** anatomical foot locking.
- Six zoom/background QA stills (1×/2×/3×, dark/light), two 8-frame visual review sheets, 1280×720 H264 6.72-second **OFFLINE NOT GODOT** video.

## Test/evidence
- `tools/verify_r2_export.py`: **59/59 technical checks PASS**, source magic/hash, all frame PNG size/mode/hash, exact lossless atlas matching, output grounding, distinct frames and preview decoding.
- No official Godot **4.7.2** was run. Physical Windows and Android UI/animation QA remain PENDING. The standalone source zip/project and offline MP4 are **NOT** native engine evidence.
- Visual comparison with original four-view APNG is limited to its displayed preview; byte-for-byte same character/sword claim remains blocked.
- No right-hand animation is accepted into the production actor, no approval fabricated. No expansion to other directions or schools while right gate remains red.

## Next gate
1. Obtain true APNG bytes (upload in conversation if Library raw materialization remains denied), compute SHA256, compare identity and source frames, preserve source without modifications.
2. Re-author raised-knee Walk-right poses rather than retime failing art; verify alternating grounded steps and seamless loop at 75/225px. Repair grip/sword continuity in Attack-right source frames; never fake by still-image translation.
3. Run official Godot 4.7.2 exact-SHA lab and real native video before owner art signoff. Do not mark animation DONE or replace production sprites from static/automated QA alone.
