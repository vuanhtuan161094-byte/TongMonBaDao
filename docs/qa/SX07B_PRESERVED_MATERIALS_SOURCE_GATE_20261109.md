# SX-07B — Preserved materials, real producer routes and deferred BOM activation

**Date:** 2026-11-09. **Repo/branch:** `vuanhtuan161094-byte/TongMonBaDao`, `integration/pve-p0-playable-ui-20261103`. **Code SHA (before this doc commit):** `cc389cee15a57c44e4c03f223a954f1d503f6f95`.

**Authority:** owner-approved SX-07B; `AGENTS.md`, architecture and checkpoint. No second Warehouse, scheduler, active-job owner or Save schema. Godot 4.7.2 / Windows / Android not yet verified on this SHA.

## Traceability — only five IDs promoted, none invented

| ID | Original preserved name | Identity evidence | Real timed producer | Required level | Design reference LT | Runtime resale |
|---|---|---|---|---:|---:|---|
| `ore_r01_c2` | Xích Đồng | V5.5-D ID preserved | Mine via `select_mine_ore` | 1 | 10 | **not listed** |
| `forest_r01_wood2` | Thanh Trúc | V5.5-D ID preserved | Forest via `select_forest_material` | 1 | 3 | **not listed** |
| `ore_r02_c2` | Trúc Cốt Sa | V5.5-D ID preserved | Mine via `select_mine_ore` | 10 | 42 | **not listed** |
| `forest_r02_wood` | Thanh Trúc Mộc | V5.5-D ID preserved | Forest via `select_forest_material` | 10 | 8 | **not listed** |
| `forest_r02_wood2` | Lục Văn Sam | V5.5-D ID preserved | Forest via `select_forest_material` | 10 | 13 | **not listed** |

Reference values are tagged `V56_G_PROPOSED_REFERENCE_NOT_TRADEABLE`. These do **not** add NPC sell/buy opportunities or Sect income. They are **not** approved LT2/T2/W2 prices.

## Real transaction / migration

- Existing `BuildingSystem` Mỏ/Forest jobs freeze `resource_id`, amount, start/finish tick and worker at start. Existing timer and carry-cycle settlement enters one canonical Warehouse; profession XP and transferred wages settle only on delivered work. No generated worksite or fake loot.
- Existing mine selector gains two real IDs. Forest gains a BuildingState-owned output selector with default `linh_moc`, respecting old saves. New selection affects future jobs **only**; current jobs continue their saved output, quantity, timer and payable wage receipt. Level ≥10 selection uses the existing paid upgrade mechanism. The SOURCE design profile's 8 units per 10-minute job is **not** ported: canonical runtime `_resource_job_batch_units` still controls real quantity, base 2 at Lv1.
- Existing `validate_invariants` now recognizes selected Forest carry-output IDs and checks both producer types' frozen timed-output identities and positive quantity.
- **GUI softlock guard:** the existing Mine picker currently hardcodes Thanh Thiết/Huyền Thiết, and the Forest has no material selector. Per SX-07B code allowlist, presentation is NOT modified. Hence the **existing eight early medicine pilot BOMs are preserved**. The V5.6-G r1 breakthrough proposal requiring Xích Đồng+Thanh Trúc, and r2 Heal proposal requiring Thanh Trúc Mộc, remain **DESIGN_HOLD for player craft activation** until the proper GUI or canonical player command exists. No previous playable recipe is silently locked by an unavailable new selector.
- **QA source:** `godot/tests/simulation/sx07b_preserved_source_job_test.gd` covers all five real producer choices, Lv10 blocking, frozen job identity on selection change, mid-job cold Save/Load, exact Warehouse units, one profession XP settlement, single wage receipt, and redundant-tick replay. Existing `sx07_source_provenance_test.gd` covers eight authored early recipes, all 111 blocked and quality BOM source routing.
- **No engine test PASS is asserted.** This environment has not executed official Godot; PR workflow test is registered. Run exact-SHA official Godot focused + old save/carry/production regression; Windows owner GUI and Android physical test are **PENDING USER**.

## Inventory and design gap

- Original V5.6-G classification: 630 material slots = 6 pre-existing runtime IDs + 117 V5.5-D IDs preserved (not necessarily V5.4 original) + 507 proposed/generated IDs without original V5.4 CSV provenance.
- SX-07B adds exactly five of the 117 preserved IDs to runtime: now **11/630 registered**, **619 missing** = **112 preserved-but-not-registered** + **507 unverified proposed**. 270/270 G source profiles remain design mappings, **not real instantiated site profiles**. Five outputs are delivered by pre-existing generic Mine/Forest instances, not by new `MO_Rxx_A` or `LAM_Rxx_A` worksite objects.
- 119 recipe IDs / 476 pill item IDs still exist; **only 8 early recipes are authored**, 111 remain intentionally not craftable. Only the original three early realm-1 grade-mode base BOMs (Heal, TuVi, Body) match G design; other five remain documented pilots. Q2–Q4 catalysts and exact fully landed economic cost await SX-08 verification.
- The old 8 body/beast ingredient IDs outside the proposed 630 slots are already registered and are **not duplicated**.

**Next required decision:** SX-07C to expose backend source selection safely through existing production panel, then integrate proven BOMs and verify earned stock → Alchemy → consumer using Godot; or SX-07B/QA to run focused regression first. Do not unlock late formulas without original IDs plus production/reward sources; do not port 270 design profile outputs as if implemented.

