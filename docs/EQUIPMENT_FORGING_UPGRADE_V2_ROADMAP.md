# EQUIPMENT V2 — LỘ TRÌNH LUYỆN KHÍ VÀ NÂNG CẤP TRANG BỊ

Updated: 2026-10-09
Status: **APPROVED ORDER BUT DEFERRED (2026-10-09) — MECHANICS NOT LOCKED; NOT IMPLEMENTED**
Historical 2026-10-09 decision approved this nine-part ordinary equipment forge/upgrade **order only**; **subsequent and more recent user instruction on the same date supersedes immediate priority**: complete real Disciple V2 attributes and behavior FIRST, as specified in `docs/DISCIPLE_V2_CHARACTER_IMPLEMENTATION_PLAN.md`. Preserve this forge plan for later; do NOT begin it in the next chat. Pháp Bảo and Phù also stay deferred. This plan does not lock recipes, chances, enhancement ceilings or authorize gameplay code.

Authority:
- `docs/WEAPON_EQUIPMENT_V2_SPEC.md` — 10 ordinary slots; item realm 1..30; quality 1..12; at Chí Tôn max 6 ordinary stat lines + 2 rare stat-special lines + 1 separate individual Chân Văn.
- `docs/EQUIPMENT_SETS_V2_SPEC.md` — 24 sets, 2/3/4 thresholds, Nhân/Tiên/Thần versions, 3+3 allowed; NO Chân Văn Cộng Hưởng.
- `docs/P3_7_BUILDING_TREE_SPEC.md` — Luyện Khí Điện 1..100, milestones 1/10/20/30/50/75/100, profession/building prerequisites.
- `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md` — real craft time and orders, not instant final V2 output.
- `docs/P3_7_RESOURCE_STORAGE_GROWTH_DATA_MODEL_SPEC.md` and `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md` — one canonical Sect Warehouse; materials distinct; all gear Sect-owned.
- `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md` — canonical stats, skill/trigger definitions and anti-recursion.

## 1. Ordered design work (the plan is LOCKED; details are OPEN)

| Order | Design package | Questions that MUST be answered before closing that package | Avoid |
|---:|---|---|---|
| 1 | **Luyện Khí Điện: forge/create gear** | One complete forge order; crafter/profession/facility/recipe/material input, duration, tier, grade outcome, chosen item template/slot, valid ordinary/rare line generation, instance uniqueness, inventory output; manual + auto queue; failure/guaranteed minimum result policy | Fabricated guaranteed Chí Tôn or new material currencies |
| 2 | **Cường hóa** | What base item component increases, level ceiling, material/cost per tier, success/failure/rollback rules and UI | Multiplying disciple RealmBodyCore or all external buffs |
| 3 | **Tinh luyện / tẩy luyện** | Separate raising a line's value from rerolling its identity; legal slot pools, rarity, chosen-line lock/keep choice, duplicate prevention, cost and determinism | Hidden rerolls, rerolling a combat Chân Văn via ordinary affix operation |
| 4 | **Thăng phẩm** | Phàm→Tinh→…→Chí Tôn, how new 6+2+1 capacities open, how to protect old investment, success/cost and non-destructive or failure policy | Treating phẩm as item realm tier, guaranteeing all ideal lines |
| 5 | **Thăng bậc cảnh giới** | Equipment tier 1..30, promotion r→r+1, Nhân→Tiên→Thần material/recipe requirements, nontrivial higher-tier inputs and set-generation compatibility | Cheap infinite low-tier material converting into Thần gear |
| 6 | **Kế thừa / phân giải** | Define transfer-compatible base/line/enhance investments, consumed source and resource recovery; unique item identity, no duplication; safe item-lock handling | Keeping both old investment and full cloned new copy |
| 7 | **Chân Văn cá thể** | Acquire/inscribe/replace/evolve a Chí Tôn item Chân Văn; event trigger/source/target/ICD/effect tier/cap, integration with skills and proc budget | "Chân Văn Cộng Hưởng" for sets, free trigger loops |
| 8 | **Nguồn rơi + kinh tế** | Viable source families for materials/recipes/sets, rank eligibility, targeted farming, Elite/Boss/Bí Cảnh/market availability and priced sinks; no dead-end upgrade | Claiming all 30 maps/recipes or exact drop rates exist |
| 9 | **Tự động cấp phát quy mô lớn** | Role/build/skills/set-aware scoring, autoequip policies and item locks, batch crafting/gear staging, salvage policies for 1,000–3,000 disciples | One disciple manually clicking thousands of items; destroying a 4-piece set due to a tiny single-item score gain |

Work packages 1..9 are planned subjects; do not begin packages 2..9's final balancing before their earlier dependencies are designed. Small dependency discussions inside package 1 are fine. User confirms detailed design separately before it is called locked. This plan is **not a new implementation phase**.

## 2. ON RESUMPTION ONLY — Order 1: one complete forge cycle

Design the transaction in understandable gameplay terms:

`Sect forge order → choose item template, realm tier, legal materials + blueprint → validate crafter Luyện Khí skill and Luyện Khí Điện capability → reserve/consume resources under canonical warehouse policy → simulate REAL production duration → resolve outcome deterministically → item grade 1..12 → generate allowed basic stats, 0..6 ordinary lines, 0..2 rare special-stat lines, 0..1 empty/inscribed Chân Văn capacity according to approved grade structure → register a Sect-owned unique item → warehouse and auto-assignment policy`.

Decide separately and explicitly:
1. Whether crafting names a targeted slot + lineage/recipe or chooses a random outcome from a controlled recipe pool; how guaranteed basic output differs from expensive chase output.
2. Item quality 1..12 generation, role of profession level, worker talents, special materials and facility level; **do not invent numeric rarity probabilities until evaluated**.
3. Which result is known before crafting, which aspects roll once on completion, deterministic seed ownership, anti-cancel/retry RNG exploitation and old/new keep policy.
4. How individual special lines and Chân Văn capacity are obtained; ordinary rare special-stat lines **do not themselves create battle actions**.
5. What a failed or poor craft yields, whether material reimbursement/salvage exists, and how to avoid economically destructive soft locks.
6. Minimum viable early forge before Lv75 vs Lv75 advanced set/special capabilities; Lv75 does **not** gate every existing low-rank set.
7. One complete beginner example, one high-rank example and one professional-forging example; validate all with the same rules.
8. How actual forge orders operate without one click per 1,000 items, and when the authored result is owned by Sect Warehouse.

The **first deliverable is the closed forge transaction/rule design**, not code or a provisional 30-realm numerical recipe spreadsheet.

## 3. Canonical safeguards throughout

- **10 ordinary slots, 12 grade capacities, 24 set families remain fixed**. Do not reopen approved equipment or set identity without an explicit user change.
- **Pháp Bảo and Phù are DEFERRED**, not deleted and not redesigned under the ordinary-gear roadmap. Their separate current slots and future dedicated design remain.
- Luyện Khí Điện's current levels and milestone direction are authority: Lv1 basic forging/repair; Lv10 auto repair; Lv20 material refinement; Lv30 monster-material forging; Lv50 additional trait/reforge; Lv75 advanced set/special chance; Lv100 rare-line/craft mastery. Precise effects/percentages are not automatically fixed here.
- Any work bonus uses real `work_speed` / `profession_xp` channels and real craft-time consumer; no unrelated Expedition Stamina cost for ordinary sect work. No universal hidden yield double multiplication.
- No unbounded % stacking or new general combat stat; Attack/Defense/HP progression/RealmBodyCore balance is unresolved. Keep ordinary affixes vs rare conditional stats vs individual Chân Văn sharply separated.
- Gear belongs 100% to Tông Môn. Any new outcome has a unique ID, location, allocation lock/reserve and deterministic save/load provenance.
- Use the real 24-set 4-item matrix for outputs; same-set pieces at different tiers must obey minimum participating rank and generation rules.
- Forge and upgrade operations must not grant arbitrary item grade beyond available facility/profession/blueprint/material competence or allow cheap duplication of valuable item state.
- Future implementation requires explicit user authorization, game-code migration and real official Godot 4.7.2 tests. A documentation commit means **design plan recorded**, not implementing V2.

## 4. Roadmap status checklist

- [x] User originally approved ORDER of 1..9 (but newer priority defers the whole forge package).
- [x] Newer 2026-10-09 directive: **finish a real playable Disciple V2 first**; next chat starts `DV2-00`, not forge.
- [x] Equipment V2 10-slot / 12-grade / 6+2+1 architecture already design-locked elsewhere.
- [x] Set V2 24-family / 2+3+4 structure already design-locked elsewhere.
- [ ] Forge transaction final rules, 12-grade rolls, examples, profession/material/recipe links — **next discussion**.
- [ ] Enhancement/refine/reroll/grade/realm/transfer/Chân Văn actual item rules.
- [ ] Full economy/source pools and policy automation design.
- [ ] RealmBodyCore numerical benchmarking.
- [ ] Real implementation, save migration, Godot focused and cumulative runtime gates.

This roadmap is a **plan-only source of truth**; it does not turn unapproved example mechanics or percentages into locked gameplay.
