# B+D+E — VFX Shared Pilot, QA Consolidation and Render Budget

**Date:** 18/11/2026 · **Branch:** integration/pve-p0-playable-ui-20261103 · **PR:** #72 Draft · **Status:** LAB PILOT (not production/live integration). Linked Art Bible C and Status Rules A remain authoritative for this pilot's *design*; AGENTS.md and V4 SOP remain operating authority.

## B — Presentational code (implemented, scope limited)
- `godot/labs/combat_lab/vfx_shared_f_pilot/vfx_presentation_policy.gd`: **read-only** normalization of verified `v63_poison`, `burn`, `slow`, `weaken`, `v63_marks` and guard/capacity shield fields, without inventing statuses from catalogue name or events. Preserves each source/owner and next/last expiry separately; deliberately ignores internal `v63_blood_marks` for overlay, so marks do not double-render.
- Same module offers `compact_rows` for normal 2 icons + overflow, expanded selected/boss display; and `select_visuals` for prioritizing warnings/hits and suppressing cosmetic FX only. This **does not** mutate combat, resource timing or cues in runtime.
- `vfx_sprite_layer.gd`: generic LAB-only Node2D with an injected **existing original** sprite atlas and pose regions, a local VFX clock, source/target anchors, timed hide, simple depth selection. Can be exercised with actor WALK anchors; never reimports or retouches owner-approved source art. It is NOT yet replacing any existing game renderer.
- `godot/tests/labs/combat_lab/vfx_shared_f_policy_test.gd`: focuses on poison multiple owners and expiry, mark, shield and instant expiry, read-only safety, selected/normal overflow, visual priority and source→moving target interpolation using a **test-only synthetic atlas**. This atlas is not a new game-art skill and must not be presented as such.

**NOT YET EXECUTED:** exact HF02/FIST07 approved/provisional skill-level animations in the new shared renderer, per-skill G3.5/G3.6/G3.7 acceptance, full live PvE motion with Combat V2 receipt authority, physical-device test and owner visual gate. POI02/POI15/PAF06 read-only native source showcase has now run separately; it is not per-skill acceptance. The existing owner-approved art and all live Combat V2 code remain immutable.

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
| B source | Shared policy and sprite-layer source committed; read-only native lab smoke **TECH PASS** on exact SHA a6557607; in-game/owner visual still PENDING |
| D source | Shared CI workflow focused and native smoke **TECH PASS**; legacy workflows unchanged |
| E source | Trial budget selector and 70-actor/218-cue CPU stress **PASS**; physical FPS **PENDING** |
| G8 | **HOLD**: no PvE integration, no V6.3, no changes to Combat V2/SaveService/AI/economy, no merge |

## Evidence and next gate
- [A status rules](../../docs/design/TMB_VFX_STATUS_BUFF_OVERLAY_RULES_V1_20261118.md) · [C Art Bible](TMB_VFX_ART_BIBLE_C_QUALITY_V1_20261118.md) · [Existing SOP V4](TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md) · [V4 packet validator](vfx_packets/README.md).
- **Fail-safe:** If Godot CI doesn't run or fails, report source committed but B/D TECH PASS **NOT VERIFIED**; do not substitute standalone Python or offline video for a genuine engine test.


## B/E pilot proof extension — 3 original sprite sources and 70-actor stress
- `shared_showcase.gd/.tscn` consumes **existing project RGBA atlases unchanged**, POI02 serpent-flight (6 poses), POI15 poison field (12 poses), PAF06 passive wind (1 isolated resident motif). Their original art is not copied, reskinned, or made part of a new skill. This test only proves shared canvas drawing, actor-layer order and moving target anchors, NOT exact per-skill animation/owner art approval. PAF06 is always-on, not a fake cast/guard receipt.
- Focused Godot `vfx_shared_f_stress_test.gd` creates **70 synthetic actors (30+40 fixture)** with 350 status-family rows and 218 candidate visual cues, checking stable culling across Lite/Balanced/Full while **all 8 telegraph warnings remain drawn**. This is policy CPU work, **not** proof that a rendered 70-actor Android battlefield runs at 60fps.
- New CI captures genuine Godot 4.7.2 1280×720 240-frame MP4 with charge/peak/contact screenshots, checksum and 14-day artifact. Native smoke evidence is **not** G3.5 per-skill acceptance. Exact-SHA results must be checked from the corresponding GitHub Actions run; if CI fails, no native-proof claim is made.

## Exact-SHA verification receipt (2026-11-18)
- **Native CI run:** [#44224916665](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44224916665) — `SUCCESS` on SHA `a6557607ebd6245bfd117f4d4dc37c26caafd4b8`.
- **Artifact:** [tmb-vfx-f-shared-native-a6557607](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44224916665/artifacts/14393095427) (GitHub Actions artifact, retention 14 days). Includes real Godot MP4, three PNG frames and SHA256; **not a persistent owner-approved asset archive**.
- **Engine:** Godot 4.7.2, strict import and scripts, `VFX_F_POLICY_TEST_RESULT=PASS failures=0`, `VFX_F_STRESS_RESULT=PASS failures=0`, 70 synthetic actors, 218 visual cues. On GitHub Actions runner the policy fixture logged `policy_cpu_ms=11.759` total; this is **one CI run, not device FPS or a reliable benchmark distribution**.
- **Native showcase:** `VFX_F_SHARED_SHOWCASE_READY original_atlases=POI02_POI15_PAF06`, real Godot `1280x720`, 240 video frames at 60fps fixed movie capture. CI movie capture's encoded frame rate **is not measured physical FPS**.
- **Boundary:** per-skill G3.5/G3.6/G3.7 and owner art review NOT EXECUTED; live PvE receipt integration HOLD, Windows/Android physical QA PENDING; no skill master altered. Other repo workflows (including separate `v63-quyen-doc-matrix` failure) are independent and must not be described as globally green.
- **D workflow improvement:** docs-only edits no longer trigger this heavy Godot run; only new shared pilot GDScript/tests/workflow paths do. New push also cancels superseded in-progress runs on this one pilot lane to avoid duplicated CI minutes. Existing school workflows remain intact.
