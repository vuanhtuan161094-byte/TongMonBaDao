# P3.3 — DISCIPLE OPERATIONAL FLOW

Date: 2026-10-04  
Status: IMPLEMENTED ON MAIN / AWAITING REAL GODOT 4.7.2 GATE

## 0. Mục tiêu

P3.3 chuyển tương tác đệ tử từ “mở hồ sơ lớn ngay” sang nhịp quản lý thực tế:

`map -> chạm đệ tử -> panel vận hành bên phải -> ra lệnh nhanh hoặc Xem chi tiết -> hồ sơ 6 tab -> Back về đúng ngữ cảnh`.

Đây là presentation/interaction trên simulation hiện có. Không tạo gameplay state song song.

Authority UX:

- `docs/P3_UX_FLOW_V3.md`;
- `docs/P3_UX_MAIN_MAP.md`;
- `docs/P3_UX_DISCIPLE_SCREEN.md`;
- `docs/DISCIPLE_MASTER_SCHEMA.md`.

## 1. Người chơi thấy gì

### A. Chạm đệ tử trên map

Không còn mở full-screen hồ sơ ngay.

Một panel cố định bên phải hiện:

- tên;
- phẩm chất;
- cảnh giới;
- HP;
- thể lực;
- tu vi;
- hành động hiện tại;
- vị trí hiện tại;
- nhóm việc;
- chiến lực hiệu dụng;
- công pháp đang dùng;
- Huyết Mạch đã biết hoặc `Chưa xác định`;
- Thể Chất hiện tại;
- lệnh Tông Chủ đang lưu.

Map vẫn nhìn thấy và vẫn pan/zoom bằng gesture.

### B. Lệnh nhanh

Panel có:

- Tu luyện;
- Nghỉ;
- Về tông;
- Khai khoáng;
- Luyện khí.

Nút không sửa `current_action` trực tiếp.

Nó gọi `WorkforceSystem.issue_command()`; simulation quyết định hành động thật theo priority/survival rules hiện có. Khi simulation đổi action, map destination tiếp tục được derive từ action thật.

### C. Xem chi tiết

`Xem chi tiết` mở màn V3.3:

- roster dọc bên trái;
- character showcase ở giữa;
- nội dung bên phải;
- đúng 6 tab thật:
  - Thuộc tính;
  - Công pháp;
  - Trang bị;
  - Huyết Mạch;
  - Thể Chất;
  - Quan hệ.

Đổi người trong roster không đóng màn.

### D. Back

Nếu vào V3.3 từ panel V3.2:

- Back trở lại map;
- panel bên phải mở lại;
- giữ đúng disciple mới nhất đang chọn;
- marker chuyển về đúng disciple;
- camera không bị reset vô cớ.

Nếu vào V3.3 trực tiếp từ bottom nav `Đệ Tử`:

- Back về map sạch;
- không tự dựng một panel V3.2 giả mà người chơi chưa đi qua.

## 2. Hệ thống phía sau

P3.3 không thay simulation authority:

- HP/stamina/action/location đọc từ `SimulationState`;
- cultivation/realm/combat power đọc `CultivationSystem`;
- công pháp đọc `TechniqueSystem`;
- equipment đọc `EquipmentSystem`;
- Huyết Mạch đọc/gọi `BloodlineSystem`;
- Thể Chất đọc/gọi `PhysiqueSystem`;
- Quan hệ đọc state P1.3;
- quick order gọi `WorkforceSystem`.

Hidden Bloodline không được leak type/purity trước reveal.

## 3. Input contract

- panel phải là fixed UI, không scale cùng map;
- khi panel mở, camera rail bên phải tạm ẩn để không chồng UI;
- gesture pan/zoom trên map vẫn hoạt động;
- tap vùng map trống đóng panel;
- kéo/pan map không bị hiểu nhầm thành tap-close;
- tap building đóng disciple panel rồi mở building context như trước.

## 4. Runtime files

Implementation:

- `godot/src/presentation/p3_2_landscape_sect.gd`.

Contract test:

- `godot/tests/presentation/p3_3_disciple_operational_flow_test.gd`.

Windows gate:

- `Verify-P3-3-Disciple-Flow.cmd`;
- `tools/godot/Verify-P3-3-Disciple-Flow.ps1`.

## 5. Acceptance gate

Không gọi P3.3 PASS cho tới khi Godot 4.7.2 trên Windows chứng minh:

1. tap actor mở panel phải, không dim map;
2. panel đọc state thật;
3. hidden Bloodline không leak;
4. quick order ghi real direct command, không sửa action/region trực tiếp;
5. `Xem chi tiết` mở V3.3;
6. đủ 6 tab real;
7. đổi roster giữ context;
8. Back từ V3.2-entry restore đúng selected disciple + marker;
9. bottom-nav direct entry Back về clean map;
10. scene smoke không parser/runtime error;
11. cumulative P3.2 interaction chain vẫn xanh.

## 6. Quan hệ với live modular actor gate

P3.3 code không được dùng để suy diễn rằng live modular female map đã PASS.

Trước khi khóa P3.3 runtime, Windows action vẫn phải lấy bằng chứng còn thiếu:

`Verify-P3-2-Female-StageA.cmd`

với dòng:

`P3.2 LIVE MODULAR FEMALE MAP INTEGRATION TEST PASS`.

Sau đó mới chạy:

`Verify-P3-3-Disciple-Flow.cmd`.

## 7. Art priority

Map actor chỉ cần đủ phân biệt ở kích thước gameplay. Character Creator không còn là blocker cho P3.3.

Variant face/hair/outfit/weapon/tint sẽ được làm gọn để chống clone, nhưng ưu tiên phát triển tiếp là gameplay interaction và living-sect management.
