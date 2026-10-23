# TÔNG MÔN BÁ ĐẠO — B3-XP-01 / DIRECT HUNT TU VI — IMPLEMENTATION READINESS PACKET

**Date:** 2026-10-23 · **Status:** OWNER-APPROVED **DESIGN SOURCE** / CODE PACKET PREPARATION ONLY · **NOT AUTHORIZATION TO CODE, MERGE, RUN FULL/CI, OR MODIFY CARE**.  
**Workstream:** isolated docs branch `docs/b3-xp01-direct-kill-canonical-20261023` from `main` inspected at `29b5fba448b0178cb520a4ada44b375b4b934e31`. Codex CARE integration worktree is independent: do not touch/change its branch, local bundle, artifact or saves.  
**Skills:** `tmb-project-director` + `tmb-balance-lab`.  
**Direct owner decision 2026-10-23:** `100%` of the **authored personal hunting Tu Vi reward** is settled as **fixed Tu Vi directly** to each genuinely eligible contributor on real monster death; Tinh Nguyên is an **optional rare crafting/forge/breakthrough material**, **not mandatory to gain hunt EXP**, and must not grant the same EXP a second time.

## 1. Canonical reconciliation and what has NOT changed

1. [`docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`](../../docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md) §2.2 (path from repository root: `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md`) now supersedes the October 9 "monster kill does not grant Tu Vi" prohibition **only** for a valid B3 per-monster death. Historical rule remains explicitly recorded. Fixed pills and XP do NOT multiply by aptitude, root, natural source. All previous natural once-per-minute behavior remains.
2. [`docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`](../../docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md) now binds hunt XP to one legal kill + one personal credit per contributor. Grade/rank/difficulty/participation amount coefficients stay **NOT YET APPROVED**.
3. [`docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`](../../docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md) now distinguishes per-kill settlement from the historical finite encounter resolution. 60% Sect / 40% personal Spirit Stones is **EXAMPLE ONLY**, not owner locked; personally distributable Stones (if approved) are shared equally among eligible disciples *after* Sect cut.
4. [`docs/design/B3_XP01_300_FLOOR_CANONICAL_COST_AUDIT_2026-10-23.csv`](../design/B3_XP01_300_FLOOR_CANONICAL_COST_AUDIT_2026-10-23.csv) contains 300 source-derived stage costs. The file is reference data, not game content / new balance. The pre-existing B3 Tinh Nguyên required-absorption design and B3 Direct-XP assistant recommendation remain historical evidence; the **2026-10-23 DIRECT owner decision now prevails**.
5. **Preserve:** Godot4.7.2; Combat V2 authoritative hit/cast/HP/stats/skill RNG; one live persistent PvE world (not wave-90sec loop), one canonical clock, sect Warehouse and SaveService, One Active Job, Injury 0/1/120 sim ticks, 30×10 cultivation and 30×10 Body, same original XP floor cost table, floor-10 major gate and breakthrough RNG/fail penalty, exactly-once reward/save. Body EXP never silently awarded by monster HP0. The B3 CARE owner's shared **pill** satiety is 1,000,000 points/disciple/canonical day, NOT an XP cap; preserve Hồi Xuân 10/+55HP, Tụ Khí25/+10k fixed and B3 CARE recovery/auto-redeploy behavior.
6. **Do not infer implementation:** Current observed `main` has legacy finite encounter `HuntingPveRunV2` and `HuntingMapV2.claim_reward`. B3 CARE Codex handoff `35ffa85fd45da42e43722e7ac74b7423602d4491` reports 15/15 focused PASS at that SHA but its import into current main is NOT verified by this docs-only task; existing World/kill/ledger classes must be freshly inspected on the *post-integration* HEAD.

## 2. Actual loop and boundaries

```text
Real B3 combat step (Combat V2 authoritative, same world) ->
   monster HP > 0 => 0, unique death of (world_id, spawn_slot_id, generation)
   -> freeze immutable kill_id, monster/grade/rank, battle source and actor evidence
   -> one RewardEnvelope with 1 Sect loot channel + N per-actor fixed cultivation channels
   -> validate actor birth/profile + deployment + role evidence + current realm/floor
   -> check committed kill_id, actor-specific receipt keys, authorized reward definition, exact-amount constraints
   -> APPLY to Sect Warehouse / unique inventory, and each eligible actor via canonical fixed grant_xp
   -> persist transaction + receipt barrier with canonical SaveService; replay does not duplicate anything
   -> UI displays actual applied XP, when floor10 is capped/overflow and true loot, no UI-created rewards
```

The `100% DIRECT` decision means **no deferred Essence token share / no forced absorption**. It does NOT mean multiply per-disciple award by 100%, ignore role-eligibility, claim an imaginary 100% drop probability, or automatically double every participant's current-floor XP. Existing `DiscipleRealmProgressV2.grant_xp(track="cultivation", gain_type="fixed")` controls floor conversion. If a contributor reaches the maximum of floor10, `unapplied_overflow` is **not** a generic saved XP bank; only the actually applied XP is credited. No hidden free breakthrough or "carry-over after rebirth".

**One kill root; many legitimate channels:** distinct `(kill_id, disciple_id, reward_channel="hunt_fixed_tuvi")` credit records, one Sect loot record, optional independently authorized mastery and personal currency. Multiple legal contributors can each receive full *authored nominal personal reward* (not divide 1/N as punishment). All credit derives from **the same original monster generation**, not a cloned per-party Boss. No payout simply for last hit. For future 2-team Boss, use existing Boss-coop evidence/withdrawal fixtures; do not implement multi-team Boss in B3-XP-01.

**Reference design schema (not code names):**
- `KillProof{world_id,slot_id,generation,death_seq,monster_id,grade,stage_rank,canonical_tick,event_order,rng_proof}`
- `ContributionProof{disciple_id,team_id,action_event_ids,effective_damage,effective_tank,effective_heal,useful_support,valid_at_action}`
- `HuntReward{sect_loot_once, personal_fixed_tuvi[disciple_id],applied_xp[disciple_id],unapplied_overflow[disciple_id],receipts[...],save_barrier}`
Avoid asserting that this schema already exists. Freeze source data/version on kill so later content table changes cannot redraw loot/XP on retry.

## 3. Role fairness contract — 1, 3, 6 disciples

**LOCKED POLICY:** only genuinely effective, causally connected Combat V2 actions can establish eligibility, including non-DPS roles. All numeric thresholds / time windows / assist-decay and partial multipliers are **OPEN**, pending Combat V2 fixture traces. Default proposal: one full authored nominal per qualifying disciple in an ordinary kill; the role gates determine eligibility, not rank-based 1/N pooling. Grade/rank/challenge modifiers can differ by actor's own stage.

| Scenario | Setup / evidence | Required decision | Why |
|---|---|---|---|
| R1-SOLO | 1 DPS valid damage, real monster HP0 | 1 genuine personal fixed grant + 1 Sect loot receipt | basic loop |
| R3-ROLES | 3 deployed: DPS actual HP reduction, tank meaningful damage prevented/taken from same engaged mob, healer actual missing HP recovered in that engaged context | 3 individually eligible, no DPS-only gating; 1 loot | healer & tank have non-DPS impact |
| R3-OVERHEAL | 3 deployed; healer only casts at full HP, no other effective action | healer **not** paid just for empty animation; other 2 evaluated normally | no phantom support |
| R6-SUP | 6 deployed: 3 DPS, 1 Tank, 1 Healer, 1 Support with valid applied buff/debuff; every contribution causal | 6 personal grants **not** 1/6 each; 1 Sect loot | same reward opportunity by role |
| R6-AFK | 6 deployed, 1 idle/proximity-only spectator, other 5 useful | spectator 0; exactly 5 lawful grants | anti-leech |
| R6-LATE | new member tags near death for negligible effective impact | no automatic full payout; threshold remains calibration OPEN | prevent last-second leech |
| R6-JOB | an actor allegedly mines + hunts concurrently | One Active Job rejects invalid deployment/credit | one scheduler truth |
| MULTI-BOSS-DESIGN | 2 teams damage same Boss, legal heal/guard and one lethal event | ONE Boss HP, ONE Sect loot, per-eligible actor XP, no last-hit | design only, not first CODE packet |
| RETREAT | actor contributes then leaves/downed before eventual kill | source-linked active epoch validly preserved for review; no credit from post-down actions, cutoff rule OPEN | no phantom / unfair role reset |
| ZERO-ELIGIBLE | valid monster death but all candidate proofs invalid | zero personal hunt grants; Sect loot acceptance determined by sect kill provenance, no duplicated credits | fail closed |

**Meaningful action signals:** `actual_damage` capped by current HP for DPS; tank actual absorbed/reduced incoming damage from a monster targeting a legal allied beneficiary; healer `effective_heal=min(missingHP,healed)` causally related to the encounter; support an applied buff, successful debuff or CC that *actually affected combat*, not the animation of a cast. Support actions must be attributable to the monster or legal team engagement context; cross-team overheal does not mint credit. Need instrumentation/trace feasibility review from integrated Combat V2; no invented event API or hard-coded thresholds.

## 4. 30 realms ×10 floors audit and progression pacing

**SOURCE:** `DiscipleProgressionBalanceV2.REALM_TOTAL_XP` and `FLOOR_WEIGHT_PER_MILLE`, source main 2026-10-23; **exactly 300 stage costs**, each realm sums its frozen total, track sum **48,130,600,000 Tu Vi XP**; Body independently requires the SAME cost amount from separate Body source (not from hunts). Stage 1..9 cost rounding to nearest10; floor10 gets exact residual.

| Realm | Realm total XP | Floor1 XP | Floor10 XP |
|---:|---:|---:|---:|
| 1 | 10,000,000 | 700,000 | 1,400,000 |
| 5 | 26,000,000 | 1,820,000 | 3,640,000 |
| 10 | 86,000,000 | 6,020,000 | 12,040,000 |
| 20 | 938,200,000 | 65,674,000 | 131,348,000 |
| 30 | 10,240,200,000 | 716,814,000 | 1,433,628,000 |

**Formula model (not locked rates):** for eligible disciple i at floor r,f with `C = floor_cost(r,f)`: candidate nominal XP/kill `=C × basePct × monsterRankMult × monsterGradeMult × challengeMult × participationMult`. All coefficients are **TUNING VARIABLES, not approved production numbers**. Use authenticated monster age/rank/grade/difficulty and sampled real qualified kills per simulation hour. Do not clone `P3.7` starting constants into code without owner approval. Any real fixed XP event remains exactly fixed once computed, not re-multiplied by aptitude/root/other natural bonuses.

**Pacing invariant:** `TOTAL cultivation per valid sim minute = one natural minute grant + sum(authored fixed kill rewards actually applied during that minute) + any separately valid fixed pill/service grant`. Never add a second "passive hunting" source. Evaluate `XP/h` over observed downtime, jobs, healing, Injury120, solo/3/6 roles, ranks and fight survival; no 1/N XP divide; high-level power should not create unbounded carry. For Tư Chất 60 and no other bonus, natural = 1,150/min = 69,000/h. Realm1/floor1 natural alone gives **9.8571% floor per hour**; realm30/floor1 gives **0.009626% floor per hour**. Thus the **10–20× labor** design aspiration and **0.5–1% current-floor/h** aspiration CANNOT BOTH be hard global invariants over the 300-floor curve. Calibrate segmented cohorts, label targets carefully, keep no unapproved daily XP ceilings/diminishing returns.

**Benchmark after CODE:** 1/3/6 disciples × Normal/Elite/Boss × representative realm1/5/10/20/30 × safe/equal-risk/high-risk. Record actual kills per simulated hour, HP/Injury uptime, per-actor applied XP, overflow, floor time, resource/stone material cost, and distribution P10/P50/P90 with recorded RNG seed. `Tinh Nguyên` rare material (if subsequently authored) enters Sect Warehouse only and gives no hunting XP at absorption. No missing-map fantasy states: only run actually authored regions.

## 5. Offline/save/replay contract

| Fixture | Preconditions | Expected behavior |
|---|---|---|
| O-00 | app offline; no authoritative recorded/replayed monster deaths | zero **hunt** XP; natural sim clock grant only if its own offline contract permits |
| O-01 | bounded deterministic replay produces N genuine death events | exactly N Sect death settlements, and per-actor credits only for those meaningfully qualifying, same seed/order as online |
| O-02 | crash before death event durable commit | no phantom grant; event may legally be retried once by authoritative replay |
| O-03 | crash after complete commit, before UI updated | already committed rewards visible after reload; retries 0 new rewards |
| O-04 | failure/partial state after one of many per-actor grants or Sect loot | atomic transactional rollback or deterministic pending completion; never loot-without-barrier then duplicate XP |
| O-05 | repeated callback, two lethal hits same tick, duplicate event key | one terminal death, one Sect loot, one personal credit per actor; no duplicated gameplay |
| O-06 | SaveService export/import, old schema missing new ledger keys | deterministic legal migration with no earned progress lost and no spurious grant |
| O-07 | finite legacy battle WIN + continuous world kill refer same event | one mode owns reward, never both; exact mode and identifiers checked |
| O-08 | full floor10 gate / offline mass kills | `applied_xp` correctly bounded; surplus `unapplied_overflow` not silently banked; no major advance without breakthrough |
| O-09 | 1,000–3,000 disciples, large offline backlog | bounded/partitioned event evaluation without fabricated averaged kills or frame-triggered scheduler, monitor CPU/time/memory |
| O-10 | pill consumption and kill EXP on same sim tick | no shared XP cap, pill satiety applies **only** pill consumer, one natural grant and independently lawful fixed grants |

Save/load equivalence requires canonical `world_id/slot/generation/death_seq`, event order, frozen RNG/loot/XP content version and coherent receipt barrier. Do not invent a new SaveService implementation or a second real-time clock. No settlement from GUI or VFX.

## 6. B3-XP-01 proposed **small CODE scope** (NOT AUTHORIZED)

**Precondition:** Codex finishes current CARE integration and closes its own focused regression at the **actual new main/integration SHA**. Then separately request owner authorization with fresh SHAs, file allowlist and testing scope; do NOT execute this packet under the existing CARE authorization.

**Proposed minimal slice:**
1. One real normal monster from an already authored pilot map; selected legal 1–6 disciple party already supported by post-CARE world owner; 1 HP0 event. Frozen registered award content and actual current floor.
2. Normalized `kill_id` and genuine `ContributionProof` read from current Combat V2 event/actor source; no proxy events to fake health/tank/heal.
3. Add one personal fixed cultivation grant per eligible actor through the existing V2 realm-progress owner, with a reject/overflow result.
4. Reuse existing canonical Sect loot/death receipt/SaveService and add actor credit keys atomically; no second Warehouse/loot pipeline and no duplicate legacy encounter-WIN grant.
5. Surface two truthful UI signals: per-actor applied `+Tu Vi`, Sect `+material`; gate/overcap status and Source A visuals remain separate acceptance items.

**Candidate PATHS — conditional, MUST BE VERIFIED against integrated current tree before CODE approval**:
- `godot/src/simulation/combat/map_battle_v2.gd` (only if genuine effect events need extending; Combat V2 damage formulas must NOT change).
- B3 persistent world, kill receipt, loot-reward coordinator paths from the integrated **B3 CARE** HEAD; actual file names/provenance must be collected by Codex first, not invented.
- `godot/src/simulation/combat/hunting_pve_run_v2.gd` and `godot/src/simulation/combat/hunting_map_v2.gd` **READ first**, to eliminate finite-WIN duplicate sources; avoid edits unless exactly necessary.
- `godot/src/simulation/cultivation/disciple_realm_progress_v2.gd` existing fixed grant contract **READ FIRST**; never modify the 30×10 costs, grant type or major gate as a shortcut.
- Existing current-world `SimulationState` / authoritative SaveService / warehouse access paths **READ FIRST**; change only when unavoidable, with explicit schema/migration/rollback tests.
- New focused tests scoped to real files and explicit fixture assets; no Source A/JX/Spine imports.

**Hard exclusions:** no Boss multi-team credit CODE, no global actor-AI rewrite, no grade/loot/map r2–r30 content invented, no master-stage RNG adjustments, no Alchemy/Needs/CARE mutation, no duplicate natural cultivation, no new energy/ticket/stamina cap, no 60/40 Stone decision, no FULL/CI unless a separate authorized integration scope requires it. No gameplay CODE, merge, Godot run, or CARE branch edit in THIS docs task.

## 7. Test plan for future authorized CODE — not run here

- XP1–XP8: one normal kill (solo), 3 role witnesses, six-member five-eligible, spectator, overheal 0, tank prevented/taken proof, useful support proof, late-join trivial hit rejected according calibrated policy.
- XP9–XP14: same world/slot/generation, two lethal hits, kill re-entry after save, pending receipt, no monkey-patching RNG; finite encounter and persistent mode disjoint, no duplicate XP/loot.
- XP15–XP20: 30×10 floor1..floor10 cost data, floor9→10, full floor10 no auto breakthrough, fixed XP not multiplied by Tư Chất, Body XP unchanged, Tư Chất natural once, no cross-realm XP bank.
- XP21–XP26: 120 Injury ticks, rest/heal/return, One Active Job rejection, offline deterministic replay, actual zero kills gives zero hunt XP, old saves and rollback/retry.
- XP27–XP30: real Sect Warehouse materials and receipt, pill + kill same tick, underpowered/overpowered monster rank gap, 1k/3k performance sampling (if authorized).
- Boss proof can reuse B3 boss fixtures as **DESIGN REVIEW**, not count as XP1 code PASS.
- Official Godot **4.7.2** focused tests at exact CODE SHA; broader cumulative regression as permitted. Android landscape 1280×720 UX and manual Windows still PENDING until owner actually observes game.

**Acceptance gate:** do not call this CODED or QA PASS from the design, CSV or prior CARE ZIP. Once CODE is authorized, every test needs source SHA + official runner exit code + log PASS marker. Valid legacy tests remain unchanged. If needed use 1–2 extra docs revision cycles **without code** to resolve evidence.

## 8. Recommended Codex review-only prompt for AFTER CARE integration

```text
TÔNG MÔN BÁ ĐẠO — CHUẨN BỊ B3-XP-01 (READ-ONLY, NO CODE). Tôi đã khóa DESIGN mới 2026-10-23: real monster death grants authored fixed Tu Vi DIRECTLY to each genuine DPS/Tank/Healer/Support; Tinh Nguyên is optional rare crafting material, not mandatory XP absorption or a second XP payout. Read docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md §2.2, docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md and docs/handoffs/B3_XP01_DIRECT_HUNT_TUVI_IMPLEMENTATION_PACKET_2026-10-23.md on docs/b3-xp01-direct-kill-canonical-20261023; inspect fresh main/Care integration HEAD. Verify actual event/receipt/SaveService paths and source diff; design the minimal CODE allowlist, migration, 1/3/6 role and 30×10/offline regression without editing runtime, tests, Source A or Codex CARE worktree. No merge/CI/FULL. Return a single ready-to-approve scope packet with exact SHAs, path list and focused test commands. Do not ask to reconfirm 1,000,000 pill CAP.
```

## 9. Open numeric values (NOT owner-locked)

- Real per-kill Tu Vi `basePct`, grade multipliers, relative rank multipliers, challenge/participation factors and EXP rate tuning per realm/party; only **the source, semantics and no-double-EXP rule are LOCKED**.
- Concrete meaningful-action thresholds/guard prevented-damage instrumentation/heal causality/retreat windows; avoid rushing arbitrary 3%/10%/2-action constants into CODE.
- Boss full disengage/HP reset credit epochs, 60/40 Stone split, drop/roll for rare optional Tinh Nguyên, future medicines/equipment/map tiers.
- Throughput targets: both "10–20x work" and "0.5–1% floor/h" are initially advisory and cannot both hold at all 300 costs with raw natural 1000/min; require measured source traces and owner signoff by tiers.
