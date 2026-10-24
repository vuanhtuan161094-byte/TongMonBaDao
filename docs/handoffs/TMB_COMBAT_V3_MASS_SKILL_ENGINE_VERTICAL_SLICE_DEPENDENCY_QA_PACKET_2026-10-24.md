# TMB COMBAT V3 — IMPLEMENTATION DEPENDENCY AND MULTI-DISCIPLE ACCEPTANCE PACKET
Date: 2026-10-24 | **DESIGN ONLY, NOT CODE APPROVAL**. No change to Godot, PR29, UI, Source A, or GitHub Actions. Do not merge.
Main base 29b5fba448b0178cb520a4ada44b375b4b934e31; PR29 S1 at 9522812e91b7ca5bc0cc108eb92e000e930fe850 OPEN/DRAFT focused QA PENDING.
Parent design doc: `docs/design/TMB_COMBAT_V3_MULTI_DISCIPLE_JX_SKILL_ENGINE_ARCHITECTURE_2026-10-24.md`.

## 0. NON-NEGOTIABLE IDENTITY
TMB is a SECT management simulator with **many active autonomous disciples on the map**. JX ideas are a source for skill mechanics, NOT a standalone hero-based combat engine. Existing Combat V2 owns damage/HP/status, one authoritative sim clock, one Warehouse/CARE receipt, One Active Job, Injury 0/1/120 and same-build save; Source A controls visuals only.
Population design target 1,000–3,000 disciples, but local `MapBattleV2` currently caps **30 disciples/40 monsters** in one arena with **6 per party**. Multiple local encounters in one world are a new coordination feature, not permission to raise battle hardcaps or duplicate boss HP.

## 1. Writer/dependency graph

| Packet | Requires | Owner / candidate files to inspect (NOT a write authorization) | Outcome |
|---|---|---|---|
| S1-QA | existing PR29 | MapBattleV2 / CombatSkillSystem / Snapshot test evidence | Godot 4.7.2 official S1 focused proven; do not claim green from static review |
| S2-P2 | S1 verified or traced blocker | `godot/src/simulation/combat/map_battle_v2.gd`, `combat_skill_system.gd`, Snapshot, targeted tests | Truy Phong Bộ dash & Liệt Diễm payoff correctly executed; current P2 numeric coefficients preserved |
| SK-A Schema | S2 baseline + separate owner code approval | CombatSkillSystem, DiscipleCombatLoadout, catalog validation and focused tests | Validated typed skill/loadout schemas, invalid rows fail closed, no 5th active |
| SK-B AI | SK-A, source role/skill priority review | MapBattleV2 and target selectors; no concurrent S2 writer | 4 active ordered eligibility + basic fallback, no generic heal/guard starvation |
| SK-C Multi-hit | SK-B | MapBattleV2 effect resolver, status/proc/snapshot tests | one authored two-hit projectile + a single non-recursive proc; one actual hit per intended packet |
| SK-D Multi Encounter | SK-C + world ownership decision, B3 CARE gates | isolated WorldHuntCoordinator proposal + canonical scheduler + MapBattle adaptor | 2+ concurrent encounters, 5 parties in one boss encounter, shared kill pool |
| SK-E Growth | SK-D or separately bounded data owner | Skill mastery, Main/Support technique, RootV2 and Sect archive canonical | real learned manuals, mastery XP5, original skill descendant; no old P2 migration |
| SK-F Presentation | backend semantic events exist, UI owner explicit authorizes | only presentation team Source A event mappings | visible 1280x720 readable, no fabricated hits; off-camera gameplay unchanged |

**NO SINGLE packet authorizes all rows.** A future coding request must name exact scope, latest SHA, permitted file paths, owner worktree, target QA and rollback, with no overlapping Codex writers. Graph is ordering guidance, not a permission slip.

## 2. The smallest interesting real gameplay slice
Sample 18 disciples in three 6-person parties on the same battle map:
- Team F1: Body frontline/guard, Sword bruiser, 2 Sword/ranged, 1 Fire Pháp, 1 healer.
- Team F2: Body frontline, 2 Fire Pháp, 2 Sword, 1 support.
- Team F3: 2 Body, 2 Sword, 1 Water Pháp, 1 healer.
Roles are **illustrative deployments**, not mandatory new path content.
- 24 mobs spawn in legal slots with unique generations. Every disciple has exact learned active loadout, 1 basic fallback. All do not have 11 skills by default.
- Fire Pháp1 uses `hoa_cau` applied real Burn; `liet_diem` checks Burn on impact; passive secondary proc from a different authored new skill triggers once only (when SK-C exists).
- A frontline `guard` changes actual incoming damage; a healer only heals effective missing HP of eligible allies; Water weaken affects actual damage.
- F1 and F2 can attack same Elite or Boss in one MapBattle; target has one HP bar, one kill ID and one domain reward receipt; participation measured from actual contribution.
- With camera in another zone, same encounter still proceeds under canonical sim clock; when user returns, health/status/loot and mastery are unchanged from a non-rendered reference.
- Extra teams beyond per-encounter 30 cannot join; coordinator gives truthful WAIT/redirect status with no hidden Boss cloning or additional loot.

### Staged playable targets
- **Slice 0:** 6 vs 8: existing 9 skill sample baseline, snapshot and movement.
- **Slice 1:** 18 vs 24: deterministic eligibility/role, heals, team-targeting, status, combo with existing skills.
- **Slice 2:** 30 vs 40: 5 teams, multi-hit/proc and congestion, no phantom kills.
- **Slice 3:** at least 2 isolated local encounters: separate RNG, actor namespaces, world scheduler, offscreen camera parity and save/restart.
- **Slice 4:** roster 1k→3k with small count of actually deployed teams; measure and optimize policy scheduling, no 3,000 per-frame actor scan.

## 3. PROPOSED typed mechanics demonstration contract (not current implementation)

### 3.1 Multi missile
`FanMissile` authored example: 3 missiles flying from one cast; hit policy `per_target_per_cast=1` by default unless explicit multi_hit=allowed, with target cap 3 and individual projectile collision. This shows three visible projectiles but does not guarantee 3× damage on same monster. Test misses, skill range, heading, target dies, spawn generation reset. Do not copy unknown JX MisslesForm enum as native Godot enum.

### 3.2 JX-style two-step combo
`HoaCau` Burn opener (PR29 S1 runtime QA pending); `LietDiem` single-target Burn payoff (S2 deferred). Existing P2 coeff 1.45 ATK ×1.35 if valid target Burn at impact; authored combo condition could skip slot when no Burn, **but do not append an extra 1.35**. Successor-family AoE variant comes later and requires explicit content approval.

### 3.3 Bounded reactive passive
Example new `Hỏa Chủng Dư Uy` **PROPOSED name, not source**: proc only when a valid main Fire hit lands; once per source cast, at most one child hit on the SAME target or one stack increment (choose through owner content); proc cannot proc itself; each passive uses its own internal cooldown. Measure its actual damage/CPU to prevent scaling runaway with 30 mages. No free proc for passive not genuinely learned/equipped.

### 3.4 Defensive skill and multiple groups
`KimCuongHoThe` personal guard in S1. A proposed ally guard must require authored side/party/radius and source caster, not implicitly protect all 30. Heal priority should not repeatedly target full HP or members of other squads unless the skill explicitly authorizes cross-party support. Strongest-status-only S1 remains baseline; new stackables require new effect TYPE.

## 4. Snapshot and event ledger
Event IDs: `encounter_id/actor_id/cast_seq/child_index/hit_index/target_spawn_generation`.
Use immutable skill definitions and stored effect/cooldown state; individual actor state contains learned/equipped skills, per skill cooldown, pending cast, expiry status, combo window, proc ICD; serializing only VFX flags is unacceptable.
Transaction edge: hit resolves exactly once → HP0 once → pending kill event contains `encounter_id:spawn_slot_id:generation` → CARE PH2 durable warehouse/loot receipt → ACK only after commit. A cap on the 2400 presentation events MUST NOT lose any gameplay receipt. Multi-projectile children cannot cause a second kill event if target already 0.
Save same-build at four points: just before cast, after cast commitment, between projectile release and impact, after monster death before reward ACK. Replay must match HP, RNG, status, source ids, item counts and personal XP; no old DEV save migration needed.

## 5. Focused QA gate table (future CODE packets only)

| QA fixture ID | Exact test scenario | PASS evidence |
|---|---|---|
| SK-G01 | skill data invalid ID, slot >4, malformed geometry/negative cooldown/unbounded procs | rejects fail closed, no combat modification |
| SK-G02 | 4 active priority heal/guard/burn/finisher; slot1 invalid while slot2 ready | correct next skill, no generic role starvation |
| SK-G03 | 3 projectiles, one victim; target moving and boundary at exact range | expected authored hit policy only, no extra damage |
| SK-G04 | two-hit cast into Boss HP near zero | one kill journal row and one receipt, not two |
| SK-G05 | one caster passive fire proc and 30 mages proc stress | hard cap/ICD, no recursive event explosion |
| SK-G06 | status stack/strongest-only policy, Boss control resistance | stable status, no permanent lock or infinite stack |
| SK-G07 | 3 parties 18 vs24, party-only heal, area buffs, smart target | correct ally scope, deterministic target ordering |
| SK-G08 | 5 parties 30 vs40 plus one Boss | never exceed actor slots; one shared HP and kill pool; no silent target overflow |
| SK-G09 | two encounters share a map; actor IDs and RNG | distinct encounter identity, no cross-zone damage/loot |
| SK-G10 | camera visible vs hidden over fixed seed/ticks | authoritative HP/status/loot/loadout identical; VFX may differ |
| SK-G11 | snapshot at cast, impact, after kill before ACK | exactly equal replay state and no reward duplication |
| SK-G12 | 1,000 and 3,000 total disciples with few deployed | no 1k–3k per-frame AI loops; measure CPU, memory, queue backlog |
| SK-G13 | map camera free pan + Source A animations | no automatic player-follow lock; only visible actors rendered; visuals cannot issue gameplay hits |
| SK-G14 | starved simulation queue/backpressure save/restart | no lost HP0 receipt, no duplicate rewards, deterministic catch-up |
| SK-G15 | One Active Job, Injury1 at tick119/tick120, manual AUTO OFF | no illegal redeploy, no phantom mastery or pill use |

**Actual QA policy:** Godot 4.7.2 official runtime, source SHA, actual test file path, command/args/exit code, stdout/stderr, true assertions. Separately benchmark physical Windows 8GB and target Android landscape 1280×720 using profiler: sim milliseconds per canonical tick, event backlog max, 1% worst frame times, peak RAM and visible actors/draw calls. Never label unexecuted fixture PASS. Benchmark criteria/proposed event ceilings are NOT canonical numbers yet.

## 6. Key risks requiring design sign-off
1. **S1 may not have passed**; do not work in its shared combat files concurrently.
2. **Generic role heal/guard before learned skills** is live precedence today; the 4-slot AI change must preserve legitimate fallback or remove only by authorized owner decision.
3. **Offscreen** requires exact deterministic combat rules. If thousands of combat actors cannot fit time budget, deploy fewer concurrent teams / increase real catch-up latency / backpressure, NOT fake offline loot.
4. **One Boss** should live in only one encounter. If an encounter has reached the 30v40 cap, queue additional teams rather than create duplicate boss.
5. **B3 participation** DPS/Tank/Heal/Support must be verified via effective contribution, no last-hit theft. Allocation formula 60/40 NOT locked.
6. **Proc loops and source attribution** need strict cast/packet depth+count caps and target spawn generation. UI/Source A animation can be offscreen, but hit packet must still settle.
7. **Data import** JX image libraries or numerical formula not necessary to implement these mechanics; JXQY2 magic INI effect field unknown, JX online raw tables missing. Do not block practical engine on further JX extraction.
8. **No migration of legacy dev disciples** across new gameplay versions by owner rule; **within-build** atomic save/replay/kill outcomes remain mandatory.

## 7. Completion and owner review choices
- **DESIGN DOC READY** means these two docs exist and compare GitHub shows docs-only changes, NOT code/performance done.
- **NEXT CODE GATE (not issued here)**: after S1 focused QA, owner may authorize a narrow S2 implementation and targeted official tests.
- **NEXT DESIGN GATE**: owner may request detailed 4-slot AI precedence and priority/condition vocabulary + event identity spec, or a 3-party on-map worked trace.
- No merge or PR creation; no status uplift for S1, CARE, Source A or Windows/Android acceptance.
