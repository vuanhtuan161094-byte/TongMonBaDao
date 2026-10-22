# TÔNG MÔN BÁ ĐẠO — B3 V2: NGƯỠNG ĐÓNG GÓP BOSS / RÚT LUI / FIXTURE

**Ngày:** 22/10/2026 · **Loại:** DESIGN / PROPOSAL / PHÂN TÍCH FIXTURE TĨNH · **KHÔNG CODE**, **KHÔNG MERGE**, **KHÔNG GODOT QA PASS**, không đụng Source A Codex.
**Repo:** vuanhtuan161094-byte/TongMonBaDao, main = 461caca1171462e0da092f21108c5c1733157ad9, docs branch = docs/b3-v2-architecture-redesign-20261022.
**Parent:** [Boss co-op & split](B3_V2_BOSS_COOP_PARTICIPATION_STONES_ANTI_EXPLOIT_CONTRACT_2026-10-22.md); [Loot/Progression](B3_V2_LOOT_BOSS_DISCIPLE_PROGRESSION_ECONOMY_CONTRACT_2026-10-22.md); [World](B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md); [Team AI](B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md); [Monster AI](B3_V2_MONSTER_AI_SPAWN_ELITE_BOSS_WORLD_CONTRACT_2026-10-22.md).

## 0. Kết luận sau khi chủ dự án chấp nhận HƯỚNG THIẾT KẾ

**APPROVED IN PRINCIPLE by owner in chat (22/10):**
1. One Boss instance/HP, multi-team, one Sect-owned loot pool, one kill key/receipt; no last-hit ownership.
2. DPS/Tank/Healer/Support **eligible via genuine causal gameplay evidence**, no phantom buffs/heals.
3. One authorized Sect share of Stones, then **equal personal distribution among eligible**; exact Sect cut (including 60/40 example) **NOT LOCKED**.
4. Tu Vi personal according to own cultivation stage, rank/challenge/valid participation; not one shared XP wallet.
5. No 90s encounter; no new damage/skill/clock authority; no duplicate loot/XP on Save/reload, camera, team swap or Boss return.
6. One Active Job, Injury 0/1/120 tick, gear Sect-owned, full canonical Warehouse.
**OPEN and not silently approved:** numeric eligibility thresholds and role normalization; what counts as an emergency one-action save, contribution decay/window on retreat; Boss epoch/reset/healing; zero-eligible Stone fallback; particular Boss drop/economy rates; full event instrumentation/production SaveService.

## 1. Evidence audit: Combat V2 source fixtures vs hypothesized events

**Verified source on GitHub main:**
- godot/src/simulation/combat/map_battle_v2.gd: STEP_SECONDS=0.25, sorted actor IDs, hit event with actual_damage; heal uses MIN(missing HP, healer attack ×1.80), only same party and ally HP ratio <0.65, skill cooldown 5s; frontline guard activates when HP ratio <0.75, lasts 4s with next skill at 9s; guarded incoming damage uses damage reduction multiplier of remaining damage ×0.65. Guard event currently gives activation/until **not prevented damage**.
- godot/src/simulation/combat/combat_stats_v2.gd: settle_damage_and_lifesteal caps actual damage at target current HP; direct-hit formula Attack × (2×Attack)/(2×Attack+effective Defense) × ratio × relevant modifiers; crit/lifesteal actually owned by Combat V2.
- godot/src/simulation/combat/monster_catalogue_v2.gd: boss ID hac_lang_vuong; realm1/floor1 base monster HP 190 × 1.15 species × 2.50 boss = **546.25**, Attack 23×1.15×1.30 = **34.385**, Defense 19×1.00×1.18 = **22.42**. These are **pilot code values**, not permanent global Boss balance.
- godot/tests/simulation/dv2_02_group_map_battle_test.gd: real authored fixture 6 disciples (four role variants repeated), 6v5 Boss+escorts; tests same-party healer scope, Boss telegraph/release, 30-person shared encounter, ordering/RNG parity; printed seeded 16× scenario summary win/downed/time but **test script is not an exported per-action Boss reward trace**.
- docs/COMBAT_SKILLS_V2_SPEC.md §§7,27–30: support participation allowed, party buff scope exact, target debuff cap global, skill meaningful effects only. docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md §§12,13,16: meaningful participation 0.8–1.0, low 0.4–0.7 as starting **design ranges**, V1 equal personal Stone share recommendation.
- Source B2.4 supplied ZIP uses opt-in continuous sandbox but **not** live multi-channel receipt/real Boss role ledger. Main still finite on WIN/DEFEAT/90s; cannot call this production.
**NO GODOT RUN THIS TURN**. The numeric vectors below are **hand-constructed deterministic design fixtures anchored to actual formulas/code**, not measured simulation logs. They are not evidence that runtime currently distributes rewards fairly.

### 1.1 Reproducible numeric baseline, seed-independent/no crit fixture

All relevant stats are from the **actual realm1 pilot** (not Source A art):
| Quantity | Code-derived value | Calculation |
|---|---:|---|
| Boss HP | 546.25 | 190 × 1.15 × 2.50 |
| Boss Attack | 34.385 | 23 × 1.15 × 1.30 |
| Boss Defense | 22.42 | 19 × 1.00 × 1.18 |
| Disciple base MaxHP / Attack / Defense | 190 / 23 / 19 | CombatStatsV2.derive(1,1,1,1,0) |
| Disciple uncrit basic against this Boss | about 15.463315 | 23 × 46/(46+22.42) |
| Boss uncrit basic against base disciple | about 26.941511 | 34.385 ×68.77/(68.77+19) |
| Same Boss hit with active guard on disciple | about 17.511982 | previous value ×0.65 |
| Actually prevented when that guard is in effect | about 9.429529 | difference **requires a new domain event**, cannot read from guard activation icon |
| Healer base potential heal per lawful cast | up to 41.4 HP | 23 ×1.80; actual capped by missing HP |

These outputs omit crit, elemental bonuses, context, lifesteal, learned skills, spatial/cooldown limits except where stated. They **must not** be copied as runtime balance rate.

## 2. Proposed eligibility: hard validity first, meaningful actions next

**Hard validity (mandatory direction, no numeric threshold):**
- canonical disciple and authorized team/job at time of effective action; Boss source monster_instance_id/generation match; actor HP>0 and engaged legally when action committed; immutable action_id; same-party target support and provable boss-origin link; no scene/VFX-only/AFK/nameplate credit;
- actual HP delta/effect with source provenance, bounded by target current HP/real missing HP; unknown event consumer → **PENDING_EVIDENCE**, never fictional positive support amount;
- Frozen BossAttemptEpoch and policy_version, one contribution ledger keyed by disciple_id (not team roster), no contributor duplication on team switch.

**Candidate T1 (“2 actions + 3% direct damage”):** a DPS with ≥2 distinct valid damage actions and cumulative actual Boss HP loss ≥3% of Boss initial HP in the *effective attempt* is a meaningful contributor; **OR** one single truly large authorized hit that removes ≥10% Boss HP (supports rare impactful burst skills). For pilot HP 546.25, 3% ≈16.3875 and 10%=54.625. One basic (~15.46) misses 3%, two basics (~30.93) may qualify; a tiny last 0.5 HP tag (0.09% HP) does not. These percentages are **trial candidates, not locks**.

**Candidate T2 (role-faithful tank):** tank has ≥2 distinct Boss-origin damaging actions it actually endured (source verified) during same active attempt; **OR** an authored single life-saving mitigation effect whose actual prevented amount reaches an evidence-based emergency threshold. One may use a *fixture* threshold ≥15% of own MaxHP (190×.15=28.5) actual prevented, but current guard hit only prevents ~9.43 and would not qualify under this single-hit exception. Tank credited for genuine involvement even if low DPS; **never award combat contribution just for taking arbitrary self-damage**. The 2-hit policy can be gamed by deliberately taking hits; combine with legal engagement, risk and cap/attempt rather than inflating payout with repeated hits. Future instrumentation should record Boss-origin actual damage + avoided damage separately.

**Candidate T3 (role-faithful healer):** healer executes ≥2 distinct actual useful heals to engaged same-party allies, totaling nontrivial restored HP **and each causally linked to Boss-origin wounds**, OR one **true emergency rescue** on a critical ally (e.g. ally HP ≤25% MaxHP immediately before heal and ≥15% ally MaxHP effective restoration; example MaxHP190, effective41.4 possible). Require source-correlated wounds/engagement; healing after battle, full HP, another party or unrelated monster farming gives zero Boss participation. No raw “heal points = DPS points” mapping. A single heal to an already injured but stable actor does not automatically count as emergency.

**Candidate T4 (support):** ≥2 genuinely useful, applied Boss-linked authored effects or 1 verified fight-saving effect. Require causal effect record (shield **absorbed**, not merely cast, buff useful, debuff/control applied and legal); if no domain event consumer exists in current kernel, feature is **BLOCKED_EVIDENCE**, not fictitious credit nor forced DPS. Do not treat every support skill label as proof.

**Candidate T5 (partial / no participation):**
- PARTIAL: one legal but insufficient useful action; design starting participationMult 0.4–0.7 in P3.7 **only after owner chooses a concrete policy**. Under recommended simple money V1, PARTIAL does not yet receive full personal Stone share; other reward channels may get discounted legal progress.
- ELIGIBLE: passes T1/T2/T3/T4 and hard validity; equal personal Stones; participationMult approx 0.8–1.0 starting range (not rate locked).
- INELIGIBLE: only AFK/camera/team membership/overheal/guard button, invalid job/skill or mere tiny tag = no Boss personal credit. If no valid contribution, XP and Contribution may be zero in proposed V1.
- PENDING_EVIDENCE: actual authored support effect lacks typed domain event → postpone that source/channel; *do not silently change healer into DPS requirement*.
- Don’t aggregate nontrivial but unrelated actions to meet a synthetic action count (e.g. 1 Boss hit + 1 heal of a miner).
- Single-action exceptions need genuine high impact and reliable evidence. Thresholds must be tuned with real deterministic combat logs, not made canonical now.

### 2.1 Why choose typed thresholds rather than one total score?

A universal numeric score would compare unrelated units: 15 Boss HP damage vs 41 healed HP vs a guard that did not prevent damage. This is not physically valid and rewards whichever role produces the easiest large number. The **same eligibility outcome can arise through different role-specific evidence**, then Stone share is equal among truly eligible. Personal Tu Vi derives from source multiplier + a bounded participation band, not from personal Stone split.

### 2.2 Benchmark variants to compare before signoff

- **P0** = ≥1 legal useful action (very permissive) → false positives tiny last-tag, overheal can be excluded but 0.5HP last hit qualifies; do not choose as production.
- **P1** = ≥2 legal actions + 3% Boss HP DPS; tank/healer 2 useful Boss-linked actions; emergency single-action exception (recommended *trial*).
- **P2** = ≥5% Boss HP plus 3 damaging actions, 3 Boss hits/tank or 3 heals/support (stricter; risks excluding burst healer or short Boss fights).
- Run all three on identical Boss seeds + roles and report: true/false eligibility, DPS/tank/healer admission, late-join, tag-leech, downed/withdraw, p50/p90 role coverage. **Do not declare P1 best before actual replay.**

## 3. Withdrawal: combat authority vs reward eligibility are two different decisions

**Physical retreat** is Team AI/Combat V2 action: based on real `DiscipleState.retreat_hp_ratio()`, HP0, supply/injury, boss danger, owner order, safe withdraw barriers, single world time. Actor stops initiating actions from legal barrier; already committed projectile follows existing V2 cast rules. Retreat does not teleport or grant item; world and Boss remain.

**Reward eligibility after retreat** is contribution evidence decision. Proposed distinction:
1. **SAME ACTIVE ATTEMPT, Boss still wounded and damage retained:** preserve previous real damage and Boss-linked tank/heal/support evidence as candidate until death. Retreat stops *new* contribution; no blanket penalty for saving team. Prevent arbitrary late return becoming duplicate entry; one disciple_id.
2. **Boss partially heals:** reduce **outstanding effective-damage credit** proportionally or by a separately specified deterministic loss-attribution policy to match restored Boss HP. Recommended **proportional attribution** for reward-credit only (NOT HP/damage formula); no retroactive reversal of already-valid action mastery. Allow preheal/guard support evidence only while causally tied to the effective surviving attempt; otherwise reset/cap based on owner policy. Example: Team A removed 120 HP, Boss restores 60 while alive; A's outstanding kill-credit could become 60 under proportional model.
3. **FULL DISENGAGE / AUTHOR-APPROVED RESET EPOCH:** old attempt actions retained for audit, **no credit carried** to later kill if owner approves reset semantics. Do not change Boss generation, create loot or move world clock; reset condition must be explicit, not triggered by camera leaving area.
4. **No death event:** no kill receipt; a team can retreat forever without generating Boss loot.
5. **Retreat timing window:** pure fixed 30s/60s eligibility window can punish slow Boss kills and healers; recommend primarily **causal survival of contribution** + configurable maximum staleness/dwell if gameplay abuse measurements warrant it. Exact time threshold **OPEN**. Test sensitivity 0s, 60s, 180s only as *fixtures*, not live rule.
6. **Downed:** stop contributions at HP0; prior valid effective actions remain candidate under same attempt; apply Injury0/1/120 once via canonical scheduler, not new Boss receipt. No automatic full reward simply for being on roster.
7. **Boss switches target/team:** no impact on contribution if same Boss generation and effective attempt. Party-only healing provenance must be preserved at time of action.
8. **Boss is fought but returns home without authorized reset:** contribution eligibility is unresolved until future actual kill; **do not silently start new payout or clear old credits**. If storage indefinitely is a concern, owner needs a formal epoch expiration/compaction rule.

### 3.1 Boss healing attribution and conservation

Recommended pure *reward-accounting* invariant:
- effective boss damage credited for kill contribution cannot exceed **actual Boss MaxHP** on the terminal generation/attempt, unless explicitly authored special health phases create additional legitimate HP pools;
- healing/regeneration should not allow the same player to accumulate infinite credit for repeatedly damaging restored HP. Maintain outstanding credited damage claims by source_action and apply recorded Boss healing against claims deterministically (recommended pro-rata across active damage claims). This is **not combat damage modification**.
- Sample: Boss HP 546.25; Team A deals 120 → current 426.25; Boss heals 60 → current 486.25, A outstanding claim 60. Team B then deals 486.25 → Boss dies, total outstanding 60+486.25 = 546.25. Without decay, sum raw 120+486.25 = 606.25 > Boss HP → farmable contribution inflation.
- Boss full HP heal after A deals 120 ⇒ outstanding A claim 0; if a real epoch reset is approved, all legacy support evidence enters audit-only epoch and cannot qualify for later kill.
- **OPEN edge**: if some incoming damage cannot be attributed (environment, summon without actor owner), keep an unassigned claim so proportional healing and HP conservation still close; never grant phantom disciple share.

## 4. Concrete fixture vectors (NOT actual Godot gameplay logs)

### F01 — Shared Boss HP, 2 teams, 6 actors

Boss HP=546.25 (source-derived). The vector assumes **a sequence of legal V2 combat results** over time, not one simultaneous basic attack, with these accumulated **actual** HP reductions:

| Actor | Team | Useful actions | Boss HP removed | Other boss-linked evidence | Expected P1 candidate |
|---|---|---|---:|---|---|
| DPS-A | A | Multiple normal/skill hits | 270.00 | Active over fight | ELIGIBLE |
| TANK-A | A | ≥3 real basic hits | 40.00 | ≥2 Boss-origin hits taken while guarding | ELIGIBLE |
| HEAL-A | A | 2 legal effective heals | 0.00 | Heals 20 + 30 HP on Boss-wounded ally, each ≤41.4 and same party | ELIGIBLE |
| DPS-B | B | Multiple normal/skill hits | 235.75 | Active over fight | ELIGIBLE |
| BUFF-B | B | Repeated nonfunctional/irrelevant buffs | 0.00 | No actual causal effect | INELIGIBLE |
| TAG-B | B | One late legal attack when Boss has 0.50 HP | 0.50 | Capped at remaining real HP | INELIGIBLE |

**Conservation:** 270 + 40 + 235.75 + 0.50 = **546.25** (one Boss lethal, one Sect loot roll). Two healer casts are ≤41.4 source-verified max; actual HP missing/party link and timing must be satisfied by the future replay. TAG-B's last hit gets no ownership.

**Stone distribution fixture only** (NOT locked Sect cut): if a source legitimately grants 100 Spirit Stones and test policy selects 60% Sect/40% personal, four eligible actors receive 10 each, Sect60; BUFF-B and TAG-B zero. Tu Vi for each eligible actor still depends on personal rank/challenge/participation, not a 10 XP identical grant.

### F02 — Guard source + tank evidence

Boss Attack34.385, base defense19 => direct uncrit approximately26.941511 actual Boss-origin damage with no guard. Active guard leaves ≈17.511982 actual and prevents ≈9.429529 of that hit. Two guarded hits would produce ≈35.023964 HP damage received and ≈18.859058 mitigated (hypothetical compatible action/timing fixture). Current `guard` UI event **does not expose prevented damage**, so no production threshold may assume mitigation data exists until domain instrumentation. Two Boss-origin hit IDs could serve as evidence of tanking, subject to real V2 source validation and spam caps.

### F03 — Emergency healer vs useless overheal

Real base heal cap41.4. A valid same-party tank has 190 MaxHP and 35 HP before Boss-linked heal (≤25% of 190=47.5). One legal cast restoring41.4 raises to76.4; this is a possible **single rescue candidate**, despite only one heal event. Another healer tries to heal a 190/190 ally; under current V2 `_heal_ally()`, target is ineligible and no heal event occurs; zero contribution. If code someday records zero-effective events, they still produce zero Boss eligibility.

### F04 — Late tag after >2 hits with insignificant damage

Boss already near death; attacker lands two distinct legal actions reducing real HP by only 1+1=2 (0.366% Boss max) because hits are capped to remaining HP. A simplistic “2 hits” gate wrongly admits it. Proposed DPS dual gate (2 actions AND ≥3% HP) rejects it. One genuine damage burst≥10% would be allowed as a separate exception.

### F05 — Valid retreat without Boss reset

Boss still alive with same generation, Team A dealt substantial legal damage and healer rescued a member; Team A withdraws, Team B completes Boss without reset. No new receipt on withdrawal. Under proposed causal-retention approach Team A's effective, still-relevant contribution remains eligible; elapsed delay alone does not erase credit unless owner signs a staleness rule.

### F06 — Heal/debt example + reset

Boss starting546.25, A deals120, Boss heals60, B deals486.25 then kills; total raw inflicted =606.25 but effective outstanding damage =546.25. Pro-rata reward credit after Boss regen: A60, B486.25. If Boss instead fully heals120, A damage claim0. If full reset epoch legally applies, A's old heal/guard action eligibility must be re-evaluated as old audit only.

### F07 — One downed, healer/Tank fairness

Tank first takes Boss-origin hit, guard mitigates second; healer same-party provides actual effective heal; Tank becomes HP0 and Injury1. Boss dies from other team. Tank/healer remain candidates for contribution before HP0; no post-HP0 activity. No V2 common heal revives a downed actor; GP-02C1 injury recovery 120 canonical ticks on correct owner.

### F08 — Party transfer mid-Boss

Disciple moved from team A to B once at legal command barrier. Historical damage/heal events reference permanent disciple_id and old party_id at original tick; after transfer, new party-only effects obey current party. One participant entry and one personal Stone distribution; cannot receive two shares.

### F09 — Split non-divisible and zero eligibility

Personal Stone pool41, eligible ordered d01,d03,d07 => grants14,14,13. If a Boss dies through unsupported environment tick and eligible count0, system BLOCKED_SPLIT_POLICY (or later owner-selected Sect fallback) rather than silently destroying/creating Stones.

### F10 — Source instrumentation + replay

The above ledger must take authoritative typed gameplay events, not capped `MapBattleV2.events` with MAX_EVENTS2400. If 2401+ visual hit/heal events exist, receipt/participation still complete. Replay and reordered input actor dictionaries, viewed/offscreen, Save-reload or retry must yield same ledger digest, ranks and personal Stones. Actual test logs for these cases are **NOT yet produced**.

## 5. Acceptance matrix and decision gates

| Gate | Test with fixture | Expected design result | Blocking fact |
|---|---|---|---|
| BTH-01 | 546.25 HP shared Boss 2 teams F01 | Only one HP0/loot; four eligible and two ineligible | Need one World CombatV2 instance and multi-team evidence |
| BTH-02 | Crit/burst large genuine hit≥10% HP | Single impact may qualify; not penalized by action count | Boss source skill action ID/range |
| BTH-03 | Single last tag0.5 HP | Does not qualify despite last hit | Effective HP delta from CombatV2 |
| BTH-04 | Two tiny hits totaling2 HP | Does not meet 3% threshold | Sum actual, not predicted hits |
| BTH-05 | Tank guard2 hits (F02) | Qualifies as tank with Boss-origin hits, no fake shield points | Missing prevented_damage event |
| BTH-06 | Same-party healer 20+30 actual | Qualifies if connected to Boss damage | Need boss-linked wound/effect provenance |
| BTH-07 | One emergency restore41.4 at HP35/190 | Candidate qualifies under emergency exception | Need causal link/life-save verification |
| BTH-08 | Overheal/unrelated team heal | Zero Boss credit | Party-only scope as current code |
| BTH-09 | Useless buff, absent DoT/control/shield consumer | Zero or PENDING_EVIDENCE, no invented contribution | Implemented feature inventory |
| BTH-10 | One downed contributor before kill | Previous useful credit candidate, none after HP0 | Injury1/120 once |
| BTH-11 | Retreat A, B kills same wounded Boss | Retain A's effective same-attempt credit | Need snapshot/attempt and withdrawal barrier |
| BTH-12 | Boss heals60 after A damage120, B kills | Pro-rata A60/B486.25, no credit inflation | Boss heal provenance + owner policy |
| BTH-13 | Boss resets to full / full disengage | Old credit audit-only, no loot until actual kill | OWNER approval reset/epoch |
| BTH-14 | Damage at stage10 / old skill mastery | Granted applied XP respects major gate; no duplicate mastery | Actual floor_costs/action-ledger |
| BTH-15 | Stone pool41/3, pool100/60/40 fixture | Exact conservation and deterministic remainder | Production sect policy not selected |
| BTH-16 | Zero eligible personal participants | Fail closed until owner-signed fallback | Pending policy |
| BTH-17 | Save before/during/after Boss HP0 | One receipt, coherent resources/Stone/XP, no reroll | Production SaveService migration |
| BTH-18 | Legacy finite test reorder, 6v5 boss, 30 actors | Parity / no shared HP clones or illegal party7 | B2.4 branch integration not yet authorized |
| BTH-19 | 24h offline while Source A worker runs separately | No design phase Godot load, no fake avg loot | Clock/offline not yet implemented |
| BTH-20 | Sensitivity thresholds P0/P1/P2 × seeds | Calibration report role false positive/negative and p50/p90 | **NEEDS REAL COMBAT TRACE**, no PASS now |

**Counterexamples before any final rate lock:** One-hit legitimate mage burst, low-DPS healer whose only effective skill was rescue, tank with Boss AoE avoidance and damage reduction but no direct Boss hit, weak disciple carried to a Boss, long Boss battle and strategically correct early retreat. Ensure no fixed numeric gate undermines valid play style.

## 6. Information needed from actual fixtures in next CODE review (no code here)

Use `dv2_02_group_map_battle_test.gd` existing deterministic seeds (6v5 boss and 30-person group) as **fixed-roster parity reference only**, not as persistent boss reward-pass proof. For future **separately authorized code instrumentation**:
1. Emit **domain event** on commit for actual Boss HP damage with source actor/skill/target generation and exact before/after HP.
2. Emit Boss-origin damage taken + actual guard prevention (no guessed guard effect), and same-party effective heals plus causal Boss wound/action provenance. If shield/debuff/control not in runtime, label absent.
3. Emit downed/withdraw/party transfer/barrier/Boss heal or reset epoch timestamps from single clock; compute cause-specific eligibility.
4. Run same seeds viewed/unviewed, reversed actor-input order, one Boss with two legal parties and no reset, retreat cases F01-F10. Record per-role action histograms, source amounts, eligibility by P0/P1/P2, unfair heal/tank false negatives, last-tag false positives, event buffer overflow, CPU/ledger size.
5. Measure p50/p90 distributions of effective Boss participation by role. Only then propose production **percent thresholds and timing**. Avoid passing P1 numbers into live economy meanwhile.

**Single authority:** Team/monster AI decides intentions, CombatV2WorldStep owns actual effects, Boss ledger owns only evidence, RewardEnvelope commits once, SaveService persists coherently. Source A artwork and V5 telegraphs are presentation only.

## 7. Proposed owner decision

**Approve architecture now:** (a) hard-validity + role-specific thresholds; (b) no DPS-only gate; (c) explicit high-impact single action exception; (d) stale/withdrawal credit should follow **effective surviving Boss HP damage and actual support**, not an arbitrary countdown; (e) Boss full reset epoch never generates loot; (f) real domain evidence required; (g) one pool Sect gear and equal personal Stones among eligible under a separate unapproved Sect percentage.

**Do NOT approve production constants yet:** 3%, 10%, two actions, 15%, eligibility split when PARTIAL, 60/40, 0/60/180 seconds, Boss regen/attempt reset. These remain controlled calibration candidates with clear reproducible fixtures and blocking test criteria.

**This deliverable is an evidence-based design/fixture proposal, not a Godot runtime implementation or test PASS.**
