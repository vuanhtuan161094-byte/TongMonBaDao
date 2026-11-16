# POI10 R2 — Độc Khí Phệ Tâm · complete original art remake & shared Poison status

Owner feedback on 16/11/2026: **POI10 R1 ART REJECTED**: dark rectangular alpha contamination, weak organic impact, wrong visual hierarchy and a continuous individual poison-body-mark on each victim. Preserve old R1 files for audit only. Remake art, do not call an exact-SHA engine PASS art approval.

## G0 authoritative Human catalogue, separated from demo timing
Skill `tmb.skill.poison.doc_cham.active_04.human`, branch `doc_cham`, element `nether`, effect `poison`, shape `circle`, `radius=2.6` in game-world units, `target_limit=3`, `range=7`, `cast_time=0.65s`, `cooldown=12s`, `projectile_speed=8`, `damage_ratio=0.9`, `duration=6s`, `poison_stacks=1`. **No `hit_count` property appears in this canonical Human entry.** Its value must remain UNSPECIFIED, not made up by the VFX layer. PvE/V6.3 OFF, `RUNTIME_MAPPING_PENDING`; the mock 1.51/1.59/1.67 contact times are NOT Combat V2 hit receipts.

## G1 artistic reference observations, not assets
- **Diablo II: Resurrected Poison Nova:** clear accelerating central burst and green outward radial lances; contrast comes from bright center against darker floor. Reference: https://www.buffed.de/Diablo-2-Resurrected-Spiel-73212/Guides/totenbeschwoerer-gift-nova-poison-1382302/
- **Path of Exile Contagion:** attack/area motif can be purple chaos energy, while status is a separate ongoing effect represented by state/UI. Reference: https://www.poewiki.net/wiki/Contagion
- **Diablo IV poisoned state:** health UI indicates ongoing poison separately from its application attack VFX. Reference: https://www.icy-veins.com/d4/guides/poisoned-status-effect/
- **Godot additive 2D sprites:** native Godot documents the advantages of additive sprites for transient 2D lighting, with limitations. Reference: https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html

No commercial Source VL/JX/Diablo/PoE pixels, audio, or frames are copied. These sources only informed animation hierarchy, distinguishable poisoned state and transient attack readability.

## G2–G3 original unique new art and atlas source
Original first-party transparent AI-painted high-resolution **2172×724 RGBA** three-component image generated for this user's Tông Môn Bá Đạo VFX request, not an actual Godot frame. Cropped faithfully into THREE independent high-quality alpha WebP masters retained under `godot/labs/combat_lab/poison10/r2_remake/assets/master/`:
- `poi10_charge_master.webp`: original 480×600 violet-green bud (caster charge).
- `poi10_bloom_master.webp`: original 1130×724 irregular violet-green radiant poisonous lotus, not a tiny 80px crop.
- `poi10_contact_master.webp`: original 577×595 separate off-axis penetration/contact cluster.
- Main original sprite material remains fully painted. Generator `tools/vfx/generate_poi10_r2_painted.py` composes independent petals, varying scale, pose, transparency, rotation and fade, not a code-only vector circle or rig.
- Attack atlases: `10 × 192×192 charge` (768×576), `12 × 384×256 lotus burst` (1536×768), `8 × 192×160 local contact` (768×320).
- **30 unique attack poses** (10/12/8), plus one shared badge `64×64`; 7,487,488 raw RGBA8 bytes ≈ 7.14 MiB for these four textures. This excludes actor textures, render targets and other skills; no measured Android FPS or VRAM guarantee.

## Shared poison mark — canonical state, NOT attack visuals
New reusable `res://labs/combat_lab/shared_poison_status/poison_status_badge.gd` + `poisoned_badge_64.png`: one small turquoise poison-droplet UI/overhead badge above any monster with poison stacks and remaining seconds. **No six-second large aura/particle** per target. Multiple poison skills may reuse this icon when the resulting *actual status* is the same. Do not claim their durations, stacking/refresh rules or ownership are identical without inspecting Combat V2 receipts. In the isolated POI10 LAB the mark is toggled by explicitly labeled synthetic demo times; live PvE must use actual authoritative status snapshot, only when separately approved to integrate. POI07 damage-only has no fake poison badge.

## Three-clock matrix and 1× scene
- **Catalogue clock:** cast 0.65s, status duration 6s, cooldown 12s, projectile_speed 8; runtime actual hit/area targeting unknown.
- **LAB animation clock:** 0–0.65 bud charge; 0.65–1.26 one cosmetic source bud flight to area center; 1.26–2.32 expanding asymmetric painted luminous lotus; 1.51,1.59,1.67 **synthetic** contact overlays on three genuinely walking monster sprite targets; each target shows only the shared overhead Poison icon while the demo status is active.
- **Movie clock:** preflight G3.5 115 frames/1.917s with `charge=0.33`, `peak=1.40`, `contact=1.67` genuine Godot 1280×720 captures; full presentation loop 513 frames/8.55s only after visual G3.5 STOP review; neither is runtime performance.

## Technical, owner and PvE gates
- Dedicated scene `res://labs/combat_lab/poison10/r2_remake/doc_khi_phe_tam_r2.tscn`, source `doc_khi_phe_tam_r2.gd`, focused `res://tests/labs/combat_lab/vfx_poi10_r2_contract_test.gd`.
- V4 preflight packet `docs/operations/vfx_packets/POI10_R2_V4_PREFLIGHT.json` verifies canonical identity, source rights, painted full-size master, movement with existing `SpriteFrames.walk`, status badge semantics, no alpha bleed and 3 genuine 1280×720 screenshots plus MP4 with exact-SHA manifest. Canonical missing `hit_count` is represented as **null/unset** instead of guessed; generic validator needs to accept that metadata gap without altering gameplay.
- **R2 INITIAL STATE: G3.5 NOT_RUN, NATIVE_VIDEO NOT_RUN, OWNER_VISUAL_PENDING, ART_SELF_REVIEW_PENDING, PVE_INTEGRATION_HOLD, PHYSICAL_DEVICE_QA_PENDING, V63_OFF.** Update with actual exact SHA/test results after running. R1 stays ART_REJECTED.
- Explicit owner art approval after viewing the true Godot clip is mandatory; no CI check may declare art PASS. No Codex, skeletal rig, branch, merge, AI/economy/Combat V2/SaveService or live PvE edits.