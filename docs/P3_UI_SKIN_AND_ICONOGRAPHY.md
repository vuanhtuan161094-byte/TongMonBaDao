# P3 — UI SKIN + ICONOGRAPHY AUTHORITY

Date: 2026-10-03
Status: CANONICAL VISUAL UI CONTRACT

## 0. Phạm vi

Authority cho panel, frame, button, tab, resource chip, notification dot, icon family, typography mood và các lớp UI bám mép màn hình.

---

# 1. Style lock

Canonical UI visual language:

- giấy ngà / parchment sáng;
- line mực nâu đen/xám xanh;
- gỗ nâu đỏ dùng cho frame phụ;
- jade xanh trầm cho neutral/nav;
- vàng đồng cho selected/high-value;
- son đỏ/cam ấm cho primary action/cảnh báo nhẹ;
- đỏ dùng tiết chế cho danger;
- không neon;
- không glassmorphism;
- không glossy RPG fantasy;
- không SaaS card trắng hiện đại.

User ngày 2026-10-03 thích asset/UI mood của mockup V3 hơn V1/V2: sáng, hand-painted, parchment, dễ đọc, có cảm giác game mobile tiên hiệp sống động hơn.

---

# 2. Panel hierarchy

Các panel cần family thống nhất:

- parchment large overlay;
- parchment medium popup;
- compact quick card;
- tooltip;
- roster/list row;
- task rail;
- dark/jade top resource strip nếu cần contrast.

Không dùng 5 style border khác nhau trên cùng màn.

---

# 3. Buttons

Tối thiểu:

- primary;
- secondary;
- disabled;
- icon-only round/square;
- close;
- plus/resource add;
- collect/claim;
- small contextual action.

Primary action dùng cinnabar/amber warm accent; selected/navigation không được nhìn giống danger button.

---

# 4. Tabs

- normal: parchment/jade muted;
- selected: gold/ivory/highlight rõ;
- disabled/locked: desaturated;
- text ngắn;
- icon chỉ dùng khi giúp scan nhanh.

Không nhồi 10 tab cùng hàng nếu width không đủ; cho scroll/paging.

---

# 5. Resource chips

Top HUD resource chip:

- icon lớn hơn text một chút;
- amount ngắn `12.4K`, không số dài chiếm chỗ;
- `+` nhỏ nếu có flow add/buy;
- chỉ 4–5 resource quan trọng visible;
- phần còn lại vào Kho/resource detail.

---

# 6. Notification language

Red dot chỉ cho:

- new/actionable;
- reward ready;
- urgent unresolved state.

Không red-dot mọi menu.

World bubble dùng icon/action cue tách khỏi UI notification dot.

---

# 7. Icon family

Icon phải:

- cùng stroke/paint treatment;
- đọc được ở 24–40 px;
- silhouette đơn giản;
- không mix flat modern icon với painterly ancient UI;
- ưu tiên motif: jade, scroll, seal, coin, herb, ore, furnace, gate, sword, cauldron.

Không copy icon từ reference game.

---

# 8. Text / typography behavior

- tiêu đề ngắn, trọng lượng rõ;
- body text không quá nhỏ;
- số liệu align dễ scan;
- label quan trọng dùng Việt ngữ rõ ràng;
- avoid decorative calligraphy cho text dài;
- nếu dùng font cổ phong thì chỉ cho title/plate, body dùng font dễ đọc.

---

# 9. Mockup generation rule

Trước mỗi mockup mới:

- plan phải nói dùng panel family nào;
- vị trí HUD/task/nav;
- số resource visible;
- quick card hay deep overlay;
- không để image model tự phát minh theme UI mới.

Nếu mockup chỉ test layout, không cần redesign icon/panel đã có canon.

---

# 10. Production checklist

Cần production assets cuối:

- parchment 9-slice large/medium/small;
- compact quick card frame;
- top bar/resource chip;
- task rail row + collapse control;
- tab normal/selected/disabled;
- primary/secondary/disabled button;
- close/plus;
- portrait frame quality variants;
- notification dot;
- title plate;
- tooltip;
- scroll/rail;
- bottom nav selected/unselected.
