# V63-P1 — 41 cặp chủ động/tuyệt kỹ: contract phân biệt truyền thừa A/B

## Execution update — 2026-11-14

- PR #72 code commit: `f83328a57dea0eb1f8765479327292773ba2dbd0`; exact tested commit: `796646ba94453762bb0d6dede093289a4fbbde2e` (Git tree `9309ae42a4e2ae495289baa0bf0e1fe8d090eac3`); latest fetched base: `8cdbff4bb520f6742b4cc6603a9d7ef66ff32f90`. The two commits since the prior fetch are separate Codex B VFX POI-02 R4 work and were preserved without file overlap.
- **P1:** 41 approved non-numeric lineage A/B policies / 82 IDs pass 1,447 deterministic checks using actual Combat V2 cast/release/effect receipts. Shape, cap, canonical resolver and numeric values unchanged. Lôi Phù radius-zero line matching uses the existing declared range.
- **P2:** 196 runtime-equal pairs, no differences/missing in 796 checks. Classification stays `OWNER_APPROVAL_PENDING`; no new shared-design or balance decision was inferred.
- **Godot:** official `4.7.2.stable.official.ed1daf0bf`, binary SHA-256 `AB1824F85BFD8E0E4128182C000C4003A3E042245B2967848D089B2A04B22424`; strict import and 23 focused/cumulative runs exit 0. Exact logs are in `logs/exact_796646ba/`; summary is `V63_EXACT_SHA_QA_MATRIX_20261114_FINAL.csv`.
- **S9:** 2,675 checks; all three branches summon real actors and use Combat V2 attacks; three GodotViewport 1280×720 captures. They are sparse technical silhouettes, not art approval or physical GUI acceptance (`OWNER_VISUAL_PENDING`).
- V6.3 stays OFF. No VFX production asset/renderer, SaveService, economy, manual or numeric combat balance edited by the V63 implementation. User save untouched; Save/Reload used isolated QA APPDATA/LOCALAPPDATA. Windows certificate-store warning persists but no parse/compile/load/shader error was found.
- **Pending:** P2 design intent, owner visual review, physical Windows GUI, Android and CI exact-SHA. Not release-ready.
**Ngày lập contract:** 2026-11-13. **Trạng thái lịch sử lúc lập:** `DESIGN_PROPOSED / OWNER_APPROVAL_PENDING / NOT_IMPLEMENTED`; bản triển khai/QA mới nhất nằm ngay dưới đây.

## Phạm vi và những gì đã làm
- Rà lại các cặp P1 theo **cùng family + slot + tier + variant_type + rarity** để không ghép rare với Divine thường.
- **41 cặp P1** (Chưởng 24, Phù 11, Triệu Hồi 6), có đúng ID từng biến thể A/B trong `LINEAGE_P1_BEHAVIOR_CONTRACTS.json`; không có cặp nào bị bỏ trống.
- Cung cấp 9 contract cấp nhánh, triển khai xuống 41 cặp cùng effect/shape/target cap **đang có**. Phần phân biệt là **đề xuất policy chọn mục tiêu hoặc thời điểm cast**, không phải hiệu ứng hiện hành.
- Bất kỳ thay đổi target order, cast gate hoặc support policy dù **không chỉnh numeric** vẫn có thể thay đổi DPS, sustain hoặc kiểm soát; vì vậy **chưa viết vào Combat V2/AI** khi chưa được owner duyệt.
- **Đã sửa nội dung chắc chắn sai:** Chưởng Liệt Dương (mô tả A/B đảo ngược), Chưởng Hàn Ngọc (kể nhầm lineage tạo vùng), Phù Hỏa (kể sai hướng AOE B), Phù Phong Ấn (A/B phân bố vùng/single). Tổng cộng 5 đoạn lore/description trong 2 catalogue; đồng bộ phần lore của presentation và liên kết Git blob SHA của registry/presentation.
- **Không đổi bất kỳ một skill definition** (damage_ratio, power, duration, cooldown, radius, target_limit, effect, shape, AI profile, IDs, parent, lore của skill nodes, passive modifiers). Không chỉnh SaveService, economy, VFX, feature gate hoặc nguồn manual.
- Sửa lỗi trong báo cáo `V63_DESIGN_AUDIT_20261113`: tổng trùng cặp đã hiệu chỉnh **237**, trong đó **41 P1 + 196 P2**; nguyên nhân báo cáo trước ghép sai `rare.a` với `divine.b`.

## Thiết kế đề xuất cấp nhánh (chưa kích hoạt)
| Hệ | Nhánh | A | B | P1 | Cơ chế hiện có giữ nguyên |
| --- | --- | --- | --- | ---: | --- |
| Chưởng Tu | Liệt Dương | Dương Ấn | Kim Ô | 9 | damage / single_target, circle |
| Chưởng Tu | Hàn Ngọc | Băng Tâm | Hàn Nguyệt | 9 | damage, slow / single_target, circle |
| Chưởng Tu | Hồi Phong | Thanh Phong | Từ Huyền | 6 | heal, cleanse, guard / single_target |
| Phù Tu | Lôi Phù | Dẫn Lôi | Tàng Lôi | 6 | damage, mark / single_target, line |
| Phù Tu | Hỏa Phù | Liên Diệm | Tụ Diệm | 4 | damage / single_target |
| Phù Tu | Phong Ấn Phù | Khép Giới | Lưu Phù | 1 | cleanse / single_target |
| Triệu Hồi | Kiếm Linh | Kiếm Tâm | Cổ Khế | 2 | guard / single_target |
| Triệu Hồi | Linh Thú | Hữu Tín | Sơn Linh | 2 | guard / single_target |
| Triệu Hồi | Khôi Lỗi Hộ Pháp | Hộ Mạch | Thiên Cơ | 2 | guard / single_target |
| **Tổng** | **9 nhánh** | | | **41** | |

### Liệt Dương — Dương Ấn / Kim Ô (9 cặp)
- **Policy A đề xuất:** Dương Ấn: ưu tiên cụm kẻ địch hợp lệ ở gần trọng tâm giao chiến khi kỹ năng hỗ trợ hình vùng; với đòn single-target vẫn chỉ chọn một đối thủ hợp lệ.
- **Policy B đề xuất:** Kim Ô: ưu tiên kẻ địch cứng cáp/đầu đàn hợp lệ để tập trung đúng một điểm chạm; kỹ năng circle sẵn có vẫn giữ nguyên hình và target cap, chỉ đổi điểm ưu tiên.
- **Kịch bản xác nhận:** Hai mục tiêu hợp lệ có HP khác nhau và một cụm ba mục tiêu: so sánh lựa chọn A/B nhưng số hit, hình vùng, sát thương từng hit không đổi.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Hàn Ngọc — Băng Tâm / Hàn Nguyệt (9 cặp)
- **Policy A đề xuất:** Băng Tâm: ưu tiên kẻ địch đang truy đuổi nhiều đồng đội trong tầm để cắt đường áp sát; hình circle chỉ dùng khi skill đang khai báo circle.
- **Policy B đề xuất:** Hàn Nguyệt: ưu tiên mục tiêu nguy hiểm gần chủ lực để duy trì nhịp slow hữu hạn; giữ nguyên chống cộng dồn và hệ số Boss hiện tại.
- **Kịch bản xác nhận:** Hai kẻ địch đuổi hai đồng đội và một Boss: so sánh target A/B, slow hữu hạn, không khóa hành động, Boss resistance giữ nguyên.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Hồi Phong — Thanh Phong / Từ Huyền (6 cặp)
- **Policy A đề xuất:** Thanh Phong: trong tập đồng đội đủ điều kiện, ưu tiên người thiếu HP theo tỷ lệ hoặc cần giải trừ trạng thái thật; guard phải qua canonical shield.
- **Policy B đề xuất:** Từ Huyền: ưu tiên điểm hỗ trợ bảo vệ nhiều đồng đội đang bị uy hiếp khi shape cho phép circle; single-target vẫn chữa/giải trừ/guard đúng một người.
- **Kịch bản xác nhận:** Đội ba người có HP và debuff khác nhau, hai người bị tấn công: so sánh ally-selection, không overheal, không hồi sinh, không xóa Injury.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Lôi Phù — Dẫn Lôi / Tàng Lôi (6 cặp)
- **Policy A đề xuất:** Dẫn Lôi: ưu tiên đường tuyến hợp lệ xuyên nhiều địch khi skill shape=line; nếu single_target thì vẫn một đích, không thêm tia lan hay stun.
- **Policy B đề xuất:** Tàng Lôi: ưu tiên đích đã có dấu thuộc người thi triển nếu còn hợp lệ, sau đó mới chọn nearest; giữ nguyên mark/damage từ effect catalogue, không thêm khống chế.
- **Kịch bản xác nhận:** Ba địch thẳng hàng, một địch có owner mark: target/cast-line phân biệt, hit chỉ theo Combat V2, không thêm secondary hit.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Hỏa Phù — Liên Diệm / Tụ Diệm (4 cặp)
- **Policy A đề xuất:** Liên Diệm: ưu tiên vùng đông địch khi skill shape=circle, dùng cap/radius hiện hành; single_target không tự biến thành AOE.
- **Policy B đề xuất:** Tụ Diệm: ưu tiên mục tiêu đầu đàn/high-HP trong tầm để tập trung đòn; không tự gây Burn, không tăng damage/cooldown/hit_count.
- **Kịch bản xác nhận:** Cụm ba địch và một địch riêng lẻ HP cao: lựa chọn A/B khác nhau có thể quan sát, không có DoT, target cap không đổi.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Phong Ấn Phù — Khép Giới / Lưu Phù (1 cặp)
- **Policy A đề xuất:** Khép Giới: với mark theo vùng ưu tiên cụm địch hợp lệ chưa có dấu của người thi triển; cleanse phải chọn đồng đội đang có debuff thật.
- **Policy B đề xuất:** Lưu Phù: giữ dấu trên một đối thủ trọng điểm hoặc ưu tiên đồng đội chịu debuff nguy hiểm khi dùng cleanse; không xóa mark người khác, không lock skill.
- **Kịch bản xác nhận:** Hai địch có/không owner mark và hai đồng đội có debuff khác nhau: kiểm tra ownership, expiry và lựa chọn hợp lệ.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Kiếm Linh — Kiếm Tâm / Cổ Khế (2 cặp)
- **Policy A đề xuất:** Kiếm Tâm: chỉ thi triển guard khi chủ khế thực sự bị địch nhắm hoặc đang chịu đòn; guard vẫn áp dụng lên chủ khế thông qua canonical resolver.
- **Policy B đề xuất:** Cổ Khế: ưu tiên thi triển guard khi Kiếm Linh hợp lệ đang hiện diện và chủ khế bị uy hiếp; không đổi target của guard, không tạo thêm summon.
- **Kịch bản xác nhận:** Cùng một chủ khế trong trạng thái có/không có Kiếm Linh: cast guard A/B khác nhau về điều kiện, nhưng protection/expiry/hit vẫn như cũ.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Linh Thú — Hữu Tín / Sơn Linh (2 cặp)
- **Policy A đề xuất:** Hữu Tín: guard khi chủ khế bị chọn làm mục tiêu, dù linh thú chưa có mặt; bảo vệ chủ theo khế ước đã học, không thêm HP.
- **Policy B đề xuất:** Sơn Linh: ưu tiên guard khi thú hợp lệ đã tới gần điểm giao chiến và chủ đang có nguy cơ bị đánh; không thay địa hình hoặc vượt cap summon.
- **Kịch bản xác nhận:** Chủ bị nhắm ở các vị trí spawn thú khác nhau: so sánh thời điểm cast A/B, kiểm tra không tự spawn và collision an toàn.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.

### Khôi Lỗi Hộ Pháp — Hộ Mạch / Thiên Cơ (2 cặp)
- **Policy A đề xuất:** Hộ Mạch: chủ động dựng guard khi chủ khế có nguy cơ nhận đòn từ tuyến trước; không thay self-guard target hiện hành.
- **Policy B đề xuất:** Thiên Cơ: ưu tiên guard khi khôi lỗi đã có mặt ở tuyến che chắn và một địch áp sát chủ; nếu thiếu điều kiện thì không tạo guard giả.
- **Kịch bản xác nhận:** Chủ bị áp sát với/không có khôi lỗi trong tầm: deterministic cast conditions, guard expiry và cap thật.
- **Cổng:** Không nâng target cap/hit count, không thêm DoT, Burn, stun, taunt, loot, heal hay summon; không nới Boss resistance. Nếu policy không thể thực hiện với canonical target set, phải báo OWNER_DECISION thay vì giả hiệu ứng.


## Đối chiếu với Combat V2 hiện hành
- Chưởng: `V63PalmSkillCombatSystem.release_cast()` chuyển qua `V63HumanSkillCombatSystem.release_cast_base()`. Cả A/B vẫn dùng cùng `effect`/shape trong các cặp P1.
- Phù: `V63TalismanSkillCombatSystem.release_cast()` dùng cùng resolver; mark/line/guard/cleanse phải giữ ownership, target cap và lifecycle thực.
- Triệu Hồi: `V63SummonSkillCombatSystem.release_cast()` chỉ tạo summon khi `effect=summon`; **6 cặp P1 ở `active_03` là guard** và tiếp tục chạy `release_cast_base()`, không tạo summon. Điều kiện cast proposed chỉ bảo vệ **chủ khế**; không tự thêm actor hoặc mục tiêu mới.
- V6.3 OFF / skill source pending / balance pending. Dữ liệu trong JSON contract **không được đọc bởi runtime**; cấm biến chúng thành current tooltip, buff hoặc trạng thái đã phê duyệt.

## Owner approval checklist
1. Chấp nhận hay bác bỏ từng trong 9 identity contracts; cho phép khác biệt **target selection/cast timing** hay muốn thay đổi cơ chế chiến đấu khác?
2. Có cần ràng buộc AI hữu hạn khi B ưu tiên mục tiêu đã được chủ nhân đánh dấu, boss/đầu đàn, hoặc đồng đội cần cứu? Nếu không có trạng thái hợp lệ phải fallback canonical.
3. Có đồng ý để 196 cặp passive/innate chung cơ chế khi active đã khác biệt ở các chiêu khác? Riêng 1 cặp Đao rare passive cần đánh giá độc lập.
4. Chỉ sau khi duyệt mới giao packet gameplay riêng; mỗi trường hợp được test deterministic target ownership, hit receipts, cold snapshot và AI policy, không đổi công thức Combat V2, VFX hoặc SaveService.

## QA / bàn giao
- **STATIC DATA QA:** 20/20 assertion PASS cho nguyên trạng skill arrays, đồng bộ lore, registry/presentation SHA pin, 41 status `OWNER_APPROVAL_PENDING`; xem `STATIC_QA.md`.
- **OFFICIAL GODOT 4.7.2 EXACT SHA:** PENDING — container không có Godot binary, mạng không phân giải được GitHub, GitHub connector hiện không có action để dispatch workflow. Không gọi static QA là Godot PASS.
- Khi runner sẵn sàng, chạy: Godot import/strict parse → D1 → S0 → S5 Chưởng → S6 Phù → S9 Triệu Hồi → affected Combat V2/presentation regression, rồi S1–S9 cumulative nếu kết quả cho thấy phụ thuộc xuyên trường. Ghi SHA, exit code, PASS marker và log.
- Giữ PR Draft, không branch/merge; V6.3 OFF; D4A/Warehouse FAIL cũ không thay đổi; Windows GUI, Android và owner VFX approval PENDING.
