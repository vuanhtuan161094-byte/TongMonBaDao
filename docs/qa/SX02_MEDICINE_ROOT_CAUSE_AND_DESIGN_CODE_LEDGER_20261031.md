# TÔNG MÔN BÁ ĐẠO — ROOT-CAUSE + DESIGN-TO-CODE REGISTER (2026-10-31)

**Owner direction:** code real gameplay, do not leave design in chat. Prioritize production + cultivation + PvE. Sect/NPC world design remains deferred. Do not deploy or merge without Godot 4.7.2 QA.

## Root-cause (evidence-based)

1. **Pilot-to-production gap:** `AlchemyRecipeRegistry.DEFINITIONS` had only `hoi_xuan_dan` and `tu_khi_dan`. B3 was written as a deliberately narrow two-item CARE pilot. Tests proved that pilot, not 30-realm, quality-bearing medicine gameplay.
2. **No product identity across boundaries:** `ResourceRegistry` and `WarehouseSystem` kept medicine as two plain stacks. Without tier/quality SKUs, a recipe cannot persist the potency and provenance of each output, and distribution cannot select the right product.
3. **No source–consumer coverage gate:** designs named hundreds of future ingredients, but many do not have verified obtainable sources; only specific field crops, limited market and some PvE F3 routes were real. Adding recipes without real sources softlocks the player.
4. **Missing advancement path:** `BuildingSystem` explicitly disabled Alchemy Hall upgrades (and Linh Lâm). Quality gated by facilities therefore had no actual progression route.
5. **Authority drift:** documents disagree in scope and numeric law (old 1000–3000 disciple / 5-person hunt vs recent owner-approved ≈480 capacity / 6-person PvE; retraced Economy V7 three-slot items vs Equipment V2 10+3+2+4). A design decision is not an implemented feature until its runtime owner, producer, consumer, save contract and test are linked.
6. **UX-only evidence was not enough:** SX-01 was committed, but Godot import, actual 1280×720 GUI, 90/200/480 simulation, Save/Reload and economy survival did not pass in this environment.

## SX-02 code implemented (Draft, no Godot pass)

| Runtime authority | Implementation | Safeguard |
|---|---|---|
| `MedicineCatalogueV2` | **30 Tu Vi realms × 4 quality grades × 2 functional families = 240 separate item IDs**, deterministic per-item effect metadata, no warehouse dependency | 30 realm names match `REALM_LADDER_V2_SPEC`; higher-tier unsourced recipes fail closed |
| `ResourceRegistry` | Dynamic identity/metadata for all 240; Warehouse unchanged and still uses original locks, `reserve_min`, atomic stacks | No parallel medicine inventory or resource grant |
| `AlchemyRecipeRegistry` | Rank 1/2 Hồi Nguyên/Tụ Linh actual ingredient definitions; rank3–30 NO recipe until real ingredient source authored | Original `hoi_xuan_dan` and `tu_khi_dan` unchanged |
| `BuildingSystem` | Alchemy Hall upgrade via provisional common-resource cost; validates building level; output quality determined by profession level + building level at job start; frozen in paid job output ID | Inputs paid once, pending job persists; grade cannot change after save |
| `B3PillSatietyV1` | Shared satiety and receipt consumer accepts catalog IDs; actual numeric potency, no gate overflow, Injury120 unaffected | Original hard cap 1,000,000 / 1440 ticks, legacy +55/+10,000, costs 10/25 and old receipts unchanged |
| `MedicineAllocationV2` | Stock-aware highest useful legal-tier pill lookup with no bypass of Warehouse `locked/reserve_min` | Catalogue remains pure data; avoids circular resource ↔ warehouse dependency |
| `SX01PillPolicy` & `B3MedicalAutoplayV1` | Graded medicine preferred where stocked; CARE fallback still original HXD and REST | One shared B3 account, occupation guards remain in force |
| `p3_2_landscape_sect.gd` | Select authored realm recipe (1/2), list existing graded pills and manual use | No arbitrary custom images, no GUI health/EXP mutation |
| Two new focused tests | Catalogue 240 IDs/sources/gates; real Alchemy job→warehouse→B3→Save | Tests **written but not executed** |

**IMPORTANT owner vs candidate distinction:**
- **Owner direction locked:** medicine scales by cultivation realm; medicine has product grade; production and consumption must be connected; keep existing B3/V2/Save compatibility.
- **Implementation candidates, NOT owner-approved balance:** FOUR grades Hạ/Trung/Thượng/Cực; coefficients 1.00/1.25/1.55/2.00; healing base 55 ×1.65^(realm−1), Tu Vi base 10k ×1.65^(realm−1); Hall/Alchemist grade thresholds (1/5/10/20 and 0/2/5/10), provisional Hall upgrade costs, temporary input recipes for rank1/2.
- New medicine is **not** proof that 30 ranks can be crafted. Only rank1 and rank2 recipes exist; rank2 depends on real Tử Vân Thảo (currently Spirit Field Lv30), so economy/upgrade playability gate remains **UNVERIFIED**. Other 28 tiers explicitly CONTENT_PENDING.

## Mandatory follow-on owner-authority packages (do not silently forget)

| ID | Feature / gap | Status | Next acceptance gate |
|---|---|---|---|
| **SX02-QA** | Import Godot 4.7.2; run new + legacy B3/O8/Save tests; real 1280x720 GUI screenshot | **P0 BLOCKER** | Godot PASS, screenshot, exact SHA; otherwise Draft |
| **SX03-SOURCES** | Medicine ingredient source matrix for realms 1–30, Field/Mine/Forest upgrade loops, quest/PvE loot suppliers | **P0 missing** | Every item has live source, acquisition rate and spend; no impossible milestone |
| **SX04-AUTO** | Per-realm/per-quality target stock policy, consumption forecast, recipe selection and minimum medicine reserves; large-roster AI | **P0 missing** | No micro at 90/200/480; stable save/offline + priority; no hidden sale |
| **MED05-BALANCE** | Grade probability and advancement/worker affinity, HP and Tu Vi curves, cost/satiety by tier, natural resting balance | **Owner review required** | Same-realm usefulness, lower-rank protection and multiple-seed economic simulation |
| **PVE-LOOT** | Normal/elite/boss actual per-kill drops + EXP+Stones credited once into canonical Warehouse/Disciple progress | **P0 missing** | UI hunt→loot→medicine/gear→hunt, no dupes |
| **EQUIP-V2** | Complete 10 worn +3 talismans+2 relics+4 consumables; 12 qualities, 24 set families | **P1 design locked / runtime legacy 3 slots** | Migration and Save/Reload; do not turn old 3-slot into authoritative V2 |
| **CULT-V2** | Tu Vi 30×10, Body 30×10, breakthrough gates, career training source parity | **partial** | Rate/ingredient source/major gate safety across both tracks |
| **WORLD-GOV** | 27 Sect ranks, initial 90/200/400–500 capacity / NPC world etc | **design owner locked, PAUSED** | ONLY after actual production+PvE acceptance |
| **PRODUCT-QA** | Single source of truth, spec→code→test map; CI/QA evidence | **P0 process debt** | Each feature requires source, production receipt, consumer, persistence, tests and real GUI |

## Required QA commands (Windows Godot 4.7.2, isolated E: checkout)

```powershell
$godot = 'E:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' # replace with ACTUAL installed path
$project = 'E:\TongMonBaDaoWorkspace\01_Game\QA_SX02\godot' # replace with clean QA checkout
& $godot --headless --path $project --editor --quit
& $godot --headless --path $project --script res://tests/simulation/sx02_medicine_catalogue_test.gd
& $godot --headless --path $project --script res://tests/simulation/sx02_medicine_runtime_test.gd
& $godot --headless --path $project --script res://tests/simulation/b3_pill_satiety_test.gd
& $godot --headless --path $project --script res://tests/simulation/b3_care_pills_autohunt_test.gd
& $godot --headless --path $project --script res://tests/presentation/p3_o8_alchemy_loop_test.gd
```

**No actual Godot binary in current assistant runtime. No import, code parsing, interactive GUI, performance or Save/Load tests have executed here. STATIC REVIEW ≠ GODOT PASS.** Check actual paths/version and execute one process at a time on the owner's 8 GB machine.

## Release/rollback safety

PR only against `feature/sx01-pill-policy-20261031`, itself DRAFT relative to integration. Do not merge `main` / PR#52 and do not alter user saves. Do not run fixed seed QA on real saves. Save V4 remains canonical. A correct rollback is abandoning the SX-02 branch; original old HXD/TQD saves must remain loadable.

