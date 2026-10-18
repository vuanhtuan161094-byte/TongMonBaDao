# TÔNG MÔN BÁ ĐẠO — COMBAT V4 / JX1 DRIVE ASSET + SKILL AUDIT
**Date:** 2026-10-18 · **Status:** READ-ONLY AUDIT / DESIGN PROPOSAL ONLY · **No runtime CODE permission implied**

## 0. Authority, refs, restrictions

- Github repository: https://github.com/vuanhtuan161094-byte/TongMonBaDao
- Verified main HEAD at audit: `461caca1171462e0da092f21108c5c1733157ad9`. Read `AGENTS.md` (blob `93996e5471b1e889ae239acc1dfcc0efceac3d63`), `docs/GAME_SYSTEM_ARCHITECTURE.md` (blob `55d4b7711920ab0faf0b2cef4dbeeab5b7e3b6ac`), `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`, `docs/COMBAT_STATS_V2_SPEC.md` and live combat source. Treat specs as rules, code as implementation evidence.
- Existing Combat visual-audit packet (different branch, **not main**): https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/combat-v4-thanh-truc-lam-packet-20261018/docs/COMBAT_V4_THANH_TRUC_LAM_IMPLEMENTATION_PACKET_2026-10-18.md
- C4-01 completed independent CODE branch `c4-01-battle-world-cast-schema-20261018`, HEAD `4e2ca7db07c98a021977bbcb026b6be7c958bbff`, **not in main**, focused test source committed but Godot 4.7.2 runtime NOT yet proven. This fixes rendering of target_id/skill_id pending casts without center/radius; any later standalone pilot must explicitly adopt verified C4-01 rather than assume it is in main.
- G1 draft PR #20 pinned HEAD `2219535fc3519ce811265ceed5cb85001efe5e45`, **not modified**. Its Source A actor bundles are not part of `main`; copying them requires separate scoped authorization and manifest verification.
- Scope: personal Godot 4.7.2 project, Android landscape 1280×720; study-only inventory. No CODE/asset import, no PR20/G1/Economy/One Active Job/Warehouse/Scheduler/Save/Injury/G2 changes, no CI/FULL/merge. Future Windows and Android QA = **PENDING**.

## 1. Drive provenance and inspection scope

**User-selected VLTK root:** https://drive.google.com/drive/folders/1OewP9yadkTSAvL0hDNo09G_Wdr0SvRCT

Direct root listing (14 entries): folders `native`, `map-kit`, `status`, `fx`, `training`, `sfx`, `scene`, `char`, `bagui`, `player`, `ui`, `items`; plus `.DS_Store` and `faction-coverage.json`. This is a Drive collection, **not a verified Godot asset release**.

- [char folder](https://drive.google.com/drive/folders/1XsUVi2NW1WmjpQDNjV8qa89bjA26vHLQ): direct folder-fetch returns **the first 100 WebP files only**; results start with `enemy146_*`, `enemy144_*`, `enemy109_*`, `enemy085_*`, `enemy076_*`, `boss103_*`, `boss027_*`, `boss024_*`, `boss019_*`, `boss015_*`, `boss014_*`, `boss012_*`, `boss011_*`, `ani055_*`, `ani038_*`, etc. The folder may contain **more than 100**. Do not extrapolate a total.
- [player folder](https://drive.google.com/drive/folders/13F96N7OZOkOgj-It97nZW9V6k2glJCfH): first **100** WebP returned; examples `fm_rw_021_at02.webp`, `fm_lh_006_st04.webp`, `fm_lh_006_rn01.webp`, `fm_lh_006_at01.webp`. They may represent **layered equipment/body components**, not whole actors; specific named clips/orientation cannot be inferred solely from file suffix.
- [fx folder](https://drive.google.com/drive/folders/10p54W-Re6YcxNn_vXYk3JuIg0N4aqg7c): the direct listing returned **0 entries**. [sfx](https://drive.google.com/drive/folders/18y2BxdS-NOa6IU3qH4MNPYOMf9B2TL-Q), [status](https://drive.google.com/drive/folders/1OB8PvPtbDHDqnd6LKKe6j65_ircZi3i4), [map-kit](https://drive.google.com/drive/folders/1Kr8u0mG6_NMNmu8kpZGu9RhxEb_VV8iF) also yielded no direct items. This does **not** prove the whole source has no JX1 VFX. The actual image/texture-to-skill mapping, SPR/PAK provenance and independent VFX binaries remain UNRESOLVED.
- [native](https://drive.google.com/drive/folders/1bevt8Apeh9PfTUoNWXPnWZm_-JOYSLKB) -> `assets` subfolder, direct listing of that subfolder returned zero entries.
- [faction-coverage.json](https://drive.google.com/file/d/1Nd0gP7swCu3yHIAOtWScwMjMisUCY1N2/view): JSON `generatedAt=2026-10-07T14:48:57.846Z`, `total=260`, `playable=118`, `passiveExcluded=63`, `supportPending=55`, `hybridPending=3`, `attackPending=21`, `sourceIncomplete=54`, `playableWithSourceGaps=26`. **These classify skills in a separate VLTK web/source project only, NOT implementation or art licenses in Tông Môn Bá Đạo**. This source explicitly marks issues including missing sound/sprite paths, unresolved direction and unsupported action resources.
- Independently accessible [ZIP-README.txt](https://drive.google.com/file/d/15soZqu1jqLJt31o-2ECg_zKbeKNRzvL7/view) for a VLTK-sourced community offline project expressly notes redistribution rights for source VLTK assets are **not established**. It is separate provenance evidence; do not assume all of its binaries equal the exact files in this selected folder.

### 1.1 Image binaries actually read and decoded

Read the **real complete WebP bytes** using connected Drive raw download, visually inspected full strips/atlases, checked dimensions with PIL and computed local SHA-256. These checks prove the named sample bytes, **not** source copyright permission, total frames, sprite mapping or a runtime Godot test.

| Drive sample (actual linked binary) | Bytes | PNG/WebP size | SHA-256 | What image proves / DOES NOT prove |
|---|---:|---:|---|---|
| [enemy146_st.webp](https://drive.google.com/file/d/1mJEwssFZT7jd1fIkop-DpSvwEi5EzVSE/view) | 91,676 | 2011×149 | `524e0fd7bcc40fafdec62db53be0f2a2ebb69cac984b493643102a85b0111b64` | Multiple human-character angles; **not a wolf** |
| [enemy146_wlk.webp](https://drive.google.com/file/d/1PQSfOzkiUhaP96hFY3CYXa2apLKc3tLS/view) | 191,684 | 2042×225 | `52280b345d65ad7e03616d11a014543b4d9bfa7f541a92ff13340b68e37711ff` | Human walking poses through several facing angles; label `wlk` corroborated visually |
| [boss103_st01.webp](https://drive.google.com/file/d/18hCmjYTqyu2OIMmcP2Wx553D-ibFuxWF/view) | 813,406 | 2048×1244 | `20387ddac869a4e5a05797bcd2818198ceb9e7da89d7354dc6323c4344661ef6` | Large armored **humanoid** in several orientations; **not Hắc Lang Vương** |
| [boss103_at01.webp](https://drive.google.com/file/d/1zq1aAJbP2FcJ03jPvJas-1TOWcYmTZMg/view) | 968,424 | 2047×1514 | `57998e288d5bff9a19b01f0e917b06331103f1770ef81758f03e28c3b9b160af` | Distinct frames of humanoid weapon swing; **actual action artwork**, but not integrated |
| [ani055_st.webp](https://drive.google.com/file/d/11gcPagGLnrwZtQyuEKufYT5jZOotduc8/view) | 66,184 | 2017×141 | `b73980a265fd908ab09c45c8cae9a0eddef77e730a277700bdeee9902038d6a7` | Small dark creature/figure strip; exact species and wolf identity UNVERIFIED |
| [boss027_st01.webp](https://drive.google.com/file/d/1O6I01MEjwEftcz_IzuCTXhyC2c6OEVKA/view) | 118,646 | 2035×298 | `28fd526c74892d2389b0c474682c5f1bc734464c110e7ef42291cad5112458a9` | Humanoid multiple views, not positively a wolf |
| [boss024_st.webp](https://drive.google.com/file/d/1bTVArpXyVb0LmNa2h503fCpqDIlKaPhX/view) | 132,580 | 2027×305 | `f1516c23fdefd566b66509cabb08b7f51435e6276a11953a6247fa70a8b38559` | Armored humanoid multiple views, not a wolf |
| [boss015_st.webp](https://drive.google.com/file/d/1ognDVArW83HFDz2bHRc1iukff6xj0f8R/view) | 164,812 | 2045×294 | `368301f5babb7d6b513723679455ef65dc947cd2268516c528fa0d654ffe3d9a` | Hooded humanoid multiple views |
| [fm_lh_006_st04.webp](https://drive.google.com/file/d/1GWg3z-tvz7PV69HKz8DBC60ODYMqSwJ4/view) | 11,878 | 928×26 | `2bd1a7bc0d7d350eb5d4616f9889ad090b9aa399e9e4fc6a2b97a225a227bf9e` | Very narrow sheet of lower-body components; cannot call this a standalone playable full-body idle actor |

**Atlas/hướng/clip classification:**
- Some inspected `boss103_st01` and `enemy146_*` sheets visually rotate through front/side/back views with poses. There is demonstrably **more than one authored facing**. Exact direction count (e.g. 8/16), frame order, per-direction strip spans, durations, point-of-origin, blend layers and texture page coordinates **PENDING descriptor/manual frame audit**; never simply hardcode as verified 8-way.
- `enemy146_st` looks standing; `enemy146_wlk` visibly walking; `boss103_at01` visibly performing weapon attacks. `boss103_st01` has idle/stance-like poses. Suffixes `st/wlk/at/rn/die/pst/bat/mg/ij/de` are filename conventions; outside the visually checked files, clip semantics **not positively verified**.
- Some atlas widths sit near 2048 pixels and one boss atlas is 2047×1514; import must test texture memory, filtering, transparency, alpha blending and explicit frame slicing, especially multi-actor Android scenes. Number of frames is **NOT** equivalent to image width or count of sprites visible by eye; descriptor/provenance needed.
- **No positive Thanh Lang or Hắc Lang Vương species ID** in the inspected assets. In particular, do NOT relabel `boss103` as a wolf simply because `boss` appears in its filename. All JX art import remains BLOCKED pending ownership/license evidence and an authorized package.

### 1.2 Rights and gating

Statuses per source family, as of this audit:
- JX character/player/boss/animal WebPs: **BYTES ACCESSIBLE; ART IDENTITY PARTLY CHECKED; RIGHTS TO COPY/DERIVE/DISTRIBUTE UNVERIFIED**. Hosting in a personal Google Drive is not a copyright grant; personal/noncommercial intent does not automatically settle the right to copy or redistribute. No JX binary to GitHub, game build, asset export, screenshots marketed as playable production art without documented permission.
- VFX/SPR/PAK: **UNRESOLVED SOURCE BINARY / RIGHTS UNVERIFIED**. JSON skill catalogue and WebP character strips do not authorize reconstruction or use of missing proprietary sprites.
- Source A rigs (separate PR #20): prior owner-approved private Source A use with manifest-backed stand/walk for female `1113028_1` and male `body_1110201`, `body_1120402`; **not in main**. Existing manifest statements do not prove attack or hit clips; using them in a Combat pilot still requires independent asset-transfer permission and hash check.
- Safe fallback: neutral schematic actors and color-coded VFX/telegraphs, clearly labeled as placeholder, while gameplay is being prototyped. Do not visually misrepresent an unverified wolf as sourced art.

## 2. Actual Combat V2 implementation: 9 definitions vs runtime

Live code at audited `main`:
- `godot/src/simulation/combat/combat_skill_system.gd` blob `275036c94e99d69ffa7be895e969ffe4a067e79f`, exactly nine P2 skills in `SKILLS`;
- `godot/src/simulation/combat/disciple_combat_loadout_v2.gd` blob `912cb8a82ec4c91f0fe10bb852810500c6acc93c` explicitly adds only `effect == "damage"` to `skill_loadout`, keeps all other learned ids in `deferred_skill_ids`;
- `godot/src/simulation/combat/map_battle_v2.gd` blob `fdef96e73343d01c63df9f1408b821e90ca1b0c6` executes `_try_learned_damage_skill()` and only those damage skills via `pending_casts`, alongside generic attacks, basic movement, healer, frontline guard, mage AoE and elite/boss telegraph.

| Skill ID | Authored effect and relevant values | Combat V2 implementation state |
|---|---|---|
| `thanh_phong_tram` | damage, ratio 1.35, range 2, cast 0.30s, CD 2.8s | **EXECUTED as learned skill**; emits `skill_cast` and `skill_hit`, damage settlement |
| `ngu_kiem_thuat` | damage, ratio 1.70, range 7, cast 0.65s, projectile_speed 10, CD 6.5s | **EXECUTED**; `ready_at = now + cast + distance/projectile_speed` and direct hit when ready; **no visible projectile entity** |
| `truy_phong_bo` | dash, ratio 0.75, range 7, cast 0.25s, CD 5s, dash_to 1.35 | **DEFERRED**; no actual dash displacement or associated learned-skill damage |
| `chan_son_quyen` | weaken, ratio 1.45, multiplier 0.82, duration 2.5s | **DEFERRED**; no specific weaken application |
| `kim_cuong_ho_the` | guard, multiplier 0.62, duration 3.5s | **DEFERRED**; generic frontline HP-triggered `guard` is NOT this learned skill |
| `bat_dong_than` | guard, multiplier 0.42, duration 4.5s | **DEFERRED**; generic frontline guard cannot be labeled as this learned skill |
| `hoa_cau` | burn, ratio 1.15, projectile_speed 8, burn ratio 0.16, duration 3.2s | **DEFERRED**; no learned Fireball hit/Burn ticking |
| `han_suong_an` | weaken, ratio 0.90, projectile_speed 9, weaken multiplier 0.72, duration 4s | **DEFERRED**; no learned Weaken duration/expiration |
| `liet_diem` | fire_combo, ratio 1.45, projectile_speed 8.5, burning_bonus 1.35 | **DEFERRED**; no authoritative Burn check/bonus |

**Other real combat:** `MapBattleV2` steps at **0.25 seconds**, with **36×20** logical arena, max **90 seconds**, one group up to **30 disciples** in parties ≤6 and **40 monsters**, AoE cap **3**. For normal movement, actor chooses nearest live enemy, approaches until its basic range, moves by `min(move_speed × 0.25, distance - attack_range + 0.02)`, clamps into arena. Default disciple speed 2.35 frontline / 2.05 elsewhere, monsters 2.2 normal and 1.9 boss, but `DiscipleCombatLoadoutV2` injects actual style/equipment-derived move_speed for real PVE actors; character-specific style base values `sword 3.10/body 2.50/spell 2.70/balanced 2.70` before relevant multipliers. This **is not navigation around obstacles or kiting**. At present `preferred_distance` is supplied by style but not employed by this nearest/approach loop.

**Cast semantics:** pending single-target learned cast packet has `caster,target_id,skill_id,ready,ratio,element` (NO AoE center/radius). Boss/elite AoE packet has `caster,center,radius,ready,ratio,maximum` (NO skill_id/target_id). AoE warns 1.0s boss / 0.75s elite; max three targets; dodge by moving out of fixed announced circle works. `_release_casts()` resolves learned skill hit only if original target alive, never retargets. Actual renderer C4-01 already repairs schema mismatch **on separate branch**.

**Known gaps relevant to JX1 visuals:** no cast-stance sprite assignment or VFX registry in main, no sprite projectile actor, no confirmed full skill status engine for Burn/Weaken/learned Guard, no dash skill path, no verified wolf art. `HuntingPveRunV2` source explicitly says not installed into legacy scheduler. No evidence of gameplay "fully playable 75 JX1 skills" in this Godot repo: those source counters describe a distinct web project.

## 3. Design-to-art mapping — placeholders, NOT verified asset IDs

| Godot skill/real event | Required movement / event truth | Candidate display language; source ID |
|---|---|---|
| `thanh_phong_tram` / `skill_cast→skill_hit` | Authored target and final hit event | Narrow frontal slash; JX VFX asset **NOT IDENTIFIED** |
| `ngu_kiem_thuat` / `skill_cast→skill_hit` | Real cast + travel and delayed hit | Sword projectile interpolation, cosmetic only; ID **NOT IDENTIFIED** |
| `truy_phong_bo` / proposed `skill_dash` | FIRST implement bounded dash in simulation | Short motion streak locked to authoritative start/end; ID **NOT IDENTIFIED** |
| `kim_cuong_ho_the`, `bat_dong_than` / deferred | Need true timed learned guard and expiration | Defensive ring/halo only after guard state exists; ID **NOT IDENTIFIED** |
| `hoa_cau`, `han_suong_an` / deferred | Need true projectile hit + status tick/expiration | Fireball/ice impact; prohibit fake Burn/slow floating labels |
| `liet_diem` / deferred | Need real target-burning precondition/bonus | Flame burst after combo proc only |
| Boss `telegraph→area_release` | Existing center/radius/time and actual targets | Telegraph ellipse + short ground impact, not flood-screen VFX |
| Normal `move`, `hit`, `downed` | Genuine event journal and position/HP | Stand/walk/facing; damage flash/numbers, downed visual (not pretend missing animation clips) |

Rendering should map typed combat events to purely cosmetic profiles. **JX1 skill names, source ID or damage math are never core/gameplay IDs**, and no implicit JX1 balance, resource system, cooldown, mana or RNG imported.

## 4. Three bounded future CODE packets (separate user permission per packet)

These are **new candidate scopes** `C4-SK01`, `C4-VFX01`, `C4-VP01`, *not* authorization and *not* a silent relabeling of the older C4-02/C4-03 packets. Every implementation must read fresh main and check branch overlap/dependencies. No CI/FULL/merge by default; if a code change later crosses a locked contract, communicate need for the applicable gate instead of silently closing it.

### Packet A — C4-SK01: one real mobility skill, Truy Phong Bộ (RECOMMENDED NEXT)
**Allowlist ONLY**:
- MODIFY `godot/src/simulation/combat/disciple_combat_loadout_v2.gd`
- MODIFY `godot/src/simulation/combat/map_battle_v2.gd`
- ADD `godot/tests/simulation/combat_v4_dash_skill_test.gd`

**Proposed small contract:** Admit learned `truy_phong_bo` (existing `effect=dash`) alongside the two damage skills, still defer the *remaining* Weaken/Guard/Burn/Fire combo types. In a deterministic `MapBattleV2` step, if a live target is farther than `dash_to=1.35`, within skill range and skill CD ready, commit a single dash action with the existing authored cast 0.25s, move toward (NOT through) the target and stop at declared distance, keep inside arena, emit a real typed `skill_dash` (with caster/start/end/target/time) and apply existing `damage_ratio=0.75` only **if the owner separately confirms** whether dash deals damage at arrival. If target dies or becomes invalid during committed cast, enforce a deterministic cancel/no retarget policy. No teleport animation authority; renderer later interpolates along actual start/end. Do not change `CombatStatsV2`, P2 `CombatSkillSystem.SKILLS` or third-party source data without expanded authorization. Resolve semantic decision (dash ratio as damage yes/no) **before CODE**.

**Focused gate:** genuine learned skill eligible only at correct cultivation stage; actual loadout admission and residual deferred skills; in-range/out-of-range/nonpositive distance, obstacle-free arena clamp, target disappears mid-cast, single-use/CD, actor actions exclusivity, saved event journal determinism, repeated-seed fight exact equality; legacy direct-damage `thanh_phong_tram`/`ngu_kiem_thuat` release unchanged, monster telegraph/dodge and 3-target cap unchanged. Existing `godot/tests/simulation/dv2_02_group_map_battle_test.gd` focused adjacent regression. Must use official Godot 4.7.2 runtime when available; no fake PASS. This is an **opt-in gameplay change**, not justified merely by reading Drive.

**Explicitly out of scope:** Burn/Weaken/Guard/Fire combo implementation; if desired, each effect family requires its own later CODE packet due to status persistence, stacking, damage, cleanup, determinism and save semantics. C4-SK01 does not "complete nine skills".

### Packet B — C4-VFX01: read-only event→VFX descriptor adapter
**Allowlist ONLY**:
- ADD `godot/src/presentation/p3/combat_v4_skill_vfx_adapter.gd`
- ADD `godot/tests/presentation/combat_v4_skill_vfx_adapter_test.gd`

**Contract:** Pure adapter reads battle `events`, actor map positions/HP and `pending_casts` snapshot; produces typed, bounded descriptors: slash cue for `skill_cast/skill_hit`, cosmetic sword projectile with duration derived from real `release_at`, dash trail only from real `skill_dash`, boss warning from real `telegraph/area_release`. No fake hit, rollback, burn/guard icon, damage numbers or automatic target retargeting. No new RNG/clock in simulation; de-duplicate by stable encounter_id/event index and bounded active-VFX budget (suggested cap **8** lightweight effects onscreen, **pilot proposal not locked**). Distinguish genuine cast vs AoE packet schema. No JX1 binary import; descriptors may resolve to neutral geometry fallback. Account for event journal `time` values, scene headless test and same-seed no observer effect.

**Focused gate:** zero mutation of actors/time/RNG/events/scheduler/warehouse/save, exact one cue on real cast, projectile cue ends at true hit-time, real boss telegraph never suppressed, old cast-schema crash absent when using authorized C4-01 code, replay deterministic, no leaked effects after repeat/fast-forward, unsupported/deferred skills render no invented state. Parse/import if Godot runner; Android GPU/FX density PENDING.

### Packet C — C4-VP01: standalone 1280×720 Combat visual pilot
**Allowlist ONLY**:
- ADD `godot/scenes/p3/combat_v4_thanh_truc_lam_pilot.tscn`
- ADD `godot/src/presentation/p3/combat_v4_thanh_truc_lam_pilot.gd`
- ADD `godot/tests/presentation/combat_v4_thanh_truc_lam_pilot_test.gd`

**Dependency gate:** Requires explicit owner-authorized composition of compatible C4-01 renderer fix, C4-SK01 gameplay and C4-VFX01 adapter; don't pretend disconnected independent branches are on main. If some steps are not approved, pilot must consciously use only code actually present on its base branch, without fake dash or JX art.

**Contract:** Bounded reproducible **demo-only** `thanh_truc_lam` showcase with ≤6 disciples/party and actual monster catalogue `thanh_lang` / `hac_lang_vuong` snapshots, HP, caster/target cues and boss warning on readable Android landscape 1280×720; no real hunting/loot/sect state changes or new rewards, no action placeholders falsely called licensed character sprites. Actor circles/neutral silhouettes must explicitly say schematic while wolf/attack art rights blocked. Use minimum Node2D draws rather than 1 Sprite2D per transient particle. Optional source-A stand/walk or licensed JX sprites require a **new separate, exact binary allowlist and rights evidence**; no implicit PR20 cherry-pick.

**Focused gate:** both normal and boss seeded scenes run to legal outcome, visual observer does not change simulation result, telegraph visible before actual release/dodge, at most 6 in one party/30 across groups, no save/warehouse/player owned objects touched, HUD does not overlap 1280×720 hitboxes, effect cap measurable; visual Windows and real Android touches/FPS PENDING until user hardware. No CI/FULL/merge.

## 5. Outstanding evidence, priority, owner handoff

- **RIGHTS BLOCKER:** no documentation granting reuse/distribution rights for JX1 character/Boss/sprite/VFX binaries. Owner must provide documentary rights or licensed alternative before game repo import; private Drive ownership is insufficient.
- **WOLF ID BLOCKER:** visually inspect the remaining `char` folder beyond the first 100 entries if provider pagination is available; require a species manifest mapping wolf ID to actual atlas and frame layout, not a filename guess. No specific wolf positively verified.
- **FRAME METADATA BLOCKER:** identify per-sprite frame rects, direction groups, durations, anchor/foot offsets, layered `player` body/armor composition, alpha/transparency; first nine downloaded sample hashes above allow reproducible read-only comparison.
- **VFX BINARY BLOCKER:** direct `fx` folder empty in read, separate web source claims VFX capability but that is not an actual authored Godot-ready `*.spr` / `*.webp` match. Asset-identity-to-skill mapping pending.
- **GAMEPLAY TODO:** six of nine P2 skill metadata effects are not mapped to specific effects in `MapBattleV2`; step A intentionally adds one mobility case, leaves five unsupported. Sequential packet required to develop each status family.
- **TEST BLOCKER:** no fresh Godot 4.7.2 focused run on this read-only audit. Windows GUI / Android target / owner art and UX acceptance all PENDING.
- **NO CODE/MERGE:** this docs-only branch must not be mistaken for C4-SK01 authorization or C4-01 merge; `main` and PR20 must remain unmodified.

### Recommended ready-to-send CODE authorization (narrow C4-SK01)

TÔNG MÔN BÁ ĐẠO — TÔI CẤP PHÉP CODE C4-SK01 (TRUY PHONG BỘ). Đọc main HEAD mới nhất, AGENTS.md, GAME_SYSTEM_ARCHITECTURE.md, COMBAT_SKILLS_V2_SPEC, COMBAT V4 packet Thanh Trúc Lâm và tài liệu kiểm toán JX1 tại nhánh docs/combat-v4-jx1-drive-skill-audit-20261018. Tạo nhánh CODE độc lập từ main HEAD được xác minh. Chỉ sửa godot/src/simulation/combat/disciple_combat_loadout_v2.gd và godot/src/simulation/combat/map_battle_v2.gd; thêm godot/tests/simulation/combat_v4_dash_skill_test.gd. Thực thi Truy Phong Bộ khi đệ tử thực sự học: dash deterministic đến khoảng cách dash_to=1.35 theo dữ liệu hiện có, giới hạn 7 đơn vị, thời gian 0.25 giây, CD 5 giây; không chồng hành động/retarget tùy tiện, đúng ranh giới 36×20, event thật. Xác nhận trước khi code rằng damage_ratio=0.75 sẽ áp dụng đúng một hit ở cuối dash, hoặc nếu tôi không chấp thuận damage thì giữ 0 hit; không tự đổi balance. Giữ 2 learned damage skills cũ, deferred Burn/Weaken/Guard/Fire combo, không sửa CombatStats/legacy/save/scheduler/economy/G1/PR20. Chạy focused test nếu có official Godot 4.7.2 runner; không CI/FULL/merge, không claim Windows/Android PASS. Không nhập asset JX1 chưa có chứng cứ bản quyền, không mở C4-VFX01/C4-VP01.
