# TÔNG MÔN BÁ ĐẠO — ĐẠI ĐIỆN V2: GOVERNANCE, OFFICES, GROWTH, BUILDINGS, UX, GAMEPLAY & QA

**Date:** 2026-11-01. **Status:** FULL NEXT-PHASE DESIGN / IMPLEMENTATION CONTRACT; **NOT YET CODED / NOT BALANCE APPROVED / NOT PLAYABLE ACCEPTED**.  
**Source basis:** ONE GAME RC at eb5e139d61adb5e9881ccb85d4cd823ad7a84263. **Do not touch main or existing owner save.**  
**Owner directive:** unlock the Chưởng Môn office and essential officers EARLY; every position grants actual tested effects and grows through real activity. If the NEXT development phase is Đại Điện, deliver the whole gameplay vertical slice (code + live 1280×720 UX + cross-system effects + Save/Reload + executable RC + raw evidence). Do not ship a text-only or UI-only Hall.

## 0. Authority and external research

### Verified CURRENT code (not a proposed future feature)
- BuildingSystem.DEFINITIONS and BuildingSystem.initialize() contain mine, forest, alchemy, field, Dẫn Tiên Đài and body-training, **not a main_hall BuildingState**, not a residence BuildingState. A main-hall token appears in the map/presentation, but map token != upgradeable runtime building.
- p3_2_landscape_sect.gd._build_main_hall_policy_controls() currently exposes workforce/needs/equipment policies and Economy-A; it does not promote sect rank, appoint office holders, upgrade Main Hall or impose hall-level building gates.
- SectState currently stores no canonical Main Hall level, 27-rank sect progression or persistent office mastery/assignments.
- P12Factory gives disciple_capacity 8; P16Factory gives lodging_capacity 6; NeedsSystem.expand_lodging spends 8 generic supply for +1 lodging only. RecruitmentSystem.accept_candidate checks disciple_capacity alone. Thus house expansion cannot unlock recruitment.
- Dẫn Tiên Đài already has RecruitmentSystem.assign_guidance_main and assistant-role IDs and Mị Lực quality logic. **NEVER create a second independent Tiếp Dẫn authority.**
- D7: Tam Căn = Tư Chất / Căn Cốt / Tâm Tính; Tứ Tính = Tiềm Lực / Thông Tuệ / Cơ Duyên / Mị Lực. Tâm Tính has no fully verified live consumer, and some proposed role effects have no existing consumer; only count a buff as complete when actually committed by an authoritative consumer. Natural cultivation and fixed pill EXP must remain distinct. Injury, production job, PvE and SaveService retain existing invariants.
- Old docs/P3_7_BUILDING_TREE_SPEC.md considers Main Hall singleton and residences multi-instance; Hall Lv10–100 governance milestones. Its earlier 1000–3000 population target is obsolete relative to user's NEWER target Nhân >=90, Tiên ~200, Thần 400–500.

### Research references: inspirations, NOT copied balance
1. https://www.taptap.cn/moment/509008378219989866 : a guide documents 掌门/传功/接引/戒律 appointments and +5-point six-stat occupation effects in 最强祖师; players can exploit rapidly changed offices for thresholds.
2. https://www.taptap.cn/moment/452771685058216137 : player guide quotes +15% ordinary cultivation efficiency for 掌门, +10% elders, +5% inner disciple; these are THAT GAME's values, not approved values here.
3. https://www.taptap.cn/moment/506171196430092461 and https://www.taptap.cn/moment/476357252727440780 : Main Hall appointments, position-specific aptitude, guide Mị Lực and other sect administration.
4. Internal reference repo vuanhtuan161094-byte/ZQZS-Source-Knowledge / analysis/SystemResearch/HOME_BUILDING_DEEP_DIVE.md: building identity/footprint/door, stage-dependent models, management and guildlvl_limit; these are evidence for building architecture/UI patterns, NOT a complete verified economy or permission to lift artwork/code.
5. https://xianxia.dev/sects/ : broader design lesson on permission-separated organizational offices, role rights, and safe reassignments. Not canonical game rules.

**Distinctive design:** More meaningful than copying +5 six stats: clear role preview, 7-stat affinity, a personal benefit plus a cross-system function where relevant, office mastery progression, idempotent receipts, eligibility/policy audits, early unlocks, and a separate Hall-level / sect-rank / population-limit system.

## 1. Three independent but coupled progressions

**A. Đại Điện instance: Lv1–100**. Exactly ONE main_hall_001 as an owned BuildingState. It has cost, work/tick progress, main-hall upgrades, milestone unlocks, level-cap authority for other building types, and allowed instance counts. Never treat a map landmark as this building until its stable ID is projected correctly.

**B. Tông Môn rank: 27 steps** = Nhân 1–9, Tiên 1–9, Thần 1–9. Rank promotion is a SEPARATE transaction, with hall min-level, minimum roster size, qualifying disciple realms, authenticated production/warehouse contribution, Uy Danh and an administrative/trial task; Boss is NOT required. Promotion does not directly upgrade buildings. Live realm cultivation gates must be SOFT, preventing a whole roster from deadlocking.

**C. Office mastery: Lv1–10 PER DISCIPLE AND OFFICE TYPE**. Unique appointments, earned role EXP, immediate personal buff and stable institutional buff according to the rules below. This is NOT a second combat/cultivation level, and does not mutate D7 birth or permanent D7 base values.

Three caps: actual admissible population = min(sect-rank administration cap, total active Residence bed capacity). Dẫn Tiên controls candidate throughput/quality but not either population cap. A rank or Hall upgrade with no real beds cannot magically admit a disciple; an extra bed with insufficient admin rank likewise cannot.

## 2. Office unlocks: move gameplay to EARLY levels

| Hall Lv | Office / number | Main focus and effect consumer | Implementation acceptance |
|---|---|---|---|
| 1 | Chưởng Môn ×1 | appointee personal D7 projection, natural cultivation, live HP | playable from first New Game |
| 1 | Tiếp Dẫn Trưởng Lão ×1 | existing guidance Main ID, Mị Lực effective recruitment snapshot | **one owner** tied to Dẫn Tiên |
| 1 | Truyền Công Trưởng Lão ×1 | ordinary natural cultivation XP | actual Tu Vi consumer |
| 3 | Nội Vụ Chấp Sự ×1 | production cycle time, workgroup policy | Mine/Forest/Spirit Field actual job starts |
| 5 | Hộ Pháp Trưởng Lão ×1 | same PvE team's damage mitigation | only if role holder is deployed in that team |
| 7 | Đan Đạo Trưởng Lão ×1 | Alchemy real batch work duration | only actual approved recipes and workers |
| 10 | Giới Luật Trưởng Lão ×1 | real rest/stamina discipline/recovery policy | NeedsSystem REST consumer, not a fake morale system |
| 12 | Kho Vận Chấp Sự ×1 | market buy/transaction handling | only if Economy-A market enabled and accurately rounded |
| 15 | Luyện Khí Trưởng Lão ×1 | real forge work/quality channel | only when verified forge consumer exists |
| >15 | optionally more assistant/department seats | requires actual backend consumer and a balance/content gate | never show fake bonuses |

**Office** is not the same as disciple sect standing (Ngoại Môn / Nội Môn / Chân Truyền), profession talent, or active one-job assignment. One disciple holds **at most one main office**; recruitment supporting assistants are NOT main offices. Appointing somebody to an office does NOT forcibly cancel cultivation, field, alchemy or PvE. Officer keeps their role while hunting. Any explicit office duty consuming time is a normal job and therefore follows One Active Job. A holder who dies/leaves/has an invalid roster ID clears the seat by authoritative migration/transaction; Injury may pause institutional effect without deleting their position, according to UI status. No historical occupied seat duplicate after load.

The player is the owner/commander; **Chưởng Môn is a chosen actual disciple**, not an automatically created player character. New Game presents an empty office with an obvious tutorial nudge, but does not silently autoappoint a specific starter disciple.

## 3. Buffs — proposed tuning data, not owner-approved balance

The table contains concrete V2 **prototype numbers**, to be reviewed using XP/production combat telemetry. Lv10 endpoint linearly interpolates from Lv1; all percentages are percentage-point bonuses relative to actual authorized base channel, never hidden multipliers on the full final result.

| Office | Lv1 active bonus | Lv10 end bonus | Selected discipline / scope |
|---|---|---|---|
| Chưởng Môn | Self +25 effective D7 in each of 7 dimensions; +8% natural Tu Vi gain; +3% max HP | +70 effective D7; +14% natural Tu Vi; +7% max HP | personal only; actual current stat projection; no permanent birth changes |
| Tiếp Dẫn | +60 effective Mị Lực in existing day's quality/quota calculation | +285 effective Mị Lực | only appointed Main Guide, same RecruitmentSystem daily snapshot; existing 5% ceiling remains |
| Truyền Công | +3% ordinary natural cultivation gains to eligible sect disciples | +9% | natural authorized XP only; zero multiplier for fixed-value pill |
| Nội Vụ | -2% time of newly started eligible Mine/Forest/Field jobs | -8% | active job start snapshot only; no change to already scheduled end time |
| Hộ Pháp | team incoming damage -2%; holder DEF +3% | -6% team damage; holder DEF +8% | only team with holder deployed; PvE, not all 6/30/60 disciples remotely |
| Đan Đạo | newly started eligible alchemy batch time -2% | -8% | needs approved recipe; no fabricated product quality/SKU |
| Giới Luật | +3% stamina/HP rest amount for legally resting, eligible sect residents | +9% | does NOT reduce Injury120 duration, auto-cure permanent injury or create morale without a consumer |
| Kho Vận | -1% purchase price for eligible market orders, rounded down with minimum payable price | -5% | future expansion; no discount if Economy-A absent |
| Luyện Khí | +2% real profession/forge XP on committed eligible craft | +8% | only if a verified XP consumer exists; otherwise feature locked, NOT a decorative "enabled" card |

**Important: the Chưởng Môn effective D7 buff must be derived separately** from immutable birth and permanent growth. Expose display: birth D7 + permanent trained D7 + current office modifier = effective D7. For an attribute without a live consumer (e.g., Tâm Tính pending), mark that specific downstream effect unimplemented rather than implying a stat impact. Recompute HP from authoritative combat stats preserving CURRENT HP RATIO; do not heal to 100% on appointment, Save/Reload, or office dismissal. Avoid double counting aptitude when both its effective points and an additional natural XP bonus are applied: two explicitly separate additive contributions to the SAME BASE, never nested multiplication.

**Office affinity proposal:** choose two visible, semantically relevant D7 stats per office:
Chưởng Môn Tâm Tính+Tiềm Lực; Tiếp Dẫn Mị Lực+Cơ Duyên; Truyền Công Thông Tuệ+Tư Chất; Nội Vụ Thông Tuệ+Tâm Tính; Hộ Pháp Căn Cốt+Tiềm Lực; Đan Đạo Thông Tuệ+Cơ Duyên; Giới Luật Tâm Tính+Căn Cốt.
Displayed suitability score, proposed q = clamp(0.90 + 0.0001*((primary+secondary)/2), 0.90, 1.15). For percentage modifiers, effective_bonus = min(channel_cap, interpolated_office_bonus * q), source-mapped to existing modifier buckets. Cap within original Dẫn Tiên quality 5%/15% and combat bounds. A good candidate must be visibly better than a weak one without 10x amplification. No magic "buff all sect output" if no real consumer exists.

**Snapshot rules:** personal Chưởng Môn projections apply immediately after a validated appointment; institutional bonuses change at the NEXT simulation-day boundary (1440 ticks) for recruitment and scheduled logistics to prevent swapping/chaining. Job-time reductions snapshot at job BEGIN; PvE mitigation snapshots at encounter/team formation or uses immutable current combat snapshot as authorized. Changing office never duplicates a paid receipt, returns resources or rerolls candidates already generated. Show "Hiệu lực: ngay/ngày kế tiếp/job kế tiếp" in tooltip.

**Stacking:** identical office IDs never stack; one sect Truyền Công maximum at first phase; multiplicative stacking with independent trait/equipment effects prohibited unless explicitly approved. Group additively per source channel, clamp caps, log source breakdown. Fixed-value consumables remain EXACT units, subject only to their existing policy/saturation ownership.

## 4. Office mastery & career progression

- Office EXP is distinct from cultivation/realm/occupation EXP. Per-disciple/per-office mastery history persists if the disciple temporarily loses their office (no swap-farm reset). Only active appointed holder earns it.
- Proposed EXP to next level from L=1..9: required(L) = 40 + 20*L + 5*L*L, deterministic integers. Max Lv10, no reward beyond cap until explicitly designed.
- Award mastery from **real committed receipts**: Chưởng Môn on an approved sect management milestone; Tiếp Dẫn on day-scoped completed admission/snapshot; Truyền Công on committed authorized nonzero natural cultivation grants; Nội Vụ on settled production job, Hộ Pháp on settled legitimate encounters involving holder, Đan Đạo on real completed approved medicine recipe, Giới Luật on legitimate REST events. No per-frame XP and no offline XP minted from an invalid background poll.
- Baseline event XP proposal: +5 for eligible completed domain receipt, +15 on first qualifying major milestone of the simulation day, daily cap 40 EXP per office, tracked by day index and bounded receipt IDs. Do not let infinite repeatable cheap jobs abuse mastery or replay after reload. *No boss-only progression*.
- Each level improves the office-specific numbers above; at milestone levels 3/5/7/10, show a small new descriptive title/office emblem and thresholds. Do not claim new system behavior at these levels unless a corresponding consumer ships.
- Office appointment log: appointee ID, office ID, appointment sequence, start tick, last assignment tick, effect activation day, snapshots and source receipt; state persists in the one authoritative SectState. UI shows current level, EXP bar, up-next source and whether office is active/paused.
- Upon leaving: immediately remove personal effects, scheduled institutional effects expire according to day/work contract; no retroactive clawback of legitimate earnings. Injury pauses active institutional effects but not mastery history, no automatic reassignment. Autoassign OFF unless player opts in; never swap a working disciple without an explicit job command.

## 5. 27 sect ranks, hall gates and population growth (PROTOTYPE CONFIG)

Exact 27 entries must reside in ONE JSON/catalogue and be validated. Sample full cap/min-Hall-level target:

| Sect step | Hall Lv min | Proposed sect admin cap |
|---|---:|---:|
| Nhân 1 | 1 | 12 |
| Nhân 2 | 5 | 18 |
| Nhân 3 | 9 | 26 |
| Nhân 4 | 13 | 36 |
| Nhân 5 | 17 | 48 |
| Nhân 6 | 21 | 60 |
| Nhân 7 | 25 | 70 |
| Nhân 8 | 29 | 80 |
| Nhân 9 | 33 | 90 |
| Tiên 1 | 37 | 105 |
| Tiên 2 | 41 | 120 |
| Tiên 3 | 45 | 135 |
| Tiên 4 | 49 | 150 |
| Tiên 5 | 53 | 165 |
| Tiên 6 | 57 | 175 |
| Tiên 7 | 61 | 185 |
| Tiên 8 | 65 | 195 |
| Tiên 9 | 69 | 200 |
| Thần 1 | 73 | 230 |
| Thần 2 | 77 | 260 |
| Thần 3 | 81 | 290 |
| Thần 4 | 85 | 320 |
| Thần 5 | 89 | 350 |
| Thần 6 | 93 | 380 |
| Thần 7 | 96 | 410 |
| Thần 8 | 98 | 445 |
| Thần 9 | 100 | 480 |

These are DESIGN PROPOSAL checkpoints, **not a final 24-month economy model**. User target: Nhân development ~3 real-world months, first Thần around month 12, completion Thần around month 24 F2P, with sufficient opportunity for many disciples. Do not claim those times from the simple rank table; simulate actual sources/sinks and offline clock before acceptance. No required Boss. Every promotion needs real preconditions: hall level, a roster count (below sect cap), minimum eligible cultivation/body realm headcount, warehouse/production milestone, Uy Danh earned from real transactions/activities, and a challenge achievable without PvE. Missing backend authority => gate disabled with a specific blocker, not a green fake.

**Hall upper authority:** it can cap an individual building's maximum accessible level, family instance count, allowed land/plots and administrative team slots. These values must come from an authored catalogue. No duplicate authority stored in Hall and other buildings; derive the current cap from SectRank/Hall state. Preserve prior level and buildings on legacy migration if they exceed new level gates; lock only further new actions instead of destructive downgrades.

**Initial gameplay:** 6 disciples, one initial Hall Lv1, one Residence Lv1 proposed 8 beds, Dẫn Tiên Lv1 and initial candidates. Rank Nhân1 has administration ceiling 12 but actual recruit limit starts 8 beds. Recruit to 8/8; upgrade residence to 10 beds; recruit #9; raising Hall rank alone cannot create beds.

## 6. Đại Điện Lv1–100 milestone architecture

- Lv1: Hall UI, Chưởng Môn, Tiếp Dẫn, Truyền Công; basic sect budget, roster, policy, manual appointment and upgrade.
- Lv3: Nội Vụ.
- Lv5: Hộ Pháp + more management scope, not combat stat hallucinations.
- Lv7: Đan Đạo if actual Alchemy consumer integrated.
- Lv10: Giới Luật, basic salary/loot & Ngoại-Nội Môn policy. They must be functional; don't "unlock" money-policy text that never changes a transaction.
- Lv12/15: Warehouse/Forge management where consumers pass.
- Lv20: deeper automation and production/combat priority policy; safely expand office slots/benefits.
- Lv30: multiple department/management-team groups with true worker constraints.
- Lv50: Chân Truyền/Trưởng Lão hierarchical governance, broader officer candidates; no auto awakening of latent character identities.
- Lv75: actual land/region management only after separate layout/land schema gate; else show future locked content accurately.
- Lv100: hall mastery/one-time reward if authored; promotion and high-tier governance, not Lv101.

**Upgrade transaction**: all costs come from the real Warehouse and spirit-stone authority, validated before debit with one durable request ID. Start -> construction progress from ONE authorized clock -> completion exactly once -> Save/Reload -> unlock UI and downstream actual capacity. Resource family Linh Mộc, Thanh Thiết, Linh Thạch, later milestone material only with proven source. Do not adopt generic tiny costs from current BuildingSystem as final. Obtain prices from Mine/Forest actual output and F2P model first; provisional early test fixtures can use authored numbers clearly marked as QA—not owner balance.

**Sect promotion transaction**: independent from Hall upgrade; no duplicate charge, no imaginary influence resource. Uy Danh gains must link to actual authorized activities; if missing, implement deterministic source/sink and validate before exposing the promotion action. Rank advancement should not be coupled to success against a Boss.

## 7. De Tu Xa / construction integration (same next phase)

- Residence: multiple real BuildingState instances with stable IDs, own Lv1–100, beds, owned position, occupancy and upgrade state; main Hall is singleton. The first Residence is a starting grant; never back-charge the New Game. Subsequent constructions require authorized building layout, land, cost and instance-limit gate.
- Proposed beds per instance: 8 + 2*(Lv-1); calculate sum of ACTIVE instances. Current legacy +1 rest slot for 8 supply cannot remain independent admission cap forever.
- One canonical capacity read API derives min(rank cap, total beds). Wire it into RecruitmentSystem.can_accept_more, accept_candidate and Dẫn Tiên UI. Use a single source of truth, never two writable capacity counters.
- Bedroom assignment / REST only affects active rest and health/stamina, does NOT reroll candidate D7 or cultivation, cannot bypass Injury120. Away PvE disciples still own beds unless player explicitly changes reservations.
- Current ADR-0003 fixed-layout V1 remains authoritative until a separate approved migration moves location into a single persistent SectLayoutState. Do not counterfeit 'buildable' by copying map textures.
- For existing saves: migration preserves old admitted disciples and legacy lodging expansions; if higher old capacity exists, preserve it in a compatibility entitlement until equivalent real residence capacity is restored. Any overcapacity save keeps its roster but cannot accept new applicants until legal; not silently delete people.

## 8. UI/UX requirements: one real Godot screen, landscape 1280x720

Target: tap real main-hall building on map -> context panel -> **ĐẠI ĐIỆN**. Match visual design of HS09, keep world visible/low obstruction when closed, no AI-generated art or HTML substitute. Source A avatar only through approved scene mapping; missing Source A shows explicit placeholder. 1170x656 or smaller on desktop; mobile touch targets min ~42 px, short label, scroll only local, retain pan/zoom.

**Tab 1 TỔNG QUAN:** actual Sect Name + Nhân/Tiên/Thần rank + Hall Lv; population used / min(rank cap, beds), housing 8/8 vs 8/12 administrative, real Prestige, resources, next unlock, warning on bottleneck. A click on bottleneck jumps to relevant Dẫn Tiên/Residence/warehouse location.

**Tab 2 CHỨC VỤ:** office card grid (open/locked/empty/occupied), one Chưởng Môn prominent at top. Show assigned portrait/name, career fit, active buff text + ACTUAL projected numeric delta, mastery Lv and XP, assignment expiry/snapshot. Clicking empty slot opens a searchable candidate drawer from actual roster with sort by relevant two D7 stats, current work, sect standing, availability, real buff preview. Compare current/new officer side by side with all consequences. Buttons Bổ Nhiệm, Đổi Người, Miễn Nhiệm; confirmation and durable receipts, no silent job cancellation. Role conflicts and role uniqueness explained inline. A new role assignment must be visible on the disciple's HS09 profile and selected character overlay.

**Tab 3 NÂNG CẤP:** Hall current Lv/100, cost/available stock, construction time and time remaining, what exact capabilities next level changes, gate status (resource/sect rank/ongoing job). One button calls backend; disable reason displayed; no misleading Mine copy.

**Tab 4 THĂNG BẬC:** rank Nhân x/9 -> next; checkbox-like evaluated requirements per actual state: Hall Lv, live roster/qualifying cultivation, real production receipts/stock, Uy Danh, challenge; current/required numeric with Go To links, total grants before confirmation. No boss-only hard lock.

**Tab 5 CHÍNH SÁCH:** existing workforce/needs/equipment/Economy-A actual authority; extend salary, allocation, officer privileges only where transactions exist. Display auto/manual and projected effect; no mass auto-reassignment while disciple has an active job.

**Tab 6 KIẾN TRÚC & TỔ CHỨC:** real level caps, family instance limits, land authority (if active), workforce groups, current offices/roles. Construction shortcut only for actually authorized placements and costs; otherwise honest disabled state / pending authorization.

UI MUST be responsive and avoid wall-of-text, use Source A portraits/icon placeholders and compact numeric badges for player decision-making; main Hall retains one overlay like HS09, not multiple overlapping modals.

## 9. Implementation ownership / exact integration

Suggested ONE candidate integration branch based on the then-current playable ONE GAME RC, created AFTER the Dẫn Tiên owner priority is accepted. One PR for the integrated feature, not endless QA PR shards.

- **Data content:** new verified Hall and Office catalogues (27 sect rank rows, office progression/buff rules, Hall unlock table, upgrade cost table). Parse/schema validation, no silent default of missing fields.
- **Backend:** Hall building lifecycle in BuildingSystem; new SectGovernanceState (or one versioned nested SectState governance dictionary), HallAuthority (level/sect rank/gates), SectOfficeSystem (appointments, eligibility, mastery receipts), SectCapacityAuthority (rank + residence beds), SectPrestigeSystem only if a legitimate real prestige/renown source exists.
- **Systems integration:** WorkforceSystem; RecruitmentSystem Main Guide SAME ID; FoundationSystem derived D7 read models; DiscipleTuViFlowV2/RealmProgressV2 natural vs fixed; combat stat HP ratio and PvE party effects; BuildingSystem job-start modifiers for economy/Alchemy; NeedsSystem rest. One modifier owner and explicit channel; no duplicate shadow bonus calculators.
- **Presentation:** actual Godot Main Hall Control scene and role selector, not just HTML; update 2.5D map token to canonical main_hall_001; panels read live authority and emit validated commands. Update HS09 per-disciple office title, relevant profile buff breakdown. No standalone clone of SimulationState/SaveService.
- **Persistence:** versioned migration and unit roundtrip for Hall, rank, officers, mastery, cap, upgrades, work snapshots, inventories, order receipts, Dẫn Tiên guide, residence instance IDs; older saves must not be silently rerolled.
- **Resource constraints:** user Windows 8GB RAM; Godot 4.7.2 official; isolate QA E: checkout, protect owner save/profile, pre-run memory gate, avoid parallel Chrome/QA instances and unjoined Thread warnings; keep 1280x720 and Android compatibility.

## 10. Definition of DONE, full end-to-end tests

1. Official Godot 4.7.2 clean import; no parse warnings; regression suites unchanged.
2. New Game actual map shows ONE canonical Hall Lv1; can click it with mouse and enter all six functional tabs; screenshots 1280x720 show no clipping, oversized text or fake stat.
3. On New Game choose one real founder as Chưởng Môn Lv1: 1 unique assignment, immediately visible and proved real D7 derived values, natural XP delta and HP ratio preservation; switch/dismiss and rollback to original effective stats with no permanent mutation.
4. Assign Tiếp Dẫn in Hall: same Main ID appears in Dẫn Tiên; quality snapshot and daily quota reflect actual Mị Lực; no two authorities, no reroll after Save/Reload.
5. Assign Truyền Công: two cultivation source channels demonstrate natural XP buff and fixed pill exact unaffected. Test additive source breakdown and no stat double counting.
6. Hall Lv3 Nội Vụ: real job-start duration before/after; no retroactive change to already running jobs.
7. Hall Lv5 Hộ Pháp: deployed team mitigation only; remove role and team effect gone at allowed snapshot; no benefit to other teams; Injury/PvE changes safe.
8. Hall Lv7 Đan Đạo: verified approved Alchemy recipe work duration changes, no fabricated SKU/quality.
9. Hall Lv10 Giới Luật: actual legal REST gains, no Injury120 premature cure.
10. Office affinity matters visibly and mathematically; 1–10 mastery EXP from genuine receipts only, cap/day, level-up applied once; duplicate receipt, repeated Save/Reload and time jumps cannot exploit.
11. Upgrade Hall Lv1→2→3 and milestones: true resources and time, exactly-one debit, no stuck upgrades, unlocks role in real UI, safe save while upgrading. Missing costs show clear blocker.
12. 27 sect-rank catalogue row and gate coverage; early rank promotion played at least once using genuine source gates; later rank gates tested with explicit fixtures; no boss hard requirement or limitless cap.
13. Reconcile capacity: 6 founders/8 beds, recruit to 8, third applicant refused; Residence upgrade 8→10, third accepted if rank cap 12; more beds with admin cap 12 still refuses 13th.
14. Multiple Residence instance tests only if authorized placement/land/building gate enabled; no duplicate house instance IDs or fake visual token, durable before/after migration.
15. Multi-system single-save scenario: New Game → office → Dẫn Tiên → Residence → Mine/Field → alchemy → Hall upgrade/rank → Save/Exit/Reload → PvE. Verify officer effects/XP/jobs/roster/resources intact, no unjoined Thread warnings, no replay.
16. Rendered GUI capture of Main Hall overview, office assignment/compare and upgrade/rank tab, actual click automation labelled accurately. Owner manual mouse/touch acceptance separately PENDING until completed.
17. Benchmark idle/30 applicants/90+ roster (with test profiles), RAM/FPS percentiles, not a single ~60fps screenshot.
18. Maintain compatibility with all existing Dẫn Tiên C2, SX01/SX02, JSON save, O8, injury, PvE tests. Headless PASS is not FULL PLAYER-ACCEPTED.

**Delivery artifacts REQUIRED:** integrated source SHA/branch, one draft PR, catalogue, schema/migration description, test scripts+logs, screenshot captures, playable Windows launcher using isolated save, concise owner playtest instructions and honest PASS/BLOCKED/PENDING matrix. No merge to main without owner review. If any office lacks an actual downstream consumer, it remains visibly LOCKED and phase is NOT fully accepted until either it is implemented or scope is deliberately reduced by the owner.

## 11. Codex task handoff after Dẫn Tiên acceptance

1. Inspect exact live RC HEAD and existing Dẫn Tiên/Residence/building feature status. Do NOT start from stale 2026-10-30 baseline.
2. Implement P0 Hall real singleton + capacity reconciliation + Chưởng Môn/Tiếp Dẫn/Truyền Công with live buffs and complete GUI; test owner playable.
3. Finish all milestone offices with real relevant downstream consumers, mastery Lv1–10, 27-rank cap/promotion, upgrade costs and actual building interactions. Do not bypass unimplemented source systems with labels. Keep one consolidated RC branch/worktree.
4. Integrate with existing SaveService, one-active-job, D7, injury, Source A, economy and PvE. Rebuild real 1280×720 captured UI and publish exact test logs.
5. Finish complete End-to-End acceptance above before offering to merge.

**Priority**: After completion of Dẫn Tiên, do Hall + Residence capacity together, rather than separate tiny placeholder milestones. Preserve the current Dẫn Tiên owner task, do not interrupt or modify its running Codex worktree.
