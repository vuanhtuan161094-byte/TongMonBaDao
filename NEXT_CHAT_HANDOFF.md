# NEXT CHAT HANDOFF — TÔNG MÔN BÁ ĐẠO

Updated: 2026-10-06

## Read first

1. `AGENTS.md`
2. `docs/GAME_SYSTEM_ARCHITECTURE.md`
3. `CURRENT_CHECKPOINT.md`
4. `docs/DISCIPLE_MASTER_SCHEMA.md`
5. the active-phase spec only after the user authorizes a new phase

Fetch live `main` before editing.

---

## Current status

**No implementation phase is active.**

P3.7C1 — Open-point Lục Duy + Dẫn Tiên Đài is closed.

Official Godot 4.7.2 closing evidence:
- P3.7 Backend run **#67**;
- run id `37483719618`;
- job id `112338256594`;
- tested SHA `a91cb9ba7a3dc775087f5b38e9a3452326f77681`;
- focused C1 gate: PASS;
- full cumulative P0 -> P2.12 -> P3.7A1 -> A2R -> B1 -> C1: PASS.

Do not call this Windows evidence.

---

## Locked six-foundation result

P3.7 lục duy is now open-point, not normalized 0..1.

Common rules:
- no hard cap;
- birth rolls one Total Birth Lục Duy then distributes it;
- ordinary birth stat envelope ≈ 0.5x–3x the six-stat average;
- Mệnh Cách may break the birth envelope;
- after birth, each stat grows independently without that envelope;
- immutable birth snapshot is persisted;
- current quality derives from current total and may promote.

Working quality totals:
- <360 Phàm Thường;
- 360–599 Xuất Chúng;
- 600–999 Thiên Kiêu;
- 1000–1799 Tuyệt Luân;
- >=1800 Nghịch Thiên.

Starting balance:
- Tư Chất +0.25% base cultivation/point;
- Căn Cốt +0.20% body-training XP/point;
- Thông Tuệ +0.15% learning XP/point;
- Tiềm Lực +0.05% future Realm+Body stat-growth/point;
- Cơ Duyên uses Luck Score 0..9999 + stat - difficulty;
- Mị Lực uses social power and Dẫn Tiên authority.

Fixed +X consumables remain +X.

---

## Locked Dẫn Tiên result

Dẫn Tiên Đài:
- Lv1–100;
- 1 Main Guide affects quality;
- assistants affect arrival quantity only;
- mortal quality Mị Lực cap = 2,500;
- at cap, Nghịch Thiên <=5%, Tuyệt Luân <=15%;
- no quality drops to 0%;
- current normal rates = 65/25/8/1.8/0.2%;
- current capped rates = 35/25/20/15/5%;
- 2,500 effective Main Mị Lực currently gives up to 4 enhanced Nghịch Thiên appearances/day;
- once that enhanced allowance is consumed, rates revert to normal until the next day;
- natural normal-rate Nghịch Thiên may still appear;
- daily snapshot prevents guide-swap reset;
- current guide slots: Lv1 one slot, up to six at Lv100;
- assistants: +1 arrival/day per 500 effective Mị Lực, current per-assistant effective cap 2,500;
- base arrivals: 2 + floor(level/10);
- Chiêu Mộ Lệnh goes through the same Dẫn Tiên pool/quota.

Do not introduce a second P3.7 gacha probability authority.

Premium currency:
- repo still has no canonical Tiên Ngọc / Tiên Ngọc Khóa wallet;
- do not invent one incidentally;
- when authorized, ordinary premium spending should buy limited Chiêu Mộ Lệnh rather than bypass Dẫn Tiên;
- special limited banners are a separate future system.

---

## Other locked corrections

Spirit Field:
- active plot reserves one disciple until harvest;
- passive crop timer grants no work Tu Vi;
- worker slots = plot slots;
- Lv1 4 slots, +1 every 5 levels;
- canonical warehouse deposit.

Warehouse:
- one canonical stackable-resource warehouse;
- no capacity gameplay ceiling;
- explicit resource IDs/realm/tier/quantity;
- no Phẩm Lực.

---

## Next

The natural next disciple-design discussion is **Linh Căn V2**.

Do not implement it unless the user explicitly authorizes that phase.
