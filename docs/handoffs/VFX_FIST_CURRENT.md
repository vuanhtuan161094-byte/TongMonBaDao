# QUYỀN TU — CURRENT VFX HANDOFF · PR #72

**Checkpoint:** 18/11/2026 · dedicated FIST school chat; G0 catalogue contract reconciled, G1 full frame-by-frame reference analysis NOT_EXECUTED, G2 semantic direction DRAFTED, **G3 illustrated RGBA SOURCE CANDIDATE LOCAL ONLY; not in repository**, no FIST skill deployed.  
**HEAD_BEFORE:** `176aa0c456eaa1a5aa1db6790d87b43150f7d63f`; **PR:** [#72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72), Draft; **branch:** `integration/pve-p0-playable-ui-20261103`. **FIRST_CHECKPOINT_COMMIT:** `a270195a22d3644f223ab63b07cee1d80a90d8cc`. **CURRENT_REVIEW_COMMIT:** see exact history of this file (cannot self-reference current commit inside itself).

## 1. Authority, exact status and frozen art

Read `AGENTS.md`, [multi-chat coordination](../operations/TMB_VFX_MULTI_CHAT_COORDINATION_AND_RECOVERY_20261118.md), [school playbook](../operations/TMB_VFX_FIST_SCHOOL_PLAYBOOK_20261114.md), [consolidated 18 Nov](../operations/VFX_FIST_SCHOOL_CONSOLIDATED_HANDOFF_20261118.md), [183-row FIST ledger](../operations/vfx_school_ledgers/05_fist_183.csv), V4 Art-First SOP, sprite-layer SOP, Art Director skill, Art Bible C, status overlay A, V4 packet guide and FIST12 R6 failure postmortem. New VFX candidates are not approved by CI.

**FROZEN / DO NOT EDIT**: FIST12 R10C `e178095b43a9b1f21b77544a821622f0cc9d706a` owner provisional; FIST13 R7 `21023942b1796b3fd5829accd55b3d2f916f7472` owner provisional; FIST08 selected R1 (R2 rejected); FIST07 R6 provisional; any other specifically approved artwork. FIST09 Trấn Sơn Hộ Đồng R3 native technical artifact `a3d2c774...` exists, and owner later said “ok chốt skill”; older repository review rejects R3 and subsequent R4/R5/R6 exist. Therefore **FIST09_OWNER_REVISION_RECONCILIATION_REQUIRED**; do not choose R3/R6 by inference or overwrite any revision. FIST10 R4 = style reference, not validated native animation.

FIST14 R2 at `1fc4ad2811fa0fcaa572b89e0b34c676d46fa416`: [Actions #44112832093](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44112832093) was technical/G3.6 PASS but **G3.7_ART_SELF_FAIL** (three claw shape, flat material); **OWNER_PENDING, PVE_HOLD**. FIST15 R2 technical PASS, art self-FAIL (V streak); do not modify in this checkpoint.

## 2. Chosen next single skill — FIST14 R3 (not yet code-integrated)

**SKILL_ID:** `tmb.skill.fist.huyet_quyen.active_04.human` · **branch:** Huyết Quyền · **name:** Liệp Huyết Truy Đả · **tier:** Human.
**Catalogue contract:** effect=`mark`; element=`nether`; shape=`single_target`, target_limit=1; range=2.8; radius=0; cast=0.45s; cooldown=8s; duration=6s; projectile_speed=0; hit_count=not declared. No gameplay new hits, poison, DoT, heal, damage or homing mechanics. `RUNTIME_MAPPING_PENDING` until actual Combat V2 receipt is separately mapped.

**Three clocks, do not conflate:** (A) catalogue cast .45 / cooldown 8 / mark 6, true combat receipt unknown; (B) **R2 LAB ONLY reference** charge 0-.45, illustrative pursuit .45-.82, single cosmetic mark .82-6.82, fade 6.82-7.11; R3 scene/event timing **NOT YET EXECUTED**, not auto-adopted; (C) R2 QA loop 7.43s, unrelated to gameplay cast clock.

**G1 motion/reference:** school playbook and original/past native review records inspected; detailed licensed source movement breakdown **NOT_EXECUTED**, so independent reference acceptance remains pending.\n\n**G2 semantic direction (DRAFT):** Caster accumulates concentrated organic ruby qi into a clearly **closed fist** with four compressed knuckles and curled thumb. One accelerating fist travels source→selected moving foe, ends in one white-hot short hit/contact, and leaves one restrained blood-palm mark on shoulder/torso (not face), fading after actual authoritative duration. No triple talon/letter V, poster, fake repeated damage, status replicated per skill. Reference Võ Lâm/JX is only art study; first-party art required.

## 3. Actual executed output and gate truth

- **Local new first-party IMAGE source:** genuine isolated true-alpha RGBA `1774×887`, SHA256 `e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5`. It shows one detailed spectral closed fist rather than three claws. A 640×320 review derivative SHA256 `d3c210f55be021dea3e4280c27f786ea5da75a53362df0da407306f9586c017f`. Both are **LOCAL, NOT_COMMITTED** (can be recovered only from this originating chat's verified downloadable source archive); do not label them permanent repository masters. This is original illustrative source, **not animated keyframe set** or Godot frame.
- Separate attempted original algorithmic 36-key code-art was visually checked at actual 320×320 review tile: flat box/wisps, insufficient 1× fist/material fidelity. **REJECTED_LOCALLY, NOT_COMMITTED**. Do not use it as FIST14 R3 art source; this deliberately avoids repeating FIST12 R6 / flat R2 errors.
- **G3 independent high-quality charge/travel/contact/mark key masters:** NOT_COMPLETE. **Atlas/source permanence in GitHub:** NOT_COMMITTED. Existing FIST14 R2 source and scene retained untouched.
- **G3.5 Godot-native 1280×720 charge / peak / moving-contact:** NOT_EXECUTED for R3. No Godot 4.7.2 binary in current local environment. Do not use offline composites/illustrations as native screenshots.
- **G3.6 RGB contrast and sustained mark visibility:** NOT_EXECUTED for R3.
- **G3.7 self art scale/semantics:** proposed concept has readable fist, but **NOT_ASSESSED in native Godot**; no claim of >=4/5.
- **G4/G5** moving foe/decoy/expiry/full genuine Godot MP4 + >=12 frame inspection: NOT_EXECUTED for R3.
- **G7** school V4 packet/evidence/CI exact-SHA: NOT_EXECUTED for R3. Previous R2 focused PASS does not transfer to R3.
- **OWNER_GATE:** VISUAL_PENDING, **PVE_GATE:** HOLD, **V63:** OFF, **ANDROID_PHYSICAL:** PENDING.

## 4. Next exact action / write ownership

**ONE NEXT ACTION:** Persist the chosen isolated 1774×887 true-RGBA illustrated master into a new FIST14-only source folder with its exact SHA and rights provenance; design genuinely independent charge, travel, contact and one status-mark master poses; then create an R3 **separate** Godot LAB preview and R3 school packet without modifying the legacy R2 scene/source. Perform real G3.5 mini native Godot capture before any full MP4 or art claims. If image transport into GitHub fails, report `SOURCE_TRANSFER_BLOCKED` and STOP instead of silently replacing the art with a procedurally flat approximation.

**Write scope:** `godot/labs/combat_lab/fist*/**`, strictly FIST-specific assets/packet/tests/workflows and **this handoff only**; no POI/PAF/AGENTS/shared coordinator/gameplay/Combat V2/SaveService/economy/PvE. No rig, no default GIF, no Codex, no branch/merge. Re-fetch HEAD before every write and never force update.

---

## Checkpoint 2026-11-18 — FIST14 R3 original source recovery + local keyframe candidates

**Live branch HEAD before this checkpoint:** `b2b5d36f87d2e7c49cd42034a6e42dcaad6bbcf7` on Draft PR #72; branch `integration/pve-p0-playable-ui-20261103`. **School-owned manifest committed:** [FIST14 R3 source package manifest](../..//godot/labs/combat_lab/fist14/r3/SOURCE_PACKAGE_MANIFEST.json), introduced at commit `b2b5d36f87d2e7c49cd42034a6e42dcaad6bbcf7`. No FIST R2 or FIST08/09/12/13 sources were modified.

- **Exact master recovered (not substituted):** first-party ImageGen RGBA `1774×887`, SHA-256 `e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5`. It is **NOT_COMMITTED_AS_GITHUB_PNG** due to binary-transfer boundary of connected GitHub text/blob operations; never claim otherwise.
- **Durable binary recovery:** ChatGPT Library `/TMB-VFX/FIST14_R3_MASTER_36KEY_CANDIDATE_20261118.zip`, Library ID `libfile_1ce9e88f83c08191bee4c639531d80ea`; ZIP SHA-256 `6762348b570cad988247e522403c00008c6a898a9df56caacfdafb3cc37a6edd`. Contains exact master, 36 PNG frames, four atlas sheets, four representative source-key images, original-building Python script, static preview and SHA/alpha manifest. This recovery is stored in Library, **not** GitHub binary storage.
- **Local keyframe candidate:** 8 charge + 12 flight + 8 contact + 8 one-mark frames; 640×640 source frames, atlas 320×320, 4 columns. Static checks: **36/36 nonempty unique RGBA, clean corner alpha, original source SHA matched**. These are layered phase-wise composites using one original hand image with newly authored light material, **not 36 independently painted fist poses**; file uniqueness does not establish beautiful motion or art approval. Straight crop matte was detected and feathered before packaging; 1× Godot review is still required.
- **G0 canonical contract unchanged:** Human Huyết Quyền MARK / nether / single_target cap1 / cast .45 / CD 8 / duration 6 / range 2.8 / projectile speed 0; hit_count undeclared. Combat V2 actual receipt = `RUNTIME_MAPPING_PENDING`. Do not generate damage/homing/extra marks.
- **Gate truth:** `G3_LOCAL_SOURCE_CANDIDATE`; `G3_GITHUB_BINARY_TRANSFER_BLOCKED`; `G3.5_NOT_EXECUTED`; `G3.6_NOT_EXECUTED`; `G3.7_NOT_EXECUTED`; `G4/G5/G7_NOT_EXECUTED`; `OWNER_VISUAL_PENDING`; `PVE_HOLD`; `ANDROID_PHYSICAL_PENDING`. The static review montage is explicitly **NOT_GODOT**, and no workflow CI/new Godot native video was run for R3.
- **Next single action:** Transfer the exact master and candidate assets from the named Library archive to **FIST14 R3-only** paths, verify full binary hashes, then implement/run an isolated Godot 4.7.2 G3.5 three-frame mini preview with a moving enemy before G3.6/G3.7. If binary upload is blocked, preserve `SOURCE_TRANSFER_BLOCKED`; never replace by lower-quality code-art or claim technical PASS. Shared status/VFX, POI/TALISMAN, gameplay, PvE, approved FIST paths remain read-only.

**Import safety checkpoint:** At HEAD-before-write `f89797a3e419dee1c601c97afa6085fe6d26c000`, a school-only byte-verifying importer was added at [FIST14 R3 importer](../../godot/labs/combat_lab/fist14/r3/import_source_archive.py) (commit `f89797a3e419dee1c601c97afa6085fe6d26c000`). A local run against the exact Library ZIP returned `FIST14_R3_SOURCE_IMPORT_PASS`, but this is **local file integrity QA**, not a GitHub binary import or Godot native pass. The tool rejects missing/bad SHA archives and refuses to overwrite different existing sources. No automated source import has been triggered on PR #72.

---

## FIST14 R3 corrective production receipt — 2026-11-18 (source truly committed)

**HEAD checked before write:** `8f6635910b9478989076b911494fe6ab921d2ccc`. PR #72 remains Draft, **no merge**. This correction replaces the earlier `G3_GITHUB_BINARY_TRANSFER_BLOCKED` assessment for the R3 files below; historical failed attempts remain documented.

- **SOURCE IN GITHUB: VERIFIED.** Original isolated first-party RGBA `1774×887` committed as binary at `godot/labs/combat_lab/fist14/r3/source/fist14_original_rgba_1774x887.png`. SHA-256 `e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5`, exact Git blob `86b67fe3ba42a56e4953433f76a05079e363e5ad`, commit `f52cef16feda3a2ec28346051a28f949d8adff6f`. This is the **actual original**, not the lower-resolution source substitute previously feared.
- **R3 atlas candidate binaries IN GITHUB:** Charge 8 `d30c9d9805a9ea046f5e5ea993c178164c91b32d`, flight 12 `a558891808b4075ef898998ba129c19b6abe1c42`, contact 8 `95cb0644193b0cba1fd4b51c56fe1beb1d45c3a6`, one mark 8 `c9c63146422b0b52c84cd7da85aa0fdcb3fe9318`, all under `godot/labs/combat_lab/fist14/r3/assets/atlases/`. **Not 36 separately illustrated anatomical fists:** exactly one painterly closed fist image is used while the 36 RGBA frames have phase-specific authored energy layers. Quality gate remains **MANUAL_ART_REVIEW_REQUIRED**.
- **New R3-only LAB/packet/test/workflow:** commit `8f6635910b9478989076b911494fe6ab921d2ccc`, scene `godot/labs/combat_lab/fist14/r3/liep_huyet_truy_da_r3.tscn`, script `liep_huyet_truy_da_r3.gd`, focused test `godot/tests/labs/combat_lab/vfx_fist14_r3_contract_test.gd`, V4 packet `docs/operations/vfx_packets/FIST14_R3_NATIVE_G35_V4.json`, workflow `.github/workflows/vfx-fist14-r3-native-g35.yml`.
- **Exact-SHA native workflow:** [Actions #44242444811](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44242444811) on `8f6635910b9478989076b911494fe6ab921d2ccc`; **RUNNING at checkpoint**, result NOT YET VERIFIED. No G3.5 PASS claim yet. Native charge at 0.22s / peak 0.65s / moving contact 0.90s, 1280×720. If run fails, record failing step and repair only school-owned R3 files; all owner art pending.
- **Confirmed isolated local generator reproduction:** original SHA matched and each of 4 rebuilt atlas Git object SHAs exactly matches the original commit. A missing-directory bootstrap was also repaired locally but **not yet committed at this checkpoint**; do not claim repo source script includes that fix.
- **Gate status at checkpoint:** `G0_VERIFIED`, `G3_SOURCE_AND_CANDIDATE_ATLASES_GITHUB_VERIFIED`, `G3_ART_SELF_PENDING`, `G3.5_NATIVE_RUNNING_NOT_VERIFIED`, `G3.6/3.7_NOT_EXECUTED`, `G4/G5/G7_NOT_EXECUTED`, `OWNER_VISUAL_PENDING`, `PVE_HOLD`, `ANDROID_QA_PENDING`. Historical R2 art self-fail and owner-provisional FIST12/FIST13/FIST08/FIST07 unchanged; no touching FIST09 until revision reconciliation.

**One next action:** Retrieve actual G3.5 native Godot 1× charge/peak/contact images for exact run #44242444811; compare with R2 and apply ART STOP or focused R3 revision. Do not run G5 before visual G3.5 gate.

---

## FIST14 R3 G3.5 verified technical and manual 1× review — 18 Nov 2026

**HEAD observed before handoff write:** `fb1fd66a5c2febb93ee6be4cb43ebe2101b54e9c`; PR #72 Draft/no merge. **Successful focused native G3.5 workflow:** [Actions #44245929756](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44245929756) on exact source SHA `a17f7b258e96796fdaca63ef77d68570a0ed60a8`; artifact ID `14401218703` (`fist14-r3-g35-native-a17f7b258e96796fdaca63ef77d68570a0ed60a8`, 14-day expiry). Earlier [Actions #44242444811](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44242444811) on `8f6635910b9478989076b911494fe6ab921d2ccc` also concluded success, but latest exact-SHA proof is run #44245929756.

- **Verified native files from artifact ZIP:** real Godot 4.7.2 1280×720 MP4 `v4-fist14-r3-native.mp4` (1.8 s) and `v4-charge.png` 0.22s, `v4-peak.png` 0.65s, `v4-contact.png` 0.90s. Focused test log: `FIST14_R3_FOCUSED_RESULT=PASS failures=0`; `GATES.txt` explicitly says `G3.5_TECH_EVIDENCE_CAPTURED`, `G3.5_ART_MANUAL_STOP_PENDING`, `G3.6_NOT_EXECUTED`, `G3.7_NOT_EXECUTED`, `G5_FULL_NATIVE_NOT_EXECUTED`, `OWNER_PENDING`, `PVE_HOLD`.
- **Manual 1× art self-review from genuine three frames:** **REWORK/STOP**. Charge and mid-flight are technically legible, but the same spectral fist reads as a drifting detached image instead of authored changing punches. The contact stays too close to the target's torso and has insufficient short white-hot local-impact separation. Current cast actor is a pre-existing non-Fist placeholder; no permitted rig/fake actor punching. Synthetic moving-target evidence does not prove Combat V2 receipt. Do not promote this to owner-ready art.
- **Status:** `G0_PASS`; `G3_BINARY_SOURCE_ON_GITHUB`; `G3_KEYPOSE_ART_REWORK`; `G3.5_NATIVE_TECH_PASS_ART_SELF_FAIL`; `G3.6/G3.7_NOT_EXECUTED`; `G4/G5/G7_NOT_EXECUTED`; `OWNER_VISUAL_PENDING`; `PVE_HOLD`; `ANDROID_PHYSICAL_PENDING`. No PvE integration, merge, GIF, rig or edits to approved FIST source.
- **One next action:** improve only independent source key poses for FIST14 R3 charge/flight/contact, clear silhouette and impact at Godot 1×, then rerun 3-frame native G3.5 against fresh exact SHA before full movie.

## FIST14 R4 simple one-sprite candidate — 2026-11-18

**Authorization:** Issue #81 refreshed at PR #72 HEAD `e6947e69b897731a264bb62569d909d5fcb4c233`. The updated owner acceptance permits one existing first-party RGBA source, does not require newly painted poses, and directs Codex Cloud to use the existing shared GitHub Actions runner for native capture. PR #72 remains Draft; no merge, no gameplay, no PvE.

- **Candidate:** `godot/labs/combat_lab/fist14/r4_simple/**`, V4 packet `docs/operations/vfx_packets/FIST14_R4_SIMPLE_NATIVE_G35_V4.json`, focused contract `godot/tests/labs/combat_lab/vfx_fist14_r4_simple_contract_test.gd`. R2/R3, approved/provisional art, POISON/PAF/HF/TAL and gameplay are unchanged.
- **Source:** uses the existing original first-party FIST14 master at `godot/labs/combat_lab/fist14/r3/source/fist14_original_rgba_1774x887.png` unchanged (SHA-256 `e0006ceb6208cb7cb037d2909f2ca9d27e10f63b7d71871f53b6b55f4903b7b5`). Reproducible derivative assets contain one masked closed-fist crop, attached soft edge falloff and one local contact crop. This is one source sprite, not multiple independently painted poses. Native 1× art judgement remains pending.
- **Visual approach:** short directed cosmetic travel between existing caster and moving target at catalogue timing; one restrained wake; one brief local contact. No status graphic is faked; no damage, extra hit, homing, mark receipt, HP, SaveService or Combat V2 call is added. LAB timing does not claim an actual Combat V2 receipt.
- **Cloud focused checks:** Godot `4.7.2.stable.official.ed1daf0bf`; V4 packet and asset validators PASS; strict GDScript check PASS; focused test `FIST14_R4_SIMPLE_FOCUSED_RESULT=PASS failures=0`. Native G3.5 capture is delegated to the exact-SHA shared Actions workflow; result and artifact are to be recorded in the subsequent receipt entry.
- **Gates:** `SOURCE_VERIFIED`; `G3.5_NATIVE_PENDING`; `ART_SELF_REVIEW_PENDING_NATIVE_FRAMES`; `OWNER_VISUAL_PENDING`; `PVE_HOLD`; `ANDROID_PHYSICAL_PENDING`.
