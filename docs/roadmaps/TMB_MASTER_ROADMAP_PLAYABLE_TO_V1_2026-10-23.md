# TÔNG MÔN BÁ ĐẠO — MASTER ROADMAP: PLAYABLE → CONTENT BETA → COMPLETE V1.0

**Ngày lập:** 2026-10-23 · **Trạng thái:** MASTER PLAN, DOCS ONLY, không cấp phép CODE / FULL / CI / MERGE.  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao` · **Engine:** Godot `4.7.2.stable.official.ed1daf0bf` · **Android:** landscape `1280×720`.  
**Main tại thời điểm lập:** `29b5fba448b0178cb520a4ada44b375b4b934e31`. Bản này **chưa có PR #24/#25**. Kế hoạch luôn phải rebase logic trên **SHA mới nhất đã kiểm chứng**, không xem các SHA trong file là bất biến.

## 0. Mục tiêu sản phẩm và định nghĩa "hoàn chỉnh"

Tông Môn Bá Đạo là **game quản lý tông môn tu tiên + săn quái tự động liên tục**, không phải nhiều demo rời. Người chơi chỉ huy đệ tử/đội, tuyển người, vận hành công trình, tích luỹ tài nguyên, chế tạo/trang bị, săn bãi và Boss, tăng Tu Vi/Luyện Thể và mở rộng tông môn. Combat V2 giữ toàn quyền kết quả; Source A/JX có thể phục vụ mỹ thuật/trình bày sau khi qua cổng asset, không đưa gameplay Unity/JX cũ thành authority. Ưu tiên trải nghiệm "chơi ngay, ít nhiệm vụ bắt buộc, auto-farm có quyết định chiến thuật".

**Ba mốc bản chơi được:**
- **M1 — PLAYABLE CORE (Windows first):** một ứng dụng P3.2 duy nhất cho tuyển/chọn V2, sản xuất, đi săn, AUTO, loot, Injury/hồi thuốc, **fixed Tu Vi nhận trực tiếp theo kill hợp lệ**, Kho, save/load, số liệu thật. Cho phép dùng placeholder chiến trường trong giai đoạn đầu; KHÔNG gọi đây là bản đẹp hoặc game hoàn chỉnh.
- **M2 — CONTENT BETA:** map/actor/effect Source A thật đã kiểm chứng + UI đủ rõ; 1/3/6 đệ tử cùng săn và có vai trò; Elite/Boss/2-team coop chính sách minh bạch; chu trình loot→trang bị/đan→mạnh lên→bãi khó hơn; AI auto-gear/đổi bãi/nghỉ/chế tạo đủ dùng. Có nội dung trải nghiệm thực trên Windows và Android smoke, chưa mặc định đủ 30×10 tầng.
- **M3 — COMPLETE V1.0 / RELEASE CANDIDATE:** 30 cảnh giới Tu Vi ×10 tầng và 30 Luyện Thể ×10 tầng **được kiểm chứng đường progression/gate** và có content tier khả thi; hệ sản xuất/trang bị/thuốc/kinh tế, AI, Boss, thọ mệnh/quan hệ/trưởng thành phù hợp canonical; quy mô lớn trên thiết bị đích; save/offline/crash; Android touch thực; Windows+Android manual QA; owner duyệt hình ảnh và release. "Đủ nội dung" phải được **owner chốt content matrix + chơi thật** trước khi kết luận; chạy thuật toán 300 tầng không tự động chứng minh có 300 tầng nội dung thú vị.

## 1. ĐIỂM XUẤT PHÁT ĐÃ XÁC MINH — 2026-10-23

| Hạng mục | Trạng thái thực | Bằng chứng/phạm vi |
|---|---|---|
| `main` | HEAD `29b5fba4` (chưa chứa CARE playable) | API GitHub tại lúc lập |
| PR [#24](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/24) | **DRAFT OPEN**, base main, head `4d08984f044bfa29a98070c8d68ee5a155256d3a` | CARE, 28/28 focused PASS ở local `862a6f6`, O6 5/5 PASS; FULL **INCOMPLETE** tại Parse227/240; GUI CARE render/proof PASS; physical Windows/Android PENDING |
| PR [#25](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/25) | **DRAFT OPEN, STACKED ON #24**, remote head `710137c0e3976e685613a86692e5eb128b8d3c62` | Main P3.2 → hunt CARE, 13/13 focused PASS at local `10dd28765a19402cc74a47e5d62749dac5d545f2`, GUI Godot 1280×720 PASS reported. No physical manual/Android/FULL. No Source A or fixed XP/kill. |
| Production | Live Mine/Forest/Field/Alchemy; jobs, Warehouse, O6 verification | Tested older accepted code + current CARE regression; visual/G1 QA distinct |
| Combat V2 | Authoritative math/casts/snapshot, B3 one-hunter continuous CARE & real loot | Proof includes same world, 120 Injury, pill 10/+55HP, 25/+10,000 fixed Tu Vi; not full 6-role/boss |
| EXP từ kill | **OWNER DESIGN LOCKED, NOT CODED** | `docs/b3-xp01-direct-kill-canonical-20261023`, contract `docs/handoffs/B3_XP01_DIRECT_HUNT_TUVI_IMPLEMENTATION_PACKET_2026-10-23.md` |
| Lục Duy V2 | raw model open-points correct; **suspected UI ×100 source defect** | `docs/playable-v1-six-foundations-numeric-truth-20261023` – P3.2 V2 `_score` legacy; radar may normalize, **labels must show raw canonical values** |
| Source A / FE-00 | Style direction Source A selected; batch conversions/pilots partial, release visual owner PENDING | ADR-0003: Godot-native presentation, one simulation owner; do not equate candidate imports to art approval |
| Boss coop | design one HP/one Sect loot, role proof, individual Tu Vi; exact thresholds / Stone 60:40 **OPEN** | B3 V2 boss design docs, not shipped |
| Large map/roster | proposal isometric `192×192`, chunk/pilot and roster `1,000–3,000` are **target/design/performance workload**, not verified shipped scale | MAP25/G1/Character Studio/C4 separate, no mass merge |

**Important:** older [B3 end-to-end audit](../../design/B3_V2_END_TO_END_GAMEPLAY_GAP_AUDIT_AND_PRIORITY_2026-10-22.md) is historical evidence of *what was missing on Oct22*; CARE has since implemented significant P0 functionality. Do NOT read that historical table as today's runtime state. If relative links do not exist on this branch, consult source branch `docs/tmb-agent-skills-20261022`. The updated direct-kill owner law outranks its old "Tinh Nguyên absorption only" warning.

## 2. Lộ trình thực thi theo GÓI NHỎ (không bỏ cổng nghiệm thu)

**Legend:** `[G]` technical/owner gate; `[DOC]` design/preflight; `[CODE]` only after separate owner authorization; `[QA]` run on a real pinned SHA; `[ART]` import with proven provenance. Every code ticket must name exact allowed files and exclude other ongoing writers. Packages grouped here are **proposals, not approvals**.

### P0 — Khóa nền PLAYABLE đang có (Gate G0)
**Phụ thuộc:** none. **Mục tiêu:** không đánh đổi game chơi được để gộp nhánh ồ ạt.

| Ticket | Việc làm nhỏ | Tiêu chí hoàn thành |
|---|---|---|
| P0-01 [QA] | So sánh cây `godot/` đã test với remote head #24/#25, xác nhận parent/stacked diff, bảo vệ game save cũ | ghi SHA, path hashes, diff, rollback; không merge khi chưa đạt gate |
| P0-02 [QA] | Windows một-click launcher trên `E:`, Godot official, isolate saves; click vật lý chọn đệ tử→Đi săn→AUTO→kill→Kho→Return→Save/Load | ảnh/video từ cửa sổ thật, exit+log, no clipping; PENDING cho tới khi thao tác vật lý |
| P0-03 [QA] | FULL bị ngắt: preflight RAM/ổ E:/C:, log heartbeat/exit, một tiến trình Godot; chạy lại cumulative FULL **sau authorization thích hợp** | terminal PASS hoặc fail có trace; Parse 227/240 cũ không coi PASS |
| P0-04 [G] | Review #24 trước, #25 sau theo dependency, chọn merge tuần tự khi luật AGENTS + QA allow; owner xác nhận nợ QA vật lý nếu cho phép defer | không merge sai base hoặc đem Source A/MAP25/C4 vào; snapshots/PR references chính xác |

**Có thể làm ngay:** P0-01/02; P0-03 sau khi kiểm soát máy 8GB. Không cần chờ lập thêm backend.
**G0 PASS** = game Windows khởi động từ P3.2, loop hoạt động theo manual evidence, các test ảnh hưởng và cumulative gate được xử lý minh bạch, rõ owner review. Nếu UAT không xong thì G0 PENDING, nhưng không nhất thiết chặn **mọi** packet code độc lập được cho phép (AGENTS §3).

### P1 — Số liệu gameplay đúng / UX dùng được (Gate G1)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P1-01 [CODE] | V2-only foundation formatter cho `p3_2_landscape_sect.gd`; bảo toàn legacy normalized `p3_1` | raw 2,500 -> nhãn 2.500, không 250.000; raw0 -> 0; test fixed V2/legacy/save |
| P1-02 [CODE/UI] | Lục Duy 6 trục: **số nguyên gốc**, tổng thật, phẩm chất thật, birth vs current; radar riêng normalized 0..100 UI-only nếu chọn vẽ | radar có thể hình tương đối, tuyệt đối không mutate source; `10,000` vs 100 nội bộ |
| P1-03 [UI] | HP/maxHP, Attack/Defense, Tu Vi EXP/tầng + gate, Body, Injury tick, AUTO, kill-receipt, Kho and reward history from canonical snapshot | mỗi nhãn đối chiếu save fixture; không cộng thưởng trong renderer |
| P1-04 [UI] | Mỏ/Linh Lâm/Linh Điền/Luyện Đan: worker/instance, progress/ETA, yield thực, 100%-pending, receipt, Kho; tương phản/click 1280×720 | G1 production visual pilot reused selectively, no fake work clips, no overlap |

**G1 PASS:** UAT đo được mọi số quan trọng, refresh và reopen không nhân 100/đổi owner; legacy regression xanh. Đây là yêu cầu owner trước khi chấp nhận hình ảnh.

### P2 — Tu Vi trực tiếp từ kill (B3-XP-01, Gate G2)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P2-01 [DOC] | Rebase 2026-10-23 owner decision vào canonical sau integration CARE; chốt per-grade/rank/realm XP pilot, không kéo theo sửa Body | EXP nguồn = fixed per valid monster death, optional Tinh Nguyên **material only** |
| P2-02 [CODE] | Một quái thường thật: immutable death_id + per-actor fixed XP receipt vào `DiscipleRealmProgressV2.grant_xp` qua correct owner | mỗi (kill,actor) paid once; no last-hit reward ownership; no duplicate WIN payout |
| P2-03 [QA] | Save/load, repeat kill callback, crash before/after commit, offline actual replay, stage10 overflow/breakthrough, natural tick once | proof exact-once + Tu Vi gate; zero real kill = zero hunt XP |
| P2-04 [DOC/QA] | Benchmark party 1/3/6, Normal/Elite/Boss, realm 1/5/10/20/30 with actual fixture; fit candidate EXP scale to 300 floors | source cost table unchanged; all numbers measured/separately labeled assumption; thresholds owner-approved before broad scale |

**G2 PASS:** fight→Tu Vi real increases and persists once; 30×10 model unaffected; Body does NOT increase from general kill without a separate authorized rule. **No 60/40 boss policy in this packet.** Gate closes M1 together with P0/P1 (visual placeholder allowed).

### P3 — Source A asset/provenance + ONE TRUE pilot environment (Gate G3)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P3-01 [ART/DOC] | Curate manifest for **1 playable disciple, 1 normal monster, 1 Elite, 1 Boss, 1 map, 5 pilot effects** (only if actually available). Verify Source A/JX ID/variant/direction/atlas/frame/pivot/size/hash/license | provenance report per file; do not mislabel NPC as school-playable actor |
| P3-02 [ART] | Spine→Godot (baked atlas/sprites etc) via established converter, idle/walk/attack/hit/die where actually available, proper facing, shadow & scale | Godot 4.7.2 runtime, visual screenshots/video, missing motion reported not fabricated |
| P3-03 [CODE/visual only] | New read-only Combat V2 view adapter: actor positions, events, cast, HP, area markers, drops → renderer | zero change to Combat V2 mechanics/timing/RNG/SaveService |
| P3-04 [UI] | Replace schematic circles with actual Source A actors/map in ONE authored hunt scene, preserving same main-runtime CARE loop | user can recognize characters/monsters/actions; source quality approved by owner |
| P3-05 [QA] | Android 1280×720 early smoke with render memory/import/atlas, and compare Windows | no asset oom/scale wrong; no code rewriting game logic to import art |

**G3 PASS** = *real art pilot* not just static PNG; if provenance missing, block that asset and use honest fallback. **Never mass-merge C4/MAP25/G1/Character Studio branches.**

### P4 — Tông môn map / UI/UX thật, không lag (Gate G4)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P4-01 [DOC] | Reconcile historic G1/MAP25/FE-00 and Source A visual approvals into one Godot-native **presentation** layout/asset map | data-driven alias, mapping, no second building/gameplay authority |
| P4-02 [CODE/UI] | One isometric starter area; scale toward large 192×192 target only when visual culling/profiler supports, viewport 1280×720 | building footprints, entrances, y-sort, roads, actor feet anchors actually align |
| P4-03 [UI] | Camera drag, pan/zoom/touch, free camera default; follow only selected actor if requested; buildings tap and panels work | no hard lock, foreground occlusion handled |
| P4-04 [UI] | Main Hall Lv/production HUD, disciple detail left/middle/right profile, production ETA/stock, legible font, touch targets | reproduce real state for all six stats, no white-on-white/truncated labels |
| P4-05 [QA] | Play Sect→Hunt→Sect across camera & save, older G1 timeline regression, FPS profiling | no animation pretending to mine without source clips; no freeze/stutter budget regression |

### P5 — Đội săn 1 → 3 → 6 người và vai trò (Gate G5)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P5-01 [CODE] | Real team admission 1→3 from existing V2 actor/loadout and One Active Job (no duplicate party world) | party save/load/redeploy, worker cannot be simultaneously mining |
| P5-02 [CODE] | Tank effective damage mitigation/threat, Healer effective missing-HP heal, Support truly applied buff/debuff, DPS real damage, with combat event evidence | AFK/overheal/animation-only do NOT qualify, non-DPS valid contributors do |
| P5-03 [CODE] | Extend to 6 actors, formation/target choice, team AI configurable skills + auto policies | six actors in same world with 1 set of real monster HP, no cloned loot |
| P5-04 [QA] | Solo/trio/six, down one actor, team return/resupply/redeploy, offline and post-reload; 6-actor HUD | no extra receipts, deterministic replay & measurable engagement performance |

**G5 PASS:** formation + useful roles + receipts functional, no last-hit monopoly, role thresholds measured; numeric anti-exploit thresholds require evidence/owner approval.

### P6 — Vùng săn, Tinh Anh, Boss & phối hợp nhiều đội (Gate G6)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P6-01 [CONTENT/CODE] | Real region/monster grade ladder: Normal, Elite random spawn, Boss and level/realm matching; caps based on actual authored source | exact spawn/generation provenance, aggro/leash/reset, no phantom hourly rewards |
| P6-02 [CODE] | Multi-team Boss: **one HP and one Sect loot pool**, causal DPS/Tank/Healer/Support participation; personal fixed Tu Vi once | no last-hit XP, no duplicate Boss/team ownership |
| P6-03 [DOC→CODE] | Threshold/withdrawal/late join, down and cross-team assistance; Spirit Stone sect/personal split remains **OPEN** until explicit owner lock; personal share equal *among eligible* | real combat fixtures justify thresholds; not assume 60/40 |
| P6-04 [CODE] | Boss loot tables, rare gear/material rolls, admin/content tool mapping monster→drops, reward receipt, no fake 100% loot | deterministic seed, unique/stack/warehouse rules, special drops correctly authored |
| P6-05 [QA] | 1/2/6 actor; 2-team shared Boss; join/leech/withdraw/crash/restart; rare loot ownership | battle and equipment/player settlement match exactly one Boss death |

### P7 — Nhân vật, chiến đấu, kỹ năng thực (Gate G7)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P7-01 [DOC/CONTENT] | Skill registry: each school/role/weapon links source ID, Combat V2 skill mechanics, cast/VFX/source asset. Start with the **5 previously defined JX pilot effects** and expand only verified content | no NPC animation silently sold as playable school variant |
| P7-02 [CODE] | Weapon/basic/skill animation triggers from real cast/hit state, target projectile/impact where available | visually faithful to Combat V2 event, not fabricated damage/VFX |
| P7-03 [CODE] | Combat skill setting (auto manual whitelist/priority/cooldown), target rule/CC/area preview | cast permission/cooldown/target deterministic and saved |
| P7-04 [QA] | One school/specialization per release pilot → broaden content; 1/3/6 actor readable on map | evidence for visual/hit sync and Android render; owner approves style |

### P8 — Kinh tế, thuốc, rèn luyện, trang bị V2 (Gate G8)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P8-01 [CODE] | Full first meaningful loot→recipe chain: mine/field/forest/monster ingredients→forge/alchemy→use | receipt per producer/consumer, no magic resources |
| P8-02 [CONTENT/CODE] | Medicine tiers for Tu Vi/Body/Breakthrough/HP and authored drops; retain pilot Tụ Khí25/+10000, Hồi Xuân10/+55, shared daily 1,000,000 pill satiety | appropriate materials/rank and no double award from Tinh Nguyên |
| P8-03 [CODE] | Equipment V2 (10 ordinary slots + 3 Phù + 2 Pháp Bảo, separate 4 consumable belt positions), quality/sets/enchant/upgrade, all equipment Sect-owned | no fake 15-slot UI before backend, rare materials & sink; strict permission/migration |
| P8-04 [CODE] | Personal profession advancement, economy/services/market/wages, auto-allocation equipment; explicit craft, repair & resource sinks | real price/resource traces, no impossible inflation |
| P8-05 [QA] | End-to-end craft→equip→stat impact→hunt→new drop→upgrade + save/offline + stress | no dupes, balances per chapter/tier, Body independent |

### P9 — AI quản lý tự động / offline / game loop dài (Gate G9)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P9-01 [CODE] | Autonomous choice of farm area by missing materials, difficulty/risk, recipe shortage, team health and gear | explainable AI decisions with user override |
| P9-02 [CODE] | Automatic refill/heal/rest/replace injured roles, equipment assign policy, crafting queue, reserve workers | One Active Job, Injury120 and sector jobs never conflict |
| P9-03 [CODE] | Deterministic bounded offline replay of real combat/jobs/loot, canonical day tick/1440, satiety and receipts; clock once | online/offline equivalent within documented boundary; no invented loot/hour |
| P9-04 [QA] | Many actors offline with huge backlog; interruption between debit/reward/save, old save migration, backup restore | exactly-once, bounded CPU/memory and no dropped real valid receipts |
| P9-05 [UI] | Lightweight player goals (no quest spam), actionable shortage panel, contribution/loot/XP history & resource forecasts | no fake metrics, no forced story-grind |

### P10 — Tiến trình 30×10, nhiều nghề, thọ mệnh & nội dung dài hạn (Gate G10)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P10-01 [DOC/CONTENT] | Full content tier matrix for **30 Tu Vi realms ×10 floors, separate 30 Body×10**: named break gates, compatible item/monster/region/work unlocks, verified existing cost sums | use canonical costs (Tu Vi entire track 48,130,600,000; separate Body), no fabricated 30-map requirement |
| P10-02 [CODE] | Author and validate progression/breakthrough gates, protections and support mats at representative then all 30 realms | floor10 no auto breakthrough, failure logic/gates preserve earned progress |
| P10-03 [CONTENT] | Real resource/monster/recipes/rare treasure tiers sufficient across progression; extra zones through authored assets and reuse with care | player has meaningful loop for each stage group, no 300 empty levels |
| P10-04 [CODE] | Age→life limit cadence/ghost state under `docs/DISCIPLE_LIFESPAN_CANON.md`, Thọ Đan/recovery receipts, relationships/loyalty/mentorship and inheritance | HP0 injury **not** death-age, no permanent disciple deletion merely from age cap |
| P10-05 [QA] | Automatic full 300-stage traversal/economic feasibility, chapter playtests early/mid/late, 30-realm gate and both tracks | P10 simulation PASS not equal human content FUN QA; no softlocks, adequate resources |

### P11 — Quy mô/hiệu năng/độ ổn định (Gate G11)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P11-01 [QA] | Profile 50/100/500→1000→3000 disciples (staged targets), one vs multiple teams and zoomed large map | record CPU/frame time/RAM/load/save times, don't claim capacity from synthetic only |
| P11-02 [CODE] | Batching/culling/dirty-UI/scene pooling/pathing, atlas load controls; avoid per-frame 3000 labels/save churn | measured before-after perf, no gameplay/source behavior change |
| P11-03 [QA] | 8GB Windows low-memory diagnostics plus target Android RAM/thermal/touch renderer trials | explicit minimum supported tier based on real measurement, not an invented 60FPS blanket promise |
| P11-04 [QA] | Legacy saves, interrupted write and .tmp/.bak recovery, app kill while Boss kill/loot/medication/upgrade, long offline | no loss/double pay, fail-closed on bad saves, trace repeatable |

### P12 — Windows + Android production/release polish (Gate G12)
| Ticket | Việc nhỏ | Tiêu chí |
|---|---|---|
| P12-01 [CODE/UI] | Navigation, settings sound/resolution, graphics quality, readable localized Vietnamese fonts and controls, helpful onboarding | complete full first session no developer button needed |
| P12-02 [UI/ART] | Asset/style final consistency Source A (all current used scenes/actors/spells), SFX/music, UI gradients, effects/pivot and occlusion QA | no missing/unattributed assets, owner visual ACCEPTED |
| P12-03 [BUILD/QA] | Windows distributable/launcher and Android signed test APK; touch landscape, app background/resume, device save sandbox | real device session with FPS/memory + video |
| P12-04 [QA] | Sequential focused + authorized cumulative FULL with terminal PASS, real end-to-end 1/3/6 roles, 300-gate simulated suites, Economy/UI/Save risk; no conflict regressions | exact SHA log+marker+exit, non-PASS debt explicit |
| P12-05 [G] | Release candidate review: user gamepad/touch + owner screen QA, first session, long session, early/mid/end progression, credits/rights if distributing | bug severity release gate, backup/rollback, version+changelog; **V1.0 DONE only after owner accepts** |

### P13 — Sau V1.0 (KHÔNG tự động là release blocker)
Optional DLC/update backlog: higher-count maps, seasonal/world events, deep sect factions, companion/relationship storytelling, advanced 30-realm elite classes, large raids, procedural treasures, guild-like sect competition, more Source A/JX skill libraries. THESE ARE EXPANSIONS, not substitutes for shipping stable V1.0.

## 3. Dependency & sequencing

```text
Current main / PR24 CARE [draft] ──> PR25 P3.2 integration [draft]
                 |                           |
                 +-- P0 Windows physical QA, save/merge-gate/FULL-triage
                                             |
                                 P1 exact numbers / UI gate
                                             |
                                 P2 direct fixed hunt Tu Vi  = M1
                                             |
                  +--------------------------+--------------------------+
                  |                          |                          |
               P3 art pilot               P5 teams/roles           P8 loot/craft pilot
                  |                          |                          |
               P4 true map               P6 Boss coop <---------+     |
                  |                          |                    |     |
               P7 skill VFX --------------->+--------------------+-----+
                                             |
                                        P9 AI/offline  = M2
                                             |
                                        P10 full tier ladder
                                             |
                              P11 scale/perf / P12 Android & release
                                             |
                                       M3 COMPLETE V1.0
```

- **P0 first:** finish manual Windows loop, confirm stacked Git trees, don't rewrite CARE.
- **One integration owner** for `p3_2_landscape_sect.gd`, `SimulationState/SectState`, `SaveService`, scheduler and Combat V2. Parallel [DOC]/asset preflight is fine; mutually exclusive CODE writers on overlapping files.
- P3 asset provenance can advance in parallel with P2 code **without merging into P2**.
- P11 early Android/performance smoke should be checked from P3 onward; do not defer all performance discovery to the end.
- P8 may deliver the first craft loop before P6 full Boss, but final rarity/material matrix depends on Boss/content authoring. Never code 30-tier items without grounded drop tables/recipes.
- Source A/JX production assets are candidate art; don't assume a copyright permission for **public distribution** from personal-use approval. Release assets need rights verification.
- Existing G1/MAP25/C4/Character Studio branches are **references and cherry-pick candidates only**; only tested, reviewed pieces may be reused; no mass merge.

## 4. Mandatory per-ticket workflow

1. **Owner direction:** one exact ticket ID e.g. `P1-01`, observable goal, latest parent SHA, explicit `CODE` authorization (not implied by roadmap), allowed files + forbidden systems, rollback.
2. **Source audit:** compare owner decision vs actual code and canonical docs. Use skills `tmb-project-director` + one specialized skill: `tmb-godot-evidence`, `tmb-balance-lab`, `tmb-asset-gate`, `tmb-autoplay-ai`, or `tmb-ui-playtest`.
3. **One small vertical slice:** reproduce failure first; implement smallest controlled patch; keep 1 runtime, clock, Warehouse, job/save/reward owner. Preserve old save and historic tests.
4. **Focused QA at real SHA:** official Godot 4.7.2, clean isolated data, source hash, PASS marker+exit0; cumulative relevant tests and authorized FULL according to release/governance gate. 8GB host: no parallel heavy imports/CI; monitor memory.
5. **Player acceptance:** actual Windows 1280×720 input/screenshots/video; target Android physical touch separately; owner reviews if UX/style. Synthetic sim tick ≠ real elapsed hours.
6. **Commit/handoff:** update `CURRENT_CHECKPOINT.md`/`NEXT_CHAT_HANDOFF.md` on the owning code PR with SHA/evidence/debt/next ticket (avoid duplicate simultaneous writes). Keep draft until required gates and authorization.
7. **No false PASS:** do not label design=code, UI proof=Windows manual, 13 focused=FULL, PC renderer=Android, simulated 300-floor model=content enjoyable, imported PNG=actor animation.

**Hard locked laws to preserve:** Combat V2 authority, two distinct 30×10 tracks, fixed XP current realm/gate, direct hunt XP once per valid credited contributor when P2 implements it, Tinh Nguyên only optional rare material by default, individual role evidence DPS/Tank/Healer/Support, one Boss HP+Sect loot, One Active Job, Injury 120 sim ticks, pill satiety 1,000,000 / disciple / canonical day, sect-owned equipment, one Warehouse/clock/save/receipt barrier, Lục Duy V2 raw points 0→thousands with visible true numbers (radar is pure normalized drawing), preserve save exactly-once.

## 5. Ready-to-use release gates (simple owner checklist)

| Gate | What player should see | Technical evidence needed | Not acceptable |
|---|---|---|---|
| G0 | Real Windows P3.2 hunt playthrough, same character/world/loot/save | live input/GUI, 13 focused + CARE 28, cumulative status | auto-click proof passed off as physical testing |
| G1 | Six real stats correct; production/HUD UI truthful | raw vs display vs save trace, legacy focused | V2 *100, chart stat=real stat |
| G2 / M1 | Every true monster kill rewards legal personal fixed Tu Vi once | kill+actor receipt, gate, retry/offline tests | legacy WIN duplicate or Tinh Nguyên double-XP |
| G3–G4 | Real Source A pilot animation & sect/hunt camera/controls | attribution/hash/atlas/visual 1280×720 | still placeholder circles or imported wrong NPC |
| G5–G6 | 1/3/6 roleful hunt, Elite/Boss & coop | causal support/heal/tank, one Boss HP/loot, withdrawal tests | 6 clones/last-hit monopoly |
| G7–G9 / M2 | Real skills/equipment/medicine/AI loop, resource progression & offline replay | receipt+save/cost+target tests, player beta | fake gear/recipes, infinite free loot |
| G10 | 30×10+30×10 stage ladder coherent across world tiers, lifespan & long-run economy | automated 300-stage + mid/end manual tests | 300 mathematically modeled empty stages |
| G11 | Scale and real device performance backed by measurements | 100→3000 profiling, save/load/crash tests | synthetic FPS/zero memory data |
| G12 / M3 | Polished complete app Windows + Android | full regression terminal PASS, device touch, UX owner signoff | "complete" while Android/visual/manual PENDING |

## 6. Immediate next 3 tickets — do not launch all three code writers simultaneously

**1. RECOMMENDED: P0-02 / PLAYABLE WINDOWS MANUAL QA**. Test PR #25 stacked on #24 using official Godot 4.7.2, Windows real mouse, isolate save and 1280×720, screenshot/video/log. If owner cannot access PC, Codex can produce launcher and automated GUI proof now but may NOT label physical manual PASS.

**2. P1-01 / FOUNDATION REAL-NUMBER FIX.** Once PR #25 code owner is available and user approves narrow CODE, replace only V2 stat formatter `_score` path; legacy remains normalized; add assertion test raw 2500→2.500 and zero→0. Could be stacked PR #26, but no automatic PR number or merge.

**3. P2-01 / B3-XP-01 PRE-FLIGHT + XP COEFFICIENT PROPOSAL.** Read design packet and post-CARE code, qualify actual per-kill points/injury/downtime and create allowed paths; code requires further explicit permission. Boss contribution thresholds/stone split separate.

### Copy-ready FIRST task prompt
```text
TÔNG MÔN BÁ ĐẠO — P0-02 PLAYABLE WINDOWS MANUAL QA, READ-ONLY.
Trên nhánh PR #25 integration/b3-playable-care-v1-20261023 stacked sau PR #24, đọc AGENTS.md, master roadmap docs/roadmaps/TMB_MASTER_ROADMAP_PLAYABLE_TO_V1_2026-10-23.md ở nhánh docs/tmb-master-completion-roadmap-20261023, và các report CARE/Post-O6. Không merge, không sửa gameplay/tests/Source A và không chạy FULL/CI. Chuẩn bị/kiểm tra launcher Windows E: Godot4.7.2 1280x720 save cách ly. Nếu có khả năng thao tác chuột THẬT trên Windows, chạy từ màn P3.2: chọn V2→Đi săn→AUTO→HP/Injury/loot→Về tông môn→Save/Load→săn tiếp; đo hiệu năng, chụp ảnh/quay màn hình, log theo SHA và phân biệt manual vs GUI automation. Nếu không thể thao tác vật lý, không tự gắn PASS: ghi PENDING OWNER; vẫn có thể chuẩn bị launcher và danh sách kiểm tra. Android/Source A/EXP kill remain pending. Báo cáo bước kế tiếp P1-01 (V2 lục duy formatter).
```

## 7. Source register

- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md` on `main`; respect chronology and the current PR provenance.
- [B3 end-to-end gap audit](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/tmb-agent-skills-20261022/docs/design/B3_V2_END_TO_END_GAMEPLAY_GAP_AUDIT_AND_PRIORITY_2026-10-22.md), historical as of Oct22.
- [B3-XP01 direct kill design](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/b3-xp01-direct-kill-canonical-20261023/docs/handoffs/B3_XP01_DIRECT_HUNT_TUVI_IMPLEMENTATION_PACKET_2026-10-23.md).
- [Lục Duy numeric truth QA](https://github.com/vuanhtuan161094-byte/TongMonBaDao/blob/docs/playable-v1-six-foundations-numeric-truth-20261023/docs/handoffs/PLAYABLE_V1_LUC_DUY_NUMERIC_TRUTH_RADAR_QA_2026-10-23.md).
- `docs/decisions/0003-fe00-godot-native-data-driven-frontend.md` and asset registries/provenance.
- [PR #24 CARE](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/24); [PR #25 integrated PLAYABLE](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/25).
- Owner-uploaded official `b3_main_hunt_integration_test.stdout.log` and `RESULTS.json` for local tested `10dd28765`, 13/13 focused PASS. Report doesn't prove native physical Windows/manual or Android.
