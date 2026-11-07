# SX-ECO / Real Production & Spirit Stone Economy Audit — 2026-11-07

**PR #72 only. QA status: SOURCE IMPLEMENTED, NOT GODOT-ACCEPTED.**
No release/merge until 4.7.2 tests, save-load and actual 1280×720 mouse QA pass.

## Direct answer: where do Spirit Stones come from?

1. **Initial grant, not income:** `TechniqueSystem.INITIAL_SECT_SPIRIT_STONES = 500` exactly once when the technique economy is first initialized. Re-initialize after zero balance must never mint again.
2. **Repeatable sect income:** player earns Stone by selling **actual, unreserved Warehouse stock** at `Kho → Phường Thị`, via `EconomySystem.sell_to_npc_v1`; it records a durable request-ID receipt. New games automatically enable Economy-A; existing saves stay opt-in and can enable the market from Kho/Đại Điện.
3. **Prices already authored:** Linh Mộc 2 LT; Thanh Thiết 8 LT; Thanh Linh Thảo 6 LT; Linh Cốc 4 LT. Huyền Thiết 34 LT at the new market outlet when actually obtained. NPC demand pilot is currently 20 units/day total (1,440 simulation ticks/day, max 5 per sale). This quota and production scale are **pilot, not the owner's accepted late-game balance**.
4. **Other valid, distinct sources:** selling a *real owned* technique manual gives Sect Stones via `TechniqueSystem.sell_manual`; legacy hunt can grant *personal* Stones, not Sect Stones. Personal wages are a **transfer** out of Sect funds, not income.
5. **Never claim** an idle mine creates Stones, or that a listed item was sold without decreasing Warehouse, or that an item bought at NPC market was player-produced.

## Stone outflows and economic guards

- Planting crop: 3 LT Linh Cốc, 4 LT Thanh Linh Thảo, 14 LT Tử Vân Thảo (real debit on sowing).
- Construction/upgrade: wood + ore + Stones, milestone components where authored; charged once when real upgrade starts.
- Market purchase: item price × actual quantity (default markup ×2), durable receipt. A purchased `Tầm Mạch Bàn` costs 160 LT at current markup, is limited to one NPC stock/day, and unlocks Mine milestones at Lv10/20/30/50/75/100; cannot be sold back to the NPC via resource-sale route.
- Separate other owners: techniques/gacha, cultivation, recruitment, alchemy materials, personal healing and paid wages. Do not treat personal Stone transfers as new Sect income.
- Auto-demand Field is now bounded by actual Warehouse stock **plus growing plots**; when all stock targets are filled it stops planting/spending. Fixed crop and explicit per-plot overrides remain deliberate player choices and may continue spending until affordability stops.
- Per-plot policy is stored with the building. Growing plots cannot be retargeted; selecting a crop does not pay or mint anything.
- New crops: **Profession EXP snapshots on planting and settles only after real harvest is delivered** to canonical Warehouse. Old in-flight plots have no pending-XP field because their EXP was paid at planting; they must not be paid a second time. Cancellation of a new plot grants no EXP.

## Current XP, output, upgrades

- Mine / Linh Lâm: 10 base profession EXP per completed delivered cycle or timer; learning coefficient applied by the real WorkforceSystem. Alchemy: 10 base per delivered batch.
- Field: 8/10/16 base EXP per delivered crop (Linh Cốc / Thanh Linh Thảo / Tử Vân Thảo) × profession learning × Field XP level factor.
- P3.7 professional level = floor(sqrt(total profession EXP / 24)), speed +1% per level before other modifiers.
- Paid upgrade buttons are present above rosters for Mine, Linh Lâm, Field, Alchemy; Forest uses **provisional** Mine cost basis until balancing approval. Mine's Lv10+ milestone resource now has an actual paid market source. Field still relies on 100 harvested fragments → 1 Linh Tuyền Chi Tâm at required milestones.
- Timer V2 Mine/Forest now samples the same facility time factor at job start. Job duration is pinned; an upgrade does not retroactively shorten an in-flight job. Integer-minute rounding means a +0.5% facility factor will not always save an integer minute immediately.

## High-priority remaining acceptance blockers

1. **Current throughput is not balanced to the locked 60–180-minute/10k-scale long-term production goals.** Current default Mỏ/Linh Lâm = 2 basic units/cycle at Lv1; Economy-A base timer 10 simulation minutes; Field crop timers 10/12/24 minutes. Market quota is just 20 units/day. Build staged economy simulations to settle source/sink rates and price targets before calling production complete.
2. No verified Windows/Godot 4.7.2 GUI mouse run on this HEAD. CI workflow jobs are currently reporting failure without retrievable steps/logs. Do not mark PASS or claim playable/staging ZIP rebuilt.
3. Tầm Mạch Bàn shop is a paid source. The intended PvE rare-drop/crafting progression for Mine specialty components is still **not implemented**. Linh Lâm milestone-specific rare contents also remain future content.
4. Field plot EXP migration needs regression against cold-save/reload and an in-flight **legacy** plot. Canonical SaveService must show exactly one payout and no second reward after reload. Verify callback behavior and UI clipping at 1280×720.

## QA commands/gates

- Import/check-only all modified GDScript on Godot 4.7.2.
- Run `godot/tests/simulation/production_exp_upgrade_contract_20261107_test.gd`, `godot/tests/simulation/production_stone_closed_loop_20261107_test.gd` and P3.7 A1/A2 backend tests.
- Run GUI O1/O3/O4/O5/O7/O9/economy_a_landscape_ui_test; verify actual clicks, stock quota, purchased board and every planted plot independently.
- Run SaveService cold reload with paid upgrade, pending Mine/Forest/Alchemy timers, old and new crop plots and exact unchanged receipts.
- Evaluate staged, non-free-provision simulation (60min/one day/30 days) before changing owner-locked balancing numbers.

**No merge. No invented resources. No UI-only reward.**
