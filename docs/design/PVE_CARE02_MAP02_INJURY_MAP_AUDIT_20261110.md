# PVE-CARE02 / PVE-MAP02 — Sửa HP, Trọng Thương và tổ chức map (2026-11-10)

**Authority:** owner 2026-11-10 14:47 UTC, supersedes PVE-BAL01 HP-for-Stones modeling. **Release:** QA candidate only; no live game toggle, no SaveService edit, no branch/merge. Source: `PveInjuryTreatmentV1`, `PveR12BalanceV1`, `HuntingPveRunV2`, `B3HuntWorld`, `PveP0CommandsV1`, `PveClusterLayoutV1`.

## One-source-of-truth combat health

| Situation | HP | Injury | Costs | Re-entry |
|---|---|---|---|---|
| In combat, takes damage | Reduced by real damage | 0 | Actual consumed healing medicine from Warehouse and skills only | Continues if alive |
| HP=0 in main V2 / B3 | On canonical terminal return/revival HP = 100% max HP | Injury = 1 | No imaginary HP service, no medicine just to change Injury | Forbidden while Injury=1 |
| Natural Injury recovery at sect | Unchanged | Injury becomes 0 exactly after 120 canonical simulation ticks | 0 LT | Allowed afterwards |
| Paid Injury clinic at sect, realm r1 | Unchanged | Shortens due tick to now + 30 | 1,500 personal LT → Sect treasury | Allowed after timer |
| Paid Injury clinic at sect, realm r2 | Unchanged | Shortens due tick to now + 30 | 3,000 personal LT → Sect treasury | Allowed after timer |
| Normal HP below max HP | Only pill/skill or legacy REST behavior can replenish | Unaffected | Canonical Warehouse pill debited once | Not cleared by HP increase |

**This correction intentionally REJECTS** previous 300/600 LT per +10 HP, 11 services per hour, and 216/288 HP based fee modeling. The corresponding PVE-BAL01 row is **SUPERSEDED**, not a live price. Old `Economy-A` V1/legacy HP service remains unchanged for legacy/off-policy saves, but `PveR12BalanceV1.active(state)` refuses it and disables automatic HP-for-LT in the new pilot. Legacy P2 ordinary HP and rest routines are a separate migration question, NOT proof that V2 injury was treated.

Injury clinic:
- Only a real owned V2 disciple, Injury=1, physically at Sect, valid realm r1/r2, no conflicting study/work/reservations, and with enough personal LT may initiate.
- No fee if natural recovery occurs within the next 30 ticks: request returns `free_recovery_earlier_or_equal`.
- One durable paid receipt `injury-treatment:<request_id>`, plus an **O(1)** active index `injury-active:<disciple_id>` inside existing Economy-A receipt dictionary. Second request while active rejects; same request returns duplicate receipt. Avoid unbounded per-minute receipt scans.
- Personal LT→Sect LT is a **transfer**, not a global currency destruction. Medicine is an **actual Warehouse resource cost**, not a second LT charge when consumed.
- Treatment holds job slot from start until due (30 simulation minutes); 1000 passive Tu Vi/min still continues. On completion `SimulationScheduler` clears Injury=1 only, never grants HP.
- Existing injury after loading older Save remains what that Save recorded; no retroactive rewriting stored HP. **New** defeat settlements in main P0 and B3 revive at full HP. This keeps historical saves stable and respects owner intent.
- Pending: player-facing clinic action/UI and real Android/Windows GUI; new pilot remains off by default. No r3+ fees yet.

## Model after correction (one hunter-hour assumption, NOT observed natural play)

12 kills/h, region mix Trúc Thử 65%, Thanh Lang 30%, Hắc Lang 5%, 2 healing pills Q1/h, injury occurrence 0.15/h. `DOWNS_PER_HOUR_REFERENCE` is an estimate to stress test the economy, not a fixed probability or monster drop parameter.

| Metric | r1 | r2 |
|---|---:|---:|
| Passive Tu Vi/h | 60,000 EXP | 60,000 EXP |
| PvE Tu Vi bonus/h | 60,000 EXP | 76,200 EXP |
| Gross PvE LT/h | 29,700 | 59,400 |
| 2 medicine units shadow replacement cost/h | 3,000 | 6,000 |
| Expected Injury clinic cost/h (0.15 down/h) | 225 | 450 |
| Expected treatment downtime/h (0.15 × 30) | 4.5 min | 4.5 min |
| Net after pills and expected injury fees (not downtime) | 26,475 | 52,950 |
| Cashflow equivalent per scheduled hour incl. downtime | 24,627.91 | 49,255.81 |
| Production LT2 gross/h | 60,000 | 120,000 |

**Do not count both** (1) shadow replacement cost of consumed medicine and (2) an imagined actual LT expense for the same Warehouse pill. Paid treatment fees transfer to the Sect; in a total-monetary-supply ledger, exclude them from destroyed-money totals. Measure actual 6/12/18-kill cadence and real down/h before enabling.

## Map structure and performance

Evidence in live source before changes:
- One **physical** Source-A `thanh_truc_lam` topology with 20 persistent camp IDs (`C01`–`C20`), 10 spawn positions/camp = 200 registered positions.
- `PveDistributedWorldV1` activates only local slots near hunters and dest-preloads; `MapBattleV2.MAX_MONSTERS=40`, `MapBattleV2.MAX_DISCIPLES=30`. **20 camps are not 200 active mobs.**
- `PveClusterLayoutV1` now describes two logical view groups of 10 camps (`Thanh Trúc Lâm · Bắc` and `Nam`), without changing map geometry, monster registry, Save identity, or reward.
- Explicit next map gates `bach_thach_khe` and `hac_phong_coc` remain `open_world=false`: their original instanced PvE content exists, but new physical terrain, topology source, entrances, Save identity, and map-specific loot must be built before claiming playable open worlds.

**Decision:** Do NOT reduce 20 camps to 10 now solely in hope of more FPS. The major variable for CPU/render pressure is *active* agents, pathing, VFX, draw calls and per-frame processing. Reducing persistent spawn slots without reducing live agents does not guarantee faster frame time.

**Proposed multi-map design to implement after FPS evidence** (DESIGN ONLY, no fake runtime):
1. Preserve current map's C01–C20 and Save; show two logical groups (10+10).
2. Next true map: Bạch Thạch Khê, 10 camps ×10 spawn slots = 100 new real slots, with separate terrain/navigation file and atomic map-entry/exit. Boss table from sourced content. **NOT IMPLEMENTED**.
3. Next true map: Hắc Phong Cốc, 10 camps ×10 spawn slots = 100 new real slots, separate actual topology; Boss/Elite rewards source-verified. **NOT IMPLEMENTED**.
4. One total cross-map cap of 30 PvE hunters; first test 40 active monsters across all loaded worlds, not 40 per map. If Android's 1% low drops under 30 FPS, compare 40→32→24 actives, A/B with fixed assets and same combat load; do not alter passive XP or drop economics to hide lag.
5. Proposed acceptance budgets **not current measured facts**: Android landscape 1280×720 target 30 FPS 1% low and >=45 average on representative hardware; Windows 1280×720 target 60 average; keep load/Save exact-once and 200+100+100 slot provenance. Profile script/physics/render CPU time, RAM and draw calls with Godot profiler rather than assuming scene count equals actors.

## Tests and legacy risks

Official Godot 4.7.2 focused gates: `pve_r12_balance_contract_test.gd`, `pve_r12_live_reward_save_test.gd`, `gp_02c1_injury_settlement_test.gd`, `pve_map02_cluster_capacity_test.gd`, B3 `b3_care_pills_autohunt_test.gd`, `b3_fasttrack_hunt_test.gd`, plus older PvE/Save.
- The first tests proved real HP0 + full HP terminal + Injury=1, paid 30min appointment, 1500 Stone debit exactly once, unchanged HP, cold Save, 29/30 tick completion, and 20 camps/200 slots/40 active structural invariants.
- **Check latest run SHA** for B3 extended cumulative before claiming FULL PASS.
- Old `CombatSystem` P2 legacy defeat still uses HP=1 and its own heal fee; it is not the P0/B3 canonical world-return authority. Analyze actual reachability for V2 before migrating it; never silently convert P2 Save or claim full HP everywhere without evidence.
- Even if all headless pass, physical Windows/Android FPS and real input/graphics remain PENDING.
