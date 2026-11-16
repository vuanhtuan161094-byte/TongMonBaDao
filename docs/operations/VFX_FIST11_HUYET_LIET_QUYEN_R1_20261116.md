# FIST11 R1 — Huyết Liệt Quyền / Huyết Quyền / Nhân giới

## G0 — authoritative catalogue (HEAD-verified)
- `tmb.skill.fist.huyet_quyen.active_01.human`, fist branch `huyet_quyen`.
- `effect=damage`, `element=nether`, `shape=single_target`, `target_limit=1`, `range=2.8`, `radius=0`, `cast_time=0.45`, `cooldown=8`, `projectile_speed=8`, `duration=0`, `power=0`.
- `hit_count` is NOT declared in canonical Human catalogue: packet keeps it **null**, no invented multi-hit count, extra DoT or status. The LAB uses exactly one synthetic contact for visual inspection only.

## G1–G3 | Existing Project Source and Rights
- New animated composite of project-first-party hand-painted `godot/labs/combat_lab/fist03/assets/godfist_master.webp` and `impact_master.webp` into blood-ink/crimson-garnet palette. Hand-painted source pigment and fist structure are retained. The visible VFX forms an independently composed directional fist with flowing dark-maroon streamers and warm white-pink knuckle streaks; not a solid red UI blob.
- Provenance status is **FIRST_PARTY_DERIVATIVE**, not a wholly new standalone ImageGen master. No copied game-art pixels from JX/Võ Lâm, not extracted from GIF/video/screenshot.
- 8 alpha cast/gather poses at 256, 12 actual flight poses at 256, 10 target impact poses at 320, total 30 frames on three 4-column PNG atlases, raw combined 10,158,080 bytes (9.69 MiB). **No rig**.
- Artwork quality must be manually checked: colored composite based on previous project source may still be visibly too similar to earlier fire/gold fist art; if so reject in art gate rather than misreport PASS.

## G3.5 timing and movement (LAB only)
- `0–0.45s` gather dark-red essence at the caster palm.
- `0.45–0.82s` blood-red fist rushes toward a separately moving enemy; trajectory derives from current `foe_at(t)` each render.
- `0.82–1.32s` one **LAB-simulated** local rose-white crimson impact, not an actual Combat V2 hit/damage/mark. No fake second hit.
- `1.32–1.54s` residual red-ink dissipates; reset at `2.20s`.
- Native QA frames t=`0.22` charge, `0.62` flight peak, `0.86` target contact, plus full **1280×720 Godot MP4** and 19 review PNGs. Native Godot 4.7.2 Compatibility, QA exact-SHA. No standalone GIF.

## Gate status
`G0_VALIDATED`, `SOURCE_REUSED_PROJECT_ONLY`, `ART_OWNER_PENDING`, `VFX_PROOF_PENDING`, `PVE_INTEGRATION_HOLD`, `PHYSICAL_QA_PENDING`, `V6.3_OFF`.

Do not merge, do not use rig, do not edit Combat V2, SaveService, gameplay economy or release-mode PvE. The owner-accepted FIST09 Trấn Sơn Hộ Đồng and FIST10 R4 no-hit are kept intact.

## R1 native self-FAIL → R2 painterly matte correction (2026-11-16)
- R1 exact SHA `92b07ee8767c218030efee7aff10bec791c4ff4b`, GitHub Actions #43905801051 **technical SUCCESS**, 30 RGBA frames and genuine Godot MP4 at 1280×720. 1x QA: flat/desaturated crimson flight and hard lower poster edge in the contacted impact at t0.86. **ART_SELF_FAIL.**
- R2 strengthens saturated garnet body and rose-white knuckle light, applies source-aware lobed edge alpha feather to the impact painting instead of scaling cropped rectangle, slightly reduces solid trail width. No GIF or source duplication from external commercial titles.
- Re-render charge .22 / flight .62 / moving foe contact .86 and full native MP4 exact SHA. FIST09 and FIST10 remain untouched. Manual owner art gate pending.
