# PR72 — QA trên PC Windows 10 thật, một lệnh

Tại workspace **E:\TongMonBaDaoWorkspace\01_Game\TongMonBaDao**, nhấp đúp:
\`tools\windows\qa\PR72-WINDOWS-PC-QA.cmd\`

Đây là *lệnh QA kỹ thuật* gọi **MO_GAME.cmd**, không phải game mới. Dùng Git, PowerShell 5.1 và Godot **4.7.2 official** tại E:\TongMonBaDaoWorkspace\04_Tools\Godot hoặc E:\Godot_v4.7.2-stable_win64.exe. Không chạy nếu nhánh không đúng \`integration/pve-p0-playable-ui-20261103\`. Lệnh chỉ ghi SHA checkout, không tự fetch/pull/reset/clean hay merge. Nếu local SHA khác GitHub HEAD, hãy đồng bộ an toàn riêng trước khi coi kết quả là mới nhất.

QA tự thiết lập \`TMB_PROFILE_ROOT\` tại \`E:\TongMonBaDaoWorkspace\03_QA_Logs\PR72_PC_QA\isolated_profile\`; Save khi chơi bình thường vẫn dùng nguyên profile cũ. Launcher cũ chỉ nhận biến tùy chọn trong phiên QA, mặc định không thay đổi.

Trong game, lần lượt mở **Map, Mỏ, Linh Lâm, Linh Điền, Kho**; tự thao tác chuột, phân công nhân lực và theo dõi vật liệu/EXP thật. Quay về cửa sổ QA nhấn **Enter** để chụp từng màn, **S** để đánh dấu chưa thử hoặc **Q** để ngừng thu thập (không giết tiến trình). Trong game **Lưu** và đóng cửa sổ bình thường. QA sẽ mở lại đúng Save QA riêng để chụp thêm Kho/nhân công. Đóng game lần nữa để kết thúc.

Kiểm tra offline theo thời gian thực: sau khi đã đóng game QA, có thể để máy ở trạng thái không chạy game 60/90/180 phút, rồi chạy lại cùng CMD với tham số \`-ResumeOnly\`. Script chỉ đo khoảng thời gian giữa các lần đóng/mở, KHÔNG tự chứng minh toàn bộ sản lượng đúng hoặc 3 mốc đã thử; cần đối chiếu nội dung/ảnh/Save thủ công.

Bằng chứng trong \`E:\TongMonBaDaoWorkspace\03_QA_Logs\PR72_PC_QA\run_...\`: \`manifest.json\` (SHA Git, Godot version, driver GPU, crash events \`ig11icd64.dll\`, hash Save trước/sau), ảnh vùng client cửa sổ game PNG, \`frames_*.csv\` và FPS thực do Godot ghi, \`process_ram_cpu_samples.csv\` (working set và private RAM), nhật ký launcher/Godot. Script không yêu cầu Administrator, không xóa Save gốc và không chạy thử trên Android.

**Điều kiện PASS cuối cùng:** cần kiểm tra ảnh thực tế không bị cửa sổ khác che/chồng chữ, chơi thử bằng chuột trên PC, ghi FPS/RAM/driver và đọc log sau khi chạy. Không biến kết quả CI Windows thành PASS PC thật. Nếu game crash khi chưa hiện cửa sổ, báo log và Windows Event Viewer, không chỉnh code đoán mò.
