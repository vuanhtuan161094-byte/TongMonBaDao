# POI07 — Xuyên Cốt Độc Châm · Human — Original Sprite-First Art Packet
Date 2026-11-14 | PR #72 Draft | isolated Combat Lab only

## Contract (exact canonical v63_human_combat_catalog.json)
Skill tmb.skill.poison.doc_cham.active_01.human; poison school / doc_cham branch; Human, active_01; damage, nether, single_target; cap ONE; range 7.5, cast 0.45, projectile speed 8, cooldown 9; zero poison stacks. READ-ONLY metadata. Never create AOE or DoT and never modify combat engine.

## Original 2D production
First-party Pillow atlas source: tools/vfx/generate_poi07_poison_needle.py (not Source A/JX/VL pixels; no commercial asset copies). Atlas 12 distinct baked faceted needle poses (4x3, cell 384x192, output 1536x576) + 8 independent asymmetric cosmetic chest-contact poses (4x2, cell 256x256, output 1024x512). UV has fully transparent cell borders; avoid bright circular UI geometry. Dark jade-violet forged body, narrow ivory spine and small blue-jade wisps. Actual caster and target idle sprites are the pre-existing accepted Stage A resources, unchanged; NO rig.

0–0.45 charge at palm (342,427); 0.45–1.39 travel toward one target chest (960,471); 1.39–1.86 visual point fracture; 1.86–2.35 fade; rest idle. Screen 1280x720. Target hit is a *mocked visual timeline only*: no HP write, no real event, no fake damage number.

## Native QA
Open res://labs/combat_lab/poison07/xuyen_cot_doc_cham.tscn in Godot 4.7.2 GL Compatibility after executing python3 tools/vfx/generate_poi07_poison_needle.py. Workflow .github/workflows/vfx-poi-07-xuyen-cot-doc-cham.yml on branch push/dispatch runs official sha256-pinned Godot import, parser and focused contract, then native 1280x720 MP4 + GIF + 14 frames + SHA logs. On first push it may add the two baked PNG files with a guarded, non-force same-branch commit and dispatch exact-final-SHA QA. On any CI failure do not label PASS.

Gates: OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, V63_OFF, WINDOWS_ANDROID_PHYSICAL_QA_PENDING. R11 unchanged. No Codex, no skeletal rig, no new branch, no merge, no SaveService/Combat V2.

## R2 native Godot proof — technical result, not owner-art approval
- Focused source commit: `93176741dd717d6a97aa7543d912755326d347fb`, official SHA256-pinned Godot 4.7.2 GL Compatibility.
- Actions [run #43617178584](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43617178584) SUCCESS, [artifact #14122533516](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43617178584/artifacts/14122533516).
- Strict import, GDScript parse and isolated contract: `VFX_POI07_RESULT=PASS failures=0`, frames=12, contact=8, single target, no gameplay.
- Native H.264 MP4 1280×720, 174 frames, 2.900 s, fixed 60 FPS frame clock, GIF and 14 native PNG checkpoints. After independent artifact download, 16/16 SHA256 media checksums matched. Fixed recording clock is not physical measured device FPS.
- R1 movie t=1.30 revealed painted needle tip overshot target chest because AtlasTexture was positioned by cell centre. R2 maintains the actual alpha pixels, translates by the painted-tip offset 138 px along flight vector, making tip arrive at chest. Contact sprite display enlarged from 0.62 to 0.78 scale, faster 0.045 s opacity rise; t=1.30 and 1.56 native stills were visually rechecked. One target, no added damage event.
- Both authored PNG atlases tracked in the same PR branch in commit `d5552690a9fa9c8926f395a5b780a7570fd0830a`. All POI06 R11 files and Combat V2, SaveService, live PvE remain untouched.
- `GODOT_FOCUSED_PASS / NATIVE_VIDEO_VERIFIED / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / V63_OFF / PHYSICAL_QA_PENDING`. This is a completed technical isolated-Lab candidate; do not infer artistic acceptance or release readiness.

## R3 — 2026-11-14 owner correction: STRAIGHT projectile, preserve other art
Owner observed the previous flying needle curved upward and ordered straight travel; all other art provisionally acceptable. The original R2 code added a *-36 × sin(PI × progress)* vertical arc even though exact catalogue declares a single-target projectile. Fixed by using `flight_tip_at(t) = PALM.lerp(CHEST, clamp((t-CAST_END)/(CONTACT_AT-CAST_END), 0, 1))`: linear geometry and constant forward travel, with a delayed on-axis trail. No new art, extra hit, poison status or gameplay changes.
- Main code commit [`101dacd1a2c9214f52c0118cee469b835fb44066`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/101dacd1a2c9214f52c0118cee469b835fb44066).
- Exact final tested source [`7200d49c4f64e37e4ab5f0a92d31234e4e546f4c`](https://github.com/vuanhtuan161094-byte/TongMonBaDao/commit/7200d49c4f64e37e4ab5f0a92d31234e4e546f4c); additional spatial focused tests verify launch at palm, arrival at chest and ideal on-line positions at 10/25/50/75/90% of flight.
- Official Godot 4.7.2 GL Compatibility exact-SHA [GitHub Actions #43619060246](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43619060246) SUCCESS: official pinned engine, strict import, GDScript parse and `VFX_POI07_RESULT=PASS failures=0`. [R3 artifact #14123251514](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43619060246/artifacts/14123251514) includes authentic 1280x720 174-frame / 2.90-second fixed-60fps H264 MP4, GIF, 14 temporal stills, logs and checksums. After independent download, **16/16** media SHA256 checksums matched. Inspect t=0.21/0.44/0.56/0.73/0.92/1.12/1.30/1.44/1.56; visible projectile progresses directly to target without mid-flight upward hump.
- No edits to POI06 R11, other schools, Combat V2, SaveService, PvE/V6.3. `GODOT_TECH_PASS` is not device performance certification; `OWNER_VISUAL_PENDING` for the R3 motion review; `PVE_INTEGRATION_HOLD`.


## R5 hand-charge and chest-contact art polish — 2026-11-14
User requested prettier charge and damage-contact after accepting straight flight as provisionally adequate. New first-party generator `tools/vfx/generate_poi07_polish_r4.py` creates **12 charge** + **12 contact** pose-specific RGBA PNG frames, each 320×320, four columns x three rows; the original 12 needle poses + 8 original contact frames remain preserved. Charge is asymmetric jade-violet convergent material localized to caster palm; contact layered behind/over target at chest, with bright penetration and a short original thorn tip to avoid a broad AOE. Straight constant-speed `flight_tip_at()` unchanged. No event mutation or rig.
- R4 engine proof [#43621191359](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43621191359) SUCCESS on binary-committed SHA `970760ea8b95e7c0730f00b34c46f6ce82731987`.
- R5 exact movie source SHA `aa379fcfa60b4821ead4c66083f015a60b746be5` and [Actions #43621509983](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43621509983) SUCCESS, [artifact #14124700856](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43621509983/artifacts/14124700856). Official pinned Godot 4.7.2 strict import, script parse, focused `VFX_POI07_RESULT=PASS failures=0`, native H264 1280×720 / 174 frames / 2.90s fixed 60fps clock, GIF + 14 timed phase stills. Independent R5 artifact: **16/16 media SHA256 hashes verified**.
- Native inspection 0.21, 0.33, 0.44, 0.73, 1.30, 1.44, 1.56, 1.81, 2.09s: charge present, needle flies straight, local hit contact centered on one chest below face, no persistent projectile or extraneous targets. New contact at t1.44 still less pronounced than at t1.56, but R5 noticeably strengthens the initial pinprick and shrinks the excessive purple rays from R4.
- `GODOT_FOCUSED_PASS / NATIVE_VIDEO_VERIFIED / OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / PHYSICAL_QA_PENDING`. User did not give explicit final R5 art approval. No new branch/merge or live gameplay modification.
