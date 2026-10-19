# TÔNG MÔN BÁ ĐẠO — C4-JX1 PRESENTATION PARITY / CHUYỂN GIAO TRẢI NGHIỆM COMBAT JX SANG GODOT

**Date:** 2026-10-19. **Status:** RESEARCH + DESIGN, owner-visible screenshot = VISUAL **NOT ACCEPTED**. **No gameplay code, no CI/FULL, no merge.** Branch `docs/c4-jx1-presentation-parity-20261019` from C4-EP01 `5c2e42abb44407bfc4d5a14ea2e7b2e966a2c3de`.
**Owner instruction:** Học JX1 tối đa — hiệu ứng, thao tác, di chuyển, render, art, camera, âm thanh, cảm giác giao tranh mượt; không chỉ đọc tên chiêu và copy WebP. Preserve all authoritative V2 rules, 6 người/đội, tối đa 30 người/cụm, Android landscape 1280×720.
**Reference A:** JX user Drive 1 — **Võ Lâm Idle** (browser fan project) `combat.js`, `fx.js`, `data.js`, `img/a/`, `fx/`, `snd/`.
**Reference B:** JX user Drive 2 — **Giang Hồ Chi Chiến Community Offline** (browser fan project) `main.js`, `engine.js`, `render.js`, `sprites.js`, `vfx.js`, `native-presentation.js`, `projectile-motion.js`, `sprite-compositing.js`, `skill-visuals.js` and `data/vltk-fx.json`. These are *community interpretations*, NOT proof of official JX1 engine equivalence or blanket redistributable rights.
**Game code audited:** `godot/src/simulation/combat/map_battle_v2.gd`, `jx_pilot_runtime_v1.gd`, `godot/src/presentation/p3/map_battle_world_layer_v2.gd`, `combat_v4_jx_pilot.gd`, `combat_v4_sprite_atlas.gd`, `combat_v4_effect_atlas.gd`.

## 1. Evidence: user's official Windows QA and screenshot

The two user-uploaded C4-EP01 QA archives report the same pinned HEAD, official `4.7.2.stable.official.ed1daf0bf`:
- `00_clone`, `01_import`, `02_pilot_status`, `03_snapshot`, `04_group` **PASS**.
- Benchmark 6 v 4 across 8 seeds: **8/8 wins, mean 21.46875 s, total downed 21**. Balance NOT accepted. Group V2 no-healer older baseline 16/16 wins vs sample boss. These facts show damage computation works, NOT balanced class roles.
- Later QA archive `TONG_MON_C4_EP01_QA_RESULTS_8dab15177be6.zip`: `exit_code=0`, manual scene process exit 0, **UX visual PENDING**; screenshot owner has now supplied supports a **visual FAIL/needs redesign**. Git tracked PowerShell file already modified **before** Godot due checkout CRLF issues; no net new tracked mutation during QA.
- 1280×720-ish screenshot displays dark rectangular green grid, giant untextured negative space, six visually indistinguishable disciple bodies converging under the wolf king, enemy and allies blended, multiple overlapping HP bars, no readable casting, no JX skill-specific FX / projectile in-flight; header/counters legible but screen reads as a test harness, not JX gameplay. Owner specifically finds it unlike JX.

Do NOT infer FPS from a static screenshot or Godot process exit 0; on real Windows Intel Iris Plus the scene opened in OpenGL Compatibility, but performance metrics/FPS and visual acceptance are NOT measured.

## 2. Why source JX feels smoother; exact code mechanisms examined

| JX source/module/function | Observed actual implementation | Reusable *design contract* | Present gap in Godot |
|---|---|---|---|
| Community `main.js::frame(now)` | requestAnimationFrame scheduling, separate presentation dt, scene update/render; SimulationClock step 1/30 or 1/60, display 30 FPS mobile and up to 60 desktop; performance sampling | Independent fixed simulation and high-frequency frame animation, time budget on mobile | Godot battle simulation 0.25s; renderer receives event-driven actor positions at discrete ticks, **no actor-position interpolation** |
| Community `render.js::render(ctx,dt)` | camera follows target with `k=min(1,dt*7)` smoothing; zoom, visible world bounds, background props and depth | Smooth camera + map/camera layout, clear visual hierarchy, culled off-screen assets | Static grid and camera; actors converge center, blank stage |
| Community `engine.js::stepToward`, `navigate` | movement-to-range, world blocked check, turn-angle fallback, line-of-sight, pathfinding and stuck recovery; `moveBy` marks moving and advances walk | Tactical space/range/steering/collision and target reacquisition | MapBattleV2 actors move straight toward nearest enemy at `move_speed*0.25`; no personal space/ally steering/formation/pathing |
| Community `sprites.js::sheetFrame`, `getFrame` | multi-direction atlas, exact `rects [x,y,w,h,ax,ay]`, `dirOffset`, action/weapon frame pacing | Asset manifest per actor/action/weapon/direction; foot anchor and source frame durations | Godot has atlas reader but actor art all hero/wolf; few actions and VFX cue resets on hit |
| Community `engine.js::performCast` | `castId`, source visual native presentation, delayed cast, legal damage and cast FX graph; damage consumer is separate | `cast_started→committed→launch→in_flight→hit/collision→afterfx`, stable `cast_id` | JX pilot `pilot_cast`/ `pilot_impact` mostly show generic `attack`/`hit` cue, no moving projectile rendered |
| Community `projectile-motion.js::advanceProjectile` | time-based x/y motion, angular homing with cap, life time, multi-missile formation `0 wall/1 line/2 spread/3 circle/6 target/7 caster`, declared `MslsGenerateData` cadence 1/18s source tick | Separate **visual** flight curve/missile quantity from actual authority hit packet; arc, trail, target lock, deterministic start/end | Pilot backend computes target-locked **time-to-impact only**, view has no actual flying missile state |
| Community `native-presentation.js::NativePresentation` | source graphs for precast, launch, primary/child missiles, contact, vanish branches and audio; binds primary visual missile to real projectile but event-only missile art never adds free damage | Event-subscribed VFX graph, one-shot sounds with de-dup and life cycle | Godot only 2 effect atlas kinds `sword_cast/sword_hit` mapped to original learned skill; 4-school pilot has no source-skill FX/SFX mapping |
| Community `vfx.js::blitFx,drawProjectileVfx` | atlas rectangle/anchor, directional `dirs`, `frameMs` independent of physics, compositing `blend`, directional index | Source accurate 16-direction missile sheets, alpha/screen/light blend and time-correct FX | `CombatV4EffectAtlas` supports a 1-direction FX Atlas and fixed alpha 0.74; missing 16-direction FX/projectile stage |
| Community `sprite-compositing.js::prepareSpriteForBlend` | matte repair for luminous legacy screen-blended sprites, preserves original source | Correct blending/transparency without rectangular gray/black occlusion | No per-source JX blend or preprocessing metadata |
| Community `render.js::drawEntity,drawProjectile` | ground shadow, boss ring, aim-target cues, floaters, layered player/FX, HP distinct | Combat readability at glance + low-occlusion FX budget | HP bars and bodies overlap; boss scale 2.30x wolf, all 6 disciples use `hero` sheet |
| Idle `fx.js` and `data.js` | 121 missile templates, 11 effect templates, 176 skill FX mappings, 202 WebP references physically matched by filename at audit | High-coverage source catalog and frame/anchor/16-direction timing data | Not imported/mapped into JX EP01 pilot renderer |
| Idle `img/a/` and `snd/` | 585 WebP = 117 × (at/die/hurt/run/st) groups; 232 MP3 physically present | Source characters/monsters and action/SFX coverage | No selected JX monster/action audio pipeline in EP01 |
| Community `data/vltk/native/assets/` | 176 WebP +74 WAV; native source graph/asset sheet bindings, 132 char WebP etc in separate folders | Authentic-looking cast/hit/monster alternatives and waveform tags | Only Source VL wolf/hero sheets and two specific VFX currently shipped in C4-VP01 |

**MUST distinguish game modes:** Idle `combat.js` runs a stage/idle wave loop including autoplay, not 6-man tactical battle. Community `engine.js` is browser survival/open-world, often controlled as one player plus bots; its movement/skill presentation is reusable, **its PvP stats or simulation model are not**. Neither source directly supplies 6×5 tông môn group AI.

## 3. Code-specific diagnosis of screenshot

1. `MapBattleV2.step`: every alive actor chooses `_nearest_enemy`, moves straight on normalized target vector until within `range`. No ally collision or personal radius. Both teams converge on few targets, bosses physically stack with swordfighters. **Root cause is gameplay spatial model**, not sprite draw order.
2. `MapBattleWorldLayerV2.point_on_map`: direct coordinate→screen mapping, no interpolation snapshot. `_process(delta)` advances **only animation clock**. `_positions` used for facing/walk cue, but actor position drawn directly from `battle.actors[id]["position"]` each render. This makes 0.25s movement jumpy even at high FPS.
3. All disciples `art_key="hero"`; all three wolf species `art_key="wolf"`, boss same body scaled 2.30×. No individual silhouettes/weapon stance. Boss appears out of scale and obscures combatants.
4. `_actor_clip` uses `attack/hit/run/idle/die`; `pilot_cast` sets attack cue and `pilot_impact` sets generic hit flash; `pilot_commit`, `pilot_hot_tick`, `pilot_poison_tick`, `pilot_party_defense` have NO skill-specific render paths. Poison/HoT counters are textual.
5. `CombatV4EffectAtlas` only draws two original Sword FX with `dirs=1`, fixed alpha/scale. Current JX pilot refuses to mislabel `ngu_kiem_thuat` effect as #158; resulting effect layer is nearly empty, correctly authentic but visually incomplete.
6. `MapBattleV2` already includes actual cast/event data, 0.25-second deterministic step; do NOT replace this with JX browser physics/damage or call `Math.random` in Godot authoritative logic.
7. HUD and stage screen ratio already 1280×720, but grid/margins waste world space; at zoom and 30-disciple cluster occupancy, labels and bars must be collision-aware and zoom-scaled.

## 4. Approved architecture proposal (DESIGN; no code in this research packet)

```text
Source A / JX1 immutable asset registries
    │ actor dirs/rects/anchors/action/weapon/SFX/VFX refs + SHA/rights
    ▼
CombatV4VisualBindings (game_skill_id, source variant, actor ID)
    ▲                                  ▲
    │ events with tick/cast_id          │ source FX/SFX metadata
MapBattleV2 / C4-EP01 authoritative    JXAssetCompiler (offline)
    │ hp/position/target/status          │ atlas manifests, graph nodes
    ▼                                  ▼
CombatV4PresentationAdapter ─────────▶ VFXGraphRunner
    │ interpolated actor view           │ pre-cast/launch/fly/hit/vanish,
    │ facing, action, foot anchor        │ real 16-dir frame timing, blend,
    │ camera/target UI                   │ sound voice budget
    ▼
Godot 4.7.2 CanvasItem 1280×720 (FPS independent, view-only)
```

- **Interpolation 250ms:** store `actor_prev_position`, `actor_next_position`, `simulation_tick_at`; sample `display_time` with an explicit render delay and clamp alpha [0,1]. `draw_position = prev.lerp(next,alpha)`. For walk anim use smooth visual velocity, orientation facing. Avoid a fake unlimited predicted position or extra random movement. Exact target movement governed by backend and serial replay, not screenshots.
- **Formation/personal space:** authoritative **future scoped** spatial pass (NOT purely visual): slot offsets/role preferred distance/ally separation/encounter-wide movement + stable-ID order/blocked-space avoidance. Only after seeded replay regression. Cannot solve all overlap by shifting just drawn sprites: ghost positions would make actual hit/range misleading.
- **Action machine:** idle/walk/attack/cast/hit/death keyed by actor+clip+cast_id, distinguish a cast recovery from a hit reaction, avoid restarting attack on every repeated event. One-shot genuine clip rates and weapon poses; Source A real matching cast if available, otherwise explicitly marked fallback.
- **Visual projectile object**: source `cast_id`, caster/target, start+commit+hit timestamps from V2, a deterministic **cosmetic** path, homing limited only if source authoring allows; on actual `pilot_impact` stop and spawn hit FX. More visual child missiles may fan/spread/circle WITHOUT creating extra V2 hit events. Preview never visually overshoots impact or grants phantom contact.
- **VFXGraphRunner:** process `precast → launch → fly → impact → vanish/status`, with verified manifest rects, offset, 1/8/16 directions and `frame_ms`, `source blend`, audio. No arbitrary `sword_cast` reuse for different school. Status applications may emit short UI status icons anchored to actor with V2 authoritative expiry.
- **Source A/JX unity:** Source A disciples if matching real action clips, JX monsters/Boss and JX skills/projectiles where authenticated; uniform scene scale/height/anchor/palette/shadows. Do not assume Source A has full combat animation when only idle/walk baked in repo.
- **Audio:** cast, launch, travel loop, impact, death one-shot with per-cast and per-sfx dedup; no overlapping 30 identical loud sounds; mix and fade per distance/priority. Declared source sound file must be verified binary and rights-cleared.
- **Stage:** authentic permitted Source A/JX terrain art foreground/background/props, grid debug OFF by default, role/HP and boss telegraph high contrast, meaningful ranged spacing. Stage art is optional until authentic files available: never relabel synthetic ground as JX original.
- **Source authenticity labels:** each binding carries `source_variant_id`, `external_skill_id`, filename SHA256, parsed metadata evidence, missing_binary status, rights; fan-engine source code can guide behavior but publisher artwork may have different permission.

## 5. Execution packets in order — no more 11 new skills first

| Packet | Scope, exact files/components | Output | ACCEPTANCE |
|---|---|---|---|
| **PRES-00: source JX audiovisual closure** | Read both user Drive sources; compile JX fx metadata and Source A actor selection for FIVE existing EP01 pilot skills (#15, #158, #159, #63, #93) + existing monsters; SHA/rects/directions/audio | Five versioned Action/VFX graphs and missing-clip truth table; no invented source | Every cited source path exists and binary/hash verified or declared PENDING |
| **PRES-01: movement/readability** | Isolated fork of C4-EP01; visually interpolate actor positions, avoid animation retriggers, add readable selection/role/HP, reduce 2.3× wolf Boss overlap, remove debug grid, add environment art where owned | Compare before/after 1280×720 stills and 10s recording; actor names and skill states legible | Smooth walking without view/snapshot changes to damage or AI; not falsely hiding 0.25s movement |
| **PRES-02: five true JX cast/projectile/impact graphs** | VFXGraphRunner + manifest + SFX event binder + real source 16-direction atlas, hover valid flags, actual `cast_id` cues, physical cosmetic missile stream | At least #158 sword projectile and #63 poison missile visibly launch, fly and hit with correct art; #93 has recognizable HoT; #15 guard and #159 aura readable | Every displayed impact correlates to exactly one authoritative committed hit/status (no phantom), asset provenance/rights checked |
| **PRES-03: group formation and no-overlap** | Narrow `MapBattleV2` 6-man formation/personal space/roles threat positioning, verified 0.25s deterministic movement, no path collision cheating; actual source JX AI heuristics adapted | Melee/ranged/heal separated, 6v5 scene never blobs, 30v40 remains manageable | Seeded replay equal viewed/offscreen, actor no illegal teleport, attack range and targeting preserved, One Active Job unaffected |
| **PRES-04: tactical camera + boss + mobile** | Boss telegraph/danger lanes, player command role policy, background JX/Source A, audio mix and VFX pooling; read-only HUD | Actual footage on target Android, screenshot 1280×720, boss cast legible, effects not obscuring actors | Windows Godot 4.7.2 import/test/scene, Android on-device performance >=30 FPS target, memory bound, user visual acceptance |
| **PRES-05: 10 schools** | Only after PRES-01..04 and four-school pilot approved, expand remaining 11 authored actives and other JX school arts, skill teaching separately | Controlled content rollout, no missing effects | Each skill real, learned, visual source proven, deterministic 6/30 team combat |

**Run ONLY focused tests:** keep existing `c4_jx_pilot_effects_test.gd`, `dv2_02_battle_snapshot_test.gd`, `dv2_02_group_map_battle_test.gd`; add presentation interpolation/FX graph dedicated focused tests, one visual GUI session. Do not run CI/FULL, don't edit main, PR20, Economy or Save unless specifically authorized. QA into isolated TEMP clone/save with SHA pin. Mark verified static vs Godot runtime vs owner UX independently.

## 6. Concrete quality checklist for owner (binary yes/no)

1. From first 2–4 seconds, distinguish Thiếu Lâm frontline, Nga Mi healer, Võ Đang backline and Ngũ Độc poison actor visually (actor color/weapon/role may differ even if no unique body available); **no six identical overlapping figurines**.
2. Movement appears continuous at 30–60 render FPS even with authoritative 4 tick/s; input/tactical orders and hit outcomes identical watched and headless.
3. At least one clean, clearly source-matched JX sword projectile #158 travels full distance before emitting hit FX; slow motion or screenshot captures three stages start/mid/hit, and no 16 frames generating 16 hits.
4. Poison #63 status persists for exactly three true 1s ticks; visually communicates poison independently of damage; HoT #93 communicates actual healing with no overheal farming; guard #15 and aura #159 distinguished clearly.
5. Boss attack warned in advance, scale and collision readable; Bị Hạ/corpse not covering living melee actors; HP bars and selected name not overlap in normal 6v5 screenshot.
6. Arena resembles permitted JX-style forest/map rather than debug grid, with ground shadow/z-order and legible 1280×720 UI.
7. Six-person benchmark 8/8 wins, 21 total downed is **not enough** to accept balance; run meaningful 30–100 seed role comparisons after real spatial changes.
8. Owner sees before/after stills AND recording (at least 10s) at 1280×720; no claim PASS just because Godot scene opens.
9. Mobile renderer maintains >=30 FPS initial target on actual midrange Android with measured memory, VFX cap and audio polyphony; **do not** infer from Intel PC.
10. C4-VP01 underlying Combat V2 and P2 known learnings untouched until downstream permission.

## 7. Recommended first next action

**Do not add 11 skills or rebuild combat simulation.** Start a new isolated **PRES-00 → PRES-01** branch from pinned C4-EP01 HEAD; source FX/actor truth table first, then smoothing/readability and real clip binding. Proof-quality screenshot/video first, not broad code. Parallel PRES-02 once verified WebP+audio are available. Keep gameplay unchanged until later narrowly authorized PRES-03. In PR/commit summary state **"V2 AUTHORITY UNCHANGED; JX-STYLE PRESENTATION ADAPTER"**.

## 8. Source boundaries and copyright

Do not automatically redistribute copyrighted JX1 artwork/recordings just because downloaded from user Drive. Maintain provenance per version, source rights and original archive SHA. Community fan-game code is a useful engineering reference; copying third-party code wholesale is subject to its actual license and dependencies. Prefer reimplement **patterns and interfaces** in GDScript and use binary assets only within permitted scope. Include explicit owner-only personal testing, deployment rights PENDING.

**END — DIRECTIVE TO LEARN JX1 PRESENTATION FULLY, NOT JUST 2 VFX SHEETS.**