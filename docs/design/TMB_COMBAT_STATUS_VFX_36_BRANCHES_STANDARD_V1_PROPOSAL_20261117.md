# Tông Môn Bá Đạo — 36 nhánh: chuẩn thể hiện Buff/Debuff V1 (ĐỀ XUẤT)

Ngày: 17/11/2026. PR #72 Draft; nhánh `integration/pve-p0-playable-ui-20261103`. **DESIGN PROPOSAL / OWNER APPROVAL PENDING**. Không kích hoạt V6.3, không sửa gameplay, không sửa trạng thái đã duyệt hoặc SaveService.

## 1. Thực trạng được kiểm tra trong HEAD

**Chưa có hệ thống trạng thái chung hoàn chỉnh cho cả 36 nhánh.**
- Đã có `godot/labs/combat_lab/shared_poison_status/poison_status_badge.gd`: một badge nhiễm độc dùng lại trong Poison Combat Lab, hiển thị khi có poison_stacks và remaining_seconds > 0, nhưng chưa phải overlay runtime đa trạng thái.
- `godot/src/presentation/p3/b3_care_combat_v5_presenter.gd` có `active_combat_status_tags`, `active_s1_combat_status_tags`: ĐỘC, HỒI, THỦ, TRẬN, BỎNG, SUY YẾU, HỘ THỂ; render text theo tối đa 2 tag ở một số actor. Đây là text status HUD, không phải icon atlas cho 36 nhánh.
- `godot/src/presentation/p3/v63_original_combat_vfx_v1.gd` đọc `status_applied` nhưng phát animation cue ngắn kiểu tổng quát, không giải quyết trạng thái kéo dài đa loại một cách thống nhất.
- Combat V2 vẫn là authority: `godot/src/simulation/combat/map_battle_v2.gd` có `status_effects` (`burn`, `weaken`, `slow`, v.v.). `godot/src/simulation/combat/v63_human_skill_combat_system.gd` lưu `status_effects.v63_poison` (mảng stacks/owner/expiry), `v63_marks` (keyed by caster, source skill, expiry), `v63_blood_marks` (internal blood combo marks) và các timer `learned_guard_until`, `v63_capacity_shield_until`; trạng thái `mark`/slow/poison/guard có event riêng. **Không tự nhân đôi mỗi status từ event**.
- Các catalogue được kiểm tra có các `effect`: damage, mobility, passive, innate, heal, guard, mark, poison, consume_poison, cleanse, slow, formation_zone, summon. Đây là **nhãn loại kỹ năng**, KHÔNG phải 13 icon debuff hay 13 trạng thái persistent. Human S1 còn có burn/weaken.

## 2. Quy ước kiến trúc: hai lớp VFX tuyệt đối độc lập

**Lớp A — Skill/Impact VFX (riêng từng kỹ năng):** hình tượng nguồn→đường đi→va chạm, có thể rất khác nhau giữa 36 nhánh; biến mất nhanh theo timeline/receipt thực. Không dùng VFX đòn đánh làm dấu debuff 6s, không làm 36 vòng sáng treo lâu trên quái.

**Lớp B — Status HUD/Icon (dùng chung theo cơ chế):** đơn vị hiển thị là canonical gameplay status, không phải skill_id hay branch. Nhiều kỹ năng gây cùng một loại trạng thái dùng **một biểu tượng trạng thái nhất quán**; không vẽ lại mỗi skill. Buff và debuff dùng hàng/khung riêng. Trong mỗi icon có thể có số tầng/nguồn, thời gian còn lại và tooltip chính xác theo state. Không tạo hiệu ứng thứ hai từ một event.

**Thẩm quyền:** chỉ snapshot Combat V2 đang sống và thời gian `battle.now` quyết định có/không có icon, stacks và expiry. `status_applied`, `status_tick`, `cleanse`, `mark_consumed` dùng để phát cue ngắn và đánh dấu dirty UI, không tạo status bất chấp state. LAB synthetic review phải ghi rõ là giả lập. Mọi icon renderer/normalizer đều READ-ONLY.

## 3. Từ vựng icon cơ sở — dự thảo cần owner duyệt

| Mã hình ảnh (presentation only) | Cơ chế hiện có | Silhouette / phụ trợ | Loại |
|---|---|---|---|
| POISON | `status_effects.v63_poison` / pilot poison | Giọt độc có vân / số tầng xN; ngọc-tím | Debuff |
| BURN | `status_effects.burn` | Ngọn lửa có khe sáng; đỏ-cam | Debuff |
| SLOW | `status_effects.slow` | Bàn chân/chuyển động bị kéo chậm (không tự suy ra đóng băng); lam | Debuff |
| WEAKEN | `status_effects.weaken` | Mũi lực gãy / khiên nứt; hổ phách | Debuff |
| MARK | `v63_marks`, owner/skill riêng | Tâm ấn có khe khuyết; ruby-tím | Debuff (conditional) |
| GUARD | `learned_guard_until`, `guard_until`, `v63_capacity_shield_until` theo loại thực | Khiên rõ đường viền; vàng/lam | Buff |
| HOT/RECOVERY | `pilot_effects.hot` hoặc nguồn heal-over-time thực khác nếu có | Mầm sáng/lá; xanh sáng | Buff (chỉ khi ongoing) |

**Không được tạo icon dai dẳng riêng** cho damage, instant heal, cleanse, consume_poison, passive, innate, mobility, summoning, formation_zone chỉ vì `effect` có nhãn ấy. Cleanse là một cue làm sạch tức thời, không phải status kéo dài. Summon là actor riêng; formation zone là hiệu ứng mặt đất có owner/duration riêng. Control/stun/silence **CHƯA** cấp icon nếu chưa có real canonical state và kiểm thử.

**Khi `mark` có subtype khác biệt thật sự:** sử dụng **cùng khung MARK**, có thể có ký hiệu phụ/viền nhỏ khác nhau cho `blood/curse/talisman` nếu gameplay thực có điều kiện nhận diện khác. `v63_blood_marks` có thể là bộ nhớ combo nội bộ; **không tự sinh thêm badge thứ hai** nếu đã có `v63_marks` cho cùng ứng dụng. Biểu tượng không được làm người chơi hiểu hai trạng thái đang tồn tại nếu Combat V2 chỉ có một mark hữu hiệu.

## 4. Quy tắc tổng hợp để tránh 36 nhánh gây rối

1. **Một icon / status family / target**, bất kể có bao nhiêu chiêu gây cùng trạng thái. POISON tập hợp stack thực của từng owner nhưng không thay đổi owner-limit, expiry, tick hay công thức. `×N` hiển thị tổng thực; chi tiết mở theo owner và source skill. `v63_marks` nhiều nguồn có thể dùng `MARK×N` nhưng từng `caster_id/skill_id/until` phải giữ nguyên; không giả trạng thái mới.
2. **Đa expiry:** countdown/ring phải được gắn nhãn rõ: thời điểm hết hạn gần nhất (`next expiry`) hoặc thời gian hết hạn cuối cùng (`last expiry`), không nói chung “còn 6 giây” khi nhiều stack khác nhau. Chi tiết khi chọn target liệt kê từng nguồn. Không tự kéo dài debuff của nguồn A vì B vừa áp dụng.
3. **UI khi đông quái 6v8:** đề xuất tối đa **2 debuff chính + “+N”** trên đầu mỗi actor thường; tối đa 2 buff tách hàng trên đồng minh. Tăng thông tin cho target được chọn/đối thủ Boss, không tăng lượng glow trên mọi quái. 24px logical icon ở canvas tham chiếu 1280×720 là **giả định thiết kế cần QA Android**. Căn theo HP/name safe-area, tránh che mặt, không tràn viewport, không nhấp nháy khi bị refresh.
4. **Ưu tiên khi tràn:** trạng thái ngăn hành động *nếu có và được engine xác nhận* > DoT nguy hiểm > làm chậm / suy yếu > mark. Giữ thứ tự ổn định theo status code; không đổi vị trí giật liên tục khi số giây đổi. Cho người chơi xem toàn bộ ở target detail.
5. **Tín hiệu thị giác hai cấp:** 0.2–0.45s impact/cue của riêng skill lúc nhận event thực; sau đó chỉ icon nhẹ nhàng. Không giữ luồng khói/vòng chú đỏ tím lớn 6–10s và không phát hit spark mới ở mỗi frame/tick. Chỉ vẽ tick nhỏ khi Combat V2 thật phát `status_tick`.
6. **Accessibility:** icon có silhouette khác nhau, không phân biệt bằng màu đơn thuần; hỗ trợ ẩn/rút gọn VFX và nâng tương phản; không dùng chớp màn hình liên tục. Hiển thị stack và duration theo source thay vì trang trí.
7. **Thiết kế đa môn phái:** nguồn/hiệu ứng va chạm tách school style; status icon chỉ theo effect. Ví dụ 3 kỹ năng Huyết Quyền cùng gây MARK => ba kiểu quyền kình khác nhau nhưng cùng hệ icon MARK. Nếu owner muốn vết huyết ấn trên thân thì nó là **cue ứng dụng ngắn**, không phải ấn dán 6s mới cho mỗi skill.

## 5. Adapter kỹ thuật đề xuất (CHƯA TRIỂN KHAI)

`StatusPresentationNormalizer` (mới, chỉ đọc snapshot) tạo danh sách immutable từ `status_effects`, `v63_marks`, guard/shield authoritative fields và pilot effects nếu trong mode tương ứng. Mỗi item: `target_id, status_family, subtype, source_refs[], real_stack_count, next_expiry, last_expiry, priority, is_buff`. `status_id` phải map từ bảng readonly được validate theo catalogue, không suy ra qua `branch` hoặc tên kỹ năng. Renderer shared icon atlas đọc output normalizer. Cue renderer khác node và khác lifetime. Luật UI chỉ đổi renderer, không mutate status/caster/AI/HP.

**Contract tests trước UI:** multi-source poison, multi-owner mark, status refresh/replacement, boss slow-resist, expire/cleanse, summon/source death, snapshot cold reload, a long persistent status, no icon from damage-only Poison Tu, no duplicate icon from tick and status_applied, no extra cosmetic hit. Screenshot/QA dark+bright, 6v8 and 30 disciples/40 monsters load, lower-end Android actual FPS. No assertions of pass until verified.

## 6. Art direction FIST14 — sửa theo tên và thực cơ chế

`Liệp Huyết Truy Đả` là **Quyền Tu**, không phải kỹ năng trảo. FIST14 R1/R2 hiện là ba chấu đỏ tương đối phẳng, semantic 2.5/5 / pigment 2/5 theo [R2 native review](../operations/VFX_FIST14_R2_NATIVE_SELF_REVIEW_20261117.md), bất kể CI PASS. **R3 nên bỏ hero 3-talon**, thay bằng **Huyết Ảnh Truy Quyền**: một nắm đấm nội lực được minh họa RIÊNG rõ năm ngón/nắm quyền, nguồn tranh mới **first-party true RGBA** ở độ phân giải ít nhất 400–700px, không dùng code-drawn flat polygon làm VFX chủ đạo, không tái tô nguồn FIST03/R9 cho skill mới.
- G2 outline: nắm đấm hội huyết nhỏ tại caster hand → sau ảnh rút ngắn theo một hướng trên quỹ đạo trình diễn (hình quyền thủ thẳng và rõ) → nắm quyền nén đầu mũi (hot ivory-pink) chạm một mục tiêu đang di chuyển → lực đỏ rung 2–4 frame (không giả gameplay hit-stop) → kết thúc VFX; chỉ shared MARK icon duy trì 6s nếu nhận status thật.
- Chất liệu: ruby/bordeaux thuần sắc + điểm vàng-trắng nóng nhỏ, bên ngoài bán trong suốt; không dùng vệt đỏ đục, ba vạch vector đồng đều, vòng sóng lặp hoặc trùng hình tượng Độc Tu.
- G3: thật sự độc lập key poses (ít nhất origin, anticipation, release/acceleration, contact/compression, release/fade); không chỉ scale/rotate 1 hình. Số frame theo chuyển động chứ không ép 8/12.
- G3.5/G3.6/G3.7: source 1x art-first → real Godot 4.7.2 at 1280×720 charge, peak, moving contact; review **không có HUD/title**, người xem đoán được là **một quyền nội lực truy kích** thay vì trảo/độc; native full MP4, >=12 checkpoints, owner gate. No rig/GIF.
- Remain canonical `effect=mark, target_limit=1, cast=.45s, duration=6s, projectile_speed=0`; quỹ đạo nội lực trong LAB **không được tự biến thành gameplay projectile/auto-chase/multiple hit**. Actual Combat V2 receipt mapping pending.

## 7. Status

**SPEC PROPOSED / OWNER_DECISION_PENDING / IMPLEMENTATION_NOT_STARTED.** Đây chỉ là chuẩn trình bày dự kiến cho 36 nhánh, chưa phải skin/icon pack được owner duyệt và chưa gắn live PvE. Tuyệt đối không sửa gameplay/V6.3 OFF/SaveService/approved assets hoặc merge PR #72 theo tài liệu này.
