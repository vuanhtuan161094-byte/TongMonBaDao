# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / THANH TRÚC LÂM
## Read-only code audit + implementation packets (2026-10-18)

**STATUS: PREPARED / NO COMBAT V4 CODE AUTHORIZED / NO NEW GODOT RUN.**
This file records actual GitHub code findings and three independent, bounded proposals. It is not a Windows or Android acceptance report, and it does not authorize code on its own.

### 1. Pinned authority and strict boundaries

- Repository: https://github.com/vuanhtuan161094-byte/TongMonBaDao
- This packet lives ONLY on the dedicated documentation branch **docs/combat-v4-thanh-truc-lam-packet-20261018**; it is NOT yet in main. Code implementers must read this exact ref and must base their new code branch on a fresh main HEAD, not on this docs-only branch unless explicitly directed.
- Read-only main HEAD: **461caca1171462e0da092f21108c5c1733157ad9** (2026-10-15T07:56:39Z). Before any implementation, refetch main; rebase/redo allowlist if changed.
- Authority read: AGENTS.md (blob **93996e5471b1e889ae239acc1dfcc0efceac3d63**), docs/GAME_SYSTEM_ARCHITECTURE.md (blob **55d4b7711920ab0faf0b2cef4dbeeab5b7e3b6ac**), CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md; docs/COMBAT_STATS_V2_SPEC.md; docs/COMBAT_SKILLS_V2_SPEC.md; docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md. Newer owner instruction wins over historical design/status.
- G1 draft PR #20: **2219535fc3519ce811265ceed5cb85001efe5e45**, OPEN/DRAFT and not merged; based on a MAP25 branch. Do NOT edit this PR or infer those assets are on main.
- Scope: Godot 4.7.2, Android LANDSCAPE design 1280×720; Combat V4 visual pilot independently of G1. **No gameplay/balance/rules code until precise owner CODE permission.**
- Never touch Economy V2, One Active Job, Warehouse, Scheduler, SaveService, persistent PvE state, Injury 0/1/120, PR #20, MAP25/sect production UI, G2 or the old combat stat formulas. No CI, FULL, merge, or fabricated Windows PASS.

### 2. Verified code matrix at pinned main

| Subsystem (blob SHA) | Observed implemented facts | What is NOT proved/implemented by this audit |
|---|---|---|
| CombatStatsV2 (2e7bda169d9ca90a759455878c737d12cf2bc0f2) | Combat-derived core/rate/crit/damage/lifesteal primitives; 30 realm × 10 floor inputs | No V4-specific VFX or whole-game balancing proof |
| MapBattleV2 (fdef96e73343d01c63df9f1408b821e90ca1b0c6) | Deterministic 0.25s step; 90s maximum; arena 36×20; party_id limit 6, up to 30 disciples/40 monsters; movement, nearest-target, basic, healer, frontline guard, mage AoE, boss/elite telegraph, event journal, 3-target AoE cap | Full boss phase AI, obstacle pathfinding, sophisticated skill-status engine and mobile FPS unproved |
| MonsterCatalogueV2 (dd9edd6906a9170dcaadeed119074265d88a1438) | thanh_lang, hac_lang, hac_lang_vuong and other catalog entries; boss tier scale; species metadata | hac_lang_vuong behavior_id is explicitly boss_phase_authoring_pending, behavior_ready false; no verified wolf sprite |
| MonsterEncounterV2 (c9129af8fd815b777c2a175cb6e9ae2ec4a62a60) | Real HP hit and hit-ID dedupe helper | Not a standalone V4 boss ability system |
| HuntingMapV2 (6df5a95f5ea327d3f2d41864d7137cca005746c3) | thanh_truc_lam authored region; 5 difficulties; normal pool contains thanh_lang; boss is hac_lang_vuong; difficulty L5 includes a boss; actual reward preview/claim authority | Do not change spawn odds, loot or balance for visual preview |
| HuntingPveRunV2 (d9532b6e8604dd54e791fab9afd21130a0d99684) | Validates true V2 disciples; builds loadout, reserves PvE actor, begins/steps/saves/settles/claims; includes exactly-once terminal receipt and saved-run reconciliation | Source explicitly says not installed into legacy scheduler; don't claim map/sect integration or offscreen work policy as finished |
| DiscipleCombatLoadoutV2 (912cb8a82ec4c91f0fe10bb852810500c6acc93c) | Uses actual owned gear and learned skills; source attrs; no combat-power-as-ATK | Only skills whose effect is 'damage' enter map_battle learned skill loadout; other P2 skill effects deferred |
| CombatSkillSystem (275036c94e99d69ffa7be895e969ffe4a067e79f) | Nine P2 authored skills/metadata (including Thanh Phong Trảm, Ngự Kiếm Thuật) | Nine fully resolved MapBattle V4 skills/animations are NOT proved |
| MapBattleWorldLayerV2 (bfef63a3d7f3df31f5357d16d71e9a1c3bfe6859) | Node2D read-only adapter, actor circles, side/tier color, HP bars, boss warning ellipse, world-map roundtrip | No true chibi or wolf sprite; actor name/role cues and skill VFX incomplete |

**Specific code-level risk, not a runtime FAIL:** MapBattleV2._try_learned_damage_skill queues a pending cast with target_id/skill_id/ready **without center/radius**; MapBattleWorldLayerV2._draw loops over ALL pending_casts and unconditionally reads cast["center"] / cast["radius"]. A genuine learned single-target skill visible in this layer can therefore hit an invalid Dictionary field access. Fix/guard by cast schema, not by inventing a center or modifying damage logic.

**Older evidence, NOT a new run:** docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md reports official Godot 4.7.2 Linux focused [#37884662844](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/37884662844) on an earlier SHA. Existing godot/tests/simulation/dv2_02_group_map_battle_test.gd (blob 2c54c9904908f13eea8f5972689281b6bda70e72) checks multi-actor AoE/heal/boss warning/dodge/30 actors/replay and historical 16-seed pilots. Those results are not a fresh proof on main or a V4 mobile pass.

### 3. Asset provenance and explicitly PENDING items

- Source A rights: owner authorized private/personal project use; do not infer commercial/public redistribution rights or treat JX1/VLTK1 sprites as free.
- At pinned PR #20, verified manifest-backed character bundles exist at:
  - godot/assets/actors/1113028_1/ (female; asset.json blob 30c630ee141dd697dd0016a6067eba4ac6af412e; stand 48 frames, walk 24 frames);
  - godot/assets/actors/body_1110201/ (male; stand/walk per PR #20 pool and asset records);
  - godot/assets/actors/body_1120402/ (male; asset.json blob 2dbd0bcdff1caa783919ac575f42e91e6b9ac7c2; stand 48 frames, walk 24 frames).
- PR #20 visual pool is godot/src/presentation/p3/disciple_source_a_visual_pool.gd (blob 91dcc62c0c47ccb24db06a507afd1f34a0952e52).
- Read docs/P3_SOURCE_A_ANIMATION_ASSET_UI_UX_HANDOFF_2026-10-17.md on PR #20. Only **stand/walk** are evidenced for these three imported rigs. **Do NOT fake attack/hit clips**. A damage flash/number is a separate presentation effect, never an animation claim.
- Two-direction policy: face left/right using AnimatedSprite2D.flip_h only after mirror-safety check; use same art when moving vertically. Share SpriteFrames atlas resources across actors; verify foot anchor and visual scale at 1280×720.
- Monster sprites: the main and inspected PR #20 tree provide no **identified + rights-checked** Thanh Lang and Hắc Lang Vương battle assets. Source A Batch-01 also mentions generic monster rigs 1113031_1 and 410041_1, but their visual identity as the required wolves is **UNVERIFIED**. No JX1/VLTK1 material may be imported without explicit rights evidence.
- The V4 pilot may temporarily render **clearly labeled schematic fallback silhouettes/circles** for these two enemies, never call them final chibi wolf art. Final owner-visual acceptance is blocked until actual relevant monster sprite manifests/clip provenance and visual QA exist.
- Godot/Windows/Android animation preview, FPS/frame-time, texture memory, user-visual approval remain **PENDING**.

### 4. Visual pilot contract — Thanh Trúc Lâm

A separate **sandbox preview scene**, not a second production simulator or a fabricated saved game. It consumes existing MapBattleV2 actor/cast/event snapshots. Stage at 1280×720 landscape, read-only HUD, near-map HP/name/side/tier and visible enemy/Boss affordances; skills shown only when an actual MapBattleV2 event occurs. AoE telegraph must show center, radius and remaining cast time; display must not become combat timing authority. Targeting and release remain decided by MapBattleV2. Use bounded 6vN default encounter and exercise the existing 30-disciples/5-party ceiling in regression; never spawn extra actors or rewrite difficulty to win the demo. Use real MonsterCatalogueV2/HuntingMapV2 content definitions, with non-persistent fixture disciples **clearly identified as visual preview**, no real saves, rewards or progression. If using existing region-spawn presets, make seed and level reproducible and document which include Thanh Lang/Boss (L5 boss guaranteed by current content). No per-frame gameplay polling beyond reading an already active pilot battle; avoid translucent VFX obscuring HP, labels or actors.

### 5. Three small independently scoped candidate CODE packets

#### C4-01 — MapBattleWorldLayer cast-schema safety (RECOMMENDED FIRST; CODE NOT AUTHORIZED)
**Owned paths only:**
- MODIFY godot/src/presentation/p3/map_battle_world_layer_v2.gd
- ADD godot/tests/presentation/combat_v4_world_layer_cast_schema_test.gd

**Contract:** In read-only drawing, distinguish pending AoE casts (center/radius) from learned target_id skill casts; render only valid warning geometry; never fabricate AoE or hide an actual valid boss telegraph. Invalid/incomplete cast visual data fails closed without a script error. Do not alter MapBattleV2, skill data, damage, RNG, time or event journal.

**Focused acceptance:** real boss telegraph rendered at MapBattleV2 coordinates; valid single-target learned pending cast does not cause Dictionary-key/runtime errors; both may coexist; overlay refresh/actor picking does not advance battle time/RNG; deterministic seed results and 3-target damage untouched. Parse/import with official Godot 4.7.2 when a runner is available; read existing dv2_02_group_map_battle_test.gd regression. NO CI/FULL. Windows GUI and Android = PENDING USER.

#### C4-02 — Standalone Thanh Trúc Lâm visual pilot (CODE NOT AUTHORIZED)
**Owned paths only:**
- ADD godot/scenes/p3/combat_v4_thanh_truc_lam_pilot.tscn
- ADD godot/src/presentation/p3/combat_v4_thanh_truc_lam_pilot.gd
- ADD godot/tests/presentation/combat_v4_thanh_truc_lam_pilot_test.gd

**Contract:** Standalone debug/pilot view only, load the existing map-world overlay and real MapBattleV2 snapshots; create a bounded, deterministic, explicitly synthetic preview party (max 6 per party) and catalogued Thanh Trúc Lâm monsters. Provide repeatable normal/Thanh Lang and Boss/Hắc Lang Vương showcases without forging production-owned disciple or reward state. Clear side/HP/boss/AoE/time/tactical readout; 1280×720 legibility; no VFX flood, no map/sect scene edits. Use fallback visuals clearly marked until animal art provenance is solved.

**Focused acceptance:** zero canonical SimulationState/Warehouse/Save changes; 6-member party & 30-member multi-party limit preserved; both showcases reproducible; AoE warns before impact and respects move-out; hidden/visible render produces equivalent battle outcomes; no gameplay in _draw. Official Godot 4.7.2 focused test and one real GUI visual session later only with runner/PC; do not label manual/Android PASS now. No CI/FULL.

#### C4-03 — Licensed sprite adapter, stand/walk mirror first (CODE NOT AUTHORIZED; ART PENDING)
**Potential owned paths only:**
- ADD godot/src/presentation/p3/combat_v4_actor_visual_adapter.gd
- ADD godot/src/presentation/p3/combat_v4_actor_visual_registry.gd
- ADD godot/tests/presentation/combat_v4_actor_visual_test.gd
- CONDITIONAL ADD ONLY verified copied bundles from pinned PR #20: godot/assets/actors/1113028_1/**, godot/assets/actors/body_1110201/**, godot/assets/actors/body_1120402/**. Only if the code branch otherwise lacks these files, the owner separately authorizes transfer, and per-file asset.json SHA-256 checks pass. NO PR #20 edits.

**Contract:** Stand/walk from existing SpriteFrames, face left/right via validated flip_h, vertical motion reuses left/right, same atlas resource across instances, map-foot anchor and Y-sort. React to genuine move, skill, damage, downed events without fabricating attack/hit clips. If no licensed wolf sprites, keep labeled fallback and fail the art-acceptance gate explicitly. Never relabel 1113031_1 or 410041_1 as Thanh Lang/Hắc Lang Vương without positive identity evidence. Never import unlicensed JX1/VLTK1 art.

**Focused acceptance:** manifest path and SHA check for each added binary, independent male/female selection, stand/walk playback, mirror-safe facing, no invented clips, texture sharing, real-map anchoring, no visual/gameplay authority leak; evidence screenshots at 1280×720 and Android perf PENDING USER. No CI/FULL.

### 6. Newly supplied G1 ZIP — evidence only, NO G1 edit

File: TONG_MON_G1_PR20_QA_20261018_105037.zip, local SHA-256 **797274e640bdb3937ebc88fbac59a56a6997be7de4e225d070d779e68dead450**.
- Windows official Godot **4.7.2.stable.official.ed1daf0bf**, checked PR #20 at **2219535fc3519ce811265ceed5cb85001efe5e45**.
- Import PASS; focused 03 radar PASS; 04 Source A actor PASS; **05 gui_workforce_v1_e2e_test FAIL**; 06 instance board PASS; 3/4 focused PASS; final Windows QA **FAIL**.
- Exact failure at godot/tests/presentation/gui_workforce_v1_e2e_test.gd:214: **"real delivered Mine batch did not notify the map"**. This is real failure evidence but does NOT yet prove whether production or test expectation is wrong.
- No GUI launch because focused test failed; **0/3 real screenshots**; G1 owner visual PENDING. G1 repair/triage remains a separately authorized packet; Combat V4 does not touch it.

### 7. Owner handoff and next action

Recommended next action: **authorize C4-01 only**, citing fresh main SHA, exact two-path allowlist and tests above; then separately authorize C4-02 and only after art provenance decide C4-03. All work must be done through GitHub connector; no Codex/Work unless owner directs otherwise. Keep this docs branch separate from G1 PR #20; no merge/CI/FULL, do not claim Windows PASS.

**Ready-to-send next prompt:**

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP CODE C4-01 TRÊN NHÁNH MỚI TÁCH TỪ GITHUB MAIN HEAD MỚI NHẤT (PHẢI KIỂM TRA LẠI; baseline kiểm toán 461caca1171462e0da092f21108c5c1733157ad9). Đọc AGENTS.md, kiến trúc, packet tại https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v4-thanh-truc-lam-packet-20261018/docs/COMBAT_V4_THANH_TRUC_LAM_IMPLEMENTATION_PACKET_2026-10-18.md và code MapBattleV2/MapBattleWorldLayerV2. Chỉ sửa godot/src/presentation/p3/map_battle_world_layer_v2.gd và thêm godot/tests/presentation/combat_v4_world_layer_cast_schema_test.gd. Sửa lỗi render pending learned single-target skill không có center/radius, giữ boss AoE telegraph thật, không sửa bất kỳ gameplay state/damage/RNG/timer/skill/balance hay hệ G1/PR20/Economy/One Active Job/Warehouse/Scheduler/Save. Test focused tối thiểu nếu runner có sẵn, không CI/FULL/merge, không giả Windows PASS. Push branch code riêng, ghi SHA/evidence, Android và owner UX PENDING. Không mở C4-02/C4-03 khi chưa có lệnh.
