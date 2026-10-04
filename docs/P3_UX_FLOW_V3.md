# P3 — V3 CORE UX FLOW

Date: 2026-10-04
Status: CANONICAL UX FLOW — USER APPROVED

## 0. Scope

Khóa flow presentation chính đã được user duyệt:

`V3.1 Main Map -> V3.2 Disciple Right Summary -> V3.3 Disciple Deep Screen -> Back to Map Context`

Đây là **UX/visual authority**, không phải runtime PASS.

---

# 1. V3.1 — Main Map Idle

Mục tiêu: nhìn thấy một tông môn đang sống.

- 1280×720 landscape;
- map-first;
- top HUD mỏng;
- task rail trái;
- bottom nav 5 entry;
- công trình nhỏ tương đối so với map;
- terrain sáng/thoáng/thủy mặc;
- 8–12 actor;
- 1–3 bubble/action cue;
- không mở detail panel mặc định.

Primary action: tap world target.

---

# 2. V3.2 — Tap Disciple

Trigger: tap một disciple actor.

Kết quả:

1. selected actor có ring/marker;
2. camera focus nhẹ;
3. panel summary dọc mở **bên phải**;
4. map vẫn visible và usable.

Panel phải ưu tiên trả lời:

- Đây là ai?
- Khỏe không?
- Đang làm gì?
- Đang ở đâu?
- Tiến triển ra sao?
- Có kỹ năng/công pháp gì đang dùng?
- Tôi có thể ra lệnh nhanh gì?
- Muốn xem sâu thì bấm đâu?

Thông tin canonical:

- portrait/name;
- quality/tag/rank nếu cần;
- realm;
- HP;
- stamina;
- cultivation/progress;
- current job;
- current status;
- location;
- key stats;
- skill/technique cues;
- contextual action;
- `Xem chi tiết`.

Không có 6 deep tabs trong V3.2.

---

# 3. V3.3 — Xem chi tiết

Trigger: `Xem chi tiết` từ V3.2 hoặc entry Đệ Tử phù hợp.

Structure:

- left vertical roster;
- center character showcase;
- right detail/tab content;
- six real tabs:
  1. Thuộc tính;
  2. Công pháp;
  3. Trang bị;
  4. Huyết Mạch;
  5. Thể Chất;
  6. Quan hệ.

Persistent continuity từ V3.2:

- HP;
- stamina;
- cultivation/progress;
- realm;
- current job;
- status;
- location.

Default tab từ V3.2: `Thuộc tính`.

---

# 4. Back / context restoration

### V3.3 -> Back

Nếu mở từ selected disciple trên map và target còn hợp lệ:

- trở về map;
- giữ selected disciple;
- restore V3.2 right panel;
- không reset camera vô cớ.

Nếu target không còn hợp lệ:

- trở về V3.1 clean state;
- không giữ stale/fake UI state.

### V3.2 -> close

- X hoặc blank tap đóng panel;
- selection clear theo interaction policy;
- map trở V3.1.

### Tap another disciple while V3.2 open

- không đóng/mở animation vòng vo;
- switch selected disciple;
- panel update đúng runtime state;
- focus marker chuyển đúng target.

---

# 5. Runtime authority mapping

Presentation chỉ đọc/gọi hệ thật.

- HP/stamina/cultivation/action/location lấy từ state thật;
- current work/action không có presentation duplicate;
- quick orders gọi `WorkforceSystem.issue_command()` hoặc authority tương ứng;
- Bloodline action gọi real `BloodlineSystem`;
- Physique action gọi real `PhysiqueSystem`;
- equipment đọc real ownership/slot;
- relationship đọc actual P1.3 state;
- hidden identity không leak.

---

# 6. Information-density rule

### V3.1
World-first, gần như không character data.

### V3.2
Operational summary: đủ để quyết định nhanh mà không mở deep screen.

### V3.3
Investigation/management depth: full 6-tab character model.

Không duplicate toàn bộ V3.3 vào V3.2.

---

# 7. UX performance target

Routine question như “đệ tử này đang làm gì/khỏe không?” phải giải quyết trong **1 tap** từ map.

Deep question như “công pháp/trang bị/huyết mạch/quan hệ của người này?” phải đạt trong **2 taps**:

`tap disciple -> Xem chi tiết`.

Không bắt người chơi đi qua bottom nav nếu target đang ở ngay trên map.

---

# 8. Mobile interaction rules

- important hit targets ~44×44 px minimum;
- right panel không che selected actor nếu có thể;
- panel không scale với map zoom;
- roster/tabs scroll/tap được ở 1280×720;
- text hierarchy ưu tiên glanceability;
- không phụ thuộc hover.

---

# 9. Visual language

Cả ba state dùng cùng family:

- parchment/ink;
- jade muted;
- bronze/gold accent;
- hand-painted xianxia;
- sáng, thoáng;
- không neon;
- không SaaS/dashboard;
- không copy proprietary reference assets.

---

# 10. Acceptance gates

## Visual/UX locked
User đã duyệt direction V3.1, V3.2 và V3.3 ngày 2026-10-04.

## Runtime implementation — chưa được gọi PASS
Chỉ gọi runtime UX PASS khi Godot thật chứng minh:

1. tap actor mở đúng V3.2;
2. data V3.2 lấy từ runtime;
3. switch actor đúng;
4. close đúng;
5. `Xem chi tiết` mở đúng V3.3 disciple;
6. 6 tab hoạt động trên authority thật;
7. hidden data không leak;
8. Back restore context;
9. pan/zoom/hit target không regression;
10. cumulative gate theo checkpoint hiện hành xanh.

