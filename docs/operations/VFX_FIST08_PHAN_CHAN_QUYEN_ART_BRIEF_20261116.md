# Phản Chấn Quyền · FIST08 R1 · 16/11/2026

**GitHub PR #72 Draft only, branch integration/pve-p0-playable-ui-20261103.**

## G0 canonical lock
Exactly `tmb.skill.fist.kim_cang.active_03.human` — Earth `guard`, `single_target`, one protected recipient, `cast_time=0.45`, `duration=4`, cooldown 8, range 5.5, projectile speed 0, radius 0. Catalogue does not declare hit_count on this legacy guard, hence V4 packet sets 0 **outgoing visual hits**, not synthetic damage. No real damage deflection or return-attack logic authorized. V6.3/PvE OFF.

## R6 carry-forward, no rewriting approved art
User allows Kim Cang Ho The R6 as **provisionally acceptable** and asks to move on; records two open debts: (a) defended-hit reaction too weak, (b) long-state marker not perceptible. Do not change R6. This FIST08 must have separate punchy guarded-hit flash and a legible but subdued status marker.

## New art, not recycled visual
- Original 512×512 gold asymmetrical compression channels and white-gold counter-impulse painted into transparent masters. Added short-lived original first-party generated dragon pigment (646×185) from an *assistant-generated concept*, NOT any JX commercial pixel or poster as Godot proof.
- Cast 0–0.45, hero retract through 0.79. Distinguish from FIST07: no statue, no permanent grand glass dome. Negative central window to preserve real actor.
- Sustain 0.45–4.45 is small luminous pressure chevrons around shoulder and under feet; no repeated cinema-scale dragon; loop 8 poses. Give UI remaining-duration **LAB ONLY**.
- Incoming guarded-hit contact at demo timestamps 1.29 and 3.09 tracked to the walking protected actor's shoulder, visible ~0.28 seconds. Short white-gold directional counter-impulse visual without damage to opponent. Last 0.4s quietly fades.
- True visual demo start/end local timeline and the engine's gameplay event clock are separately declared in the V4 packet, `RUNTIME_MAPPING_PENDING`.

## G1 source/style reference
Owner wants JX/Kiếm Thế feeling: pure saturated luminous gold + ivory-hot core, strong quick contact, readable actor, restrained ongoing buff. External JX pixels are only for visual study and are **not** included. Source hero from this conversation is independent first-party. Two incorrectly generated poster boards featuring different fictional skill IDs were **rejected** and are not production assets.

## G3–G5 technical contract and evidence
- Original source: 3 encoded RGBA masters (two 512px original raster painted, one 646×185 cropped first-party generated gold dragon detail); generator `tools/vfx/generate_fist08_phan_chan_quyen.py`.
- Atlas: 8×320 cast (1280×640); 8×192 sustain (768×384); 10×256 contact (1024×768): **26 poses, 3 textures, 7,602,176 raw RGBA bytes = 7.25 MiB**. This is raw source pixels, NOT measured Android texture residency.
- Godot isolated LAB: `godot/labs/combat_lab/fist08/phan_chan_quyen.tscn`, view only. MOVING target via approved unchanged frame-by-frame WALK. No rig.
- V4 G3.5 mini proof genuine Godot native 1280×720 `v4-charge.png` .30, `v4-peak.png` .59, `v4-contact.png` 1.34 and exact SHA evidence manifest. After manual STOP art gate, full movie review >12 checkpoints, dark/bright terrain and occlusion checks.

## Current approval boundary
R1 is **not** owner-approved, ART_SELF_QA_PENDING until actual Godot footage reviewed, PVE_INTEGRATION_HOLD, Android device pending. No Combat V2, damage, status mutations, SaveService, AI, merge, new branch, rig or Codex.
\n## R2: 1× Godot R1 manual review and correction (2026-11-16)\n- R1 exact SHA `4fea05b537ec8a46f79605365da0df9f088103bf`, Actions #43810074259, V4 PACKET/ASSET/3 NATIVE PREVIEW/FULL MP4 and focused Godot PASS. Native 16 checkpoint montage exposed artistic failure: faint thin amber cast, guarded-hit weak thin scratches and indistinct quiet status.\n- **R2** offline grades true source-paint luminance/alpha towards saturated gold with hot ivory center and overlays a tiny baked white-hot local contact. Slightly enlarges contact while leaving the protected actor readable. Sustained mark is brighter but **still compact**; no cast dragon for four seconds. Three atlases/26 poses and 7.25 MiB unchanged, no new runtime node/draw call. V4 focused exact-SHA to rerun; owner art PENDING and no PvE.\n

## R2 exact-SHA native Godot QA and manual art review — 16/11/2026
- **Code/asset SHA:** fa63283a74b35b5eb3f39fcdd8d552ae07b043a4; [GitHub Actions #43810603937](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43810603937) completed SUCCESS. Artifact vfx-fist08-r1-native ID 14199544974; the artifact name is historical R1, the tested SHA and scene revision are R2.
- Godot 4.7.2.stable.official.ed1daf0bf strict import/parse, V4 catalog packet and 26-pose alpha sources, focused VFX_FIST08_FOCUSED_RESULT=PASS failures=0, G3.5 actual 1280×720 charge/peak/moving-protected-contact at 0.30/0.59/1.34, V4_MANIFEST.json, 315-frame 1280×720 full video, 16 screenshots, GIF. Fixed-clock video 60fps NOT Android device FPS.
- **Actual native 1× film inspection:** R1→R2 gold channels/short original painted dragon at 0.30–0.52 brighter. The compact guard sign remains around the protector at 0.90–4.21; guarded hit at 1.34 and 3.17 stronger and follows protected WALK actor rather than damaging other dummy; 5.01 clears.
- **Honest self art rubric /5:** silhouette 3.2, material/light 3.5, motion 3.1, composition 3.5, contact 3.3, fade 4.1, distinctiveness 3.3, readability 3.7. BELOW >=4/5 art gate: still arc-like, some bronze rather than white-hot gold, guarded-hit less substantial than owner benchmark. No automatic owner approval despite GitHub technical PASS.
- 26 poses, 3 atlases, 7,602,176 bytes (7.25 MiB) raw RGBA. Original first-party art sources permanently retained as base64 first-party raster + assistant-generated concept gold crop (not commercial JX pixels). No outgoing hit, status/HP write, PvE/AI/SaveService edit, or rig.
- **Separate previous-skill art debt:** Owner accepts FIST07 Kim Cang Ho The R6 provisionally, with guarded-hit reaction weak and 4s ongoing sign unclear; do not modify it without new owner request. Owner permission to move to FIST08 is not explicit FIST08 owner art approval.
- Gates: CODE_LAB_READY, V4_PACKET_ASSETS_PASS, G3.5_TECH_PASS, GODOT_FOCUSED_PASS, GODOT_FULL_CAPTURED, FRAMES_REVIEWED; ART_REWORK_REQUIRED / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / ANDROID_DEVICE_PENDING.
