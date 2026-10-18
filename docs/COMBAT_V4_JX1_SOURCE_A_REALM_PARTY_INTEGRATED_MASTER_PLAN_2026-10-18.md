# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / JX1 + SOURCE A / MASTER DESIGN & ASSET INTAKE PLAN

**Date:** 2026-10-18
**STATUS: DESIGN ONLY — NO GAMEPLAY CODE, NO CI, NO FULL TEST, NO MERGE.**
**Repository:** vuanhtuan161094-byte/TongMonBaDao.
**Parent research:** `docs/COMBAT_V4_JX_SCHOOL_30_REALM_SKILL_AND_COMBAT_STAT_DESIGN_2026-10-18.md` and `docs/COMBAT_V4_JX1_SOURCE_260_SKILLS_INDEX_2026-10-18.md`.
**Immediate constraint:** Owner is still downloading additional versions of JX source; do not treat available Source VL as source-complete. Sources can be received/inventoried independently of combat code.

## 0. Owner direction / non-negotiable architecture

1. First finish **design, balance audit, 30-realm+party design, asset ingestion interface**, THEN in-game Combat V4 mechanics; do not race to import more skills into unvalidated runtime.
2. **Live Combat V2 / Godot 4.7.2** remains the authoritative simulator: stats, target selection, deterministic 0.25s step, action cooldown, damage, HP, skill unlock/ownership, injury/reward settlement. Legacy P0/P3.7 should not be broken or silently replaced.
3. **JX1 family** is reference material for ten-school fighting identities, weapons, maps, sprites, VFX, audio, skill graphs, missile/projectile timing, enemy behaviors, target/duel/party presentation, not plug-and-play balance; different JX versions must be catalogued separately.
4. **Source A** remains production-quality candidate for disciples and sect; it has original Spine/atlas and 10-rig processed Batch-01 evidence, and must coexist with JX characters/monsters/FX rather than be thrown out.
5. Keep already-designed V2 **30 Tu Vi × 10 floors AND 30 Luyện Thể × 10 floors**, six canonical foundations, independent roots, 16 combat stats, one soft active Chủ Đạo, One Active Job, Injury 0/1/120, save/offline exactly-once, 6 per party / 30 disciple cluster.
6. Model C martial school freedom: innate root/five-elements do not class-lock; a chosen JX-inspired curriculum can differ from inherited root. No generic School ATK/HP buff, fake class XP or arbitrary subclass. One Basic + 4 Active + 6 combat-triggered Passive mature loadout, gradually unlocked per authored design.
7. Legendary signature skill Model A: only the named individual can ever use it, cannot copy/teach/transfer even on school switch, must occupy a normal active slot, requires real skill legality and never duplicate proc.
8. No implicit broad commercial distribution right can be inferred from the fact the user uploaded JX1 files. Record ownership/provenance/usage rights by source variant for future packaging; private research and release clearance are separate.

## 1. Evidence: what the CURRENT main code really does

- `CombatStatsV2.derive(r, floor, br, bfloor, potential, sources)` already calculates HP/ATK/DEF **using independent Tu Vi and Luyện Thể plus current Tiềm Lực**. Source contributions must use registered channels. `G(r,f)=1.65^(r-1)×1.03^(f-1)`; Realm base (100 HP,20 ATK,12 DEF), Body base (90,3,7), Potential factor `1+0.0005×P`. Direct-hit mitigation uses `2A/(2A+D_eff)`, crit, resistances, DR, actual HP and exactly-once lifesteal.
- This function DOES NOT mean all real in-game fights automatically use V2. `DiscipleCombatLoadoutV2.build` currently bridges genuine P2 equipment and actual learned P2 **direct-damage** skills. Its caller supplies independent progression; it does not turn legacy `combat_power` into new ATK. Full 30-realm progression/persistence and skill inheritance still need cross-system runtime integration audits. `HuntingPveRunV2.begin` can consume saved `v2_realm_progress` when present, prohibits caller-spoofed progress, but comments explicitly mark remaining legacy scheduler integration.
- `TeamState` persists `leader_id` and `member_ids`; it does not by itself implement party combat formation or leader aura/command buff. `MapBattleV2.setup` enforces max six actors for same `party_id`; total max30 disciples, max40 monsters. Ticks `0.25s`, arena36×20, cap90s, AoE cap3, max2400 events.
- Current `MapBattleV2.step` targets nearest live enemy (deterministic ID tie). It has position/range/movement, **generic frontline self Guard** at <75% HP lasting 4s, 9s CD, reducing remaining incoming damage 35%; **generic Healer** at same-party ally <65% HP within 6 coordinate units, `1.8×ATK` heal every 5s. These are *pilot role abilities*, NOT previously learned Guard/Y Đạo skills. Mage AoE and boss telegraph work, role-based threat/taunt/cross-party combo AI is NOT done.
- `CombatSkillSystem`: nine definitions in V2 bridge, only two currently direct damage usable; buff/Debuff/Burn/Poison/control, dash, actual learned guard, formation aura and advanced JX impact stages need real consumers. C4-VP01 is an isolated visual 6v5 Source VL pilot, not a full live hunting loop; Windows Godot 4.7.2 acceptance stays PENDING.
- Previous focused 16-seed group examples in `docs/DV2_02_GROUP_MAP_COMBAT_CONTRACT.md` include one **no-healer party still 16/16 wins** vs chosen Boss. It is evidence group role differentiation is not balanced yet, not a universal winner rate. Need many-seed tests and tactical changes before locking buffs.

## 2. Real effect of EACH realm and floor: locked numeric stat growth, separate authoring unlocks

For EACH track independently:
```text
G(r,f) = 1.65 ^ (r-1) * 1.03 ^ (f-1)
P = 1 + 0.0005 * current_potential
core_max_hp = (100*G(TuVi_r,TuVi_f) + 90*G(Body_r,Body_f))*P
core_attack = (20*G(TuVi_r,TuVi_f) +  3*G(Body_r,Body_f))*P
core_defense= (12*G(TuVi_r,TuVi_f) +  7*G(Body_r,Body_f))*P
final_core = (core + sum_registered_flat) * (1 + sum_same_channel_percent_add)
```
At equal growth per track: same-floor increase of a major realm is ×1.65; 1st to 10th floor is ×1.304773; moving from realm r floor10 to realm r+1 floor1 is ×1.264588. Tu Vi-only progression affects the 100/20/12 component; Luyện Thể-only progression affects the 90/3/7 component. Neither track is a permanent class or level XP.

### 30-row stat snapshot FROM LIVE formula, NOT new balance

Assumptions: both Tu Vi and Luyện Thể at SAME realm/floor, **P=100**, no gear, sources, roots or learned skill bonuses. Numerals rounded for UI, actual source retains floats. Compare all realm1 HP/ATK/DEF and realm10 HP; the skill-content column is a **candidate** realm theme only, not currently enabled or approved unlock.

| # | Tu Vi canonical realm | Tầng 1 HP | Tầng 1 ATK | Tầng 1 DEF | Tầng 10 HP | Skill progression theme (PROPOSAL) |
|---:|---|---:|---:|---:|---:|---|
| 1 | Phàm Nhân | 200 | 24 | 20 | 260 | Thường Kỹ; chưa tự nhận phái |
| 2 | Luyện Khí | 329 | 40 | 33 | 429 | Định Đạo hợp lệ, kỹ năng tấn công A (đề xuất) |
| 3 | Trúc Cơ | 543 | 66 | 54 | 709 | Mở utility/phòng ngự B (đề xuất) |
| 4 | Tử Phủ | 896 | 108 | 90 | 1.169 | Cơ chế debuff/buff đầu |
| 5 | Kim Đan | 1.479 | 179 | 148 | 1.929 | Chuỗi family đơn mục tiêu nâng cao |
| 6 | Nguyên Anh | 2.440 | 295 | 244 | 3.183 | Quần kích/AoE và giới hạn thật |
| 7 | Hóa Thần | 4.026 | 487 | 403 | 5.253 | Tương tác hai kỹ năng, slot tiến triển |
| 8 | Luyện Hư | 6.642 | 804 | 664 | 8.667 | Khả năng cơ động hoặc phản đòn |
| 9 | Hợp Thể | 10.960 | 1.327 | 1.096 | 14.300 | Hoàn thiện các chủ động trưởng thành (mốc đề xuất) |
| 10 | Đại Thừa | 18.084 | 2.189 | 1.808 | 23.596 | Tuyệt học Nhân Giới: gate học, không tặng |
| 11 | Nhân Tiên | 29.839 | 3.612 | 2.984 | 38.933 | Gia phả A đời Tiên |
| 12 | Địa Tiên | 49.234 | 5.960 | 4.923 | 64.239 | Gia phả B đời Tiên |
| 13 | Thiên Tiên | 81.236 | 9.834 | 8.124 | 105.995 | Mở rộng combo nhưng không auto skill |
| 14 | Chân Tiên | 134.040 | 16.226 | 13.404 | 174.892 | Hỗ trợ cùng đội có contribution thật |
| 15 | Huyền Tiên | 221.166 | 26.773 | 22.117 | 288.571 | Kiếm trận/độc trận/lôi trận (nếu implemented) |
| 16 | Kim Tiên | 364.924 | 44.175 | 36.492 | 476.143 | Phòng thủ/sinh tồn Tiên |
| 17 | Thái Ất Kim Tiên | 602.124 | 72.889 | 60.212 | 785.635 | Multi-hit có cast-id/target cap |
| 18 | Đại La Kim Tiên | 993.505 | 120.266 | 99.350 | 1.296.298 | Tương tác status/kháng |
| 19 | Tiên Vương | 1.639.283 | 198.440 | 163.928 | 2.138.892 | Tuyệt học Tiên hoàn thiện |
| 20 | Tiên Đế | 2.704.817 | 327.425 | 270.482 | 3.529.172 | Gia phả Tiên cao nhất; không slot 5 |
| 21 | Thần Nhân | 4.462.948 | 540.252 | 446.295 | 5.823.134 | Gia phả A đời Thần |
| 22 | Chân Thần | 7.363.863 | 891.415 | 736.386 | 9.608.172 | Pháp tắc hữu hạn |
| 23 | Thiên Thần | 12.150.375 | 1.470.835 | 1.215.037 | 15.853.483 | Ngũ Hành/Dị Căn eligible |
| 24 | Thần Quân | 20.048.118 | 2.426.877 | 2.004.812 | 26.158.247 | Trận pháp cấp Thần hữu hạn |
| 25 | Thần Vương | 33.079.395 | 4.004.348 | 3.307.940 | 43.161.108 | Sinh tồn cứu nguy hữu hạn |
| 26 | Thần Hoàng | 54.581.002 | 6.607.174 | 5.458.100 | 71.215.828 | Giải trạng thái phù hợp từng tier |
| 27 | Thần Đế | 90.058.654 | 10.901.837 | 9.005.865 | 117.506.116 | Đòn nhiều nhịp không proc vô hạn |
| 28 | Thần Tôn | 148.596.778 | 17.988.031 | 14.859.678 | 193.885.092 | Cấm chết / chống chết encounter cap |
| 29 | Hỗn Độn Thần | 245.184.684 | 29.680.251 | 24.518.468 | 319.910.401 | Hỗn Độn kế thừa build đã nuôi |
| 30 | Sáng Thế Chủ | 404.554.729 | 48.972.415 | 40.455.473 | 527.852.162 | Kết thúc gia phả Thần; không tự unlock |

**Uneven track examples**, both with P=100, floor1, no gear:
- Tu Vi realm10 / Luyện Thể realm1: HP~9,612; ATK~1,907; DEF~1,150.
- Tu Vi realm1 / Luyện Thể realm10: HP~8,671; ATK~307; DEF~679.
These do not create a class, they arise from the different Realm/Body base contributions.

**Important anti-inflation rule:** DO NOT make a new "school level +65% HP" multiplier when realm already provides ×1.65; JX schools differentiate skill family/timing/target status and equipment eligibility. Check high-end r30 float safety, crit/defense behavior, monster G scale, monster tier, screen abbreviation/precision, hit log, and fight duration for 300 floors × two tracks. Monster tier multipliers in `MonsterCatalogueV2` are pilot, not global locked balance; no adaptive scaling after monsters spawned. The big source numbers must be represented in UI compactly without secretly truncating battle logic.

### XP/learning is DISTINCT from pure stats
- Exactly 30×10 Tu Vi and Luyện Thể levels do NOT mean 300 skills or 300 authored attack coefficients. Floors change stat core and may gate skill mastery, not auto-teach powers.
- A family has Nhân (realm1–10), Tiên (11–20), Thần (21–30) successors; learned using real manuals/sect transmission, owned skill, basis (Tu Vi/Luyện Thể/Hybrid), requirements, time, mastery. A successor is NOT an additional automatically stacked copy.
- Candidate realm unlock thresholds and active/passive slot milestones must be separately user-approved; V2 locks max 1 basic /4 active/6 combat passives but not exact unlock levels.

## 3. JX source ingestion architecture: MULTI VERSION, reproducible and asset-maximizing

### Immutable source folders (outside the game repo)
```text
Drive/
  JX1_Versions/
    JX_Variant_01/original/        # original PAK/SPR/TXT/LUA/BIN/scene/sound if legitimately accessible
    JX_Variant_02/original/        # do NOT overwrite or mix variants
    JX_Variant_03/original/
  Source_A/
    originals/                    # full raw Spine/atlas/PNG, archive, config, rig/skeleton details
    processed_godot472/           # already-tested rendered/sliced atlas/frame tables/clip metadata
    manifests/
  Documentation/
    source_versions.csv
    rights_provenance.csv
```
Do not call one downloaded JavaScript community project a fully authoritative JX1 client. Current Source VL has 260 source skill records/13 schools, 118 playable in web version; actual Drive artifact closure previously incomplete. Different game variations may have overlapping `SkillId` but different assets, animation graphs, timings or licensed use. All identities must be prefixed `source_id/version_id`. Preserve archive untouched and hash manifest SHA-256 per file. Keep Chinese filename/codepage normalization in sidecars so PAK/SPR matching is reproducible.

### Multi-version JX content catalogue columns
`version_id, original_path, hash_sha256, size, archive_container, source_skill_id, skill_name, faction, element, weapon, activation_type, effects/logic evidence, dependency_paths, sprite_clip_id, state, action, direction_count, frame_count, frame_rects, anchor, source_fps_or_frame_ms, cast_release/hit_event, projectile_graph, SFX, native_binary_present, extracted_binary_present, Godot_resource_path, QA_status, rights_status, license_proof`.

**Asset closure status must distinguish:** metadata-only, complete original binary, original with damaged/missing dependencies, validated Godot runtime, and Windows/Android approved. Never infer 270 VFX profiles are 270 working skills or a manifest path exists as a binary. Prefer graph-based cast/precast/projectile/impact/status instead of faking hit timing.

### Asset adapters (DESIGN, no code yet)
- `AssetSourceRegistry`: source version + hashes + source path + rights.
- `JXSkillIdentityMap`: external `SkillId` to **canonical authored game SkillFamilyId**, lineage Nhân/Tiên/Thần; NEVER use source SkillId to directly decide player level or apply source MMO damage.
- `ActorVisualBinding`: source A default disciple rig/sprite by character appearance, JX1 player/monster fallback only if matching fit/rights, 2D 8-direction or approved mirrored 2-direction per asset; camera and animation remain view-only.
- `ActionAtlas`: idle/walk/attack/hit/death and optional spell poses, authentic frame duration, anchor, weapon layers.
- `VFXGraph`: ordered `cast/precast → launch/projectile → hit/impact → aftereffect/status` sequences, real `cast_id` and sequence ID, playback anchored to authoritative `MapBattleV2` events, no phantom damage.
- `SoundBank`: IDs and verified audio graph with collision/dedup; no raw audio duplicates or 496 metadata records miscounted as 496 files.
- `MobileBudget`: visible-object culling, pooled VFX, lazy textures, LOD for noncritical FX, compositing budget, cap cast sounds, target **Android landscape 1280×720 and 30FPS+ on actual midrange phone**, not inferred from desktop.
- Only export/commit vetted asset subsets. Do not flood Git repo with raw PAK/APK or automatic huge ZIPs.

## 4. Source A: EXACT upload decision

**ANSWER: upload BOTH original + already-processed Godot exports if storage/bandwidth permit. Original first; processed second.**
- Raw source is **irreplaceable**: `.skel` or Spine JSON, `.atlas`, original `.png`, skin/slot/attachment info, rig IDs, constraints, Spine export version, associated clip lists. Godot cannot necessarily open arbitrary Spine `.skel` alone: Spine runtime/export compatibility or baked conversion is required. Keep masters and dependency mapping, not loose PNG only.
- Existing conversion work is **worth preserving**: historical Batch-01 source conversation reported 10 usable rigs, 31 clips, 1,016 frames, 28 WebP atlases, 35.6MB Godot472-ready outputs. Upload `Assets_Godot472` (frame atlas WebP/PNG and full JSON/CSV frame rectangles, pivots, timing, source-rig mappings, action/facing tags, import settings, converter tool VERSION/CONFIG/LOG and SHA-256 manifest); this avoids repeating a conversion that already passed local checks.
- Do NOT upload only processed sheets and delete raw, or only `.skel` and discard validated clip frames. If bandwidth limited upload **(1) raw archives of prioritized rigs + exact manifest, (2) processed matching rigs, (3) full remaining raw library**. The assistant can read files via connected Drive, validate hash and map metadata, but cannot guarantee running Spine binary/rendering pipelines or Godot on the current environment without runner.
- Proposed manageable bundles: `SourceA_Raw_Rigs_Batch01.zip`, `SourceA_Godot472_Batch01.zip`, `SourceA_Manifests.zip`, `SourceA_Environment_Original.zip`, optional `SourceA_Raw_Remaining_Parts_NN.zip`. Preserve stable relative paths **within archives**; use ZIP to avoid thousands of Google Drive tiny files, plus a mirrored/extracted directory if individual viewing is desired. Keep each archive at practically retrievable size; do not force arbitrary fixed MB caps.
- Include `rig_id, original_files, original_sha256, spine_export_version, processing_script_commit, output_files, output_sha256, clip, fps/frame_times, directions, pivots/anchors, atlas_rects, atlas_dimensions, blend, root motion, verified_runtime`. If metadata differs from original, keep both and log a provenance conversion.
- Exclude `.godot` import cache, `.import` generated machine-local cache unless absolutely required by explicit Godot loader design, `.git`, builds, local saves, duplicated previews, unknown executables. Convert safely, never execute a random supplied EXE.
- Author's Source A rights are acknowledged for personal project use; file rights for mixed JX assets must still be recorded independently; upload does not confer external commercialization rights.

## 5. Party & battle: JX1 combat texture over V2 6-person groups

### 5.1 Formation contract
- Persistent `TeamState` currently has leader_id and member_ids only. Add authored pre-battle `TeamLoadout` **when later coding authorized**: 6 slots, optional leader for commands/social interactions, 3 front/3 back or 2 front/2 mid/2 back chosen manually, initial positions, active skill loadouts, target profile, retreat policy, formation preset. Do not mutate 6-cap or One Active Job constraints.
- Team1 = 6 disciples. Up to 5 teams = 30 disciples in ONE cluster/encounter; **not** five independent RNG engines fighting same boss. At most 40 monsters in current simulation.
- The "leader" may direct focus and positioning, **NOT automatically add ATK or crit** without a real learned skill/trait with valid source attribution. Change leader outside battle; team buff range/party eligibility remain explicit.
- Formations presets: **balanced** (2 frontline/2 DPS/1 Y Dao heal/1 control), **boss hunt** (1 high-EHP tank/2 boss DPS/1 break-defense/1 healer/1 interrupt), **farm** (1 front/3 AoE/1 sustain/1 control), **poison attrition** (1 guard/2 poison + mark/1 cleanse/1 burst/1 sustain). These are formation recommendations, not permanent JX classes.
- JX-inspired priorities: protect support, target focus, ranged spacing, kite, evade AoE warning, reposition to healing radius, threat/aggro, buff own party, target debuff shared across encounter; low-level AI can be deterministic heuristic, not neural or turn order.
- No hidden formation percentage multiplier. Composition value must result from actual battlefield positions, skill events, protection, crowd-control and sustain.

### 5.2 Party/encounter status ownership
- Only one `party_id` receives ordinary group buff/healing when defined same-party. The existing generic healer does this already.
- Shared target enemy debuff/marks come from target `encounter_id`, globally capped for **all** attacking parties; no "five parties each stacking ×3 defense break" exploit.
- Threat is a real system prerequisite for tank's **protection role**, not a cosmetic Taunt icon; Boss may have explicit resistance, not all encounters mandatory aggro lock.
- Revive limited, downed cannot be treated by ordinary heal; use explicit rare revive successor gated by realm/mastery and once-per-battle constraints if approved.
- Debuff statuses: poison, burn, freeze, slow, armor break, mark, shield, HoT; require snapshot magnitudes and exactly-once tick settlement; no infinite proc loops or cross-skill exploit. DoT and heal contributions must count for legitimate participation but prevent idle farming.
- World loop: reserve party members with canonical One Active Job, start one `HuntingPveRunV2`, commit authoritative snapshots, finish in background/offline deterministically, settle injury and rewards **exactly once**, then return members.

### 5.3 UI 1280×720 information hierarchy
- At player-visible screen: battlefield first, 6 compact party HP/status strip, selected actor name/role/realm, cast/impact VFX readable, boss warning ground indicator, tiny skill cooldown indicators, encounter time/state/clear retreat.
- Pre-battle party panel: drag/replace one disciple, role, school, five-element icon, skill set, gear, matching basis, suggested survival score; show `Why?` tooltip for "Boss very difficult" based on estimated stats/skills, no hidden scaling.
- After-battle: actual hits/tank damage received/heal effective/status/control/downs/cost/time/loot receipts. Never treat purely DPS as all contribution.
- At 30 person cluster: aggregate per-party panels, keep map legible and VFX priority/culling, not 30 giant HP bars + 40 monster names.

## 6. Design stage plan — chronological packets, gates and deliverables

| Phase | Work before coding? | Exact deliverables | Exit gate |
|---|---|---|---|
| **P0 — Source Intake Protocol** | YES; starts now while sources download | Versioned manifests, rights, SHA, tool reproducibility, raw/baked Source A workflow, do-not-execute binaries rule | Every newly added source classified, never infer unverified binary presence |
| **P1 — Realm/Power Audit** | YES | 30×10×2 core growth table, mismatched-track cases, rates, crit/defense/monster power, inflation and UI formatting risk, real P2 vs V2 migrations | Determine precisely which gameplay entrypoints apply real canonical progress; protect locked G formula |
| **P2 — Combat Character Contract** | YES | Origins birth/root/potential, soft path + optional JX curriculum, actual learned skills, 1+4+6 slots, Model C, legendary exclusive A, stat-source breakdown | Single canonical identity; no free school stats or fake inherited skill |
| **P3 — School Curriculum** | YES | Ten classic schools, source SkillId→ authored family, weapon, effect basis, Nhân/Tiên/Thần successors, mastery, manuals, learning cost/time; three source expansion schools postponed | Every proposed effect has actual V2 primitive dependency and exact source provenance |
| **P4 — Party Design** | YES | Team6 formation roles, 5-team encounter, deterministic AI priorities, threat/support/poison/mark/buff contract, accurate participation, rewards/injury | Formation matters through real tactics, not percent aura; no healer/healer benchmark revisited |
| **P5 — Sprite/VFX Audio Interface** | YES | Immutable source version catalog; actor/skill/clip metadata; JX FX lifecycle, Source A rig mapping; 1280×720 LOD/pool/budget | Anchor, direction, clip duration, event sync, fallback, memory/CPU plan and rights matrix documented |
| **GATE D** | YES | Unified master design and balance acceptance | Owner approves interfaces and scoped next action; DO NOT open broad gameplay rewrite |
| **I0 — Narrow backend pilot** | AFTER DESIGN | True 4-family primitive vertical slice: Võ Đang projectile, Ngũ Độc status DoT, Thiếu Lâm threat/guard, Nga Mi effective heal; deterministic seeded tests | No false status; events/reward exactly once; 6 actors from actual saved state |
| **I1 — Actor/VFX pilot** | AFTER I0 | Source A real disciple + JX1 wolf/boss + cast/impact/armor/SFX, 6v5 active map, Android landscape | Actual Godot 4.7.2 Windows + physical Android visual/log/FPS evidence; owner UX acceptance |
| **I2 — Team integration** | AFTER I1 | 6-member roster management, 5 parties/30 cluster, threat/formation AI, targeting/retreat, save/offline | No One Active Job violation; persistent replay matches viewed/offscreen, exactly-once settlement |
| **I3 — Ten classic schools** | AFTER I2 | Incremental authored learned skill families and successor generations, valid assets, UI, unlock/mastery | Every skill tested at documented loadout/realm; no dummy VFX-only abilities |
| **I4 — Expanded content** | LAST | Three extra schools, more JX version effects, monster species, premium signature skills | Complete per-asset rights/status + mobile QA + no balance regression |

No timeframe stated while source uploads are incomplete. Work in small, separately approved commits/branches with scoped allowlists, one focused QA per real dependency, no CI/FULL unless separately requested.

## 7. QA / balance baseline and required benchmarks

- For realm growth: sample equal levels r1,2,5,10,11,20,21,30; f1,f10; mix Tu Vi high/Body low and vice versa, potential0/100/1000, add/disable valid equipment sources. Verify no off-by-one around realm10→11 or 20→21; QA at very large r30.
- For combat: same seed and roster should produce identical outcomes viewed and offscreen, independent of FPS, VFX, camera and source art version. Check 0.25s step, max90s, area target cap3, one cast one settle, mid-battle save load, target ID tie, no retry exploit.
- For team archetypes: 6 balanced vs 6 DPS vs 6 heal vs no healer vs off-element build; same monsters over 30–100 distinct seeds, preserve identical tier/level/spawn to isolate composition. Metrics: wins, duration, remaining HP ratio, number downed, effective heal, actual protected damage, control uptime, DPS, target spread, total resource/injury burden. **Do not set universal win-rate quotas without real tests**.
- For multi-team: 2×6, 5×6 vs <=40 monsters, one encounter, shared debuff cap, same-party buff cap, not five independent settlement receipts. Verify player cannot assign a worker/hunter twice.
- For mobile presentation: one Android mid-range handset, 1280×720, >=30 FPS as initial target, load/render memory traced, VFX cull/pool/quality tiers; do not claim PASS from a desktop or static atlas check.
- All remaining missing Godot runners, source variants, NPC/boss identities, safe source mixing and license proof are reported **PENDING**, never fabricated.

## 8. Working agreement / next immediate tasks with no Windows PC

1. User continues uploading **JX1 source versions separately**, preserving original ZIP/PAK/SPR/TXT tables and exact filename hierarchy; no need to wait for all variants before design/manifest ingestion. A chat session with connected Google Drive can inspect files and build indexes where within provider limits.
2. User uploads Source A preferably **both original and converted Batch-01** with SHA manifests and converter settings, prioritized for 2 male + 1 female rigs used in disciple pilot. Do not reconvert 1,016 frames just to recreate an already validated export.
3. Design owner evaluates this master plan. Further docs-only work: build the **one-page canonical stat breakdown UI schema**, **party/formation 6×5 diagram**, **asset registry version schema**, **10 faction battle role kits** and **real skill effect primitive dependency checklist**.
4. Hold C4-VP01 visual branch runtime-PENDING; do not merge/push gameplay. After design gate and targeted Windows QA, pick a focused packet, not a 260-skill bulk migration.

**END — design and source intake only.**
