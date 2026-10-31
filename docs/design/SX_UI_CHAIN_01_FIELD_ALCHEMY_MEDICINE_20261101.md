# TMB — SX-UI-CHAIN-01: Linh Điền → Luyện Đan Điện → Dược Phòng (design-to-code, source-first)

**Status: DESIGN READY FOR SOURCE-BINDING REVIEW; NOT RUNTIME CODE / NOT TESTED / NO BALANCE AUTHORIZATION.**  
Date: 2026-11-01. Baseline ONE GAME \`199f888c7fd690830728dfbf29b6b79276e3b283\`. No existing branch changed.  
Purpose: a coherent 1280×720 Godot UI/UX implementation brief that Codex can read **after** fixing the Dẫn Tiên C2 and SX-01/SX-02 technical blockers.

## A. Sources inspected and source-of-truth rule

- Runtime/building: \`BuildingSystem\`, \`SpiritCropRegistry\`, \`WarehouseSystem\`, \`WorkforceSystem\`, \`B3PillSatietyV1\` / \`B3MedicalAutoplayV1\`; UI: \`p3_2_landscape_sect.gd\`.
- SX-01 Draft PR #57 (2/8 PASS): \`docs/qa/SX01_SELF_IMPLEMENTATION_REVIEW_20261031.md\`.
- SX-02 Draft PR #58 (7/11 PASS): \`docs/qa/SX02_MEDICINE_ROOT_CAUSE_AND_DESIGN_CODE_LEDGER_20261031.md\`.
- Independent G1–G4 SX checkpoint on PR #59 and Issue #56 comment 6546102114.
- **A registered item ≠ an obtainable ingredient ≠ a tested recipe ≠ a drinkable medicine ≠ a player-visible closed loop.** The UX must show provenance and disable unsupported action; never present catalogue future tiers as craftable now.
- Everything labelled as "candidate" in #57/#58 is candidate code, **not accepted balance or current ONE GAME gameplay**.

## B. Visual system

Landscape **1280×720**. Dark jade / parchment / antique gold compatible with HS-09. Map is main surface; focused management popover occupies right ~420–520 px, keeping a slice of world visible for normal workflows. A larger centered modal is permitted for multi-target stock policy, but must close to the same selected building/camera. No full-screen wall of paragraphs. Label fonts readable on Android; discrete short lines, big action targets, touch scroll, gamepad/back/Escape. 
- Tab icons, recipe items, herbs, pills, grade stamps and VFX are **reserved PNG/animated slots**, loaded from verified assets when available. Blank or clearly marked fallback otherwise. **Source A authorized for disciples** via existing verified pool; no AI art inserted as Source A, no uncontrolled redistribution.
- Each action shows cost/duration/materials, blocked reason, before→after result, source authority and a focused view of actual warehouse quantities. No fake preview income or equipment effects.
- Color is informative, not exclusive: item quality also has text labels, accessibility contrast and symbols.

## C. Three connected screens — workflow contracts

### C1. Linh Điền panel (map → field click)

**Header:** building level, fields in use / capacity, herbs currently growing, Linh Thạch, next harvest timing, upgrade state/gate.  
**Plot grid:** one compact tile per plot, states EMPTY, GROWING, HARVEST_READY when actually supported; show crop thumbnail, crop name, assigned disciple avatar from Source A if asset present, cultivation profession Lv, paid cost, remaining simulated time, expected **base** yield clearly distinguished from actual settlement.  
**Controls:** choose crop only from \`SpiritCropRegistry.eligible_crop_ids(field.level)\`; modes AUTO_DEMAND / PRIORITY / FIXED from \`BuildingSystem\`, but LV and candidate-authority validation apply. User explicitly controls manual vs auto. Each slot maps to one real worker; busy disciples are visible but cannot be taken without a confirmation/cancel path.  
**Outputs:** warehouse quantity (total / locked / reserved / available) for Linh Cốc, Thanh Linh Thảo, Tử Vân Thảo, no duplicate quantity from old legacy buckets. "Đến Luyện Đan" goes to selected Alchemy Hall.  
**Caveats:** Current ONE GAME has older Lv1–9 AUTO_DEMAND and some policy restrictions (FIXED/Priority Lv10); proposed SX-01 demand planner is Draft, not proven. Linh Điền Lv100 requires 29 Linh Tuyền Chi Tâm in static path; source/acquisition uncertainty must appear as gated content, not a ready-to-upgrade button.

### C2. Luyện Đan Điện panel

**Header:** Lv, alchemist slots/occupancy, warehouse input, active paid jobs, recipe mode and latest real receipt.  
**Recipe collection:** each card has real source-backed recipe name, realm/tier, resulting quality/SKU *if authoritative and fixed at job start*, materials needed/available, duration, profession and Hall prerequisites. Show two existing legacy pills as legacy IDs. The SX-02 240 IDs are viewable in a **catalogue/locked tab**, but only four rank1/2 newly authored definitions exist and are not yet Godot accepted; rank3–30 has **NO RECIPE** and must be locked.  
**Player controls:** select known recipe, assign an eligible alchemist, choose manual vs approved auto policy, start legal timed job, cancel with documented consequence if supported, set target stock only when SX-01 policy has been approved and QA passed. Do not invent manual-claim buttons or zero-time crafting.  
**Results:** actual output SKU credited to canonical Warehouse once, exact source→pill provenance, Save/Reload frozen grade/recipe/cost and no double grant. Link "Xem Dược Phòng".  
**Caveats:** ONE GAME Alchemy Hall upgrade is disabled; SX-02 upgrade economics are provisional, so Lv gate and rank2 recipe can appear BLOCKED. Do not draw rank2 as player-reachable until Field Lv30 source and Hall Lv10 gates are playable.

### C3. Dược Phòng panel

**Header:** real warehouse medicine stock by SKU, reserved/usable, HP/Injury status, B3 satiety remaining of owner-locked 1,000,000/day and policy enable/disable state.  
**Roster table:** compact disciple rows searchable by name, realm, HP, B3 daily satiety, active job, current auto priority. Source A avatar only where verified. Distinguish Injury120 from HP loss; never promise that an HP pill cures Injury.  
**Actions:** manual pill use is explicit choice SKU + disciple with before/after HP or Tu Vi projection from the **actual canonical B3 consumer**. Auto policy only toggles valid mechanisms, respects One Active Job, busy guards, satiety, reserves, quotas, and recipe/realm compatibility; dormant controls marked unavailable rather than simulated. Show daily use counter and stock target for permitted profiles when policy works.  
**Receipt:** each actual use lists resource SKU, user, effect, satiety cost, stock before/after, and stable receipt ID. Existing old HXD +55 HP and TQD +10,000 Tu Vi remain canonical when operating in legacy pathway. No direct UI mutation of HP/EXP.  
**Caveats:** SX-01 policy roundtrip and SX-02 CARE reload currently FAIL. Do not enable full auto graded medicine as a player feature until #57/#58 runtime and version migration pass. No extra passive pill effects invented.

## D. Critical UX decision flow

\`Select field → choose legal crop → reserve/payment → assign worker → timed growth → warehouse receipt → open Alchemy → choose obtainable recipe → reserve once → timed output + frozen quality → warehouse SKU → Dược Phòng → select recipient and legal pill → B3 consumer → receipt → Save/Reload\`.

At each gate, show one of: **AVAILABLE / COST SHORTAGE / WORKER BUSY / BUILDING GATE / MISSING SOURCE / POLICY OFF / NOT TESTED**. A card with no producer displays "Chưa có nguồn kiếm vật phẩm", never a fake "Craft" action.

## E. QA and handoff

- Render REAL 1280×720 Godot UI from exact tested SHA and installed assets, not generated concept screenshots; verify 8GB memory idle and many workers.
- Automated fixture at min tiers: crop start/paid once, exact crop job persisted, Warehouse stock, Alchemy paid job, quality SKU if authorized, B3 use, satiety, Save/Return/Reload/offline exactly-once, no duped receipt. Production authority tests and G0 Save/Reload 14/14 must remain green.
- In #57/#58 candidate context, reproduce known-red 2/8 and 7/11 before fixes. Fix parser, JSON numeric type, CARE v4/v5 assertions without weakening production invariants. Only claim integrated UX when gameplay source, consumer, persistence, Godot test and real GUI all PASS.
- **Owner approvals pending:** quality multipliers, grade cutoffs, Hall cost/upgrade law, quotas and defaults; source paths for missing milestone components; source/loot rates. Keep candidate values OFF / unmerged until decisions.
- No merge of this design-only branch; implementation is a separate scoped PR after technical blockers are repaired.
