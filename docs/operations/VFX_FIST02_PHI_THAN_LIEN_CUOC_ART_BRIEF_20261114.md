# FIST02 — Phi Thân Liên Cước | Art-first V1 (14/11/2026)

**Status:** CODE_LAB_READY; technical & visual approval not inferred from committing. PR #72 Draft; Godot 4.7.2 GL Compatibility; no rig, Codex, merge, new branch, live PvE or gameplay edits.

## G0 — Exact canonical declaration
- `tmb.skill.fist.ba_quyen.active_02.human` (Human Bá Quyền): effect=`guard`, element=`fire`, shape=`single_target`, cap=1, cast=0.45 s, range=5.5, cooldown=8, projectile_speed=0, power=0.35, duration=4 s.
- **This is guard, not a multi-hit damage effect.** The catalogue's damage_ratio metadata is not permission to synthesize a hit; no damage, fake DoT, HP changes, shield strength formula change, or AoE.
- LAB guard is shown on the caster as a **visual sample**. Actual recipient and timing will only derive from a separately verified Combat V2 cast/guard event if live integration is later authorized.

## G1–G3 — Art direction and assets
- A pair of rapid broken-arc heel trails, individually posed, condensing into a **crossed kinetic pressure guard**, with a few earth dust motes. Amber, ivory-gold and warm umber, no flame projectile or talisman paper/runes.
- This is a new first-party deterministic raster atlas generator based on the *production method* learned from Tal01, not any of its art: `tools/vfx/generate_fist02_guard_atlas.py`.
- Three transparent RGBA sprite sheets, generated before Godot import: 12 heel-sweep poses 4×3×320px =1280×960; 8 crossing-guard poses 4×2×320px =1280×640; 8 footfall-dust poses 4×2×320px =1280×640. Each pose has independently varied path geometry, brush highlights and motes; no external licensed pixels and no rig.
- The existing Nu Doc Tu idle sprite and valley SVG backdrop are only scale/composition **stand-ins**. A full frame-by-frame Fist actor kick is NOT claimed.

## G4 — Animation chronology (visual-only lab)
| Local preview | Visual behavior |
|---|---|
| 0–0.19 s | first kinetic heel sweep / dust |
| 0.19–0.45 s | second sweep; whole sprite advances as a *placeholder* |
| 0.45–4.45 s | one guard cue on one recipient, 4.0-second contract duration |
| 4.45–4.94 s | guard dissipates, no new damage cue |
| 4.94–5.32 s | full clear / preview loop reset |

The 0.45 s mockup is no authority to add gameplay guard; no real Combat V2 hit/status writes. No persistent damage projectile. Additional light glow is subordinate to the raster hero sheet. No mock impacts at the dummy opponent.

## G5–G7 — Evidence
- Isolated scene: `res://labs/combat_lab/fist02/phi_than_lien_cuoc.tscn`.
- Focused contract: `res://tests/labs/combat_lab/vfx_fist02_contract_test.gd`.
- Native workflow: `.github/workflows/vfx-fist-02-phi-than-lien-cuoc.yml`: Godot 4.7.2 pinned executable, strict import/parse and contract, genuine 1280×720 video of 318 fixed-clock frames, GIF, 12 checkpoints, raw generated atlases and hashes.
- Required manual review: cast 0.09/0.17/0.29/0.41, guard 0.51/0.81/1.25/2.15/3.33/4.30, fade 4.61/5.07. At 1× verify the guarding actor stays visible and the VFX remains distinct from FIST01.
- **Owner R10 decision:** Khai Sơn Trọng Quyền R10 'tạm tạm': provisional acceptance to move to the next skill, not ideal art approval or live PvE permission. FIST02 must pass technical and real-image QA separately.
- `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_WINDOWS_ANDROID_PENDING`.

## R1–R3 official Godot evidence / art review — 2026-11-14

R1 at source SHA c9fc879d904115a975bef0223bc5978f98f055d6, Actions #43583360823: Godot 4.7.2 focused PASS + movie captured, but native 0.29s and 1.25s are too faint; art failed self-review.

R2 generator commit 0a4ca34f9161bdf40ef8a6f8aaddac276b5ad117, scene SHA 690c035d8ca35c31b78e630d79ebf5b6a09eec1d, Actions #43583699091: alpha/contrast and real-scale positioning improved. However the 4s guard remains a generic ring.

R3 generator commit e236f4980ed5a6414e69dc474542a0cde554f004, exact tested scene SHA **5714e80e94745e3234140adcffc59e12f3b3ecc4**, Actions **https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43584024114** SUCCESS. Artifact **vfx-fist02-native**, ID **14109840513**. Strict import+parse+focused **VFX_FIST02_FOCUSED_RESULT=PASS failures=0**, actual original Godot 4.7.2 Compatibility MP4 1280x720 / 318 fixed-clock frames, GIF, 12 PNG checkpoints, generator PNG atlases, checksums. The 60fps movie encoding is NOT measured Windows/Android performance.

Actual R3 inspection: 0.29s two brighter heel sweeps and whole-sprite afterimage, not a rig; 1.25s a crossed golden guard (rather than filled circular shield) is visible behind the recipient, but still too much like an X-shaped UI effect and actor still idle. At 4.30s guard holds, 4.61 fades and 5.07 is clear. The other actor is not hit. Art rubric /5: silhouette 3.0, lighting/material 3.1, motion 2.5, composition 3.6, semantic guard/one recipient 4.2, fade 3.8, uniqueness 3.2. Below art gate, so this is a usable **technical LAB prototype, NOT an art-approved skill**.

Gates: CODE_LAB_READY, GODOT_FOCUSED_PASS, GODOT_CAPTURED, FRAMES_REVIEWED; ART_REWORK_REQUIRED, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF, PHYSICAL_WINDOWS_ANDROID_PENDING. Owner provisional permission to move past FIST01 R10 is NOT FIST02 approval. Further artistic work must use premium illustrated guard art and original Fist body animation frame-by-frame without rig. No Combat V2, HP, target, SaveService, economy, AI or live PvE edits.

## OWNER REJECTION — V4 art-first reset, 2026-11-14
The owner REJECTED R1–R3 visual interpretation of "Phi Thân Liên Cước" as literal physical kicking: current character has NO kick animation; moving idle sprites and geometric orange lines made unattractive game VFX. A skill name and description are ARTISTIC INSPIRATION, never a mandate to fake nonexistent actor movements. The actual locked catalogue mechanic is guard/fire/single_target 1, cast 0.45s, duration 4.0s. R1–R3 technical PASS does not mean art PASS: mark OWNER_ART_REJECTED.

V4 uses a real first-party ImageGen-derived painted fire-spirit hero, carefully cropped from generated illustration and segmented into transparent 320x256 WebP (SHA256 f8e7393b986dfdad4a69eb485bfec683e6ea358cedf2c15ad8406f22a66118b6), stored in godot/labs/combat_lab/fist02/assets/v4/guardian_spirit_master.webp. The original presentation image is NOT a Godot screenshot and is not the production asset: only a cleaned isolated flame/spirit region survives. No source pixels from any unlicensed commercial game.

The source master is built to 12 cast + 8 guard + 8 ember original-alpha frames by tools/vfx/generate_fist02_spirit_v4.py, behind a STATIC caster proxy. Ghostly fire is an illustrative effect, not actual kicking, new summons, combat hit events or player animation. Guard visual remains for exactly four seconds after cast and clears. No rig, no Codex, no gameplay changes, no PvE integration, no other school's file edits.

Gates: CODE_REWORKED, exact-SHA GODOT_QA_PENDING until actual Actions result, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF. Judge native 1280x720 film at 1x and reject any leftover fake sprites/low-quality geometric artifacts.


## V4 exact-SHA native QA and visual check — 2026-11-14
Final art-producing GitHub commit **51ce7e6b220535504642f14b6c9fd7fe46b91f69**, Actions **https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43587918901**, **SUCCESS**. Artifact vfx-fist02-native ID **14111760406**. Godot 4.7.2 Compatibility, strict import/parse, focused contract `VFX_FIST02_FOCUSED_RESULT=PASS failures=0`, authentic 1280x720 318-frame MP4, GIF, 12 timecode frames and PNG atlas SHA256 manifests. 60fps is fixed movie cadence, NOT measured Android hardware FPS.

Original source master file is 320x256 transparent first-party illustrated Fire Spirit, generated from ImageGen concept output, visibly hand-painted/painterly strokes, cropped/segmented and then edge-feathered in reproducible source before atlas. CI produces 12 cast, 8 breathing guard, 8 ember sprites. No actual actor leg or skeletal movement: CASTER and OTHER images are static. Spirit imagery represents the skill concept metaphorically; neither gold silhouettes nor flames produce actual Combat V2 damage, hit, projectile or summons.

Native frame review: 0.29s illustrated golden energy imprints manifest behind unmoving caster; at 0.81/1.25/2.15s illustrated gold Hỏa guard remains and face is visible; 4.61s fades and 5.07s clears. Removed most dark rectangular crop backing with a hot-chroma alpha mask plus edge feather. Remaining limits: preview uses existing Poison Tu actor image solely for scale; guard silhouette still inherits two illustrated spirit figures from original concept, not custom final Fist character art, with some painterly ground texture along bottom. No claim of owner art pass.

Gates: **GODOT_FOCUSED_PASS, GODOT_NATIVE_CAPTURED, FRAMES_REVIEWED, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF**. R1–R3 were OWNER_ART_REJECTED and must not be reused. This new version is a distinct illustrated-asset implementation pending owner's visual decision. Never modify actual Combat V2, target/HP, SaveService/economy, or rig a character.
