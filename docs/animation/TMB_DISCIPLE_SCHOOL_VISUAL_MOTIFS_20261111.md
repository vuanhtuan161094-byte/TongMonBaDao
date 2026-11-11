# Character art guide — 12 môn phái, 36 nhánh

**Scope:** visual-only direction for the Issue #77 character-family pipeline. The school and branch names follow the current V63 design authority. This file does not create skills, VFX, gameplay effects, or animation assets.

Three schools have existing runtime catalogues (Cung, Quyền, Độc); nine schools are still planning-only. **All 36 entries below are art guidance until a rig, storyboard, authored frames, and QA evidence are linked.** Reuse a shared compatible body rig, but make each school recognizable through weapon, posture, and gesture. Keep VFX outside character frames.

| Môn phái | Common silhouette | Nhánh | Motion signature for storyboard | Art status |
|---|---|---|---|---|
| Cung Tu | Lean aim line, bow as a separate prop | Liệp Ảnh | Stable aim, draw, release one straight arrow | DESIGN_ONLY |
| Cung Tu | Open shoulder and raised bow | Linh Tiễn | Longer focus pose, high release; projectile remains external | DESIGN_ONLY |
| Cung Tu | Broader sweep and lifted elbows | Thiên Vũ | Upward sweep and release; never bake arrow volleys into actor | DESIGN_ONLY |
| Quyền Tu | Low center, independent fists, opposite hip/shoulder turn | Bá Quyền | Compact guard then one heavy punch | DESIGN_ONLY |
| Quyền Tu | Braced stance and paired forearm guard | Kim Cang | Tighten guard, hold balance; shield VFX remains external | DESIGN_ONLY |
| Quyền Tu | Close aggressive posture | Huyết Quyền | Short burst then recover; no wound/HP change from art | DESIGN_ONLY |
| Độc Tu | Flexible wrist; needle/vial props separate | Độc Châm | Elbow draw then short flick; no projectile baked in | CANDIDATE_V4_ONLY |
| Độc Tu | Hands form a seal; keep body silhouette readable | Cổ Độc | Close hands into seal then turn palms outward; serpent is external VFX | DESIGN_ONLY |
| Độc Tu | Open palms and grounded medicinal stance | Dược Độc | Gather hands then extend; lotus/heal effect remains external | DESIGN_ONLY |
| Kiếm Tu | One clear sword line; weapon separate | Ngự Kiếm | Leading hand points; flying sword is a separate actor if sourced | DESIGN_ONLY |
| Kiếm Tu | Tight stance with sword close to body | Sát Kiếm | Short wind-up, one decisive cut, clear recovery | DESIGN_ONLY |
| Kiếm Tu | Crossed guard and rear foot bearing weight | Hộ Kiếm | Guard, receive, then return to stance; no fake parry event | DESIGN_ONLY |
| Đao Tu | Wide shoulders and heavy separated blade | Cuồng Đao | Hip rotation and capped sweep sequence | DESIGN_ONLY |
| Đao Tu | Stable rear leg with descending diagonal | Trảm Phách Đao | Raise, shift weight, make one weighty cleave | DESIGN_ONLY |
| Đao Tu | Wide planted feet and horizontal guard | Trấn Đao | Bring blade across, hold line, recover into guard | DESIGN_ONLY |
| Song Đao | Two separate blades with independent hands | Ảnh Nhẫn | Alternate left/right hand timing; no duplicate afterimage body | DESIGN_ONLY |
| Song Đao | Staggered alternating rhythm | Liên Hoàn | Readable combo beats with anticipation and recovery | DESIGN_ONLY |
| Song Đao | Paired blades form a crescent at crossing | Huyết Nguyệt | Cross briefly then separate; color does not imply HP change | DESIGN_ONLY |
| Thương Tu | Long straight shaft and fixed two-hand grip | Phá Trận Thương | Step forward and thrust down a straight line | DESIGN_ONLY |
| Thương Tu | Spear tip leads while torso follows | Long Thương | One line thrust and return; dragon trace is external | DESIGN_ONLY |
| Thương Tu | Horizontal spear guard across the body | Hộ Quân Thương | Move from guard to protective stance while feet stay planted | DESIGN_ONLY |
| Chưởng Tu | Open palm and readable arm line | Liệt Dương Chưởng | Gather, then deliver one forceful palm; no baked fire/AoE | DESIGN_ONLY |
| Chưởng Tu | Soft curved arm, slow palm direction | Hàn Ngọc Chưởng | Lead with smooth forearm and palm; frost is external | DESIGN_ONLY |
| Chưởng Tu | Balanced posture and both hands open | Hồi Phong Chưởng | Draw in, then extend gently; heal only follows a real event | DESIGN_ONLY |
| Trận Tu | Balanced stance, hands mark ground anchors | Tụ Linh Trận | Place and hold the pose; formation circle is a separate layer | DESIGN_ONLY |
| Trận Tu | Hands outline a boundary | Phong Tỏa Trận | Close the hands like closing a boundary; no baked rune | DESIGN_ONLY |
| Trận Tu | Planted stance and low marking gesture | Sát Phạt Trận | Mark a point and withdraw; ground zone stays external | DESIGN_ONLY |
| Triệu Hồi | Inviting gesture with actor space beside the body | Kiếm Linh | Guide with one hand; spirit sword stays a separate actor | DESIGN_ONLY |
| Triệu Hồi | Open outward silhouette with room for a beast | Linh Thú | Call and hold a clear side space for a separate actor | DESIGN_ONLY |
| Triệu Hồi | Protective arm and compact stance | Khôi Lỗi Hộ Pháp | Commanding gesture; puppet is a separate actor | DESIGN_ONLY |
| Chú Tu | Finger seal; text stays off the body sprite | Trấn Hồn Chú | Form seal and hold; status visuals are external | DESIGN_ONLY |
| Chú Tu | Pulling hand gesture and slight torso lean | Phệ Linh Chú | Draw back then recover; no baked tether or drain | DESIGN_ONLY |
| Chú Tu | Raised forearm protects the chest | Hộ Mệnh Chú | Raise guard and hold; do not imply resurrection or injury clear | DESIGN_ONLY |
| Phù Tu | Paper/talisman prop in a separate hand layer | Lôi Phù | Take and release a talisman; lightning stays external | DESIGN_ONLY |
| Phù Tu | Compact paper prop close to the chest | Hỏa Phù | Draw and extend; area fire stays external | DESIGN_ONLY |
| Phù Tu | Short placement gesture toward the target | Phong Ấn Phù | Place/release the seal then hold; glyph stays external | DESIGN_ONLY |

## Palette and material suggestions

These are art-only recommendations, not runtime properties: Cung — moon silver/ink blue; Quyền — dark stone/red bronze; Độc — violet-black/jade; Kiếm — silver steel/ink violet; Đao — dark steel/brick red; Song Đao — graphite/deep crimson; Thương — blue steel/antique gold; Chưởng — warm earth/cool jade by branch; Trận — indigo ink/stone; Triệu Hồi — ash violet/jade; Chú — ink violet/bronze; Phù — ivory paper/cinnabar ink. Palette never grants skill effects or stats.

## Shared clip contract

Compatible actors may share Idle, Walk, Cast, Attack, Hit, and Death timing structure, but school identity comes from distinct key poses, props, and weapon rhythms. Missing clips remain missing. This guide does not claim any branch currently has its own authored animation.

## Current coverage

Only Nữ Độc Tu has a V4 four-direction atlas candidate in this review pack. It has not passed Godot or target-size visual QA. Every other branch above remains without a verified school-specific character animation. Existing Source A packages stay in their unverified identity categories.
