# TÔNG MÔN BÁ ĐẠO — TÔNG VỤ / BACKEND GAP & ACCEPTANCE MATRIX
Date: 2026-10-30
Status: DESIGN-BACKLOG ONLY, NOT AN AUTHORIZATION TO CODE
Reference: docs/design/TMB_TONG_VU_UIUX_V1_20261030.md (3-screen design approved by owner).
Read-only audit: `integration/one-game-v65-20261030` was initially aligned to RC #52 when checked. Re-fetch exact HEAD and diff before any implementation.

## 0. Chốt thiết kế KHÔNG có nghĩa là chốt backend

- Owner approved 3 **layout designs**: Tổng Quan, Sản Xuất, Nhân Sự.
- Existing simulation/authorities may support some actions, but **Tông Vụ itself has NOT been implemented or tested in Godot**.
- This file isolates missing mechanics from visual work. Only the ONE GAME integration owner may later approve a code packet with exact changed-path ownership. No updates to `main` or integration branch here.
- No fabricated resource/capacity/receipt, no action that changes `SimulationState` directly from UI, no forced cancellation of `One Active Job`.

## 1. Existing backend surfaces to reuse

| Component | Observed evidence | Permitted UI use |
| --- | --- | --- |
| BuildingSystem and SimulationState | `building_system.gd`: building definitions, `assigned_worker_ids`, `active_worker_ids`, `can_disciple_work` | Display real instance, level, worker slots, status; allow actual eligible assignment via authority |
| Building upgrade | `can_start_upgrade`, `upgrade_cost`, `start_upgrade` | Enabled only when validated; reject `already_upgrading`, missing material, missing milestone, etc |
| Spirit Field | `set_spirit_field_policy` supports `auto_demand`, `priority`, `fixed` | Select from actual crop registry; fixed/priority policies require field Lv >= 10, and running plots are not arbitrarily canceled |
| Alchemy | `set_alchemy_recipe`, `set_alchemy_recipe_enabled` | Recipe selection applies to **future jobs only**; active job keeps frozen recipe |
| Forge | EquipmentSystem real craft actions, P3.4C documented 5 real recipes | Expose valid recipe/material status only; no invented production line |
| World focus and P3.4 panel | P3.2 map focus and building panels | Need dedicated bridge from Tông Vụ + return context |
| Warehouse | Real quantity/available balance and settlement | Stock totals, not fictional global capacity |
| Source A assets | Partial verified packs + scene/map provenance in PR #28 / RC #52 | Art may be reused only after matching asset SHA, runtime import, license/provenance gates |

## 2. P0 — must block live UI behavior where absent

| ID | Gap | Required resolution | Negative test |
| --- | --- | --- | --- |
| TV-BE-01 | New Tông Vụ screen has no proven live controller/connector | Implement screen wiring to SimulationState and existing commands; maintain no UI-owned game state | Every active button must invoke authoritative action, never just visual success |
| TV-BE-02 | Batch workforce optimizer not verified | Suggest only eligible idle disciples, rank by **correct profession mastery and verified efficiency**; one worker per slot, no duplicates; explicit player preview/confirm | Never auto-reassign a disciple with active job; reject stale suggestions, insufficient slots, race with PvE |
| TV-BE-03 | Policy orchestrator across all production facilities not established | Phase rollout: start with real Spirit Field and Alchemy; keep other types read-only unless engine supports actions | Never auto-cancel crop, duplicate input, consume unapproved material or invent cycle outputs |
| TV-BE-04 | Batch upgrade and auto-upgrade policy not established | Preview per-building `can_start_upgrade` with total costs/reserve; no partial over-spend; check exact validity again before each execution | No fake/duplicate upgrade or funds charged twice on save/reload |
| TV-BE-05 | Some building upgrades intentionally disabled | `linh_forest` and `alchemy_hall` definitions had `upgrade_enabled=false` at audit | Their Nâng cấp controls hidden/disabled until game design+backend formally approve |
| TV-BE-06 | No general warehouse capacity for all stock | Remove "Kho 75%", "sắp đầy", global full-kho trigger; use **stock target reached** only when target exists | Do not display an arbitrary storage capacity or sell/convert raw stock automatically |
| TV-BE-07 | Crop selection has level guards | Fixed/priority modes only for valid Lv>=10 fields; valid crops checked per level | Changing Lv1 plot to fixed/priority must not succeed |
| TV-BE-08 | State persistence and exactly-once with new batch policy | Save request/configuration, batch decision receipts, offline replay semantics aligned with canonical SaveService and Warehouse | No double payout, no double payment, no job reset after reload |

## 3. P1 — UI integration/quality, not new game mechanics

| ID | Work | Acceptance |
| --- | --- | --- |
| TV-UX-01 | Map **Tới**/Return connector | Correct building instance focus + panel, back to exact tab/filter/scroll; no camera or zoom regression |
| TV-UX-02 | Sản Xuất density | One canonical list; two row actions Tới / Quản lý; details panel owns production, personnel and upgrade buttons |
| TV-UX-03 | Nhân Sự sort/filter | Idle toggle, profession level sort, optional condition filter, real texts/statuses only |
| TV-UX-04 | Tổng Quan & alerts | At most 3 meaningful decision cards; no mock stats, fake inventory cap or spamming |
| TV-UX-05 | Image provenance | AI image is reference only; verify exact Source A imported art, font/readability/contrast |
| TV-UX-06 | Android / Windows QA | 1280x720 touch targets, no nested scroll trap, mouse pan/zoom unchanged, screenshot comparison |
| TV-UX-07 | Runtime performance | No large screen rebuild on every poll; incremental refresh/cache; ensure 8 GB Windows machine tolerates QA |

## 4. Behavioural gates for release

1. Open each of 3 Tông Vụ tabs against **real game state**; refresh values without duplication.
2. Navigate **Sản Xuất → specific instance → Tới → world map → return**.
3. Assign idle disciple using real profession data, compare recommendation with the actual eligibility policy; no active job canceled without separate explicit confirmation.
4. Change a *valid* Linh Điền policy, persist through save/load, ensure job-in-progress remains uninterrupted.
5. Select a new Alchemy recipe, verify running job unaffected, future job uses new recipe.
6. Upgrade eligible building with real resources; disabled types stay disabled, shortage warnings show correct quantities.
7. Batch operations idempotent and reversible only to the extent the real engine supports; no fabricated rollback.
8. Verify actual GUI screenshot + input, Android testing, focused regressions, exact merged SHA with owner acceptance.

## 5. Implementation ordering once the integration branch is stable

**Minimal viable Tông Vụ:** read-only 3 tabs + correct per-building panel/Tới/return + existing atomic commands. This allows a usable UI before complex smart automation.

**Next:** safe manual/batch assignment and batch upgrade preview, with exact authoritative checks.

**Later (not a release blocker for first screen):** smarter optimization and cross-facility production planner, advanced rules and policy engine.

**Do not create separate urgent tasks or wake up Codex now.** The integration hub remains https://github.com/vuanhtuan161094-byte/TongMonBaDao/issues/56. This matrix is a future handoff, not a new lane or immediate work order.
