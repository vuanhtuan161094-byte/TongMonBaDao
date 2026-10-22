# TÔNG MÔN BÁ ĐẠO — DIRECT KILL TU VI REWARD / POST-CARE GAMEPLAY RECOMMENDATION

**Date:** 2026-10-23 (Asia/Bangkok), user requested expert choice 2026-10-22T23:38Z.  
**Type:** RECOMMENDED GAMEPLAY DECISION + DESIGN CONTRACT, **NOT CODE AUTHORIZATION**.  
**Base observed:** `main=29b5fba448b0178cb520a4ada44b375b4b934e31` (six repo skills merged via PR #23). B3 CARE local `35ffa85fd45da42e43722e7ac74b7423602d4491` with supplied 15/15 focused PASS is a separate code integration.  
**Branch:** `docs/b3-postcare-next-playable-design-20261022`. This file **supersedes the "Tinh Nguyen required absorption to obtain hunting Tu Vi" preference** in `B3_POST_CARE_NEXT_PLAYABLE_PROGRESSION_DECISION_PACKET_2026-10-22.md`; previous packet is historical and may still be helpful for receipt tests. Direct owner has delegated selection of the best game loop, **but canonical `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md` §2.2 currently prohibits direct EXP on monster HP0**. Treat this as an explicit **canonical-change proposal** that must be reconciled in an owner-authorized docs/CODE integration packet before game code modifications. Do not silently implement contradictory logic.

## 0. Decision summary: simplify the player loop

**SELECTED DESIGN: monster death -> direct personal fixed Tu Vi EXP to genuinely participating disciples; the same real death -> one Sect-owned loot settlement, possibly resources/gear/rare materials.** No mandatory return-to-Sect, no compulsory Tinh Nguyen absorb, no extra click to claim EXP. Progress is immediately visible as bar/tier growth during continuous auto-hunt. Normal farming gives steady growth; Elite/Boss adds bursts and rare drops. Optionally **Tinh Nguyen** exists only as a special non-mandatory rare crafting/breakthrough material; it is NOT an additional general EXP source unless specifically approved.

This deliberately changes **only the source/receipt of fixed hunting Tu Vi**, not the math/damage/cast/RNG of Combat V2. It keeps the sect-tycoon management loop: farms/mines/crops and alchemy supply gear/heals/material sinks; hunting drives personal cultivation and Sect loot; training and body conditioning remain distinct ways to develop.

**Evidence/inspiration:** Evil Hunter Tycoon's official game materials emphasize hunter EXP/items from hunting bounties, town production and support facilities. Specific TMB timing/drop/economy must be empirically tuned rather than copied.

## 1. Three non-duplicated growth channels

| Source | Authority | When EXP commits | Nature / cap | Implemented at current main? |
| --- | --- | --- | --- | --- |
| Natural Tu Vi | Existing `DiscipleTuViFlowV2`/scheduler | Once per canonical simulation minute for eligible V2 disciple | Natural bonus applies (Tư Chất); `CULTIVATE` accelerates SAME source | YES at main |
| Hunt Tu Vi | PROPOSED reward receipt integrated with B3 world and `DiscipleRealmProgressV2.grant_xp` | On *genuine monster death* for each causal/qualified actor | **fixed** EXP; no Tư Chất multiplier; unique `kill_id+disciple_id+reward_channel` | NO, needs explicit canonical design override + CODE packet |
| Tu Vi pills | B3 CARE local: `tu_khi_dan` | On actual pill use/warehouse debit | fixed +10,000 pilot; shared Pill Satiety **1,000,000/day/disciple** | CARE code reported, main CODE merge unverified |

**Not allowed**: a second generic "ambient hunting cultivation" bonus *plus* direct kill EXP while still claiming 10–20x total; Tinh Nguyen consumption duplicating the XP from same kill; body XP from monster by default; bonus once per hit/cast/render frame/monster spawn, unearned support spam, old finite battle WIN bonus for the same kills.

## 2. Player-facing loop

```text
Deploy team (max 6) to eligible persistent map
 -> real Combat V2 fight (quái respawn independently)
 -> genuine HP>0 -> HP0 terminal event for generation K
 -> ONE death/reward envelope, save-authoritative
       A) Sect-owned: actual loot to Warehouse/unique registry, once
       B) Personal: direct fixed Tu Vi per QUALIFIED real contributor, once each
       C) Optional genuine mastery/other personal currencies via separate authorized channel
 -> fast EXP meter animation; 10th floor gate holds without auto bypass
 -> HP0 disciple returns with Injury 120 simulation ticks, uses real heals and redeploys
 -> policy chooses next map by efficiency/risk; player manages priorities not individual kills
```

**UX:** Reward ticker groups events every 1–3s / batch to avoid 3000 actors spamming labels, but domain settlements happen exactly once at each real kill. Show per-disciple EXP, rank/progression and "gated at floor 10" reason; show material source and amount on Sect Warehouse log, and a distinct Boss unique-loot highlight. No "loot EXP item" button.

## 3. Multiplayer-in-the-same-sect: reward eligibility

- One monster ID (`world, region, spawn_slot, generation`) has one real HP pool and one death receipt; no per-team duplicate monster/loot. Killing blow **does not** own all Tu Vi or drops.
- When normal mob dies, each real participant who dealt effective damage, intercepted/absorbed boss-origin harm, healed missing HP causally, or applied a useful party/combat effect may be eligible for **personal EXP**. A support class isn't penalized simply for DPS=0.
- Eligibility must come from actual Combat V2 action events and a documented bounded participation epoch; idle/passive nearby spectator, spam zero-heals, a player joining last millisecond and no actual useful action get **no or appropriately partial reward**. Numeric thresholds and grace/retreat duration remain OPEN until fixtures.
- Recommend **equal nominal personal EXP for meaningfully eligible members of the same party** (no 1/N divide for healer/tank), with optional bounded partial tier ONLY if proven by event data; avoid DPS-weighted splits that push users to six DPS. For a Boss with two parties, use the same typed eligibility and separate Boss fixture; one Sect loot payout, personal EXP per true eligible actor. Exact Boss Sect/personal Linh Thach allocation including historical 60/40 is UNLOCKED and separate from EXP.
- At failure/retreat/downed, preserve credit for truly effective past actions only per explicitly approved epoch/reset rule; being injured does not retroactively mint rewards. No extra reward on reset without death. Each `(kill_id, disciple_id, fixed_tuvi)` is persisted with once-only claim history.
- Non-participants working Mine/Forest/Field/Alchemy receive only their valid natural cultivation+job rewards, not kill EXP by affiliation or by being on a team list.

## 4. Pacing, per-monster coefficient — PRELIMINARY FIXTURE ONLY

Normal ordinary-worker Tu Vi SOURCE baseline = `1000/min` before Tư Chất, e.g. Tư Chất 60 -> `1150/min`, assuming no extra modifier and eligible natural source.
- Target healthy matched hunting yield over *observed full canonical time*, including health, injury, travel and alchemy downtime = approximately `10–20×` **ordinary-work Tu Vi** (P3.7 existing DESIGN band, not locked current code).
- For illustrative 12× at 1150/min, desired total `13,800/min`; fixed-hunt contribution `13,800-1,150=12,650/min` expected across full day. If effective eligible kills = 0.5/min across that same observation window, **~25,300 fixed Tu Vi per normal kill per eligible hunter**, purely as a starting fixture at early realm/floor. Actual official Combat V2 kill cadence, team size, injury/downtime, difficulty/rank and time-to-floor must be measured; do **not** hardcode 25,300 or multiply every kill by 12.
- Fit a smooth bounded per-kill reward function to canonical current-floor EXP cost, monster `realm` / `floor`, `normal|elite|boss` grade and real `difficulty`, legitimate participation and encounter throughput. No infinite farming realm1 mobs to blast through realm30. Avoid rigid zero-return cliffs where possible; display clearly when zone is outdated.
- Elite/Boss provide more EXP but mainly material/gear progression. Do not force exclusive Boss loop for basic leveling or basic medicine; make normal monsters a satisfying steady farm.
- For 6-member party, each member's actual XP/min should be calibrated based on that group's **real** mob kill frequency: adding members shouldn't multiply per-actor XP unbounded or punish supports by dividing a fixed `total XP` six ways. The Sect's aggregate XP across six actors can legitimately exceed one actor's XP; anti-leech guards limit free riding.
- Saturation 1,000,000 limits **pill consumption**, NOT hunting XP; no extra per-day hunt EXP cap or diminishing-returns penalty unless later specifically approved. Avoid phantom "Tinh Nguyen saturation" policy.

## 5. Breakthrough and persistence guardrails

1. `DiscipleRealmProgressV2.grant_xp(..., track="cultivation", gain_type="fixed", ...)` applies to a real initialized actor; fixed XP does not multiply Tư Chất. Luyện Thể uses only valid independent sources.
2. Floor 1..9 advances using canonical 300-floor costs. At floor10 major gate, **do not auto bypass**: follow current `unapplied_overflow` semantics. Do not add hidden unbounded XP bank; at cap show warning and redirect task or seek owner-approved policy instead of quietly wasting time.
3. Single transaction: validate death+roster+effective contribution -> allocate true personal grants and one Sect loot envelope -> journal receipt / canonical state -> SaveService; repeated load/retry does not mint EXP, loot or Linh Thạch. Crash pre/post debit, multiple last hits same combat substep, world TTL/generation and offline replay must be specifically tested.
4. No extra source in finite legacy `HuntingMapV2.claim_reward`; avoid mode collision/double reward. UI reads event/result only and is not authority.
5. Testing negative cases: kill not terminal, no valid participants, spectator, useless support, 2 teams one Boss, loss/reset, death with pending save, realm10 floor10 gate, zero HP healer, missing character, save/reload after reward, offline catch-up and warehouse capacity limitation.
6. Real Godot official 4.7.2 fresh integrated SHA tests; game-view screenshot 1280×720 and physical Android/owner approval remain separate.

## 6. Implementation order after Codex merges B3 CARE into main

- **Design reconciliation DOCS packet:** modify canonical `docs/CULTIVATION_BREAKTHROUGH_V2_SPEC.md §2.2` **with explicit owner-approved override** of "no EXP on kill". Preserve unchanged clauses natural source once, Tư Chất, fixed grant and major-gate requirements. Update any future B3/Tinh Nguyen document references so there is one authoritative current policy. **Do not edit canonical spec during unrelated Codex integration or from this branch.**
- **CODE packet B3-XP-01:** list exact affected B3 world death/receipt, RewardEnvelope, `DiscipleRealmProgressV2`, SaveService, test+presentation allowlist after reading new main; implement one normal mob kill, 1–6 real eligible actors, exactly-once personal fixed EXP, one Sect loot, reasonable UI feedback. No Boss coop in first packet, no asset/Source A, no scope creep.
- **Fixture review:** simulate r1f1/r1f10/r5f1/r10f1 and squad size 1/3/6; warm-up/uptime, 24h/7day per sim-time, seeded P50/P90, partial contribution fairness, healer zero-DPS. Decide true drop/XP rates **after** measuring real kill cadence. No covert nerf; test anti-leech with roles.
- **Next:** team policy/targeting -> multi-team shared Boss ledger -> map rank/content -> higher-grade medicines/Body forging. Avoid code in Codex overlapping integration worktree until current B3 CARE PR is closed.

## 7. Status/choice

- This file is **recommendation selected by assistant at user's request**, a request to amend previous no-direct-kill-TuVi canonical rule. No simulation code, source balance table, tests, gameplay authority, or old save bytes were changed in this commit.
- Require an explicit clear owner confirmation of this *specific canonical rule change* before treating as OWNER LOCK and implementing. The user has delegated a best-choice recommendation; the authoring of this document alone is not a CODE packet.
- Previous `B3_POST_CARE_NEXT_PLAYABLE_PROGRESSION_DECISION_PACKET_2026-10-22.md` preserves past Tinh Nguyen mandatory-absorption plan only for audit/history and is superseded by this choice for gameplay recommendation.
