# Vân Long Điểm Thủy — Spear VFX Art-First packet, R1

**Status:** preview-only candidate. G3 source review is a self-pass. G3.5 native technical capture and visual self-review passed on exact packet SHA `979604473787d224080eebd3a2d7965588ba877b`. Actor and weapon art owner review is pending. PvE and production gates remain OFF.

## G0 — exact identity and runtime contract

- Skill: `tmb.skill.spear.long_thuong.active_01.human` — Vân Long Điểm Thủy.
- Family: `tmb.skill.spear.long_thuong.active_01`; school `spear`; branch `long_thuong`; tier `human`.
- Contract: `damage`, `line`, `target_limit=2`, `range=6.2`, `cast_time=0.38`, `cooldown=10`, `projectile_speed=0`, `metal`, `hit_count=1`.
- Visual truth: one axis-bound thrust trace, attached to the caster's spear movement. It is not a free-flight projectile. Contact art is drawn only for a matching, committed `v63_spear_line_hit`; this presentation adds no target or damage.

## G1–G3 — source and 1x review

All four final RGBA masters were generated through `image_gen.imagegen`. The exact prompts, original generated paths, sizes, alpha ranges, hashes, and intended display widths are recorded in [`assets/source/manifest.json`](../../../godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/manifest.json). No commercial JX pixels or external reference art were used. The previous peak draft is retained only as edit provenance and is not used in the scene.

| Phase | Source | SHA-256 | Intended motif width |
| --- | --- | --- | ---:|
| Charge | `charge_r1.png` | `b1570eb7920534b7c59d5047158388f545c5333e07266c2f11c4d054982782ac` | 48 px |
| Peak release | `peak_r2.png` | `ab47f16ecdfa5c968ecc97c90c993e7726509f33026dc0e80fa442a9f7ec3998` | 150 px |
| Confirmed contact | `contact_r1.png` | `5ca6ecf790750f74586545dc61c89511d305c6f9550acb4a55f9792f2f469aa6` | 42 px |
| Dissolve | `fade_r1.png` | `5615db468e42b93e3080eda60a6ff0dee15ef8f343aa166f78ca68c4dfb0cb71` | 58 px |

The source-only scale sheets were produced with `tools/vfx/prepare_g3_source_review.py`, then visually inspected against dark and light backgrounds at their listed 1x motif widths. The charge reads as a compact silver-cyan coil; the peak is a narrow rightward thrust trace with a cloud curl; contact is a localized glint; fade is two thin remnants. This supports **G3_SOURCE_SELF_PASS** only; it is not a Godot render, formal art approval, or owner acceptance.

## Candidate actor and target evidence

- The scene uses the actual AS54 `SpriteFrames` attack-right clip and candidate spear socket/weapon adapter from `PveASCharFrameRendererV1`; it uses no rig. The AS54 body, weapon, and sockets remain `CANDIDATE` / `PENDING`.
- Three actual `MonsterCatalogueV2` Thanh Lang runtime actors are used in `MapBattleV2`. The preview moves all three actor positions during the 0.38-second cast interval. Two remain in the line and the third is outside it.
- Target presentation uses the supported generic Source A monster pack `monster_1113031_1`. Its species-to-visual mapping is unverified; the scene labels this placeholder explicitly. Combat receipts and HP are from runtime actors, not the visual mapping.
- On release, `MapBattleV2._release_casts()` runs the normal line query and damage settlement. The LAB asserts exactly two `v63_spear_line_hit` receipts, each with `target_limit=2`; both in-line actor HP values fall and the outside actor's HP stays unchanged. The scene draws contact art only at those two receipt targets.

## Verification and gate boundary

Godot 4.7.2 focused test:

```sh
XDG_DATA_HOME=/tmp/tmb_spear_godot_data XDG_CACHE_HOME=/tmp/tmb_spear_godot_cache \
  /usr/local/bin/godot --headless --path godot \
  --script res://labs/combat_lab/spear01/van_long_diem_thuy/r1/vfx_spear_long_thrust_receipt_test.gd
```

Result: `SPEAR_LONG_THRUST_RECEIPT_RESULT PASS checks=20 runtime=MapBattleV2 moving_targets=3 line_receipts=2 cap=2 actor=AS54_CANDIDATE source=SourceA_PLACEHOLDER pve=OFF gate=OFF`.

Godot native scene runtime:

```sh
XDG_DATA_HOME=/tmp/tmb_spear_godot_data XDG_CACHE_HOME=/tmp/tmb_spear_godot_cache \
  /usr/local/bin/godot --headless --path godot \
  --scene res://labs/combat_lab/spear01/van_long_diem_thuy/r1/van_long_diem_thuy_preview.tscn \
  --quit-after 120
```

Result: scene runtime reached `CONFIRMED_TWO_TARGET_RELEASE`; 2 line receipts, cap 2, outside HP unchanged. Project import completed with exit code 0; Godot printed editor-config write errors because `/home/agent/.config/godot` is unavailable, but import and native runtime completed.

The first local framebuffer attempt was blocked because this workspace exposes only the headless dummy display; it produced no screenshot. A display-backed run then passed using Godot 4.7.2 Xvfb/ffmpeg: [exact-SHA run #45579114495](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45579114495). Its three 1280×720 phase frames and 1.23-second MP4 are archived in [`native_g35_20261125_run45579114495/`](../../../godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/native_g35_20261125_run45579114495/); the receipt and status are in [`G3_5_STATUS.md`](../../../godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/G3_5_STATUS.md). Visual self-review confirms readable AS54 scale beside the monsters and a visible existing spear prop pointing with the rightward thrust. This is a native preview technical pass, not owner art approval: actor, weapon, sockets, and source art remain pending; the Source A species mapping is unverified; PvE and physical-device QA remain on hold.

## Files

- Sources and source manifest: `godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/assets/source/`
- Source-only 1x reviews: `godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/g3_review_*`; native runtime and capture boundary: `godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/NATIVE_GODOT_RUNTIME_AND_CAPTURE_20261125.txt`
- Native phase evidence and visual status: `godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/evidence/native_g35_20261125_run45579114495/`, `G3_5_STATUS.md`
- Isolated preview: `godot/labs/combat_lab/spear01/van_long_diem_thuy/r1/van_long_diem_thuy_preview.tscn`, `vfx_spear_long_thrust_lab.gd`
- Native scripts: `vfx_spear_long_thrust_receipt_test.gd`, `vfx_spear_long_thrust_native_capture.gd`

The preview is isolated to this Spear batch. No shared catalog, workflow, ledger, inventory report, Combat V2, SaveService, or PvE configuration was edited. Follow-up changes and proof are on the existing Draft PR #72 branch; no merge or PvE enable was made.
