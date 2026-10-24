# TMB — Development Save / Snapshot Compatibility Policy
Ngày quyết định: 2026-10-24 | Status: OWNER POLICY, DOCUMENTATION ONLY
Áp dụng: TÔNG MÔN BÁ ĐẠO, giai đoạn **prototype / development**, kể từ packet phối hợp PR #28 + Combat V3-S1.

## 1. Quyết định owner (ưu tiên cao hơn QA packet cũ nếu có xung đột)

**KHÔNG BẮT BUỘC MIGRATE SAVE CŨ GIỮA CÁC PHIÊN BẢN ĐANG PHÁT TRIỂN.**
Có thể reset profile / đệ tử / tiến độ trong quá trình làm lại combat, UI, D7, schema; đừng tốn công thiết kế compatibility cho mọi version thử nghiệm. Đây là chính sách PHẠM VI QA, **không phải yêu cầu xóa SaveService hoặc xóa save của người chơi ngay bây giờ**.

**Vẫn bắt buộc** hoạt động save/load trong cùng một code/version, bảo toàn exactly-once loot, Warehouse, paid_generation, injury/One Active Job/scheduler, combat deterministic replay theo hợp đồng hiện hành, và tránh duplicate/deadlock/crash/double claim. Các rủi ro bảo mật/phá dữ liệu vẫn là blocker thực sự.

## 2. Ma trận chính sách

| Scenario | Phải hỗ trợ? | Cách QA |
|---|---|---|
| Save -> load trong **cùng exact build SHA** | **YES — REQUIRED** | Đệ tử, task, Kho, injury, CARE paid_generation, loot, công trình, worker, scene/UI cùng logic; kiểm tra ít nhất một battle có status V3 |
| Save -> load khi ứng dụng đóng/mở lại **cùng version** | **YES** | So sánh state trước/sau + exactly-once |
| Mid-encounter snapshot mới của **cùng schema/build** | **YES** nếu gameplay hiện có lưu encounter | Cooldown, burn/weaken/guard, cast, HP, timers, battle RNG không nhân đôi hoặc lặp tick |
| Corrupt/crafted input, missing fields, NaN, invalid IDs | **YES — fail closed** | Không crash/dupe; không tự grant resource hoặc chữa thương |
| Bản v2/v3/PR27 lịch sử -> **bản combat V3-S1 mới** | **NO — BEST EFFORT ONLY** | Không buộc migration; có thể từ chối/load reset theo chính sách dev; ghi rõ khả năng mất tiến độ |
| Historical active encounter continuation giữ exact action trace sau đổi cadence | **NO** | Đổi nhịp chiến đấu có thể cố ý làm replay khác; không đầu tư version-specific battle engine |
| PR27 D7 migration / regression test **đã có** | **KEEP INTACT** | Chạy test regression trong scope ảnh hưởng nếu test hiện tồn tại; không xóa hoặc sửa assert chỉ để phù hợp quyết định này |
| Game sau khi public/release chính thức | **NOT DECIDED HERE** | Cần policy versioning, backups, compatibility được owner phê duyệt riêng |

## 3. Hướng dẫn cho Codex / reviewer

1. **Không tự xóa save local, user://, log, profile, E: outputs**. Làm ở TEMP clone và isolated userdata; khi cần reset phải reset riêng test profile và ghi lại.
2. Không thay đổi hay gỡ D7 migration/SaveService đang có chỉ vì owner bỏ yêu cầu hỗ trợ **future historical saves**. Chức năng cũ vẫn phải đứng vững; thay đổi code SaveService cần owner cho phép riêng.
3. QA S1 có thể tập trung 14-file focused chính cùng new V3-S1 edge tests và current-version snapshot/replay. Các fixture legacy độc lập vẫn được chạy như regression nếu đã thuộc ma trận chính thức; giữ nguyên báo cáo failure. Nếu incompatible legacy thật sự là nguyên nhân duy nhất: **classify LEGACY_DEV_POLICY_EXEMPT**, không sửa test để PASS và không tuyên bố 14/14 PASS khi vẫn fail.
4. Nếu encounter cũ không thể nâng cấp an toàn: không tự chế thuật toán migration hoặc trả loot/đệ tử giả; định nghĩa reset fail-closed và phải có quyết định riêng trước khi CODE.
5. Save test cần xác minh **earned vs display**: animation không tạo vật phẩm, Warehouse/CARE mới là nguồn đã COMMITTED. Một monster chết chỉ có một paid receipt per generation, kể cả burn DoT / reload.
6. Khi chuẩn bị giao cho người dùng bản demo, phải cảnh báo rõ: bản dev có thể yêu cầu tạo game mới; có thể sao lưu save cũ nếu muốn. Không hứa giữ đệ tử từ build cũ.

## 4. Ranh giới pháp lý của tài liệu

Tài liệu ghi chính sách QA do owner chọn, không thực hiện reset, không sửa schema, không chạy thử, không tuyên bố SaveService đã hỗ trợ policy mới. Các điểm triển khai cần CODE permission và exact SHA.

## 5. Chỉ dẫn ưu tiên khi điều phối

- Tránh lặp lại tối ưu migration qua nhiều phiên bản development chưa phát hành.
- Không thỏa hiệp với integrity trong **cùng version** hoặc với receipt exactly-once.
- Rủi ro deferred tương thích lịch sử **không tự động chặn** việc bắt đầu bản thử tích hợp, nhưng phải ghi rõ là policy exception, không thay thế bằng PASS giả.
