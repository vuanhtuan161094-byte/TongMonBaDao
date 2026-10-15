# UI-REF-01 — Code Handoff and QA (DESIGN ONLY)

## Current repository gates as of 2026-10-15

- Main: `461caca1171462e0da092f21108c5c1733157ad9` (Economy-A merged; official Windows Godot headless 18/18 at an older gameplay SHA; Windows real GUI not accepted).
- Draft GUI-WORKFORCE-V1 PR #2: branch `gui-workforce-v1-20261015`, latest `01272b2d54ef5651c62deb0dedc963089ae771ee`; not merged, no exact-SHA runtime gates. Does implement direct selection via WorkforceSystem and safety checks.
- Unity pilot PR #3: paused; leave separate, do not merge. No Spine runtime dependency.
- This design packet: **only `docs/design/UI_REF_01_*.md`**. Nothing is claimed running.

## 2026-10-15 owner correction — Mỏ single slot + level/Lục Duy output

A Mỏ has **one disciple only**; harvesting depends on that disciple's level and six foundation stats. This is a **gameplay design decision**, not just a visual adjustment. Current `BuildingSystem` has two initial slots and +1 per five building levels; O3 checks two initial workers and a fixed building-level batch. PR #4 remains **DESIGN ONLY**. A later gameplay packet must establish the precise level meaning/weights, migration of existing multi-worker saves and in-flight timer/legacy carry jobs, preservation of canonical Warehouse and wage receipts, and regression migration of O3/GP-01/GP-02C1/O6. No slot clamping or yield changes in UI without backend readiness.

## Integration plan after separate CODE authorization

1. Fetch current main and PR #2, inspect exact diffs and baseline (do not blindly merge branches).
2. Extract the transient picker from monolithic `godot/src/presentation/p3_2_landscape_sect.gd` into reusable scene/component **only if** focus tests and existing stable node names can remain compatible. Keep one actual picker, not competing controllers.
3. Apply one parchment UI theme; source images only if genuine bytes/provenance available. Preserve current clean original theme as fallback; no broken asset references.
4. Replace raw text worker rows with portrait slots; overlay with portrait tiles, search/filter and one command. Keep `WorkforcePickerSearch`, `WorkforcePick_<id>`, `WorkforcePickerOpen_*` stable for testing or provide tested adapters.
5. Validate real Economy-A Mine/Forest timer and paid packet, Field/Alchemy locks, Body reservations, old carried-cycle drain and save/offline. UI must not change producer authority.
6. Capture actual game screen and owner approval; no visual PASS by inspecting GDScript alone.

## Test matrix, exact-SHA on official Godot 4.7.2

| Gate | What to check | Closure |
| --- | --- | --- |
| Scene parse/import | scripts, nodes, paths, Theme/9-slice, no missing art | PENDING |
| UI focused | picker open/close, filter, search, pages, occupied and open slot, async update, state remains canonical | PENDING |
| Economy-A UI | same Mine/Field/Alchemy market/read models, no fake progress | PENDING |
| Backend regressions | GP-01, GP-02A/B1/C1, O3–O9 with O6 `==4`, SAFE-01/02, P3.7 FULL | PENDING |
| Visual evidence | Windows **actual Godot** screenshot at 1280×720, tap targets, no horizontal overflow | PENDING |
| Android | touch/keyboard, portrait never used, safe area and keyboard hides, FPS | PENDING |
| Scale | page/virtual rows at 100 / 500 / 1000 / 3000 disciples; no excessive frame hitch/memory | PENDING |
| Persistence | real job/save/reload exactly-once retained; no new timekeeper/warehouse | PENDING |

## Hard blockers and error policy

- No Spine runtime/license assumed.
- Missing asset ⇒ explicit fallback + pending visual acceptance; never substitute random art and call it the historical S3 source.
- Busy worker ⇒ present reason; no automatic cancel or silent transfer.
- Actual scene bug ⇒ repair only inside authorized allowlist; out-of-scope behavior requires separate owner authorization.
- Nothing merges until accepted tests and manual visual review. PR #2 retains its DRAFT status until integrated safely.

## Suggested smallest follow-up authorization wording

> TÔNG MÔN BÁ ĐẠO — UI-REF-01A CODE AUTHORIZATION. Duyệt thiết kế `docs/design/UI_REF_01_MAP_MINE_DISCIPLE_UX_V1.md` và inventory/QA kèm theo. Cấp phép triển khai presentation-only map/Mine right panel + shared portrait picker trên Godot 4.7.2, dựa trên `main` mới nhất và tái sử dụng logic GUI-WORKFORCE-V1 PR #2. Trước code phải kiểm tra exact main/branch và lập allowlist. Không sửa gameplay/backend, Economy-A, injury, scheduler, warehouse, save, map authority hoặc balance; không merge cho đến khi focused+FULL+O6 đạt và có ảnh Godot thực tế. Asset thiếu phải ghi pending, không bịa/giả source cũ.
