# Tông Môn Bá Đạo — Visual Quality & Light Language V1

## Owner's confirmed design decisions
- Owner likes procedural **sét** and **rắn ánh sáng V9** because moving light feels alive.
- Reject V9–V17 sword work when it looks like stiff geometric shapes, identical glowing sticks, physical steel blades or overlapping UI circles. Green CI is NOT art approval.
- Use provided classic-Võ-Lâm screenshot as visual direction: many **unequal** blue-white tapered streaks orbit around a character; white-hot thin core + soft blue-violet falloff + misty ground ring. Actor remains readable in center; no constant opaque blue disk. A screenshot shows appearance, not production technique or actual movement frame timing.
- Gold standard: **light defines the silhouette, rather than painting a shape blue and applying glow**. Test at 1× gameplay scale, not oversized preview.

## Aesthetic grammar by family
| Family | Physical silhouette | Light signature | Motion | Contact | Reject |
| --- | --- | --- | --- | --- | --- |
| Kiếm khí | none/energy only | pointed white-core azure haze, narrow tapered light | accelerates, bends gently, clear lead/trail | brief razor-cut + fragments | metallic hilt/guard, flat triangle, repeated ellipses |
| Phi kiếm thực thể | real sword | lit edge, fin and thin tail, steel stays shaded | coherent orientation and arrival | point piercing / cut by actual event | all-blend-add washes metal into white |
| Kiếm trận | no need for steel | orbiting unequal long/short luminous needles | multiple rings, slight phase/velocity differences | inward collapse only after actual trigger | 12 uniform spokes or solid donut |
| Lôi | energy branch | bright core with cyan/violet aurora | restless fractal forks, quick fade | localized lightning flash | static zigzag ladder |
| Cổ độc | serpentine energy | jade + violet moving core | 2–3 twisted wave lanes with distinct moving head | bite flicker, quiet status mark | blob snake PNG, fake DoT |
| Độc châm | sharp micro-line | dark violet + toxic small bright tip | ultrafast straight/fan | single puncture | fake poison on damage-only skill |
| Dược độc | lotus / jade air | gentle green-white wave | rising/wrapping | heal/cleanse only when real | violent damage burst on heal |
| Hỏa | optional smoke/flame tongues | yellow-white inner fire, orange-red gradient | turbulent rising and shedding ember | localized burst/scorch | one flat orange circle |
| Băng | physical crystal | icy highlighted edges, pale fog | grow then shatter | sharp crack + fading mist | glow-only when ice must crystallize |
| Thủy | fluid | cyan light crests / layered alpha | unequal overlapping ripples & swirls | directional droplets | uniform blue rings |
| Phong | air shear | thin white/teal outer rim | angular-curved, asymmetric moving wake | brief sweeping cut | a stationary outline |
| Phù/Trận | original glyphs & lines | fine strokes + joint glows | staged line-appearance/activation | event-bound discharge | commercial copied JX glyph |
| Hộ thể | thin aura | faint always-on edge, hotspot at blocked hit | restrained stable | only a real guard proc | opaque permanent globe obscuring player |
| Triệu hồi | original formation | portal opening light + brief motes | ring opens, actor appears, ring dissolves | no extra fake hit | visual actor counted as gameplay spawn |

## Five stages — one consistent choreography
A. **Tụ khí**: a few light strands gather near hand/weapon or ritual source, minimal alpha; actor remains visible.
B. **Xuất chiêu**: short high-energy emission and meaningful change in acceleration; energy scale stays connected to caster.
C. **Phi hành/duy trì**: clear head/axis, living wake, nonuniform bends/brightness; group spell has compositional hierarchy.
D. **Va chạm thật**: a *single localized sharp peak* only on confirmed target/hit/status event; no fake additional contacts and no crossing through chest of monster.
E. **Tan biến**: tip shortens/erodes, halo softly fades, debris sparse; no static white line left over.

## Layer implementation in Godot 4.7.2 GL Compatibility
- Light core: thin continuous high-value gradient, tapered to sharp point.
- Mid energy field: colored soft falloff, aligned to same spine, separate from real body material.
- Outer halo: smooth distance-based alpha fade, not multiple fully opaque hard-edge geometric pieces.
- Trail: follows real path history, high energy near tip and low near tail; avoid identical shifted copies.
- Ground atmosphere: gentle ellipse oriented with terrain/caster footing; transparent center and no fake AoE.
- Material-specific geometry for literal sword/ice/rock, otherwise favor original shader/ribbon/particle light. Optional authored sprites are fine with rights + production QA; do not claim JX uses no textures.
- Fixed LOD budgets, event-driven lifetime, deterministic replay; no unnecessary Forward+ HDR bloom dependency.

## Project status and reference doc

a) `docs/operations/VFX18_JX_SOURCEA_LIGHT_LANGUAGE_RESEARCH_20261113.md` — full owner-style audit.
b) `godot/labs/combat_lab/combat_lab_v9_energy_fx.gd` — serpentine energy technique praised by owner.
c) `godot/labs/combat_lab/combat_lab_v14_sword_fx.gd` — physical metal-like blade (not the sword-qi target).
d) `godot/labs/combat_lab/research01/` and `research02/` — prior rejected/awaiting approval baseline and Godot evidence.

These are working references, not permission to edit game runtime. Read live GitHub HEAD and latest owner comments before acting.
