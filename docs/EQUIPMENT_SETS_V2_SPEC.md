# ĐỒ BỘ V2 — 24 DÒNG, MA TRẬN 4 MÓN, MỐC 2/3/4

Updated: 2026-10-08
Status: **USER-APPROVED DESIGN STRUCTURE — NOT IMPLEMENTED**.
Primary gear authority: `docs/WEAPON_EQUIPMENT_V2_SPEC.md`. This file supersedes the old 5-slot/2+3-only set design in `docs/WEAPON_EQUIPMENT_V2_REALM_MAP_SET_MATRIX.md`. Names of individual items are working names and may be polished without affecting slot/lineage identity. Numeric coefficients, material IDs, drop and crafting rates are not locked.

## 1. Set law: stat identity, not a second skill system

**Six eligible positions only:** M=Mũ, G=Giáp, P=Phi Phong, U=Hộ Uyển, D=Đai Lưng, X=Giày. Vũ Khí, Thủ Sáo, Ngọc Bội, Nhẫn remain free. Every set lineage has **exactly four distinct authored positional pieces**. 18 combat lineages + 6 profession lineages = 24 sets × 4 = **96 distinct position-templates** before realm/quality versions.

**2 pieces:** identity base. **3 pieces:** more specialized statistics. **4 pieces:** strongest focused statistics/conditional effect modifiers matching the set's name. Bonuses **accumulate**; no automatic new summon, sword echo, autonomous retaliatory action, revive, shield creation, skill or `Chân Văn Cộng Hưởng` from matching pieces. Chân Văn is only the **individually rolled/inscribed** rare system (not a set requirement).

Allowed **4+2**, **3+3** (BOTH families' 2- and 3-piece bonuses remain active), **2+2+2**, **3+2+1**, etc. An item has one lineage and counts once in its occupied position. In this stat-based design, there is **no rule that disables the second 3-piece bonus**. Same-channel percentage adds follow canonical aggregation. Only genuine party-wide shared auras use strongest-only/shared caps.

Match by `set_lineage_id`, generation and equipped enabled item ID. Mixed individual **qualities** allowed. Mixed **realm tiers within same generation** allowed: tier-scaled effect of a threshold is limited by **the weakest participating item's tier**, not the strongest; no free top-tier effect from cheap pieces. Mixed Nhân/Tiên/Thần pieces **do not count as one set generation**. When upgrading, accumulate a successor in Sect Warehouse then swap coherent group; don't let AI downgrade a completed set by equipping one isolated higher-generation piece.

## 2. All 18 combat sets: exact item-position matrix

| Set lineage | Four individual items and slots |
|---|---|
| **Sát Tinh** | Mũ: Sát Tinh Quan; Phi Phong: Phi Tinh Phi Phong; Hộ Uyển: Trảm Tinh Uyển; Giày: Lưu Tinh Ngoa |
| **Phá Cương** | Giáp: Phá Cương Giáp; Hộ Uyển: Phá Phong Uyển; Đai Lưng: Đoạn Cương Đái; Giày: Toái Sơn Ngoa |
| **Huyết Chiến** | Giáp: Huyết Chiến Giáp; Phi Phong: Xích Huyết Phi Phong; Hộ Uyển: Huyết Nộ Uyển; Đai Lưng: Huyết Nộ Đái |
| **Truy Phong** | Mũ: Phong Ảnh Quan; Phi Phong: Truy Phong Phi Phong; Đai Lưng: Lưu Phong Đái; Giày: Thiên Phong Ngoa |
| **Thiên Kích** | Mũ: Thiên Kích Quan; Hộ Uyển: Liên Kích Uyển; Đai Lưng: Chiến Linh Đái; Giày: Tật Ảnh Ngoa |
| **Trấn Yêu** | Mũ: Trấn Yêu Quan; Giáp: Phục Yêu Giáp; Hộ Uyển: Liệp Yêu Uyển; Đai Lưng: Phục Ma Đái |
| **Hộ Sơn** | Mũ: Hộ Sơn Quan; Giáp: Trấn Sơn Giáp; Hộ Uyển: Thạch Linh Uyển; Đai Lưng: Bất Động Đái |
| **Tịnh Thần** | Mũ: Tịnh Thần Quan; Giáp: Tịnh Tâm Bào; Phi Phong: Thanh Tịnh Phi Phong; Đai Lưng: Trấn Niệm Đái |
| **Thiên Trận** | Mũ: Trận Linh Quan; Giáp: Thiên Trận Giáp; Phi Phong: Hộ Trận Phi Phong; Hộ Uyển: Liên Trận Uyển |
| **Phản Kiếm** | Mũ: Hộ Kiếm Quan; Giáp: Thủ Kiếm Giáp; Hộ Uyển: Phản Kiếm Uyển; Giày: Trấn Kiếm Ngoa |
| **Huyết Liệp** | Giáp: Liệp Huyết Giáp; Phi Phong: Huyết Ảnh Phi Phong; Đai Lưng: Huyết Khí Đái; Giày: Truy Huyết Ngoa |
| **Thanh Linh** | Mũ: Thanh Linh Quan; Phi Phong: Hồi Xuân Phi Phong; Đai Lưng: Tụ Sinh Đái; Giày: Linh Bộ Ngoa |
| **Ngũ Hành** | Mũ: Ngũ Hành Quan; Phi Phong: Luân Hành Phi Phong; Hộ Uyển: Tương Sinh Uyển; Đai Lưng: Ngũ Nguyên Đái |
| **Hàn Vân** | Mũ: Hàn Tâm Quan; Phi Phong: Hàn Vân Phi Phong; Hộ Uyển: Băng Mạch Uyển; Giày: Sương Hàn Ngoa |
| **Cửu Lôi** | Mũ: Cửu Lôi Quan; Phi Phong: Lôi Vân Phi Phong; Đai Lưng: Dẫn Lôi Đái; Giày: Thiểm Lôi Ngoa |
| **Thực Cốt** | Giáp: Thực Cốt Bào; Phi Phong: Thực Cốt Phi Phong; Hộ Uyển: Thực Cốt Uyển; Giày: Thực Cốt Ngoa |
| **Huyền Ấn** | Mũ: Huyền Ấn Quan; Giáp: Trấn Ấn Bào; Phi Phong: Mặc Ấn Phi Phong; Đai Lưng: Phong Ấn Đái |
| **Hỗn Độn** | Giáp: Hỗn Độn Giáp; Phi Phong: Hư Không Phi Phong; Hộ Uyển: Quy Nguyên Uyển; Đai Lưng: Hỗn Nguyên Đái |

## 3. Six profession sets: exact item-position matrix

| Set lineage | Four individual items and slots |
|---|---|
| **Thiên Công** | Mũ: Khí Sư Quan; Giáp: Khí Lô Phòng Y; Hộ Uyển: Luyện Khí Hộ Uyển; Đai Lưng: Thiên Công Đái |
| **Đan Tâm** | Mũ: Đan Tâm Quan; Giáp: Đan Sư Pháp Bào; Phi Phong: Dược Hương Phi Phong; Đai Lưng: Hỏa Hầu Đái |
| **Mộc Linh** | Mũ: Linh Thực Quan; Phi Phong: Thanh Mộc Phi Phong; Đai Lưng: Dưỡng Thổ Đái; Giày: Điền Hành Ngoa |
| **Địa Mạch** | Giáp: Thám Khoáng Giáp; Hộ Uyển: Tạc Mạch Uyển; Đai Lưng: Khoáng Tâm Đái; Giày: Địa Mạch Ngoa |
| **Phù Văn** | Mũ: Phù Sư Quan; Phi Phong: Linh Mặc Phi Phong; Hộ Uyển: Khắc Phù Uyển; Đai Lưng: Tàng Phù Đái |
| **Thiên Cơ** | Mũ: Trận Sư Quan; Giáp: Hộ Trận Bào; Phi Phong: Thiên Cơ Phi Phong; Hộ Uyển: Bố Trận Uyển |

## 4. Combat set bonuses — Nhân baseline (no free skills)

| Set | 2 pieces | 3 pieces | 4 pieces |
|---|---|---|---|
| Sát Tinh | Bạo Kích | Sát thương Bạo Kích | Sát thương kỹ năng trực tiếp gây Bạo Kích |
| Phá Cương | Xuyên Phòng | Sát thương lên mục tiêu bị giảm Phòng Ngự | Sát thương lên mục tiêu có Phòng Ngự cao hoặc Hộ Thuẫn |
| Huyết Chiến | Công Kích và HP | Sát thương khi HP bản thân thấp | Giảm Sát Thương khi HP bản thân thấp |
| Truy Phong | Tốc Di Chuyển và Thi Pháp | Hiệu quả kỹ năng Phong hoặc kỹ năng cơ động đã sở hữu | Hiệu quả kỹ năng sau đổi vị trí bằng kỹ năng hợp lệ |
| Thiên Kích | Tốc Đánh Thường | Sát thương Đánh Thường | Bạo Kích và Sát thương trực tiếp từ Đánh Thường |
| Trấn Yêu | Sát thương lên Tinh Anh/Boss | Kháng Hiệu Ứng trong trận Tinh Anh/Boss | Hiệu quả kỹ năng trực tiếp vs Tinh Anh/Boss |
| Hộ Sơn | HP và Phòng Ngự | Giảm Sát Thương trực tiếp | Chống chịu đòn trực tiếp mạnh hợp lệ |
| Tịnh Thần | Kháng Hiệu Ứng | Giảm ảnh hưởng/thời lượng khống chế hợp lệ | Chống nhóm phong ấn/khống chế đúng cấp |
| Thiên Trận | Hiệu quả Hộ Thuẫn | Hộ Thuẫn do mình tạo cho đồng đội | Hiệu quả Hộ Thuẫn nhóm từ kỹ năng đã có |
| Phản Kiếm | Phòng Ngự và hiệu quả Kiếm kỹ phòng thủ | Sát thương kỹ năng Phản Kiếm đã sở hữu | Hiệu quả kỹ năng Hộ Kiếm và Phản Kiếm |
| Huyết Liệp | Sát thương trực tiếp và Nhận Trị Liệu | Sát thương lên mục tiêu HP thấp | Hiệu quả nguồn hồi phục thực tế đã sở hữu trong chiến đấu |
| Thanh Linh | Hiệu quả Trị Liệu | Trị Liệu cho đồng đội HP thấp | Hiệu quả Hộ Thuẫn và Trị Liệu kỹ năng hỗ trợ nhóm |
| Ngũ Hành | Hiệu quả kỹ năng Ngũ Hành | Hiệu quả Tương Sinh cá nhân hợp lệ | Hiệu quả kỹ năng trong tương khắc hợp lệ |
| Hàn Vân | Thủy/Băng và Chính Xác Hiệu Ứng phù hợp | Thời lượng Làm Chậm/Hàn Trệ hợp lệ | Sát thương Thủy/Băng lên mục tiêu đang chịu trạng thái lạnh |
| Cửu Lôi | Hiệu quả Lôi kỹ | Bạo Kích của Lôi kỹ trực tiếp | Sát thương Bạo Kích của Lôi kỹ trực tiếp |
| Thực Cốt | Hiệu quả sát thương duy trì (DoT) | Thời lượng DoT hợp lệ | Sát thương kỹ năng trực tiếp lên mục tiêu đang chịu DoT bản thân |
| Huyền Ấn | Chính Xác Hiệu Ứng | Thời lượng debuff hợp lệ | Hiệu quả kỹ năng lên mục tiêu có debuff do mình áp dụng |
| Hỗn Độn | Kháng nhiều nguyên tố | Giảm Sát Thương từ kỹ năng nguyên tố | Chống chịu nhiều nguyên tố và tương khắc qua kênh đã có |

Definitions: any bonus "under a condition" is a **filtered stat channel** applied to a real combat outcome, not an independent proc. Skill names/tags, valid target and combat actor must be real. Phản Kiếm deliberately supports trained Hộ Kiếm/Phản Kiếm style rather than every weapon. Huyết Chiến checks wearer HP; Huyết Liệp checks enemy HP and a real existing healing source. Sát Tinh emphasizes crit-based direct **skills**; Thiên Kích emphasizes **basic attacks**. Hộ Sơn wearer durability differs from Thiên Trận shield-skill specialization and Thanh Linh healing specialization. Tịnh Thần defends vs negative effects; Huyền Ấn boosts owned debuffs. Thực Cốt is general DoT, no invented poison element. Trấn Yêu uses existing Elite/Boss encounter tags, not an imaginary Boss-break meter.

## 5. Generation: Nhân / Tiên / Thần

Existing 2/3/4 identity is **inherited**, then made stronger through realm tier scaling and deeper **existing-channel** specialization. No compulsory new spell at Tiên or Thần; no free skill evolution from wearing higher gear. Only Nhân item realm tiers 1..10, Tiên 11..20, Thần 21..30. Within each generation, per-realm equipment base varies. Higher-quality grade remains independent. **Hỗn Độn is reserved for Thần only.**

| Set | Tiên additional specialization | Thần additional specialization |
|---|---|---|
| Sát Tinh | Chuyên hóa Bạo Kích của kỹ năng trực tiếp | Chuyên sát thương trực tiếp gây Bạo Kích lên mục tiêu khó |
| Phá Cương | Khai thác trạng thái giảm Phòng Ngự/Hộ Thuẫn | Chuyên phá mục tiêu phòng thủ mạnh, không xóa toàn bộ phòng thủ Boss |
| Huyết Chiến | Tăng hiệu quả Nhận Trị Liệu ở HP thấp | Tăng độ bền và sát thương khi nguy cấp; không tự gây thương để lấy thưởng |
| Truy Phong | Cường hóa Cast/Cooldown của kỹ năng cơ động thực | Chuyên phối nhịp thi pháp và di chuyển; không có tàn ảnh tự đánh |
| Thiên Kích | Cường hóa sát thương trực tiếp Đánh Thường | Chuyên nhịp đánh thường liên tục lên cùng mục tiêu, không tự thêm đòn |
| Trấn Yêu | Chuyên đánh Boss kéo dài | Tấn công và phòng thủ trước Boss, không thêm thanh Phá Thế giả |
| Hộ Sơn | Thêm kháng nguyên tố theo mẫu | Chuyên sống sót trước đòn mạnh và Boss, không miễn tử |
| Tịnh Thần | Chuyên kháng khống chế Tiên phù hợp | Chuyên kháng khống chế Thần phù hợp, không tuyệt đối miễn nhiễm |
| Thiên Trận | Tăng hiệu quả kỹ năng tạo Shield nhóm | Chuyên Shield nhóm trước đòn mạnh, không tự dựng kết giới |
| Phản Kiếm | Chuyên Kiếm phòng thủ Tiên | Tối ưu Hộ Kiếm/Phản Kiếm Thần, không tự phản đòn |
| Huyết Liệp | Chuyên săn mục tiêu trọng thương | Chuyên chiến đấu kéo dài, không cấp Hút Máu chung |
| Thanh Linh | Chuyên hồi phục nhiều người khi kỹ năng gốc hỗ trợ | Chuyên Y Đạo Thần hỗ trợ nhóm, không tự hồi sinh |
| Ngũ Hành | Chuyên chuỗi Tương Sinh có thật | Tương Sinh/Tương Khắc đã thực sự được kỹ năng kích hoạt, không yêu cầu năm căn |
| Hàn Vân | Chuyên Hàn Trệ có nguồn rõ | Chuyên khống chế mềm Boss trong luật cấp hiệu ứng, không đóng băng vĩnh viễn |
| Cửu Lôi | Chuyên Bạo Kích kỹ năng Lôi | Chuyên Lôi trực tiếp Bạo Kích, không tự triệu Thiên Lôi |
| Thực Cốt | Chuyên nguồn DoT thực sự | Chuyên áp lực DoT hợp lệ, không tự tạo nguyên tố Độc |
| Huyền Ấn | Chuyên duy trì suy yếu hợp lệ | Chuyên khai thác debuff cao cấp, không cấp phong ấn |
| Hỗn Độn | Không có Tiên Bộ | Chỉ Thần Bộ; không miễn nhiễm/phá pháp tắc, không tạo cơ chế Boss mới |

For Hỗn Độn, "reduce elemental matchup disadvantage" is **not an unconditional rewrite of the Ngũ Hành counter system**: keep effects on existing elemental-resistance/incoming-damage channels unless a properly authored canonical matchup modifier is approved. Neither Thần Bộ nor a high-quality item automatically upgrades a Nhân-tier hard-control/cleanse/seal to Thần tier.

## 6. Profession set bonuses (only real consumers)

| Set | 2 pieces | 3 pieces | 4 pieces |
|---|---|---|---|
| Thiên Công | Tốc độ Luyện Khí | EXP nghề Luyện Khí | Tăng tốc công đoạn rèn công thức khó hợp lệ |
| Đan Tâm | Tốc độ Luyện Đan | EXP nghề Luyện Đan | Tốc độ mẻ đan phức tạp hợp lệ |
| Mộc Linh | Tốc độ Linh Thực | EXP nghề Linh Thực | Hỗ trợ một lần kiểm tra thu hoạch may mắn thật |
| Địa Mạch | Tốc độ Khai Khoáng | EXP nghề Khai Khoáng | Tốc độ mạch khoáng khó |
| Phù Văn | Tốc độ Chế Phù | EXP nghề Chế Phù | Tốc độ công thức phù phức tạp |
| Thiên Cơ | Tốc độ nghề Trận Pháp khi consumer tồn tại | EXP nghề Trận Pháp khi consumer tồn tại | Hiệu quả thời gian công việc trận khó; consumer-gated |

| Set | Tiên | Thần |
|---|---|---|
| Thiên Công | Công thức Tiên hợp lệ | Công thức Thần hợp lệ, không tự nâng phẩm 12 |
| Đan Tâm | Công thức Tiên hợp lệ | Công thức Thần hợp lệ, chưa tạo phép nâng phẩm |
| Mộc Linh | Hỗ trợ crop hợp lệ ở Tiên | Hỗ trợ lucky roll chu kỳ Thần, không tăng lượt thu hoạch |
| Địa Mạch | Mạch khoáng Tiên hợp lệ | Mạch khoáng Thần; kiểm tra quặng quý chỉ khi hệ Mỏ có roll thật |
| Phù Văn | Công thức phù Tiên | Công thức phù Thần, không tự tạo phù quý |
| Thiên Cơ | Chờ nghề Trận Pháp thật | Chờ nghề Trận Pháp thật, không tự tạo trận/chế phẩm |

Work sets never give generic double routine yield for profession speed or unlimited rare rolls. Profession XP and work speed are existing canonical modifier channels. **Consumer-gated:** a real profession task and a known check must exist. Mộc Linh lucky-harvest bonus is sampled per live Linh Điền crop cycle (not an extra harvest). Địa Mạch rare-ore result is gated until Mine actually has the roll. Đan Tâm/Thiên Công/Phù Văn high-grade result bonuses require a complete product-quality consumer; neither 4-piece bonuses nor Thần progression guarantee a Chí Tôn product. Thiên Cơ high-rank bonuses await a real Trận Pháp work action. Item instance assignment to a real worker prevents sharing a snapshot bonus across a thousand concurrent jobs.

## 7. Legal six-position loadouts checked against matrix

| Arrangement | Legal pieces | Active thresholds |
|---|---|---|
| 4+2 | Hộ Sơn M/G/U/D + Truy Phong P/X | Hộ Sơn 2+3+4; Truy Phong 2 |
| 3+3 | Sát Tinh M/P/X + Hộ Sơn G/U/D | **Both sets** 2+3 |
| 2+2+2 | Sát Tinh M/P + Hộ Sơn G/U + Huyết Liệp D/X | Three separate 2-piece |
| 3+2+1 | Sát Tinh M/P/U + Hộ Sơn G/D + free X | Sát Tinh 2+3 and Hộ Sơn 2 |

**All four configurations passed structural legality checks** (all pieces exist in their family and no slot collision). Not every pair of arbitrary families will support a proposed configuration.

## 8. Safety and source gating

- Sources from Huyết Mạch, Thể Chất, Mệnh Cách, Linh Căn, Pháp Bảo and gear **may overlap**; use canonical typed addition/remaining damage/stack-family rules rather than a blanket overlap ban.
- Damage Reduction and elemental resistance compose on remaining incoming damage; don't sum to total immunity. Crit Chance and Effect Hit use their existing semantic percentage-point formulas; DoT/reflect/proc are not secretly crit-enabled.
- Role-conditional bonuses use actual skill tags/target statuses/HP and explicit range; if the necessary skill/consumer doesn't exist, that row is **content-gated**, not faked in the game UI.
- Buffs for multiple party members need existing shared effect family policy; do not multiply six copies of a named team aura without stated cap. The sets themselves do not produce new auras by default.
- 100% Sect-owned items, auto-equip by *complete* set outcome (not individual item stat), lock/reserve and staging for upgraded successors.
- Generic repeatable recipe/drop path for basic set progression; targeted Elite/Boss/Bí Cảnh for chase variants. Exact 30-realm material/recipe IDs, probability pools and authored Boss sources **remain OPEN**, as does the 30-main-map projected quantity.
- Benchmark 3+3 vs 4+2; all numeric %/base values remain pending RealmBodyCore Attack/Defense/HP and final equipment share.

## 9. Status boundary

**LOCKED USER DIRECTION:** 24 roles (18 combat + 6 work), four positional items per set, six eligible gear slots, cumulative 2/3/4 bonuses, 3+3 both active, three generations preserve named style and add specialization with rising realm tier, and NO free combat mechanics or set Chân Văn. Item qualities/affix capacities belong to the gear spec.

**NOT LOCKED:** exact line percentages, final item names and loot pools, per-realm stat coefficients, recipes and drop rates, profession quality/rare consumers not implemented, specific balance thresholds and Godot V2 runtime. The prior Chân Văn Cộng Hưởng design is **abandoned**, not an alternate authority.
