---
name: tmb-ui-playtest
description: "Nghiệm thu UI/UX Tông Môn Bá Đạo Godot Android ngang 1280x720: đọc chữ, camera tự do, zoom, thanh tiến độ Mỏ/Linh Lâm/Linh Điền, combat HUD, thanh HP/Injury, ảnh và thao tác thật; no fake UI."
---
# TMB UI Playtest — SKILL
Begin with one actual player journey, not a static prettiness pass. Reproduce on Godot 4.7.2 landscape 1280x720 and read the real simulation source of each displayed item. Show current work, worker, quantity, remaining time, completion, Warehouse receipt, HP/Injury, enemy targeting/casts, and AUTO ON/OFF only when real data exists.
Inspect contrast, font size, no overlap/clipping, tap targets, camera pan and zoom, selected actor vs free camera, foreground tree occlusion and responsiveness. For production show progress at exact mine/forest/field instance and state changes only after settlement. Do not invent mining/chopping/planting action when clips do not exist.
Prefer engine containers/anchors and event-driven state updates; keep gameplay truth outside renderer and avoid per-frame reformatting of thousands of labels.
One round of actual interaction beats screenshots of arbitrary placeholder states. Report tested resolutions, physical platform, observed problems and owner visual PENDING; a headless PASS does not equal user-friendly UI.
Source concepts: gamedev-skills/awesome-gamedev-agent-skills game-ui-ux, setcodes/gamedev-skills godot-gamedev.
