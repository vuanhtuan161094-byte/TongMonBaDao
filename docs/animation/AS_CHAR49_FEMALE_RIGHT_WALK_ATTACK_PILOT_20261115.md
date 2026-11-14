# AS-CHAR-49 — Nữ Kiếm Tu RIGHT Walk/Attack pilot (2026-11-15)

Status: **TWO TECHNICAL CLIP CANDIDATES, NOT PRODUCTION; GODOT_NOT_RUN; OWNER_ART_PENDING; ORIGINAL_APNG_BYTES_BLOCKED**.

## Provenance and branch

- Draft PR #72; existing branch `integration/pve-p0-playable-ui-20261103`.
- Branch HEAD before starting asset investigation: `4995d56524ef0f902a624b2af35634f082329b7a`.
- Branch reverified before creating this checkpoint: `e9bf9a3b523469d2fb6cf16e8b61d986fbd6fb1c` (concurrent VFX work; no force, no merge).
- Mandatory authority read: `AGENTS.md`, AS-CHAR49 handoff, female Art Direction, female violation audit, male AS-CHAR48 technical handoff, Issue #77.
- Verified Library metadata/file preview of `KIEM_TU_FEMALE_4DIR_ATTACK_LOSSLESS.apng` (962,165 bytes per metadata), with dark indigo hair, white-blue flower, blue-white dress, blue-silver sword. The **raw original APNG bytes were NOT accessible** (Library materialization denied). Thus no honest APNG magic/frame count/SHA256 can be reported.

## New and separate right-direction candidate art

Animation generation produced TWO actual source GIFs, each 8 encoded frames at 120ms, not marketing posters/contact sheets. The generator named them `.png`, but magic-byte validation returned **GIF89a**, and they were saved in the delivery package with corrected `.gif` extensions.

1. `sources/Walk_Right.gif`: 443×443, 8 native GIF frames, SHA256 `d879bb7a55adaa6145b4fab66f14b09d513bc5a7effd3df36d7da6613b51dc69`.
2. `sources/Attack_Right.gif`: 473×444, 8 native GIF frames, SHA256 `e645bc91b10d574331e2675170676596eda7dbf2be5730c019a23e0ff183ec05`.

These are **newly generated visual candidates informed by the Library preview**, NOT verified extractions or approved exact reproductions of the locked female APNG. Right Walk involves alternating step poses; Attack depicts weapon raised / lunging / sword extension / recovery, rather than reusing Walk. No rig, cutout bones, rotated stand sprite, or generated contact-sheet sampling is used.

## Physical binary deliverable

In personal ChatGPT Library:
`/TMB-Character-Art/AS_CHAR49_FEMALE_RIGHT_WALK_ATTACK_CANDIDATE_20261115.zip`

- ZIP SHA256: `3d88cb60fbeb8b201be3267ff38f97e2268d160faf2c605f8bcd12b42757d9e5`.
- 51 entries; ZIP integrity test passed. Actual ZIP is stored in Library, NOT in this GitHub commit.
- Both authentic GIF input files preserved verbatim; 16 independently decoded 512×512 RGBA PNG frames; consistent fixed registration to shared foot (256,442) with scale 0.82; 2 lossless 4×2 atlases 2048×1024, pixel-for-pixel comparisons to PNG; 2 GIF previews; Godot `SpriteFrames` `.tres`, 1280×720 isolated Godot project; source SHA and per-frame SHA in JSON manifest.
- Walk: loops; Attack: nonloop one-shot.
- 1× / 2× / 3× OFFLINE preview stills and MP4 provided; **NOT Godot-generated media**. The Godot 4.7.2 binary is unavailable in this runtime, so native import/playback/movie cannot be claimed.

## Quality gate and open debts

- Python extraction + registration + atlas checks: **12/12 targeted technical checks PASS**, including 16/16 distinct PNG byte identities, no alpha-border cropping, source format validated, 512×512 RGBA, and exact atlas cell pixels.
- **NOT YET QA-PASS**: camera frame motion, foot slide/hand/weapon geometry, whole clip consistency at 75px and 225px, alpha fringing, official Godot 4.7.2 parse/import, native 1280×720 video and physical device performance. Numeric distinct hashes do not prove art movement/quality.
- **Sourcing blocker**: original Library APNG raw bytes denied. Do not imply its SHA or master has been locked.
- Owner approval required. Current counts **2/24 new exported candidate clips**, **0/24 production approved**. Remaining 22 clips not produced. Do not integrate pilot into runtime actor or affect 11 other schools.
- No gameplay, Combat V2, SaveService, PvE/V6.3 or male art changed. No new branch, no merge, no Codex, no rig.

## Next exact gate

Recover original APNG *raw bytes* and verify SHA256/source identity, compare both pilot clips with the approved female reference and fix anatomy/weapon/style inconsistencies; run the standalone Godot 4.7.2 project with physical/native video review (1×/2×/3×); then expand only if owner signs off on the visual master and true Walk/Attack behavior. Never label these candidates production-ready from the existence of 24 file slots alone.
