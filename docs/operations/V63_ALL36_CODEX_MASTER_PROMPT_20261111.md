# CODEX MASTER PROMPT — V63 ALL36: 36 BRANCHES, SKILL DESCRIPTIONS, VFX, AI & PK
Owner instruction 2026-11-11 · existing PR #72 / Issue #76 · DO THE WORK, NOT ANOTHER ROADMAP.

## Mission and current truth

Act as implementation owner for Tông Môn Bá Đạo V6.3: **12 combat schools × 3 branches = 36 branches**, **420 foundational skill families**, **2,196 target evolution nodes**. Deliver actual playable skills, Vietnamese in-game descriptions, lineage progression, root/element use, PvE AI, visible VFX, and eventual isolated offline cross-school sparring (PK lab). Do not mistake filling catalogue rows for completed gameplay.

**First read in order**: AGENTS.md, docs/GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md and NEXT_CHAT_HANDOFF.md, then:
1. docs/operations/V63_ALL36_SKILLS_CODEX_EXECUTION_PACKET_20261111.md — approved G0→G7 roadmap.
2. docs/design/V63_ALL36_SKILL_DESCRIPTIONS_AND_VFX_CONTRACT_20261111.md — REQUIRED per-node Vietnamese narrative, mechanics, UI tooltip and VFX field/schema; four precise existing-skill examples.
3. docs/design/V63_ALL36_BRANCH_AND_ELEMENT_RULES.md — existing and proposed branch signatures.
4. docs/qa/V63_ALL36_ID_AND_EFFECT_MATRIX.csv — 2,196-row authoritative coverage ledger; currently 549 EXISTING, 1,647 NOT_AUTHORED.
5. docs/SPIRITUAL_ROOT_V2_SPEC.md; docs/COMBAT_SKILLS_V2_SPEC.md; docs/design/TMB_SKILL_DESIGN_AND_DEFERRED_20261106.md; three V6.3 JSON catalogues and content registry; Issue #76.
6. docs/qa/V63_G1B_ROOT_MASTERY_EXACT_SHA_QA_20261111.md — fixed and tested G1B baseline.

**Preserve measured progress:** G1B PvE detached mastery/Root V2 preview PASS at tested SHA ed813ab157fd8c814f8d6b88ebf46aa69b6a58f2 (official Godot 4.7.2 Actions #42960950171, 52/52 mastery, 233/233 Root, 1,475 Poison, cumulative PvE/HP/Save regression). This does NOT close G1 mutation/refinement or turn on V6.3, or prove full skill/VFX gameplay.

**Owner approved implementation scope** of nine new schools as well as Cung, Quyền, Độc: Kiếm, Đao, Song Đao, Thương, Chưởng, Phù, Chú, Trận, Triệu Hồi. Original branch labels/36 signatures are locked as direction; individual numerical coefficients remain balance candidates until QA.

## Boundaries (must not break to go faster)

Only write to existing integration/pve-p0-playable-ui-20261103 / Draft PR #72, no new branch/PR/merge/force push/rebase/reset. If Codex environment mandates a separate branch, report BLOCKED_SAME_BRANCH; do not fake a direct commit. No SaveService, player saves/E: backup, economy/GP/SX, Warehouse, fictitious resources, new material/drop sources, or automatic V6.3 activation. Share neither writer nor commits for overlapping file/authority with current GP/Economy writers. Changes to common MapBattleV2, HuntingPveRunV2, shared state or GUI require a single confirmed writer plus focused+cumulative regressions. CombatStatsV2, canonical roots, existing exactly-once mastery and real monster source remain authority. No invented DoT/CC/procs/status just because a skill name sounds like poison/fire. Dị Linh Căn remain pending unless real source/data and locked combat primitives exist.

Windows 1280×720 real GUI and Android physical remain PENDING USER until tested. Official Linux Godot headless import/QA is valid as headless evidence, not visual hardware acceptance. Offline 1v1/3v3/6v6 **PK LAB** must be gated and never silently enable actual player/network PvP.

## Work plan, with concrete deliverables and exit gates

### S0 — Authoring infrastructure (start immediately, short vertical slice)
- Inventory actual code at latest PR HEAD and preserve 549 existing IDs plus 1,647 planning slots.
- Add a small, canonical **presentation/authoring manifest** keyed by runtime skill ID, partitioned by school if useful. Runtime catalogue owns numbers. Additional metadata owns text, VFX art direction and QA provenance only. Avoid duplicate gameplay formulas.
- Every skill node gets (from its source): stable id/family/branch/tier/lineage/parent/replaces, Vietnamese short description, Vietnamese long description, player-visible mechanical tooltip synced to real numeric fields, tactical purpose/counterplay, actual element/root rule, AI target/range/priority, VFX production brief (motif/palette/shape, windup/telegraph/release/travel/impact/status/fade, attachment anchors, actual hit/AoE scope, tier delta, animation/vfx key, asset status), and QA markers. Passive/innate must describe the true modifier/trigger; no fake projectile or fabricated proc.
- Add validator of 12×183=2,196, 420 families, unique IDs, no missing name/short/long text/VFX brief, valid lineage graph/slot, no nonzero numeric claims absent from runtime, and no missing or phantom source. Existing 549 names and IDs unchanged; numeric tooltip must follow code values.
- Prove end-to-end on **real Cung and Độc source entries**: Tiễn Thức Căn Bản, Xuyên Tâm Tiễn, Xà Ảnh Quấn Mạch, Xuyên Cốt Độc Châm; do not mislabel the last as a DoT skill. Status separates AUTHORING / RUNTIME / BEHAVIOR_TESTED / VFX_META / ASSET / RENDER / GUI.

**Exit S0:** real manifest/schema/validator/initial truthful entries and a focused Godot test, not only a prompt or source diagram. After validating first school, proceed without waiting for owner.

### S1 — 35-family → 183-node Kiếm vertical slice (gold standard)
- Author precisely **35 Human families**: 1 Basic + 1 Mobility shared; across Ngự Kiếm, Sát Kiếm, Hộ Kiếm each 4 active, 1 ultimate, 5 passive, 1 innate. For EACH family: distinctive Vietnamese name, short+long skill descriptions, real effect/cast/AI/source, root/element, exact gameplay limits, and VFX production spec.
- Author **68 Immortal A/B and 80 Divine normal/rare successor nodes** = 183 total Kiếm node IDs, with explicit parent/replaces graph and meaningful lineage contrast. Keep 3 branch identities: flying swords/ranged control; focused execute/line cuts; parry/guard/reflect only after genuine absorbed damage. Avoid 183 copy/paste cosmetic clones.
- Implement Kiếm mechanics through existing shared architecture, AI, equip/unlock/mastery/save, VFX mapped to real cast/release/hit/status. Actual assets/renderer: 3 identifiable school branches + 3 signature ultimates, progressive Nhân–Tiên–Thần cues; visually distinguish cast vs hit and never fake gameplay damage with particles.
- QA actual effect per family and all-ID learn/equip/lineage, Hero vs real monsters, Boss resistance, 1v1, 6v8, root counters, fixed seed trace, Save/Load and crowd stress where test environment supports.

**Exit S1:** Kiếm 183 IDs **authored + implemented** as applicable, real behavior and render event evidence with honest per-layer status; release gate OFF; official Godot focused+cumulative exact SHA. This provides the pattern for next 8 schools.

### S2 — Original 549 audit + eight additional schools, independent school-sized chunks
- **G2:** Audit/repair original Cung/Quyền/Độc 549 one-by-one on their *real* runtime effect: Basic/Active/Ultimate/Passive/Innate, source, learn/mastery/equip, elements and root, target/AI/range, DoT/guard/heal/cleanse/Boss, 90s protective ICD/Poison bounded effects, successor A/B, VFX. Preserve prior 52+233+1,475 PASS evidence and do not claim that aggregate JSON checks mean all 549 playable.
- **8 remaining new schools**: Đao, Thương, Song Đao, Chưởng, Phù, Chú, Trận, Triệu Hồi. Per school independently create 35 Human families with all description/VFX/mechanic data, expand to 68 Immortal and 80 Divine nodes, implement real effects + VFX, run focused QA, commit, proceed.
- Mechanical differentiators: Quyền ≠ Chưởng; Đao heavy vs Song Đao fast; Thương real linear reach; Phù projectile/glyph without fictitious inventory cost; Chú bounded statuses; Trận area source/expiry; Triệu Hồi bounded real actor ownership/lifecycle/no independent loot. Ranged skills stop at their maximum authored distance, do not run into melee because of visual rendering.
- Use shared finite effect runtime where behavior is actually common; new mechanics require distinct bounded primitives. Do not invent 1,647 separate monolithic GDScript classes, 1,647 unrelated atlas textures, or fill with weak number-only clones. A/B variants must create tactical tradeoff; not every tier must create a new mechanics trigger if there is no authorized one.

**Exit per school:** 35 core families + 183 nodes with real localized text, VFX direction, lineage, AI and gameplay, 3 recognizably different signatures, exact SHA focused QA, matrix entry statuses; no blanket PASS.

### S3 — Visual implementation and gameplay integration (overlap with S1/S2, not afterward only)
- Build modular, high-quality Godot VFX: bow trajectory, fists/chi, poison needles/gu/lotus, sword arcs and formations, saber combos, spear thrusts, palm force, talisman glyphs, curse seals, finite formation zones, bounded summon silhouettes.
- 12 school art languages; **36 distinct signature ultimate compositions**; 420 family visual plans; 2,196 node-specific VFX metadata including successor/tier evolution. Reuse master atlas/shader responsibly with correct shape and intensity differences; do not build a totally new VFX every time a disciple levels up.
- Each event cue attached to authoritative actual event (cast telegraph → release → travel → hit → DoT/status/heal → fade). Visible name and meaningful description in appropriate UI. Actual AoE target cap and source must match visual. Avoid restart hit animation on each DoT tick, screen blur, excessive shakes, overlapping particle floods and invisible attack events; preserve 720p Android readability.
- Assets might be authored images, procedural Godot renderers, shaders or reusable atlases. Every claimed asset needs a real repo path and hash/manifest. One VFX key ≠ visual quality PASS. Capture actual rendered output and FPS/RAM where engine GUI access exists; Windows/Android manual QA remains separately pending.

### S4 — Cross-school offline PK sparring and final G7 QA
- Implement a gated offline simulated arena (NOT network/player PvP). 36×36 ordered branch matchups = **1,296 labeled scenarios** with fixed seed and honest NOT_RUN for unexecuted fixtures; 1v1, 3v3, 6v6. Evaluate DPS, healing, shields, DoT ownership, CC cooldown/ICD, element counters, target switching, actual HP reduction and survival. Stress up to 30 disciples/40 monsters and boss encounters with actual runtime (not fake results).
- Godot 4.7.2 official import, focused school regression, cumulative CombatStats/PvE/root/mastery/snapshot/Save/Poison/GP injury exact SHA. Verify 2,196 ID and 36 branch coverage and honest per-node behavior; deliver VFX screenshot/animation evidence separately. No feature gate activation without later owner release approval.

## Speed policy — autonomous, high-throughput, safe

The entire S0–S4 / G0–G7 task is authorized. **Do not pause to ask approval every 5 skills or every branch.** Work in school-sized batches, prefer many small atomic commit changes and one rich progress comment per completed gate instead of constant long planning responses. It is permitted to create data/content for two independent schools in parallel, but **never** have concurrent writers modify the same catalogue/registry or shared combat/state file. Serialize shared-runtime/renderer integration and keep QA scoped. Design metadata/validator can move forward even while G1C mutation resources remain PENDING. If a real blocker exists, record reason and continue unrelated safe school; don't fill gaps with fake items, fake tests or fake VFX.

At each meaningful school gate: update Issue #76 with **HEAD/code SHA**, actual authored/runtime/behavior/VFX status counts (not a single misleading %), changed paths, Godot version/command/exit and CI log link, blockers, next slice; keep existing PR Draft. Avoid proliferation of roadmaps/docs: use this instruction, the companion contract, one canonical ledger and actual content/testing assets. Do not edit GP-owned checkpoint/handoff files in parallel.

**Immediate first Codex step:** fetch latest PR #72 HEAD and read both new docs; implement S0 validator + skill description/VFX manifest on actual Cung/Độc sample; then Kiếm 35 foundational families/183-node vertical slice; audit the original three and continue remaining eight, with progressive VFX and QA. Stop only on a concrete authority/safety/tool blocker, not because the current conversation ends.

**Never claim completion solely for authored names or 2,196 parseable JSON entries. The goal is 36 playable branches, real tooltips and convincing, performant skill VFX.**