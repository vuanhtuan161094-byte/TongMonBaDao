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


---

## 2026-10-19 — C4 JX1 source assets, ranks and touch inspector (owner-authorized)

**Base:** `c4-jx1-ui-readability-hardening-20261019` pinned `8f14d171744b3d332f198dc5fca9c2547a71989c`.
**Code branch:** `c4-jx1-rank-and-fx-source-20261019`; `main` still at `461caca1171462e0da092f21108c5c1733157ad9` when checked.
User expressly affirmed permission to use all owner-supplied assets in this personal project, 2026-10-19. No claim that the original VLTK publisher licensed distribution to unrelated third parties.

**VERIFIED ASSET IMPORT (all SHA-256 recomputed from Drive binary bytes before commit):**

| Godot relative basename under `assets/combat_v4/jx1_skill_fx/` | Bytes | SHA-256 | skill, stage |
| --- | ---: | --- | --- |
| `3dfcabc2.webp` | 35210 | `84c63b5352a2873c05370c5d5c884e72aab07c4f2073af905e0f45b05605bb52` | #158 precast |
| `aa93d577.webp` | 213656 | `bbd0e0c189249e9aa44920d6fa9fe6e61caf26f18530244501f1c2fae732a53c` | #158 cast |
| `361b4525.webp` | 16286 | `4052de409053ad3dc3562795c0f0d93e96029387169c7f42a4dca5d104352e13` | #158 impact |
| `40a1c4ff.webp` | 228498 | `b33a62e2e78957f85cee8d44991a5a482ae39dd3aed3e069d405a5dada8f4448` | #63 cast (16 dirs) |
| `1fffed7e.webp` | 12602 | `a22e5b9148a7d36e73dfea69cba271472e8700150f235da32fd5d36e212a5d2c` | #63 impact |
| `2f8c6d50.webp` | 15714 | `621d884fd24c9fffbde197b667f734c0b88094fae3f3afdc6d37586f3ee6ab67` | #93 precast |
| `e8178d06.webp` | 51244 | `84e3ae2bb64af51bb44384c5d63064ccfbe5db4b0c4b3f18c28357578632f362` | #93 impact |
| `bar_hp.png` under `assets/combat_v4/jx1_ui/` | 354 | `2f4a6395548e64bc88f2cb951084a1ca017e85e5648abe19cb31e9f2ab2c14c5` | owner Võ Lâm Idle, 106×11 RGBA original UI fill |

Google Drive source folders: Võ Lâm Idle `https://drive.google.com/drive/folders/1OYhASFXTBNK4ky3ln2p_m7g7qGbyYDPm`; Giang Hồ Chi Chiến `https://drive.google.com/drive/folders/19mdpwyTf2tzYblpfOg0CARi-JHdO70ZR`. Imported via authenticated Drive → GitHub blob/tree without rescaling source bytes; no commercial licensing representations.

**Direct C4 presentation code:** rank label uses only `DiscipleRealmProgressV2.CULTIVATION_REALM_NAMES` + actual raw `realm_index/floor_index` provided to `layer.set_actor_view_metadata()`. Body uses independent `BODY_REALM_NAMES` + source body coordinates; view can also read a genuine linked `DiscipleState.v2_realm_progress` when valid. V2 `MapBattleV2.setup` strips original source realm and name, so the generic view adapter requires explicit original metadata from its encounter caller, not guessing from combat stats. Monster tier prefix Boss/Tinh Anh derives from actual snapshot tier; pilot source monsters created at realm2/floor1. Real linked `DiscipleState.display_name` is preferred over synthetic role badge. Touch/mouse actor pick displays both tracks and actual HP read-only. Pilot's six members use actual stats inputs CombatStatsV2.derive(2,1,2,1) and display corresponding rank; it is a fixture, not a production recruit. No changes to saved DiscipleState or MonsterCatalogueV2.

**Source FX adapter:** existing Source VL manifest remains available; separate `jx1_skill_fx/fx_manifest.json` provides verified, opt-in WebP frame rects. Only real `pilot_impact(pilot_id=jx_wudang_158, effective_damage>0)` → #158 impact sheet, `pilot_impact(...jx_wudu_63, damage>0)` → #63 impact sheet, and `pilot_cast(pilot_id=jx_emei_93)` → #93 precast; no duplicate on refresh, no effect on HP or roll sequence. No FX on zero effective impact. #158 cast, #63 16-dir cast, #93 impact sheets imported but mapping/preview **PENDING**; #15/#159 have missing source binding. No fake `MISS`/`DODGE`, effect playback does not change cast timing.

**Test/evidence:** expanded `c4_gp01_combat_feedback_receipts_test.gd` verifies canonical Tu Vi/Body labels, data missing/invalid fail-closed, linked name, source HP strip. New `c4_jx1_rank_fx_source_test.gd` checks 3 imported clips decoded with real Godot, durations/end frames, exact event cues, zero-damage omission, refresh dedupe, unchanged sim HP/RNG/time. No Godot 4.7.2 executable in current environment; official exact-HEAD import/focused Windows runtime, screenshot/UX and Android FPS **PENDING** (tests authored, not run). No CI, FULL, merge, main/PR20/Economy/SaveService/CombatStatsV2/MapBattleV2 touched. Static review only; the one-click isolated Windows ZIP will be delivered directly in ChatGPT pinned to final HEAD.

**Remaining product gaps, not fabricated:** permanent real production name+realm bridge on all hunting entrypoints, skill teaching/equipping outside 5 pilot IDs, missing #15/#159 VFX, remaining four WebP atlas/movement mappings, true linked/source cast rigs, JX1 exact font/color/camera proof, real 30v40 readability/FPS, real Accuracy/Evasion roll/miss and learned evade skill simulation migration. These require relevant source evidence, testing, or separately-authorized gameplay work; do not claim feature completion.


---

### 2026-10-19 — Backend BE01 identity preservation audit

Pinned predecessor: `f757c5f162f85ebccda936b06ba8a06b07eac003`, isolated new branch `c4-backend-identity-contract-20261019`.

User requested a backend gap review. Rather than silently alter existing Combat V2 RNG/replay balance, implemented a **source-only actor identity preservation contract**: disciple names plus Tu Vi and Luyện Thể 30×10 inputs pass `DiscipleCombatLoadoutV2.build` → `MapBattleV2.setup` → `MapBattleSnapshotV2` → HUD, and monster canonical names/realm follow `MonsterCatalogueV2.create_actor` → battle → saved hunting. Invalid source coordinates fail admission, legacy absent coordinates remain absent. `HuntingPveRunV2.restore_state` rejects saved monster name/realm metadata that conflicts with seeded canonical spawn; historical V1 snapshots without those fields are still supported. Kept presentation's pilot view override only for fixture-specific views. Added dedicated focused BE01 test and adjusted old GP01 HUD expectation for authentic monster rank. **No combat-damage/stat formulas, RNG, HP, hitboxes, cooldown, injury or rewards changed.**

Code written to GitHub, static inspection only. Official Godot 4.7.2 import, focused tests, inherited battle snapshot/5-tier PvE and GP02C1 Injury regressions **PENDING**, not claimed PASS. Deferred substantial C4-GP02 accuracy/evasion RNG migration, C4-GP03 movement/telegraph reactive AI, C4-GP04 learned evade, and JX skills outside pilot until separate scoped authorization. Production move speed from equipped gear is already explicitly bridged by `DiscipleCombatLoadoutV2.build`; do not report as globally broken.
