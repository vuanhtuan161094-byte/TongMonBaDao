# Sword art review candidate R2

This folder is an isolated art review only. Nothing here is an approved production/runtime asset.

## Three directions

- A — Huyền Mộc · Tứ Khung: narrow straight jian, offset interlocking bronze frame guard, smoke-black steel and dark jade.
- B — Tử Yên · Song Khuyết: broad leaf blade with open negative-space windows, braided knot guard, ivory steel and plum enamel.
- C — Thanh Xà · Lưu Vân: continuously curved blade, folded asymmetric ribbon guard, jade-black enamel and antique copper.

The owner's two uploaded sword images were used only as references for material craft density and finish. The three concepts use different blade silhouettes and guard structures; exact reference geometry/layout was not copied. These are still generated concept candidates and require owner art direction.

## Pairing and scale truth

The scene shows exact AS48/AS49 source identity PNGs beside each sword candidate. The source images retain their old baked weapons, so they are identity references only. New options are not composited into a hand or presented as tested overlays.

The small comparison row is 52×52, matching portrait.custom_minimum_size = Vector2(52, 52) in godot/src/presentation/p3_1_landscape_sect.gd on PR #72 parent HEAD 7a6875302552043bd7ff43c5cb796de1c55d9f36. This is the current map portrait-slot size, not a verified scale for a future full-body animated actor. The larger sword render is a design-detail view only.

## Gates

- Candidate art: OWNER_APPROVAL_PENDING
- Runtime integration: NOT_STARTED
- Weapon hand/grip placement: NOT_STARTED
- Per-frame pivots/occlusion: NOT_STARTED
- Full animation production: WAITING_FOR_ART_DIRECTION
- Gameplay/Combat/SaveService changed: NO
- Approval: not claimed

## QA

- Official Godot: 4.7.2 stable official ed1daf0bf
- Isolated project import: exit 0
- Godot native review scene / Viewport capture: exit 0, 1280×720
- The process used a project-local isolated APPDATA; no game profile or player save was opened.
- Godot logged Failed to read the root certificate store in this Windows sandbox; the project still imported, rendered and exited 0. No script parse or rendering error was logged.

