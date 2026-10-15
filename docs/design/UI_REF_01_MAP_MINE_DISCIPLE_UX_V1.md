# UI-REF-01 — Map → Mỏ → Chọn đệ tử (Godot 4.7.2)

**Date:** 2026-10-15
**Status:** DESIGN + SOURCE AUDIT COMPLETED; VISUAL / GODOT RUNTIME / USER APPROVAL PENDING
**Baseline:** GitHub `main` `461caca1171462e0da092f21108c5c1733157ad9`
**Scope:** 1280×720 Android landscape; source-referenced presentation design only. No Unity migration, no Spine requirement, no Godot runtime/production edits.
**Work branch:** `ui-ref-01-design-20261015`; separate from draft GUI-WORKFORCE-V1 PR #2 (`01272b2d`).

## 1. Decision

Reuse the existing Godot V2 simulation and the **real interaction contracts** already implemented in the GUI-WORKFORCE-V1 draft. Build a game UI, not a staff-management dashboard. Use 最强祖师 / Ta Làm Tông Sư as a **reference for window hierarchy, portrait list, interaction density and asset family**; use permitted Source A images only after locating and verifying actual image bytes. The owner confirms full Source A asset rights for private game development; this does not establish Spine Runtimes licensing. Avoid Spine dependencies for this packet. If art is absent, supply original production art or a visually explicit placeholder pending approval, never claim a placeholder is the previously approved source.

The order is:
1. **Map first** (world scene retains space).
2. Tap Mine → **right concise panel** with active workers, production and 1–3 quick actions.
3. Tap `+` empty worker position / `Điều động` → **one parchment selection overlay**, search and select real disciple.
4. Selection passes through existing WorkforceSystem / relevant BuildingSystem contract, and reflects authoritative state. No gameplay formulas in UI.

Existing V3 source: `docs/P3_REFERENCE_UI_AUDIT.md`, `docs/P3_UX_FLOW_V3.md`, `docs/P3_UX_BUILDING_INTERACTION.md`, `docs/P3_UX_DISCIPLE_SCREEN.md`, `docs/P3_UI_SKIN_AND_ICONOGRAPHY.md`, `docs/P3_2_UI_ART_PRODUCTION_SPEC.md`.
These are canonical where already approved; numbers below are **UI-REF-01 provisional layout measurements**, not a replacement for V3 authority.

## 2. Screen A — World-first map (1280×720)

| Zone | Prototype bounds at logical size | Purpose |
| --- | --- | --- |
| Top HUD | y=0–56 | Sect name, handful of actual key resource chips; do not display all currencies |
| Left task rail | x=12–212, y=84–~345; collapsible | 2–4 useful tasks |
| World viewport | central/background full screen | Buildings, actors, roads, production cues; no grid/table layer obscuring center |
| Bottom navigation | edge-bottom, compact, x≈280–1000, h≈55 | Direct entry to Disciple, Warehouse, Building, World |
| Selected building panel | x≈952–1268, w≈316, y≈70–680 | **Only when a building is tapped**; map still usable |
| World resource cue | anchored to building | `ready`, `blocked`, `working` (only if real state provides it) |

No always-open side dashboard. Camera pan/pinch or wheel affects only world; HUD and overlay do not move/scale with map. One target/panel at a time. Close on X or map blank tap; switching buildings changes the panel without stacking.

**Map proof:** tapping the actual Mine source visual opens the Mine panel; tapping disciple displays V3.2 disciple summary. Buttons that look like actions must work. No fake feature tabs.

## 3. Screen B — Mỏ summary panel (right, approximately 316px wide)

Hierarchy, not arbitrary text dump:

1. Header: Mỏ Thanh Thiết, actual building level/status, small image, X.
2. Production: real production name, progress if supported, time remaining **using canonical simulation tick semantics**, warehouse destination; do not display invented seconds or fabricated ore.
3. Workforce: `real active_count/worker_slots` and assigned **portrait tokens** (portrait 44–52px), short name/current work; blank positions are clickable `+` buttons.
4. Warning/reason: material/capacity/worker condition **only if backed by live read model**. Show one primary warning; explanatory tooltip/deep details if required.
5. Actions: `Điều động` (opens shared picker), `Quản lý` (deep parchment page), conditional real `Thu` / `Sản xuất` only when genuine command exists.

**Avoid:** show `Group_*`, `Work_*` or long serialized state fields as visible player copy; do not remove backward-compatible command handlers needed by existing O3–O9 tests. Preserve collapsed technical controls in test/dev mode until safe migration.

**Busy workers:** do not silently terminate a timed Mine/Forest job, old `work_cycle_state` (including valid `carried_units`), active Field plot, Alchemy, Body reservation or PvE. Disable transfer with the exact reason; empty/full slots remain intelligible.

## 4. Screen C — Chọn đệ tử (shared parchment overlay)

| Zone | Provisional layout | Function |
| --- | --- | --- |
| Backdrop | 1280×720 dimmed map | Blocks world gestures behind modal |
| Main parchment | x≈165–1115, y≈60–660 | Full selection task at 1280×720 |
| Heading + close | top 56px | `Chọn đệ tử — Mỏ`; X large touch target |
| Search/filter | next 52px | Search by name/ID; quick filters `Sẵn sàng`, `Tất cả`, `Đang bận`, `Đã ở Mỏ` |
| Roster area | main body | Portrait-first reusable tiles, **3 columns × 3 rows as a provisional design, not final source-exact claim** |
| Footer | bottom 50px | Actual candidates count, page/next/back; cancel |

A tile: 52–64px portrait, name, profession level, real status, and one action `Phân công`. If busy, no transfer; show reason in tile/tooltip and clearly disabled action. Selected/rare disciples use rarity frame **only when underlying quality is real**. Sorting default: available first, then relevant profession level descending, stable ID/name. Selection updates the current building in-place and closes modal on verified success; failure leaves an actionable reason. A full Mine still allows the user to inspect the roster but must not approve an unsafe assignment.

**Roster at scale:** 1,000–3,000 disciples must not create 3,000 scene nodes at once; maintain a bounded visible page/virtualized list, preserve search/filter/page selection without regenerating unrelated gameplay. Existing eight-rows-per-page logic from PR #2 may be reused; tile count is **visual design proposal**, not a mandated backend rewrite. Search debounce only if actual performance tests justify it.

## 5. Visual system / reusable presentation-only components

Create a consistent Godot UI family when CODE is separately authorized:
- `SectHUD` (resource chip, task rail, edge navigation).
- `BuildingQuickPanel` (one selected building, no duplicated simulation read model).
- `WorkerPortraitSlot` (occupied, empty, disabled/busy states).
- `DisciplePickerOverlay` (single modal shared by Mine, Linh Lâm, Field, Alchemy, Forge, Body).
- `DiscipleRosterTile` (portrait, text, profession, status, safe command).
- `ParchmentSkin` / `SectTheme` with 9-slice frames and fixed palette.

Presentation language: ivory parchment, ink-gray text, muted jade UI, cinnabar primary actions, bronze selected edges, subtle ancient motifs. No neon, business dashboard cards, oversized text tables. Default body text ≈16–18px and status ≈14–16px; no truncation of action/disable reasons; actionable targets ≳44×44 logical pixels. Exact treatment to be visually reviewed in **real Godot**, not approved from this document alone.

Fallback until exact UI skin is available: original simple non-proprietary theme that **does not claim** to reproduce original reference graphics. Portrait fallback may use existing V3 female sample or clear silhouette, but never invent a real individual identity from that art.

## 6. Technical ownership / invariants

Source of truth remains `SimulationState`, `DiscipleState`, `BuildingState`, `WorkforceSystem`, `BuildingSystem`, existing `SimulationScheduler`, one canonical `WarehouseSystem`, and Economy-A jobs. UI calls existing `WorkforceSystem.assign_group`, `assign_worksite`, `issue_command` with current safety checks. Body uses existing body command bridge.

`GUI-WORKFORCE-V1` draft PR #2 already contains a working **code path**, not visual acceptance: `WorkforcePickerOverlay`, `WorkforcePickerPanel`, `WorkforcePickerSearch`, `WorkforcePickerList`, `WorkforcePick_<disciple_id>`, launcher nodes and focused test. Extract/refactor *presentation only* later without breaking these hooks or tests. The decision to combine this design with PR #2 requires a dedicated integration branch and **new owner code authorization**.

**Must not change**: Injury 0/1/120 tick, one active job, legacy drain/carry, complete packet & wage exactly once, Economy-A balances/receipts, PvE 60/40 (not authorized), save migration, workshop/equipment gameplay, scene cameras, map 192×192 or Android landscape authority. UI must show actual effect when backed by authority; no new queuing systems or economy values.

## 7. Proposed CODE packet (NOT granted by this DESIGN completion)

When owner explicitly approves UI code:
- Base/merge strategy: rebase latest `main`, isolate PR #2 visual refactor and preserve functional picker behavior; no direct unreviewed merge to `main`.
- Proposed allowlist: `godot/src/presentation/p3_2_landscape_sect.gd`, focused presentation scene/Control scripts under `godot/src/presentation/p3/` or `godot/scenes/p3/`, new UI theme/art paths only after source bytes and provenance confirmed, relevant focused UI test(s), narrowly scoped checkpoint docs.
- Excluded: `godot/src/simulation/**`, workforce/building/scheduler/save authority, gameplay balance, injury, Unity/Spine, Economy-B/C, FE-02.
- Refactor in two reviewable passes: **A** map + Mine panel and portrait slots; **B** common picker visual tiles & regression preservation.
- Do not delete old test-facing node names or disable deep-action paths without a compatible replacement.
- Static checks alone never establish render quality. Run official Godot 4.7.2 import + focused UI + Economy-A + GP-01/02A/02B1/02C1 + O3–O9/O6 + SAFE-01/02 + P3.7 FULL on exact SHA, then **real 1280×720 Windows screenshot/video** and Android touch/performance as separate proof.

## 8. Acceptance checklist

1. Map feels like a sect scene; UI edge-based; no horizontal scrolling to reach common actions.
2. Mine tap opens right panel immediately; can close/switch buildings without stale panes.
3. Every Mine slot shows actual worker identity or usable `+`; full Mine still provides safe status/reasons.
4. Picker uses visual portrait grid, search and status, correct live profession sorting and usable 44px+ controls.
5. Busy Field/PvE/Alchemy/Body/Mine/legacy-cycle worker rejected without losing goods or silently reassigning.
6. Actual Mine → timer → output to canonical Warehouse and real wages remain unchanged.
7. UI works at 1280×720 and on Android landscape with no clipped text/buttons.
8. 100/500/1000/3000 roster navigation has bounded UI nodes/acceptable responsiveness on target hardware.
9. Source art hashes confirmed; every graphic labeled S0/S1/S2/S3/S4 and licensed usage appropriately recorded.
10. No `PASS` or `MERGED` label before exact-SHA runtime and owner visual approval.

**Next:** owner reviews this design/asset inventory and, if accepted, authorizes a presentation-only implementation pass. Other gameplay code stays untouched.
