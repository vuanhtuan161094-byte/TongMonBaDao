# TÔNG MÔN BÁ ĐẠO — B3 V2: TÔNG MÔN SỐNG / SĂN LIÊN TỤC / PHÁT TRIỂN ĐỆ TỬ

**Ngày:** 2026-10-22 (Asia/Ho_Chi_Minh)  
**Trạng thái:** DESIGN PROPOSAL — FOR OWNER REVIEW; KHÔNG PHẢI LUẬT GAMEPLAY MỚI ĐÃ KHÓA, KHÔNG PHẢI CODE PACKET  
**Repo:** `vuanhtuan161094-byte/TongMonBaDao`  
**Code audit:** GitHub `main @ 461caca1171462e0da092f21108c5c1733157ad9`  
**Nguồn handoff:** `docs/tmb-status-20261021-v5-sa-lib @ 447112287da6b2aaa0e7c32bf53a3e3d70fa59d0`  
**Nhánh thiết kế độc lập:** `docs/b3-v2-architecture-redesign-20261022`  
**Scope:** audit + kiến trúc/contract/roadmap/QA có điều kiện. Không sửa gameplay/test/save, không CI, không merge, không chạm local Codex SA-LIB hoặc B2.4.

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
| QoL/UX | Android landscape 1280×720; map/camera và chibi Source A là presentation; người chơi có thể pan/zoom/chọn nhân vật, không khóa toàn bộ camera vào một người; chân/bóng thật định vị sprite. |
| RNG & durability | Determinism, save/load chống double award, idempotent, migration legacy. AI, UI, asset converter không phải kill/loot authority. |

**Lưu ý về spec cũ:** `docs/P3_7_LONG_TERM_SECT_ECONOMY_HUNTING_SPEC.md` còn mô tả injury dạng thang 0–100; luật runtime đã được khóa mới hơn theo GP-02C1 là 0/1/120. Không âm thầm tái kích hoạt mô tả cũ.

### B2. Code đã thấy trực tiếp trên `main` — KHÔNG thổi phồng hoàn thành

| Code | Có thật | Gap B3 |
|---|---|---|
| `map_battle_v2.gd` | Bước **0,25 giây combat**, trận tối đa **90 giây**, 30 disciple / 40 mob trên **một battle**, kết thúc khi quái/đệ tử chết hết hoặc timeout. Presentation flags không tham gia simulation. | **Chưa là world combat liên tục**; không thể tuyên bố respawn giữa cùng một trận hoặc 300 cluster live. |
| `hunting_map_v2.gd` | 3 vùng V2 pilot, 5 mức lựa chọn/vùng, reward **theo trận thắng rồi claim**, rare được roll theo encounter; bảo đảm `linh_tuy` theo **4 thắng encounter** lịch sử. | Không phải loot per-monster production; không biến 4 win thành 4 kill. |
| `hunting_pve_run_v2.gd` | Begin/advance/finish/claim, đặt reservation cho đệ tử, terminal HP/Injury, live snapshot. | Chưa nối continuous world/legacy scheduler; claim và terminal receipt khác nguồn. |
| `simulation_scheduler.gd` | Phút mô phỏng, nghề/production/đệ tử; legacy path HUNT→TRAVEL→COMBAT→LOOT và `CombatSystem.resolve_encounter`. | Có **legacy route cá nhân**; không thể đồng thời trả B2.4 per-kill cho cùng một kill. |
| `decision_system.gd`, `goal_system.gd` | AI cá nhân có HUNT/REST/HEAL..., choose region và preference; `choose_region/evaluate` có mutation `last_decision`. | Reuse nội suy/risk nếu phù hợp, nhưng không gọi AI mutation trong GUI preview và không dùng như reward authority. |
| `organization_system.gd`, `workforce_system.gd` | Team tối đa 6; role, explicit `HUNT_REGION`, One Active Job thực tế liên hệ nhiều timers. | Cần **admission preflight thuần**, tránh `issue_command` gây hủy/cướp việc khi dùng làm dự báo. |
| `warehouse_system.gd` | Canonical stack, `available_quantity` (reserve/lock), `MAX_SAFE_STACK`, consumption preflight. | Ledger kill cần commit tất cả reward channels với Warehouse/unique/progression cùng state, không có kho song song. |
| `equipment_system.gd` | **Pilot cũ 3 slot, 3 quality, 5 recipes**; craft hiện synchronous, unique item registry. | Chưa có 10/12/24, chưa có lệnh forge có thời gian thật theo V2; không gắn fake ETA. |
| `save_service.gd` | Current wire `v2` với staging `.tmp`, verify, backup. | Schema thế giới, auto-duty và receipt mới chưa tích hợp production; cần versioned migration packet. |

**Handoff mới hơn:** B2.3 đã có ZIP với 7 focused PASS; B2.4 ZIP integrity verified (85 entries, 84 hash) và có standalone opt-in săn thử 6 synthetic actors, Warehouse clone, seeded test-only `linh_moc`. **Production per-kill table vẫn trống, Editor manual pending, live SaveService và integration pending.** Worktree B2.4/Codex SA-LIB chỉ địa phương, không thể đọc từ GitHub. V5.1 và Character Studio HOLD.

## C. Nguyên tắc thiết kế sản phẩm B3 V2

1. **Duty thường trực trước, FarmOrder sau.** Người chơi có thể giao đội “săn liên tục ở vùng này, đổi khi nguy hiểm, nghỉ nếu HP thấp”; tùy chọn thêm ưu tiên vật liệu/đồ bộ/Boss/Tu Vi. Đội không vô lý trở về nhà ngay khi kiếm đủ 3 nguyên liệu nếu còn đủ an toàn để săn tiếp.
2. **Combat V2 là kernel duy nhất.** World coordinator quản lý di chuyển, chọn encounter, hợp đồng spawn/lease/reward, không tạo `damage_v3`/skill RNG riêng. V5 render những gì kernel xảy ra.
3. **Mỗi quái một nguồn chết và reward identity duy nhất.** Dùng `zone_instance/slot/generation`, một receipt/kill, kiểm soát cạnh tranh giữa đội; preview/UI không bao giờ cấp loot.
4. **Một thế giới logic, nhiều cách trình bày.** Visible/offscreen có cùng state, RNG và kết quả với cùng lệnh/thời gian; trình diễn chỉ là projection. Đã có game logic thì có thể dùng Source A pack được QA sau, không chờ chuyển đổi 6.578 rig để chứng minh backend.
5. **Một economy, nhiều nguồn cung.** Mỏ/Linh Lâm/Linh Điền sản xuất ổn định; săn cấp nguyên liệu yêu thú, phần thưởng cá nhân, đặc sản vùng, gear trực tiếp; craft là consumer, không chi phối mọi quyết định.
6. **Càng đông càng giảm micro.** Team policy > hall policy > direct disciple commands; scheduler theo sự kiện/nhóm; không AI per-frame cho 1.000–3.000 người.

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
                  B3CombatBridge → MapBattleV2 / HuntingPveRunV2
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
- `HuntSession`: active team, zone/encounter reference, travel/engagement/return state, canonical time consumed, battle snapshot/HP/target and stop request.
- `RewardReceipt`: stable identity, source table/seed and already-rolled payload, recipient/progression shares, status `PENDING/COMMITTED`, provenance; game save chung với Warehouse/unique/disciples.
- `ForgeOrder` (phase riêng): real crafter/building/time/material escrow/finish outcome/item unique receipt; current sync `craft()` pilot không tự động biến thành queue.

**Chưa quyết định** kích thước serializable dictionaries, compaction ledger, IDs chính thức, model save migration và chính sách cấp boss; nội dung này phải được đóng trước CODE.

## E. Săn liên tục mà không sửa Combat V2

### E1. Trải nghiệm đích

- Người chơi nhìn trên map một hoặc nhiều đội đệ tử tự đi, tìm và đánh quái; camera pan/zoom tự do, nhấn theo đội nếu muốn.
- Đội thắng: quái đó được quyết toán, slot chuyển dead, chờ hồi quái; đội tự nhặt thưởng *về authority ngay*, đánh tiếp/quay tuần tra. **Không yêu cầu click Claim mỗi trận B3 production**, nhưng legacy claim vẫn giữ nguyên mode cũ cho save cũ.
- HP/stamina/medicine thấp: AI ưu tiên thoát đúng luật V2, về chữa trị, sau đó tự tiếp tục nếu policy cho phép và đã hết injury.
- Boss/rare là cơ hội có source thật; không ép boss cố định mỗi 5 trận hoặc gắn tỷ lệ chưa duyệt.
- Không khóa cứng đội hình; vị trí chân, shadow và collision logic phải đúng, sprite chồng hình tự nhiên được phép.

### E2. Thực trạng hạn chế kỹ thuật, lộ trình giải quyết

`MapBattleV2` **đang kết thúc ngay khi hết quái, sau 90 battle-seconds hoặc hết đệ tử**. Vì vậy **KHÔNG thể gọi API hiện có là continuous in-place**.

**Đề xuất V1 khả thi, tương thích luật:**
1. World/zone/session sống qua nhiều encounter, mỗi encounter là một `MapBattleV2` hữu hạn.
2. World coordinator chỉ giao đúng quái có slot/generation/lease; tập hợp một battle subset trong max 30v40, không cấp cùng monster cho hai trận.
3. Sau WIN, xử lý kill/HP/reward rồi chọn quái kế trên cùng map, giữ vị trí/world presentation và party continuity **chỉ khi adapter thực sự bảo toàn state hợp lệ** (HP, cooldown, skill stacks, target/cast, RNG, cursor). Không reset HP/cooldown miễn phí giữa trận, không dịch chuyển tức thời. Nếu chưa bảo đảm, ghi là **bridge gap**, không giả lập liền mạch.
4. TIMEOUT/DEFEAT đi qua terminal Injury/retreat và policy; không tự tạo WIN/loot.
5. Ở bước nâng cao, muốn **quái spawn vào ngay giữa combat** hoặc hai đội cùng đánh một Boss theo thời gian thực thì cần mở rộng riêng combat-world interaction, kiểm tra kernel/event contracts và approval; không sửa `MapBattleV2` âm thầm.

**Semantics “continuous”:** nghĩa là duty/zone của đội tồn tại và tự tạo các lần giao chiến hợp lệ nối tiếp; không đồng nghĩa một object battle bất tử hoặc loot tự rơi khi map không render.

### E3. Hai thang thời gian: V2 phút và combat giây

- Current: scheduler một phút/lần; battle `0.25` giây/lần. Không nhân tuỳ ý `1 kill = 1 minute` hoặc `1 monster = 1 offline minute`.
- **Hướng đề xuất:** một timeline authoritative từ runtime clock, battle sử dụng **substep 0.25-second fixed point** trong ngân sách thời gian đã tiến, tích lũy carry qua biên một phút. Timer kinh tế xử lý đúng mốc phút; travel/engagement/cast/respawn có timestamp trên cùng timeline (minute + substep hoặc fixed integer quarter-seconds; schema quyết định sau).
- Khi 60 wall seconds trôi: tối đa **240 combat substeps 0.25s được cấp** cho một trận đang chạy, nhưng không được coi là 240 tác vụ/sản lượng. Đệ tử bận hunt không đồng thời kiếm production work theo scheduler.
- Combat diễn ra song song giữa **các team hợp lệ** trong thế giới cùng timeline, không trừ thời gian toàn game hai lần. Một team chỉ một duty/engagement đang hoạt động.
- Online và offline dùng cùng thứ tự sự kiện, RNG nguồn và ngân sách thời gian; offline có thể xử lý sự kiện cấp tốc hoặc bounded replay tương đương. Không lấy `elapsed × average_drop` để mint tài nguyên khi không có kill.
- **OPEN GATE:** hợp đồng substep ↔ scheduler chính xác, policy khi app tắt nửa trận, limit offline catch-up, hiệu năng 1.000–3.000, save timing. Đây là blocker production, không phải thành quả B2.4 sandbox.

### E4. Spawn, nhiều đội, Boss và map lớn

- Một `MonsterSlot` có một generation đang sống tối đa, death once; respawn deadline tính từ authority chứ không từ sprite/VFX. Chỉ active zones có actor-level update; vùng tắt chỉ cần countdown/event cursor, không farm từ không khí.
- Một monster spawn không thể bị hai đội quyết toán độc lập. **Mob lease** cấp tới một encounter, trả lease khi terminal; eventual Boss cooperation/assist needs a separately approved damage+reward-sharing contract.
- Các quái cùng loài có slot/generation độc lập; giết hai con cùng lúc có hai receipts. DoT/AoE/projectile event order canonical, không lọc từ capped UI events.
- **30 disciples / 40 monsters** là hard cap **trên một `MapBattleV2`**, không được nhầm là trần tông môn 30 người vĩnh viễn; nhiều teams active phải chứng minh budgets/CPU/memory và fair spawn arbitration.
- **30 vùng realm ×10 cụm** hiện là **content projection**, không phải 300 vùng đã code; engine data-driven có phân tầng `realm_band → region → cluster → spawn_pool`, lazy instantiate và ID stable. Map chibi 192×192 hiện là quy mô bản đồ presentation khác hoàn toàn content progression.
- Boss rarity/release, ownership/quyền tham gia, reset interval, server-like global/world rare quotas: OPEN. Không bịa tỷ lệ hoặc giới thiệu “world boss” như tính năng đã có.

## F. Reward production — ONE kill, ONE eligible payout, MANY channels

### F1. Ngăn 3 payout paths gây nhân ba đồ

| Mode | Code/reward authority | Rule |
|---|---|---|
| `LEGACY_AUTONOMOUS_P2` | `SimulationScheduler` + `CombatSystem.resolve_encounter` + pending inventory | Giữ save cũ; không đồng trả V2/B3 per-kill. |
| `LEGACY_V2_ENCOUNTER` | `HuntingMapV2.claim_reward` after WIN + encounter receipt | Giữ 4-win `linh_tuy`, reward theo lần thắng, chưa phải mỗi monster. |
| `B3_PER_KILL` (FUTURE) | authoritative verified HP lethal → receipt → one canonical settlement | Không gọi hai path trên cho cùng battle/kill; opt-in sau migration, content production đã duyệt. |

Không thực hiện migration/reinterpreting pending loot hay legacy receipts một cách ngầm. Đội cũ đang dở battle phải hoàn thành/settle theo old authority hoặc explicitly orchestrated migration có tests.

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

Orthogonal **control state** `ACTIVE | PAUSE_REQUESTED | PAUSED | BLOCKED | STOP_REQUESTED | CANCELLED`, không nhập trộn với battle outcome `WIN | DEFEAT | TIMEOUT`.

- Trước khi deploy: pure eligibility preflight team IDs, One Active Job, Injury=0, HP, active battle lease, zone unlocked, actual target content, supply requirements.
- `SEARCH` dựa spawn availability/source and world travel, không giả mob “mỗi tick” nếu không có slot. 
- `ENGAGE`: Combat V2 alone. Combat V2 determines kill/outcome.
- `SETTLE`: freeze valid receipt, durable commit; no double pay via old claim.
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
8. After WIN, continuous encounter bridge preserves legal party HP and next battle readiness; after TIMEOUT/DEFEAT it follows Injury/retreat, does not fake WIN.
9. FarmOrder target uses actual usable Warehouse, not raw stock; material-ready ≠ gear-crafted ≠ gear-assigned.
10. One fully authored forge order consumes canonical resources once at real finish tick, creates one Sect-owned unique item, respects player locks and existing pilot compat.
11. Load older save version 2 unchanged; opt-in new B3 state never reclaims old completed encounter; versioned explicit migration.
12. Performance smoke one team, five teams, many regions, 30v40 battle and 1.000–3.000 background roster **after** correctness; no product scalability claim from static QA.

**QA philosophy:** test focused at each packet; cross-subsystem regression when changing Save/Scheduler/Combat; only name PASS with Godot official output. Source A converter QA is a *separate*, simplified overnight workflow; B3 will not trigger it.

## K. Phân rã gói triển khai đề xuất (TẤT CẢ CHƯA ĐƯỢC PHÊ DUYỆT CODE)

| Packet | Outcome kiểm chứng | Dependency / scope |
|---|---|---|
| **B3-V2-D0 DESIGN** | Đặc tả này + graph audit + cơ chế open decisions. | Docs-only, thực hiện được ngay. |
| **B3-V2-C0 WORLD/TIME CONTRACT** | Design freeze single clock, encounter bridge, world slots, team leases, online/offline proof fixtures. | Sau khi review B2.4 ZIP hiện hành. Có thể viết pure model trước nhưng cần approved allowed paths để CODE. |
| **B3-V2-C1 ONE REAL KILL** | Opt-in one zone/one team/per-mob live authoritative lethal → production source → one ReceiptEnvelope + Warehouse/character grants → same SaveService. | One integration writer for Combat/State/Save/Warehouse; preserve old modes and data. **Không public payout trước.** |
| **B3-V2-C2 CONTINUOUS DUTY** | Same persistent zone and team seamlessly move between legal V2 battles/slots; patrol, HP/supplies, return/recover, no free cooldown reset; UI live projection. | C0/C1 and Combat bridge proof; explicit pilot only. |
| **B3-V2-C3 POLICY TEAM AI** | Default continued hunting + per-team/sect risk/rotation/goal, resume, optional FarmOrder; no job stealing. | Workforce/Organization/safety focused gates. |
| **B3-V2-C4 GROWTH REWARDS** | Tu Vi/mastery/Contribution/sect+personal stones attributed to valid participants exactly once, challenge scale; test old migration. | C1 and authorized progression rate policy; don't mutate old P2 gains silently. |
| **B3-V2-C5 GEAR/CRAFT BRIDGE** | First real source → one actual forge order/timer or drop unique → allocate gear without dup; basic materials from production still needed. | Owner-approved forge transaction, new content IDs/recipes. |
| **B3-V2-C6 EQUIPMENT V2 MIGRATION** | 10-slot/12-grade/24-set legality; old items preserved; real Combat/stat/work consumers; auto-equip set-aware. | Dedicated allowlist, migration, separate focused+cumulative tests. |
| **B3-V2-C7 WORLD/CONTENT SCALE** | Data-driven regions/clusters, multiple teams/contested Boss, offscreen equivalence/performance; Android 1280×720 measurable. | After real one-team loop; 30×10 target is content plan, not C1 scope. |
| **B3-V2-C8 BALANCE** | Drop/progression/craft-rate simulation, p50/p90/p95 first useful upgrade, Boss chase variance, injury/downtime, production vs hunt economy. | Requires actual gameplay telemetry and owner approval of rates. |

**Khuyến nghị thực thi:** chỉ 1 CODE writer chạm shared combat/state/save/scheduler, một design/QA researcher độc lập; không chạy B3 Godot đồng thời với heavy Source A trên Windows 8 GB. B2.4 đang sandbox không tự nhận là B3-C1; phải review exact worktree/ZIP trước khi code.

## L. Owner decisions còn MỞ (không tự chốt)

| Câu hỏi | Khuyến nghị thiết kế, CHƯA LOCK |
|---|---|
| Duty mặc định | **CONTINUOUS_HUNT**, có policy đổi vùng/nghỉ, không “đủ 3 nguyên liệu thì dừng”. |
| Auto tiếp tục sau hồi phục | Bật theo team policy sau recovery hợp lệ, có giới hạn rủi ro và nguồn cung, không tự vượt Injury 1. |
| Boss tranh chấp | V1: một lease/encounter, không hai team double-kill cùng slot. Cooperative boss riêng về sau. |
| Seamless combat thật | V1: bounded `MapBattleV2` nối tiếp, world duty/state liên tục; validate state continuity trước khi tuyên bố seamless; in-combat spawn là scope riêng. |
| Offline farm | Replay cùng authoritative time với cap xử lý/progress ledger; limit accrual và backlog sau kiểm chứng, không thả quyền “offline = x monsters” tùy ý. |
| Gear source mix | Cả direct drop, material forge và Boss chase; không Boss-only hoặc forge-only. |
| Reward split / drop / rarity / forge | Không tự khóa tỷ lệ; legacy pilot số hiện tại giữ trong legacy mode; production B3 phải owner duyệt. |
| 30 realm regions ×10 clusters | Giữ làm target hướng content, nhưng implementation data-driven, tier gating soft/validated và lazy loading. |
| UI complexity | Overview đội/chính sách + chỉ báo farm/hồi phục/đồ rơi; chi tiết mở drilldown. Không 1.000 actor per screen. |

## M. Điều kiện CHẤP THUẬN thiết kế trước khi phát CODE

Owner duyệt/cập nhật tối thiểu: (1) “săn liên tục” là duty mặc định với stop/auto-return đúng; (2) online/offline authoritative time bridge; (3) per-kill + personal growth reward segmentation; (4) nguồn item direct-drop + forge; (5) nhóm/đội và Boss tranh chấp; (6) chỉ định một integration owner và packet allowlist, migration + regressions. **Duyệt kiến trúc không đồng nghĩa cấp phép code.**

**Proof status:** Đã đọc từ GitHub `main` và các design spec, chưa mở chạy Godot, chưa kiểm chứng save hiện hành trên máy owner, chưa đo drop/gameplay, chưa có production B3 per-kill content. V5.1/Character Studio HOLD, Codex SA-LIB không bị ảnh hưởng.

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
