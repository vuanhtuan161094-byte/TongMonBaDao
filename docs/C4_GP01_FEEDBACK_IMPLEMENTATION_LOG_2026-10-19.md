# C4-GP01 — Implementation audit and QA (2026-10-19)

**Scope**: real feedback UI from canonical MapBattleV2 events; user separately directed Accuracy/Evasion design override. Existing parent PRES01 head d160f97982f627460ab17661bdbfc572fe7c51b4; main inspected 461caca1171462e0da092f21108c5c1733157ad9.

- Real event `hit.damage` displays final settled damage at true target world position; `critical=true` creates CRIT label. `hit.lifesteal` displays actual healed amount at attacking character. `heal.amount` and `pilot_hot_tick.amount` display actual heal. `pilot_poison_tick.damage` displays DoT. No popup for zero or NaN values.
- `skill_hit` and `pilot_impact` are not additional damage receipts. Event cursor + index prevents double rendering on refresh; no authoritative damage/event lost.
- Combat display uses no gameplay RNG and never changes HP, simulation position, real crit or cooldown. Maximum 28 floating popups, 0.8 second lifetime, deterministic visual lanes, prioritizes critical/heals when over cap, 13–16 px text with background; real source actor coordinates, scene view camera projection.
- Pilot poison and HoT stacks, frontline guard, Shaolin guard and party-defense tags are computed from authoritative current statuses and `battle.now`, never from display-only elapsed time. Max two tags displayed at any one actor to limit crowding.
- New focused test: `godot/tests/presentation/c4_gp01_combat_feedback_receipts_test.gd` uses one authentic MapBattleV2 battle to require a genuine seeded critical, one visual popup per real HP commit, no double from skill_hit/pilot_impact or repeated refresh, correct source category and current status expiry, no mutation to battle actors, RNG, time/events.
- User explicitly reversed old no-Accuracy/Dodge design; see `docs/C4_ACCURACY_EVASION_MOVEMENT_SKILL_REACTION_DESIGN_2026-10-19.md`. GP01 does not enable new stats/miss/skill dash in simulation because that changes RNG and snapshot contracts. This needs separate scope/packet. The derived move_speed channel currently DOES NOT automatically propagate into MapBattleV2's role movement speed.
- **QA truth:** Static implementation/checkpoint only; official Godot 4.7.2, import, test, full adjacent existing focused regressions, scene 6v5 smoke, Windows GUI and owner UX on THIS HEAD are ALL PENDING. Old v5 six PASS on a different SHA does not transfer. No CI/FULL/merge, no main/PR20/Economy/SaveService edits.
- Windows helper ZIP must pin exact new branch HEAD; clone and save isolated TEMP; write `C4_GP01_QA_LOGS.zip` BESIDE launcher on all successes/failures. Owner supplies actual log/archive + short video; fix evidenced regressions without silently changing authority.


---

## 2026-10-19 — JX1 UI SOURCE-FIRST PRESENTATION FOLLOW-UP (owner-authorized)

**Base verified**: `c4-gp01-combat-feedback-20261019` = `f2ea6852823d8bf5f7a1451c0cb975a0773364af`. Current isolated branch: `c4-jx1-ui-source-first-20261019`. `main` observed `461caca1171462e0da092f21108c5c1733157ad9` and remains untouched.

### Evidence-to-GP01 comparison

| Visual concern | JX1 screen / source evidence | GP01 prior state | Implemented now |
| --- | --- | --- | --- |
| Combat damage | Classic VLTK PC screenshot reference shows integer floating damage with colored text above fighters; this is **visual observation**, not official renderer code | Amounts below 10 could show one decimal | Always round to integer *for glyph only*; exact receipt float preserved; one popup per settlement |
| Player/enemy identity | Classic PC JX1 shows names floating at actors and small HP bars | Role abbreviations for disciples; no canonical enemy name | Authored actor label when available, canonical `MonsterCatalogueV2.SPECIES` for monsters; un-authored disciples keep stable class+slot tag |
| Font, color, damage backdrop | Reference has small glyphs with dark stroke, distinct contrasting colors, not opaque per-number boxes | Background-filled popups, neutral damage tint | Godot font (no copied JX font), outlined text, red-orange damage, gold CRIT, green healing/lifesteal, purple poison; visual-only |
| Camera | Original overview sees surrounding battlefield and modest sprite scale; exact JX engine camera values not proved | Spectator zoom auto-up to 2.10 causes close framing | Opt-in pilot `spectator_zoom_ceiling=1.0`; generic spectator code retains 2.10; JX game-reference metric **not claimed** |
| FX/HP/order | Reference keeps silhouettes/ground beneath labels and top HUD | Source VL actor atlas, genuine effects, late HUD pass already present | Preserve source atlas and true actor feet; drawn sprite→HP/name/status→receipted text, no false cast |
| Rights | Owner Drive **Võ Lâm Idle** README: unofficial fan-made, research/learning only; **Giang Hồ Chi Chiến** `docs/VERIFICATION.md`: VLTK mirror rights unresolved | Source VL legally permitted assets already in game | Only reuse code-owned canonical names/source atlas and Godot rendering; **NO new JX binaries, fonts or art imported** |

Reference provenance: primary visual references from [Thanh Niên historic VLTK PC screenshot](https://thanhnien.vn/vo-lam-truyen-ky-lieu-con-co-ngay-mai-1851118555.htm), [VNG 2017 webgame screenshot (not mistaken for 2005 PC)](https://gamek.vn/webgame-vo-lam-truyen-ky-vng-hoi-tu-nhung-tinh-nang-hoi-uc-20170428172736751.chn), and official [VLTK1 Mobile view-distance settings](https://volamm.vnggames.com/tin-tuc/huong-dan/huong-dan-thiet-lap-tuy-chinh-cau-hinh.html). Community [jx1client-axmol](https://github.com/locthanhtx/jx1client-axmol) is an unofficial client reference; its source/SPR redistribution rights are **not verified**. Private Drive evidence includes owner-supplied two folder URLs in the issue/context. No claims of byte-for-byte UI parity or source ownership.

**Focused regression**: extended `c4_gp01_combat_feedback_receipts_test.gd` for integer glyphs, authentic canonical monster name, authored actor name, no extra popup, and 1x view goal. Existing seven focused tests must be run on official Godot 4.7.2 exact branch HEAD. This environment has **no Godot executable and no network git clone**, hence Windows Godot import/tests, actual 1280×720 screenshot, Android memory/FPS and owner UX signoff **PENDING**. No CI/FULL/merge. GP01 7/7 historic user-reported result applies only to owner-tested previous SHA; it must NOT be carried forward to this branch.

**Scope**: only `godot/src/presentation/p3/map_battle_world_layer_v2.gd`, `godot/src/presentation/p3/combat_v4_jx_pilot.gd`, adjacent focused regression, and these documents. One-click user-facing QA ZIP pinned to exact final SHA is shipped via ChatGPT, not committed binary.

---

## 2026-10-19 — Second-pass review, JX UI readability hardening

Previous branch `c4-jx1-ui-source-first-20261019` at `5cd6889` verified; user unavailable for Windows and authorized next presentation pass. Created independent `c4-jx1-ui-readability-hardening-20261019`. Audited actual renderer and `MapBattleV2._event`: combat events append up to MAX_EVENTS=2400 and never shift/rotate; the index cursor is consistent with this bounded log. Did not modify this simulation/event authority. Public classic JX1 PC capture reference: https://thanhnien.vn/vltk-tinh-trong-thien-ha-xin-dung-thach-thuc-tinh-yeu-1851119381.htm ; this is only style evidence and does not establish camera/FPS/font values.

**Observed source defects & patches:**
1. `layout_hp_overlays` originally processed all name/status/HP entries in incidental per-actor iteration order, allowing title/status to evict HP from its intended near-character slot. Added deterministic HP-first/name-second/status-third placement, preserving caller's output order and not changing physics.
2. Numeric events originally queried the actor's *current* interpolated position on every draw frame. Damage numbers therefore followed a moving wolf. Frozen `world_origin` is sampled when the true event reaches the view and reprojected through the existing camera transformation; supports pan without actor-position mutation.
3. The max 28 queue originally always evicted an item even when a new *ordinary* hit arrived with a queue full of protected CRIT/heal popups. Now common hit is dropped in that exact case; high-priority heal/crit/lifesteal may evict the oldest protected one while never exceeding the cap. Only discarded cosmetic popups, not simulation event receipts.
4. Numeric floating text previously painted after HUD; changed draw ordering to keep crucial HP/name/status labels visible above text while preserving source FX below sprites.

**Adjacent focused regression:** GP01 receipt script now covers the 3-entry contested HUD, original-arrangement fidelity, deterministic collision avoidance, static source-world anchor, 28-crit saturation, healed popup admission. Simulation snapshots/events/RNG are not modified by the view. Code SHA and official Windows data still need verification; no claim of 4.7.2 runtime PASS, frames, FPS, memory or UX. No borrowed JX1 binary/file/license claim, no CI/FULL/merge.

