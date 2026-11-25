# Phá Vây Khai Sơn R1 — G3.5 status

**Current gate:** source G3 self-review pass / formal owner G3 pending · focused runtime `checks=29` · exact-SHA native 1280×720 technical and visual self-review PASS · owner pending · PvE HOLD.

The preview reuses the existing male Blade disciple AS50, its candidate frame-by-frame main-hand sockets and hand masks, and the existing `curved_dao` candidate image. A preview-only scale and direction override keep the actor near 68 px at 720p and align the DAO tip toward the target. No new disciple art, shared socket edits, rig, catalog or gameplay change was made.

Contact and fade appear only after the isolated `MapBattleV2` cast produces the exact `v63_skill_hit` receipt. The focus test confirms the 0.28 s cast plus 4.0 / 10.0 projectile travel, one target and one hit; the native scene moves the runtime monster during flight. The production `blade_skill_combat` gate remains OFF.

## Exact-SHA native review

- Exact source SHA `105b48ee77174c99974912208031c9bd263b0c74`; shared V4 native run [#45586338616](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45586338616) passed packet/assets validation, strict import/parse, focused receipt test, native Xvfb capture and FFmpeg encoding.
- Inspected charge at 0.12 s, peak at 0.40 s, contact at 0.75 s, and an extracted fade frame at 0.90 s. Relative actor/monster scale, rightward DAO orientation, charge placement, moving target and contact readability pass visual self-review.
- Native runner log confirms one `MapBattleV2` `v63_skill_hit`, one target, one hit, moved target, and production gate OFF. The V4 manifest still has `no_runtime_receipt=true` and `runtime_receipt_timestamp=RUNTIME_MAPPING_PENDING`; it does not encode receipt timing. Keep the runner logs and capture together as evidence.
- Full workflow artifact and packet snapshot are archived in `evidence/native_g35_20261125_run45586338616/`; checksums and review are in `NATIVE_VISUAL_SELF_REVIEW.md`.

## Remaining gates

- Formal owner G3 and actor/weapon art approval remain pending; current source candidate status is unchanged.
- Bright-terrain G3.6, no-HUD semantic G3.7, full G5 motion review, physical Android QA and live PvE remain unexecuted or OFF.
