# VFX-TAL01 R3 — Điện Quang Khai Phù / exact-SHA motion QA

Date: 2026-11-14. Owner decision: `OWNER_VISUAL_PENDING`.
Scope: one **Human** master only: `tmb.skill.talisman.loi_phu.active_01.human`. No other talisman or poison skill was coded.

## Source and evidence
- PR [#72](https://github.com/vuanhtuan161094-byte/TongMonBaDao/pull/72), existing branch `integration/pve-p0-playable-ui-20261103`.
- **Art source SHA tested:** `1ebf7834c17a0ff8e511a2097fd77eca6311a469` (R3). The R1 base code `4231bc9316d46019d624e4274305c293c2538011`, R2 `fb5b32ef3f4337ca2fd2b5b3696e1143a84ed599` are retained in history.
- **Real Godot 4.7.2 workflow run:** [#43575037278](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/43575037278), artifact ID `14106261494`, name `vfx-tal01-1ebf7834c17a0ff8e511a2097fd77eca6311a469`.
- Strict Godot import, `--check-only`, focused `vfx_tal01_contract_test.gd`: `VFX_TAL01_FOCUSED_RESULT=PASS failures=0`. Exit 0, no gameplay authority edits.
- Genuine Godot GL Compatibility movie: **1280×720 / 188 fixed-clock frames / 60/1 encoded FPS / 3.133333s**; MP4, GIF, 14 PNG checkpoint frames and SHA256SUMS in workflow artifact. Encoded frame rate is NOT measured Windows/Android performance.
- Original generator `tools/vfx/generate_talisman01_atlas.py` outputs 900×1440 RGBA 12-pose sheet; source script, Godot scene, and tests are committed. Asset generated deterministically during QA, not a proprietary JX/VL PNG.

## Canonical skill contract (read-only)
`damage`, `lightning`, `single_target`, cap **1**, cast **0.50s**, cooldown **9.40**, range **8.50**, declared projectile speed **10.0**. LAB choreography is a preview; its impact is deliberately called `demo_contact`, **NOT** a real Combat V2 hit or damage/status receipt.

## Native motion inspection
Actually examined workflow movies/contact sheets and checkpoint frames at:
`0.12, 0.26, 0.43, 0.56, 0.73, 0.90, 1.08, 1.25, 1.43, 1.51, 1.66, 1.92, 2.23, 2.57` seconds.

- **R1 visual debt:** single bolt was a detached short line at 1.08, and impact was six evenly spaced bright spokes at 1.51. R1 tech PASS was not art PASS.
- **R2 correction:** one continuously connected source-to-moving-head filament, full-path alpha taper and up to two minor forks; at 1.08 the arc visibly reaches back to caster.
- **R3 correction:** localized uneven lightning streams and tiny motes in the actual target's chest area; at 1.51 no six-spoked uniform star icon. Phase timing, original paper atlas and flight remain unchanged.
- The effect returns to a clear screen at 2.57. No persistent AoE disk, no second gameplay hit, no fake DoT/guard/heal.
- **Art review:** original parchment/ink sprite is distinct from generic SVG; the R3 lightning and impact are perceptible at 1×. Subjective Source-VL-equivalence or final beauty **not owner-approved**. Actor is a preexisting female Poison asset used only as a composition stand-in; the correct Phù Tu cast pose and real target are future integration/character tasks, not claimed complete.

## Decision gates
- `CODE_LAB_READY`, `GODOT_FOCUSED_PASS`, `GODOT_CAPTURED`, `FRAMES_REVIEWED`.
- `OWNER_VISUAL_PENDING` — owner has not reviewed/approved the R3 native animation.
- `PVE_INTEGRATION_HOLD`, `V63_OFF`, `PHYSICAL_WINDOWS_ANDROID_PENDING`, `RIGHTS_OF_EXISTING_STANDIN_UNVERIFIED_FOR_RELEASE`.
- No rig, Codex, merge/branch, live gameplay, Combat V2, HP/targets, SaveService, economy, AI or other schools altered.

**Next only after owner visual feedback:** correct this same R3 if needed. Owner acceptance of isolated LAB still does NOT authorize connecting to live PvE, switching feature gate, or replacing the actual character.
