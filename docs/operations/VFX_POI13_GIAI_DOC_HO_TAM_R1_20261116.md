# POI13 — Giải Độc Hộ Tâm R1 — Native VFX, no GIF

Date 16 Nov 2026; PR #72 Draft `integration/pve-p0-playable-ui-20261103`. New asset only; prior POI11 R9 and Poison Basic V3.1 provisional assets remain unchanged. Owner explicitly requested direct real **VFX** production and no GIF.

## Exact G0 catalogue
`tmb.skill.poison.duoc_doc.active_02.human`, Human Dược Độc, effect **HEAL**, element **wood**, shape **single_target**, cap1, range **6.5**, cast **0.55 s**, cooldown **18 s**, speed **0** (no missile), duration **0** (no prolonged shield/DoT), numerical damage_ratio **0.05** is a catalogue field **NOT** proof of actual healing amount. Catalogue does not declare hit_count; no invented heal receipt, poison cleanse or true HP state. Do not turn the friendly name into `cleanse`; POI14 Nghịch Độc Phản Chế is catalogue `cleanse`.

## Art identity
Original translucent jade pearl forms in caster hand (8 pose); two cupped emerald/teal leaf wings appear around **one MOVING ALLIED disciple chest** and brighten a white hot center (10 pose); seven tiny mint/ivory motes rise and vanish (8 pose). This is not the same flat green projectile used for POI12, nor a ring, hard black matte, snake tail, giant opaque smoke or any alleged healer gameplay status. A SEPARATE walking monster appears as combat background but does not receive healing visuals.

Code-painted first-party full color/alpha source `tools/vfx/generate_poi13_heal_heart.py`, original 3 PNG master keyposes, 3 animated atlases of 8/10/8 transparent frames. Source and ingame sprite are separate from any unapproved illustrated actor. No GIF, rig, Codex or copyrighted pixel extraction.

## Three-clock truth
Combat cast0.55, cooldown18, no status duration and no projectile. **LAB-only**: charge0-.55, one ally heart light .55-.98, rising light .98-1.56, fade; demo loop1.9s. At charge t=.28, peak t=.82, contact/release t=1.20 the actual scene shows moving ally and moving unhealed monster. No real CombatV2 hp update and no heal receipt; later PvE integration must first map actual target identity and authority separately.

## QA and owner
Godot 4.7.2 Compatibility native 1280×720 MP4 (120 encoded fps60 frames ~2sec) and three native 1280×720 charge/peak/contact PNG on a moving allied disciple, with a simultaneously walking monster, and 12 motion checkpoints for manual review. V4 packet/assets/evidence exact-SHA, focused target/cast/effect assertions and original alpha masters are non-negotiable.

**Initial gates:** `TECH_G35_NOT_RUN`; `ART_MANUAL_REVIEW_REQUIRED`; `OWNER_VISUAL_PENDING`; `RUNTIME_MAPPING_PENDING`; `PVE_INTEGRATION_HOLD`; `V63_OFF`; `PHYSICAL_QA_PENDING`. No merge/new branch or modifying combat, SaveService, AI or economy.

## G3.5 exact-SHA Godot result — 2026-11-16

- Technical CI **SUCCESS**: [GitHub Actions #43904363236](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43904363236), source commit **`74d8fa0565ed602c33c7ebded72adca9ee67f7e7`**, [artifact #14245020793](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43904363236/artifacts/14245020793), V4 `VFX_V4_PACKET_TECHNICAL_PASS`, `ASSETS_TECHNICAL_PASS`, `EVIDENCE_TECHNICAL_PASS`, Godot 4.7.2 import/parse/focused `POI13_HEART_R1_RESULT=PASS failures=0`.
- Actual **native 1280×720 MP4, 120 encoded video frames at fixed 60fps, 2.0 seconds**, three Godot native PNG proofs charge `0.28`, peak `0.82`, contact `1.20` s, 14 native timeline captures. Video SHA256 `575149db43eec8460732c2753017d20d33ae327ee3fb7eabf1a6569e3d4c62d0`. All 26 original RGBA key pose PNG atlases + 3 master art PNGs were saved on the same PR branch by CI after verification. 120 encoded movie frames are **not** 120 atlas poses, and neither implies Android FPS.
- Original owner-approved disciple sprite reused twice for caster/moving ally; separately moving enemy WALK sprite is visible but NOT the healing target. No rig, no GIF, no actual healed HP event or cleanse receipt. Catalogue is `effect=heal`, NOT `cleanse`, no persistent shield or duration.
- Human visual inspection of true Godot 1× screenshot and enlarged crop: good separation of cool jade leafy light from character, alpha is transparent and no square matte; however the peak leaf silhouette is still somewhat angular / V-shaped and the final release is visually subtle. **ART_CANDIDATE_OWNER_REVIEW, NOT OWNER_ART_PASS.** Optional R2 polish only after feedback: more organic flowing lobes and brighter graceful leaf release, not random glowing circles.
- Gates: `V4_G35_NATIVE_TECH_PASS`, `SOURCE_MASTERS_COMMITTED`, `ART_CANDIDATE_REVIEW_PENDING`, `OWNER_VISUAL_PENDING`, `PVE_INTEGRATION_HOLD`, `RUNTIME_MAPPING_PENDING`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_QA_PENDING`.
