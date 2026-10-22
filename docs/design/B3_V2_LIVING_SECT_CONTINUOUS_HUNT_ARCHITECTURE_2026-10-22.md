# TÔNG MÔN BÁ ĐẠO — B3 V2: TÔNG MÔN SỐNG / SĂN LIÊN TỤC / PHÁT TRIỂN ĐỆ TỬ

**Ngày:** 2026-10-22 (Asia/Ho_Chi_Minh)  
**Trạng thái:** DESIGN PROPOSAL — FOR OWNER REVIEW; KHÔNG PHẢI LUẬT GAMEPLAY MỚI ĐÃ KHÓA, KHÔNG PHẢI CODE PACKET  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`  
**Code audit:** GitHub `main @ 461caca1171462e0da092f21108c5c1733157ad9`  
**Nguồn handoff:** `docs/tmb-status-20261021-v5-sa-lib @ 447112287da6b2aaa0e7c32bf53a3e3d70fa59d0`  
**Nhánh thiết kế độc lập:** `docs/b3-v2-architecture-redesign-20261022`  
**Scope:** audit + kiến trúc/contract/roadmap/QA có điều kiện. Không sửa gameplay/test/save, không CI, không merge; không chạm worktree/agent Map, Character Studio, Source A SA-LIB, B2.4, V5.1.

> **OWNER OVERRIDE / ERRATUM — 2026-10-22, áp dụng ngay cho B3 V2:** Lệnh người dùng từ **2026-09-30** và **2026-10-21** xác nhận PvE **Evil Hunter Tycoon / Võ Lâm continuous in-place**: **không có trận 90 giây, không nối trận, không reset actor sau wave**. Mỗi quái có spawn slot và chết/rơi đồ/hồi sinh **độc lập**, ngay khi nhiều đệ tử tiếp tục combat trên **cùng map đang sống**. Tinh Anh/Boss xuất hiện theo cấu hình, skill auto theo cooldown; map farm **phẳng, chỉ hoa/cỏ trang trí, không collision vật cản hay pathfinding**. 90s vẫn đang nằm trong code `MapBattleV2` legacy, là **technical debt cần xử lý bằng CODE packet khác**, không phải luật được duyệt. Combat V2 vẫn là authority damage/stats/skills/RNG; đời sống thế giới/combat scheduling cần tái cấu trúc để *dùng* chính authority đó. **Mọi đoạn trước đây khuyên nối các trận hữu hạn đã bị hủy bỏ.**

> **Concurrent work owner update:** Người dùng xác nhận đang có **Map** và **Character Studio nhân vật** thực hiện riêng, bên cạnh **Source A library**; tính là **OWNER-REPORTED ACTIVE**, chưa thể xác thực trạng thái worktree/HEAD từ GitHub. Không chuyển chúng thành HOLD dựa vào handoff cũ, không tự dừng/ghi đè, không chạy nhiệm vụ trùng chức năng. Combat V5.1 owner visual acceptance vẫn chưa có bằng chứng đóng; B2.4 standalone sandbox đã bàn giao ZIP, nhưng chưa phải B3 production.

> **B3 V2 DEEP-DIVE CONTRACT (2026-10-22):** Tài liệu chi tiết của Persistent PvE World tại [B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md](B3_V2_PERSISTENT_PVE_WORLD_RUNTIME_CONTRACT_2026-10-22.md). Chứa world/monster/team/snapshot states, API đề xuất, combat event ordering, Boss/multi-team, receipt/save exactly-once, clock online/offline, test edge cases và 8 packet chỉ ở mức đề xuất. **Tài liệu này KHÔNG cấp phép CODE hoặc thay đổi Map/Character Studio/Source A.**

> **TEAM AI DEEP DIVE 2026-10-22:** [B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md](B3_V2_TEAM_AI_TARGETING_AGGRO_RECOVERY_CONTRACT_2026-10-22.md) — lựa chọn mục tiêu/aggro/đơn-đa đội/Boss, khoảng cách và skill theo Combat V2, retreat/recovery/auto-resume không cướp One Active Job; state transitions, đề xuất API và test; **DESIGN-ONLY, NOT CODE AUTHORIZATION**.

> **NEW EVIDENCE AUDIT (FOUR ZIP, 2026-10-22):** [Review checkpoint](../handoffs/2026-10-22/TMB_FOUR_REVIEW_PACKETS_TRIAGE_AND_INTEGRATION_PLAN_2026-10-22.md) verified user-supplied B2.4 source ZIP. Contrary to legacy `main` finite-only runtime, local B2.3/B2.4 snapshot already includes an **opt-in continuous_mode** in `MapBattleV2` with no 90-second/empty-monster termination in that mode, individual spawn/removal, stable death/receipt IDs, snapshot v2 supporting v1 reader, and an isolated 6-actor sandbox. **It is NOT pushed/merged/production**; still needs live World/Team AI, authoritative per-kill source and canonical SaveService. Future CODE plans must **reuse/audit this existing kernel patch instead of implementing a duplicate combat engine**. No CODE is authorized by this note.

> **MONSTER AI / SPAWN / BOSS DEEP DIVE (2026-10-22):** [B3_V2_MONSTER_AI_SPAWN_ELITE_BOSS_WORLD_CONTRACT_2026-10-22.md](B3_V2_MONSTER_AI_SPAWN_ELITE_BOSS_WORLD_CONTRACT_2026-10-22.md). Đã đối chiếu mã B2.4 ZIP: opt-in continuous đang có, nhưng tất cả đệ tử chết vẫn terminal DEFEAT; AI nearest target thiếu phạm vi aggro/leash; SpawnDirector có đồng hồ riêng; death scanner dựa event buffer. Bản này chỉ khóa nhận diện GAP, đề xuất FSM/contract/QA và không cấp quyền CODE.


## A. Kết luận thiết kế

**B3 không phải “3 vùng farm để hoàn thành 5 công thức”**. Đó chỉ là fixture integration đầu tiên. B3 thực sự là vòng sinh hoạt mở của một tông môn:

```text
Chưởng Môn định chính sách / xếp đội / phát triển hạ tầng
       ↓
Đệ tử tự chuẩn bị — đi săn — tìm quái — Combat V2 — nghỉ / hồi phục — săn tiếp
       ├── Tu Vi, kỹ năng, tinh thông, cống hiến, Linh Thạch, lịch sử cá nhân
       ├── Vật liệu yêu thú, nguyên liệu đặc thù, đồ rơi trực tiếp, Boss/đồ bộ
       └── Rủi ro: tiêu hao, thời gian di chuyển, thương thế, thất bại, cạnh tranh nguồn
       ↓
Một Kho tông môn + registry vật phẩm unique, chính sách phân bổ
       ├── Sản xuất hậu phương / luyện đan / điều trị / vật tư tiêu hao
       ├── Luyện khí / nâng cấp / chọn bộ / cấp đồ tự động
       └── Đệ tử mạnh hơn → mở vùng săn cao hơn, ưu tiên khác → lặp
```

**Vòng lặp KHÔNG dừng mặc định** khi đủ tài nguyên một món đồ. `FarmOrder` là một mục tiêu có thể đặt chồng lên **duty săn thường trực**, không phải trung tâm toàn bộ AI. Chưởng Môn điều hành bằng chính sách cấp tông môn, đội, vùng và ngoại lệ; đệ tử tự vận hành đúng trong phạm vi được phép.

## B. Ranh giới authority — đã khóa / đã code / mới đề xuất

### B1. Đã khóa ở spec hoặc quyết định owner — KHÔNG đổi trong B3

| Authority | Quy tắc phải giữ |
|---|---|
| Gameplay combat | **Combat V2** quyết định hit, damage, cast/cooldown, hiệu ứng, skill, trạng thái, RNG và tử trận của quái. Cảm giác JX1 real-time/VFX là mục tiêu **presentation**, không phải chuyển combat law sang JX1. |
| Tông môn sống | Target **1.000–3.000 đệ tử**, đa số background; quản lý qua nhóm/đội/chính sách, không thao tác từng người. Mục tiêu phân công săn/hậu phương xấp xỉ **70/30** là hướng cân bằng mềm, KHÔNG ép quota. |
| Đội & tác vụ | Team tối đa **6** theo `OrganizationSystem`; thường 5 người là định hướng thiết kế, solo có điều kiện. **One Active Job**, cấm AI tự hủy công việc sản xuất/tu luyện/plot đang được bảo vệ. |
| Trọng thương hiện hành | Production **Injury 0/1**, hồi sau **120 scheduler ticks**; không áp dụng mô hình 0–100 trong spec cũ hoặc injury 0–3 study khi chưa có packet riêng. Không xóa vĩnh viễn đệ tử vì thua săn. |
| Thời gian / mô phỏng | Một clock simulation/scheduler chuẩn; 60 wall seconds = 1 simulation minute trong `SimulationRuntimeClockV2` hiện tại. Không tạo bộ đếm thời gian thứ hai để tạo loot. |
| Kho & sở hữu | **Một Kho tông môn** cho resource stack; không Loot Warehouse, không team loot bag tồn tại lâu; gear unique 100% sở hữu tông môn, đệ tử chỉ được cấp quyền dùng; tôn trọng lock/reserve, không gameplay storage cap. |
| Đệ tử & thưởng | Hai nhánh 30 Tu Vi ×10 tầng / 30 Luyện Thể ×10 tầng; săn tương xứng cảnh giới là con đường tăng Tu Vi mạnh (thiết kế khoảng 10–20× lao động thường), kèm skill mastery/Contribution/Linh Thạch tùy source luật đã duyệt. Tránh phá luật progression cũ trước migration. |
| Trang bị đích | **10 ordinary slots, 12 phẩm, 24 lineage set (18 combat/6 nghề), mốc 2/3/4**, 6 vị trí set hợp lệ; 3+3 kích hoạt cả hai; 3 Phù + 2 Pháp Bảo **riêng**; độ phẩm != item realm rank 1..30. Không tự phát minh Chân Văn Cộng Hưởng. |
| QoL/UX | Android landscape 1280×720; map/camera và chibi Source A là presentation; người chơi có thể pan/zoom/chọn nhân vật, không khóa toàn bộ camera vào một người; chân/bóng thật định vị sprite. **Map săn phẳng, chỉ nền/hoa cỏ trang trí; không vật cản/pathfinding/collision địa hình** theo quyết định owner 21/10. |
| RNG & durability | Determinism, save/load chống double award, idempotent, migration legacy. AI, UI, asset converter không phải kill/loot authority. |

**Lưu ý về spec cũ:** `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md` còn mô tả injury dạng thang 0–100; luật runtime đã được khóa mới hơn theo GP-02C1 là 0/1/120. Không âm thầm tái kích hoạt mô tả cũ.

### B2. Code đã thấy trực tiếp trên `main` — KHÔNG thổi phồng hoàn thành

| Code | Có thật | Gap B3 |
|---|---|---|
| `map_battle_v2.gd` | Code legacy hiện bước **0,25 giây**, `MAX_SECONDS=90`, **tự WIN khi hết quái**, 30 disciple/40 monster trong một `MapBattleV2`; presentation flag không tham gia tính toán. | **90s/WIN-on-empty là lỗi khớp thiết kế đích, không phải luật B3**. World-combat mới phải bước liên tục **không timeout 90s, không wave clear, không re-setup/reset**; giữ kernel formula/RNG/skills của Combat V2 và backward compatibility save/mode legacy. |
| `hunting_map_v2.gd` | 3 vùng V2 pilot, 5 mức lựa chọn/vùng, reward **theo trận thắng rồi claim**, rare được roll theo encounter; bảo đảm `linh_tuy` theo **4 thắng encounter** lịch sử. | Không phải loot per-monster production; không biến 4 win thành 4 kill. |
| `hunting_pve_run_v2.gd` | Begin/advance/finish/claim, đặt reservation cho đệ tử, terminal HP/Injury, live snapshot. | Chưa nối continuous world/legacy scheduler; claim và terminal receipt khác nguồn. |
| `simulation_scheduler.gd` | Phút mô phỏng, nghề/production/đệ tử; legacy path HUNT→TRAVEL→COMBAT→LOOT và `CombatSystem.resolve_encounter`. | Có **legacy route cá nhân**; không thể đồng thời trả B2.4 per-kill cho cùng một kill. |
| `decision_system.gd`, `goal_system.gd` | AI cá nhân có HUNT/REST/HEAL..., choose region và preference; `choose_region/evaluate` có mutation `last_decision`. | Reuse nội suy/risk nếu phù hợp, nhưng không gọi AI mutation trong GUI preview và không dùng như reward authority. |
| `organization_system.gd`, `workforce_system.gd` | Team tối đa 6; role, explicit `HUNT_REGION`, One Active Job thực tế liên hệ nhiều timers. | Cần **admission preflight thuần**, tránh `issue_command` gây hủy/cướp việc khi dùng làm dự báo. |
| `warehouse_system.gd` | Canonical stack, `available_quantity` (reserve/lock), `MAX_SAFE_STACK`, consumption preflight. | Ledger kill cần commit tất cả reward channels với Warehouse/unique/progression cùng state, không có kho song song. |
| `equipment_system.gd` | **Pilot cũ 3 slot, 3 quality, 5 recipes**; craft hiện synchronous, unique item registry. | Chưa có 10/12/24, chưa có lệnh forge có thời gian thật theo V2; không gắn fake ETA. |
| `save_service.gd` | Current wire `v2` với staging `.tmp`, verify, backup. | Schema thế giới, auto-duty và receipt mới chưa tích hợp production; cần versioned migration packet. |

**Handoff mới hơn:** B2.3 đã có ZIP với 7 focused PASS; B2.4 ZIP integrity verified (85 entries, 84 hash) và có standalone opt-in săn thử 6 synthetic actors, Warehouse clone, seeded test-only `linh_moc`. **Production per-kill table vẫn trống, Editor manual pending, live SaveService và integration pending.** Các worktree địa phương không xem được từ GitHub. **Mới nhất từ owner:** Map và Character Studio đang có các luồng thực hiện song song; Source A library vẫn là luồng chuyển đổi riêng. Handoff ghi Character Studio HOLD là **mốc cũ**, không được dùng để bác thông báo ACTIVE mới; V5.1 visual vẫn chưa owner PASS.

## C. Nguyên tắc thiết kế sản phẩm B3 V2

1. **Thế giới PvE + Combat V2 continuous in-place, không encounter/reset/90s.** Một bản đồ logic hoạt động liên tục, quái chết và hồi từng cá thể trong lúc đệ tử vẫn truy đuổi/đánh/skill. Combat V2 giữ công thức authority; orchestration/lifecycle được tách để mở world-step.
2. **Duty thường trực trước, FarmOrder sau.** Người chơi có thể giao đội “săn liên tục ở vùng này, đổi khi nguy hiểm, nghỉ nếu HP thấp”; tùy chọn thêm ưu tiên vật liệu/đồ bộ/Boss/Tu Vi. Đội không vô lý trở về nhà ngay khi kiếm đủ 3 nguyên liệu nếu còn đủ an toàn để săn tiếp.
3. **Combat V2 là kernel duy nhất.** World coordinator quản lý di chuyển, chọn encounter, hợp đồng spawn/lease/reward, không tạo `damage_v3`/skill RNG riêng. V5 render những gì kernel xảy ra.
4. **Mỗi quái một nguồn chết và reward identity duy nhất.** Dùng `zone_instance/slot/generation`, một receipt/kill, kiểm soát cạnh tranh giữa đội; preview/UI không bao giờ cấp loot.
5. **Một thế giới logic, nhiều cách trình bày.** Visible/offscreen có cùng state, RNG và kết quả với cùng lệnh/thời gian; trình diễn chỉ là projection. Đã có game logic thì có thể dùng Source A pack được QA sau, không chờ chuyển đổi 6.578 rig để chứng minh backend.
6. **Một economy, nhiều nguồn cung.** Mỏ/Linh Lâm/Linh Điền sản xuất ổn định; săn cấp nguyên liệu yêu thú, phần thưởng cá nhân, đặc sản vùng, gear trực tiếp; craft là consumer, không chi phối mọi quyết định.
7. **Càng đông càng giảm micro.** Team policy > hall policy > direct disciple commands; scheduler theo sự kiện/nhóm; không AI per-frame cho 1.000–3.000 người.

## D. Đề xuất kiến trúc module (logical, CHƯA CÓ FILE RUNTIME)

```text
Sect Master / Policy UI → validated SectDirective
           ↓
B3PolicyPlanner (pure decision/proposal, NO mutation/reward)
           ↓
B3TeamDutyOrchestrator (single authority for team hunting admission)
           ├── OrganizationSystem + WorkforceSystem/OneActiveJob preflight
           ├── B3TravelSupplyRecovery (canonical time, injury/HP/items)
           └── B3ZoneRuntime (instance + spawn slots + ownership leases)
                        ↓
                  B3CombatV2WorldStep (continuous actors & casts)
                       └── Reuse Combat V2 formulas/skills/targeting/RNG, NOT legacy battle lifecycle
                        ↓       authoritative lethal transition/outcome
                  B3KillAttribution → B3RewardResolver
                        ↓
                  B3RewardLedger (one receipt, deterministic seeds)
                        ↓
     canonical SectState / SimulationState (single SaveService snapshot)
      ├── WarehouseSystem, Sect spirit stones
      ├── Sect-owned unique equipment registry
      ├── per-disciple Tu Vi, skill mastery, Contribution and personal stones
      └── HP/Injury/Team availability/terminal settlement
                        ↓
                Read-only ViewModel → Map V5 / management UI
```

**Đây là trách nhiệm logic**, không cho phép tạo một loạt hệ thống độc lập cùng can thiệp `SimulationScheduler`, `SectState`, `SaveService` trước khi có 1 integration owner. Mỗi module có thể ban đầu là adapter dùng API có sẵn, KHÔNG clone subsystem.

### D1. Persistent design model đề xuất

- `SectDirective`: policy vùng được phép, risk/retreat, supply, auto-resume, ưu tiên progression/loot/Boss, điều kiện dừng khi owner chỉ thị; `revision`.
- `TeamDuty`: team ID canonical, mode `CONTINUOUS_HUNT | TARGET_MATERIAL | TARGET_GEAR | PROGRESSION | BOSS_SEARCH | RETURN/HOLD`, ưu tiên cấp nhóm, route, entitlement; không sở hữu danh sách disciple copy.
- `ZoneInstance`: zone/content version, unlock, biome, world/grid coordinates, clustered source pool, monster instance slots, respawn eligibility, contested boss lease.
- `MonsterSlot`: stable slot ID, species + tier + authored content source, `generation`, `alive/dead`, respawn deadline theo canonical tick/offset, one active lease; không render sprite nghĩa là chết.
- `HuntDuty`: active team/region/world ID, patrol/engage/retreat state, world time cursor, persistent actor HP/cooldowns/pending casts/positions, stop request. **Không có reset encounter hoặc WIN toàn map**. Existing legacy `HuntingPveRunV2` vẫn riêng cho save cũ.
- `RewardReceipt`: stable identity, source table/seed and already-rolled payload, recipient/progression shares, status `PENDING/COMMITTED`, provenance; game save chung với Warehouse/unique/disciples.
- `ForgeOrder` (phase riêng): real crafter/building/time/material escrow/finish outcome/item unique receipt; current sync `craft()` pilot không tự động biến thành queue.

**Chưa quyết định** kích thước serializable dictionaries, compaction ledger, IDs chính thức, model save migration và chính sách cấp boss; nội dung này phải được đóng trước CODE.

## E. Săn liên tục mà không sửa Combat V2

### E1. Trải nghiệm đích

- Người chơi nhìn trên map một hoặc nhiều đội đệ tử tự đi, tìm và đánh quái; camera pan/zoom tự do, nhấn theo đội nếu muốn.
- Đội thắng: quái đó được quyết toán, slot chuyển dead, chờ hồi quái; đội tự nhặt thưởng *về authority ngay*, đánh tiếp/quay tuần tra. **Không yêu cầu click Claim mỗi trận B3 production**, nhưng legacy claim vẫn giữ nguyên mode cũ cho save cũ.
- HP/stamina/medicine thấp: AI ưu tiên thoát đúng luật V2, về chữa trị, sau đó tự tiếp tục nếu policy cho phép và đã hết injury.
- Boss/rare là cơ hội có source thật; không ép boss cố định mỗi 5 trận hoặc gắn tỷ lệ chưa duyệt.
- Không khóa cứng đội hình; vị trí chân và shadow thật; không thiết kế collision địa hình/pathfinding. Sprite chồng hình tự nhiên được phép, nhưng nguồn position gameplay ổn định.

### E2. Quyết định ĐÃ CHỐT: COMBAT LIÊN TỤC TRÊN MỘT THẾ GIỚI — KHÔNG BATTLE 90 GIÂY

**Owner lock 2026-09-30 và 2026-10-21:** Chơi như Evil Hunter Tycoon: người/đội đang đứng trên một map mở, đi tìm quái, tự đánh và cast skill. Khi quái A chết, A rơi đồ và chờ respawn; B/C vẫn đánh đệ tử bên cạnh; đội không bị đưa sang “trận” khác, không màn WIN, không hồi HP/skill cooldown/cast/RNG/position khi quái hết. Nếu tất cả quái gần đó chết, đệ tử tuần tra/chờ cá thể mới spawn; map/duty vẫn sống. Không có “giới hạn 90 giây” và không “clear cả wave”.

**Lý do code chưa đạt:** `MapBattleV2.step()` của `main` dùng `_count_alive("monster")==0 → win`, `now>=MAX_SECONDS → timeout_retreat`, `active=false`; `setup()` tạo battle roster hữu hạn, và event queue `MAX_EVENTS=2400`. Chỉ xóa hằng `MAX_SECONDS` **KHÔNG ĐỦ**: vẫn WIN-on-empty, capped event history, snapshot actor list/HP, spawn identity, cooldown, persistent caster/buff và scheduler chưa nối live World.

**Phương án kỹ thuật đích, mới là đề xuất CODE:**
1. **`PveWorldState` là lifetime owner**, tồn tại theo region/zone instance, giữ 2D positions/hp/aggro/threat-triggers (nếu V2 có), actor cooldown, pending cast, deterministic RNG, spawn slot/generation, party duty và reward receipts. Không tạo `MapBattleV2.setup()` mới sau mỗi kill; không rollback world khi view đổi/camera pan.
2. **`CombatV2WorldStep` tái sử dụng hạt nhân xử lý Combat V2** (range/move, attack interval, crit/damage/defense, skill use, AoE/projectile/cast/status and target resolution) bằng adapter hoặc tách lõi dùng chung **mà không đổi kết quả luật toán**. Có thể thêm `world_mode` hoặc một driver/factorization tương đương, nhưng không sao chép formula Combat V2 sang backend chiến đấu thứ hai.
3. **Kill theo HP transition** từ từng `monster_instance_id`, kể cả basic/DoT/projectile/AoE. Emitted immutable `Killed(monster_id, generation, tick, attributed participants)` là gameplay event *trước* presentation ring buffer. Roll và commit reward per kill chính xác một lần.
4. **Dead monster được thay sau deadline riêng** ngay trên world runtime: mọi quái khác/đệ tử/cast tiếp tục hành động tại timestamp đó. Respawn vào spawn slot theo vùng; nếu slot bị chiếm/không hợp lệ, xác định retry rule data-driven, không gọi wave-complete. Elite/Boss spawn chỉ khi có content hợp lệ.
5. **Không defeat/win/timeout toàn zone**. Một **đội** có thể chủ động stop/return/retreat, bị HP/Injury buộc về, hoặc tạm mất mục tiêu; đội khác vẫn tiếp tục săn. Event terminal cũ chỉ dành cho `LEGACY_V2_ENCOUNTER`; luật bị thương/HP ở level disciple/team vẫn authoritative.
6. **Map farm phẳng**: vị trí chân 2D, định hướng, khoảng cách attack/aggro, movement speed và skill range thật; di chuyển thẳng đến mục tiêu, không collision địa hình, không navmesh/pathfinding. Hoa/cỏ, bụi cây, shadow và chibi Source A hoàn toàn thuộc Map/Character presentation, không chặn chạy hay tác động RNG.
7. **Giữ legacy nguyên vẹn qua opt-in migration**. Existing `HuntingPveRunV2` finite run và `HuntingMapV2.claim_reward` cần giữ cho game save/QA cũ, nhưng **KHÔNG còn được coi là hướng triển khai B3 continuous**.

**Ví dụ đúng:** Mười quái hiện trên bãi: A bị đội 1 hạ lúc t=18.5s, thả reward A và lên lịch spawn A' lúc t=respawn_at; đồng thời đội 2 vẫn đánh B, đội 1 chuyển đánh C. Khi A' về map, A' sống độc lập trong khi B/C/đệ tử đang combat; không có màn dừng, tổng kết, reset hay 90s. AoE hạ A/C cùng bước → hai kill keys riêng. Các giờ chạy dài vẫn dùng cùng state; memory/render có giới hạn riêng.

**Compatibility gate bắt buộc:** test parity các formula và skill/cast/RNG event ở Combat V2 trên một cửa sổ bước cố định với đầu vào tương đương; test world 90s, 180s, 3600s thấy world/cooldown/HP liên tục mà không hard timeout hoặc reset. Không mượn V5 Source A render để làm gameplay authority.

### E3. Hai thang thời gian — ĐỒNG HỒ DUY NHẤT, NHƯNG KHÔNG GIỚI HẠN SESSION

- Existing: `SimulationRuntimeClockV2` có `60 wall seconds = 1 scheduler minute`, `MapBattleV2.STEP_SECONDS=0.25` combat. Không suy luận `1 quái = 1 phút`, `1 trận = 90 giây`, hoặc tính tiền offline theo số phút nhân tỷ lệ rơi đồ.
- **Design proposal:** canonical world timestamp dạng fixed integer sub-ticks (mỗi 0.25 giây là một bước chiến đấu), với economic scheduler tick tại biên mỗi 240 sub-ticks; không đồng hồ riêng thứ hai. **Điều này là kế hoạch tái cấu trúc clock/adapter, CHƯA LOCK cách triển khai numeric.**
- Khi có 60 giây thực trôi, world active đủ điều kiện nhận 240 substeps, nhưng tương tác tiêu hao travel, attack, mana-like mechanics **chỉ theo luật Combat V2 hiện có**, không tự tạo resource không được chốt. Đệ tử làm nghề không đồng thời hành động hunt qua One Active Job.
- Thời gian respawn đếm theo **global canonical time**, không reset về zero khi quái cuối bị hạ, khi GUI đóng hoặc khi đội khác đến. `respawn_at` là deadline, không có timer tính bởi animation.
- Online, nhìn thấy/không nhìn thấy và offline cùng command stream/state RNG/action ordering. Event-driven batching chỉ cho phép khi chứng minh bằng test cho kết quả như step-by-step; tuyệt đối không thu nhập đơn giản `thời gian × drop rate` hoặc simulate từng bước cho hàng nghìn đệ tử vô ích.
- **Open decisions:** offline cap, exact substep/minute persistence, world-active/hibernation authority, snapshot granularity, chi phí CPU và save size; đo trên Android/Windows 8GB sau khi có 1-zone continuous gameplay, không suy diễn từ sandbox.

### E4. Spawn từng con, nhiều đội, Tinh Anh/Boss, nhiều bản đồ

- **`SpawnPointDef`** khai ID nguồn quái/địa điểm/vùng, số slot hoặc population budget, tier/loài/tables, independent respawn delay và điều kiện Elite/Boss. Chỉ dùng bảng production khi được author/duyệt; không tạo Boss định kỳ theo tỉ lệ chưa có.
- **`MonsterInstance`** mang `zone/slot/generation` + vị trí chân/HP + next AI decision + combat cooldown/cast/FX link (FX không authority). Mỗi quái chết chuyển `DEAD`, tạo receipt, giữ `respawn_at`; các monster khác vẫn sống. Không phát `respawn all` khi hết quái.
- Mỗi quái được một engagement/target reservation khi cần chống hai world combat owners; **không cấm nhiều đệ tử/đội đánh cùng một con quái theo mặc định**. Nếu nhiều đội cùng đánh một Boss, tất cả damage V2 xảy ra trên **một Boss HP state** và chỉ **một kill/receipt**, phân chia reward/participation phải quyết định sau; V1 chưa nên triển khai cooperative Boss khi chưa có luật attribution.
- `30 disciples/40 mobs` đang là giới hạn `MapBattleV2` cũ, **không phải cap toàn map PvE đích hay trần thế giới 1.000–3.000 đệ tử**. Future live kernel phải có actor/region/chunk budgets và đo hiệu năng; không tự claim >40 active đã chạy.
- 30 realm-region × 10 clusters đang là projection content; kiến trúc data-driven/lazy zoning hỗ trợ mở rộng mà không dựng 300 cụm ngay. Con số map tile `192×192` trong nhánh Map là presentation concern riêng, không biến thành một quy tắc slot/monster của B3.
- Thiết kế bãi quái **không có địa hình cản, collision vật lý, pathfinding hoặc navmesh**. Ưu tiên sân phẳng rải hoa cỏ; khoảng cách 2D gameplay, speed, range, AI search/target là đủ. Character actor được phép overlap ảnh, chân/bóng thật phân biệt vị trí.
- Spawn/generation/kill IDs phải khớp map content theo manifest versioned; Map stream được quyền bố trí cảnh/điểm spawn **dạng authored metadata**, còn backend B3 quyết định spawn lifetime/HP/loot. No duplicate source of truth.

## F. Reward production — ONE kill, ONE eligible payout, MANY channels

### F1. Ngăn 3 payout paths gây nhân ba đồ

| Mode | Code/reward authority | Rule |
|---|---|---|
| `LEGACY_AUTONOMOUS_P2` | `SimulationScheduler` + `CombatSystem.resolve_encounter` + pending inventory | Giữ save cũ; không đồng trả V2/B3 per-kill. |
| `LEGACY_V2_ENCOUNTER` | `HuntingMapV2.claim_reward` after WIN + encounter receipt | Giữ 4-win `linh_tuy`, reward theo lần thắng, chưa phải mỗi monster. |
| `B3_PER_KILL_CONTINUOUS_WORLD` (FUTURE) | authoritative per-monster HP lethal in persistent world → one receipt → canonical settlement | Không gọi hai path trên cho cùng world kill; **không có WIN/Claim/90s/wave reset**; opt-in sau migration, content production được duyệt. |

Không migration/reinterpret pending loot hay legacy receipts một cách ngầm. Đội cũ đang trong legacy battle hoàn thành/settle theo **old authority riêng**, hoặc có migration với tests/consent; **chỉ legacy** còn trạng thái WIN/TIMEOUT toàn encounter.

### F2. RewardEnvelope/receipt đề xuất

Identity `world_run_id/zone_instance_id/slot_id/generation`; immutable source `species_id, tier, realm, content_version, loot_table_version`, reward seed domain-separated từ combat RNG. Một envelope có thể chứa các **đầu ra hợp lệ độc lập**:
- Kho stack (vật liệu, yêu đan, thuốc/vật tư, resource ID đăng ký).
- Trang bị unique/pháp bảo/vật phẩm hiếm khi content đã auth, vào **canonical sect item registry**, không nhét unique vào fake quantity.
- Sect/personal Linh Thạch splits theo policy đã duyệt.
- Tu Vi, skill mastery, profession EXP/Contribution theo **canonical personal progression consumers** và tham gia thực tế (support/heal/tank được ghi nhận, không chỉ last-hit). Không tạo “Tu Vi per mob = X” nếu chưa có rate approval.
- HP/ Injury/terminal cost thuộc lifecycle combat riêng nhưng phải có idempotent coordination, không reapply khi reload.
- Contribution và any achievement unlocked khi transaction committed, tránh duplicate event/notice.

**Exactly-once không chỉ là Warehouse.** B2.4 sandbox clone chỉ chứng minh một phần. Production cần commit/rollback các recipient mutations nhất quán, receipt state durable trong cùng snapshot với all gains; `PENDING` replays stored payload, `COMMITTED` never rerolls. Save/reload mid-kill + mid-credit + table-version changed + occupied inventory tests. Receipt retention/compaction phải giữ replay protection bằng generation watermarks và chứng minh không duplicate, không prune tùy hứng.

### F3. Chase / loot economics

- Săn thường: Tu Vi/skill advancement + monster materials + ordinary gear/source drops (chỉ khi authored); không bắt mọi reward đi qua luyện khí.
- Elite: source đặc trưng/blueprint/khả năng unique phù hợp nội dung; không có tỷ lệ production nào được khóa ở đây.
- Boss: gear/lineage fragments/Chân Văn source *possible design*, giết Boss có rủi ro, thông tin và kế hoạch tự săn; không cam kết Boss nào bảo đảm Chí Tôn hoặc tỉ lệ rơi.
- Rear base: Mỏ/Linh Lâm/Linh Điền, luyện khí, luyện đan, y quán, logistics tạo nhu cầu/nguồn ổn định. Săn không xóa vai trò sản xuất; nguồn cung đáng tin cho gear cơ bản phải có trước khi chase hiếm.
- Duplicate gear: policy lưu, cấp cho đội khác, phân giải/market **chỉ sau khi có consumer thật và auth**; không auto salvage vật phẩm lock/bộ chưa hoàn thiện.
- Stock/locks/reserve từ `WarehouseSystem.available_quantity` là nguồn tính thiếu hụt; `FarmOrder` không có một “loot warehouse” riêng.

## G. AI săn — default duty không phải hoàn thành một công thức

### G1. Ba tầng policy và quyền can thiệp

1. **Sect policy**: nhóm săn, mức rủi ro, min supply, ra/về, ưu tiên Tu Vi/loot/rare/boss, vật liệu bảo vệ, downtime.
2. **Team policy**: zone/rotation, 1–6 member, leader, allow-retreat, auto-resupply, optional target item/recipe/material, “ưu tiên săn liên tục”.
3. **Disciple decision**: skill target use Combat V2, self-preservation, healing/role, personal preference khi không xung đột. Chưởng Môn có thể ra lệnh thủ công nhưng không vượt quy tắc an toàn/time/save.

Thứ tự quyền: **survival & One Active Job guard > lệnh owner hợp lệ > team duty > personal preferences**. Team lúc đang mining/training phải WAIT, không bị tự cướp.

### G2. Mode chức năng đề xuất

| Mode | Điều kiện hoàn thành | Khi xong |
|---|---|---|
| **CONTINUOUS_HUNT** (default) | Không có mốc vật liệu tự dừng. | Săn tiếp, nghỉ/return khi không an toàn, resume hợp lệ sau hồi phục. |
| **PROGRESSION** | Mốc Tu Vi/skill/realm nếu owner đặt hoặc đến risk ceiling. | Reevaluate tier/zone; không spam quái quá yếu. |
| **MATERIAL_PRIORITY** | Đủ vật liệu khả dụng theo kho và reserve. | Chuyển ưu tiên sang continuous/progression/next target, **không auto-stop** nếu người chơi không chọn. |
| **GEAR_CHASE** | Đúng unique template/set objective **thực sự** vào registry; không chỉ đã đủ nguyên liệu. | Khoá/cấp phát theo policy, đổi mục tiêu hoặc continuous. |
| **BOSS_SEARCH** | Cơ hội boss content-authored, giới hạn risk/cooldown. | Sau Boss chuyển vùng/fallback farm; không ngồi vô tận tại vùng không có source. |
| **RETURN / HOLD** | Lệnh owner hoặc điều kiện nghiêm ngặt (HP/Injury/thiếu supply). | Terminal settlement → hồi phục → đợi/chạy lại đúng policy. |

Không buộc có quest dài. Trạng thái nhiệm vụ/AI tổng gọn, phù hợp người chơi muốn farm liên tục.

### G3. FSM thực thi đề xuất

`READY → PREPARE → TRAVEL → SEARCH/PATROL → ENGAGE → SETTLE → [PATROL | RETURN] → RECOVER/RESUPPLY → READY`.

Orthogonal **control state** `ACTIVE | PAUSE_REQUESTED | PAUSED | BLOCKED | STOP_REQUESTED | CANCELLED`, không nhập trộn với **individual monster `ALIVE/DEAD/RESPAWNING`** và **team `HUNTING/RETURNING/RECOVERING`**. `WIN/DEFEAT/TIMEOUT` là encounter outcome **legacy-only**, không phải trạng thái terminal của B3 map.

- Trước khi deploy: pure eligibility preflight team IDs, One Active Job, Injury=0, HP, active battle lease, zone unlocked, actual target content, supply requirements.
- `SEARCH` dựa spawn availability/source and world travel, không giả mob “mỗi tick” nếu không có slot. 
- `ENGAGE`: Combat V2 quyết định đòn đánh/skill/HP lethal; thế giới và các con quái khác **vẫn đang chạy**. Không chờ 'win toàn map'.
- `SETTLE`: chạy theo **individual kill event** song song với các hành động PvE khác, durable commit, không double pay qua old claim; không pause toàn thế giới để tổng kết trận.
- `PATROL`: nếu continued, chọn mục tiêu kế theo policy, không “complete recipe then return” mặc định.
- `RETURN`: retreat/low supply, explicit owner stop or unacceptable risk, respects terminal state and outstanding receipt.
- `RECOVER`: Injury/HP/treating follows existing law; wait 120 ticks or legitimate heal consumer, not fake instant.
- Save/load resumes each state idempotently. Reselect region only when event/meaningful improvement, tránh oscillation.

**Policy planner pure** phải không đụng `DecisionSystem.evaluate/choose_region` từ GUI trước khi command thật. Stable sort/tie break and explicit reason codes. `FarmOrder` là optional objective pointer, không reserve stock vật lý giả và không mutate Warehouse.

## H. Tu Vi / nghề / trang bị — phát triển nhân vật mới là phần thưởng dài hạn

1. Săn tăng sức mạnh đệ tử **với challenge thực tế**: tỉ lệ phần trăm yêu cầu Tu Vi của tầng hiện tại + relative realm + grade/challenge + participation (spec V2 đã định nghĩa shape). Không xóa P2 old fixed rewards trước migration.
2. Tôn trọng 2 progression tracks 30×10. Quái không tự trực tiếp nâng Luyện Thể nếu thiếu body source/legal gate; vật liệu body từ xác nhận source, không phá Injury/training contract.
3. Kỹ năng tăng mastery khi actor thật cast/hit/support theo `COMBAT_SKILLS_V2_SPEC`; không tự tick mastery bằng animation frames.
4. Cống hiến và personal stones phân đúng source/policy; không gộp personal currency với Kho.
5. Equip: schema/content target từ đầu **10 ordinary slots, 12 grades, 24 sets**, nhưng lộ trình code tách migration, không biến pilot 3 slots thành 10 slots trong một B3 integration diff bừa bãi. Không tạo 10 item slot render chỉ để “đủ tính năng” mà combat/stats không consume.
6. Forge V2 phải có real `ForgeOrder` và đồng hồ canonical nếu triển khai. `EquipmentSystem.craft` pilot là synchronous; demo instant craft không đồng nghĩa V2 có lệnh nghề 5 phút; `FORGING_DURATION=5` là profession work, không phải timer tạo trang bị.
7. Auto-equip đánh giá **full legal loadout**, 2/3/4 set, 3+3, player lock và real Combat V2 utility; không thay item chỉ vì đơn chiếc +1% gây phá bộ. Chỉ auto-salvage/sell khi có quyền và không reserve/lock.
8. Không xây B3 quanh đúng **5 pilot recipes**: `ContentRegistry` phải có versioned recipe/template/material/rarity/source schema, thăng bậc/phẩm/generation 1..30, lazy load. Số lượng công thức, phôi và boss source là **content authoring** và balance ở phase sau.

## I. Content architecture mở rộng, không overengineer

Đề xuất lớp định nghĩa read-only/data-driven:

```text
WorldBand (realm 1..30) / map chapter
   └─ RegionDef (zone, unlocks, recommended realm, terrain, resources)
       └─ ClusterDef (spawn footprints, density, hazard, access, travel)
           ├─ SpawnPool(species / normal / elite / boss / tier / respawn policy)
           └─ LootSourceDef(versioned eligible drop tables)
MonsterDef(species identity, combat stats/skills via Combat V2, authored visuals)
RecipeDef(forge/alchemy/etc, materials, building+profession prereqs, real duration)
GearTemplateDef(10-slot, realm tier, grade pools, 24 set lineage, source tags)
```

Existing Thanh Trúc Lâm, Bạch Thạch Khê, Hắc Phong Cốc are **integration fixtures**, not a product world size decision. Pilot old encounter drops/rare percentages and `linh_tuy` 4-win source remain legacy; no direct mapping into per-kill probabilities without authored separate table and owner sign-off.

**QA data gates:** IDs registered, table weights valid, no missing recipe chain, reachable progression path, early supply not Boss-RNG hard locked, no phantom VFX/skill or made-up rare gear; known incomplete Source A packs can use verified fallback for backend proof, not fake gameplay.

## J. Online/offline/scaling and evidence

### J1. Correctness first

- A live viewing client cannot advance simulation twice. Exactly one runtime owner injects time and commands; presentation only reads.
- Fast replay/offline can skip drawing but not skip legal combat/kill/consumption/retreat/receipt outcomes; performance optimization must prove semantic equivalence on seeded tests.
- Bounded budget: actor-level computation only active visible/relevant encounters, event-based logic elsewhere; avoid scanning every monster or all 1.000–3.000 disciples per 0.25s when they are idle.
- Large-offline period: preserve backlog as bounded pending work/paused state or batch only where mathematically equivalent and tested, **not** unlimited proportional idle awards.
- Telemetry versioned: simulation seconds vs wall seconds, eligible kills/hour, effective farming time, wipe/retreat/injury, material/h, unique gear, duplicate receipts, queue starvation, save-size growth, memory/CPU on 8GB dev and Android target.

### J2. Focused tests to design before CODE

1. `CONTINUOUS_HUNT` after fulfilling optional material target **continues legally** or falls back; explicit STOP pauses new deployments, old completed kills stay credited.
2. One real monster killed by two delayed lethal notifications/DoT/AoE makes one receipt; two slots/generations independent; 40-mob event truncation can't drop rewards.
3. Two parties see same slot, one lease only; team absent/injured/active work not dispatched; no One Active Job theft.
4. Legacy P2, V2 encounter and opt-in B3 modes cannot reward a single kill twice; old four-WIN `linh_tuy` guarantee remains unchanged.
5. Same seed + commands + elapsed world time yields identical combat/loot/HP/progression on visible vs offscreen vs save/reload and bounded offline.
6. Save mid-cast/mid-death/PENDING reward/COMMITTED/respawn preserves state, no HP/cooldown reset exploit, unique ID collision or dup.
7. RewardEnvelope with material, unique item, personal Tu Vi, skill mastery, Contribution and Spirit Stone partition commits atomically or rolls back; invalid resource/lock/range fails closed.
8. World PvE chạy qua mốc 90s, 180s và 3600s **không dừng/reset**, quái A chết/hồi riêng lúc đội đánh B; HP/cooldown/pending cast/position không reset, kể cả khi một cluster hết quái. Team retreat/HP0 xử lý Injury đúng authority; only legacy encounter uses WIN/TIMEOUT.
9. FarmOrder target uses actual usable Warehouse, not raw stock; material-ready ≠ gear-crafted ≠ gear-assigned.
10. One fully authored forge order consumes canonical resources once at real finish tick, creates one Sect-owned unique item, respects player locks and existing pilot compat.
11. Load older save version 2 unchanged; opt-in new B3 state never reclaims old completed encounter; versioned explicit migration.
12. Performance smoke one team, five teams, many regions, 30v40 battle and 1.000–3.000 background roster **after** correctness; no product scalability claim from static QA.

**QA philosophy:** test focused at each packet; cross-subsystem regression when changing Save/Scheduler/Combat; only name PASS with Godot official output. Source A converter QA is a *separate*, simplified overnight workflow; B3 will not trigger it.

## K. Phân rã gói triển khai đề xuất (TẤT CẢ CHƯA ĐƯỢC PHÊ DUYỆT CODE)

| Packet | Outcome kiểm chứng | Dependency / scope |
|---|---|---|
| **B3-V2-D0 DESIGN** | Đặc tả này + graph audit + cơ chế open decisions. | Docs-only, thực hiện được ngay. |
| **B3-V2-C0 CONTINUOUS WORLD / TIME CONTRACT** | Chốt single clock, 0.25s Combat V2 stepping **không 90s/no WIN-on-empty**, monster slot/generation, actor persistence, scene-neutral world view; typed kill events, online/offline fixtures. | Sau khi review B2.4 ZIP. Cần scoped CODE packet/1 writer, không sửa formula V2. |
| **B3-V2-C1 ONE REAL KILL IN WORLD** | Một `MonsterInstance` trong thế giới **không reset**, HP0 → per-kill receipt, reward đúng source; `SaveService` chung, replay/save consistency. | Integration writer duy nhất Combat/State/Save/Warehouse; bảo toàn legacy, production table đã duyệt. |
| **B3-V2-C2 WORLD DUTY & INDIVIDUAL RESPAWN** | Nhiều monster trên cùng map, chết/hồi riêng trong lúc đội tiếp tục combat, AI patrol/target/return/recover, map view là projection. | C0/C1; không nối nhiều battle finite, không wave clear; thử 1 map nội dung authored. |
| **B3-V2-C3 POLICY TEAM AI** | Default continued hunting + per-team/sect risk/rotation/goal, resume, optional FarmOrder; no job stealing. | Workforce/Organization/safety focused gates. |
| **B3-V2-C4 GROWTH REWARDS** | Tu Vi/mastery/Contribution/sect+personal stones attributed to valid participants exactly once, challenge scale; test old migration. | C1 and authorized progression rate policy; don't mutate old P2 gains silently. |
| **B3-V2-C5 GEAR/CRAFT BRIDGE** | First real source → one actual forge order/timer or drop unique → allocate gear without dup; basic materials from production still needed. | Owner-approved forge transaction, new content IDs/recipes. |
| **B3-V2-C6 EQUIPMENT V2 MIGRATION** | 10-slot/12-grade/24-set legality; old items preserved; real Combat/stat/work consumers; auto-equip set-aware. | Dedicated allowlist, migration, separate focused+cumulative tests. |
| **B3-V2-C7 WORLD/CONTENT SCALE** | Data-driven regions/clusters, nhiều đội, spawn independent/Elite/Boss, cooperative Boss chỉ khi có reward attribution, offscreen/performance; Android landscape measurable. | Sau continuous 1-team proof; 30×10 content target là data plan, không phải C1 scope; Map/Character Studio không bị chạm. |
| **B3-V2-C8 BALANCE** | Drop/progression/craft-rate simulation, p50/p90/p95 first useful upgrade, Boss chase variance, injury/downtime, production vs hunt economy. | Requires actual gameplay telemetry and owner approval of rates. |

**Khuyến nghị thực thi:** chỉ 1 CODE writer chạm shared combat/state/save/scheduler, một design/QA researcher độc lập; không chạy B3 Godot đồng thời với heavy Source A trên Windows 8 GB. B2.4 đang sandbox không tự nhận là B3-C1; phải review exact worktree/ZIP trước khi code.

## L. Owner decisions còn MỞ (không tự chốt)

| Câu hỏi | Khuyến nghị thiết kế, CHƯA LOCK |
|---|---|
| Duty mặc định | **CONTINUOUS_HUNT**, có policy đổi vùng/nghỉ, không “đủ 3 nguyên liệu thì dừng”. |
| Auto tiếp tục sau hồi phục | Bật theo team policy sau recovery hợp lệ, có giới hạn rủi ro và nguồn cung, không tự vượt Injury 1. |
| Boss tranh chấp | V1: một lease/encounter, không hai team double-kill cùng slot. Cooperative boss riêng về sau. |
| Continuous combat world | **OWNER LOCK:** một PvE world chạy xuyên 90s/multi-kill, từng quái hồi sinh ngay khi các quái khác còn sống; **KHÔNG nối `MapBattleV2` hữu hạn hoặc reset**, chỉ tách/chuyển core Combat V2 giữ nguyên luật. |
| Offline farm | Replay cùng authoritative time với cap xử lý/progress ledger; limit accrual và backlog sau kiểm chứng, không thả quyền “offline = x monsters” tùy ý. |
| Gear source mix | Cả direct drop, material forge và Boss chase; không Boss-only hoặc forge-only. |
| Reward split / drop / rarity / forge | Không tự khóa tỷ lệ; legacy pilot số hiện tại giữ trong legacy mode; production B3 phải owner duyệt. |
| 30 realm regions ×10 clusters | Giữ làm target hướng content, nhưng implementation data-driven, tier gating soft/validated và lazy loading. |
| UI complexity | Overview đội/chính sách + chỉ báo farm/hồi phục/đồ rơi; chi tiết mở drilldown. Không 1.000 actor per screen. |

## M. Điều kiện CHẤP THUẬN thiết kế trước khi phát CODE

Owner duyệt/cập nhật tối thiểu: (1) “săn liên tục” là duty mặc định với stop/auto-return đúng; (2) online/offline authoritative time bridge; (3) per-kill + personal growth reward segmentation; (4) nguồn item direct-drop + forge; (5) nhóm/đội và Boss tranh chấp; (6) chỉ định một integration owner và packet allowlist, migration + regressions. **Duyệt kiến trúc không đồng nghĩa cấp phép code.**

**Proof status:** Đã đọc từ GitHub `main` và các design spec, chưa mở chạy Godot, chưa kiểm chứng save hiện hành trên máy owner, chưa đo drop/gameplay, chưa có production B3 per-kill content. **Map và Character Studio: OWNER-REPORTED ACTIVE**, local SHA/chức năng còn phải review khi có handoff; Source A SA-LIB chạy độc lập theo tài nguyên; Combat V5.1 owner visual chưa PASS. Không tự can thiệp các luồng này.

## N. Phân ranh rõ B3 backend ↔ Map ↔ Character Studio ↔ Source A / V5

| Workstream | Quyền chủ trì | Chỗ B3 được thiết kế tiếp | Cấm trong B3 hiện tại |
|---|---|---|---|
| **Map (OWNER-REPORTED ACTIVE)** | Tỉ lệ/texture mặt đất, hoa/cỏ, vùng nhìn, màn hình/zoom/pan/camera, layout scene và placement authored metadata nếu Map owner xuất ra | `ZoneDef`/spawn-point interface theo **tọa độ chân gameplay**, stable IDs, viewport projection; không đòi physics/pathfinding | Không sửa map asset, scene, camera, tile/chunk, `project.godot` hay điều khiển Codex Map |
| **Character Studio V2 (OWNER-REPORTED ACTIVE)** | Chọn rig/nam nữ/clip/skin/gear appearance, preview/lazy cache/manifest; clip thật, không giả action | B3 xuất `actor_id`, `rig_ref`, `clip_intent`, `heading`, `world_foot_position`, `skill_event_id` đọc-only | Không sửa Studio plugin/rig/clip/skin/outfit; không tạo converter khác |
| **Source A SA-LIB (overnight conversion)** | converter/fingerprint/pack/checkpoint/status, rig Source A chuẩn, QA nhẹ theo rule riêng, không đụng source raw | B3 chỉ yêu cầu metadata schema/rig references; backend có thể dùng fallback khi chưa có pack QA | Không tải/batch/QA lại asset từ B3; không phá resource safety gate |
| **Combat V5.1 presentation (owner visual pending)** | Render map battle, actor animation, VFX, HUD, chân/bóng/tên/camera | Nhận immutable Combat V2 gameplay events/snapshots cho FX, damage numbers, skill cues | Không ép hình ảnh làm HP, damage, loot, time authority |
| **B2.4 Editor/tool sandbox** | Author/validate spawn/loot data, synthetic per-kill demo evidence | Tái sử dụng **format/catalog/validator/receipt concepts** khi proven, không bê bản test thành payout production | Không ghi worktree/merge/re-run sandbox của Codex |
| **B3 backend (DESIGN ONLY)** | World runtime lifecycle model, canonical time, monster death/respawn, combat authority adapter, loot exactly-once, team autonomy/injury, persistence | Hợp đồng dữ liệu cho 4 luồng trên, và migration packet khi owner cho phép | Không sửa bất kỳ runtime/file chồng phạm vi cho tới khi CODE packet được duyệt rõ |

**Proposed minimal Map→B3 boundary:** `zone_id, map_content_revision, world_to_canvas_scale, spawn_points[{id,foot_x,foot_y,species_pool_id,visual_marker?}], visual_decorations?`. **B3→Map/Studio read-only stream:** `{world_tick, entity_id, source_rig_ref, foot_position, facing, alive, hp_ratio, cast/cooldown/skill_event, damage_event, loot_visual_hint}`. Visual `loot_visual_hint` xuất **sau receipt**, không tự cấp reward. Metadata hoa cỏ `visual_decorations` không đi vào combat/loot RNG.

**Collision/file coordination:** vì các agent Map và Studio đang chạy ở worktrees riêng theo owner, không thêm prompts/branch edits chạm file của họ; chỉ nhận review ZIP/diff/manifest sau khi họ xong. Nếu cần nối `project.godot`, scene root, Combat V5, `SectState`/Save, chỉ một integration owner được phép trong CODE packet riêng. B3 docs branch hiện tại không can thiệp tiến trình máy 8GB.

## O. Acceptance examples cho PvE đúng kiểu Evil Hunter (owner lock)

1. **T+0–T+120s:** một đội được thả vào bãi gồm ít nhất 3 con đang sống. Chết A lúc 20s, B chết lúc 41s, A respawn theo timer riêng lúc 55s trong khi đội đang đánh C; **không dừng toàn map lúc t=90s**, không reset cooldown/HP/position, không gọi claim WIN.
2. **AoE 2 kills cùng tick:** A/B có 2 receipt độc lập, không thưởng lại nếu projectile/DoT cùng frame nổ sau HP0; world không đóng.
3. **Empty-zone:** tạm hết quái, đội patrol/chờ spawn; có một con hồi thì tiếp tục đánh trong thế giới đã sống từ trước.
4. **Hai đội đồng thời:** cùng map, 2 set hero/monster logic, không double kill cùng monster; bình thường có thể hỗ trợ đánh chung nếu reward attribution được chốt, nhưng Boss cooperation phải có luật riêng.
5. **Return/injury:** 1 đệ tử bị hạ xử lý injury 0/1 và recovery 120 ticks theo authority, team khác vẫn hoạt động; save/load không reset.
6. **Map giản lược:** tất cả chuyển động dùng chân XY/attack range, không có vật cản hoặc navmesh; xoay camera/zoom/ẩn map không đổi kill/loot/target simulation.
7. **Online/offline:** cùng seed/lệnh/elapsed, quái/tick/HP/skill/receipt và reward giống nhau với giới hạn xử lý offline đã duyệt; không mint `elapsed × average_drop`.
8. **5–10 phút và 1 giờ giả lập:** không có `MAX_SECONDS` termination, event history được xoay vòng presentation mà không mất simulation kill; không leak memory vì tích lũy event vô hạn.

**Status:** Đây là diễn đạt chính xác quyết định owner về trải nghiệm. Những mục CODE cần để đạt vẫn được đánh dấu PENDING, không gọi runtime hiện tại là PASS.

### Nguồn đọc (GitHub)

- `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `CURRENT_CHECKPOINT.md`, `NEXT_CHAT_HANDOFF.md`.
- `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md`, `docs/P3_7_DISCIPLE_LOADOUT_HUNTING_PROGRESSION_SPEC.md`, `docs/P3_7_TIME_SPEED_COOLDOWN_SPEC.md`.
- `docs/COMBAT_STATS_V2_SPEC.md`, `docs/COMBAT_SKILLS_V2_SPEC.md`.
- `docs/WEAPON_EQUIPMENT_V2_SPEC.md`, `docs/EQUIPMENT_SETS_V2_SPEC.md`, `docs/EQUIPMENT_FORGING_UPGRADE_V2_ROADMAP.md`.
- `godot/src/simulation/combat/map_battle_v2.gd`, `hunting_map_v2.gd`, `hunting_pve_run_v2.gd`, `map_battle_snapshot_v2.gd`.
- `godot/src/simulation/core/simulation_runtime_clock_v2.gd`, `simulation_scheduler.gd`; `ai/decision_system.gd`, `ai/goal_system.gd`; `organization/organization_system.gd`; `workforce/workforce_system.gd`.
- `godot/src/simulation/resource/warehouse_system.gd`, `equipment/equipment_system.gd`, `save/save_service.gd`, `state/sect_state.gd`.
- `docs/handoffs/2026-10-21/TMB_FOUR_ZIP_REVIEW_AND_NEXT_CODEX_2026-10-21.md` and `TMB_B23_BACKEND_B3_RESEARCH_CHECKPOINT_2026-10-21.md`.

**Không merge**, không gọi đây là chương trình code đã hoàn tất; chỉ dùng để owner duyệt/sửa thiết kế và tách thành code packets sau này.
