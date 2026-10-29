# V6.4 — Manuals, learning, study, economy and UI contract

Status: **economy candidate, not approved balancing**. Integrate with existing sect Warehouse, personal Contribution/Spirit Stones and One Active Job. Do not create a duplicate inventory, second scheduler, or extra class XP bar.

## 1. Objects and relationships

- Kỹ Phổ/Bí Kíp: complete sect-archivable skill-family or chapter transmission. Archive first complete copy permanently; student never destroys teaching source.
- Công Pháp: separate cultivation/build foundation; one main and up to two auxiliaries active; other learned technique IDs retain personal mastery and history.
- Truyền Thừa: successor unlock for Human→Immortal→Divine; branch A/B explicit. A descendant replaces the previous generation as active source; no triple stacked generations.
- Ngộ Đạo: deterministic personal mastery/evolution with authored realm/body/skill/technique gates, time and costs. No learning-failure RNG.
- Dị Thần: authored rare Divine ultimate and alternate elective passive; **replaces** existing ultimate/passive, never adds free slot. Rare and normal paths remain earned, not random instant character reroll.

A disciple can discover an authored skill/technique personally through experience/requirements and may Khắc Lục into Sect Archive. Historical "learned" and current "active" are distinct.

## 2. Catalogue structure

Nine branches × three Human chapters, with shared school basics and mobility:
- Ch1 Nhập Môn: actives 1–2, passives 1–2.
- Ch2 Chuyên Tu: actives 3–4, passives 3–5.
- Ch3 Tuyệt Học: ultimate and successor eligibility.
- Branch innate is opened through eligible Định Đạo/Diễn Đạo, not a standalone purchased sixth passive.
- Immortal/Divine authored successor chapters are tied to chosen branch A/B and previously learned family; no automated free grant of unlearned active skills.

First complete manual archived unlocks definition permanently across all disciples; duplicates can feed sect research and reconstruction. Individual learning charges per-disciple resources and a timed job.

## 3. Eligibility gates (candidate content thresholds)

| Unlock | Proposed minimum |
|---|---|
| Human standard | suitable path and realm/body requirement, archived Ch1 |
| Human full loadout | macro-realm milestones 1/3/5/7/9; exact skill progression_basis can be tuvi/body/hybrid |
| Immortal I | realm 11 (or authored Body-equivalent), main compatible technique >= Đại Thành, one Human core active Lv7, Human ultimate Lv4, lineage unlock |
| Immortal II / III | realm 15 /19 plus meaningful mastery and authored personal gates |
| Divine I | realm 21, Immortal main technique >= Đại Thành, Immortal ultimate at least II, lineage unlock |
| Divine II / III | realm 25 /29 with authored milestones |
| Rare Divine | realm 25+ and completed authored rare lineage; choose an eligible variant, not a random learning failure |

Human skill Lv1–10 has choice nodes Lv4 and Lv7 (mutually exclusive options each). Personal technique mastery stages Sơ Học, Nhập Môn, Tiểu Thành, Đại Thành, Viên Mãn. Relevant damage/heal/shield/utility actions award mastery once per meaningful event; no per-projectile XP explosion or trivial-farm endless reward.

## 4. Candidate economy numbers (NOT final)

| Action | Contribution | Personal stones | Time |
|---|---:|---:|---|
| Human basic skill | 80 | 500 | 15m |
| Human specialized | 400 | 3,000 | 45m |
| Human ultimate | 1,200 | 10,000 | 90m |
| Human main technique | 800 | 6,000 | 2h |
| Immortal I lineage | 6,000 | 500,000 | 4h |
| Immortal II/III | 10,000 /15,000 | 1m /2m | 6h /8h |
| Divine I lineage | 40,000 | 30m | 10h |
| Divine II/III | 70,000 /100,000 | 60m /100m | 12h /16h |
| Rare Divine | 150,000 | 200m | 24h |

Fragment-to-one-archival-chapter candidate: Human normal24, Human ultimate36, Immortal48, Divine96, rare Divine144. Ancillary materials (Mặc Ngọc, Tiên Linh Ngọc, Thần Văn Ngọc, Ấn, Pháp Tắc Tàn Phiến) are **new candidate item IDs** until approved in the canonical warehouse item registry. Exact prices must be rebalanced for economy V2 and 300-floors power growth; never insert hardcoded costs in live P2.

## 5. Drops, routes and no-roulette progression

- Human entry guaranteed via sect onboarding and authored assignments; no RNG trap.
- Elite may yield research materials, normal/elite/zone fragments.
- Human boss: 1–2 guaranteed preferred fragments, candidate 3% additional complete Human chapter.
- Immortal boss: 1–3 guaranteed Immortal fragments, candidate 1.5% complete.
- Divine boss: 1–3 guaranteed Divine fragments, candidate 0.5% complete; difficult challenge 2–4 and rare-Divine candidate drops.
- First access to Immortal/Divine allows choosing a **baseline** lineage via deterministic realm/sect challenge. Optional rare versions and specialized alternate lineages can remain collectible.
- Boss-specific **preferred** sources: Stone Ape -> Bá Quyền/Kim Cang; Wolf -> Liệp Ảnh/Huyết; Spider -> Độc Châm/Dược; Lightning General -> Linh Tiễn Lôi/Bá Quyền; Mirror Empress -> Băng/Thiên Vũ; Gu Immortal -> Cổ/Dược; Dragon -> Lôi/Thiên Vũ; Blood Demon -> Huyết/Độc; Divine Emperor -> cross-branch law shards.
- Multiple paths must exist for off-specialty fragments and research conversions; no one boss as hard dependency that a build cannot defeat.

Rewards: personal contribution, personal stone portion, cultivation/mastery EXP go directly to eligible disciples by original reward rules; sect-owned manuals and materials go directly to **main Sect Warehouse**. One Boss kill receipt yields one boss roll, not six per party member. No duplicate kill, generation or offline settle grants. Reward tables remain provisional.

## 6. One Active Job and timed research

**Disciple learning** reserves that disciple's sole active job. A working farmer/miner/hunter cannot simultaneously study. Job state: queued -> hold/eligible -> running -> completed/cancelled; percent and ETA visible. Costs journalized by job_id and committed once; on cancel partial progress is lost in line with current One Active Job, but a committed earlier chapter and learned skill remain. **Refund policy of reserved but unused materials must be explicitly authored**; do not silently reimburse or duplicate costs.

**Sect research** is a separate sect-order, not secretly a free concurrent job for the assigned researcher. If an actual disciple is the researcher, it occupies that disciple's One Active Job. One scheduler/warehouse authority for sect and disciple work, not second independent settlement.

Bulk learning policy: player authorizes cohorts/branch/target realm, system schedules only idle or authorized disciples, respecting protected assignments and locks. No auto theft of equipment, no mandatory manual assignment for 1000–3000 disciples. Store only owned definition IDs, mastery and active jobs, not personal full inventories.

## 7. UX information architecture, Android 1280×720 landscape

**Tàng Kinh Các** right panel (map remains primary):
1. Kỹ Phổ: 9 branches, 3 Human chapters, owner/progress/shards, Boss source hints, missing conditions.
2. Công Pháp: known sect techniques, learned/eligible, 1 main+2 aux, conflict alerts and effect differences.
3. Truyền Thừa: visible Human→Immortal→Divine A/B descendants, descendants learned, special rare unlock, branch switch out-of-combat.
4. Nghiên Tu: restoration, sect research progress, assigned scholar, materials and %/ETA.
Disciple panel: current school/branch; 1 basic, 4 active, ultimate, mobility, 5 selectable passives, innate as branch badge; explain why legacy sixth passive is dormant; personal skills/mastery, 1+2 technique slots; available/blocked reasons; study action and task ETA.
Boss UI: HP, phases, named major cast with countdown, safe telegraph, breakbar only when applicable, unique summon objectives; no full-screen VFX hiding navigation.
Features: list filters school/realm/learned/compatible/missing fragments; batch enrollment; locked/manual assignment; tooltip formula shows base ratio, elemental share and actual effective mitigation (no invented flat multiplier).
Notifications: manual archived; chapter restored; eligible trainee; job completed; rare fragment; reason for unusable skill, not permanent spam.
UI should not cause map redraw and actor animation on every 0.25s world simulation tick.

## 8. Required conflict UX

When selecting a new branch, preview: old learned content preserved; incompatible equipped fifth/sixth passives become dormant; their mastery does not reset. When switching back, restore last legal loadout if no other conflict. Warn before paying to switch, never clear a learned record. When missing own root matching, learning is NOT globally blocked unless that exact technique declares requirement; purity influences matching authored effectiveness and cultivation/mastery as already specified.
