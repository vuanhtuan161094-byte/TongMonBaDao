# PAF04 R6 – Hộ Mệnh Lưu Văn: moving-energy exact-SHA native Godot verification

Date 2026-11-17. Owner rejected PAF04 R3 as art FAIL: apparent flat image stretch/scale/fade, not living VFX, and requested research-inspired remaking, **without any requirement for 3D**.

## Change and source preservation
- Exact code SHA tested: `1de15ad4d0558f0685dac985727b94824b3276ac` on PR #72 Draft / `integration/pve-p0-playable-ui-20261103`.
- Rebuilt VFX source in `tools/vfx/paf04_glass_guard_assets.py`: original frame-by-frame RGBA independent travelling light on multiple deforming curves, not 2D copies of a stretched poster. R4 introduced moving packets and actor-relative recentering, R5 made luminous cores more legible and added one small 2D Godot canvas_item shader sampling the screen buffer for moving faux refraction (`godot/labs/combat_lab/talisman14/living_glass_refraction.gdshader`); R6 makes **different partial segments advance and retreat along the flow** rather than displaying a fixed closed shield ring, and re-centers the charge streams near the self character's palms instead of above the head.
- Glass/energy is 2D RGBA plus small sprite-contained shader, not a 3D model and **not** skeletal rigging. Authored masters + six independent atlases remain reproducible from committed source; no borrowed commercial game asset pixels. All other PAF01–PAF03 sources unchanged.

## Three-clock separation and exact contract
Exact Human skill `tmb.skill.talisman.phong_an_phu.active_04.human`: wind, guard/mitigation, single **SELF**, target_limit1, hit_count1, range8.5, guard power0.16, cast0.5s, status duration4.0s, cooldown13.6s, projectile_speed0, damage0.
- **Gameplay clock:** real guard receipt still `RUNTIME_MAPPING_PENDING`; no CombatV2/SaveService/PvE modifications.
- **VFX optical clock:** first charge flow in .03–.58s; shield forms from .55, synthetic lock around .82–1.30, end of large glass field1.48, small residue1.67.
- **Movie clock:** 2.0s native Godot video at 1280x720, encoded 120 frames at 60fps, not a four-second fixed shield movie. Four-second status expiry is tested separately in LAB.

## Exact-SHA technical evidence
- [GitHub Actions #44002044548](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44002044548) **SUCCESS** at SHA `1de15ad4d0558f0685dac985727b94824b3276ac`, artifact ID `14292243711` named `vfx-paf04-native-1de15ad4d0558f0685dac985727b94824b3276ac`.
- Native Godot `4.7.2.stable.official`, Compatibility, strict import/parse and focused checks PASS: `VFX_PAF04_FOCUSED_RESULT=PASS failures=0`. V4 packet/assets/evidence PASS; negative missing-contact evidence fails as expected. Real moving SELF WALK actor, three native charge/peak/contact 1280x720 screenshots at .30/.72/.99, at least 12 checkpoint frames and 2.0s native MP4.
- Native MP4 SHA256 `948d53b8c011c0ee2ce509d2d5807a4896393c00cd86b67215a8bb59ff2e6ee4`.
- Native 12-frame motion review at .12/.25/.43/.56/.67/.78/.89/1.00/1.13/1.32/1.49/1.62: charge now converges at the body instead of a symmetric crown, partial lights appear progressively at .56–.89; a stronger moving contact crest appears .99–1.13, followed by segment-wise release before 1.49. **Residual limitation:** faux glass still suggests a faint globe at some timestamps and source remains code-painted; 2D refraction/performance not measured on physical Android.

## Honest gates
`G0 / V4 TECH / NATIVE GODOT = PASS`. 
`SELF ART = IMPROVED MOTION, NOT PROFESSIONAL ART PASS`; `OWNER_VISUAL_PENDING`.
`PVE_INTEGRATION_HOLD / V6.3_OFF / PHYSICAL_ANDROID_AND_WINDOWS_QA_PENDING`.
Do **not** merge, integrate into Combat V2, create GIF or claim real live status receipt.