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


## R3 exact-SHA outcome and human 1× visual gate — 2026-11-16
- Tested exact code SHA: \`a3d2c7747278152383d3b030e6c33b1dbd169af4\`; workflow [Actions #43823508990](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43823508990) **SUCCESS**.
- Reproducible V4 packet/atlas/evidence validations PASS; Godot 4.7.2 official strict parse and focused moving-guard contract \`VFX_FIST09_FOCUSED_RESULT=PASS failures=0\`; 333-frame true native 1280×720 movie (5.55s at encoded 60 fps) and 17 timestamped PNGs. Original project-owned 24 frames / 3 atlases / 6,553,600 raw RGBA bytes.
- **Manual native 1× review:** 0.25/0.42/0.59 guardian looks like three nearly parallel jagged luminous stone spikes, not yet a distinguished mountain shield; 0.84/2.22 sustained buff is two tiny detached marks difficult to perceive in actual battle; 1.34/3.19 protected contact is an oversized diagonal flare, lacking a crisp local impact. Real actors and ground composition readable, but visual identity/impact still below owner JX-quality target.
- **ART_SELF_FAIL / ART_REWORK_REQUIRED**, \`OWNER_VISUAL_PENDING\`, \`PVE_INTEGRATION_HOLD\`, \`V63_OFF\`, \`PHYSICAL_ANDROID_PENDING\`. Do not promote to finished/approved art from technical CI success, and do not pretend an encoded 60-fps fixed-clock video proves Android FPS.
- Verified downloadable GitHub workflow artifact: \`vfx-fist09-r1-v4-native\` (historical name despite R3 code) artifact #14204939737, contains \`fist09-r1.mp4\` (historical filename) plus PNG atlas and native times. Both filename and artifact label are legacy; **SHA and \`R3_BRIGHT_SCALE_MOUNTAIN_GUARD\` script define the actual R3 version**.
- Owner-selected FIST08 R1 remains restored; this FIST09 review does not alter earlier skill selection.

## R4 source-composite remake — 16 Nov 2026
- Owner REJECTS FIST09 R3. R3 video and artifact remain archival, not art PASS.
- Replaces the **three offensive-looking upright spikes** with a wide gold illustrated protective arch and two horizontal weight-bearing rock shoulders, crown and foot seal, more readable 4-second moving buff, and incoming right-flank compressed painted shield on block. Same single-target Earth guard contract.
- Original source/rights: both FIST05 cracked rock painting and FIST07 first-party gold illustration; R4 crops the lower protective arch/ornaments, NOT the deity. This is an explicitly acknowledged **first-party derivative composite** rather than a new standalone commissioned/ImageGen master. Duplicated art language and matte quality require manual inspection.
- Three clocks unchanged: canonical cast 0.45s and guard 0.45–4.45s; LAB-only 0–0.78s cast visuals, synthetic blocks at 1.30s/3.13s and fade by 4.88s; actual Combat V2 guard receipt mapping pending.
- Visual gate: G3.5 three true native Godot frames at .25/.59/1.34 on protected walking actor, full 1280x720 movie and >=12 timestamps, manually inspect on actual 1x terrain. R3 technical CI success is NOT R4 evidence. Until reviewed: ART_REVIEW_PENDING, OWNER_VISUAL_PENDING, PVE_INTEGRATION_HOLD, physical QA pending.

## R4 native self-fail and R5 remedial re-bake (2026-11-16)
- R4 exact SHA \`3681982960d527e054023cc8332e9fafde4c3029\`; Actions #43831348972 **GODOT_TECH_PASS** on original master + 24 poses + real moving protected WALK + 1280x720 full movie + 17 frame checks, artifact #14209305212.
- Visual inspection of actual .59 / 1.34 / 2.22 screenshots: cast is a clearer broad arc than R3, but giant rectangular source cutout edges at contact and shoulder guards visibly break production quality. **R4 ART_SELF_FAIL**; no owner approval.
- R5 keeps only R4's useful broad arch, rebakes every painted crop with a spatially broad feathered irregular-intensity matte to erase straight rectangular cut lines; increases sustained painted shoulder visibility, lowers crown toward head and moves defended-hit flank to x+67.
- No invented outgoing damage/return, no new cast event, no rig, no PvE. Before R5 self art judgment: require genuine G3.5 charge .25, peak .59, moving defended-hit 1.34; full native 1280x720 and 12+ frame review. OWNER_VISUAL_PENDING, PVE_HOLD, physical device QA pending.
