# TÔNG MÔN BÁ ĐẠO — C4-VP01 SOURCE VL REAL-TIME COMBAT PILOT

Date: 2026-10-18. Status: **CODE IMPLEMENTED ON ISOLATED BRANCH; GODOT 4.7.2 RUNTIME/USER UX PENDING**.

## Scope and authority

- Owner instruction: check Source VL on Google Drive, implement real combat, owner authorizes use of Drive assets. This packet deliberately implements only an **isolated visual prototype** with the already-implemented **MapBattleV2** gameplay loop, not a replacement for Combat V2, not integration with live disciples, not guaranteed commercial use or public redistributability of original VLTK IP.
- Source: https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR ; actual WebP bytes plus exact rect/anchor/direction in `data/sprites.json`, `data/vltk-fx.json`. JX1-derived third-party copyright chain remains **unverified** even though owner authorized using this Drive content. Do not redistribute outside authorized owner workflow before clearing IP.
- Baseline main: `461caca1171462e0da092f21108c5c1733157ad9`. Stacked on independent C4-01 hotfix HEAD `4e2ca7db07c98a021977bbcb026b6be7c958bbff`, which fixes the typed pending-cast telegraph crash without modifying combat simulation. **NOT merged**, no code changes to main/PR20/G1/Economy/Injury/Save/Warehouse/Scheduler.
- Branch: `c4-vp01-sourcevl-real-combat-pilot-20261018`.
- User's Model C school choice and legend exclusive signature skills (Model A) remain separate **design documents**; this pilot does **NOT** unlock school/fate mechanics or grant any signature skill.

## What really exists in this packet

**Imported from owner's Source VL Drive**: 11 actor WebP sheets (**wolf** `ani011_{pst,st,wlk,at,bat,die}.webp` = 6; **VLTK human** `boss019_{st,wlk,at01,bat,die}.webp` = 5). `boss019` is a **generic source sword-fighter stand-in**, not the confirmed permanent disciple Source A character. Additional two authentic VLTK-styled **Võ Đang** fx sheets `wd_150_jianchuixinghe_{a,d}.webp`. All are binary blobs stored on this isolated branch; no AI re-render and no resizing of original files. Source import is not an assertion of third-party rights.

**Exact source atlas metadata**: `godot/assets/combat_v4/source_vl/atlas_manifest.json` has source x/y/w/h/ax/ay arrays and eight directional views for actions idle/run/attack/hit/die. `vfx_manifest.json` has verified source `effects.swords9` (36 frames) and `effects.hitBig` (21 frames), both `interval=30ms`. These two styles are **visual analogs** for the Godot `ngu_kiem_thuat` skill, **not** an official one-to-one JX1 SkillId mapping. The FX blending mode `lighter` is source metadata, additive blending fidelity in Godot still needs review; pilot uses controlled alpha.

**Code (PRESENTATION only)**:
- `godot/src/presentation/p3/combat_v4_sprite_atlas.gd` reads rect/anchor/direction metadata, samples source textures by visual animation age.
- `godot/src/presentation/p3/combat_v4_effect_atlas.gd` displays source VFX frames, bounded to real event lifetime.
- `godot/src/presentation/p3/map_battle_world_layer_v2.gd` opts in with `enable_source_vl_art=true` and `draw_pilot_ground=true` only in sandbox. Real `battle.events` move/cast/hit/heal/downed drives direction, actor pose and VFX, drawn behind actors and HP. Baseline flag default FALSE preserves legacy map circles. C4-01's AoE schema safety remains.
- `godot/src/presentation/p3/combat_v4_pilot.gd` and `godot/scenes/p3/combat_v4_pilot.tscn` are a manual stand-alone **6-versus-5** playable-observable auto-fight: 6 temporary seeded actors (frontline, ranged, mage, healer roles), 3 Thanh Lang, 1 Hắc Lang, 1 Hắc Lang Vương, real V2 HP, range, cooldown, AI, 0.25s steps, skill `ngu_kiem_thuat`, AoE cap3 and Boss warning; re-play button; no external save/rewards. Source `ani011` is used as **placeholder scale** for Hắc Lang/Hắc Lang Vương, NOT verified as their original artwork; this is explicitly shown in the sandbox caption.
- `godot/tests/presentation/c4_vp01_source_vl_battle_visual_test.gd` includes source WebP frame bounds/load, visual-read-only RNG/tick, real `skill_cast` and `skill_hit`, no duplicate event consumption.

### QA status — do not overstate
- **STATIC IMAGE CHECK PASS (local Python PIL on original uploaded Drive binary)**: exact 10 displayed actor actions (5 hero + 5 wolf) across all 8 directions, all rectangles x/y/w/h bounded by real WebP dimensions. `ani011_pst` originally missing but later fetched and committed; metadata and image match. Original two VFX atlas `swords9` (36 frames) / `hitBig` (21 frames) all rects bounded by actual WebP; source interval = 30 ms.
- **Godot 4.7.2 import/parse/focused visual test: PENDING**. This sandbox does NOT have the official Godot binary; DO NOT claim engine/runtime PASS. Also **Windows actual gameplay screenshots and Android landscape FPS/touch: PENDING**. A static bounds PASS says nothing about Godot runtime.
- **Combat V2 balance/save/end-to-end PVE: UNCHANGED, NOT RE-TESTED on this commit**. The roster fixture in sandbox is not the canonical player's 6 real disciples, so this packet is not full game integration.
- **No CI/FULL / no merge**, independent from PR20 and ongoing G1.

## Minimal one-pass acceptance (user Windows PC, safe TEMP clone)

Open the isolated branch in a fresh TEMP clone; never overwrite local game/save/untracked Source A. In official Godot 4.7.2:
1. Import project (headless `godot --headless --path ./godot --import` or Godot Editor import).
2. Run focused test only: `godot --headless --path ./godot --script res://tests/presentation/c4_vp01_source_vl_battle_visual_test.gd`, save stdout/stderr and exit code. Marker must be `C4-VP01 SOURCE VL REAL ATLAS + MAPBATTLE V2 VISUAL TEST: PASS` with exit0 and no GDScript parser/import error.
3. Run `godot --path ./godot res://scenes/p3/combat_v4_pilot.tscn`. At 1280×720 visually confirm actual art for wolf/human, idle/run/attack/hit/die, HP, cast/impact FX, Boss warning, 6v5 combat resolution; repeat using CHƠI LẠI. Capture one screenshot and rough FPS. Correct source assets not enough if animation/clip, labels, anchor, performance are wrong.
4. Check C4-01 pending cast test and DV2-02 group battle focused test if applicable (no CI/FULL); only then report actual runtime outcome. Keep owner UX **PENDING** until screenshots inspected.
5. If any parser/asset error, fix only isolated packet paths and redo focused tests, do not change CombatStatsV2/MapBattleV2/Save or pretend PASS.

## Known limitations & next scope (requires separately scoped approval)

- Current pilot art actor/rendering view only; full 10 school real VFX, 6 named Legendary personal skills, additional monster visual identity, Source A disciple runtime integration and encounter sync remain **future packets**.
- No original verified `hac_lang_vuong` source sprite; using scaled `ani011` wolf as marked placeholder is intentional. Does not silently label gray wolf sprite "original boss".
- `ngu_kiem_thuat` uses real V2 damage and one of two currently implemented P2 learned direct-damage skills. Other seven P2 effects remain deferred; do not claim functioning DoT, Poison, Dash, learned Guard or FireCombo. Current event cue VFX is cosmetic and never consumes source-JX damage/MP/target logic.
- Sprite/FX view uses full authored 8 directions for wolves/humans and view interpolation for frames only. Simulation still ticks fixed .25s and events remain deterministic; render must not mutate RNG.
- Next packet after runtime validation should connect **real DiscipleCombatLoadoutV2/HuntingPveRunV2** to map UI, add actual party/skill selection, correct boss art and authentic 1:1 native skill VFX via completed binary source, while preserving One Active Job and exactly-once settlement. No automatic implicit authorization.

This document is a handoff and acceptance contract, not evidence of a passed official engine run.
