# POI16 – Vạn Linh Giải Ách R1 — Dược Độc Nhân giới ultimate

17 November 2026. **Owner approved POI15 Hóa Độc Tán R1B as visually beautiful. Freeze that exact asset and use its color-pure, organic, translucent green-jade/light material as a reference standard, not as source pixels for this ultimate.** This is the next full cast after 4 active Dược Độc Human skills. Innate/passives are proc-only and must not be fabricated as full cast skills.

## G0 canonical contract — exact
`tmb.skill.poison.duoc_doc.ultimate.human`, `effect=heal`, `element=wood`, `shape=circle`, radius **2.5 world units**, max **3 allied targets**, range6.5, cast1.2s, cooldown46s, projectile speed0, duration0, power0.16. Numerical `damage_ratio=0.05` is original catalogue metadata, not real heal receipt. The catalogue does not specify a hit_count. No poison status, fake heals, heal numbers, periodic HP regen, ward, cleanse, enemy hit, Combat V2 mutation or PvE enablement.

## Independent original luminous 38-pose soft RGB-alpha art
- Source generator: `tools/vfx/generate_poi16_van_linh_giai_ach_r1.py`. All four original RGBA sprite-sheet atlases and four preserved 1x masters: `godot/labs/combat_lab/poison16_van_linh_giai_ach/r1/assets`.
- Phase1 charge: 8×192x192 key poses, jade-white life pearl accumulates above caster palm during canonical 1.2s cast, fine filaments and sparse muted gold highlights.
- Phase2 area bloom: 12×384x320 key poses, a **broad, threefold asymmetrical bright life-flower in flowing light** with an opening irregular teal-jade/pearl wave; no opaque sticker, UI ring, poster or hard icon.
- Phase3 blessing: 10×192x192 key poses, three separate *moving friendly* disciples get soft luminous emerald/ivory fountains with gold light grains, layered behind and in front of frozen original approved 2D actor sprite, not a POI13 leaf.
- Phase4 fade: 8×256x224 key poses, micro-motes gently rise and stop; no lingering state.
- All materials use saturated RGB while alpha stays genuinely soft and translucent. MOVING WALK monster in scene never healed. A fourth friendly character outside LAB area must never receive healing visual. No rig, GIF, external game artwork pixels or unapproved actor.

## Three independent timing clocks
Combat: cast1.20, cooldown46, no projectile, duration0; **no actual Combat V2 heals**. LAB: charge [0,1.20), bloom ~1.20-2.04, imaginary simultaneous heal at **1.75**, 3 ally blessing from 1.45-2.19, fade2.04-2.65, idle2.65-2.95. One common AOE root; three cosmetic target anchors. 205 screen pixels for LAB fixture NOT a scale mapping for world radius2.5.

Real 1280×720 Godot 4.7.2 native 177-frame MP4 (2.95 seconds @60fps encoded), charge screenshot0.62, bloom1.48, 3-ally contact1.92, fade2.42, idle2.80. 38 authored key poses ≠ 177 video frames ≠ physical Android FPS. Focused QA asserts three inside-fourth outside, moving actors, zero invented states. V4 packet, source/color alpha import, strict Godot and exact-SHA evidence mandatory.

**Initial QA gates:** `G3.5_NATIVE_NOT_YET_EXECUTED`, `TECH_PENDING`, `ART_SELF_REVIEW_REQUIRED`, `OWNER_VISUAL_PENDING`, `RUNTIME_MAPPING_PENDING`, `PVE_INTEGRATION_HOLD`, `V6.3_OFF`, `PHYSICAL_QA_PENDING`. No Codex, new branch or merge. Owner approval from POI15 does NOT carry over to POI16.


## ART CORRECTIVE ACTION — R1B OWNER REJECTED 17/11/2026

Owner explicitly stated **“làm rõ hơn các hiệu ứng. mờ quá rồi. k thấy gì luôn. xem lại quy trình làm vfx”** after reviewing genuine R1B Godot footage. This overrides previous internal self-QA positive notes. **R1B ART REWORK REQUIRED**. No “owner accepted” or “art PASS” may be inferred from Godot technical PASS.

### Root-cause evidence from exact native R1B
Source \`e876d605416f0e200be1d2eed30135c855ee637d\`; QA Actions #44002926808 (TECH PASS) and same SHA frame captures.
- Median nonzero sprite alpha / 255: charge 8, bloom 20, blessing 9; despite very bright RGB source values and valid transparency, the rendered pixel weights averaged far too small.
- Bright jade pixels at actual native-resolution ROI: charge ~79; bloom peak ~7,747; contact ~7,539; expired background ~91. Charge was effectively invisible and complex 3fold bloom was not readable at 1×.
- Layer/temporal alpha multiplies the already-low source alpha, while interpolation and background/character composition further attenuate contrast. Source alpha-check only saw *some* translucent pixels, not effective chromatic contrast. Full-frame screenshot overviews had encouraged passing a weak effect.

### R1C corrective implementation
1. **Rebuild first-party alpha material hierarchy** for all 38 authored RGBA poses using the existing generator (source original R1B retrievable at prior SHA): sharp ivory hot nucleus; medium-opacity jade/aqua luminous paths; genuinely translucent exterior. Independently shaped 3fold life-streams and visible pulse on three moving allied targets; do not add hard ring/UI graphics.
2. Increase Godot world-screen sprite geometry/visibility of palm, threefold bloom, translucent 3-ally blessing and dissolving motes. Original frozen actors and target cap/clip/Combat V2 unchanged; no rig/GIF.
3. Add **G3.6 quantitative visibility STOP gate** \`tools/qa/check_poi16_native_visibility.py\` to real native Godot 1280×720 screenshot flow, in addition to V4 alpha/provenance/motion/contract checks. Thresholds for charge/peak/contact/fade are specific to POI16 color and screenshots; expiry image must return to background. Any threshold violation FAILS CI. Passing is not equivalent to art acceptance or accessibility for all color-vision types.
4. Before owner review, self-check native size 1× (not zoom-only), contrast both dark and bright scene, moving targets and alpha material separation, distinct contact and fade. Optional 6v8/30-disciple crowd + physical Android QA remain separate HOLD, never claimed executed without proof.

Status: \`R1B_OWNER_ART_REJECTED_INVISIBLE\` → \`R1C_REWORK_IN_PROGRESS\`, pending new exact-SHA technical G3.5/G3.6 evidence and later human owner visual review; \`V6.3_OFF\`, \`PVE_INTEGRATION_HOLD\`, \`PHYSICAL_QA_PENDING\`. Do not move to next skill until owner direction.


### R1C native G3.6 STOP and R1D correction (17/11/2026)

True native Godot 1280×720 source SHA `99ce4a4300b795b9d22871b0b9e06a9ad4b204ba`, Actions #44014452070: focused Godot/V4 technical PASS; **G3.6 VISIBILITY FAIL** with unedited charge **3,884** (minimum 300), peak **55,726** (minimum13,000), contact **45,746** (minimum14,500), fade **303** (minimum500), expired **105** (maximum200). R1B baseline charge79/peak7747/contact7539. This demonstrates a truthful threshold-based STOP before owner review. New R1D (same source family, new SHA) smooths and curves rectangular-looking 3-ally streams, and strengthens/fans 23 soft fade motes and final true-alpha light to pass fade threshold without extending the real skill duration, or relaxing visibility limits. Owner aesthetic approval remains PENDING. R1C assets/movie retrievable via exact-SHA CI artifact; none of these changes touches Combat V2, SaveService, economy or PvE.
