# PAF01 Phong Giới Truy Dấu R3 — actual Godot VFX / pending art owner review

**Day:** 16 November 2026. **Repo:** `vuanhtuan161094-byte/TongMonBaDao`, **PR #72 Draft**, branch `integration/pve-p0-playable-ui-20261103`. New isolated **`talisman11`** Combat Lab. Previous HF05 R7 was explicitly accepted only provisionally; no art-final inference.

## Canonical skill contract (G0, no invented VFX mechanics)

- Exact ID `tmb.skill.talisman.phong_an_phu.active_01.human`; name **Phong Giới Truy Dấu**, `wind` element, `mark` effect, `single_target`, `target_limit=1`, `hit_count=1` as catalogue mark application (NOT a damage hit), `range=8.5`, `radius=0`, `cast_time=0.5`, `cooldown=9.4`, `projectile_speed=0`, `duration=6.0`, `damage_ratio=0.72` read-only, no real application. **Do not reinterpret a mark as burst/DoT/AoE or a gameplay projectile.**
- Film and movement are LAB-ONLY. User has not authorized enabling V6.3 or PvE, altering Combat V2/SaveService/AI/HP, adding shots or merging.
- **Three separate clocks:** real catalogue cast 0.5s, actual Combat V2 mark receipt `RUNTIME_MAPPING_PENDING` and status6s; visual-only charge .02-.60, cosmetic wind transfer .51-1.12, simulated arrival **1.15**, marks ONE genuinely moving WALK enemy **1.15–7.15** (six simulated seconds, separate from casting), soft alpha fade 7.15–7.51; fixed **8.00s** video loop is neither cooldown nor engine/device performance.

## Source-art lineage / limitations

- Reproducible permanently committed source recipe: `tools/vfx/paf01_r1_wind_mark.py`. It authors original cyan-ivory-gold `風` main scroll (480×560 RGBA) and separate mark master (420×420 RGBA) with custom paint-stroke wind material in Pillow, **using only the first-party original in-repo talisman pigment** `talisman06/art_sources/hf01_r5_talisman_master_png.b64`; system-installed Noto Serif CJK font only for glyph rendering, not distributed. Four distinct regenerated atlas animations: **12 charge ×320×320**, **16 moving wind transfer ×512×256**, **12 non-damaging arrival ×256×256**, **20 persistent floating wind rune ×256×256**. The 480×560 and 420×420 original source masters are generated and included in evidence archives, while source recipe and underlying first-party paper remain durable in GitHub. There is **no separate hand-painted illustrative wind painting** beyond this original code-painted raster recipe; owner should know this aesthetic limitation.
- A generated **HF06 fire-dragon/AoE promotional poster** was incorrectly produced during setup; it is **INVALID ART for this skill and expressly excluded** from source, atlas, screenshot, gameplay and QA. No commercial Source A/JX/Võ Lâm art imported.
- R1 visually thin/needle-like tracer at true 1280×720. R2 enlarged the actual mark and carried one `風` scroll along brighter cyan tracer. R3 replaced too many regular noodle-like strands with ONE irregular wide living wind fan plus a single authentic source-painted optical scroll, preserving the six-second target mark and all first-party masters. No rig, no color-swap mass production. No gameplay or source approved HF02/HF03/HF04/HF05 assets modified.

## Real exact-SHA Godot 4.7.2 engine evidence

Both jobs ran from **identical art/source SHA `02ab55a3e5bffb368e402e91a5206f385ac27dc8`**, strict Godot 4.7.2 Compatibility, no downstream art/source changes in later documentation-only commits.

1. **V4 G3.5 three genuine screenshots:** [Actions #43822501594](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43822501594), **SUCCESS**, source+atlas/provenance schema, strict import/parse, focused actual WALK contract, 125-frame native 1280×720 MP4, charge at **0.30s**, peak at **0.84s**, non-damaging contact/mark at **1.28s**, manifest SHA and fail-closed missing-contact proof. Artifact ID `14204574286`.
2. **Full genuine movie:** [Actions #43822501556](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43822501556), **SUCCESS**, artifact ID `14204928624`. Native Godot 1280×720 MP4 with **480 frames / fixed 60fps / 8.00 seconds**, MP4 SHA256 `39f84ebfe3e890c477d243eb17e4d53177a06865af4d8fab0e59f69f1d68c008`, GIF, four RGBA atlases, both generated original masters, focused QA and 15 timed PNG screenshots. `VFX_TAL11_FOCUSED_RESULT=PASS failures=0`: one moving target, mark duration exactly six simulated seconds, no projectile, no real damage/status write.
3. The 15 native full movie snapshots reviewed: **0.16, 0.30, 0.54, 0.84, 1.13, 1.28, 1.46, 2.20, 3.15, 4.22, 5.25, 6.22, 7.02, 7.30, 7.64 seconds**. Inspect at 1× shows cyan-gold paper at caster hand, one bright wind source→target transfer containing a visible real scroll, one small target imprint, `風` sigil remains above the genuine moving monster until its six-second mark expiry and fades cleanly. Actor remains legible throughout. No unintended black matte visible on sampled frames.

## G6 honest self visual review / open concerns

- **R1** rejected internally because wind was too thread-like and hard to read.
- **R2** rejected as a final visual due to parallel sine-like neon strands; marked paper and target glyph were kept.
- **R3** actual native 1× review: source icon legibility **4/5**; pure cyan/gold material **4/5**; mark tracking **4.5/5**; motion continuity **4/5**; contact readability **4/5**; clean fade **4/5**; unique wind motif **4/5**; bright-terrain comparison **NOT_EXECUTED** and physical device FPS **NOT_MEASURED**. These are subjective internal observations; **not an owner's art approval**. The art remains somewhat graphic rather than a high-detail fully painted cinematic effect; owner may request a new original illustrated master before approval.

## Scope and independent gates

`PAF01_R3_SOURCE_RECIPE_COMMITTED / V4_G3_5_TECH_PASS / GODOT472_FULL_NATIVE_480_FRAME_TECH_PASS / OWNER_VISUAL_PENDING / V63_OFF / RUNTIME_MARK_MAPPING_PENDING / PVE_INTEGRATION_HOLD / WINDOWS_ANDROID_PHYSICAL_QA_PENDING`.

Original source/generator is durable; GitHub Actions artwork archives have retention policy and are not permanent. **No Codex, rig, branch, merge, gameplay, combat, SaveService or PvE edits.**
