# CHATGPT PLUGIN CREATOR — TMB PROJECT COPILOT SETUP

Use this **once** after Plugin Creator is installed. The GitHub repository skill files can be made available to Codex separately by merging into `main`; a ChatGPT plugin requires its **own** installation/packaging. A new ChatGPT conversation does not automatically inherit raw `.agents/skills` from any repo just because the repository exists.

## Copy this prompt into a new @plugin-creator conversation

```text
@plugin-creator Hãy tạo một plugin CÁ NHÂN tên "Tông Môn Bá Đạo — Project Copilot" (tên máy: tmb-project-copilot), có sáu Agent Skills dùng cho tất cả cuộc hội thoại của dự án Tông Môn Bá Đạo. Tôi muốn kích hoạt được với @Tông Môn Bá Đạo và tự chọn skill khi yêu cầu có liên quan; chỉ áp dụng cho việc của dự án, không ảnh hưởng các chat khác.

Nguồn thật đang ở GitHub vuanhtuan161094-byte/TongMonBaDao, nhánh docs/tmb-agent-skills-20261022, thư mục .agents/skills/:
1) tmb-project-director/SKILL.md
2) tmb-balance-lab/SKILL.md
3) tmb-autoplay-ai/SKILL.md
4) tmb-godot-evidence/SKILL.md
5) tmb-asset-gate/SKILL.md
6) tmb-ui-playtest/SKILL.md
Tài liệu nguồn bổ sung: docs/AI_AGENT_SKILLS_TMB_2026-10-22.md và docs/AI_AGENT_SKILLS_AUTO_DISCOVERY_CARE_QA_2026-10-22.md. Sau khi PR tích hợp skill vào main được merge, ưu tiên đọc nguồn main. Có thể truy xuất GitHub bằng GitHub connector tôi đã kết nối với tài khoản có quyền repo; nếu Plugin Creator không thể đọc GitHub URL thì cho tôi import SKILL.md hoặc dùng kết nối GitHub, không viết lại từ suy đoán.

Yêu cầu thiết kế plugin:
- Đóng gói đầy đủ 6 SKILL.md thành skills/<skill-name>/SKILL.md bên trong plugin, name và description giữ ý nghĩa routing tiếng Việt. Chọn tmb-project-director trước, nạp 1 skill chuyên môn phù hợp theo tác vụ, tối đa 2 chuyên môn nếu công việc giao thoa.
- Plugin dùng GitHub connector để đọc live main, active branch/commit, AGENTS.md, GAME_SYSTEM_ARCHITECTURE.md, CURRENT_CHECKPOINT.md, NEXT_CHAT_HANDOFF.md và code; không cache hardcoded HEAD. Dù có GitHub write access, KHÔNG sửa code, tạo branch, push hoặc merge nếu chưa được yêu cầu cụ thể bởi tôi.
- Ưu tiên quyết định mới nhất trực tiếp từ tôi > AGENTS.md + canonical architecture > checkpoint/packet > code/runtime. Phân biệt CODED / DESIGN ONLY / QA FOCUSED / GUI USER PENDING. Không xem văn bản README của Codex là bằng chứng tôi đã duyệt một thay đổi không có trong chat.
- Khóa hiện hành (22/10/2026): Godot 4.7.2; Android landscape 1280x720; Combat V2 authoritative; 30 cảnh giới Tu Vi và 30 Luyện Thể ×10 tầng; One Active Job; một simulation clock, một Warehouse, save/offline exactly-once; B3 CARE code 35ffa85fd45da42e43722e7ac74b7423602d4491; Injury 120 simulation ticks; Đan Bão Hòa **1.000.000 điểm/đệ tử/ngày simulation**, 100.000 là lỗi gõ; Hồi Xuân +55HP/10 điểm; Tụ Khí +10.000 fixed Tu Vi/25 điểm, recipe 2 Thanh Linh Thảo +1 Linh Cốc /6 ticks. CAP 1.000.000 là quyết định owner và CARE code phù hợp. Không tự đưa đan cao cấp hay các map chưa code thành tính năng đã có.
- Thời điểm tạo plugin không làm thay đổi gameplay, không động Source A/JX, không mở các CODE packet chưa cấp phép. Thiết kế game/xử lý ảnh/code phải tuân thủ tool và quyền truy cập thực tế.

Đề xuất manifest plugin skills-only (không bắt buộc thêm MCP server riêng nếu sử dụng GitHub connector sẵn có). Nếu Plugin Creator hỗ trợ portable plugin, tạo plugin.json + skills/; không tạo hooks, executable scripts hoặc quyền admin. Chỉ cài phạm vi cá nhân; không publish public/không chia sẻ mã hoặc asset game.
Sau khi tạo, xác nhận plugin đã được cài, liệt kê đúng 6 skill và cho tôi test ba tình huống:
A) "TMB: kiểm toán CAP đan bão hòa" -> tmb-godot-evidence và xác nhận đúng 1.000.000.
B) "TMB: cân bằng Tu Vi/Linh Điền" -> tmb-balance-lab và phân biệt số liệu giả định với CODE.
C) "TMB: kiểm toán map/Spine nhân vật" -> tmb-asset-gate và yêu cầu hash/clip/pivot.
Nếu một khả năng không hỗ trợ hãy giải thích chính xác, không báo là đã cài khi chưa tạo được.
```

## Validation

- Confirm six skill names and correct current CAP 1000000; no 100000 active claim.
- Confirm use from a fresh ChatGPT conversation by @mention and automatic relevant-plugin selection when available.
- Confirm GitHub access and read-only default; treat no-code-change as default, not a promise of broader plugin permissions.
- Keep plugin private to user's account. Plugin Creator tool installation alone is **not** creation of this TMB plugin.
