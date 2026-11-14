# VFX-POI05 ART REMAKE R6 — Tán Cổ Diễn Nhiễm, Tu Tiên living spirit-gu
2026-11-14 | PR #72 Draft | OWNER REJECTED R5 VISUAL | R6 OWNER_VISUAL_PENDING until actual R6 film reviewed

## Canonical facts — not game balance edits
`tmb.skill.poison.co_doc.active_04.human`, school `poison`, branch `co_doc`, slot `active`, effect `poison`, shape `circle`, radius `2.5`, target cap `3`, cast `0.55`, cooldown `12`, range `7`, duration `7`, poison_stacks `1` as read from `godot/data/combat/v63_human_combat_catalog.json`. This is view-only movie. The three dummies have NO gameplay poison and no extra hit/DoT events.

## Why POI05 R5 failed (owner's assessment controls)
R5 R1–R5 attempts produced a symmetrical six-petal radial **flower/star** with flat chitin SVG shape, huge flash behind actors, sparse poorly readable insects, almost-static endpoint and insufficient xianxia living-light/luxury detail. **ART_REWORK_REQUIRED**. Do NOT use flower growth/cocoon explosion from R5 again. Prior technical PASS does not imply owner approval. R5 retained unmodified for history and comparative QA.

## R6 new art contract — source-independent ORIGINAL xianxia creature
Theme: **Tử Ngọc Cổ Linh** — dark ink-jade chrysalis, one long spectral **centipede-like spirit GU** with luminous violet-white edged chitin plates, many segmented legs, fangs, twin horns/antennae, jade scales and trailing gossamer purple/emerald vapour. This is a gu creature, **not** a translucent serpent reused from Xà Ảnh, and **not** Cổ Vụ mist.
Assets are *new original game-specific alpha SVG image textures* under `godot/labs/combat_lab/poison05/remake_r6/assets`:
- `gu_00.svg` … `gu_11.svg`: **12 independent non-rig sprite frames**, spline body deformation, individual chitin/legs/jaw variations, hand-authored highlights and light glints, full alpha transparent, 512×512.
- `seed_0.svg` … `seed_5.svg`: six cracked original ink-jade spiritual-chrysalis frames, 512×512, NOT flower petals.
- `mark_0.svg` … `mark_5.svg`: six open (NOT thick ring) living infestation rune frames at target chest, 320×320, fine purple/jade filaments.
- `immortal_valley.svg`: 1280×720 original moonlit immortal valley, distant temple silhouette, dark stone courtyard and mist, for more credible Xianxia game-scale composition. Original from TMB; reference imagery is NOT copied into production pixels.
No generated concept-poster / typography or copyrighted JX/Source VL pixels are imported into scene. Concept visuals are research only; new SVG assets are original game artwork. Source VL used as style benchmark, not proprietary sprite bank.

## 5-phase storyboard
1. 0.00–0.55s **Độc ấn tụ khí**: small black jade core cracks at caster palm with soft purple green glow, character face clear.
2. 0.55–1.32s **Linh cổ xuất thế**: physically articulated centipede spirit arcs to zone above 3 targets. Actual 12-frame chitin/leg motion; faint short afterimages, no flat vector spear.
3. 1.32–1.65s **Phân hồn cổ**: one spirit splits with short dark jade splinters, three branches launch with slightly staggered timing, no huge flower or full-screen radial ring.
4. 1.65–2.92s **Diễn nhiễm**: spirit gu travel along three distinct curved paths with short flowing tails, then coil/glide around each preview target, original six-frame chest parasite rune flickers. All target heads & torsos remain visible. This is NOT actual multiple hit/proc/DoT application.
5. 2.92–3.72s **Tử ngọc tán độc**: clear into jade plum embers, no stationary giant symbol; 3.72–4.20 idle, no fake persistent status.

## Independent scene and QA gates
Godot scene: `res://labs/combat_lab/poison05/remake_r6/tan_co_dien_nhiem_r6.tscn` and dedicated GDScript. R5 scene unchanged. Test: `res://tests/labs/combat_lab/vfx_poi05_r6_contract_test.gd`; focused workflow `.github/workflows/vfx-poi-05-tan-co-dien-nhiem.yml` switched to R6 scene/test. Pin official Godot 4.7.2 SHA, strict import/parse/test, native 1280x720 252 frames 4.2sec fixed-step (not measured device FPS), MP4+GIF and 14 phase frames.
Art review: inspect actual video at t=0.24,0.44,0.65,0.96,1.18,1.34,1.50,1.65,1.90,2.16,2.50,2.82,3.24,3.60. If animated gu gets too small, chitin looks like flat centipede logo, target silhouettes obscured, purple/green overexposed, or contact timing ambiguous, R6 is ART_REWORK_REQUIRED. Only owner can approve.
No character rigs, Codex, new branch or merge, Combat V2 target/status/HP, SaveService, economy, AI, or V6.3/PvE changes. Three older approved Poison LABs untouched.

## R6–R8 executed Godot evidence — 2026-11-14

R6 code SHA `6c259d21fd890063b0e05cde161eebaa0ed71d1a`: official [Actions #43563818182](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43563818182) PASS, real native video. Author inspected 0.44/1.18/1.65/1.90/2.50/3.60: 12 unique segmented living chitin gu poses read clearly, but too dark and centipedes linger over actor faces. **R6 ART REWORK REQUIRED**.

R7 code SHA `c5a08c5e1beadcb0a2370c49cda5500f632f9a28`: [Actions #43564147643](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43564147643) PASS. Increased purple/jade radial glows, generated short genuine flight-tether streaks, shortened visible gu after contact, added glowing infection curls. Native frame review at 2.50s revealed nearly closed purple-shield outline obscuring the target torso. **R7 ART REWORK REQUIRED**.

R8 **exact tested code SHA `262f80aaaa87e8391ed8aa779583fa61d25eafd2`**, [official Godot 4.7.2 Compatibility run #43564471099](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43564471099) **SUCCESS**. Strict import/parse and test `VFX_POI05_R6_RESULT=PASS failures=0 gu=12 seed=6 mark=6`; 1280x720 native **252 frames 4.20s**. The fixed-step film's 60fps is NOT physical hardware FPS. Artifacts: [#14101553006](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43564471099/artifacts/14101553006), MP4/GIF, 14 native PNGs, logs and checksums.

R8 replaces shield-like closed crescents with 3 moving **open vertical parasitic qi veins**, tiny ghost-gu approaching target chest and smaller living spore rune centered below faces. Actual frame inspection 0.44 (cast), 1.18 (large gu spirit in flight), 1.65 (split), 1.90 (staggered flight), 2.50 (3 separate small infection visuals; victim faces unobstructed), 3.60 (fade). Owner artist-quality gate **PENDING**, despite technical PASS; visual style may be polished further if owner asks. No automatic cross-tier approval.

**CRITICAL state:** `GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / PHYSICAL_WINDOWS_ANDROID_PENDING`. Prior three Human Poison approved skills remain unchanged. R5 remains as rejection evidence. New R8 user-facing movie and GIF were copied from the exact Godot R8 artifact, not invented concept art; untouched original concept poster artwork was NOT imported into live game.

## R9 → R10: one-skill art repair with official source-backed Godot proof (2026-11-14)

**R9 tested code SHA `d76170970125f55e39694da46f90a0df93e43cc0`, [Actions #43569063203](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43569063203) SUCCESS.** Added 8 original 384×384 gu_swarm_0..7 SVG alpha frames: purple-lime four-wing jade chitin moth GU with independently drawn alternate wing poses, luminous chest, six insect legs and thin veins. Kept only ONE original 12-frame ghost-centipede as an art-only release projectile; at split transitions to 3 groups of tiny jade GU instead of cloning three giant centipedes. Actual native 1280×720 frames viewed. **R9 ART REWORK REQUIRED:** lead moths too large and passed over victim faces at 1.90–2.50s.

**R10 code-exact SHA `6c8f6f0df48ef27f0c763c33828eda5437da036d`, [official Godot Actions #43569372244](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43569372244) SUCCESS.** Official `4.7.2.stable.official.ed1daf0bf` Godot GL Compatibility: strict import, parse and focused `VFX_POI05_R6_RESULT=PASS failures=0 gu=12 seed=6 mark=6 swarm=8` (test marker retains R6 file name). A **genuine native 1280×720, 252 fixed frames/4.20s, encoded 60fps** Godot video, GIF, 14 time-specific PNG captures, SHA256 and exact-SHA logs. Official artifact ID **14104070538**, generated from exact R10 commit. Encoded fixed FPS does not demonstrate device 60 FPS.

**Real R10 art inspection:** 0.44 charge has smaller palm-sourced ink-jade seed; 0.96/1.18 one articulated gu flight; 1.34–1.65 break; 1.90 two visibly smaller gu moths and their secondary flock route AOE; 2.16–2.50 three separate torso-level thin jade infection filaments with gu moths **flanking** victim actors, not covering faces; 2.82–3.24 fade; 3.60 mostly cleared. R10 moved leads laterally 60–76px from dummy heads and added focused short links back to the target chest. Focused GDScript test explicitly checks moth destination distance from the face exceeds 40px. **Technical PASS and a stronger LAB visual-review candidate**, not an art-final Source-VL equivalent: the background and sprite materials may still look somewhat vector/Cel compared with the richer painterly baseline; remaining polish only if owner requests.

**Gates unchanged:** `GODOT_FOCUSED_PASS / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD`, no Combat V2 real poison, no changes to HP/target/SaveService/economy/AI; neither R5 (rejected) nor generic VFX batch is reused. No rig, no Codex, no branch/merge. Physical Windows/Android QA pending. Must NOT move to next skill until OWNER has explicitly approved actual R10 clip.

## Owner feedback on R10 (2026-11-14, latest)
Owner said Tán Cổ Diễn Nhiễm is only **'tàm tạm'**; explicitly dislikes charge and says the centipede looks worse than previously approved luminous serpent, asks to learn and do the **next skill**. This is **permission to advance production**, NOT full `OWNER_VISUAL_APPROVED`. Retain `OWNER_VISUAL_PENDING` in ledger and defects `CHARGE_RING_POLISH_BACKLOG` (streams of light converge into a partial ring), `CENTIPEDE_CREATURE_POLISH_BACKLOG` (replace angular repetitive silhouette with painted natural gesture). Do not claim flawless art. Source/code R10 held unchanged as historical candidate until dedicated polish is requested. Next: Cổ Độc Human ultimate **Vạn Cổ Phệ Giới** as POI06, no direct Combat V2 integration.
