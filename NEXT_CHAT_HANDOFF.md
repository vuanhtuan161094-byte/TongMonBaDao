# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. `docs/P3_7_SPIRIT_FIELD_SPEC.md`
5. relevant current code
6. this file

Fetch live `main` before editing.

---

## Active phase

**P3.7A2R — LINH ĐIỀN COMPLETION**

Do not work on B2 Construction Resolver or another building until A2R closes.

---

## Why A2 was reopened

Old A2 proved:
- a field can plant;
- crops can grow without holding a worker;
- a worker can harvest;
- output can reach the canonical warehouse;
- save/load/determinism can remain green.

But old A2 was only a lifecycle foundation.

It did NOT provide:
- real seeds;
- multiple crop definitions;
- independent plots;
- useful parallel workers;
- multiple-field routing;
- crop policy;
- complete field milestones;
- dynamic yield/quality;
- a Linh Thực-specific talent.

---

## Locked new direction

Do NOT over-model walking/pathfinding.

Farming authority is based on:
- planting/tending time;
- passive growth time;
- harvest/processing time;
- deterministic logistics overhead if needed;
- yield;
- Phẩm Lực;
- seeds;
- rare/mutation outcome.

No mid-haul state is required.

---

## Character interaction

The six existing foundation dimensions are sufficient.

Use:
- Căn Cốt -> endurance/stamina;
- Cơ Duyên -> rare/mutation/exceptional seed outcomes;
- Thông Tuệ -> Herbalism learning and difficult crop handling.

Do not invent routine bonuses for:
- Tư Chất;
- Mị Lực;
- Tiềm Lực.

Add:
- `herbalist_affinity` profession talent;
- primary effect +80% Herbalism profession XP.

Spiritual Root affinity is crop-specific and positive-only.
Bloodline/Physique do not automatically buff farming.

---

## Implementation order inside A2R

1. CropDefinition/CropRegistry.
2. Real seed resources and seed consumption.
3. Replace one-field `production_state` with multiple independent plot states.
4. Persist plot state.
5. Add specific worksite/building assignment for Herbalism workers.
6. Implement field crop policy.
7. Replace travel/haul phases with planting/growth/harvest timing + optional logistics overhead.
8. Add yield/Phẩm Lực/seed-return/rare deterministic resolution.
9. Add `herbalist_affinity` to generation/suitability.
10. Implement Lv10 real behavior and guard higher milestones honestly.
11. Focused A2R gate.
12. Full cumulative gate.
13. Update checkpoint and STOP.

Do not start the next phase automatically.
