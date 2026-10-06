# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. relevant active-phase spec only after the user authorizes a new phase

Fetch live `main` before editing.

---

## Current status

**No implementation phase is active.**

P3.7A2R — Linh Điền Completion is closed.

Official Godot 4.7.2 evidence:
- focused P3.7 backend gate: GREEN;
- full cumulative P0 -> P2.12 + P3.7 A1 + A2R + B1: GREEN;
- closing CI run: P3.7 Backend #48.

Do not start another gameplay phase automatically.

---

## Locked Linh Điền result

Linh Điền now uses:

**start crop -> one timer -> harvest resolves**

No:
- seed item;
- backend walking/tending/harvest/haul phases;
- worker occupancy during crop countdown;
- Phẩm Lực.

Implemented:
- Spirit Stone planting cost;
- no-refund cancel;
- multiple plots;
- multiple Spirit Field instances;
- specific worksite assignment;
- AUTO_DEMAND / PRIORITY / FIXED policies;
- canonical warehouse deposit;
- save/load/determinism;
- legacy A2 migration.

---

## Locked shared work model

Keep the system simple.

One common lục-duy factor:

**`0.75 + 0.50 × normalized value`**

Primary roles:
- Tư Chất -> cultivation gain;
- Căn Cốt -> body training;
- Cơ Duyên -> rare chance;
- Thông Tuệ -> profession/skill learning;
- Mị Lực -> social effects;
- Tiềm Lực -> long-term permanent growth.

Do not force all six dimensions into every profession.

Profession level:
- +1% work speed per level.

Normal trait/physique/bloodline/buff percentages should flow through generic modifier channels.
Names such as Cần Mẫn/Cẩu Thả must not require private work-formula branches.

Current generic channels:
- `work_speed`;
- `profession_xp`;
- `cultivation_gain`;
- `body_training_gain`;
- `rare_chance`;
- `social_effect`.

Linh Thực Thiên Phú:
- grade 1–5 -> +5/+10/+15/+20/+25% profession XP.

Passive work Tu Vi:
- only while an actual work action is being performed;
- passive crop countdown grants none.

---

## Important

The old PL-based B2 direction is canceled.

Wait for the user's next phase decision.
