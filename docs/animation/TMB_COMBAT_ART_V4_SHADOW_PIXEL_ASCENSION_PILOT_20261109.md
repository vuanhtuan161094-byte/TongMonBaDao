# TMB Combat Art V4 — Shadow Pixel-Chibi · Approval + Ascension Pilot

**Approved by owner:** 2026-11-09. **Target:** existing Draft PR #72 on `integration/pve-p0-playable-ui-20261103`. **Scope:** presentation-only. No merge, no new branch, no gameplay/SaveService edits.

## Character identity locked

Owner selected the stronger Shadow Pixel-Chibi four-view **Nữ Độc Tu** (black long hair/high bun, glowing emerald eyes and poison forehead seal, jade-black heavy xianxia armor/robe, gold ornaments, serpent aura). Approved image reference: `nữ_độc_tu_poison_cultivator_turnaround.png`, SHA-256 `e77452971fca23f7c6cb79d07396e9fee8a88619e888d7a68bdaf4afbd84c16a`. The approved still is **not** evidence of animation continuity. Do not silently redesign the actor's face, hairstyle, proportions, or armor.

## NEW two ascension VFX (additive to V4)

The authoritative 30-realm ladder transitions are:
- `immortal`: **Đại Thừa (realm 10) → Nhân Tiên (realm 11)**. Jade/ivory/gold, lotus petals, double halo, upward light, gentle ground sigils.
- `divine`: **Tiên Đế (realm 20) → Thần Nhân (realm 21)**. Purple/gold divine seal, crown, jagged cosmic energy, lightning pillars, broad luminous rays.

**Trigger only on a confirmed successful cultivation major breakthrough**. Required read-model/command result semantics: `track == cultivation && ok == true && success == true && old_realm==10 && realm==11` (or 20→21). Dedupe by the canonical actual event ID. Do NOT trigger on failed roll, body training-only milestone, button click, mere loading a save, or repeated event. Do NOT issue EXP, damage, currency, HP, RNG, realm, or Save mutations from VFX. If production signal lacks `old_realm`, read the verified before-state; never invent a transition.

## Deterministic authored visual pack (local artifact, NOT yet merged into repo)

- **Immortal:** 48 frames × 16 FPS = 3.0 s; dual alpha atlases (BACK + FRONT); jade-white-green palette.
- **Divine:** 64 frames × 16 FPS = 4.0 s; dual alpha atlases (BACK + FRONT); purple-gold palette.
- Each VFX cell 256×320 px; 8 columns; logical pixel canvas 128×160 and 2× nearest scaling; foot pivot **(128,254)**; 4-direction invariant (effect is view-independent, actor is not).
- Asset filenames `ascend_immortal_back_atlas.png`, `ascend_immortal_front_atlas.png`, `ascend_divine_back_atlas.png`, `ascend_divine_front_atlas.png`. No VFX precomposed onto character frames.
- Frame generation source: `build_ascension.py` (Python/Pillow deterministic geometry, included in the user-delivered pilot archive); original authored pack, no sampled game footage.
- The user-delivered ZIP `TMB_V4_Ascension_Tien_Than_Pilot.zip` SHA-256 `d068704ae84d782199143e2a809ec77c8464f927be6bbae88188c34d390dbaac`. GIF previews and alpha sheets are included in that ZIP, not automatically materialized in the repository by this Markdown.
- Test design: 22 deterministic asset checks, 0 fail (atlas dimensions, PNG SHA, transparent corner samples, intended fade-in/fade-out nonempty-frame coverage, GIF frame counts). **NOT a Godot 4.7.2 import/GUI PASS.**

## Hard acceptance gate

Do not wire the show into gameplay until approved assets are committed into source storage and a genuine Godot 4.7.2 scoped test verifies 4x orientation, alpha, timing, deterministic ordering and end-state. Also compare 1280×720 view (gameplay 1x + zoom 2/4/6), resource use on 8 GB RAM Windows, Android performance, and zero `SCRIPT ERROR`. A generated preview GIF/MP4 is an asset animation proof, **not a Godot game recording**.

**Current status:** `V4_ART_REFERENCE_APPROVED`, `V4_ASCENSION_ASSET_PILOT_AUTHORED`, `RUNTIME_INTEGRATION_PENDING`, `GODOT_VIDEO_PENDING`. Previous V3 poison art/atlases are preserved for comparison; never delete or replace them before V4 acceptance.
