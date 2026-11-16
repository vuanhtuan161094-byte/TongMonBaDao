# HF05 Vạn Phù Phần Thiên — R7 ending-only remake (16 Nov 2026)

**Owner feedback:** After viewing the genuine HF05 R5 Godot 1280×720 clip, owner explicitly stated: **"chưa ok lắm. đoạn cuối nên làm ntn khác đi."** Owner does **not** approve R5's finale. Keep R5 charge / animated seals / falling papers intact; remake **only** the visual ending. Do not silently mark an art PASS.

## What actual R5/R6/R7 native captures show

- **R5** (reviewed): roughly 1.86–2.08 showed an oversized glowing paper seal above the moving monsters followed by dull low fire strips; at ~2.18 the fire and big card had disappeared almost completely, making the ultimate lose its sense of impact. Prior R5 technical success never meant owner's final artistic approval.
- **R6** (self-rejected, actual source R6 SHA `fb274eff9c2bf6b5f93db4253bcce43280d5e18a`): attempted a multi-petal painterly fire lotus, but at native Godot 1× its flame strips formed a generic orange ring around enemies. **`ART_REJECTED_INTERNAL_DO_NOT_USE`**, despite complete V4 and native movie technical PASS.
- **R7** (current visual candidate): the illustrated giant 炎 paper drops/compresses into the one legal circle hit. A first-party **gold-white central solar flame column** rises, asymmetric broad flame wings spread left/right (NO 360° HUD rings), and irregular original painted ember fragments lift and fade. The source alpha is animated frame-by-frame using 20 distinct 640×400 source-painted key-composition cells with adjacent-cell blending at 60fps, **no rig**.
- Actual same-scale R5/R7 movie comparisons at **2.02, 2.18, 2.38 seconds** confirm R5 fades out early while R7 has a strong center plume and side wings through 2.38; the fade begins ~2.48 and is clean by 2.74. This is a **human visual self-review**, not owner art approval or a physically measured device-fps claim.

## Exact-SHA Godot technical evidence

- **G3.5 V4 true native 1× 1280×720 frames:** [Actions #43817376464](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43817376464), **SUCCESS**, exact SHA `4b7dbb701c1a85de60981d56ddd23bbc9229f12c`, charge at **0.52**, paper-rain peak at **1.44**, one-circle contact on 3 moving WALK actors at **1.96**, strict Godot import+parse+focused test, fail-closed missing-contact and original source/atlas manifest. Full preflight and source hashes in artifact `14202762972`.
- **Full genuine Godot native movie and atlas proof:** [Actions #43817381240](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43817381240), **SUCCESS**, exact SHA `6d698fc845245a1116b5af71edbb39d05552d5ed`, artifact `14202792371`, Godot **4.7.2 Compatibility** native **1280×720, 201 frames, fixed 60fps (3.35 s)**, MP4 SHA256 `becfc3cd28733e4a32f20ea03216483e846f8fe7f5585aee0d286d5beb3d5a50`. Includes video GIF, 15 evidence frames, five RGBA atlas layers and source SHA manifest. The full movie checkout SHA differs from G3.5 only by separate CI workflow edits, while same R7 source master/scene/contract generator is used by both; each job is exact-SHA checked independently.
- 10 additional actual video checkpoint frames reviewed at **1.65, 1.82, 1.92, 2.02, 2.12, 2.22, 2.35, 2.48, 2.63, 2.76**; comparison to real R5 same stage at **2.02, 2.18, 2.38**. These are **Godot captures**, not promotional illustration or generated screenshots.

## Source master, original art and animation truth

- Independent final-only generator: `tools/vfx/hf05_r7_solar_pillar.py`.
- First-party art: the original painted flame `godot/labs/combat_lab/talisman07/art_sources/hf02_r5_owner_fire_blast.webp.b64` derived for this project, alpha-unmatted by `tools/vfx/hf02_r5_source_painted.py`. Base HF05 illustrated 96×132 炎 paper master still separately durable at `godot/labs/combat_lab/talisman10/art_sources/hf05_original_van_phu_hero_master_rgba.webp.b64`.
- Original VFX layers unchanged: `tal10_r1_charge.webp` (16), `tal10_r1_storm.webp` (24), `tal10_r1_rain.webp` (20), and historical `tal10_r1_impact.webp` (12, kept for proof but visually replaced in the new ending). **New:** `tal10_r7_solar_pillar.webp` (20 cells × 640×400, 4×5 alpha atlas). The 20 poses are uniquely re-composed first-party painted pixels, **not** handpainted new 20 independent high-resolution assets. Source code/master remains in Git; CI baked binary atlases are downloadable artifacts with 30-day retention.
- The video fixed 60fps is a recording setting, not a measured Android/Windows performance result. Video frames show at most 3 moving WALK actors with faces legible and only one bounded source-painted fire response.

## No gameplay scope or extra hit

**Canonical contract unchanged**: `tmb.skill.talisman.hoa_phu.ultimate.human`, FIRE damage circle, `target_limit=3`, `hit_count=1`, `radius=2.8`, `range=9.5`, cast **1.05s**, cooldown **23s**, `projectile_speed=0`, status duration **0**, damage ratio **1.58** (read-only). Cosmetic moving scrolls/pillar do not create real projectile, burn, post-hit persistent zone, damage events or repeated hits.

**Three clocks:** catalogue cast/cooldown and unknown real Combat V2 hit receipt; LAB-only charge/storm/rain/one visual circle hit at 1.85 followed by solar pillar ~1.80–2.74; separate QA movie loop 3.35s. The LAB's 1.85 second simulated contact is NOT a confirmed real receipt. `RUNTIME_MAPPING_PENDING`.

**Final status:** `HF05_R7_SOURCE_COMMITTED / V4_G3_5_TECH_PASS / FULL_NATIVE_GODOT472_201FRAME_TECH_PASS / R6_RING_ART_REJECTED / OWNER_R7_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_ANDROID_WINDOWS_QA_PENDING`.

No Codex, no rig, no new branch, no merge, no SaveService, Combat V2, economy, targeting, AI or playable PvE changes.
