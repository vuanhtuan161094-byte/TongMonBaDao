# P3 — UI SKIN + ICONOGRAPHY AUTHORITY

Date: 2026-10-03
Status: CANONICAL VISUAL UI CONTRACT
Source availability: V3 MOOD APPROVED / EXACT V3 IMAGE NOT INGESTED / PRODUCTION UI SET PENDING

## 0. Phạm vi

Authority cho panel, frame, button, tab, resource chip, notification dot, icon family, typography mood và các lớp UI bám mép màn hình.

Đọc theo thứ tự:

1. `P3_PRESENTATION_MASTER.md`;
2. `P3_ART_BIBLE.md`;
3. `P3_ASSET_REGISTRY.json`;
4. `P3_SOURCE_RECOVERY_MANIFEST.md`;
5. file này.

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

# 2. Source status hiện tại

## `ui.main_map.v3_mood`

- visual mood: **approved**;
- exact generated image source: chưa được ingest vào repo/source_art và chưa có persistent locator xác minh;
- registry: `source_status=missing`, `source_evidence_class=S3`;
- vai trò: mood/layout reference, **không phải runtime UI pack**.

Nếu exact V3 image được phục hồi, ghi locator/checksum trước khi ingest. Không generate một lookalike mới rồi gọi đó là “V3 cũ”.

## `ui.skin.production_set`

- design/style: approved;
- exact production source: chưa sản xuất;
- registry: `source_status=missing`, `source_evidence_class=S4`, `visual=pending`;
- được phép sản xuất mới sau plan + user approval.

---

# 3. Panel hierarchy

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

# 4. Buttons

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

# 5. Tabs

- normal: parchment/jade muted;
- selected: gold/ivory/highlight rõ;
- disabled/locked: desaturated;
- text ngắn;
- icon chỉ dùng khi giúp scan nhanh.

Không nhồi 10 tab cùng hàng nếu width không đủ; cho scroll/paging.

---

# 6. Resource chips

Top HUD resource chip:

- icon lớn hơn text một chút;
- amount ngắn `12.4K`, không số dài chiếm chỗ;
- `+` nhỏ nếu có flow add/buy;
- chỉ 4–5 resource quan trọng visible;
- phần còn lại vào Kho/resource detail.

---

# 7. Notification language

Red dot chỉ cho:

- new/actionable;
- reward ready;
- urgent unresolved state.

Không red-dot mọi menu.

World bubble dùng icon/action cue tách khỏi UI notification dot.

---

# 8. Icon family

Icon phải:

- cùng stroke/paint treatment;
- đọc được ở 24–40 px;
- silhouette đơn giản;
- không mix flat modern icon với painterly ancient UI;
- ưu tiên motif: jade, scroll, seal, coin, herb, ore, furnace, gate, sword, cauldron.

Không copy icon từ reference game.

---

# 9. Text / typography behavior

- tiêu đề ngắn, trọng lượng rõ;
- body text không quá nhỏ;
- số liệu align dễ scan;
- label quan trọng dùng Việt ngữ rõ ràng;
- avoid decorative calligraphy cho text dài;
- nếu dùng font cổ phong thì chỉ cho title/plate, body dùng font dễ đọc.

---

# 10. Mockup generation rule

Trước mỗi mockup mới:

- plan phải nói dùng panel family nào;
- vị trí HUD/task/nav;
- số resource visible;
- quick card hay deep overlay;
- asset/reference nào là source thật, asset nào chỉ là S3 historical authority, asset nào là S4 production pending;
- không để image model tự phát minh theme UI mới.

Nếu mockup chỉ test layout, không cần redesign icon/panel đã có canon.

---

# 11. Production checklist

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

Mỗi asset sau khi user duyệt phải được cập nhật vào registry và recovery/source manifest trước khi coi là canonical production source.
