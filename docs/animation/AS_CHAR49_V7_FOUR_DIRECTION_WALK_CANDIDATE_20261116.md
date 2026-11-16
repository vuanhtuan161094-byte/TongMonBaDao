# AS-CHAR-49 V7 — Nữ Kiếm Tu Walk bốn hướng (16/11/2026)

## Kết quả thực tế (không làm giả 24 clip)
- **10/24 clip ứng viên kỹ thuật**, **0/24 đã được Owner duyệt mỹ thuật / Production**, **14/24 chưa có frame**.
- Giai đoạn action-first đã có: **Idle × Front/Right/Back/Left (4 frame/clip)** và **Walk × Front/Right/Back/Left (8 frame/clip)**. Các clip cũ giữ lại: **Attack_Right**, **Cast_Right** (8 frame/clip).
- Tổng **64 ảnh nguồn frame PNG 512×512 RGBA**, **10 atlas 4 cột**, 10 GIF và 10 APNG, manifest SHA256, Godot 4.7.2 *standalone source-only* scene, offline 1280×720 preview, một HTML chọn action/hướng. 14 trạng thái thiếu **không tạo placeholder**.
- **Bộ Walk 4 hướng** tạo từ một PNG 1774×887 gồm 4 hàng x 8 tư thế vẽ khác nhau (không phải GIF động, không phải poster marketing). Nguồn lưu nguyên gốc kèm trong ZIP. Alpha thấp/rác xung quanh được loại, căn điểm chân theo *root cố định cho toàn bộ 8 frame của mỗi hướng*, không căn riêng đáy mỗi frame, không rig.
- Để bảo đảm cùng nguồn giữa cả bốn hướng, **Walk_Right của R4 được thay bằng nguồn Walk 4 hướng mới**. Dữ liệu lịch sử R4 được giữ trong Library/gói cũ và provenance note; Attack/Cast không thay đổi.
- File source Walk SHA256: `8b784716f7c057973cdb4cca5779132f34ab96053875a18d20f971a89fc5a6bd`.
- ZIP `/TMB-Character-Art/AS_CHAR49_V7_IDLE_WALK_4DIR_CANDIDATE_20261116.zip` trong ChatGPT Library (KHÔNG phải trên GitHub), SHA256 `544c473dd692b16fec0f56612bf0e1c3cde32068c4108bd6f86af2e56ebcbf70`, 38,685,036 bytes, 189 entries, ZIP CRC PASS.

## QA và giới hạn rõ ràng
- Python xuất & kiểm tra **220/220 assertions PASS** cho 10 clips: khớp SHA frame, 512² RGBA, atlas exact pixel equality, frame distinct, GIF/APNG có frame thật, trạng thái thiếu được đánh dấu rõ.
- Chạy độc lập `tools/verify_assets.py`: **84 checks PASS** (64 frame SHA và 20 preview GIF/APNG kiểm tra có alpha), 10 atlas và nguồn gốc so khớp.
- Xem `previews/Walk_FOUR_DIRECTIONS_QA.gif` để thấy đủ bốn hướng chạy đồng thời, hoặc `qa/AS_CHAR49_V7_WALK_4DIR_OFFLINE_NOT_GODOT_1280x720.mp4`, *đây là render ngoại tuyến, KHÔNG PHẢI capture Godot*. Phóng 1×/2×/3× nền sáng/tối trong `qa/`.
- **MASTER APNG NỮ CHƯA XÁC MINH BYTES**; nguồn mới chỉ là candidate về đồng nhất nhận diện, chân/trọng tâm, animation loop và transition. Bản đồ game thật chưa được nghiệm thu. Chỉ owner art signoff mới cấp production PASS.
- **GODOT 4.7.2 NOT_RUN** (binary unavailable trong môi trường này); không bịa native screenshot, log, CI exact-SHA hay performance Android.
- Một lần yêu cầu Attack ×4 ở lượt này tạo sai poster quảng cáo; bị **REJECTED** và KHÔNG dùng làm source hoặc tính progress.
- Không rig, không Codex, không new branch/merge, không chỉnh Combat V2, PvE, V6.3, SaveService, economy hoặc gameplay, không gắn actor vào game.

## Theo quy trình Action-First

| Action | Front | Right | Back | Left |
|---|---|---|---|---|
| Idle | 4 candidate | 4 candidate | 4 candidate | 4 candidate |
| Walk | 8 candidate | 8 candidate | 8 candidate | 8 candidate |
| Attack | MISSING | 8 candidate | MISSING | MISSING |
| Cast | MISSING | 8 candidate | MISSING | MISSING |
| Hit | MISSING | MISSING | MISSING | MISSING |
| Death | MISSING | MISSING | MISSING | MISSING |

HEAD khi bắt đầu lượt: `820aaa705304ad56a1bc73d028cc5b6d276e8257`. HEAD ngay trước checkpoint: `f2980355ab2107fac994d66b187105ee15a6260f`; các chat khác có thể tiếp tục cập nhật nhánh. Chỉ tài liệu được cập nhật lên PR #72; asset binary ở Library để tránh claim GitHub chứa file mà thực chất không có.
