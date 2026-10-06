# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`
5. `docs/P3_7_SPIRIT_FIELD_SPEC.md`
6. current ResourceRegistry / Warehouse / Workforce / Building code
7. this file

Fetch live `main` before editing.

---

## Active phase

**P3.7A2R — LINH ĐIỀN COMPLETION**

Do not start another gameplay phase.

---

## Locked simplification

Linh Điền uses one crop timer:

**start -> countdown -> harvest**

No:
- seed item;
- separate planting/growth/harvest backend timers;
- detailed path/haul state;
- Phẩm Lực.

Starting a plot consumes Sect Spirit Stones.
Output is explicit resource quantity deposited directly into the main Sect Warehouse.

---

## Shared work formulas

Use `docs/P3_7_PROFESSION_WORK_MODIFIER_SPEC.md`.

Key locked numbers:
- profession level: +1% work speed/level;
- Cần Mẫn grade 1–5: +5/+10/+15/+20/+25% speed;
- Cẩu Thả grade 1–5: −5/−10/−15/−20/−25% speed;
- profession talent grade 1–5: +5/+10/+15/+20/+25% profession XP;
- Thông Tuệ XP factor: 0.75 + 0.50×Thông Tuệ;
- Căn Cốt stamina: Base×(1−0.25×Căn Cốt);
- Cơ Duyên rare chance: Base×(1+2×Cơ Duyên);
- passive work Tu Vi/hour: R×0.0005×(1+0.0005×profession level), then existing CultivationSystem modifiers.

Linh Điền lucky harvest:
- x4: 0.20% base;
- x3: 0.80% base;
- x2: 3.00% base;
- x1 otherwise;
- multiply rare bands by Fortune factor and resolve highest first.

---

## A2R implementation order

1. Remove legacy Phẩm Lực runtime fields/APIs from ResourceRegistry/Warehouse tests and keep B1 green.
2. Add shared graded work/profession modifier data model with backward-compatible migration.
3. Add Linh Thực talent to generation/suitability.
4. Add CropRegistry with simple crop data: cost/time/yield/tier.
5. Replace old single production_state with multiple plot timers.
6. Add specific Spirit Field worksite assignment.
7. Spend Sect Spirit Stones when starting a plot.
8. Resolve harvest quantity + lucky multiplier directly to canonical Warehouse.
9. Add AUTO_DEMAND / PRIORITY / FIXED field policy.
10. Add passive work Tu Vi through shared cultivation authority.
11. Implement field level/milestone modifiers.
12. Save/load/determinism tests.
13. Focused A2R gate.
14. Full cumulative gate.
15. Update checkpoint and STOP.

Do not begin the next phase automatically.
