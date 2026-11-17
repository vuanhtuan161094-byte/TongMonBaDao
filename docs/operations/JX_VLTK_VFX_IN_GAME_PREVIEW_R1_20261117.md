# JX/VLTK source-VFX visual A/B in Tông Môn Bá Đạo Godot 4.7.2

**Date:** 2026-11-17. **Purpose:** owner-requested trial of how existing Võ Lâm graphics look in actual TMB Godot combat setting, for artistic comparison only. Draft PR #72 branch `integration/pve-p0-playable-ui-20261103`. This is a **LIVE-ENGINE LAB PREVIEW**, not a completed gameplay skill or production license for commercial VLTK art.

## Evidence and rights (DO NOT overclaim)
The existing `CombatV4EffectAtlas` reads 2 manifests **already tracked before this task**: `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json` (user's JX1 source batch) and `godot/assets/combat_v4/source_vl/vfx_manifest.json` (Source VL). No new third-party art fetched, extracted or committed. The user-supplied archive provenance is recorded in the original manifest, but **ownership/license for public redistribution of the commercial-source visuals remains unverified**. Therefore: internal test only, do not enable in release, itch.io, production/PvE or upload original binary art to this artifact. Build artifacts contain only a short comparison movie, scene screenshots/QA and hash metadata. Separate clearance is needed before release.

The comparison clips are *not* semantically identical to POI19 Phệ Cổ: specifically, Võ Đang #158 sword animation and Source VL sword animation are not poison one-target marks. They are **visual-style comparisons**, not substitutes for canonical skills.

## Existing native VFX, concrete frames and durations
| Test A/B | Existing atlas cue(s) | Source frame count & native interval | Video segment |
|---|---|---|---|
| A – JX1 Võ Đang #158 | `jx_wudang_158_precast`, `jx_wudang_158_cast`, `jx_wudang_158_impact` | 10×50ms, 17×50ms, 8×40ms | movie 0–3s |
| B – JX1 Ngũ Độc #63 | `jx_wudu_63_impact` ONLY | 13×56ms; **no precast/cast source** proven | movie 3–6s; impact around offset1.15s |
| C – Source VL sword | `sword_cast`, `sword_hit` | 36×30ms and 21×30ms | movie 6–9s |
| D – POI19 R3 first-party | existing R3 Godot scene and native additive flow; preserved original 80-pose RGBA | real-time Godot, not external VLTK source | movie 9–12s |

All four are displayed with the same actual approved Nữ Độc Tu demo caster and the same two independently WALKING V5 monster actors in the same Godot valley background at **1280×720**. The original legacy frame offsets, rects and FPS are read from stored manifests **by existing adapter** `godot/src/presentation/p3/combat_v4_effect_atlas.gd`; no poster crops, no fabricated VLTK animations.

## Controls and integration scope
Godot test scene `godot/labs/combat_lab/jx_reference_preview/r1/jx_reference_preview.tscn` launches four styles automatically 3s each; **1/2/3/4** locks style, **A** returns auto, **Space** restarts, **P** pauses. Native engine draws source atlases in a dedicated ADD CanvasItem child on top of unchanged demo sprites. R3 baseline is a genuine instanced existing Godot scene, not an offline screenshot. The selected WALK monster receives the test cue; the independent decoy is not marked. All timing in the comparison is a **DEMO CLOCK**, no VFX event is a legitimate Combat V2 hit or status.

**No gameplay modification:** no Combat V2, SaveService, PvE adapter, damage, target rules, economy, actor rigging, V6.3 enable, branch creation or merge. Existing POI19 R3 owner-provisional state preserved.

## QA and gates
Dedicated `godot/tests/labs/combat_lab/jx_vltk_reference_preview_r1_contract_test.gd` tests exact metadata (frames, duration, frame clipping), nonempty original source textures, independent target WALK, negative-control decoy, 4 mode switching and no gameplay writes. Exact SHA GitHub Actions workflow `.github/workflows/jx-vltk-in-game-compare-r1-native.yml` generates genuine Godot 4.7.2 **720 frames at fixed encoded 60 FPS, 12 seconds**, plus 1× images of JX1 precast/cast/impact, Wudu impact, Source VL cast/impact and POI19 R3 baseline. **Encoded 60 FPS is not measured physical Android performance**.

Initial status: `GODOT_QA_NOT_EXECUTED`, `INTERNAL_ART_COMPARISON_PENDING`, `JX_RIGHTS_FOR_PUBLIC_RELEASE_NOT_CLEARED`, `PVE_INTEGRATION_HOLD`, `PR72_DRAFT_NO_MERGE`. Any later PASS can prove native playback, **not license clearance or owner visual approval**.

## Final exact-SHA internal Godot A/B proof — 2026-11-17
- **Tested source commit:** `fae452fa2cdea3716cf7048cc5041f4aaca4bcaf`; GitHub Actions [#44113006743](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44113006743) **SUCCESS**: real official Godot 4.7.2 strict import/parse, source metadata/texture region checks, contract `JX_VLTK_COMPARE_RESULT=PASS failures=0`, original RGBA POI19 baseline import, actual native video and screenshots, artifact uploaded. Source SHA (not later doc-only HEAD) is the exact QA subject.
- First attempt [#44112533963](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44112533963) **failed** a too-short selected-WALK displacement interval 0.2–1.2s on sinusoidal movement (near position return), not gameplay/render. Replaced check with actual .2–1.75s >20px displacement; latest run PASS. No external binary or Combat V2 changed.
- Output: **1280×720 genuine Godot 60-encoded-FPS, 720 frames/12.00 sec MP4**, filename `JX_VLTK_Godot_Compare_12s.mp4`. Sections A0–3s (JX1 Võ Đang), B3–6s (JX1 Ngũ Độc), C6–9s (Source VL sword), D9–12s (existing POI19 R3 native gradient light); still captures at .20/.95/1.51/4.50/6.93/7.53/9.95/10.46/11.50 sec. The ZIP contains MP4, thumbnails, engine/import/test/metadata and original-source SHA manifest, **not original WebP commercial atlas binaries**.
- Actual 1× visual inspection: Source JX1 #158 cast shows narrow white sword-like vertical emission around flight, but relatively small/thin versus the 1280×720 combat stage. JX1 Wudu #63 impact makes a compact jade/green effect around selected monster; its source manifest contains *no precast* and the demo deliberately does not fabricate any. Source VL sword has wispy white/silver motion but not the cinematic purple dragon/bone motif in owner's unrelated reference image. POI19 R3 native light produces a more continuous bright violet trail at the tested screen scale. **These are legitimate context-dependent observations, not a claim that the original Võ Lâm game itself looks sparse or has poor art.**
- Scope: all four clips use real in-project existing assets, source frame-index metadata and GODOT playback, original characters plus two independently WALKING monsters; visuals are not injected into canonical `tmb.skill.poison.co_doc.active_01.immortal.b` PvE or release. Original assets' public release rights **remain unresolved**; any current successful render is **NOT licensing approval**.
- Manual gate: `EXACT_SHA_GODOT_PREVIEW_TECH_PASS`, `OWNER_AB_ART_DECISION_PENDING`, `SOURCE_ART_RELEASE_RIGHTS_UNVERIFIED`, `PVE_HOLD`, `PR72_DRAFT_NO_MERGE`. No native physical Android FPS test. Interactive lab keys 1–4, A, Space, P retained.
