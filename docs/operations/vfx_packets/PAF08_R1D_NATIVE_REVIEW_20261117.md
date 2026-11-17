# PAF08 R1D – Lưu Văn Liễm Tức: Godot-native truthful visual review (2026-11-17)

## Owner decision carried forward
The owner said **“ok tạm đc đó. tiếp tục đi”** about PAF06 R5 after receiving a genuine native Godot sprite VFX candidate. Interpret as **PAF06 R5 PROVISIONAL_ACCEPT**, not unconditional final art or live PvE permission. Preserve PAF06 R5 verified content SHA `de2aeb5e6aaff60c08214d99a7ed23dd905be880` and all earlier R3/R4 revisions. PAF07 R1 Dưỡng Phù Quy Nguyên had a native technical PASS but no separate owner visual approval; do not silently promote it.

## PAF08 G0 canonical metadata
- Skill: `tmb.skill.talisman.phong_an_phu.passive_03.human`, **Lưu Văn Liễm Tức** / Phong Ấn Phù, Human tier.
- Catalogue `godot/data/combat/v63_talisman_combat_catalog.json`, effect passive, shape single_target, target_limit 1 as metadata, `ai_profile=passive_always_on`, `outgoing_factor=0.015` candidate.
- Cast/cooldown/duration/projectile speed/range/radius/damage ratio **ALL ZERO**. No cast or impact or enemy mark. This LAB is view-only and never modifies a combat stat/target/receipt.
- Three clocks: skill passive always active while equipped, VFX original 36-pose material/light loop **3.0s**, demo **252 frames/4.2s at fixed 60fps**. Cast/impact G3.5 gates are **NOT_APPLICABLE_BY_CONTRACT**; the three native checkpoints are material flow .42, 1.32, 2.37 seconds, NOT fabricated charge/hit/contact.

## G1–G3.7 art decisions
- G1 style reference: luminous green-jade pure energy with warm-gold lettering appropriate to the Phong school; **no Võ Lâm/Kiếm Thế commercial asset pixels or ripped VFX**.
- Unique semantic silhouette: **flowing calligraphic inscription** (Lưu Văn) forming from soft jade ink and concentrating into a warm gold flowing script at the forearm (Liễm Tức). No generic full-body twin-rings like PAF06, no hand-held pearl like PAF07, no paper talisman icons.
- Authored source: `tools/vfx/paint_paf08_liem_tuc.py` is deterministic first-party code-painted **isolated RGBA**, 36 independent poses per BACK/FRONT/SCRIPT layer (108 key poses), 320² cell, alpha atlas each 9×4 cells 2880×1280. Independent hot ivory filament, saturated jade body and soft halo; pose-specific moving caustic packets and dynamic ink stroke length. Source code is permanent in repo; PNG master and WebP atlas binaries are included in the exact-SHA Actions artifact and user ZIP (binary masters are not permanently committed; regenerate with Python/Pillow).
- R1 at `2a5f1a2`: actual native TECH PASS but self art FAIL because jade swoops looked like another buff ring.
- R1B at `a0954212`: TECH PASS, gold letters too close to the gold costume.
- R1C at `efa44f3`: TECH PASS, gold inscription relocated to forearm edge, still too static across keyframes.
- **R1D** `d5c092b853b92727540a9f8bb94898293b54daad`: individual original jade and gold ink stroke outlines **extend/retract** over time; not a whole-poster sine warp, no fake character movement or rig. Existing CAST art and approved PAF06/PAF07 source unchanged.

## Verified native technical result
- [GitHub Actions #44135022832](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/44135022832) **COMPLETED SUCCESS** on exact tested content SHA `d5c092b853b92727540a9f8bb94898293b54daad`.
- Genuine Godot **4.7.2 Compatibility**, Linux software renderer; video `paf08-r1-native.mp4`: 1280×720, **252 frames**, native 4.2s demo. Passive-OFF control is actually separately rendered in Godot at the same camera and sample clock; unrelated demon walks to prevent false target attachment.
- Focused contract `godot/tests/labs/combat_lab/vfx_paf08_r1_contract_test.gd` reported `PAF08_R1_FOCUSED_RESULT=PASS failures=0`, no fake cast/damage/target, toggling emission on/off.
- Visibility sample at t=1.32 seconds: **2114 pixels** changed >22 RGB threshold in caster ROI x498:778,y345:597 comparing native ON vs OFF; distinct forearm glyph ROI x662:710,y433:516 had **799 changed pixels** >26 threshold. Counts are screen-space visibility ONLY, not attractiveness. Original screenshot is 1280×720.
- Manual 12-checkpoint MP4 review t0.18–3.81s. Motion around forearm ROI x656:715,y429:529 between t.18 and t1.50 changed **693 pixels >28** with dynamic authored strokes vs **269** in static-ish R1C. Again a relative motion metric, NOT art scoring or physical measured FPS.
- Sources/receipt: `.github/workflows/vfx-paf08-script-native.yml`, `godot/labs/combat_lab/talisman18/luu_van_liem_tuc_r1.tscn`, its OFF baseline scene, source generator and native logs, keyed SHA in CI artifact `vfx-paf08-native-d5c092...`.
- Tech status: **SOURCE_RGBA_PASS / GODOT_IMPORT_PASS / FOCUSED_PASS / 1X_VISIBILITY_PASS / REAL_NATIVE_MP4_PASS**. Artwork review at gameplay scale: unique calligraphy clearer than initial, but gold strokes remain somewhat geometric and short; **ART_SELF_REWORK_SUGGESTED, OWNER_VISUAL_PENDING**, not fully released.

## Release and performance hold
**No merge, no new branch, no gameplay/Combat V2/SaveService/economy/AI/PvE/V6.3 writes.** Native Linux QA does not establish Android/Windows device performance, crowded combat readability or production-ready artist quality. PHYSICAL_DEVICE_PENDING / PVE_INTEGRATION_HOLD / OWNER_VISUAL_PENDING. Do not convert R1D to approved until the owner sees the actual native MP4.
