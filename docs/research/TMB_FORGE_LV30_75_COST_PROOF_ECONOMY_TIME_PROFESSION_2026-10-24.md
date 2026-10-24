# TÔNG MÔN BÁ ĐẠO — KIỂM TOÁN NGUỒN, CHI PHÍ, THỜI GIAN, NGHỀ Lv30→75

**24/10/2026 · DOCS ONLY · DATA PILOT, NO CODE.** Parent: docs/design/TMB_FORGE_LV30_TO_LV75_STRICT_R21_GATE_REAL_SOURCE_CONTRACT_2026-10-24.md. Main source SHA 29b5fba448b0178cb520a4ada44b375b4b934e31. Owner chose Lv75 MANDATORY before forging any R21 equipment. Numeric Forge upgrade costs are not locked. [SOURCE] means verified main; [PILOT] means our synthetic numbers; [BLOCKED] means Forge runtime absent.

## 1. Exact cost model and executable limitation
[SOURCE] Current BuildingSystem has no Forge type/definition or Forge-specific costs, so nothing in this table is a live Forge quote. [PILOT] Copied only numerical curve shape from the already registered Mine upgrade: for each target level L=31..75, p=L-1; F=1+0.15p+0.01p²; multiplier M=2 for milestones L50 or L75, otherwise 1. Inputs are ceil(4FM) Linh Mộc, ceil(6FM) Thanh Thiết, ceil(20FM) Sect Spirit Stones, plus [P] Lv50:10 Yêu Đan and Lv75:20 Yêu Đan; building work (8+2L)×(1.75 if milestone else1). Existing milestone names Lô Tâm/Hỏa Chủng are examples, NOT equivalent to Yêu Đan. This alternative milestone ingredient must receive owner approval.

| Upgrade targets | Levels | Linh Mộc | Thanh Thiết | Sect Stones | Yêu Đan | Work units |
|---|---:|---:|---:|---:|---:|---:|
|31–49|19|1,706|2,556|8,504|0|1,672|
|50|1|259|389|1,295|10|189|
|51–74|24|4,669|6,998|23,303|0|3,192|
|75|1|535|803|2,675|20|276.5|
|**TOTAL**|**45**|**7,169**|**10,746**|**35,777**|**30**|**5,329.5**|

[SOURCE] Existing per-building process_tick advances upgrading construction by 1 work/tick, no particular Forge worker in that method. [SIM] Future Forge using the same scheme takes 5,330 completed ticks due to ceil(276.5)=277 on final stage, equaling **3.7014 simulation days** when starting with all cash/materials and zero interruptions. This is building construction ONLY, not resource gathering, funding, crafting R21 items, live test time or real-world wall clock. Lv30→31 trial bill 58wood+87ore+290Stones; Lv49→50 259wood+389ore+1295Stones+10Yêu Đan; Lv74→75 535wood+803ore+2675Stones+20Yêu Đan. Values are reproducible with the formula and do not change main.

| Reached Lv | Cumulative wood | Ore | Stones | Yêu Đan | Work units |
|---:|---:|---:|---:|---:|---:|
|35|324|484|1,608|0|370|
|40|731|1,094|3,636|0|790|
|45|1,231|1,844|6,134|0|1,260|
|49|1,706|2,556|8,504|0|1,672|
|50|1,965|2,945|9,799|10|1,861|
|55|2,685|4,023|13,387|10|2,431|
|60|3,529|5,287|17,595|10|3,051|
|65|4,506|6,752|22,473|10|3,721|
|70|5,626|8,432|28,071|10|4,441|
|74|6,634|9,943|33,102|10|5,053|
|75|7,169|10,746|35,777|30|5,329.5|

## 2. Inputs and real pre-R20 source authority
- [SOURCE] Linh Mộc is registered and comes from actual Linh Lâm working producer. Required 7,169 units are NOT already present. Production rate depends on genuine worker/source/tick and availability, not camera.
- [SOURCE] Thanh Thiết is registered and comes from actual Mỏ producing resource. Need 10,746 units and more if separately sold to finance upgrade.
- [SOURCE] Yêu Đan ID is registered. HuntingMapV2 Hắc Phong Cốc reward declaration contains 2 Yêu Đan per successful completed LEVEL ONE ENCOUNTER; at the one-victory once-settled contract, 30 Yêu Đan costs 15 legitimate wins if no alternative spend. This is NOT 2 per monster or per contributing disciple. Map must be actually reachable, combat won and receipt applied; code definition alone is not completed field evidence.
- [SOURCE] Sect Spirit Stones are held in Economy-A Sect balance, NPC sales to market against real unreserved resources. Only Linh Mộc, Thanh Thiết, Thanh Linh Thảo and Linh Cốc are accepted in the V2 merchant. Unsupported new R21 material cannot be sold to finance upgrade. Existing Body-Gate materials and seals do NOT become Forge inputs.
- No material depends on a future R21 area or boss. A squad with actual R20 equipment should still be able to hunt old-region monsters by ordinary survival mechanics, but this remains gameplay evidence PENDING.

## 3. Critical Stone-funding bottleneck
[SOURCE default policy] Market daily sale quota=20 units, maximum5 per sale request, and sell values of Thanh Thiết=8 Stones and Linh Mộc=2 Stones/unit. [PILOT] The 45 upgrade stages cost 35,777 Stones. If starting Sect balance=0, NO other income/expenses, and selling only ore at most20/day, need ceil(35777/8)=**4,473 extra ore sold** and at least ceil(4473/20)=**224 simulation days** merely to accumulate fee funding. Thus total ore mine output at least 10,746 paid+4,473 sold=**15,219** if financed only this way. Wood-only financing requires 17,889 additional wood sales and at least 895 days under same quota. These are conditional MINIMUMS, not observed gameplay ETA: sale policy can change, workers/mine resources may be unavailable, different valid Stone receipts or preexisting savings can help, and wages/upkeep prolong.
Recommended reserve planning: first calculate next-level costs, protect existing player Warehouse rules and any active job reservations, then decide whether to divert additional lower-tier ore into market sale. Do not invent a new direct tax/Stone drip, make NPC buy unavailable rare ore, or charge a personal wallet instead of Sect Stones.
Owner open: accept slow strategic funding, revise Forge-specific coefficients, or author a genuine accessible pre-R20 Stone faucet with source+receipt+sink. Strict Lv75 must not be bypassed as economic fix.

## 4. Profession/clock separation
[P3.7 LOCK] Luyện Khí profession level=floor(sqrt(XP/24)), speed=1+0.01×level. This is a worker factor for genuine forging/repair/research work, not a proven building-construction speed multiplier; BuildingSystem currently advances construction progress by tick independently of crafter role. Forge Lv75 is BUILDING level, not profession75. One Active Job remains for Mine/Forest/hunt/Forge workers; Injury0/1 auto-return/recovery120 ticks is not a free work speed bonus. Two workers assigned to a building do not automatically create two concurrent Forge job lanes. Future construction worker policy must be a separately approved authority if requested.
A building in UPGRADING status by default should refuse new equipment jobs or drain/pause old jobs under a coherent reservation/receipt rule; current Forge has no process to do so. Snapshot duration and materials at acceptance; job speed modifies time only, not quantity or quality without an explicitly authored skill consumer.

## 5. One building investment, thousands of recipients
Facility Lv30→75 fee paid once per legitimate Forge INSTANCE. It is not repeated for every one of 1,000–3,000 Sect disciples. Future R21 10-slot kit from prior source study: 15 new tier ore +21 new tier fiber +4 normal beast+420 Stones+320 base forge ticks per disciple, one Sect basic catalog unlock consumes1 extra ore+1 beast. 30 hunter kits would require 451/630/121 R21 material units and 12,600 Stones, for a combined initial building+30 kit pilot Stone bill **48,377** excluding research expenses. Those R21 materials and recipes are proposed IDs, NOT active registered source. Forge Lv75 alone does not create any Thần material, set, grade12 or Chân Văn. Prioritize 30 actual combat deployable units before broad 3,000-person re-gearing and use lawful hand-me-downs when appropriate.
## 6. Owner gates
Numeric coefficients4/6/20 and milestone Yêu Đan10/20 OPEN; core Lv75 required before any R21 forge is owner-chosen direction. Construction time, facility upgrade ability, real resource stock/source payouts, money pacing, pre-R21 map source path, old-save compatibility, and physical Godot 4.7.2 regression/Windows/Android are NOT PASSED.
