# B+D+E — VFX Shared Pilot, QA Consolidation and Render Budget

**Date:** 18/11/2026 · **Branch:** integration/pve-p0-playable-ui-20261103 · **PR:** #72 Draft · **Status:** LAB PILOT (not production/live integration). Linked Art Bible C and Status Rules A remain authoritative for this pilot's *design*; AGENTS.md and V4 SOP remain operating authority.

## B — Presentational code (implemented, scope limited)
- `godot/labs/combat_lab/vfx_shared_f_pilot/vfx_presentation_policy.gd`: **read-only** normalization of verified `v63_poison`, `burn`, `slow`, `weaken`, `v63_marks` and guard/capacity shield fields, without inventing statuses from catalogue name or events. Preserves each source/owner and next/last expiry separately; deliberately ignores internal `v63_blood_marks` for overlay, so marks do not double-render.
- Same module offers `compact_rows` for normal 2 icons + overflow, expanded selected/boss display; and `select_visuals` for prioritizing warnings/hits and suppressing cosmetic FX only. This **does not** mutate combat, resource timing or cues in runtime.
- `vfx_sprite_layer.gd`: generic LAB-only Node2D with an injected **existing original** sprite atlas and pose regions, a local VFX clock, source/target anchors, timed hide, simple depth selection. Can be exercised with actor WALK anchors; never reimports or retouches owner-approved source art. It is NOT yet replacing any existing game renderer.
- `godot/tests/labs/combat_lab/vfx_shared_f_policy_test.gd`: focuses on poison multiple owners and expiry, mark, shield and instant expiry, read-only safety, selected/normal overflow, visual priority and source→moving target interpolation using a **test-only synthetic atlas**. This atlas is not a new game-art skill and must not be presented as such.

**NOT YET EXECUTED:** preview of HF02/POI15/FIST07 art in the shared renderer, true native 1280×720 G3.5 charge/peak/contact, full motion, physical-device test, visual owner gate. The existing owner-approved art and all live Combat V2 code remain immutable.

## D — Workflow consolidation pilot
- New `.github/workflows/vfx-shared-f-pilot.yml` drives strict Godot 4.7.2 import/parse and the common policy contract test; tests exact commit SHA and records G3.5/owner/PvE/Android **HOLD**.
- No legacy workflow removed. Current repo has numerous dedicated per-skill workflows (89 with `vfx-` prefix at audit), and custom QA scripts. A single test runner and packet-specific input is the proposed migration, **not** an immediate removal of prior evidence.
- **Migration gate:** first get this shared test green on exact SHA, then compare representative original skill tests from attack/guard/passive, check runtime anchors/effect semantics, then migrate one workflow at a time. Reuse V4 validator `packet → assets → evidence` and artifact SHA; don't skip G3.5/G3.6/G3.7 for new art.
- Script/runner does not assert `ART_APPROVED`, frame hashes only indicate integrity; any future native film claims require actual Godot captures.

## E — Visual budget (PROVISIONAL / to be measured)
`select_visuals` uses **trial** policy, not FPS-backed device limits:

| Trial profile | Hero | Ordinary contact (impact) | Ambient |
|---|---:|---:|---:|
| Full | 4 | 12 | 10 |
| Balanced | 3 | 8 | 6 |
| Lite | 1 | 4 | 2 |

- All telegraph warnings are visually mandatory independent of the cosmetic cap. `essential_hit` degrades to `lite` instead of disappearing. Offscreen cosmetics are discarded from drawing only. Pending detail: 30 disciples +40 monsters and overlapping multi-cast may need priority tie-break and distance-based LOD. **No gameplay effect/event may ever be dropped.**
- These numbers **must not be described as optimized Android performance** until Godot native overdraw/draw-call/texture memory and Windows/Android actual frame time are benchmarked under 6v8, crowded 30+40 and multiple buffs.
- Metrics after device tests: p50/p95 frame times, GPU draw calls/overdraw and texture memory, number of simultaneously visible cues, warning visibility and user art approval. Reduce redundant halos/ambient first, never telegraph/critical contact.
- For passives and 4–6s buffs: sustain icon/quiet aura is the default **candidate**; active flash is brief and distinct, response to real blocked-hit only. No invented casts/hits.

## Gate accounting
| Phase | Result |
|---|---|
| A design | Source of truth document committed; icon designs pending owner signoff |
| C quality | Cross-school Art Bible/checklist committed; no art rewritten |
| B source | Shared policy and sprite-layer source committed; native/in-game/owner visual **NOT_EXECUTED until CI** |
| D source | Shared CI workflow introduced, legacy workflows unchanged; focused result **PENDING RUN** |
| E source | Trial budget selector and regression scenarios implemented; physical FPS **PENDING** |
| G8 | **HOLD**: no PvE integration, no V6.3, no changes to Combat V2/SaveService/AI/economy, no merge |

## Evidence and next gate
- [A status rules](../../docs/design/TMB_VFX_STATUS_BUFF_OVERLAY_RULES_V1_20261118.md) · [C Art Bible](TMB_VFX_ART_BIBLE_C_QUALITY_V1_20261118.md) · [Existing SOP V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) · [V4 packet validator](vfx_packets/README.md).
- **Fail-safe:** If Godot CI doesn't run or fails, report source committed but B/D TECH PASS **NOT VERIFIED**; do not substitute standalone Python or offline video for a genuine engine test.
