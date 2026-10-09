# REALM LADDER V2 — TÔNG MÔN BÁ ĐẠO

Date: 2026-10-07
Status: **DESIGN LOCKED — NOT IMPLEMENTED**

Purpose:
- define one canonical long-form realm ladder for Tu Vi and Luyện Thể;
- keep both progressions equal in length while preserving independent growth;
- provide one shared level coordinate for future map/reward/content scaling.

This document locks realm names/order and 10-floor structure.
It does not implement cultivation/breakthrough/runtime migration.

---

# 1. Shared structure

Both Tu Vi and Luyện Thể use:

- **30 đại cảnh**;
- **10 tầng per đại cảnh**;
- therefore **300 progression floors per track**.

The 30 realms are organized into three macro stages:

1. **Nhân Giới** — realm 1..10;
2. **Tiên Giới** — realm 11..20;
3. **Thần Giới** — realm 21..30.

These are progression bands, not hard travel locks by themselves.

Global floor coordinate:

`global_floor = (realm_index - 1) × 10 + floor`

where:
- `realm_index = 1..30`;
- `floor = 1..10`;
- `global_floor = 1..300`.

Tu Vi global floor and Luyện Thể global floor are separate values.

A disciple may have very different progress on the two tracks.

---

# 2. Tu Vi — 30 đại cảnh

## Nhân Giới — 1..10

| # | Tu Vi |
|---:|---|
| 1 | Phàm Nhân |
| 2 | Luyện Khí |
| 3 | Trúc Cơ |
| 4 | Tử Phủ |
| 5 | Kim Đan |
| 6 | Nguyên Anh |
| 7 | Hóa Thần |
| 8 | Luyện Hư |
| 9 | Hợp Thể |
| 10 | Đại Thừa |

Transition direction:
- after Đại Thừa tầng 10, the ascension transition may use an explicit **Độ Kiếp** event/system;
- Độ Kiếp is not a 31st realm in this ladder.

## Tiên Giới — 11..20

| # | Tu Vi |
|---:|---|
| 11 | Nhân Tiên |
| 12 | Địa Tiên |
| 13 | Thiên Tiên |
| 14 | Chân Tiên |
| 15 | Huyền Tiên |
| 16 | Kim Tiên |
| 17 | Thái Ất Kim Tiên |
| 18 | Đại La Kim Tiên |
| 19 | Tiên Vương |
| 20 | Tiên Đế |

Transition direction:
- Tiên Đế tầng 10 -> Thần Giới may later use an explicit Thần Kiếp/ascension event;
- the event is not another realm.

## Thần Giới — 21..30

| # | Tu Vi |
|---:|---|
| 21 | Thần Nhân |
| 22 | Chân Thần |
| 23 | Thiên Thần |
| 24 | Thần Quân |
| 25 | Thần Vương |
| 26 | Thần Hoàng |
| 27 | Thần Đế |
| 28 | Thần Tôn |
| 29 | Hỗn Độn Thần |
| 30 | Sáng Thế Chủ |

Sáng Thế Chủ tầng 10 is the current V2 ladder endpoint, not a promise that future content can never append beyond it.

---

# 3. Luyện Thể — 30 đại cảnh

Luyện Thể is a separate progression track.
Realm rows are aligned by broad content/power band with Tu Vi but do not require equality.

## Nhân Giới — 1..10

| # | Luyện Thể |
|---:|---|
| 1 | Phàm Thân |
| 2 | Luyện Bì |
| 3 | Luyện Nhục |
| 4 | Dịch Cân |
| 5 | Đoán Cốt |
| 6 | Thông Mạch |
| 7 | Tôi Tạng |
| 8 | Luyện Huyết |
| 9 | Khai Khiếu |
| 10 | Linh Thân |

Note:
- `Luyện Huyết` is intentionally used instead of `Hoán Huyết` to avoid collision with the Huyết Mạch V2 replacement mechanic named Hoán Huyết.

## Tiên Giới — 11..20

| # | Luyện Thể |
|---:|---|
| 11 | Kim Thân |
| 12 | Pháp Thân |
| 13 | Huyền Thân |
| 14 | Thánh Khu |
| 15 | Tiên Khu |
| 16 | Chân Thân |
| 17 | Bất Hoại |
| 18 | Thái Ất Kim Thân |
| 19 | Đại La Kim Thân |
| 20 | Đế Thân |

## Thần Giới — 21..30

| # | Luyện Thể |
|---:|---|
| 21 | Thần Khu |
| 22 | Thần Cốt |
| 23 | Thần Mạch |
| 24 | Thần Tạng |
| 25 | Thần Tủy |
| 26 | Thần Khiếu |
| 27 | Thần Thể |
| 28 | Bất Diệt Thần Thể |
| 29 | Hỗn Độn Thần Thể |
| 30 | Sáng Thế Thần Thể |

Sáng Thế Thần Thể tầng 10 is the current V2 body-training endpoint.

---

# 4. Alignment rule

Same row means:
- similar broad content band;
- useful for map recommendations and content planning.

It does NOT mean:
- Tu Vi must equal Luyện Thể;
- one track hard-locks the other;
- a character below the recommended body realm cannot enter a map.

Examples:
- Kim Đan 7 + Đoán Cốt 3 is valid;
- Trúc Cơ 2 + Đoán Cốt 10 is valid;
- Sáng Thế Chủ 5 + Hỗn Độn Thần Thể 8 is valid.

Map access/viability is governed by actual combat and expedition rules, not a hidden equality requirement.

---

# 5. What this lock does not decide

Still separate/future:
- exact Tu Vi EXP curve;
- exact Luyện Thể EXP curve;
- ~~exact Realm/Body Core ATK/DEF/HP tables~~ — **subsequently locked on 2026-10-09** by `docs/DV2_REALM_BODY_COMBAT_CURVES_V1_PROPOSAL.md`: `G(r,f)=1.65^(r-1)*1.03^(f-1)` and Realm/Body base rows. Actual V2 gameplay migration still pending;
- exact Tu Vi breakthrough chances beyond already approved breakthrough laws;
- exact Luyện Thể major-breakthrough material recipes;
- ascension encounter content;
- map-by-map recommended floor values.

Those systems must consume this 30×10 ladder rather than create another realm ordering.
