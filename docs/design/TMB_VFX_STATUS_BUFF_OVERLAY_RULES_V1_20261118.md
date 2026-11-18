# A — Quy ước hiệu ứng trên quái, Buff/Debuff và trạng thái 36 nhánh — V1

**Ngày:** 18/11/2026. **Phạm vi:** thiết kế Presentation-only trong Draft PR #72, không thay đổi Combat V2 hoặc các scene/atlas đã được duyệt. **Trạng thái:** RULESET IMPLEMENTED IN PILOT SPEC; owner art sign-off và PvE G8 còn HOLD.

## 1. Thẩm quyền và hai lớp
- **Lớp cast/impact (riêng từng skill):** tụ khí → release → đúng số mục tiêu → contact → residue. Hình tượng, tông màu và hướng đánh khác nhau; chỉ phát cue theo sự kiện/contract thật, không tạo damage/mark.
- **Lớp status (chung theo cơ chế):** đọc snapshot bất biến từ `MapBattleV2` tại `battle.now`. Không tạo thêm trạng thái từ `status_applied`. Poisons giữ nguyên từng stack/owner/expiry; Marks giữ caster/skill/expiry; Guard thường/capacity shields phải giữ đúng loại và điều kiện tồn tại.
- **Không tự có icon dài hạn:** `damage`, `instant_heal`, `cleanse`, `consume_poison`, `mobility`, `summon`, `passive`, `formation_zone`, trừ khi chính Combat V2 có state duy trì tương ứng. Cảm giác chiêu thức luôn giữ ở impact chứ không tạo thêm mark giả.

## 2. Trạng thái và cách đọc
| Family | Điều kiện HIỂN THỊ | Biểu tượng dùng chung | Khi apply | Khi sustain |
|---|---|---|---|---|
| POISON | stack trong `status_effects.v63_poison` có `expires_at > battle.now` | giọt độc/vân; ×stack thật | độc quang / châm / xà **riêng skill** | icon; optional sương nhỏ **chỉ khi được cấp budget** |
| MARK | entry `v63_marks` còn hạn theo owner | ấn tâm, ×nguồn nếu >1 | ấn phù hoặc quyền đích riêng skill | icon nhỏ, không che mặt, không hiện thêm internal `v63_blood_marks` |
| BURN | `status_effects.burn.until` còn hạn | lửa khe sáng | contact hỏa riêng | icon; không giữ cả vụ nổ |
| SLOW | `status_effects.slow.until` còn hạn | chân/chuyển động chậm | cue ngắn khi apply | icon; không giả frozen/stun |
| WEAKEN | `status_effects.weaken.until` còn hạn | lực gãy | cue ngắn | icon |
| GUARD | `guard_until`/`learned_guard_until` còn hạn, hoặc capacity shield có remaining >0 và chưa hết hạn | khiên vàng/trắng | burst bảo hộ riêng skill | một aura mỏng hoặc icon; flare phản đòn CHỈ theo receipt thực |
| HOT | Chỉ khi có real HOT state được ghi nhận; pilot phải báo pilot | mầm hồi phục | ánh sáng hồi phục riêng | icon, không phát cast lặp |
 
**Danh mục trên chỉ định hướng mỹ thuật; mã pilot GDScript sẽ đọc subset có source xác minh.** Một vài nguồn S1/legacy/pilot dùng cấu trúc không đồng nhất: không dùng tên effect để suy diễn dữ liệu. Status trong v63 chưa bật vẫn phải HOLD khi chế độ này không có authority.

## 3. Phân lớp và vị trí
- `ground/ambient → back FX → actor → front local contact → status HUD`. Dấu hiệu không được che mặt, HP, tên, telegraph hay đích.
- **Anchor:** `feet`, `hand`, `chest`, `shoulder_left/right`, `head_safe`, `impact`, `ground`. Mỗi family nhân vật/quái và hướng nhìn cần bảng pivot; không dùng một pixel-offset cố định cho Boss, quái nhỏ và đệ tử.
- **Quái thường:** thử nghiệm 2 icon debuff chính + `+N`; buff ở hàng riêng tối đa 2; chi tiết khi được chọn. Boss/selected có vùng thông tin chi tiết. Đề xuất ~24 px logical tại 1280×720 là **giả thuyết thử**, chưa duyệt/đo Android.
- **Ưu tiên:** cảnh báo sát thương > contact thật > phản ứng cần đọc > buff apply > status icon > ambient. Telegraph không bị cắt chỉ vì đủ budget. Status gộp icon **không làm mất** owner, source, next/last expiry thực trong drill-down.
- **Nhiều apply cùng lúc:** cue của skill chỉ chạy riêng nếu budget; status hiển thị một family không nhân bản N overlay. Event tick không tái tạo toàn bộ cast.
- **Vùng đúng:** selected target cap1 chỉ có một dấu; cap3 tối đa ba target đã được authority chọn. Decoy không nhận cue.

## 4. Buff ba nhịp
1. **Apply 0–1 s ngắn theo skill:** cho phép vòng năng lượng, dấu hộ thể, vệt phát sáng giàu chi tiết và độc đáo.
2. **Sustain (1–10 s / passive always-on):** nhỏ, mỏng, hạn chế overdraw; một aura nền nổi bật/actor là mặc định **cần thử nghiệm**, các buff khác đi vào icon. Không dùng hàng loạt vòng tròn, không bắt passive có cast/hit.
3. **Reaction/expiry:** blocked-hit flare ngắn **theo sự kiện guard thực**, cleanse fade nhẹ, hết hạn tan sạch; không phát damage/knockback giả.

## 5. Cần kiểm chứng / chưa cho triển khai runtime
- Multi-owner poison stack, refresh, expiry khác nhau, cleanse, mark consume, shield exhaustion và death; **status renderer chỉ đọc** không sửa state.
- HUD 6v8, 30 đệ tử/40 quái, zoom 0.7–2.25, Boss lớn, HP/tên không che, Android đo; hiện NOT_EXECUTED.
- Chốt vocabulary icon/glyph với owner trước khi vẽ bộ chính thức. Không copy tài nguyên JX/Võ Lâm có quyền thương mại chưa rõ.
- Kiểm tra FIST09 revision art theo owner, POI06 preview vs ledger; không tự promote PROVISIONAL.

**Nguồn:** [Status proposal](TMB_COMBAT_STATUS_VFX_36_BRANCHES_STANDARD_V1_PROPOSAL_20261117.md), [SOP V4](../operations/TMB_VFX_ART_FIRST_SINGLE_SKILL_SOP_V3_20261114.md), [Báo cáo VFX tổng](../operations/TMB_VFX_CROSS_SCHOOL_LESSONS_AND_EFFICIENT_WORKFLOW_20261118.md).
