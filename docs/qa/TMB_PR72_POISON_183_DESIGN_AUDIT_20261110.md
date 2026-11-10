# TMB PR #72 — Độc Tu 183-ID architecture / duplicate / VFX audit
Audit date 2026-11-10. Source snapshot PR #72 HEAD `5d235d127beaf0e270c2e601d78a4cceca336506`. **DESIGN/AUDIT ONLY.** No gameplay, SaveService or VFX code edits. CSV evidence: [183 individual rows](TMB_PR72_POISON_183_SKILL_ID_AUDIT_20261110.csv).

## Source and reproduction
- `godot/data/combat/v63_human_combat_catalog.json`
- `godot/data/combat/v63_immortal_combat_catalog.json`
- `godot/data/combat/v63_divine_combat_catalog.json`
- `godot/tests/simulation/v63_doc_full_combat_matrix_test.gd`
- `godot/labs/combat_lab/combat_lab_poison_skill_art_brief.gd`
- `godot/labs/combat_lab/combat_lab_poison_v4_layers.gd`
- `godot/labs/combat_lab/combat_lab_vfx_v2.gd`
- `godot/labs/combat_lab/assets/poison_vfx/poison_vfx_manifest.json`
No Godot physical test was run in this audit. The test harness enumerates 183 IDs; its existence is not proof of this exact HEAD's runtime PASS.

## Raw counts, exact source fields
| Tier | Basic | Mobility | Active | Ultimate | Passive | Innate | Total |
|---|---:|---:|---:|---:|---:|---:|---:|
| Human | 1 | 1 | 12 | 3 | 15 | 3 | 35 |
| Immortal | 1 | 1 | 24 | 6 | 30 | 6 | 68 |
| Divine + rare | 1 | 1 | 24 | 12 | 36 | 6 | 80 |
| Total | 3 | 3 | 60 | 21 | 81 | 15 | 183 |

183 IDs belong to 35 conceptual foundational skill families: 2 common (basic, mobility) and each of 3 branches with 4 active, 1 ultimate, 5 passive, 1 innate. Immortal has A/B lineages; Divine adds variants and rare substitutions. A user should not read the catalogue as 183 simultaneously equippable skills.

Computer-checked field-pattern results (across 183 records):
- 93 distinct display name strings; **30 duplicate-name groups involving 120 ID records**.
- 63 distinct exact mechanic signatures over `effect, damage_ratio, range, cast_time, cooldown, shape, radius, target_limit, power, duration, poison_stacks, passive_modifiers`. **41 duplicate mechanic groups involving 161 ID records**. Important: this is not a combat equivalence proof, since lineage, learned prerequisites and dynamic branches are excluded.
- 61 distinct `vfx_key` strings; **26 reused-key groups**. A unique key is metadata, not a unique illustrated effect.
- Effect IDs: damage 20, mobility 3, poison 28, passive 81, innate 15, heal 7, cleanse 6, consume_poison 19, mark 4.

## High-priority defects / design collisions
1. **Names collapse different skills.** E.g., `Độc Châm · Thực Cốt · Tuyệt Thức` is shared by four distinct Immortal active_01..04 IDs. Equivalent collisions occur for all 3 branches and both lineages in Immortal and Divine. Five distinct passive slots share the display name `Tâm Quyết` within each lineage. Visible library and battle callouts would be ambiguous.
2. **Distinct names, duplicate mechanisms.** Human `doc_cham.active_03` / `active_04` both have `poison, ratio=1.35, range=7, CD=8, circle radius=3, cap=3, power=.06, duration=10, stacks=1`. Human `co_doc.active_03` / `active_04` are also identical on these fields. Human `duoc_doc.active_03` / `active_04` are identical cleanse abilities by the same comparison.
3. **Cross-branch mechanical cloning.** Human `doc_cham.active_01`, `co_doc.active_01`, and `duoc_doc.active_01` share an identical damage profile. Their narrative identity and VFX art may differ, but actual effects need to be differentiated if they are to support 3 convincing specializations.
4. **VFX keys under-differentiate named spells.** E.g., Immortal/Divine `doc_cham.active_01..04.a` reuse `v63_immortal_original_poison_doc_cham_active_a` although effects include poison, direct damage, consume_poison and shape changes. Divine variants still reference Immortal-key motifs. Rarity does not imply unique actual rendered animation.
5. **Divine mechanics are candidate-gated**. `enabled:false` in all 3 catalogues; special Divine rules `single_spread_poison` and `removed_debuff_counter` were separately documented as DESIGN_PENDING. Do not mark all 183 finished or physically tested.
6. **VFX evidence scope:** human art brief explicitly declares 17 human visible actions (basic, mobility, 12 active, 3 ultimate), and no cast/impact visuals for 18 human passive/innate records. The current V4 renderer uses four authored texture masters (needle, serpent, lotus, smoke) plus programmatic layered drawing; it is a Combat Lab render-only opt-in, not proof of 183 released animations. Need per-ID runtime capture before PASS.

## Recommended unified design (pending owner approval)
- Retain IDs and saved identifiers as **immutable node IDs**. Do NOT delete/rename/merge existing records in gameplay/Save, because of potential equipped/loadout/archive references.
- Present **35 fundamental abilities/traits** to players (2 common + 11 per branch), evolving through Human → Immortal A/B → Divine A/B. Display only currently available upgrades and one selected successor per family; retain previous mastery/history. Rare Divine entries are replacements of an established ultimate/passive, NOT extra simultaneous slots.
- Within 35 fundamentals, only **17** Human skills require visible cast/movement VFX (basic + mobility + 15 branch active/ultimate). **18** are passive/innate with a passive icon + proc/tiny overlay only when triggered. Immortal/Divine can reuse motif families but need generation-specific overlays, intensity and silhouettes, not 183 separate art assets.
- Distinguish branch roles: Độc Châm = focused piercing / poison stacking / deliberate detonation; Cổ Độc = mark, spread and area pressure with clear target caps; Dược Độc = ally sustain/cleanse and conditional poisonous counterplay.
- Human duplicate-role remediation proposal (not approved to implement): `doc_cham.active_03` should remain targeted fan AoE while `active_04` becomes a distinct delayed poison burst or consume mechanic; `co_doc.active_03` remains low-ground mist zone while `active_04` should become bounded marked-target spread; `duoc_doc.active_03` should dispel negative effects while `active_04` provides different targeted regeneration/conditional protection. Avoid adding fake multi-target casts. All such changes must be rebalanced in PvE with real status/AI/loot and tested against Boss.
- Unique user-facing names for every slot, with a shared name retained across tier evolution plus a suffix like `· Tiên (Thực Cốt)` or `· Thần (Bạo Phệ)`; preserve unchanging family identity and explicit lineage labels. Do not display the generic `Tuyệt Thức` or `Tâm Quyết` alone for four/five different skills.
- Set VFX identity by `family_id + effect + shape + lineage + tier`, map to a bounded render profile (cast telegraph, projectile/area, committed hit, status tick) instead of one generic VFX key per lineage. Enforce cap/radius and no VFX that fabricates hits. Tier increases are parameterized; **no need to redraw VFX at every cultivation level**.
- Proposed content budget: 35 durable families, 183 legacy/evolution nodes, 17 Human cast signatures, ~6 lineage signature layers, and a small set of tier/proc overlays. This is an architecture proposal, **not** a claim that all 17 have passed exact-HEAD VFX acceptance.

## Release gates
1. Normalize naming/role/upgrade mapping in a design-only crosswalk (do not touch Save IDs).
2. Owner approves 3 branch role deltas and a tier/lineage evolution contract.
3. After future implementation authorization: author focused tests for each effect/shape/stack and 183 ID registry integrity; verify 26 Divine pending rules independently.
4. Exact source SHA Godot 4.7.2 import + automated skill matrix + 4v8 live GUI visual comparisons (cast/impact/tick at 1×); Windows/Android FPS and Save regressions must be separate explicit gates.

**Status:** catalogue structural audit completed, gameplay/Save untouched, external GUI QA not run.
