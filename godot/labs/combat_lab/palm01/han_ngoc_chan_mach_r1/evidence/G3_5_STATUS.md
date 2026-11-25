# Hàn Ngọc Chấn Mạch R1 — G3.5 native evidence boundary

**G3 source:** `PASS — self-review at 120 px / 64 px / 40 px`; owner art review remains pending.
**Combat V2 cast/receipt path:** `PASS` in a focused Godot 4.7.2 run.
**Native rendered actor/effect review:** `BLOCKED`; the managed shell has no active desktop renderer in this chat. Do not treat this as a visual PASS.
**PvE:** `OFF`.

## Focused run

Godot reported `4.7.2.stable.official.ed1daf0bf`. The Palm-owned preview scene and script are:

- `lab/han_ngoc_chan_mach_lab.tscn`
- `lab/han_ngoc_chan_mach_lab.gd`

The scene uses the real AS60 Palm candidate SpriteFrames at `res://assets/p3/baked_candidates/aschar60_candidate/AS60_PALM_CLIPS_CANDIDATE.tres`, with its `cast_right` windup and `attack_right` open-palm action. The actual monster target instance comes from `res://assets/actors/v5_sa_monster_1113031_1/actor.tscn` and walks while the cast is pending. Both are explicitly candidate/source art in a preview-only fixture.

The script calls `V63HumanSkillCombatSystem.try_cast` with the Palm candidate actor gate enabled only on its in-memory actor fixture, advances the actual target position during the 0.55 s windup, then calls `MapBattleV2._release_casts()` at the cast’s ready time. The exact cast, release, and positive one-target hit receipts are in `G3_5_RECEIPT.json`:

- Cast ID: `palm01_han_ngoc_preview_only/palm_lab_caster/1`
- Target position changed from `[5.0, 0.0]` at cast to `[5.5500002, 0.0]` at release, within the catalogue range of 6.0.
- One `skill_release`, one positive `v63_skill_hit` on `palm_lab_moving_monster`, damage `40.8`.
- No status, heal, cleanse, or slow event.
- The preview only shows the peak/contact sprites after the corresponding real receipt; the contact sprite is receipt-gated.

Run command:

```sh
XDG_DATA_HOME=/tmp/palm01_godot_data XDG_CACHE_HOME=/tmp/palm01_godot_cache XDG_CONFIG_HOME=/tmp/palm01_godot_config FONTCONFIG_CACHE_DIR=/tmp/palm01_fontcache godot --headless --path godot res://labs/combat_lab/palm01/han_ngoc_chan_mach_r1/lab/han_ngoc_chan_mach_lab.tscn
```

Relevant output:

```text
PALM_G35_CAST_PENDING id=tmb.skill.palm.han_ngoc_chuong.active_01.human cast_id=palm01_han_ngoc_preview_only/palm_lab_caster/1 ready=0.55 gate=OFF
PALM_G35_RECEIPT_PASS cast_id=palm01_han_ngoc_preview_only/palm_lab_caster/1 release=1 hit=1 target=palm_lab_moving_monster damage=40.8
PALM_G35_NATIVE_CAPTURE_BLOCKED reason=viewport_image_unavailable_headless_dummy_renderer
process exit code: 2
```

The receipt path was exercised by a real `MapBattleV2` and the existing `V63HumanSkillCombatSystem` / `V63PalmSkillCombatSystem` APIs. No SaveService, persistent game state, shared runtime, release gate, or PvE path was used.

## Exact G3.5 blocker

The headless Godot run selects the dummy renderer. `ViewportTexture.get_image()` returns null, so it cannot save a rendered 1280×720 capture. The environment status reports remote desktop enabled but state unknown; this chat does not expose the desktop JavaScript control tool, and the Cloud desktop skill fallback says not to enable it when unavailable. Therefore actor scale, palm placement, wave motion, contact placement, and final compositing remain unreviewed in a native rendered capture.

The LAB intentionally exits with code 2 after recording the successful simulation receipts and the capture blocker. It does not substitute a Python/composited mock for Godot. Keep the scene preview-only until a real Compatibility-rendered capture can be inspected and owner art approval is completed.
