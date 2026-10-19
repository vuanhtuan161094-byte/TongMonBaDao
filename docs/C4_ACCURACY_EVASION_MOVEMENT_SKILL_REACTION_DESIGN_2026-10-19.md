# C4 — BỔ SUNG AUTHORITY DESIGN: Chính Xác / Né Tránh / Tốc Chạy / Kỹ Năng Né (2026-10-19)

Status: USER REQUESTED DESIGN OVERRIDE — IMPLEMENTATION OF COMBAT STATS / SIMULATION NOT YET AUTHORIZED IN GP01. This document supersedes "No normal Accuracy / Dodge" in \`docs/COMBAT_STATS_V2_SPEC.md §12.1\` **for a future dedicated migration packet only**; previous V2 formulas and tests remain live until the code/fixtures/save migration is separately approved, implemented and verified. GP01 changes only presentations, NEVER silently enables the new probability or prints MISS/DODGE when not emitted. Main checked at \`461caca1171462e0da092f21108c5c1733157ad9\`; C4 presentation baseline \`d160f97982f627460ab17661bdbfc572fe7c51b4\`.

## 1. New owner policy — gameplay, not random 100% avoidance

Owner explicitly requests:
1. Add **Chính Xác (Accuracy)**, **Né Tránh (Evasion)**, **Tỷ Lệ Trúng (effective Hit Chance)** with legitimate RPG build sources. **Không áp dụng tuyên bố cũ "không có Accuracy/Dodge".** Neither is a skill in itself; actual skill evade is an independent mechanic.
2. Boss warning real; no AI teleport/guaranteed 100% dodge. Use learned/equipped **né skill** when available and legal. Build movement speed should affect actor speed both in ordinary battles and in future region map, if those two view contexts use the same authoritative entity's attributes.
3. No costly full pathfinding AI solely for this. First scope: simple warning reaction based on currently visible circle, own speed, and a real skill. If cannot leave warning before release, take damage unless a genuinely authored status/skill or a legitimate accuracy miss applies.
4. **Crit remains existing V2**: base 5% chance, 1.50x multiplier, anti-crit reduction. Accuracy roll and crit roll must be separately observable and deterministic.

## 2. Existing code mismatch (verified)

- \`CombatStatsV2.derive\` currently outputs \`stats["move_speed"] = max(0,1 + move_speed_percent)\`. This is a dimensionless multiplicative coefficient from equipment/technique sources.
- \`MapBattleV2.setup\` currently **ignores** that derived \`stats["move_speed"]\` and defaults to role speed 2.35 (frontline) / 2.05 (other), except a direct \`row["move_speed"]\` override. Then \`step()\` uses \`actor["move_speed"] * 0.25\` per tick. A normal build-speed modifier will therefore NOT automatically apply to battle movement today.
- Normal monster speeds are currently hardwired to 2.2 or Boss 1.9 in setup, not the Source VL JX RunSpeed fields.
- \`CombatStatsV2.resolve_direct_hit\` has critical + defense + element + damage reduction but no accuracy or dodge stage. \`MapBattleV2._deal_direct\` spends RNG on crit, then on damage and optional followup; cannot insert a new hit roll without deliberately versioning deterministic seed/snapshot expectation.
- \`HuntingMapV2\` and visible sect MAP25 are separate from the arena actor; movement-speed propagation needs a canonical adapter/roster check. **Do not claim that fixing battle speed automatically fixes sect pedestrian velocity.**
- \`MapBattleV2\` has Boss AoE warning 1.00 s, radius 2.8 world units, steps 0.25 s. From warning CENTER, a naked frontline at 2.35 units/s cannot leave radius during 1 second. Faster builds can if speed exceeds (2.8+margin)/(available react time); if cannot, skill escape or take hit.

## 3. Proposed new combat formulas (DRAFT NUMERIC, owner requested feature, NOT BALANCE LOCKED)

**Two primary stats to register only in a separately approved Combat V2 migration:**
- \`accuracy\` (Chính Xác): integer/float score, default proposed 100 at baseline, non-negative; gear/skill can grow.
- \`evasion\` (Né Tránh): integer/float score, default proposed 5 at baseline, non-negative; gear/skill can grow.
- \`ignore_evasion\`: **per-skill/contextual modifier** only, not a seventeenth global headline stat without additional owner decision.
- \`effective_hit_chance\`: **derived transient percentage, NOT separately persisted**, depending on attacker accuracy, defender evasion and skill override.
- Proposed \`hit_probability = clamp( accuracy / (accuracy + evasion * (1 - ignore_evasion)), 0.10, 0.98 )\` for eligible direct targeted skills/basic hits with valid spatial geometry. Example baseline 100 vs 5 → 95.24%; against evasion 50 → 66.67%; with accuracy 200 against evasion 50 → 80%. Numbers illustrative, pending seed-driven balance; an explicit guaranteed-hit skill can bypass the probability *but not targeting and geometry*.
- Ordinary hit resolution: validate alive/target/range, then **ONE accuracy/evasion RNG roll per eligible attack commit**; on miss: zero damage, no lifesteal, no crit, no status-hit payload, no followup; emit authoritative \`attack_miss\`/ \`evaded_hit\` receipt with attacker, target, reason, context and actual chance (not a phantom zero-damage \`hit\`). On success: existing Crit Chance and Crit Damage exactly as previous contract, then defense/element/reduction/actual HP commit.
- DoT ticks, healing, shields, environmental damage, true/guaranteed hits and non-targeted effects don't each reroll accuracy unless their authored effect explicitly says otherwise. A missile physically missing a moving actor is a **separate** geometry miss. Effect Hit / Resistance only resolves STATUS landing after the direct hit as currently authored.
- AoE selection: real geometry + deterministic max-three selection, then eligible hit roll per selected actor **without refilling a missed target with a fourth actor**. No popup "NÉ" on a fourth actor merely untouched by max-three cap.
- Roll ordering must be versioned for replay/save: RNG consumption change makes prior exact-seed damage traces differ. Keep historical tests as a pinned baseline and introduce schema/migration path, not a silent overnight regression. Preserve event IDs and one settle/receipt per damaging source.
- Fail reasons to expose as distinct UI: \`TRUOT\` (accuracy roll failed), \`NE\` (defender evasion success as resolved), \`RA KHOI VUNG\` (physically out of AoE at release), \`VO HIEU\` (truly documented immunity) — **not interchangeable**, no fake feedback.

**Why this differs from JX sources:** Community JX1 material describes \`Accuracy / (Accuracy + Evasion * (1 - ignoreEvasion))\`, while VLTK1 Mobile reports Thân Pháp raises both and official patch notes mention Accuracy/Evasion. These are references, NOT a verified original client source binary or a mandate to import stats verbatim. Sources:
- https://groups.google.com/g/k15tpm/c/ehi1ENvpmXs (2011 community formula)
- https://www.jxcuulong.info/content.php?i=chiso_thuoctinh_hieuung (unofficial server table)
- https://volamm.vnggames.com/tin-tuc/tin-tuc/dieu-chinh-ky-nang-mot-so-mon-phai-tu-26-06.html (official VLTK1 Mobile game patch)
- https://www.bluestacks.com/vi/blog/game-guides/vo-lam-truyen-ky-1-mobile/vltk1m-character-system-upgrade-guide-vn.html (mobile character explainer)
Do not assume classic PC JX1 and Mobile mechanics are identical. No third-party code/assets copied.

## 4. Movement speed as a real build, not animation slider

Canonical bridge for future implementation:
\`base_role_speed * CombatStatsV2.stats["move_speed"] * validated_temporary_speed_multiplier\`
where derived move_speed default 1.00, existing role base 2.35 / 2.05; interpret \`+20%\` as 1.20x *distance per simulated second*, never the animation-frame count, never Attack Speed. Race/Root/gear/trait contributions must use registered source channels only. Use finite bounds/anti-exploit cap defined in focused packet (e.g. pilot candidate multiplier 0.25–3.00x) and actual world-bound stepping.

For true 0.25s tick, max normal displacement is \`effective_move_speed * 0.25\` world units; **no free extrapolation** when offscreen. If a sect/map unit's movement is unrelated authority today, name and implement that integration separately rather than reusing \`MapBattleV2\` positions in the sect map. All movement & warning strategies are deterministic across renderer FPS.

### Two different ways to escape a warned zone

**(A) Ordinary run:** on visible \`telegraph\` only, if actor is free to move, decide whether stepping straight to the nearest safe rim is physically possible; prefer shortest reachable legal path (single direct vector with bounds; no A* required for basic pilot). The actor uses its *own actual speed build* every tick. If warning ends before it exits, real damage still applies. If busy with committed cast, do not cancel for free; caster may be hit.

**(B) Equipped Evade Skill:** when caster actually LEARNED and equipped a specific skill with \`action_kind=evade_dash\` or \`evade_guard\`, has cooldown/resources ready, and a real warning threatens it, choose that action by fixed priority. Each skill specifies range, cast lock, skill duration/cooldown, positional legality and any i-frame/guard windows. Dash cannot pass through borders/obstacles; no instant universal immunity; no innate skill automatically given to all disciples. If a movement dash cannot exit AoE its owner can still be hit. Defensive \`evade_guard\` legitimately absorbs/reduces based on its own authored contract rather than fake miss. The first pilot might author ONE generic learned martial movement technique using legal skill source/permission, not invent JX skill IDs.
- If no learned evade skill: ordinary run if simple reaction policy is enabled and physically possible; otherwise eat hit. A character building only tank/DEF can choose guard & accept damage.
- No automatic generic random \`skill evade 100%\` at warning. AI complexity is intentionally bounded to one branch on warning and one step per V2 tick.

## 5. Actor and map UI/source provenance

Attribute panel: **Chính Xác**, **Né Tránh**, **Tỷ Lệ Trúng vs selected target** (tooltip computes target-specific and notes range), **Tốc độ Di chuyển** (actual world units/s or normalized score + derived real velocity), **Bạo kích**, **ST Bạo kích**, **Kháng Bạo kích**. Never show \`100% guaranteed\` unless authored skills truly guarantee. For currently unimplemented new stats mark "chưa có hiệu lực" and don't display a fake number as live.

During combat: actual authoritative \`hit\` ⇒ number, if crit ⇒ CRIT number, if heal/HoT ⇒ green +, if poison tick ⇒ DOC, actual \`attack_miss\`/ \`evaded_hit\` ⇒ TRƯỢT/ NÉ, actual \`evade_skill_used\` ⇒ icon/label, actual \`zone_exit_success\` ⇒ RA KHOI VUNG. **GP01 currently only renders already-supported hit/crit/heal/poison + active status**, never invent miss or zone dodges before simulation has events.

## 6. Implementation split and approval guard

**C4-GP01 (already explicitly authorized in this conversation):** \`godot/src/presentation/p3/map_battle_world_layer_v2.gd\` + one focused presentation test + docs/handoff. Only authentic numeric popups/status. No changes to CombatStatsV2, MapBattleV2, save/economy/Main. This packet may PASS only after official Godot 4.7.2 focused + 1280x720 UX evidence.

**C4-GP02-STAT (requires separate specific CODE packet):** CombatStatsV2 register accuracy/evasion and actual owner-authorised sources; MapBattleV2 and MonsterEncounterV2 hit roll + own damage receipts; schema and deterministic replay/version boundary; focused stats/unit/context + seeded hit/crit/miss Monte Carlo; no cosmetics backdoor; migrate affected snapshots with explicit strategy, pin old version. Base main must be rechecked immediately before code.

**C4-GP03-MOVE (requires separate CODE packet):** speed modifier bridge in MapBattleV2.setup plus scoped actual region map adapter, real anti-exploit caps, attack/cast/movement differences and actor speed readout, seeded trajectory comparisons, no gameplay fake translations.

**C4-GP04-EVADE-SKILL (requires separate CODE packet):** one author-approved learned/equipped dodge action using existing pilot V2 cast/status/skill engine, simple telegraph-triggered auto-use, cooldown and range. Candidate only after initial two gates. It may need 1–2 planning ticks and rollback of an unauthorised simulation update, so cannot be slipped into GP01.

**C4-GP05-BOSS:** afterwards tune boss radius/windup only based on physical possible-escape matrix and authentic 3 encounters. No blanket AI pathfinding.

Minimum hard tests:
- 100% miss chance only when explicitly authored (not from divide by zero); high defense is not random avoidance; accuracy + evasion produce expected seeded 1000-hit frequency tolerance registered in advance.
- Miss never consumes crit RNG, creates hit/HP/lifesteal/poison, grants extra attacks or bypasses pending casts.
- Base move speed vs gear buff Δdistance EXACT within tick ±epsilon; offscreen, fps30/60, snapshot/resume same.
- From AoE center under 1s warning at speed 2.35 radius 2.8, ordinary run does NOT fabricate a successful escape; with sufficient speed+time or legally used skill, departure can succeed.
- No actor gets an unlearned dash or invulnerability; same guard/consumption/cooldown rules for normal/Elite/Boss; no actor escapes if locked and uninterruptible.
- No fake \`DODGE\` popup for target #4 excluded by three-target cap; independent crit and hit chance; healing/DoT don't reroll.
- Multi-team/30 actors, Android landscape 1280×720 and performance scaled; V2 prior exactly-once/save/economy unchanged.
