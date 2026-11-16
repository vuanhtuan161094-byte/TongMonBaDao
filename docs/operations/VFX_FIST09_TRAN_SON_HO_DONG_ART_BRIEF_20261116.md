# Trấn Sơn Hộ Đồng / FIST09 R1 — Production System V4
Date: 2026-11-16. Branch integration/pve-p0-playable-ui-20261103; PR #72 Draft.

## Truth and prior decision
- Owner rejected **FIST08 Phản Chấn Quyền R2** and explicitly selects R1. FIST08 selection file in docs/operations/vfx_packets/FIST08_OWNER_SELECTED_R1_20261116.md; no further FIST08 artistic edits are authorized here.
- **New exact skill:** tmb.skill.fist.kim_cang.active_04.human: Earth / guard / single_target / target_limit 1 / cast .45s / duration 4s / range 5.5 / cooldown 8 / projectile speed zero / power .35. Legacy guard has no outgoing hit_count; packet declares zero, even though title sounds like defending a group.
- No fake multi-target benefit, damage return, summon, enemy hit, movement speed, HP, V6.3 or gameplay changes.

## Source art, style, rights
- Source: first-party original painting godot/labs/combat_lab/fist05/assets/spires_master.webp, independently reconfigured as three protective vertical mountain slabs, white-gold energized veins and scattered glassy rock shards. This is a distinct shield-like composition, but SOURCE MATERIAL IS SHARED with FIST05, not an independently generated new stone-painting master. Do not conceal this limitation or claim source from JX.
- VFX style: clean ivory/gold compressed mountain aura with broad painterly source shapes, no repeated rings/dome/glyph, not a monster attack. One local defender, moving-target tracking.
- Offline artist: tools/vfx/generate_fist09_tran_son_ho_dong.py. 8 cast poses at 320x320, 8 quiet status at 192x192, 8 protected-hit contact at 256x256. 24 poses on 3 RGBA atlases, 6,553,600 bytes uncompressed source (6.25MiB); no per-instance runtime texture duplication implied.
- Actor: unchanged original Nu Doc Tu 4-direction WALK and IDLE sprite for QA scale, NOT owner-approved new Kim Cang character rig or body animation.

## Three clocks, no invented live receipt
- Authority: cast 0-.45s, shield .45–4.45s, cooldown 8s, hit receipt source unknown, RUNTIME_MAPPING_PENDING.
- Local visual: mountain cast/burst 0-.78s; the shield shrinks to small stone markers after .45s; synthetic protected-hit contact at 1.30 and 3.13, 0.26s each; status fades 4.45–4.88s.
- Movie: isolated 5.35s loop, 1280x720 fixed 60fps video, not an Android FPS measurement.
- G3.5 real Godot charge .25, peak .59, moving protected-hit contact 1.34; mandatory human look before claiming art pass.
- G4 motion/anchors: one moving protected WALK actor and independently walking enemy; blocked impact follows protected actual frame. No fake strike.
- G5 15-timecode genuine 1280x720 movie inspection, dark/bright terrain review required. Art risk: three pillars may feel too rocky versus pure light quality target; decide by screenshots, not CI.
- G7: exact SHA V4 packet/assets/evidence manifest, original art SHA256, focused test and 1280x720 proof. OWNER_VISUAL_PENDING; PVE_INTEGRATION_HOLD; V6.3_OFF; PHYSICAL_ANDROID_PENDING.


## R1 native G3.5 / full film ART FAIL and R2 correction
- R1 exact SHA \`6ef9ffb84c19fc344ba9627eb504150d4ea0101c\`, Actions #43822106152 technical SUCCESS, full 333-frame 1280×720 Godot movie and V4 proof. Native 1x art at charge/peak: three duplicate golden oblongs due to full-alpha yellow haze, small weak status markers and soft block. **R1 ART SELF_FAIL; owner was not asked to approve it.**
- R2 is an ART-source correction not code-drawn runtime geometry: luminosity-selected ONLY original rock-vein emission, overlap three different rock poses into a more integrated mountain ward, strengthen 4s shoulder marks and 0.26s protected hit contact. 24 poses, three atlases, 6.25MiB unchanged. Validate exact Godot V4 again and manually inspect; no art PASS or PvE enable until owner.
- This R2 belongs ONLY to FIST09; FIST08 Phản Chấn Quyền R1 remains restored per owner's decision.


## R2 native QA and R3 scale/lighting rework
- R2 exact SHA \`decf66d441153a7c2b0922a218f0a4efffd993ce\`, Actions #43822930260 technical SUCCESS: full 333-frame 1280×720 Godot movie, 17 1× frames, V4 packet/asset/3 native preflight proofs and strict focused PASS. Manual 1× frames: flat yellow capsule outlines fixed; still undersized cast and weak 4s sign/local block. ART_SELF_REWORK.
- R3 adjusts only genuine existing atlas's hot vein emission (not whole-rock glow), LAB cast scale 1.13→1.43, status 1.11→1.29, protected-hit contact .95→1.22. 24 poses and 6.25MiB unchanged. No runtime generated circles, rig, fake damage or PvE integration. Another native exact-SHA film is mandatory before judging.
