# AS-CHAR-49 — Female Sword RIGHT R3 checkpoint (2026-11-16)

**Current result: two motion candidates exported; 0/24 production approved.** Preserve existing female references and R2. NO rig, Codex, gameplay, PvE, Combat V2, SaveService, new branch or merge.

## Live branch and provenance

- Draft PR #72, existing integration branch `integration/pve-p0-playable-ui-20261103`.
- HEAD verified before this documentation commit: `a22d8056c6fe02cc2d7976b39cf9b6d459b1b16b` (other writers may update later).
- Original owner Library `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` is searchable/viewable; however raw-file materialization is still denied. Hence no original APNG bytes, actual magic SHA-256, frame validation or owner MASTER lock.
- Female visual identity retained in R3 candidates: dark indigo long hair/high bun, white-blue flower, pale blue/silver robe and blue-silver sword. Independently generated animation candidates are **not** guaranteed identical to original APNG.
- Source generator returned actual 8-frame GIF89a magic even though file extension was `.png`; export retains true GIF original with corrected extension.

## R3 actual deliverable

ZIP preserved in personal ChatGPT Library (not in GitHub):
`/TMB-Character-Art/AS_CHAR49_FEMALE_RIGHT_R3_CANDIDATE_20261116.zip`

- ZIP SHA256: `a99618fb54fdd3e839789cc890e131477ee7ea7a10b0e6b73487fed0507e9980`.
- Contains 57 files, CRC verified, 16 authored-motion source-derived 512x512 PNG RGBA cells, two lossless 2048x1024 atlases, APNG/GIF previews, 1280x720 standalone **UNRUN** Godot project SpriteFrames/scene, source/PNG SHA manifest, complete 68-check QA JSON, original GIFs, offline dark/light 1x/2x/3x visual reviews and an 8-second 1280x720 **OFFLINE NOT GODOT** MP4.
- `Walk_Right` R3: new 8-frame GIF real motion, actual source SHA256 `23b2291945bc1956707694e42a6ac7ba1c41e3530ac07032bbe80219857f5e49`; lowered excessive knee lift compared with R2, preserved sword color and facial profile. Loop still requires live-motion/foot-contact review. **ART CANDIDATE, NOT PASS**.
- `Attack_Right` R2: preserve all eight R2 painted source poses, original source GIF SHA256 `a7b97473c35c134ae63d9ec38efa130e5d29dc86bc203d10c30d65d24c1eaf2e`. R2 export had alpha bottom **Y=445**, despite its earlier description claiming Y=442. R3 takes the complete R2 painted frame and translates it upward **3 px** to meet export foot reference Y=442; it does not redraw/rig actor poses or change combat logic. **ART CANDIDATE, NOT PASS**.
- `Cast_Right`: two separately attempted generation outputs were both mislabeled Walk-like motion; **REJECTED AND EXCLUDED**, no synthetic coverage counted.

## Verified tests and open visual gates

- Actual Pillow source-frame, alpha, 512x512 RGBA, pixel-hash, registration, 4x2 atlas equality and frame uniqueness checks **68/68 PASS**.
- Independent rerun of included verifier confirmed 16/16 frame hash/bbox/atlas checks.
- GIF and APNG previews: both 512x512 transparent with eight frames. Offline MP4: H264, 1280x720, 8.00s. **It is not Godot footage.**
- Real actor walk stance/feet/hair continuity, hand/sword attachment and motion smoothness are not proven by the numeric checks or still images. A body-bottom Y=442 alpha check is not a grounded-foot contact test.
- Godot **4.7.2** executable is unavailable in the working environment. Native import/render/video not run and CI exact-SHA engine gate NOT PASS. Windows/Android physical QA pending.
- **0/24 production approved**; no integration with the deployed female disciple actor. Do not falsely inflate 24-slot coverage.

## Next responsible work

1. Restore materializable original female APNG or get an owner attachment, compute true SHA256, compare pose identity, grip, hair, flower and sword before locking master.
2. Repair any remaining Walk landing/recovery and Attack hand-hilt discontinuities by original frame-by-frame animation. Do not rebrand Walk as Cast/Hit/Death.
3. Run Godot 4.7.2 official native 1280x720 on exact commit and visually inspect at 1x/2x/3x, get owner art approval before integrating.
