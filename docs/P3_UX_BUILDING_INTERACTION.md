# P3 — BUILDING INTERACTION & MANAGEMENT UX AUTHORITY

Date: 2026-10-04
Status: CANONICAL BUILDING UX DESIGN — USER APPROVED

## Core rule
Buildings are living workplaces, not passive stat cards.

Canonical flow:
Map -> world cue -> tap building -> right building summary panel -> quick action OR Quản lý -> deep building screen.

This extends the approved V3 language: left = tasks, center = world, right = selected-target summary, deep systems = parchment overlay/page. Do not use a floating center popup as canonical building interaction.

## One-tap questions
One tap should answer:
- What building is this and what level/function?
- Is it operating?
- Who is here?
- What is it producing/providing?
- What critical input/capacity does it depend on?
- Is there a problem/opportunity?
- What can the Sect Master do immediately?

## Selection
Tap building: select it, focus camera lightly, show restrained selection treatment, and open a right vertical panel in the same family as V3.2. Target width is about 280–320 px at 1280×720. Map remains visible and usable. Panel never scales with map camera.

Tap another building or actor replaces the selected target and panel; never stack target windows. X or blank tap closes it and returns to V3.1.

## Panel hierarchy
1. Identity: name, level, short function tag, small icon/thumbnail if available.
2. Operating state: current production/service, progress, remaining time when meaningful, worker/slot count, efficiency/output/capacity metric appropriate to that building.
3. People: real involved disciples, role, relevant condition/contribution, empty slots. Tap portrait -> V3.2 disciple summary.
4. Inputs/capacity/dependency: only decision-relevant materials, storage, beds, slots or supply dependencies. Do not dump full inventory.
5. Problems/opportunities: low material, near-full storage, insufficient workers, exhausted/injured worker, output ready, upgrade available, event requiring decision.
6. Quick actions: roughly 2–4 common actions plus primary deep entry Quản lý.

## Operating-state semantics
Presentation should distinguish these when underlying systems support them:
- ACTIVE — operating;
- IDLE — available but no task;
- BLOCKED_INPUT — missing an input/condition;
- BLOCKED_WORKFORCE — insufficient workforce;
- OUTPUT_READY — result/capacity needs attention.

These are presentation semantics over real runtime state, not duplicate simulation state. Always show the reason, e.g. “Tạm dừng — thiếu Linh Thảo”, not generic “Lỗi”.

## Explainability
Derived metrics such as efficiency should expose a cause breakdown when real authority provides it: base value, building level, worker/profession contribution, fatigue/condition penalty, environment/resource modifiers, and other real modifiers. UI must not invent a second formula.

Goal: the player understands why a number changed and can make a decision.

## Workforce philosophy
Assignment is strategic intervention, not mandatory minute-by-minute puppeteering. Where supported, worker choice may affect productivity, quality/risk, fatigue/recovery, mood/social consequences, profession/mastery progression and events. Player chooses people/policies/priorities; disciples carry out work in the simulated world. Routine micromanagement remains optional at scale.

## Production queue / automation direction
When gameplay authority exists, production buildings should scale to multiple batches, reorder/cancel, repeat targets and conditional stops such as minimum reserve or desired stock.

Examples: “Produce Hồi Khí Đan until Kho >= 100” or “Stop when Linh Thảo < 20”.

This is a design target only; do not fabricate a presentation-only queue before runtime authority exists.

## Deep management
Quản lý opens a parchment deep overlay/page while preserving world context.

Target information architecture:
1. Vận hành / Sản xuất — recipe/service, inputs, output, queue, progress.
2. Nhân sự — assigned disciples, suitability, condition, open slots.
3. Nâng cấp — cost, prerequisites, time, explicit unlock/value.
4. Nhật ký — optional/later, only when runtime event history exists.

Routine one-tap questions should not require this deep screen.

## Building dependency graph
Buildings participate in one world economy rather than isolated mini-games.

Conceptual flow: resource source / expedition -> Kho -> production/service building -> Kho / disciple use.

Warnings should link to their cause/source when useful. Example: Dược Phòng thiếu Linh Thảo -> show real Kho reserve / known incoming source -> focus Kho or relevant assignment. Never fake supply data.

## Building <-> disciple navigation
Bidirectional:
- building worker portrait -> V3.2 disciple panel;
- disciple current location/building -> building panel.

Direct orders should become visible world behavior when simulation supports it, e.g. a disciple leaves Dược Phòng and walks to Đệ Tử Xá after a rest assignment.

## World cue language
Avoid alert spam. Canonical cue families:
- check mark: output/result ready;
- exclamation: problem/attention;
- work icon: active production/service;
- ellipsis: event/decision.

If multiple conditions exist, show the highest-priority cue on the map; panel explains the rest.

## Building-specific primary questions
- Tông Môn Đại Điện: Tông môn đang phát triển thế nào?
- Đệ Tử Xá: Ai đang nghỉ, còn chỗ không, hồi phục thế nào?
- Tu Luyện Đài: Ai đang tu, tiến độ/tốc độ ra sao?
- Kho: Có gì, sắp đầy hay đang thiếu gì?
- Luyện Khí Đường: Đang chế tạo gì, ai làm, bao giờ xong?
- Dược Phòng: Đang luyện gì, ai làm, nguyên liệu đủ không?
- Khu Khai Khoáng: Đang khai thác gì, sản lượng/nhân lực thế nào?
- Tông Môn Đại Môn: Ai ra/vào, đội nào bên ngoài, có khách/sự kiện gì?

Shared shell does not mean identical data.

## V3.4 proof state — Dược Phòng
First visual proof deliberately includes a small operational problem:
- Dược Phòng — Cấp 2;
- active;
- Hồi Khí Đan x20;
- progress 12/20;
- remaining 04:32;
- workforce 2/3;
- Hắc Liên — Chủ luyện;
- Lý Thanh — Phụ việc;
- one empty slot;
- efficiency 86%;
- warning: Linh Thảo chỉ đủ 1 mẻ tiếp theo;
- quick actions: Thu hoạch disabled while unfinished, Đổi sản phẩm, Điều động;
- primary action: Quản lý.

These exact values are mockup proof data unless/until backed by runtime state.

## V3.4 visual constraints
Keep V3.1 composition and V3.2 interaction language:
- logical 1280×720;
- bright/airy hand-painted xianxia map;
- left task rail, top HUD and bottom navigation unchanged;
- right panel same material family as V3.2;
- selected Dược Phòng remains visible where composition permits;
- a few nearby actors/world-life cues;
- no central floating tooltip;
- no redesign of canonical Dược Phòng architecture.

Exact approved building source bytes are currently S3/missing. Any mockup representation is reference-only and cannot silently replace the approved canonical building asset.

## Runtime boundary
This document locks UX design, not implementation PASS. Presentation reads/calls real authority. Workforce, inventory, materials, action/location, production/queue and commands must come from their real systems. If a field lacks runtime authority, mark it future/presentation-proof until that system exists. Never create duplicate UI-only production economy.

## Runtime acceptance target
No building UX runtime PASS until real Godot proves selection/panel behavior, runtime-backed data, building<->disciple navigation, clean close, real alerts/actions, deep-management context restoration, and no camera/V3 regression.
