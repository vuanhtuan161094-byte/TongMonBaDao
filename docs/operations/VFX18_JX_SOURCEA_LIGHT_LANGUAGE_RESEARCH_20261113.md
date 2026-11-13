# VFX18-R0 — JX / Source VL / Source A skill visual-language audit (RESEARCH ONLY)
Date: 2026-11-13 · Repo: Tông Môn Bá Đạo · PR #72 · Source HEAD before report: `e70e9a9708274ac18c815457a4e7b6399ce25ae8`.

**Scope**: read-only visual and source research plus this standalone document; DO NOT change Combat Lab renderers, gameplay, numeric combat, targeting, SaveService or PvE integration before the next art-directed implementation gate. ART_Direction proposed, **OWNER_VISUAL_PENDING**. No new branch or merge.

## 1. Critical distinction: "Light-first" does NOT mean "no image files"

The owner supplied a screenshot of a blue orbiting sword-qi array around an actor on a grey ground. Visible observations only: roughly concentric rotating arrangement of many tapered azure-white streaks, varied size/angle/brightness, broad weak diffuse blue circular atmosphere on the ground, clear central character, readable motion implied by tangential orientation. A still frame cannot prove actual rotation speed, shader, implementation or source asset type.

Legacy JX/Chinese Wuxia sources frequently use **pre-rendered translucent sprite sequences** plus brightness/compositing rules. The visual target is luminous light, regardless of whether underlying geometry is shader-generated or sprite-driven. Avoid incorrectly claiming "all JX effects use code and no images". Own Godot V9 luminous serpent is code-formed, but that is merely one technique.

## 2. Source inventory on the ACTUAL PR #72 HEAD

### 2a. JX1 owner-provided 2D sprites (already in repository)
`godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json`.
- Wudang #158: `jx_wudang_158_precast`, `3dfcabc2.webp`, **10 frames at 50ms = 500ms**.
- Wudang #158: `jx_wudang_158_cast`, `aa93d577.webp`, **17 frames at 50ms = 850ms**.
- Wudang #158: `jx_wudang_158_impact`, `361b4525.webp`, **8 frames at 40ms = 320ms**.
- Wudu #63: `jx_wudu_63_impact`, `1fffed7e.webp`, **13 frames at 56ms = 728ms**.
- Emei #93: `jx_emei_93_precast`, `2f8c6d50.webp`, **5 frames at 60ms = 300ms**.
- Seven WebP source sheets physically in the repo directory; two others (`40a1c4ff.webp`, `e8178d06.webp`) do not have entries in this five-effect manifest and MUST NOT be labeled as verified skills.
- The Wudang three-sheet sequence has 35 documented frame rectangles/anchors and SHA-256 provenance; see `docs/handoffs/2026-10-27/TMB_PVE_AUX03_VFX_PROVENANCE_AND_EVENT_QA_2026-10-27.md`. Durations are **each independent sequence length**, NOT proof of actual live cast clock, overlap, or chained runtime playback.
- Existing `godot/src/presentation/p3/pve_jx_sword_vfx_adapter_v1.gd` consumes Combat V2 event journal; this source read is a reference for presentation ownership, not approval to alter it.

### 2b. Source VL sword sheets (separate from JX1 #158)
`godot/assets/combat_v4/source_vl/vfx_manifest.json`:
- `sword_cast` = `wd_150_jianchuixinghe_a.webp`, **36 frames × 30ms = 1080ms**, `blend="lighter"`.
- `sword_hit` = `wd_150_jianchuixinghe_d.webp`, **21 frames × 30ms = 630ms**, `blend="lighter"`.
- Strongest *available local light-compositing* reference: analyze sprite progression, silhouette and fade **in an isolated preview, not by copying proprietary pixels**. Do not treat Source VL and Source A as the same source.

### 2c. Source A (Unity extraction from `E:\GameAssetExtract`)
Known archived metadata (not re-opened from current E: drive): `godot/data/presentation/pve_aux03_vfx_asset_manifest_v1.json` and the AUX-03 handoff.
- `1113101_Skill_TX`: candidate cast clip, **~0.567s**, 30fps, 9 streamed curves.
- `feijian`: candidate flying sword, **~0.467s**, 30fps, 10 dense curves.
- `feijian_TX`: another flying FX/transform clip **~0.467s**, 30fps, 12 dense curves.
- `1113101_hit_TX`: candidate hit **~0.267s**, 30fps, 3 streamed curves.
- `yujianshu_hit/Pattern_003_Q_white...`: ONE 256×256 grayscale ornamental texture, not a verified finished hit animation.
- `Jian_Hei`, `Jian_JIn`, `Jian_JIn2`: static textures possibly for sword mesh/material; actual prefab/material/particle connections NOT VERIFIED.
- **NOT VERIFIED**: Unity prefab linkage, material/shader, emission, transform pivot, actual appearance, live skill-ID binding, proof that candidate clips form a single skill. No Source A skill-fx textures or full Unity effect hierarchies are imported as production-ready files under `godot/assets/combat_v5_source_a/` (that directory contains only an *actor* visual manifest).
- `vuanhtuan161094-byte/ZQZS-Source-Knowledge` private catalog covers extracted *text* and metadata, NOT packed PNG / Unity textures / Unity bundles. `SOURCE_CATALOG.md` and `SOURCE_EVIDENCE_POLICY.md` explicitly exclude art binaries and forbid treating inferred connection as verified. Merely searching a filename is not sufficient.

### 2d. JXQY2 *offline* source (NOT JX1 online or Source A)
`Upwinded/jxqy2-assets` is separately catalogued in `godot/data/combat/jxqy2_slice_v1.json` at commit `8ffc1ecd1b50742ac619bf74684f70b9850c2af3`.
Sample source INI (inspect actual named files; **no source code copied into Godot**):
- `ini/magic/player-magic-天意剑诀.ini` declares `alphablend=1`, `flyinglum=16`, `vanishlum=24`, distinct `flyingimage` and `vanishimage`.
- `ini/magic/player-magic-天师符法.ini` references blue-white lightning as a flying effect.
- `ini/magic/player-magic-烈火情天.ini` declares flying/vanish/supermode image stages and a linked action/attack file.
- `ini/magic/player-magic-寒霜掌.ini` uses a blue-white worm-like effect plus violet-white explosion (name does not prove the exact visual).
- `ini/magic/player-magic-花飞蝶舞剑.ini` uses a violet-white vortex plus separate impact.
- `ini/magic/player-magic-金刚不坏神功.ini` declares longer persistent shield-like life without vanish image.
- `ini/magic/player-magic-风雪狂刀.ini` has no flyingimage but a white explosion, `alphablend=0`.
- `ini/magic/player-magic-无影神针.ini` has a flying needle and no mandatory vanish image.
- The public JXQY2 assets repository does **NOT expose a redistributable LICENSE file in its root**. Source availability does not confer ownership or commercial-use rights. These INI values demonstrate design-stage separation, not an engine implementation guarantee.

## 3. External gameplay visual evidence (what still images CAN show)
- Owner screenshot: circulating blade-light rings, transparent center and 2D ground atmosphere; cannot deduce exact engine tech from one image.
- VLTK 1 Mobile official Wudang sword skill descriptions: `https://volamm.vnggames.com/tuyet-hoc/vo-dang/he-thong-chieu-thuc-vo-dang-kiem-phap.html`. Sword fan, sword rain, triple attack are mechanically distinct; don't assume one VFX can be reused unchanged for all three.
- Ngũ Độc gameplay screenshot from official VNG: `https://volamm.vnggames.com/tuyet-hoc/ngu-doc/gioi-thieu-tong-quan-mon-phai-ngu-doc.html` shows a bounded green poison region. Suggests readable poison area; cannot claim particle shader from still.
- KT Origin Thuý Yên gameplay screenshot `https://vi.ldplayer.net/blog/1010.html`: multi-ring aqua/water attack; source visual cues are overlapping translucent curves with clear target area.
- KT Origin Thiên Nhẫn gameplay screenshot `https://vi.ldplayer.net/blog/1000.html`: flowing orange fire AoE and grounded length instead of uniform glow disk.
- JX3 quest screenshot `https://ol.3dmgame.com/gl/76281.html`: sword rain vertical composition; quest animation, not proof it is a particular player skill.
- Wuxia flying slash screenshot `https://gnn.gamer.com.tw/detail.php?sn=113955`: strong single curved luminous slash and clear actor silhouette, from 九陰真經 (NOT JX3).

Photographs and footage from other games are REFERENCE ONLY; no copyrighted sprite, UI, code or distinctive finished visual is to be redistributed as own game art.

## 4. Visual-language families to build for Tông Môn (distinct families, not color-swaps)
| priority | Master family | Reference and grounded motif | What the player should perceive | Own Godot Compatibility proposal |
| --- | --- | --- | --- | --- |
| P0 | **Luminous sword arc / Kiếm khí** | owner reference, VLTK sword fan, Source VL 'lighter' sword cast | razor-thin sharp hot tip, flowing light tail, directional follow-through, NOT metal weapon | SDF soft luminous blade profile + short core ribbon + taper, no solid-color opaque polygons |
| P0 | **Rotating sword array / Kiếm trận** | owner screenshot: many directional light streaks around a readable center | tangential velocity, 2 orbit depths, breathing halo, transparent caster center | deterministic precomputed orbit paths; layered core/halo and ground atmosphere |
| P0 | **Short contact burst** | JX1 #158 separate impact; JXQY2 flying/vanish image distinction | clear exact hit and fast energy breakup, no giant blinding flash | single impact hotspot, directional sparks, decay independent from projectile |
| P0 | **Chain lightning / Thiên Lôi** | JXQY2 lightning sample, current TMB V9/owner praised lightning | branched bright white core, cyan/violet sleeve, unpredictable fractal silhouette | existing original procedural spline branching; cap branch count by LOD |
| P1 | **Venom-serpent / Cổ độc** | VLTK Ngũ Độc green field, existing TMB V9 serpent and Poison V4 | living green flow, brief bite/impact, weak DoT overlay only on real status | dynamic spine ribbon + softened cloud; never fake an extra poison tick |
| P1 | **Fire plume / Liệt Hỏa** | JXQY2 flying and supermode stages; KT Thiên Nhẫn flame screenshot | rising turbulent tongues of flame; ember tail; contact burst and bounded ground heat | gradient turbulence ribbon + pooled sparks; orange/yellow hot-core, low alpha smoke |
| P1 | **Frost / Hàn Băng** | KT icy/water AoE and VLTK Mobile frozen spikes screenshot | crisp growing icicles + thin frost mist + impact shatter | ice-silhouette geometry only where the effect literally crystallizes; soft light for cold aura |
| P1 | **Water rings / Thủy Pháp** | KT Origin Thuý Yên screenshot concentric water waves | multiple expanding ripples with gaps and amplitude differences | distorted ribbon rings, layered alpha, very light foam/sparks |
| P1 | **Blade wind / Phong nhận** | JXQY2 white/violet vortex family and Wind-sword motifs | transparent fluid shear with thin moving white edges, visible attack vector | short warped ribbons, 2D vortical displacement, no huge constant circles |
| P1 | **Guardian aura / Hộ thể** | JXQY2 金刚不坏 persistent shield | quiet persistent aura, a punctuated bright rim only on actual block | light ring + occasional thin intercept arc on confirmed guard/absorb |
| P2 | **Talisman / Phù** | source JX 天师符法 and TMB V6.3 talisman school | thin symbol strokes, brief discharge, distinct from merely a circle | self-authored glyph strokes + branching energy, no copied seal textures |
| P2 | **Healing / Cleansing** | existing TMB jade lotus, V63 real heal/cleanse events | upward soft motes, non-damaging green-white pulse | sparse additive trails only on real healing/cleanse event |
| P2 | **Earth & metal / Thổ Kim** | thematic complement to light language | earth crack/dust or hard metallic pierce/reflect | physical base geometry where materially necessary; light as accent, NOT all-light world |
| P2 | **Summon / Triệu Hồi** | Source A Unity clip structure as animation design reference only, V63 S9 school | formation seal opens, actor manifests; no fake summon if actor didn't spawn | short portal/formation + real spawn event + light fade, zero gameplay ownership |

## 5. Why VFX14 / Research01 A-B / VFX17 are inferior at 1x
1. Current VFX17 still renders `combat_lab_v14_sword_fx.gd::_qi_blade`: a literal steel weapon with guard/hilt/rune polygons; the user wants energy-only *for sword-qi abilities*. Separate these from literal summoned flying-sword skills.
2. Research01 A/B sampled bright edges as flat colored polygons and lines with hard cutoffs, not continuous falloff. More lines/shader brightness worsens the plastic/artificial look.
3. Nine similarly sized swords competing for visual priority, empty charge/readable middle and weakened physical contact, combined with simplified grey-grid mockup background and blocky actors.
4. Repeating skill effect composition identically across waves is perceived as replaying a loop. Professional effects change spacing, power, and silhouette with time.
5. Old standalone Combat Lab on basic background does not reveal interactions with real Source A actor pixels/background contrast or 30 disciples / 40 active monsters. Existing actual Godot 1280×720 Research02 QA `#43382287589` PASS proves functional rendering only, NOT acceptance of art quality.
6. NOT ALL FX should be light: literal summoned sword, ice crystal, rock debris, earth cracks and characters require believable material silhouettes; only their energy accents must glow.

## 6. Technical design for Godot 4.7.2 GL Compatibility (research architecture, NOT code yet)
- Project config `godot/project.godot`: `renderer/rendering_method="gl_compatibility"` and mobile also Compatibility, screen 1280x720.
- Native CanvasItem supports `blend_add` and `blend_mix`; `draw_*()` can set geometry. **Avoid relying on 2D HDR/Forward+ bloom or HDR screen output**: Godot 4.7 docs note the Compatibility path has different limited glow controls; full HDR output is not supported in Compatibility.
- Proposed LightCore2D lab prototype: original 1D tapered light-distance profile evaluated in CanvasItem shader, layered hot core + soft per-pixel falloff, short procedurally updated motion spine and 1-2 associated trails, no external texture required. A polygon is just shader canvas geometry, not an opaque fake material shape.
- Separate `LightTravel`, `LightContact`, `LightGroundField`, and bounded `LightStatus` compositors. No global add blending for dark physical character/weapon sprite. Per-effect draw layer behind/above actor intentionally.
- Performance: fixed budgets, shared materials, effects pooled, far/near LOD, no unbounded particles, no per-actor full-screen expensive shader or full-canvas blur. Must profile 6v8 then 30v40, Android physical PENDING USER. Don't infer FPS from fixed-fps offline MP4.
- Event source: Combat V2/Mapped V63 authoritative actual `skill_cast`, `hit`, `status_applied`, `heal`, `absorb`, `summon_created`. No invented damage/target/count/DoT. No repeated animation on snapshot replay; preserve Save and combat.
- First required **black-background diagnostic**: white-to-cyan tapered luminous sword-qi with feathered edges and hot tip; then **real Source A scene comparison**, then only multiple-knife orbit mode and crowd test. A nice static frame is not enough; record charge/flight/contact/fade and compare at same time.
- Build two ONE-stroke Godot prototypes before 9 swords: (1) core/trail gradient geometry, (2) shader procedural SDF-distance-profile. Choose visually, not by shader count.

## 7. Permission and audit gates
- Historical Source A user-authorized extraction/internals ≠ license to redistribute; candidate manifests mark rights as unverified. Restrict study to authorized local research until a specific license/permission allows packaging.
- JXQY2 repo has public downloadable files but no redistributable LICENSE observed; JX1/Source VL sheets contain commercial art; **do not ship them** without license.
- Separate verified source fact / inferred aesthetic lesson / planned original technique / tested output / owner art approval.
- **THIS ROUND**: RESEARCH ONLY; no VFX renderer/scene, Combat V2, HP, target selection, Source A extraction, or production assets changed.
- Proposed next LAB gate *after this research is accepted*: new `VFX18_LightCore` 1280×720 isolated comparison, 1 light-sword projectile and 1 orbit array, 4 controlled screenshots each, 60fps fixed output, no production integration; rerender real 1x and compare against screenshot user's bright orbit.
