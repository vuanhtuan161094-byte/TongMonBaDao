# FIST07 R5 — Kim Cang Hộ Thể: persistent JX-style buff, three clocks
**2026-11-16 | PR #72 Draft | Godot 4.7.2 Compatibility | art = owner pending**

## G0 — canonical truth, no gameplay fabrication
- Skill `tmb.skill.fist.kim_cang.active_02.human`, branch Kim Cang, Human; effect **guard**, element **earth**, shape **single_target**, cap=1, cast 0.45s, duration **4.0s**, cooldown 8, range 5.5, projectile speed 0, radius 0, power .35.
- The canonical Fist human JSON does **not declare** `hit_count`; for this **guard-only visual** the packet uses `hit_count=0` exclusively as “no outgoing hit”, not as a new game rule. V4 validator must tolerate this missing field ONLY for guard while still comparing all other fields, and assert matched skill school when catalogue has no root-level `school`.
- Existing V4 R4 reused a large goddess/guardian+glass dome through 4 seconds, causing visual clutter and losing readability; the owner asked to learn how JX/Kiếm Thế shows multi-second states.

## G1 — references / legal provenance / what is inferred
1. Official **Kiếm Thế basic UI guide** (https://kiemthe.vnggames.com/cam-nang/tan-thu/giao-dien-co-ban.html) explicitly confirms current buffs have icons and duration. This supports status readability, **not** the claim every JX shield uses one identical sprite/length.
2. JX1 technical skill format community notes (https://github.com/lichnt318/jx1/blob/main/%5BJx1%20linux%20PC%5D%20H%C6%B0%E1%BB%9Bng%20d%E1%BA%ABn%20To%C3%A0n%20B%E1%BB%99%20v%E1%BB%81%20skills) describe `PrecastSpr` and `StateSpecialId`, differentiating cast art from buff-state art. This is community documentation, not a current licensed source dump for copying.
3. Source screenshot of a VLTK scene displays small symmetric auras around several actors while the body remains visible (GameHub 2020). We use the **design principle** of less persistent on-screen occlusion, never the pixels/assets.
4. **Original first-party ImageGen master** generated specifically for this rework in chat, stored as an encoded WebP in `godot/labs/combat_lab/fist07/assets/source/kim_cang_guardian_master_r5.webp.b64`. The master portrays a golden divine guardian and a transparent-open protective dome with the actor body not included; `tools/vfx/generate_fist07_jx_buff_r5.py` bakes 24 RGBA sprite frames from it, with no commercial JX pixels, no rig.

## G2–G3 — distinct art at three separate intensity levels
**Three clocks; do not conflate them:**
| Authority / phase | Time | What it means |
|---|---|---|
| Canonical cast | 0–0.45s | Gameplay authority only; no hit receipt manufactured |
| LAB cast art (8 poses) | 0–0.78s | Single brilliant illustrated guardian appears then **retracts once**; 0.45–.78 tail is a visual fade, not an extended cast |
| Canonical guard duration | 0.45–4.45s | **4 seconds buff**; actor can move and be readable |
| LAB sustained art (8 looping poses) | 0.45–4.45s | Only a restrained bright foot seal + two faint shoulder glints + small chest highlight; no arena-sized 4s dome |
| LAB guarded-hit demos | 1.29s, 3.12s | Local 0.24s white-gold painted contact on **protected moving actor**; `H` manually tests a block; no outgoing enemy damage |
| LAB status fade | 4.45–4.84s | Light subsides and temporary LAB buff icon clears; genuine runtime expiry mapping pending |
| LAB loop reset | 5.28s | Demo clock only |

**3 original pixel atlases:** cast 8×320px/4×2 (1280×640) = 3.125MiB RGBA; quiet status 8×192px/4×2 (768×384) =1.125MiB; guarded hit 8×256px/4×2 (1024×512) =2.00MiB. **Total 6.25MiB raw source pixels** and 24 poses; additional one 64px LAB-only status icon. Resource use is a budget, NOT measured Android VRAM/FPS.

**Art layering:** terrain behind → large guardian cast only → small feet/shoulder status loop follows walk → unmodified actual character WALK frames → local hit flash on protected walker only → LAB-only status icon/duration. Godot uses atlas regions, opacity, transforms and text; does not paint shield outline via geometric primitives. Source frames show real painted material and changed opacity/art silhouette, though key poses are derived from one illustrated master and **not independently painted eight originals**; quality gate remains manual.

## G3.5 native STOP / G4–G7 evidence
- V4 packet: `docs/operations/vfx_packets/FIST07_R5_PERSISTENT_GUARD_V4.json`.
- Early native 1280×720 images `v4-charge.png` (0.30), `v4-peak.png` (0.59), `v4-contact.png` (1.33 **moving protected actor**), validated with `tools/qa/validate_vfx_v4_packet.py` on exact SHA; artificial `H` events do not claim Combat V2 receipts.
- Full 1280×720 Godot MP4 + GIF + ≥17 checkpoints after technical preflight; actual 1× visual gate must compare with owner reference at charge and high-energy content. Strong cast is allowed; restrained sustain is **intended**, not weaker art.
- Source/master committed as `.b64` and deterministic generator to avoid expiring CI artifact as only storage.
- Test uses actual **unchanged** `walk_4dir_APPROVED_UNCHANGED.png` for walking instead of translating an idle frame; shield/contact position follows the moving recipient. Opponent walker also moves during the test.
- **Must never claim:** poster preview equals Godot video, exact 60FPS fixed movie equals Android FPS, technical script PASS equals human art PASS. `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `V63_OFF`, physical Android/Windows pending. No rig, Codex, branch, merge, Combat V2, SaveService, economy or other-school edits.

## R5 actual native QA and R6 artist corrections
- R5 exact source SHA `0c32073f72010b0fa3c933123613d8b64e81e5b2`, official [GitHub Actions #43799366518](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43799366518): V4 packet+assets+evidence, strict Godot 4.7.2 import/parse/focused and native 1280×720 film all TECHNICAL PASS. Actual moving WALK subject and moving opponent verified, 3 image preflight at .30/.59/1.33.
- Owner-reference comparison at real 1×: R5 cast guardian at .59 too faint due premature art fade; localized guarded-hit flash at 1.33 too subtle. R5 is ART_REWORK_REQUIRED, not owner-approved. Do not conflate technical success with visual quality.
- R6 corrected **only original sprite/visual timing**, not gameplay: retain cast illustration close to full brightness until .63s, then rapidly retract by .78s, increase illustrated alpha and feather rectangular-origin matte, bake a short white-hot contact glint into the existing guarded-hit atlas. The 4-second sustained buff remains small quiet art; 3 pages / 24 poses / 6.25 MiB raw unchanged. R6 exact-SHA Godot and manual motion review remain mandatory.
