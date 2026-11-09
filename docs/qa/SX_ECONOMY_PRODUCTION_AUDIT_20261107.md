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
- `Mảnh Linh Tuyền Chi Tâm` is also available from a **paid** NPC market stock of up to 20 fragments/day at current 4 LT/fragment (resource market value 2 × markup 2). The existing scarce genuine harvest drop remains valid. Buying fragments immediately invokes the existing exact 100 fragments → one Heart Warehouse conversion. These purchased fragments cannot be re-sold to the same NPC.
- Separate other owners: techniques/gacha, cultivation, recruitment, alchemy materials, personal healing and paid wages. Do not treat personal Stone transfers as new Sect income.
- Auto-demand Field is now bounded by actual Warehouse stock **plus growing plots**; when all stock targets are filled it stops planting/spending. Fixed crop and explicit per-plot overrides remain deliberate player choices and may continue spending until affordability stops.
- Per-plot policy is stored with the building. Growing plots cannot be retargeted; selecting a crop does not pay or mint anything.
- New crops: **Profession EXP snapshots on planting and settles only after real harvest is delivered** to canonical Warehouse. Old in-flight plots have no pending-XP field because their EXP was paid at planting; they must not be paid a second time. Cancellation of a new plot grants no EXP.

## Current XP, output, upgrades

- Mine / Linh Lâm: 10 base profession EXP per completed delivered cycle or timer; learning coefficient applied by the real WorkforceSystem. Alchemy: 10 base per delivered batch.
- Field: 8/10/16 base EXP per delivered crop (Linh Cốc / Thanh Linh Thảo / Tử Vân Thảo) × profession learning × Field XP level factor.
- P3.7 professional level = floor(sqrt(total profession EXP / 24)), speed +1% per level before other modifiers.
- Paid upgrade buttons are present above rosters for Mine, Linh Lâm, Field, Alchemy; Forest uses **provisional** Mine cost basis until balancing approval. Mine's Lv10+ milestone resource now has an actual paid market source. Field requires **exactly 100 accumulated fragments** to obtain a Linh Tuyền Chi Tâm; fragments come either from genuine harvest or the paid capped NPC market, never from a free milestone grant.
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

## SX-07 appended audit — 2026-11-09 (code SHA `c05b1aac9ffe186ebefe56395dfa4ec6abfe6556`)

The V5.6-G 630×270 workbook is **DESIGN, not runtime**: 630 unique material IDs, 270 proposed source profiles, 119 proposed recipes, 476 SKUs and 2,049 proposal BOM rows. Only 6/630 design material IDs exactly match the static `ResourceRegistry.DEFINITIONS` IDs; 624 are not registered. All 270 profiles are `DESIGN_MAPPING_NOT_RUNTIME`, so none may be called a live Mine/Forest/Field output. Eight beast/body IDs outside the 630 proposal exist separately in the runtime ResourceRegistry (116 design BOM lines): this mismatch requires catalogue reconciliation rather than adding duplicate IDs.

SX-07 restored eight **existing early authored** recipes via removal of a dead `return {}` and upgraded actual Mine/Forest/Field/paid-NPC provenance gates. Of 119 identities, **111 remain intentionally not craftable** until real source jobs and materials exist. V5.6-G realm-1 Heal/TuVi/Body BOMs are aligned for explicit-grade mode; five other early recipes retain pilot recipe definitions, not a claim of exact G-balanced cost. Batch cost estimates use registered resource reference resale values and current wage; exclude crop sowing, taxes, time and NPC premium. New test: `godot/tests/simulation/sx07_source_provenance_test.gd`. Official Godot evidence not yet available for current SHA. Windows GUI/Android **PENDING USER**.

Next authorized source packet candidate: reconcile real V5.4 source CSV and first additional full source→timed job/earned PvE receipt→Warehouse→alchemy→consumer slice; **not** mass-register 507 proposed placeholder IDs or fabricate 270 worksite outputs.

## SX-07B owner-packet addendum — 2026-11-09

Five material IDs retained from V5.5-D now have canonical Mine/Forest timed output selectors on PR #72 at code SHA `98642da36abb25f260de0e3dcaba5762d35804c0`. None is fabricated. The V5.6-G 270 source profiles are NOT activated as new world site IDs or 8-unit yields; current generic worksite formula and real job scheduler remain authoritative. The two proposed r1/r2 BOM replacements were withheld/reverted to avoid a GUI softlock until selectors become usable in the legitimate production panel. Detailed trace: `docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md`. Aggregate after this packet: 11/630 registered, 619 not registered (112 preserved, 507 proposed); 111/119 high formulas blocked. Focused Godot and GUI still PENDING.

### SX-07B CI status at `98642da36abb25f260de0e3dcaba5762d35804c0`

The latest O9 workflow run [42586042509](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/42586042509) has conclusion **FAILURE**. Its job exposed no steps and completed in roughly two seconds; logs were not available through the GitHub connector. This is NOT a Godot PASS and does NOT establish a code defect as root cause. See `CURRENT_CHECKPOINT.md` and `docs/qa/SX07B_PRESERVED_MATERIALS_SOURCE_GATE_20261109.md`. 619 material IDs and 111 recipes remain blocked as design/integration debt.
