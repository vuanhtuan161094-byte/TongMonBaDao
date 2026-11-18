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
