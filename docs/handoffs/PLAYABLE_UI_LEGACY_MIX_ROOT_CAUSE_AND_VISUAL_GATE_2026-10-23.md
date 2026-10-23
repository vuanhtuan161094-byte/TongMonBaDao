# TÔNG MÔN BÁ ĐẠO — PLAYABLE UI/UX: Vì sao còn pha giao diện cũ? (Read-only forensic)

**Date:** 2026-10-23. **Owner issue:** user supplied a screenshot and flagged persistent old UI/UX mixed with newer interface, following 13/13 PASS P3.2 CARE integration. **Status:** SOURCE-CONFIRMED PRESENTATION DEBT, **NOT owner visual PASS**, documentation only. No code, no asset modification, no merge or comments/changes to PR #24/#25.

## Confirmed, concrete root cause from PR #25 code

PR #25 head `710137c0e3976e685613a86692e5eb128b8d3c62` (at inspection, draft stacked on PR #24) still has:
1. `godot/scenes/p3/p3_2_landscape_sect.tscn`: an almost empty `Control` root bound to script, not a completed Source A native scene tree.
2. `godot/src/presentation/p3_2_landscape_sect.gd`: `extends "res://src/presentation/p3_1_landscape_sect.gd"`; its `_ready()` calls `super._ready()` first.
3. Parent `p3_1_landscape_sect.gd`: parent `_ready()` calls `_build_shell()`; that builds `_build_map_decoration()` (drawn colored areas, river, polygon), `_build_buildings()`, `_build_top_bar()`, `_build_bottom_bar()`, plus popup layers and interactive classic production UI. These are **actual active legacy presentation**, not unused code.
4. P3.2 then dynamically adds `_build_disciple_summary_panel()`, `_build_building_operation_panel()`, and `_build_b3_hunt_panel()`. The CARE panel uses manually positioned `Panel`, `Label`, `Button` and `B3MainHuntArena`; arena's `_draw()` renders **`draw_circle` actors/monsters and grid lines**, not production Source A art.
5. PR #25 changed ONLY P3.2 source, a focused integration test and two continuity docs. It explicitly leaves Source A, Character Studio, MAP25/C4/G1 branches outside scope.

**Conclusion:** Old UI remains because the staged gameplay integration deliberately **reused the existing P3.1 shell**, then overlaid new CARE controls. The screenshot complaint is consistent with source architecture. It is not evidence that engine accidentally loaded the wrong branch, nor proof every visible pixel in supplied screenshot has been independently mapped to a node. To verify exact screenshot provenance, compare source commit/launcher and runtime Screenshot→Node names during visual acceptance.

**Why this was not caught by 13/13 PASS:** focused tests prove runtime/save/loot/Injury/AUTO and automated HUD data, not owner acceptance of visual style, screen composition, authentic Source A sprites or manual tap targets. GUI render showing a window ≠ GUI approval; Windows physical, Android and Source A aesthetic still PENDING.

## Decision recommended: UI integration gate separate from CARE gameplay gate

**Do not fix by:** reverting CARE, rewriting Combat V2, introducing another map/runtime/clock/save, reskinning only the new popup while leaving legacy shell, blindly merging G1/MAP25/C4, duplicating HUD with old/new components, or repainting Source A with fake static stand-ins.

**Recommended U2 — staged in-place presentation migration** (UI content/logic can move; gameplay owner unchanged):
- UV-00 [READ ONLY] inventory all visually active legacy nodes, map draw paths, overlaps and components with screenshot+SHA. Mark `LEGACY ACTIVE / KEEP TEMP / REPLACE WHEN ART VERIFIED / REMOVED AFTER QA`. Take engine Inspector scene-tree hierarchy capture.
- UV-01 [ART/DOC] verify exact Source A candidate/approved identity, atlas/pivot, map footprint and approved fallback. FE-00/ADR-0003 data-driven native UI architecture and runtime isolation govern. Owner's past direction: **do not rewrite Combat renderer/gameplay**; presentation adapters only.
- UV-02 [CODE after separate authorization] route the existing P3.2 UI through ONE presentation composition/adapter using true snapshot sources; replace old visual shell/popup compositions **incrementally**, not `super._ready()` runtime authority, avoiding duplicate map/HUD. Build map/HUD/UI components with Godot native Nodes/Controls; never make HUD own gameplay or save.
- UV-03 [CODE after separate authorization] merge/present actual Source A one pilot sect map/building/actor and one combat map where provenance and clips pass; replace one old drawing at a time, stage rollback and maintain camera pan/zoom, movement, responsive touch, and production timeline truth.
- UV-04 [QA] one full physical Windows walkthrough 1280×720 with screenshots/video and owner comparing EXACT source screenshot target: select disciple→profile six raw foundation values→assign Mine/Field→production timeline actual worker/qty/ETA→Hunt AUTO/HP/loot→Sect→Save/Load. No mixed duplicate bars, clashing themes, graybox shape substitutes without explicit visible `prototype` label, tiny font, white-on-white, clipped HUD.
- UV-05 [QA] Android touch/perf proof; owner visual acceptance. Legacy compatibility test continues even if old UI rendering removed.

**Alternative choices:** U1 cosmetic re-theme only (fast, but **will not solve old painted map and mixed composition**, NOT recommended); U2 adapter-based staged presentation migration (**recommended**); U3 merge all UI/map branches wholesale (high conflict/runtime regression risk; REJECT).

## Cross-gate acceptance

| Gate | True condition |
|---|---|
| CARE gameplay | 13/13 on PR #25 true simulation, save/load/loot/Injury, no duplicate authority. Already reported. |
| UI structural | Legacy visible map/panel shell deactivated or replaced in a selected presentation scope; no old/new simultaneous nodes; read-only binding, working commands. Pending. |
| Art authenticity | Approved exact Source A style/variant/provenance, Godot clip/map render, no fake mining clips. Pending. |
| Visual | Screenshot of actual target game vs approved composition, Windows manual UI and Android touch, owner explicit thumbs-up. Pending. |

## Ownership/work boundary

Do not edit PR #24/#25 while Codex still owns the PLAYABLE code. This note only adds docs to `docs/bd01-equipment-deep-design-20261023`. A future UI packet needs explicit owner CODE authorization naming allowed paths/branch/from SHA, no overlapping writer on P3.2, and official Godot 4.7.2 focused tests + real viewport + rollback.

**Suggested next owner instruction:** "TÔNG MÔN BÁ ĐẠO — UV-00 READ ONLY: audit precisely why P3.2 still mixes P3.1 UI; compare actual screenshot and running code to node tree, submit per-component REMOVE/REPLACE/KEEP matrix and one style acceptance checklist; NO code/merge/FULL/CI. Preserve CARE and live runtime." This is no authorization for code.
