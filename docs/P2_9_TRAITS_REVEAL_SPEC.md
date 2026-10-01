# P2.9 — Đặc Chất + Khuyết Điểm + Ẩn/Thức tỉnh

Date: 2026-10-01
Status: IMPLEMENT AFTER P2.8 RUNTIME GREEN

## Mục tiêu

Làm hai đệ tử cùng Phẩm chất vẫn khác nhau rõ rệt bằng các Đặc Chất có hậu quả thật và một cơ chế đặc chất ẩn được sinh từ đầu rồi lộ ra theo lịch sử sống.

P2.9 không làm Huyết Mạch, Thể Chất hay Thiên Mệnh. Nó dựng hạ tầng chung để các lớp đó sau này dùng cùng nguyên tắc: sinh một lần, lưu một lần, reveal không reroll.

## Feature gate

`SectState.disciple_traits_enabled`.

Khi false:

- P0-P2.8 serialized state và gameplay không đổi;
- không sinh profile trait;
- không áp modifier;
- không reveal.

## Profile storage

Trait profile được giữ ở cấp `SectState.disciple_trait_profiles`, keyed theo character id. Candidate và accepted disciple giữ cùng id, nên acceptance không tạo/re-roll profile mới.

Mỗi profile:

- `initialized`;
- `visible` — đặc chất thấy ngay;
- `latent` — đặc chất ẩn đã được khóa từ seed;
- `revealed` — tập con của latent đã được lộ.

`latent` không được thay đổi khi reveal.

## Visible traits vertical slice

### Tích cực

- `steady_meridians` — Kinh Mạch Ổn Định: tăng hiệu suất tu luyện.
- `diligent_worker` — Cần Mẫn: tăng tốc làm việc và học nghề.
- `fearless` — Gan Dạ: tăng nhẹ sức chiến đấu thực.

### Khuyết điểm

- `fragile_meridians` — Kinh Mạch Yếu: giảm hiệu suất tu luyện.
- `careless_worker` — Cẩu Thả: giảm tốc làm việc.
- `timid` — Nhát Chiến: giảm nhẹ sức chiến đấu thực.

Visible trait roll có thể cho 0-2 trait. Một cá thể không có trait visible là kết quả hợp lệ.

## Latent traits vertical slice

- `battle_instinct` — Bản Năng Chiến Đấu; reveal sau đủ combat history; tăng combat power thật.
- `craftsman_eye` — Nhãn Lực Luyện Khí; reveal sau đủ work completions; tăng work speed + profession learning thật.
- `meditative_insight` — Ngộ Tĩnh; reveal sau đủ cultivation sessions; tăng cultivation gain thật.

P2.9 chỉ reveal khi điều kiện lịch sử đạt. Không roll mới ở thời điểm reveal.

## Reveal thresholds

Vertical slice deterministic thresholds:

- `battle_instinct`: `metrics.combats >= 3`;
- `craftsman_eye`: `metrics.work_completions >= 2`;
- `meditative_insight`: `metrics.cultivation_sessions >= 3`.

Reveal tăng `disciple_trait_event_count` và `metrics.trait_reveals`.

## Gameplay hooks

### Cultivation

Trait multiplier áp trong `CultivationSystem.add_progress()` sau các multiplier hiện có, chỉ khi trait feature bật.

### Workforce

Trait modifier áp vào `_work_speed` và `_learning_multiplier`, chỉ khi feature bật.

### Combat

Trait combat bonus được cộng qua `CultivationSystem.effective_combat_power()` để P2.5 resolver nhận hậu quả thật mà không rewrite combat engine.

## Recruitment integration

- P2.9 initialize trait profile cho V2 candidate pool hiện hữu;
- future V2 candidate được `TraitSystem.ensure_candidate_profile()` ngay sau generation;
- accept candidate giữ nguyên profile vì id không đổi;
- reject candidate xóa profile orphan.

Legacy/non-V2 characters không tự sinh trait profile trong phase này.

## Persistence

Trait profile phải exact round-trip:

- same seed/source/index -> same visible/latent traits;
- empty visible list vẫn là initialized valid result;
- reveal chỉ thêm id vào `revealed`, không thay `latent`;
- save/load không thay profile;
- continuation deterministic.

## Gate contracts

1. P2.8 remains traits-disabled and behavior-identical.
2. Same V2 identity produces same trait profile.
3. Empty visible result does not trigger reroll.
4. Positive/negative cultivation traits measurably change real cultivation gain.
5. Positive/negative work traits measurably change real work speed or XP gain.
6. Combat traits measurably change real effective combat power.
7. Hidden trait has no effect before reveal.
8. Hidden trait reveals only after its deterministic history threshold.
9. Reveal does not modify latent trait identity.
10. Candidate -> disciple acceptance preserves the same trait profile.
11. Rejected candidate profile is removed.
12. Exact save/load and continuation PASS.
13. P0-P2.8 cumulative regression PASS.
14. P2.9 trait-profile scene smoke PASS.

## Deferred

- trait evolution/upgrading;
- social traits tied to Mị Lực;
- rare trait chains;
- bloodline;
- physique;
- Destiny;
- injury/medical;
- loyalty/stipend.
