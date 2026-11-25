# Phá Vây Khai Sơn R1 — source and runtime gate status

## Canonical contract

- Skill: `tmb.skill.blade.cuong_dao.active_01.human` — Phá Vây Khai Sơn · Nhân Giai.
- Contract remains `damage`, `single_target`, `target_limit=1`, `hit_count=1`, metal, range 8, cast 0.28 s, projectile speed 10, cooldown 8 s.
- VFX intent: compressed charge → one heavy red-bronze crescent in forward flight → one compact contact glint after a real hit receipt → two separated fading fragments. No area wave, second hit, ring, fabricated target, damage logic or gameplay edits.

## Original effect source

`SOURCE_SELF_REVIEW = PASS / recommend owner review` at intended 1× widths across silhouette, distinction from thin Sword qi, phase separation, red-bronze metal material, restraint and dark/light contrast. Each phase scored at least 4/5 in author self-review. The sheets and provenance are under `review/` and `source/`; these are source-scale checks, not native screenshots or owner approval.

`FORMAL_G3 = PENDING HUMAN/OWNER ART REVIEW`. `OWNER_ART_APPROVAL = PENDING`.

## Existing disciple and weapon integration

- Reuse the existing `AS50_FRONT_CLIPS_CANDIDATE.tres` four-frame attack clip selected by the ASCHAR bridge for male Blade disciples.
- Reuse AS50's candidate per-frame main-hand anchor and hand mask, plus the existing `curved_dao.png` library asset. The LAB supplies a preview-only direction/scale override so the tip points toward the target. Shared attachment/socket data and the game actor are not modified.
- Actor scale is `0.20` in 1280×720, about 67.6 px visible body height from the authored 338 px. Weapon is scaled relative to that hand socket.
- AS50/socket/weapon remain candidates. Their geometry has not been owner-approved or promoted to production.

## Focused runtime and native status

- Local Godot 4.7.2 strict import and script parse pass.
- Focused contract passes `checks=29`: exact skill metadata, existing AS50/DAO binding and socket masks, rightward tip alignment, unchanged production feature gate, and one real `MapBattleV2` V63 hit after the runtime monster moves. A second outside target remains unchanged.
- Local headless LAB runtime passes and prints the actual receipt marker. Headless runtime does not produce native framebuffer evidence.
- `G3.5_NATIVE = PASS / visual self-review PASS` on exact SHA `105b48ee77174c99974912208031c9bd263b0c74`, native run [#45586338616](https://github.com/vuanhtuan161094-byte/TongMonBaDao/actions/runs/45586338616). The 1280×720 charge, peak, receipt-bound contact, fade frame and MP4 are archived under `evidence/native_g35_20261125_run45586338616/`; review notes are in `NATIVE_VISUAL_SELF_REVIEW.md`. The V4 manifest still leaves receipt timestamp mapping pending, so runtime receipt timing is evidenced by focused/native runner logs and the captured LAB state rather than the manifest alone.

`PvE = HOLD_V63_OFF`. Formal owner visual approval, production actor/weapon approval, bright-terrain G3.6, no-HUD semantic G3.7, full G5 motion review and physical-device QA remain pending.

## Earlier blocker correction

The earlier blocker concluded no matching DAO overlay existed because it treated candidate `weapon_visible`/socket status as a production-validation prerequisite. That was too restrictive for a preview-only LAB. The current LAB uses the already bound AS50 candidate and `curved_dao` without changing their status or claiming production readiness. It still cannot close owner art or live gameplay gates.
