# Tông Môn Bá Đạo — AUX-03 VFX provenance and event QA

- **Issue:** [#43](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/43), parent [#37](https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/37)
- **Audit date:** 2026-10-27
- **Branch:** `qa/pve-aux03-vfx-provenance-20261027`
- **Base:** `feature/pve-jx-continuous-world-20261026` at `9ad423ec9fa08b388c9aef96b8316f7b6c0bd2c5`
- **Status:** JX #158 sheet bytes and frame geometry verified; Source A animation candidates found with partial provenance; focused SaveService QA pending runtime execution.

## Scope

This change records provenance and a focused VFX event gate. Combat V2 remains authoritative. The VFX adapter consumes its event journal and does not calculate damage, targets, or combat results. No gameplay code, production renderer, raw Source A artwork, or converted artwork is changed or added.

The `pve_jx_sword_vfx_adapter_test.gd` fixture now uses a real `HuntingMapV2` spawn and real `MapBattleV2` actors. It covers the existing `ngu_kiem_thuat` cast → travelling projectile cue → positive `learned_skill` hit → one impact contract. It also verifies that cue observation leaves the battle snapshot unchanged, a cast with no positive hit does not explode, and canonical `SaveService` → `HuntingPveRunV2.resume_active` reload baselines historical events instead of replaying VFX.

Issue #37's Source A shortlist has 263 `QA_PASS` rows, mostly actor/NPC clips. Those rows are not treated as proof of skill VFX; this audit only labels objects in the extracted Effects skill subtree as stage candidates when their names support it.

## JX #158 — verified runtime sheets

The existing `godot/assets/combat_v4/jx1_skill_fx/fx_manifest.json` supplies the exact frame rectangles, per-frame anchors, direction counts, and frame timing. Actual image bytes in this branch match its recorded SHA256 values. The static audit checked all 35 rectangles against their source sheets, checked anchors remain inside each frame, and measured a maximum 0.5 px difference from each crop's geometric center.

| Runtime cue | Stage | Source sheet | Dimensions | Frames | Frame time | Duration | SHA256 |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| `jx_wudang_158_precast` | Precast | `3dfcabc2.webp` | 1266×207 | 10 | 50 ms | 500 ms | `84c63b5352a2873c05370c5d5c884e72aab07c4f2073af905e0f45b05605bb52` |
| `jx_wudang_158_cast` | Projectile | `aa93d577.webp` | 1961×774 | 17 | 50 ms | 850 ms | `bbd0e0c189249e9aa44920d6fa9fe6e61caf26f18530244501f1c2fae732a53c` |
| `jx_wudang_158_impact` | Impact | `361b4525.webp` | 1006×125 | 8 | 40 ms | 320 ms | `4052de409053ad3dc3562795c0f0d93e96029387169c7f42a4dca5d104352e13` |

Visual inspection of the 17-frame cast sheet shows a coherent sequence of sword projectiles on a transparent sheet. The current manifest anchors are preserved as authored; no pivot or renderer retuning was made. The existing adapter's focused test loads each of the three sheets through `CombatV4EffectAtlas` and verifies the declared frame counts.

## Source A on E: — found assets and status

`E:\GameAssetExtract` was accessible. Its `Reports\apk_manifest.csv` identifies package `com.vnzqzs.and` and records matching SHA256s for the base APK (`175abf3f1569af3b83cb98f798b23cbe5e9e75090702940a76915815b2a2dab2`) and `split_AssetPack.apk` (`9521e60fb5199c33283d03c014a22cc5ea8d71422861290d27a54860c9e3262b`). The split-asset catalog contains the matching `AnimationClip` records under `Effects/SplitAssetPack/effect/prefabs/skill/character_pro/jianxiu/res_179_pak`.

| Source A object | Stage candidate | Timing evidence | SHA256 verified | Status |
| --- | --- | --- | --- | --- |
| `1113101_Skill_TX` | Cast | 30 fps; stop 0.566667 s; 17 timeline intervals; dense-frame field 19; 9 streamed curves | Yes | Real clip export; prefab/skill mapping and pivot unknown |
| `feijian` | Projectile | 30 fps; stop 0.466667 s; 14 timeline intervals; 16 dense frames / 10 dense curves | Yes | Real clip export; projectile attachment and skill mapping unknown |
| `feijian_TX` | Projectile/effect transform | 30 fps; stop 0.466667 s; 14 timeline intervals; 16 dense frames / 12 dense curves | Yes | Separate clip; exact stage and prefab mapping unknown |
| `1113101_hit_TX` | Impact | 30 fps; stop 0.266667 s; 8 timeline intervals; dense-frame field 5; 3 streamed curves | Yes | Real clip export; prefab/skill mapping and pivot unknown |
| `Pattern_003_Q_white_Texture2D_2320372030354606675.png` | Impact texture | One 256×256 texture; no animation timeline | Yes | Visually a grey circular ornament; no verified standalone hit effect |

The extracted Unity clips expose sample rate, stop time, stream/dense curve data, and generic bindings. They do not expose a sprite-sheet pivot. The `Jian_*` PNGs beside the clips are texture maps; their matching prefab/mesh bindings and render placement are not established here. The filenames support cast/projectile/impact **candidate** labels only. No evidence maps these objects to JX #158, and no single connected Source A VFX chain is marked production-ready.

Full paths, byte counts, exact hashes, frame metadata, and unknowns are in [`pve_aux03_vfx_asset_manifest_v1.json`](../../../godot/data/presentation/pve_aux03_vfx_asset_manifest_v1.json). Original E: assets remain in place; none were copied, imported, or batch-converted.

## Focused QA evidence

The focused gate is `godot/tests/presentation/pve_jx_sword_vfx_adapter_test.gd`. It uses the authentic map spawn and the canonical save/reload path; the test expects these assertions:

- A live Combat V2 `ngu_kiem_thuat` cast starts precast and a projectile cue.
- One positive `learned_skill` hit produces exactly one impact.
- A cast without a positive hit produces no impact.
- Repeated observation does not mutate the saved Combat V2 snapshot or duplicate hits/impacts.
- `SaveService` persists the active run; `HuntingPveRunV2.resume_active` restores it; historical journal events do not start VFX again.

**Execution result:** pending. Nine Godot processes were active in the shared session at the latest check. I left those processes untouched and did not launch another engine; this document does not claim a runtime PASS before that evidence exists.

## Guardrails observed

- The branch is isolated from the active main Codex checkout and the base is the current PvE feature branch, not `main`.
- No merge to `main`, renderer-production edits, gameplay changes, or art conversion occurred.
- Only this manifest, report, and focused QA test are intended for the AUX-03 commit.

## Recovery continuation — CODEX 2 / 2026-10-27

- Recovery branch: recovery/pve-playable-visual-a1-20261027, created from the live feature HEAD 6b3fd181392c96c2386e5aa85950d2e993d67dda.
- AUX-03 PR #44 remains open/draft at 89d1061770c87858b76b7f940d2c35fae75edf56. It diverges from current feature: common base 9ad423ec9fa08b388c9aef96b8316f7b6c0bd2c5, PR #44 ahead 3 / behind 4. This recovery carries forward only its report, manifest, and focused test change; it does not merge the stale branch.
- Direct read-only verification on E:\GameAssetExtract rechecked all eight listed Unity clip/texture byte counts and SHA-256 values against the manifest. apk_manifest.csv identifies package com.vnzqzs.and and reports the base APK and AssetPack rows hash_match=True. No source APK/art files were copied or changed.
- Direct WebP header/hash audit rechecked JX #158: precast 1266×207, 10 frames × 50 ms; projectile 1961×774, 17 × 50 ms; impact 1006×125, 8 × 40 ms. All 35 manifest rectangles are in image bounds, anchors are within their frame, and maximum anchor-to-center deviation is 0.5 px. The frame sheet images were visually inspected; no pivot retuning is justified by this evidence.
- The updated focused adapter test now uses a real HuntingMapV2 spawn and verifies Combat V2 cast → projectile → positive learned_skill hit → exactly one impact; no impact without a positive hit; no snapshot mutation or duplicate event on repeat observation; and canonical SaveService.save_to_path → load → HuntingPveRunV2.resume_active without historical VFX replay. The active feature already contains the Source A death-snapshot idempotence contract.
- Source A AnimationClip hashes/timings are verified, but cast/projectile/impact labels remain filename-based candidates. Unity prefab hierarchy, attachment/pivot, Combat V2 skill-ID binding, and a single linked Source A effect chain are UNVERIFIED. They remain excluded from runtime assets.
- Source inspection confirms the visible Săn quái / Thanh Trúc Lâm entry, six-member V2 eligibility picker, live Source A map/HUD/minimap route, and existing focused integration checks. This is static/source evidence only; no real Windows 1280×720 capture or physical mouse result is claimed.
- Run-PVE-FPS-QA.cmd now fails closed when exact Git SHA is unavailable and passes the existing timestamped TMB_LOG to Godot, preventing the logger-mode fixed-name overwrite. The probe statically records raw frame gaps per phase, P50/P95/P99/max/1%-low, Godot process/physics time, node/draw peaks, Godot static-memory and video-memory peaks, and top-spike timestamps. It has not been run on a GUI.
- Latest Issue #37 comments contain no CODEX1_GODOT_QA_RELEASE. Per engine-slot ownership, all Godot focused tests, GUI interaction, Save/Return, logger OFF/ON profiling, OS RAM measurement, and screenshots/video remain PENDING_ENGINE_SLOT / PENDING_GUI; no Godot process was launched from this recovery work.
- No production renderer/UI, simulation, combat, save, map authority, gameplay or source art was modified. The existing Source A map and current in-view actor presentation are preserved.

### Recovery status

ASSET_STATIC_VERIFIED / SOURCE_A_MAPPING_UNVERIFIED / JX_STATIC_VERIFIED / GODOT_QA_PENDING_ENGINE_SLOT / PHYSICAL_GUI_PENDING / FPS_OFF_ON_PENDING / SAVE_RETURN_GUI_PENDING.