# TMB PR72 — Poison VFX skill-by-skill art brief (Human pilot)
Date: 2026-11-10. Scope: **Lab-only V4**. No source game art copied.
Owner reference: classic Võ Lâm / Kiếm Thế spell richness, **not** permission to duplicate intellectual-property assets.

## Verified sources and methods

- Riot Games — Art Education VFX: https://www.riotgames.com/en/artedu/visual-effects — communicate gameplay and character identity, restrain visual clutter.
- Godot 4.x — Particle Systems 2D: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html — animation flipbooks, particle generation and culling.
- Godot 4.x — CanvasItem shader reference: https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html — `blend_add`/alpha, light core versus soft smoke.
- Riot VFX Style Guide (reference only; independent asset creation): https://nexus.leagueoflegends.com/wp-content/uploads/2017/10/VFX_Styleguide_final_public_hidpjqwx7lqyx0pjj3ss.pdf

**Guiding timing:** authentic `skill_cast` = telegraph/anticipation, `skill_release` = shot/locked AoE, committed `hit`/`v63_skill_hit` = punch/impact, committed `status_tick` = minimal residue; no invented damage, no fabricated hit count or target. Test all at 1x (actual game), 2x (presentation), 4x/6x (framing debug). Footprint beneath sprites, projectile/impact above.

## Canonical names and VFX briefs

The names, effect, target shape, range, target cap below are read from `godot/data/combat/v63_human_combat_catalog.json`. The final column is art direction only, not implemented gameplay power.

| Canonical skill suffix | Tên trong game | Mechanic (catalog) | Hình thái VFX |
|---|---|---|---|
| `basic.human` | Độc Châm Thường Thức | Sát thương, Đơn, tầm 6 | Kim ngọc tím-bạc đơn, dư ảnh ngắn |
| `mobility.human` | Yểm Ảnh Bộ | Thân pháp, Đơn, tầm 11 | Tàn ảnh tím mỏng, sáng tại điểm đến |
| `doc_cham.active_01.human` | Xuyên Cốt Độc Châm | Sát thương, Đơn, tầm 7.5 | Kim nhọn xuyên, tia bạc tại điểm trúng |
| `doc_cham.active_02.human` | Phệ Mạch Độc Thích | Gây độc, Đơn, tầm 7.5 | Kim tím sẫm, vân độc lan qua thân |
| `doc_cham.active_03.human` | Bách Độc Tán Châm | Gây độc, AOE R3, ≤3, tầm 7 | Mưa/quạt kim tán trên vòng AoE |
| `doc_cham.active_04.human` | Độc Khí Phệ Tâm | Gây độc, AOE R3, ≤3, tầm 7 | Xung khí độc tím-lục sát đất |
| `doc_cham.ultimate.human` | Vạn Độc Xuyên Tâm | Gây độc, AOE R3, ≤3, tầm 8.5 | Đại trận nhiều kim hội tụ |
| `co_doc.active_01.human` | Phụ Cốt Cổ | Sát thương, Đơn, tầm 7.5 | Cổ trùng nhỏ bay và cắn |
| `co_doc.active_02.human` | Xà Ảnh Quấn Mạch | Gây độc, Đơn, tầm 7.5 | Xà ảnh cuộn siết quanh mục tiêu |
| `co_doc.active_03.human` | Cổ Vụ Mê Tung | Gây độc, AOE R3, ≤3, tầm 7 | Sương lục thấp với cổ quang |
| `co_doc.active_04.human` | Tán Cổ Diễn Nhiễm | Gây độc, AOE R3, ≤3, tầm 7 | Cổ trùng tản từ tâm vùng |
| `co_doc.ultimate.human` | Vạn Cổ Phệ Giới | Gây độc, AOE R3, ≤3, tầm 8.5 | Xà ảnh lớn và quầng cổ quang |
| `duoc_doc.active_01.human` | Tẩy Mạch Linh Dược | Sát thương, Đơn, tầm 7.5 | Dược châu lam ngọc bung cánh nhọn |
| `duoc_doc.active_02.human` | Giải Độc Hộ Tâm | Hồi phục, Đơn, tầm 6 | Liên hoa ngọc sáng nâng trên đồng minh |
| `duoc_doc.active_03.human` | Nghịch Độc Phản Chế | Thanh tẩy, Đơn, tầm 6 | Dược ấn xoay ngược kéo độc |
| `duoc_doc.active_04.human` | Sinh Cơ Tán | Thanh tẩy, Đơn, tầm 6 | Cánh hoa mịn và bụi ngọc |
| `duoc_doc.ultimate.human` | Vạn Linh Giải Ách | Hồi phục, Đơn, tầm 6 | Đại liên hoa nhiều lớp, hồi máu đơn |

## Palette and priority

- Độc Châm: midnight violet `#24163F`, luminous purple `#7A5CFF`, mint specular `#A7F28A`. Pierce silhouettes; fan needles for named AoE; no generic giant rings.
- Cổ Độc: dark green `#24351C`, toxic chartreuse `#B8E85B`, antique gold `#F3E37C`. Insect bite / living serpent / low opaque mist must be distinct.
- Dược Độc: deep jade `#143E3D`, mint-teal `#63E6BE`, blue jade `#74F0D4`, gold `#F6D97A`. Heal ascends; cleanse pulls out; damage strikes. Dược Độc's `active_01` is **damage**, `active_02` is **heal**.

**Important bound:** `Bách Độc Tán Châm` is radius **3 cells** with **max 3** affected targets per approved cast; six physical monsters inside are not six guaranteed hits. `Vạn Linh Giải Ách` is **single-target HEAL**, not AoE. Never derive mechanics from the spell's cinematic name.

## Implementation authority and acceptance

- Art metadata source `godot/labs/combat_lab/combat_lab_poison_skill_art_brief.gd`: exactly 17 scoped Human attack/mobility/active/ultimate IDs. The Lab displays real effect, authored geometry and distinct **visual** descriptions without modifying canonical catalogue.
- Draw-only V4 module `combat_lab_poison_v4_layers.gd` renders skill motifs by exact canonical ID; none writes battle state. Existing MapBattleV2, V6.3, SaveService, and player assets remain unchanged. No new paid asset or external texture; original line/polygon effects only.
- 5 passive + 1 innate per Human poison branch are intentionally not given false cast/impact visuals. Immortal/Divine visual briefs are a different, unapproved gate.
- **Artistically not yet final:** 4 true Nữ Độc Tu views final atlas not committed to repo, Combat Lab still uses legacy mirrored `nu_doc_tu_grok_01` pending accepted source. Do not claim final 4-view integration.
- Official Godot 4.7.2 import/compile/contract + 4v8 AoE cinematic and Windows/Android physical FPS are required before declaring PASS. Source/CI status must be associated with exact SHA.
